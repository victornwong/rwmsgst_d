
import org.victor.*;

// other supporting funcs used in rentalsBOM_v1
/*
SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
*/
// irecs: stockrentalitems_det recs digged
boolean checkDupParts(Object irecs)
{
	HashMap hm = new HashMap();
	retval = false;
	String[] partsid = { "ram","ram2","ram3","ram4","hdd","hdd2","hdd3","hdd4",
	"battery","gfxcard" }; // TODO HARDCODED
	// count parts
	/*
	bomtype,cpu,ram,hdd,battery,gfxcard,poweradaptor,vgacable,mouse,keyboard," + 
	"monitor,asset_tag
	*/
	for(di : irecs)
	{
		bomty = kiboo.checkNullString(di.get("bomtype")).trim();

		for(i=0;i<partsid.length;i++) // chk dup parts in BOM builds
		{
			ikl = kiboo.checkNullString( di.get(partsid[i]) ).trim();
			if(!ikl.equals("")) hm.put(ikl, ( (hm.containsKey(ikl)) ? 2 : 1) );
		}

		ipwr = kiboo.checkNullString(di.get("poweradaptor")).trim();
		imoni = kiboo.checkNullString(di.get("monitor")).trim();
		iatg = kiboo.checkNullString(di.get("asset_tag")).trim();

		// only count power-adaptor if bomtype=notebook
		if(bomty.equals("NOTEBOOK"))
			if(!ipwr.equals("")) hm.put(ipwr, ((hm.containsKey(ipwr)) ? 2 : 1) );

		if(!imoni.equals("")) hm.put(imoni, ((hm.containsKey(imoni)) ? 2 : 1) );
		if(!iatg.equals("")) hm.put(iatg, ((hm.containsKey(iatg)) ? 2 : 1) );
	}
	ptsck = hm.values().toArray(); // chk for dups
//msg = "";
	for(i=0;i<ptsck.length;i++)
	{
		if(ptsck[i] != 1) { retval = true; break; }
//msg += ptsck[i].toString() + " :: ";
	}
//alert(irecs + "---" + msg);
	return retval;
}

// check if parts alloced or non-exist TODO checkReplacementParts() in replacementsMan_v1.zul almost the same..
// retval: 1=non-exist, 2=parts exist and already alloced for other BOM, 3=parts in RMA, 4=parts in a pick-list
int checkPartStock_alloced(String istockcode, String istkcat)
{
	retval = 0;
	sqlstm = "select bom_id,rma_id,pick_id from stockmasterdetails where stock_code='" + istockcode.trim() + "' and stock_cat='" + istkcat + "'";
	ichk = sqlhand.gpSqlFirstRow(sqlstm);
	if(ichk != null)
	{
		if(ichk.get("bom_id") != null) retval = 2;
		if(ichk.get("rma_id") != null) retval = 3;
		if(ichk.get("pick_id") != null) retval = 4;
	}
	else
		retval = 1;

	return retval;
}

// retv: 1=asset-tag non-exist, 2=isactive non-rentable, 3=already in another bom, 4=wrong build-type, 5=in RMA
int checkAssetTagUsed(String iasstg, String ibuildtype)
{
	retv = 0;
	sqlstm = "select stock_cat, isactive, bom_id, rma_id from stockmasterdetails where stock_code='" + iasstg + "'";
	krc = sqlhand.gpSqlFirstRow(sqlstm);
	if(krc == null)
	{
		retv = 1;
	}
	else
	{
		kisa = (krc.get("isactive") == null) ? false : krc.get("isactive");
		if(!kisa) retv = 2;
		kbom = (krc.get("bom_id") == null) ? "" : krc.get("bom_id");
		if(!kbom.equals("")) retv = 3;

		stkcat = kiboo.checkNullString(krc.get("stock_cat"));
		if(!stkcat.equals(ibuildtype)) retv = 4;
		if(krc.get("rma_id") != null) retv = 5;
	}
	return retv;
}

