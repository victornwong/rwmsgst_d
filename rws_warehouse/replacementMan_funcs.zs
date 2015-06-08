
import org.victor.*;

// Supporting funcs for replacementMan_v1.zul
// Written by Victor Wong

void toggleRMAItems_butts(boolean iwhat)
{
	savermaitem_b.setDisabled(iwhat);
	completeitem_b.setDisabled(iwhat);
	//updrma_b.setDisabled(iwhat); // TODO logic to see need to save rma-details sometimes..
}

void sendEmailNotification(int itype)
{
	// use rw_localrma.createdby to get email-addr from user-table
	if(glob_sel_rmauser.equals("")) return;
	urc = sechand.getPortalUser_Rec_username(glob_sel_rmauser);
	if(urc == null) { guihand.showMessageBox("ERR: send-noti cannot access user-table"); return; }

	iwho = kiboo.checkNullString(urc.get("email"));
	if(iwho.equals("")) { guihand.showMessageBox("ERR: no email address defined, cannot send notification"); return; }

	subj = "TEST";
	msgb = "TESTING ONLY";
	lnkc = LOCALRMA_PREFIX + glob_selected_rma;

	switch(itype)
	{
		case 1: // RMA complete
			subj = lnkc + " has been fulfilled";
			msgb = lnkc + " has been fulfilled. To review, do login to the system.";
			break;
	}

	msgb += "\n\n--This is an automated notification-email, no reply necessary--";

	//simpleSendemail_MSEX(SYS_SMTPSERVER,SYS_EMAILUSER,SYS_EMAILPWD,SYS_EMAIL,"victor@rentwise.com",subj,msgb);
}

void showPartsAuditLog(Object iwhat)
{
	itype = iwhat.getId();

	whatchk = null;
	if(itype.equals("al_newasset_tag")) whatchk = rmai_newasset_tag;
	if(itype.equals("al_monitor")) whatchk = rmai_monitor;
	if(itype.equals("al_gfxcard")) whatchk = rmai_gfxcard;
	if(itype.equals("al_battery")) whatchk = rmai_battery;
	if(itype.equals("al_pwradaptor")) whatchk = rmai_poweradaptor;
	if(itype.equals("al_ram")) whatchk = rmai_ram;
	if(itype.equals("al_hdd")) whatchk = rmai_hdd;

	if(itype.equals("al_ram2")) whatchk = rmai_ram2;
	if(itype.equals("al_ram3")) whatchk = rmai_ram3;
	if(itype.equals("al_ram4")) whatchk = rmai_ram4;

	if(itype.equals("al_hdd2")) whatchk = rmai_hdd2;
	if(itype.equals("al_hdd3")) whatchk = rmai_hdd3;
	if(itype.equals("al_hdd4")) whatchk = rmai_hdd4;

	tstkc = kiboo.replaceSingleQuotes(whatchk.getValue().trim());
	if(tstkc.equals("")) return;
	showSystemAudit(auditlogs_holder,tstkc,"");
	auditlogs_pop.open(iwhat);
}

void clearRMAitemsBoxes()
{
	rmai_asset_tag.setValue("");
	rmai_origid.setValue("");
	rmai_problem.setValue("");
	rmai_action.setValue("");
	rmai_newasset_tag.setValue("");
	rmai_monitor.setValue("");
	rmai_gfxcard.setValue("");
	rmai_battery.setValue("");
	rmai_poweradaptor.setValue("");
	rmai_others.setValue("");
	rmai_notes.setValue("");
	rmai_ram.setValue("");
	rmai_hdd.setValue("");

	rmai_ram2.setValue("");
	rmai_ram3.setValue("");
	rmai_ram4.setValue("");

	rmai_hdd2.setValue("");
	rmai_hdd3.setValue("");
	rmai_hdd4.setValue("");
}

// Check RMA items complete all, return true
boolean checkRMACompletedItems(String iwhat)
{
	retv = false;

	sqlstm = "select count(rmai.origid) as items, " + 
	"(select count(origid) from rw_localrma_items where completeby is not null and parent_id=" + iwhat+ ") as doneitems " +
	"from rw_localrma_items rmai where parent_id=" + iwhat;
	krc = sqlhand.gpSqlFirstRow(sqlstm);

	if(krc != null)
	{
		if((int)krc.get("items") == (int)krc.get("doneitems")) retv = true;
	}
	return retv;
}

// retval: 0=cannot find stockcode, 1=bom_id ada, 2=rma_id ada, 3=bom_id and rma_id ada, 4=all good
int checkReplacementParts(String istkcode)
{
	retval = -1;
	//if(istkcode.equals("")) return 0;
	sqlstm = "select bom_id,rma_id from stockmasterdetails where stock_code='" + istkcode + "'";
	krc = sqlhand.gpSqlFirstRow(sqlstm);
	//alert(sqlstm + " :: " + krc);
	if(krc != null)
	{
		bmid = krc.get("bom_id");
		rmid = krc.get("rma_id");
		if(bmid != null) retval = 1;
		if(rmid != null) retval = 2;
		if(bmid != null && rmid != null) retval = 3;
	}
	else
		retval = 0;

	if(retval == -1) retval = 4;

	return retval;
}

