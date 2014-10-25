
// Convert spaces to tabs and save the file
macro Save_Spaces_To_Tabs()
{
	hbuf = GetCurrentBuf()
	if (hbuf != hNil)
		{
		Spaces_To_Tabs()
		SaveBuf(hbuf)
		}
}


// Convert tabs to spaces and save the file
macro Save_Tabs_To_Spaces()
{
	hbuf = GetCurrentBuf()
	if (hbuf != hNil)
		{
		Tabs_To_Spaces()
		SaveBuf(hbuf)
		}
}




//----------------------------------------------------------------------------
// 	Function: Spaces_To_Tabs
// 
//	Description:
// 		Convert all sets of two or more spaces in the current buffer into the
//      appropriate number of tab characters.
//
macro Spaces_To_Tabs()
{
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()
	srSave = GetWndSel(hwnd)

    // Phase 1: convert the spaces at the beginning of lines
    //
	Leading_Spaces_To_Tabs()

    // Phase 2: convert the spaces NOT at the beginning of lines
    //
	sr = SearchInBuf(hbuf, "  +", 0, 0, 1, 1, 0)
	
	while (sr != "")
	{
	    SetWndSel(hwnd, sr)
		ReTab_Current_Line()
	    sr = GetWndSel(hwnd)
        sr = SearchInBuf(hbuf, "  +", sr.lnLast, sr.ichLim, 1, 1, 0)
	}
	SetBufIns(hbuf, srSave.lnFirst, srSave.ichFirst)
}


//----------------------------------------------------------------------------
// 	Function: Tabs_To_Spaces
// 
//	Description:
// 		Convert all tab characters in the current buffer into the appropriate
//      number of spaces.
//
macro Tabs_To_Spaces()
{
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()
	srSave = GetWndSel(hwnd)
	
    // Phase 1: convert the tabs at the beginning of lines
    //
	Leading_Tabs_To_Spaces()

    // Phase 2: convert the tabs NOT at the beginning of lines
    //
	sr = SearchInBuf(hbuf, "\\t", 0, 0, 1, 1, 0)

	while (sr != "")
	{
		SetWndSel(hwnd, sr)
		DeTab_Current_Line()
	    sr = GetWndSel(hwnd)
		sr = SearchInBuf(hbuf, "\\t", sr.lnLast, sr.ichLim, 1, 1, 0)
	}
	SetBufIns(hbuf, srSave.lnFirst, srSave.ichFirst)
}