void showPartsAuditLog(Object iwhat)
{
	itype = iwhat.getId();
	whatchk = null;

	String[] bt = { "pickcpu_butt", "pickram_butt", "pickram2_butt", "pickram3_butt", "pickram4_butt",
	"pickhdd_butt", "pickhdd2_butt", "pickhdd3_butt", "pickhdd4_butt",
	"pickpoweradapt_butt", "pickbatt_butt", "pickgfx_butt", "pickmonitor_butt" };

	Object[] ob = { m_asset_tag, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
	m_poweradaptor, m_battery, m_gfxcard, m_monitor };

	for(i=0; i<bt.length; i++)
	{
		if(itype.equals(bt[i])) { whatchk = ob[i]; break; }
	}

	if(whatchk != null)
	{
		tstkc = kiboo.replaceSingleQuotes(whatchk.getValue().trim());
		if(tstkc.equals("")) return;
		showSystemAudit(auditlogs_holder,tstkc,"");
		auditlogs_pop.open(iwhat);
	}
}

void toggleBuildsButts(boolean iwhat)
{
	Object[] dk = { assigncust_b, updatebom_butt, newdesktop_butt, newnotebook_butt,
	newmonitor_butt, delbuilds_butt, updbuild_b, getjobid_b, imperg_b, pbuildparts_b, autinserteq_b, autinsertmon_b, fastscan_tb };

	tongComponents(dk,iwhat);
}

void tongComponents(Object[] icmps, boolean iwhat)
{
	for(i=0;i<icmps.length;i++)
	{
		icmps[i].setDisabled(iwhat);
	}
}

// itype: 1=desktop, 2=notebook, 3=monitor
void togglePartsButtons(int itype)
{
	Object[] dis3 = { pickcpu_butt, pickram_butt, pickram2_butt, pickram3_butt, pickram4_butt,
		pickhdd_butt, pickhdd2_butt, pickhdd3_butt, pickhdd4_butt, pickbatt_butt, pickgfx_butt,
		pickvgac_butt, pickmse_butt, pickkbd_butt, pickpoweradapt_butt, pickmonitor_butt,
		m_cpu, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_battery, m_poweradaptor, m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor };

	tongComponents(dis3,false);

	if(itype == 1)
	{
		Object[] d1 = { pickbatt_butt, m_battery, pickpoweradapt_butt, m_poweradaptor };

		tongComponents(d1,true);
	}

	if(itype == 2) // notebook
	{
		Object[] d4 = {
		pickgfx_butt, pickvgac_butt, pickmse_butt, pickkbd_butt, pickmonitor_butt,
		m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor
		};

		tongComponents(d4,true);
	}

	if(itype == 3) // monitor
	{
		tongComponents(dis3,true);
	}
}

// clear build-items textboxes
void clearBuilds_items()
{
	Object[] en1 = { m_asset_tag, m_description,
		m_cpu, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_battery, m_poweradaptor, m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor,
		m_misc, coa1, coa2, coa3, coa4,
		n_cpu, n_ram, n_ram2, n_ram3, n_ram4,
		n_hdd, n_hdd2, n_hdd3, n_hdd4,
		n_battery, n_gfxcard, n_vgacable, n_mouse,
		n_keyboard, n_poweradaptor, n_monitor,
		m_optical, m_cardreader, m_webcam, m_bluetooth };

	clearUI_Field(en1);
	lbhand.matchListboxItems( osversion, "NONE" );
	lbhand.matchListboxItems( offapps, "NONE" );
}

void showBOMMetadata(String ibom)
{
	bmr = getBOM_rec(ibom);
	if(bmr == null) { guihand.showMessageBox("ERR: Cannot access BOM table"); return; }

	bomheader.setValue(BOM_PREFIX + ibom);
	bomuserheader.setValue("User: " + kiboo.checkNullString(bmr.get("createdby")) );
	customername.setValue( kiboo.checkNullString(bmr.get("customer_name")) );
	lbhand.matchListboxItems(bomcategory, kiboo.checkNullString(bmr.get("bomcategory")) );

	jid = (bmr.get("job_id") == null) ? "" : bmr.get("job_id").toString();
	job_id.setValue(jid);

	//showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	//jobnotes_div.setVisible(true);

	workarea.setVisible(true);

	if(workarea.getFellowIfAny("shwmini_ji_row") != null)
		shwmini_ji_row.setVisible(false);

}

