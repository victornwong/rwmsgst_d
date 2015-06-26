import java.util.regex.*;
import org.victor.*;
// Asset related funcs for contractBillingTrack_v1.zul
// 04/12/2014: added city and state field for asset-location, req by Leanne

void showAssetMetadata(String iwhat)
{
	rc = rwsqlfun.getLCEquips_rec(iwhat);
	glob_sel_assetrec = rc;

	Object[] metflds = {
	m_asset_tag,m_brand,m_model,m_battery,m_hdd,m_hdd2,m_hdd3,m_hdd4,m_ram,m_ram2,m_ram3,m_ram4,
	m_gfxcard,m_mouse,m_keyboard,m_monitor,m_poweradaptor,coa1,coa2,coa3,coa4,m_misc,m_cust_location,
	m_type,osversion,offapps,m_serial_no, m_rm_month, m_qty, m_do_no, m_loca_city, m_loca_state
	};

	String[] metfnms = {
	"asset_tag","brand","model","battery","hdd","hdd2","hdd3","hdd4","ram","ram2","ram3","ram4",
	"gfxcard","mouse","keyboard","monitor","poweradaptor","coa1","coa2","coa3","coa4",
	"remarks","cust_location",
	"type","osversion","offapps","serial_no", "RM_Month", "qty", "do_no", "loca_city", "loca_state"
	};
	
	ngfun.clearUI_Field(metflds);
	ngfun.populateUI_Data(metflds, metfnms, rc);
	assbom_holder.setVisible(true);
}

Object[] asslb_hds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("GCO/N",true,"40px"), // 5
	new listboxHeaderWidthObj("Bill",true,"40px"),
	new listboxHeaderWidthObj("BuyO",true,"40px"),
	new listboxHeaderWidthObj("FrmLC",true,"70px"),
	new listboxHeaderWidthObj("Qty",true,"40px"),
	new listboxHeaderWidthObj("Asgn",true,"40px"), // 10
	new listboxHeaderWidthObj("origid",false,""),
};

ASSLB_TYPE_IDX = 4;
ASSLB_GCO_IDX = 5;
ASSLB_ORIGID_IDX = 11;

class assClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_selected_ass_li = isel;
		glob_selected_ass = lbhand.getListcellItemLabel(isel,ASSLB_ORIGID_IDX); // asset's origid always last TODO
		glob_selected_asstag = lbhand.getListcellItemLabel(isel,0);
		showAssetMetadata(glob_selected_ass);
	}
}
assclicko = new assClick();

void showAssets(String iwhat)
{
	Listbox newlb = lbhand.makeVWListbox_Width(lcasset_holder, asslb_hds, "lcassets_lb", 20);
	sqlstm = "select origid,asset_tag,brand,model,type,serial_no,gcn_id,billable,buyout,impfromlc,hotswap,qty,assigned from rw_lc_equips " +
	"where lc_parent=" + iwhat + " order by asset_tag";

	asrs = sqlhand.gpSqlGetRows(sqlstm);
	if(asrs.size() == 0) return;
	newlb.setMold("paging"); newlb.setMultiple(true); newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", assclicko);
	ArrayList kabom = new ArrayList();
	String[] fl = { "asset_tag", "serial_no", "brand", "model", "type", "gcn_id", "billable",
	"buyout", "impfromlc", "qty", "assigned", "origid" };
	for(d : asrs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		ks = "font-size:9px;";
		if(d.get("gcn_id") != null && d.get("gcn_id") != 0 )
		{
			if(d.get("buyout") != null)
				ks += "background:#EF780F";
			else
				ks += "background:#f77272";
		}

		if(d.get("buyout") != null)
			if(d.get("buyout")) ks += "background:#23B3DB";

		if(d.get("billable") != null)
			if(d.get("billable")) ks += "background:#AEF26B";

		if(d.get("hotswap") != null)
			if(d.get("hotswap")) ks += "background:#D11CBE";

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",ks);
		kabom.clear();
	}
	//updateFoundStuff_labels(lc_assetsfound_lbl,lcassets_lb, " asset/item(s) found");
	//glob_selected_ass = ""; // reset
	//assetworkarea.setVisible(false);
}

