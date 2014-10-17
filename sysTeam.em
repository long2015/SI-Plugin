macro AutoExpand()
{
    hwnd = GetCurrentWnd()/*return the handle of the active,front-most source file window*/
    if (hwnd == 0)
        stop
        
    sel = GetWndSel(hwnd)/*return the selection state of the window specified by hwnd*/
    if (sel.ichFirst == 0)
        stop
        
    hbuf = GetWndBuf(hwnd)

    nVer = 0
    nVer = GetVersion()
    
    szLine = GetBufLine(hbuf, sel.lnFirst);// get line the selection (insertion point) is on

    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine) // parse word just to the left of the insertion point

    ln = sel.lnFirst;
    chTab = CharFromAscii(9)
        
    // prepare a new indented blank line to be inserted.
    // keep white space on left and add a tab to indent.
    // this preserves the indentation level.
    chSpace = CharFromAscii(32);
    ich = 0
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine,0,ich)
    szLine = strmid(szLine, 0, ich) # "    "
    
    sel.lnFirst = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim = wordinfo.ich

    /*自动完成简化命令的匹配显示*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    
    ExpandProcCN(wordinfo,szLine,szLine1,nVer,ln,sel)

}

macro ExpandProcCN(wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    if (szCmd == "/*")
    {   
	    SetBufSelText(hbuf, " */")
        SetBufIns (hbuf, ln, strlen(szLine)-1)
    	
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "#in") //#include ""
    {
        PutBufLine(hbuf, ln, szLine1 # "#include \"\"")
        SetBufIns (hbuf, ln, strlen(szLine1)+10)
        return
    }

    else if (szCmd == "#is") //#include <>
    {
	    PutBufLine(hbuf, ln, szLine1 # "#include <>")
        SetBufIns (hbuf, ln, strlen(szLine1)+10)
        return
    }
    else if (szCmd == "#if") //#ifdef
    {
        SetBufSelText(hbuf, " ")
        InsBufLine(hbuf, ln + 1, "#endif")
        return
    }
    else if (szCmd == "#ifd") //#ifdef
    {
        SetBufSelText(hbuf, "ef ")
        InsBufLine(hbuf, ln + 1, "#endif")
        return
    }
    else if (szCmd == "#ifn") //#ifdef
    {
        SetBufSelText(hbuf, "def ")
        InsBufLine(hbuf, ln + 1, "#endif")
        return
    }  
    else if (szCmd == "#ife") //#ifdef
    {
    	oldLn = ln;
	    DelBufLine(hbuf, ln)
	    InsBufLine(hbuf, ln ++, "#if ")
	    InsBufLine(hbuf, ln ++, "")
        InsBufLine(hbuf, ln ++, "#else")
        InsBufLine(hbuf, ln ++, "")
        InsBufLine(hbuf, ln ++, "#endif")
        SetBufIns (hbuf, oldLn, 4)
        return
    }        
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln, strlen(szLine))
    }
    else if( szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln, strlen(szLine)+5)
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        SetBufIns (hbuf, ln, strlen(szLine))
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ()");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" );
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
        SetBufIns (hbuf, ln, strlen(szLine))
    }
    else if (szCmd == "for")
    {
	    szVar = ask("请输入循环变量")
        PutBufLine(hbuf, ln, szLine1 # "for ( @szVar@ = 0 ; @szVar@ < ; @szVar@++ )");
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetBufIns (hbuf, ln, strlen(szLine1)+ strlen(szVar) * 2 + 16)        
    }
    else if (szCmd == "fori")
    {
	    szVar = i;
	    PutBufLine(hbuf, ln, szLine1 # "for ( @szVar@ = 0 ; @szVar@ < ; @szVar@++ )");
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetBufIns (hbuf, ln, strlen(szLine1) + 18)        
    }
    else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("请输入case的个数")
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }    
    else if (szCmd == "case" || szCmd == "ca" )
    {
        SetBufSelText(hbuf, " :")
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
        SetBufIns (hbuf, ln, strlen(szLine) + 1);
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ()")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln, strlen(szLine)+3)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ();")
        SetBufIns (hbuf, ln + 3, strlen(szLine) + 5)
    }
    else if (szCmd == "st")
    {
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@struct ");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@};");
        SetBufIns (hbuf, ln, strlen(szLine)+5)
        return
    }
    else if (szCmd == "tst")
    {
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@typedef struct");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@};");
        SetBufIns (hbuf, ln + 3, strlen(szLine)-3)
        return
    }
    else if (szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@enum ");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        InsBufLine(hbuf, ln + 3, "@szLine1@};");
        SetBufIns (hbuf, ln, strlen(szLine)+4)
        return
    }
    else if (szCmd == "ten")
    {
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@typedef enum");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        InsBufLine(hbuf, ln + 3, "@szLine1@};");
        SetBufIns (hbuf, ln + 3, strlen(szLine)-3)
        return
    }
    else if (szCmd == "file" || szCmd == "fi" )
    {
        DelBufLine(hbuf, ln)
        /*生成文件头说明*/
        InsertFileHeaderCN( hbuf,0)
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*生成C语言的头文件*/
		InsertCPP(hbuf,0);

		//插入文件头说明
		InsertFileHeaderCN(hbuf,0);
		
        return
    }
    else if (szCmd == "func"|| szCmd == "fun" || szCmd == "fu"  || szCmd == "f")
    {       
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*对于2.1版的si如果是非法symbol就会中断执行，故该为以后一行
              是否有‘（’来判断是否是新函数*/
            if( (strstr(szNextLine,"(") != -1) || (nVer != 2))
            {            	
                /*是已经存在的函数*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                	DelBufLine(hbuf,ln)
                    FuncHeadCommentCN(hbuf, ln, symbol,0)
                    return
                }
            }
        }
    }
    //OSA 的快速输入
    else if (szCmd == "info" ||szCmd == "inf" 
	    || szCmd == "INFO" ||szCmd == "INF")
    {
        PutBufLine(hbuf, ln, szLine1 # "OSA_INFO(\"\\n\");")
        SetBufIns (hbuf, ln, strlen(szLine1)+10)
        return
    }
    else if (szCmd == "ERR" ||szCmd == "ER" 
	    || szCmd == "err" ||szCmd == "er")
    {
        PutBufLine(hbuf, ln, szLine1 # "OSA_ERROR(\"\\n\");")
        SetBufIns (hbuf, ln, strlen(szLine1)+11)
        return
    }
    else if (szCmd == "WA" ||szCmd == "wa" 
	    ||szCmd == "WAR" ||szCmd == "war" 	    
	    || szCmd == "WARN" ||szCmd == "warn")
    {
        PutBufLine(hbuf, ln, szLine1 # "OSA_WARN(\"\\n\");")
        SetBufIns (hbuf, ln, strlen(szLine1)+10)
        return
    }
    else if (szCmd == "isF" || szCmd == "isf")
    {
    	oldLn = ln;
	    PutBufLine(hbuf, ln++, szLine1 # "if(OSA_isFail(status))");
        InsBufLine(hbuf, ln++, "@szLine1@{")
        InsBufLine(hbuf, ln++, "@szLine1@    OSA_ERROR(\"\\\n\");")
        InsBufLine(hbuf, ln++, "@szLine1@    return OSA_EFAIL;")
        InsBufLine(hbuf, ln++, "@szLine1@}")
        SetBufIns (hbuf, oldLn+2, strlen(szLine)+11)        
    }
    else if (szCmd == "alloc")
    {
    	oldLn = ln;
        szVar = ask("请输入内存分配指针名")
        PutBufLine(hbuf, ln++, szLine1 # "@szVar@ = OSA_memAlloc(sizeof(*@szVar@))");
        InsBufLine(hbuf, ln++, "@szLine1@if(OSA_isNull(@szVar@))")
        InsBufLine(hbuf, ln++, "@szLine1@{")
        InsBufLine(hbuf, ln++, "@szLine1@    OSA_ERROR(\"memAlloc for @szVar@ err\\n\");")
        InsBufLine(hbuf, ln++, "@szLine1@    return OSA_EFAIL;")
        InsBufLine(hbuf, ln++, "@szLine1@}")
        SetBufIns (hbuf, ln-1, strlen(szLine1)+1)        
    }
    /*配置命令执行*/
	if (szCmd == "config" || szCmd == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    if (szCmd == "main")
    {
	    DelBufLine(hbuf, ln)
        InsertMain(hbuf, ln)
        return
    }

    return 
}

macro RestoreCommand(hbuf,szCmd)
{
    if(szCmd == "ca")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if(szCmd == "sw") 
    {
        SetBufSelText(hbuf, "itch")
        szCmd = "switch"
    }
    else if(szCmd == "el")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "else"
    }
    else if(szCmd == "wh")
    {
        SetBufSelText(hbuf, "ile")
        szCmd = "while"
    }
    return szCmd
}

macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}
macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = "" // create a "wordinfo" structure
    
    chTab = CharFromAscii(9)
    
    // scan backwords over white space, if any
    ich = ich - 1;
    if (ich >= 0)
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0)
                break;
        }
    
    // scan backwords to start of word    
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)
        
