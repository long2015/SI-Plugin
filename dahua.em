/*
//大华Source Insight插件v0.1
//此插件融合各方插件功能
//修改使适用于大华，提高研发开发效率
//
//2014年5月17日
//
//
//功能：
//1、tab键
//自动补全功能if else while for 
//trace include main
//2、插入函数名
//InsertFuncName
//InsertPoint
//4、光标移动
//行首，行尾
//
//5、svn相关
//log diff blace explorer
//
//6、注释
//多行注释
//Doxygen文档注释：函数、
//6、快捷启动Ctrl+Enter
//
//7、文件操作
//文件切换Ctrl+d
*/

#define IF_KEY 1
#define FOR_KEY 2
#define WHILE_KEY 3

/*********************Start Base Functions*********************/

/*
* 基础函数：字符串处理，查找word、非空字符位置
*
*/

//返回 str1第n次出现的位置（正向）
macro strstr(str,str1,n)
{
    len = strlen(str)
    len1 = strlen(str1)
    i = 0

    times = 0
    while( i < len - len1 )
    {
        strrmp = strmid(str,i,i+len1)
        if( strrmp == str1 )
        {
            times = times + 1
            if( times >= n )
            {
                return i+1;
            }
        }
        i = i + 1;
    }

    return -1;
}
//返回 str1第n次出现的位置（逆向）
macro strrstr(str,str1,n)
{
    len = strlen(str)
    len1 = strlen(str1)
    i = len - len1

    times = 0
    while( i > 0 )
    {
        strrmp = strmid(str,i,i+len1)
        if( strrmp == str1 )
        {
            times = times + 1
            if( times >= n )
            {
                return i+1;
            }
        }
        i = i - 1;
    }

    return -1;
}

macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
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
macro GetLeftWord(ich, sz)
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

        //只提取字符和# { / *作为命令
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }
    
    ich = ich + 1
    wordinfo.key = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;
    
    return wordinfo
}
//
macro GetLeftNoBlank(ich, linebuf)
{
    chTab = CharFromAscii(9)
    while (ich > 0)
    {
        ich = ich - 1;
        if (linebuf[ich] == " " || linebuf[ich] == chTab)
        {
            continue
        }
        else
        {
            break
        }
    }

    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    ch = toupper(linebuf[ich])
    asciiCh = AsciiFromChar(ch)
    symbol = ""
    if( asciiCh < asciiA || asciiCh > asciiZ )
    {
        //是符号，直接退出
        symbol.name = linebuf[ich]
        symbol.ichFirst = ich
        return symbol
    }

    //搜索单词
    ichLim = ich + 1
    while (ich >= 0)
    {
        ch = toupper(linebuf[ich])
        asciiCh = AsciiFromChar(ch)

        //不是字母，退出
        if (asciiCh < asciiA || asciiCh > asciiZ)
            break;

        ich = ich - 1;
    }
    ichFirst = ich + 1
    symbol = ""
    symbol.name = strmid(linebuf,ichFirst,ichLim)
    symbol.ichFirst = ichFirst
    return symbol
}

macro GetRightNoBlank(ich, linebuf)
{
    chTab = CharFromAscii(9)
    len = strlen(linebuf)

    while (ich < len-1)
    {
        ich = ich + 1;
        if (linebuf[ich] == " " || linebuf[ich] == chTab)
        {
            continue
        }
        else
        {
            break
        }
    }

    symbol = ""
    if( ich == len-1 )
    {
        symbol.name = ""
        symbol.ichFirst = -1
    }
    else
    {
        //右边只返回一个字符
        symbol.name = linebuf[ich]
        symbol.ichFirst = ich
    }

    return symbol
}
macro GetBeginNoBlank(ich, linebuf)
{
    chTab = CharFromAscii(9)

    ich1 = ich
    len = strlen(linebuf)
    ich = 0
    while (ich < ich1 && ich < len)
    {
        if (linebuf[ich] == " " || linebuf[ich] == chTab)
        {
            ich = ich + 1;
            continue
        }
        else
        {
            break
        }
    }
    if( ich == ich1 )
    {
        ich = ich -1
    }
    if( ich < 0 )
    {
        ich = 0
    }

    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    ch = toupper(linebuf[ich])
    asciiCh = AsciiFromChar(ch)

    if( asciiCh < asciiA || asciiCh > asciiZ )
    {
        //是符号，直接退出
        symbol = ""
        symbol.name = linebuf[ich]
        symbol.ichFirst = ich
        return symbol
    }

    //搜索单词
    ichFirst = ich
    while ( ich <= ich1 && ich < len)
    {
        ch = toupper(linebuf[ich])
        asciiCh = AsciiFromChar(ch)

        //不是字母，退出
        if (asciiCh < asciiA || asciiCh > asciiZ)
            break;

        ich = ich + 1;
    }
    ichLim = ich
    symbol = ""
    symbol.name = strmid(linebuf,ichFirst,ichLim)
    symbol.ichFirst = ichFirst
    return symbol
}
macro GetBeginBlank(linebuf)
{
    ich = 0
    while (linebuf[ich] == " " || linebuf[ich] == "\t")
    {
        ich = ich + 1
    }
    lineblanks = strmid(linebuf,0,ich)
    return lineblanks
}
macro GetEndBlankPos(linebuf)
{
    ich = strlen(linebuf) - 1
    while (linebuf[ich] == " " || linebuf[ich] == "\t")
    {
        ich = ich - 1
    }
    ich = ich + 1
    return ich
}
/*********************End Base Functions*********************/

