/*======================================================================
* -------Source Insight3 中文操作(左右键、删除和后退键）支持宏-------
* 用原来作者提供的方法使用工程中有的问题，于是换了种方式试了一下，测试OK，
* 现在只需按照下面的说明①--③应用即可，已经测试OK
* 感谢丁兆杰（zhaojie.ding@gmail.com）及互联网上辛勤耕耘的朋友们！！！  
*                                                 Evan: sdcw@163.com
*
* ① Project→Open Project，打开Base项目，将本文中的所有内容函数复制到utils.em文件的最后
* ② 重启SourceInsight；
* ③ Options→Key Assignments，将下面宏依次与相应按键绑定：
          Marco: SuperBackspace绑定到BackSpace键；
          Marco: SuperCursorLeft绑定到<-键，
          Marco: SuperCursorRight绑定到->键，
          Marco: SuperShiftCursorLeft绑定到Shift+<-，
          Macro: SuperShiftCursorRight绑定到shift+->，
          Macro: SuperDelete绑定到del。
* ④ Enjoy
------------解决source insight 中文间距的方法：-----------------     
默认情况下，往Source Insight里输入中文，字间距相当的大，要解决这个问题，具体设置如下：
1.Options->Style Properties
2. 在左边Style Name下找到Comment Multi Line和Comment.在其右边对应的Font属性框下的
Font Name中选“Pick...” 设置为宋体、常规、小四。确定，退回Style Properties界面，
Size设为10。最后设置Clolors框下Foreground，点“Pick...”选择一种自己喜欢的颜色就OK了。
3.Done
======================================================================*/
/*======================================================================
1、BackSpace后退键
======================================================================*/
macro SuperBackspace()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
        stop;   // empty buffer
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " ");  // stupid & buggy sourceinsight 
        // del the " "
        SuperBackspace(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);
    // if the cursor is at the start of line, combine with prev line
    if (ipos == 0 || len == 0) {
        if (ln <= 0)
            stop;   // top of file
        ln = ln - 1;    // do not use "ln--" for compatibility with older versions
        prevline = GetBufLine(hbuf, ln);
        prevlen = strlen(prevline);
        // combine two lines
        text = cat(prevline, text);
        // del two lines
        DelBufLine(hbuf, ln);
        DelBufLine(hbuf, ln);
        // insert the combined one
        InsBufLine(hbuf, ln, text);
        // set the cursor position
        SetBufIns(hbuf, ln, prevlen);
        stop;
    }
    num = 1; // del one char
    if (ipos >= 1) {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i - 1]) >= 160) {
            i = i - 1;
            count = count + 1;
            if (i == 0)
                break;
        }
        if (count > 0) {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if ((count / 2 * 2 != count) && (ipos < len))
                ipos = ipos + 1;    // adjust cursor position
        }
    }
    // keeping safe
    if (ipos - num < 0)
        num = ipos;
    // del char(s)
    text = cat(strmid(text, 0, ipos - num), strmid(text, ipos, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos - num);
    stop;
}
/*======================================================================
2、删除键——SuperDelete.em
======================================================================*/
macro SuperDelete()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
        stop;   // empty buffer
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight 
        // del the " "
        SuperDelete(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);
      
    if (ipos == len || len == 0) {
totalLn = GetBufLineCount (hbuf);
lastText = GetBufLine(hBuf, totalLn-1);
lastLen = strlen(lastText);
        if (ipos == lastLen)// end of file
   stop;
        ln = ln + 1;    // do not use "ln--" for compatibility with older versions
        nextline = GetBufLine(hbuf, ln);
        nextlen = strlen(nextline);
        // combine two lines
        text = cat(text, nextline);
        // del two lines
        DelBufLine(hbuf, ln-1);
        DelBufLine(hbuf, ln-1);
        // insert the combined one
        InsBufLine(hbuf, ln-1, text);
        // set the cursor position
        SetBufIns(hbuf, ln-1, len);
        stop;
    }
    num = 1; // del one char
    if (ipos > 0) {
        // process Chinese character
        i = ipos;
        count = 0;
      while (AsciiFromChar(text[i-1]) >= 160) {
            i = i - 1;
            count = count + 1;
            if (i == 0)
                break;
        }
        if (count > 0) {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if (((count / 2 * 2 != count) || count == 0) && (ipos < len-1))
                ipos = ipos + 1;    // adjust cursor position
        }
// keeping safe
if (ipos - num < 0)
            num = ipos;
    }
    else {
i = ipos;
count = 0;
while(AsciiFromChar(text) >= 160) {
     i = i + 1;
     count = count + 1;
     if(i == len-1)
   break;
}
if(count > 0) {
     num = 2;
}
    }
   
    text = cat(strmid(text, 0, ipos), strmid(text, ipos+num, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos);
    stop;
}
/*======================================================================
3、左移键——SuperCursorLeft.em
======================================================================*/
macro IsComplexCharacter()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
   return 0;
//当前位置
pos = GetWndSelIchFirst(hwnd);
//当前行数
ln = GetBufLnCur(hbuf);
//得到当前行
text = GetBufLine(hbuf, ln);
//得到当前行长度
len = strlen(text);
//从头计算汉字字符的个数
if(pos > 0)
{
   i=pos;
   count=0;
   while(AsciiFromChar(text[i-1]) >= 160)
   { 
    i = i - 1;
    count = count+1;
    if(i == 0) 
     break;
   }
   if((count/2)*2==count|| count==0)
    return 0;
   else
    return 1;
}
return 0;
}
macro moveleft()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
        stop;   // empty buffer
       
