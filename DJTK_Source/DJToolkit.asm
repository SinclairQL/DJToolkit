QMON2      equ     0

*=======================ex qmac_qmac=================================*
* DJTOOLKIT - Mini toolkit for Dilwyn to do with as he pleases.      *
*                                                                    *
* VERSION 1.16                                                       *
*                                                                    *
* Copyright - Norman Dunbar                                          *
*             January - March 1993 and on and on and on and on ....  *
*====================================================================*
* STACK NEWS.                                                        *
*                                                                    *
* See STACK_DOC on the disc for stack information discovered by QMON *
* and me during the testing of this toolkit.                         *
*====================================================================*
* REMark $$asmb = 'DJToolkit', 0, 12                                 *
*====================================================================*
* AMENDMENT HISTORY                                                  *
*                                                                    *
* 26/01/93 - Started writing version 1.00.                           *
*--------------------------------------------------------------------*
* 05/03/93 - Version 1.10 created by adding SET_XINC, SET_YINC,      *
*            USE_FONT as new procedures. In addition, MOVE_MEM has   *
*            been optimised to use LONG moves wherever possible as   *
*            Dilwyn complained about it being too slow when moving   *
*            screens around.                                         *
*--------------------------------------------------------------------*
* 23/03/93 - Version 1.10 not yet fully tested but the functions     *
*            DISPLAY_WIDTH, WHERE_FONTS & QPTR added at Dilwyn's     *
*            request.                                                *
*--------------------------------------------------------------------*
* 24/03/93 - Further playing to get error codes returned plus the    *
*            SCREEN_MODE function now returns 2, 4, 8 or any other   *
*            result passed back in D1.B from the trap. This should   *
*            be suitable for ATARI ST/QLs or even the Graphics card  *
*            (if and when) from Miracle.                             *
*--------------------------------------------------------------------*
* 16/05/93 - Dilwyn discovered that DISPLAY_WIDTH returns a garbage  *
*            result if run on an 'AH' or 'JM' ROMmed QL. This is due *
*            to the offset at $64(channel definition block) being    *
*            the top word of SD_KBD and not the screen width. QDOS   *
*            version 1.04 onwards is ok. Now testing for an older    *
*            QDOS version and if found simply returns 128. Thanks to *
*            Ralf (Bundesralf) for an assembler listing that does a  *
*            similar test. Version now 1.11 to compensate.           *
*--------------------------------------------------------------------*
* 14/06/93 - Dilwyn discovered that a bug had been introduced into   *
*            MOVE_MEM due to the new 'optimisation' that was added.  *
*            The bug corrupted the first few bytes of a memory area  *
*            being moved with overlap and both addresses were even.  *
*            This has now been fixed so that there is more & better  *
*            checking done to figure out how the move is to be done. *
*            Version now at 1.12.                                    *
*--------------------------------------------------------------------*
* 15/06/92 - The variable QMON2 added, in the source files on disc   *
*            it will always be set to 0, but when testing, it is set *
*            to 1 and a TRAP #15 instruction is assembled into the   *
*            COUNT_PARS subroutine. This will cause a jump into QMON *
*            if present and activated.                               *
*--------------------------------------------------------------------*
* 19/07/93 - Fixed obscure bug in FILE_POSITION. If run on a Gold    *
*            Card, it works fine, hangs a Trump Card with no visible *
*            results and crashes a 128K QL by filling the screen up  *
*            from the bottom to the top. Turns out to be FS_POSRE    *
*            trashes A1 after the TRAP #3, it is in the book so I    *
*            should have seen it !  Version upped to 1.13 but why    *
*            does the Gold Card work ?                               *
*--------------------------------------------------------------------*
* 12/06/94 - The following new commands added by request :-          *
*                                                                    *
*            FUNCTIONS : MAX_DEVS, MAX_CON, DJ_OPEN, DJ_OPEN_IN,     *
*                      DJ_OPEN_NEW, DJ_OPEN_OVER, DJ_OPEN_DIR        *
*                      PEEK_FLOAT                                    *
*                                                                    *
*            PROCEDURE : POKE_FLOAT                                  *
*            Version updated to 1.14 to cover changes.               *
*--------------------------------------------------------------------*
* 16/06/94 - Dilwyn phoned, 'what happened to FILLMEM then ?', oops  *
*            these 3 routines (_B, _W & _L) were left out of 1.14. I *
*            have added them to the new latest version which is 1.15 *
*--------------------------------------------------------------------*
* 27/02/13 - A long hidden bug. GET_STRING gived EOF errors is the   *
*            string to be read is of zero length. Strangely enough   *
*            we get EOF on QPC ram discs, but it works fine on QPC   *
*            win discs. Weird or what?                               *
*====================================================================*

           section code

*--------------------------------------------------------------------*
* Include files, Dilwyn should already have these. QMAC looks in     *
* filename first, then DATA_DEV$ & filename finally, it looks in     *
* PROG_DEV$ & 'INCLUDE_' & filename, then it fails !                 *
*--------------------------------------------------------------------*

           include win1_qmac_include_trap1_hdr
           include win1_qmac_include_trap2_hdr
           include win1_qmac_include_trap3_hdr
           include win1_qmac_include_vectors_hdr
           include win1_qmac_include_errors_hdr
           include win1_qmac_include_sysvars_hdr
           include win1_qmac_include_basic_hdr
           include win1_qmac_include_chantab_hdr
           include win1_qmac_include_windows_hdr

*--------------------------------------------------------------------*
* Other equates not included in the above header files               *
*--------------------------------------------------------------------*
me         equ     -1                  This job
timeout    equ     -1                  Infinite timeout

version    equ     '1.16'              Version, used by DJTK_VER$

get_word   equ     $00                 Offset on CA_GTINT for words
get_float  equ     $02                 Ditto for floats
get_string equ     $04                 Ditto for strings
get_long   equ     $06                 Ditto for longs
f_length   equ     $00                 Offset for file length (long)
f_type     equ     $05                 Ditto - file type (byte)
f_data     equ     $06                 Ditto - file dataspace etc (long)
f_update   equ     $34                 Ditto - file update date (long)
f_backup   equ     $3C                 Ditto - file backup date (long)
sd_linel   equ     $64                 Offset for display_width
iop_flim   equ     $6C                 Find window LIMits
iop_pinf   equ     $70                 Get pointer info trap key

*--------------------------------------------------------------------*
* Procedure/function link information and routine to link to Basic,  *
* for inclusion with QLiberator try '$$asmb = filename, 0, 12' which *
* should point to the start of the definitions.                      *
*--------------------------------------------------------------------*
start      lea.l   def_block,a1        Pointer to definition block
           move.w  BP_INIT,a2          Vector to be called
           jsr     (a2)                Do it
           rts                         Exit

*--------------------------------------------------------------------*
* Procedure definition block                                         *
*--------------------------------------------------------------------*
num_procs  equ     14
p_chars    equ     173

def_block  dc.w    num_procs+p_chars+7/8

           dc.w    rel_heap-*
           dc.b    12,'RELEASE_HEAP'

           dc.w    abs_pos-*
           dc.b    12,'ABS_POSITION'

           dc.w    rel_pos-*
           dc.b    13,'MOVE_POSITION'

           dc.w    put_byte-*
           dc.b    8,'PUT_BYTE'

           dc.w    put_word-*
           dc.b    8,'PUT_WORD'

           dc.w    put_long-*
           dc.b    8,'PUT_LONG'

           dc.w    put_float-*
           dc.b    9,'PUT_FLOAT'

           dc.w    put_string-*
           dc.b    10,'PUT_STRING'

           dc.w    poke_strg-*
           dc.b    11,'POKE_STRING'

           dc.w    move_mem-*
           dc.b    8,'MOVE_MEM'

           dc.w    flush_chan-*
           dc.b    13,'FLUSH_CHANNEL'

           dc.w    use_font-*
           dc.b    8,'USE_FONT'

           dc.w    set_xinc-*
           dc.b    8,'SET_XINC'

           dc.w    set_yinc-*
           dc.b    8,'SET_YINC'

           dc.w    poke_float-*
           dc.b    10,'POKE_FLOAT'

           dc.w    fillmem_b-*
           dc.b    9,'FILLMEM_B'

           dc.w    fillmem_w-*
           dc.b    9,'FILLMEM_W'

           dc.w    fillmem_l-*
           dc.b    9,'FILLMEM_L'

           dc.w    0                   End of procedure list

*--------------------------------------------------------------------*
* Function definition block                                          *
*--------------------------------------------------------------------*
num_fns    equ     38
f_chars    equ     374

           dc.w    num_fns+f_chars+7/8

           dc.w    djtk_vers-*
           dc.b    9,'DJTK_VER$'

           dc.w    sys_vars-*
           dc.b    16,'SYSTEM_VARIABLES'

           dc.w    scr_mode-*
           dc.b    11,'SCREEN_MODE'

           dc.w    scr_base-*
           dc.b    11,'SCREEN_BASE'

           dc.w    res_heap-*
           dc.b    12,'RESERVE_HEAP'

           dc.w    set_head-*
           dc.b    10,'SET_HEADER'

           dc.w    read_head-*
           dc.b    11,'READ_HEADER'

           dc.w    level2-*
           dc.b    6,'LEVEL2'

           dc.w    file_pos-*
           dc.b    13,'FILE_POSITION'

           dc.w    file_len-*
           dc.b    11,'FILE_LENGTH'

           dc.w    file_data-*
           dc.b    14,'FILE_DATASPACE'

           dc.w    file_type-*
           dc.b    9,'FILE_TYPE'

           dc.w    file_bkdt-*
           dc.b    11,'FILE_BACKUP'

           dc.w    file_updt-*
           dc.b    11,'FILE_UPDATE'

           dc.w    get_byte-*
           dc.b    8,'GET_BYTE'

           dc.w    get_wrd-*
           dc.b    8,'GET_WORD'

           dc.w    get_lng-*
           dc.b    8,'GET_LONG'

           dc.w    get_flt-*
           dc.b    9,'GET_FLOAT'

           dc.w    get_str-*
           dc.b    10,'GET_STRING'

           dc.w    fetch_str-*
           dc.b    11,'FETCH_BYTES'

           dc.w    peek_str-*
           dc.b    11,'PEEK_STRING'

           dc.w    search_i-*
           dc.b    8,'SEARCH_I'

           dc.w    search_c-*
           dc.b    8,'SEARCH_C'

           dc.w    dev_name-*
           dc.b    8,'DEV_NAME'

           dc.w    free_mem-*
           dc.b    11,'KBYTES_FREE'

           dc.w    free_byte-*
           dc.b    10,'BYTES_FREE'

           dc.w    check-*
           dc.b    5,'CHECK'

           dc.w    disp_width-*
           dc.b    13,'DISPLAY_WIDTH'

           dc.w    qptr-*
           dc.b    4,'QPTR'

           dc.w    w_fonts-*
           dc.b    11,'WHERE_FONTS'

           dc.w    dj_open-*
           dc.b    7,'DJ_OPEN'

           dc.w    dj_in-*
           dc.b    10,'DJ_OPEN_IN'

           dc.w    dj_new-*
           dc.b    11,'DJ_OPEN_NEW'

           dc.w    dj_over-*
           dc.b    12,'DJ_OPEN_OVER'

           dc.w    dj_dir-*
           dc.b    11,'DJ_OPEN_DIR'

           dc.w    peek_float-*
           dc.b    10,'PEEK_FLOAT'

           dc.w    max_devs-*
           dc.b    8,'MAX_DEVS'

           dc.w    max_con-*
           dc.b    7,'MAX_CON'
           dc.w    0                   End of function list




*====================================================================*
* DJTK_VER$ = return the version of the toolkit.                     *
*--------------------------------------------------------------------*
* I dont want any parameters, so check that there are none.          *
*--------------------------------------------------------------------*
* Stack uses 0 bytes and requires 2 + 4 bytes for the result.        *
*====================================================================*
djtk_vers  bsr     count_pars          How many parameters ?
           beq.s   dv_0_ok             I got none

dv_badpar  moveq   #ERR_BP,d0          Bad parameter

dv_error   rts                         Quit & complain

dv_0_ok    moveq   #6,d1               I need 6 bytes
           bsr     bv_get              Go get them
           move.w  #4,0(a6,a1.l)       Stack the length
           move.l  #version,2(a6,a1.l) Stack the version
           move.l  a1,BV_RIP(a6)       New stack pointer
           moveq   #1,d4               Result is a string
           moveq   #0,d0               No errors
           rts                         Exit


*====================================================================*
* SYSTEM_VARIABLES = return address of the system variables.         *
*--------------------------------------------------------------------*
* I dont want any parameters, so check that there are none. If so,   *
* simply call the MT_INF trap, stuff the returned A0 into D1 & float *
* it back to SuperBasic. Easy stuff to start with.                   *
*--------------------------------------------------------------------*
* Stack uses 0 bytes and requires 6 bytes for the result.            *
*====================================================================*
sys_vars   bsr     count_pars          How many parameters ?
           beq.s   sv_0_ok             I want none

sv_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra.s   sv_ret_d1           Exit

sv_0_ok    bsr     mtinf               Do MT_INF trap
           move.l  a0,d1               A0 = system variable address

sv_ret_d1  moveq   #6,d2               Request 6 bytes for result
           bra     float_bv            Return d1.L as float


*====================================================================*
* SCREEN_MODE = return current screen mode (2, 4, 8 or whatever)     *
*--------------------------------------------------------------------*
* Another relatively easy one, call MT_DMODE in enquire mode (?) and *
* if the return value in D1.B is zero, this is mode 4 so stick 4 in  *
* D1.W and return it as an integer, otherwise the mode is in D1.B so *
* extend it to word and return it. Errors are returned via D1.W too. *
*--------------------------------------------------------------------*
* Stack uses 0 bytes and requires 2 for the result.                  *
*====================================================================*
scr_mode   bsr     count_pars          How many paramaters ?
           beq.s   sm_0_ok             There were none

sm_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra.s   sm_ret_d1           Quit

sm_0_ok    moveq   #MT_DMODE,d0
           moveq   #-1,d1              Read mode
           moveq   #-1,d2              Read display (don't care)
           trap    #1                  Do it (it will not fail !)

sm_ret_d1  moveq   #2,d2               Space required for result
           tst.b   d1                  Check mode
           bne.s   mode_8              Mode is 8

mode_4     moveq   #4,d1               Return 4 for mode 4
           bra     integer_bv

mode_8     ext.w   d1                  Return result for any other mode
           bra     integer_bv


