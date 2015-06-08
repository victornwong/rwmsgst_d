/*
Reporting and data-export Funcs for rwpurchaseReq
exec dbo.getWeekOfMonth @thedate = '2013-11-28'

	Type of reporting : Procurement Department
	Type of Reporting :  Product Analysis Report
	Information needed :  Able to get an excel sheet showing the products name price and the quantity purchased on a specific date,
	Reason :  This is to make sure that we constantly capture the prices and don’t run to far from it and also know how much are we buying on.
	Type of Reporting :  Commodity report
	Information needed : able to get a report based on group products purchase on a month, example office items how much/ware house item how much.
	Reason :   So that we know which department is using what on a high basis and to make sure there is no wastages.
	Type of Reporting :  Average Supplier Income report
	Information needed :  The amount of sales given to our supplier
	Reason :  This is to proof to our suppliers on the amount of sales given to them, for us to re-negotiate prices and credit terms.
*/

Object[] asireplb =
{
	new listboxHeaderWidthObj("PR#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("Total",true,"100px"),
};

Object[] pareplb_hds =
{
	new listboxHeaderWidthObj("PR#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("Item",true,"250px"),
	new listboxHeaderWidthObj("Qty",true,"60px"),
	new listboxHeaderWidthObj("U/P",true,"70px"),
};

class prepdobcliker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget();
		pn = lbhand.getListcellItemLabel(selitem,0);
		searchprno_tb.setValue(pn);
		showPRList();
	}
}
repoDoublCliker = new prepdobcliker();

class prodanalclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		if(isel.getLabel().equals("Export product analysis report"))
		{
			kk = isel.getParent().getFellowIfAny("parepitems_lb");
			if(kk == null) return;
			exportExcelFromListbox(kk, kasiexport, pareplb_hds, "ProductAnalyReport.xls","ProdAnalRep");
		}

		if(isel.getLabel().equals("Export average supplier income report"))
		{
			kk = isel.getParent().getFellowIfAny("supincome_lb");
			if(kk == null) return;
			exportExcelFromListbox(kk, kasiexport, asireplb, "AvrSupplierIncome.xls","SupplierIncome");
		}

		if(isel.getLabel().equals("Export commodity report"))
		{
			kk = isel.getParent().getFellowIfAny("commid_lb");
			if(kk == null) return;
			exportExcelFromListbox(kk, kasiexport, asireplb, "CommodityReport.xls","Commodity");
		}
	}
}
prodanalcliker = new prodanalclik();

void showPurchasesByCat(String sdate, String edate, String icatname)
{
	sqlstm = "select origid, supplier_name, datecreated, pr_qty, pr_unitprice from purchaserequisition " +
	"where purchasecat='" + icatname + "' and pr_status='APPROVE' and datecreated between '" + sdate + "' and '" + edate + "'";

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) { repnothing_lb.setVisible(true); return; }
	repnothing_lb.setVisible(false);

	mw = vMakeWindow(winsholder, "Commodity Report : (" + icatname + ")", "3px", "center", "700px","");
	dv = new Div();
	dv.setParent(mw);
	Listbox newlb = lbhand.makeVWListbox_Width(dv, asireplb, "commid_lb", 15);
	kbut = new Button();
	kbut.setLabel("Export commodity report");
	kbut.addEventListener("onClick", prodanalcliker );
	kbut.setParent(dv);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "supplier_name" };
	for(d : r)
	{
		iqty = sqlhand.clobToString(d.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(d.get("pr_unitprice")).split("~");
		tot = calcPR_total(iqty,iupr);
		popuListitems_Data(kabom,fl,d);
		kabom.add(nf2.format(tot));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, repoDoublCliker);
}

void showSupplierIncomeRep(String sdate, String edate, String isupname)
{
	sqlstm = "select origid, supplier_name, datecreated, pr_qty, pr_unitprice from purchaserequisition " +
	"where supplier_name like '%" + isupname + "%' and datecreated between '" + sdate + "' and '" + edate + "' and pr_status='APPROVE';";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) { repnothing_lb.setVisible(true); return; }
	repnothing_lb.setVisible(false);

	mw = vMakeWindow(winsholder, "Average Suppl Income Report : (" + isupname + ")", "3px", "center", "700px","");
	dv = new Div();
	dv.setParent(mw);
	Listbox newlb = lbhand.makeVWListbox_Width(dv, asireplb, "supincome_lb", 15);
	kbut = new Button();
	kbut.setLabel("Export average supplier income report");
	kbut.addEventListener("onClick", prodanalcliker );
	kbut.setParent(dv);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "supplier_name" };
	for(d : r)
	{
		iqty = sqlhand.clobToString(d.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(d.get("pr_unitprice")).split("~");
		tot = calcPR_total(iqty,iupr);
		popuListitems_Data(kabom,fl,d);
		kabom.add(nf2.format(tot));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, repoDoublCliker);
}

