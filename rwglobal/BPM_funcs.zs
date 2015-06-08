import java.util.*;
import java.text.*;
import java.lang.*;
import groovy.sql.Sql;
import org.zkoss.zul.*;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import org.victor.*;
/*
Written by Victor Wong
BPM actions related funcs, can be used in other mods - modi required probably.
sample DIV to include into other mods

<div style="background:#555753; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px" >
	<div style="background:#555753;padding:2px">
		<label value="JOB APPROVAL" sclass="subhead1" />
		<button label="Logs" style="font-size:9px" onClick="viewBPM_logs(JOBS_PREFIX + glob_sel_job, self)" />
	</div>
	<div id="approvers_box" />
</div>
*/

// toggle 'em BPM related buttons
void BPM_toggleButts(boolean iwhat, Div iholder)
{
	if(iholder.getFellowIfAny("app_grid") != null)
	{
		cbs = app_grid.getFellows();
		for(di : cbs)
		{
			kid = di.getId();
			kid = kid.substring(0,3);
			if(kid.equals("APP") || kid.equals("DAP")) di.setDisabled(iwhat);
		}
	}
}

// Check if user can do BPM buttons. Hardcoded RENTWISE users lookup: CC_APPROVER_USER , ACCT_APPROVER_USER
void BPM_checkUserAccess(Div iholder, String iusername)
{
	cando = true;
	if(sechand.allowedUser(iusername,"CC_APPROVER_USER")) cando = false;
	if(sechand.allowedUser(iusername,"ACCT_APPROVER_USER")) cando = false;
	BPM_toggleButts(cando,iholder);
}

// count BPM-actions and APPROVED, if equ, return true
boolean checkBPM_fullapproval(String ilnkc)
{
	retv = false;
	sqlstm = "select count(origid) as bpcount, " +
	"(select count(origid) from bpm_actions where assigner='" + ilnkc + "' and actionstatus='APPROVE') as appcount " +
	"from bpm_actions where assigner='" + ilnkc + "'";

	krr = sqlhand.gpSqlFirstRow(sqlstm);
	if(krr != null)
	{
		if((int)krr.get("bpcount") == (int)krr.get("appcount")) retv = true;
		if((int)krr.get("bpcount") == 0) retv = false; // no BPM-actions found
	}
	//alert(sqlstm + " " + krr + " " + retv);
	return retv;
}

// Check if a set of BPMs got any disapproval
boolean checkBPM_gotDisapproval(String ilnkc)
{
	retv = false;
	sqlstm = "select top 1 origid from bpm_actions where assigner='" + ilnkc + "' and actionstatus='DISAPPROVE'";
	krr = sqlhand.gpSqlFirstRow(sqlstm);
	if(krr != null)
	{
		if(krr.get("origid") != null) retv = true;
	}
	return retv;
}

// bpm_actions.field1 = approver group, field2 = jobtype
// ijob = linking-code for a BPM rec
void injectApprovers(String lnkc, String ijobtype)
{
	sqlstm = "";

	if(ijobtype.equals("UNDEF")) // if job-type set to undef, remove all BPM-actions if any
	{
		sqlstm = "delete from bpm_actions where assigner='" + lnkc +"';";
	}
	else
	{
		todaydate =  kiboo.todayISODateTimeString();
		sqlstm = "select top 1 origid from bpm_actions where assigner='" + lnkc + "' and field2='" + ijobtype + "'";
		crk = sqlhand.gpSqlFirstRow(sqlstm);
		if(crk == null) // if no approvers in bpm_actions for this jobtype, do new one
		{
			// remove all previous ones in-case any
			sqlstm = "delete from bpm_actions where assigner='" + lnkc + "';";
		
			// TODO customize here to inject how type/how-many approvers
			//if(ijobtype.equals("ROC"))

			if(!ijobtype.equals("PR"))
				sqlstm += "insert into bpm_actions (assigner,datecreated,actiontype,field1,field2) values " +
				"('" + lnkc + "','" + todaydate + "','APPROVAL','CC','" + ijobtype + "');";

			if(ijobtype.equals("SO"))
				sqlstm += "insert into bpm_actions (assigner,datecreated,actiontype,field1,field2) values " +
				"('" + lnkc + "','" + todaydate + "','APPROVAL','SALES','" + ijobtype + "');";

			if(ijobtype.equals("PR"))
			{
				sqlstm += "insert into bpm_actions (assigner,datecreated,actiontype,field1,field2) values " +
				"('" + lnkc + "','" + todaydate + "','APPROVAL','VERF_PM_GM','" + ijobtype + "');";

				sqlstm += "insert into bpm_actions (assigner,datecreated,actiontype,field1,field2) values " +
				"('" + lnkc + "','" + todaydate + "','APPROVAL','APP1_GM_FC_CEO','" + ijobtype + "');";
/*
				sqlstm += "insert into bpm_actions (assigner,datecreated,actiontype,field1,field2) values " +
				"('" + lnkc + "','" + todaydate + "','APPROVAL','APP2_FC_CEO','" + ijobtype + "');";
*/
			}
				
		}
	}
	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
}

