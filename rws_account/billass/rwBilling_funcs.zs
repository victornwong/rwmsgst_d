import org.victor.*;
// billing funcs

void getFC_RWI(String iwhat)
{
	if(glob_sel_lcid.equals("")) return;

String[] fl = { "voucherno", "vdate", "customer_name", "dorefyh", "rocnoyh", "opsnoteyh", "ordertypeyh", "deliverytoyh",
"insttypeyh", "noofinstallmentyh", "projectsiteyh", "bookno" };

	iwhat = "RW" + kiboo.replaceSingleQuotes(iwhat);

	sqlstm = "select d.voucherno, convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, d.bookno, ac.name as customer_name, " +
	"li.dorefyh, li.rocnoyh, li.opsnoteyh, li.ordertypeyh, li.deliverytoyh, upper(li.insttypeyh), li.noofinstallmentyh, li.projectsiteyh " +
	"from data d " +
	"left join mr000 ac on ac.masterid = d.bookno " +
	"left join u001b li on li.extraid = d.extraheaderoff where " +
	"d.vouchertype=3329 and d.voucherno='" + iwhat + "';";

	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null) { guihand.showMessageBox("ERR: cannot get FC6 RWI data.."); return; }

	ngfun.populateUI_Data(ob,fl,r);
	impdiv.setVisible(true);
}

void updLCRemarks(String irem)
{
	rmk = kiboo.replaceSingleQuotes(irem);
	if(rmk.equals("")) return;
	if(glob_selected_lc.equals("")) return;
	sqlstm = "update rw_lc_records set remarks='" + rmk + "' where origid=" + glob_selected_lc;
	sqlhand.gpSqlExecuter(sqlstm);
	glob_sel_item.toArray()[LC_REMARKS_POS].setLabel(rmk);
	add_RWAuditLog(JN_linkcode(), "", "Update LC remarks", useraccessobj.username);
}

void updLC_stat(Object iwhat)
{
	lcsetstat_pop.close();
	itype = iwhat.getId();
	if(itype.equals("stactive_b") || itype.equals("sttermin_b") || itype.equals("stextens_b") ||
	itype.equals("stinerti_b") || itype.equals("stbuyout_b") || itype.equals("stinactive_b") || itype.equals("stpartial_b") ||
	itype.equals("partret_b") || itype.equals("creditn_b") )
	{
		if(glob_selected_lc.equals("")) return;
		sqlstm = "update rw_lc_records set lstatus='" + iwhat.getLabel() + "' where origid=" + glob_selected_lc;
		sqlhand.gpSqlExecuter(sqlstm);
		glob_sel_item.toArray()[LC_STAT_POS].setLabel( iwhat.getLabel() );
		add_RWAuditLog(JN_linkcode(), "", "Update LC status", useraccessobj.username);
	}
}

void togRentInstPrintout()
{
	if(glob_selected_lc.equals("")) return;
	sqlstm = "update rw_lc_records set manual_inv=1-manual_inv where origid=" + glob_selected_lc;
	sqlhand.gpSqlExecuter(sqlstm);
}

void showLC_audit()
{
	if(glob_selected_lc.equals("")) return;
	showSystemAudit(auditlogs_holder,JN_linkcode(),"");
	auditlogs_pop.open(glob_sel_item.get(0));
}

void drillLC_things(String iwhat)
{
Object[] asslb_hds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("GCO",true,"50px"),
	new listboxHeaderWidthObj("ASGN",true,"40px"),
	new listboxHeaderWidthObj("origid",false,""),
};
	lcr = getLCNew_rec(iwhat);
	if(lcr == null) return;

	kwin = vMakeWindow(windsholder, "LC " + lcr.get("lc_id"), "normal", "center", "580px", "");
	mdv = new Div();
	mdv.setParent(kwin);