void showProductAnalysisRep(String sdate, String edate, String ipn)
{
	sqlstm = "select origid, supplier_name, datecreated, pr_items, pr_qty, pr_unitprice " +
	"from purchaserequisition where datecreated between '" + sdate + "' and '" + edate + "' and pr_items like '%" + ipn + "%' and pr_status='APPROVE'";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) { repnothing_lb.setVisible(true); return; }
	repnothing_lb.setVisible(false);
	mw = vMakeWindow(winsholder, "Product Analysis Report : (" + ipn + ")", "3px", "center", "700px","");
	dv = new Div();
	dv.setParent(mw);
	Listbox newlb = lbhand.makeVWListbox_Width(dv, pareplb_hds, "parepitems_lb", 15);
	kbut = new Button();
	kbut.setLabel("Export product analysis report");
	kbut.addEventListener("onClick", prodanalcliker );
	kbut.setParent(dv);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "supplier_name" };
	for(d : r)
	{
		itms = sqlhand.clobToString(d.get("pr_items")).split("~");
		iqty = sqlhand.clobToString(d.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(d.get("pr_unitprice")).split("~");
		for(i=0; i<itms.length; i++)
		{
			if(itms[i].toUpperCase().indexOf(ipn.toUpperCase()) != -1)
			{
				popuListitems_Data(kabom,fl,d);
				kabom.add(itms[i]);
				kabom.add(iqty[i]);
				kabom.add(iupr[i]);
				lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
				kabom.clear();
			}
		}
	}
	lbhand.setDoubleClick_ListItems(newlb, repoDoublCliker);
}

void rep_PaymentDueWeek(String istart, String iend)
{
	sqlstm = "select origid,datecreated,supplier_name,creditterm,pr_qty,pr_unitprice,paydue_date from purchaserequisition " +
	"where datecreated between '" + istart + " 00:00:00' and '" + iend + " 23:59:00' and pr_status='APPROVE' " +
	"order by paydue_date" ;

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) { guihand.showMessageBox("No purchasing records found.."); return; }

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("PAY_WEEK");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	String[] ihds = { "PR.ID","DATED","SUPPLIER","PAYMENT_DUE","WEEK 0","WEEK 1","WEEK 2","WEEK 3", "WEEK 4", "WEEK 5" };
	for(i=0; i<ihds.length; i++)
	{
		excelInsertString( sheet, 0, 0+i, ihds[i]);
	}

	sum0 = sum1 = sum2 = sum3 = sum4 = sum5 = 0.0;

	rwcount = 1;
	for(d : recs)
	{
		excelInsertString( sheet,rwcount, 0, d.get("origid").toString() );
		excelInsertString( sheet,rwcount, 1, dtf2.format(d.get("datecreated")) );
		excelInsertString( sheet,rwcount, 2, d.get("supplier_name") );
		excelInsertString( sheet,rwcount, 3, (d.get("paydue_date")==null) ? "" : dtf2.format(d.get("paydue_date")) );

		wkd = getWeekOfDay_java(d.get("paydue_date"));
		sume = calcPR_total(sqlhand.clobToString(d.get("pr_qty")).split("~"),
		sqlhand.clobToString(d.get("pr_unitprice")).split("~"));
		
		switch(wkd)
		{
			case 1 : sum1 += sume; break;
			case 2 : sum2 += sume; break;
			case 3 : sum3 += sume; break;
			case 4 : sum4 += sume; break;
			case 5 : sum5 += sume; break;
			default: sum0 += sume; break;
		}
		excelInsertNumber( sheet, rwcount, 4 + wkd , sume.toString() );
		rwcount++;
	}

	// put all 'em sum-ups
	excelInsertString( sheet, rwcount, 3, "TOTAL");
	excelInsertNumber( sheet, rwcount, 4 , nf2.format(sum0) );
	excelInsertNumber( sheet, rwcount, 5 , nf2.format(sum1) );
	excelInsertNumber( sheet, rwcount, 6 , nf2.format(sum2) );
	excelInsertNumber( sheet, rwcount, 7 , nf2.format(sum3) );
	excelInsertNumber( sheet, rwcount, 8 , nf2.format(sum4) );
	excelInsertNumber( sheet, rwcount, 9 , nf2.format(sum5) );

	jjfn = "paymentdueweek.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();

	downloadFile(kasiexport,jjfn,outfn); // rwsqlfuncs.zs TODO need to move this
}

