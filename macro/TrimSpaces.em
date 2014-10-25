
// This function trims white spaces from the ends of the selected lines
// in the current file buffer.  If the selection is empty, it does the 
// whole file.
macro TrimSpaces()
{
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()
	sel = GetWndSel(hwnd)

	if (sel.fExtended)
		{
		// use selected lines
		ln = sel.lnFirst
		lnLim = sel.lnLast + 1
		}
	else
		{
		// process the whole file buffer
		ln = 0
		lnLim = GetBufLineCount(hbuf)
		}

	// do for each line....
	while (ln < lnLim)
		{
		s = GetBufLine(hbuf, ln)
		sTrim = StrTrimSpaces(s)
		if (s != sTrim)
			PutBufLine(hbuf, ln, sTrim)
		ln = ln + 1
		}
}


// Helper function: trims white space from the string s.
// Returns resulting string.
macro StrTrimSpaces(s)
{
	
	cch = strlen(s)
	ich = cch - 1

	chTab = CharFromAscii(9)

	while (ich >= 0)
		{
		ch = s[ich]
		if (ch != " " && ch != chTab)
			return strmid(s, 0, ich + 1)
		ich = ich - 1
		}

	return ""
}


