import org.victor.*;
// Job-ID assignment related funcs

sel_assign_job = sel_assign_rocid = ""; // global set by jobClick.onClick

// knockoff from jobMaker_funcs.zs
void checkMakeItemsGrid(Div iholder, String igid, String irowsid)
{
	String[] colws = { "35px","","60px","60px" };
	String[] colls = { "No." ,"Item description","Color","Qty" };

	oldg = iholder.getFellowIfAny(igid);

	if(oldg == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId(igid);
		//igrd.setWidth("800px");

		icols = new org.zkoss.zul.Columns();
		for(i=0;i<colws.length;i++)
		{
			ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(colws[i]);
			ico0.setLabel(colls[i]);
			if(i > 1) ico0.setAlign("center");
			ico0.setStyle("background:#97b83a");
			ico0.setParent(icols);
		}

		icols.setParent(igrd);

		irows = new org.zkoss.zul.Rows();
		irows.setId(irowsid);
		irows.setParent(igrd);
		igrd.setParent(iholder);
	}
}

// knockoff from jobMaker_funcs.zs - modded
void showJobItems(Object tjrc, Div iholder, String igid, String irowsid)
{
	oldg = iholder.getFellowIfAny(igid);
	if(oldg != null) oldg.setParent(null);

	glob_icomponents_counter = 1; // reset for new grid
	if(tjrc.get("items") == null) return; // nothing to show

	checkMakeItemsGrid(iholder,igid,irowsid);

	items = sqlhand.clobToString(tjrc.get("items")).split("::");
	qtys = tjrc.get("qtys").split("::");
	colors = tjrc.get("colors").split("::");
	prows = iholder.getFellowIfAny(irowsid);

	for(i=0;i<items.length;i++)
	{
		cmid = glob_icomponents_counter.toString();
		irow = gridhand.gridMakeRow("","","",prows);
		gpMakeLabel(irow, "", cmid + ".", "font-size:14px;font-weight:bold" );
		soms = "";
		try { soms = items[i]; } catch (Exception e) {}
		dk = gpMakeLabel(irow, "", soms, "font-size:9px;font-weight:bold;" );
		dk.setMultiline(true);
		soms = "";
		try { soms = colors[i]; } catch (Exception e) {}
		gpMakeLabel(irow, "", soms, "font-weight:bold;" );
		soms = "";
		try { soms = qtys[i]; } catch (Exception e) {}
		gpMakeLabel(irow, "", soms, "font-weight:bold;" );
		glob_icomponents_counter++;
	}
}

Object[] jobslb_headers = 
{
	new listboxHeaderWidthObj("JOB",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("User",true,""),
	new listboxHeaderWidthObj("Type",true,"60px"),
	new listboxHeaderWidthObj("ROC.No",true,"80px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
};

class jobClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		sel_assign_job = lbhand.getListcellItemLabel(isel,0);
		sel_assign_rocid = lbhand.getListcellItemLabel(isel,4); // 07/07/2014: save ROC.no for later use
		jrec = getRWJob_rec(sel_assign_job);
		if(jrec != null) showJobItems(jrec,jobitems_holder,"jobitems_grid","jobitems_rows"); // jobitems_holder def in popup
	}
}
joblcioekr = new jobClick();
// Show approved and pickup jobs by customer(def in BOM)
// iexjob: existing job-id assigned, will exclude from jobs-list
void showLinkJobs(Object iwhat, String iexjob)
{
	//if(global_selected_bom.equals("")) return;
	if(global_selected_customer.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(jobs_holder, jobslb_headers, "jobs_lb", 5);
	linkjob_header.setValue(global_selected_customer + "\nUnassigned jobs");

	excs = "";
	if(!iexjob.equals("")) excs = " and origid<>" + iexjob;
/*
	sqlstm = "select origid,datecreated,username,jobtype,priority,rwroc from rw_jobs " +
	"where customer_name='" + global_selected_customer + "' and status='WIP' and approve=1 " + excs;
*/
	sqlstm = "select origid,datecreated,username,jobtype,priority,rwroc from rw_jobs " +
	"where customer_name='" + global_selected_customer + "' " + excs;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(21);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", joblcioekr);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "username", "jobtype", "rwroc", "priority" };
	for(dpi : screcs)
	{
		popuListitems_Data(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold;font-size:9px");
		kabom.clear();
	}
	if(jobitems_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	linkjobs_pop.open(iwhat);
}

Object[] jobsalllb_headers = 
{
	new listboxHeaderWidthObj("JOB",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,""),
	new listboxHeaderWidthObj("Type",true,"60px"),
	new listboxHeaderWidthObj("ROC.No",true,"80px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
};

// Knock-off from showLinkJobs() -- this one will show all jobs (TODO limit to show last 7days jobs or 14days)
void showLinkJobsAll(Object iwhat, String iexjob)
{
	//if(global_selected_bom.equals("")) return;
	if(global_selected_customer.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(jobs_holder, jobsalllb_headers, "jobs_lb", 5);
	linkjob_header.setValue(global_selected_customer + "\nUnassigned jobs");

	excs = "";
	if(!iexjob.equals("")) excs = " where origid<>" + iexjob;

	sqlstm = "select origid,datecreated,username,jobtype,priority,customer_name,rwroc from rw_jobs " + excs;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.addEventListener("onSelect", joblcioekr);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "customer_name", "username", "jobtype", "rwroc", "priority" };
	for(dpi : screcs)
	{
		ngfun.popuListitems_Data(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}
	if(jobitems_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	linkjobs_pop.open(iwhat);
}

// chg job-id var for other mod
void viewJobWindow(String ijid, Component ipanel)
{
	if(ijid.equals(""))
	{
		vj_jobid_label.setValue("NOTHING TO SHOW");
		if(vj_jobitems_holder.getFellowIfAny("vjobitems_grid") != null) vjobitems_grid.setParent(null);
		return;
	}
	if(ipanel !=  null) ipanel.setOpen(false);
	activateModule(mainPlayground,"workbox","rws_account/jobMaker_v1.zul",kiboo.makeRandomId("vbm"),
	"jb=" + ijid, useraccessobj);
}

void viewJobWindow_2(String ijid, Component ipanel)
{
	if(ijid.equals(""))
	{
		vj_jobid_label.setValue("NOTHING TO SHOW");
		if(vj_jobitems_holder.getFellowIfAny("vjobitems_grid") != null) vjobitems_grid.setParent(null);
		return;
	}
	if(ipanel !=  null) ipanel.setOpen(false);
	activateModule(mainPlayground,"workbox","rws_account/jobMaker_v2.zul",kiboo.makeRandomId("vbm"),
	"jb=" + ijid, useraccessobj);
}