/*
* 主功能
*
*/

//tab键自动补全功能
macro tabCompletion()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    linebuf = GetBufLine(hbuf, sel.lnFirst);
    linebufLen = strlen(linebuf)

    if( sel.ichFirst != sel.ichLim || sel.lnFirst != sel.lnLast )
    {
        //选择模式,插入4个空格
        oldSel = sel
        line = oldSel.lnFirst
        while( line <= oldSel.lnLast )
        {
            sel.ichFirst = 0
            sel.ichLim = 0
            sel.lnFirst = line
            sel.lnLast = line
            SetWndSel(hwnd, sel)
            SetBufSelText(hbuf, "    ")
            line = line + 1
        }
        //还原选中状态
        oldSel.ichFirst = oldSel.ichFirst + 4
        oldSel.ichLim = oldSel.ichLim + 4
        SetWndSel(hwnd, oldSel)

        stop
    }

    //补全模式
    word = GetLeftWord(sel.ichFirst, linebuf)

    key = word.key
    lnblanks = GetBeginBlank(linebuf)
    ln = sel.lnFirst
    //先跳出
    if ( jumpOut()==true )
    {
        //跳出函数，后括号等
        // 跳到"/* code */"处
        return
    }
    else if (key == "inc" )
    {
         sel.ichFirst = sel.ichFirst - 3
         SetWndSel(hwnd, sel)
         SetBufSelText(hbuf, "#include \"\"")
         sel.ichFirst = sel.ichFirst + 10
         sel.ichLim = sel.ichFirst
         SetWndSel(hwnd, sel)
         return
    }
    else if (key == "tra" )
    {
         sel.ichFirst = sel.ichFirst - 3
         SetWndSel(hwnd, sel)
         SetBufSelText(hbuf, "trace(\"\");")
         sel.ichFirst = sel.ichFirst + 7
         sel.ichLim = sel.ichFirst
         SetWndSel(hwnd, sel)
         return
    }
    else if( key == "pri" )
    {
        SetBufSelText(hbuf, "ntf(\"\");")
        sel.ichFirst = sel.ichFirst + 5
        sel.ichLim = sel.ichFirst
        SetWndSel(hwnd, sel)
        return
    }
    else if( key == "main" )
    {
        sel.ichFirst = sel.ichFirst - 4
        ln = sel.lnFirst
        SetWndSel(hwnd, sel)
        SetBufSelText(hbuf,"int main(int argc, char* argv[])")
        InsBufLine(hbuf, ln + 1, "{")
        InsBufLine(hbuf, ln + 2, "    ")
        InsBufLine(hbuf, ln + 3, "    ")
        InsBufLine(hbuf, ln + 4, "    return 0;")
        InsBufLine(hbuf, ln + 5, "}")
        sel.ichFirst = sel.ichFirst + 4
        sel.ichLim = sel.ichLim
        sel.lnFirst = ln + 2
        sel.lnLast = sel.lnFirst
        SetWndSel(hwnd,sel)
        return
    }
    else if( key == "if" || key == "while" || key == "for" || key == "elif" )
    {
        if( key == "elif" )
        {
            sel.ichFirst = sel.ichFirst - 4
            SetWndSel(hwnd, sel)
            SetBufSelText(hbuf, "else if(  )")
            sel.ichFirst = sel.ichFirst + 7
        }
        else
        {
            SetBufSelText(hbuf, "(  )")
        }

        InsBufLine(hbuf, ln + 1, lnblanks # "{");
        InsBufLine(hbuf, ln + 2, lnblanks # "    /* code */");
        InsBufLine(hbuf, ln + 3, lnblanks # "}");

        sel.ichFirst = sel.ichFirst + 2
        sel.ichLim = sel.ichFirst
        sel.lnLast = sel.lnFirst
        SetWndSel(hwnd, sel)
        return
    }
    else if( key == "else" || key == ")")
    {
        linecur = GetBufLine(hbuf, ln);
        line1 = GetBufLine(hbuf, ln+1);
        line2 = GetBufLine(hbuf, ln+2);
        line3 = GetBufLine(hbuf, ln+3);

        szLine1 = lnblanks # "{"
        szLine2 = lnblanks # "    /* code */"
        szLine3 = lnblanks # "}"

        sel.ichFirst = strlen(lnblanks) + 4
        if( line1 == szLine1 && line2 == szLine2 && line3 == szLine3 )
        {
            sel.ichLim = sel.ichFirst + 10
        }
        else if( line1 == szLine1 )
        {
            sel.ichLim = sel.ichFirst
        }
        else if( cmd == "else" )
        {
            InsBufLine(hbuf, ln + 1, szLine1);
            InsBufLine(hbuf, ln + 2, szLine2);
            InsBufLine(hbuf, ln + 3, szLine3);
            sel.ichLim = sel.ichFirst + 10
        }


        sel.lnFirst = ln + 2
        sel.lnLast = sel.lnFirst
        SetWndSel(hwnd, sel)
        return
    }
    else if( key == "{" )
    {
        InsBufLine(hbuf, ln+1, lnblanks # "    ");
        InsBufLine(hbuf, ln + 2, lnblanks # "}");
        sel.lnFirst = ln + 1
        sel.lnLast = sel.lnFirst
        sel.ichFirst = sel.ichFirst + 4
        sel.ichLim = sel.ichFirst
        SetWndSel(hwnd, sel)
        return
    }
    else
    {
        //
        Tab
        return
    }
}

macro jumpOut()
{
    hwnd = GetCurrentWnd()
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)

    linebuf = GetBufLine(hbuf, sel.lnFirst)
    linebufLen = strlen(linebuf)
    ichFirst = sel.ichFirst;


    if( sel.ichFirst == linebufLen )
    {
        //在行尾，跳转到code行
        line = sel.lnFirst + 1
        while( line <= sel.lnFirst + 2 )
        {
            linebuf = GetBufLine(hbuf, line)
            pos = strstr(linebuf,"* code *",1)
            if( pos != -1 )
            {
                sel.ichFirst = pos - 2
                sel.ichLim = pos + 8
                sel.lnFirst = line
                sel.lnLast = line
                SetWndSel(hwnd,sel)

                return true
            }
            line = line + 1
        }
    }
    else
    {
        //处理冒话、括号的跳出
        right = strmid(linebuf,ichFirst,linebufLen)
        gothere = 0
        if( right == "\");" || right == ")" )
        {
            gothere = 1;
        }
        else if( right == ");" || right == " )" )
        {
            gothere = 2;
        }

        if( gothere != 0 )
        {
            sel.ichFirst = sel.ichFirst + gothere
            sel.ichLim = sel.ichFirst
            SetWndSel(hwnd,sel) 
            return true
        }
    }
    return false
}

//跳转到行首 Ctrl + a
macro jumpLineStart()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    
    linebuf = GetBufLine(hbuf, sel.lnFirst);
    right = TrimLeft(linebuf)
    pos = strlen(linebuf) - strlen(right)
    //如果当前位置已是最左端，则跳到0
    if( pos == sel.ichFirst )
        pos = 0

    sel.ichFirst = pos
    sel.ichLim = pos
    SetWndSel(hwnd, sel)
}

//跳转到行尾 Ctrl + e
macro jumpLineEnd()
{
   hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)

    linebuf = GetBufLine(hbuf, sel.lnFirst);
    left = TrimRight(linebuf)
    pos = strlen(left)
    //如果当前位置已是最左端，则跳到0
    if( pos == sel.ichFirst )
        pos = strlen(linebuf)

    sel.ichFirst = pos
    sel.ichLim = pos
    SetWndSel(hwnd, sel)
}
macro IsWord(ch)
{
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    ch = toupper(ch)
    asciiCh = AsciiFromChar(ch)

    if( asciiCh >= asciiA && asciiCh <= asciiZ )
    {
        return true
    }
    else
    {
        return false
    }
}
macro IsSymbol(ch)
{
    if( IsWord(ch) == true || ch == "_" || IsNumber(ch) )
    {
        return true
    }
    else
    {
        return false
    }
}
macro GoLeft()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    linebuf = GetBufLine(hbuf,sel.lnFirst)
    ichFirst = sel.ichFirst
    lnFirst = sel.lnFirst

    ichFirst = ichFirst - 1
    if( ichFirst < 0 )
    {
        lnFirst = lnFirst - 1
        if(lnFirst < 0)
        {
            ichFirst = 0
            lnFirst = 0
        }
        else
        {
            linebuf = GetBufLine(hbuf,lnFirst)
            ichFirst = strlen(linebuf)
        }

        sel.ichFirst = ichFirst
        sel.ichLim = ichFirst
        sel.lnFirst = lnFirst
        sel.lnLast = lnFirst
        SetWndSel(hwnd, sel)
        return
    }
    hasword = false
    while( ichFirst >= 0 )
    {
        ch = linebuf[ichFirst]

        if( hasword == false && IsSymbol(ch) == false )
        {
            ichFirst = ichFirst - 1
        }
        else if( IsSymbol(ch) )
        {
            hasword = true
            ichFirst = ichFirst - 1
        }
        else
        {
            break
        }
    }
    if( hasword == true )
    {
        ichFirst = ichFirst + 1
    }
    sel.ichFirst = ichFirst
    sel.ichLim = sel.ichFirst
    SetWndSel(hwnd, sel)
}
macro GoRight()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    linebuf = GetBufLine(hbuf,sel.lnFirst)
    len = strlen(linebuf)
    maxline = GetBufLineCount(hbuf)
    ichFirst = sel.ichFirst
    lnFirst = sel.lnFirst

    ichFirst = ichFirst + 1
    if( ichFirst > len )
    {
        lnFirst = lnFirst + 1
        if(lnFirst > maxline)
        {
            ichFirst = len
            lnFirst = maxline
        }
        else
        {
            ichFirst = 0
        }

        sel.ichFirst = ichFirst
        sel.ichLim = ichFirst
        sel.lnFirst = lnFirst
        sel.lnLast = lnFirst
        SetWndSel(hwnd, sel)
        return
    }
    hasword = false
    while( ichFirst < len )
    {
        ch = linebuf[ichFirst]

        if( hasword == false && IsSymbol(ch) == false )
        {
            ichFirst = ichFirst + 1
        }
        else if( IsSymbol(ch) )
        {
            hasword = true
            ichFirst = ichFirst + 1
        }
        else
        {
            break
        }
    }
    sel.ichFirst = ichFirst
    sel.ichLim = sel.ichFirst
    SetWndSel(hwnd, sel)
}
macro GoUp5()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    sel.lnFirst = sel.lnFirst - 5
    if( sel.lnFirst < 0 )
    {
        sel.lnFirst = 0
    }
    sel.lnLast = sel.lnFirst
    topline = GetWndVertScroll(hwnd)
    SetWndSel(hwnd,sel)
    ScrollWndToLine(hwnd,topline-5)
}
macro GoDown5()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    lnFirst = sel.lnFirst

    lnFirst = lnFirst + 5
    if( lnFirst >= GetBufLineCount(hbuf) )
    {
        lnFirst = GetBufLineCount(hbuf) - 1
    }
    topline = GetWndVertScroll(hwnd)
    if topline + GetWndLineCount(hwnd) < GetBufLineCount(hbuf)
        ScrollWndToLine(hwnd,topline + 5)

    sel.lnFirst = lnFirst
    sel.lnLast = sel.lnFirst
    SetWndSel(hwnd,sel)
}

