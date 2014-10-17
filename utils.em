/* Utils.em - a small collection of useful editing macros */



/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function. 
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)
	
	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "
	
	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}
	
	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2
	
	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")
	
	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function. 
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)
	
	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2
	
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}
macro blame()
{
  filename = GetBufName (GetCurrentBuf ())
  path = strmid(filename,0,getFileName(filename));
  cmdline = cat(cat("cmd /C \"TortoiseProc.exe /command:blame /path:\"",filename),"\"\"")
  RunCmdLine (cmdline, path, 0);
}

macro diff()
{

  filename = GetBufName (GetCurrentBuf ())
  path = strmid(filename,0,getFileName(filename));
  cmdline = cat(cat("cmd /C \"TortoiseProc.exe /command:diff /path:\"",filename),"\"\"")
  //cmdline = cat(cat("TortoiseProc.exe /command:diff /path:\"",filename),"\"")
  RunCmdLine (cmdline, path, 0);

}

macro log()
{
  filename = GetBufName (GetCurrentBuf ())

  path = strmid(filename,0,getFileName(filename));
  cmdline = cat(cat("cmd /C \"TortoiseProc.exe /command:log /path:\"",filename),"\"\"")
  //cmdline = cat(cat("TortoiseProc.exe /command:diff /path:\"",filename),"\"")
  RunCmdLine (cmdline, path, 0);
}

macro explorer()
{
  filename = GetBufName (GetCurrentBuf ())
  path = strmid(filename,0,getFileName(filename));
  cmdline = cat(cat("explorer /select,\"",filename),"\"");
  RunCmdLine (cmdline, path, 0);
}


macro getFileName(str)
{//碌鹿脨貌虏茅脮脪"\"
  pos = strlen(str) - 1;
  while(pos >= 0)
  { 
    if(strmid (str,pos, pos+1) == "\\")
      return pos;
    pos = pos - 1;
  }
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}

	
// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and 
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}
	
	hbufOutput = NewBuf("Results")
	
	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}
		
	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)
	
	return hbufOutput

}

macro checkEnv()
{
		//版本判断,3.5056以下程序不支持
		ProVer = GetProgramInfo ();
		if(ProVer.versionMinor < 50 || ProVer.versionBuild < 56)
		{
			Msg("您的Source Insight版本太低，如需使用此工具，请安装3.50.0060及以上版。");
			stop
		}
		
		initGlobal();//初始化全局变量
		
		hProj = GetCurrentProj ();
		dir_proj = GetProjDir (hProj);

		//寻找代码目录
		depend_file = cat(dir_proj, "\\Build\\depend");
		
		//depend文件不存在,说明代码和source insight工程不在一个文件夹，则询问
		if(0 == ifExist(depend_file) )
		{	
			dir_proj = searchDir();
		}
		
		if(-1 == dir_proj )
		{
			dir_proj = Ask("请输入当前工程的代码目录，如'D:\\Code\\P_2011.05.04_XQ_2.608'，最后无斜杠。");
		}

		//根据宏名列表文件,清除已经存在的环境变量
		con_file = cat(dir_proj, "\\clsList");
		clearCondition(hProj,con_file);
		//syncProj (hProj);
		Msg("当前已清理已有的宏，恢复了默认状态。要继续设置环境，请点击确定；如果您想恢复默认，请点取消或者右上角的'X'按钮。");		
		
		//向depend文件写入命令		
		depend_file = cat(dir_proj, "\\Build\\depend");
		cmd_count = writeDependFile(depend_file)
		
		//向depend_ti文件写入命令
		depend_file = cat(dir_proj, "\\Build\\depend_ti");
		writeDependFile(depend_file)

		modiFile();
		
		Msg("请先编译您的工程，编译完后再按确定!");

		//向工程添加环境变量
		con_file = cat(dir_proj, "\\define");
		addCondition(hProj,con_file);

		//从depend文件中清除linux命令
		depend_file = cat(dir_proj, "\\Build\\depend");
		ln = lineOfFile(depend_file, GetEnv("cmd_str0"));
		deleteCommand(depend_file, ln, cmd_count);

		depend_file = cat(dir_proj, "\\Build\\depend_ti");
		ln = lineOfFile(depend_file, GetEnv("cmd_str0"));
		deleteCommand(depend_file, ln, cmd_count);

		con_file = cat(dir_proj, "\\define");
		if(0 != ifExist(con_file))
		{
			//syncProj (hProj);
						
			Msg("环境变量已经设定。");			
		}
		else
		{
			Msg("您是否未编译、或者代码路径有误、又或者没有编译时__make:Nothing to be done for 'all'?如果是，请更改文件后重新操作。");
		}
		
		//清理中间文件,避免对下次产生干扰,但保留clsList，用于清理环境变量			
		com_str = cat("cmd /C \"del ",cat(dir_proj, "\\clsList\""));
		RunCmdLine (com_str, dir_proj, 1);		
		
		com_str = cat("cmd /C \"ren ",cat(dir_proj, "\\define clsList\""));
		RunCmdLine (com_str, dir_proj, 1);
}

