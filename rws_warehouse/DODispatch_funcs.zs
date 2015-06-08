import org.victor.*;
// Other misc funcs for DODispatch_v1.zul

glob_sel_do_li = null;

void showDOMetadata(String idoid)
{
	dor = getDO_rec(idoid);
	if(dor == null) return;

	d_origid.setValue(idoid);
	d_customer_name.setValue( kiboo.checkNullString(dor.get("customer_name")) );
	d_contact.setValue( kiboo.checkNullString(dor.get("contact")) );
	d_contact_tel.setValue( kiboo.checkNullString(dor.get("contact_tel")) );
	d_delivery_address.setValue( kiboo.checkNullString(dor.get("delivery_address")) );
	d_notes.setValue( kiboo.checkNullString(dor.get("do_notes")) );

	lnkc = DO_PREFIX + idoid;

	showApprovalThing(lnkc, "DO", approvers_box );

	if(dor.get("do_status").equals("SUBMIT"))
		BPM_checkUserAccess(approvers_box, useraccessobj.username);
	else
		BPM_toggleButts(true, approvers_box); // if DO not submit, BPM buttons always disable

	// Update bpm-approval things
	appf = checkBPM_fullapproval(lnkc);
	sqlstm = "update rw_deliveryorder set approve=" + ( (appf) ? "1" : "0" ) + " where origid=" + idoid;
	sqlhand.gpSqlExecuter(sqlstm);
	if(glob_sel_do_li != null) // update list-item
	{
		lbhand.setListcellItemLabel(glob_sel_do_li,6,(appf) ? "YES" : "NO"); // HARDCODED colm posi
	}

	if(appf) BPM_toggleButts(true, approvers_box); // disable BPM buttons too if DO already approved..

	toogleDOButts(0, false);
	if( dor.get("do_status").equals("SUBMIT") ) toogleDOButts(1, true);
}

class dosClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		glob_sel_do_li = event.getReference();
		glob_sel_do = lbhand.getListcellItemLabel(glob_sel_do_li,0);
		glob_sel_customername = lbhand.getListcellItemLabel(glob_sel_do_li,3);
		glob_sel_stat = lbhand.getListcellItemLabel(glob_sel_do_li,5);
		glob_sel_approve = lbhand.getListcellItemLabel(glob_sel_do_li,6);

		glob_sel_bomid = lbhand.getListcellItemLabel(glob_sel_do_li,7);
		glob_sel_picklist = lbhand.getListcellItemLabel(glob_sel_do_li,8);

		showDOMetadata(glob_sel_do);

		} catch (Exception e) {}
	}
}

Object[] dos_hds =
{
	new listboxHeaderWidthObj("DO#",true,"80px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("MFT",true,"40px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Stat",true,"60px"), // 5
	new listboxHeaderWidthObj("App",true,"30px"),
	new listboxHeaderWidthObj("BOM",true,"80px"), // 7
	new listboxHeaderWidthObj("P.Lst",true,"80px"),
	new listboxHeaderWidthObj("D.Date",true,"60px"),
};

last_listdo_type = 0;

void listDO(int itype)
{
	last_listdo_type = itype;

	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	sqlstm = "select do.origid,do.datecreated,do.customer_name,do.username,do.do_status,do.manif_id,do.approve,complete_date " + 
	"from rw_deliveryorder do ";

	switch(itype)
	{
		case 0:
			sqlstm += "where do.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!scht.equals("")) sqlstm += "and customer_name like '%" + scht + "%' ";
			//guihand.showMessageBox(sqlstm); return;
			break;

		case 1:
			if(!glob_sel_manif_dos.equals(""))
				sqlstm += "where do.origid in (" + glob_sel_manif_dos + ")";
			else
				return;
			break;
			
		case 2:
			donm = kiboo.replaceSingleQuotes(donumber_tb.getValue());
			if(donm.equals("")) return;
			sqlstm += "where do.origid in (" + donm + ")";
			break;
	}

	try {
	recs = sqlhand.gpSqlGetRows(sqlstm);
	} catch (Exception e) { return; }
	
	//alert(sqlstm + " :: " + recs);

	Listbox newlb = lbhand.makeVWListbox_Width(do_holder, dos_hds, "dos_lb", 5);
	if(recs.size() == 0) return;
	newlb.setRows(15);
	newlb.setCheckmark(true);
	newlb.setMultiple(true);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", new dosClick());

	for(d : recs)
	{
		doid = d.get("origid").toString();
		ArrayList kabom = new ArrayList();
		kabom.add(doid);
		kabom.add( dtf2.format(d.get("datecreated")) );
		kabom.add( (d.get("manif_id") == null) ? "" : d.get("manif_id").toString() );
		kabom.add(kiboo.checkNullString(d.get("customer_name")));
		kabom.add(kiboo.checkNullString(d.get("username")));
		kabom.add(kiboo.checkNullString(d.get("do_status")));

		kabom.add( (d.get("approve") == null) ? "NO" : (d.get("approve")) ? "YES" : "NO" );

		kabom.add( getLinkingJobID_others(BOM_DOID,doid) );
		kabom.add( getLinkingJobID_others(PICKLIST_DOID,doid) );

		kabom.add( (d.get("complete_date") == null) ? "" : dtf2.format(d.get("complete_date")) );

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
	}

	dc_obj = new dosDClick();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

class dosDClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		showLinkingJobs(isel);
	}
}

