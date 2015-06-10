import org.victor.*;
import java.math.BigDecimal;
// RW purchase-requisition supporting funcs
// Written by : Victor Wong
// 05/03/2014: integrate FC6 temp-grn in grnPO_tracker.zul

void disableButts(boolean iwhat)
{
	Object[] ob = { newitem_b, remitem_b, calcitems_b, saveitems_b, updatepr_b,
	asssupp_b, getjobid_b };

	for(i=0;i<ob.length;i++)
	{
		ob[i].setDisabled(iwhat);
	}
}

// custom func to sum-up items qty*price
float calcPR_total(String[] iqty, String[] iuprice)
{
	rtot = 0.0;
	for(i=0;i<iqty.length;i++)
	{
		try {
		rtot += Float.parseFloat(iqty[i]) * Float.parseFloat(iuprice[i]);
		} catch (Exception e) {}
	}
	return (float)rtot;
}

int getWeekOfDay_java(java.sql.Timestamp datey)
{
	if(datey == null) return 0;
	Date dt1 = dtf2.parse(dtf2.format(datey));
	Calendar ca1 = Calendar.getInstance();
	ca1.setTime(dt1);
	ca1.setMinimalDaysInFirstWeek(1);
	return ca1.get(Calendar.WEEK_OF_MONTH);
}

// Send noti-email for dis/approve PR
void prApprovalEmailNoti(String iprid, int itype)
{
	prc = getPR_rec(iprid);
	if(prc == null) return;
	reqr = sechand.getPortalUser_Rec_username( kiboo.checkNullString(prc.get("username")) ) ;
	if(reqr == null) return;
	if( kiboo.checkNullString(reqr.get("email")).equals("")) return;

	appst = "";
	switch(itype)
	{
		case 1:
			appst = "APPROVED";
			break;
		case 2:
			appst = "DISAPPROVED";
			break;
	}

	lnkc = PR_PREFIX + iprid;
	topeople = reqr.get("email") + "," + NOTIF_EMAILS; // HARDCODED: notif emails list defined in rwpurchaseReq_v2.zul
	emailsubj = "RE: Your PR " + lnkc + " has been " + appst;
	emailmsg = "The PR you've submitted earlier has been " + appst;
	emailmsg += "\n\n(This is only a notification)";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
	//alert(prc + " :: " + reqr);
}

void checkPR_Approval(String iwhat)
{
	todaydate =  kiboo.todayISODateTimeString();
	appst = sqlstm = "";

	if(checkBPM_fullapproval(PR_PREFIX + iwhat)) // chk if full-approval
	{
		sqlstm = "update purchaserequisition set pr_status='APPROVED', approvedate='" + todaydate + "' where origid=" + iwhat;
		glob_sel_prstatus = "APPROVE";
		appst = "APPROVE";
		prApprovalEmailNoti(iwhat,1);
		disableButts(true);
	}
	else
	if(checkBPM_gotDisapproval(PR_PREFIX + iwhat)) // chk if any disapproval
	{
		sqlstm = "update purchaserequisition set pr_status='APPROVED', approvedate='" + todaydate + "' where origid=" + iwhat;
		glob_sel_prstatus = "DISAPPROVE";
		appst = "DISAPPROVE";
		prApprovalEmailNoti(iwhat,2);
	}

	if(!appst.equals(""))
		sqlstm = "update purchaserequisition set pr_status='" + appst + "', approvedate='" + todaydate + "' where origid=" + iwhat;

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	showPRList(last_listpr_type);
}

