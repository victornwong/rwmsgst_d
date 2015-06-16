import org.victor.*;
// Rentwise Jobmaker module funcs

glob_icomponents_counter = 1; // use globally to set items components ID

void toggleButts(String itype, boolean iwhat)
{
	if(itype.equals("submitjob_b") || itype.equals("all"))
	{
		submitjob_b.setDisabled(iwhat);
	}

	if(itype.equals("pickjob_b") || itype.equals("all"))
	{
		pickjob_b.setDisabled(iwhat);
	}

	if(itype.equals("workarea_butts") || itype.equals("all"))
	{
		Object[] ob = { ji_insert_b, ji_remove_b, ji_calc_b, ji_save_b, asscust_b,
			updatejob_b, improc_b, impso_b, impquote_b, impcsv_b };
		for(i=0; i<ob.length; i++)
		{
			ob[i].setDisabled(iwhat);
		}
	}
}

void showRentableItems(Div iholder, String lbid, String istockcat, String ipname)
{
Object[] stklist_headers = {
	new listboxHeaderWidthObj("Models",true,""),
	new listboxHeaderWidthObj("Avail",true,"60px"), };
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, stklist_headers, lbid, 3);

	whrstr = "item='DT' or item='DR'";
	if(istockcat.equals("NB") || istockcat.equals("MT")) whrstr = "item='" +  istockcat + "'";
	if(istockcat.equals("") && !ipname.equals("")) whrstr = "name like '%" + ipname + "%'";

	sqlstm = "select distinct name, sum(qty) as unitc from partsall_0 " +
	"where " + whrstr + " group by name,qty order by name;";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(10); newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new jobsClick());
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add( kiboo.checkNullString(d.get("name")) );
		kabom.add( nf0.format(d.get("unitc")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"true","");
		kabom.clear();
	}
}

// might be usable for other mods -- show in-stock DT and NB models
void showRentableItems2(Div iholder, String lbid, String istockcat)
{
Object[] stklist_headers =
{
	new listboxHeaderWidthObj("Models",true,""),
	new listboxHeaderWidthObj("Avail",true,"60px"),
};
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, stklist_headers, lbid, 3);

	sqlstm = "select distinct smd.brandname, smd.description, " +
	"(select count(id) from stockmasterdetails where " +
	"description = smd.description and bom_id is null and rma_id is null) as unitc " +
	"from stockmasterdetails smd " +
	"where smd.stock_cat='" + istockcat + "' and smd.brandname is not null";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(10); newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new jobsClick());
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add( kiboo.checkNullString(dpi.get("brandname")) + ": " + kiboo.checkNullString(dpi.get("description")) );
		kabom.add( dpi.get("unitc").toString() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"true","");
		kabom.clear();
	}
}