// linking-job view job-details and job-notes button-clicker. Uses button label to determine type, ID screwup once dupes
class lj_viewdetClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		kid = event.getTarget().getLabel();
		cps = event.getTarget().getParent().getParent().getChildren().toArray();
		lnkid = "";

		if(kid.equals("J.Details") || kid.equals("B.Details") || kid.equals("P.Details"))
			lnkid = cps[ (kid.equals("J.Details")) ? 2 : 0 ].getValue();

		if(kid.equals("J.Notes") || kid.equals("B.Notes") || kid.equals("P.Notes"))
		{
			prf = JOBS_PREFIX;
			if(kid.equals("B.Notes")) prf = BOM_PREFIX;
			if(kid.equals("P.Notes")) prf = PICKLIST_PREFIX;
			lnkid = prf + cps[ (kid.equals("J.Notes")) ? 2 : 0 ].getValue();

			activateModule(mainPlayground,"workbox","rws_misc/showJobNotesWindow_v1.zul",kiboo.makeRandomId("vjc"),
			"jn=" + lnkid, useraccessobj);
		}

		if(kid.equals("J.Details"))
		{
			disdopanle.setOpen(false); // wind-up
			activateModule(mainPlayground,"workbox","rws_account/jobMaker_v1.zul",kiboo.makeRandomId("vjc"),
			"jb=" + lnkid, useraccessobj);
		}

		if(kid.equals("B.Details"))
		{
			activateModule(mainPlayground,"workbox","rws_warehouse/showBOMWindow_v1.zul",kiboo.makeRandomId("vbm"),
			"bom=" + lnkid, useraccessobj);
		}

		if(kid.equals("P.Details"))
		{
			activateModule(mainPlayground,"workbox","rws_warehouse/showPickListWindow_v1.zul",kiboo.makeRandomId("vpl"),
			"ppl=" + lnkid, useraccessobj);
		}
		
	}
}

