import java.lang.Float;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import java.math.BigDecimal;
import org.zkoss.util.media.AMedia;
import org.victor.*;

// 10/07/2013: moved 'em funcs here TODO byte-compile later
// 11/08/2014: byte-compiled some funcs

NGfuncs ngfun = new NGfuncs();
RWMS_sql rwsqlfun = new RWMS_sql();

// GP: remove sub-div from DIV if any
void removeSubDiv(Div idivholder) // bc
{
	ngfun.removeSubDiv(idivholder);
}

void fillListbox_uniqField(String itbn, String ifl, Listbox ilb)
{
	sqlstm = "select distinct " + ifl + " from " + itbn;
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	String[] kabom = new String[1];
	for(d : r)
	{
		dk = d.get(ifl);
		if(dk != null)
		{
			kabom[0] = dk;
			lbhand.insertListItems(ilb,kabom,"false","");
		}
	}
	ilb.setSelectedIndex(0);
}

/*
void disableUI_obj(Object[] iob, boolean iwhat) // ngfuncs.jav
{
	ngfun.disableUI_obj(iob,iwhat);
	for(i=0; i<iob.length; i++)
	{
		iob[i].setDisabled(iwhat);
	}
}
*/

// itype, return value: 1=month, 2=year
int countMonthYearDiff(int itype, Object ist, Object ied) // generals.jav
{
	return kiboo.countMonthYearDiff(itype, ist, ied);
	/*
	Calendar std = new GregorianCalendar();
	Calendar edd = new GregorianCalendar();
	std.setTime(ist.getValue());
	edd.setTime(ied.getValue());
	diffYear = edd.get(Calendar.YEAR) - std.get(Calendar.YEAR);
	diffMonth = diffYear * 12 + edd.get(Calendar.MONTH) - std.get(Calendar.MONTH);
	return (itype == 1) ? diffMonth : diffYear;
	*/
}

/*
// convert 1023,3929,2990 to '1023','3929'..
String makeQuotedFromComma(String iwhat) // bc
{
	return kiboo.makeQuotedFromComma(iwhat);
}
*/

/*
Object vMakeWindow(Object ipar, String ititle, String iborder, String ipos, String iw, String ih) // bc
{
	return ngfun.vMakeWindow(ipar, ititle, iborder, ipos, iw, ih);
}
*/

/*
void popuListitems_Data2(ArrayList ikb, String[] ifl, Object ir)
{
	//ngfun.popuListitems_Data2(ikb, ifl, ir);

	String kstr = "";

	for(int i=0; i<ifl.length; i++)
	{
		//try {
		kk = ir.get(ifl[i]);

		if(kk == null) kstr = "";
		else
			if(kk instanceof Date) kstr = dtf.format(kk);
		else
			if(kk instanceof Integer) kstr = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				BigDecimal xt = (BigDecimal)kk;
				BigDecimal rt = xt.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kstr = nf2.format(kk);
				else
					kstr = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kstr = nf2.format(kk);
		else
			if(kk instanceof Float) kstr = kk.toString();
		else
			if(kk instanceof Boolean)
			{
				Boolean mm = (Boolean)kk;
				String wi = (mm) ? "Y" : "N";
				kstr = wi;
			}
		else
			kstr = kk;

		ikb.add( kstr );
		//} catch (Exception e) {}
	}
}
*/
/*
void popuListitems_Data(ArrayList ikb, String[] ifl, Object ir)
{
	//ngfun.popuListitems_Data(ikb, ifl, ir);
	String kstr = "";

	for(int i=0; i<ifl.length; i++)
	{
		//try {
		kk = ir.get(ifl[i]);
		if(kk == null) kstr = "";
		else
			if(kk instanceof Date) kstr = dtf2.format(kk);
		else
			if(kk instanceof Integer) kstr = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				BigDecimal xt = (BigDecimal)kk;
				BigDecimal rt = xt.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kstr = nf2.format(kk);
				else
					kstr = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kstr = nf2.format(kk);
		else
			if(kk instanceof Float) kstr = kk.toString();
		else
			if(kk instanceof Boolean)
			{
				Boolean mm = (Boolean)kk;
				String wi = (mm) ? "Y" : "N";
				kstr = wi;
			}

		ikb.add( kstr );
		//} catch (Exception e) {}
	}
}
*/

