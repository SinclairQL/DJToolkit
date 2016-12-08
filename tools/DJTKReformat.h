#ifndef __djtkreformat_h__
#define __djtkreformat_h__

#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>
#include <cctype>
#include <list>

using std::string;
using std::cout;
using std::cerr;
using std::endl;
using std::ifstream;
using std::setbase;
using std::string;
using std::list;
using std::setw;

//======================================================================
// GLOBALS (and yes, I know ....)
//======================================================================
const int LABEL_POS = 1 - 1;
const int OPCODE_POS = 12 - 1;
const int OPERAND_POS = 20 - 1;
const int COMMENT_POS = 40 - 1;

//======================================================================
// Input stream for the database file, the current file name and the
// current lineNumber.
//======================================================================
ifstream dbf;
char *fileName;
unsigned lineNumber;

//======================================================================
// Somewhere to save a source line.
//======================================================================
string source_line;

//======================================================================
// List of opcodes that take no operand. Or at least, the ones I use!
// And I only use lower case.
//======================================================================
string noOperand_[] = {"rts", "nop"};
list<string> noOperands(noOperand_, noOperand_ + sizeof(noOperand_)/ sizeof(string));

//======================================================================
// Function prototypes.
//======================================================================
bool doFile(const char *fname);
void reformatLine();
string extractString(string::iterator &x);
string extractComment(string::iterator &x);

#endif