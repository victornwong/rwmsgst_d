/*
Repetitive stuff used throughout other modules
Take note of some <popup> required by these funcs
*/

// ---- Linking documents funcs ---

void doViewDoculinkPopup()
{
	if(selected_folderno.equals("")) return;
	documentLinkProp.global_eq_origid = selected_folderno;
	documentLinkProp.refreshListbox.populateDocumentLinks(documentLinkProp.global_eq_origid, documentLinkProp.document_idprefix);

	// show CRUD buttons for admin
	if(useraccessobj.accesslevel == 9)
	{
		documentLinkProp.refreshListbox.showCrudButtons();
		documentLinkProp.refreshListbox.showAdminButtons();
	}
	doculink_popup.open(viewdoculinks_btn);
}

// 10/03/2011: modification from original simpler funcs - this will show "sent" status
void showDocumentsList(String selected_folderno)
{
	Object[] documentlinkslb_headers = {
	new listboxHeaderObj("origid",false),
	new listboxHeaderObj("Title",true),
	new listboxHeaderObj("D.Created",true),
	new listboxHeaderObj("Owner",true),
	new listboxHeaderObj("Sent",true),
	};

	duclink = "DOCS" + selected_folderno;

	ds_sql = als_DocumentStorage();
	if(ds_sql == null) return;
	sqlstm = "select origid,file_title,datecreated,username from DocumentTable " +
	"where docu_link='" + duclink + "' and deleted=0";

	if(useraccessobj.accesslevel == 9) // admin can send everything..
	{
		sqlstm = "select origid,file_title,datecreated,username from DocumentTable " +
		"where docu_link='" + duclink + "' ";
	}

	docrecs = ds_sql.rows(sqlstm);
	ds_sql.close();

	Listbox newlb = makeVWListbox(doculist_holder,documentlinkslb_headers,"doculinks_lb",10);

	if(docrecs.size() == 0) return;
	newlb.setMultiple(true);
	//newlb.addEventListener("onSelect", new doculinks_lb_Listener());

	sql = als_mysoftsql();
    if(sql == NULL) return;

	for(dpi : docrecs)
	{
		ArrayList kabom = new ArrayList();
		doculink = dpi.get("origid").toString();
		kabom.add(doculink);
		kabom.add(dpi.get("file_title"));
		kabom.add(dpi.get("datecreated").toString().substring(0,10));
		kabom.add(dpi.get("username"));

		sqlstm = "select top 1 origid from stuff_emailed where linking_code='" + selected_folderno + "' and docu_link=" + doculink;
		sentrec = sql.firstRow(sqlstm);
		sentflag = "---";
		if(sentrec != null) sentflag = "YES";
		kabom.add(sentflag);

		strarray = convertArrayListToStringArray(kabom);
		insertListItems(newlb,strarray,"false");
	}

	sql.close();
}

void viewDocument()
{
	if(!check_ListboxExist_SelectItem(doculist_holder,"doculinks_lb")) return;
	eorigid = doculinks_lb.getSelectedItem().getLabel();
	theparam = "docid=" + eorigid;
	uniqid = makeRandomId("vd");
	globalActivateWindow("miscwindows","qc/viewlinkingdocument.zul", uniqid, theparam, useraccessobj);
}
// ---- ENDOF Linking documents funcs ---

//----------- Job-notes stuff : added 22/02/2011

void showJobNotes(String ifoldno)
{
	foldrec = getFolderJobRec(ifoldno);
	if(foldrec == null) return;
	jobnotes_tb.setValue(foldrec.get("jobnotes"));
}

void saveUpdateJobNotes()
{
	if(selected_folderno.equals("")) return;

	forigid = convertFolderNoToInteger(selected_folderno).toString();
	jobnotes = replaceSingleQuotes(jobnotes_tb.getValue());

	if(!forigid.equals(""))
	{
		sql = als_mysoftsql();
		if(sql == null ) return;
		todaysdate = getDateFromDatebox(hiddendatebox);

		// 19/7/2010: TeckMaan suggested to include a history feature for notes - incase others accidentally delete lines
		// get old JobFolders.jobnotes
		sqlstm1 = "select jobnotes from JobFolders where origid=" + forigid;
		oldj = sql.firstRow(sqlstm1);
		// insert into JobNotes_History table
		insertJobNotesHistory_Rec(forigid, oldj.get("jobnotes"), jobnotes, todaysdate,useraccessobj.username); // samplereg_funcs.zs
		// update JobFolders.jobnotes and JobFolders.lastjobnotesdate
		sqlstm = "update JobFolders set jobnotes='" + jobnotes + "', lastjobnotesdate='" + todaysdate + "' where origid=" + forigid;
		sql.execute(sqlstm);
		sql.close();
		showMessageBox("Job notes saved..");
	}
}

