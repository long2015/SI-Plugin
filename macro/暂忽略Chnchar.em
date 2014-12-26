/****************************************************************************
 *  Ver:    1.13
 *  Date:   2002.9.18
 *  Author: suqiyuan
 * ================================
 * 这里有几个宏可以用来部分支持汉字:
 * 使用这些宏重载对应的键就可以了
 *
 * 重载关系如下:
 * EM_delete:            DELETE
 * EM_backspace:         BACKSPACE
 * EM_CursorUp:          ↑（上方向键）
 * EM_CursorDown:        ↓（下方向键）
 * EM_CursorLeft:        ←（左方向键）
 * EM_CursorRight:       →（右方向键）
 * EM_SelectWordLeft:    Shift + ←
 * EM_SelectWordRight:   Shift + →
 * EM_SelectLineUp:      Shift + ↑
 * EM_SelectLineUp:      Shift + ↓
 ****************************************************************************/
 
 //For keyboard delete
 Macro EM_delete()
 {
    //get current character
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    ln      = GetWndSelLnFirst(hWnd)
    lnLast  = GetWndSelLnLast(hWnd)
    lnCnt   = lnLast - ln + 1
    sel     = GetWndSel(hWnd)
    ich     = GetWndSelIchFirst(hWnd)
    ichLast = GetWndSelIchLim(hWnd)
    hBuf    = GetWndBuf(hWnd)
    curLine = GetBufLine(hBuf,ln)

    //Msg("Now Select lines:@lnCnt@,Line @ln@ index @ich@ to line @lnLast@ index @ichLast@")
    if((lnCnt > 1) || ((lnCnt==1)&&(ichLast>ich)))//选择的是块
    {
        //Msg("Selection is One BLOCK.")
        curLine = GetBufLine(hBuf,ln)
        if(ich>0)
        {
            index = 0
            while(index < ich)
            {
                ch = curLine[index]
                if(SearchCharInTab(ch))
                    index = index + 1
                else
                    index = index + 2
            }
            //如果块首在汉字中间，块首向前调整一个字节
            sel.ichFirst = ich - (index-ich)
        }
        curLine = GetBufLine(hBuf,lnLast)
        len     = GetBufLineLength(hBuf,lnLast)
        index   = 0
        while(index < ichLast && index < len)
        {
            ch = curLine[index]
            if(SearchCharInTab(ch))
                index = index + 1
            else
                index = index + 2
        }
        sel.ichLim = index
        if(ichLast>len)
            sel.ichLim = ichLast
        SetWndSel(hWnd,sel)
        //Msg("See the block selected is adjusted now.")
        Delete_Character
    }
    else//选择的不是块
    {
        //Msg("Selection NOT block.")
        curChar = curLine[ich]
        //如果在行末,应该能够使得下一行连到行尾
        if(ich == strlen(curLine))
        {
            Delete_Character
            stop
        }
        //Msg("Not at the end of line.")
        flag    = SearchCharInTab(curChar)
        //Msg("Current char:@curChar@,Valid flag:@flag@")
        if(flag)
        {
            //Msg("Byte location to delete:@ich@,Current char:@curChar@")
            DelCharOfLine(hWnd,ln,ich,1)
        }
        else
        {
            /*这里的实现方法是这样的:从行首开始找,如果是Table中的,加一继续
             *如果不是,加二继续,一直到当前字符,决定怎么删除
             *这里有这样的假定,当前行没有半个汉字的情形
             */
            index = 0
            word  = 0
            byte  = 0
            len   = strlen(curLine)
            while(index < ich)
            {
                ch   = curLine[index]
                flag = SearchCharInTab(ch)
                if(flag)
                {
                    index = index + 1
                    byte  = byte + 1
                }
                else
                {
                    index = index + 2
                    word  = word + 1
                }
            }
            //index = ich + 1,current cursor is in the middle of word
            //                or in the front of byte
            //index = ich,current cursor is NOT in the front of word
            nich = 2*(word-(index-ich)) + byte
            //Msg("Start deleting position:@ich@,word:@word@,byte:@byte@")
            DelCharOfLine(hWnd,ln,nich,2)
            if((index-ich) && !flag && (ich != len-1))//当在一个不在末尾的汉字中间
                Cursor_Left
        }
    }
}