/*        if ((asciiCh < asciiA || asciiCh > asciiZ)
             && !IsNumber(ch)
             &&  (ch != "#") )
            break // stop at first non-identifier character
*/
        //只提取字符和# { / *作为命令
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }
    
    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;
    
    return wordinfo
}
macro InsertFileHeaderCN(hbuf, ln)
{
	lnOld = ln;
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }

    SysTime = GetSysTime(1);    
    szDate = SysTime.date;  

    szFileName = GetFileName(getBufName(hbuf)); 

    szName = getreg(AUTHOR);
    szMail = getreg(EMAIL);

    if(szName == "" || szMail == "")
    {
    	ConfigureSystem();
    	szName = getreg(AUTHOR);
	    szMail = getreg(EMAIL);
    }    

    InsBufLine(hbuf, ln ++, "/*******************************************************************************")
    InsBufLine(hbuf, ln ++, " * @szFileName@")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " * Copyright (C) 2011-2013 ZheJiang Dahua Technology CO.,LTD.")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " * Author : @szName@ <@szMail@>")
    InsBufLine(hbuf, ln ++, " * Version: V1.0.0  @szDate@ Create")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " * Description: ")
    InsBufLine(hbuf, ln ++, " *")  
    InsBufLine(hbuf, ln ++, " *       1. 硬件说明")
    InsBufLine(hbuf, ln ++, " *          无。")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " *       2. 程序结构说明。")
    InsBufLine(hbuf, ln ++, " *          无。")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " *       3. 使用说明。")
    InsBufLine(hbuf, ln ++, " *          无。")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " *       4. 局限性说明。")
    InsBufLine(hbuf, ln ++, " *          无。")
    InsBufLine(hbuf, ln ++, " *")
    InsBufLine(hbuf, ln ++, " *       5. 其他说明。")
    InsBufLine(hbuf, ln ++, " *          无。")
	InsBufLine(hbuf, ln ++, " *")
	InsBufLine(hbuf, ln ++, " * Modification: ")
	InsBufLine(hbuf, ln ++, " *    Date     : ")
	InsBufLine(hbuf, ln ++, " *    Revision :")
	InsBufLine(hbuf, ln ++, " *    Author   :")
	InsBufLine(hbuf, ln ++, " *    Contents :")
    InsBufLine(hbuf, ln ++, " *******************************************************************************/")
	InsBufLine(hbuf, ln ++,"")
	SetBufIns (hbuf, lnOld + 8, strlen(GetBufLine (hbuf, lnOld + 8)))
}

