import org.victor.*;
// GP funcs for contractBillingTrack.zul

// chk if asset already in LC - dups-check. Return LC-id
String assetExistInLC(String iastg)
{
	retv = "";
	sqlstm = "select lc_parent from rw_lc_equips where asset_tag='" + iastg + "' order by lc_parent desc";
	kr = sqlhand.gpSqlFirstRow(sqlstm);
	if(kr != null) retv = kr.get("lc_parent").toString();
	return retv;
}

// check asset-tag already link to LC
// retv: 0=not-found, 1=no LC-id linked, 2=already linked to LC
int assetLinkToLC(String iastg)
{
	retv = 0;
	sqlstm = "select lc_id from stockmasterdetails where stock_code='" + iastg + "'";
	kr = sqlhand.gpSqlFirstRow(sqlstm);
	if(kr == null) return retv;
	if(kr.get("lc_id") == null) retv = 1;
	else retv = 2;
	return retv;
}

// Get value from textbox/datebox as concatenated-string separated TODO other mods have similar func, make them use this
// icol=which column, isepa=separator
String concatRowsComp_str(int icol, String isepa, Object irows)
{
	cds = irows.getChildren().toArray();
	retv = "";

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();

		if(c1[icol] instanceof Textbox)
			retv += kiboo.replaceSingleQuotes( c1[icol].getValue().replaceAll(isepa," ") ) + isepa;

		if(c1[icol] instanceof Datebox)
			retv += kiboo.getDateFromDatebox( c1[icol] ) + isepa;
	}

	try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
	return retv;
}

// TODO some modules have similar func, make them use this general-purpose one
void makeLinkThingsGrid(Div iholder, String igrid, String irowsid, String[] icolws, String[] icolls, String istyle)
{
	if(iholder.getFellowIfAny(igrid) == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId(igrid);

		icols = new org.zkoss.zul.Columns();
		for(i=0;i<icolws.length;i++)
		{
			ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(icolws[i]);
			ico0.setLabel(icolls[i]);
			//if(i != 1 || i != 2) 
			ico0.setAlign("center");
			if(!istyle.equals("")) ico0.setStyle(istyle);
			ico0.setParent(icols);
		}
		icols.setParent(igrd);
		irows = new org.zkoss.zul.Rows();
		irows.setId(irowsid);
		irows.setParent(igrd);
		igrd.setParent(iholder);
	}
}

// TODO some modules have similar func, make them use this general-purpose one
void removeRowFromGrid(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		if(c1[0].isChecked()) cds[i].setParent(null);
	}
}

// Hide all and show only iwhat
void showHideFuncBar(Object iwhat)
{
	Div[] allfuncbars = { assets_func_bar };
	for(i=0; i<allfuncbars.length; i++)
	{
		allfuncbars[i].setVisible(false);
	}

	iwhat.setVisible(true);
}

