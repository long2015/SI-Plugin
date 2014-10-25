


/*   A U T O   E X P A N D   */
/*-------------------------------------------------------------------------
    Automatically expands C statements like if, for, while, switch, etc..

    To use this macro, 
    	1. Add this file to your project or your Base project.
		
		2. Run the Options->Key Assignments command and assign a 
		convenient keystroke to the "AutoExpand" command.
		
		3. After typing a keyword, press the AutoExpand keystroke to have the
		statement expanded.  The expanded statement will contain a ### string
		which represents a field where you are supposed to type more.
		
		The ### string is also loaded in to the search pattern so you can 
		use "Search Forward" to select the next ### field.

	For example:
		1. you type "for" + AutoExpand key
		2. this is inserted:
			for (###; ###; ###)
				{
				###
				}
		3. and the first ### field is selected.
-------------------------------------------------------------------------*/
macro AutoExpand()
{
	// get window, sel, and buffer handles
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	if (sel.ichFirst == 0)
		stop
	hbuf = GetWndBuf(hwnd)
	
	// get line the selection (insertion point) is on
	szLine = GetBufLine(hbuf, sel.lnFirst);
	
	// parse word just to the left of the insertion point
	wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
	ln = sel.lnFirst;
	
	chTab = CharFromAscii(9)
	
	// prepare a new indented blank line to be inserted.
	// keep white space on left and add a tab to indent.
	// this preserves the indentation level.
	ich = 0
	while (szLine[ich] == ' ' || szLine[ich] == chTab)
		{
		ich = ich + 1
		}
	
	szLine = strmid(szLine, 0, ich) # chTab
	sel.lnFirst = sel.lnLast
	sel.ichFirst = wordinfo.ich
	sel.ichLim = wordinfo.ich
	
	// expand szWord keyword...

	
	if (wordinfo.szWord == "if" || 
		wordinfo.szWord == "while" ||
		wordinfo.szWord == "elseif")
		{
		SetBufSelText(hbuf, " (###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{");
		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
		InsBufLine(hbuf, ln + 3, "@szLine@" # "}");
		}
	else if (wordinfo.szWord == "for")
		{
		SetBufSelText(hbuf, " (###; ###; ###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{");
		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
		InsBufLine(hbuf, ln + 3, "@szLine@" # "}");
		}
	else if (wordinfo.szWord == "switch")
		{
		SetBufSelText(hbuf, " (###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@" # "case ###:")
		InsBufLine(hbuf, ln + 3, "@szLine@" # chTab # "###")
		InsBufLine(hbuf, ln + 4, "@szLine@" # chTab # "break;")
		InsBufLine(hbuf, ln + 5, "@szLine@" # "}")
		}
	else if (wordinfo.szWord == "do")
		{
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
		InsBufLine(hbuf, ln + 3, "@szLine@" # "} while (###);")
		}
	else if (wordinfo.szWord == "case")
		{
		SetBufSelText(hbuf, " ###:")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "###")
		InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
		}
	else
		stop

	SetWndSel(hwnd, sel)
	LoadSearchPattern("###", true, false, false);
	Search_Forward
}


/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the 
    text word just to the left of the ich.

    Output:
    	wordinfo.szWord = the word string
    	wordinfo.ich = the first ich of the word
    	wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
	wordinfo = "" // create a "wordinfo" structure
	
	chTab = CharFromAscii(9)
	
	// scan backwords over white space, if any
	ich = ich - 1;
	if (ich >= 0)
		while (sz[ich] == " " || sz[ich] == chTab)
			{
			ich = ich - 1;
			if (ich < 0)
				break;
			}
	
	// scan backwords to start of word	
	ichLim = ich + 1;
	asciiA = AsciiFromChar("A")
	asciiZ = AsciiFromChar("Z")
	while (ich >= 0)
		{
		ch = toupper(sz[ich])
		asciiCh = AsciiFromChar(ch)
		if ((asciiCh < asciiA || asciiCh > asciiZ) && !IsNumber(ch))
			break // stop at first non-identifier character
		ich = ich - 1;
		}
	
	ich = ich + 1
	wordinfo.szWord = strmid(sz, ich, ichLim)
	wordinfo.ich = ich
	wordinfo.ichLim = ichLim;
	
	return wordinfo
}

