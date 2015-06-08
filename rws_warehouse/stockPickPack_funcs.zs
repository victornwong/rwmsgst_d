import java.util.*;
import java.text.*;
import org.victor.*;

// General funcs for stockPickPack_v1.zul

SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
DecimalFormat nf2 = new DecimalFormat("#0.00");

// hide/show areas -- toggler
void blindTings(Object iwhat, Object icomp)
{
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
	
	// HARDCODED for this
	//if(itype.equals("blind_datebox")) search_header.setVisible((bld) ? false : true);
}

// Toggle 'em work butts by types now..
// itype: 0=all, 1=metadata butts, 2=workare main butts, 3=save-all butt + Upload(items worksheet) ONLY
void toggleButts(int itype, boolean iwhat)
{
	if(itype == 1 || itype == 0)
	{
		asscust_b.setDisabled(iwhat);
		updatepl_b.setDisabled(iwhat);
		newpicktype_b.setDisabled(iwhat);
	}

	if(itype == 2 || itype == 0)
	{
		saveallitems_b.setDisabled(iwhat);

		kis = pl_rows.getFellows();
		for(di : kis)
		{
			cid = di.getId().substring(0,2);
			if(cid.equals("CT")) di.setDisabled(iwhat);
			if(cid.equals("UD")) di.setDisabled(iwhat);
			if(cid.equals("RM")) di.setDisabled(iwhat);
			if(cid.equals("UP")) di.setDisabled(iwhat);
			if(cid.equals("UD")) di.setDisabled(iwhat);
		}
	}

	if(itype == 3)
	{
		saveallitems_b.setDisabled(iwhat);

		kis = pl_rows.getFellows();
		for(di : kis)
		{
			cid = di.getId().substring(0,2);
			if(cid.equals("UP")) di.setDisabled(iwhat);
		}
	}
}

void showPickPackMeta(String iwhat)
{
	ppr = getPickPack_rec(iwhat);
	if(ppr == null) { guihand.showMessageBox("ERR: Cannot access pick-pack table.."); return; }

	i_requestor.setValue( kiboo.checkNullString(ppr.get("requestor")) );
	lbhand.matchListboxItems(i_os_id, kiboo.checkNullString(ppr.get("os_id")) );
	customername.setValue( kiboo.checkNullString(ppr.get("customer_name")) );

	jid = (ppr.get("job_id") == null) ? "" : ppr.get("job_id").toString();
	job_id.setValue(jid);

	showPickPack_items(iwhat);
	fillDocumentsList(documents_holder,PICKLIST_PREFIX,iwhat);

	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	jobnotes_div.setVisible(true);

	if(jobnotes_div.getFellowIfAny("shwmini_ji_row") != null)
		shwmini_ji_row.setVisible(false); // 10/09/2013: hide linking-job grid-row. Wait till user click -> reload -> show

	ppl_workarea.setVisible(true);
	workarea.setVisible(true);
}

Object[] pickp_headers = 
{
	new listboxHeaderWidthObj("###",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Reqr",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Stat",true,"50px"), // 5
	new listboxHeaderWidthObj("R.By",true,"50px"),
	new listboxHeaderWidthObj("R.Date",true,"60px"),
	new listboxHeaderWidthObj("QA.Date",true,"60px"),
	new listboxHeaderWidthObj("QA.User",true,"60px"),
	new listboxHeaderWidthObj("JobID",true,"50px"),

};

class pickpClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_picklist = lbhand.getListcellItemLabel(isel,0);
		global_selected_customer = lbhand.getListcellItemLabel(isel,4);
		glob_sel_status = lbhand.getListcellItemLabel(isel,5);
		glob_sel_jobid = lbhand.getListcellItemLabel(isel,10);

		pick_mhd.setValue("PICK-LIST : " + glob_sel_picklist);
		pick_mhd2.setValue("PICK-LIST : " + glob_sel_picklist);

		showPickPackMeta(glob_sel_picklist);

		toggleButts(0,false); // def all butts on for NEW
		if(glob_sel_status.equals("WIP"))
		{
			toggleButts(0,true);
			toggleButts(3,false);
		}
		// pick-list already done/received -- disable all butts
		if(glob_sel_status.equals("DONE") || glob_sel_status.equals("RECV")) toggleButts(0,true);
	}
}
pickpkkclk = new pickpClick();

void showPickPacks()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(picklists_holder, pickp_headers, "pickpack_lb", 6);

	sqlstm = "select origid,datecreated,username,requestor,customer_name,status," + 
	"receivedby,receivedate,job_id,qa_date,qa_username from rw_pickpack " +	
	"where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	if(!scht.equals("")) sqlstm += "and customer_name like '%" + scht + "%' ";
	sqlstm += "order by origid ";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(10);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", pickpkkclk );
	ArrayList kabom = new ArrayList();
	String[] fl = {	"origid", "datecreated", "username", "requestor", "customer_name", "status",
	"receivedby", "receivedate", "qa_date", "qa_username", "job_id" };
	for(dpi : screcs)
	{
		popuListitems_Data(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	picklists_holder.setVisible(true);
}

