/*
	Macro command that performs a progressive search as the user types.
	
	As with other macros, to use this:
		1. Add this macro file to your project.
		2. Run the Options->Key Assignments command.
		3. Find and select the macro command name in the command list
		4. Press 'Add' to bind a key to the macro.
		Now you can run the macro command
*/


macro ProgressiveSearch()
{
	/* This does a progressive search as the user types characters
	   Pressing Enter or Escape will cancel the search 
	*/

    hbuf = GetCurrentBuf()
    hwnd = GetCurrentWnd()
    key = 0
    char = 1 // needs to start with any non-zero value
    SearchFor = ""
    sel = GetWndSel(hwnd)
    
	while (char != 0)
	{
		key = GetKey()
		char = CharFromKey(key)
		if (char != 0)
		{
		    
			if (key == 13) //Enter searches current string again
				sel.ichFirst = sel.ichFirst + 1
			else if (key == 8) // backspace
			{
				if (strlen(SearchFor) > 0)
					SearchFor = strtrunc (SearchFor, strlen(SearchFor) - 1)
			}
			else
				SearchFor = cat(SearchFor, char)
			sel = SearchInBuf(hbuf, SearchFor, sel.lnFirst, sel.ichFirst, 0, 0, 0)
			if (sel == "")
			{
				sel = GetWndSel(hwnd)
				if (key == 13)
				{
					sel.fExtended = 0
					sel.ichLim = sel.ichFirst
					SetWndSel(hwnd, sel)
					char = 0
					Beep()
				}
				else  
					if (strlen(SearchFor) > 0)
						SearchFor = strtrunc (SearchFor, strlen(SearchFor) - 1)
			}
			else
			{
        		ScrollWndToLine(hwnd, sel.lnFirst)
        		SetWndSel(hwnd, sel)
                LoadSearchPattern(SearchFor, 0, 0, 0)
        	}
        }
	}
}
	
