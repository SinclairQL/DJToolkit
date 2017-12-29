//=========================================================================
// A utility to attempt to reformat the source code for DJToolkit, as per
// the following:
//
// LABELs start in column 1.
// The OPCODE starts in column 12 or as close as possible to it.
// The OPERAND start in column 20 or as close to it as possible.
// COMMENTS start in column 40 or as close as possible to it.
//
// Call it thus:
//
//      DJTKReformat Source_file_name
//
//
// Output is to the console, so it can be redirected:
//
//      DJTKReformat Source_file_name > output_file_name
//
// Debugging, logging, structure information messages etc go to stderr, so
// those can be redirected too:
//
//      DJTKReformat Source_file_name > output_file_name 2>error_filename
//
//
//=========================================================================
// 2016/12/08  Norman Dunbar  Created.
// 2017/07/26  Norman Dunbar  Fixed bug in scanning quoted operands.
//=========================================================================

#include "DJTKReformat.h"


int main (int argc, char *argv[])
{
    // We need at least one argument.
    if (argc <= 1) {
        cerr << "No parameters supplied. Nothing to do." << endl;
        cerr << "At least give me a source file to reformat!" << endl;
        return -1;
    }

    // We have a/some file(s), try to process it/them.
    for (int x = 1; x < argc; x++) {
        fileName = argv[x];
        bool ok = doFile(fileName);
        if (!ok) {
            cerr << "Failed processing file \"" << fileName << "\"." << endl;
        }
    }
    
    return 0;
}


bool doFile(const char *fname)
{
    // Open a source file and reformat the contents.
    // Comments beginning at column 1 are assumed to be ok and
    // are written out unchanged.

    // Open it in binary as this is (most likely) Windows and the
    // source is most likely QDOS line feeds, no carriage returns!

    // The following line doesn't work if using non-borland compilers!
    //dbf = ifstream(fname, std::ifstream::in | std::ifstream::binary);
    dbf.open(fname, std::ifstream::in | std::ifstream::binary);
    if (!(dbf.good())) {
        cerr << endl << "Cannot open file '" << fname << "'." << endl;
        return false;
    }

    // Announce the current file name.
    cerr << endl << "File Name: " << fname << endl;
    

    // Loop the loop, reading and writing. Plus a little
    // bit of reformatting in between! :-)
    lineNumber = 0;
    getline(dbf, source_line);
    
    while (dbf.good()) {
        // What line are we processing now?
        lineNumber++;
        
        // Comment & blank lines get written out unchanged.
        if ((source_line.empty()) || (source_line[0] == '*') || (source_line[0] == ';')) {
            cout << source_line << endl;
        } else {
            // Not a comment, needs reformatting.
            // The reformatLine function does the output too.
            reformatLine();
        }
            
        // Get the next line and go around again.
        getline(dbf, source_line);
    }
    
    dbf.close();
    return true;    
}