macro InsertPoint()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    SetBufSelText(hbuf, "tracepoint();");

    linebuf = GetBufLine(hbuf,sel.lnFirst)
    lnblanks = GetBeginBlank(linebuf)
    InsBufLine(hbuf, sel.lnFirst + 1, lnblanks);
    sel.lnFirst = sel.lnFirst + 1
    sel.lnLast = sel.lnFirst
    SetWndSel(hwnd, sel)
}
macro InsertFuncName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    index = 0
    len = strlen(symbolname)
    while( index < len )
    {
        if( symbolname[index] == "." )
            break
        index = index + 1
    }
    if( index == len)
    {
        str = "trace(\"" # symbolname # ">>> \\n\");"
    }
    else
    {
        classname = strmid(symbolname,0,index)
        funcname = strmid(symbolname,index+1,len)
        str = "trace(\"" # classname # "::" # funcname # ">>> \\n\");"
    }
    SetBufSelText(hbuf, str)
    sel.ichFirst = sel.ichFirst + strlen(str) - 5
    sel.ichLim = sel.ichFirst
    SetWndSel(hwnd, sel)
}

//多行注释与去注释功能
macro MultiLineComment()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    lnFirst = GetWndSelLnFirst(hwnd)      //取首行行号
    lnLast = GetWndSelLnLast(hwnd)      //取末行行号
    ichFirst = sel.ichFirst
    ichLim = sel.ichLim
    hbuf = GetCurrentBuf()

    isComment = true      //默认注释过

    //先检查是否已注释过
    line = lnFirst
    while( line <= lnLast )
    {
        lineBuf = GetBufLine(hbuf,line)
        lineLen = strlen(lineBuf)

        szRight = TrimLeft(lineBuf)
        rightLen = strlen(szRight)
        if( rightLen == 0 )  //空行不处理
        {
            line = line + 1
            continue
        }
        else if(  rightLen == 1 )
        {
            isComment = false
            break
        }

        if( strmid(szRight,0,2) == "//" )
        {
            line = line + 1
            continue
        }
        else
        {
            isComment = false
            break
        }
    }

    if( isComment )
    {
        //去除注释
        line = lnFirst
        lnFirstPos = 2 //第一行向左退2格
        while(line <= lnLast)
        {
            lineBuf = GetBufLine(hbuf,line)
            lineLen = strlen(lineBuf)
            szRight = TrimLeft(lineBuf)
            rightLen = strlen(szRight)
            if( rightLen == 0 )  //空行不处理
            {
                line = line + 1
                continue
            }

            leftLen = lineLen - rightLen
            pos = leftLen + 2
            newbuf = ""
            if( rightLen > 2 && szRight[2] == " ")
            {
                pos = pos + 1
                if( line == lnFirst )
                    lnFirstPos = lnFirstPos + 1
            }
            if( leftLen > 0 )
                newbuf = newbuf # strmid(lineBuf, 0,leftLen)
            newbuf = newbuf # strmid(lineBuf, pos,lineLen)
            DelBufLine(hbuf,line)
            InsBufLine(hbuf,line,newbuf)

            line = line + 1
        }
        sel.ichFirst = ichFirst - lnFirstPos
        sel.ichLim = ichLim - lnFirstPos
        SetWndSel(hwnd, sel)
    }
    else
    {
        //增加注释

        //查找最左边的非空字符
        minFirst = 9999
        line = Lnfirst
        while( line <= lnLast )
        {
            lineBuf = GetBufLine(hbuf,line)
            lineLen = strlen(lineBuf)
            szRight = TrimLeft(lineBuf)
            rightLen = strlen(szRight)
            if( rightLen == 0 )   //空行不处理
            {
                line = line + 1
                continue
            }
            if( lineLen - rightLen < minFirst )
            {
                minFirst = lineLen - rightLen
            }
            line = line + 1
        }
        //增加注释"// "
        line = lnFirst
        while( line <= lnLast )
        {
            lineBuf = GetBufLine(hbuf,line)

            sel.ichFirst = minFirst
            sel.ichLim = minFirst
            sel.lnFirst = line
            sel.lnLast = line
            SetWndSel(hwnd, sel)
            if( TrimLeft(lineBuf) != "" )
                SetBufSelText(hbuf, "// ")
            line = line + 1
        }
        sel.ichFirst = ichFirst + 3
        sel.ichLim = ichLim + 3
        sel.lnFirst = lnFirst
        sel.lnLast = lnLast
        SetWndSel(hwnd, sel)
    }
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
macro RunExe()
{

}