/*
String[] getString_fromUI(Object[] iob) // bc
{
	return ngfun.getString_fromUI(iob);
}
*/

/*
void populateUI_Data(Object[] iob, String[] ifl, Object ir)
{
	//ngfun.populateUI_Data(iob, ifl, ir);
	for(int i=0;i<iob.length;i++)
	{
		try
		{
			woi = ir.get(ifl[i]);

			if(iob[i] instanceof Textbox || iob[i] instanceof Label)
			{
				String kk = "";
				if(woi == null) kk = "";
				else
				if(woi instanceof Date) kk = dtf2.format(woi);
				else
				if(woi instanceof Integer || woi instanceof Double || woi instanceof BigDecimal) kk = woi.toString();
				else
				if(woi instanceof Float) kk = nf2.format(woi);

				iob[i].setValue(kk);

				//if(iob[i] instanceof Textbox) { Textbox mm = (Textbox)iob[i]; mm.setValue(kk); }
				//if(iob[i] instanceof Label) { Label mm = (Label)iob[i]; mm.setValue(kk); }
			}

			if(iob[i] instanceof Checkbox)
			{
				//Checkbox kk = (Checkbox)iob[i];
				iob[i].setChecked( (woi == null ) ? false : (Boolean)woi);
			}

			if(iob[i] instanceof Listbox)
			{
				lbhand.matchListboxItems( (Listbox) iob[i], kiboo.checkNullString((String)woi).toUpperCase() );
			}
			if(iob[i] instanceof Datebox)
			{
				//Datebox kk = (Datebox)iob[i];
				iob[i].setValue( (Date)woi );
			}
		} catch (Exception e) {}
	}
}
*/

/*
void clearUI_Field(Object[] iob) // bc
{
	ngfun.clearUI_Field(iob);
}
*/

int getWeekOfMonth(String thedate)
{
	sqlstm = "SELECT DATEPART(WEEK, '" + thedate + "') - DATEPART(WEEK, DATEADD(MM, " + 
	"DATEDIFF(MM,0,'" + thedate + "'), 0))+ 1 AS WEEK_OF_MONTH";

	krr = sqlhand.gpSqlFirstRow(sqlstm);
	if(krr == null) return -1;

	return (int)krr.get("WEEK_OF_MONTH");
}

// Lookup-func: get value1-value8 from lookup table by parent-name
String getFieldsCommaString(String iparents,int icol) // lookupfuncs.java
{
	return luhand.getFieldsCommaString(iparents, icol);
	/*
	aprs = luhand.getLookups_ByParent(iparents);
	retv = "";
	fld = "value" + icol.toString();
	for(di : aprs)
	{
		tpm = kiboo.checkNullString(di.get(fld));
		retv += tpm + ",";
	}

	retv = retv.replaceAll(",,",",");
	try {
	retv = retv.substring(0,retv.length()-1);
	} catch (Exception e) {}

	return retv;
	*/
}

// Merge 2 object-arrays into 1 - codes copied from some website
Object[] mergeArray(Object[] lst1, Object[] lst2) // generals.java
{
	return kiboo.mergeArray(lst1,lst2);
	/*
	List list = new ArrayList(Arrays.asList(lst1));
	list.addAll(Arrays.asList(lst2));
	Object[] c = list.toArray();
	return c;
	*/
}

void blindTings(Object iwhat, Object icomp) // ngfuncs.java
{
	ngfun.blindTings(iwhat, icomp);
	/*
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
	*/
}

void blindTings_withTitle(Object iwhat, Object icomp, Object itlabel) // ngfuncs.java
{
	ngfun.blindTings_withTitle(iwhat, icomp, itlabel);
	/*
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
	itlabel.setVisible((bld == false) ? true : false );
	*/
}

void downloadFile(Div ioutdiv, String ifilename, String irealfn)
{
	File f = new File(irealfn);
	fileleng = f.length();
	finstream = new FileInputStream(f);
	byte[] fbytes = new byte[fileleng];
	finstream.read(fbytes,0,(int)fileleng);

	AMedia amedia = new AMedia(ifilename, "xls", "application/vnd.ms-excel", fbytes);
	Iframe newiframe = new Iframe();
	newiframe.setParent(ioutdiv);
	newiframe.setContent(amedia);
}