// Could be modified for other mods
void showLinkingJobs(Component iwhere)
{
	if(glob_sel_bomid.equals("") && glob_sel_picklist.equals("")) return;
	bjr = pjr = null;

	if(!glob_sel_bomid.equals(""))
	{
		sqlstm = "select origid,job_id from stockrentalitems where origid in (" + glob_sel_bomid + ")";
		bjr = sqlhand.gpSqlGetRows(sqlstm);
	}

	if(!glob_sel_picklist.equals(""))
	{
		sqlstm = "select origid,job_id from rw_pickpack where origid in (" + glob_sel_picklist + ")";
		pjr = sqlhand.gpSqlGetRows(sqlstm);
	}
	
	//alert(bjr + " :: " + pjr);

	if(joblinkage_holder.getFellowIfAny("jlink_grid") != null) jlink_grid.setParent(null);

	apg = new Grid();
	apg.setId("jlink_grid");
	apg.setParent(joblinkage_holder);
	krws = new org.zkoss.zul.Rows();
	krws.setParent(apg);

	linkjobs_header.setValue("Jobs Linkage : " + DO_PREFIX + glob_sel_do);
	vjde = new lj_viewdetClick();

	if(bjr != null)
	{
		if(bjr.size() == 0) continue;

		irw = gridhand.gridMakeRow("","background:#729fcf","2,2",krws);
		gpMakeLabel(irw,"","BOM","font-size:9px");
		gpMakeLabel(irw,"","JOB","font-size:9px");

		for(d : bjr)
		{
			ji = d.get("job_id").toString();
			bi = d.get("origid").toString();

			irw = gridhand.gridMakeRow("","","",krws);
			gpMakeLabel(irw,"", bi, "font-weight:bold");

			hb = new Hbox();
			hb.setParent(irw);
			kb0 = gpMakeButton(hb, "", "B.Details", "font-size:9px", null);
			kb0.addEventListener("onClick",vjde);

			kb1 = gpMakeButton(hb, "", "B.Notes", "font-size:9px", null);
			kb1.addEventListener("onClick",vjde);

			gpMakeLabel(irw,"", ji, "font-weight:bold");

			hb = new Hbox();
			hb.setParent(irw);

			kb2 = gpMakeButton(hb, "", "J.Details", "font-size:9px", null);
			kb2.addEventListener("onClick",vjde);

			kb3 = gpMakeButton(hb, "", "J.Notes", "font-size:9px", null);
			kb3.addEventListener("onClick",vjde);
		}
	}
	
	if(pjr != null)
	{
		if(pjr.size() == 0) continue;

		irw = gridhand.gridMakeRow("","background:#729fcf","2,2",krws);
		gpMakeLabel(irw,"","PPL","font-size:9px");
		gpMakeLabel(irw,"","JOB","font-size:9px");

		for(d : pjr)
		{
			ji = d.get("job_id").toString();
			pi = d.get("origid").toString();

			irw = gridhand.gridMakeRow("","","",krws);

			gpMakeLabel(irw,"", pi, "font-weight:bold");

			hb = new Hbox();
			hb.setParent(irw);
			kb0 = gpMakeButton(hb, "", "P.Details", "font-size:9px", null);
			kb0.addEventListener("onClick",vjde);

			kb1 = gpMakeButton(hb, "", "P.Notes", "font-size:9px", null);
			kb1.addEventListener("onClick",vjde);
			
			gpMakeLabel(irw,"", ji, "font-weight:bold");

			hb = new Hbox();
			hb.setParent(irw);
			appb = gpMakeButton(hb, "", "J.Details", "font-size:9px", null);
			appb.addEventListener("onClick",vjde);
			kb3 = gpMakeButton(hb, "", "J.Notes", "font-size:9px", null);
			kb3.addEventListener("onClick",vjde);
		}
	}

	linkjobs_popup.open(iwhere);
}

// knockoff from jobmaker_funcs.zs -- trimmed
void showJobs()
{
Object[] jobs_headers =
{
	new listboxHeaderWidthObj("JOB",true,"70px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
};

	Listbox newlb = lbhand.makeVWListbox_Width(jobs_holder, jobs_headers, "jobs_lb", 5);

	sqlstm = 
	"select jbs.origid, jbs.datecreated, jbs.customer_name " +
	"from rw_jobs jbs " +
	"where jbs.status='WIP'";

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setRows(10);
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new jobsClick());

	for(d : recs)
	{
		jbid = d.get("origid").toString();
		ArrayList kabom = new ArrayList();
		kabom.add(jbid);

		kabom.add( dtf2.format(d.get("datecreated")) );
		kabom.add(kiboo.checkNullString(d.get("customer_name")));

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
	}

	jobs_holder.setVisible(true);
}

