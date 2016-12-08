============
INTRODUCTION
============

**WRITTEN BY NORMAN DUNBAR, 1993-94**


This toolkit has been produced at the suggestion of *Dilwyn Jones* in an effort to provide ``QLiberator`` users with some of the file & memory handling utilities, direct file access (in internal format) & positioning commands that are found in the ``Turbo Toolkit`` and ``Toolkit 2`` etc. In addition, there are a few routines not (yet) found in any other toolkit.

All of the procedures and functions in this toolkit can be compiled by ``QLiberator``, but one of the functions, ``DEV_NAME``, cannot be compiled by ``Turbo`` or ``Supercharge`` as it modifies its parameter as well as returning a string.

This toolkit may be supplied as part of a commercial or shareware or public domain program which has been ``QLiberator`` compiled. It should be supplied *linked* to the object program, not loaded by a ``BOOT`` program.

To link this toolkit into a ``QLiberator`` compiled program, use the following compiler directive somewhere near the start of the program to be compiled. The drive name is where the compiler can find the toolkit file::

    110 REMark $$asmb=FLP2_DJToolkit_BIN,0,12


COPYRIGHT NOTICE AND DISCLAIMER
===============================

This software is Copyright © Norman Dunbar 1993-94/2013 and may be freely copied as QL free ware.

You can make backup copies using whatever method you have and normally use (e.g. ``WCOPY`` from ``Toolkit 2``). DJToolkit is not copy protected (except by copyright law).

While all reasonable care has been taken to ensure that this program and its manual are accurate and do not contain any errors, neither the author nor publisher will in any way be liable for any direct, indirect or consequential damage or loss arising from the use of, or inability to use, this software or its documentation. We reserve the right to constantly develop and improve our products.

.. Note::
    Yeah, yeah, yeah! Since that was originally written, sometime in the early 1990's, the world has moved on and most of the old QL programs are pretty much in the public domain, free ware or open source. As indeed, this one is!
    
    *Norman Dunbar, December 2016*


QUESTIONS ABOUT THE TOOL KIT
============================

WHAT IS A TOOL KIT?
-------------------

A tool kit is a set of BASIC extensions, new commands and functions which add to the number of "words" understood by the QL's BASIC language. These new extensions greatly add to the power and versatility of SuperBASIC, by adding the facility to perform new actions, or by simplifying a task which is difficult to program at the moment

CAN I USE THE TOOLKIT IN MY OWN PROGRAMS?
-----------------------------------------

Yes, you can use these commands both in interpreted BASIC programs and compiled BASIC programs, but see the note above regarding use with Turbo.

DOES IT WORK WITH OTHER TOOLKITS?
---------------------------------

We have tried to ensure that there is no clash, but it is impossible to test it against every other piece of software or hardware. Please let us know if you discover any incompatibilities so that we can try to sort them out.


BRIEF DESCRIPTION OF THE NEW COMMANDS
=====================================

