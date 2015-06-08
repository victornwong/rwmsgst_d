import org.victor.*;

// itype: 1=deliver flag, 2=recv flag
void toggleDelRecvFlag(int itype)
{
	if( !lbhand.check_ListboxExist_SelectItem(sendouts_holder, "sendouts_lb") ) return;
	todaydate =  kiboo.todayISODateTimeString();
	selitms = sendouts_lb.getSelectedItems().toArray();
	sots = "";
	for(i=0; i<selitms.length; i++)
	{
		soi = lbhand.getListcellItemLabel(selitms[i],0);
		sots += soi + ",";
	}

	try {
	sots = sots.substring(0,sots.length()-1);
	} catch (Exception e) {}
	
	setstr = (itype == 1) ? "delivered=1-delivered" : "recvback=1-recvback,recvbackdate='" + todaydate + "'";

	sqlstm = "update rw_sendouttracker set " + setstr + " where origid in (" + sots + ")";

	sqlhand.gpSqlExecuter(sqlstm);
	showSendoutList();
}

void showSendoutMeta(String iwhat)
{
	sre = getSendout_rec(iwhat);
	if(sre == null) { guihand.showMessageBox("DBERR: Cannot access sendout table.."); return; }
	s_origid.setValue(iwhat);

	String[] fl = { "datecreated", "customer_name", "destination", "contact_person", "contact_tel", "contact_email",
	"docu_type", "docu_ref", "priority", "dispatcher", "waybill", "user_roclc_no" };

	Object[] ob = { s_datecreated, customername, s_destination, s_contact_person, s_contact_tel, s_contact_email,
	s_docu_type, s_docu_ref, s_priority, s_dispatcher, s_waybill, s_user_roclc_no };

	populateUI_Data(ob,fl,sre);

	if(sre.get("et_action") == null)
		kiboo.setTodayDatebox(s_et_action);
	else
		s_et_action.setValue( sre.get("et_action") );

	atns = sqlhand.clobToString(sre.get("actions_taken"));
	actionstaken_holder.setValue(atns);

	workarea.setVisible(true);
}

void genCoverLetter_sendout(String isd)
{
	sre = getSendout_rec(isd);
	if(sre == null) { guihand.showMessageBox("DBERR: Cannot access sendout table.."); return; }

	startadder = 0;
	rowcount = 2 + startadder;

	templatefn = "rwimg/sendoutcover_1.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	excelInsertString(sheet,0,1,SENDOUT_PREFIX + glob_sel_sendout); // send-out ID

	dets1 =
	kiboo.checkNullString(sre.get("customer_name")) +
	"\n" + kiboo.checkNullString(sre.get("destination")) +
	"\n\nATTENTION: " + kiboo.checkNullString(sre.get("contact_person")) + "\nTEL: " + kiboo.checkNullString(sre.get("contact_tel"));

	excelInsertString(sheet,2,1,dets1);
	excelInsertString(sheet,0,4, dtf2.format(sre.get("datecreated")) );
	
	excelInsertString(sheet,3,0,"Dear " + kiboo.checkNullString(sre.get("contact_person")) + ",");

	tfname = SENDOUT_PREFIX + isd + "_coveroutp.xls";
	outfn = session.getWebApp().getRealPath("sharedocs/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();

	downloadFile(kasiexport,tfname,outfn);
}

// itype: 1=undelivered sorta like dispatch-manifest format for dispatcher to fill-up. 2=everything for analysis
void exportSendouts(int itype)
{
	sdate = kiboo.getDateFromDatebox(exp_startdate);
    edate = kiboo.getDateFromDatebox(exp_enddate);
    dspc = exp_dispatcher.getSelectedItem().getLabel();

    sqlstm = "select origid,datecreated,customer_name,contact_person,contact_tel,waybill,destination,docu_ref from rw_sendouttracker " +
    "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " + 
    "and dispatcher='" + dspc + "' and delivered=0 order by origid";

    if(itype == 2)
    	sqlstm = "select origid,datecreated,customer_name,contact_person,contact_tel,waybill from rw_sendouttracker " +
	    "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' order by origid ";

	sors = sqlhand.gpSqlGetRows(sqlstm);
	if(sors.size() == 0) return;

   	startadder = 2;
	rowcount = 1 + startadder;

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("SENDOUTS");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	if(itype == 1)
	{
		String[] type1hds = { "No.","Date","Customer","Address","Ref/Action","Contact","Tel","Waybill","Chop/Sign" };
		excelInsertString(sheet,0,0,"DOCUMENTS DELIVERY LIST");
		excelInsertString(sheet,1,0,"DISPATCHER: " + dspc);

		for(i=0;i<type1hds.length;i++)
		{
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,i,type1hds[i]),wfont,true,"");
		}
		rowcount++;
		lncnt = 1;

		for(d : sors)
		{
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,0, d.get("origid").toString() + "."),wfont,true,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,1, dtf2.format(d.get("datecreated")) ),wfont,true,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,2, kiboo.checkNullString(d.get("customer_name")) ),wfont,false,"");

			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,3, kiboo.checkNullString(d.get("destination")) ),wfont,false,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,4, kiboo.checkNullString(d.get("docu_ref")) ),wfont,false,"");			

			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,5, kiboo.checkNullString(d.get("contact_person")) ),wfont,true,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,6, kiboo.checkNullString(d.get("contact_tel")) ),wfont,true,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,7, kiboo.checkNullString(d.get("waybill")) ),wfont,true,"");
			POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,8, "" ),wfont,true,"");

			lncnt++;
			rowcount++;
		}
	}

	jjfn = "sendoutList_t" + itype.toString() + ".xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();

	downloadFile(kasiexport,jjfn,outfn); // rwsqlfuncs.zs TODO need to move this
	expsendout_pop.close();
}

