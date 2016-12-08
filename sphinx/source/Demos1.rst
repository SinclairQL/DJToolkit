DJTOOLKIT BASIC DEMONSTRATION ROUTINES

BY DILWYN JONES, 1993

This document gives some instructions for the demonstration routines supplied with the DJToolkit. They are contained in the file DEMOS_bas, which can be loaded from BASIC with the LOAD command.

FIRST A WARNING FROM NORMAN DUNBAR

If you have checked the UPDATES_DOC file then you will be aware of a QL BUG which causes problems. I have detailled it here as well, just in case. 

Some of the demo procedures and functions have a large number of parameters and/or local variables. When the total of these comes to more than 9 the QL will probably crash when these routines are executed. To avoid this, I have REMarked out the 'extra' LOCals in some of the routines, however, if you compile them and ONLY run the compiled version, you can unREMark them as most compilers fix this bug. Now back to Dilwyn's instructions for his demo routines.


Those short programs, implemented as procedures and functions, are intended to give some examples of how to use Toolkit extensions, or in some cases how to get around some limitations or how to adapt the useage slightly in practical use or on certain ROM versions where results may vary slightly. These are, in effect, "programmed routines". Most are simple demonstrations only, some can easily be adapted or copied for use in your programs, while one (FIND_FILE) is a really useful, complete program in its own right.

This document is supplied as a Quill _DOC file for two reasons. Firstly, since the price of the DJToolkit is quite low, it saves on costs by not having to print a larger manual than is necessary for the toolkit itself. Secondly, it allows us to change or add to these example routines as required at short notice, or to fix bugs, without the expense and inconvenience of having to reprint instructions all the time.

The instructions are listed in the order in which the routines are listed in DEMOS_bas, using the name of the procedure or function. Users who have the QREF utility from Liberation Software (available from DJC) can use the QFIND utility to quickly locate the routine.

These routines can be used in compiled commercial software along with the toolkit - follow the guidelines in the manual.

Beware - some routines call others in this file, e.g. the CURSOR_ENABLE and CURSOR_DISABLE routines are used by some of the routines.

PLEASE NOTE: The routines in DEMOS1_bas were written using an older version of DJToolkit. The routines which directly access the display, for example, could be improved through the use of MAX_CON, for example, to test the maximum sizes of display available.


1. CURSOR_ENABLE

