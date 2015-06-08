import org.victor.*;
// Internal tasks managmenet funcs
// Written by Victor Wong : 04/12/2013

glob_sel_inttask = ""; // glob internal-task selected
glob_sel_taskowner = "";

String JN_linkcode()
{
	return "";
}

void internaltask_callback() // def call-back - have to def in other mods which need this callback
{
}

Object[] inttskslb_hds =
{
	new listboxHeaderWidthObj("Tsk#",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Assigner",true,"80px"), // 2
	new listboxHeaderWidthObj("Assignee",true,"80px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Task",true,""),
	new listboxHeaderWidthObj("Action",true,""),
	new listboxHeaderWidthObj("A.Date",true,"65px"),
	new listboxHeaderWidthObj("Link",true,"70px"),
	new listboxHeaderWidthObj("Done",true,"35px"), // 9
};

class inttskclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
//class ctxopen implements org.zkoss.zk.ui.event.EventListener
		glob_sel_inttask = lbhand.getListcellItemLabel(isel,0);
		glob_sel_taskowner = lbhand.getListcellItemLabel(isel,2);
		kdn = lbhand.getListcellItemLabel(isel,9); // done flag

		if(isel.getFellowIfAny("intmytaskno_lbl") != null)
		{
			intmytaskno_lbl.setValue("Task# : " + glob_sel_inttask);
		}

		//intmytaskno_lbl.setValue("Task# : " + glob_sel_inttask);

		if(isel.getFellowIfAny("saveaction_b") != null)
		{
			saveaction_b.setDisabled( (kdn.equals("Y")) ? true : false);
		}
	}
}
inttaskclicker = new inttskclk();
inttask_lastdate = "";

// itype: 1=assigner tasks, 2=not-assigner tasks
void showInternalTasksList(int itype, String iassigner, String lnkcode, String istdate, Div idiv, String lbid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, inttskslb_hds, lbid, 12);
	inttask_lastdate = istdate;
	glob_sel_inttask = ""; // reset

	sqlstm = "select origid,assignee,assigner,datecreated,task,action,actiondate,done,priority,linking_code from rw_int_tasks ";
	switch(itype)
	{
		case 1:
			sqlstm += "where assigner='" + iassigner + "'";
			break;
		case 2:
			sqlstm += "where assignee='" + iassigner + "' and done=0 ";
			break;
	}
	
	lnkc = (lnkcode.equals("")) ? "" : " and linking_code='" + lnkcode + "' ";
	dtsq = (istdate.equals("")) ? "" : " and datecreated >= '" + istdate + "' ";

	sqlstm += lnkc + dtsq + " order by datecreated";
	
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", inttaskclicker );
	String[] fl = { "origid", "datecreated", "assigner", "assignee", "priority", "task", "action", "actiondate", "linking_code", "done" };
	ArrayList kabom = new ArrayList();
	for(d : recs)
	{
		popuListitems_Data(kabom,fl,d);
		prty = kiboo.checkNullString(d.get("priority"));
		/*
		kabom.add( d.get("origid").toString() );
		kabom.add( kiboo.checkNullDate(d.get("datecreated"),"") );
		kabom.add( kiboo.checkNullString(d.get("assigner")) );
		kabom.add( kiboo.checkNullString(d.get("assignee")) );
		kabom.add( prty );
		kabom.add( kiboo.checkNullString(d.get("task")) );
		kabom.add( kiboo.checkNullString(d.get("action")) );
		kabom.add( kiboo.checkNullDate(d.get("actiondate"),"") );
		kabom.add( kiboo.checkNullString(d.get("linking_code")) );
		kabom.add( (d.get("done") == null) ? "" : (d.get("done")) ? "Y" : "" );
		*/
		styl = "";
		if(prty.equals("URGENT")) styl = "font-size:9px;background:#f57900;color:#ffffff;font-weight:bold";
		if(prty.equals("CRITICAL")) styl = "font-size:9px;background:#ef2929;color:#ffffff;font-weight:bold";

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",styl);
		kabom.clear();
	}
}

// Can be used for other mods -- remember the popup
void internalTasksDo(Object iwhat)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh_byme = refresh_forme = docallback = false;
	sqlstm = msgtext = "";

	lnkc = "";
	try { lnkc = JN_linkcode(); } catch (Exception e) {}

	if(itype.equals("saveinttask_b"))
	{
		tsk = kiboo.replaceSingleQuotes(assignto_task.getValue().trim());
		asgnee = intassignto_lb.getSelectedItem().getLabel();
		if(tsk.equals("")) msgtext = "You have not enter anything for " + asgnee + " to do..";
		else
		{
			prty = inttaskprio_lb.getSelectedItem().getLabel();
			sqlstm = "insert into rw_int_tasks (assigner,assignee,task,datecreated,done,linking_code,priority) values " +
			"('" + useraccessobj.username + "','" + asgnee + "','" + tsk + "','" + todaydate + "',0,'" + lnkc + "'," +
			"'" + prty + "')";

			assignto_task.setValue("");
			msgtext = "Task assigned..";
			docallback = true;
		}
	}

	if(itype.equals("delinttask_b"))
	{
		if(glob_sel_inttask.equals("")) return;
		if (Messagebox.show("This will delete the internal-task..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		sqlstm = "delete from rw_int_tasks where origid=" + glob_sel_inttask;
		docallback = true;
	}

	if(itype.equals("clearinttask_b"))
	{
		intassignto_lb.setSelectedIndex(0);
		inttaskprio_lb.setSelectedIndex(0);
		assignto_task.setValue("");
	}

	if(itype.equals("settaskdone_b"))
	{
		if(glob_sel_inttask.equals("")) return;
		if(useraccessobj.accesslevel < 8 && !glob_sel_taskowner.equals(useraccessobj.username)) return;
		sqlstm = "update rw_int_tasks set done=1-done where origid=" + glob_sel_inttask;
		refresh_byme = true;
	}

	if(itype.equals("saveaction_b"))
	{
		if(glob_sel_inttask.equals("")) return;
		acts = kiboo.replaceSingleQuotes(inttask_action.getValue().trim());
		if(acts.equals("")) return;
		sqlstm = "update rw_int_tasks set action='" + acts + "', " +
		"actiondate='" + todaydate + "' where origid=" + glob_sel_inttask;
		msgtext = "Action posted..";
		inttask_action.setValue("");
		refresh_forme = true;
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm); // alert(sqlstm);
	if(refresh_byme) showInternalTasksList(1,useraccessobj.username, lnkc, "", tasksfromyou_holder, "asstasks_lb");
	if(refresh_forme) showInternalTasksList(2, useraccessobj.username, "", inttask_lastdate, tasksforyou_holder, "yourtasks_lb" );
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
	if(docallback) internaltask_callback();

}

// Inject task - general purpose , can be used by others
void injInternalTask(String iassner, String iassnee, String itask, String ilnc, String iprty)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = "insert into rw_int_tasks (assigner,assignee,task,datecreated,done,linking_code,priority) values (" +
	"'" + iassner + "','" + iassnee + "','" + itask + "','" + todaydate + "',0,'" + ilnc + "','" + iprty + "');";

	sqlhand.gpSqlExecuter(sqlstm);
}


