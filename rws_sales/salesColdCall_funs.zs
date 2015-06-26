// Sales cold-call functions

void showActiContactMeta(String iwhat)
{
	acr = getActivitiesContact_rec(iwhat);
	glob_acticont_rec = acr; // save for later
	if(acr == null) { guihand.showMessageBox("DBERR: Cannot access acti-contacts table.."); return; }

	cntp = kiboo.checkNullString(acr.get("contact_person"));
	titt = (cntp.indexOf("Ms") != -1) ? "Ms" : "Mr";
	lbhand.matchListboxItems( a_cont_temp, titt);
	cntp = cntp.replaceAll(titt + " ","");
	a_contact_person.setValue( cntp );

	Object[] ob = { a_cust_name, a_industry, a_designation, a_cust_address1, a_cust_address2, a_cust_address3, a_cust_address4,
	a_cust_tel, a_cust_fax, a_cust_email, a_businessroc, a_leadsource, a_campaign, a_grading_remarks, currentcustomergrade_lbl };

	String[] fl = { "cust_name", "industry", "designation", "cust_address1", "cust_address2", "cust_address3", "cust_address4",
	"cust_tel", "cust_fax", "cust_email", "businessroc", "leadsource", "campaign", "grading_remarks", "customer_grade" };

	ngfun.populateUI_Data(ob, fl, acr);

	coldcd = sqlhand.clobToString(acr.get("coldcall_rec"));
	coldcallmform.wolipar.clearFormFieldsAll();
	if(coldcd != null) coldcallmform.populateFormValues(coldcd);

	fillDocumentsList(documents_holder,COLDCALL_PREFIX,iwhat);

	lbhand.matchListboxItems( a_coldcdv, kiboo.checkNullString(acr.get("call_div")) );
	workarea.setVisible(true);
}

Object[] qtlhds =
{
	new listboxHeaderWidthObj("QT#",true,"50px"),
	new listboxHeaderWidthObj("ContactP",true,""),
	new listboxHeaderWidthObj("QStatus",true,""),
	new listboxHeaderWidthObj("QType",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
};

class tiedqtdcicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		iqt = lbhand.getListcellItemLabel(isel,0);
		try {
			salcolcla.setOpen(false);
			activateModule(mainPlayground,"workbox","rws_sales/rwQuotationHC_v2.zul",kiboo.makeRandomId("vpl"),"iqt=" + iqt, useraccessobj);
			} catch (Exception e) {}
	}
}
tiequotedclicker = new tiedqtdcicker();

void listTiedQuotations(String icn)
{
	// always clear old one..
	if(quotelist_holder.getFellowIfAny("lnkquotes_lb") != null) lnkquotes_lb.setParent(null);

	sqlstm = "select origid, contact_person1, qstatus, qt_type, username from rw_quotations where customer_name='" + icn + "';";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(quotelist_holder, qtlhds, "lnkquotes_lb", 20);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "contact_person1", "qstatus", "qt_type", "username" };
	for(d : recs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, tiequotedclicker);
}

Object[] actconthds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("DateCrt",true,""),
	new listboxHeaderWidthObj("Grade",true,""),
	new listboxHeaderWidthObj("Grd.Req",true,""),
	new listboxHeaderWidthObj("ContactP",true,""),
	new listboxHeaderWidthObj("Tel",true,""),
	new listboxHeaderWidthObj("Email",true,""),
	new listboxHeaderWidthObj("Industry",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Class",true,"70px"),
	new listboxHeaderWidthObj("Divs",true,"70px"),
};

USERNAME_POSI = 9;

class acticontclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();

		glob_sel_acticont = lbhand.getListcellItemLabel(isel,0);
		glob_sel_custname = lbhand.getListcellItemLabel(isel,1);
		glob_sel_username = lbhand.getListcellItemLabel(isel,USERNAME_POSI);

		showActiContactMeta(glob_sel_acticont);
		listActivities(glob_sel_acticont);
		listTiedQuotations(glob_sel_custname);
	}
}
acticontclkier = new acticontclk();