String[] flns = {
	"lc_id", "rocno", "rwno", "fc6_custid", "customer_name", "remarks", "order_type", "product_name",
	"fina_ref", "co_assigned_name", "co_do_ref", "co_master_lc", "co_inv_to_financer", "prev_lc", "prev_roc", "charge_out",
	"cust_project_id", "noa_no", "lstartdate", "lenddate", "charge_out_date", "period", "inst_type", "invoice_date"
	};	

	mgd = new Grid();
	mgd.setParent(mdv);
	fs9 = "font-size:9px";

	mrs = gridhand.gridMakeRows("","",mgd);
	kr = gridhand.gridMakeRow("","","",mrs);
	gpMakeLabel(kr,"", "ROC",fs9);
	gpMakeLabel(kr,"", lcr.get("rocno"),fs9);
	gpMakeLabel(kr,"", "User",fs9);
	gpMakeLabel(kr,"", lcr.get("username"),fs9);

	kr = gridhand.gridMakeRow("","","",mrs);
	gpMakeLabel(kr,"", "C.Start",fs9);
	gpMakeLabel(kr,"", dtf2.format(lcr.get("lstartdate")),fs9);
	gpMakeLabel(kr,"", "C.End",fs9);
	gpMakeLabel(kr,"", dtf2.format(lcr.get("lenddate")),fs9);

	kr = gridhand.gridMakeRow("","","",mrs);
	kr.setSpans("1,3");
	gpMakeLabel(kr,"", "Order.Type",fs9);
	gpMakeLabel(kr,"", lcr.get("order_type"),fs9);

	kr = gridhand.gridMakeRow("","","",mrs);
	kr.setSpans("1,3");
	gpMakeLabel(kr,"", "Product.Name",fs9);
	gpMakeLabel(kr,"", lcr.get("product_name"),fs9);

	kr = gridhand.gridMakeRow("","","",mrs);
	kr.setSpans("1,3");
	gpMakeLabel(kr,"", "Remarks",fs9);
	gpMakeLabel(kr,"", lcr.get("remarks"),fs9);

	lid = kiboo.makeRandomId("yy");
	Listbox newlb = lbhand.makeVWListbox_Width(mdv, asslb_hds, lid, 20);
	sqlstm = "select origid,asset_tag,brand,model,type,serial_no,gcn_id,assigned from rw_lc_equips " +
	"where lc_parent=" + iwhat + " order by asset_tag";

	asrs = sqlhand.gpSqlGetRows(sqlstm);
	if(asrs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.setMultiple(true); newlb.setCheckmark(true); newlb.addEventListener("onSelect", assclicko);
	ArrayList kabom = new ArrayList();
	String[] fl = { "asset_tag", "serial_no", "brand", "model", "type", "gcn_id", "assigned", "origid" };
	ks = "font-size:9px";
	for(d : asrs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);

		if(d.get("gcn_id") != null)
			if(!d.get("gcn_id").equals("0"))
				ks="background:#f77272;font-size:9px";

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",ks);
		kabom.clear();
	}
}

class titclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		glob_sel_item = event.getTarget().getChildren();
		glob_selected_lc = glob_sel_item.get(LC_ORIGI_POS).getLabel();
		glob_sel_lcid = glob_sel_item.get(0).getLabel();

		global_selected_customername = glob_sel_item.get(LC_CUSTOMERNAME_POS).getLabel();
		glob_ordertype = glob_sel_item.get(LC_ORDERTYPE_POS).getLabel();
	}
}

class tidclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		glob_sel_item = event.getTarget().getChildren();
		glob_selected_lc = glob_sel_item.get(LC_ORIGI_POS).getLabel();
		glob_sel_lcid = glob_sel_item.get(0).getLabel();

		global_selected_customername = glob_sel_item.get(LC_CUSTOMERNAME_POS).getLabel();
		glob_ordertype = glob_sel_item.get(LC_ORDERTYPE_POS).getLabel();

		drillLC_things(glob_selected_lc);
	}
}
tidcliker = new tidclik();
titicliker = new titclik();

LC_CUSTOMERNAME_POS = 1;
LC_ORDERTYPE_POS = 6;
LC_STAT_POS = 8;
LC_REMARKS_POS = 9;
LC_ASSIGN_POS = 10;
LC_ORIGI_POS = 11; // mcells[] index created below