void activateModule(String iplayg, String parentdiv_name, String winfn, String windId, String uParams, Object uAO) // ngfuncs.java
{
	ngfun.activateModule(iplayg, parentdiv_name, winfn, windId, uParams, uAO);
	/*
	Include newinclude = new Include();
	newinclude.setId(windId);
	includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);
	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs
	Div contdiv = Path.getComponent(iplayg + parentdiv_name);
	newinclude.setParent(contdiv);
	*/
} // activateModule()

// Use to refresh 'em checkboxes labels -- can be used for other mods
// iprefix: checkbox id prefix, inextcount: next id count
// NOTES: dunno why this is hard-coded with items_grid -- CHECK which modu using this !!!
void refreshCheckbox_CountLabel(String iprefix, int inextcount)
{
	ngfun.refreshCheckbox_CountLabel(iprefix, inextcount, items_grid);
	/*
	count = 1;
	for(i=1;i<inextcount; i++)
	{
		bci = iprefix + i.toString();
		icb = items_grid.getFellowIfAny(bci);
		if(icb != null)
		{
			icb.setLabel(count + ".");
			count++;
		}
	}
	*/
}

// itype: 1=width, 2=height
gpMakeSeparator(int itype, String ival, Object iparent) // bc
{
	ngfun.gpMakeSeparator(itype,ival,iparent);
}

class dropMe implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		//alert(event.getDragged());
		//lbhand.getListcellItemLabel(event.getDragged(),0)
		event.getTarget().setValue( event.getDragged().getLabel() );
	}
}
droppoMe = new dropMe();

Textbox gpMakeTextbox(Object iparent, String iid, String ivalue, String istyle, String iwidth) // ngfuncs.jav
{
	ngfun.gpMakeTextbox(iparent, iid, ivalue, istyle, iwidth, droppoMe);
}

Button gpMakeButton(Object iparent, String iid, String ilabel, String istyle, Object iclick) // bc
{
	return ngfun.gpMakeButton(iparent, iid, ilabel, istyle, iclick);
}

Label gpMakeLabel(Object iparent, String iid, String ivalue, String istyle) // bc
{
	return ngfun.gpMakeLabel(iparent, iid, ivalue, istyle);
}

Checkbox gpMakeCheckbox(Object iparent, String iid, String ilabel, String istyle) // bc
{
	return ngfun.gpMakeCheckbox(iparent, iid, ilabel, istyle);
}

// knock from GridHandler.java (javac prob -- 19/03/2014)
void gpmakeGridHeaderColumns_Width(String[] icols, String[] iwidths, Object iparent) // bc
{
	ngfun.gpmakeGridHeaderColumns_Width(icols, iwidths, iparent);
}

// Add something to rw_systemaudit, datecreated will have time too
// ilinkc=linking_code, isubc=linking_sub, iwhat=audit_notes
void add_RWAuditLog(String ilinkc, String isubc, String iwhat, String iuser)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = "insert into rw_systemaudit (datecreated,linking_code,linking_sub,audit_notes,username) values " +
	"('" + todaydate + "','" + ilinkc + "','" + isubc + "','" + iwhat + "','" + iuser + "')";
	sqlhand.gpSqlExecuter(sqlstm);
}

Object getStockItem_rec(String istkcode) // rwms_sql.jav
{
	return rwsqlfun.getStockItem_rec(istkcode);
}

boolean checkStockExist(String istkc) // rwms_sql.jav
{
	return rwsqlfun.checkStockExist(istkc);
}

Object getFocus_CustomerRec(String icustid) // bc
{
	return rwsqlfun.getFocus_CustomerRec(icustid);
}

String getFocus_CustomerName(String icustid) // bc
{
	return rwsqlfun.getFocus_CustomerName(icustid);
}

Object getGCO_rec(String iwhat) // bc
{
	return rwsqlfun.getGCO_rec(iwhat);
}

Object getGRN_rec(String iwhat)
{
	return rwsqlfun.getGRN_rec(iwhat);
}

Object getHelpTicket_rec(String iwhat)
{
	return rwsqlfun.getHelpTicket_rec(iwhat);
}

