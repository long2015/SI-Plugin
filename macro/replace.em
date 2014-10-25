
/*   R E P L A C E   F R O M   L I S T   */
/*-------------------------------------------------------------------------
    Replace a list of strings across the whole project.
	Warning: Changes are automatically saved and are permanent!
	Note: this only works for whole word replacements.

    Outputs a replacement-log to a Results file
    
    The current window should contain a list of strings, one per line, 
    with a comma separating the old and new string.
    Example:

    oldword1,newword1
    oldword2,newword2
	... etc ...
-------------------------------------------------------------------------*/
macro ReplaceFromList()
{
	hbufList = GetCurrentBuf();
	lnMax = GetBufLineCount(hbufList)

	// create result log file
	hbufResult = NewBuf("Results")
	if (hbufResult == 0)
		stop
	
	countTot = 0
	
	// process each item in the list
	ln = 0
	while (ln < lnMax)
		{
		// get list item; parse out old and new string
		line = GetBufLine(hbufList, ln)
		ichComma = IchInString(line, ",")
		if (ichComma > 0)
			{
			szOld = strmid(line, 0, ichComma)
			szNew = strmid(line, ichComma + 1, strlen(line))
			
			// use one the next 2 lines to do replaces.
			count = ReplaceSzWordInProject(szOld, szNew, hbufList)
			// count = ReplaceSzAnyInProject(szOld, szNew, hbufList)
			
			AppendBufLine(hbufResult, "@szOld@=>@szNew@ : @count@ replacements")
			countTot = countTot + count
			}
		ln = ln + 1
		}
	
	SetCurrentBuf(hbufResult)
	Msg("@countTot@ total replacements were made.");
}


/*   R E P L A C E   S Z   W O R D   I N   P R O J E C T   */
/*-------------------------------------------------------------------------
    Replace whole word szOld with szNew across the whole project.
    Note: this only works for whole word replacements.
    
	hbufSkip is skipped over.  This is handy because
	we don't want to replace in the replacement-list file

	Returns the number of replacements performed
-------------------------------------------------------------------------*/
macro ReplaceSzWordInProject(szOld, szNew, hbufSkip)
{
	TRUE = 1; FALSE = 0;
	
	// create source link buffer
	hbufLinks = NewBuf("Links") 
	if (hbufLinks == 0)
		stop
	
	// search across project for szOld
	SearchForRefs(hbufLinks, szOld, 0)
	
	// step thru each source link
	ilinkMac = GetBufLineCount(hbufLinks)
	ilink = 0;
	fileLast = ""
	cReplace = 0
	while (ilink < ilinkMac)
		{
		link = GetSourceLink(hbufLinks, ilink)
		if (link != "" && link.file != fileLast)
			{
			// open the file and search for each occurence
			fileLast = link.file
			hbuf = OpenBuf(link.file)
			if (hbuf != 0 && hbuf != hbufSkip)
				{
				// do replace operation in the buffer
				count = DoReplace(hbuf, szOld, szNew)
				cReplace = cReplace + count
				
				// Save and close the file
				// SaveBuf(hbuf)
				if (count != 0)
					SaveBuf(hbuf)
				CloseBuf(hbuf)
				}
			}
		
		// next source link
		ilink = ilink + 1
		}

	CloseBuf(hbufLinks)
	return cReplace
}


/*   R E P L A C E   S Z   A N Y   I N   P R O J E C T   */
/*-------------------------------------------------------------------------
    Replace any szOld with szNew across the whole project.
    Note: this works for any szOld string, not just whole words
    
	hbufSkip is skipped over.  This is handy because
	we don't want to replace in the replacement-list file

	Returns the number of replacements performed
-------------------------------------------------------------------------*/
macro ReplaceSzAnyInProject(szOld, szNew, hbufSkip)
{
	TRUE = 1; FALSE = 0;
	
	hprj = GetCurrentProj()
	if (hprj == 0)
		{
		Msg ("You must have a project open.")
		stop
		}
	
	// for each project file...
	ifileMac = GetProjFileCount(hprj)
	ifile = 0
	cReplace = 0
	while (ifile < ifileMac)
		{
		// open each project file and search for each occurence
		filename = GetProjFileName(hprj, ifile)
		
		hbuf = OpenBuf(filename)
		if (hbuf != 0 && hbuf != hbufSkip)
			{
			// do replace operation in the buffer
			count = DoReplace(hbuf, szOld, szNew)
			cReplace = cReplace + count
			
			// Save and close the file
			if (count != 0)
				SaveBuf(hbuf)
			CloseBuf(hbuf)
			}
		
		// next source link
		ifile = ifile + 1
		}

	return cReplace
}


/*   R E P L A C E   */
/*-------------------------------------------------------------------------
    Do a replace operation in the given buffer.
    Returns the number of replacements
-------------------------------------------------------------------------*/
macro DoReplace(hbuf, szOld, szNew)
{
	TRUE = 1
	
	// find each occurence and replace each one
	ln = 0
	ich = 0
	cReplace = 0
	hwnd = 0
	while (TRUE)
		{
		sel = SearchInBuf(hbuf, szOld, ln, ich, TRUE, FALSE, TRUE)
		if (sel == "")
			break;
		if (hwnd == 0)
			{
			// put buffer in a window
			SetCurrentBuf(hbuf)
			hwnd = GetCurrentWnd()
			}
		cReplace = cReplace + 1
		SetWndSel(hwnd, sel)
		SetBufSelText(hbuf, szNew)
		ln = sel.lnLast;
		ich = sel.ichLim;
		}
	
	return cReplace
}

/*   I C H   I N   S T R I N G   */
/*-------------------------------------------------------------------------
    Return index of character ch in string s;
    Return -1 if ch is not found
-------------------------------------------------------------------------*/
macro IchInString(s, ch)
{
	i = 0
	cch = strlen(s)
	while (i < cch)
		{
		if (s[i] == ch)
			return i
		i = i + 1
		}

	return (0-1)
}