void showPRMetadata(String iwhat)
{
	Object[] ob = { p_origid, p_datecreated, p_supplier_name, p_sup_contact, p_sup_tel, p_sup_fax, p_sup_email,
	p_sup_address, p_notes, p_sup_quote_ref, p_duedate, p_priority, p_job_id, p_creditterm, p_curcode,
	p_paydue_date, p_sup_etd, p_purchasecat };

	String[] fs = { "origid", "datecreated", "supplier_name", "sup_contact", "sup_tel", "sup_fax", "sup_email",
	"sup_address", "notes", "sup_quote_ref", "duedate", "priority", "job_id", "creditterm", "curcode",
	"paydue_date", "sup_etd", "purchasecat" };

	prc = getPR_rec(iwhat);
	glob_pr_rec = prc; // 28/11/2013: store globally for later
	ngfun.populateUI_Data(ob, fs, prc);

	fillDocumentsList(documents_holder,PR_PREFIX,iwhat);
	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..

	if(!prc.get("pr_status").equals("CANCEL"))
		showApprovalThing(PR_PREFIX + iwhat, "PR", approvers_box );
	else
		if(approvers_box.getFellowIfAny("app_grid") != null) app_grid.setParent(null); // clear the approver-box

	// show PR items,prices,qty
	if(pritems_holder.getFellowIfAny("pritems_grid") != null) pritems_grid.setParent(null);
	checkMakeItemsGrid();

	ktg = sqlhand.clobToString(prc.get("pr_items"));
	if(!ktg.equals(""))
	{
		itms = sqlhand.clobToString(prc.get("pr_items")).split("~");
		iqty = sqlhand.clobToString(prc.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(prc.get("pr_unitprice")).split("~");
		ks = "font-size:9px;font-weight:bold;";

		for(i=0; i<itms.length; i++)
		{
			irow = new org.zkoss.zul.Row();
			irow.setParent(pritems_rows);

			gpMakeCheckbox(irow,"", "","");
			itm = "";
			try { itm = itms[i]; } catch (Exception e) {}
			desb = gpMakeTextbox(irow,"",itm,ks,"99%");
			desb.setMultiline(true);
			desb.setHeight("70px");

			qty = "";
			try { qty = iqty[i]; } catch (Exception e) {}
			gpMakeTextbox(irow,"",qty,ks,"99%"); // qty
			
			unp = "";
			try { unp = iupr[i]; } catch (Exception e) {}
			gpMakeTextbox(irow,"",unp,ks,"99%"); // unit price

			gpMakeLabel(irow,"","",ks); // sub-total
		}
	}

	total_lbl.setValue("");
	calcPRItems(pritems_rows); // do pr-items calc

	prst = ( prc.get("pr_status").equals("DRAFT") ) ? false : true;
	disableButts(prst);

	BPM_toggleButts( true, approvers_box);

	if(sechand.allowedUser(useraccessobj.username,"PR_APPROVERS"))
		BPM_toggleButts( (prc.get("pr_status").equals("SUBMIT")) ? false : true, approvers_box);

	workarea.setVisible(true);
	bpm_area.setVisible(true);

}

Object[] prlb_hds =
{
	new listboxHeaderWidthObj("PR#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Notify",true,"60px"), // 5
	new listboxHeaderWidthObj("Status",true,"60px"), // 6
	new listboxHeaderWidthObj("Job-ID",true,"60px"),
	new listboxHeaderWidthObj("Due",true,"60px"),
	new listboxHeaderWidthObj("Appr",true,"60px"),
	new listboxHeaderWidthObj("Sup.ETD",true,"65px"),
	new listboxHeaderWidthObj("Sup.Del",true,"65px"),
	new listboxHeaderWidthObj("D.Stat",true,"70px"),
	new listboxHeaderWidthObj("T.GRN",true,"40px"),
	new listboxHeaderWidthObj("Ver",true,"30px"), // 14
	new listboxHeaderWidthObj("Cate",true,"50px"),
};

p_ver = 14;
p_stt = 6;
p_cnm = 2;

class prlbcjlick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{ngfun = new NGfuncs(); rwsqlfun = new RWMS_sql();
		isel = event.getReference();
		glob_sel_prid = lbhand.getListcellItemLabel(isel,0);
		glob_sel_prstatus = lbhand.getListcellItemLabel(isel,p_stt);
		glob_sel_prversion = lbhand.getListcellItemLabel(isel,p_ver);
		global_selected_customer = lbhand.getListcellItemLabel(isel,p_cnm);
		showPRMetadata(glob_sel_prid);
	}
}
prlbclicker = new prlbcjlick();

void showPRList(int itype)
{
	last_listpr_type = itype;
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim()); // search by customer-name and so on
	sprn = kiboo.replaceSingleQuotes(searchprno_tb.getValue().trim()); // search by PR no.
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(prlist_holder, prlb_hds, "prs_lb", 22);

	sqlstm = "select top 100 origid,datecreated,supplier_name,username,priority,pr_status,duedate,approvedate," + 
	"sup_etd,sup_actual_deldate,job_id,version,notify_pr,del_status,temp_grn, purchasecat from purchaserequisition ";

	whdts = "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	switch(itype)
	{
		case 1: // by date-range and searchtext
			sqlstm += whdts;
			if(!st.equals("")) sqlstm += "and supplier_name like '%" + st + "%' ";
			break;

		case 2: // by pr-no
			try { kk = Integer.parseInt(sprn); } catch (Exception e) { return; }
			sqlstm += "where origid=" + sprn;
			searchprno_tb.setValue("");
			break;

		case 3: // approved PR
			sqlstm += whdts + "and pr_status='APPROVE'";
			break;

		case 4: // non-approved
			sqlstm += whdts + "and pr_status in ('SUBMIT','DRAFT')";
			break;
	}

	sqlstm += " order by origid";

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", prlbclicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "supplier_name", "username", "priority", "notify_pr", "pr_status", "job_id", "duedate",
	"approvedate", "sup_etd", "sup_actual_deldate", "del_status", "temp_grn", "version", "purchasecat" };
	for(dpi : r)
	{
		ngfun.popuListitems_Data(kabom,fl,dpi);
		supdeld = kiboo.checkNullDate(dpi.get("sup_actual_deldate"),"");
		stt = kiboo.checkNullString(dpi.get("pr_status"));
		prit = kiboo.checkNullString(dpi.get("priority"));
		spetd = kiboo.checkNullDate(dpi.get("sup_etd"),"");

		styl = "";
		if(kiboo.todayISODateString().equals(spetd) && supdeld.equals("")) styl = "background:#e58512;font-size:9px";

		if(prit.equals("URGENT") || prit.equals("CRITICAL") ) styl = "font-weight:bold;color:#ffffff;background:#cc0000;font-size:9px";
		if(stt.equals("APPROVE"))
		{
			styl = "font-weight:bold;background:#73d216;font-size:9px";
			if( prit.equals("URGENT") || prit.equals("CRITICAL") ) styl += ";background:#ef2929;color:#ffffff";
		}

		if(stt.equals("DISAPPROVE")) styl = "font-weight:bold;background:#ad7fa8;font-size:9px";

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",styl);
		kabom.clear();
	}
}