macro InsertMain(hbuf, ln)
{
	lnOld = ln;
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }

    InsBufLine(hbuf, ln ++, "Int32 main(Int32 argc,char *argv[])")
    InsBufLine(hbuf, ln ++, "{")
    InsBufLine(hbuf, ln ++, "    ")
    InsBufLine(hbuf, ln ++, "	return OSA_SOK;")
    InsBufLine(hbuf, ln ++, "}")
    SetBufIns (hbuf, lnOld + 2, 4)
}
macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == "\\")
      {
        szName = strmid(sz,iLen-i+1,iLen)
        break
      }
      i = i + 1
    }
    return szName
}

macro InsertCPP(hbuf,ln)
{
	lnOld = ln;
	
	szFileName =toupper(GetFileNameNoExt(getBufName(hbuf))); 
	
	headNameMac="_@szFileName@_H_"
	
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "#ifndef @headNameMac@")
	InsBufLine(hbuf, ln++, "#define @headNameMac@")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "/*                             头文件区                                       */")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "#ifdef __cplusplus")
	InsBufLine(hbuf, ln++, "extern \"C\"{")
	InsBufLine(hbuf, ln++, "#endif /* __cplusplus */")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "/*                           宏和类型定义区                                   */")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "/*                          数据结构定义区                                    */")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "/*                          函数声明区                                        */")
	InsBufLine(hbuf, ln++, "/* ========================================================================== */")
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	iTotalLn = GetBufLineCount (hbuf)   
	InsBufLine(hbuf, iTotalLn++, "#ifdef __cplusplus")
	InsBufLine(hbuf, iTotalLn++, "}")
	InsBufLine(hbuf, iTotalLn++, "#endif /* __cplusplus */")
	InsBufLine(hbuf, iTotalLn++, "")
	InsBufLine(hbuf, iTotalLn++, "")
	InsBufLine(hbuf, iTotalLn++, "#endif")
	InsBufLine(hbuf, iTotalLn++, "")
	setbufins(hbuf,lnOld+10,0);
}

macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
         szExt = strmid(sz,j + 1,iLen)
         return szExt
      }
      i = i + 1
    }
    return ""
}

macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen 
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,j)
         return szName
      }
      i = i + 1
    }
    szName = strmid(sz,0,j)
    return szName
}

macro ConfigureSystem()
{    
    szAuthor = ASK("Please input your name");
    if(szAuthor == "#")
    {
       SetReg ("AUTHOR", "")
    }
    else
    {
       SetReg ("AUTHOR", szAuthor)
    }

    szEmail = ASK("Please input your email");
    if(szEmail == "#")
    {
       SetReg ("EMAIL", "")
    }
    else
    {
       SetReg ("EMAIL", szEmail)
    }

    while(1)
    {
    	defaultAstylePath="C:\\Program Files\\astyle"
		AStyleCmd = getreg(astylePath)
		if(AStyleCmd == "")
		{
			AStyleCmd=defaultAstylePath
			SetReg ("astylePath", defaultAstylePath)			
		}
		AStyleCmd = cat (AStyleCmd,"\\AStyle.exe")

		retRun  = ShellExecute("", AStyleCmd, "--version", "", 0);
		if(0 == retRun)
		{
			szPath = ASK("Please input Astyle path");
		    if(szEmail == "#")
		    {
		       SetReg ("astylePath", "")
		    }
		    else
		    {
		       SetReg ("astylePath", szPath)
		    }   
		}
		else
		{
			break;
		}
    }

    while(1)
    {
    	defaultSourceStylePath="C:\\Program Files\\Ochre Software\\SourceStyler"
    	
	    SourceStylerCmd = getreg(sourceStylePath)

	    if(SourceStylerCmd == "")
		{
			SourceStylerCmd=defaultSourceStylePath
			SetReg ("sourceStylePath", defaultSourceStylePath)			
		}
		
	    SourceStylerCmd = cat (SourceStylerCmd,"\\SourceStylerCmd.exe")

		retRun  = ShellExecute("", SourceStylerCmd, "--version", "", 0);
		if(0 == retRun)
		{
			szPath = ASK("Please input sourceStyle path");
		    if(szEmail == "#")
		    {
		       SetReg ("sourceStylePath", "")
		    }
		    else
		    {
		       SetReg ("sourceStylePath", szPath)
		    }   
		}
		else
		{
			break;
		}
    }
}


macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}
macro strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return -1
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j]) 
                {
                    break
                }
            }     
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1      
    }  
    return -1
}

macro InsertMultiCaseProc(hbuf,szLeft,nSwitch)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
	lnOld = ln;
    nIdx = 0
    if(nSwitch == 0)
    {
        hNewBuf = newbuf("clip")
        if(hNewBuf == hNil)
            return       
        SetCurrentBuf(hNewBuf)
        PasteBufLine (hNewBuf, 0)
        nLeftMax = 0
        lnMax = GetBufLineCount(hNewBuf )
        i = 0
        fIsEnd = 1
        while ( i < lnMax) 
        {
            szLine = GetBufLine(hNewBuf , i)
            //先去掉代码中注释的内容
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //从剪贴板中取得case值
            szLine = GetSwitchVar(szLine)
            if(strlen(szLine) != 0 )
            {
                ln = ln + 3
                InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case @szLine@:")
                InsBufLine(hbuf, ln    , "@szLeft@    " # "    ")
                InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
			}
			i = i + 1
        }
        closebuf(hNewBuf)
	}
	else
	{
		while(nIdx < nSwitch)
		{
			ln = ln + 3
			InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case # :")
			InsBufLine(hbuf, ln    , "@szLeft@    " # "    ")
			InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
			nIdx = nIdx + 1
		}
	}
    InsBufLine(hbuf, ln + 2, "@szLeft@    " # "default:")
    InsBufLine(hbuf, ln + 3, "@szLeft@    " # "    ")
    InsBufLine(hbuf, ln + 4, "@szLeft@" # "}")

    szLine = GetBufLine(hbuf , lnOld)
    setbufins(hbuf, lnOld, strlen(szLine)-1);
}

macro GetSwitchVar(szLine)
{
    if( (szLine == "{") || (szLine == "}") )
    {
        return ""
    }
    ret = strstr(szLine,"#define" )
    if(ret != -1)
    {
        szLine = strmid(szLine,ret + 8,strlen(szLine))
    }
    szLine = TrimLeft(szLine)
    nIdx = 0
    nLen = strlen(szLine)
    while( nIdx < nLen)
    {
        if((szLine[nIdx] == " ") || (szLine[nIdx] == ",") || (szLine[nIdx] == "="))
        {
            szLine = strmid(szLine,0,nIdx)
            return szLine
        }
        nIdx = nIdx + 1
    }
    return szLine
}

macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);/*Loads the search pattern used for the Search, Search Forward, and Search Backward commands*/
    Search_Forward
}

macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}
macro FuncHeadCommentCN(hbuf, ln, szFunc,newFunc)
{
    iIns = 0
    lnMax = 0
    lnOld = ln;
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
                
            //将文件参数头整理成一行并去掉了注释
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName
            
            //取出返回值定义
            szTemp = strmid(szLine,0,iBegin)
            szTemp = TrimString(szTemp)
            szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //对于宏返回值特殊处理
                szRet = ""
            }
            
            //从函数头分离出函数参数
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szRet = ""
        szLine = ""
    }

	InsBufLine(hbuf, ln++,"/*******************************************************************************");
	InsBufLine(hbuf, ln++,"* 函数名  : @szFunc@");
	InsBufLine(hbuf, ln++,"* 描  述  : ");

    szIns = "* 输  入  : - "

    if(newFunc != 1 && lnMax >0)
    {
        //对于已经存在的函数输出输入参数表
        i = 0

        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)

            nLen = strlen(szTmp);
            
            //对齐参数后面的空格，实际是对齐后面的参数的说明
            szBlank = CreateBlankString(nMaxParamSize - nLen  )

            szTmp = cat(szTmp,szBlank)

            szTmp = cat(szIns,szTmp)

            InsBufLine(hbuf, ln++,"@szTmp@:");
            iIns = 1
            szIns = "*         : - "
            i = i+1;
        }    
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {    
		InsBufLine(hbuf, ln++,"* 输  入  : 无");
    }

    InsBufLine(hbuf, ln++,"* 输  出  : 无");
	InsBufLine(hbuf, ln++,"* 返回值  : OSA_SOK  : 成功");
	InsBufLine(hbuf, ln++,"*           OSA_EFAIL: 失败");
	InsBufLine(hbuf, ln++,"*******************************************************************************/");
	SetBufIns (hbuf, lnOld + 2, 12);
    
}
macro GetFunctionDef(hbuf,symbol)
{
    ln = symbol.lnName
    szFunc = ""
    if(strlen(symbol) == 0)
    {
       return szFunc
    }
    fIsEnd = 1
//    msg(symbol)
    while(ln < symbol.lnLim)
    {
        szLine = GetBufLine (hbuf, ln)
        //去掉被注释掉的内容
        RetVal = SkipCommentFromString(szLine,fIsEnd)
		szLine = RetVal.szContent

		//trim后，可能会将变量名与类型连起来了
		//szLine = TrimString(szLine)
		fIsEnd = RetVal.fIsEnd
        //如果是{表示函数参数头结束了
        ret = strstr(szLine,"{")        
        if(ret != -1)
        {
            szLine = strmid(szLine,0,ret)
            szFunc = cat(szFunc,szLine)
            break
        }
        szFunc = cat(szFunc,szLine)        
        ln = ln + 1
    }
    return szFunc
}
macro CreateBlankString(nBlankCount)
{
    szBlank=""
    nIdx = 0
    while(nIdx < nBlankCount)
    {
        szBlank = cat(szBlank," ")
        nIdx = nIdx + 1
    }
    return szBlank
}
macro GetFirstWord(szLine)
{
    szLine = TrimLeft(szLine)
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ") ||(szLine[nIdx] == "\t") 
          ||(szLine[nIdx] == ";") ||(szLine[nIdx] == "(")
          ||(szLine[nIdx] == ".") ||(szLine[nIdx] == "{")
          ||(szLine[nIdx] == ",") ||(szLine[nIdx] == ":")
          ||(szLine[nIdx] == "*") ||(szLine[nIdx] == "/"))
        {
            return strmid(szLine,0,nIdx)
        }
        nIdx = nIdx + 1
    }
    return ""
    
}
macro GetLastWord(szLine)
{
    szLine = TrimRight(szLine)
    
    iLen = strlen(szLine)
    nIdx = iLen;
    while(nIdx > 0 )
    {
        if( (szLine[nIdx] == " ") ||(szLine[nIdx] == "\t") 
          ||(szLine[nIdx] == ";") ||(szLine[nIdx] == "(")
          ||(szLine[nIdx] == ".") ||(szLine[nIdx] == "{")
          ||(szLine[nIdx] == ",") ||(szLine[nIdx] == ":")
          ||(szLine[nIdx] == "*") ||(szLine[nIdx] == "/"))
        {        	
            return strmid(szLine,nIdx+1,iLen)
        }
        nIdx = nIdx - 1
    }
    return szLine
    
}
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //如果当前行开始还是被注释，或遇到了注释开始的变标记，注释内容改为空格?
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " " 
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                
                //如果是倒数第二个则最后一个也肯定是在注释内
