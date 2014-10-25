// 
// Converts leading spaces to tabs in C or C++ source lines
//

//
// Converts spaces to tabs based on the number of spaces per tab specified
// in the TabSize registry key
//
// Set HKEY_CURRENT_USER/Software/Source Dynamics/Source Insight/2.0
// TabSize="<tabsize>"
// The default is 4 if none is specified by the registry value record
//
macro tsSpaceToTab()
{
	szTabSize = GetReg("TabSize");

	if (szTabSize != "")
	{
		tabSize = AsciiFromChar(szTabSize[0]) - AsciiFromChar("0");
	}
	else
	{
		tabSize = 4;
	}

	_tsSpaceToTab(tabSize);
}

//
// Sets the TabSize registry key to the value specified by the user.
//
macro tsSetSpaceToTabSize()
{
	spaces = Ask("How many spaces per tab for SpaceToTab converter?");

	SetReg("TabSize", spaces);
}


//
// Converts spaces to tabs based on the number of spaces per tab specified
// by the user.
//
macro _tsAskSpaceToTab()
{
	szTabSize = Ask("How many spaces per tab?");

	if (szTabSize != "" && IsNumber(szTabSize))
	{
		tabSize = AsciiFromChar(szTabSize[0]) - AsciiFromChar("0");
		_tsSpaceToTab(tabSize);
	}
}


//
// Does the work of parsing the C/C++ source lines looking for spaces to convert to tabs.
//
macro _tsSpaceToTab(tabSize)
{
	hbuf = GetCurrentBuf();
	ln = GetBufLineCount(hbuf);

	szTabs = "																														";
	szSpaces = "                ";

	ilnFile = 0;

	StartMsg("Converting spaces to tabs.  Please wait...");
	
	while (iln < ln)
	{
		szLine = GetBufLine(hbuf, iln);
		cchLine = strlen(szLine);

		ichLine = 0;
		col = 0;
		szNewLine = "";
		cchSpaces = 0;
		while (ichLine < cchLine)
		{
			if (szLine[ichLine] == " ")
			{
				cchSpaces = cchSpaces + 1;
				col = col + 1;
			}
			else if (AsciiFromChar(szLine[ichLine]) == 9)
			{
				colPrev = col;
				col = (((col + tabSize) / tabSize) * tabSize);
			}
			else
			{
				if (cchSpaces)
				{
					tabs = col / tabSize;
					spaces = col - (tabs * tabSize);

					if (cchSpaces != spaces)
					{
						if (tabs)
							szNewLine = strmid(szTabs, 0, tabs);

						if (spaces)
							szNewLine = cat(szNewLine, strmid(szSpaces, 0, spaces));
						
						szNewLine = cat(szNewLine, strmid(szLine, ichLine, cchLine));
					}
					else
					{
						cchSpaces = 0;
					}
				}
				break;
			}

			ichLine = ichLine + 1;
		}

		if (cchSpaces)
		{
			PutBufLine(hbuf, iln, szNewLine);
		}
		iln = iln + 1;
	}
	EndMsg();
}