//For keyboard backspace <-
Macro EM_backspace()
{
    //get current character
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    sel     = GetWndSel(hWnd)
    ln      = sel.lnFirst
    ich     = sel.ichFirst
    if(ich < 0)
        stop
    lnLast  = GetWndSelLnLast(hWnd)
    lnCnt   = lnLast - ln + 1
    ichLast = GetWndSelIchLim(hWnd)

    //Msg("Now Select lines:@lnCnt@,Line @ln@ index @ich@ to line @lnLast@ index @ichLast@")
    if((lnCnt > 1) || ((lnCnt==1)&&(ichLast>ich)))//选择的是块,直接删除调整后的块
    {
        EM_delete
    }
    else
        {if(ich == 0)
        {
            Backspace
            stop
        }
        hBuf    = GetWndBuf(hWnd)
        curLine = GetBufLine(hBuf,ln)

        index = 0
        flag  = 0  // 1-byte,0-word
        byte = 0
        word = 0
        while(index < ich)
        {
            ch   = curLine[index]
            flag = SearchCharInTab(ch)
            if(flag)
                {
                    byte  = byte + 1
                    index = index + 1
                }
            else
                {
                    word  = word + 1
                    index = index + 2
                }
        }
        if(flag)//char before cursor is in table
        {
            //Msg("char before cursor is in table,byte!")
            Backspace
        }
        else if(!flag && (index-ich))//current cursor is in the middle of word
        {
            //Msg("current cursor is in the middle of word.")
            DelCharOfLine(hWnd,ln,ich-1,2)
            if(!(sel.ichFirst == strlen(curLine)-1))
                Cursor_Left
        }
        else if(!flag && !(index-ich))//Current cursor is after a word
        {
            //Msg("Current cursor is after a word.")
            DelCharOfLine(hWnd,ln,ich-2,2)
            if(sel.ichFirst != strlen(curLine))
            {
                Cursor_Left
                Cursor_Left
            }
        }
    }
}

Macro SearchCharInTab(curChar)
{
     /* Total 97 chars */
    AsciiChar = AsciiFromChar(curChar)
    //Msg("Current char in SearchCharInTab():@curChar@.")
    if(AsciiChar >= 32 && AsciiChar <= 126)
        return 1
    //Msg("Current Char(@curChar@) NOT between space and ~")
    if(AsciiChar == 9)//Tab
        return 1
    //Msg("Current Char(@curChar@) NOT Tab")
    if(AsciiChar == 13)//CR
        return 1
    //Msg("Current Char(@curChar@) Not CR")
    return 0
}

Macro DelCharOfLine(hWnd,ln,ich,count)
{
    if(hWnd == 0)
        stop
    sel     = GetWndSel(hWnd)
    hBuf    = GetWndBuf(hWnd)
    if(hBuf == 0)
        stop
    if(ln > GetBufLineCount(hBuf))
        stop
    szLine = GetBufLine(hBuf,ln)
    len    = strlen(szLine)
    if(ich >  len)
        stop

    NewLine = ""
    if(ich > 0)
    {
        NewLine = NewLine # strmid(szLine,0,ich)
    }
    if(ich+count < len)
    {
        ichLast = len
        NewLine = NewLine # strmid(szLine,ich+count,ichLast)
    }
    /**/
    //Msg("Current line:@szLine@")
    //Msg("Replaced as:@NewLine@")
    /**/
    PutBufLine(hBuf,ln,NewLine)
    SetWndSel(hWnd, sel)
}