//取行的名称,例如取"version=2.6"中的"version",如果不含等号，则返回原字符串。
macro nameOf(str)
{
	pos=0;
	while(pos<strlen (str))
	{
		if(strmid (str,pos, pos+1) == "=")
			break;
		pos = pos + 1;
	}
	return strmid (str,0,pos);
}

//取等式的值,例如取"version=2.6"中的"2.6"，如果不含等号，则返回"0"
macro valueOf(str)
{
	pos=0;
	while(pos<strlen (str))
	{
		if(strmid (str,pos, pos+1) == "=")
			break;
		pos = pos + 1;
	}

	if(strlen(str) == pos)
		return "0";
	else
		return strmid (str,pos+1,strlen (str));
}

//判断文件是否存在,0代表不存在,1代表存在
macro ifExist(file)
{
	hbuf = OpenBuf(file);
	if(0 == hbuf )
	{
		return 0;
	}
	else
	{
		CloseBuf(hbuf);
		return 1;
	}
}

//返回特定内容在文件中的行序号
macro lineOfFile(file, str)
{
	if(0 == ifExist(file))
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf (file);
		ln_cnt = GetBufLineCount(hbuf);
		ln = 0;	
		while(ln<ln_cnt)
		{
			if(str == GetBufLine (hbuf, ln))
				return ln;
				
			ln = ln + 1;
		}
		CloseBuf (hbuf);		
		return 0;

	}
}

//把要写进depend文件的命令写入系统的环境变量里，
//当做全局变量使用,便于以后更改程序
macro initGlobal()
{
	PutEnv("cmd_count", "10");//需要插入的命令行数
	
	putEnv("cmd_str0","\t-\@echo Collecting condition variables......");
	
	putEnv("cmd_str1","\t-\@find ../../ -name *.cpp -exec grep -E '#endif|#ifdef|(\\s+|\\t+)defined|#elif' {} \\; > ../../tmp ;cat ../../tmp|sed -r '/\\//d'|sed -r 's/\\|\\||&&/\\n/g' >../../tmp_0");
	putEnv("cmd_str2","\t-\@cat ../../tmp_0|sed -r 's/#endif|#elif|#ifdef|#if\\s|defined//g'|sed -r 's/\\\\|!|\\(|\\)//g'|sed -r '/\\/|=|>|<|^\\s*$$$//d'|sed -r 's/\\s*|\\t*//g'|sort|uniq > ../../tmp0");
	
	putEnv("cmd_str3","\t-\@cat ../../tmp|grep -E -o '.*\\/\\/'|sed -r 's/\\/\\///g'|sed -r 's/\\|\\||&&/\\n/g'|sed -r 's/#endif|#elif|#ifdef|#if\\s|defined//g'|sed -r 's/!|\\(|\\)//g' >../../tmp_0");
	putEnv("cmd_str4","\t-\@cat ../../tmp_0|sed -r '/\\/|=|>|<|^\\s*$$$//d'|sed -r 's/\\s*|\\t*//g'|sort|uniq >> ../../tmp0;cat ../../tmp0|sed -r '/^\s*[0-9]*\s*$$$//d'|sed -r '/^\\s*[0-9]+\\s*$$$//d'|sort|uniq >../../defined.all");
	
	putEnv("cmd_str5","\t-\@echo $(CFLAGS)|grep -E -o '\\-D.*'|sed -r 's/(-D|-U)/\\n/g'|sed -r 's/\\s*=\\s*1//g'|sed -r 's/\\\"//g' >../../tmpp1;echo $(CFLAGS)|grep -E '\\-U[^ ]+' -o|sed -r 's/-U//g'>../../defined.undef;grep -v -f ../../defined.undef ../../tmpp1 >../../tmp1;");
	putEnv("cmd_str6","\t-\@cat ../../tmp1|sed -r '/=|^\\s*$$$//d'|sed -r 's/\\s*|\\t*//g'|sed -r 's/(.*)/^\\1$$$//'|sort|uniq >../../defined.noequal");
	putEnv("cmd_str7","\t-\@cat ../../tmp1|sed -r '/^\\s*$$$//d'|grep -E '='|sed -r 's/\\s*|\\t*//g'|sort|uniq >../../defined.equal");
	
	putEnv("cmd_str8","\t-\@grep -v -f ../../defined.noequal  ../../defined.all|sed -r 's/(.*)/\\1=0/' > ../../define;cat ../../defined.noequal|sed -r 's/\\^//'|sed -r 's/\\$$$//=1/' >> ../../define;cat ../../defined.equal >> ../../define");
	
	putEnv("cmd_str9","\t-\@rm ../../tmp* ../../defined.*");
	
}