Object getLocalRMA_rec(String iwhat)
{
	return rwsqlfun.getLocalRMA_rec(iwhat);
}

Object getLocalRMAItem_rec(String iwhat)
{
	return rwsqlfun.getLocalRMAItem_rec(iwhat);
}

Object getLC_rec(String iwhat)
{
	return rwsqlfun.getLC_rec(iwhat);
}

Object getLCAsset_rec(String iwhat)
{
	return rwsqlfun.getLCAsset_rec(iwhat);
}

Object getLCEquips_rec(String iwhat)
{
	return rwsqlfun.getLCEquips_rec(iwhat);
}

Object getLCNew_rec(String iwhat)
{
	return rwsqlfun.getLCNew_rec(iwhat);
}

Object getRentalItems_build(String iwhat)
{
	return rwsqlfun.getRentalItems_build(iwhat);
}

Object getPickPack_rec(String iwhat)
{
	return rwsqlfun.getPickPack_rec(iwhat);
}

Object getRWJob_rec(String iwhat)
{
	return rwsqlfun.getRWJob_rec(iwhat);
}

Object getBOM_rec(String iwhat)
{
	return rwsqlfun.getBOM_rec(iwhat);
}

Object getDO_rec(String iwhat)
{
	return rwsqlfun.getDO_rec(iwhat);
}

Object getDispatchManifest_rec(String iwhat)
{
	return rwsqlfun.getDispatchManifest_rec(iwhat);
}

Object getOfficeItem_rec(String iwhat)
{
	return rwsqlfun.getOfficeItem_rec(iwhat);
}

Object getSoftwareLesen_rec(String iid)
{
	return rwsqlfun.getSoftwareLesen_rec(iid);
}

Object getPR_rec(String iwhat)
{
	return rwsqlfun.getPR_rec(iwhat);
}

Object getSendout_rec(String iwhat)
{
	return rwsqlfun.getSendout_rec(iwhat);
}

Object getQuotation_rec(String iwhat)
{
	return rwsqlfun.getQuotation_rec(iwhat);
}

Object getCheqRecv_rec(String iwhat)
{
	return rwsqlfun.getCheqRecv_rec(iwhat);
}

Object getDrawdownAssignment_rec(String iwhat)
{
	return rwsqlfun.getDrawdownAssignment_rec(iwhat);
}

Object getActivitiesContact_rec(String iwhat)
{
	return rwsqlfun.getActivitiesContact_rec(iwhat);
}

Object getActivity_rec(String iwhat)
{
	return rwsqlfun.getActivity_rec(iwhat);
}

Object getReservation_Rec(String iwhat)
{
	return rwsqlfun.getReservation_Rec(iwhat);
}

Object getEqReqStat_rec(String iwhat)
{
	return rwsqlfun.getEqReqStat_rec(iwhat);
}

Object getFC_indta_rec(String iwhat)
{
	return rwsqlfun.getFC_indta_rec(iwhat);
}

boolean existRW_inLCTab(String iwhat) // not BC
{
	sqlstm = "select top 1 origid from rw_lc_records where rwno='" + iwhat + "' or lc_id='" + iwhat + "'";
	return (sqlhand.gpSqlFirstRow(sqlstm) == null) ? false : true;
}

Object getFC6DO_rec(String iwhat)
{
	return rwsqlfun.getFC6DO_rec(iwhat);
}
// all single-rec sql func done bc
BOM_JOBID = 1; // BOM link to job-id
PICKLIST_JOBID = 2; // pick-list link to job-id
BOM_DOID = 3; // BOM link to DO
PICKLIST_DOID = 4; // pick-list link to DO
DO_MANIFESTID = 5; // DO link to manifest
PR_JOB = 6; // PR link to job
//DO_JOBPICKID = 6; // DO link to job-id