//上移光标
macro EM_CursorUp()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop

    hbuf = GetCurrentBuf()

    //移动光标
    Cursor_Up

    //检查移动光标后的光标位置
    hwnd = GetWndhandle(hbuf)
    sel = GetWndSel(hwnd)
    str = GetBufline(hbuf, sel.lnFirst)

    flag = StrChinChk(str, sel.ichFirst)
    //光标位于中文字符之中则向前移动一个字符
    if (flag == True)
    {
        Cursor_Left
    }
}

//下移光标
macro EM_CursorDown()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop

    hbuf = GetCurrentBuf()

    //移动光标
    Cursor_Down

    //检查移动光标后的光标位置
    hwnd = GetWndhandle(hbuf)
    sel = GetWndSel(hwnd)
    str = GetBufline(hbuf, sel.lnFirst)

    flag = StrChinChk(str, sel.ichFirst)
    //光标位于中文字符之中则向前移动一个字符
    if (flag == True)
    {
        Cursor_Right
    }
}


//右移光标
macro EM_CursorRight()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop

    hbuf = GetCurrentBuf()

    //移动光标
    Cursor_Right

    //检查移动光标后的光标位置
    hwnd = GetWndhandle(hbuf)
    sel = GetWndSel(hwnd)
    str = GetBufline(hbuf, sel.lnFirst)

    flag = StrChinChk(str, sel.ichFirst)
    //光标位于中文字符之中则向前移动一个字符(向后移时是再向后移动一个字符)
    if (flag == True)
    {
        Cursor_Right
    }
}

//左移光标
macro EM_CursorLeft()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop

    hbuf = GetCurrentBuf()

    //移动光标
    Cursor_Left

    //检查移动光标后的光标位置
    hwnd = GetWndhandle(hbuf)
    sel = GetWndSel(hwnd)
    str = GetBufline(hbuf, sel.lnFirst)

    flag = StrChinChk(str, sel.ichFirst)
    //光标位于中文字符之中则向前移动一个字符(向后移时是再向后移动一个字符)
    if (flag == True)
    {
        Cursor_Left
    }
}

//向左选择字符
macro EM_SelectWordLeft()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    hbuf = GetCurrentBuf()

    //执行命令
    Select_Char_Left

    hwnd = GetWndhandle(hbuf)
    //selold = GetWndSel(hwnd)
    sel = GetWndSel(hwnd)
    //ln = GetBufLnCur(hbuf)

    /*
    if (selold.ichFirst == sel.ichFirst && sel.lnFirst == selold.lnFirst)
        curinhead = 1
    else
        curinhead = 0
    */
    str = GetBufline(hbuf, sel.lnFirst)
    hdflag = StrChinChk(str, sel.ichFirst)

    str = GetBufline(hbuf, sel.lnLast)
    bkflag = StrChinChk(str, sel.ichLim)

    if (hdflag == TRUE || bkflag == TRUE)
    {
        Select_Char_Left
    }
}

//向右选择字符
macro EM_SelectWordRight()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    hbuf = GetCurrentBuf()

    //执行命令
    Select_Char_Right

    hwnd = GetWndhandle(hbuf)
    //selold = GetWndSel(hwnd)
    sel = GetWndSel(hwnd)
    //ln = GetBufLnCur(hbuf)

    /*
    if (selold.ichFirst == sel.ichFirst && sel.lnFirst == selold.lnFirst)
        curinhead = 1
    else
        curinhead = 0
    */
    str = GetBufline(hbuf, sel.lnFirst)
    hdflag = StrChinChk(str, sel.ichFirst)

    str = GetBufline(hbuf, sel.lnLast)
    bkflag = StrChinChk(str, sel.ichLim)

    if (hdflag == TRUE || bkflag == TRUE)
    {
        Select_Char_Right
    }
}

