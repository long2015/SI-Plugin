/*********************************************
SIHelper.em: Source Insight助手宏
**********************************************/

/* 打开书签管理 */
macro SIH_CodeFavor()
{
    if(0 == GetCurrentProj())
    {
        msg("Source Insight未打开工程!");
        return;
    }
    
    curFile = "";
    hwnd = GetCurrentWnd();
    if(hwnd != 0)
    {
        hbuf = GetWndBuf(hwnd)
        /* 得到当前文件 */    
        curFile = GetBufName(hbuf);

        /* 得到当前符号 */
        curSymbol = GetcurSymbol();        
    }

	/*构造调用参数*/
    Para = "-st \""; /*参数-s:从Source Insight中调用,-t:置顶*/
    Para = cat(Para,curFile);    
    Para = cat(Para,"|");
    Para = cat(Para,GetProjDir(GetCurrentProj()));    
    Para = cat(Para,"|");    
    Para = cat(Para,curSymbol);    
    Para = cat(Para,"\"");

    /* 调用CodeFav程序 */
    SIHPath = getreg(SIH_ProPath);
    SIHPath = cat(SIHPath, "CodeFav.exe");
    retRun  = ShellExecute("open", SIHPath, Para, "", 1);
    if(0 == retRun)
    {
        msg(cat("程序调用失败: ",SIHPath));    
    }
}


/* 添加书签 */
macro SIH_AddCodeFavor()
{
    if(0 == GetCurrentProj())
    {
        msg("Source Insight未打开工程!");    
        return;
    }
    
    curFile = "";
    hwnd = GetCurrentWnd();
    if(hwnd != 0)
    {
        hbuf = GetWndBuf(hwnd)
        /* 得到当前文件 */
        curFile = GetBufName(hbuf);

        /* 得到当前符号 */
        curSymbol = GetcurSymbol();        
    }

	/*构造调用参数*/
    Para = "-as \""; /*参数-a:添加符号模式;
                                      参数-s:表明是从Source Insight中调用的*/
    Para = cat(Para,curFile);    
    Para = cat(Para,"|");
    Para = cat(Para,GetProjDir(GetCurrentProj()));    
    Para = cat(Para,"|");    
    Para = cat(Para,curSymbol);    
    Para = cat(Para,"\"");

    /* 调用CodeFav程序 */
    SIHPath = getreg(SIH_ProPath);
    SIHPath = cat(SIHPath, "CodeFav.exe");
    retRun  = ShellExecute("open", SIHPath, Para, "", 1);
    if(retRun == 0)
    {
        msg(cat("程序调用失败: ",SIHPath));    
    }
}

/* 
插件返回处理
该宏由插件程序返回时自动调用
必须为该宏分配快捷键Ctrl+Alt+R
*/
macro SIH_OnEvent_Ctrl_Alt_R()
{
    retType = getreg(SIH_Ret_Type);
    retFile = getreg(SIH_Ret_File);
    retSymbol = getreg(SIH_Ret_Symbol);

    setreg(SIH_RETURN, "1"); //标识收到返回消息

    if(retType == "jump") //跳转到符号
    {
        JumpToSymbolDef(retSymbol);
    }
    else if(retType == "file") //打开文件
    {
        if(FALSE == openMiscFile(retFile))        
        {
            errormsg = "打开文件失败:";
            errormsg = cat(errormsg, retFile);
            msg(errormsg);
        }
    }
    else if(retType == "insert") //插入符号
    {
        hwnd = GetCurrentWnd();
        if(hwnd != 0)
        {
            hbuf = GetWndBuf(hwnd)
            memGet = getreg(MEM_GET);
            if(memGet != "")
                SetBufSelText(hwnd, memGet);
        }    
    }
}

/* 导出搜索结果(SearchResult)中的所有文件 */
macro SIH_SearchExport()
{
    if(0 == GetCurrentProj())
    {
        msg("Source Insight未打开工程!");    
        return;
    }

    curFile = "";
    hwnd = GetCurrentWnd();
    if(hwnd != 0)
    {
        hbuf = GetWndBuf(hwnd)
        /* 得到当前文件 */
        curFile = GetBufName(hbuf);
        /* 得到当前符号 */
        curSymbol = GetcurSymbol();        
    }

	/*构造调用参数*/
    Para = "\"";
    Para = cat(Para,curFile);    
    Para = cat(Para,"|");
    Para = cat(Para,GetProjDir(GetCurrentProj()));    
    Para = cat(Para,"\"");

    /* 调用SearchExport程序 */
    SIHPath = getreg(SIH_ProPath);
    SIHPath = cat(SIHPath, "SearchExport.exe");
    retRun  = ShellExecute("open", SIHPath, Para, "", 1);
    if(0 == retRun)
    {
        msg(cat("程序调用失败: ",SIHPath));    
    }
}