Object[] bomslb_headers = 
{
	new listboxHeaderWidthObj("BOM#",true,"70px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Stat",true,"30px"),
	new listboxHeaderWidthObj("Catg",true,"60px"),
	new listboxHeaderWidthObj("Job",true,"60px"),
	new listboxHeaderWidthObj("ROC",true,"60px"),
	new listboxHeaderWidthObj("Commit",true,"80px"),
	new listboxHeaderWidthObj("Comm.Date",true,"80px"),
	new listboxHeaderWidthObj("Approve",true,"80px"),
	new listboxHeaderWidthObj("Appr.Date",true,"80px"),
};
CUST_IDX = 2;
BOMUSER_IDX = 3;
BOMSTAT_IDX = 4;
BOMCAT_IDX = 5;
BOMJOB_IDX = 6;
BOMROC_IDX = 7;

class bomslbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		cel1 = lbhand.getListcellItemLabel(isel,0);

		global_selected_bom = cel1.substring(3,cel1.length());
		global_selected_customer = lbhand.getListcellItemLabel(isel,CUST_IDX);

		global_bom_user = lbhand.getListcellItemLabel(isel,BOMUSER_IDX);
		global_sel_bom_status = lbhand.getListcellItemLabel(isel,BOMSTAT_IDX);

		glob_sel_bomcategory = lbhand.getListcellItemLabel(isel,BOMCAT_IDX);
		glob_sel_jobid = lbhand.getListcellItemLabel(isel,BOMJOB_IDX);

		if(documents_holder.getFellowIfAny("doculinks_lb") != null) doculinks_lb.setParent(null);

		showBOMMetadata(global_selected_bom);
		showBuildItems(global_selected_bom);
		bval = ( global_sel_bom_status.equals("COMMIT") || global_sel_bom_status.equals("APPROVE") ) ? true : false;
		toggleBuildsButts(bval);

		glob_commit_sql = ""; // clear prev commit-bom sqlstm
		global_selected_build = ""; // clear prev selected build
		build_details_grid.setVisible(false);
	}
}
bomclkier = new bomslbClick();