//向上选择字符
macro EM_SelectLineUp()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    hbuf = GetCurrentBuf()

    //执行命令
    Select_Line_Up

    hwnd = GetWndhandle(hbuf)
    //selold = GetWndSel(hwnd)
    sel = GetWndSel(hwnd)
    //ln = GetBufLnCur(hbuf)

    /*
    if (selold.ichFirst == sel.ichFirst && sel.lnFirst == selold.lnFirst)
        curinhead = 1
    else
        curinhead = 0
    */
    str = GetBufline(hbuf, sel.lnFirst)
    hdflag = StrChinChk(str, sel.ichFirst)

    str = GetBufline(hbuf, sel.lnLast)
    bkflag = StrChinChk(str, sel.ichLim)

    if (hdflag == TRUE || bkflag == TRUE)
    {
        Select_Char_Right
    }
}

//向下选择字符
macro EM_SelectLineDown()
{
    hWnd = GetCurrentWnd()
    if(hWnd == 0)
        stop
    hbuf = GetCurrentBuf()

    //执行命令
    Select_Line_Down

    hwnd = GetWndhandle(hbuf)
    //selold = GetWndSel(hwnd)
    sel = GetWndSel(hwnd)
    //ln = GetBufLnCur(hbuf)

    /*
    if (selold.ichFirst == sel.ichFirst && sel.lnFirst == selold.lnFirst)
        curinhead = 1
    else
        curinhead = 0
    */
    str = GetBufline(hbuf, sel.lnFirst)
    hdflag = StrChinChk(str, sel.ichFirst)

    str = GetBufline(hbuf, sel.lnLast)
    bkflag = StrChinChk(str, sel.ichLim)

    if (hdflag == TRUE || bkflag == TRUE)
    {
        Select_Char_Right
    }
}

//对字符串str到ln位进行检查
//如果有偶数个中文字符则返回FALSE
//如果是奇数个中文字符则返回TRUE
macro StrChinChk(str, ln)
{
    tm  = 0
    flag = False
    len  = strlen(str)
    while (tm < ln)
    {
        if (str[tm] != "")
            ascstr = asciifromchar(str[tm])
        else
            ascstr = 0

        //中文字符ASCII > 128
        if (ascstr > 128)
            flag = !flag

        tm = tm + 1
        if (tm >= len)
            break
    }
    return flag
}

// 在工程中查找半个汉字,依赖"macro OpenorNewBuf(szfile)"
macro FindHalfChcharInProj()
{
    hprj = GetCurrentProj()
    if (hprj == 0)
        stop
    ifileMax = GetProjFileCount(hprj)
    
    hOutBuf = OpenorNewBuf("HalfChch.txt")
    if (hOutBuf == hNil)
    {
        Msg("Can't Open file:HalfChchar.txt")
        stop
    }
    AppendBufLine(hOutBuf, ">>半个汉字列表>>")
    
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName(hprj, ifile)
        hbuf = OpenBuf(filename)
        if (hbuf != 0)
        {
            StartMsg("@filename@ is being processing. . . press ESC to cancel.")
            iTotalLn = GetBufLineCount(hbuf)
            iCurLn = 0
            while (iCurLn < iTotalLn)
            {
                str = GetBufline(hbuf, iCurLn)
                flag = StrChinChk(str, strlen(str))
                if (flag == True)
                {
                    // 存在半个汉字,记录文件名和行号
                    iOutLn = iCurLn + 1
                    outstr = cat(filename, "(@iOutLn@) : ")
                    outstr = cat(outstr, str)
                    AppendBufLine(hOutBuf, outstr)
                    SetSourceLink(hOutBuf,GetBufLineCount(hOutBuf)-1,filename,iCurLn)
                }
                iCurLn = iCurLn + 1
            }
            EndMsg()
        }
        ifile = ifile + 1
    }
    //SetCurrentBuf(hOutBuf)
    //Go_To_First_Link
}

// 如果没有szfile指明的文件打开,则新建,否则打开,并返回BUFF句柄
macro OpenorNewBuf(szfile)
{
    hout = GetBufHandle(szfile)
    if (hout == hNil)
    {
        hout = OpenBuf(szfile)
        if (hout == hNil)
        {
            hout = NewBuf(szfile)
            NewWnd(hout)
        }
    }
    return hout
}