// iades: approver-decision
void BPM_updateRec(String ibid, String iuser, String icomment, String isubtype, String iades, String ilnkc)
{
	todaydate =  kiboo.todayISODateTimeString();
	cmt = kiboo.replaceSingleQuotes( icomment.trim() );

	sqlstm = "update bpm_actions set assignee='" + iuser + "',notes='" + cmt + "'," +
	"actiondate='" + todaydate + "', actionstatus='" + iades + "' where origid=" + ibid;
	sqlhand.gpSqlExecuter(sqlstm);

	add_RWAuditLog(ilnkc,"BPM"+ibid, isubtype + " " + iades + ": " + cmt, iuser); // audit-log
}

class bpm_approverClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		bid = event.getTarget().getId();

		spl = bid.split("_"); // split comp-ID, first part the button_id and 2nd = bpm linking-code

		bty = spl[0].substring(0,3);
		bid = spl[0].substring(3,spl[0].length());

		// bty = APP or DAP, bid = BPM rec-id
		lnkc = spl[1];
		cmtb = app_grid.getFellowIfAny("CMT" + bid); // approver-comment-box
		bfield1 = app_grid.getFellowIfAny("BPT" + bid); // BPM sub-type (rentwise= CC, SALES or later def)
		bpt = bfield1.getValue();
		
		BPM_updateRec(bid,useraccessobj.username,cmtb.getValue(), bpt,
			( (bty.equals("APP")) ? "APPROVE" : "DISAPPROVE") , lnkc);

		// refresh according to linking-code prefix (def in rwglobaldefs.zs)
		if(lnkc.indexOf(JOBS_PREFIX) != -1)
		{
			kid = spl[1].substring(JOBS_PREFIX.length(),spl[1].length());
			showJobMetadata(kid);
		}

		if(lnkc.indexOf(DO_PREFIX) != -1)
		{
			kid = spl[1].substring(DO_PREFIX.length(),spl[1].length());
			showDOMetadata(kid);
		}
		
		if(lnkc.indexOf(PR_PREFIX) != -1)
		{
			kid = spl[1].substring(PR_PREFIX.length(),spl[1].length());
			showPRMetadata(kid);
			checkPR_Approval(kid); // call-back in rwpurchaseReq_v1.zul
		}

	}
}

/* remember to include the pop-up in other mods
<popup id="auditlogs_pop">
<div style="background:#ef2929; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
	box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px" width="500px" >
<label style="font-size:14px;font-weight:bold;">Audit Logs</label>
<separator height="3px" />
<div id="auditlogs_holder" />
<separator height="3px" />
<button label="Ok" style="font-size:9px" onClick="auditlogs_pop.close()" />
</div>
</popup>
*/
void viewBPM_logs(String lnkc, Object iwhat)
{
	showSystemAudit(auditlogs_holder,lnkc,"");
	auditlogs_pop.open(iwhat);
}

// v1: show BPM recs by assigner-code
// could be used in other mods - need some modification - 
void showApprovalThing(String lnkc, String ijobtype, Div iholder)
{
	if(iholder.getFellowIfAny("app_grid") != null) app_grid.setParent(null);

	sqlstm = "select origid,field1,assignee,actiondate,actionstatus,notes from bpm_actions where assigner='" + lnkc + "' order by origid";
	aks = sqlhand.gpSqlGetRows(sqlstm);
	if(aks.size() == 0) return;

	apg = new Grid();
	apg.setId("app_grid");
	apg.setParent(iholder);
	krws = new org.zkoss.zul.Rows();
	krws.setParent(apg);

	bpmevt = new bpm_approverClick();

	for(di : aks)
	{
		bpid = di.get("origid").toString();
		irw = gridhand.gridMakeRow("","background:#729fcf","1,5",krws);
		gpMakeLabel(irw,"BPT" + bpid, di.get("field1"),"font-weight:bold");
		hb1 = new Hbox();
		hb1.setParent(irw);
		appb = gpMakeButton(hb1, "APP" + bpid + "_" + lnkc, "Approve", "", null);
		dappb = gpMakeButton(hb1, "DAP" + bpid + "_" + lnkc, "Disapprove","",null);

		appb.addEventListener("onClick", bpmevt);
		dappb.addEventListener("onClick", bpmevt);

		irw = gridhand.gridMakeRow("","","",krws);
		gpMakeLabel(irw,"","Last","font-size:9px");
		gpMakeLabel(irw,"BPU" + bpid, kiboo.checkNullString(di.get("assignee")),"font-size:9px");
		gpMakeLabel(irw,"","A/D","font-size:9px");

		kas = kiboo.checkNullString(di.get("actionstatus"));
		sty = "background:#555753";
		if(kas.equals("DISAPPROVE")) sty = "background:#cc0000";

		ndv = new Div();
		ndv.setStyle(sty + ";box-shadow: 4px 5px 7px #000000;padding:2px;margin:2px");
		ndv.setParent(irw);

		gpMakeLabel(ndv,"BPA" + bpid, " " + kas + " ", sty + ";color:#ffffff");

		gpMakeLabel(irw,"","Date","font-size:9px");
		gpMakeLabel(irw,"BPD" + bpid, (di.get("actiondate") == null) ? "" : dtf2.format(di.get("actiondate")), "font-size:9px");

		irw = gridhand.gridMakeRow("","","1,5",krws);
		gpMakeLabel(irw,"","Comments","font-size:9px");
		cmb = gpMakeTextbox(irw,"CMT" + bpid,kiboo.checkNullString(di.get("notes")),"font-size:9px", "99%");
		cmb.setMultiline(true);
		cmb.setHeight("50px");
	}
}

