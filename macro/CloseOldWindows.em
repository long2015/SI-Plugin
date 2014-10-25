// Closes all but the most recently visited windows and files.
// Any dirty files are kept open.
macro CloseOldWindows()
{
	var hwnd
	var cWnd
	
	// This is the number of recent windows to keep open.  You may change 
	// this constant to suit your needs.
	var NumberOfWindowsToKeep; NumberOfWindowsToKeep = 4

	hwnd = GetCurrentWnd()
	cWnd = 0

	// skip the most recently visited windows in the z-order
	while (hwnd != hNil && cWnd < NumberOfWindowsToKeep)
		{
		cWnd = cWnd + 1
		hwnd = GetNextWnd(hwnd)
		}
	
	// close the remaining windows
	while (hwnd != hNil)
		{
		var hwndNext
		
		hwndNext = GetNextWnd(hwnd)
		
		// only close the window if the file is not edited
		if (!IsBufDirty(GetWndBuf(hwnd)))
			CloseWnd(hwnd)
		
		hwnd = hwndNext
		}

	// close all files that are not visible in a window anymore
	var cBuf
	cBuf = BufListCount()
	while (cBuf > 0)
		{
		var hbuf
		cBuf = cBuf - 1
		hbuf = BufListItem(cBuf)
		if (GetWndHandle(hbuf) == hNil)
			CloseBuf(hbuf)
		}
}