void showJobMetadata(String iwhat)
{
	j_origid.setValue(iwhat);
	jrec = getRWJob_rec(iwhat);
	if(jrec == null) { guihand.showMessageBox("ERR: Cannot access jobs database.."); return; }

	String[] flds = { "username", "customer_name", "jobtype", "quote_no_old", "rwroc", "cust_ref", "prepayment",
	"contract_start", "priority", "contact", "contact_tel", "contact_email", "deliver_address",
	"do_notes", "order_type", "debit_note", "whoscode", "eta", "etd" };

	Object[] uiob = { j_username, customername, j_jobtype, j_quote_no_old, j_rwroc, j_cust_ref, j_prepayment,
	j_contract_start, j_priority, j_contact, j_contact_tel, j_contact_email, j_deliver_address,
	j_do_notes, j_order_type, j_debit_note, j_whoscode, j_eta, j_etd };

	ngfun.populateUI_Data(uiob, flds, jrec);

	fc6n = (jrec.get("fc6_custid") == null) ? "" : jrec.get("fc6_custid").toString();
	j_fc6_custid.setValue(fc6n); // hidden fc6 cust-id

	showJobItems(jrec);
	fillDocumentsList(documents_holder,JOBS_PREFIX,iwhat);

	showApprovalThing(JN_linkcode(), jrec.get("jobtype"), approvers_box );

	// Update bpm-approval things
	appf = checkBPM_fullapproval(JOBS_PREFIX + iwhat);
	sqlstm = "update rw_jobs set approve=" + ( (appf) ? "1" : "0" ) + " where origid=" + iwhat;
	sqlhand.gpSqlExecuter(sqlstm);
	/*
	if(glob_sel_joblistitem != null) // update list-item
	{
		lbhand.setListcellItemLabel(glob_sel_joblistitem,10,(appf) ? "YES" : "NO"); // HARDCODED colm posi = 9
	}
	*/

	BPM_toggleButts( (glob_sel_status.equals("SUBMIT")) ? false : true, approvers_box);

	if( sechand.allowedUser(useraccessobj.username,"CC_APPROVER_USER") || sechand.allowedUser(useraccessobj.username,"SALES_APPROVER_USER") )
		BPM_toggleButts( (glob_sel_status.equals("SUBMIT")) ? false : true, approvers_box);

/* hide it 24/06/2014
	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	jobnotes_div.setVisible(true);
*/
	workarea.setVisible(true);
}

Object[] jbshds =
{
	new listboxHeaderWidthObj("fc6",false,""),
	new listboxHeaderWidthObj("ROC.No",true,"60px"),
	new listboxHeaderWidthObj("BOM",true,"40px"), // 2
	new listboxHeaderWidthObj("BOM DO",true,"60px"),
	new listboxHeaderWidthObj("P.By",true,"60px"), // 4
	new listboxHeaderWidthObj("P.Date",true,"60px"),
	new listboxHeaderWidthObj("P.Lst",true,"60px"), // 6
	new listboxHeaderWidthObj("PPL DO",true,"60px"),
	new listboxHeaderWidthObj("C.By",true,"60px"), // 8
	new listboxHeaderWidthObj("C.Date",true,"60px"),
//	new listboxHeaderWidthObj("PR",true,"60px"), // 11
//	new listboxHeaderWidthObj("GRN",true,"60px"),
};

x_fc6 = 0;
x_pck = 4;
x_cby = 8;
x_bom = 2;
x_pls = 6;

x_rocno = 4;
x_ordc = 5;
x_stat = 10;
x_prn = 12;
x_grn = 13;
x_mrn = 14;

previous_sel_jbrow = null;

class jbrowclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selrow = event.getTarget();
		if(previous_sel_jbrow != null)
		{
			if(selrow != previous_sel_jbrow)
			{
				previous_sel_jbrow.setStyle("background:#ffffff");
				xk = previous_sel_jbrow.getChildren().get(0);
				xk.setOpen( (xk.isOpen()) ? false : true);
			}
		}
		ks = selrow.getChildren().toArray();
		glob_sel_job = ks[1].getValue();
		selrow.setStyle("background:#909d2a");

		selrow.getChildren().get(0).setOpen(true);
		previous_sel_jbrow = selrow;

		itm = ks[0].getChildren().get(0).getChildren().get(0).getChildren().get(1); // HARDCODED!!!

		glob_sel_fc6 = lbhand.getListcellItemLabel(itm,x_fc6);
		glob_sel_pickup = lbhand.getListcellItemLabel(itm,x_pck);
		glob_sel_complete = lbhand.getListcellItemLabel(itm,x_cby);
		glob_sel_bomid = lbhand.getListcellItemLabel(itm,x_bom);
		glob_sel_picklist = lbhand.getListcellItemLabel(itm,x_pls);

		glob_sel_jobtype = ks[x_ordc].getValue();
		glob_sel_rocno = ks[x_rocno].getValue();
		glob_sel_prn = ks[x_prn].getValue();
		glob_sel_grn = ks[x_grn].getValue();
		glob_sel_mrn = ks[x_mrn].getValue();
		glob_sel_status = ks[x_stat].getValue(); // status from grid->row

		toggleButts("all", (glob_sel_status.equals("NEW")) ? false : true );
		if(glob_sel_status.equals("SUBMIT")) toggleButts("pickjob_b",false);

		showJobMetadata(glob_sel_job);
	}
}
jbrowcliker = new jbrowclik();