void showLCMetadata(String iwhat)
{
	lcr = getLCNew_rec(iwhat);
	glob_lcmeta_rec = lcr; // later use
	if(lcr == null) { guihand.showMessageBox("DBERR: cannot access LC table"); return; }

	clearLCMetaFields();

	recnum_lbl.setValue("Record: " + iwhat);

	String[] flns = {
	"lc_id", "rocno", "rwno", "fc6_custid", "customer_name", "remarks", "order_type", "product_name",
	"fina_ref", "co_assigned_name", "co_do_ref", "co_master_lc", "co_inv_to_financer", "prev_lc", "prev_roc", "charge_out",
	"cust_project_id", "noa_no", "lstartdate", "lenddate", "charge_out_date", "period", "inst_type", "invoice_date", "batch_lc"
	};

	Object[] ibx = {
	i_lc_no, i_rocno, i_rwno, l_fc6_custid, customername, i_remarks, i_order_type, i_product_name,
	i_fina_ref, i_co_assigned_name, i_co_do_ref, i_co_master_lc, i_co_inv_to_financer, i_prev_lc, i_prev_roc, i_charge_out,
	i_cust_project_id, i_noa_no, i_lstartdate, i_lenddate, i_charge_out_date, i_period, i_inst_type, i_invoice_date, i_batch_lc
	};

	ngfun.populateUI_Data(ibx, flns, lcr);

	iass = (lcr.get("assigned") == null) ? "NO" : ( (lcr.get("assigned")) ? "YES" : "NO" );
	lbhand.matchListboxItems(i_assigned, iass );

	String[] fln2 = {
	"rm_month", "rm_contract", "qty_dt", "qty_mt", "qty_nb", "qty_pt", "qty_hs", "qty_ms",
	"charge_out_period", "co_instalment_count", "co_due_date",
	"fina_amount", "co_monthly_rental", "co_deposit", "co_recv_ex_deposit", "co_recv_in_deposit",
	"co_pv_drawdown", "co_pv_drawdown_ex_deposit", "co_assigned_interest","sales_related"
	};

	Object[] ibx2 = {
	i_rm_month, i_rm_contract, i_qty_dt, i_qty_mt, i_qty_nb, i_qty_pt, i_qty_hs, i_qty_ms,
	i_charge_out_period, i_co_instalment_count, i_co_due_date,
	i_fina_amount, i_co_monthly_rental, i_co_deposit, i_co_recv_ex_deposit, i_co_recv_in_deposit,
	i_co_pv_drawdown, i_co_pv_drawdown_ex_deposit, i_co_assigned_interest, i_sales_related
	};

	ngfun.populateUI_Data(ibx2, fln2, lcr);

	// remove previous DO/assets/RMA/etc boxes if any
	/*
	if(dorders_holder.getFellowIfAny("dorder_grid") != null) dorder_grid.setParent(null);
	if(rmas_holder.getFellowIfAny("rma_grid") != null) rmas_grid.setParent(null);

	makeLinkThingsGrid(rmas_holder,"rmas_grid","rma_rows",rma_colws,rma_colls,"background:#97b83a");
	showLC_RMA_recs(glob_selected_lc,rma_rows); // show RMA recs if any

	makeLinkThingsGrid(dorders_holder,"dorder_grid","dorder_rows",do_colws,do_colls,"background:#97b83a");
	showLC_DO_recs(glob_selected_lc,dorder_rows); // show DO recs if any
	*/

	showAssets(iwhat); // list assets link to this LC
	fillDocumentsList(documents_holder,LC_PREFIX,iwhat);

	global_selected_customerid = lcr.get("fc6_custid");

	// reset/hide some stuff when new LC selected - avoid brought-over from previous selection
	glob_selected_ass = glob_selected_asstag = "";
	glob_sel_assetrec = null;
	assbom_holder.setVisible(false);

	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb");
	jobnotes_div.setVisible(true);
	mainworkarea.setVisible(true);
}

Object[] lclb_hds =
{
	new listboxHeaderWidthObj("REC",true,"60px"),
	new listboxHeaderWidthObj("LC#",true,"50px"),
	new listboxHeaderWidthObj("RW#",true,"70px"),
	new listboxHeaderWidthObj("ROC#",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("A.Qty",true,"40px"), // 5
	new listboxHeaderWidthObj("GCO",true,"40px"),
	new listboxHeaderWidthObj("S.Date",true,"60px"),
	new listboxHeaderWidthObj("E.Date",true,"60px"),
	new listboxHeaderWidthObj("Period",true,"60px"),
	new listboxHeaderWidthObj("Instalm",true,"60px"),
	new listboxHeaderWidthObj("Status",true,"80px"), // 10
	new listboxHeaderWidthObj("User",true,"90px"),
	new listboxHeaderWidthObj("Ord.Type",true,""),
	new listboxHeaderWidthObj("ASGN",true,"40px"),
};

class lclbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_selected_lc_li = isel;
		glob_selected_lc = lbhand.getListcellItemLabel(isel,0);
		glob_sel_lc_str = lbhand.getListcellItemLabel(isel,1);
		glob_sel_customer = lbhand.getListcellItemLabel(isel,4);
		showLCMetadata(glob_selected_lc);
		/*
		showAssets(glob_selected_lc);
		lcworkarea.setVisible(true);
		lc_metagrid.setVisible(true);
		*/
	}
}
lclcblicker = new lclbClick();
glob_commasep = "";