void showBOMList()
{
	scht = kiboo.replaceSingleQuotes( searhtxt_tb.getValue().trim() );
	bybom = kiboo.replaceSingleQuotes( bybomid_tb.getValue().trim() );
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(boms_holder, bomslb_headers, "boms_lb", 3);

	sqlstm = "select sri.origid,sri.customer_name,sri.createdate,sri.createdby,sri.bomstatus," + 
	"sri.bomcategory,sri.job_id, sri.approveby, sri.approvedate, sri.roc_id, sri.commitdate, sri.commitby from stockrentalitems sri ";
	wherestr = "where sri.createdate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	if(!bybom.equals(""))
	{
		bybomid_tb.setValue("");
		try
		{
			kk = Integer.parseInt(bybom);
			wherestr = "where sri.origid=" + bybom;
		} catch (Exception e)
		{
			return;
		}
	}

	if(!scht.equals(""))
	{
		wherestr = "left join stockrentalitems_det srid on srid.parent_id = sri.origid " + 
		"where srid.asset_tag like '%" + scht + "%' or sri.customer_name like '%" + scht + "%' " +
		"group by sri.origid,sri.customer_name,sri.createdate,sri.createdby,sri.bomstatus,sri.bomcategory," +
		"sri.job_id, sri.approveby, sri.approvedate, sri.roc_id, sri.commitdate, sri.commitby ";

		searhtxt_tb.setValue("");
	}

	sqlstm += wherestr;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.addEventListener("onSelect", bomclkier);
	ArrayList kabom = new ArrayList();
	String[] fl = { "createdate", "customer_name", "createdby", "bomstatus", "bomcategory", "job_id", "roc_id", "commitby", "commitdate", "approveby", "approvedate" };
	for(dpi : screcs)
	{
		kabom.add(BOM_PREFIX + dpi.get("origid").toString());
		ngfun.popuListitems_Data(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	workloadholder.setVisible(true);
}

void showBuild_metadata(String ibui)
{
	if(documents_holder.getFellowIfAny("doculinks_lb") != null) doculinks_lb.setParent(null);

	ris = getRentalItems_build(ibui);
	if(ris == null)
	{
		guihand.showMessageBox("ERR: Cannot access rental-item builds table..");
		return;
	}
	clearBuilds_items();

	Object[] fls = {
	m_asset_tag, m_description, m_cpu, m_ram, m_hdd, m_gfxcard, m_vgacable,
	m_mouse, m_keyboard, m_poweradaptor, m_misc, m_monitor, m_battery,
	coa1, coa2, coa3, coa4,
	m_ram2, m_ram3, m_ram4,
	m_hdd2, m_hdd3, m_hdd4,
	m_grade, osversion, offapps,
	m_optical, m_webcam, m_cardreader, m_bluetooth };

	String[] fln = {
	"asset_tag", "description", "cpu", "ram", "hdd", "gfxcard", "vgacable",
	"mouse", "keyboard", "poweradaptor", "misc", "monitor", "battery",
	"coa1", "coa2", "coa3", "coa4",
	"ram2", "ram3", "ram4",
	"hdd2", "hdd3", "hdd4",
	"grade", "osversion", "offapps",
	"optical", "webcam", "cardreader", "bluetooth" };

	ngfun.populateUI_Data(fls,fln,ris);

	fillDocumentsList(documents_holder,ASS_PREFIX,ibui);
}

Object[] builds_headers = 
{
	new listboxHeaderWidthObj("##",true,"60px"),
	new listboxHeaderWidthObj("Builds",true,"70px"),
	new listboxHeaderWidthObj("AssetTag",true,"80px"),
	new listboxHeaderWidthObj("Grd",true,"40px"),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("origid",false,""),
};

class buildsClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		//doFunc(updbuild_b); // update prev build-items if any
		isel = event.getReference();
		global_selected_build = lbhand.getListcellItemLabel(isel,5);
		bln = lbhand.getListcellItemLabel(isel,0);
		global_sel_buildtype = lbhand.getListcellItemLabel(isel,1);
		buildno_lbl.setValue(bln + " " + global_sel_buildtype);

		// toggle parts-selection butts TODO later need to modi to cater SERVER
		// 26/08/2013: monitor type added
		blty = (global_sel_buildtype.equals("DESKTOP")) ? 1 : 2;
		if(global_sel_buildtype.equals("MONITOR")) blty = 3;

		togglePartsButtons(blty);
		showBuild_metadata(global_selected_build);
		build_details_grid.setVisible(true);

		} catch (Exception e) {}
	}
}
buidlsclik = new buildsClick();