// 19/03/2014: ljob_myname use to list user's jobs - by date
void showJobs()
{
	previous_sel_jbrow = null;
	if(jobs_holder.getFellowIfAny("jobs_grid") != null) jobs_grid.setParent(null);
	mgrid = new Grid();
	mgrid.setMold("paging");
	mgrid.setId("jobs_grid");
	mgrid.setParent(jobs_holder);
	mrows = new Rows();
	mrows.setParent(mgrid);

	String[] mcols = { "", "Job", "Date", "Customer", "ROC", "O.Cat", "O.Type", "ETA", "ETD", "User", "Stat", "Appr", "PO", "GRN","MRN" };
	String[] mwdth = { "40px", "60px", "80px", "", "", "", "", "80px", "80px", "", "", "", "60px", "60px","60px" };

	gpmakeGridHeaderColumns_Width(mcols,mwdth,mgrid);

	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	jid = kiboo.replaceSingleQuotes(jobid_tb.getValue().trim());

	sqlstm = 
	"select jbs.origid, jbs.datecreated, jbs.username, jbs.jobtype, jbs.fc6_custid, jbs.customer_name, jbs.status," +
	"jbs.approve, jbs.pickup_by, jbs.pickup_date, jbs.complete_date, jbs.complete_by, jbs.eta, jbs.etd, jbs.whoscode, " +
	"jbs.rwroc, jbs.order_type from rw_jobs jbs ";

	chkdt = " jbs.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
	whtst = "where " + chkdt;
	if(!scht.equals(""))
	{
		whtst = "where (jbs.customer_name like '%" + scht + "%' or jbs.rwroc like '%" + scht + "%') ";
		searhtxt_tb.setValue("");
	}
	if(!jid.equals(""))
	{
		try
		{
			kk = Integer.parseInt(jid);
			whtst = "where jbs.origid=" + jid;
			jobid_tb.setValue("");
		} catch (Exception e)
		{
			return;
		}
	}
	if(!ljob_myname.equals("")) // list ONLY user job
	{
		whtst = "where jbs.username='" + ljob_myname + "' and " + chkdt;
		ljob_myname = "";
	}
	if(ljob_reqnewpurchase) // list only job req new-purchases
	{
		whtst = "where jbs.order_type='NEW' and " + chkdt;
		ljob_reqnewpurchase = false;
	}
	if(ljob_rmaonly) // list RMA jobs only
	{
		whtst = "where jbs.jobtype='RMA' and " + chkdt;
		ljob_rmaonly = false;
	}

	sqlstm += whtst + " order by jbs.origid ";
	//guihand.showMessageBox(sqlstm); return;
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	lbc = 0;
	ArrayList kabom = new ArrayList();
	k9 = "font-size:9px";
	k9h = "font-size:9px;color:#06333a;font-weight:bold";

	for(d : r)
	{
		jbid = d.get("origid").toString();

		krow = new Row(); krow.setParent(mrows);
		krow.addEventListener("onClick", jbrowcliker);
		kdetail = new Detail(); kdetail.setParent(krow);
		kdiv = new Div(); kdiv.setParent(kdetail);
		Listbox newlb = lbhand.makeVWListbox_Width(kdiv, jbshds, "jlb"+lbc.toString(), 2);
		lbc++;

		// fill-up detail listbox 1
		kabom.add( (d.get("fc6_custid") == null) ? "" : d.get("fc6_custid").toString() );
		kabom.add(kiboo.checkNullString(d.get("rwroc")));

		tboms = getLinkingJobID_others(BOM_JOBID,jbid).trim();
		kabom.add(tboms);
		kabom.add( getDOLinkToJob(2,tboms) );
		kabom.add(kiboo.checkNullString(d.get("pickup_by")));
		kabom.add( kiboo.checkNullDate(d.get("pickup_date"),"") );
		tppls = getLinkingJobID_others(PICKLIST_JOBID,jbid).trim();
		kabom.add(tppls);
		kabom.add( getDOLinkToJob(1,tppls) );
		kabom.add(kiboo.checkNullString(d.get("complete_by")));
		kabom.add( (d.get("complete_date") == null) ? "" : dtf.format(d.get("complete_date")) );

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();

		gpMakeLabel(krow,"", d.get("origid").toString() ,"");
		gpMakeLabel(krow,"", dtf2.format(d.get("datecreated")) , k9);
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("customer_name")) ,"font-weight:bold");
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("rwroc")) ,"font-weight:bold");
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("jobtype")), k9);
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("order_type")), k9);
		gpMakeLabel(krow,"", dtf2.format(d.get("eta")) , k9);
		gpMakeLabel(krow,"", dtf2.format(d.get("etd")) , k9);
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("username")) , k9);
		gpMakeLabel(krow,"", kiboo.checkNullString(d.get("status")) , k9);

		apr = (d.get("approve") == null) ? "NO" : ( (d.get("approve")) ? "YES" : "NO" ) ;
		gpMakeLabel(krow,"", apr , k9);

		ipr = getDOLinkToJob(3,jbid);
		gpMakeLabel(krow,"", ipr , k9h);
		tgrns = getDOLinkToJob(4,ipr);
		gpMakeLabel(krow,"", tgrns, k9h);

		tmrns = grnToMRN_str(tgrns.trim()); // 17/04/2014: req by Lai, see MRNs tied to GRNs
		gpMakeLabel(krow,"", tmrns, k9h);
	}
}