*====================================================================*
* DISPLAY_WIDTH = return number of bytes in one line on the screen,  *
*                this is NOT the width of a window but the display.  *
*--------------------------------------------------------------------*
* There must be one parameter and it must be preceeded by a hash (#) *
* to signify a channel number. This is converted into a channel id   *
* and an EXTOP is called to pick up the word at offset $64 in the    *
* channel definition block. This is the width of the actual display  *
* in bytes as used to step from one line to another. This is a nice  *
* little routine that should keep Phil Borman happy, as well as any  *
* other Atari users who have funny screen modes !                    *
*--------------------------------------------------------------------*
* Modified to test for a QDOS version less than 1.04 - these return  *
* a wrong result. The offset at $64 is the top word of SD.KBD on the *
* older ROMs. Thanks Ralf.                                           *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result as most of the    *
* code is part of SCREEN_BASE below.                                 *
*====================================================================*
disp_width moveq   #SD_LINEL,d7        Flag & offset for DISPLAY_WIDTH
           bra.s   sb_do_it            Skip

*====================================================================*
* SCREEN_BASE = return base of screen for given channel number       *
*--------------------------------------------------------------------*
* A bit more difficult. There must be only one parameter and it must *
* be preceeded by a hash (#) to signify a channel number. Convert it *
* into a channel id and call an EXTOP routine on that channel id to  *
* obtain the address of the base of the screen that that channel is  *
* opened into. Any non screen channels will return  an error from    *
* SD_EXTOP so there is no problems there.                            *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
scr_base   moveq   #SD_SCRB,d7         Flag for SCREEN_BASE (& offset)

sb_do_it   bsr     count_pars          How many parameters ?
           moveq   #6,d2               Stack space required (for errors)
           subq.w  #1,d0               Should be only 1
           bne.s   sb_badpar           Oops...
           bsr     check_hash          Was there a hash ?
           bne.s   sb_hash_ok          Yes

sb_badpar  moveq   #ERR_BP,d1          Set up error code
           bra     float_bv            Stack not yet used !

sb_badpar2 moveq   #ERR_BP,d1          Error code (again)
           bra     float_d1            Stack has been used !

sb_error   rts                         Return it to SuperBasic

sb_hash_ok moveq   #get_long,d0        Signal CA_GTINT required
           bsr     get_params          Get our parameter as a long integer
           bne.s   sb_error            Oops...
           moveq   #2,d2               Just in case of an error
           move.l  0(a6,a1.l),d0       Get channel number
           bmi.s   sb_badpar2          Negative is bad news
           bsr     get_chan            Convert to channel id in A0
           bne.s   sb_ret_d0           Id is duff !

sb_open    moveq   #sd_extop,d0        Prepare to use the channel
           move.w  d7,d1               Get the offset required
           moveq   #timeout,d3         Take all the time in the world
           lea.l   sb_extop,a2         The routine to call
           trap    #3                  Do it
           tst.l   d0                  Did it work ?
           beq.s   sb_ret_d1           Yes, exit with screen address/width

sb_ret_d0  move.l  d0,d1               Set up the error code for return
           bra.s   sb_ret_sb           And return the error

sb_ret_d1  cmpi.w  #SD_SCRB,d7         Which routine is this ?
           beq.s   sb_ret_sb           Skip, it is SCREEN_BASE
           move.l  d1,-(a7)            Save D1, it could be wrong
           moveq   #MT_INF,d0          Set a trap for the unwary
           trap    #1                  Get system info
           move.l  (a7)+,d1            Restore possible value
           and.l   #$FF00FFFF,d2       Mask out the decimal point or whatever
           cmpi.l  #$31003034,d2       Is QDOS > version 1.03?
           bcs.s   sb_ret_128          No, result in D1 is wrong for JM or AH
           andi.l  #$FFFF0000,d1       Keep upper word only for DISPLAY_WIDTH
           swap    d1                  And move it to lower word
           ext.l   d1                  Save the sign too !
           bra.s   sb_ret_sb           Skip AH and JM processing

sb_silly   dc.b    'Thanks Ralf !!'    Handy help is credited !

sb_ret_128 move.l  #128,d1             Result is 128 for Ah and JM ROMs

sb_ret_sb  moveq   #2,d2               Extra space required for result
           bra     float_d1            Exit

*--------------------------------------------------------------------*
* EXTOP routine used by SCREEN_BASE, returns address of the screen   *
* for the given channel number. On return, A0.L reverts back to the  *
* channel id as per the TRAP parameters set up above.                *
*--------------------------------------------------------------------*
* ENTRY                         | EXIT                               *
*                               |                                    *
* A0.L = Base of defn block     | D0.L = Zero                        *
* D1.L = Offset in defn block   | D1.W = Returned data               *
* REST = Who cares ?            | REST = Preserved                   *
*--------------------------------------------------------------------*
sb_extop   move.l  0(a0,d1.w),d1       Get data required
           moveq   #0,d0               No errors
           rts                         Finished


*====================================================================*
* RESERVE_HEAP = allocate some heap and return its address           *
*--------------------------------------------------------------------*
* Check that we only have one parameter and if so get it as a long,  *
* make sure that it is even (or else !) and request that amount of   *
* heap space. Float the address of the given heap or an error code & *
* return it to SuperBasic after sticking a flag into the first long  *
* word of the heap. The flag will be used by RELEASE_HEAP.           *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
res_heap   bsr     count_pars          Should be only 1 parameter
           moveq   #6,d2               Just in case of errors
           subq.w  #1,d0               How many ?
           beq.s   rh_1_ok             Ok, only 1

rh_badpar  moveq   #ERR_BP,d1          Error to be returned
           bra     float_bv            Stack not yet used

rh_badpar2 moveq   #ERR_BP,d1
           bra     float_d1            Stack has been used

rh_error   rts                         Quit

rh_1_ok    moveq   #get_long,d0        We want long parameters
           bsr     get_params          Stack parameters
           bne.s   rh_error            Oh dear

rh_got_1   moveq   #2,d2               Prepare for an error
           move.l  0(a6,a1.l),d1       Required number of bytes
           ble.s   rh_badpar2          Should be positive & not zero
           addq.l  #5,d1               4 for flag & 1 to ...
           bclr    #0,d1               ... make even
           bsr     mtalchp             Get some space
           beq.s   rh_ok               It worked ok
           move.l  d0,d1               Get the error code
           bra.s   rh_ret              Return it as result

rh_ok      move.l  #'NDhp',(a0)+       Store the flag and up the address
           move.l  a0,d1               Get address of allocation

rh_ret     moveq   #2,d2               Extra space required for result
           bra     float_d1            Return address to SuperBasic


*====================================================================*
* RELEASE_HEAP = deallocate some previously allocated heap space     *
*--------------------------------------------------------------------*
* Check that we only have one parameter and if so get it as a long,  *
* make sure that it is even (or else !) and deallocate the heap at   *
* that address having first checked that we have a flag at offset -4 *
* from the given address. If not, it is not our heap.                *
*====================================================================*
rel_heap   bsr     count_pars          Check for only one parameter
           subq.w  #1,d0               How many are there ?
           bne.s   rlh_badpar          Oh dear...
           moveq   #get_long,d0        We want long ones
           bsr     get_params          So get them
           bne.s   rlh_error           Oops...
           move.l  0(a1,a6.l),d3       Get the address
           addq.l  #1,d3               Prepare to ...
           bclr    #0,d3               ... make even
           subq.l  #4,d3               Point down to the flag
           move.l  d3,a0               Set up the address to MT_RECHP
           cmpi.l  #'NDhp',(a0)        Check for the flag
           bne.s   rlh_badpar          No flag found
           clr.l   (a0)                Trash the flag to save doing it twice !
           moveq   #MT_RECHP,d0        Release heap
           trap    #1                  Do it (no error returns)
           moveq   #0,d0               Just in case
           bra.s   rlh_error           Return to SuperBasic, no errors

rlh_badpar moveq   #ERR_BP,d0          Bad parameter error

rlh_error  rts                         Exit.


*====================================================================*
* ABS_POSITION = set file pointer to given absolute position         *
*--------------------------------------------------------------------*
* Check that we have 2 parameters and that the first one is prefixed *
* by a hash (#) for the channel number. Get them both as longs. The  *
* first parameter is converted to a channel id and the second is the *
* required position in the file and should be positive.              *
*====================================================================*
abs_pos    moveq   #FS_POSAB,d7        Required routine (absolute)
           bra.s   do_filepos          Skip


*====================================================================*
* MOVE_POSITION = change our position in the file, relatively        *
*--------------------------------------------------------------------*
* Check that we have 2 parameters and that the first one is prefixed *
* by a hash (#) for the channel number. Get them both as longs. The  *
* first parameter is converted to a channel id and the second is a   *
* signed relative displacement in the file.                          *
*====================================================================*
rel_pos    moveq   #FS_POSRE,d7        Required routine (relative)

do_filepos bsr     count_pars          How many do we have ?
           subq.w  #2,d0               Should be 2
           beq.s   ap_2                Yes, ok

ap_badpar  moveq   #ERR_BP,d0          Bad parameter

ap_error   rts                         Exit

ap_2       bsr     check_hash          Is there a hash ?
           beq.s   ap_badpar           No, quit
           moveq   #get_long,d0        I want a pair of longs
           bsr     get_params          Go get them
           bne.s   ap_error            Oops...
           move.l  0(a6,a1.l),d0       Channel number
           bsr     get_chan            Convert
           bne.s   ap_error            Oops
           move.b  d7,d0               Trap required
           move.l  4(a6,a1.l),d1       Position required
           cmpi.b  #FS_POSAB,d7        Doing absolute ?
           bne.s   ap_rel              No, offset is signed
           tst.l   d1                  Set flags again
           bmi.s   ap_badpar           Needs to be positive for absolute

ap_rel     moveq   #timeout,d3         Take all day...
           trap    #3                  Do it - TRASHES A1, beware in Functions
           cmpi.l  #ERR_EF,d0          Ignore End of file errors
           bne.s   ap_end
           moveq   #ERR_OK,d0          No errors

ap_end     rts                         Exit


*====================================================================*
* PUT_BYTE = stuff 1 byte to the given channel                       *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a single byte in    *
* numeric form. Get them both as long. Convert the first to a channel*
* id and stick the low byte of the second to that channel.           *
*====================================================================*
put_byte   moveq   #1,d7               Flag PUT_BYTE
           bra.s   do_put              Skip


*====================================================================*
* PUT_WORD = stuff 2 bytes to the given channel                      *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a word in numeric   *
* form. Get them both as long. Convert the first to a channel id and *
* shove the low word of the second to that channel.                  *
*====================================================================*
put_word   moveq   #2,d7               Flag PUT_WORD
           bra.s   do_put              Skip


*====================================================================*
* PUT_LONG = stuff 4 bytes to the given channel                      *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a long word in      *
* numeric form. Get them both as longs. Convert the first to a       *
* channel id and stuff the second to it.                             *
*====================================================================*
put_long   moveq   #4,d7               Flag PUT_LONG
           bra.s   do_put              Skip


*====================================================================*
* PUT_FLOAT = stuff 6 bytes to the given channel                     *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a floating point    *
* number. Get the first as a long and the second as a float. Convert *
* the first to a channel id and stuff the second to it as 6 bytes.   *
*====================================================================*
put_float  moveq   #6,d7               Flag PUT_FLOAT

do_put     bsr     count_pars          How many parameters ?
           subq.w  #2,d0               Should be 2 only
           beq.s   pb_hash             Ok, there are 2

pb_badpar  moveq   #ERR_BP,d0          Bad parameter

pb_error   rts                         Quit

pb_hash    bsr     check_hash          Is there a hash ?
           beq.s   pb_badpar           No, quit
           cmpi.b  #6,d7               Is this PUT_FLOAT ?
           bne.s   pb_not_flt          No, skip

*--------------------------------------------------------------------*
* This is different for floats as the parameters come in 2 different *
* flavours, one long and one float.                                  *
*--------------------------------------------------------------------*
pb_float   lea.l   8(a3),a5            Pretend to get 1 long
           moveq   #get_long,d0        I want a long
           bsr     get_params          Go get it
           bne.s   pb_error            Oh dear
           move.l  0(a6,a1.l),d5       D5 is not corrupted by CA_GT???
           adda.l  #4,a1               Tidy maths stack
           move.l  a5,a3               Point to last param
           addq.l  #8,a5               Ditto
           moveq   #get_float,d0       I require a float this time
           bsr     get_params          Go get it
           bne.s   pb_error            Oops
           bra.s   pb_got_all          Skip

pb_not_flt moveq   #get_long,d0        Get as longs
           bsr     get_params          Do it
           bne.s   pb_error            Oh dear
           move.l  0(a6,a1.l),d5       Get channel number
           adda.l  #4,a1               Tidy stack

*--------------------------------------------------------------------*
* At this point, the channel # is in D5 and (A6,A1.l) is the buffer  *
* address where the byte(s) to be PUT are, on the maths stack still. *
* D7 holds a flag which is the number of bytes to be PUT.            *
*--------------------------------------------------------------------*
pb_got_all move.l  d5,d0               Get the channel id
           bsr     get_chan            Convert to channel id
           bne.s   pb_error            Oh dear
           move.w  d7,d2               How many bytes (1, 2, 4 or 6)
           moveq   #timeout,d3         It could take a while
           cmpi.b  #2,d7               WORD or BYTE ?
           bgt.s   pb_do_it            No, LONG or FLOAT
           moveq   #4,d1               Preset D1
           sub.w   d7,d1               Make up an offset
           adda.w  d1,a1               Add to stack pointer

pb_do_it   trap    #4                  A1 is relative A6
           moveq   #IO_SSTRG,d0        Trap to send some bytes
           trap    #3                  Send 1, 2, 4 or 6 bytes to channel
           rts                         Finished.


*====================================================================*
* PUT_STRING = stuff a word followed by n bytes to a channel         *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a string variable   *
* or some text. Get the first as a long and convert it to a channel  *
* id, the second is got as a string. A word is written to the        *
* channel being the length of the following text.                    *
*====================================================================*
put_string bsr     count_pars          How many parameters ?
           subq.w  #2,d0               Should be only 2
           beq.s   ps_2_ok             Seems ok

ps_badpar  moveq   #ERR_BP,d0          Bad Parameter

ps_error   rts                         

ps_2_ok    bsr     check_hash          Is there a hash (#) ?
           beq.s   ps_badpar           No, quit
           lea.l   8(a3),a5            Pretend to get 1 parameter
           moveq   #get_long,d0        1 Long is required
           bsr     get_params          Get channel number
           bne.s   ps_error            Oops...
           move.l  0(a6,a1.l),d7       Get channel number (preserved)
           move.l  a5,a3               Last parameter
           lea.l   8(a3),a5            Ditto
           moveq   #get_string,d0      I want a string
           bsr     get_params          Get it
           bne.s   ps_error            Oops...
           move.w  0(a1,a6.l),d2       How many bytes ?
           blt.s   ps_badpar           Size is negative
           move.l  d7,d0               Get channel number
           bsr     get_chan            Convert to channel id
           bne.s   ps_error            Oops...
           addq.w  #2,d2               Send the word count as well
           moveq   #timeout,d3         Take all day if you like
           trap    #4                  A1 is relative A6
           moveq   #io_sstrg,d0        Trap is set
           trap    #3                  Send the word & the bytes
           rts                         Finished


*====================================================================*
* POKE_STRING = stuff text into memory at given address              *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first is an address, the      *
* second is a string variable or some text. Get the first as a long  *
* and the second as a string then store the string at the address    *
* given by the first. Need not be an even address as a byte by byte  *
* transfer is done.                                                  *
*====================================================================*
poke_strg  bsr     count_pars          How many parameters ?
           subq.w  #2,d0               Is there only 2 ?
           beq.s   pks_2_ok            Seems to be

pks_badpar moveq   #ERR_BP,d0          Bad parameter

pks_error  rts                         Quit

pks_2_ok   bsr     check_hash          Is there a hash (#)
           bne.s   pks_badpar          Shouldn't be
           moveq   #get_long,d0        I want 1 long
           lea.l   8(a3),a5            And only 1
           bsr     get_params          Go get it
           bne.s   pks_error           Oops...
           move.l  0(a6,a1.l),d7       Get address
           move.l  a5,a3               Point to last parameter
           lea.l   8(a3),a5            Ditto
           moveq   #get_string,d0      I want a string this time
           bsr     get_params          Go get it
           bne.s   pks_error           Oops...
           move.l  d7,a2               Get destination address
           move.w  0(a1,a6.l),d2       Get length
           beq.s   pks_error           If zero, finished
           bmi.s   pks_badpar          If negative, error
           bra.s   pks_next            Skip

pks_shift  move.b  2(a1,a6.l),(a2)+    Shift a byte
           addq.l  #1,a1               Adjust source

pks_next   dbra    d2,pks_shift        Do the rest
           moveq   #0,d0               No errors
           rts                         Exit


*====================================================================*
* MOVEMEM = Shift some memory around                                 *
*--------------------------------------------------------------------*
* Check that we have 3 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a floating point    *
* number. Get them all as longs so that large chunks of memory can   *
* be shifted around. Make sure that the source & destinations don't  *
* overlap and if so, do it from the other end instead.               *
* Credit to the book 'The Standard C library' by PJ Plauger for the  *
* !! correct !! algorithm for checking overlaps, mine failed if the  *
* destination was less than the source but there was an overlap, all *
* the rest worked fine.                                              *
*--------------------------------------------------------------------*
* Amended 05/03/93 to use long word moves wherever possible, this    *
* will slow byte sized moves down as more checking is done before    *
* the move is carried out. It is now better for large sized moves as *
* opposed to small ones.                                             *
*--------------------------------------------------------------------*
* Amended 14/06/93 to make optimisation work correctly, I think the  *
* algorithm I used was wrong, as well as the fact that I got some of *
* my address pointer pointing to far up when moving long words down. *
*====================================================================*
move_mem   bsr     count_pars          How many ?
           subq.w  #3,d0               Only 3 required
           beq.s   mm_3_ok             Ok

mm_badpar  moveq   #ERR_BP,d0          Bad parameter error

mm_error   rts                         Quit

mm_3_ok    moveq   #get_long,d0        I want long ones
           bsr     get_params          Go get them
           bne.s   mm_error            Oops...
           move.l  0(a6,a1.l),d1       Source address
           move.l  4(a6,a1.l),d2       Destination address
           move.l  8(a6,a1.l),d3       Length

*--------------------------------------------------------------------*
* Negative addresses/size are assumed to be very large positives.    *
* If SIZE = 0 then finished.                                         *
* If SRC = DEST then finished.                                       *
* If (SRC < DEST) AND ((SRC + SIZE - 1) >= DEST) -> Top down move    *
* else -> normal move.                                               *
*--------------------------------------------------------------------*
           beq     mm_done             Size = 0
           cmp.l   d1,d2               Source = Destination ?
           beq     mm_done             Yes, finished
           bcs.s   mm_normal           Source > Dest -> Normal move
           move.l  d3,d0               Get size
           subq.l  #1,d0               Minus 1
           add.l   d1,d0               Source + Size - 1
           cmp.l   d0,d2               (Source + size - 1) < Destination ?
           bhi.s   mm_normal           No -> Normal move

*--------------------------------------------------------------------*
* Top down move is required due to overlap. Set the source and dest  *
* addresses = current value + size - 1. Set the skip size to -1.     *
*--------------------------------------------------------------------*
mm_t_down  move.l  d0,d1               Source address + size - 1
           move.l  d1,a2               Get into correct register
           add.l   d3,d2               Add size to destination
           subq.l  #1,d2               Minus 1
           move.l  d2,a3               Get into correct register
           moveq   #-1,d7              Top down shift required
           bra.s   mm_do_it            Skip

*--------------------------------------------------------------------*
* Normal move is being done, Set the skip size to +1.                *
*--------------------------------------------------------------------*
mm_normal  move.l  d1,a2               Source address
           move.l  d2,a3               Destination address
           moveq   #1,d7               Assume bottom up shift, step +1

*--------------------------------------------------------------------*
* D1.L = Source address                                              *
* D2.L = Destination address                                         *
* D3.L = Length to shift                                             *
* D7.B = Step size, 1 or -1 (assuming byte moves)                    *
* A2.L = Source address                                              *
* A3.L = Destination address                                         *
*--------------------------------------------------------------------*
* Optimised 14/06/93 as follows :-                                   *
*                                                                    *
* If size is less than 4, do byte sized moves.                       *
*                                                                    *
* If ONE address is odd, we are 'FUBARred', so we must do byte sized *
* moves.                                                             *
*                                                                    *
* If both addresses are even and direction is upwards, we need to do *
* the move. Our addresses and counter are correct.                   *
*                                                                    *
* If both addresses are even and direction is downwards, we need to  *
* move 3 bytes downwards adjusting the pointers to make them both    *
* odd. The counter must be reduced by 3 as well.                     *
*                                                                    *
* If both addresses are odd and direction is upwards, we need to do  *
* one byte sized move, adjust the pointers and the count to make the *
* addresses even.                                                    *
*                                                                    *
* Finally, if both addresses are odd and the direction is downwards, *
* we need to simply adjust the pointers down by 3 bytes to make them *
* even.                                                              *
*--------------------------------------------------------------------*
mm_do_it   cmpi.l  #4,d3               Less than 4 bytes ?
           bcs.s   mm_bytes            Yes, easy move

           andi.l  #$00000001,d1       Mask out bit 0 of source address
           andi.l  #$00000001,d2       Ditto for destination address
           sub.b   d2,d1               Set flags

*--------------------------------------------------------------------*
* Zero is set if both addresses were odd or both were even.          *
*--------------------------------------------------------------------*
           bne.s   mm_bytes            Have to move bytes, 1 odd address
           btst    #0,d2               Are both even ?
           bne.s   mm_b_odd            No, both are odd

*--------------------------------------------------------------------*
* Both addresses are even. If direction is up, we are ok.            *
*--------------------------------------------------------------------*
mm_b_even  cmpi.b  #1,d7               Is direction upwards ?
           beq.s   mm_long             Yes, easy

*--------------------------------------------------------------------*
* Direction must be down, we must move the first 3 bytes making the  *
* addresses both odd. This will then be dealt with below.            *
* PS. There is no 'MOVE.B (A2)-,(A3)-' instruction, what a shame.    *
*--------------------------------------------------------------------*
           moveq   #2,d0               Counter for DBRA

mm_odd_1   move.b  (a2),(a3)           Move 1 byte down
           subq.l  #1,a2               Point source down
           subq.l  #1,a3               Point dest down
           dbra    d0,mm_odd_1         Do another
           subq.l  #3,d3               Adjust counter

*--------------------------------------------------------------------*
* This now leaves both addresses odd and the direction is still down *
* so skip the next bit and process as for the current state.         *
*--------------------------------------------------------------------*
           bra.s   mm_d_odd            Deal with both odd & downwards

*---------------------------------------------------------------------*
* Both addresses are odd, if direction is upwards we must move 1 byte *
* upwards, adjust the counter and addresses and then move some longs. *
*---------------------------------------------------------------------*
mm_b_odd   cmpi.b  #1,d7               Going up ?
           bne.s   mm_d_odd            No thanks, going down
           move.b  (a2)+,(a3)+         Move the odd byte upwards
           subq.l  #1,d3               Adjust the counter
           bra.s   mm_long             Do the rest as longs

*--------------------------------------------------------------------*
* Both are odd, direction has to be down, simply adjust both address *
* registers down by 3 to make them both even, this will not affect   *
* the count.                                                         *
*--------------------------------------------------------------------*
mm_d_odd   subq.l  #3,a2               Adjust the source address
           subq.l  #3,a3               And the destination address

*--------------------------------------------------------------------*
* Both addreses are even, so count how many long moves are required  *
* and use D0 as the long counter, the remainder will be done as 1, 2 *
* or 3 single byte moves below. D7 is negative if a top down move is *
* being done. A2 and A3 are pointing correctly regardless of the     *
* direction of the move.                                             *
*--------------------------------------------------------------------*
mm_long    move.l  d3,d0               Copy length to be moved into D0
           andi.l  #$03,d3             D3 now = single byte moves required
           lsr.l   #2,d0               D0 = long word moves required
           beq.s   mm_bytes            No longs to be moved, skip
           muls    #4,d7               Step is now -4 or +4 for longs

mm_do_long move.l  (a2),(a3)           Move 1 long word
           adda.l  d7,a2               Next source address
           adda.l  d7,a3               Next destination address
           subq.l  #1,d0               Reduce counter
           bne.s   mm_do_long          More to be done
           divs    #4,d7               Step is back to -1 or +1 for bytes

*--------------------------------------------------------------------*
* Now of course we are pointing too far down in memory if the move   *
* is downwards, but ok if the move is upwards. If the move is down   *
* we need to adjust the source and destination pointers back up by 3 *
* prior to moving the last (maximum of) 3 bytes.                     *
*--------------------------------------------------------------------*
           cmpi.b  #1,d7               Moving up ?
           beq.s   mm_bytes            Yes, pointers are ok
           addq.l  #3,a2               Adjust source address
           addq.l  #3,a3               And destination address

*--------------------------------------------------------------------*
* We are moving single bytes at this point.                          *
*--------------------------------------------------------------------*
mm_bytes   tst.l   d3                  Finished yet ?
           beq.s   mm_done             Yes, skip

mm_do_byte move.b  (a2),(a3)           Shift one byte
           adda.l  d7,a2               Add step size to source
           adda.l  d7,a3               Add step size to destination
           subq.l  #1,d3               Reduce number of bytes
           bne.s   mm_do_byte          Do some more

mm_done    moveq   #0,d0               No errors
           rts                         Finished



*====================================================================*
* FLUSH_CHANNEL = flush the buffers for the given channel number     *
*--------------------------------------------------------------------*
* Check that we have 1 parameter preceeded by a hash (#), get it as  *
* a long and convert it to a channel id. Then simply flush the       *
* channel using the appropriate trap.                                *
*====================================================================*
flush_chan bsr     count_pars          How many ?
           subq.w  #1,d0               Only 1 ?
           beq.s   fc_1_ok             Yes

fc_badpar  moveq   #ERR_BP,d0          Bad parameter

fc_error   rts                         Quit

fc_1_ok    bsr     check_hash          Is there a hash (#) ?
           beq.s   fc_badpar           No, quit
           moveq   #get_long,d0        I want a long one !!!!
           bsr     get_params          Go get it
           bne.s   fc_error            Oh dear
           move.l  0(a6,a1.l),d0       Get channel number
           bsr     get_chan            Convert to channel id
           bne.s   fc_error            Oops...
           moveq   #FS_FLUSH,d0        Prepare a trap for the unwary
           moveq   #timeout,d3         How long has this been going on ?
           trap    #3                  Pull the chain & flush !
           rts                         Exit


*====================================================================*
* READ_HEADER = read the file header for the given channel into a    *
*              buffer at the given address.                          *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a buffer address.   *
* Get them both as longs, convert the first to a channel id and      *
* call the FS_HEADR trap to read the appropriate header. Return the  *
* error code as a word integer.                                      *
*====================================================================*
read_head  moveq   #FS_HEADR,d7        Flag READ_HEADER
           bra.s   sh_both             Skip


*====================================================================*
* SET_HEADER = read the file header for the given channel into a     *
*              buffer at the given address.                          *
*--------------------------------------------------------------------*
* Check that we have 2 parameters, the first must be prefixed by a   *
* hash (#) for the channel number, the second is a buffer address.   *
* Get them both as longs, convert the first to a channel id and      *
* call the FS_HEADS trap to read the appropriate header. Return the  *
* error code as a word integer.                                      *
*--------------------------------------------------------------------*
* Stack uses 8 bytes, requires 2 for result.                         *
*====================================================================*
set_head   moveq   #FS_HEADS,d7        Flag SET_HEADER

sh_both    bsr     count_pars          How many this time ?
           moveq   #2,d2               Prepare for an error
           subq.w  #2,d0               Perhaps there were 2
           beq.s   sh_2_ok             Yes, there was

sh_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     integer_bv          Unused stack !

sh_error   rts                         Quit

sh_2_ok    bsr     check_hash          Look for that hash (#) again
           beq.s   sh_badpar           Oops...
           moveq   #get_long,d0        I want 2 long ones this time
           bsr     get_params          Go get them
           bne.s   sh_error            Oh dear
           move.l  0(a1,a6.l),d0       Get the channel number
           addq.l  #6,a1               Tidy stack but leave space for result
           bsr     get_chan            Convert to channel id
           bne.s   sh_ret_d0           Oops
           move.l  -2(a1,a6.l),d0      Get buffer address
           bpl.s   sh_buf_ok           Can't be zero or less
           moveq   #ERR_BP,d0          Negative or zero is bad news
           bra.s   sh_ret_d0           Bale out

sh_buf_ok  move.l  a1,-(a7)            Stack it
           move.l  d0,a1               Buffer pointer
           bsr     read_set            Do the appropriate trap
           move.l  (a7)+,a1            Restore maths stack pointer

sh_ret_d0  moveq   #0,d2               No extra space required for result
           move.l  d0,d1               Get the error code
           bra     integer_d1          Return it as a word int


*====================================================================*
* FILE_LENGTH = Return the length of the file given as a channel     *
*              number or as a string.                                *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if the first is prefixed by a hash *
* (#) get it as a long, convert to a channel id. If it is not, then  *
* it must be a string. Get it, open the file and get the channel id. *
* Now call the FS_HEADR trap, extract the file length, close the file*
* if I opened it and return the length as a float.                   *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
* OR uses 2 + string length, beware !                                *
*====================================================================*
file_len   moveq   #f_length,d7
           bra.s   f_count


*====================================================================*
* FILE_TYPE = Return the type byte of the file given as a channel    *
*             number or as a string.                                 *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if the first is prefixed by a hash *
* (#) get it as a long, convert to a channel id. If it is not, then  *
* it must be a string. Get it, open the file and get the channel id. *
* Now call the FS_HEADR trap, extract the file type, close the file  *
* if I opened it and return the type as a float. (saves code space !)*
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
* OR uses 2 + string length, beware !                                *
*====================================================================*
file_type  moveq   #f_type,d7
           bra.s   f_count


*====================================================================*
* FILE_DATASPACE = Return the dataspace of the file given as a       *
*                 channel number or as a string.                     *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if the first is prefixed by a hash *
* (#) get it as a long, convert to a channel id. If it is not, then  *
* it must be a string. Get it, open the file and get the channel id. *
* Now call the FS_HEADR trap, extract the file dataspace, close the  *
* file if I opened it and return the dataspace as a float.           *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
* OR uses 2 + string length, beware !                                *
*====================================================================*
file_data  moveq   #f_data,d7
           bra.s   f_count


*====================================================================*
* FILE_UPDATE = Return the update date of the file given as a channel*
*              number or as a string.                                *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if the first is prefixed by a hash *
* (#) get it as a long, convert to a channel id. If it is not, then  *
* it must be a string. Get it, open the file and get the channel id. *
* Now call the FS_HEADR trap, extract the update date, close the file*
* if I opened it and return the date as a float.                     *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
* OR uses 2 + string length, beware !                                *
*====================================================================*
file_updt  moveq   #f_update,d7
           bra.s   f_count


*====================================================================*
* FILE_BACKUP = Return the backup date of the file given as a channel*
*              number or as a string.                                *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if the first is prefixed by a hash *
* (#) get it as a long, convert to a channel id. If it is not, then  *
* it must be a string. Get it, open the file and get the channel id. *
* Now call the FS_HEADR trap, extract the update date, close the file*
* if I opened it and return the date as a float.                     *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
* OR uses 2 + string length, beware !                                *
*====================================================================*
file_bkdt  moveq   #f_backup,d7

f_count    bsr     count_pars          How many parameters ?
           moveq   #6,d2               Looking on the gloomy side again !
           subq.w  #1,d0               Should be 1
           beq.s   f_1_ok              Yes

f_badpar   moveq   #ERR_BP,d1          Bad parameter
           bra     float_bv

f_error    rts                         Quit

f_1_ok     bsr     check_hash          Is there a hash ?
           bne.s   f_hash_ok           Yes

f_no_hash  moveq   #get_string,d0      I want a string please
           bsr     get_params          Go get it
           bne.s   f_error             Oops...
           bset    #31,d7              Set 'please close file' flag
           tst.w   0(a6,a1.l)          Check filename length
           bne.s   f_nlen_ok           Name length is ok

*--------------------------------------------------------------------*
* Stack must have only 2 bytes on it, can you have a negative length *
* string and if so, what data is in it ?                             *
*--------------------------------------------------------------------*
f_badname  moveq   #ERR_BN,d1          Bad name
           moveq   #4,d2               Extra space required
           bra     float_d1            Quit with error code

*--------------------------------------------------------------------*
* On the stack there is a filename and its word count, in order to   *
* get the open error back to SuperBasic I need to tidy the stack and *
* leave only 6 bytes for a float result. If I do this before opening *
* the file, life is a lot easier. This next section has been re-done *
* since version 1.00 and should do the necessary.                    *
*--------------------------------------------------------------------*
f_nlen_ok  move.l  a1,d6               Save maths stack for later
           moveq   #0,d2               Clear upper word
           move.w  0(a1,a6.l),d2       Get size of name
           addq.w  #3,d2               Add in word count size
           bclr    #0,d2               Make even too
           cmpi.w  #6,d2               Room for a float ?
           beq.s   f_is_tidy           Yes, there are 6 bytes free
           bgt.s   f_too_big           Oops, too many free bytes
           moveq   #6,d1               Find out how many extra bytes required
           sub.w   d2,d1               These are the extras I need
           bra.s   f_more              Go get them

*--------------------------------------------------------------------*
* There is too much room on the stack, find out how much extra there *
* is and tidy it off, leaving 6 bytes for the result.                *
*--------------------------------------------------------------------*
f_too_big  subq.w  #6,d2               Leave enough for a float
           adda.w  d2,a1               Tidy up
           bra.s   f_is_tidy           Skip, stack is now ok

f_more     move.l  a1,BV_RIP(a6)       Save current top of stack
           bsr     bv_get              Make space (preserves D6, sets A1)

*--------------------------------------------------------------------*
* From here on, if parameter 1 was a filename then the stack has     *
* room for the returned result. A1 holds the top of stack address.   *
*--------------------------------------------------------------------*
f_is_tidy  move.l  a1,BV_RIP(a6)       New stack pointer saved
           move.l  d6,a0               Address of filename
           moveq   #me,d1              For this job
           moveq   #1,d3               Existing file, shared access
           trap    #4                  Unrelative A0 & trash A1 !!!
           moveq   #IO_OPEN,d0         Prepare to open a file
           trap    #2                  Open it
           move.l  BV_RIP(a6),a1       Untrash A1 !
           tst.l   d0                  Did it work ?
           beq.s   f_got_id            Yes, skip
           bclr    #31,d7              No need to close, open failed
           bra.s   f_oops              Return error code & quit

*--------------------------------------------------------------------*
* At this point, the first parameter was a channel number, the stack *
* is currently unused and has not yet got room for the result.       *
*--------------------------------------------------------------------*
f_hash_ok  moveq   #get_long,d0        I want a long one
           bsr     get_params          Go get it
           bne.s   f_error             Oops
           move.l  0(a6,a1.l),d0       Get channel number
           move.l  a1,BV_RIP(A6)       Save stack top
           moveq   #2,d1               2 extra bytes needed
           bsr     bv_get              Get stack space (Preserves D0, sets A1)
           move.l  a1,BV_RIP(a6)       New stack pointer saved

*--------------------------------------------------------------------*
* Stack is now able to hold a floating point result from this point. *
*--------------------------------------------------------------------*
           bsr     get_chan            Convert to channel id
           bne.s   f_oops              Oh dear, give up & exit

*--------------------------------------------------------------------*
* At this point, A0.L is the channel id, D7 bit 31 is zero if the    *
* first parameter was a channel number and 1 if it was a string.     *
* D7.W = required offset into file header for the required data to   *
* be returned. A1.L is all set for a float result to be passed back. *
*--------------------------------------------------------------------*
f_got_id   move.l  a1,BV_RIP(a6)       Save new stack pointer
           move.l  a0,-(a7)            Stack channel id
           moveq   #64,d1              I need 64 bytes for a buffer
           bsr     mtalchp             Allocate heap space
           movea.l a0,a1               Get buffer address
           move.l  (a7)+,a0            Get channel id again
           tst.l   d0                  Did trap work ?
           beq.s   f_trap_ok           Yes

f_oops     btst    #31,d7              Check for 'close file' flag
           beq.s   f_ret_d0            No need to close
           move.l  d0,-(a7)            Save error code
           bsr     close_file          We opened it, so close it
           move.l  (a7)+,d0            Retrieve error code

f_ret_d0   move.l  d0,d1               Get the error code
           moveq   #0,d2               6 bytes for result
           move.l  BV_RIP(A6),a1       Maths stack is tidy, A1 is not !
           bra     float_d1            Return to SuperBasic with error code

*--------------------------------------------------------------------*
* We have a buffer for the header at (A1.L), the channel id in A0.L  *
*--------------------------------------------------------------------*
f_trap_ok  move.l  d7,d5               We need d7 later
           move.l  a1,-(a7)            And the buffer address
           moveq   #FS_HEADR,d7        Read header trap
           bsr     read_set            Do it
           move.l  (a7)+,a1            Get buffer address again
           move.l  d5,d7               Restore flag & offset
           tst.l   d0                  Set flags again
           bne.s   f_rechp             Oh dear, exit with error

*--------------------------------------------------------------------*
* The header has been read ok, extract the data                      *
*--------------------------------------------------------------------*
           moveq   #0,d1               Clear result buffer
           cmpi.w  #f_type,d7          Byte size required ?
           bne.s   f_get_long          No, skip
           move.b  0(a1,d7.w),d0       Get a byte of data
           bra.s   f_rechp             Skip

f_get_long move.l  0(a1,d7.w),d0       Get a long word of data

*--------------------------------------------------------------------*
* D0 contains an error code or an item of required data, A1 holds    *
* the buffer address to be reclaimed before exit.                    *
*--------------------------------------------------------------------*
f_rechp    movem.l d0/a0,-(a7)         Stack result & file id
           moveq   #MT_RECHP,d0        Reclaim buffer
           move.l  a1,a0               Buffer address
           trap    #1                  Reclaim heap, no errors
           movem.l (a7)+,d0/a0         Retrieve result & file id
           bra     f_oops              Return, via close, with result


*====================================================================*
* FILE_POSITION = Where am I in the file given as a channel number ? *
*--------------------------------------------------------------------*
* Check that we have 1 parameter, if it is prefixed by a hash (#)    *
* then get it as a long and convert it to a channel id. Then simply  *
* call the FS_POSRE trap with a zero offset to get the current file  *
* position.                                                          *
*--------------------------------------------------------------------*
* On a Gold Card the TRAP #3 in this routine seems to work without   *
* trashing A1, everything else trashes A1 in the trap. Guess which I *
* used to do my testing ?                                            *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
file_pos   bsr     count_pars          Oh look, I am counting again
           moveq   #6,d2               Prepare for errors
           subq.w  #1,d0               Check for 1
           beq.s   fp_1_ok             Ok

fp_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     float_bv            Exit via an empty maths stack

fp_error   rts                         Quit

fp_1_ok    bsr     check_hash          Look for a hash (#)
           beq.s   fp_badpar           Oops...
           moveq   #get_long,d0        I still want a long one
           bsr     get_params          Get it
           bne.s   fp_error            Oh dear
           move.l  0(a6,a1.l),d0       Get channel number
           bsr     get_chan            Convert to channel id
           bne.s   fp_ret_d0           Oops
           moveq   #FS_POSRE,d0        Trap is set
           moveq   #0,d1               No movement
           moveq   #timeout,d3         These things take time
           move.l  a1,-(a7)            Gets trashed by the TRAP #3
           trap    #3                  Do it
           move.l  (a7)+,a1            Restore my stack again
           tst.l   d0                  Did it work
           beq.s   fp_ok               Yes
           cmpi.l  #ERR_EF,d0          Was it End Of File ?
           beq.s   fp_ok               Yes, ignore this error

fp_ret_d0  move.l  d0,d1               Get the error code

fp_ok      moveq   #2,d2               Extra space needed for the result
           bra     float_d1            Float error code or file position


*====================================================================*
* GET_BYTE = Get a byte from a given channel number.                 *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be prefixed by a hash.      *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
get_byte   moveq   #1,d7               Signal GET_BYTE
           bra.s   gb_do_it            Skip


*====================================================================*
* GET_WORD = Get a word from a given channel number.                 *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be prefixed by a hash.      *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
get_wrd    moveq   #2,d7               Signal GET_WORD
           bra.s   gb_do_it            Skip


*====================================================================*
* GET_LONG = Get a long word from to a given channel number.         *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be prefixed by a hash.      *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
get_lng    moveq   #4,d7               Signal GET_LONG
           bra.s   gb_do_it            Skip


*====================================================================*
* GET_FLOAT = Get a float from a given channel number.               *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be prefixed by a hash.      *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the result.                  *
*====================================================================*
get_flt    moveq   #6,d7               Signal GET_FLOAT

gb_do_it   bsr     count_pars          How many parameters ?
           moveq   #6,d2               Assume the worst
           subq.w  #1,d0               Should be 1
           beq.s   gb_1_ok             Yippee !

gb_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     float_bv            Quit, stack is unused

gb_error   rts                         Quit

gb_1_ok    bsr     check_hash          Did it have a hash ?
           beq.s   gb_badpar           Obviously not
           moveq   #get_long,d0        I want a long one
           bsr     get_params          Go get it
           bne.s   gb_error            Oh dear
           move.l  0(a6,a1.l),d0       Get channel number
           bsr     get_chan            Convert to id
           beq.s   gb_get              Ok ?
           moveq   #2,d2               Spare stack required
           bra.s   gb_ret_d0           Error return required

*--------------------------------------------------------------------*
* Use the maths stack as the buffer, read 1, 2, 4 or 6 bytes from    *
* the file and if it works ok, check to see if this is GET_FLOAT, if *
* so, return the float on the maths stack otherwise, remove the bytes*
* from the maths stack, reset it and exit via float_d1 to return the *
* result. If any access errors occur, exit causing an error.         *
*--------------------------------------------------------------------*
gb_get     move.l  a1,BV_RIP(a6)       Where is maths stack now ?
           move.l  #2,d1               Extra room needed for a float
           bsr     bv_get              Reserve extra space
           move.l  a1,BV_RIP(a6)       And store the new value

*--------------------------------------------------------------------*
* From here on, the stack has enough room for the result.            *
*--------------------------------------------------------------------*
           move.l  d7,d2               Bytes required
           moveq   #timeout,d3         Infinity
           trap    #4                  Unrelative A1
           moveq   #IO_FSTRG,d0        Set a trap (corrupts A1)
           trap    #3                  Stack a float from the file
           tst.l   d0                  Did it work ?
           beq.s   gb_done_it          Yes, exit
           bra.s   gb_ret_d0           Exit returning error

gb_done_it move.l  BV_RIP(a6),a1       Point to base of stack again
           cmpi.w  #6,d7               Is this GET_FLOAT ?
           bne.s   gb_not_flt          No, skip
           moveq   #0,d0               No errors
           moveq   #2,d4               Float result
           rts                         Finished for floats

gb_not_flt moveq   #0,d2               No room required, got it above
           move.l  0(a6,a1.l),d1       Assume GET_LONG, D1 = ????????
           cmpi.w  #4,d7               Is this GET_LONG
           beq     float_d1            Yes, finished for GET_LONG
           clr.w   d1                  Lose the duff bytes, D1 = ????0000
           swap    d1                  Switch high & low bytes, D1 = 0000????
           cmpi.w  #2,d7               Is this GET_WORD ?
           beq     float_d1            Yes, finished for GET_WORD
           andi.w  #$ff00,d1           Mask off duff byte, D1 = 0000??00
           lsr.w   #8,d1               Shift byte into position, D1 = 000000??
           bra     float_d1            Finished with GET_BYTE

gb_ret_d0  moveq   #0,d2               Just in case (GET_BYTE leaves 1 in d2)
           move.l  d0,d1               Get error code
           bra     float_d1            Return it as result



*====================================================================*
* GET_STRING = Get a word count then all the bytes from a given      *
*              channel number.                                       *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be prefixed by a hash.      *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 2 + ??? for the result.            *
*====================================================================*
get_str    bsr     count_pars          Count them
           subq.w  #1,d0               Should be 1
           beq.s   gs_1_ok             Ok

gs_badpar  moveq   #ERR_BP,d0          Bad parameter

gs_error   rts                         Quit with error

gs_1_ok    bsr     check_hash          Look for that hash again
           beq.s   gs_badpar           Oh dear
           moveq   #get_long,d0        I want a long one
           bsr     get_params          Get it
           bne.s   gs_error            Oh dear
           move.l  0(a6,a1.l),d0       Get the channel number
           bsr     get_chan            Convert it to an id
           bne.s   gs_error            Oops..
           move.l  a1,d7               A1 gets corrupted by IO_FBYTE
           moveq   #0,d1               Where the word is going
           moveq   #1,d4               2 byte count for dbra
           moveq   #timeout,d3         Timeout

gs_get_1   moveq   #IO_FBYTE,d0        Set a trap
           trap    #3                  Fetch one byte
           tst.l   d0                  Check errors
           bne.s   gs_error            Failed, get out with error
           lsl.l   #8,d1               Make room for next byte
           dbra    d4,gs_get_1         Get next byte
           move.l  d7,a1               Restore maths stack pointer
           lsr.l   #8,d1               Shift down again, too far
           bra.s   fb_get              Skip


*====================================================================*
* FETCH_BYTES = Get the required number of bytes from the given      *
*              channel number.                                       *
*--------------------------------------------------------------------*
* There are two parameters, the first is a channel id and the second *
* is the required number of bytes. Get both as words, convert the    *
* first into a channel id and read the required number of bytes.     *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 2 + ??? for the result.            *
*====================================================================*
fetch_str  bsr     count_pars          How many this time ?
           subq.w  #2,d0               Should be 2
           beq.s   fb_2_ok             Ok

fb_badpar  moveq   #ERR_BP,d0          Bad Parameter

fb_error   rts                         Quit

fb_2_ok    bsr     check_hash          Check for the hash (#)
           beq.s   fb_badpar           No, oh dear
           moveq   #get_word,d0        I want 2 words
           bsr     get_params          Go get them
           bne.s   fb_error            Oops...
           moveq   #0,d0               Clear upper word of channel no
           move.w  0(a6,a1.l),d0       Get channel number first
           bsr     get_chan            Convert to an id
           moveq   #0,d1               Clear upper word of length
           move.w  2(a6,a1.l),d1       How many bytes to fetch

fb_get     move.l  d1,d7               Both.W = number of bytes, top word = 0
           bge.s   fb_2b_got           Some to be done >= 0 length
           bra.s   fb_badpar           Negative amount, quit

*--------------------------------------------------------------------*
* There are 4 bytes available on the maths stack, find out how many  *
* I need, D1 holds the size of the result string.                    *
*--------------------------------------------------------------------*
fb_2b_got  addq.l  #3,d1               Need space for the word count
           bclr    #0,d1               And to be even
           cmpi.l  #4,d1               Do I need room ?
           beq.s   fb_room_ok          No, only 4 required
           bgt.s   fb_more             Yes, more than 4 needed
           addq.l  #2,a1               Must only need 2 bytes then
           bra.s   fb_worked           Skip - zero length string

fb_more    subq.l  #4,d1               Extra bytes required
           move.l  a1,BV_RIP(a6)       Store current place
           bsr     bv_get              Reserve space

fb_room_ok move.l  a1,-(a7)            Save stack pointer for now
           addq.l  #2,a1               Leave room for word count
           move.l  d7,d2               Actual length required
           moveq   #timeout,d3         Infinity
           trap    #4                  Unrelative A1
           moveq   #IO_FSTRG,d0        Set a trap
           trap    #3                  Fetch string onto stack
           move.l  (a7)+,a1            Restore maths stack pointer
           tst.l   d0                  Check for errors
           bne.s   fb_exit             Exit, causing an error

fb_worked  move.w  d7,0(a6,a1.l)       Stack the actual word length (odd/even)
           moveq   #1,d4               Result is a string
           move.l  a1,BV_RIP(a6)       Save top of maths stack

fb_exit    rts                         Done


*====================================================================*
* PEEK_STRING = Get a number of bytes from a given address which may *
*              be odd as I use single byte moves.                    *
*--------------------------------------------------------------------*
* There must be 2 parameters, the first is a long address and the    *
* second is a word length.                                           *
*--------------------------------------------------------------------*
* Stack uses 6 bytes and requires 2 + ??? for the result.            *
*====================================================================*
peek_str   bsr     count_pars          Count parameters
           subq.w  #2,d0               Should be 2
           beq.s   pk_2_ok             Ok

pk_badpar  moveq   #ERR_BP,d0          Bad parameter

pk_error   rts                         Quit with error

pk_2_ok    moveq   #get_long,d0        Get address as long
           lea.l   8(a3),a5            Only getting 1
           bsr     get_params          Go get them
           bne.s   pk_error            Oh dear
           move.l  0(a6,a1.l),a4       Source address
           moveq   #get_word,d0        Get word length next
           move.l  a5,a3               Point to last parameter
           addq.l  #8,a5               Ditto
           bsr     get_params          Go get it
           bne.s   pk_error            Oh dear
           move.w  0(a6,a1.l),d7       Length
           blt.s   pk_badpar           Length is negative, quit & complain
           moveq   #0,d1               Clear it
           move.w  d7,d1               Get stack size required
           move.l  d1,d7               Save it (I know, but just wait !)
           addq.l  #3,d1               Space for word count
           bclr    #0,d1               And an even number
           cmpi.l  #6,d1               Is there room already ?
           beq.s   pk_room_ok          Yes, 6 bytes only required
           bgt.s   pk_more             No, needs more than 6,
           moveq   #6,d6               Find out how much to adjust stack by
           sub.l   d1,d6               It will be even !
           adda.l  d6,a1               Adjust stack
           bra.s   pk_room_ok          Skip

pk_more    subq.l  #6,d1               Extra bytes required
           move.l  a1,BV_RIP(a6)       Save current stack
           bsr     bv_get              Reserve extra space

pk_room_ok move.l  a1,BV_RIP(a6)       Store new maths stack
           move.w  d7,0(a6,a1.l)       Stack string actual length
           bra.s   pk_next             Skip dbra

pk_move_1  move.b  (a4)+,2(a6,a1.l)    Stack a byte
           addq.l  #1,a1               Point to next space

pk_next    dbra    d7,pk_move_1        Move the rest of the bytes
           move.l  BV_RIP(a6),a1       Make sure a1 & BV_RIP are equal
           moveq   #0,d0               No errors
           moveq   #1,d4               Result is a string
           rts                         Finished


*====================================================================*
* LEVEL2 = Test to see if the level 2 drivers are present or not.    *
*--------------------------------------------------------------------*
* There must be 1 parameter preceeded by a hash. Return 1 if there   *
* are level 2 drivers on the connected device, zero if not.          *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 2 for the result.                  *
*====================================================================*
level2     bsr     count_pars          There should be 1
           moveq   #2,d2               Assume an error will occur
           subq.w  #1,d0               Was there 1 ?
           beq.s   l2_1_ok             Yes

l2_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     integer_bv          Quit via an unused stack

l2_error   rts                         Quit

l2_1_ok    bsr     check_hash          Test for the hash (#)
           beq.s   l2_badpar           Not there, quit & complain
           moveq   #64,d1              This big
           bsr     mtalchp             Allocate it (preserves D2)
           bne.s   l2_ret_err          Oops...
           move.l  a0,d5               Save buffer address
           moveq   #get_long,d0        Get 1 long please
           bsr     get_params          Go get it
           bne.s   l2_error            Oops...
           move.l  0(a6,a1.l),d0       Get channel number
           addq.l  #2,a1               Tidy stack but leave room for a word
           bsr     get_chan            Convert to id in A0 for trap
           bne.s   l2_ret_d0           Oops...
           move.l  a1,d7               A1 gets corrupted
           moveq   #IOF_XINF,d0        Use extended trap
           moveq   #0,d1               Must be, why ?
           moveq   #0,d2               Interrogate mode
           moveq   #timeout,d3         Infinity rules ok ?
           move.l  d5,a1               Buffer address in A1 for trap
           trap    #3                  Do extended trap, A0 & A1 preserved
           move.l  d0,d6               Store error code
           moveq   #MT_RECHP,d0        Trap is set
           move.l  a1,a0               Buffer address
           trap    #1                  Release buffer, no errors
           moveq   #0,d2               I don't need any extra space
           move.l  d7,a1               Restore maths stack
           move.l  d6,d1               Restore previous error code
           beq.s   l2_ret_1            Level 2 is present
           moveq   #0,d1               Level 2 drivers not found
           bra     integer_d1          Back to SuperBasic

l2_ret_d0  moveq   #0,d2               Stack is fine

l2_ret_err move.l  d0,d1               Get error code
           bra     integer_d1          Return it as result

l2_ret_1   moveq   #1,d1               Flag found level 2 drivers
           bra     integer_d1          And finished


*====================================================================*
* CHECK = Return a 1 if the procedure/function name given exists in  *
*         the name list.                                             *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be a string.                *
*--------------------------------------------------------------------*
* Stack uses 2 + ??? bytes and requires 2 for the result.            *
*====================================================================*
check      bsr     count_pars          Count those parameters
           moveq   #2,d2               Always assume the worst (pessimist !)
           subq.w  #1,d0               Should be 1
           beq.s   ch_1_ok             Yes

ch_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     integer_bv          Quit with error result

ch_error   rts                         Quit

ch_1_ok    moveq   #get_string,d0      I want a string
           bsr     get_params          Go get it
           bne.s   ch_error            Oh dear
           moveq   #0,d7               Clear upper word
           move.w  0(a6,a1.l),d7       Get word length of string
           ble.s   ch_badpar           Complain if null or negative
           lea.l   2(a1),a5            Use A5 for a loop
           move.w  d7,d0               Get length again
           bra.s   ch_next             Skip for dbra

*--------------------------------------------------------------------*
* Convert the name on the stack to lower case by setting bit 5. This *
* prepares the name being looked for for later on.                   *
*--------------------------------------------------------------------*
ch_case    ori.b   #32,(a6,a5.l)       Force case change if required
           addq.l  #1,a5               Point to next byte

ch_next    dbra    d0,ch_case          Do next byte

*--------------------------------------------------------------------*
* Now, find system variables from MT_JINF, find BASIC from there,    *
* get the start of the name table in A3, the end in A5 (just like in *
* a PROC or FN) and the start of the name list in D1.                *
*--------------------------------------------------------------------*
           move.l  a1,-(a7)            Gets corrupted by MT_JINF
           moveq   #MT_JINF,d0         Set the trap
           moveq   #0,d1               Info on SuperBasic required
           move.l  d1,d2               Top of tree = SuperBasic
           trap    #1                  Go get info
           move.l  (a7)+,a1            Restore again
           tst.l   d0                  Did it work ?
           beq.s   ch_inf              Yes, skip
           move.w  d0,d1               Get error code as result
           bra.s   ch_tidy             And exit with it

ch_inf     move.l  BV_NTBAS(a0),a3     A3,A0 = start of name table = PROC/FN
           move.l  BV_NTP(a0),a5       A5,A0 = end of name table = PROC/FN
           move.l  BV_NLBAS(a0),d1     D1,A0 = start of name list

*--------------------------------------------------------------------*
* Loop around the whole name table looking for machine code PROCs &  *
* FNs, at the end, return 0 for not found.                           *
*--------------------------------------------------------------------*
ch_type    move.w  0(a3,a0.l),d0       Get name's type word
           cmpi.w  #$0800,d0           Is it a machine code procedure ?
           beq.s   ch_proc_fn          Yes
           cmpi.w  #$0900,d0           Try machine code function
           beq.s   ch_proc_fn          Yes

ch_end     addq.l  #8,a3               Try next name
           cmpa.l  a5,a3               Finished yet ?
           bge.s   ch_not_fnd          Yes - not found
           bra.s   ch_type             No, try next entry in name table

*--------------------------------------------------------------------*
* If we get here, we have found a machine code PROC/FN, get the      *
* offset into the name list and pick up its length byte, note byte   *
* not word, and not even addresses either.                           *
*--------------------------------------------------------------------*
ch_proc_fn move.w  2(a3,a0.l),a2       Offset into name list
           adda.l  d1,a2               Start of name list, but...
           cmp.b   0(a2,a0.l),d7       Its all relative = 0(a0,a2,d1) !!
           bne.s   ch_end              Wrong length, try again

*--------------------------------------------------------------------*
* Got a byte at 0(a2,a0.l) which is the length of the name list      *
* entry being studied. Now check the bytes in the name which is still*
* on the maths stack at 2(a6,a1.l) and has been all this time !      *
*--------------------------------------------------------------------*
           move.w  d7,d0               Size of name
           move.l  a1,-(a7)            Save maths pointer
           bra.s   ch_next_2           Skip dbra

ch_test    move.b  1(a2,a0.l),d2       Get a byte from name list
           ori.b   #32,d2              Force lower case
           cmp.b   2(a6,a1.l),d2       Test it
           bne.s   ch_quit             No match, exit loop
           addq.l  #1,a1               Point to next byte on stack
           addq.l  #1,a2               And in the name list

ch_next_2  dbra    d0,ch_test          Do the rest of the bytes

*--------------------------------------------------------------------*
* If we get out of the dbra here, we have found the name. Yippee !   *
*--------------------------------------------------------------------*
           moveq   #0,d0               Flag found

ch_quit    move.l  (a7)+,a1            Retrieve the maths stack pointer
           tst.w   d0                  Check the flag
           bne.s   ch_end              Try another name
           moveq   #1,d1               Result = found
           bra.s   ch_tidy             Prepare to exit

ch_not_fnd moveq   #0,d1               Result = not found

ch_tidy    addq.w  #1,d7               Prepare to make even
           bclr    #0,d7               Make even
           adda.w  d7,a1               Add string length, leaves room for word
           moveq   #0,d2               No extra space required for result
           bra     integer_d1          And return the result to SuperBasic


*====================================================================*
* BYTES_FREE = Return the amount of free space left in the QL as a   *
*              number of bytes. For the sake of this function, the   *
*              free memory starts at SV_FREE and stops at SV_BASIC.  *
*--------------------------------------------------------------------*
* No parameters allowed.                                             *
*--------------------------------------------------------------------*
* Stack uses 0 bytes and requires 6 for the result.                  *
*====================================================================*
free_byte  moveq   #0,d7               Flag for BYTES_FREE
           bra.s   fm_do_it            Skip


*====================================================================*
* KBYTES_FREE = Return the amount of free space left in the QL as a  *
*              number of Kilobytes. For the sake of this function,   *
*              the free memory starts at SV_FREE and stops at        *
*              SV_BASIC.                                             *
*--------------------------------------------------------------------*
* No parameters allowed.                                             *
*--------------------------------------------------------------------*
* Stack uses 0 bytes and requires 6 for the result.                  *
*====================================================================*
free_mem   moveq   #10,d7              Flag for KBYTES_FREE

fm_do_it   bsr     count_pars          I don't expect to find any
           beq.s   fm_none             I didn't

fm_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra.s   fm_ret_d1           Exit


fm_none    bsr     mtinf               Do MT_INF trap
           move.l  SV_BASIC(a0),d1     Start of Basic
           sub.l   SV_FREE(a0),d1      Minus start of free memory
           lsr.l   d7,d1               Make into KBYTES_FREE if flag set

fm_ret_d1  moveq   #6,d2               Extra space for result
           bra     float_bv            Return result to SuperBasic


*====================================================================*
* SEARCH_I = Look in memory for characters matching a required       *
*          string treat case as unimportant.                         *
*--------------------------------------------------------------------*
* There must be three parameters, 2 longs for start address & length *
* and one string for what to look for.                               *
*--------------------------------------------------------------------*
* Stack uses 8 + 2 + ??? bytes and requires 6 for the result.        *
*====================================================================*
search_i   moveq   #1,d7               Ignore case flag
           bra.s   s_do_it             Skip


*====================================================================*
* SEARCH_C = Look in memory for characters matching a required string*
*            treating case as important.                             *
*--------------------------------------------------------------------*
* There must be three parameters, 2 longs for start address & length *
* and one string for what to look for.                               *
*--------------------------------------------------------------------*
* Stack uses 8 + 2 + ??? bytes and requires 6 for the result.        *
*====================================================================*
search_c   moveq   #0,d7               Case is important flag

s_do_it    bsr     count_pars          Count parameters
           moveq   #6,d2               Required space for result if errors
           subq.w  #3,d0               Should be 3
           beq.s   s_3_ok              Yes

s_badpar   moveq   #ERR_BP,d1          Bad parameter
           bra     float_bv            Stack is unused remember ?

s_error    rts                         Exit & complain

s_3_ok     lea.l   16(a3),a5           Get first 2 only
           moveq   #get_long,d0        As long words
           bsr     get_params          Go get them
           bne.s   s_error             Oh dear
           move.l  0(a6,a1.l),a4       A4 = start address of scan area
           move.l  4(a6,a1.l),d5       D5 = length of scan area
           bgt.s   s_got_ok            Length is ok

*--------------------------------------------------------------------*
* Length is bad, stack uses 8 bytes but only 6 are needed.           *
*--------------------------------------------------------------------*
           addq.l  #2,a1               Leave room for a float
           moveq   #ERR_BP,d1          Bad parameter
           bra     s_quit              Return error code

s_got_ok   move.l  a5,a3               Point to last parameter
           lea.l   8(a3),a5            Ditto
           moveq   #get_string,d0      I want 1 string this time
           bsr     get_params          Go get it
           bne.s   s_error             Oh dear
           moveq   #0,d1               Clear upper word
           move.w  0(a6,a1.l),d1       Get length of string
           lea.l   2(a1),a5            Pointer to stacked string (relative A6)
           move.l  d5,d0               Length of scan area
           move.l  d1,d2               Length of string
           addq.l  #3,d2               Include length word & prepare to...
           bclr    #0,d2               ...Make even
           adda.l  d2,a1               Tidy string off stack, leaves 8 bytes
           addq.l  #2,a1               Now room for FLOAT result

*--------------------------------------------------------------------*
* ENTRY at label S_SCAN                                              *
*                                                                    *
* D0.L = Number of bytes to be scanned                               *
* D2.B = Used as a found it flag, 0 = not found, 1 = found           *
* D3.B = Used to hold a byte from memory to avoid changes            *
* D1.W = Length of string                                            *
* D7.B = Case flag (0 = check case, 1 = ignore case)                 *
*                                                                    *
* A1.L = Place on maths stack to store a float                       *
* A4.L = Start address of memory being searched                      *
* A5.L = Start of string on stack, relative A6                       *
* A6.L = Usual Basic value                                           *
*--------------------------------------------------------------------*
s_scan     moveq   #0,d2               Preset found flag to not found
           tst.w   d1                  Is string NULL ?
           beq.s   so_ret_0            Yes, not found
           sub.l   d1,d0               Adjust maximum memory count
           bcs.s   so_ret_0            Unsigned calcs now ! (not found)
           subq.w  #1,d1               Adjust string length for 'dbra'
           tst.b   d7                  Checking case ?
           beq.s   s_outer             Yes, skip

*--------------------------------------------------------------------*
* Case being ignored, so scan the string on the stack for any lower  *
* case letters only, and if I find any, convert to UPPER case, all   *
* other characters remain the same.                                  *
*--------------------------------------------------------------------*
s_upper    movem.l d1/a5,-(a7)         Stack dbra counter & search$ pointer

s_case     move.b  0(a6,a5.l),d3       Get a byte of PROC/FN name
           cmpi.b  #'a',d3             Only change lower case characters
           bcs.s   s_next              Not lower case
           cmpi.b  #'z',d3
           bhi.s   s_next              Still not lower case
           bclr    #5,0(a6,a5.l)       Change to UPPER case (on stack)

s_next     addq.l  #1,a5               Point to next byte on stack
           dbra    d1,s_case           Do the rest
           movem.l (a7)+,d1/a5         Retrieve dbra counter & search$ pointer

*--------------------------------------------------------------------*
* The outer loop, controlled by D0.L, scans through the area being   *
* searched until it comes across a character that matches the first  *
* character of the search string. If it doesn't find one, it exits   *
* with D2.L = 0 which it puts into D1 and floats back to SuperBasic. *
* D3.B is used to hold the byte from memory, this is to avoid changes*
* being made to actual memory contents if the case is being ignored. *
*--------------------------------------------------------------------*
s_outer    move.b  (a4),d3             Get a byte from memory
           tst.b   d7                  Checking case ?
           beq.s   so_scan             Yes, skip
           cmpi.b  #'a',d3             Check its case
           bcs.s   so_scan             Not a lower case letter
           cmpi.b  #'z',d3             Try again
           bhi.s   so_scan             Still not lower case
           bclr    #5,d3               Change to UPPER case

so_scan    cmp.b   0(a5,a6.l),d3       Test against first byte of string
           beq.s   s1_found            It matches

so_next    addq.l  #1,a4               Try next byte in memory
           subq.l  #1,d0               Adjust memory count
           bge.s   s_outer             And try again if more to do

so_ret_0   move.l  d2,a4               Not found a4 = 0 = address found at
           bra.s   so_end              And exit

*--------------------------------------------------------------------*
* The inner loop is controlled by D1.W which is the length of the    *
* string on the stack, adjusted for dbra. This loop scans along the  *
* remaining bytes of the search string and the scan area until it    *
* has found the search string or a mis match occurs. If found, D2 is *
* set to 1 and the return address is in A4, otherwise we quit from   *
* the inner loop and go back to the outer one and search for the next*
* occurance of the first character of the string.                    *
*--------------------------------------------------------------------*
s1_found   movem.l a4-a5/d1,-(a7)      Stack memory, string address & length
           bra.s   si_next             Don't check current byte twice

s_inner    move.b  (a4),d3             Get next byte from memory
           tst.b   d7                  Checking case ?
           beq.s   si_scan             Yes, skip case change
           cmpi.b  #'a',d3             Check its case
           bcs.s   si_scan             Not a lower case letter
           cmpi.b  #'z',d3             Try again
           bhi.s   si_scan             Still not lower case
           bclr    #5,d3               Change case to UPPER

si_scan    cmp.b   0(a5,a6.l),d3       Does it still match ?
           bne.s   si_end              No match

si_next    addq.l  #1,a4               Next memory byte
           addq.l  #1,a5               Next string on stack byte
           dbra    d1,s_inner          Continue matching

si_found   moveq   #1,d2               A match has been found

si_end     movem.l (a7)+,a4-a5/d1      Get back counters
           tst.l   d2                  Check if found
           beq.s   so_next             Not found, repeat outer loop

so_end     move.l  a4,d1               D1 = 0 or start address

s_quit     moveq   #0,d2               Stack has enough room, thank you !
           beq     float_d1            Exit


*====================================================================*
* DEV_NAME = Return a string being a device name from the directory  *
*            device linked list. Update the parameter supplied so    *
*            that the search can continue on the next call. First    *
*            call should be zero.                                    *
*--------------------------------------------------------------------*
* Note that updating the supplied parameter will not allow this      *
* function to be compiled by Supercharge or Turbo, only QLiberator.  *
*--------------------------------------------------------------------*
* Only one parameter allowed and it must be long.                    *
*--------------------------------------------------------------------*
* Stack uses 4 bytes and requires 6 for the float then 2 + ??? for   *
* the string, tricky one this !                                      *
*====================================================================*
dev_name   bsr     count_pars          Check parameter count
           subq.w  #1,d0               Should only be 1
           beq.s   dn_1_ok             Yes

dn_badpar  moveq   #ERR_BP,d0          Bad parameter

dn_error   rts                         Quit & complain

dn_1_ok    moveq   #get_long,d0        I want a long one
           bsr     get_params          Go get it then
           bne.s   dn_error            Oops
           move.l  0(a6,a1.l),d0       Get parameter
           beq.s   dn_zero             It is zero, search from start of list
           move.l  d0,a0               Assume a valid address
           move.l  (a0),a0             Pick up next address in list
           bra.s   dn_got_a0           Skip

*--------------------------------------------------------------------*
* If the parameter is zero, pick up the start of the Directory       *
* driver list, otherwise it is assumed to be the pointer to the last *
* device returned's linkage block, so carry on from there.           *
*--------------------------------------------------------------------*
dn_zero    bsr     mtinf               Do MT_INF trap
           move.l  SV_DDLST(a0),a0     A0 now points at first driver linkage

dn_got_a0  moveq   #0,d4               Clear device name length
           cmpa.l  #0,a0               Finished yet ?
           beq.s   dn_stack            Yes, no more linkage blocks
           move.w  $24(a0),d4          Get size of device name

*--------------------------------------------------------------------*
* Float the address in A0 and call BP_LET to assign it back to the   *
* supplied parameter. The last call should reset it to 0 again. A3.L *
* better still be pointing at it in the name table as per entry.     *
*--------------------------------------------------------------------*
dn_stack   movem.l d1-d5/a0,-(a7)      Float_d1 is bad news for these
           move.l  a0,d1               Result in D1 for conversion
           moveq   #2,d2               I need 2 extra bytes for the float
           bsr     float_d1            Float address & stack it
           move.l  a1,-(a7)            Save A1 during BP_LET
           move.w  BP_LET,a2           Get the vector
           jsr     (a2)                Set parameter to next address
           move.l  (a7)+,a1            Safe stack pointer again
           movem.l (a7)+,d1-d5/a0      Restore registers

*--------------------------------------------------------------------*
* Stack now uses 6 bytes and requires 2 + ??? for the result.        *
*--------------------------------------------------------------------*
           tst.l   d0                  Did BP_LET actually work ?
           bne.s   dn_done             No, bale out & complain
           move.l  d4,d1               Name length
           addq.l  #3,d1               Plus word count
           bclr    #0,d1               And even
           cmpi.l  #6,d1               Is there enough room now ?
           beq.s   dn_room_ok          Yes, 6 only wanted
           bgt.s   dn_more             No, more than 6 required
           moveq   #6,d5               Prepare to adjust stack
           sub.l   d1,d5               By this (even) amount
           adda.l  d5,a1               Adjust maths stack
           bra.s   dn_room_ok          Skip

dn_more    subq.l  #6,d1               Make D1 = extra bytes required
           move.l  a1,BV_RIP(a6)       Save current pointer
           bsr     bv_get              Reserve space

dn_room_ok move.w  d4,0(a6,a1.l)       Stack actual length of device name
           move.l  a1,a4               And A1 too
           bra.s   dn_next             Skip dbra

dn_shift   move.b  $26(a0),2(a6,a4.l)  Stack 1 byte
           addq.l  #1,a0               Point to next byte in name
           addq.l  #1,a4               And to next byte on stack

dn_next    dbra    d4,dn_shift         Do another byte
           move.l  a1,BV_RIP(a6)       Store maths stack
           moveq   #1,d4               Its a string result
           moveq   #0,d0               No errors

dn_done    rts                         Exit, we hope !


*====================================================================*
* USE_FONT - Sets the font(s) in use for a given channel number, if  *
*            the channel number is not present, use #1 as default.   *
*--------------------------------------------------------------------*
* Requires three parameters, the first preceeded by a hash as a      *
* channel is being specified, the other 2 are addresses where a font *
* file has been stored.                                              *
*--------------------------------------------------------------------*
* Uses 12 bytes of stack and does not care about returns.            *
*====================================================================*
use_font   bsr     count_pars          How many parameters ?
           cmpi.w  #3,d0               Should be 1, 2 or 3 left
           beq.s   uf_ok               Yes, skip

uf_badpar  moveq   #ERR_BP,d0          Bad parameter

uf_exit    rts                         Quit

uf_ok      bsr     check_hash          Is there a channel number
           beq.s   uf_badpar           No, skip
           moveq   #get_long,d0        Get all params as long words
           bsr     get_params          Go get them
           bne.s   uf_exit             Oops ...
           move.l  a1,a5               I need A1 later
           move.l  4(a6,a5.l),a1       Get font 1 address
           move.l  8(a6,a5.l),a2       Get font 2 address
           move.l  0(a6,a5.l),d0       Get channel number
           bmi.s   uf_badpar           Oops, negative is bad news
           bsr     get_chan            Convert to id in A0
           bne.s   uf_exit             Oops ...
           moveq   #sd_fount,d0        Set a trap
           moveq   #timeout,d3         And take all day if you like
           trap    #3                  Do it
           rts                         Take the error back to SuperBasic


*====================================================================*
* SET_XINC - sets the horozontal spacing for each character in the   *
*            given channel.                                          *
*--------------------------------------------------------------------*
* Uses 4 bytes on the maths stack and doesn't care about returns.    *
*====================================================================*
set_xinc   moveq   #SD_XINC,d7         Flag for SET_XINC
           bra.s   sxy_do_it           Skip


*====================================================================*
* SET_YINC - sets the vertical spacing for each character in the     *
*            given channel.                                          *
*--------------------------------------------------------------------*
* Uses 4 bytes on the maths stack and doesn't care about returns !   *
*====================================================================*
set_yinc   moveq   #SD_YINC,d7         Flag for SET_YINC

sxy_do_it  bsr     count_pars          How many parameters ?
           subq.w  #2,d0               Must be 2
           beq.s   sx_2                More than zero

sx_badpar  moveq   #ERR_BP,d0          Bad parameter

sx_exit    rts                         And quit

sx_2       bsr     check_hash          Try for a hash
           beq.s   sx_badpar           Oops...
           moveq   #get_word,d0        Get params as word integers
           bsr     get_params          Go get them
           bne.s   sx_exit             Oops ...
           moveq   #0,d0               Clear upper word
           move.w  2(a6,a1.l),d1       Get increment size
           move.w  0(a6,a1.l),d0       Get channel number
           bmi.s   sx_badpar           Negative is bad
           bsr     get_chan            Convert to channel id in A0
           bne.s   sx_exit             Oops ...
           moveq   #sd_extop,d0        Prepare to trap the unwary
           move.w  d7,d2               Offset into channel block
           moveq   #timeout,d3         How long you get to do it
           lea.l   sx_extop,a2         Routine to be called
           trap    #3                  Call it
           rts                         Exit with or without errors


*====================================================================*
* EXTOP routine for SET_XINC & SET_YINC, this simply stores the data *
* in D1.W, the new character increment, at the offset in D2.W, which *
* is either SD_XINC or SD_YINC, relative to the base of the channel  *
* definition block which QDOS is kind enough to pass in A0.L on entry*
* to this routine.                                                   *
*====================================================================*
sx_extop   move.w  d1,0(a0,d2.w)       Store the new increment
           moveq   #0,d0               There are no errors
           rts                         And exit


*====================================================================*
* QPTR = Return 1 if PTR_GEN/WMAN present otherwise return 0 or an   *
*        error code.                                                 *
*--------------------------------------------------------------------*
* Requires a channel id prefixed by a hash (#) as the only parameter *
* this is used to call IOP_PINF to get information on PTR/WMAN.      *
*--------------------------------------------------------------------*
* Uses 2 bytes on the stack for the parameter and requires 2 for the *
* result.                                                            *
*====================================================================*
qptr       bsr     count_pars          Count the parameters
           moveq   #2,d2               Space required for an error
           subq.w  #1,d0               Should be 1 only
           beq.s   qp_got_1            Ok

qp_badpar  moveq   #ERR_BP,d1          Bad parameter
           bra     integer_bv          Stack still unused

qp_exit    rts                         

qp_got_1   bsr     check_hash          There should be a hash
           beq.s   qp_badpar           Oops
           moveq   #get_word,d0        I need a word
           bsr     get_params          Go get it then
           bne.s   qp_exit             Oops
           moveq   #0,d0               Clear for action
           move.w  0(a6,a1.l),d0       Get channel id
           bge.s   qp_ch_ok            Zero or more is fine
           moveq   #ERR_BP,d0          Oops...
           bra.s   qp_ret_d0           Exit with the bad news

qp_ch_ok   bsr     get_chan            Convert to id
           beq.s   qp_got_ch           Converted ok

qp_ret_d0  move.l  d0,d1               Get error code
           moveq   #0,d2               No space required
           bra     integer_d1          Return error code to SuperBasic

qp_got_ch  moveq   #0,d2               No extra space required
           moveq   #IOP_PINF,d0        Set a trap
           moveq   #timeout,d3         Take all day if you like
           move.l  a1,a3               Save maths stack
           trap    #3                  Do it
           move.l  a3,a1               Restore maths stack
           tst.l   d0                  Trap ok ?
           beq.s   qp_ret_1            Yes, skip
           cmpi.l  #ERR_BP,d0          Bad Parameter = no QPTR
           bne.s   qp_ret_d0           Other error, quit
           moveq   #0,d1               No QPTR present
           bra     integer_d1

qp_ret_1   moveq   #1,d1               QPTR present
           bra     integer_d1


*====================================================================*
* WHERE_FONTS = Return the address of font 1 or font 2 for the given *
*              channel.                                              *
*--------------------------------------------------------------------*
* Requires 2 parameters, the first a channel number must be prefixed *
* by the obligitory hash, the second must be 1 or 2 and specifies    *
* which font address is required. Any other value causes an error.   *
*--------------------------------------------------------------------*
* Uses 4 bytes for parameters and requires 6 for a float result.     *
*====================================================================*
w_fonts    bsr     count_pars          Check those parameters
           moveq   #6,d2               I assume that something is wrong
           subq.w  #2,d0               I need 2 only
           beq.s   wf_got_2            Ok

wf_bad_par moveq   #ERR_BP,d1          Bad parameter
           bra     float_bv            Stack is still brand new

wf_exit    rts                         Quit

wf_got_2   bsr     check_hash          There must be a hash
           beq.s   wf_bad_par          Oops
           moveq   #get_word,d0        I need a word or two
           bsr     get_params          Go get them
           bne.s   wf_exit             Oops
           moveq   #0,d0               Clear upper word
           move.w  2(a6,a1.l),d7       Get font number
           move.w  0(a6,a1.l),d0       Get channel number
           bge.s   wf_get_ch           Channel is valid
           moveq   #2,d2               Can I have some more please ?
           bra.s   wf_oops             And quit

wf_get_ch  bsr     get_chan            Convert to id
           beq.s   wf_id_ok            Ok

wf_ret_d0  move.l  d0,d1               Get error code
           moveq   #2,d2               Extra space required
           bra     float_d1            Float error back to SuperBasic

wf_id_ok   move.l  a1,a5               Save maths stack
           moveq   #SD_EXTOP,d0        Set a trap
           moveq   #timeout,d3         Takes a while this you know...
           lea.l   wf_extop,a2         Get address of routine
           trap    #3                  And call it
           move.l  a1,a0               Save definition block address
           move.l  a5,a1               Restore maths stack
           tst.l   d0                  Did trap work ?
           bne.s   wf_ret_d0           No, return error
           moveq   #2,d2               Extra space required
           cmpi.w  #1,d7               Font 1 required ?
           bne.s   wf_2                No
           move.l  SD_FONT(a0),d1      Get font 1 address
           bra     float_d1            Return it to SuperBasic

wf_2       cmpi.w  #2,d7               Try font 2
           bne.s   wf_oops             Oh shit !
           move.l  SD_FONT+4(a0),d1    Get font 2 address
           bra     float_d1            Return it to SuperBasic

wf_oops    moveq   #ERR_BP,d1          Oops, not 1 or 2 required
           bra     float_d1            And return it to SuperBasic


*--------------------------------------------------------------------*
* EXTOP for WHERE_FONTS - simply returns address of definition block *
*--------------------------------------------------------------------*
wf_extop   move.l  a0,a1               Get definition block address
           moveq   #0,d0               No problems
           rts                         And finally Esther...


*====================================================================*
* MAX_DEVS = return count of the number of directory devices in the  *
*            QL. Uses no stack for parameters but requires 2 for the *
*            result or error code.                                   *
*====================================================================*
max_devs   bsr     count_pars          Check how many
           beq.s   mdv_none            Got none = ok

mdv_badpar moveq   #err_bp,d1          Oops !

mdv_done   moveq   #2,d2               2 bytes required for error/result
           bra     integer_bv          Stack it & return it

mdv_none   bsr     mtinf               Get A0 = sys_vars
           moveq   #0,d1               Running total
           move.l  sv_ddlst(a0),a0     A0 = start of directory driver list

mdv_next   cmpa.l  #0,a0               Done yet ?
           beq.s   mdv_done            Yes, quit
           addq.w  #1,d1               Count this device
           move.l  (a0),a0             Next in list
           bra.s   mdv_next            Do some more


*====================================================================*
* POKE_FLOAT = poke a float into memory. Uses 10 for params and none *
*              for the result as it is a PROC.                       *
*====================================================================*
poke_float bsr     count_pars          Must have 2 params
           subq.w  #2,d0
           beq.s   pkf_ok              Found 2

pkf_badpar moveq   #err_bp,d0          Oops !
pkf_exit   rts                         Bye !

pkf_ok     lea.l   8(a3),a5            Pretend to get 1 only
           moveq   #get_long,d0        I want a long one !
           bsr     get_params          Go get it
           bne.s   pkf_exit            Oh bugger !
           move.l  0(a6,a1.l),a4       Get address
           addq.l  #4,a1               Tidy up again
           move.l  a5,a3               Prepare to ...
           addq.l  #8,a5               ... get value
           moveq   #get_float,d0       As a float
           bsr     get_params          Go get it
           bne.s   pkf_exit            Oops !
           moveq   #5,d0               6 bytes to shift

pkf_loop   move.b  0(a6,a1.l),(a4)+    Save a byte
           addq.l  #1,a1               Point to next
           dbra    d0,pkf_loop         And the rest
           moveq   #0,d0               No errors
           rts                         Back to caller


*====================================================================*
* PEEK_FLOAT = return 6 bytes as a floating point number. Uses 4 for *
*              the parameter and needs 6 for the result.             *
*====================================================================*
peek_float bsr     count_pars          Count them
           subq.w  #1,d0               Only 1 required
           beq.s   pekf_ok             Ok

pek_badpar moveq   #6,d2               Stack unused as yet
           moveq   #err_bp,d1
           bra     float_bv            Return error as float

pekf_ok    moveq   #get_long,d0        I want a long one !
           bsr     get_params          Go get it then
           beq.s   pekf_got            Ok
           rts                         Cannot trust stack, so bale out

pekf_got   move.l  0(a6,a1.l),a2       Get address
           moveq   #2,d1               2 more bytes required
           bsr     bv_get
           move.l  a1,bv_rip(a6)       Save new stack top
           moveq   #5,d0               6 bytes in a float = 5 in DBRA

pekf_loop  move.b  (a2)+,0(a6,a1.l)    Stack a byte
           addq.l  #1,a1               Next available space on stack
           dbra    d0,pekf_loop        Do the rest
           moveq   #0,d0               No errors
           moveq   #2,d4               Result is floating
           move.l  bv_rip(a6),a1       Set A1 again
           rts                         Bye !


*====================================================================*
* chan = DJ_OPEN_?? => returns channel id or error code for the open *
*                     based on Simon Goodwins DIY TK routines but a  *
*                     slight modification for DJToolkit. Uses 2 + ?  *
*                     on entry and requires 2 for result.            *
*====================================================================*
dj_open    moveq   #0,d5               Flag DJ_OPEN
           bra.s   do_open

dj_in      moveq   #1,d5               Flag DJ_OPEN_IN
           bra.s   do_open

dj_new     moveq   #2,d5               Flag DJ_OPEN_NEW
           bra.s   do_open

dj_over    moveq   #3,d5               Flag DJ_OPEN_OVER
           bra.s   do_open

dj_dir     moveq   #4,d5               Flag DJ_OPEN_DIR
           bra.s   do_open

sng_credit dc.b    'Credit to SNG'

do_open    bsr     count_pars          Count params
           subq.w  #1,d0               I need only 1
           beq.s   dj_ok               Correct

dj_badpar  moveq   #err_bp,d1          Oops !
dj_done    moveq   #2,d2               Stack unused, I require 2
           bra     integer_bv          Bale out

dj_ok      moveq   #get_string,d0      I want a piece of string
           bsr     get_params          Go get it
           beq.s   dj_gotit            Ok

dj_error   rts                         Stack is unknown, bale out

dj_gotit   moveq   #io_open,d0         Prepare to open a file
           moveq   #me,d1              For this job
           move.l  d5,d3               Get the open type
           move.l  a1,a0               Pointer to address
           move.l  a1,-(a7)            Gets trashed by TRAP #4/TRAP #2
           trap    #4                  Signal that A0 is relative A6
           trap    #2                  Open file
           move.l  (a7)+,a1            Restore maths stack
           move.w  0(a6,a1.l),d1       Word length
           addq.w  #1,d1
           bclr    #0,d1               Make even
           adda.w  d1,a1               Tidy stack
           tst.l   d0                  Did open work ?
           bne.s   dj_ret_d0           No, bale out

*--------------------------------------------------------------------*
* Channel is open id in A0.L, stuff it into the SB  channel area. D0 *
* must be set to zero as well.                                       *
*--------------------------------------------------------------------*
           move.l  bv_chbas(a6),a2     Base of table
           moveq   #$28,d1             Size of an entry in tab le

dj_scan    cmpa.l  bv_chp(a6),a2       Done yet ?
           bge.s   dj_make_rm          Yes, need to add an entry
           tst.b   0(a6,a2.l)          Is this channel closed ?
           bmi.s   dj_room_ok          Yes, we can use it
           addq.w  #1,d0               Increment channel number
           adda.l  d1,a2               Next entry in table
           bra.s   dj_scan             Do it all over again

*--------------------------------------------------------------------*
* No room, or any closed channels in the table, call an undocumented *
* QDOS routine to make room for 1 channel entry.                     *
*--------------------------------------------------------------------*
dj_make_rm move.w  d0,d6               Save channel number for later
           move.w  bv_chrix,a2         Get base vector
           lea     $2C(a2),a2          Set to 'make channel room' vector
           jsr     (a2)                Go do it
           move.l  bv_chp(a6),a2       Top of (new) table
           lea     $28(a2),a3          Top of final entry
           move.l  a3,bv_chp(a6)       Mark new top entry in table
           move.w  d6,d0               Restore channel number

*--------------------------------------------------------------------*
* Room at the inn has been found, (A2,A6) points to first byte in the*
* table for this channel, D0.W holds the channel number for returning*
* to SuperBasic, A0.L holds the QDOS channel id.                     *
*--------------------------------------------------------------------*
dj_room_ok move.l  a0,0(a6,a2.l)       Store channel id
           moveq   #7,d1               8 * 4 = 32 bytes to clear (DBRA)

dj_clear   addq.l  #4,a2               Skip a bit
           clr.l   0(a6,a2.l)          Zap this long word
           dbra    d1,dj_clear         And some more
           move.b  #$50,3(a6,a2.l)     Set the default width to 80 chars

dj_ret_d0  moveq   #0,d1               Just in case
           move.w  d0,d1               Error or channel number
           moveq   #0,d2               No spare room required
           bra     integer_d1          A1 is tidy stack address


*====================================================================*
* error = MAX_CON #channel, x%, y%, xo%, yo% => returns an error and *
*                updates the 4 (non-channel) parameters to be the    *
*                maximum sizes & positions that a CON channel is.    *
*====================================================================*
max_con    bsr     count_pars          I need 5 parameters
           subq.w  #5,d0               Ok ?
           beq.s   mc_got_5            Yes

mc_badpar  moveq   #err_bp,d1          Oops
           moveq   #2,d2               Stack not used, needs 2 bytes
           bra     integer_bv          Bale out

mc_got_5   bsr     check_hash          I need a hash
           beq.s   mc_badpar           Oops, no hash
           moveq   #get_word,d0
           bsr     get_params          I need them as words
           beq.s   mc_got_ok           All ok
           rts                         Can't trust the stack now !

mc_got_ok  moveq   #0,d0               Just in case
           move.w  0(a6,a1.l),d0       Get channel id
           bsr     get_chan            Convert D0 to id in A0
           addq.l  #8,a1               Tidy stack, room for integer result
           move.l  a1,bv_rip(a6)       Save it for later, we will use it
           subq.l  #8,a7               Result buffer for IOP_FLIM
           tst.l   d0                  Did get_chan work
           bne.s   mc_done             No, return error code

mc_flim    move.l  a7,a1               Result buffer pointer
           move.l  a1,a5               And again
           moveq   #iop_flim,d0
           moveq   #0,d2
           moveq   #timeout,d3
           trap    #3                  Call IOP_FLIM preserves all reggies
           tst.l   d0                  Ok ?
           bne.s   mc_done             No, bale out with error code
           move.w  bp_let,a4           Preserved during bp_let
           moveq   #3,d4               Ditto

mc_loop    move.l  bv_rip(a6),a1       Gets trashed by bp_let
           addq.l  #8,a3               Point to next parameter
           move.w  (a5)+,0(a6,a1.l)    Stack next result word
           jsr     (a4)                Call bp_let
           tst.l   d0                  Did it work ?
           bne.s   mc_done             No, bugger it !
           dbra    d4,mc_loop          Do some more

mc_done    move.l  bv_rip(a6),a1       Restore maths stack
           addq.l  #8,a7               And program stack
           move.l  d0,d1               Get error code
           moveq   #0,d2               Stack requires no extra space
           bra     integer_d1          Return result/error code

*====================================================================*
* FILLMEM_B - fills memory with a single BYTE value. Stack is not to *
*             be considered important, this is a PROC.               *
*====================================================================*
fillmem_b  moveq   #1,d7               Flag FILLMEM_B
           bra.s   fillmem

*====================================================================*
* FILLMEM_W - fills memory with a single WORD value. Stack is not to *
*             be considered important, this is a PROC.               *
*====================================================================*
fillmem_w  moveq   #2,d7               Flag FILLMEM_W
           bra.s   fillmem

*====================================================================*
* FILLMEM_L - fills memory with a single LONG value. Stack is not to *
*             be considered important, this is a PROC.               *
*====================================================================*
fillmem_l  moveq   #4,d7               Flag FILLMEM_L

fillmem    bsr     count_pars          I need 3 parameters
           subq.w  #3,d0               Do I have them ?
           beq.s   fm_got_3            Yes

fm_errbp   moveq   #err_bp,d0          Oops !
fm_exit    rts                         

fm_got_3   moveq   #get_long,d0        I need long ones
           bsr     get_params          Go get them
           bne.s   fm_exit             Oops !
           move.l  0(a6,a1.l),a0       Start address
           move.l  4(a6,a1.l),d0       Number of fills to do
           beq.s   fm_exit             Done, nothing to do
           move.l  8(a6,a1.l),d1       Value to be used
           cmpi.b  #1,d7               FILLMEM_B ?
           beq.s   fm_bytes            Yes
           move.l  a0,d2               Start address must be even
           btst    #0,d2               Is it ?
           bne.s   fm_errbp            No, quit
           cmpi.b  #2,d7               FILLMEM_W ?
           beq.s   fm_words            Yes

fm_longs   move.l  d1,(a0)+            Stuff a long word
           subq.l  #1,d0               Reduce counter
           bne.s   fm_longs            Not finished yet
           rts                         Done.

fm_words   move.w  d1,(a0)+            Stuff a word
           subq.l  #1,d0               Reduce counter
           bne.s   fm_words            Not finished yet
           rts                         Done

fm_bytes   move.b  d1,(a0)+            Stuff a byte
           subq.l  #1,d0               Reduce counter
           bne.s   fm_bytes            Not finished yet
           rts                         Done



*====================================================================*
* Various handy subroutines used by the above                        *
*====================================================================*
* FLOAT_D1   - Convert D1.L to float & stack it and exit to Basic.   *
* INTEGER_D1 - Stack D1.W and exit to Basic.                         *
* GET_CHAN   - Convert channel # in D0.L to channel id in A0.L with  *
*              error code in D0.L and Z flag set/unset as required.  *
* COUNT_PARS - Count the number of parameters supplied & return in   *
*              D0.W, zero flag set if none supplied.                 *
* CHECK_HASH - Set Zero flag if there is NOT a hash in front of the  *
*              first parameter. May be altered by use of A3/A5 etc.  *
* GET_PARAMS - Get any number of any type of parameters onto the     *
*              maths stack. D0.W is a flag for the required type.    *
* READ_SET   - Read or set a file header (64 bytes) according to the *
*              trap code held in D7. Returns with Zero set as reqd.  *
* CLOSE_FILE - Close the file whose id is in A0.L                    *
* MTINF      - Calls MT_INF trap & preserves all but A0.             *
* MTALCHP    - Calls MT_ALCHP trap, preserves all but D0 & A0.       *
* BV_GET     - Gets space on maths stack & sets A1 to it.            *
*====================================================================*




*====================================================================*
* Convert D1.L to float and return to caller which may be SuperBasic *
* stolen from Simon Goodwin's routine.                               *
*                                                                    *
* Entry at FLOAT_D1 means the caller had some parameters, therefore  *
* the tidied stack address needs to be stored in BV_RIP.             *
*                                                                    *
* Entry at FLOAT_BV means the caller had no parameters, therefore A1 *
* will NOT be a suitable value for the maths stack. It will be zero. *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* D1.L = Value to convert       | D0.L = zero                        *
* D2.L = Extra stack required   | D2.L = Corrupted probably!         *
* A1.L = Maths stack pointer    | A1.L = New stack pointer           *
* A6.L = Usual Basic value      | A6.L = Preserved                   *
* REST = Don't care             | REST = Who cares, we're quitting!  *
*====================================================================*
float_d1   move.l  a1,BV_RIP(a6)       Tidy stack address required

float_bv   move.l  d2,-(a7)            Stack extra space needed
           move.w  d1,d4               D4 will be exponent
           move.l  d1,d5               D5 will be mantissa
           beq.s   normalised          Zero is a trivial case
           move.w  #2079,d4            First guess at exponent
           add.l   d1,d1               Already normalised?
           bvs.s   normalised
           subq.w  #1,d4               No, halve exponent weight
           move.l  d1,d5               Double mantissa to match
           moveq   #16,d0              Try a 16 bit shift

normalise  move.l  d5,d1               Take copy of mantissa
           asl.l   d0,d1               Shift mantissa D0 places
           bvs.s   too_far             Overflow; must shift less
           sub.w   d0,d4               Correct exponent for shift
           move.l  d1,d5               New mantissa is more normal
too_far    asr.w   #1,d0               Halve shift distance
           bne.s   normalise           Try shift of 8, 4, 2 and 1

*--------------------------------------------------------------------*
* Check there's enough space for the result                          *
*--------------------------------------------------------------------*
normalised move.l  (a7),d1             COPY ! additional space requirements
           beq.s   stack_ok            None required
           move.w  BV_CHRIX,a0         BV.CHRIX vector
           jsr     (a0)
           move.l  BV_RIP(a6),a1       Get safe A1 value

stack_ok   suba.l  (a7)+,a1            Get additional space & tidy A7 stack
           move.l  a1,BV_RIP(a6)       Make sure I update BV_RIP
           move.l  d5,2(a1,a6.l)       Stack mantissa
           move.w  d4,0(a1,a6.l)       Stack exponent
           moveq   #2,d4               Floating point result
           moveq   #0,d0               No errors
           rts                         Back to caller, probably SuperBasic


*====================================================================*
* Stack D1.W and return it to caller which may be SuperBasic         *
*                                                                    *
* See above for the difference between entry at INTEGER_D1 and       *
* INTEGER_BV.                                                        *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* D1.W = Value to convert       | D0.L = zero                        *
* D2.L = Extra stack required   | D2.L = Probably corrupted          *
* A1.L = Maths stack pointer    | A1.L = New stack pointer           *
* A6.L = Usual Basic value      | A6.L = Preserved                   *
* REST = Don't care             | REST = Who cares, we're quitting ! *
*====================================================================*
integer_d1 move.l  a1,BV_RIP(a6)       Tidy stack address required

integer_bv movem.l d1-d2,-(a7)         Save result & extra stack needed
           tst.l   d2                  Do I need to call BV_CHRIX ?
           beq.s   stack_fine          No, skip
           move.l  d2,d1               I need these extra bytes
           move.w  BV_CHRIX,a2         Allocate vector
           jsr     (a2)                Get space on maths stack
           move.l  BV_RIP(a6),a1       Get new stack address

stack_fine movem.l (a7)+,d1-d2         Restore result & extra space needed
           suba.l  d2,a1               Make room if required
           move.w  d1,0(a6,a1.l)       Result on maths stack
           moveq   #3,d4               Return is word integer
           moveq   #0,d0               Never any errors
           move.l  a1,BV_RIP(a6)       New stack
           rts                         Return to SuperBasic


*====================================================================*
* Convert D0.L to channel id for that channel #number, or error.     *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* D0.L = Channel #number        | D0.L = ERR_OK, ERR_NO or ERR_BP    *
* A6.L = Usual Basic value      | A0.L = Channel id (open) or -1     *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
get_chan   tst.l   d0                  D0.l cannot be negative
           bmi.s   bad_chan            Oops, it is
           mulu    #$28,d0             Get offset into channel table
           add.l   BV_CHBAS(a6),d0     Add on channel table start address
           cmp.l   BV_CHP(a6),d0       Past end ?
           bge.s   not_open            Yes - channel not open
           movea.l CH_ID(a6,d0.l),a0   No - get id into a0.l
           tst.l   CH_ID(a6,d0.l)      Is channel open ?
           bmi.s   not_open            No - return not open error code
           moveq   #ERR_OK,d0          Yes - return ok code
           bra.s   exit                And exit

not_open   moveq   #ERR_NO,d0          Channel not open
           bra.s   exit                And exit

bad_chan   moveq   #ERR_BP,d0          Bad parameter

exit       tst.l   d0                  Set zero & minus flags as required
           rts                         Back to caller


*====================================================================*
* Count the number of parameters supplied and return it in D0.W the  *
* zero flag is set if none were supplied.                            *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* A3.L = Pointer to first param | D0.W = Count of parameters         *
* A5.L = Pointer to last param  |                                    *
* A6.L = Usual Basic value      |                                    *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
count_pars move.l  a5,d0               Last parameter pointer
           sub.l   a3,d0               Subtract first parameter pointer
           divu    #$08,d0             Divide by 8 bytes per parameter

*--------------------------------------------------------------------*
* Conditional code for testing, if QMON2 is 1, the trap will be      *
* included in the assembled output, if not, it won't.                *
*--------------------------------------------------------------------*
           GENIF   QMON2               = 1
           trap    #15                 Hello QMON 2, are you there?
           ENDGEN  
           rts                         Back to caller


*====================================================================*
* Check to see if there is a # prefix for the parameter pointed to   *
* by A3.L in the name list. Set the zero flag if there is not one.   *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* A3.L = First parameter        |                                    *
* A6.L = Usual Basic value      |                                    *
* REST = Don't care             | ALL  = Preserved                   *
*====================================================================*
check_hash btst    #7,1(a6,a3.l)       Check the hash flag
           rts                         Flag is set, exit


*====================================================================*
* Obtain any number of parameters onto the maths stack as pointed to *
* by A1.L relative to A6.L of course. The parameter type is held in  *
* D0.W on entry to this routine.                                     *
*====================================================================*
* ENTRY                          | EXIT                              *
*                                |                                   *
* D0.L = Parameter type flag     | D0.L = Error code                 *
*                                | D3.W = How many were obtained     *
* A1.L = Pointer to maths stack  | A1.L = New stack pointer          *
* A3.L = First parameter pointer | A3.L = Preserved                  *
*                                | A4.L = Preserved                  *
* A5.L = Last parameter pointer  | A5.L = Preserved                  *
* A6.L = Usual Basic value       | A6.L = Preserved                  *
* REST = Don't care              | REST = Corrupted (except D5 & D7) *
*====================================================================*
get_params movea.l #CA_GTINT,a2        Points to CA_GTINT, not the vector yet !
           move.w  0(a2,d0.w),a2       Now has the appropriate vector
           jsr     (a2)                Do what must be done

           rts                         Return to caller


*====================================================================*
* Read or set a 64 byte file header to the channel held in A0.L, the *
* appropriate trap code is in D7. Return with the Zero flag set or   *
* unset as appropriate for the success or failure of the trap.       *
*====================================================================*
* ENTRY                          | EXIT                              *
*                                |                                   *
* D7.B = FS_HEADR or FS_HEADS    | D0.L = Error code                 *
* A0.L = Channel id              | A0.L = Preserved                  *
* A1.L = Buffer address absolute | A1.L = Updated buffer address     *
* A6.L = Usual Basic value       | A6.L = Preserved                  *
* REST = Don't care              | REST = Assume corrupted!          *
*====================================================================*
read_set   move.b  d7,d0               Get trap code
           moveq   #64,d2              Buffer size
           moveq   #timeout,d3         Infinity is a big thing
           trap    #3                  Do it
           tst.l   d0                  Set flags
           rts                         Return to caller


*====================================================================*
* Close file whose id is in A0.L and return with zero in D0.L and    *
* the zero flag set.                                                 *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
*                               | D0.L = Zero                        *
* A0.L = Channel id             | A0.L = Corrupted                   *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
close_file moveq   #io_close,d0        Prepare to close it
           trap    #2                  Close it
           moveq   #0,d0               Close does not fail (!)
           rts                         Exit


*====================================================================*
* Get the system information by calling TRAP #1, with D0 = MT_INF.   *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
*                               | A0.L = System Variables            *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
mtinf      movem.l d1-d2,-(a7)         Save working registers
           moveq   #MT_INF,d0          Set the trap
           trap    #1                  Do it
           movem.l (a7)+,d1-d2         Restore working registers
           rts                         Exit


*====================================================================*
* Allocate some heap. Return address in A0 & flags set for errors.   *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
*                               | D0.L = Error code                  *
* D1.L = Space required         | A0.L = Base of area allocated      *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
mtalchp    movem.l d1-d3/a1-a3,-(a7)   Save working registers
           moveq   #MT_ALCHP,d0        Set the trap
           moveq   #me,d2              I want it for me
           trap    #1                  Do it
           movem.l (a7)+,d1-d3/a1-a3   Restore working registers
           tst.l   d0                  Set flags
           rts                         Exit


*====================================================================*
* Allocate some space on the maths stack.                            *
*====================================================================*
* ENTRY                         | EXIT                               *
*                               |                                    *
* BV_RIP(A6) = Current stack    | BV_RIP(A6) = Preserved (* note *)  *
* D1.L = Space required         | A1.L = New stack pointer           *
* REST = Don't care             | REST = Preserved                   *
*====================================================================*
bv_get     movem.l d0-d3/a2,-(a7)      Save working registers
           move.w  BV_CHRIX,a2         Get vector
           jsr     (a2)                Make space
           move.l  BV_RIP(a6),a1       Get new stack address
           movem.l (a7)+,d0-d3/a2      Restore registers
           suba.l  d1,a1               Allocate the space
           rts                         


           END     
