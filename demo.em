macro VimMode()
{
	hbuf = GetCurrentBuf();
	while(1)
	{
		// Wait for the next key press and return the key code.
		key = GetKey()
		
		// Map the key code into a simple character.
		//
		// If you only need a simple character, you can 
		// call GetChar() instead of GetKey + CharFromKey
		ch = CharFromKey(key)
		
		if (ch == "q")
			stop

		SetBufSelText(hbuf,ch)
		
	}
}

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
	

/* --------------------------------------------------------------
# Module CompleteWord version 0.0.1
# Released to the public domain 14-Aug-1999,
# by Tim Peters (tim_one@email.msn.com).

# Provided as-is; use at your own risk; no warranty; no promises; enjoy!

Word completion.
Macro CompleteWord moves forward.
Macro CompleteWordBack moves backward.
Assign to e.g. F12 and Shift+F12.

The word characters ([a-zA-Z0-9_]) immediately preceding the
cursor are called the "stem".  A "completion" is any full word
that begins with the stem.  Conceptually, all possible
completions are built into a list as follows:

	look backward in the buffer from the stem location,
	and append each completion not seen before

	similarly, look forward in the buffer from the stem
	location for other new completions

	for all other open windows, look forward from the start
	of their buffers for other new completions

CompleteWord then moves forward through this list, and
CompleteWordBack moves backward through it.  If you invoke
CompleteWord when you're already at the end of the list,
a msg pops up telling you so; likewise if you're at the start
of the list and invoke CompleteWordBack.

Each time you move to a new list entry, the stem is completed
and the insertion point is moved to the end of the completion.

Example:

   	Py_BEGIN_ALLOW_THREADS
	errno = 0;
	res = fflush(f->f_fp);
	Py_END_ALLOW_THREADS
	if (res != 0) {
		PyErr_SetFromErrno(PyExc_IOError);
		clearerr(f->f_fp);
		return NULL;
	}
	Py_INCREF(Py_None);
	Py_
    Py_SomethingElse();

Suppose the cursor follows the "Py_" on the penultimate line.
Then CompleteWord will first suggest Py_None, then Py_INCREF,
then Py_END_ALLOW_THREADS, then Py_BEGIN_ALLOW_THREADS, then
Py_SomethingElse, and if you're still unhappy <wink> will go on
to search other windows' buffers.

Notes:

+ This has nothing to do with Source Insight's notion of "symbols".
  To the contrary, the long hairy words I need to type most often
  over & over are local words that SI's Complete_Symbol doesn't
  know about.  It's also the case that the word you most often
  need to type is one you most recently typed, so the macros
  work hard to suggest the closest preceding matches first.
  This flavor of completion also works fine in file types SI knows
  nothing about.

+ The list isn't actually built up at once -- as far as possible,
  it's built incrementally as you continue to invoke CompleteWord.

+ It would help if SI's SearchInBuf could search backwards.  As
  is, finding the first suggestion is done by searching the entire
  buffer forward up until the stem location, and fiddling the
  results to act "as if" things were found in the other order.
  This is clumsy, but worse if you're near the end of a long file
  with many stem matches it can take appreciable time to find the
  "first" match (since it's actually found last ...)..

+ Would be nice to be able to display msgs on the status line;
  e.g., the macros keep track of the file names and line numbers
  at which completions were found, and that's sometimes useful
  info to know (the completion process sometimes turns up
  surprises! then you'd like to know where they came from).
  The list is built into a buffer named "*Completion*", and you
  may want to peek at that.
-------------------------------------------------------------- */

macro CompleteWord()
{
	return CW_guts(1)
}

macro CompleteWordBack()
{
	CW_guts(0)
}

/* BUG ALERT:  there's apparently an undocumented limit on
   string & record vrbl size (about 2**8 chars).  Makes the
   following more convoluted than I'd like, and it will still
   fail in bizarre ways if e.g the stem is "too big".
 */

/* --------------------------------------------------------------
Structure of *Completion* buffer:
	First record summarizes our state:
		.orighbuf	original buffer
		.orighwnd	original window
		.origlno	original line number
		.origi		slice indices of start ...
		.origj		... and end of stem
		.stem		original stem word
		.newj		where we left insertion point
		.index		index into *Completion* of current completion
		.searchwnd	window we're searching now
		.searchlno	next line number to search at
		.searchich  next char index to search at
	Remaining records detail unique completions:
		.file		name of file match found in
		.line		line number within file of match
		.match		the completion
-------------------------------------------------------------- */