// GUI part of the recursive func
Treeitem showLCtreeDetails(Object ichd, Object d)
{
	kk = "font-size:9px;font-weight:bold";
	Treeitem titem = new Treeitem();
	Treerow newrow = new Treerow();
	Treecell[] mcells = new Treecell[] { new Treecell(), new Treecell(), new Treecell(), new Treecell(), new Treecell(),
	new Treecell(), new Treecell(), new Treecell(), new Treecell(), new Treecell(), new Treecell(), new Treecell() };
	for(i=0; i<mcells.length; i++)
	{
		mcells[i].setParent(newrow);
		mcells[i].setStyle("font-size:9px");
	}
	idt = d.get("bmonth");

	mcells[0].setLabel( kiboo.checkNullString(d.get("lc_id")) );
	mcells[0].setStyle(kk);
	mcells[1].setLabel( kiboo.checkNullString(d.get("customer_name")) );
	mcells[1].setStyle(kk);

	invd = (d.get("invoice_date") == null) ? "" : GlobalDefs.dtf2.format(d.get("invoice_date"));

	mcells[2].setLabel( invd );
	mcells[3].setLabel( (d.get("lstartdate") == null) ? "" : GlobalDefs.dtf2.format(d.get("lstartdate")) );
	mcells[4].setLabel( (d.get("lenddate") == null) ? "" : GlobalDefs.dtf2.format(d.get("lenddate")) );
	mcells[5].setLabel( (idt < 0) ? "0" : idt.toString() );

	mcells[6].setLabel( d.get("order_type") );
	mcells[6].setStyle("font-size:7px");
	mcells[7].setLabel( d.get("aqty").toString() );

	lst = kiboo.checkNullString(d.get("lstatus")).toUpperCase();
/*
	if(lst.equals("EXTENSION"))
	{
		newrow.setStyle("background:#f10c4f");
	}
*/
	mcells[LC_STAT_POS].setLabel(lst);

	mcells[LC_REMARKS_POS].setLabel( kiboo.checkNullString(d.get("remarks")) ); // 03/06/2014: add-back for waygu to keep track on things.. haha
	mcells[LC_REMARKS_POS].setStyle("font-size:7px");

	mcells[LC_ASSIGN_POS].setLabel( (d.get("assigned") == null) ? "" : (!(d.get("assigned")) ? "" : "YES") );
	mcells[LC_ASSIGN_POS].setStyle( (d.get("assigned") == null) ? "" : (!(d.get("assigned")) ? "" : "background:#00ee11;font-size:9px") );

	mcells[LC_ORIGI_POS].setLabel( d.get("origid").toString() );

	if(idt != null)
	{
		styl = "";
		if(idt > 0 && idt <= 2) styl = "background:#BFB663";
		if(idt > 2)
		{
			styl = "background:#F5768B";
			for(i=0; i<mcells.length; i++)
			{
				//mcells[i].setStyle(mcells[i].getStyle() + ";color:#ffffff;");
				//mcells[i].setSclass("blink");
			}
		}
		newrow.setStyle(styl);
	}

	if(invd.equals("")) 
	{
		newrow.setStyle("background:#5c3566"); // no invoice-date hilite
		for(i=0; i<mcells.length; i++)
		{
			mcells[i].setStyle(mcells[i].getStyle() + ";color:#ffffff;");
			//mcells[i].setSclass("blink");
		}
	}

	newrow.setParent(titem);
	newrow.addEventListener("onDoubleClick", tidcliker);
	newrow.addEventListener("onClick", titicliker);
	titem.setOpen(false);
	titem.setParent(ichd);
	return titem;
}

HashMap lcTreeCheckHash = new HashMap(); // to keep track of dups prev_lc which can crash stack/heap

// ilvl=branch level-drilling, 0=until end-branch
void recurLC_Tree(Treechildren ichd, Object irs, int ilvl)
{
	st = kiboo.replaceSingleQuotes( schbox.getValue().trim() );
	whts = "";
	if(!st.equals("")) whts = " and lc.customer_name like '%" + st + "%' ";

	for(d : irs)
	{
		titem = showLCtreeDetails(ichd,d);
		lk = kiboo.checkNullString(d.get("lc_id")).trim();
		lcTreeCheckHash.put(lk,1);

		check_parlc = kiboo.checkNullString(d.get("prev_lc")).trim();
		if(!check_parlc.equals("") && ilvl == 0)
		{
			if(!lcTreeCheckHash.containsKey(check_parlc))
			{
				sqlstm = "select lc.origid, lc.lc_id, lc.customer_name, lc.invoice_date, lc.lstatus, " +
				"(select count(origid) from rw_lc_equips where lc_parent=lc.origid) as aqty, lc.prev_lc, lc.order_type, " +
				"lc.lstartdate, lc.lenddate, " +
				"( DATEDIFF(mm,lc.lstartdate,GETDATE()) - DATEDIFF(mm,lc.lstartdate,lc.lenddate) ) as bmonth, " +
				"lc.manual_inv, lc.remarks, lc.assigned " +
				//"DATEDIFF(mm,lc.lstartdate,GETDATE()) as invmm " +
				//"DATEDIFF(mm,lc.invoice_date,GETDATE()) as lstinvmonth " +
				"from rw_lc_records lc " +
				"where lc.lc_id = '" + check_parlc + "'";
				// lstatus='inactive';
				subr = sqlhand.gpSqlGetRows(sqlstm);
				if(subr.size() > 0)
				{
					Treechildren newone = new Treechildren();
					newone.setParent(titem);
					recurLC_Tree(newone,subr,ilvl);
				}
			}
		}
	}
}

