// Writte by Victor Wong
//--- Search contracts/assets stuff , can be used in other mods -- remember the popup

import org.victor.*;

// Show LC metadata in the popup ..
void showLC_searchMeta(Object rmr)
{
	if(rmr == null) { guihand.showMessageBox("Sorry.. cannot find LC"); return; }
	// remove prev grid and asset-LB
	if(lc_check_holder.getFellowIfAny("lcsearch_grid") != null) lcsearch_grid.setParent(null);
	if(lc_check_holder.getFellowIfAny("lcassets_lb") != null) lcassets_lb.setParent(null);
	
	//alert(rmr);

	Grid rgrid = new Grid();
	rgrid.setId("lcsearch_grid");
	mrows = gridhand.gridMakeRows("","",rgrid);

	prow = gridhand.gridMakeRow("","background:#d3d7cf","",mrows);
	gridhand.makeLabelToParent("LC No.", "font-size:9px",prow);
	gridhand.makeLabelToParent(rmr.get("lc_no").toString(), "font-size:12px",prow);
	gridhand.makeLabelToParent("Status", "font-size:9px",prow);

	lcst = rmr.get("lstatus").toUpperCase();
	mysty = "background:#4e9a06;color:#eeeeee";
	if(!lcst.equals("ACTIVE")) mysty = "background:#cc0000;color:#eeeeee";
	gridhand.makeLabelToParent(lcst, mysty,prow);

	gridhand.makeLabelToParent("Period", "font-size:9px",prow);
	gridhand.makeLabelToParent(rmr.get("period").toString(), "",prow);

	prow = gridhand.gridMakeRow("","background:#d3d7cf","",mrows);
	gridhand.makeLabelToParent("Start date", "font-size:9px",prow);
	gridhand.makeLabelToParent(kiboo.checkNullDate(rmr.get("lstartdate"),""), "font-size:12px",prow);
	gridhand.makeLabelToParent("End date", "font-size:9px",prow);
	gridhand.makeLabelToParent(kiboo.checkNullDate(rmr.get("lenddate"),""), "font-size:12px",prow);
	gridhand.makeLabelToParent("RW No.", "font-size:9px",prow);
	gridhand.makeLabelToParent( ((rmr.get("rwno") == null) ? "" : rmr.get("rwno").toString()), "",prow);

	prow = gridhand.gridMakeRow("","","1,6",mrows);
	gridhand.makeLabelToParent("Customer","",prow);
	gridhand.makeLabelToParent(kiboo.checkNullString(rmr.get("customer_name")),"font-size:12px",prow);

	prow = gridhand.gridMakeRow("","","1,6",mrows);
	gridhand.makeLabelToParent("Remarks", "font-size:9px",prow);
	gridhand.makeLabelMultilineToParent(kiboo.checkNullString(rmr.get("remarks")), "font-size:9px",prow);

	rgrid.setParent(lc_check_holder);
}

class assClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		selected_ass = lbhand.getListcellItemLabel(isel,0);

		arc = getLCAsset_rec(selected_ass);
		if(arc == null) return;
		i_asset_tag.setValue(kiboo.checkNullString(arc.get("asset_tag")));
		i_serial_no.setValue(kiboo.checkNullString(arc.get("serial_no")));
		i_type.setValue(kiboo.checkNullString(arc.get("type")));
		i_brand.setValue(kiboo.checkNullString(arc.get("brand")));
		i_model.setValue(kiboo.checkNullString(arc.get("model")));
		i_capacity.setValue(kiboo.checkNullString(arc.get("capacity")));
		i_color.setValue(kiboo.checkNullString(arc.get("color")));
		i_coa.setValue(kiboo.checkNullString(arc.get("coa")));
		i_ram.setValue(kiboo.checkNullString(arc.get("ram")));
		i_hdd.setValue(kiboo.checkNullString(arc.get("hdd")));
		i_others.setValue(kiboo.checkNullString(arc.get("others")));
		i_location.setValue(kiboo.checkNullString(arc.get("location")));

		SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd");

		i_replacement.setValue(kiboo.checkNullString(arc.get("replacement")));
		repdt = (arc.get("replacement_date") == null) ? "" : dtf.format(arc.get("replacement_date"));
		i_replacement_date.setValue(repdt);

		coll = (arc.get("collected") == null) ? "NO" : ((arc.get("collected") == 1) ? "YES" : "NO");
		lbhand.matchListboxItems(i_collected,coll);
		i_ass_remarks.setValue(kiboo.checkNullString(arc.get("remarks")));

		asset_metagrid.setVisible(true);
	}
}