String rmaitem_errorMsg(String iwtype, String istkcode, int ierrt)
{
	// HARDCODED err-msg
	String[] errmsg = {
	" not found in inventory..",
	" is already used in a BOM.",
	" is already assigned in another RMA"," AMBIGUOUS, assigned to RMA and BOM!!"," Checked OK.." };

	retval = "\n" + iwtype + ": " + istkcode + errmsg[ierrt];
}

void showRMA_items_meta(String iwhat, String iasstag)
{
	kitm = getLocalRMAItem_rec(iwhat);
	if(kitm == null) { guihand.showMessageBox("ERR: Cannot access RMA-items table"); return; }

	rmai_asset_tag.setValue(iasstag);
	rmai_problem.setValue( kiboo.checkNullString(kitm.get("problem")) );
	rmai_action.setValue( kiboo.checkNullString(kitm.get("action")) );
	rmai_notes.setValue( kiboo.checkNullString(kitm.get("notes")) );
	rmai_newasset_tag.setValue( kiboo.checkNullString(kitm.get("newasset_tag")) );
	rmai_monitor.setValue( kiboo.checkNullString(kitm.get("monitor")) );
	rmai_gfxcard.setValue( kiboo.checkNullString(kitm.get("gfxcard")) );
	rmai_battery.setValue( kiboo.checkNullString(kitm.get("battery")) );
	rmai_poweradaptor.setValue( kiboo.checkNullString(kitm.get("poweradaptor")) );
	rmai_others.setValue( kiboo.checkNullString(kitm.get("others")) );
	rmai_hdd.setValue( kiboo.checkNullString(kitm.get("hdd")) );
	rmai_ram.setValue( kiboo.checkNullString(kitm.get("ram")) );

	rmai_ram2.setValue( kiboo.checkNullString(kitm.get("ram2")) );
	rmai_ram3.setValue( kiboo.checkNullString(kitm.get("ram3")) );
	rmai_ram4.setValue( kiboo.checkNullString(kitm.get("ram4")) );

	rmai_hdd2.setValue( kiboo.checkNullString(kitm.get("hdd2")) );
	rmai_hdd3.setValue( kiboo.checkNullString(kitm.get("hdd3")) );
	rmai_hdd4.setValue( kiboo.checkNullString(kitm.get("hdd4")) );

	rmai_origid.setValue("[c:" + iwhat + "]");
}

Object[] rmaitms_headers =
{
	new listboxHeaderWidthObj("ori",false,""),
	new listboxHeaderWidthObj("##",true,"40px"),
	new listboxHeaderWidthObj("AssetTag",true,"80px"),
	new listboxHeaderWidthObj("Stat",true,"50px"),
	new listboxHeaderWidthObj("Action",true,""),
	new listboxHeaderWidthObj("CompBy",true,"60px"),
};

class rmailbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_rmaitem_li = isel;
		glob_sel_rmaitem = lbhand.getListcellItemLabel(isel,0);
		glob_sel_assettag = lbhand.getListcellItemLabel(isel,2);

		cmck = ( lbhand.getListcellItemLabel(isel,5).equals("") ) ? false : true;
		toggleRMAItems_butts(cmck); // if already completed-by .. disable butts

		showRMA_items_meta(glob_sel_rmaitem,glob_sel_assettag);
		//alert(glob_sel_rmaitem + " : " + glob_sel_assettag);
	}
}

void showRMA_items(String irma)
{
	Listbox newlb = lbhand.makeVWListbox_Width(rmaitems_holder, rmaitms_headers, "rmaitems_lb", 8);
	sqlstm = "select rmai.origid,rmai.asset_tag,rmai.action,rmai.itemstatus,rmai.completeby " + 
	"from rw_localrma_items rmai where rmai.parent_id=" +  irma;
	rmais = sqlhand.gpSqlGetRows(sqlstm);
	if(rmais.size() == 0) return;

	//newlb.setCheckmark(true);
	//newlb.setMultiple(true);
	newlb.addEventListener("onSelect", new rmailbClick());
	lncnt = 1;

	for(dpi : rmais)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		kabom.add(lncnt.toString() + ".");
		kabom.add(kiboo.checkNullString(dpi.get("asset_tag")));
		kabom.add(kiboo.checkNullString(dpi.get("itemstatus")));
		kabom.add(kiboo.checkNullString(dpi.get("action")));
		kabom.add(kiboo.checkNullString(dpi.get("completeby")));
		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbitm = lbhand.insertListItems(newlb,strarray,"false","");
		lncnt++;
	}
}

// update RMA li, completed items count ONLY
void updateRMA_completeditems(String iwhat)
{
		isql = "select count(origid) as doneitems from rw_localrma_items " + 
		"where completeby is not null and parent_id=" + iwhat;
		krc = sqlhand.gpSqlFirstRow(isql);
		if(krc != null)
		{
			//alert("wo:" + krc.get("doneitems").toString());
			lbhand.setListcellItemLabel(glob_sel_rma_li,9,krc.get("doneitems").toString()); // take care of the col rmalb_headers[]
		}
}