// itype: 0=normal by extension + customer-name(if any), 1=by LC, 2=LC req instalment printout(toggled), 3=expiring
void showLC_tree(int itype, Tree itree)
{
	st = kiboo.replaceSingleQuotes( schbox.getValue().trim() );
	blc = kiboo.replaceSingleQuotes( lc_tb.getValue().trim() );
	sqlstm = whts = lmts = "";
	wola = " lc.origid, lc.lc_id, lc.customer_name, lc.invoice_date, lc.lstatus, " +
			"(select count(origid) from rw_lc_equips where lc_parent=lc.origid) as aqty, lc.prev_lc, lc.order_type, " +
			"lc.lstartdate, lc.lenddate, " +
			"( DATEDIFF(mm,lc.lstartdate,GETDATE()) - DATEDIFF(mm,lc.lstartdate,lc.lenddate) ) as bmonth, " +
			"lc.manual_inv, lc.remarks, lc.assigned ";

	recurlvl = 0; // recur-branches until finish
	switch(itype)
	{
		case 0:
			if(!st.equals("")) whts = " and lc.customer_name like '%" + st + "%' ";
			else lmts = " top 10 ";

			sqlstm = "select " + lmts + wola +
			//"DATEDIFF(mm,lc.lstartdate,GETDATE()) as invmm " +
			//"DATEDIFF(mm,lc.invoice_date,GETDATE()) as lstinvmonth " +
			"from rw_lc_records lc " +
			"where lc.lstatus='EXTENSION'" + whts + " order by lc.origid desc";
			//"where (lc.prev_lc is null or lc.prev_lc = '') and lc.lstatus='inactive'";
			break;

		case 1:
			if(blc.equals("")) return;
			sqlstm = "select " + wola +
			"from rw_lc_records lc " +
			"where lc.lc_id='" + blc + "'";
			break;

		case 2:
			sqlstm = "select " + wola +
			"from rw_lc_records lc " +
			"where lc.manual_inv=1";
			break;

		case 3: // expiring days can be changed.. expire_lc_daysbefore defn in rwBilling_v1.zul
			sdate = kiboo.getDateFromDatebox(expsdate);
			edate = kiboo.getDateFromDatebox(expedate);
			kk = kiboo.replaceSingleQuotes( expschtb.getValue().trim() );
			cph = "";
			if(!kk.equals("")) cph = "and customer_name like '%" + kk + "%' ";

			sqlstm = "select " + wola +
			"from rw_lc_records lc " +
			//"where ( DATEDIFF(dd,lc.lenddate,GETDATE()) ) > " + expire_lc_daysbefore +
			"where lc.lstatus not in ('INACTIVE', 'TERMINATED', 'CN', 'BUYOUT', 'Buy Out') " +
			"and lc.lenddate between '" + sdate + "' and '" + edate + "' " +
			cph +
			"order by lc.lenddate";
			recurlvl = 1; // only 1 level branch
			break;
	}

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;

	lcTreeCheckHash.clear(); // clear hashmap for new listing to detect dups

	Treechildren tocheck = itree.getTreechildren();
	if(tocheck != null) tocheck.setParent(null);
	Treechildren nchd = new Treechildren();
	nchd.setParent(itree);

	recurLC_Tree(nchd, r, recurlvl);
	itmcount_lbl.setLabel( "Found: " + r.size().toString() );
}