// General purpose to return string of other things with linking job-id (ijid)
String getLinkingJobID_others(int itype, String ijid) // bc
{
	return rwsqlfun.getLinkingJobID_others(itype, ijid);
	/*
	retv = tablen = "";
	lnkid = "job_id";

	switch(itype)
	{
		case BOM_JOBID :
		case BOM_DOID :
			tablen = "stockrentalitems";
			break;
		case PICKLIST_JOBID :
		case PICKLIST_DOID :
			tablen = "rw_pickpack";
			break;
		case DO_MANIFESTID :
			tablen = "rw_deliveryorder";
			lnkid = "manif_id";
			break;
	}

	if(itype == BOM_DOID || itype == PICKLIST_DOID) lnkid = "do_id";

	if(!tablen.equals(""))
	{
		sqlstm = "select origid from " + tablen + " where " + lnkid + "=" + ijid;
		krs = sqlhand.gpSqlGetRows(sqlstm);
		if(krs.size() != 0)
		{
			for(d : krs)
			{
				retv += d.get("origid").toString() + ",";
			}
			try {
			retv = retv.substring(0,retv.length()-1);
			} catch (Exception e) {}
		}
	}
	return retv;
	*/
}

// DOs link to bom/picklist link to job - can be used for other mods to comma-string something
// itype: 1=picklist, 2=boms, 3=PR, 4=GRN(iorigids=PR), 5=ADT->GCO
String getDOLinkToJob(int itype, String iorigids) // bc
{
	return rwsqlfun.getDOLinkToJob(itype, iorigids);
	/*
	retv = sqlstm = "";
	if(iorigids.equals("")) return "";

	switch(itype)
	{
		case 1:
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join rw_pickpack ppl on ppl.do_id = do.origid " +
		"where ppl.origid in (" + iorigids + ")";
		break;

		case 2:
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join stockrentalitems sri on sri.do_id = do.origid " +
		"where sri.origid in (" + iorigids + ")";
		break;

		case 3:
		sqlstm = "select distinct pr.origid as doid from purchaserequisition pr " +
		"where pr.pr_status in ('APPROVE','APPROVED') and pr.job_id=" + iorigids;
		break;

		case 4:
		sqlstm = "select temp_grn as doid from purchaserequisition where origid in (" + iorigids + ")";
		//alert(sqlstm);
		break;

		case 5: // get GCO from ADT table
		sqlstm = "select origid as doid from rw_qcaudit where gcn_no=" + iorigids;
		break;
	}

	if(!sqlstm.equals(""))
	{
		rcs = sqlhand.gpSqlGetRows(sqlstm);
		if(rcs.size() > 0)
		{
			for(d : rcs)
			{
				if(d.get("doid") != null) retv += d.get("doid") + ",";
			}
			try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
		}
	}
	return retv;
	//return sqlstm;
	*/
}

// FC6: Get MRN linked to T.GRN. iwhat=T.GRNs
Object grnGetMRN(String iwhat) // bc
{
	return rwsqlfun.grnGetMRN(iwhat);
/*
	sqlstm = "select voucherno from v_link4 where vouchertype=1280 and sortlinkid=" + 
	"(select top 1 links1 from data where vouchertype=1281 and voucherno='" + iwhat + "')";
*/
/*	
	sqlstm = "select distinct voucherno from v_link4 where vouchertype=1280 and sortlinkid in " + 
	"(select links1 from data where vouchertype=1281 and voucherno in (" + iwhat + "))";

//	return sqlhand.rws_gpSqlFirstRow(sqlstm);
	return sqlhand.rws_gpSqlGetRows(sqlstm);
*/
}

// Get MRNs from GRNs. iwhat: GRNs - split and put quotes to be used in grnGetMRN()
String grnToMRN_str(String iwhat) // bc
{
	rwsqlfun.grnToMRN_str(iwhat);
	/*
	if(iwhat.equals("")) return "";
	ks = iwhat.split(",");
	if(ks.length < 1) return "";
	wps = "";
	for(i=0;i<ks.length;i++)
	{
		wps += "'" + ks[i] + "',";
	}
	try { wps = wps.substring(0,wps.length()-1); } catch (Exception e) {}
	mrns = grnGetMRN(wps);
	wps = "";
	if(mrns.size() > 0)
	{
		for(d : mrns)
		{
			wps += d.get("voucherno") + ",";
		}
		try { wps = wps.substring(0,wps.length()-1); } catch (Exception e) {}
	}
	return wps;
	*/
}

// Populate a listbox with usernames from portaluser
void populateUsernames(Listbox ilb, String discardname) // bc
{
	rwsqlfun.populateUsernames(ilb,discardname);
}