/* Selection format
lnFirst		the first line number
ichFirst	the index of the first character on the line lnFirst
lnLast		the last line number
ichLim		the limit index (one past the last) of the last character
			on the line given in lnLast
fExtended	TRUE if the selection is extended to include more than one
            character
        .   FALSE if the selection is a simple insertion point.
Note: this is the same as the following expression:
(sel.fRect || sel.lnFirst != sel.lnLast || sel.ichFirst != sel.ichLim)

fRect		TRUE if selection is rectangular (block style),
FALSE 		if the selection is a linear range of characters.
The following fields only apply if fRect is TRUE:
xLeft		the left pixel position of the rectangle in window coordinates.
xRight		the pixel position of the right edge of the rectangle in
			window coordinates.
*/

/* Completion "word" was found in file "fname" at line "lno".
 * Search hBuf for an exact previous match to "word".  If
 * none found, append a match record to hBuf, and return
 * the match record.  If found and bReplace is false, leave
 * hBuf alone and return "".  Else replace the file & line
 * fields of the matching record, move it to end of the
 * buffer, & return it.
 */
macro CW_addword(word, fname, lno, hBuf, bReplace)
{
    /* SearchInBuf (hbuf, pattern, lnStart, ichStart,
                    fMatchCase, fRegExpr, fWholeWordsOnly)
    */
	foundit = SearchInBuf(hBuf, ";match=\"@word@\"", 1, 0, 1, 0, 0)
	record = ""
	if (foundit == "") {
		record = "file=\"@fname@\";line=\"@lno@\";match=\"@word@\""
	}
	else if (bReplace) {
		record = GetBufLine(hBuf, foundit.lnFirst)
		record.file = fname
		record.line = lno
		DelBufLine(hBuf, foundit.lnFirst)
	}
	if (record != "") {
		AppendBufLine(hBuf, record)
	}
	return record
}

/* Search in hSourceBuf for unique full-word matches to regexp,
 * up through line lastlno, adding match records to hResultBuf.
 * In the end, the match recrods look "as if" we had really
 * searched backward from lastlno, which the closest preceding
 * matches earliest in the list.
 */
macro CW_addallbackwards(regexp, hSourceBuf, hResultBuf, lastlno)
{
	lno = 0
	ich = 0	
	fname = GetBufName(hSourceBuf)
	while (1) {
	    /* SearchInBuf(hbuf, pattern, lnStart, ichStart,
	                   fMatchCase, fRegExpr, fWholeWordsOnly)
	    */
		foundit = SearchInBuf(hSourceBuf, regexp, lno, ich, 1, 1, 1)
		if (foundit == "") {
			break
		}
		lno = foundit.lnFirst
		if (lno > lastlno) {
			break
		}
		ich = foundit.ichLim
		matchline = GetBufLine(hSourceBuf, lno)
		match = strmid(matchline, foundit.ichFirst, ich)
		/* We're forced to search forward, but want the last match
		 * (closest preceding the target), so tell CW_addword to
		 * replace any previous match.
		 */
		CW_addword(match, fname, lno, hResultBuf, 1)
	}
	/* reverse the match order */
	n = GetBufLineCount(hResultBuf) - 1
	i = 1
	while (i < n) {
		r1 = GetBufLine(hResultBuf, i)
		r2 = GetBufLine(hResultBuf, n)
		PutBufLine(hResultBuf, i, r2)
		PutBufLine(hResultBuf, n, r1)
		i = i + 1
		n = n - 1
	}
}

/* The major complication here is that this is essentially an asynch
 * event-driven process:  we don't know what the user has done
 * between invocations, so have to squirrel away and check a lot
 * of state in order to guess whether they're invoking the
 * CompleteWord macros repeatedly.
 */