//                if(nIdx == nLen -2 )
//                {
//                    szLine[nIdx + 1] = " "
//                }
                nIdx = nIdx + 1 
            }    
            
            //如果已经到了行尾终止搜索
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //如果遇到的是//来注释的说明后面都为注释
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        nIdx = nIdx + 1                
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //先定位到开始字符标记处
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //用于检测chBeg和chEnd的配对情况
    iCount = 0
    
    nEndWord = 0
    //以分隔符为标记进行搜索
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chSeparator)
        {
           szWord = strmid(szLine,nBegWord,nIdx)
           szWord = TrimString(szWord)
           szWord = GetLastWord(szWord);
           nLen = strlen(szWord)
           if(nMaxLen < nLen)
           {
               nMaxLen = nLen
           }
           AppendBufLine(hbuf,szWord)
           nBegWord = nIdx + 1
        }
        if(szLine[nIdx] == chBeg)
        {
            iCount = iCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            iCount = iCount - 1
            nEndWord = nIdx
            if( iCount == 0 )
            {
                break
            }
        }
        nIdx = nIdx + 1
    }
    if(nEndWord > nBegWord)
    {
        szWord = strmid(szLine,nBegWord,nEndWord)
        szWord = TrimString(szWord)
        szWord = GetLastWord(szWord);
        nLen = strlen(szWord)
        if(nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf,szWord)
    }
    return nMaxLen
}

macro delete_coment(str,beginIndex)
{

	maxLen = strlen(str)
	i=beginIndex;

	while(i < maxLen-1)
	{		
		if((str[i] == / && str[i+1] == *)
			||(str[i] == * && str[i+1] == /))
		{
			str[i] = " "
			str[i+1] = " " 
		}
		else if((str[i] == / && str[i+1] == /))
		{
			if(i < maxLen -3 && (str[i+2] == / && str[i+3] == <))
			{
				str[i+2] = " "
				str[i+3] = " " 			 	
			}
			str[i] = " "
			str[i+1] = " " 
			
		}
		i = i+1;
	}



	return str
}

macro insert_c_comment_start(str,beginIndex)
{
	maxLen = strlen(str)

	//将当前行的 '//' 替换成 /*
	str[beginIndex] = /
	str[beginIndex+1] = *

	//注释独占一行
	if(beginIndex +2 >= maxLen)
	{
		return str;
	}


	//有些结构体中，会用到 ///<，也是替换成 /*
	if((beginIndex +3 >= maxLen)
		&& (str[beginIndex+2]== / )
		&& (str[beginIndex+3]== <) )
	{
		str[beginIndex+2] = " "
		str[beginIndex+3] = " "
	}


	// '/*' 后面没有空格，则添加一个
	if (str[beginIndex+2] != " ")
	{
		str = insert_space(str,beginIndex+2,1)
	}

	// '/*' 后面空格很多，则删除到最剩一个
	i = beginIndex+2
	while(i < maxLen)
	{
		if( str[i] != " ")
		{
			break;
		}
		i = i + 1;
	}


	if(i-beginIndex - 3 > 0)
	{
		str = delete_space(str,beginIndex + 2,i-beginIndex - 3)
	}

	return str
}

