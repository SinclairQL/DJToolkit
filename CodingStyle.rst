DJToolkit Coding Style
======================

..  Convert this document to HTML:
..  pandoc -f rst -t html -o CodingStyle.html CodingStyle.rst

..  Or to Word's DOCX format:
..  pandoc -f rst -t docx -o CodingStyle.docx --toc --toc-depth 3 CodingStyle.rst

..  Or to Libre Office's ODT format:
..  pandoc -f rst -t odt -o CodingStyle.odt --toc --toc-depth 3 CodingStyle.rst

..  Etc.

Introduction
============

This document attempts to detail how I expect the source code to be formatted/styled/whatever by anyone wishing to attack it and make changes. It's also a reminded to myself as to what I used to do and what I should still be doing!

Source Coding Style
===================

Line Length
-----------

We try to keep the line length to 80 columns or less.


Tab Settings
------------

If your editor allows, set your tabs to:

- Column 12 for the opcode.
- Column 20 for the operand.
- Column 40 for the comments.

And *always* replace TAB characters with spaces. We *do not like* hard tabs as these mess up the source when it is edited in another editor that uses different tab settings. Ask me how I know - and this is why I wrote the DJTKReformat utility, to make things right again!

Make sure your line ends are set to Linux/Unix or just to Line Feed and not, carriage return and line feed.

Labels
------

Labels are optional in most cases, but are used for various things such as the destination of a ``BRA`` or ``JSR`` for example.

They should be 'lower_case_with_underscores', or 'CamelCaseWithoutUnderscores'. These days I prefer the latter, but back then, I used pretty much anything but mainly the former.

Labels that are longer that the width allowed, see above, should be on a line by themselves. For example::

    * The following is just a ruler, for (so called) clarity!
    00000000011111111112222222222333333333344444444445555555555666666666677777777778
    12345678901234567890123456789012345678901234567890123456789012345678901234567890
    
    ShortLabel moveq   #7,d0               Do something here with d0.   
    
    ThisIsALongLabel
               nop
               rts

Opcodes
-------

Opcodes are in *lower case*. This applies to assembler directives too, unless your assembler can't cope with that. I much prefer reading source code where the vast majority of the text is in lower case. Reading code written in upper case, is quite difficult.

Opcodes start in column 12, as mentioned above.


Operands
--------

Operands are in whatever letter case is suitable for their content. The use of lower case where possible is preferred though.

Operands begin in column 20, however, in the unlikely event that the opcode takes up too much room, a pair of spaces should be used to separate the operand from the opcode.

Comments
--------

Comments come in two flavours:

- Descriptive - those at the head of a routine explaining what it does;
- In Line - those tagged on to the end of a code line, with brief details of something you might want people to know about.

Descriptive Comments
~~~~~~~~~~~~~~~~~~~~

Descriptive comments begin in column 1 with either a '*' or a ';' according to your assembler syntax.

Sections of your code, perhaps a function or procedure should have a descriptive comment explaining what it does, in something resembling the following::

    *====================================================================*
    * DJTK_VER$ = return the version of the toolkit.                     *
    *--------------------------------------------------------------------*
    * I dont want any parameters, so check that there are none.          *
    *--------------------------------------------------------------------*
    * Stack uses 0 bytes and requires 2 + 4 bytes for the result.        *
    *====================================================================*

The full width above is only 70 characters.

Particularly noteworthy sections of the main code should be described with something similar to the following::

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

In the above, the '|' character is in column 33.


In-line Comments
~~~~~~~~~~~~~~~~

In line comments begin in column 40 *unless* operands take up too much space, whereupon a pair of spaces should be used to separate the comment from the operand. 

That is all! (Well, for now!)