void listROCLC(int itype)
{
	Listbox newlb = lbhand.makeVWListbox_Width(rocs_holder, lclb_hds, "lc_lb", 10);

	if(itype == 4) // save the quoted-comma-separated things
	{
		glob_commasep = search_txt.getValue().trim();
	}

	last_list_type = itype;
	sct = kiboo.replaceSingleQuotes(search_txt.getValue().trim());
	lcsdate = kiboo.getDateFromDatebox(lcend_startdate);
	lcedate = kiboo.getDateFromDatebox(lcend_enddate);

	sqlstm = "select top 600 lc.origid, lc.lc_id, lc.rocno, lc.customer_name,lc.period,lc.lstartdate,lc.lenddate,lc.lstatus, lc.super_reminder, lc.assigned, " +
	"(select count(origid) from rw_lc_equips where lc_parent=lc.origid) as aqty, lc.inst_type, lc.rwno, " +
	"(select count(lce1.gcn_id) from rw_lc_equips lce1 " +
	"where lce1.lc_parent=lc.origid and (lce1.gcn_id is not null or lce1.gcn_id<>0)) as gcocount," +
	"lc.order_type, lc.username from rw_lc_records lc ";

	switch(itype)
	{
		case 1 : // find LC by customer-name
			if(sct.equals("")) return;
			sqlstm += "where (lc.customer_name like '%" + sct + "%' or " +
			"lc.order_type like '%" + sct + "%' or lc.remarks like '%" + sct + "%' or " +
			"lc.rwno like '%" + sct + "%' or lc.lc_id like '%" + sct + "%' or lc.prev_lc like '%" + sct + "%') " +
			"order by lc.rwno";
			glob_commasep = "";
			break;

		case 2 : // by LC end date
			sqlstm += "where lc.lenddate between '" + sdate + "' and '" + edate + "' " +
			"and (lc.lstatus='active' or lstatus is null) " +
			"order by lc.rwno";
			glob_commasep = "";
			break;

		case 3 : // load latest entered
			sqlstm = "select top 15 lc.origid, lc.lc_id, lc.rocno, lc.customer_name,lc.period,lc.lstartdate,lc.lenddate,lc.lstatus, lc.super_reminder, lc.assigned," +
			"(select count(origid) from rw_lc_equips where lc_parent=lc.origid) as aqty, lc.inst_type, lc.rwno, " +
			"(select count(lce1.gcn_id) from rw_lc_equips lce1 " +
			"where lce1.lc_parent=lc.origid and (lce1.gcn_id is not null or lce1.gcn_id<>0)) as gcocount," +
			"lc.order_type, lc.username from rw_lc_records lc " +
			"order by lc.origid desc";
			glob_commasep = "";
			break;

		case 4: // list by what're found, uses sct
			search_txt.setValue("");
			sqlstm += "where lc.lc_id in (" + glob_commasep + ");";
			break;

		case 5: // list by LC end-date range
			sqlstm += "where lc.lenddate between '" + lcsdate + " 00:00:00' and '" + lcedate + " 23:59:00' " +
			"and lc.lstatus in ('extension','active','refresh') order by lc.customer_name, lc.lenddate";
			break;
	}
	
	lcrecs = sqlhand.gpSqlGetRows(sqlstm);
	if(lcrecs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.addEventListener("onSelect", lclcblicker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "lc_id", "rwno", "rocno", "customer_name", "aqty", "gcocount", "lstartdate", "lenddate", "period",
	"inst_type", "lstatus", "username", "order_type", "assigned" };
	for(dpi : lcrecs)
	{
		ngfun.popuListitems_Data(kabom,fl,dpi);
		sty = "";
		if(dpi.get("super_reminder")) sty = "background:#EBF531;font-weight:bold;font-size:9px";
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
		kabom.clear();
	}
}

// Clear the main LC metaform fields
void clearLCMetaFields()
{
	Object[] flds = {
	i_lc_no, i_rwno, i_rocno, i_prev_lc, i_prev_roc, l_fc6_custid,
	customername, i_lstartdate, i_lenddate, i_period, i_rm_month, i_rm_contract, i_inst_type,
	i_qty_dt, i_qty_mt, i_qty_nb, i_qty_pt, i_qty_hs, i_qty_ms,
	i_product_name, i_order_type, i_remarks, i_assigned, i_charge_out_date, i_charge_out_period,
	i_charge_out, i_fina_ref, i_fina_amount, i_co_assigned_name, i_co_do_ref, i_co_master_lc,
	i_co_monthly_rental, i_co_instalment_count, i_co_due_date, i_co_deposit, i_co_recv_ex_deposit, i_co_recv_in_deposit,
	i_co_pv_drawdown, i_co_pv_drawdown_ex_deposit, i_co_assigned_interest, i_co_inv_to_financer, i_cust_project_id, i_batch_lc,
	i_sales_related
	};

	ngfun.clearUI_Field(flds);
}

void exportAssetsList(String iwhat, int itype)
{
	if(iwhat.equals("")) return;
	if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("expassframe"); newiframe.setWidth("100%"); newiframe.setHeight("600px");
	cnm = glob_sel_customer.replaceAll(" ","%20");
	ort = i_order_type.getValue().trim().replaceAll(" ","%20");

	bfn = "rwreports/lc_assetslist_v1.rptdesign";

	switch(itype)
	{
		case 2:
		bfn = "rwreports/lc_assetslist_amt_v1.rptdesign";
		break;
		case 3: // evf w/o specs but with location
		bfn = "rwreports/lc_assetslist_v2.rptdesign";
		break;
		case 4:
		bfn = "rwreports/lc_assetslist_amt_v2.rptdesign";
		break;
		case 5: // evf with specs
		bfn = "rwreports/lc_assetslist_v3.rptdesign";
		break;
		case 6: // multi-LC EVF with grouping (mainly for MISC or other big customers)
		udi = userdef_inv.getValue().trim().replaceAll(" ","%20");
		bfn = "rwreports/multilcgroupy_1.rptdesign&userdef_inv=" + udi;
		break;
	}

	thesrc = birtURL() + bfn + "&lcid=" + iwhat + 
	"&customername=" + cnm + "&ordertype=" + ort + "&rwno=" + glob_sel_lc_str;
	newiframe.setSrc(thesrc);
	newiframe.setParent(expass_div);
	expasspop.open(newasset_b);
}

// 28/10/2014: list dups LC records
void listDupLC_records(Div iwinholder)
{
Object[] dlrhds =
{
	new listboxHeaderWidthObj("LC",true,"50px"),
	//new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Dups",true,"40px"),
};

	mwin = vMakeWindow(iwinholder,"Duplicate LC records","0","center","500px","");
	kdiv = new Div();
	kdiv.setParent(mwin);

	Listbox newlb = lbhand.makeVWListbox_Width(kdiv, dlrhds, "dplc_lb", 3);

	sqlstm = "select distinct lc_id, count(lc_id) as dupscount from rw_lc_records " +
	"group by lc_id having count(lc_id) > 1 order by lc_id;";

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); newlb.setRows(21);
	ArrayList kabom = new ArrayList();
	String[] fl = { "lc_id", "dupscount" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// 14/05/2015: copy LC metadata/assets - req by shopa
// call from copyFromOtherLC_meta_pop
void copyLCmetadata()
{
	frmlc = kiboo.replaceSingleQuotes(whichlcid.getValue().trim());
	if(frmlc.equals("")) return;
	try { kk = Integer.parseInt(frmlc); } catch (Exception e) { guihand.showMessageBox("ERR: need LC/RWI number.."); return; }

	sqlstm = "if exists(select origid from rw_lc_records where lc_id='" + frmlc + "') " +
	"insert into rw_lc_records (datecreated,username,lc_id,rocno,fc6_custid, " +
	"customer_name,rwno,invoice_date,period,lstartdate,lenddate,lstatus, " +
	"contract_filed,remarks,qty_dt,qty_mt,qty_nb,qty_pt,qty_ms,rm_month,rm_contract,inst_type,prev_roc,prev_lc,order_type) " +
	"select getdate(),'" + useraccessobj.username + "',lc_id,rocno,fc6_custid, " +
	"customer_name,rwno,invoice_date,period,lstartdate,lenddate,lstatus, " +
	"contract_filed,remarks,qty_dt,qty_mt,qty_nb,qty_pt,qty_ms,rm_month,rm_contract,inst_type,prev_roc,prev_lc,order_type " +
	"from rw_lc_records where lc_id='" + frmlc + "';";

	sqlhand.gpSqlExecuter(sqlstm);
	listROCLC(3); // load some latest recs to show what's copied..
}