// ROC/LC assets funcs
void assFunc(Object iwhat)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh_wass = false;
	msgtext = sqlstm = "";

	if(itype.equals("newasset_b"))
	{
		if(glob_selected_lc.equals("")) return;
		sqlstm = "insert into rw_lc_equips (asset_tag,serial_no,lc_parent,billable,buyout,hotswap,qty) values " +
		"('NEW ASSET','NO SERIAL'," + glob_selected_lc + ",0,0,0,1)";
		refresh_wass = true;
	}

	if(itype.equals("updasset_b"))
	{
		if(glob_selected_ass.equals("")) return;
		
		Object[] inpflds = {
		m_asset_tag, m_brand, m_model, m_battery, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_ram, m_ram2, m_ram3, m_ram4, m_gfxcard, m_mouse, m_keyboard, m_monitor,
		coa1, coa2, coa3, coa4, osversion, offapps, m_misc,
		m_type, m_cust_location, m_poweradaptor, m_serial_no, m_rm_month, m_qty, m_do_no,
		m_loca_city, m_loca_state
		};

		inpdat = ngfun.getString_fromUI(inpflds);
		try { k = Float.parseFloat(inpdat[27]); } catch (Exception e) { inpdat[27] = "0"; } // chk RM/month is truly numba
		try { k = Integer.parseInt(inpdat[28]); } catch (Exception e) { inpdat[28] = "1"; } // chk got set qty else 1

		sqlstm = "update rw_lc_equips set asset_tag='" + inpdat[0] + "', brand='" + inpdat[1] + "', model='" + inpdat[2] +"'," +
		"battery='" + inpdat[3] + "', hdd='" + inpdat[4] + "', hdd2='" + inpdat[5] + "', hdd3='" + inpdat[6] + "', hdd4='" + inpdat[7] + "'," +
		"ram='" + inpdat[8] + "', ram2='" + inpdat[9] + "', ram3='" + inpdat[10] + "', ram4='" + inpdat[11] + "'," +
		"gfxcard='" + inpdat[12] + "', mouse='" + inpdat[13] + "', keyboard='" + inpdat[14] + "', monitor='" + inpdat[15] + "'," +
		"coa1='" + inpdat[16] + "', coa2='" + inpdat[17] + "', coa3='" + inpdat[18] + "', coa4='" + inpdat[19] + "'," +
		"osversion='" + inpdat[20] + "', offapps='" + inpdat[21] + "', remarks='" + inpdat[22] + "', type='" + inpdat[23] + "'," + 
		"cust_location='" + inpdat[24] + "', poweradaptor='" + inpdat[25] + "', serial_no='" + inpdat[26] + "', rm_month=" + inpdat[27] +
		", qty=" + inpdat[28] + ", do_no='" + inpdat[29] + "', loca_city='" + inpdat[30] + "', loca_state='" + inpdat[31] + "' where origid=" + glob_selected_ass;

		refresh_wass = true;
	}

	if(itype.equals("remasset_b"))
	{
		if(glob_selected_ass.equals("")) return;
		/*
		if(useraccessobj.accesslevel == 9)
		{
			if (Messagebox.show("This will be a hard delete..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			deleteLCAssets();

			glob_sel_assetrec = null;
			glob_selected_ass = "";
			assbom_holder.setVisible(false);
			refresh_wass = true;
		}
		else
		msgtext = "Higher access level required to remove-asset from LC/ROC";
		*/
			if (Messagebox.show("This will be a hard delete..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			deleteLCAssets();

			glob_sel_assetrec = null;
			glob_selected_ass = "";
			assbom_holder.setVisible(false);
			refresh_wass = true;
	}

	if(itype.equals("repasspop_b"))
	{
		clearReplaceAssetPopup();
		currasst_lbl.setValue(glob_selected_asstag);
		replaceasset_pop.open(iwhat);
	}

	// 13/01/2014: no need any checking for now. Just let 'em replace anything
	if(itype.equals("repasset_b")) // replace assets - TODO a bit complex, need to link-up with BOM or something
	{
		if(glob_selected_ass.equals("")) return;
		ks = kiboo.replaceSingleQuotes(r_asset_tag.getValue().trim());
		if(ks.equals("")) return;
		replaceasset_pop.close();
		replaceLCAsset(); // actually doing it
		glob_selected_ass = "";
		clearReplaceAssetPopup();
	}

	if(itype.equals("assimpbom_b"))
	{
		if(glob_selected_lc.equals("")) return;
		if(glob_sel_importbom.equals("")) return; // glob_sel_importbom def in: TODO
		importBOMToLC(glob_selected_lc,glob_sel_importbom);
	}

	if(itype.equals("markcollect_b")) // mark for collection
	{
		try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
		astgs = "";
		for(d : lcassets_lb.getSelectedItems())
		{
			atg = lbhand.getListcellItemLabel(d,0);
			gcni = lbhand.getListcellItemLabel(d,5); // gcn-id must be blank
			if( !atg.equals("") && (gcni.equals("") || gcni.equals("0")) ) astgs += atg + "\n";
		}
		gcntrans_lbl.setValue(astgs);
		gcn_trans_pop.open(iwhat);
	}

	if(itype.equals("svgcntrans_b")) // actually saving selected assets for collection - gcn-transient-table
	{
		try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
		if(glob_sel_lc_str.equals(""))
		{
			msgtext = "To save transient-asset-tags for collection, LC-id must be available.";
		}
		else
		{
			for(d : lcassets_lb.getSelectedItems())
			{
				atg = lbhand.getListcellItemLabel(d,0);
				asn = lbhand.getListcellItemLabel(d,1);
				if(atg.equals("")) continue;

				gcni = lbhand.getListcellItemLabel(d,ASSLB_GCO_IDX); // gcn-id must be blank to be saved in transient-table
				if(gcni.equals("") || gcni.equals("0"))
				{
					itmd =
					"[" + lbhand.getListcellItemLabel(d,4) + "] " +
					lbhand.getListcellItemLabel(d,2) + " " + lbhand.getListcellItemLabel(d,3);

					// TODO save fc6-customer-id
					sqlstm += "insert into rw_gcn_transient (lc_id,serial_no,asset_tag,item_desc) values " +
					"('" + glob_sel_lc_str + "','" + asn + "','" + atg + "','" + itmd + "');";
				}
			}
			//alert(sqlstm);
			if(!sqlstm.equals("")) msgtext = "Assets saved to GCN/O transient-table..";
		}
	}

	if(itype.equals("impDOass_b")) // import from FC6 DO
	{
		if(glob_selected_lc.equals("")) return;
		impFC6_DO_Assets(glob_selected_lc,1);
	}

	if(itype.equals("flexi_impDOass_b"))
	{
		if(glob_selected_lc.equals("")) return;
		impFC6_DO_Assets(glob_selected_lc,2);
	}

	if(itype.equals("getfc6assdet_b")) // try to suck asset-details from FC6
	{
		if(glob_selected_ass.equals("")) return;
		suckFCAssetDetails(glob_selected_ass, glob_selected_asstag);
	}

	if(itype.equals("sedutcontc_b")) // try suck from contract-care equips listing as of 20/02/2014
	{
		if(glob_selected_lc.equals("")) return;
		actualSuckContractcare();
	}

	// copy assets from another LC. 25/07/2014: omit gcn/buyout
	// 09/03/2015: huping/nurul req, import assets with billable-flag on
	if(itype.equals("copyassflc_b") || itype.equals("copyassflc_filt_b") || itype.equals("copyassflc_billable_b"))
	{
		if(glob_selected_lc.equals("")) return;
		olc = kiboo.replaceSingleQuotes( copylcid.getValue().trim() );
		if(olc.equals("")) return;
		sqlr = "select origid from rw_lc_records where lc_id='" + olc + "'";
		rc = sqlhand.gpSqlFirstRow(sqlr);
		if(rc != null)
		{
			if(itype.equals("copyassflc_b")) superCopyAssetsFromLC(1,glob_selected_lc, rc.get("origid").toString());
			if(itype.equals("copyassflc_filt_b")) superCopyAssetsFromLC(2,glob_selected_lc, rc.get("origid").toString());
			if(itype.equals("copyassflc_billable_b")) superCopyAssetsFromLC(3,glob_selected_lc, rc.get("origid").toString());

			add_RWAuditLog(LC_PREFIX + glob_selected_lc, "", "Copy assets from LC " + olc + " [" + itype + "]" , useraccessobj.username);
		}
	}

	if(itype.equals("cleargcntrans_b")) // 08/04/2014: clear transient-GCO recs
	{
		if(glob_sel_lc_str.equals("")) return;
		if (Messagebox.show("Delete temp.GCO records..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		sqlstm = "delete from rw_gcn_transient where lc_id='" + glob_sel_lc_str + "';";
		msgtext = "Puifff";
	}

	if(itype.equals("sdtdoaddr_b")) // 31/10/2014: import from FC6 DO's delivery address for asset location
	{
		try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
		for(d : lcassets_lb.getSelectedItems())
		{
			atg = lbhand.getListcellItemLabel(d,0);
			sqlstm += update_AssetLocation_byDOAddress(glob_selected_lc, atg);
		}
		msgtext = "Asset-location imported from DO delivery address..";
	}

	if(itype.equals("chkreplacement_b")) // 31/10/2014: check helpdesk entered replacements
	{
		if(glob_lcmeta_rec == null) return;
		f6 = glob_lcmeta_rec.get("fc6_custid");
		showLCAss_RepTrack_2(null,lcreps_holder,"lcreps_lb",f6);
		rmareplace_pop.open(iwhat);
	}

	if(itype.equals("chkreplall_b")) // 04/11/2014: check all non-updated replacements by helpdesk
	{
		showLCAss_RepTrack_2(null,lcreps_holder,"lcreps_lb","");
		rmareplace_pop.open(iwhat);
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	if(refresh_wass) showAssets(glob_selected_lc);
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

// 31/10/2014: update asset-location from DO delivery address - req by huiping
String update_AssetLocation_byDOAddress(String ilc, String iatg)
{
	retv = "";

	sqlstm = "select top 1 k.deliveryaddressyh from Focus5012.dbo.data d2 left join Focus5012.dbo.u001c k on k.extraid = d2.extraheaderoff " +
	"where d2.vouchertype=6144 and d2.voucherno=(select do_no from rw_lc_equips where lc_parent=" + ilc + " and asset_tag='" + iatg + "');";

	r = sqlhand.gpSqlFirstRow(sqlstm);

	if(r != null)
	{
		dla = r.get("deliveryaddressyh");
		if(dla.equals("")) return retv;
		retv = "update rw_lc_equips set cust_location='" + dla + "' where lc_parent=" + ilc + " and asset_tag='" + iatg + "';";
	}
	return retv;
}

// 09/03/2015: consolidate all the functions into this one.
// 09/03/2015: huping/nurul req, import assets with billable-flag on
// 25/07/2014: import assets from other LC omitting those with GCO or buyout flag
void superCopyAssetsFromLC(int itype, String idest, String isrc)
{
	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap " +
	"from rw_lc_equips WHERE lc_parent=" + isrc;

	wherest = "";

	switch(itype)
	{
		case 1: // copy all assets from src to dest
			break;

		case 2: // import and ommit GCO or buyout flag
			wherest = " and (buyout is null or buyout=0) and (gcn_id is null or gcn_id=0)";
			break;

		case 3: // import assets with billable-flag on
			wherest = " and billable=1";
			break;
	}

	sqlstm += wherest;
	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
}

void copyAssetsFromLC(String idest, String isrc)
{
	/*
	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap " +
	"from rw_lc_equips WHERE lc_parent=" + isrc;

	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
	*/
}

// 25/07/2014: import assets from other LC omitting those with GCO or buyout flag
void copyAssetsFromLC_omitgcnbuyout(String idest, String isrc)
{
	/*
	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap " +
	"from rw_lc_equips WHERE (buyout is null or buyout=0) and (gcn_id is null or gcn_id=0) and lc_parent=" + isrc;
	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
	*/
}

// 09/03/2015: huping/nurul req, import assets with billable-flag on
void copyAssetsFromLC_onlyBillable(String idest, String isrc)
{
	/*
	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,hotswap " +
	"from rw_lc_equips WHERE billable=1 and lc_parent=" + isrc;
	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
	*/
}

void suckFCAssetDetails(String iasid, String iastg)
{
	if(lcassets_lb.getSelectedCount() > 1) multiSuckFCAssetDetails();

	sqlstm = "select m.code, u.brandyh, u.modelyh, u.hddsizeyh,u.itemtypeyh, u.remarkyh, u.coa1yh, u.coa2yh," +
	"u.coa1keyyh, u.coa2keyyh, u.ramsizeyh from mr001 m left join u0001 u on u.extraid = m.masterid " +
	"where m.code2='" + iastg + "'";

	d = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(d == null) return;

	sql2 = "update rw_lc_equips set serial_no='" + kiboo.checkNullString(d.get("code")) + "'," +
	"brand='" + kiboo.checkNullString(d.get("brandyh")) + "'," +
	"model='" + kiboo.checkNullString(d.get("modelyh")) + "'," +
	"type='" + kiboo.checkNullString(d.get("itemtypeyh")) + "'," +
	"hdd='" + kiboo.checkNullString(d.get("hddsizeyh")) + "'," +
	"ram='" + kiboo.checkNullString(d.get("ramsizeyh")) + "'," +
	"osversion='" + kiboo.checkNullString(d.get("coa1yh")) + "'," +
	"offapps='" + kiboo.checkNullString(d.get("coa2yh")) + "'," +
	"coa1='" + kiboo.checkNullString(d.get("coa1keyyh")) + "'," +
	"coa2='" + kiboo.checkNullString(d.get("coa2keyyh")) + "' " +
	"where origid=" + iasid;

	sqlhand.gpSqlExecuter(sql2);
	showAssetMetadata(iasid);
}

// 20/02/2014: multi-select grab asset-spec from FC6
void multiSuckFCAssetDetails()
{
	kx = lcassets_lb.getSelectedItems().toArray();
	sqlstm = "";
	for(i=0;i<kx.length;i++)
	{
		atg = lbhand.getListcellItemLabel(kx[i],0).trim();
		oid = lbhand.getListcellItemLabel(kx[i],ASSLB_ORIGID_IDX);

		fst = "select m.code, u.brandyh, u.modelyh, u.hddsizeyh,u.itemtypeyh, u.remarkyh, u.coa1yh, u.coa2yh," +
		"u.coa1keyyh, u.coa2keyyh, u.ramsizeyh from mr001 m left join u0001 u on u.extraid = m.masterid " +
		"where ltrim(rtrim(m.code2))='" + atg + "'";

		d = sqlhand.rws_gpSqlFirstRow(fst);

		if(d != null)
		{
			sqlstm += "update rw_lc_equips set serial_no='" + kiboo.checkNullString(d.get("code")) + "'," +
				"brand='" + kiboo.checkNullString(d.get("brandyh")) + "'," +
				"model='" + kiboo.checkNullString(d.get("modelyh")) + "'," +
				"type='" + kiboo.checkNullString(d.get("itemtypeyh")) + "'," +
				"hdd='" + kiboo.checkNullString(d.get("hddsizeyh")) + "'," +
				"ram='" + kiboo.checkNullString(d.get("ramsizeyh")) + "'," +
				"osversion='" + kiboo.checkNullString(d.get("coa1yh")) + "'," +
				"offapps='" + kiboo.checkNullString(d.get("coa2yh")) + "'," +
				"coa1='" + kiboo.checkNullString(d.get("coa1keyyh")) + "'," +
				"coa2='" + kiboo.checkNullString(d.get("coa2keyyh")) + "' " +
				"where origid=" + oid + ";";
		}
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
	}
}

// Log asset-record by LC no.
// 24/09/2014: 
void logAssetRecord(String ilc, String iass)
{
	//alert("lc: " + ilc + " :: asset: " + iass);
	Object[] inpflds = { m_asset_tag, m_brand, m_model, m_battery, m_hdd, m_hdd2, m_hdd3, m_hdd4,
	m_ram, m_ram2, m_ram3, m_ram4, m_gfxcard, m_mouse, m_keyboard, m_monitor, m_poweradaptor,
	coa1, coa2, coa3, coa4, m_misc, m_type, m_cust_location, osversion, offapps, m_serial_no
	};

	String[] hds = { "REPLACED: astg:", ", brnd:", ", mdel:", ", btry:", 
	", hdd1:", ", hdd2:", ", hdd3:", ", hdd4:", ", ram1:",", ram2:",", ram3:",", ram4:", ", gfxc:",
	", mse:", ", kyb:", ", moni:", ", pwra:", ", coa1:", ", coa2:", ", coa3:", ", coa4:", ", misc:",
	", tpe:", ", loc:", ", osv:", ", ofa:", ", snm:"
	};

	String[] inpdat = new String[inpflds.length];
	lgstr = "";

	// quite stupid hack here .. hahaha interpolate strings
	for(i=0;i<inpflds.length;i++)
	{
		if(inpflds[i] instanceof Textbox) inpdat[i] = kiboo.replaceSingleQuotes( inpflds[i].getValue().trim() );
		if(inpflds[i] instanceof Listbox) inpdat[i] = inpflds[i].getSelectedItem().getLabel();
		lgstr += hds[i] + inpdat[i];
	}

	prevass = currasst_lbl.getValue(); // get the previous asset-tag from popup
	lgstr += " FOR " + prevass;

	//alert(lgstr);
	//add_RWAuditLog(LC_PREFIX + ilc, inpdat[0], lgstr, useraccessobj.username);
}

// 24/09/2014: Replace asset audit-log - much simpler than logAssetRecord()
void replaceAssetAuditLog(String ilc, String iass)
{
	prevass = currasst_lbl.getValue(); // get the previous asset-tag from popup
	newass = kiboo.replaceSingleQuotes( r_asset_tag.getValue().trim() );
	repreason = kiboo.replaceSingleQuotes( repass_reason_tb.getValue().trim() );
	lgstr = "REPLACED: " + prevass + " TO " + newass + " (" + repreason + ")";
	add_RWAuditLog(LC_PREFIX + ilc, prevass, lgstr, useraccessobj.username);
}

// Do checks and so on to replace asset
/// TODO 13/01/2014: later put in all these checks. for now, free for all
void replaceLCAsset()
{
	if(glob_selected_ass.equals("")) return;
	replaceAssetAuditLog(glob_selected_lc,glob_selected_ass); // save existing asset-rec in audit-log

	Object[] inpflds =
	{ r_asset_tag, r_brand, r_model, r_battery, r_hdd, r_hdd2, r_hdd3, r_hdd4,
	r_ram, r_ram2, r_ram3, r_ram4, r_gfxcard, r_mouse, r_keyboard, r_monitor,
	r_coa1, r_coa2, r_coa3, r_coa4, r_osversion, r_offapps, r_misc,
	r_type, r_cust_location, r_poweradaptor, r_serial_no, r_do_no
	};

	dt = ngfun.getString_fromUI(inpflds);

	sqlstm = "update rw_lc_equips set asset_tag='" + dt[0] + "', brand='" + dt[1] + "', model='" + dt[2] +"'," +
	"battery='" + dt[3] + "', hdd='" + dt[4] + "', hdd2='" + dt[5] + "', hdd3='" + dt[6] + "', hdd4='" + dt[7] + "'," +
	"ram='" + dt[8] + "', ram2='" + dt[9] + "', ram3='" + dt[10] + "', ram4='" + dt[11] + "'," +
	"gfxcard='" + dt[12] + "', mouse='" + dt[13] + "', keyboard='" + dt[14] + "', monitor='" + dt[15] + "'," +
	"coa1='" + dt[16] + "', coa2='" + dt[17] + "', coa3='" + dt[18] + "', coa4='" + dt[19] + "'," +
	"osversion='" + dt[20] + "', offapps='" + dt[21] + "', remarks='" + dt[22] + "', type='" + dt[23] + "'," + 
	"cust_location='" + dt[24] + "', poweradaptor='" + dt[25] + "', serial_no='" + dt[26] + "', do_no='" + dt[27] + "' where origid=" + glob_selected_ass;

	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
/*
	// chk if to-be-replaced asset-tag exist
	rstkc = kiboo.replaceSingleQuotes(r_asset_tag.getValue().trim());
	tbr_ass = getStockItem_rec(rstkc);
	if(tbr_ass == null)
	{
		guihand.showMessageBox("Sorry, " + rstkc + " does not exist in the system..");
		return;
	}
	// chk to-be-replaced asset type, must be same as selected asset
	// TODO put in codes in rental_items.zul to set smd.item_type
	styp = m_type.getSelectedItem().getLabel();
	tbr_type = kiboo.checkNullString( tbr_ass.get("item_type") );
	if(!styp.equals(tbr_type))
	{
		guihand.showMessageBox("Problem, you're trying to replace an asset of type " + tbr_type + " to " + styp);
		return;
	}
	// check new-asset parts form
	// audit-log: current asset's record
	// save current-asset to gcn-transient (to collect back)
	// replace new asset's record - link to LC-id
*/
}

// Clear those fields in replace-asset popup
void clearReplaceAssetPopup()
{
	Object[] metaflds = {
	r_asset_tag, r_brand, r_model, r_cust_location, r_hdd, r_ram, r_hdd2, r_ram2,
	r_hdd3,r_ram3,r_hdd4,r_ram4,r_gfxcard,r_battery,r_mouse,r_keyboard,r_monitor,
	r_poweradaptor,r_coa1,r_coa3,r_coa2,r_coa4,r_misc,
	r_type,r_osversion,r_offapps, r_serial_no
	};

	ngfun.clearUI_Field(metaflds);
}

// Delete assets from LC, reset SMD.lc_id
void deleteLCAssets()
{
	asts = lcassets_lb.getSelectedItems().toArray();
	sels = iorig = "";

	for(i=0;i<asts.length;i++)
	{
		sels += "'" + lbhand.getListcellItemLabel(asts[i],0) + "',";
		iorig += lbhand.getListcellItemLabel(asts[i],ASSLB_ORIGID_IDX) + ",";
		lcassets_lb.removeChild(asts[i]);
	}

	try {
	sels = sels.substring(0,sels.length()-1);
	iorig = iorig.substring(0,iorig.length()-1);
	} catch (Exception e) {}

	sqlstm = "delete from rw_lc_equips where origid in (" + iorig + ");";
	sqlstm += "update stockmasterdetails set lc_id=null where stock_code in (" + sels + ");"; // null smd.lc_id for recs-sync
	sqlhand.gpSqlExecuter(sqlstm);
}

// iasid: rw_lc_equips.origid, iasstg: asset-tag
void bomDetailsToLC(String iasid, String iasstg)
{
	sqlstm = "select top 1 * from stockrentalitems_det where ltrim(rtrim(asset_tag)) = '" + iasstg + "' order by origid desc";
	mm = sqlhand.gpSqlFirstRow(sqlstm);
	if(mm == null) return;

	kt = "DT";
	if(mm.get("bomtype").equals("NOTEBOOK")) kt = "NB";
	if(mm.get("bomtype").equals("MONITOR")) kt = "MT";

	String[] brands = { "HP", "DELL", "ACER", "APPLE", "SAMSUNG", "ASUS", "LENOVO" };
	bnd = mdl = "";
	oo = kiboo.checkNullString(mm.get("description")).toUpperCase();

	for(i=0; i<brands.length; i++)
	{
		if(oo.indexOf(brands[i]) != -1)
		{
			mdl = (mm.get("description").replaceAll(brands[i],"")).trim();
			bnd = brands[i];
			break;
		}
	}

	sqlstm = "update rw_lc_equips set ram='" + kiboo.checkNullString(mm.get("ram")) +
	"', ram2='" + kiboo.checkNullString(mm.get("ram2")) +
	"', ram3='" + kiboo.checkNullString(mm.get("ram3")) +
	"', ram4='" + kiboo.checkNullString(mm.get("ram4")) +
	"', hdd='" + kiboo.checkNullString(mm.get("hdd")) +
	"', hdd2='" + kiboo.checkNullString(mm.get("hdd2")) +
	"', hdd3='" + kiboo.checkNullString(mm.get("hdd3")) +
	"', hdd4='" + kiboo.checkNullString(mm.get("hdd4")) +
	"', battery='" + kiboo.checkNullString(mm.get("battery")) +
	"', poweradaptor='" + kiboo.checkNullString(mm.get("poweradaptor")) +
	"', mouse='" + kiboo.checkNullString(mm.get("mouse")) +
	"', keyboard='" + kiboo.checkNullString(mm.get("keyboard")) +
	"', gfxcard='" + kiboo.checkNullString(mm.get("gfxcard")) +
	"', monitor='" + kiboo.checkNullString(mm.get("monitor")) +
	"', osversion='" + kiboo.checkNullString(mm.get("osversion")) +
	"', offapps='" + kiboo.checkNullString(mm.get("offapps")) +
	"', coa1='" + kiboo.checkNullString(mm.get("coa1")) +
	"', coa2='" + kiboo.checkNullString(mm.get("coa2")) +
	"', coa3='" + kiboo.checkNullString(mm.get("coa3")) +
	"', coa4='" + kiboo.checkNullString(mm.get("coa4")) +
	"', remarks='" + kiboo.checkNullString(mm.get("misc")) +
	"', model='" + mdl + "', brand='" + bnd + "'," +
	"type='" + kt + "' where origid=" + iasid;

	sqlhand.gpSqlExecuter(sqlstm);
	showAssetMetadata(iasid);
}

void impRWI_Extra()
{
	lcn = kiboo.replaceSingleQuotes(i_lc_no.getValue().trim());
	if(lcn.equals("")) return;
	//lcn = "RW" + lcn;

	sqlstm = "select d.bookno, c.name, r.rocnoyh, r.noofinstallmentyh, " +
	"convert(datetime, dbo.ConvertFocusDate(d.date_), 112) vdate, " +
	"r.ordertypeyh, r.remarksyh, r.insttypeyh, " +
	"(select sum(amount1) from data where voucherno='" + lcn + "' and vouchertype=3329) as contractamt, " +
	"convert(datetime, dbo.ConvertFocusDate(u.contractstartyh), 112) as cstart, " +
	"convert(datetime, dbo.ConvertFocusDate(u.contractendyh), 112) as cend, " +
	"case r.insttypeyh when 'monthly' then cast(round(u.totaldiffdaysyh/30,0) as int) else cast( (round(u.totaldiffdaysyh/30,0)/4) as int) end as rperiod " +
	"from data d " +
	"left join u011b u on u.extraid = d.extraoff " +
	"left join u001b r on r.extraid = d.extraheaderoff " +
	"left join mr000 c on c.masterid = d.bookno " +
	"where d.voucherno = '" + lcn + "' and d.vouchertype=3329;";

	drc = sqlhand.rws_gpSqlFirstRow(sqlstm);

	if(drc == null) return;

	String[] fl = { "name", "bookno", "cstart", "cend", "rocnoyh", "noofinstallmentyh",
	"remarksyh", "ordertypeyh", "insttypeyh", "contractamt", "vdate" };

	Object[] ob = { customername, l_fc6_custid, i_lstartdate, i_lenddate, i_rocno, i_period,
	i_remarks, i_order_type, i_inst_type, i_rm_contract, i_invoice_date };

	ngfun.populateUI_Data(ob,fl,drc);

	try {
	mrnt = drc.get("contractamt") / Integer.parseInt(drc.get("noofinstallmentyh"));
	i_rm_month.setValue(nf2.format(mrnt));
	} catch (Exception e) {}

	i_rwno.setValue(lcn);
	doFunc(updlcmeta_b);
}

Object[] rephds =
{
	new listboxHeaderWidthObj("Dated",true,""),
	new listboxHeaderWidthObj("DO",true,""),
	new listboxHeaderWidthObj("DO Item",true,""),
	new listboxHeaderWidthObj("Remarks",true,""),
	new listboxHeaderWidthObj("RMARef",true,""),
	new listboxHeaderWidthObj("Ass1",true,""),
	new listboxHeaderWidthObj("Ass2",true,""),
};

void checkRMA_Reps()
{
	atgs = "";
	lk = lcassets_lb.getItems().toArray();
	for(i=0; i<lk.length; i++)
	{
		otg = lbhand.getListcellItemLabel(lk[i],0);
		atgs += "di.remarksyh like '%" + otg + "%' or ";
	}

	try { atgs = atgs.substring(0,atgs.length()-3); } catch (Exception e) {}

	sqlstm = "select convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate," +
	"d.voucherno, i.name as do_item, di.remarksyh as repremarks, dio.referenceyh " +
	"from data d " +
	"left join u001c dio on dio.extraid = extraheaderoff " +
	"left join u011c di on di.extraid = d.extraoff " +
	"left join mr000 c on c.masterid = d.bookno " +
	"left join mr001 i on i.masterid = d.productcode " +
	"where d.vouchertype=6144 and d.productcode<>0 " +
	"and d.bookno=" + l_fc6_custid.getValue() +
	" and dio.referenceyh like 'RMA%' and (" + atgs + ")";

	// c.name as customer_name, 
	//alert(sqlstm);

	rcs = sqlhand.rws_gpSqlGetRows(sqlstm);

	if(rcs.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(rmarep_holder, rephds, "reprma_lb", 20);
	ArrayList kabom = new ArrayList();
	String[] fl = { "vdate", "voucherno", "do_item", "repremarks", "referenceyh" };
	Pattern pattern = Pattern.compile("([NAM])([0-9][0-9][0-9][0-9][0-9][0-9]?[0-9])");
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);

		ass1 = pattern.matcher(d.get("do_item"));
		if(ass1.find())
		{
			kabom.add( ass1.group(1) + ass1.group(2) );
		}

		ass2 = pattern.matcher(d.get("repremarks"));
		if(ass2.find())
		{
			kabom.add( ass2.group(1) + ass2.group(2) );
		}

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	showRMA_pop.open(chkrma_b);
}

void digAssets(Object ipo)
{
Object[] dahds =
{
	new listboxHeaderWidthObj("LC",true,""),
	new listboxHeaderWidthObj("Prev.LC",true,""),
	new listboxHeaderWidthObj("Customer",true,""),
};

	st = kiboo.replaceSingleQuotes( schasset_txt.getValue().trim() );
	if(st.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(dgass_holder, dahds, "digasst_lb", 10);
	sqlstm = "select lc.lc_id, lc.prev_lc, lc.customer_name from rw_lc_equips lci " +
	"left join rw_lc_records lc on lci.lc_parent = lc.origid where ltrim(rtrim(lci.asset_tag))='" + st + "' " +
	"order by cast(lc.lc_id as int);";

	drs = sqlhand.gpSqlGetRows(sqlstm);
	if(drs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.setMultiple(true);
	//newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new assClick());
	String[] fl = { "lc_id", "prev_lc", "customer_name" };
	ArrayList kabom = new ArrayList();
	for(d : drs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	digass_pop.open(ipo);
}

void drillFoundAssets()
{
	try { if(digasst_lb.getItemCount() == 0) return; } catch (Exception e) { return; }
	k = digasst_lb.getItems().toArray();
	mlc = "";
	for(i=0;i<k.length;i++)
	{
		mlc += "'" + lbhand.getListcellItemLabel(k[i],0) + "',";
	}
	try { mlc = mlc.substring(0,mlc.length()-1); } catch (Exception e) {}
	search_txt.setValue(mlc);
	digass_pop.close();
	listROCLC(4); // list LCs by what're found
}

void updManualGCN()
{
	ogn = kiboo.replaceSingleQuotes( oldgcnno_tb.getValue().trim() );
	if(ogn.equals("")) return;
	try { g = Integer.parseInt(ogn); } catch (Exception e) { guihand.showMessageBox("OLD GCN numbers only.."); return; }
	try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
	k = lcassets_lb.getSelectedItems().toArray();
	atgs = "";
	for(i=0; i<k.length; i++)
	{
		atgs += lbhand.getListcellItemLabel(k[i],ASSLB_ORIGID_IDX) + ","; // TODO HARDCODED list-item pos - chk contBill_assets.asslb_hds
	}
	try
	{
		atgs = atgs.substring(0,atgs.length()-1);
		sqlstm = "update rw_lc_equips set gcn_id=" + ogn + " where origid in (" + atgs + ")";
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
	}
	catch (Exception e) {}
}

void checkAssetDups()
{
	la = lcassets_lb.getItems().toArray();
	kh = new HashMap();
	for(i=0; i<la.length; i++)
	{
		atg = lbhand.getListcellItemLabel(la[i],0);
		if(kh.get(atg) == null) // no dups - add to hashmap
		{
			kh.put(atg,"1");
		}
		else
		{
			la[i].setStyle("background:#f57900");
		}
	}
}

// 04/04/2014: count no. of assets in LC .. insert no. into textbox
void countAssetsInsertBox()
{
	dtc = nbc = mtc = othc = swc = 0;
	if(lcassets_lb.getItemCount() == 0) return;
	ks = lcassets_lb.getItems().toArray();
	for(i=0; i<ks.length; i++)
	{
		tp = lbhand.getListcellItemLabel(ks[i],ASSLB_TYPE_IDX).trim();
		if(tp.equals("NB")) nbc++;
		else
		if(tp.equals("MT")) mtc++;
		else
		if(tp.equals("DT")) dtc++;
		else
		if(tp.equals("SW")) swc++;
		else
			othc++;
	}
	i_qty_dt.setValue(dtc.toString());
	i_qty_mt.setValue(mtc.toString());
	i_qty_nb.setValue(nbc.toString());
	i_qty_pt.setValue(othc.toString());
	i_qty_ms.setValue(swc.toString());
}

void massUpdateRental(String iwh)
{
	try { kk = Float.parseFloat(iwh); } catch (Exception e) { return; }
	try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
	mpf_pop.close();
	k = lcassets_lb.getSelectedItems().toArray();
	atgs = "";
	for(i=0; i<k.length; i++)
	{
		atgs += lbhand.getListcellItemLabel(k[i],ASSLB_ORIGID_IDX) + ","; // TODO HARDCODED list-item pos - chk contBill_assets.asslb_hds
	}
	try
	{
		atgs = atgs.substring(0,atgs.length()-1);
		sqlstm = "update rw_lc_equips set rm_month=" + iwh + " where origid in (" + atgs + ")";
		sqlhand.gpSqlExecuter(sqlstm);
		//showAssets(glob_selected_lc);
	}
	catch (Exception e) {}
	guihand.showMessageBox("Pufffff... monthly rental changed.");
}

// 12/06/2014: req by Nurul to update if asset billable -- special for MISC Berhad
// 16/06/2014: req by Nurul to have a BUYOUT flag
// itype: 1=billable, 2=buyout, 3=hotswap(10/09/2014 req by farah)
// 27/10/2014: itype: 4,5 = set asset assigned/unassigned
void updateAssetFlags(int itype)
{
	try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
	mpf_pop.close();
	k = lcassets_lb.getSelectedItems().toArray();
	atgs = msgtext = "";
	for(i=0; i<k.length; i++)
	{
		atgs += lbhand.getListcellItemLabel(k[i],ASSLB_ORIGID_IDX) + ",";
	}
	try
	{
		atgs = atgs.substring(0,atgs.length()-1);
		sqlstm = "update rw_lc_equips set ";
		flagstr = "";
		switch(itype)
		{
			case 1:
				flagstr = "billable=1-billable";
				msgtext = "Pufffff... billable flag toggled.";
				break;
			case 2:
				flagstr = "buyout=1-buyout";
				msgtext = "Piffff... BUYOUT flag toggled.";
				break;
				
			case 3:
				flagstr = "hotswap=1";
				msgtext = "Dussshhh.. HOTSWAP flag toggled.";
				break;
			case 6:
				flagstr = "hotswap=0";
				msgtext = "Dussshhh.. HOTSWAP flag toggled.";
				break;

			case 4: // assigned-flag
				flagstr = "assigned=1";
				msgtext = "Kapowww.. assigned-flag set";
				break;
			case 5: // unassigned flag
				flagstr = "assigned=0";
				msgtext = "Kadommm.. assigned-flag cleared";
				break;
		}

		sqlstm += flagstr + " where origid in (" + atgs + ")";
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
		guihand.showMessageBox(msgtext);
	}
	catch (Exception e) {}
}

// 24/09/2014: dig audit-logs - req by huiping
void digAuditLog(String iwhat)
{
Object[] dalhds =
{
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("LC",true,""),
	new listboxHeaderWidthObj("Dated",true,""),
	new listboxHeaderWidthObj("User",true,""),
	new listboxHeaderWidthObj("Audit notes",true,""),
};
	kk = kiboo.replaceSingleQuotes(iwhat);
	if(kk.equals("")) return;

	sqlstm = "select lcr.customer_name, lcr.lc_id, sdt.datecreated, sdt.audit_notes, sdt.username from rw_systemaudit sdt " +
	"left join rw_lc_records lcr on sdt.linking_code = 'LC'+ convert(varchar(20),lcr.origid) " +
	"where audit_notes like '%" + kk + "%' " +
	"order by sdt.datecreated desc";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(diglogs_holder, dalhds, "diglogs_lb", 20);
	ArrayList kabom = new ArrayList();
	String[] fl = { "customer_name", "lc_id", "datecreated", "username", "audit_notes" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}

}

