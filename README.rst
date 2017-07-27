READ ME
=======

This is the new home for the DJToolkit source code. 

The original file, ``DJToolkit.asm`` was an old, very old, QDOSMSQ version written with an editor that had hard tabs. All the tabs have been subsequently replaced by spaces, but the resulting code was asymmetrical, so the code formatting had been completely bolloxed. (Technical term!)

The new file ``DJToolkit.asm`` that can be found in the ``DJTK_Source`` folder, is the new improved version that has been reformatted to something resembling a decent readable format. See the docs under Coding Style for details.

The formatter utility, ``DJTKReformat`` can be found in the ``Tools`` folder, and was compiled with Borland/Embarcadero C++ version 10.1 - which you can get for free, legally. 

If you have the excellent Embarcadero C++ 10.1 compiler, then there's a build file in the ``tools`` folder that will build the code for you. You can get the compiler free (for all time) from `Embarcadero Free Tools <https://www.embarcadero.com/free-tools>`__. Sign up for an account, download, unzip, add ``bin`` to ``%PATH%``. That's it!

If you have another compiler, then do whatever you must to compile a single C++ file into an executable. I have not tried any other Windows C++ compilers, I'm a big fan of the old Borland Tools and don't use anything else. (Well, ``GCC`` of course, on Linux! (and on Windows too sometimes!))

Possibly the following will work::

    cd SourceCode\DJToolkit\tools
    your_compiler_name -o DJTKReformat.exe DJTKReformat.cpp
    
Where 'your_compiler_name' is what you use to call your compiler on the command line.



Cheers,
Norm.
8th December 2016.