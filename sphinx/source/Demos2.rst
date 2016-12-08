DJTOOLKIT V1.15 DEMOS2

by Dilwyn Jones, June 1994

The files DEMOS2_bas and DEMOS2_sav (QSAVEd version) contain a further set of demo routines to show how to use the new commands and functions available in DJToolkit from V1.15. Basically, these are the fill memory, file open, float peek/poke and MAX_ extensions.

Many of these routines use quite complex bits of code, so do not be discouraged if you find them difficult to follow at first if you do not have much experience of basic programming.

Several of these routines use MAX_CON. This uses the iop.flim trap which returns the screen size if testing a primary channel (usually lowest CON channel, e.g. #0 in Superbasic), or the maximum size within the outline of the primary channel - the outline is the outer limits of a window in pointer environment terms (there is a bit more to it than that, but the full explanation is too complex to list here). This means that other window numbers cannot be lager in size than this outline size.

For superbasic, applying MAX_CON to #0 will generally tell you the maximum screen size provided that the iop.flim trap is implemented on your system. If you have pointer environment installed, for example, it should be present, though MAX_CON may not work on early QL rom versions.

If in doubt that MAX_CON is returning the full screen size rather than the outline size, check the result given by MAX_CON against that given by DISPLAY_WIDTH.

There is a routine in DEMOS1_bas to determine maximum window size by error trapped trial and error if you wish to do it that way (i.e. using WINDOW to size down from large window size until it comes into range, error trapping the command for out of range errors).


1. SCREEN_SIZES

Shows how to use MAX_CON to return the maximum possible display size (see pointer environment warning above), allowing for the fact that the trap may not be implemented on some early QL systems by setting default values for the screen dimensions to those of the standard QL video screen (512 x 256 pixels). It returns the width, height and origin values for the standard three superbasic windows. For #0, it will return 512,256,0,0. For the other channels it depends on the outline set for the basic windows. In general, if you don't know about outlining, it won't affect you and you do not need to know about it to use this demo routine.


2. CLEAR_WHOLE_SCREEN2

Fills the display with 16 bit values (0) to clear the whole screen to black, by using FILLMEM_W. See warning re. pointer environment above, which is why it tests channel #0 rather than #1 or #2. This routine is broadly equivalent to WINDOW #0,512,256,0,0 : CLS #0 but writes directly into the display area. Though this is not good practice, it is nonetheless possible and shows how to do this in a reasonably safe way.


3. PEEK_FLOAT_DEMO

Sets up a table of 10 six byte floating point numbers in memory by using RESERVE_HEAP to make room for the table, then using POKE_FLOAT to store the ten random numbers. It then asks you to enter a number from 1 to 10 for the number to be recovered from the table. If you enter a 0, the routine comes to an end.


4. L2_DIR

This routine only works with Gold Card, Super Gold Card, hard disk or other device (such as emulators) which supports real directories created with a command such as MAKE_DIR, with file type 255 (i.e. not Thor directories).

This is a complex routine which allows you to get a list of all files in a given directory on a given drive, including files living in sub-directories. This routine requires two parameters, the drive name and the directory name. If you wish to look at the root directory (i.e. see every single filename on that drive), specify the subdirectory as a null string ( L2_DIR "win1_","" ) - on hard disk systems, for example, this can result in a very long list of files. The routine calls itself recursively every time it finds a subdirectory name until it runs out of names. Note how each variable needs to be a local variable for this routine to work, so each time the routine calls itself it can create a new set of variables each time and remember them for the previous call when it returns to that. The routine lists filenames and directory names (directory names followed by -> like the DIR command).

The DJ_OPEN_DIR function is used to access the file headers in the directories studied on the drive. Each entry is 64 bytes long and fetched with FETCH_BYTES. The name is extracted from this along with the file type byte. If this is 255, the name under study is considered to be a sub directory and the routine calls itself again to read the contents of that directory and so on. Because the action is basically the same for each subdirectory read and there is a finite return point each time (i.e. a definite end of the list of files in a directory) this is an ideal example of a routine which calls itself recursively. Recursion is a mind-bending subject to those who have never studied it before, so if you want to know more about it, find a good programming textbook (or ask Norman Dunbar). Recursive routines can use up a lot of memory, which may be an important consideration when compiling a program containing routines such as this one.

This routine may be useful to anyone who is considering writing software which needs to access and manipulate files in sub directories, such as backup programs, file searchers, or listing utilities.


5. DIR_ARRAY

This routine is based on the previous one, but rather than just producing a listing of files in a given directory, this routine returns a list in an array so that your program can access the filenames if required. It makes two passes through the list of files, the first is only to check for lengths of names and how many names need to be fitted into the arrays. This information is used to dimension two sets of arrays, one containing subdirectory names, the other containing the filenames. The array filenames$() contains the filenames, while the array called dirs$() contains the directory names. The four variables indicated at the beginning of the procedure called DIR_ARRAY with REMark statements contain details such as how many filenames, how many directory names, length of the longest names etc.


6. SAVE_BIG_SCREEN

On hardware such as the Miracle Systems Ltd QXL which allow the use of screen sizes larger than the standard QL 512x256 screen, it is useful to have a method of being able to save the screen automatically without having to ask the user what width and height to save. The QL manual describes how to save the current screen picture with the command:

SBYTES 'filename',131072,32768

This is fine for the standard QL screen, but for the larger screens of the QXL and enhanced mode 4 on the Atari ST-QL emulator, for example, a better method is needed as several factors are likely to change:
(i) The screen base address may not be at address decimal 131072 (hex 20000).
(ii) The width of the screen may be different (e.g. 640 or 800 pixels on the QXL, 768 on the enhanced mode 4 of the Atari emulator).
(iii) The height of the screen may also differ.

This routine first of all works out the size of the screen in pixels using MAX_CON applied to the primary basic channel (#0), then working out the number of bytes per line with DISPLAY_WIDTH. As the QL screen is a series of lines of pixel, all of the same length, it is a simple matter to work out the length of the area to save by multiplying the width of one line in bytes by the height of the screen in lines. The SCREEN_BASE function is also used to find the address in memory at which the screen starts. I have also used the primary channel for SCREEN_BASE and DISPLAY_WIDTH, as there is the possibility (as advised in the Minerva manual) that future display hardware could theoretically have different windows in different copies of the screen where the hardware and operating system permitted this.


7. STORE_BIG_SCREEN

Rather than store the screen as a file on disk, this function allocates some common heap memory (with RESERVE_HEAP) and uses DISPLAY_WIDTH, SCREEN_BASE and MAX_CON to check the screen size and allocate enough memory accordingly. The function returns either the base address of the area of memory used to store the screen address, or a negative number which will be an error code. MOVE_MEM is used to transfer a copy of the screen to the area of memory reserved. If you really must directly address the screen rather than use operating system calls, e.g. for speed reasons or because no operating system facility exists, these routines are reasonably safe ways of doing so and correctly used should ensure your program works on future QL hardware.


8. RESTORE_BIG_SCREEN

This routine restores a picture from the reserved area of memory directly onto the screen. Just as before, the DISPLAY_WIDTH, SCREEN_BASE and MAX_CON functions are used to check screen dimensions and MOVE_MEM is used to transfer the picture back to the screen. RELEASE_HEAP removes the area of common heap memory used, and the variable holding the common heap address is zeroed so that the calling routine knows the common heap area used has been released.


9. SAVE_PTR_SCREEN

Requires one parameter - the filename of the file to be saved. This routine saves a copy of the screen picture in a file format known as the area save bitmap format used by many pointer environment programs for graphical applications. Line Design is one well known example of a program which can use this format. It is a standard format for saving whole screens or areas of the screen in such a way that it can be loaded into any application which supports this format. The files have a few bytes of preamble at the beginning to identify them as this type of file.

2 bytes   Hex'4AFC' Decimal 74,252
1 word    width in pixels
1 word    height in pixels
1 word    line increment in bytes (number of bytes between
          the start of one line and the start of the next)
1 byte    screen mode (usually 4 or 8)
1 byte    spare (not used, reserved for future application)
followed by the bit image data in the same form as that of the screen picture memory itself.

First of all, MAX_CON is used to check the size of the current screen. Then DISPLAY_WIDTH is used to check the width of each line of the display in bytes. Note that for standard mode 4 and mode 8 displays, the line width in bytes will always be INT(pixel_width/4), but this is a dangerous assumption to make as any future graphics hardware may well implement modes which do not conform to this rule. But for standard QL mode 4 and 8 displays, it is a useful rule of thumb.

Next, the DJ_OPEN_NEW function is used to try to open a file with the given filename. If the file already exists, DJ_OPEN_NEW will return the error code -8 (which corresponds to the QL error message 'already exists'), which is a useful way of implementing a 'OVERWRITE YES/NO?' type of option for saving files, as we can act on the '-8' value obtained. The user is asked to state by pressing Y for Yes or N for No if he/she wishes to delete the existing file with that filename. If N for No is pressed, the routine comes to an end.

If Y for Yes is pressed, DJ_OPEN_OVER deletes the file and  has another go at opening a new file for us.

PUT_WORD and BUT_BYTE are used to build up the file preamble for us (10 bytes in all). SCREEN_BASE tells us where to start saving the screen from, then PEEK_STRING is used to fetch each line of the display from memory, with the number of lines being kept in the variable h% from the earlier MAX_CON statement. PRINT is used to send each line to the file before the file is finally closed.


10. LOAD_PTR_SCREEN

Requires one parameter, the filename of the screen to be loaded.

This routine loads a picture previously saved in the area save bitmap format with the routine described above onto the screen. The area loaded may be smaller than the screen itself - this would allow a standard QL screen picture to be merged onto a larger QXL or Atari screen, for example.

First of all, MAX_CON and DISPLAY_WIDTH are used to check the display size details. DJ_OPEN_IN is then used to try to open the picture file - if it fails, the routine simply returns without error, other than a low pitched beep which I use to signify errors of some sort.

FILE_LENGTH is used to check the length of the file. Since the area save bitmap files include a ten byte preamble in the file at the very least, files which are less than 10 bytes long can be ignored. This routine also shows an approach to decoding files of certain types, an approach you may be able to use if your program needs to be able to manipulate certain types of files only. It is common practice to place a few bytes at the start of the file as markers to identify files, and it only takes a very small amount of time for a program to open the file and check these first two or four bytes, which drastically cuts down the risk of causing all sorts of problems by accidentally loading another program's files. First of all, FETCH_BYTES fetches two bytes from the file to check for the hex $4AFC flag at the beginning which identify the area save bitmap files. GET_WORD and GET_BYTES are then used to fetch the width, height and mode details. As there is one spare, unused byte in the file, MOVE_POSITION is used to skip over it.

Next, the file dimensions are checked against those of the screen, in case the picture is too big to be loaded onto the screen. The mode of the picture is checked against the screen mode and changed if necessary. Note how the routine checks the mode, changes it, and checks again to see if the mode change was successful. Usually, this will not be necessary, but some versions of the Atari ST-QL emulator did not have MODE 8 built in, so attempting to change to mode 8 would not be successful.

If anything went wrong, the file is closed and the procedure returns.

To load the picture itself, we check the base address of the screen and fetch one line at a time from the file onto the screen display directly. The 'a' loop ensures that the correct number of lines are fetched. Note the warning in the listing for owners of version AH or JM QL roms (you can check your rom version with PRINT VER$), which may give buffer overflow errors if FETCH_BYTES is used to fetch more than 128 bytes at a time from a file due to a limitation in those rom versions. There is a FETCH_BYTES_JM$ routine in DEMOS1_bas which can be used in its place if this causes you a problem.

POKE_STRING is used to place the string of bytes corresponding to one line of the picture direct into the display.


11. OPEN_OVER_QUERY

Requires one parameter - the filename of the file to be opened.

Tries to open a channel to a file, and if that file already exists, prompts you to choose whether or not to delete the file. The error code returned by DJ_OPEN_NEW (in the variable 'chan') is checked for a value which indicates that the file already exists, and prompts to ask if the file is to be deleted or not.

This routine allows you to build routines into programs which act rather like the Toolkit 2 'Already exists, overwrite Y/N?' prompts, without having to rely on the recipient of your programs having Toolkit 2 on his/her system.


12. TK2_DATA$

This routine looks in the system variables and finds the Toolkit 2 data default drive (as set with the DATA_USE command in basic). If the default is not found, the function returns a null string, otherwise it uses a rather complex PEEK_STRING statement to recover the default drive details. Although it is easy enough to use the Toolkit 2 DATAD$ function to find the default drive of course, this routine allows you to check if the default itself is present, so your program can take alternative action if Toolkit 2 is not present. The data default drive is the drive from which data files, screens, and even basic programs are loaded from by default, though see under TK2_PROG$ below for details of basic programs loaded and saved using QLOAD and QSAVE.


13. TK2_PROG$

This function returns the Toolkit 2 program default drive details, in much the same way as the TK2_DATAD$ function above. The program default drive is the one programs are executed from, or that which Liberation Software's QLOAD and QSAVE utilities use to load and save basic programs from.


14. TK2_DEST$

A function which returns the current Toolkit 2 default destination name, as set with DEST_USE.


15. OPEN_IN_TK2

Requires one filename, that which the function is to open. Normally, DJ_OPEN_IN etc functions do not pick up the Toolkit 2 default drives, but if you want them to do this and act like the Toolkit 2 redefined file opened commands, this function shows how to do this, but also means that your program can also work on systems without Toolkit 2.


16. FILE_BROWSER

A useful little routine which allows you to list files on all of your drives with just one or two keypresses. It shows the device names on your system (FLP, MDV, RAM, WIN, DEV etc) which are obtained by using the DEV_NAME function, and allows you to choose drives 1 to 8 for those device names (often there will only be one or two floppy drives, for example, although up to 8 ramdisk drives amy be present on most systems).

To select a drive, press the first letter of its name (e.g. F for FLP). To select drive number, press a number from 1 to 8 (e.g. 1 for FLP1_). Sub directories are scanned using the L2_DIR routine described earlier.