This routine shows how to use CHECK to test if given commands are present in the machine and vary its action accordingly. Since DJToolkit has no cursor enabling command of its own (normally, you'd use the Toolkit 2 CURSEN or the QLiberator Q_CURSON) this routine finds out which version is present and switches on the cursor in the specified channel. If neither is available, it uses an undocumented command present in current ROMs, but which may not be implemented in future ROM versions or operating systems such as SMS. You could extend this routine to look for other cursor enabling commands, or adapt it to search for other types of extensions to allow your programs to take advantage of toolkits loaded or to report errors if toolkits required are not present, so that a program can stop neatly if an extension is not present rather than just give an obscure error message. One parameter is required, the channel number in which you want a cursor to be enabled. Note that just because a cursor has been enabled, it does not necessarily follow that it will be flashing! Indeed, this action may vary from ROM version to ROM version - you may have to press CTRL C (hold down CTRL and tap the C key) until the right cursor starts flashing, especially if there are several jobs running in the QL at the time. Why have a cursor flashing at all? Because (unless you are using the Extended Environment, as supplied with software such as QPAC2) you can only have keyboard input to a compiled program if the cursor is enabled before reading. INPUT does not need you to do this, since it turns on the cursor by itself, but INKEY$ does need a cursor to be enabled. If you have a compiled program which uses INKEY$ and you CTRL C out of it to another program, you can be locked out of the program.


2. CURSOR_DISABLE

Performs the opposite action to the CURSOR_ENABLE routine above. It stops the cursor flashing and turns it off. Here's a couple of short examples of how to use these two routines:-

REMark wait for a keypress, PAUSE works from #0 in older ROMs
PRINT #0,'PRESS A KEY TO CONTINUE. ';
CURSOR_ENABLE #0 : PAUSE : CURSOR_DISABLE #0 : PRINT #0,

REMark using INKEY$
CURSOR_ENABLE #3 : LET k$ = INKEY$(#3) : CURSOR_DISABLE #3

Note that if INKEY$ is used in a loop, rapidly switching the cursor off and on may cause the cursor to flicker annoyingly, so either use a delay in INKEY$ or put it in a loop with the cursor controls outside the loop, e.g.

REMark wait for a key to be pressed
CURSOR_ENABLE #0
REPeat get_key
  key = CODE(INKEY$)
  IF key <> 0 : EXIT get_key
END REPeat get_key
CURSOR_DISABLE #0

REMark another method
CURSOR_ENABLE #0
key = CODE(INKEY$(-1)) : REMark INKEY$ defaults to #0
CURSOR_DISABLE #0

Note for when compiling programs - INPUT defaults to screen channel #1 (normally the red part of the screen after starting up the QL), while INKEY$ and PAUSE default to channel #0 (the part at the bottom of the screen). INPUT and INKEY$ can both have specified channel numbers (INKEY$(#number) and INPUT#number), but PAUSE cannot in most versions of the ROM. PAUSE can take an optional channel number under a Minerva ROM. If you need a delay and are using a window other than channel #0, there may be difficulties with PAUSE on an older ROM, so use INKEY$ instead. PAUSE n is roughly equivalent to LET variable$ = INKEY$(#0,n), so it is easy to make INKEY$ work from another channel. The string variable is only there to accept the dummy result from INKEY$ since that is a function - sometimes it is useful for detecting the ESC key, which returns a CHR$(27):

PRINT#0,'PRESS A KEY TO CONTINUE, OR ESC TO QUIT ';
CURSOR_ENABLE #0
LET k$ = INKEY$(#0,-1) : REMark wait until key pressed
CURSOR_DISABLE #0
IF k$ = CHR$(27) : STOP : REMark ESC key pressed

You will notice I took a lot of space to explain cursors! When compiling programs, it is one of the biggest sources of errors and difficulties new programmers encounter when attempting to ensure that their programs can multi-task or task switch properly. Since DJToolkit is intended mainly for use with QLiberator, I thought it was the least I could do to help with these problems!


3. SLIDE_SHOW

This routine loads a number of QL screen pictures from disk and stores them in memory, then shows them on screen one after another like a slide show. Each QL screen picture has to be in the same mode (i.e. mode 4 or mode 8 or other 32k mode supported by your hardware). Since each picture requires 32k of memory, it is a routine only likely to be useful on a machine with expanded memory. First, the routine asks for the number of pictures to be loaded, then tries to reserve enough memory in the common heap (if there is not enough free memory, the program stops). Next, it asks for the filenames of the screens to be loaded. Enter those (remember to press ENTER after each one of course). After each filename is entered, the screen is loaded into a slot in the common heap. Note the rather strange looking expression in the LBYTES statement - the '&""' expression is needed since sc$ is a string array and in versions AH, JM and JS, using a string array as a parameter for LBYTES without having Toolkit 2 enabled can cause problems (unless of course you copied the string array to a normal undimensioned string variable first). Adding a null string to the array entry converts it to an expression rather than a standard array as far as LBYTES is concerned and gets around the problem. The fix is not needed if Toolkit 2 is used, since the redefined commands in Toolkit 2 do not exhibit this problem.

The code in the loop then copies the pictures to the screen one at a time with a slight pause between each one. The MOVE_MEM statement copies the 32k (32768 bytes) of each picture direct to the screen, while the SCREEN_BASE statement ensures it goes to the correct screen for that channel (e.g. if using Minerva second screen).

Finally, the RELEASE_HEAP statement frees up the memory used to hold the pictures.


4. REFLECT_SCREEN

This routine simply reflects the top half of the screen into the bottom half, like a mirror effect. The variable "from" starts from the top of the current screen (note the use of SCREEN_BASE to check where the screen is), while the variable "dest" points to the start of the last line of the screen, to work up from the bottom. The routine works by copying the top line of the screen to the bottom, then the second line is moved to the bottom line but one, and so on. PEEK_STRING and POKE_STRING are used to copy chunks of memory - it is possible to use MOVE_MEM to do this as well. Sadly, it is not possible to create a routine to reflect sideways in the same way due to the way the screen is laid out. Note how this routine uses the DISPLAY_WIDTH function to ensure that whole lines are moved at a time (normally on a standard QL, the standard width of a line in bytes is 128, but it can be different on new hardware, so using techniques such as this should help to ensure such programs work on new display hardware). You may like to adapt the maximum display sizes routine below to also allow the maximum height of the screen to be calculated. Note that this routine uses another function in this demo file, DISPLAY_WIDTH_JM (see below for details) to ensure that the routine can work properly on version AH and JM QLs.


5. ZOOM_IN

This routine magnifies the top half of the screen picture, doubling its height to fill the whole screen. It works in a very similar way to the previous example, including the use of DISPLAY_WIDTH.


6. SAVE_THE_SCREEN

This routine saves the content of the screen so that it can be restored later. The routine reserves 32 kilobytes in the common heap then later restores it later as required, by using MOVE_MEM. You can adapt this routine for use in your own programs.


7. RANDOM_ACCESS

This demonstrates the use of the file handling functions to make files with fixed-length information in them, which can be read back later in a simple fashion, because the known length of the items makes it easy to fetch the information at known or predictable positions.

As an example, consider writing random numbers to a file. The number '100' is three digits long, while the number '6' is only one digit long. If the file is full of numbers of random length, we can't easily work out where each one starts. However, by using the PUT_BYTE, PUT_WORD or PUT_LONG commands we can send numbers to a file as one byte, two byte or four byte long items respectively, making it easier to recover the numbers later when required, since each number will be the same length in the file.

The first loop generates 100 random numbers in the range 0 to 255 in value and sends them to a file with the PUT_BYTE command. Each byte can only hold numbers from 0 to 255 in value.

The second loop reads back the random numbers from the file. You are asked to enter a number from 1 to 100 to choose any of the numbers from the file (if you enter 0 the routine stops). Each entry is one byte long, so to fetch the fortieth number, for example, we position the file pointer to the start of the fortieth entry, remembering that in common with many computer conventions, files start at position 0, so the fortieth item is actually at position 39. The ABS_POSITION command is used to move the file pointer to the required position. Once the pointer is at the required location, we use GET_BYTE to fetch the number and it is then displayed on the screen.

Although this is a trivial example of random access files (the name has nothing to do with the random numbers used, it merely means that you can fetch any item you want from any point in the file), it does serve to illustrate some of the techniques used in database programs. In these, the technique often used is to specify in advance the maximum size of each record (or entry). Compare this with the way in which you define screens in Archive. Provided a little care is used to ensure that each record written to the disk is the same length, it becomes a simple matter to fetch any given one by using multiples of this length to position the file pointer. If you add something to the database, it is a simple matter of adding it at the end or in an unused slot in the file. To change or alter a record, fetch it from the disk, edit it then put it back where it came from. To delete a record, simply mark it as unused, then it can be re-used when something new is added.

In case you have not come across it before, a record is one whole entry in a file. Imagine you have a record collection - that is the file. Each part is (surprise, surprise) one record. These records are often further divided into tracks on a musical record, or fields in a computer record. The fields (divisions within a record) are not always the same size, but it is quite common for each record to have the same structure. Examples of records and fields in use might be an address database. One field might hold initials or forenames, a second might hold surnames, while the third might hold the address. This could be expected to be much longer than the others.

The whole subject of random access file handling is very complex and really needs a whole book by itself to explain it, so don't be surprised if you don't quite get the hand of it immediately!


8. FILE_DETAILS

As its name implies, this routine shows the details such as file length, file type, dates etc for a file whose name is passed to the procedure (e.g. FILE_DETAILS 'flp1_boot'). The dataspace is also shown for an executable file.


9. DRIVE_DETAILS

This routine shows how to use DEV_NAME to produce a listing of QL devices to choose from, then proceed to list the details of files on that drive. It also shows how to make decisions about the best way for a program to perform an action depending on whether or not some particular item is present or not, in this case if a ramdisk is present or not. The program lists the devices on the screen for you to select one by entering its number, then you are asked for a drive number, then a list of files is shown along with their details.


10. SHOW_QUARTER_SCREENS

A short utility to aid with viewing QL screen pictures. A quarter of each picture found on a disk is displayed in each corner of the screen allowing a quick viewing facility. It again shows how to use POKE_STRING, SCREEN_BASE, etc to more correctly access the screen. The second version (QUARTER_SCREENS2) shows a different way of approaching the display, namely by placing the top left quarter of each picture in four quarters of the screen. This routine (QUARTER_SCREENS2) is rather slow in interpreted BASIC.


11. MAKE_DIRECTORY

A short utility for those writing programs which expect to be able to make use of hard directories (as found on Gold Card systems, or on hard disk systems). From BASIC, one way of checking to see if the system on which the program is running is able to support hard directories is to check if the MAKE_DIR command is present. You could use CHECK('MAKE_DIR') to do this. But the best way is to use the LEVEL2 function to test. This shows a simple way to test if it is possible to create hard directories.


12. SET_MODE

The purists will tell you that if the computer is already in the screen mode you want it to be, you should not issue another mode command to change it to the same mode! So if your program needs to run in MODE 4, it is bad practice to issue a MODE 4 statement if the computer is already in mode 4. This routine checks if the computer is in another screen mode before issuing a MODE command. Simply put the mode number required after SET_MODE (e.g. SET_MODE 4).


13. AUTO_REPEAT

This little program shows the current setting of the auto repeat system variables. The delay is the time before the key pressed starts to repeat, i.e. if you press and hold down A, how long it takes before the A appears. The period is the time between repeats, i.e. in the example given, the time between the second and third A and so on. Standard values on a UK version JS system are 30 and 2 respectively. The program shows the settings currently used and allows you to change them, which may be useful if another program changes the settings and makes the keyboard too fast or too slow to use. This routine shows how to use the SYSTEM_VARIABLES function to access the system variables wherever they may be hiding in a machine. Most QDOS documentation lists system variable locations as offsets from the base of the block (i.e. how many bytes further than where they start). This is how they are accessed by this function, for example, if a particular system variable is 140 bytes from the base of the system variables area, it is simply added to the number returned by SYSTEM_VARIABLES.


14. SHOW_CAPS_LOCK

This is a routine which sits across the system variables constantly monitoring the state of the CAPS LOCK flag, and prints a message on the screen to say if the caps lock is on or off. It looks at the system variable at offset 136 and prints either CAPS ON if set, or CAPS OFF if reset. A modification to this routine would enable it to remember the last setting it saw and only print if it spotted a change, so that it is not printing all the time as in this example.

You can extend this routine to force caps lock off or on if you wish. What you need to do is to study the values normally stored in this variable and modify the content to be whatever you want. On my machine, the values given by PEEK_W(SYSTEM_VARIABLES+136) are:

Caps lock off : 0
Caps lock on  : -256

To switch on caps lock from a program, you'd use POKE SYSTEM_VARIABLES+136,-256. To switch off caps lock, you'd use 0 instead of -256.


15. LAST_KEY

This routine looks at the sv.arbuf system variable for a number corresponding to the last key pressed. In some cases, the number may not be what you expected, especially if you press ALT with another key, but it can be of use sometimes if one compiled program wishes to monitor for a given key press while another program is in use, e.g. a screen dump routine could be programmed to watch out for a key press to activate a screen dump to a printer of a picture within another program. Imagine that the screen dump routine is called SCREEN_DUMP and that the key to activate it is the TAB key. We might write a small piece of code like this to wait for the TAB key to be pressed, then activate the screen dump routine, or stop if the ESC key was pressed.

REPeat get_key
  key = LAST_KEY
  IF key = 27 THEN EXIT get_key
  IF key = 9 THEN SCREEN_DUMP
END REPeat get_key
STOP


16. NET_STATION

A useful little routine if you use the QL network a lot. If you have forgotten the number of the station you are working on, simply use this function to remind you.


17. BAUDRATE

Another useful little function, this time to remind you of the current baudrate set on your machine.


18. FIND_TEXT_IN_ROM

A routine to anable you to find any text in the ROM. Try looking for command names or keywords to see where they live in the ROM, or even look for names in the ROM, e.g. look for Sinclair. The routine uses the SEARCH_I function to look for a string which will match if in upper case or not. You can adapt this routine to become a general purpose routine to search within any given area of memory.


19. LINE_INPUT$

This example provides a function similar to INPUT, but allows text to be presented for editing and also allows ESC to be pressed to end the routine.

There is a list of 6 parameters to this routine, as follows.

"channel" is the screen channel to use, e.g. #1
"aty" is the y co-ordinate to be used, values as in the AT command
"atx" as "aty", but x co-ordinate across
"ending" is the code of the character which ended the input
         codes currently supported are 208 and 216 for cursor up
         and down keys, 10 for ENTER and 27 for ESC. Note that it
         is a returned code, not one supplied to the routine,
         though the calling variable should have been pre-defined
         to avoid an error (any dummy value will do). The returned
         value allows the program to make a decision on next
         action depending on how this one was finished (e.g. to
         stop if the entry was terminated with ESC or to move up
         or down a list if the cursor up/down keys were used.
"maxlen" is the longest length of entry permitted, e.g. 20
         characters.
"prompt$"is the text supplied to the routine for editing, e.g. a
         default drive name.

You could call this routine with a line such as:

LET how_ended = 0 : LET drive$ = 'MDV1_'
LET a$ = LINE_INPUT$(#1,5,5,how_ended,40,drive$)
SELect ON how_ended
  =27 : PRINT "ESC"
  =10 : PRINT "ENTER"
  =208: PRINT "Cursor up"
  =216: PRINT "Cursor down"
END SELect

Here, we are entering a string in channel #1, 5 characters across the window and 5 down. It is to be a string no more than 40 characters across and the default is 'MDV1_'. You can edit it on the screen using the normal cursor left and right keys and typing whatever text is required, as you would in an INPUT statement. When you have finished, press ENTER to finish normally, or ESC to quit. You can also quit by pressing cursor up or down if the entry was part of a list to be altered.

Some other keypresses are supported, such as ALT left and right to get to the ends of the string being edited, CTRL left and right for deleting characters while editing and CTRL ALT left or right to delete the whole line while editing.

This routine is a bit slow on a standard unexpanded QL, but fast enough when compiled.


20. FETCH_BYTES_JM$

Due to a problem with the input buffer on a QL with a version AH or JM ROM, the FETCH_BYTES function will stop with a buffer full error if you try to fetch more than 128 bytes from a file. This is also true for GET_STRING, see below. The cure, quite simply, is to split it up to fetch 128 bytes at a time and this routine shows you how to do this. The routine checks if the QL has a version AH or JM QL by using VER$, then if it has, it splits up the string fetched into 128 byte chunks. This is much slower than the usual FETCH_BYTES function, but at least it works on a version AH or JM QL.


21. GET_STRING_JM$

This routine is similar to FETCH_BYTES but performs a similar action for the GET_STRING command which can fail for the same reason as the FETCH_BYTES function.

Strings fetched with GET_STRING have a two byte length specifier followed by the characters of the string itself. So GET_WORD is used to fetch this two byte part first, then the FETCH_BYTES_JM$ function is called to fetch the rest of the string in 128 byte chunks.

Note that both routines test the ROM version and use the normal (faster) commands if not a version AH or JM system.

When fetching strings from files and writing strings to files, you should always be careful with odd length strings. In some cases, the operating system ensures that string lengths are even by adding an extra dummy character at the end (which is normally invisible) if the string itself has an odd length.


22. FIND_FILE

This routine, though written as a single procedure, is a complete, complex program in its own right. Its purpose is simple - given a drive name and a short text string (less than a kilobyte long, though the routine is easily adapted for longer ones if required), FIND_FILE will hunt through files on a disk or cartridge, scanning them for the string. For example, if you want to find letters to a Mr. Jones, simply put the disk you wish to search in a drive and type in

FIND_FILE 'FLP1_', 'Jones'

It does not matter if you use upper or lower case letters and you can even use directories if you wish. FIND_FILE shows the filenames of files containing the string on the screen and a short extract from the file either side of where the string was found (about 140 bytes in all). Up to 20 filenames can be listed before the program pauses and asks you to press a key to continue.

While this program is useful in its own right, there are some changes you can make to improve it. The best thing you can do is buy Norman Dunbar's The Gopher program from DJC (which is far better than this effort and has more facilities) to get some ideas of what else is possible.

This program fetches about 2 kilobytes at a time from the file, overlapping by enough text to cover the length of the string being searched for. If you wish to make it read larger chunks at a time, change the value of the variable called "buffer" a few lines from the start of the FIND_FILE buffer. While increasing the value of this variable will speed up searches, it also needs extra memory to hold the buffer string.

Other things which can be added:

a. Make the routine search through all directories it finds, you will need to add an extra procedure to scan through all files, picking out the sub-directories with the FILE_TYPE function and calling this routine for each one found to be type 255 (directory). You will, of course, need to modify FIND_FILE itself to ignore directory files and you may need some clever code to handle sub-directories within directories!

b. Add a printout option. This has been marked with a REMark statement in the middle of the procedure.

c. Add an option to only search certain file types (e.g. DATA files or JOB files)

d. Add an option to only search files with given filename endings

e. Add an option to only search, say, 10 kilobytes into the file to speed up searches.


23. YN$

A simple, short routine which waits for you to press Y for Yes or N for No. It enables a cursor while it waits for the keypress and converts upper case letters to lower case, so it always returns a y or an n.


24. DISPLAY_SIZES

This is a function which helps you to detect what type of display is in use. This function uses error trapping to open known maximum sizes of display for various hardware available. It returns a number from 0 to 3, representing the type of display:

3 is a QVME card (from Jochen Merz), the maximum display size tested for is 800 x 300.

2 is Extended Mode 4 on the Atari ST-QL emulator, resolution 768 x 268.

1 is the mono mode on the Atari ST-QL emulator, resolution 640 x 400.

0 is a standard QL resolution display, 512 x 256

-1 means that the routine was not able to test the display sizes and abandoned without a result (-1 is the QDOS error code for 'Not Complete').

The routine currently tests for the Toolkit 2 FOPEN function or the QLiberator Q_ERR_ON error trapping keyword. If neither is found (tested with CHECK) the program cannot function. But a REMark statement shows where you could add a WHEN ERRor statement as error trapping as the third option for the routine if your ROM version supports WHEN ERRor (version JS, MG, or Minerva, for example).

I am grateful to Ralf Rekoendt (Germany) for supplying the information on display sizes, without which this routine would not be possible.


25. IS_POINTER_ENVIRONMENT

This routine checks if pointer environment is present and prints up a message to say if it is installed or not. You can use similar routines in your programs to allow the use of keyboard control if the pointer environment is not present. One example of a program which can be pointer driven, or can be controlled from keyboard if the pointer environment is not installed, is QLiberator version 3.


26. REPORT_ON_FONTS

The address of the pair of fonts for the channel number specified is printed, along with the details of the lowest valid character code and number of characters in the font. You can use this information to copy a character set from ROM into RAM, for example, and redefine a few characters as required. This routine then goes on to print the characters (not including the default character) of both fonts.


27. LIST_HEAP

If you have made multiple common heap allocations and perhaps CLEARed out the variables holding the addresses, you may well find that the QL starts to run short of memory, because of blocks of memory are still present as reserved blocks. When the variables holding the addresses of these blocks have been cleared, it is difficult to clear out the heap. This procedure shows how to list the blocks allocated by DJToolkit, so that you can see how many there are and remove them with RELEASE_HEAP if desired. It picks up the address of the heap from the system variables and steps through all entries it finds. It checks that it is a DJToolkit allocation (as distinct from Toolkit 2, Turbo Toolkit, MegaToolkit, etc allocation) by checking for the "NDhp" string at the start address - 4 of the block (DJToolkit actually allocates 4 bytes more than asked for and uses those four to hold this little identifier header, or "signature"). NOTE, the Toolkit 2 routine CLCHP will NOT clear out any of DJToolkit's reserved areas. 

This procedure has been updated to reserve a couple of areas in the heap so that you can see something on the screen when it is called. It does NOT release these areas, so now you also have a valid reason to call the next routine CLEAR_DJTK_HEAP don't you ? (N. Dunbar 22/10/93)


28. CLEAR_DJTK_HEAP

Why clear them out manually when the computer can do it for you? This is an adaptation of the LIST_HEAP procedure, which stores the addresses in the array addrs(). Up to one hundred addresses can be handled, which should be quite enough! Note that the blocks are released in reverse order to help avoid heap fragmentation. Please note that if heap allocations have been made using extensions from other toolkits, this routine will NOT clear them out, you may well find you have a fragmented heap afterwards as well in that case - there is no substitute for being tidy and deallocating heap memory after you have finished with it. You can use CLCHP from Toolkit 2 to clear out its heap allocations, which may help.


29. DISPLAY_WIDTH_JM

As mentioned in the manual, the DISPLAY_WIDTH function can not always return reliable values on a version JM or AH QL - the manual hints at using VER$ to test for these QL ROM versions, but does not explain how. Here is the solution, and this routine is used by a few others in this demos file. It simply returns the 'fixed' value of 128 bytes per line if it is a version AH or JM QL which cannot have a screen of different size anyway. PLEASE NOTE: A fix for this problem has been built into the DJToolkit from version 1.11 onwards so this routine is now not required, though it will be included for a while for use with older versions of the toolkit.


30. ERROR_MESSAGE$

This is not a demonstration file for the DJToolkit as such, more a short routine to turn the error codes returned by some functions into a meaningful message like the ones the QL gives when something goes wrong. It accepts the error code as its parameter and returns a string with the message. It is used by some of the example routines.


31. LARGE_TEXT

This routine is a simple character enlargement routine which prints text by using the letters of the string to be enlarged to represent the pixels of each character. This is obviously of limited use on the screen, but you may be able to adapt it to make similar enlarged characters for printing on paper (perhaps several letters per pixel for large characters for banner-making). It is a simple way of enlarging characters and saves messing about with bit image graphics if you intend to print large characters to a printer! The parameters for the routine are: channel number, y and x co-ordinates down and across the channel concerned, and finally the text string to be printed.


32. LOAD_A_FONT

Shows how to load a font for a given channel by checking its length (which also serves as a rudimentary error trap by checking the value returned by FILE_LENGTH), reserving the required amount of memory in the common heap, using USE_FONT to assign the character font to the channel specified, print a sample string to the channel using the new font and finally resetting to default font before releasing the heap memory and ending. If you wish to experiment with this routine, there is a small number of fonts on the disk. Fonts have filenames ending with _FNT to make them easy to spot in a directory listing. Note that this routine assumes that the font file only contains one font - some font files contain the fonts for set number 1 and 2 of each channel, the second one is ignored.


33. NARROW TEXT

This routine needs the NARROW_FNT font file on the disk to be loaded (it looks for it and reserves memory itself). It shows how to use SET_XINC and SET_YINC to squeeze more characters on the screen. To demonstrate, it acts as a typewriter. Simply type enough characters (a few lines) of text to see what it looks like, press ESC to quit. You should get over 120 characters per line with the 4 pixel increment set by this routine, though unless you have a good monitor it won't be particularly readable. Note that if the window in which such reduced text is displayed has a border, it may be damaged by some x increment values (give this window a BORDER#0,1,255, for example and see what happens when the cursor reaches the right of the screen).


34. FASTCOPY

This uses the DJToolkit heap and file handling commands to set up as much of the common heap as practical for fas copying by loading the files into RAM and saving as many in one go as possible. On the Gold Card this will be no faster than using the WCOPY command in many cases, but can make quite a difference on older interfaces. The routine also sets the file type in copied files, so is not just limited to data file copying. It is quite a long procedure and difficult to follow unless you are used to long, complex BASIC routines! It requires two parameters, the drive to copy from and the drive to copy to.


35. BACKUP_BY_DATE

The file header in QL files can contain three important dates, the file update date (when a file was last changed), the file reference date (not used in many systems) and the file backup date (when a backup was last made, but this is not implemented on most QL systems). This routine compares the update date with the backup date and makes a backup copy if required (i.e. it has changed since the last backup). This means that if you have a disk full of files and only a few have changed, only those few files need to be copied, not the whole lot, thus giving you a quick and simple automatic backup facility. There is, however, a snag (isn't there always?). A normal QL doesn't set the backup date when you copy a file, for example, so we have to check if the command SET_FBKDT is present (it's a command built into the Gold Card, and on Miracle's hard disk system) to be able to set the backup date after making a copy.

If it is present, life is sweet again. The routine wades through all the files it can find on the disk or directory specified, compares the update date with the backup date and if the file has been updated since the last backup date, copies the file and changes the original file's backup date. It does not change the backup date on the copy of the file, unless you make another backup of that too!


36. CLEAR_BACKUP_DATES

Where the previous routine comes unstuck is when something happens to the backup copy, or you wish to make another backup from the source disk. Since the date has been changed, you are stuck, catch 22. However, it is possible to get around this by clearing the backup date by setting it to a DATE value of 1 (0 is not used, because it is ignored by the Gold Card version of the SET_FBKDT command), effectively back to the start of 1961!

At this point, a plug for a piece of DJC software! If you think these last two routines are clever, wait until you try Norman Dunbar's Winback backup utility which is even cleverer than these routines. Backup by dates, by directory, splitting long files, and much more is possible with this super program - if you have ED drives or HD drives on your Gold Card system, you can use Winback to make backups of those onto cheaper DSDD disks. If you have a Miracle hard disk, Winback is one of the most useful add-ons you can have for it, for only £25.00 (and I can heartily recommend it for all users ! (N. Dunbar 22/10/93))


37. ALTER_DATASPACE

A short routine which allows you to inspect the dataspace of an executable program and modify it. Often, no useful purpose is served by this, and in some cases it can be an unwise thing to do. But if a compiled program runs out of memory due to insufficient dataspace (this can sometimes happen with Turbo compiled programs if they were given the wrong dataspace to start with), this program can help you to increase the dataspace. Simply enter the name of the file to be inspected, then it shows the current dataspace and prompts you to enter a new value. To leave it unchanged, enter the same value.

