

/*   R E P L A C E   S P A N S   */
/*-------------------------------------------------------------------------
    Replaces patterns that span lines

    Inputs:
    	hbuf - the buffer
    	lnStart - the first line number to start searching.  Replacement continues
    		up to the end of the file.
    	newtext - the replacement text.  The newtext is limited to a single line or less.
    	patternStart - the pattern that starts a span.
    	patternEnd - the pattern that ends a span.  The start and end patterns
    		may be on separate lines.
    	fCaseSens - boolean: case sensitive search
    	fRegExp - boolean: use regular expression patterns

    Returns the number of replacements
-------------------------------------------------------------------------*/
macro ReplaceSpans(hbuf, lnStart, newtext, patternStart, patternEnd, fCaseSens, fRegExp)
{
	var cReplace
	var selMatch
	var selEnd
	
	cReplace = 0;
	
	selMatch = SearchInBuf(hbuf, patternStart, lnStart, 0, fCaseSens, fRegExp, False);
	
	while (selMatch != nil)
		{
		// find starting pattern
		SetBufIns(hbuf, selMatch.lnFirst, selMatch.ichFirst);
		
		// find ending pattern and extend selection up to include it
		Toggle_extend_mode;
		selEnd = SearchInBuf(hbuf, patternEnd, selMatch.lnFirst, selMatch.ichFirst, 
			fCaseSens, fRegExp, False);

		if (selEnd == nil)
			{
			// no more matches
			Toggle_extend_mode;
			break;
			}
			
		SetBufIns(hbuf, selEnd.lnLast, selEnd.ichLim);
		Toggle_extend_mode;
		
		// replace the old text with newtext
		SetBufSelText(hbuf, newtext);
		cReplace = cReplace + 1;
	
		// set the insertion point just past the new text
		selMatch.ichFirst = selMatch.ichFirst + strlen(newtext)
		SetBufIns(hbuf, selMatch.lnFirst, selMatch.ichFirst);
		
		// search for the next occurrence
		selMatch = SearchInBuf(hbuf, patternStart, selMatch.lnFirst, selMatch.ichFirst, 
			fCaseSens, fRegExp, False);
		}

	return cReplace;
}


/*-------------------------------------------------------------------------
    Replaces a pattern with the contents of the Clipboard

    Inputs:
    	hbuf - the buffer
    	lnStart - the first line number to start searching.  Replacement continues
    		up to the end of the file.
    	pattern - the pattern to find and replace.
    	fCaseSens - boolean: case sensitive search
    	fRegExp - boolean: use regular expression patterns

    Returns the number of replacements
-------------------------------------------------------------------------*/
macro ReplaceWithClipboard(hbuf, lnStart, pattern, fCaseSens, fRegExp)
{
	var cReplace
	var selMatch
	var selEnd
	var hwnd
	
	// put the target buffer in the current window
	SetCurrentBuf(hbuf)
	hwnd = GetCurrentWnd()
	
	cReplace = 0;
	
	selMatch = SearchInBuf(hbuf, pattern, lnStart, 0, fCaseSens, fRegExp, False);
	
	while (selMatch != nil)
		{
		// find starting pattern
		SetWndSel(hwnd, selMatch)
		
		// replace the old text with newtext
		Paste
		cReplace = cReplace + 1;
	
		// set the insertion point just past the new text
		selMatch.ichFirst = selMatch.ichFirst + 1;
		SetBufIns(hbuf, selMatch.lnFirst, selMatch.ichFirst);
		
		// search for the next occurrence
		selMatch = SearchInBuf(hbuf, pattern, selMatch.lnFirst, selMatch.ichFirst, 
			fCaseSens, fRegExp, False);
		}

	return cReplace;
}


/*-------------------------------------------------------------------------
    Replaces patterns that span lines with the contents of the Clipboard

    Inputs:
    	hbuf - the buffer
    	lnStart - the first line number to start searching.  Replacement continues
    		up to the end of the file.
    	patternStart - the pattern that starts a span.
    	patternEnd - the pattern that ends a span.  The start and end patterns
    		may be on separate lines.
    	fCaseSens - boolean: case sensitive search
    	fRegExp - boolean: use regular expression patterns

    Returns the number of replacements
-------------------------------------------------------------------------*/
macro ReplaceSpansWithClipboard(hbuf, lnStart, patternStart, patternEnd, fCaseSens, fRegExp)
{
	var cReplace
	var selMatch
	var selEnd
	
	// put the target buffer in the current window
	SetCurrentBuf(hbuf)
	
	cReplace = 0;
	
	selMatch = SearchInBuf(hbuf, patternStart, lnStart, 0, fCaseSens, fRegExp, False);
	
	while (selMatch != nil)
		{
		// find starting pattern
		SetBufIns(hbuf, selMatch.lnFirst, selMatch.ichFirst);
		
		// find ending pattern and extend selection up to include it
		Toggle_extend_mode;
		selEnd = SearchInBuf(hbuf, patternEnd, selMatch.lnFirst, selMatch.ichFirst, 
			fCaseSens, fRegExp, False);

		if (selEnd == nil)
			{
			// no more matches
			Toggle_extend_mode;
			break;
			}
			
		SetBufIns(hbuf, selEnd.lnLast, selEnd.ichLim);
		Toggle_extend_mode;
		
		// replace the old text with newtext
		Paste
		cReplace = cReplace + 1;
	
		// set the insertion point just past the new text
		selMatch.ichFirst = selMatch.ichFirst + 1;
		SetBufIns(hbuf, selMatch.lnFirst, selMatch.ichFirst);
		
		// search for the next occurrence
		selMatch = SearchInBuf(hbuf, patternStart, selMatch.lnFirst, selMatch.ichFirst, 
			fCaseSens, fRegExp, False);
		}

	return cReplace;
}


