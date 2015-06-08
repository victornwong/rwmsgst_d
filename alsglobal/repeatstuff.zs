import org.victor.*;

kiboo = new Generals();
lbhand = new ListboxHandler();
sqlhand = new SqlFuncs();
guihand = new GuiFuncs();
samphand = new SampleReg();
luhand = new LookupFuncs();

/*
Repetitive stuff used throughout other modules
Take note of some <popup> required by these funcs
*/

// pre-def itype for lookupfuncs.populateDynamic_Mysoft()

PDYN_TERMS = 0; // populateTerms_dropdown() = terms: customer.credit_period
PDYN_QUOTEUSER = 1; // populateQuotationUser_dropdown() = quotation users: elb_quotations.username
PDYN_SALESMAN = 2; // populateSalesman_dropdown()
PDYN_GROUPCODE = 3; // populateGroupCode_dropdown()
PDYN_STOCKCAT = 4; // populateStockCat_dropdown()
PDYN_CUSTOMERCAT = 5;

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

	ds_sql = sqlhand.als_DocumentStorage();
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

	Listbox newlb = lbhand.makeVWListbox(doculist_holder,documentlinkslb_headers,"doculinks_lb",10);

	if(docrecs.size() == 0) return;
	newlb.setMultiple(true);
	//newlb.addEventListener("onSelect", new doculinks_lb_Listener());

	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

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

		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}

	sql.close();
}

void viewDocument()
{
	if(!lbhand.check_ListboxExist_SelectItem(doculist_holder,"doculinks_lb")) return;
	eorigid = doculinks_lb.getSelectedItem().getLabel();
	theparam = "docid=" + eorigid;
	uniqid = kiboo.makeRandomId("vd");
	guihand.globalActivateWindow("//als_portal_main/","miscwindows","qc/viewlinkingdocument.zul", uniqid, theparam, useraccessobj);
}
// ---- ENDOF Linking documents funcs ---

//----------- Job-notes stuff : added 22/02/2011

void showJobNotes(String ifoldno)
{
	foldrec = samphand.getFolderJobRec(ifoldno);
	if(foldrec == null) return;
	jobnotes_tb.setValue(foldrec.get("jobnotes"));
}

void saveUpdateJobNotes()
{
	if(selected_folderno.equals("")) return;

	forigid = samphand.convertFolderNoToInteger(selected_folderno).toString();
	jobnotes = kiboo.replaceSingleQuotes(jobnotes_tb.getValue());

	if(!forigid.equals(""))
	{
		sql = sqlhand.als_mysoftsql();
		if(sql == null ) return;
		todaysdate = kiboo.getDateFromDatebox(hiddendatebox);

		// 19/7/2010: TeckMaan suggested to include a history feature for notes - incase others accidentally delete lines
		// get old JobFolders.jobnotes
		sqlstm1 = "select jobnotes from JobFolders where origid=" + forigid;
		oldj = sql.firstRow(sqlstm1);
		// insert into JobNotes_History table
		samphand.insertJobNotesHistory_Rec(forigid, oldj.get("jobnotes"), jobnotes, todaysdate,useraccessobj.username); // samplereg_funcs.zs
		// update JobFolders.jobnotes and JobFolders.lastjobnotesdate
		sqlstm = "update JobFolders set jobnotes='" + jobnotes + "', lastjobnotesdate='" + todaysdate + "' where origid=" + forigid;
		sql.execute(sqlstm);
		sql.close();
		guihand.showMessageBox("Job notes saved..");
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
	forigid = samphand.convertFolderNoToInteger(selected_folderno).toString();

	sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;
	sqlstm = "select origid,oldjobnotes,change_date,user_changed from JobNotes_History where jobfolders_id=" + forigid;
	histrecs = sql.rows(sqlstm);
	sql.close();

	if(histrecs.size() == 0)
	{
		guihand.showMessageBox("Sorry.. no job-notes history found");
		return;
	}

	Listbox newlb = lbhand.makeVWListbox(historyjobnotes_lb_div,jobnoteshistory_lb_headers,"jobnoteshistory_lb", 5);

	for(dpi : histrecs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		jnotes = lbhand.trimListitemLabel(dpi.get("oldjobnotes"),50);
		kabom.add(jnotes);
		kabom.add(dpi.get("user_changed"));
		kabom.add(dpi.get("change_date").toString().substring(0,10));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false");
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
	luhand.populateDynamic_Mysoft(PDYN_STOCKCAT,idiv,"","font-size:9px");
}

// listbox = groupcode_lb
void populateGroupCode_dropdown(Div idiv)
{
	luhand.populateDynamic_Mysoft(PDYN_GROUPCODE,idiv,"","font-size:9px");
}
// ENDOF

// TODO: same as populateTerms_dropdown(Div idiv) - find which mod using this one and change
// uses the same func call
// listbox = customer_terms_lb
void populateCustomerTerms_dropdown(Div idiv)
{
	luhand.populateDynamic_Mysoft(PDYN_TERMS,idiv,"customer_terms_lb","font-size:9px");
}
// ENDOF

// To populate salesman drop-down - can be used for other mods
void populateSalesman_dropdown(Div idiv)
{
	luhand.populateDynamic_Mysoft(PDYN_SALESMAN,idiv,"","font-size:9px");
}

// To populate salesman drop-down - can be used for other mods
// idiv : where to put, ilb_name = listbox ID
// 21/11/2011: add filter-out resigned staff
void populateQuotationUser_dropdown(Div idiv, String ilb_name)
{
	luhand.populateDynamic_Mysoft(PDYN_QUOTEUSER,idiv,ilb_name,"font-size:9px");
}

// terms distinct extracted from customer.credit_period - can be used for other mods
void populateTerms_dropdown(Div idiv)
{
	luhand.populateDynamic_Mysoft(PDYN_TERMS,idiv,"","font-size:9px");
}

