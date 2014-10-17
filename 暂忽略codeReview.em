/* version 1.1.1 */

macro Review_Restore_Link()
{
	hbuf = GetCurrentBuf()

	sProjRoot = GetProjDir(GetCurrentProj())
	sProjRoot = Cat(sProjRoot, "\\")

	line = 0
	while(True)
	{
		sel = SearchInBuf(hbuf, "FileName : ", line, 0, 1, 0, 0)
		if(sel == "") break

		line = sel.lnFirst
		col = sel.ichLim
		str = GetBufLine(hbuf, line)
		fileName = strmid(str, col, strlen(str))
		fileName = cat(sProjRoot, fileName)
				
		str = GetBufLine(hbuf, line+1)
		lnNumber = strmid(str, 11, strlen(str))
		SetSourceLink(hbuf, line + 2, fileName, lnNumber - 1)
		line = line+2
	}
	
	//updateSummary(hbuf)
}

macro Review_Add_Comment()
{
	hbuf = GetCurrentBuf()
	curFileName = GetBufName(hbuf)
	curFunc = GetCurSymbol()
	curLineNumber = GetBufLnCur(hbuf)

	sProjRoot = GetProjDir(GetCurrentProj())
	nPos = strlen(sProjRoot)
	sFileName = strmid(curFileName, nPos+1, strlen(curFileName))
	sLocation = cat("Location : ",sFileName);
	sFileName = cat( "FileName : ", sFileName )
	sLineNumber = cat( "Line     : ", curLineNumber + 1 )
	sLocation = cat(sLocation,"/L");
	sLocation = cat(sLocation,curLineNumber + 1);
	
	promote = "Defect : D,d(Defect); Q,q(Query)"
	sTemp = ask(promote);
	sTemp = toupper(sTemp[0]);
	while( sTemp != "D" && sTemp != "Q")
	{
		sTemp = ask(cat("Please input again! ", promote));
		sTemp = toupper(sTemp[0]);
	}

	if( sTemp == "D" ) sTemp = "Defect缺陷";
	else if ( sTemp == "Q" ) sTemp = "Query疑问";
	sClass = cat("Class    : ",sTemp);
		
	/* get the severity of the current comment */
	if(sTemp == "Defect缺陷")
	{
		promote = "Severity : G,g(General); S,s(Suggest); M,m(Major)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "G" && sTemp != "S" && sTemp != "M" )
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}
	
		if( sTemp == "G" ) sTemp = "General一般";
		else if ( sTemp == "S" ) sTemp = "Suggest提示";
		else if ( sTemp == "M" ) sTemp = "Major严重";
		sSeverity = cat( "Severity : ", sTemp );
		// end of get the severity of the current comment
		
		/* get Categories */
		promote = "Categories : S,s(SRS); H,h(HLD); L,l(LLD); T,t(TP); C,c(Code); U,u(Um)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "S" && sTemp != "H" && sTemp != "L" 
			&& sTemp != "T" && sTemp != "C" && sTemp != "U")
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}
		
		if( sTemp == "S" ) sTemp = "SRS软件需求";
		else if ( sTemp == "H" ) sTemp = "HLD概要设计";
		else if ( sTemp == "L" ) sTemp = "LLD详细设计";
		else if ( sTemp == "T" ) sTemp = "TP测试计划";
		else if ( sTemp == "C" ) sTemp = "Code代码";  
		else if ( sTemp == "U" ) sTemp = "UM用户手册";
		sCategories = cat( "Categories : ", sTemp );
		//end of get categores
		
		/* get defect type */
		promote = "Categories : I,i(接口); F,f(功能); B,b(构建/打包); A,a(赋值); D,d(文档); C,c(校验); L,l(算法); T,t(时序/顺序缺陷); O,o(其它)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "I" && sTemp != "F" && sTemp != "B" 
			&& sTemp != "A" && sTemp != "D" && sTemp != "C"
			&& sTemp != "L" && sTemp != "T" && sTemp != "O")
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}
		
		if( sTemp == "I" ) sTemp = "Interface接口";
		else if ( sTemp == "F" ) sTemp = "Function功能";
		else if ( sTemp == "B" ) sTemp = "Build/Package构建/打包";
		else if ( sTemp == "A" ) sTemp = "Assignment赋值";
		else if ( sTemp == "D" ) sTemp = "Documentation文档";  
		else if ( sTemp == "C" ) sTemp = "Checking校验";
		else if ( sTemp == "L" ) sTemp = "aLgorithm算法";
		else if ( sTemp == "T" ) sTemp = "Timing/Serialization时序/顺序缺陷";
		else if ( sTemp == "O" ) sTemp = "Others其它";
		sDefectType = cat( "DefectType : ", sTemp );
		/* end of get defect type */
	}
	else
	{
		sTemp = " ";
		sSeverity = cat( "Severity : ", sTemp );
		sCategories = cat( "Categories : ", sTemp );
		sDefectType = cat( "DefectType : ", sTemp );
	}
	
	/* get the comment */
	promote = "Input your comment:"
	sTemp = ask(promote);
	sComments = cat( "Comments : ", sTemp );
	
	/* get the licence user name for the reviewer name */
	progRecord = GetProgramEnvironmentInfo()
	sMyName = progRecord.UserName

	/* get the ReviewComment buffer handle */
	bNewCreated = false; // used for the review comment is firstly created
	hout = GetBufHandle("ReviewComment.txt")
	if (hout == hNil)
	{
		// No existing Review Comment buffer
		hout= OpenBuf ("ReviewComment.txt")
		if( hout == hNil )
		{
			/* No existing ReviewComment.txt, then create a new review comment buffer */
			hout = NewBuf("ReviewComment.txt")
			NewWnd(hout)
			bNewCreated = true
			
			/*----------------------------------------------------------------*/
			/* Get the owner's name from the environment variable: MYNAME.    */
			/* If the variable doesn't exist, then the owner field is skipped.*/
			/*----------------------------------------------------------------*/
			AppendBufLine(hout, cat("Reviewer Name : ", sMyName))
			
			AppendBufLine(hout, "-------------------------------------------------------------------------")
		}
	} // end of get ReviewComment buffer handle

	delConver123(hout)
	delSummary(hout)
	AppendBufLine(hout, "")
	AppendBufLine(hout, sFileName)
	AppendBufLine(hout, sLineNumber)
	AppendBufLine(hout, sLocation)
	AppendBufLine(hout, cat("Reviewer : ", sMyName))
	AppendBufLine(hout, cat("Symbol   : ", curFunc) )
	AppendBufLine(hout, sCategories)
	AppendBufLine(hout, sClass)
	AppendBufLine(hout, sSeverity)
	AppendBufLine(hout, sDefectType)
	AppendBufLine(hout, "Status   : Open")
	AppendBufLine(hout, sComments)
	AppendBufLine(hout, "Resolve : ")
	AppendBufLine(hout, "Author : ")

	lnSource = GetBufLineCount(hout) - 11
	SetSourceLink(hout, lnSource, curFileName, curLineNumber)
	//updateSummary(hout)
	if( bNewCreated ) SetCurrentBuf(hbuf)
	jump_to_link;
}

