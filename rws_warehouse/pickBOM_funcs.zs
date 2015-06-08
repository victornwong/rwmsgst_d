import org.victor.*;

/*
Show BOMs to allow picking -- can be used in other mods - modi accordingly and remember the popups

<!-- BOM import popup -->
<popup id="bomimport_pop">
<div style="background:#f9b12d; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
	box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px">
	<hbox>
	<div>
		<label value="ASSIGN BOM to DO" style="font-weight:bold;font-size:14px" />
		<separator height="2px" />
		<div id="imp_boms_holder" width="680px" />
		<separator height="2px" />
		<hbox>
			<button id="assignbom_b" label="Assign BOM to DO" style="font-weight:bold" onClick="doFunc(self)" />
			<button label="View BOM details" style="font-size:9px;font-weight:bold" onClick="impViewBOMDetails()" />
			<button label="View job breakdown" style="font-size:9px" onClick="impBOM_viewJob()" />
		</hbox>
	</div>
<!--
	<div>
		<label id="impbomselected" value="BUILDS" style="font-weight:bold;font-size:14px" />
		<separator height="2px" />
		<div id="bitems_holder" width="350px" />
		<separator height="2px" />
	</div>
-->
	</hbox>
</div>
</popup> <!-- ENDOF bomimport_pop -->

*/

glob_sel_importbom = ""; // glob var for BOM selected
glob_sel_importbom_jobid = glob_sel_bom_customername = glob_sel_bom_doid = "";

/*
void showBOM_items(String ibid)
{
Object[] bitms_hds =
{
	new listboxHeaderWidthObj("###",true,"50px"),
	new listboxHeaderWidthObj("Type",true,"70px"),
	new listboxHeaderWidthObj("AssetTag",true,""),
};
	Listbox newlb = lbhand.makeVWListbox_Width(bitems_holder, bitms_hds, "bomitems_lb", 5);
	sqlstm = "select bomtype,asset_tag from stockrentalitems_det where parent_id=" + ibid;
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(10);
	newlb.setMold("paging");
	cnt = 1;
	for(dpi : rcs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add( cnt.toString() + "." );
		kabom.add(dpi.get("bomtype"));
		kabom.add( kiboo.checkNullString( dpi.get("asset_tag") ) );
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","font-weight:bold");
		cnt++;
	}
}
*/

class bomClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_importbom = lbhand.getListcellItemLabel(isel,0);
		glob_sel_bom_customername = lbhand.getListcellItemLabel(isel,1);
		glob_sel_importbom_jobid = lbhand.getListcellItemLabel(isel,3);
		glob_sel_bom_doid = lbhand.getListcellItemLabel(isel,5);
		//impbomselected.setValue("BOM" + glob_sel_importbom + " : BUILDS");
		//showBOM_items(glob_sel_importbom);
	}
}
bomldicker = new bomClick();

// TODO filter BOM by customer-name, so user can't import wrongly
void popImportBOM(Component iwhere)
{
Object[] boms_hds =
{
	new listboxHeaderWidthObj("BOM",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("JOB",true,"60px"),
	new listboxHeaderWidthObj("LC",true,"60px"),
	new listboxHeaderWidthObj("DO",true,"60px"),
};

	glob_sel_importbom = glob_sel_importbom_jobid = ""; // reset for new listbox
	//if(bitems_holder.getFellowIfAny("bomitems_lb") != null) bomitems_lb.setParent(null);

	Listbox newlb = lbhand.makeVWListbox_Width(imp_boms_holder, boms_hds, "boms_lb", 10);
	sqlstm = "select sri.origid,sri.customer_name,sri.job_id,sri.lc_id,sri.do_id," +
	"(select count(origid) from stockrentalitems_det where parent_id=sri.origid) as builds " +
	"from stockrentalitems sri where customer_name is not null and customer_name <> 'UNDEF'";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", bomldicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "customer_name", "builds", "job_id", "lc_id", "do_id" };
	for(dpi : recs)
	{
		popuListitems_Data(kabom,fl,dpi);
		/*
		kabom.add(dpi.get("origid").toString());
		kabom.add( kiboo.checkNullString(dpi.get("customer_name")) );
		kabom.add( dpi.get("builds").toString() );
		kabom.add( (dpi.get("job_id") == null) ? "" : dpi.get("job_id").toString() );
		kabom.add( (dpi.get("lc_id") == null) ? "" : dpi.get("lc_id").toString() );
		kabom.add( (dpi.get("do_id") == null) ? "" : dpi.get("do_id").toString() );
		*/
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}
	bomimport_pop.open(iwhere);
}

void impViewBOMDetails()
{
	if(glob_sel_importbom.equals("")) return;
	try {
	activateModule(mainPlayground,"workbox","rws_warehouse/showBOMWindow_v1.zul",kiboo.makeRandomId("vbm"),
	"bom=" + glob_sel_importbom, useraccessobj);
	} catch (Exception e) {}
}

// import-BOM related - open job-breakdown window
void impBOM_viewJob()
{
	if(glob_sel_importbom_jobid.equals("")) return;
	activateModule(mainPlayground,"workbox","rws_account/jobMaker_v1.zul",kiboo.makeRandomId("vbm"),
		"jb=" + glob_sel_importbom_jobid, useraccessobj);
}


