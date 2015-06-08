import org.victor.*;

/*
Import pick-list funcs - can be used in other mods

<!-- Pick-List import popup -->
<popup id="plimport_pop">
<div style="background:#f9b12d; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
	box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px">

<div id="imp_picklist_holder" width="600px" />
<separator height="2px" />
<button id="importppl_b" label="Assign pick-list to DO" style="font-weight:bold" onClick="doFunc(self)" />
<button label="View pick-list details" style="font-size:9px;font-weight:bold" onClick="impViewPickListDetails()" />

</div>
</popup> <!-- ENDOF plimport_pop -->

*/

glob_sel_imp_picklist = glob_sel_imppl_customername = "";
glob_sel_imppl_doid = glob_sel_imppl_jobid = "";

class pplClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_imp_picklist = lbhand.getListcellItemLabel(isel,0);
		glob_sel_imppl_customername = lbhand.getListcellItemLabel(isel,2);
		glob_sel_imppl_jobid = lbhand.getListcellItemLabel(isel,3);
		glob_sel_imppl_doid = lbhand.getListcellItemLabel(isel,4);

		//impbomselected.setValue("BOM" + glob_sel_importbom + " : BUILDS");
		//showBOM_items(glob_sel_importbom);
	}
}
npplcliker = new pplClick();

void popImportPickList(Component iwhere)
{
Object[] plist_hds =
{
	new listboxHeaderWidthObj("PPL",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("JOB",true,"60px"),
	new listboxHeaderWidthObj("DO",true,"60px"),
};
	if(iwhere == null) return;

	glob_sel_imp_picklist = ""; // reset for new listbox
	glob_sel_imppl_jobid = "";

	Listbox newlb = lbhand.makeVWListbox_Width(imp_picklist_holder, plist_hds, "picklist_lb", 10);
	// TODO chk picklist stat
	sqlstm = "select origid,customer_name,datecreated,job_id,do_id from rw_pickpack where customer_name <> 'UNDEF'";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", npplcliker);
	ArrayList kabom = new ArrayList();
	for(dpi : recs)
	{
		kabom.add(dpi.get("origid").toString());
		kabom.add( dtf2.format(dpi.get("datecreated")) );
		kabom.add( kiboo.checkNullString(dpi.get("customer_name")) );
		kabom.add( (dpi.get("job_id") == null) ? "" : dpi.get("job_id").toString() );
		kabom.add( (dpi.get("do_id") == null) ? "" : dpi.get("do_id").toString() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}
	plimport_pop.open(iwhere);
}

// Open view pick-list window - uses glob_sel_imp_picklist
void impViewPickListDetails()
{
	if(glob_sel_imp_picklist.equals("")) return;
	try {
	activateModule(mainPlayground,"workbox","rws_warehouse/showPickListWindow_v1.zul",kiboo.makeRandomId("vpl"),
	"ppl=" + glob_sel_imp_picklist, useraccessobj);
	} catch (Exception e) {}
}

void impPickList_viewJob()
{
	if(glob_sel_imppl_jobid.equals("")) return;
	activateModule(mainPlayground,"workbox","rws_account/jobMaker_v1.zul",kiboo.makeRandomId("vbm"),
		"jb=" + glob_sel_imppl_jobid, useraccessobj);
}