void showBuildItems(String ibid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(builds_holder, builds_headers, "builds_lb", 3);
	sqlstm = "select origid,bomtype,grade,misc,asset_tag from stockrentalitems_det where parent_id=" + ibid;
	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	newlb.setMultiple(true); newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", buidlsclik);
	lncnt = 1;
	ArrayList kabom = new ArrayList();
	String[] fl = { "bomtype", "asset_tag", "grade", "misc", "origid" };
	for(dpi : screcs)
	{
		kabom.add(lncnt.toString() + ".");
		ngfun.popuListitems_Data2(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lncnt++;
		kabom.clear();
	}
}

Object[] bldsdehds = 
{
	new listboxHeaderWidthObj("bomtype",true,""),	new listboxHeaderWidthObj("asset_tag",true,""),
	new listboxHeaderWidthObj("f_ename",true,""),	new listboxHeaderWidthObj("f_grade",true,""),
	new listboxHeaderWidthObj("ram1",true,""), new listboxHeaderWidthObj("f_ram1",true,""),
	new listboxHeaderWidthObj("ram2",true,""), new listboxHeaderWidthObj("f_ram2",true,""),
	new listboxHeaderWidthObj("ram3",true,""), new listboxHeaderWidthObj("f_ram3",true,""),
	new listboxHeaderWidthObj("ram4",true,""), new listboxHeaderWidthObj("f_ram4",true,""),
	new listboxHeaderWidthObj("hdd1",true,""), new listboxHeaderWidthObj("f_hdd1",true,""),
	new listboxHeaderWidthObj("hdd2",true,""), new listboxHeaderWidthObj("f_hdd2",true,""),
	new listboxHeaderWidthObj("hdd3",true,""), new listboxHeaderWidthObj("f_hdd3",true,""),
	new listboxHeaderWidthObj("hdd4",true,""), new listboxHeaderWidthObj("f_hdd4",true,""),
	new listboxHeaderWidthObj("battery",true,""), new listboxHeaderWidthObj("f_battery",true,""),
	new listboxHeaderWidthObj("poweradaptor",true,""), new listboxHeaderWidthObj("f_power",true,""),
	new listboxHeaderWidthObj("gfxcard",true,""), new listboxHeaderWidthObj("f_gfxcard",true,""),
	new listboxHeaderWidthObj("osversion",true,""), new listboxHeaderWidthObj("coa1",true,""),
	new listboxHeaderWidthObj("offapps",true,""), new listboxHeaderWidthObj("coa2",true,""),
	new listboxHeaderWidthObj("coa3",true,""), new listboxHeaderWidthObj("coa4",true,""),
	new listboxHeaderWidthObj("misc",true,""), new listboxHeaderWidthObj("description",true,""),
	new listboxHeaderWidthObj("optical",true,""), new listboxHeaderWidthObj("webcam",true,""),
	new listboxHeaderWidthObj("cardreader",true,""), new listboxHeaderWidthObj("bluetooth",true,""),
};

void showBuildsLikeExcel()
{
	if(global_selected_bom.equals("")) return;

	sqlstm = "select srd.bomtype, srd.asset_tag, " +
	"(select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.asset_tag) as f_ename, " +
	"(select top 1 grade from Focus5012.dbo.partsall_0 where assettag=srd.asset_tag) as f_grade, " +
	"srd.ram, (select top 1  name from Focus5012.dbo.partsall_0 where assettag=srd.ram) as f_ram1, " +
	"srd.ram2, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram2) as f_ram2, " +
	"srd.ram3, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram3) as f_ram3, " +
	"srd.ram4, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram4) as f_ram4, " +
	"srd.hdd, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd) as f_hdd1, " +
	"srd.hdd2, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd2) as f_hdd2, " +
	"srd.hdd3, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd3) as f_hdd3, " +
	"srd.hdd4, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd4) as f_hdd4, " +
	"srd.battery, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.battery) as f_battery, " +
	"srd.poweradaptor, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.poweradaptor) as f_power, " +
	"srd.gfxcard, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.gfxcard) as f_gfxcard, " +
	"srd.misc, srd.description, srd.osversion, srd.coa1, srd.offapps, srd.coa2, srd.coa3, srd.coa4, " +
	"srd.optical, srd.webcam, srd.cardreader, srd.bluetooth " +
	"from stockrentalitems_det srd where parent_id=" + global_selected_bom;

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(buildslikexcel_holder, bldsdehds, "buildsdetails", 10);
	ArrayList kabom = new ArrayList();
	String[] fl = { "bomtype", "asset_tag", "f_ename", "f_grade", "ram", "f_ram1", "ram2", "f_ram2", "ram3", "f_ram3", "ram4", "f_ram4",
	"hdd", "f_hdd1", "hdd2", "f_hdd2", "hdd3", "f_hdd3", "hdd4", "f_hdd4", "battery", "f_battery", "poweradaptor", "f_power",
	"gfxcard", "f_gfxcard", "osversion", "coa1", "offapps", "coa2", "coa3", "coa4", "misc", "description", "optical", "webcam", "cardreader", "bluetooth" };
	for(d : r)
	{
		popuListitems_Data(kabom,fl,d);

		for(i=0;i<kabom.size();i++)
		{
			kk = kabom.get(i);
			if(kk.equals("COMBO")) kabom.set(i,"");
		}

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-size:6px");
		kabom.clear();
	}
	buildsnombor_lbl.setValue(global_selected_bom);
}

void exportBuildsDetails()
{
	bn = buildsnombor_lbl.getValue();
	if(bn.equals("")) return;
	exportExcelFromListbox(buildsdetails, kasiexport, bldsdehds, "BUILDS_" + bn + ".xls","thebuilds");
}

// Commit the BOM -- check builds' parts for deployed-status
// 19/06/2014: old-version using stockmasterdetails -- not using
void commitBOM(String ibomid)
{
	// chk BOM assign to customer
	if(global_selected_customer.equals("NEW"))
	{
		guihand.showMessageBox("BOM is not assigned to a customer, cannot commit!");
		return;
	}

	sqlstm = "select bomtype,cpu,ram,hdd,battery,gfxcard,poweradaptor,vgacable,mouse,keyboard," + 
	"monitor,asset_tag,ram2,ram3,ram4,hdd2,hdd3,hdd4 from stockrentalitems_det where " + 
	"parent_id=" + ibomid;
	bis = sqlhand.gpSqlGetRows(sqlstm);
	if(bis.size() == 0)
	{
		guihand.showMessageBox("Nothing to commit..");
		return;
	}

	if(checkDupParts(bis)) // chk for dups in the builds parts
	{
		guihand.showMessageBox("Duplicates found in this BOM list.. please check");
		return;
	}

	msg = "";
	kerror = 0;
	DOESNOTEXIST_STR = " does not exist in inventory or different type";
	ALREADYASS_STR = " already assigned/deployed";
	partslist = "";
	assettags = "";

	String[] parts_ram = { "ram","ram2","ram3","ram4" }; // HARDCODED
	String[] parts_hdd = { "hdd","hdd2","hdd3","hdd4" };

	for(bi : bis) // check parts
	{
		astg = kiboo.checkNullString(bi.get("asset_tag")).trim();
		bmtype = kiboo.checkNullString(bi.get("bomtype")).trim();

		if(astg.equals("")) // disallow empty asset-tag
		{
			msg += "\nERR: Found 1 build without asset-tag";
			kerror++;
		}
		else // drill builds - check parts
		{
			msg += "\nProcessing " + bmtype + " : " + astg + "..";

			kchk = checkAssetTagUsed(astg, bmtype );
			if( kchk != 0)
			{
				msg += "\nASSET: " + astg + " cannot be used. Pls check: " + kchk.toString() ;
				kerror++;
			}
			else
			{
				assettags += "'" + astg + "',";
				if(bmtype.equals("MONITOR")) { msg += "OK"; continue; }
			}

			derr = 0;

			// chk bomtype(build type) for parts
			bram = kiboo.checkNullString(bi.get("ram")).trim();
			bhdd = kiboo.checkNullString(bi.get("hdd")).trim();
			bbat = kiboo.checkNullString(bi.get("battery")).trim();
			bpwr = kiboo.checkNullString(bi.get("poweradaptor")).trim();
			bmoni = kiboo.checkNullString(bi.get("monitor")).trim();
			bgfx = kiboo.checkNullString(bi.get("gfxcard")).trim();

			// RAM1 and HDD1 mandatory in desktop and NB builds
			if(bram.equals("")) { msg += "\n\tRAM: " + bmtype + " build needs RAM!!"; kerror++; }
			if(bhdd.equals("")) { msg += "\n\tHDD: " + bmtype + " build needs HDD!!"; kerror++; }

			// proceed to chk stock when both hdd1 and ram1 was entered..
			if(!bram.equals("") && !bhdd.equals(""))
			{
				for(i=0;i<parts_ram.length;i++)
				{
					pts = kiboo.checkNullString( bi.get(parts_ram[i]) ).trim();
					if(!pts.equals(""))
					{
						ck = checkPartStock_alloced(pts,"RAM");
						if(ck != 0)
						{
							msg += "\n\tRAM: " + pts + ((ck == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
							kerror++;
						}
						else
							partslist += "'" + pts + "',";
					}
				}

				for(i=0;i<parts_hdd.length;i++)
				{
					pts = kiboo.checkNullString( bi.get(parts_hdd[i]) ).trim();
					if(!pts.equals(""))
					{
						ck = checkPartStock_alloced(pts,"HDD");
						if(ck != 0)
						{
							msg += "\n\tHDD: " + pts + ((ck == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
							kerror++;
						}
						else
							partslist += "'" + pts + "',";
					}
				}
			}

			if(bmtype.equals("DESKTOP"))
			{
				if(!bgfx.equals("")) // chk gfxcard, if only assigned
				{
					chkgfx = checkPartStock_alloced(bgfx,"GFXCARD");
					if(chkgfx != 0)
					{
						msg += "\n\tGFX: " + bgfx + ((chkgfx == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
						kerror++;
					}
					partslist += "'" + bgfx + "',";
				}
				if(!bmoni.equals("")) // chk monitor
				{
					chkmoni = checkPartStock_alloced(bmoni,"MONITOR");
					if(chkmoni != 0)
					{
						msg += "\n\tMONI: " + bmoni + ((chkmoni == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
						kerror++;
					}
					partslist += "'" + bmoni + "',";
				}
			}

			if(bmtype.equals("NOTEBOOK"))
			{
				// notebook mandatory battery,power-adaptor
				chkbat = checkPartStock_alloced(bbat,"BATTERY");
				chkpwr = checkPartStock_alloced(bpwr,"PWRADAPTOR");
				if(chkbat != 0)
				{
					msg += "\n\tBATT: " + bbat + ((chkbat == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
					kerror++;
				}
				if(chkpwr != 0)
				{
					msg += "\n\tPWRA: " + bpwr + ((chkpwr == 1) ? DOESNOTEXIST_STR : ALREADYASS_STR);
					kerror++;
				}
				partslist += "'" + bbat + "','" + bpwr + "',";
			}

			// TODO need to check windows or office if any

		} // ENDOF drill builds
	}

	if(kerror > 0)
	{
		msg += "\n\n" + kerror.toString() + " error(s) found.. cannot commit this BOM list";
	}
	else
	{
	/*
		for(bi : bis)
		{
			bram = kiboo.checkNullString(bi.get("ram")).trim();
			bhdd = kiboo.checkNullString(bi.get("hdd")).trim();
			bbat = kiboo.checkNullString(bi.get("battery")).trim();
			bpwr = kiboo.checkNullString(bi.get("poweradaptor")).trim();
			bmoni = kiboo.checkNullString(bi.get("monitor")).trim();
		}
	*/
		msg += "\n\nBOM passed checks. Parts assigned..";
		// Update all those parts bom_id
	
		todaydate =  kiboo.todayISODateTimeString();

		if(partslist.length() > 0)
		{
			partslist = partslist.substring(0,partslist.length()-1);
			glob_commit_sql = "update stockmasterdetails set bom_id=" + ibomid + ", bom_date='" + todaydate + "', " + 
			"stock_movement = cast(stock_movement as nvarchar(max)) + '" + todaydate + ": Item assigned to BOM " + ibomid + "\n' " +
			"where stock_code in (" + partslist + ");"; // update bom_id in parts
		}

		if(assettags.length() > 0)
		{
			assettags = assettags.substring(0,assettags.length()-1);
			glob_commit_sql += "update stockmasterdetails set bom_id=" + ibomid + ", bom_date='" + todaydate + "', " +
			"stock_movement = cast(stock_movement as nvarchar(max)) + '" + todaydate + ": Item assigned to BOM " + ibomid + "\n' " + 
			"where stock_code in (" + assettags + ");"; // update bom_id for asset-tags
		}

		glob_commit_sql += "update stockrentalitems set bomstatus='COMMIT', commitdate='" + todaydate + "'," + 
		"commitby='" + useraccessobj.username + "' where origid=" + ibomid + ";";

		// msg += "\n" + sqlstm;

	}

	commbom_lbl.setValue(msg);
	commitpro_pop.open(commitbom_butt);
}