//----------------------------------------------------------------------------
// 	Function: Leading_Spaces_To_Tabs
// 
//	Description:
// 		Convert all sets of two or more spaces in the current buffer into the
//      appropriate number of tab characters.
//
macro Leading_Spaces_To_Tabs()
{
	hbuf = GetCurrentBuf()
    iConsecutiveTabs = 0
    while (iConsecutiveTabs < 15)
    {
		ReplaceInBuf(hbuf, "^\\(\\t*\\)    ", "\\1\\t", 0,
				 	 GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
		iConsecutiveTabs = iConsecutiveTabs + 1
	}
}



//----------------------------------------------------------------------------
// 	Function: Leading_Tabs_To_Spaces
// 
//	Description:
// 		Convert all tab characters at line beginnings in the current buffer
//		into the appropriate number of spaces. Brute force method.
//
macro Leading_Tabs_To_Spaces()
{
	hbuf = GetCurrentBuf()
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                                            ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                                        ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                                    ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                                ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                            ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                        ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                    ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t\\t",
    			 "                                ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t\\t",
    			 "                            ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t\\t",
    			 "                        ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t\\t",
    			 "                    ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t\\t",
    			 "                ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t\\t",
    			 "            ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t\\t",
    			 "        ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
    ReplaceInBuf(hbuf, "^\\t",
    			 "    ", 
				 0, GetBufLineCount(hbuf) + 1, 1, 1, 0, 0)
}



//----------------------------------------------------------------------------
// 	Function: DeTab_Current_Line
// 
//	Description:
// 		Convert all tabs in the current line into the appropriate number of
//		spaces, based upon line position. Good for up to 25 consecutive tabs.
//
macro DeTab_Current_Line()
{
	szSpaces = "                                                                                                    "
	tabSize  = 4
	hbuf = GetCurrentBuf()
	iLine = GetBufLnCur(hbuf)
	cLines = GetBufLineCount(hbuf)
	szLine = GetBufLine(hbuf, iLine)
	cchLine = strlen(szLine)

	ichL = 0
	ichR = 0
	icoL = 0
	icoR = 0
	ichLine = 0
	icoLine = 0
	inTabs = '<'
	szNewLine = ""

	while (ichLine < cchLine)
	{
		if (szLine[ichLine] == "\t")
		{
			if (inTabs == 'N')
			{
				szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
				icoL = icoLine
			}
			icoLine = (((icoLine + tabSize) / tabSize) * tabSize)
			icoR = icoLine
			inTabs = 'Y'
		}
		else
		{
			if (inTabs == 'Y')
			{
				cSpaces = icoR - icoL
				szNewLine = cat(szNewLine, strtrunc(szSpaces, cSpaces))
				ichL = ichLine
				ichR = ichLine
			}
			else
			{
				ichR = ichLine
			}
			icoLine = icoLine + 1
			inTabs = 'N'
		}
		ichLine = ichLine + 1
	}
	if (inTabs == 'Y')
	{
		cSpaces = icoR - icoL
		szNewLine = cat(szNewLine, strtrunc(szSpaces, cSpaces))
	}
	else
	{
		szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
	}
	PutBufLine(hbuf, iLine, szNewLine)

	// Work around weirdness of PutBufLine(); it moves UP one line when 
	// putting the last line in the buffer!
	//
	if (iLine + 1 == cLines)
	{
		Cursor_Down
	}
	End_Of_Line
}


//----------------------------------------------------------------------------
// 	Function: ReTab_Current_Line
// 
//	Description:
// 		Convert all sets of two or more spaces in the current line into the
//      appropriate number of tab and space characters, based upon line
//		position. Good for indentations up to 100 columns.
//
macro ReTab_Current_Line()
{
	szTabs   = "																									";
	szSpaces = "    "		// As many spaces as value of tabSize
	tabSize  = 4
	hbuf = GetCurrentBuf()
	iLine = GetBufLnCur(hbuf)
	cLines = GetBufLineCount(hbuf)
	szLine = GetBufLine(hbuf, GetBufLnCur(hbuf))
	cchLine = strlen(szLine)

	ichL = 0
	ichR = 0
	icoL = 0
	icoR = 0
	ichLine = 0
	icoLine = 0
	inText = '<'
	quotes = 'N'
	szNewLine = ""

	while (ichLine < cchLine)
	{
		if (szLine[ichLine] == "\t")
		{
		    if (quotes == 'N')
		    {
    			if (inText == 'Y')
    			{
    				szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
    				icoL = icoLine
    			}
    			else if (inText == '?')
    			{
    				ichR = ichR - 1
    				szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
    			}
    			inText = 'N'
    		}
   			icoLine = (((icoLine + tabSize) / tabSize) * tabSize)
   			icoR = icoLine
		}
		else if (szLine[ichLine] == " ")
		{
		    if (quotes == 'N')
		    {
    			if (inText == 'Y')
    			{
    				icoL = icoLine
    				ichR = ichLine
    				inText = '?'
    			}
    			else if (inText == '?')
    			{
    				ichR = ichR - 1
    				szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
    				inText = 'N'
    			}
    			else
    			{
    				inText = 'N'
    			}
    		}
   			icoLine = icoLine + 1
   			icoR = icoLine
		}
		else
		{
			if (inText == 'N')
			{
				cTabs = (icoR / tabSize) - (icoL / tabSize)
				if (cTabs > 0)
				{
					szNewLine = cat(szNewLine, strtrunc(szTabs, cTabs))
					cSpaces = icoR - ((icoR / tabSize) * tabSize)
				}
				else
				{
					cSpaces = icoR - icoL
				}
				if (cSpaces > 0)
				{
					szNewLine = cat(szNewLine, strtrunc(szSpaces, cSpaces))
				}
				ichL = ichLine
				ichR = ichLine
			}
			else
			{
				ichR = ichLine
			}
			if (szLine[ichLine] == "\"")
			{
				if (quotes == 'N')
				{
			    	quotes = 'Y'
			    }
			    else if (szLine[ichLine - 1] != "\\")
			    {
			    	quotes = 'N'
			    }
			}
			icoLine = icoLine + 1
			inText = 'Y'
		}
		ichLine = ichLine + 1
	}
	if ((inText == 'Y') || (inText == '?'))
	{
		szNewLine = cat(szNewLine, strmid(szLine, ichL, ichR + 1))
	}
	else if (inText == 'N')
	{
		cTabs = (icoR / tabSize) - (icoL / tabSize)
		if (cTabs > 0)
		{
			szNewLine = cat(szNewLine, strtrunc(szTabs, cTabs))
			cSpaces = icoR - ((icoR / tabSize) * tabSize)
		}
		else
		{
			cSpaces = icoR - icoL
		}
		if (cSpaces > 0)
		{
			szNewLine = cat(szNewLine, strtrunc(szSpaces, cSpaces))
		}	
	}
	PutBufLine(hbuf, iLine, szNewLine)

	// Work around weirdness of PutBufLine(); it moves UP one line when 
	// putting the last line in the buffer!
	//
	if (iLine + 1 == cLines)
	{
		Cursor_Down
	}
	End_Of_Line
}