// This will show historical job-notes - to make sure every changes to the job notes are recorded
// noteshistory_btn jobnotes_lb_div global_sjn_folder
void jobNotesHistory_clicker()
{
Object[] jobnoteshistory_lb_headers = {
	new listboxHeaderObj("origid",false),
	new listboxHeaderObj("Prev.Notes",true),
	new listboxHeaderObj("Chg.By",true),
	new listboxHeaderObj("Chg.Date",true),
};
	if(selected_folderno.equals("")) return;
	forigid = convertFolderNoToInteger(selected_folderno).toString();

	sql = als_mysoftsql();
	if(sql == null ) return;
	sqlstm = "select origid,oldjobnotes,change_date,user_changed from JobNotes_History where jobfolders_id=" + forigid;
	histrecs = sql.rows(sqlstm);
	sql.close();

	if(histrecs.size() == 0)
	{
		showMessageBox("Sorry.. no job-notes history found");
		return;
	}

	Listbox newlb = makeVWListbox(historyjobnotes_lb_div,jobnoteshistory_lb_headers,"jobnoteshistory_lb", 5);

	for(dpi : histrecs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		jnotes = trimListitemLabel(dpi.get("oldjobnotes"),50);
		kabom.add(jnotes);
		kabom.add(dpi.get("user_changed"));
		kabom.add(dpi.get("change_date").toString().substring(0,10));
		strarray = convertArrayListToStringArray(kabom);
		insertListItems(newlb,strarray,"false");
	}
	jobnotes_history_popup.open(noteshistory_btn);
}

// To view the prev job-notes.. cannot run away.
// prev_jn_btn
void jobnoteshistory_viewprev_clicker()
{
	if(historyjobnotes_lb_div.getFellowIfAny("jobnoteshistory_lb") == null) return;
	if(jobnoteshistory_lb.getSelectedIndex() == -1) return;

	pjn_origid = jobnoteshistory_lb.getSelectedItem().getLabel(); // 1st col is JobNotes_History.origid
	pjnrec = getJobNotesHistory_Rec(pjn_origid);
	if(pjnrec == null) return;
	prevjn_tb.setValue(pjnrec.get("oldjobnotes"));
	viewprev_jn_popup.open(prev_jn_btn);
}
//----------- end of Job-notes stuff

// 07/10/2011: stock_cat dropdown - can be used in other module, change listbox id and div
// listbox = stockcategory_lb
void populateStockCat_dropdown(Div idiv)
{
	Object[] sm_lb_headers = {
	new dblb_HeaderObj("stockcat",true,"stock_cat",1),
	};

	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select distinct stock_cat from stockmasterdetails order by stock_cat";
	Listbox newlb = makeVWListbox_onDB(idiv,sm_lb_headers,"stockcategory_lb",1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle("font-size:9px");
	newlb.setSelectedIndex(0);
}

// listbox = groupcode_lb
void populateGroupCode_dropdown(Div idiv)
{
	Object[] sm_lb_headers = {
	new dblb_HeaderObj("groupcode",true,"groupcode",1),
	};

	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select distinct groupcode from stockmasterdetails order by groupcode";
	Listbox newlb = makeVWListbox_onDB(idiv,sm_lb_headers,"groupcode_lb",1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle("font-size:9px");
	newlb.setSelectedIndex(0);
}
// ENDOF

// listbox = customer_terms_lb
void populateCustomerTerms_dropdown(Div idiv)
{
	Object[] sm_lb_headers = {
	new dblb_HeaderObj("credit_period",true,"credit_period",1),
	};

	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select distinct credit_period from customer order by credit_period";
	Listbox newlb = makeVWListbox_onDB(idiv,sm_lb_headers,"customer_terms_lb",1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle("font-size:9px");
	newlb.setSelectedIndex(0);
}
// ENDOF

// To populate salesman drop-down - can be used for other mods
void populateSalesman_dropdown(Div idiv)
{
	Object[] sm_lb_headers = {
	new dblb_HeaderObj("SM.Name",true,"salesman_name",1),
	new dblb_HeaderObj("SM.Code",false,"salesman_code",1),
	};
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select salesman_code,salesman_name from salesman";
	Listbox newlb = makeVWListbox_onDB(idiv,sm_lb_headers,"qt_salesperson",1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle("font-size:9px");
	newlb.setSelectedIndex(0); // default
}

// To populate salesman drop-down - can be used for other mods
// idiv : where to put, ilb_name = listbox ID
// 21/11/2011: add filter-out resigned staff
void populateQuotationUser_dropdown(Div idiv, String ilb_name)
{
	Object[] sm_lb_headers = {
	new dblb_HeaderObj("SM.Name",true,"username",1),
	};
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select distinct username from elb_quotations where username not in ('nadiah','chen','wongev','suiyee','yclim','metest')";
	Listbox newlb = makeVWListbox_onDB(idiv,sm_lb_headers,ilb_name,1,sql,sqlstm);
	sql.close();
	newlb.setMold("select");
	newlb.setStyle("font-size:9px");
	newlb.setSelectedIndex(0); // default
}