void savePRItems(String iwhat)
{
	if(pritems_holder.getFellowIfAny("pritems_grid") == null) return;
	cds = pritems_rows.getChildren().toArray();
	//if(cds.length < 1) return;
	itms = iqty = iuprice = "";
	todaydate =  kiboo.todayISODateTimeString();

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		itms += kiboo.replaceSingleQuotes( c1[1].getValue().replaceAll("~"," ") ) + "~";
		iqty += kiboo.replaceSingleQuotes( c1[2].getValue().replaceAll("~"," ") ) + "~";
		iuprice += kiboo.replaceSingleQuotes( c1[3].getValue().replaceAll("~"," ") ) + "~";
	}

	try { itms = itms.substring(0,itms.length()-1); } catch (Exception e) {}
	try { iqty = iqty.substring(0,iqty.length()-1); } catch (Exception e) {}
	try { iuprice = iuprice.substring(0,iuprice.length()-1); } catch (Exception e) {}

	sqlstm = "update purchaserequisition set pr_items='" + itms + "', pr_qty='" + iqty + "', pr_unitprice='" + iuprice + "' " +
	"where origid=" + iwhat;
	sqlhand.gpSqlExecuter(sqlstm);
}

void checkMakeItemsGrid()
{
	String[] colws = { "15px", "350px" ,"50px", "60px", "80px" };
	String[] colls = { "", "Item description", "Qty", "U.Price", "Sub.Total" };

	if(pritems_holder.getFellowIfAny("pritems_grid") == null) // make new grid if none
	{
		igrd = new Grid(); igrd.setId("pritems_grid");
		//igrd.setWidth("800px");

		icols = new org.zkoss.zul.Columns();
		for(i=0;i<colws.length;i++)
		{
			ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(colws[i]); ico0.setLabel(colls[i]);
			ico0.setAlign("center"); ico0.setStyle("background:#97b83a");
			ico0.setParent(icols);
		}
		icols.setParent(igrd);
		irows = new org.zkoss.zul.Rows();
		irows.setId("pritems_rows"); irows.setParent(igrd);
		igrd.setParent(pritems_holder);
	}
}

// Calculate sub-total and populate column
void calcPRItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	gtotal = 0.0;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		qty = c1[2].getValue();
		upr = c1[3].getValue();
		subt = 0.0;
		try { subt = Integer.parseInt(qty) * Float.parseFloat(upr); } catch (Exception e) {}
		gtotal += subt;
		c1[4].setValue(nf.format(subt));
	}
	total_lbl.setValue(nf.format(gtotal));
}

void removePRItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		if(c1[0].isChecked()) cds[i].setParent(null); // remove only CHECKED items
	}
}

void sendNoti_newPR(String iwhat,String iwho)
{
	lnkc = PR_PREFIX + iwhat;
	topeople = NOTIF_EMAILS; // defined in rwpurchaseReq_v2.zul
	//topeople = "victor@rentwise.com";
	emailsubj = "RE: New " + lnkc + " requested by " + iwho;
	emailmsg = "A new PR has been created. Pending procurement-division action.";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
	guihand.showMessageBox("Email-notification sent to procurement-division");
}

void sendPR_approver_email(String iwhat)
{
	lnkc = PR_PREFIX + iwhat;
	topeople = getFieldsCommaString("PR_APPROVERS",1);
	emailsubj = "RE: New " + lnkc + " submitted [" + glob_pr_rec.get("priority") + "]";
	emailmsg = "A new PR has been submitted. Pending approval, your action is required.";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
}

