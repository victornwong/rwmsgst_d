/**
 * Job-folders module general purpose functions
 * @author Victor Wong
 * @since 14/04/2016
 */

void disable_Butts(boolean iwhat)
{
	massDisableComponents(module_butts,iwhat); // components array defined in main
	massDisableComponents(jobmetaboxes,iwhat);
	massDisableComponents(customerdetails_boxes,iwhat);
	massDisableComponents(samplesmetaboxes,iwhat);
}

Object[] jobfolderhds1 =
{
	new listboxHeaderWidthObj("JOB",true,"80px"),
	new listboxHeaderWidthObj("DATED",true,"70px"),
	new listboxHeaderWidthObj("CUSTOMER",true,""),
	new listboxHeaderWidthObj("SC",true,"60px"),
	new listboxHeaderWidthObj("STAT",true,"70px"),
	new listboxHeaderWidthObj("PRTY",true,"70px"), // 5
	new listboxHeaderWidthObj("USER",true,"70px"),
	new listboxHeaderWidthObj("STAGE",true,"70px"),
	new listboxHeaderWidthObj("arcode",false,""),
};
JF_ORIGID = 0; JF_DATED = 1; JF_CUSTOMER = 2; JF_SAMPLECOUNT = 3;
JF_STATUS = 4; JF_PRIORITY = 5; JF_USER = 6; JF_LABSTATUS_STAGE = 7; JF_ARCODE = 8;

last_listjob_type = 0;

class joblbonselect implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException { jobfolders_callBack(event.getReference()); }
}
joblb_onselect = new joblbonselect();

class joblbdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException { jobfolders_callBack(event.getTarget()); }
}
joblb_dcliker = new joblbdclick();

/**
 * List job-folders, uses some hardcoded UI obj: startdate,enddate,searhtxt_tb,byjob_tb
 * @param pType type of list-out
 * @param pDiv  DIV holder
 * @param pLbid listbox ID string
 */
void listJobFolders(int pType, Div pDiv, String pLbid)
{
	last_listjob_type = (pType == 0) ? 1 : pType;
	sdate = kiboo.getDateFromDatebox(startdate); edate = kiboo.getDateFromDatebox(enddate);
	jfi = "0";
	try { jfi = Integer.parseInt(byjob_tb.getValue().trim()).toString(); } catch (Exception e) {}
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());

	Listbox newlb = lbhand.makeVWListbox_Width(pDiv, jobfolderhds1, pLbid, 13);
	newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", joblb_onselect);

	sqlstm = "select j.origid,j.ar_code,j.datecreated,j.folderstatus,j.priority,j.createdby,j.labfolderstatus," +
	"CAST((select count(origid) from JobSamples where jobfolders_id=j.origid) as DECIMAL(0)) as samplecount, c.customer_name " +
	"from JobFolders j " +
	"left join Customer c on c.ar_code=j.ar_code ";

	switch(pType)
	{
		case 1: // by date-range and search-text
			sqlstm += "where DATE(j.datecreated) between '" + sdate + "' and '" + edate + "' ";
			if(!st.equals("")) sqlstm += "and c.customer_name like '%" + st + "%' ";
			break;

		case 2: // by job-folder ONLY
			sqlstm += "where j.origid=" + jfi;
			break;
	}

	sqlstm += " order by j.origid;";
	r = vsql_GetRows(sqlstm); if(r.size() == 0) return;

	String[] fl = { "origid","datecreated","customer_name","samplecount","folderstatus","priority","createdby","ar_code" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		li = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	//lbhand.setDoubleClick_ListItems(newlb, joblb_dcliker);
}

/**
 * Insert a new blank job-folder into database
 * @param pUser   user-name creator
 * @param pBranch branch-name, for future usage
 */