macro Review_Summary()
{
	hbuf = GetCurrentBuf()
	updateSummary(hbuf)
}

macro Review_Output_123()
{
	sSign123 = "-----------------------Convert to lotus123 format------------------------------------------------"
	rvTitle = "it1=\"FileName :\";it2=\"评审人员\t\";it3=\"描述\t\";it4=\"位置\t\";it5=\"问题类型\t\";it6=\"严重级别\t\";it7=\"缺陷来源\t\";it8=\"缺陷类型\t\";it9=\"作者修改说明\t\";it10=\"状态\t\""
	//rvObj = "it1=\"FileName :\";it2=\"Reviewer :\";it3=\"Comments :\";it4=\"Location :\";it5=\"Class    :\";it6=\"Severity :\";it7=\"Categories :\";it8=\"DefectType :\";it9=\"Resolve :\";it10=\"Status   :\""
	
	hbuf = GetCurrentBuf()
	
	delConver123(hbuf)
	
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "")
	
	AppendBufLine(hbuf, sSign123)
	sOutput = cat(rvTitle.it2,rvTitle.it3)
	sOutput = cat(sOutput,rvTitle.it4)
	sOutput = cat(sOutput,rvTitle.it5)
	sOutput = cat(sOutput,rvTitle.it6)
	sOutput = cat(sOutput,rvTitle.it7)
	sOutput = cat(sOutput,rvTitle.it8)
	sOutput = cat(sOutput,rvTitle.it9)
	sOutput = cat(sOutput,rvTitle.it10)
	AppendBufLine(hbuf, sOutput)
	AppendBufLine(hbuf, "-------------------------------------------------------------------------------------------------")
		
	ln = 0
	while (True)
	{
		sOutput = ""
		sel = SearchInBuf(hbuf, "^FileName\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break
		
		ln = sel.lnFirst
		col = sel.ichLim
		
		tpsel = SearchInBuf(hbuf, "^Reviewer\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Comments\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Location\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Class\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Severity\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Categories\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^DefectType\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Resolve\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		tpsel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,"\t")
		}
		
		AppendBufLine(hbuf, sOutput)
		
		tpsel = SearchInBuf(hbuf, "^Author\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
			tpln = tpsel.lnFirst
		else
			tpln = ln + 9
		
		ln = tpln + 1
	}
	
}

macro updateSummary(hbuf)
{
	rvSum0 = getReviewSummary(hbuf)
	rvSum = "general=\"0\";suggest=\"0\";major=\"0\";query=\"0\";open=\"0\";closed=\"0\";rejected=\"0\";SysReq=\"0\";SDes=\"0\";SRS=\"0\";HLD=\"0\";LLD=\"0\";TP=\"0\";Code=\"0\";Docs=\"0\";Others=\"0\""
	
    /* summary the severity */
	ln = 0
	while (True)
	{
		sel = SearchInBuf(hbuf, "^Severity\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break
		
		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		if((col + 1) > strlen(s))
		{
			rvSum.query = rvSum.query + 1
			ln = ln + 1;
			continue;
		}
		sTemp = strmid(s, col, col+1)
		sTemp = toupper(sTEmp);
		
		if (sTemp == "G" && norejected(hbuf, ln)) 
			rvSum.general = rvSum.general + 1
		else if (sTemp == "S" && norejected(hbuf, ln))
			rvSum.suggest = rvSum.suggest + 1
		else if (sTemp == "M" && norejected(hbuf, ln))
			rvSum.major = rvSum.major + 1
		
		ln = ln + 1
	}
	
	/* summary the satus */
	ln = 0
	while (True)
	{
		sel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break
		
		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		sTemp = strmid(s, col, col+1)
		sTemp = toupper(sTEmp);
		
		if (sTemp == "O") rvSum.open = rvSum.open + 1
		else if (sTemp == "C")	rvSum.closed = rvSum.closed + 1
		else if (sTemp == "R")	rvSum.rejected = rvSum.rejected + 1
		
		ln = ln + 1
	}

	/* summary the categories */
	ln = 0
	while (True)
	{
		norej = norejected(hbuf, ln);
		sel = SearchInBuf(hbuf, "^Categories\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break
		
		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		if ( (col+2 > strlen(s)) && IsDefect(hbuf, ln)) 
		{
			msg("Please write categories!")
			return
		}
		if((col + 2) > strlen(s))
			sTemp = "OT"
		else
			sTemp = strmid(s, col, col+2)
		sTemp = toupper(sTEmp);
		
		if (sTemp == "SY" && norej) rvSum.SysReq = rvSum.SysReq + 1
		else if (sTemp == "SD" && norej)	rvSum.SDes = rvSum.SDes + 1
		else if (sTemp == "SR" && norej)	rvSum.SRS = rvSum.SRS + 1
		else if (sTemp == "HL" && norej)	rvSum.HLD = rvSum.HLD + 1
		else if (sTemp == "LL" && norej)	rvSum.LLD = rvSum.LLD + 1
		else if (sTemp == "TP" && norej)	rvSum.TP = rvSum.TP + 1
		else if (sTemp == "CO" && norej)	rvSum.Code = rvSum.Code + 1
		else if (sTemp == "UM" && norej)	rvSum.Docs = rvSum.Docs + 1
		else if (sTemp == "OT" && norej)	rvSum.Others = rvSum.Others + 1
		
		ln = ln + 1
	}

	if ( rvSum.general == rvSum0.general && rvSum.suggest == rvSum0.suggest && rvSum.major == rvSum0.major &&
		  rvSum.query == rvSum0.query && rvSum.open == rvSum0.open &&
		  rvSum.closed == rvSum0.closed && rvSum.rejected == rvSum0.rejected  &&
		  rvSum.SysReq == rvSum0.SysReq && rvSum.SDes == rvSum0.SDes &&
		  rvSum.SRS == rvSum0.SRS && rvSum.HLD == rvSum0.HLD &&
		  rvSum.LLD == rvSum0.LLD && rvSum.TP == rvSum0.TP &&
		  rvSum.Code == rvSum0.Code && rvSum.Docs == rvSum0.Docs &&
		  rvSum.Others == rvSum0.Others )
		return
	else
	{
		delSummary(hbuf)
		setReviewSummary(hbuf, rvSum)
	}
}

macro getReviewSummary(hbuf)
{
	sel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	rvSum = "general=\"0\";suggest=\"0\";major=\"0\";query=\"0\";open=\"0\";closed=\"0\";rejected=\"0\";SysReq=\"0\";SDes=\"0\";SRS=\"0\";HLD=\"0\";LLD=\"0\";TP=\"0\";Code=\"0\";Docs=\"0\";Others=\"0\""

	if (sel == null)
		return rvSum
		
	/* get severity summary */
	ln = sel.lnFirst + 2
	sel = SearchInBuf(hbuf, "^General\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.general = strmid(sLine, col, strlen(sLine))
	
	sel = SearchInBuf(hbuf, "^Suggest\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.suggest = strmid(sLine, col, strlen(sLine))
	
	sel = SearchInBuf(hbuf, "^Major\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.major = strmid(sLine, col, strlen(sLine))
	
	sel = SearchInBuf(hbuf, "^Query\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.query = strmid(sLine, col, strlen(sLine))

	/* get status summary */
	sel = SearchInBuf(hbuf, "^Open\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.open = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Closed\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.closed = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Rejected\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.rejected = strmid(sLine, col, strlen(sLine))

	/* get categories summary */
	sel = SearchInBuf(hbuf, "^SysReq\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SysReq = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^SDes\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SDes = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^SRS\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SRS = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^HLD\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.HLD = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^LLD\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.LLD = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^TP\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.TP = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Code\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Code = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^UM\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Docs = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Others\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Others = strmid(sLine, col, strlen(sLine))

	return rvSum
}

macro setReviewSummary(hbuf, rvSum)
{
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "Summary")
	AppendBufLine(hbuf, "-------------------------------------------------------------------------")
	
	/* Defects sumary */
	AppendBufLine(hbuf, "[Defects sumary]:")
	s = Cat("Total defects = ", rvSum.general + rvSum.suggest + rvSum.major + rvSum.query)
	AppendBufLine(hbuf, s)
	s = Cat("General = ", rvSum.general)
	AppendBufLine(hbuf, s)
	s = Cat("Suggest = ", rvSum.suggest)
	AppendBufLine(hbuf, s)
	s = Cat("Major = ", rvSum.major)
	AppendBufLine(hbuf, s)
	s = Cat("Query = ", rvSum.query)
	AppendBufLine(hbuf, s)
	
	/* Status sumary */
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "[Status sumary]:")
	s = Cat("Open = ", rvSum.open)
	AppendBufLine(hbuf, s)
	s = Cat("Closed = ", rvSum.closed)
	AppendBufLine(hbuf, s)
	s = " ";
	AppendBufLine(hbuf, s)
	s = Cat("Rejected = ", rvSum.rejected)
	AppendBufLine(hbuf, s)

	/* Categories summary */
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "[Defects categories]:")
	s = Cat("Total defects = ", rvSum.SysReq + rvSum.SDes + rvSum.SRS + rvSum.HLD + rvSum.LLD + rvSum.TP + rvSum.Code + rvSum.Docs + rvSum.Others)
	AppendBufLine(hbuf, s)
	s = Cat("SysReq = ", rvSum.SysReq)
	AppendBufLine(hbuf, s)
	s = Cat("SDes = ", rvSum.SDes)
	AppendBufLine(hbuf, s)
	s = Cat("SRS = ", rvSum.SRS)
	AppendBufLine(hbuf, s)
	s = Cat("HLD = ", rvSum.HLD)
	AppendBufLine(hbuf, s)
	s = Cat("LLD = ", rvSum.LLD)
	AppendBufLine(hbuf, s)
	s = Cat("TP = ", rvSum.TP)
	AppendBufLine(hbuf, s)
	s = Cat("Code = ", rvSum.Code)
	AppendBufLine(hbuf, s)
	s = Cat("UM = ", rvSum.Docs)
	AppendBufLine(hbuf, s)
	s = Cat("Others = ", rvSum.Others)
	AppendBufLine(hbuf, s)
}

macro delSummary(hbuf)
{
	sSign123 = "-----------------------Convert to lotus123 format-----------------------------------"
	
	sel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	tpsel = SearchInBuf(hbuf, sSign123, 0, 0, 1, 1, 0)
	if(tpsel == null)
		tpln = 0
	else
		tpln = tpsel.lnFirst
	
	if (sel == null)
		return 
	else
	{
		ln = sel.lnFirst
		LineCount = GetBufLineCount(hbuf) - 1
		
		if(tpln > ln)
			LineCount = tpln - 1 
			
		while(LineCount >= ln)
		{
            DelBufLine(hbuf, LineCount)
            LineCount = LineCount -1;
        }
    }
}

macro delConver123(hbuf)
{
	sSign123 = "-----------------------Convert to lotus123 format-----------------------------------"
	
	tpsel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	sel = SearchInBuf(hbuf, sSign123, 0, 0, 1, 1, 0)
	if(tpsel == null)
		tpln = 0
	else
		tpln = tpsel.lnFirst
	
	if (sel == null)
		return 
	else
	{
		ln = sel.lnFirst
		LineCount = GetBufLineCount(hbuf) - 1
		
		if(tpln > ln)
			LineCount = tpln - 1 
			
		while(LineCount >= (ln - 2))
		{
            DelBufLine(hbuf, LineCount)
            LineCount = LineCount -1;
        }
    }
}

macro norejected(hbuf, ln)
{
	sel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
	if (sel == null) return True;
		
	ln = sel.lnFirst
	col = sel.ichLim
	s = GetBufLine(hbuf, ln)
	sTemp = strmid(s, col, col+1)
	sTemp = toupper(sTEmp);
		
	if (sTemp == "R") return  False;

	return True;
}

macro IsDefect(hbuf, ln)
{
	sel = SearchInBuf(hbuf, "^Class\\s+:\\s+", ln, 0, 1, 1, 0)
	if (sel == null) return True;
		
	ln = sel.lnFirst
	col = sel.ichLim
	s = GetBufLine(hbuf, ln)
	sTemp = strmid(s, col, col+1)
	sTemp = toupper(sTEmp);
		
	if (sTemp == "Q") return  False;

	return True;
}