+------------------+---------------------------------------------------------+
| ABS_POSITION     | Set file position absolute                              |
+------------------+---------------------------------------------------------+
| BYTES_FREE       | How much free memory is left, in bytes                  |
+------------------+---------------------------------------------------------+
| CHECK            | Test to see if a machine code PROC/FN exists            |
+------------------+---------------------------------------------------------+
| DEV_NAME         | Scan the Directory Device list, returning the next name |
+------------------+---------------------------------------------------------+
| DISPLAY_WIDTH    | How many bytes are used to hold one screen line         |
+------------------+---------------------------------------------------------+
| DJ_OPEN          | Opens a file, returns error or channel id               |
+------------------+---------------------------------------------------------+
| DJ_OPEN_IN       | Ditto, similar to OPEN_IN                               |
+------------------+---------------------------------------------------------+
| DJ_OPEN_NEW      | Creates a file, returns channel id or error             |
+------------------+---------------------------------------------------------+
| DJ_OPEN_OVER     | Overwrites a file, returns error or channel id          |
+------------------+---------------------------------------------------------+
| DJ_OPEN_DIR      | Opens a device directory for access                     |
+------------------+---------------------------------------------------------+
| DJTK_VER$        | Return the toolkit version number as a string           |
+------------------+---------------------------------------------------------+
| FETCH_BYTES      | Get some bytes from a channel                           |
+------------------+---------------------------------------------------------+
| FILE_BACKUP      | Get the backup date for a specific file                 |
+------------------+---------------------------------------------------------+
| FILE_DATASPACE   | Get the file's dataspace                                |
+------------------+---------------------------------------------------------+
| FILE_LENGTH      | Get the file's length                                   |
+------------------+---------------------------------------------------------+
| FILE_POSITION    | Get the current position in the file                    |
+------------------+---------------------------------------------------------+
| FILE_TYPE        | Get the file's type                                     |
+------------------+---------------------------------------------------------+
| FILE_UPDATE      | Get the file's update date                              |
+------------------+---------------------------------------------------------+
| FILLMEM_B        | Fill memory with a byte value                           |
+------------------+---------------------------------------------------------+
| FILLMEM_L        | Fill memory with a long value                           |
+------------------+---------------------------------------------------------+
| FILLMEM_W        | Fill memory with a word value                           |
+------------------+---------------------------------------------------------+
| FLUSH_CHANNEL    | Flush the data on a channel to a device                 |
+------------------+---------------------------------------------------------+
| GET_BYTE         | Fetch one byte from a channel                           |
+------------------+---------------------------------------------------------+
| GET_FLOAT        | Fetch 6 bytes from a channel                            |
+------------------+---------------------------------------------------------+
| GET_LONG         | Fetch 4 bytes from a channel                            |
+------------------+---------------------------------------------------------+
| GET_STRING       | Fetch a QDOS string from a channel                      |
+------------------+---------------------------------------------------------+
| GET_WORD         | Fetch 2 bytes from a channel                            |
+------------------+---------------------------------------------------------+
| KBYTES_FREE      | How much free memory is left in Kbytes                  |
+------------------+---------------------------------------------------------+
| LEVEL2           | Test whether level 2 drivers are present on a channel   |
+------------------+---------------------------------------------------------+
| MAX_CON          | Returns the absolute limits of a SCR or CON channel     |
+------------------+---------------------------------------------------------+
| MAX_DEVS         | Counts the number of directory devices. See DEV_NAME    |
+------------------+---------------------------------------------------------+
| MOVE_MEM         | Move memory around                                      |
+------------------+---------------------------------------------------------+
| MOVE_POSITION    | Set a file position relative to its current one         |
+------------------+---------------------------------------------------------+
| PEEK_FLOAT       | Read 6 bytes from memory into a float variable          |
+------------------+---------------------------------------------------------+
| PEEK_STRING      | Get bytes from memory into a string                     |
+------------------+---------------------------------------------------------+
| POKE_FLOAT       | pokes a floating point variable into memory             |
+------------------+---------------------------------------------------------+
| POKE_STRING      | Store the string in memory at a given address           |
+------------------+---------------------------------------------------------+
| PUT_BYTE         | Send 1 byte to a channel                                |
+------------------+---------------------------------------------------------+
| PUT_FLOAT        | Send 6 bytes to a channel                               |
+------------------+---------------------------------------------------------+
| PUT_LONG         | Send 4 bytes to a channel                               |
+------------------+---------------------------------------------------------+
| PUT_STRING       | Send a QDOS string to a channel                         |
+------------------+---------------------------------------------------------+
| PUT_WORD         | Send 2 bytes to a channel                               |
+------------------+---------------------------------------------------------+
| QPTR             | Is the Pointer Environment available                    |
+------------------+---------------------------------------------------------+
| READ_HEADER      | Read the header for a file into a buffer                |
+------------------+---------------------------------------------------------+
| RELEASE_HEAP     | Remove some space allocated with RESERVE_HEAP           |
+------------------+---------------------------------------------------------+
| RESERVE_HEAP     | Get some Common Heap space for a program to use         |
+------------------+---------------------------------------------------------+
| SCREEN_BASE      | Find out where the screen memory starts for a channel   |
+------------------+---------------------------------------------------------+
| SCREEN_MODE      | Returns the current screen mode, 4 or 8                 |
+------------------+---------------------------------------------------------+
| SEARCH_C         | Look in memory for a string, case is considered         |
+------------------+---------------------------------------------------------+
| SEARCH_I         | Ditto, but case is ignored                              |
+------------------+---------------------------------------------------------+
| SET_HEADER       | Set the header for a file                               |
+------------------+---------------------------------------------------------+
| SET_XINC         | Change horizontal spacing between characters            |
+------------------+---------------------------------------------------------+
| SET_YINC         | Change vertical spacing between lines of characters     |
+------------------+---------------------------------------------------------+
| SYSTEM_VARIABLES | Find out where the system variables are                 |
+------------------+---------------------------------------------------------+
| USE_FONT         | Change the fonts used by a channel                      |
+------------------+---------------------------------------------------------+
| WHERE_FONTS      | Find the addresses of the two fonts used on a channel   |
+------------------+---------------------------------------------------------+



In the following  descriptions, all parameters must be supplied as there are no defaults, in addition, when a channel number is being passed, either as a number or as a variable, it must be preceded by a hash (#).


QDOS ERROR CODES
================

Many of the above functions return a valid result, such as an address, or a negative error code. The QDOS error codes are listed below for reference.

- -1 Not complete
- -2 Invalid job
- -3 Out of memory
- -4 Out of range 
- -5 Buffer overflow 
- -6 Channel not open 
- -7 Not found 
- -8 File already exists 
- -9 In use 
- -10 End of file 
- -11 Drive full 
- -12 Bad device name 
- -13 Xmit (transmit) error 
- -14 Format failed 
- -15 Bad parameter 
- -16 File error 
- -17 Error in expression 
- -18 Arithmetic overflow 
- -19 Not implemented 
- -20 Read only 
- -21 Bad line