ln = GetBufLnCur(hbuf);
ipos = GetWndSelIchFirst(hwnd);
if(GetBufSelText(hbuf) != "" || (ipos == 0 && ln == 0))   // 第0行或者是选中文字,则不移动
{
   SetBufIns(hbuf, ln, ipos);
   stop;
}
if(ipos == 0)
{
   preLine = GetBufLine(hbuf, ln-1);
   SetBufIns(hBuf, ln-1, strlen(preLine)-1);
}
else
{
   SetBufIns(hBuf, ln, ipos-1);
}
}
macro SuperCursorLeft()
{
moveleft();
if(IsComplexCharacter())
   moveleft();
}
/*======================================================================
4、右移键——SuperCursorRight.em
======================================================================*/
macro moveRight()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
        stop;   // empty buffer
ln = GetBufLnCur(hbuf);
ipos = GetWndSelIchFirst(hwnd);
totalLn = GetBufLineCount(hbuf);
text = GetBufLine(hbuf, ln); 
if(GetBufSelText(hbuf) != "")   //选中文字
{
   ipos = GetWndSelIchLim(hwnd);
   ln = GetWndSelLnLast(hwnd);
   SetBufIns(hbuf, ln, ipos);
   stop;
}
if(ipos == strlen(text)-1 && ln == totalLn-1) // 末行
   stop;      
if(ipos == strlen(text))
{
   SetBufIns(hBuf, ln+1, 0);
}
else
{
   SetBufIns(hBuf, ln, ipos+1);
}
}
macro SuperCursorRight()
{
moveRight();
if(IsComplexCharacter()) // defined in SuperCursorLeft.em
   moveRight();
}
/*======================================================================
5、shift+右移键——ShiftCursorRight.em
======================================================================*/
macro IsShiftRightComplexCharacter()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
   return 0;
selRec = GetWndSel(hwnd);
pos = selRec.ichLim;
ln = selRec.lnLast;
text = GetBufLine(hbuf, ln);
len = strlen(text);
if(len == 0 || len < pos)
return 1;
//Msg("@len@;@pos@;");
if(pos > 0)
{
   i=pos;
   count=0; 
   while(AsciiFromChar(text[i-1]) >= 160)
   { 
    i = i - 1;
    count = count+1;   
    if(i == 0) 
     break;    
   }
   if((count/2)*2==count|| count==0)
    return 0;
   else
    return 1;
}
return 0;
}
macro shiftMoveRight()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
        stop; 
       
ln = GetBufLnCur(hbuf);
ipos = GetWndSelIchFirst(hwnd);
totalLn = GetBufLineCount(hbuf);
text = GetBufLine(hbuf, ln); 
selRec = GetWndSel(hwnd);   
curLen = GetBufLineLength(hbuf, selRec.lnLast);
if(selRec.ichLim == curLen+1 || curLen == 0)
{ 
   if(selRec.lnLast == totalLn -1)
    stop;
   selRec.lnLast = selRec.lnLast + 1; 
   selRec.ichLim = 1;
   SetWndSel(hwnd, selRec);
   if(IsShiftRightComplexCharacter())
    shiftMoveRight();
   stop;
}
selRec.ichLim = selRec.ichLim+1;
SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorRight()
{       
if(IsComplexCharacter())
   SuperCursorRight();
shiftMoveRight();
if(IsShiftRightComplexCharacter())
   shiftMoveRight();
}
/*======================================================================
6、shift+左移键——ShiftCursorLeft.em
======================================================================*/
macro IsShiftLeftComplexCharacter()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
   return 0;
selRec = GetWndSel(hwnd);
pos = selRec.ichFirst;
ln = selRec.lnFirst;
text = GetBufLine(hbuf, ln);
len = strlen(text);
if(len == 0 || len < pos)
   return 1;
//Msg("@len@;@pos@;");
if(pos > 0)
{
   i=pos;
   count=0; 
   while(AsciiFromChar(text[i-1]) >= 160)
   { 
    i = i - 1;
    count = count+1;   
    if(i == 0) 
     break;    
   }
   if((count/2)*2==count|| count==0)
    return 0;
   else
    return 1;
}
return 0;
}
macro shiftMoveLeft()
{
hwnd = GetCurrentWnd();
hbuf = GetCurrentBuf();
if (hbuf == 0)
        stop; 
       
ln = GetBufLnCur(hbuf);
ipos = GetWndSelIchFirst(hwnd);
totalLn = GetBufLineCount(hbuf);
text = GetBufLine(hbuf, ln); 
selRec = GetWndSel(hwnd);   
//curLen = GetBufLineLength(hbuf, selRec.lnFirst);
//Msg("@curLen@;@selRec@");
if(selRec.ichFirst == 0)
{ 
   if(selRec.lnFirst == 0)
    stop;
   selRec.lnFirst = selRec.lnFirst - 1;
   selRec.ichFirst = GetBufLineLength(hbuf, selRec.lnFirst)-1;
   SetWndSel(hwnd, selRec);
   if(IsShiftLeftComplexCharacter())
    shiftMoveLeft();
   stop;
}
selRec.ichFirst = selRec.ichFirst-1;
SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorLeft()
{
if(IsComplexCharacter())
   SuperCursorLeft();
shiftMoveLeft();
if(IsShiftLeftComplexCharacter())
   shiftMoveLeft();
}
/*---END---*/ 