// C++ 风格注释转换为 C 风格
macro ComentCPPtoC(hBuf)
{
	if(IsNumber (hBuf) ==  0)
	{
		hBuf = GetCurrentBuf();
	}

    lnCurrent = 0
    lnLast = GetBufLineCount( hBuf )

    isCommentContinue = 0
    bInCComment = 0;
    
    while ( lnCurrent < lnLast )
    {
        szLine = GetBufLine(hBuf,lnCurrent)

        cpp_com_index = strstr(szLine,"//")
        c_com_start_index = strstr(szLine,"/*")
        c_com_end_index = strstr(szLine,"*/")

        //忽略 /* */之前的 //
        if((c_com_start_index != -1)
			&& ((cpp_com_index == -1) ||( cpp_com_index > c_com_start_index )))
        {
        	bInCComment = 1;        	
        }

        if(bInCComment == 1)
        {
        	if((c_com_end_index != -1) 
        	&& ((cpp_com_index == -1) ||( cpp_com_index > c_com_end_index)))
        	{
        		bInCComment = 0;
        	}
        }

        if(bInCComment == 1)
        {
        	lnCurrent = lnCurrent + 1;
        	continue;
        }

        if(c_com_end_index > cpp_com_index 
	         && cpp_com_index > c_com_start_index
	         && c_com_start_index != -1)
         {
         	lnCurrent = lnCurrent + 1;
        	continue;
         }

        //当前行不含有 '//'，
        if(cpp_com_index == -1)
        {        	
            if(isCommentContinue == 1)
            {
        	    isCommentContinue = 0;
            	szLine = GetBufLine(hBuf,lnCurrent -1)

                if(szLine[strlen(szLine)-1] != "")
            	{
	                szLine = cat (szLine, " */")
            	}
                else
                {
            	    szLine = cat (szLine, "*/")
                }
                PutBufLine(hBuf, lnCurrent - 1, szLine);  
            }
        	
            lnCurrent = lnCurrent + 1;
        	continue;
        }


        //当前行含有 '//'

        //连续注释块
        if(isCommentContinue == 1)
        {            		
            lastNonSpace = find_last_non_space(szLine, cpp_com_index - 1)

            //msg(lastNonSpace # szLine)

			//上一个连续多行注释结束，下一个注释开始
            if(lastNonSpace >0 )
            {
            	szPreLine = GetBufLine(hBuf,lnCurrent -1)
            	szPreLine = cat (szPreLine, "*/")
            	PutBufLine(hBuf, lnCurrent - 1, szPreLine);  

				szLine = delete_coment(szLine,cpp_com_index)

				szLine = insert_c_comment_start (szLine,cpp_com_index);

				PutBufLine(hBuf, lnCurrent, szLine);
            } 
            //连续块继续，删除 '//'
            else
            {        
	    		szLine = delete_coment(szLine,cpp_com_index)

	    		PutBufLine(hBuf, lnCurrent, szLine);  
            }
        	
        }
        //注释块开始
        else
        {
        	isCommentContinue = 1;

    		szLine = delete_coment(szLine,cpp_com_index)

        	szLine = insert_c_comment_start (szLine,cpp_com_index);

        	PutBufLine(hBuf, lnCurrent, szLine);
        }        
        
        lnCurrent = lnCurrent + 1
    }

}

macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = 4
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = 4
    szBlank = CreateBlankString(nBlank)

    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
        }
        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)
        ifile = ifile + 1
    }
}


macro ReplaceInBuf(hbuf,chOld,chNew,nBeg,nEnd,fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    sel.ichLim = 0
    sel.lnLast = 0
    sel.ichFirst = sel.ichLim
    sel.lnFirst = sel.lnLast
    SetWndSel(hwnd, sel)
    LoadSearchPattern(chOld, 0, 0, 0);
    while(1)
    {
        Search_Forward
        selNew = GetWndSel(hwnd)
        if(sel == selNew)
        {
            break
        }
        SetBufSelText(hbuf, chNew)
           selNew.ichLim = selNew.ichFirst 
        SetWndSel(hwnd, selNew)
        sel = selNew
    }
}

/* 延时 1 ms，估计的，不精确*/
macro msdelay(ms)
{
	i=0;
	max = ms * 10000;

	while(i<max)
	{
		i = i+1;
	}
}

macro format_file_by_macro(fileName)
{
    hBuf= GetBufHandle (filename)
    if(hNil == hBuf)
    {
    	hBuf = openbuf(fileName);
    }
    else
    {	
    	runcmd("reload File")
    }	
    if (hbuf == 0)
    {
        return hbuf;   
    }
    
    //对C++风格的注释进行C风格转换
    ComentCPPtoC(hBuf);

    //对行内注释进行对齐处理
    format_c_comment(hBuf)
    
    savebuf(hBuf)

    return hBuf;
}

macro format_file()
{
	hbuf = GetCurrentBuf ();
	if(hbuf == 0)
	{
		return 0;
	}

	//格式化之前，先进行保存，否则可能丢失修改
	SaveBuf (hbuf);

    fileName = GetBufName(hbuf)	;
    
	//使用sourceStyle进行格式处理，主要是用于结构体成员变量对齐    
    format_file_by_source_style(fileName);
    msdelay(10);

    format_file_by_macro(fileName); 

    //用astyle对文件进行对齐处理，主要是为了处理表达式的缩进
    format_file_by_astyle(fileName);
    msdelay(10);

    runcmd("reload File");
      
}

