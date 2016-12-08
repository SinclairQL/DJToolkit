DJTKReformat
============

This is a utility which takes the source code from a QL/QDOSMSQ system, and reformats it to a known coding standard. It does this as follows:

- Comment lines with an '*' or ';' in column 1 and written out unchanged.
- Blank lines are written out unchanged.

All other lines are reformatted so that:

- The label, if present, starts in column 1.
- The opcode starts in column 12. This includes assembler directives.
- The operand, if required, starts in column 20. This also includes operands for assembler directives.
- The comments, if present, start in column 40.

Not all opcodes take an operand. ``nop`` and ``rts`` are the two known and used ones in the original source code, so these are treated specially to avoid extracting the comments as an operand. Not good style!

The utility writes a lot of debugging information to ``stderr`` so you are advised to redirect this to a file, or ``nul`` if you are not interested.

What you will be interested in is the output, which goes to ``stdout`` and that should be redirected to a file, otherwise, you lose all the benefits of the reformatting.

Compiling
---------

There is a ``build.cmd`` file in the ``tools`` folder to build the code for you. IT assumes that the compiler is Borland/Embarcadero and is on the PATH. If you use a different C++ compiler, then you should do what you do to convert a single CPP file into an executable.

See the docs for how you can obtain the free Borland compiler.

Execution
---------

For best results, execute the utility as follows::

    DJTKReformat your_source_file > reformatted_file 2>debug_file
    
This way, ``your_source_file`` is read in and reformatted. The output is sent to ``reformatted_file`` and all the debugging information, which may be useful to me in the event that something isn't working, goes to ``debug_file``.

Easy!