Object[] asslb_hds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("SerialNo",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Notes",true,""),
};

void showLC_searchEquips(Object ircs)
{
	if(ircs.size() == 0) return;

	Listbox newlb = lbhand.makeVWListbox_Width(lc_check_holder, asslb_hds, "lcassets_lb", 18);
	newlb.addEventListener("onSelect", new assClick());
	newlb.setMold("paging");

	for(dpi : ircs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		kabom.add(kiboo.checkNullString(dpi.get("asset_tag")));
		kabom.add(kiboo.checkNullString(dpi.get("serial_no")));
		kabom.add(kiboo.checkNullString(dpi.get("type")));
		kabom.add(kiboo.checkNullString(dpi.get("brand")));
		kabom.add(kiboo.checkNullString(dpi.get("model")));
		kabom.add(kiboo.checkNullString(dpi.get("location")));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
}

// itype: 1=by lc_no, 2=by asset-tag
void searchLC(int itype)
{
	lcno = kiboo.replaceSingleQuotes(lc_lc_no.getValue().trim());
	asst = kiboo.replaceSingleQuotes(lc_asset_tag.getValue().trim()).toUpperCase();
	snm = kiboo.replaceSingleQuotes(lc_serial_no.getValue().trim()).toUpperCase();

	sqlstm = "";
	lchsql = "select top 1 lc.origid as lc_no, lc.rwno, lc.customer_name, lc.lstartdate, lc.lenddate, " + 
		"lc.period, lc.lstatus, lc.remarks from rw_leasingcontract lc ";
	lcfsql = " order by lc.lstartdate desc";

	if(itype == 1 && !lcno.equals("")) // by lc_no
	{
		sqlstm = lchsql + "where lc.origid=" + lcno + lcfsql;
		lcr = sqlhand.gpSqlFirstRow(sqlstm);
		showLC_searchMeta(lcr);

		lc_asset_tag.setValue(""); // avoid user confusion
	}

	if(itype == 2 && !asst.equals("")) // by asset_tag
	{
		sqlstm = lchsql + "left join rw_leaseequipments lce on lce.lc_parent = lc.origid " +
		"where lce.asset_tag='" + asst + "' " + lcfsql;
		lcr = sqlhand.gpSqlFirstRow(sqlstm);
		showLC_searchMeta(lcr);

		lcno = "";
		if(lcr != null) lcno = lcr.get("lc_no").toString(); // use below to show assets in the LC

		lc_lc_no.setValue(""); // avoid user confusion
	}

	if(itype == 3 && !snm.equals("")) // by s/num
	{
		sqlstm = lchsql + "left join rw_leaseequipments lce on lce.lc_parent = lc.origid " +
		"where lce.serial_no='" + snm + "' " + lcfsql;
		lcr = sqlhand.gpSqlFirstRow(sqlstm);
		showLC_searchMeta(lcr);

		lcno = "";
		if(lcr != null) lcno = lcr.get("lc_no").toString(); // use below to show assets in the LC

		lc_lc_no.setValue(""); // avoid user confusion
		lc_asset_tag.setValue("");
	}

	if(!lcno.equals(""))
	{
		// stuff in LC
		sqlstm = "select lce.origid,lce.asset_tag, lce.serial_no, lce.type,lce.brand,lce.model,lce.location from rw_leaseequipments lce " +
		"where lce.lc_parent=" + lcno + " order by lce.asset_tag";

		lces = sqlhand.gpSqlGetRows(sqlstm);
		asset_metagrid.setVisible(false);
		showLC_searchEquips(lces);

		if(itype == 2) // if search by asset-tag
		{
			mtli = lbhand.matchListboxReturnListItem(lcassets_lb, asst, 1);
			mtli.setStyle("background:#3465a4;color:#eeeeee");
		}
		
		if(itype == 3) // hilite by s/num
		{
			mtli = lbhand.matchListboxReturnListItem(lcassets_lb, snm, 2);
			mtli.setStyle("background:#3465a4;color:#eeeeee");
		}
	}
}
//--- ENDOF Search contracts/assets stuff , can be used in other mods -- remember the popup

