import org.victor.*;

// supporting funcs for contractAssetman_v1.zul

void populateLCStatus_dd(Object iwhat)
{
	sqlstm = "select distinct lstatus from rw_leasingcontract order by lstatus";
	lcs = sqlhand.gpSqlGetRows(sqlstm);
	if(lcs.size() == 0) return;
	for(dpi : lcs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("lstatus"));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(iwhat,strarray,"false","");
	}
	iwhat.setSelectedIndex(0);
}

// chk if asset already in LC - dups-check. Return LC-id
String assetExistInLC(String iastg)
{
	retv = "";
	sqlstm = "select lc_parent from rw_leaseequipments where asset_tag='" + iastg + "' order by lc_parent desc";
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

/*
i_asset_tag i_serial_no i_type i_brand i_model i_capacity i_color i_coa i_ram
i_hdd i_other i_location i_collected i_ass_remarks
*/
// NOTE: remarks and others swapped because imported recs are screwed
void showAssetMetadata(String iwhat)
{
	arc = getLCAsset_rec(iwhat);
	if(arc == null) return;

	String[] flds = {
	"asset_tag","serial_no","type","brand","model","capacity","color","coa",
	"ram","hdd","others","location","remarks" };

	Object[] cmps = {
	i_asset_tag,i_serial_no,i_type,i_brand,i_model,i_capacity,i_color,i_coa,
	i_ram,i_hdd,i_others,i_location,i_ass_remarks };

	for(i=0;i<flds.length;i++)
	{
		cmps[i].setValue( kiboo.checkNullString(arc.get(flds[i])) );
	}

	coll = (arc.get("collected") == null) ? "NO" : ((arc.get("collected") == 1) ? "YES" : "NO");
	lbhand.matchListboxItems(i_collected,coll);

	i_bom_id.setValue( (arc.get("bom_id") == null) ? "" : arc.get("bom_id").toString() );
}

Object[] asslb_hds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("SerialNo",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Remarks",true,""),
};

class assClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		doFunc(updass_b); // update prev asset meta if any

		isel = event.getReference();
		glob_selected_ass_li = isel;
		glob_selected_ass = lbhand.getListcellItemLabel(isel,0);
		glob_selected_asstag = lbhand.getListcellItemLabel(isel,1);
		showAssetMetadata(glob_selected_ass);
		assetworkarea.setVisible(true);
		asset_metagrid.setVisible(true);
	}
}

