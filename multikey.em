/* 
	This is an example macro that can be used to create a 
	secondary key mapping which maps keys after an initial
	key press.

	For example, the user presses Ctrl+K, followed by "d" 
	to run the "Cut Line" command.
	
	This example assumed Ctrl+K, but you can use whatever key
	combination you want.
	
	Instructions:

	1. Add this macro to a .EM file and add it to 
	   your project.
	
	2. Use the Key Assignments command to map this macro 
	   to Ctrl+K.  The macro name "CtrlK" will show up in the list
	   of commands.

	3. Now you can type Ctrl+K, followed by another key
	   to invoke either "Cut Line" or "Paste Line".  These
	   two commands were picked by random.  You could add
	   what ever key combinations and commands you want.
*/

macro CtrlK()
{
	// Wait for the next key press and return the key code.
	key = GetKey()
	
	// Map the key code into a simple character.
	//
	// If you only need a simple character, you can 
	// call GetChar() instead of GetKey + CharFromKey
	ch = CharFromKey(key)

	ch = ToUpper(ch)
	
	if (ch == "D")
		{
		// Ctrl+K, followed by Ctrl+D
		if (IsCtrlKeyDown(key))
			// run the "Paste Line" command
			Paste_Line
		
		// Ctrl+K, followed by "D"
		else
			// run the "Cut Line" command
			Cut_Line
		
		
		// Note: you can also use IsAltKeyDown and
		// IsFuncKey to further discriminate keys.
		
		}
}