void vInsert_JobFolder(String pUser, String pBranch)
{
	Sql sql = v_Sql(); if(sql == null) { guihand.showMessageBox("ERR: Cannot connect to database.."); return; }
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into JobFolders " +
	" (ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate," +
	"tat,extranotes,folderstatus,deleted,folderno_str," + 
	"deliverymode,securityseal,noboxes,temperature,custreqdate," +
	"customerpo,customercoc,allgoodorder,paperworknot,paperworksamplesnot, " + 
	"samplesdamaged,attention,priority,exportReportTemplate,branch," +
	"labfolderstatus,releasedby,releaseddate,coadate,coaprintdate," + 
	"jobnotes,lastjobnotesdate,share_sample,createdby) values " + 
	"(?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?)");

	String todaysdate = kiboo.todayISODateTimeString();

	pstmt.setString(1,""); pstmt.setString(2,todaysdate); pstmt.setInt(3,0); pstmt.setInt(4,0); pstmt.setString(5,todaysdate);
	pstmt.setInt(6,7); pstmt.setString(7,""); pstmt.setString(8,FOLDER_DRAFT); pstmt.setInt(9,0); pstmt.setString(10,"");
	pstmt.setString(11,""); pstmt.setString(12,""); pstmt.setString(13,""); pstmt.setString(14,""); pstmt.setString(15,todaysdate);
	pstmt.setString(16,""); pstmt.setString(17,""); pstmt.setInt(18,0); pstmt.setInt(19,0); pstmt.setInt(20,0);
	pstmt.setInt(21,0); pstmt.setString(22,""); pstmt.setString(23,"NORMAL"); pstmt.setInt(24,0); pstmt.setString(25,pBranch);
	pstmt.setString(26,"WIP"); pstmt.setString(27,""); pstmt.setString(28,null); pstmt.setString(29,null); pstmt.setString(30,null);

	pstmt.setString(31,""); pstmt.setString(32,null); pstmt.setString(33,""); pstmt.setString(34,pUser);

	pstmt.executeUpdate(); sql.close();
	//alert("insert new job"); // TODO nagbar
}

/**
 * Save job-folder meta-data
 * @param pJn job-folder no., origid
 */
void saveFolderMetadata(String pJn)
{
	Sql sql = v_Sql(); if(sql == null) { guihand.showMessageBox("ERR: Cannot connect to database.."); return; }
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement(
	"update JobFolders set ar_code=?, projectref=?, projectsiteref=?, customerpo=?, customercoc=?, tat=?, duedate=?, priority=?," +
	"deliverymode=?, securityseal=b?, noboxes=?, temperature=?, samplesdamaged=b?, paperworknot=b?, paperworksamplesnot=b?, allgoodorder=b?," +
	"extranotes=? where origid=?;");

	String todaysdate = kiboo.todayISODateTimeString();
	d = ngfun.getString_fromUI(jobmetaboxes);

	for(i=0;i<jobmetafields.length;i++)
	{
		if(jobmetafields[i].equals("tat"))
		{
			k = 7; // set default TAT : 7 days
			try { k = Integer.parseInt(d[i]); } catch (Exception e) {}
			pstmt.setInt(i+1, k);
		}
		else
		{
			pstmt.setString(i+1,d[i]);
		}
	}
	pstmt.setInt(18,Integer.parseInt(pJn)); // where origid=?
	pstmt.executeUpdate(); sql.close();
	//alert("updated.."); // TODO nagbar
}

void showJobFolder_Metadata(Object pJfr)
{
	// show job-folder metadata
	jobfolder_header_lbl.setValue("[" + kiboo.dtf2.format(pJfr.get("datecreated")) + "] Job folder : " + pJfr.get("origid").toString());
	ngfun.populateUI_Data(jobmetaboxes,jobmetafields,pJfr);

	cr = null;
	if(pJfr.get("ar_code") != null)
	{
		cr = get_CustomerByArCode(pJfr.get("ar_code"));
		if(cr != null)
		{
			ngfun.populateUI_Data(customerdetails_boxes,customerdetails_fields,cr);
		}
	}

	disable_Butts( (pJfr.get("folderstatus").equals(FOLDER_DRAFT)) ? false : true ); // Check job-folder status, if not DRAFT, disable all butts

	showJob_Samples(pJfr.get("origid").toString(),samples_holder,SAMPLES_LISTBOX_ID,sampleshds1,13); // show samples
	showJobNotes(JN_linkcode(),jobnotes_holder,"folderjobnotes_lb"); // show job-notes (jobnotes_v2.zs)
	// show attachments
}
