:: Make sure that the Borland C++ compiler is on %PATH%
:: before running this file to build the HexDump utility.
::
:: Norman Dunbar April 2016


bcc32c -o DJTKReformat.exe DJTKReformat.cpp  wildargs.obj

if exist DJTKReformat.pdb (
    del /f DJTKReformat.pdb 2>nul
)

if exist DJTKReformat.tds (
    del /f DJTKReformat.tds 2>nul
)

pause