macro format_project_do_skip_file(filename,hBuf)
{
	
	szLine = ""
	ln = 0;
	
	extType = GetFileNameExt(filename);

	if(extType == "c" || extType == "h")
	{
		if(hBuf != 0)
		{
			nLineCnt = GetBufLineCount(hBuf);

			while(ln < nLineCnt)
			{
				szLine = GetBufLine(hBuf,ln)				

				index = strstr(filename,szLine)

				//msg(szLine # index)

				if (index != -1)
				{
					//msg(skip # filename)
					return 1;
				}

				ln = ln + 1;
			}
		}

		//msg(filename)
		return 0;
	}

	return 1;
}

macro format_project_by_source_style(hprj,hExcludeBuf)
{

	ifileMax = GetProjFileCount (hprj)
	ifile = 0
	maxCnt = 20
	formatCnt = 0;
	while (ifile < ifileMax)
	{
		filename = GetProjFileName (hprj, ifile)

		skip = format_project_do_skip_file(filename,hExcludeBuf)

		if(skip == 0)
		{
			format_file_by_source_style(filename);

			formatCnt = formatCnt + 1;

			if((((formatCnt / maxCnt ) * maxCnt) == formatCnt) && ( formatCnt != 0))
			{
				msg("共" # ifileMax # "个文件，已格式化 " # ifile # " 个，五秒后点击确定后继续" )
			}
		}

		

		ifile = ifile + 1
	}
}
macro format_project_by_astyle(hprj,hExcludeBuf)
{

	ifileMax = GetProjFileCount (hprj)
	ifile = 0
	maxCnt = 50
	formatCnt = 0
	while (ifile < ifileMax)
	{
		filename = GetProjFileName (hprj, ifile)

		skip = format_project_do_skip_file(filename,hExcludeBuf)

		if(skip == 0)
		{
			format_file_by_astyle(filename);
			formatCnt = formatCnt + 1;

			if((((formatCnt / maxCnt ) * maxCnt) == formatCnt) && ( formatCnt != 0))
			{
				msg("共" # ifileMax # "个文件，已格式化 " # ifile # " 个，五秒后点击确定后继续" )
			}
		}
		

		ifile = ifile + 1
	}
}

macro format_project_by_macro(hprj,hExcludeBuf)
{

	ifileMax = GetProjFileCount (hprj)
	ifile = 0
	while (ifile < ifileMax)
	{
		filename = GetProjFileName (hprj, ifile)

		skip = format_project_do_skip_file(filename,hExcludeBuf)

		if(skip == 0)
		{
			hBuf = format_file_by_macro(filename);

			if(hBuf != 0)
			{
				closebuf(hBuf);
			}
		}

		ifile = ifile + 1
	}
}

macro format_project()
{	
	openWindCnt = WndListCount ();

	if(openWindCnt > 0)
	{
		msg("对整个工程的.c,.h进行格式化，为了提高运行效率，会先关闭掉所有打开的文件，是否继续?")
		runcmd("close all")
	}


	exclude = ASK("文件路径及名称中含哪些字符的不需要格式化，用,进行分割，不支持通配符，无请输入空格");

	hExcludeBuf = NewBuf("Tempbuf")

    SplitStringToBuf(exclude,hExcludeBuf);

	hprj = GetCurrentProj ();

	format_project_by_source_style(hprj,hExcludeBuf);

	format_project_by_macro(hprj,hExcludeBuf);

	format_project_by_astyle(hprj,hExcludeBuf);	

	kill_source_style_cmds();

	msg("format done");
	closebuf(hExcludeBuf)
}

macro kill_source_style_cmds()
{
	ShellExecute("", "taskkill", "/IM SourceStylerCmd.exe", "", 0);

	msdelay(10);

	ShellExecute("", "taskkill", "/IM SourceStylerCmd.exe", "", 0);
	
}

macro format_file_by_astyle(filename)
{

    AStyleCmd = getreg(astylePath)
    AStyleCmd = cat (AStyleCmd,"\\AStyle.exe")

	AStylePrm = "\""
	AStylePrm = cat(AStylePrm,filename)
	AStylePrm = cat(AStylePrm,"\"")

    retRun  = ShellExecute("", AStyleCmd, AStylePrm, "", 0);
    if(0 == retRun)
    {
        msg(cat("程序调用失败: ",AStyleCmd));    
    } 
}

macro format_file_by_source_style(fileName)
{

    SourceStylerCmd = getreg(sourceStylePath)
    SourceStylerCmd = cat (SourceStylerCmd,"\\SourceStylerCmd.exe")

	SourceStylerPrm ="--scheme  sysTerm --in \""
	SourceStylerPrm = cat (SourceStylerPrm,fileName)
	SourceStylerPrm = cat (SourceStylerPrm,"\" ")
	SourceStylerPrm = cat (SourceStylerPrm,"--out \"")
	SourceStylerPrm = cat (SourceStylerPrm,fileName)
	SourceStylerPrm = cat (SourceStylerPrm,"\"")

	retRun  = ShellExecute("open", SourceStylerCmd, SourceStylerPrm, "", 0);
    if(0 == retRun)
    {
        msg(cat("程序调用失败: ",SourceStylerCmd));    
    }
}


macro find_last_non_space(str, index)
{
    while(index > 0)
    {
        if(str[index] != " ")
        {
            break;
        }

        index = index - 1;
    }

    return index;
}
macro insert_space(str, index, cnt)
{
    //msg(str # index # cnt)
    maxLen = strlen(str);
    strCode = strmid(str, 0, index);
    strComm = strmid(str, index, maxLen);
    strSpace = "                                                                                                                            "
	willInsertSpace = strmid(strSpace, 0, cnt)

	strCode = cat(strCode, willInsertSpace)
	strCode = cat(strCode, strComm)

	return strCode;
}
macro delete_space(str, index, cnt)
{
    //msg("del" # str # index # cnt)
    maxLen = strlen(str);
    strCode = strmid(str, 0, index);
    strComm = strmid(str, index + cnt , maxLen);

    strCode = cat(strCode, strComm)

	return strCode;
}

macro format_c_comment_start(str)
{
	index = strstr(str, "/*");
	maxLen = strlen(str);

	//不包含 '/*'
	if(index == -1)
    {
    	return str;
    }

	// '/*'独占一行，不处理
    if(maxLen == index + 2)
    {
    	return str;    	
    }

	// '*/' 前为空格或者 '*'，不处理
    if(str[index+2] == " " || str[index+2] == "*")
    {
    	return str;    	
    }

    newStr = insert_space(str,index+2,1)

    return newStr
}

// 对 '*/' 前添加空格
macro format_c_comment_end(str)
{
	index = strstr(str, "*/");

	//不包含 '*/'
	if(index == -1)
    {
    	return str;
    }

	// '*/'独占一行，不处理
    if(index == 0)
    {
    	return str;    	
    }

	// '*/' 前为空格或者 '*'，不处理
    if(str[index-1] == " " || str[index-1] == "*")
    {
    	return str;    	
    }

    newStr = insert_space(str,index,1)

    return newStr
}

macro format_c_comment(hBuf)
{    
	if(IsNumber (hBuf) ==  0)
	{
		hBuf = GetCurrentBuf();
	}

	lnMax = GetBufLineCount(hBuf);
    ln = 0;
    beginIndex = 40;
    max_comment_len = 40;

    while(ln < lnMax)
    {
        line = GetBufLine(hBuf, ln);

        index = strstr(line, "/*");

        if(index != -1)
        {
        	//msg(line)

			c_comment_end_index = strstr(line, "*/");           

            lastNonSpace = find_last_non_space(line, index - 1)

           //msg(lastNonSpace # line)
           //不是行内注释，不处理
           if(lastNonSpace <= 0 || c_comment_end_index ==-1)
            {
            	newStr = format_c_comment_end(line);
            	newStr = format_c_comment_start(newStr);            	
            	PutBufLine(hBuf, ln, newStr);
                ln = ln + 1;
                continue;
            }

            //注释正好对齐，不处理
            if(beginIndex == index)
            {
            	newStr = format_c_comment_end(line);
            	newStr = format_c_comment_start(newStr); 
            	PutBufLine(hBuf, ln, newStr);
                ln = ln + 1;
                continue;
            }

            //msg ("lastNonSpace = " # lastNonSpace # "beginIndex = " # beginIndex # "index = "# index)

            //可以行内注释
            if(lastNonSpace < beginIndex
	            && (max_comment_len > c_comment_end_index - index))
            {
                //空格不够，插入空格
                if(index < beginIndex)
                {
                    newStr = insert_space(line, index, beginIndex - index)
                    newStr = format_c_comment_end(newStr);
                    newStr = format_c_comment_start(newStr); 
					PutBufLine(hBuf, ln, newStr);
                }
                //空格过多，删除空格
                else
                {
                    newStr = delete_space(line, beginIndex, index - beginIndex)
                    newStr = format_c_comment_end(newStr);
                    newStr = format_c_comment_start(newStr); 
					PutBufLine(hBuf, ln, newStr);
                }

            }
            //注释在行内放不下，另起一行
            else
            {
                comStr = strmid(line, index, strlen(line));
				codeStr = strmid(line, 0, index);
				comStr = format_c_comment_end(comStr);
				comStr = format_c_comment_start(comStr); 
				InsBufLine(hbuf, ln, comStr);
				PutBufLine(hBuf, ln + 1, codeStr);
                ln = ln + 1;
            }

        }

        ln = ln + 1;
    }
}


macro SplitStringToBuf(szLine,hBuf)
{
	szLine = cat(szLine,",")
	while(1)
	{
		szWord = GetFirstWord(szLine);

		if(szWord == "")
		{
			szLine = strmid(szLine,1,strlen(szLine))
		}
		else
		{
			//msg(szWord)

			AppendBufLine(hbuf,szWord)
			szLine = strmid(szLine,strlen(szWord)+1,strlen(szLine))
		}

		if(strlen(szLine) < 1)
		{
			break;
		}
	}

	nLineCnt = GetBufLineCount(hBuf);
	//msg(nLineCnt)
  
}