void checkMakeItemsGrid()
{
	String[] colws = { "50px","350px",           "60px" ,"60px","60px",    "60px",     "80px",   "80px" };
	String[] colls = { "No." ,"Item description","Color","Qty" ,"R.Period","R.PerUnit","ROC Monthly","Sub.Total" };

	if(items_holder.getFellowIfAny("items_grid") == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId("items_grid");
		igrd.setWidth("850px");

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
		irows.setId("items_rows");
		irows.setParent(igrd);
		igrd.setParent(items_holder);
	}
}

void showJobItems(Object tjrc)
{
	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	saved_label.setVisible(false);
	grandtotalbox.setVisible(false);
	
	glob_icomponents_counter = 1; // reset for new grid

	if(tjrc.get("items") == null) return; // nothing to show

	checkMakeItemsGrid();
	items = sqlhand.clobToString(tjrc.get("items")).split("::");
	qtys = tjrc.get("qtys").split("::");
	colors = tjrc.get("colors").split("::");
	rental_periods = tjrc.get("rental_periods").split("::");
	rent_perunits = tjrc.get("rent_perunits").split("::");
	
	kk = "font-weight:bold;";

	for(i=0;i<items.length;i++)
	{
		cmid = glob_icomponents_counter.toString();

		irow = gridhand.gridMakeRow("IRW" + cmid ,"","",items_rows);
		gpMakeCheckbox(irow,"CBX" + cmid, cmid + ".", kk + "font-size:14px");

		soms = "";
		try { soms = items[i]; } catch (Exception e) {}

		desb = gpMakeTextbox(irow,"IDE" + glob_icomponents_counter.toString(),soms,"font-size:9px;font-weight:bold;","99%");
		desb.setMultiline(true);
		desb.setHeight("70px");
		//desb.setDroppable("mydrop");
		desb.addEventListener("onDrop",dropMname);

		soms = "";
		try { soms = colors[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"ICL" + cmid ,soms, kk,"99%"); // color

		soms = "";
		try { soms = qtys[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IQT" + cmid,soms,kk,"99%"); // qty

		soms = "";
		try { soms = rental_periods[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IRP" + cmid,soms,kk,"99%"); // rental-period

		soms = "";
		try { soms = rent_perunits[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IRU" + cmid,soms,kk,"99%"); // rental per unit

		gpMakeLabel(irow,"MON" + cmid,"",kk); // per month total
		gpMakeLabel(irow,"RTO" + cmid,"",kk); // rental all total

		glob_icomponents_counter++;
	}

	jobItems(ji_calc_b); // Do items total/rental calcs
}

class dropModelName implements org.zkoss.zk.ui.event.EventListener // drag-drop mode-name into item-description
{
	public void onEvent(Event event) throws UiException
	{
		Component dragged = event.dragged;
		kk = event.getTarget();
		kk.setValue(dragged.getLabel());
	}
}
dropMname = new dropModelName();

// TODO knockoff from grnPO_tracker_v1.zul -- need to make this global
void showGRNitems(String iwhat, String ivtype, Div idiv)
{
Object[] grnihds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Product",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
};
	lid = kiboo.makeRandomId("gnr");
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, grnihds, lid, 20);

	sqlstm = "select i.name as productname, iy.qty2 from data d " +
	"left join mr001 i on i.masterid = d.productcode " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"where d.vouchertype=" + ivtype + " and d.productcode<>0 " +
	"and d.voucherno='" + iwhat + "'";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	/*
	rsz = (r.size() < 20) ? r.size()+1 : 20;
	newlb.setRows(rsz);
	newlb.addEventListener("onSelect", grnclikor);
	*/
	lnc = 1;
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add(lnc.toString() + "." );
		kabom.add( kiboo.checkNullString(d.get("productname")) ); 
		kabom.add( GlobalDefs.nf0.format(d.get("qty2")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}

void showPOitems(String iwhat, Div idiv)
{
	prc = getPR_rec(iwhat);
	if(prc == null) { guihand.showMessageBox("ERR: cannot find PO"); return; }

	dgrid = new Grid();	dgrid.setParent(idiv);
	drows = new Rows();	drows.setParent(dgrid);

	// Show PO details
	drow = new Row();
	drow.setParent(drows);
	gpMakeLabel(drow,"", "Dated","");
	gpMakeLabel(drow,"", dtf2.format(prc.get("datecreated")),"");
	gpMakeLabel(drow,"", "Owner","");
	gpMakeLabel(drow,"", prc.get("username"),"");

	drow = new Row();
	drow.setSpans("1,3");
	drow.setParent(drows);
	gpMakeLabel(drow,"", "Vendor","");
	gpMakeLabel(drow,"", prc.get("supplier_name"),"");

	String[] colws = { "30px","","40px","" };
	String[] colls = { "No." ,"Item description","Qty", "UPrice" };

	mgrid = new Grid(); mgrid.setParent(idiv);
	gpmakeGridHeaderColumns_Width(colls,colws,mgrid);
	mrows = new Rows(); mrows.setParent(mgrid);

	//alert(sqlhand.clobToString(prc.get("pr_items")));

	ktg = sqlhand.clobToString(prc.get("pr_items"));
	if(!ktg.equals(""))
	{
		itms = sqlhand.clobToString(prc.get("pr_items")).split("~");
		iqty = sqlhand.clobToString(prc.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(prc.get("pr_unitprice")).split("~");
		ks = "font-size:9px;";

		for(i=0; i<itms.length; i++)
		{
			irow = new org.zkoss.zul.Row();
			gpMakeLabel(irow,"", (i+1).toString() + ".","");
			itm = "";
			try { itm = itms[i]; } catch (Exception e) {}
			gpMakeLabel(irow,"",itm,ks);

			qty = "";
			try { qty = iqty[i]; } catch (Exception e) {}
			gpMakeLabel(irow,"",qty,ks);

			prc = "";
			try { prc = iupr[i]; } catch (Exception e) {}
			gpMakeLabel(irow,"",prc,ks);

			irow.setParent(mrows);
		}
	}
}