//向文件的ln行写入命令,参数是已打开文件的句柄，返回插入命令的行数
macro writeCommand(file, ln)
{
	cmdLnCnt = GetEnv("cmd_count");// 10;

	if(0 == file && ln == 0)
	{
		return 
	}
	else if(0 == ifExist(file))
	{
		return cmdLnCnt;
	}
	else
	{
		hbuf = OpenBuf (file);

		i = cmdLnCnt - 1;
		while(i >= 0)
		{
			InsBufLine (hbuf, ln, GetEnv(cat("cmd_str",i)));
			i = i - 1;
		}
		
		SaveBuf (hbuf);	
		CloseBuf (hbuf);

		return cmdLnCnt;
	}
}

//从文件中删除行,包括ln所在行以及之后的count行,返回删除掉的行数
macro deleteCommand(file,ln,count)
{
	if(0 == ifExist(file) || ln == 0)
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf(file);
		if(ln + count< GetBufLineCount(hbuf))
		{
			i = count - 1;
			while(i >= 0)
			{
				DelBufLine (hbuf, ln + i);
				i = i - 1;
			}	
			SaveBuf (hbuf);	
		}
		
		CloseBuf(hbuf);
		return count;
	}
}

//向depend文件写入linux命令(用于提取宏以及处理),返回插入命令的行数
macro writeDependFile(depend_file)
{
	str = GetEnv("cmd_str0");//标志内容
	ln = lineOfFile(depend_file,str);

	if(0 == ln)//文件中无命令
	{	
		str = "\t$(AR) crus $\@ $(OBJS)";//生成libapp.a的工程的标志行
		ln_lib = lineOfFile(depend_file,str);
		if(0 != ln_lib)//如果是生成libapp.a的工程
		{
			return writeCommand(depend_file,ln_lib + 1);
		}
		else
		{
			str = "\t\@echo $(CFLAGS)";//Challenge的工程的标志行
			ln_ch = lineOfFile(depend_file,str);

			return writeCommand(depend_file,ln_ch + 1);
		}		
	}
	else
	{	//当参数为0，0时，writeCommand不处理文件，仅返回插入命令的行数，
		//这么做是为解耦，避免这里返回文件中已经插入的命令的行数，
		//checkEnv依此来恢复depend文件
		return 9;//writeCommand(0, 0);
	}
}

//根据file的内容，向hProj添加环境变量
macro addCondition(hProj, file)
{	
	if(0 == ifExist(file))
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf(file);
		
		ln_cnt = GetBufLineCount(hbuf);
		ln = 0;
		while(ln<ln_cnt)
		{
			str = GetBufLine(hbuf, ln);
			
			if(str != " ")	
				AddConditionVariable(hProj ,nameOf(str), valueOf(str));
				
			ln = ln + 1;
		}
		
		CloseBuf (hbuf);
		return ln;
	}
}

//清除工程内，file文件指定的环境变量,返回删除掉的变量数
macro clearCondition(hProj,file)
{
	if(0 == ifExist(file))
	{
		return 0;
	}
	else
	{
		hbuf = OpenBuf(file);
		ln_cnt = GetBufLineCount (hbuf);
		ln = 0;
		while(ln<ln_cnt)
		{
			str = GetBufLine(hbuf, ln);
			DeleteConditionVariable(hProj ,nameOf(str));
			ln = ln + 1;
		}
		
		CloseBuf (hbuf);
		return ln;
	}
}

//避免自己输入代码路径
macro searchDir()
{
	hbuf = GetCurrentBuf ();
	dir_str = GetBufName (hbuf);
	pos = strlen(dir_str) - 1;
	while(pos > 0)
	{
		while(pos > 0)
		{
			if(strmid (dir_str, pos, pos + 1) == "\\")
				break;
			pos = pos - 1;
		}
		if(ifExist(cat(strmid(dir_str, 0, pos ),"\\Build\\depend")))
			break;
		pos = pos - 1;
	}
	if(pos > 0)
		return strmid(dir_str, 0, pos );
	else
		return -1;
}
//避免make:nothing to been done for all;的情况
macro modiFile()
{
	hbuf = GetCurrentBuf ();
	ln_cnt = GetBufLineCount (hbuf);

	if(GetBufLine (hbuf, ln_cnt - 1) == "  ")
		DelBufLine (hbuf, ln_cnt - 1);
	else
		AppendBufLine (hbuf, "  ");

	SaveBuf (hbuf);
}