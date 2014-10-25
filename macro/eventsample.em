/* Events.em - This file contains example event functions

To show an example of what can be done with events,  the functions in this file 
output events to a textual log file.

The log file is named c:\sitest.log. The name is determined in the function OpenLogBuffer.

For more information, see Readme_Events.txt

***Some Practical Tips***

SI will ignore event handlers in any file that is modified and unsaved. 
Therefore, if you are editing an event handler source file, SI will not try 
to execute the handler while you are editing it!  Once you are done with the 
editing, save the file. SI will once again execute the handlers when the 
file is saved.

If an event handler causes a syntax error or runtime error, then ALL event 
handlers are disabled for the rest of the SI session. You will see a "Macro 
Error" warning message.  To enable event handlers again, simply restart SI.

It is best to put all event handlers in one file, or a small number of files 
with names like "event-something.em".  That way, you can easily remove those
files from the project to effectively turn off the handlers.
*/


// This is called when the application starts
event AppStart()
{
}


// This is called when the application exits
event AppShutdown()
{
	var fname
	var hbuf

	hbuf = OpenLogBuffer()
	fname = GetBufName(hbuf)
	SaveBufAs(hbuf, fname)
}


// This is called when the user issues a command via the keyboard or menus
event AppCommand(sCommand)
{
	AppendToLog("command: " # sCommand)
}


// This is called after the document is opened
event DocumentOpen(sFile)
{
	AppendToLog("opening " # sFile)
}
  
 
// This is called just before the document is closed
event DocumentClose(sFile)
{
	AppendToLog("closing " # sFile)
}


// this is called when the user edits the document
event DocumentChanged(sFile)
{
	AppendToLog("Document Changed: " # sFile)
}
      

// This is called when the user selects text or moves the cursor
// in the given document
event DocumentSelectionChanged(sFile)
{ 
	var hbuf 
	var hwnd
	var ln var sym
	var sel 
	

	// this global counter is used to throttle the event action down
	// to every 5 calls
	global selchange_count
	if (selchange_count == nil) selchange_count = 0;
	if (++selchange_count < 5) stop
	selchange_count = 0;
	
	// note that the sFile may not be open anymore, because this event is
	// called asynchronously.
	hbuf = GetBufHandle(sFile)
	if (hbuf == hNil)
		stop
	
	// get the exact selection details
	hwnd = GetWndHandle(hbuf)
	sel = GetWndSel(hwnd)
	
	
	// determine the function or symbol that contains the selection's first line
	ln = sel.lnFirst
	sym = GetSymbolLocationFromLn(hbuf, ln)
	if (sym == nil)
 		stop
	 
	// if the symbol not the same as last time, then output a message to the log file
	global lastsym
	if (sym.symbol != lastsym)
		{
		AppendToLog("SelChange: symbol: " # sym.symbol # " line: " # ln # " ich: " # sel.ichFirst)
		lastsym = sym.symbol
		}
	
} 


// This is called when a project is opened
event ProjectOpen(sProject) 
{
	AppendToLog("Open project @sProject@")
}


// This is called when a project is about to be closed
event ProjectClose(sProject) 
{
	AppendToLog("Close project @sProject@")
}
 

// This is called whenever the statusbar is changed
event StatusbarUpdate(sMessage)
{
	var hbuf

	// this global counter is used to throttle down the output 
	global statusbar_count
	if (statusbar_count == nil) statusbar_count = 0;
	if (++statusbar_count < 5) stop
	statusbar_count = 0;
	
 	AppendToLog("Statusbar: " # sMessage)
}

 

// Helper function to append a string line to the log file
macro AppendToLog(s)
{
	var hbuf
	var stime
	 
	stime = GetSysTime(true)
	
	hbuf = OpenLogBuffer()
	AppendBufLine(hbuf, stime.month # "/" # stime.day # "/" # stime.year # " " # stime.time # ":  " # s)
}


// Open the log file buffer and return its handle
macro OpenLogBuffer()
{
	var hbufLog
	var sLogFile

	sLogFile = "c:\\sitest.log"
	
	// see if log file buffer is already open
	hbufLog = GetBufHandle(sLogFile)
	if (hbufLog == hNil)
		{
		// try to open existing log file
	 	hbufLog = OpenBuf(sLogFile)
		
		// if existing file doesn't exist, then create new one
		if (hbufLog == hNil)
			hbufLog = NewBuf(sLogFile)
	 	} 

	return hbufLog
}