void showAssets(String iwhat)
{
	Listbox newlb = lbhand.makeVWListbox_Width(lcasset_holder, asslb_hds, "lcassets_lb", 20);
	//lc_assetsfound_lbl.setValue("");

	sqlstm = "select origid,asset_tag,serial_no,type,brand,model,remarks from rw_leaseequipments " +
	"where lc_parent=" + iwhat;

	asrs = sqlhand.gpSqlGetRows(sqlstm);
	if(asrs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", new assClick());

	for(dpi : asrs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		kabom.add(kiboo.checkNullString(dpi.get("asset_tag")));
		kabom.add(kiboo.checkNullString(dpi.get("serial_no")));
		kabom.add(kiboo.checkNullString(dpi.get("type")));
		kabom.add(kiboo.checkNullString(dpi.get("brand")));
		kabom.add(kiboo.checkNullString(dpi.get("model")));
		krem = kiboo.checkNullString(dpi.get("remarks"));
		if(krem.length() > 40) krem = krem.substring(0,40) + "..";
		kabom.add(krem);
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
	//updateFoundStuff_labels(lc_assetsfound_lbl,lcassets_lb, " asset/item(s) found");
	glob_selected_ass = ""; // reset
	assetworkarea.setVisible(false);
}

/*
i_lc_no l_fc6_custid i_customer_name i_lstartdate i_lenddate i_period i_lstatus
i_remarks i_rm_month i_rm_contract
*/
void showLCMetadata(String iwhat)
{
	lcr = getLC_rec(iwhat);
	if(lcr == null) { guihand.showMessageBox("DBERR: cannot access LC table"); return; }

	i_lc_no.setValue(lcr.get("origid").toString());
	l_fc6_custid.setValue(kiboo.checkNullString(lcr.get("fc6_custid")));
	customername.setValue(kiboo.checkNullString(lcr.get("customer_name"))); // customername updated in fc6_customerselector.zs
	i_lstartdate.setValue(lcr.get("lstartdate"));
	i_lenddate.setValue(lcr.get("lenddate"));
	i_period.setValue(lcr.get("period").toString());
	lbhand.matchListboxItems(i_lstatus,kiboo.checkNullString(lcr.get("lstatus")));
	i_remarks.setValue(kiboo.checkNullString(lcr.get("remarks")));
	i_rm_month.setValue(nf2.format(lcr.get("RM_Month")));
	i_rm_contract.setValue(nf2.format(lcr.get("RM_Contract")));

	fillDocumentsList(documents_holder,LC_PREFIX,iwhat);
	assetworkarea.setVisible(false);

	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	jobnotes_div.setVisible(true);
}

Object[] lclb_hds =
{
	new listboxHeaderWidthObj("LC#",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("A.Qty",true,"50px"),
	new listboxHeaderWidthObj("Period",true,"60px"),
	new listboxHeaderWidthObj("S.Date",true,"60px"),
	new listboxHeaderWidthObj("E.Date",true,"60px"),
	new listboxHeaderWidthObj("Status",true,"60px"),
};

class lclbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		//doFunc(updlc_b); // update prev LC meta if any

		isel = event.getReference();
		glob_selected_lc_li = isel;
		glob_selected_lc = lbhand.getListcellItemLabel(isel,0);
		showLCMetadata(glob_selected_lc);
		showAssets(glob_selected_lc);
		lcworkarea.setVisible(true);
		lc_metagrid.setVisible(true);
	}
}

// itype: 1=by lc_status, 2=by customer/search box, 3=by lc_no
void showLC(int itype)
{
	Listbox newlb = lbhand.makeVWListbox_Width(lc_holder, lclb_hds, "lc_lb", 20);
	lc_found_lbl.setValue("");

	lstat = s_lcstatus.getSelectedItem().getLabel();
	scht = kiboo.replaceSingleQuotes(s_customer_tb.getValue()).trim();
	lcno = kiboo.replaceSingleQuotes(s_lcno_tb.getValue()).trim();
	syer = s_limit_start.getSelectedItem().getLabel();
	eyer = s_limit_end.getSelectedItem().getLabel();

	sqlstm = "select lc.origid,lc.customer_name,lc.period,lc.lstartdate,lc.lenddate,lc.lstatus," +
	"(select count(origid) from rw_leaseequipments where lc_parent=lc.origid) as aqty " +
	"from rw_leasingcontract lc where ";

	last_lc_loadtype = itype;

	switch(itype)
	{
		case 1:
			sqlstm += "	lstatus='" + lstat + "' " +
			"and lstartdate >= '" + syer + "-01-01' and lenddate <= '" + eyer + "-12-31'";
			break;

		case 2:
			if(scht.equals("")) return;
			sqlstm += " customer_name like '%" + scht + "%' ";
			break;

		case 3:
			if(lcno.equals("")) return;
			sqlstm += " origid=" + lcno;
			break;
	}

	sqlstm += " and (deleted=0 or deleted is null) order by origid";

	lcrecs = sqlhand.gpSqlGetRows(sqlstm);
	if(lcrecs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", new lclbClick());

	for(dpi : lcrecs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());

		custn = kiboo.checkNullString(dpi.get("customer_name"));
		if(custn.length() > 48) custn = custn.substring(0,48) + "...";
		kabom.add(custn);

		kabom.add(dpi.get("aqty").toString());
		kabom.add( (dpi.get("period") == null) ? "" : dpi.get("period").toString() );
		kabom.add( kiboo.checkNullDate(dpi.get("lstartdate"),"") );
		kabom.add( kiboo.checkNullDate(dpi.get("lenddate"),"") );
		kabom.add(kiboo.checkNullString(dpi.get("lstatus")));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}

	//updateFoundStuff_labels(lc_found_lbl,lc_lb," LC(s) found");
}

// Faster to update only changed list-item instead of relisting -- can do this for other mods
void updateLC_li(Object ilit, String ilcid)
{
	sqlstm = "select lc.customer_name,lc.period,lc.lstartdate,lc.lenddate,lc.lstatus," +
	"(select count(origid) from rw_leaseequipments where lc_parent=lc.origid) as aqty " +
	"from rw_leasingcontract lc where origid=" + ilcid;

	lcr = sqlhand.gpSqlFirstRow(sqlstm);
	if(lcr == null) return;
	
	custn = kiboo.checkNullString(lcr.get("customer_name"));
	if(custn.length() > 48) custn = custn.substring(0,48) + "...";

	lbhand.setListcellItemLabel(ilit,1,custn);
	lbhand.setListcellItemLabel(ilit,2,lcr.get("aqty").toString());
	lbhand.setListcellItemLabel(ilit,3,lcr.get("period").toString());
	lbhand.setListcellItemLabel(ilit,4,lcr.get("lstartdate").toString().substring(0,10));
	lbhand.setListcellItemLabel(ilit,5,lcr.get("lenddate").toString().substring(0,10));
	lbhand.setListcellItemLabel(ilit,6,lcr.get("lstatus"));
}

void updateAsset_li(Object ilit, String iassid)
{
	sqlstm = "select asset_tag,serial_no,type,brand,model,remarks from rw_leaseequipments " +
	"where origid=" + iassid;
	acr = sqlhand.gpSqlFirstRow(sqlstm);
	if(acr == null) return;
	lbhand.setListcellItemLabel(ilit,1,acr.get("asset_tag"));
	lbhand.setListcellItemLabel(ilit,2,acr.get("serial_no"));
	lbhand.setListcellItemLabel(ilit,3,acr.get("type"));
	lbhand.setListcellItemLabel(ilit,4,acr.get("brand"));
	lbhand.setListcellItemLabel(ilit,5,acr.get("model"));

	krem = kiboo.checkNullString(acr.get("remarks"));
	if(krem.length() > 40) krem = krem.substring(0,40) + "..";
	lbhand.setListcellItemLabel(ilit,6,krem);
}