Object[] sotlb_hds =
{
	new listboxHeaderWidthObj("ST#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("LC/ROC",true,"70px"),
	new listboxHeaderWidthObj("DocuT",true,"70px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Dispatcher",true,"80px"),
	new listboxHeaderWidthObj("Waybill",true,"80px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Sent",true,"40px"),
	new listboxHeaderWidthObj("Recv",true,"40px"),
	new listboxHeaderWidthObj("R.Date",true,"60px"),
	new listboxHeaderWidthObj("ETAction",true,"70px"),
};

class sotlbcjlick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_sendout = lbhand.getListcellItemLabel(isel,0);
		showSendoutMeta(glob_sel_sendout);
	}
}
sotbldkclicker = new sotlbcjlick();

void showSendoutList()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(sendouts_holder, sotlb_hds, "sendouts_lb", 5);
	scsql = "";
	if(!scht.equals("")) scsql = "and (customer_name like '%" + scht + "%' or docu_type like '%" + scht + "%') ";

	sqlstm = "select origid,datecreated,customer_name,username,priority,dispatcher,waybill,delivered," + 
	"et_action,docu_type,user_roclc_no,recvback,recvbackdate from rw_sendouttracker " +
	"where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " + scsql;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;

	newlb.setRows(22);
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.addEventListener("onSelect", sotbldkclicker );
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add( dpi.get("origid").toString() );
		kabom.add( dtf2.format(dpi.get("datecreated")) );
		kabom.add( kiboo.checkNullString(dpi.get("customer_name")) );
		kabom.add( kiboo.checkNullString(dpi.get("user_roclc_no")) );
		kabom.add( kiboo.checkNullString(dpi.get("docu_type")) );
		kabom.add( kiboo.checkNullString(dpi.get("username")) );
		kabom.add( kiboo.checkNullString(dpi.get("dispatcher")) );
		kabom.add( kiboo.checkNullString(dpi.get("waybill")) );
		kabom.add( kiboo.checkNullString(dpi.get("priority")) );
		kabom.add( (dpi.get("delivered") == null) ? "N" : ((dpi.get("delivered")) ? "Y" : "N" ) );
		kabom.add( (dpi.get("recvback") == null) ? "N" : ((dpi.get("recvback")) ? "Y" : "N" ) );
		kabom.add( (dpi.get("recvbackdate") == null) ? "" : dtf2.format(dpi.get("recvbackdate")) );
		kabom.add( (dpi.get("et_action") == null) ? "" : dtf2.format(dpi.get("et_action")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}