// itype: 1=list all, 2=list by username, 3=by date range
void listActiContacts(int itype, String iusername)
{
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	last_loadcont = itype;
	st = kiboo.replaceSingleQuotes(schbox.getValue()).trim();
	bycst = "";

	Listbox newlb = lbhand.makeVWListbox_Width(acticonts_holder, actconthds, "acticonts_lb", 20);

	sqlstm = "select origid,cust_name,potential,username,industry,deleted,datecreated," +
	"contact_person,cust_tel,cust_email,call_div,customer_grade,grade_req from rw_activities_contacts ";
	switch(itype)
	{
		case 1:
			if(!st.equals("")) sqlstm += "where (cust_name like '%" + st + "%' or contact_person like '%" + st + "%')";
			break;
		case 2:
			sqlstm += "where username='" + iusername + "'";
			break;
		case 3:
			sqlstm += "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00'";

			break;
	}
	
	sqlstm += " order by datecreated desc";

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", acticontclkier );
	ArrayList kabom = new ArrayList();
	String[] fl = { "datecreated", "customer_grade", "grade_req", "contact_person", "cust_tel", "cust_email", "industry", "username", "potential", "call_div" };
	for(d : recs)
	{
		kabom.add( d.get("origid").toString() );
		cstn = kiboo.checkNullString( d.get("cust_name") );
		if(cstn.equals("")) cstn = "NEW CUSTOMER";
		kabom.add( cstn );
		ngfun.popuListitems_Data(kabom,fl,d);
		dlt = (d.get("deleted") == null) ? "" : (d.get("deleted")) ? "font-size:9px;text-decoration:line-through;opacity:0.6;" : "";
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",dlt);
		kabom.clear();
	}
}

void showActivityMeta(String iwhat)
{
	rcs = getActivity_rec(iwhat);
	glob_activ_rec = rcs; // use later
	if(rcs == null) { guihand.showMessageBox("DBERR: Cannot access activity-table!!"); return; }
	Object[] ob = { o_contact_person, o_designation, o_telephone, o_email, o_act_type, o_act_notes, o_act_date };
	String[] fl = { "contact_person", "designation", "telephone", "email", "act_type", "act_notes", "act_date" };
	ngfun.populateUI_Data(ob,fl,rcs);
}

Object[] actihds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Contact",true,""),
	new listboxHeaderWidthObj("Designation",true,"100px"),
	new listboxHeaderWidthObj("Type",true,"80px"),
	new listboxHeaderWidthObj("User",true,"80px"),
	new listboxHeaderWidthObj("Act.Date",true,"80px"),
};

class activiclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_activity = lbhand.getListcellItemLabel(isel,0);
	}
}
activityclker = new activiclk();

class activiDclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		glob_sel_activity = lbhand.getListcellItemLabel(isel,0);
		showActivityMeta(glob_sel_activity);
		updateactiv_pop.open(isel);
	}
}
activityDclker = new activiDclk();