// Assign selected DO's to Manifest - do some stats checking and so on
void assignDOToManifest(String imfi, Object ils)
{
	domys = "";
	ks = ils.toArray();	

	for(i=0;i<ks.length;i++)
	{
		donm = lbhand.getListcellItemLabel(ks[i],0);
		mfi = lbhand.getListcellItemLabel(ks[i],2);
		apf = lbhand.getListcellItemLabel(ks[i],6); // take note of approve-column - in dodispatch_funcs.zs
		if(mfi.equals("")) // check selected DO not assigned to some manifest
		{
			cnm = lbhand.getListcellItemLabel(ks[i],3);
			if(!cnm.equals("UNDEF")) // make sure DO assigned to customer
			{
				if(apf.equals("YES")) // check if DO already approved..
					domys += donm + ",";
			}
		}
	}

	try {
		domys = domys.substring(0,domys.length()-1);
	} catch (Exception e) {}

	if(!domys.equals(""))
	{
		if (Messagebox.show("Assigning DO " + domys + " to manifest " + DISP_PREFIX + imfi, "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		sqlstm = "update rw_deliveryorder set manif_id=" + imfi + " where origid in (" + domys + ");";
		sqlhand.gpSqlExecuter(sqlstm);
		listDO(last_listdo_type);
		listManifest(last_list_manifest);
	}
	else
	{
		guihand.showMessageBox("Some DO was already assigned to some manifest or undefined customer..");
	}
}

// Dispatch/logistic manifest related funcs

// Based on the dowaybill_grid, get 'em items and update rw_deliveryorder
void updateDOWaybillStatus(Div iholder)
{
	if(iholder.getFellowIfAny("dowaybill_grid") == null) return; // no grid to process
	todaydate =  kiboo.todayISODateTimeString();
	// find all WB(waybill textbox) and DN(deliver checkbox)
	kcd = dowaybill_grid.getFellows();
	sqlstm = "";
	errc = 0;
	for(d : kcd)
	{
		cid = d.getId();
		if(cid.indexOf("WB") != -1)
		{
			doi = cid.substring(2,cid.length());
			wbn = kiboo.replaceSingleQuotes(d.getValue().trim());
			if(wbn.equals("")) errc++;
			else
			{
				dck = dowaybill_grid.getFellowIfAny("DN" + doi).isChecked();
				dost = (dck == true) ? ",complete_by='" + useraccessobj.username + "'," + "complete_date='" + todaydate + "'" : 
				",complete_by=null,complete_date=null";

				sqlstm += "update rw_deliveryorder set waybill_no='" + wbn + "'" + dost + " where origid=" + doi + ";";
			}
		}
	}

	if(errc > 0) { guihand.showMessageBox("ERR: Please enter some transporter way-bill or ref-no"); return; }
	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		listManifest(last_list_manifest);
		listDO(last_listdo_type);
	}
}

void listDOWaybill(String iseldos, Div iholder)
{
	if(iholder.getFellowIfAny("dowaybill_grid") != null) dowaybill_grid.setParent(null);
	if(glob_sel_manif_dos.equals("")) return; // no DOs assigned to manif

	sqlstm = "select origid,waybill_no,complete_date from rw_deliveryorder where origid in (" + iseldos + ");";
	drs = sqlhand.gpSqlGetRows(sqlstm);

	apg = new Grid();
	apg.setId("dowaybill_grid");
	krws = new org.zkoss.zul.Rows();
	krws.setParent(apg);
	apg.setParent(iholder);

	irw = gridhand.gridMakeRow("","background:#729fcf","",krws);
	gpMakeLabel(irw,"","DO#","font-size:9px");
	gpMakeLabel(irw,"","Waybill","font-size:9px");
	gpMakeLabel(irw,"","Delivered","font-size:9px");

	for(d : drs)
	{
		ki = d.get("origid").toString(); 
		irw = (org.zkoss.zul.Row)gridhand.gridMakeRow("","","",krws);
		gpMakeLabel(irw,"", DO_PREFIX + ki  ,"font-size:9px");
		gpMakeTextbox(irw, "WB" + ki, kiboo.checkNullString(d.get("waybill_no")), "font-weight:bold", "99%");

		mchk = gpMakeCheckbox(irw, "DN" + ki, "", "");
		bbn = (d.get("complete_date") == null) ? false : true;
		mchk.setChecked(bbn);

		//debugbox.setValue(debugbox.getValue() + "\n" + "D> " + irw);
	}
}

void showDispatchManifestMetadata(String imanf, String idotomanf, Object litm)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = "";

	drc = getDispatchManifest_rec(imanf);
	lbhand.matchListboxItems( m_transporter, kiboo.checkNullString(drc.get("transporter")) );
	m_manif_notes.setValue( kiboo.checkNullString(drc.get("manif_notes")) );

	fillDocumentsList(documents_holder,DISP_PREFIX,imanf);
	listDOWaybill(idotomanf,manf_items_holder);

	// disable update manifest DO items when do-count = delivered-do
	docount = lbhand.getListcellItemLabel(litm,7);
	deldo = lbhand.getListcellItemLabel(litm,8);
	upmanifstat_b.setDisabled( (docount.equals(deldo)) ? true : false);

	if(!docount.equals("0") && !deldo.equals("0"))
	{
		sqlstm = "update rw_dispatchmanif set deliverdate=";

		if(docount.equals(deldo)) // update rw_dispatchmanif.deliverdate
		{
			sqlstm += "'" + todaydate + "' ";
			lbhand.setListcellItemLabel(litm,5,todaydate); // update deliver-date list-item - no need to refresh whole list
		}
		else
		{
			sqlstm += "null ";
			lbhand.setListcellItemLabel(litm,5,""); // take note of the column posi
		}

		sqlstm += "where origid=" + imanf;
		sqlhand.gpSqlExecuter(sqlstm);
	}
}

class manifClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_manif = lbhand.getListcellItemLabel(isel,0);
		glob_sel_manif_stat = lbhand.getListcellItemLabel(isel,4);
		glob_sel_manif_dos = lbhand.getListcellItemLabel(isel,6);
		showDispatchManifestMetadata(glob_sel_manif,glob_sel_manif_dos,isel);

		docholder.setVisible(true);
		manifmetaholder.setVisible(true);
	}
}

class manifDClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		listDO(1);
	}
}

String deliveredDOCount(String idostomanf)
{
	if(idostomanf.equals("")) return "0";
	retv = "0";
	sqlstm = "select count(origid) as delcount from rw_deliveryorder where origid in (" + idostomanf + ") and complete_date is not null";
	kr = sqlhand.gpSqlFirstRow(sqlstm);
	if(kr != null) retv = kr.get("delcount").toString();
	//debugbox.setValue(debugbox.getValue() + "\n" + "D> " + sqlstm);
	return retv;
}

String getDOCount(String idostomanf)
{
	if(idostomanf.equals("")) return "0";
	retv = "0";
	try {
		mfs = idostomanf.split(",");
		retv = mfs.length.toString();
	} catch (Exception e) {}
	return retv;
}

void listManifest(int itype)
{
Object[] manif_hds =
{
	new listboxHeaderWidthObj("MFT",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Transporter",true,""),
	new listboxHeaderWidthObj("Stat",true,"60px"),
	new listboxHeaderWidthObj("D.Date",true,"60px"), // 5
	new listboxHeaderWidthObj("DO",true,"80px"),
	new listboxHeaderWidthObj("DO.Q",true,"40px"), // 7
	new listboxHeaderWidthObj("DLV",true,"30px"),
};

	last_list_manifest = itype;

	sdate = kiboo.getDateFromDatebox(mftstartdate);
	edate = kiboo.getDateFromDatebox(mftenddate);
	//scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(manifest_holder, manif_hds, "manifest_lb", 5);

	sqlstm = "select origid,datecreated,username,transporter,status,deliverdate from rw_dispatchmanif " +
	"where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	switch(itype)
	{
		case 2: // by delivered
			sqlstm += "and deliverdate is not null";
			break;

		case 3: // by incomplete
			sqlstm += "and deliverdate is null";
			break;

		case 4: // by transporter
			dsp = bydispatcher_lb.getSelectedItem().getLabel();
			sqlstm += "and transporter='" + dsp + "'";
			break;
	}

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setRows(15);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", new manifClick());

	for(d : recs)
	{
		mfid = d.get("origid").toString();
		ArrayList kabom = new ArrayList();
		kabom.add(mfid);
		kabom.add( dtf2.format(d.get("datecreated")) );
		kabom.add(kiboo.checkNullString(d.get("username")));
		kabom.add(kiboo.checkNullString(d.get("transporter")));
		kabom.add(kiboo.checkNullString(d.get("status")));
		kabom.add( (d.get("deliverdate") == null) ? "" : dtf2.format(d.get("deliverdate")) );
		dtmnf = getLinkingJobID_others(DO_MANIFESTID,mfid);
		kabom.add(dtmnf);

		kabom.add( getDOCount(dtmnf) );
		kabom.add( deliveredDOCount(dtmnf) );

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
	}
	dc_obj = new manifDClick();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