macro JumpCpp()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    bufname = GetBufName(hbuf)
    pos = strrstr(bufname,"\\",2)
    //没有找到，则取全部字符串
    if( pos == -1 )
    {
        pos = 0
    }

    filename = strmid(bufname,pos,strlen(bufname))
    len = strlen(filename)

    if( filename[len-2] == "." && filename[len-1] == "h" )
    {
        file = strmid(filename,0,len-1) # "cpp"
    }
    else
    {
        file = strmid(filename,0,len-3) # "h"
    }

    ifile = 0
    hproj = GetCurrentProj()
    ifileMax = GetProjFileCount (hproj)
    while (ifile < ifileMax )
    {
        file1 = GetProjFileName (hproj, ifile)
        len1 = strlen(file1)
        len = strlen(file)
        
        if( len1 < len )
        {    
            ifile = ifile + 1
            continue
        }
        if( strmid(file1,len1-len,len1) == file )
        {
            break
        }
        ifile = ifile + 1
    }

    if( ifile < ifileMax )
    {
        fbuf = OpenBuf(file1)
        SetCurrentBuf(fbuf)
    }
}

///\brief 添加函数Doxygen注释
///\param 空
///\return 无
macro AddFuncDoc()
{
    // Get a handle to the current file buffer and the name
    // and location of the current symbol where the cursor is.
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur( hbuf )

    buf = GetBufLine(hbuf,ln)
    blanks = GetBeginBlank(buf)
    InsBufLine( hbuf, ln, blanks # "/**" )
    InsBufLine( hbuf, ln + 1, blanks # " * \@brief " )
    InsBufLine( hbuf, ln + 2, blanks # " * \@param " )
    InsBufLine( hbuf, ln + 3, blanks # " * \@return " )
    InsBufLine( hbuf, ln + 4, blanks # " */" )
 
    // put the insertion point inside the header comment
    SetBufIns( hbuf, ln+1, strlen(blanks) + 10 )
}

macro AddDetailDoc()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur( hbuf )

    buf = GetBufLine(hbuf,ln)
    blanks = GetBeginBlank(buf)
    ln = ln + 1;InsBufLine( hbuf, ln, blanks # "//! " )
    line = ln
    ln = ln + 1;InsBufLine( hbuf, ln, "" )
    ln = ln + 1;InsBufLine( hbuf, ln, blanks # "//! " )
    ln = ln + 1;InsBufLine( hbuf, ln, blanks # "//! " )
 
    // put the insertion point inside the header comment
    SetBufIns( hbuf, line, strlen(blanks) + 4 )
}
macro AddBreifDoc()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur( hbuf )

    buf = GetBufLine(hbuf,ln)
    blanks = GetBeginBlank(buf)
    InsBufLine( hbuf, ln, blanks # "//! " )
 
    // put the insertion point inside the header comment
    SetBufIns( hbuf, ln, strlen(blanks) + 4 )
}
macro AddMemberDoc()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur( hbuf )

    buf = GetBufLine(hbuf,ln)
    pos = GetEndBlankPos(buf) + 1

    sel.ichFirst = pos
    sel.ichLim = pos
    SetWndSel(hwnd, sel)
    //SetBufSelText(hbuf, "/**<  */")
    SetBufSelText(hbuf, "///< ")
    SetBufIns( hbuf, ln, pos + 5 )
}
macro AddFileHeaderDoc()
{
    hbuf = GetCurrentBuf()
    ln = 0
    InsBufLine( hbuf, ln,    "/*" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *  ********************************************************************************")
    ln = ln + 1;InsBufLine( hbuf, ln,    " *                                     Challenger" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *                          Digital Video Recoder xp" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *   (c) Copyright 1992-2004, ZheJiang Dahua Information Technology Stock CO.LTD." )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *                            All Rights Reserved" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *  File        : Challenger.cpp" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *  Description : " )
    line = ln
    ln = ln + 1;InsBufLine( hbuf, ln,    " *  Create      : 2005/3/9      WHF     Create the file" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " *  ********************************************************************************" )
    ln = ln + 1;InsBufLine( hbuf, ln,    " */" )
    ln = ln + 1;InsBufLine( hbuf, ln,    "" )

    // put the insertion point inside the header comment
    SetBufIns( hbuf, line, 20 )
}

