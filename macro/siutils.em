// Indents a line if the selection is extended or covers an entire line.
// Otherwise we inserts a normal tab if the selection is just an insertion point.
macro TabOrIndent()
{
	hwnd = GetCurrentWnd()
	if (hwnd != 0)
	{
		sel = GetWndSel(hwnd)
		
		if (sel.fExtended && sel.lnFirst != sel.lnLast )
			Indent_Right
		else
		{
		    // Figure out if the entire line is selected
		    // This is slow so try it second
            buff = GetCurrentBuf()
            cur_line = GetBufLine( buff, sel.lnFirst )
            len = strlen( cur_line )

            if( (sel.ichLim - sel.ichFirst) > len )
                Indent_Right
            else
                Tab
		}
	}
}

// Used to override shift-tab
macro BackTabOrUnIndent()
{
    Indent_Left
}

// Adds C++ style comments to the selected block of code (or current line).
// If the line already starts with a comment then we do nothing for that line.
macro CommentBlock()
{
	hwnd = GetCurrentWnd()
	buff = GetCurrentBuf()
	hit = 0
	
    if (hwnd != 0 && buff != 0 )
	{
		sel = GetWndSel(hwnd)

        ln = sel.lnFirst
        while( ln <= sel.lnLast )
        {
	        cur_line = GetBufLine( buff, ln )

            // SkipWS lives in StringUtils
            start = SkipWS( cur_line, 0 )
            len = strlen( cur_line )
            
            if( start == "X" || (len - start) < 2 )
            {
                cur_line = cat( "//", cur_line )
                DelBufLine( buff, ln )
                InsBufLine( buff, ln, cur_line )
                hit = 1
            }
            else
            {
                // Short-circuits don't exist
                if( cur_line[start] != "/" || cur_line[start+1] != "/" )
                {
                    cur_line = cat( "//", cur_line )
                    DelBufLine( buff, ln )
                    InsBufLine( buff, ln, cur_line )
                    hit = 1
                }
            }
            
	        ln = ln + 1
	    }

	    // Not perfect, but this work most of the time
	    if( hit == 1 )
	    {
            sel.ichFirst = sel.ichFirst + 2
            sel.ichLim = sel.ichLim + 2
        }
        
		SetWndSel(hwnd, sel)
    }
}

// Removes C++ style comments to the selected block of code (or current line).
// If the line does not start with a comment then we do nothing for that line.
macro UncommentBlock()
{
	hwnd = GetCurrentWnd()
	buff = GetCurrentBuf()
	hit = 0
	
    if (hwnd != 0 && buff != 0 )
	{
		sel = GetWndSel(hwnd)

        ln = sel.lnFirst
        while( ln <= sel.lnLast )
        {
	        cur_line = GetBufLine( buff, ln )
	        
            // SkipWS lives in StringUtils
            start = SkipWS( cur_line, 0 )
            len = strlen( cur_line )
            
            if( start != "X" && (len - start) >= 2 )
            {
                // Short-circuits don't exist
                if( cur_line[start] == "/" && cur_line[start+1] == "/" )
                {
                    start_line = strmid( cur_line, 0, start )
                    end_line = strmid( cur_line, start + 2, len )
                    new_line = cat( start_line, end_line )
                
                    DelBufLine( buff, ln )
                    InsBufLine( buff, ln, new_line )
                    hit = 1
                }
            }
           
	        ln = ln + 1
	    }

	    // Not perfect, but this work most of the time
	    if( hit == 1 )
	    {
            sel.ichFirst = sel.ichFirst - 2
            sel.ichLim = sel.ichLim - 2
        }
        
		SetWndSel(hwnd, sel)
    }
}

// Counts the number of selected characters including CR/LF (each counts as 1)
macro CountChars()
{
	hwnd = GetCurrentWnd()
	buff = GetCurrentBuf()
    if (hwnd != 0 && buff != 0 )
	{
		sel = GetWndSel(hwnd)

        count = 0
        if( sel.fExtended )
        {
            sel = NormSel( buff, sel )
            
            ln = sel.lnFirst

            while( ln <= sel.lnLast )
            {
                cTotal = GetBufLineLength(buff, ln)
                cSel = cTotal
            
                if( ln == sel.lnFirst )
                {
                    cSel = cSel - sel.ichFirst 
                }
                if( ln == sel.lnLast )
                {
                    cSel = cSel - (cTotal - sel.ichLim)
                }

                count = count + cSel
                ln = ln + 1
            }
        }

        // SI does not count <CR><LF>
        count = count + (sel.lnLast - sel.lnFirst)
        Msg( count )
	}
}