void listActivities(String ilnk)
{
	Listbox newlb = lbhand.makeVWListbox_Width(actis_holder, actihds, "activities_lb", 5);
	sqlstm = "select origid,datecreated,contact_person,designation," + 
	"act_type,username,act_notes,act_date from rw_activities where parent_id=" + ilnk;

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	// newlb.setMultiple(true);
	newlb.setRows(21); newlb.setMold("paging");
	newlb.addEventListener("onSelect", activityclker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid","datecreated","contact_person","designation","act_type","username","act_date" };
	for(d : recs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		kak = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kak.setTooltiptext( kiboo.checkNullString(d.get("act_notes")) );
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, activityDclker);
	glob_sel_activity = ""; // reset
}

void clearAddActiFields()
{
	Object[] acf = { k_contact_person, k_telephone, k_email, k_act_notes, k_designation, k_act_type };
	clearUI_Field(acf);
}

// Update contact's potential by using button-label
void setContactPotential(Object iwhat)
{
	potenial_pop.close();
	if(glob_sel_acticont.equals("")) return;
	lbl = iwhat.getLabel();
	sqlstm = "update rw_activities_contacts set potential='" + lbl + "' where origid=" + glob_sel_acticont;
	sqlhand.gpSqlExecuter(sqlstm);
	listActiContacts(last_loadcont,glob_current_user);
}

void genColdCallDump()
{
	sqlstm = "select * from rw_activities_contacts where deleted=0";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;

 	startadder = 1;
	rowcount = 0;
	HashMap myhmap;

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("RECEIVALS");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	String[] rhds = { "REC","Dated","User","Customer","Grade","Potential","Contact","Designation",
	"Address1","Address2","Address3","Address4","Tel","Fax","Email","Industry","Division",
	"Total No PC","DT","NB","Tech.Level","OS","Brand","Specs","Warranty",
	"Server brand","Server count", "MS-Off Ver", "MS-Off License",
	"ERP", "PABX Brand", "PC/Server remarks",
	"Desktop", "Notebook",
	"Internal Cost of Funds / Finance rate","IT Depreciation", "Usage Tenure",
	"Contact1", "Designation1", "Email1",
	"Contact2", "Designation2", "Email2",
	"Contact3", "Designation3", "Email3",
	"Contact4", "Designation4", "Email4",
	"Customer remarks"
	 };

	String[] flsd = { "username","cust_name","customer_grade","potential","contact_person","designation",
	"cust_address1","cust_address2","cust_address3","cust_address4",
	"cust_tel","cust_fax","cust_email","industry","call_div" };

	String[] hsds = {
	"s_totpc","s_dtperc","s_nbperc","s_techlvl","s_ostype","s_brand","s_specs","s_warranty",
	"s_serverbrand","s_servercount","s_msoffver","s_msofflic",
	"s_erp","s_pabx","s_pcsvrremks",
	"s_dtapprxprice","s_nbapprxprice",
	"s_icffr","s_itdepre","s_usgten",
	"s_cont1","s_desg1","s_email1",
	"s_cont2","s_desg2","s_email2",
	"s_cont3","s_desg3","s_email3",
	"s_cont4","s_desg4","s_email4",
	"s_remarks"
	};

	for(i=0;i<rhds.length;i++)
	{
		POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,i,rhds[i]),wfont,true,"");
	}

	rowcount++;
	for(d : recs)
	{
		excelInsertString(sheet,rowcount,0, d.get("origid").toString() );
		excelInsertString(sheet,rowcount,1, dtf2.format(d.get("datecreated")) );
		for(k=0;k<flsd.length;k++)
		{
			excelInsertString(sheet,rowcount,k+2, kiboo.checkNullString(d.get(flsd[k])) );
		}

		myhmp = null;
		coldcd = sqlhand.clobToString(d.get("coldcall_rec"));
		if(!coldcd.equals(""))
		{
			myhmap = new HashMap();
			irecs = coldcd.split("::"); // split by ::
			for(int i=0; i<irecs.length; i++)
			{
				tmpstr = irecs[i];
				iparts = tmpstr.split("\\|"); // split the field and data parts
				fieldpart = iparts[0].replace("\"","");
				datapart = iparts[1].replace("\"","");
				//alert(fieldpart + " = " + datapart);
				myhmap.put(fieldpart,datapart);
			}

			for(k=0; k<hsds.length; k++)
			{
				excelInsertString(sheet,rowcount,k+flsd.length+2, kiboo.checkNullString( myhmap.get(hsds[k])) );
			}
		}

		rowcount++;
	}

	jjfn = "coldCalldat.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();
	downloadFile(kasiexport,jjfn,outfn);
}