macro CW_guts(bForward)
{
	hwnd = GetCurrentWnd()
	selection = GetWndSel(hwnd)
	if (selection.fExtended) {
		Msg("Cannot word-complete with active selection")
		stop
	}
	hbuf = GetCurrentBuf()
	hResultBuf = GetOrCreateBuf("*Completion*")

	/* Guess whether we're continuing an old one. */
	newone = 0
	if (GetBufLineCount(hResultBuf) == 0) {
		newone = 1
	}
	else {
		stat = GetBufLine(hResultBuf, 0)
		newone = stat.orighbuf != hbuf ||
				 stat.orighwnd != hwnd ||
				 stat.origlno != selection.lnFirst ||
		         stat.newj != selection.ichFirst
	}

	/* suck up stem word */
	if (newone) {
		j = selection.ichFirst	/* index of char to right of cursor */
	}
	else {
		j = stat.origj
	}
	line = GetBufLine(hbuf, selection.lnFirst)
	i = j - 1				/* index of char to left of cursor */
	while (i >= 0) {
		ch = line[i]
		if (isupper(ch) || islower(ch) || IsNumber(ch) || ch == "_") {
			i = i - 1
		}
		else {
			break
		}
	}
	i = i + 1
	if (i >= j) {
		return false
	}
	/* BUG contra docs, line[j] is not included in the following */
	word = strmid(line, i, j)
	regexp = "@word@[a-zA-Z0-9_]+"


	/* BUG "||" apparently doesn't short-circuit, so
        	if (newone || word != stat.stem)
       doesn't work (if newone, stat isn't defined)
    */
    if (!newone) {
    	/* despite that everything looks the same, they
    	   may have changed the stem! */
    	newone = word != stat.stem
    }
    if (newone) {
		stat = ""
		stat.orighbuf = hbuf
		stat.orighwnd = hwnd
		stat.origlno  = selection.lnFirst
		stat.origi    = i
		stat.origj    = j
		stat.stem     = word
		stat.newj     = j
		stat.index    = 0
		stat.searchwnd = hwnd
		stat.searchlno = selection.lnFirst
		stat.searchich = j
		ClearBuf(hResultBuf)
		AppendBufLine(hResultBuf, stat)
		CW_addallbackwards(regexp, hbuf, hResultBuf, stat.origlno)
		if (GetBufLineCount(hResultBuf) >= 2) {
			/* found at least one completion in this buffer,
			   so display the first */
			CW_completeindex(hResultBuf, 1)
			return true
		}
	}

	/* continuing an old one, or a new one w/o backward match */
	n = GetBufLineCount(hResultBuf)
	i = stat.index
	if (!bForward) {
		if (i > 1) {
			CW_completeindex(hResultBuf, i - 1)
		}
		else {
			CW_completeword(hResultBuf, word, 0)
			Msg("move forward for completions")
		}
		return true
	}

	/* moving forward */
	if (i < n-1) {
		CW_completeindex(hResultBuf, i + 1)
		return true
	}

	if (i == n) {
		Msg("move back for completions")
		return
	}

	/* i == n-1: we're at the last one; look for another completion */
	while (1) {
		stat = GetBufLine(hResultBuf, 0)
		hwnd = stat.searchwnd
		lno	= stat.searchlno
		ich = stat.searchich
		hbuf = GetWndBuf(hwnd)
	    /* SearchInBuf(hbuf, pattern, lnStart, ichStart,
	                   fMatchCase, fRegExpr, fWholeWordsOnly)
	    */
	    if (hBuf == hResultBuf) {
	    	/* no point searching our own result list! */
	    	foundit = ""
	    }
	    else {
			foundit = SearchInBuf(hbuf, regexp, lno, ich, 1, 1, 1)
		}
		if (foundit == "") {
			hwnd = GetNextWnd(hwnd)
			if (hwnd == 0 || hwnd == stat.orighwnd) {
				n = GetBufLineCount(hResultBuf)
				if (n == 1) {
					Msg("No completions for @word@")
				}
				else {
					CW_completeword(hResultBuf, word, n)
					Msg("No more completions for @word@")
				}
				break
			}
			stat.searchwnd = hwnd
			stat.searchlno = 0
			stat.searchich = 0
			PutBufLine(hResultBuf, 0, stat)
			continue
		}
		lno = foundit.lnFirst
		ich = foundit.ichLim
		stat.searchlno = lno
		stat.searchich = ich
		PutBufLine(hResultBuf, 0, stat)
		matchline = GetBufLine(hbuf, lno)
		match = strmid(matchline, foundit.ichFirst, ich)
		result = CW_addword(match, GetBufName(hbuf), lno, hResultBuf, 0)
		if (result != "") {
			CW_completeindex(hResultBuf, GetBufLineCount(hResultBuf) - 1)
			break
	 	}
	}
}

/* Replace the stem with the completion at index i */
macro CW_completeindex(hBuf, i)
{
	record = GetBufLine(hBuf, i)
	CW_completeword(hBuf, record.match, i)
}

/* Replace the stem with the given completion */
macro CW_completeword(hBuf, completion, i)
{
	stat = GetBufLine(hBuf, 0)
	targetBuf = stat.orighbuf
	oldline = GetBufLine(targetBuf, stat.origlno)
	newline = cat(strmid(oldline, 0, stat.origi), completion)
	newj = strlen(newline)
	newline = cat(newline, strmid(oldline, stat.newj, strlen(oldline)))
	PutBufLine(targetBuf, stat.origlno, newline)
	SetBufIns(targetBuf, stat.origlno, newj)
	stat.newj = newj
	stat.index = i
	PutBufLine(hBuf, 0, stat)
}

/* Get handle of buffer with name "name", or create a new one
 * if no such buffer exists.
 */
macro GetOrCreateBuf(name)
{
	hBuf = GetBufHandle(name)
	if (hBuf == 0) {
		hBuf = NewBuf(name)
	}
	return hBuf
}

