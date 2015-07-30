// 27/07/2015: output PO via BIRT
// generate PO from Excel-template .. used by rwpurchaseReq_v1.zul

RWPOTEMPLATE_FN = "RWPO_v1.rptdesign";

/**
 * Generate PO via BIRT for multi-type exports
 * @param ipr selected purchase-req
 */
void birt_genPO_Template(String ipr)
{
	// Extract items and put into report table - have to remove previous items if avail
	sqlstm = "delete from purchasereq_items where pr_parent_id=" + ipr;
	sqlhand.gpSqlExecuter(sqlstm);

	prc = getPR_rec(ipr);

	itms = sqlhand.clobToString(prc.get("pr_items")).split("~");
	iqty = sqlhand.clobToString(prc.get("pr_qty")).split("~");
	iupr = sqlhand.clobToString(prc.get("pr_unitprice")).split("~");

	sqlstm = "";

	if(itms.length > 0)
	{
		for(i=0; i<itms.length; i++)
		{
			unitprice = "0.0";
			try { kk = Float.parseFloat(iupr[i]); unitprice = iupr[i]; } catch (Exception e) {}
			quantity = "0";
			try { kk = Integer.parseInt(iqty[i]); quantity = iqty[i]; } catch (Exception e) {}

			sqlstm += "insert into purchasereq_items (pr_parent_id,description,unitprice,quantity,curcode) values " +
			"(" + ipr + ",'" + kiboo.checkNullString(itms[i]) + "'," + unitprice + "," + quantity + ",'" + kiboo.checkNullString(prc.get("curcode")) + "');";
		}
		
		sqlhand.gpSqlExecuter(sqlstm);

		if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
		Iframe newiframe = new Iframe();
		newiframe.setId("expassframe"); newiframe.setWidth("100%"); newiframe.setHeight("600px");
		thesrc = birtURL() + "rwreports/" + RWPOTEMPLATE_FN + "&prid=" + ipr;
		newiframe.setSrc(thesrc);
		newiframe.setParent(expass_div);
		expasspop.open(printpr2_b);

	}
	else
	{
		guihand.showMessageBox("No items in the purchase-order.. no output");
	}
}

/**
 * Original PO output by excel-worksheet
 * @param ipr selected purchase-req
 */
void genPO_Template(String ipr)
{
	prc = getPR_rec(ipr);
	if(prc == null)
	{
		guihand.showMessageBox("DBERR: Cannot access purchase-requisition table!!");
		return;
	}

	startadder = 1;
	rowcount = 1 + startadder;

	templatefn = "rwimg/poTemplate_1.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	dets1 =
	"SUPPLIER:\n" + kiboo.checkNullString(prc.get("supplier_name")) + "\n" +
	kiboo.checkNullString( prc.get("sup_address") ) +
	"\n\nContact person: " + kiboo.checkNullString(prc.get("sup_contact")) + 
	"\nTEL: " + kiboo.checkNullString(prc.get("sup_tel")) + " FAX: " + kiboo.checkNullString(prc.get("sup_fax")) +
	"\nEMAIL: " + kiboo.checkNullString(prc.get("sup_email"));

	excelInsertString(sheet,0,0,dets1);

	stdate = dtf2.format(prc.get("datecreated"));
	etdate = dtf2.format(prc.get("sup_etd"));

	sqlstm = "SELECT (DATEDIFF(dd, '" + stdate + "','" + etdate + "') + 1) " +
	"-(DATEDIFF(wk, '" + stdate + "','" + etdate + "') * 2) " +
	"-(CASE WHEN DATENAME(dw, '" + stdate + "') = 'Sunday' THEN 1 ELSE 0 END) " +
	"-(CASE WHEN DATENAME(dw, '" + etdate + "') = 'Saturday' THEN 1 ELSE 0 END) as dayff ";

	kr = sqlhand.gpSqlFirstRow(sqlstm);
	dayff = (kr.get("dayff")-1).toString();

	dets2 = 
	"PR/PO No.      : " + ipr +
	"\nDated        : " + dtf2.format(prc.get("datecreated")) +
	"\nPayment Term : " + kiboo.checkNullString(prc.get("creditterm")) +
	"\nCurrency     : " + kiboo.checkNullString(prc.get("curcode")) +
	"\nPrepared by  : " + prc.get("username") +
	"\nDelivery ETD : " + dtf2.format(prc.get("sup_etd")) + " (" + dayff + " day(s))" +
	"\n\nNotes: " + kiboo.checkNullString(prc.get("notes"));

	excelInsertString(sheet,0,3, dets2 );

	String[] colhd = { "No.","Description","Qty","Unit Price","Sub Total"};
	for(i=0;i<colhd.length;i++)
	{
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, 2, i, colhd[i] ),wfont,true,"");
	}

	itms = sqlhand.clobToString(prc.get("pr_items")).split("~");
	iqty = sqlhand.clobToString(prc.get("pr_qty")).split("~");
	iupr = sqlhand.clobToString(prc.get("pr_unitprice")).split("~");
	
	//alert( sqlhand.clobToString(prc.get("pr_items")) );

	if(itms.length > 0)
	{
		qtytot = 0;
		gtotal = 0.0;

		for(i=0; i<itms.length; i++)
		{

		uprstr = "";
		try {
		uprstr = nf.format(Float.parseFloat(iupr[i]));
		} catch (Exception e) {}

		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 0, (i+1).toString() + "." ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 1, itms[i] ),wfont,false,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 2, iqty[i] ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 3, uprstr ),wfont,true,"");

		stot = 0.0;
		try {
		stot = Integer.parseInt(iqty[i]) * Float.parseFloat(iupr[i]);
		gtotal += stot;
		} catch (Exception e) {}
		
		try {
		qtytot += Integer.parseInt(iqty[i]);
		} catch (Exception e) {}

		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 4, nf.format(stot) ),wfont,true,"");

		rowcount++;
		}

		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 1, "TOTAL" ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 2, qtytot.toString() ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 4, nf.format(gtotal) ),wfont,true,"");
	}

	tfname = PR_PREFIX + ipr + "_outp.xls";
	outfn = session.getWebApp().getRealPath("sharedocs/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();

	downloadFile(kasiexport,tfname,outfn);
}



