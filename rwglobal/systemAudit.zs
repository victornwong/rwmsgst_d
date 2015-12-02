import java.util.*;
import java.text.*;
/**
 * Funcs to process rw_systemaudit
 * @author Victor Wong
 * @since 01/08/2013
 */

/**
 * Add something to rw_systemaudit, datecreated will have time too
 * @param ilinkc linking_code
 * @param isubc  linking_sub
 * @param iwhat  audit_notes
 * @param iuser  username
 */
void add_RWAuditLog(String ilinkc, String isubc, String iwhat, String iuser)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = "insert into rw_systemaudit (datecreated,linking_code,linking_sub,audit_notes,username) values " +
	"('" + todaydate + "','" + ilinkc + "','" + isubc + "','" + iwhat + "','" + iuser + "')";
	sqlhand.gpSqlExecuter(sqlstm);
}

Object[] sysloglb_hds =
{
	new listboxHeaderWidthObj("Dated",true,"100px"),
	new listboxHeaderWidthObj("User",true,"65px"),
	new listboxHeaderWidthObj("Logs",true,""),
};

/**
 * Can be used in other mods to show system-audit logs
 * @param ihold  DIV holder
 * @param ilinkc linking code
 * @param isubc  sub linking code
 */
void showSystemAudit(Div ihold, String ilinkc, String isubc)
{
	Listbox newlb = lbhand.makeVWListbox_Width(ihold, sysloglb_hds, "syslogs_lb", 5);
	SimpleDateFormat ldtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	
	chksub = " and linking_sub='" + isubc + "' "; // check req to filter by linking_sub
	if(isubc.equals("")) chksub = "";

	sqlstm = "select datecreated,username,audit_notes from rw_systemaudit where " +
	"linking_code='" + ilinkc + "'" + chksub + "order by datecreated desc";

	sylog = sqlhand.gpSqlGetRows(sqlstm);
	if(sylog.size() == 0) return;
	newlb.setRows(10); newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new tkslbClick());
	ArrayList kabom = new ArrayList();
	for(dpi : sylog)
	{
		kabom.add( ldtf.format(dpi.get("datecreated")) );
		kabom.add(kiboo.checkNullString(dpi.get("username")));
		kn = (dpi.get("audit_notes") == null) ? "" : sqlhand.clobToString(dpi.get("audit_notes"));
		kabom.add(kn);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

/**
 * KNOCKOFF from showSystemAudit() but with added things to handle more demanding request
 * @param ihold  DIV holder
 * @param ilinkc linking code
 * @param isubc  sub linking code
 * @param istart  logs start-date
 * @param iend logs end-date
 * @param isearch search-text in audit-logs
 */
void showSystemAudit_2(Div ihold, String ilinkc, String isubc, String isearch, Datebox istart, Datebox iend)
{
	sdate = kiboo.getDateFromDatebox(istart);
	edate = kiboo.getDateFromDatebox(iend);
	isearch = kiboo.replaceSingleQuotes(isearch);

	Listbox newlb = lbhand.makeVWListbox_Width(ihold, sysloglb_hds, "syslogs_lb", 5);
	SimpleDateFormat ldtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	
	chksub = " and linking_sub='" + isubc + "' "; // check req to filter by linking_sub
	if(isubc.equals("")) chksub = "";

	sqlstm = "select datecreated,username,audit_notes from rw_systemaudit where " +
	"linking_code='" + ilinkc + "'" + chksub +
	" and datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00'" +
	" and convert(nvarchar(max),audit_notes) like '%" + isearch + "%' order by datecreated desc";

	sylog = sqlhand.gpSqlGetRows(sqlstm);
	if(sylog.size() == 0) return;
	newlb.setRows(10); newlb.setMold("paging");	//newlb.addEventListener("onSelect", new tkslbClick());
	ArrayList kabom = new ArrayList();
	for(dpi : sylog)
	{
		kabom.add( ldtf.format(dpi.get("datecreated")) );
		kabom.add(kiboo.checkNullString(dpi.get("username")));
		kn = (dpi.get("audit_notes") == null) ? "" : sqlhand.clobToString(dpi.get("audit_notes"));
		kabom.add(kn);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

/**
 * 18/11/2015: export whatever in the audit-log listbox generated in showSystemAudit() into EXCEL using
 * header def in sysloglb_hds . Uses uploadedWorksheet_v1.exportExcelFromListbox() .
 * Assuming DIV kasiexport is defined in calling module
 */
void export_auditlog()
{
	exportExcelFromListbox(syslogs_lb, kasiexport, sysloglb_hds, "auditlogs.xls","logs");
}

/**
 * Save inventory changes log. User would then list them logs by date, uses a generic linking-code for them logs
 * @param pLinkcode the linking-code in system-audit
 * @param pAsstags asset-tags being changed
 * @param pAction  what action performed
 * @param pToWhat  change to what, (grade,pallet and etc)
 */
void saveInventoryChangeLog(String pLinkcode, String pAsstags, String pAction, String pToWhat)
{
	wo = pAsstags.replaceAll("'","").replaceAll(",",", "); // assuming the string passed is quote-comma delimited
	add_RWAuditLog(pLinkcode, "", pAction + pToWhat + " for " + wo, useraccessobj.username);
}
