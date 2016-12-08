=================
DJToolkit Updates
=================

UPDATES TO DJTOOLKIT V1.10
--------------------------

A few new commands have been added, such as ``QPTR``, the font handling commands and ``DISPLAY_WIDTH`` to check the display size. All these are now documented in the manual. Norman has, however, given me an embarrassing list of typing errors I made when I transferred the manual to prepare it in Text87, these will be corrected in the next issue of the manual, as they do not affect the accuracy of the manual, only offend those who dislike typos! 

*Dilwyn Jones*


UPDATES TO DJTOOLKIT V1.11 (18/5/1993)
--------------------------------------

Despite the fact that the AH and JM ROM presented the ``DISPLAY_WIDTH`` command with problems, this has now been solved in two ways. Firstly, a demo routine (``DISPLAY_WIDTH_JM``) checks for an offending ROM version and returns a default value to prevent the problem. Secondly, Norman has patched the ``DISPLAY_WIDTH`` function to include a check for AH and JM ROMs (or rather the versions of QDOS with those versions of BASIC, to be accurate) to prevent the problem.

I have fixed an embarrassing number of faults in the demo files. Nobody actually complained about these, I just noticed them myself. I've also added a few more demo routines such as a fast copier and dates utility - most of the new routines are at the end of the file.

Note that the DEMOS_sav version can give a list of missing extensions when loaded with QLOAD if the QLiberator extensions are not present. For the most part, they will still run OK, since a check is made for their presence (e.g. the ``CURSOR_ENABLE`` routine. I have also updated the DEMOS_doc documentation file to include details of the new routines.

I made a few changes to the demo routines to take account of the fact that Norman reprogrammed some functions in V1.10 at the suggestion of Ralf Rekoendt of Germany, to return negative error codes rather than stopping with an error message.

The first commercial program using this toolkit has been launched - DJC's CONVERT-PCX graphics conversion utility for clipart ported from the PC (used in conjunction with Discover, plug, plug). CONVERT-PCX costs just £10.00.

*Dilwyn Jones*


UPDATES TO DJTOOLKIT V1.12 (15/6/1993)
--------------------------------------

Due to the fact that I tried to make things a bit quicker in the ``MOVE_MEM`` command, I ended up using an algorithm that allowed an easy (!) way to figure out which direction the memory needed to be moved in order to avoid overlap problems. As it turned out, the algorithm was wrong! This caused a slight problem in that some of the first 6 bytes were not moved when moving from an even address to an even address with no overlap, the program did it as if there was an overlap and missed a few bytes out of the move.

``MOVE_MEM`` is now fixed, bigger and for small memory moves, it spends most of its time figuring out how to actually do it. Large memory moves, say saving and restoring screens, should now work correctly and quickly.  

*Norman Dunbar*



UPDATES TO DJTOOLKIT V1.13 (19/07/1993)
---------------------------------------

I use a Gold Card for all my work, it is quick and the vast amount of memory allows me to run lots of utility programs together with QPAC 2 etc. So what, I hear you think. Well it seems that a small bug has existed in the ``FILE_POSITION`` function which causes a normal 128K QL to crash with a fancy screen display which fills the screen from the bottom to the top - interesting. A Trump Card (old version, no level 2 drivers) just gives up quietly and gives no indication of its troubles. A Gold Card works !!!!!!!

It seems that the system call ``FS_POSRE`` (TRAP #3, D0 = $43) actually destroys register A1 which is of course the maths stack pointer. This has now been fixed for All QLs, not just the Gold Card users. Funny, no one has complained about it up until yesterday when Dilwyn Phoned !

Having tested the new version (1.13) on a Trump Card equipped QL, I fired up the trusty Gold Card and traced the execution of ``FILE_POSITION`` using QMON 2. Lo and behold, the A1 register is PRESERVED by the system call ``FS_POSRE`` (and ``FS_POSAB``?) when running with a Gold Card, mystery solved, but why is it preserved ?

*Norman Dunbar*


UPDATES TO VERSION 1.13 PART 2 (22/10/1993)
-------------------------------------------

Dilwyn contacted me to say that a customer was having problems with some of Dilwyn's demo routines. I have had a look at these (Dilwyn has more than enough problems with Page Designer 3 !!!!) and found that most of them were caused by not having enough ``LOCal`` statements.

Some of Dilwyn's routines use the same names, but some are ARRAYs and others are not. If ``FASTCOPY`` has been called, ``LOAD_A_FONT`` refuses to work due to the variable 'fl' being a ``DIM``med array in ``FASTCOPY`` (for file length). I have added a few more ``LOCals`` to every routine that needs them. Problem now solved.

You should be aware that on some QLs, JS in particular, there is a bug that occurs when a program routine is executed. If the routine (PROC or FN) has a total of 10 or more parameters and locals then the SuperBasic listing gets trashed in a big way. The program will probably fall over with BAD NAME or something.

When testing the amended demo routines, I of course had forgotten about this bug and managed to remove the SuperBasic job from the QL all together (who said it couldn't be done ?) Using the ``JOBS``/``RJOB`` utilities in QPAC 2 did not even show SuperBasic as a job any more !!!!!

Luckily I always (?) save changes before running them, just in case. One quick reset later and all was well again. Enough waffle, hopefully the demos are now ok. I have put a warning in the demos file at the start and ``REMark``ed out extra ``LOCal`` lines but there shouldn't be any more name clashes - famous last words.

*Norman Dunbar*


UPDATES TO DJTOOLKIT V1.14 (12/06/1994)
---------------------------------------

At Dilwyn's request, some additional routines have been added to the toolkit. These being some file opening functions that return an error code or the channel id. I also added a couple of extra handy routines of my own, just for fun. The new routines are::

    POKE_FLOAT address,value (PROC)
    PEEK_FLOAT(address)      (FN returning float)
    MAX_DEVS                 (FN returning integer)
    DJ_OPEN('filename')      (FN returning integer)
    DJ_OPEN_IN('filename')   (ditto)		
    DJ_OPEN_NEW('filename')  (ditto)	
    DJ_OPEN_OVER('filename') (ditto)
    DJ_OPEN_DIR('filename')  (ditto)
    MAX_CON(#ch, x,y,xo,yo)  (FN returning int + altered params)

The file opening procedures are very similar to Simon Goodwin's recent article in the DIY Toolkit series in QL WORLD magazine (Vol 2, issue 8 which was marked Vol 2 issue 7 just to be confusing). The article was about his routines called ``ANYOPEN%``. Simon's article came in very handy as I had known about the ability to extend the SuperBasic channel table, but had not quite figured out how to fill it in afterwards. Thanks Simon.

*Norman Dunbar*

UPDATES TO DJTOOLKIT V1.15 (16/06/1994)
---------------------------------------

So, I thought it was complete, but Dilwyn left a message on my machine, which went something like "what happened to the fill memory commands then ?" - oops, I forgot !

This version, 1.15, now contains the additional procedures ::

    FILLMEM_B start_address, how_many, value
    FILLMEM_W start_address, how_many, value
    FILLMEM_L start_address, how_many, value

and that is about what they do !

*Norman Dunbar*


UPDATES TO DJTOOLKIT V1.16 (27/02/2013)
---------------------------------------

Change to ``GET_STRING`` function so as not to cause End Of File error on SMSQmulator if a null string is the last item fetched from the end of a file.

*Norman Dunbar*
