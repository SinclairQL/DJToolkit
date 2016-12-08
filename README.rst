READ ME
=======

This is the new home for the DJToolkit source code. 

The file, ``DJToolkit.asm`` in the ``DJTK_Source\Original`` folder is the old, very old, QDOSMSQ version written with an editor that had hard tabs. All the tabs have been replaced by spaces, but the tabs were asymmetrical, so the code formatting has been bolloxed. (Technical term!)

The file ``DJToolkit.asm`` that can be found in the ``DJTK_Source`` folder, is the new improved version that has been reformatted to something resembling a decent readable format. See the docs under Coding Style for details.

The formatter utility, ``DJTKReformat`` can be found in the ``Tools`` folder, and was compiled with Borland/Embarcadero C++ version 10.1 - which you can get for free, legally. 

If you have the excellent Embarcadero C++ 10.1 compiler, then there's a build file in the ``tools`` folder that will build the code for you. You can get the compiler free (for all time) from `Embarcadero Free Tools <https://www.embarcadero.com/free-tools>`__. Sign up for an account, download, unzip, add ``bin`` to ``%PATH%``. That's it!

If you have another compiler, then do whatever you must to compile a single C file into an executable. I have not tried any other Windows C compilers, I'm a big fan of the old Borland Tools and don't use anything else. (Well, ``GCC`` of course, on Linux!)

Possibly the following will work::

    cd SourceCode\MyPath\Release
    your_compiler_name -o MyPath.exe ..\MyPath\MyPath.c
    
Where 'your_compiler_name' is what you use to call your compiler on the command line.

If you decide to change the code, please stick to the coding style detailed in the docs. Ta.


Cheers,
Norm.
8th December 2016.