// Finds matching scoping delimiters and jumps to them.
// If the cursor is not positioned on a delimiter but is inside 
// a matching part the macro will jump to the start of the closest
// scope. Currently matches [],(),<>,{}
macro MatchDelim2()
{
	hwnd = GetCurrentWnd()
	buff = GetCurrentBuf()
    if (hwnd != 0 && buff != 0 )
	{
		sel = GetWndSel(hwnd)
        cur_line = GetBufLine( buff, sel.lnFirst )
        cur_char = cur_line[sel.ichFirst]
        match_sel = 0

        
		if( IsLeftDelim( cur_line, sel.ichFirst ) )
            match_sel = MatchLeftDelim( cur_char, buff, sel, hwnd )
		else if( IsRightDelim( cur_line, sel.ichFirst ) )
  		    match_sel = MatchRightDelim( cur_char, buff, sel, hwnd )
		else
            match_sel = FindFirstLeftDelim(buff, sel, hwnd )

		if( match_sel )
		{
    	    match_sel.lnLast = match_sel.lnFirst
    	    match_sel.ichLim = match_sel.ichFirst
		    SetWndSel( hwnd, match_sel )

		    // If the new selection is not visible scroll to it
            // This causes SI to jump around even when already visible so skip it
//		    ScrollWndToLine( hwnd, match_sel.lnFirst )
		}
	}
}


macro MatchLeftDelim( left_delim, buff, sel, hwnd )
{
    // Special case paren because the built in stuff is much faster
    if( cur_char == "(" )
    {
        Paren_Right
		return GetWndSel(hwnd)
    }
    
    right_delim = GetRightDelim( left_delim )
    nest = 1
    
    cur_line = sel.lnFirst
    cur_pos = sel.ichFirst + 1
    
    buff_lines = GetBufLineCount(buff) 
    while( cur_line < buff_lines )
    {
        line = GetBufLine( buff, cur_line )
        line_len = GetBufLineLength( buff, cur_line )
        while( cur_pos < line_len )
        {
            if( line[cur_pos] == left_delim )
                nest = nest + 1
            else if( line[cur_pos] == right_delim )
            {
                nest = nest - 1
                if( nest == 0 )
                {
                    sel.lnFirst = cur_line
                    sel.ichFirst = cur_pos
                    return sel
                }
            }

            cur_pos = cur_pos + 1
        }

        cur_line = cur_line + 1
        cur_pos = 0;
    }

    return 0
}

macro MatchRightDelim( right_delim, buff, sel, hwnd )
{
    // Special case paren because the built in stuff is much faster
    if( cur_char == ")" )
    {
        Paren_Left
		return GetWndSel(hwnd)
    }
            
    left_delim = GetLeftDelim( right_delim )
    nest = 1
    
    cur_line = sel.lnFirst
    cur_pos = sel.ichFirst - 1
    
    while( cur_line >= 0 )
    {
        line = GetBufLine( buff, cur_line )
        while( cur_pos >= 0 )
        {
            if( line[cur_pos] == right_delim )
                nest = nest + 1
            else if( line[cur_pos] == left_delim )
            {
                nest = nest - 1
                if( nest == 0 )
                {
                    sel.lnFirst = cur_line
                    sel.ichFirst = cur_pos
                    return sel
                }
            }

            cur_pos = cur_pos - 1
        }

        cur_line = cur_line - 1
        if( cur_line >= 0 )
            cur_pos = GetBufLineLength( buff, cur_line )
    }

    return 0
}

macro FindFirstLeftDelim( buff, sel, hwnd )
{
    while( sel.lnFirst >= 0 )
    {
        line = GetBufLine( buff, sel.lnFirst )
        while( sel.ichFirst >= 0 )
        {
            if( IsRightDelim( line, sel.ichFirst ) )
            {
                jump_sel = MatchRightDelim( line[sel.ichFirst], buff, sel, hwnd )
                if( jump_sel )
                {
                    sel = jump_sel
                    line = GetBufLine( buff, sel.lnFirst )
                }
            }
            else if( IsLeftDelim( line, sel.ichFirst) )
            {
                return sel
            }

            sel.ichFirst = sel.ichFirst - 1
        }

        sel.lnFirst = sel.lnFirst - 1
        if( sel.lnFirst >= 0 )
            sel.ichFirst = GetBufLineLength( buff, sel.lnFirst )
    }

    return 0
}


macro IsLeftDelim( line, pos )
{
    if( line[pos] == "(" ||
        line[pos] == "{" ||
        line[pos] == "[" ||
        line[pos] == "<"    )
        return 1
    else
        return 0
}

macro IsRightDelim( line, pos )
{
    back_pos = 0
    if( pos > 0 )
        back_pos = pos - 1

    if( line[pos] == ")" ||
        line[pos] == "}" ||
        line[pos] == "]" ||
        // The account for C-style pointer->member
        (line[pos] == ">" && (pos == 0 || line[back_pos] != "-")   )
        return 1
    else
        return 0
}

macro GetRightDelim( left_delim )
{
    if( left_delim == "(" )
        return ")"
    else if( left_delim == "{" )
        return  "}"
    else if( left_delim == "[" )
        return  "]"
    else if( left_delim == "<" )
        return  ">"
    else
        return "-"
}

macro GetLeftDelim( right_delim )
{
    if( right_delim == ")" )
        return "("
    else if( right_delim == "}" )
        return  "{"
    else if( right_delim == "]" )
        return  "["
    else if( right_delim == ">" )
        return  "<"
    else
        return "-"
}


// SI does not include \n in buffer
macro NormSel(hbuf, sel)
{
	if (sel.ichLim >= GetBufLineLength(hbuf, sel.lnLast))
	{
		sel.lnLast = sel.lnLast + 1
		sel.ichLim = 0
    }

	return sel
}


