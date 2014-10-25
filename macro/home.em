/*   S H I F T   H O M E   */
/*-------------------------------------------------------------------------
    Extends the selection back to the first non-white space on the
    current line.
-------------------------------------------------------------------------*/
macro ShiftHome()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop

	sel = GetWndSel(hwnd)
	hbuf = GetWndBuf(hwnd)

	// if selection is extended, collapse it first
	if (sel.fExtended)
		{
		SetBufIns(hbuf, sel.lnFirst, sel.ichFirst)
		sel = GetWndSel(hwnd)
		}
	
	// if the first character on the line is white space, 
	// then move forward to the first word on the line
	szLine = GetBufLine(hbuf, sel.lnFirst)
	chTab = CharFromAscii(9)
	ich = 0
	while (szLine[ich] == " " || szLine[ich] == chTab)
		ich = ich + 1
	
	if (ich < sel.ichLim)
		{
		sel.ichFirst = ich;
		SetWndSel(hwnd, sel);
		}
	else
		Beginning_of_Line
}