void showRMA_metadata(String irma) // knockoff localRMA_v1.zul
{
	rmr = getLocalRMA_rec(irma);
	l_priority.setValue( kiboo.checkNullString(rmr.get("priority")) );
	l_delivery_addr.setValue(kiboo.checkNullString(rmr.get("delivery_addr")));
	l_notes.setValue(kiboo.checkNullString(rmr.get("rma_notes")));
	l_createdby.setValue(kiboo.checkNullString(rmr.get("createdby")));

	if(!glob_sel_fc6custid.equals(""))
	{
		l_customername.setValue( kiboo.checkNullString(getFocus_CustomerName(glob_sel_fc6custid)) );
	}
}

Object[] rmalb_headers =
{
	new listboxHeaderWidthObj("RMA#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Owner",true,"60px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Pickup",true,"60px"),
	new listboxHeaderWidthObj("PickDt",true,"60px"),
	new listboxHeaderWidthObj("Complt",true,"60px"),
	new listboxHeaderWidthObj("Items",true,"30px"),
	new listboxHeaderWidthObj("C.Itm",true,"30px"),
	new listboxHeaderWidthObj("fc6cust",false,""),
};

class rmalbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_rma_li = isel;
		glob_selected_rma = lbhand.getListcellItemLabel(isel,0);
		//glob_rma_status = lbhand.getListcellItemLabel(isel,5);
		glob_rma_pickupby = lbhand.getListcellItemLabel(isel,5);
		glob_rma_completed = lbhand.getListcellItemLabel(isel,7);
		glob_sel_fc6custid = lbhand.getListcellItemLabel(isel,10);
		glob_sel_rmauser = lbhand.getListcellItemLabel(isel,3);

		pkup = (glob_rma_pickupby.equals("")) ? true : false; // if RMA not pickup by anyone, cannot do per-item func
		toggleRMAItems_butts(pkup);

		l_origid.setValue(glob_selected_rma);
		showRMA_metadata(glob_selected_rma);
		showRMA_items(glob_selected_rma);

		glob_sel_rmaitem = ""; // reset rma-item if new RMA selected
		clearRMAitemsBoxes();

		workarea.setVisible(true);

		//btst = (glob_rma_status.equals("DRAFT")) ? false : true;
		//disableButts(btst); // if local-rma not new, disable those butts
	}
}

void showLocalRMA() // knockoff localrma_v1.zul
{
	scht = kiboo.replaceSingleQuotes( search_tb.getValue().trim() );
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
	wherestr = "";

	Listbox newlb = lbhand.makeVWListbox_Width(rmas_holder, rmalb_headers, "rma_lb", 10);

	sqlstm = "select rma.origid,cust.name as custname,rma.datecreated,rma.createdby,rma.priority," + 
	"rma.pickupby,rma.pickupdate, rma.completed,rma.createdby, rma.fc6_custid, " +
	"(select count(origid) from rw_localrma_items where parent_id = rma.origid) as items, " +
	"(select count(origid) from rw_localrma_items where completeby is not null and parent_id=rma.origid) as doneitems " +
	"from rw_localrma rma " +
	"left join focus5012.dbo.mr000 cust on cust.masterid=rma.fc6_custid " +
	"where rma.rstatus='COMMIT' and rma.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	if(!scht.equals("")) wherestr = "and (cust.name like '%" + scht + "%' or rma.createdby like '%" + scht + "%') ";

	sqlstm += wherestr + " order by rma.priority desc";

	//and rma.completed is null 

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;

	newlb.setRows(20);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", new rmalbClick());

	for(dpi : screcs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		kabom.add(dpi.get("datecreated").toString().substring(0,10));
		kabom.add( kiboo.checkNullString(dpi.get("custname")) );
		kabom.add(kiboo.checkNullString(dpi.get("createdby")));
		tprio = kiboo.checkNullString(dpi.get("priority"));
		kabom.add(tprio);
		kabom.add(kiboo.checkNullString(dpi.get("pickupby")));

		pkdt = (dpi.get("pickupdate") == null) ? "" : dtf.format(dpi.get("pickupdate")) ;
		kabom.add(pkdt);
		cmdt = (dpi.get("completed") == null) ? "" : dtf.format(dpi.get("completed")) ;
		kabom.add(cmdt);

		kabom.add(dpi.get("items").toString());
		kabom.add(dpi.get("doneitems").toString());
		kabom.add( kiboo.checkNullString(dpi.get("fc6_custid")) );
		strarray = kiboo.convertArrayListToStringArray(kabom);

		mysty = "";
		if(tprio.equals("CRITICAL")) mysty = "font-size:9px;" + CRITICAL_BACKGROUND;
		if(tprio.equals("URGENT")) mysty = "font-size:9px;" + URGENT_BACKGROUND;

		lbhand.insertListItems(newlb,strarray,"false",mysty);
	}
}