void reformatLine()
{
    // Takes whatever is in source_line and manipulates it how
    // I want it to be, then writes it out.
    string label;
    string opcode;
    string operand;
    string comment;
    
    // Iterate the string.
    string::iterator x = source_line.begin();
    
    // Where are we?
    cerr << endl << "Line " << lineNumber << ": [" << source_line << "]" << endl;
    
    // Do we have a label?
    if (!isspace(*x)) {
        // We have a label.
        label.assign(extractString(x));
        cerr << "LABEL = '" << label << "'" << endl;
    }

    // There must be an opcode.
    opcode.assign(extractString(x));
    cerr << "OPCODE = '" << opcode << "'" << endl;
    
    // There might be an operand. NOP etc excepted!
    // Oh, and we like lower case opcodes!
    // Yes, but other people don't.
    bool needOperand = true;
    for (list<string>::iterator y = noOperands.begin(); y != noOperands.end(); y++) {
	
	// Lowercase the opcode from the file, the list is in lowercase already.
	// We need the destination to be big enough first though!
	string opcodeLower = opcode;
	
	// This doesn't work!
	//transform(operand.begin(), operand.end(), opcodeLower.begin(), tolower());
	for (string::iterator x = opcodeLower.begin(); x != opcodeLower.end(); x++) {
	    *x = tolower(*x);
	}
	
        // Do we need an operand?
        cerr << "CHECKING: '" << opcodeLower << "' with '" << *y << "': ";
	
        if (!opcodeLower.compare(*y)) {
            needOperand = false;
            cerr << "Matched" << endl;
            break;
        } else {
            cerr << "No match" << endl;
        }
    }
    
    if (needOperand) {
        operand.assign(extractString(x));
        cerr << "OPERAND = '" << operand << "'" << endl;
    }
    
    // There might be a comment.    
    if (x != source_line.end()) {
        comment.assign(extractComment(x));
        cerr << "COMMENT = '" << comment << "'" << endl;
    }
    
    // We have all we need, create an output line.
    string outputLine;
    
    // We do it this way as numerous resize() operations
    // can be very slow. Even on small strings. So we make it
    // bigger than we need and trim it once afterwards.
    // Mind you, replace() can be fun too!
    // Lesser of two evils.
    outputLine.resize(120, ' ');     // 120 spaces. Bigger than we need.
    
    // if the label is too long, write it out by itself.
    if (label.length() >= OPCODE_POS - 1) {
        cout << label << endl;
    } else {
        // Shove the label in at the front. This is easy!
        if (!label.empty()) {
            outputLine.replace(LABEL_POS, label.length(), label);
        }
    }
    
    // Because the label is either big enough, or by itself we are fine here.
    int offset = OPCODE_POS;
    outputLine.replace(offset, opcode.length(), opcode);
    offset += opcode.length();
    
    // If we need an operand, try to get it where we want it.
    if (needOperand) {        
        offset = (offset > OPERAND_POS) ? offset + 2 : OPERAND_POS;
        outputLine.replace(offset, operand.length(), operand);
        offset += operand.length();
    } else {
        // Move on up to COMMENT_POS - no OPCODE will span that far.
        // Will it? ;-)
        offset = COMMENT_POS;
    }

    // And make sure the comment fits in its place too. Or close by.
    if (!comment.empty()) {
        offset = (offset > COMMENT_POS) ? offset + 2 : COMMENT_POS;
        outputLine.replace(offset, comment.length(), comment);
        offset += comment.length();
    }
    
    // Trim the crud off the end & write the output.
    outputLine.resize(offset);
    cout << outputLine << endl;
}


string extractString(string::iterator &x)
{
    // Extract a string from the position of the iterator
    // until the next whitespace character. Updates the
    // Iterator to point at the next character after the extraction.
    string result;
    
    // We ignore any leading whitespace.
    while (isspace(*x) && x != source_line.end()) {
        cerr << "extractString(): Ignoring '" << *x << "'." << endl;
        x++;
    }
    
    // Now we have something...
    string::iterator startPos = x;
    while (!isspace(*x) && x != source_line.end()) {
        cerr << "extractString(): Scanning... '" << *x << "'." << endl;
        // Watch out for quotes!
        if (*x == '"' || *x == '\'') {
            cerr << "extractString(): Found a quote [" << *x << "]." << endl;
            // Grab closing quote to search for, and scan to it.
            char endQuote = *x++;
            cerr << "extractString(): Scanning for closing quote [" << endQuote << "]." << endl;
            
            // Look for the next quote.
            while ((*x != endQuote) && (x != source_line.end())) {
                cerr << "extractString(): still in string... '" << *x << "'." << endl;
                x++;
            }
            
            // Point at the next character after the quote.
            x++;
        } else {
            // Not a quote, just keep scanning.
            x++;
        }
    }
        
    // Return it.
    return result.assign(startPos, x);
}


string extractComment(string::iterator &x)
{
    // Extract a comment. 
    // Scan to the first non whitespace character and 
    // take from there to EOL.
    string result;
    
    // We ignore any leading whitespace.
    while (isspace(*x) && x != source_line.end()) {
        cerr << "extractComment(): Ignoring '" << *x << "'." << endl;
        x++;
    }
    
    // Return the result.
    if (x != source_line.end()) {
        return result.assign(x, source_line.end());
    } else {
        // Empty string.
        return result;
    }
}