// Export watever main-branches in the tree ONLY
void exportLC_thing()
{
	try { tg = mainlc_tree.getTreechildren().getChildren().toArray(); } catch (Exception e) { return; }

	//alert(mainlc_tree.getTreechildren().getChildren()); return;

	rowcount = 0;
	HashMap myhmap;
	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("LC_list");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	String[] rhds = { "LC/RW","Customer","Inv.Date","LC.Start","LC.End","Gap.Mths","Order type","A.Qty","Status","Remarks" };
	for(i=0;i<rhds.length;i++)
	{
		POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,i,rhds[i]),wfont,true,"");
	}
	rowcount++;

	for(i=0; i<tg.length; i++)
	{
		//alert(tg[i].getChildren().get(0));
		ti = null;
		try { ti = tg[i].getChildren().get(1).getChildren().toArray(); } // TODO HARDCODED!!!
		catch (Exception e) { ti = tg[i].getChildren().get(0).getChildren().toArray(); }
		if(ti != null)
		{
			for(m=0; m<ti.length-1; m++)
			{
				excelInsertString(sheet,rowcount,m,ti[m].getLabel() );
			}
			rowcount++;
		}
	}

	jjfn = "LCworkList.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();
	downloadFile(kasiexport,jjfn,outfn);
}

void actuallyLinkExtension()
{
	todaydate =  kiboo.todayISODateTimeString();
	dt = getString_fromUI(ob);
	dt[0] = dt[0].replaceAll("RW",""); // remove RW from voucherno

	sqlstm = "insert into rw_lc_records (lc_id, invoice_date, customer_name, do_records, rocno, remarks, order_type, inst_type, " +
	"period, cust_project_id, fc6_custid, prev_lc, lstatus, datecreated,username) values ('" + dt[0] + "','" + dt[1] + "','" + dt[2] + "','" + dt[3] + "'," +
	"'" + dt[4] + "','" + dt[5] + "\n" + dt[7] + "','" + dt[6] + "','" + dt[8] + "'," + dt[9] + ",'" + dt[10] + "','" + dt[11] + "','" +
	glob_sel_lcid + "','EXTENSION','" + todaydate + "','" + useraccessobj.username + "');";

	sqlstm += "update rw_lc_records set lstatus='INACTIVE' where lc_id='" + glob_sel_lcid + "';";
	sqlhand.gpSqlExecuter(sqlstm);

	// copy 'em asses from current LC to extension LC
	gsql = "select origid from rw_lc_records where lc_id='" + dt[0] + "' and prev_lc='" + glob_sel_lcid + "'";
	r = sqlhand.gpSqlFirstRow(gsql);
	if(r == null) { guihand.showMessageBox("Data exchange between FC6 screwed-up!!"); return; }
	idest = r.get("origid").toString();

	// copy some shits from old LC to extension LC
	sqlstm = "update rw_lc_records set " +
	"lstartdate=s.lstartdate, lenddate=s.lenddate, qty_dt=s.qty_dt, qty_mt=s.qty_mt, " +
	"qty_nb=s.qty_nb, qty_pt=s.qty_pt, qty_hs=s.qty_hs, qty_ms=s.qty_ms, " +
	"rm_month=s.rm_month, rm_contract=s.rm_contract, assigned=s.assigned " +
	"from (select lstartdate,lenddate,qty_dt,qty_mt,qty_nb,qty_pt,qty_hs,qty_ms, " +
	"rm_month,rm_contract,assigned from rw_lc_records where origid=" + glob_selected_lc + ") s " +
	"where origid=" + idest + ";";

	sqlstm += "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor " +
	"from rw_lc_equips WHERE lc_parent=" + glob_selected_lc;

	sqlhand.gpSqlExecuter(sqlstm);
	ngfun.clearUI_Field(ob);
	showLC_tree(0, mainlc_tree);
	extbilling_pop.close();
}

// knockoff from contractbillingtrack.zul -- make sure sync changes if any
void exportAssetsList(String iwhat, int itype)
{
	if(iwhat.equals("")) return;
	if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("expassframe");
	newiframe.setWidth("100%");
	newiframe.setHeight("600px");
	cnm = global_selected_customername.replaceAll(" ","%20");
	ort = glob_ordertype.replaceAll(" ","%20");
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
	}
	thesrc = birtURL() + bfn + "&lcid=" + iwhat + 
	"&customername=" + cnm + "&ordertype=" + ort + "&rwno=RW" + glob_sel_lcid;
	newiframe.setSrc(thesrc);
	newiframe.setParent(expass_div);
	expasspop.open(repbutt);
}

