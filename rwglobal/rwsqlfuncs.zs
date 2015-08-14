import java.lang.Float;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import java.math.BigDecimal;
import org.zkoss.util.media.AMedia;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;

// 10/07/2013: moved some funcs here TODO byte-compile later

/**
 * Based on FOCUS sql-procedure, port the calculation here
 * @param  dstr date-string YYYY-MM-DD
 * @return      integer value compatible with FOCUS
 */
int calcFocusDate(String dstr)
{
	java.util.Calendar thedate = Calendar.getInstance();
	thedate.setTime(GlobalDefs.dtf2.parse(dstr));
	// ((2014-1950)*416) + ((9*32)+1) + (18 - 1);
	//retval = ((thedate.get(Calendar.YEAR)-1950)*416) + ((thedate.get(Calendar.MONTH)*32)+1) + (thedate.get(Calendar.DAY_OF_MONTH)-1);
	retval = ((thedate.get(Calendar.YEAR)-1950)*416) + ((thedate.get(Calendar.MONTH)+1)*32) + (thedate.get(Calendar.DAY_OF_MONTH));
	return retval;
}

/**
 * [getGRN_rec_NEW description]
 * @param  iwhat the origid
 * @return       data-record object
 */
Object getGRN_rec_NEW(String iwhat)
{
	sqlstm = "select * from rw_grn where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

/**
 * [removeAllListitems description]
 * @param ilb the listbox
 */
void removeAllListitems(Listbox ilb)
{
	kk = ilb.getItems().toArray();
	for(i=0;i<kk.length;i++)
	{
		kk[i].setParent(null);
	}
}

/**
 * Fill a listbox with distinct column items from a table RWMS
 * @param itbn database table name
 * @param ifl  field-name
 * @param ilb  listbox obj
 */
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
	try {	ilb.setSelectedIndex(0); } // default select item 1 in listbox
	catch (Exception e) {}
}

/**
 * Get selected items in a listbox and return string as number-comma or quoted-comma.
 * To be used in SQL statement
 * @param ilb the listbox to check
 * @param  icol column to concatenate(zero-index)
 * @param inum return string as true= number-comma, false= quoted-comma, 
 * @return      [description]
 */
String getSelected_Listitems(Listbox ilb, int icol, boolean inum)
{
	String retval = "";
	kx = ilb.getSelectedItems().toArray();
	for(i=0; i<kx.length; i++)
	{
		vx = lbhand.getListcellItemLabel(kx[i],icol);
		if(inum) // number-comma
			retval += vx + ",";
		else // quoted-comma
			retval += "'" + vx + "',";
	}
	try { retval = retval.substring(0,retval.length()-1); return retval; } catch (Exception e) { return ""; }
}

/**
 * Fill a listbox with distinct column items from a table Focus
 * chopped from fillListbox_uniqField()
 * @param itbn database table name
 * @param ifl  field-name
 * @param ilb  listbox obj
 */
void rws_fillListbox_uniqField(String itbn, String ifl, Listbox ilb)
{
	sqlstm = "select distinct " + ifl + " from " + itbn +
	" order by " + ifl;
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
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
	try {	ilb.setSelectedIndex(0); } catch (Exception e) {}
}

// TODO move this to listboxhandler.j
void setListcell_Style(Listitem ilbitem, int icolumn, String istyle)
{
	List prevrc = ilbitem.getChildren();
	Listcell prevrc_2 = (Listcell)prevrc.get(icolumn); // get the second column listcell
	prevrc_2.setStyle(istyle);
}

// GP: remove sub-div from DIV if any
void removeSubDiv(Div idivholder)
{
	prvds = idivholder.getChildren().toArray();
	for(i=0;i<prvds.length;i++) // remove prev sub-divs if any
	{
		prvds[i].setParent(null);
	}
}

// itype, return value: 1=month, 2=year
int countMonthYearDiff(int itype, Object ist, Object ied)
{
	Calendar std = new GregorianCalendar();
	Calendar edd = new GregorianCalendar();
	std.setTime(ist.getValue());
	edd.setTime(ied.getValue());
	diffYear = edd.get(Calendar.YEAR) - std.get(Calendar.YEAR);
	diffMonth = diffYear * 12 + edd.get(Calendar.MONTH) - std.get(Calendar.MONTH);
	return (itype == 1) ? diffMonth : diffYear;
}

// convert 1023,3929,2990 to '1023','3929'..
String makeQuotedFromComma(String iwhat)
{
	if(iwhat.equals("")) return "";
	pp = iwhat.split("\n");
	lcs = "";
	for(i=0; i<pp.length; i++)
	{
		lcs += "'" + pp[i].trim() + "',";
	}
	try { lcs = lcs.substring(0,lcs.length()-1); } catch (Exception e) {}
	return lcs;
}

Object vMakeWindow(Object ipar, String ititle, String iborder, String ipos, String iw, String ih)
{
	rwin = new Window(ititle,iborder,true);
	rwin.setWidth(iw);
	rwin.setHeight(ih);
	rwin.setPosition(ipos);
	rwin.setParent(ipar);
	rwin.setMode("overlapped");
	return rwin;
}

void popuListitems_Data2(ArrayList ikb, String[] ifl, Object ir)
{
	for(i=0; i<ifl.length; i++)
	{
		try {
		kk = ir.get(ifl[i]);
		if(kk == null) kk = "";
		else
			if(kk instanceof Date) kk = dtf.format(kk);
		else
			if(kk instanceof Integer) kk = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				rt = kk.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kk = nf2.format(kk);
				else
					kk = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kk = nf2.format(kk);
		else
			if(kk instanceof Float) kk = kk.toString();
		else
			if(kk instanceof Boolean) { wi = (kk) ? "Y" : "N"; kk = wi; }

		ikb.add( kk );
		} catch (Exception e) {}
	}
}

void popuListitems_Data(ArrayList ikb, String[] ifl, Object ir)
{
	for(i=0; i<ifl.length; i++)
	{
		try {
		kk = ir.get(ifl[i]);
		if(kk == null) kk = "";
		else
			if(kk instanceof Date) kk = dtf2.format(kk);
		else
			if(kk instanceof Integer) kk = nf0.format(kk);
		else
			if(kk instanceof BigDecimal)
			{
				rt = kk.remainder(BigDecimal.ONE);
				if(rt.floatValue() != 0.0)
					kk = nf2.format(kk);
				else
					kk = nf0.format(kk);
			}
		else
			if(kk instanceof Double) kk = nf2.format(kk);
		else
			if(kk instanceof Float) kk = kk.toString();
		else
			if(kk instanceof Boolean) { wi = (kk) ? "Y" : "N"; kk = wi; }

		ikb.add( kk );
		} catch (Exception e) {}
	}
}

String[] getString_fromUI(Object[] iob)
{
	rdt = new String[iob.length];
	for(i=0; i<iob.length; i++)
	{
		rdt[i] = "";
		try {
		if(iob[i] instanceof Textbox || iob[i] instanceof Label) rdt[i] = kiboo.replaceSingleQuotes(iob[i].getValue().trim());
		if(iob[i] instanceof Listbox) rdt[i] = iob[i].getSelectedItem().getLabel();
		if(iob[i] instanceof Datebox) rdt[i] = dtf2.format( iob[i].getValue() );
		if(iob[i] instanceof Checkbox) rdt[i] = (iob[i].isChecked()) ? "1" : "0";
		}
		catch (Exception e) {}
	}
	return rdt;
}

void populateUI_Data(Object[] iob, String[] ifl, Object ir)
{
	for(i=0;i<iob.length;i++)
	{
		try {
		if(iob[i] instanceof Textbox || iob[i] instanceof Label)
		{
			kk = ir.get(ifl[i]);
			if(kk == null) kk = "";
			else
			if(kk instanceof Date) kk = dtf2.format(kk);
			else
			if(kk instanceof Integer || kk instanceof Double || kk instanceof BigDecimal) kk = kk.toString();
			else
			if(kk instanceof Float) kk = nf2.format(kk);

			iob[i].setValue(kk);
		}

		if(iob[i] instanceof Checkbox) iob[i].setChecked( (ir.get(ifl[i]) == null ) ? false : ir.get(ifl[i]) );
		if(iob[i] instanceof Listbox)
		{
			lbhand.matchListboxItems( iob[i], kiboo.checkNullString( ir.get(ifl[i]) ).toUpperCase() );
		}
		if(iob[i] instanceof Datebox) iob[i].setValue( ir.get(ifl[i]) );
		} catch (Exception e) {}
	}
}

void clearUI_Field(Object[] iob)
{
	for(i=0; i<iob.length; i++)
	{
		if(iob[i] instanceof Textbox || iob[i] instanceof Label) iob[i].setValue("");
		if(iob[i] instanceof Datebox) kiboo.setTodayDatebox(iob[i]);
		if(iob[i] instanceof Listbox) iob[i].setSelectedIndex(0);
	}
}

/**
 * Uses t-sql to get week-of-month
 * @param  thedate date string YYYY-MM-DD
 * @return         week-of-month
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
String getFieldsCommaString(String iparents,int icol)
{
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
}

// Merge 2 object-arrays into 1 - codes copied from some website
Object[] mergeArray(Object[] lst1, Object[] lst2)
{
	List list = new ArrayList(Arrays.asList(lst1));
	list.addAll(Arrays.asList(lst2));
	Object[] c = list.toArray();
	return c;
}

void blindTings(Object iwhat, Object icomp)
{
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
}

void blindTings_withTitle(Object iwhat, Object icomp, Object itlabel)
{
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);

	itlabel.setVisible((bld == false) ? true : false );
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

void activateModule(String iplayg, String parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);

	includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);

	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs

	Div contdiv = Path.getComponent(iplayg + parentdiv_name);
	newinclude.setParent(contdiv);

} // activateModule()

// Use to refresh 'em checkboxes labels -- can be used for other mods
// iprefix: checkbox id prefix, inextcount: next id count
void refreshCheckbox_CountLabel(String iprefix, int inextcount)
{
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
}

// itype: 1=width, 2=height
gpMakeSeparator(int itype, String ival, Object iparent)
{
	sep = new Separator();
	if(itype == 1) sep.setWidth(ival);
	if(itype == 2) sep.setHeight(ival);
	sep.setParent(iparent);
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

Textbox gpMakeTextbox(Object iparent, String iid, String ivalue, String istyle, String iwidth)
{
	Textbox retv = new Textbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) retv.setValue(ivalue);
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	retv.setDroppable("true");
	retv.addEventListener("onDrop", droppoMe);
	retv.setParent(iparent);
	return retv;
}

Button gpMakeButton(Object iparent, String iid, String ilabel, String istyle, Object iclick)
{
	Button retv = new Button();
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	if(!iid.equals("")) retv.setId(iid);
	if(iclick != null) retv.addEventListener("onClick", iclick);
	retv.setParent(iparent);
	return retv;
}

Label gpMakeLabel(Object iparent, String iid, String ivalue, String istyle)
{
	Label retv = new Label();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	retv.setValue(ivalue);
	retv.setParent(iparent);
	return retv;
}

Checkbox gpMakeCheckbox(Object iparent, String iid, String ilabel, String istyle)
{
	Checkbox retv = new Checkbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	retv.setParent(iparent);
	return retv;
}

// knock from GridHandler.java (javac prob -- 19/03/2014)
void gpmakeGridHeaderColumns_Width(String[] icols, String[] iwidths, Object iparent)
{
	Columns colms = new Columns();
	for(int i=0; i<icols.length; i++)
	{
		Column hcolm = new Column();
		hcolm.setLabel(icols[i]);
		/*
		Comp asc = new Comp(true,i);
		Comp dsc = new Comp(false,i);
		hcolm.setSortAscending(asc);
		hcolm.setSortDescending(dsc);
		*/
		hcolm.setStyle("font-size:9px");
		hcolm.setWidth(iwidths[i]);
		hcolm.setParent(colms);	
	}
	colms.setParent((Component)iparent);
}

Object getStockItem_rec(String istkcode)
{
	sqlstm = "select * from stockmasterdetails where stock_code='" + istkcode + "'";
	return sqlhand.gpSqlFirstRow(sqlstm);
}

boolean checkStockExist(String istkc)
{
	sqlstm = "select id from stockmasterdetails where stock_code='" + istkc + "'";
	krr = sqlhand.gpSqlFirstRow(sqlstm);
	retval = false;
	if(krr != null) retval = true;
	return retval;
}

Object getFocus_CustomerRec(String icustid)
{
	focsql = sqlhand.rws_Sql();
	if(focsql == null) return null;
	sqlstm = "select cust.name,cust.code,cust.code2, " +
	"custd.address1yh, custd.address2yh, custd.address3yh, custd.address4yh, " +
	"custd.telyh, custd.faxyh, custd.contactyh, custd.deliverytoyh, " +
	"custd.manumberyh, custd.rentaltermyh, custd.interestayh, " +
	"custd.credit4yh, custd.credit5yh, custd.creditlimityh, custd.suspendyh, " +
	"custd.salesrepyh,custd.interestayh,custd.emailyh, cust.type from mr000 cust " +
	"left join u0000 custd on custd.extraid = cust.masterid " +
	"where cust.masterid=" + icustid;
	retval = focsql.firstRow(sqlstm);
	focsql.close();
	return retval;
}

// Get FC6 customer-id/bookno by customer-name
Object getFocus_CustomerID(String icustname)
{
	sqlstm = "select masterid from mr000 where name='" + icustname + "';";
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	return (r == null) ? "" : r.get("masterid").toString();
}

String getFocus_CustomerName(String icustid)
{
	if(icustid.equals("")) return "NEW";
	focsql = sqlhand.rws_Sql();
	if(focsql == null) return "NEW";
	sqlstm = "select cust.name from mr000 cust where cust.masterid=" + icustid;
	retval = focsql.firstRow(sqlstm);
	focsql.close();
	if(retval == null) return "NEW";
	return retval.get("name");
}

Object getGCO_rec(String iwhat)
{
	sqlstm = "select * from rw_goodscollection where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getGRN_rec(String iwhat)
{
	sqlstm = "select * from tblgrnmaster where id=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getHelpTicket_rec(String iwhat)
{
	sqlstm = "select * from rw_helptickets where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLocalRMA_rec(String iwhat)
{
	sqlstm = "select * from rw_localrma where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLocalRMAItem_rec(String iwhat)
{
	sqlstm = "select * from rw_localrma_items where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLC_rec(String iwhat)
{
	sqlstm = "select * from rw_leasingcontract where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCAsset_rec(String iwhat)
{
	sqlstm = "select * from rw_leaseequipments where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCEquips_rec(String iwhat)
{
	sqlstm = "select * from rw_lc_equips where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCNew_rec(String iwhat)
{
	sqlstm = "select * from rw_lc_records where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getRentalItems_build(String iwhat)
{
	sqlstm = "select * from stockrentalitems_det where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getPickPack_rec(String iwhat)
{
	sqlstm = "select * from rw_pickpack where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getRWJob_rec(String iwhat)
{
	sqlstm = "select * from rw_jobs where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getBOM_rec(String iwhat)
{
	sqlstm = "select * from stockrentalitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDO_rec(String iwhat)
{
	sqlstm = "select * from rw_deliveryorder where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDispatchManifest_rec(String iwhat)
{
	sqlstm = "select * from rw_dispatchmanif where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getOfficeItem_rec(String iwhat)
{
	sqlstm = "select * from rw_officeitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getSoftwareLesen_rec(String iid)
{
	sqlstm = "select * from rw_clientswlicenses where origid=" + iid;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getPR_rec(String iwhat)
{
	sqlstm = "select * from purchaserequisition where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getSendout_rec(String iwhat)
{
	sqlstm = "select * from rw_sendouttracker where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getQuotation_rec(String iwhat)
{
	sqlstm = "select * from rw_quotations where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getCheqRecv_rec(String iwhat)
{
	sqlstm = "select * from rw_cheqrecv where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDrawdownAssignment_rec(String iwhat)
{
	sqlstm = "select * from rw_assigned_rwi where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getActivitiesContact_rec(String iwhat)
{
	sqlstm = "select * from rw_activities_contacts where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getActivity_rec(String iwhat)
{
	sqlstm = "select * from rw_activities where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getReservation_Rec(String iwhat)
{
	sqlstm = "select * from rw_stockreservation where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getEqReqStat_rec(String iwhat)
{
	sqlstm = "select * from reqthings_stat where parent_id='"+ iwhat + "'";
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getFC_indta_rec(String iwhat)
{
	sqlstm = "select * from indta where salesid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

boolean existRW_inLCTab(String iwhat)
{
	sqlstm = "select top 1 origid from rw_lc_records where rwno='" + iwhat + "' or lc_id='" + iwhat + "'";
	return (sqlhand.gpSqlFirstRow(sqlstm) == null) ? false : true;
}

Object getFocus_StockGrades() // Get Focus6 available inventory grades
{
	sqlstm = "select distinct grade from partsall_0 order by grade";
	return sqlhand.rws_gpSqlGetRows(sqlstm);
}

Object getFC6DO_rec(String iwhat) // TODO check java codes for this
{
	sqlstm = "select top 1 convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, d.voucherno, " +
	"c.name as customer_name, k.deliverystatusyh, k.deliverydateyh, k.transporteryh, k.deliveryrefyh, k.deliveryaddressyh," +
	"k.narrationyh, k.referenceyh from data d " +
	"left join mr000 c on c.masterid = d.bookno " +
	"left join u001c k on k.extraid = d.extraheaderoff " +
	"where d.vouchertype=6144 " +
	"and d.voucherno='" + iwhat + "'";

	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

BOM_JOBID = 1; // BOM link to job-id
PICKLIST_JOBID = 2; // pick-list link to job-id
BOM_DOID = 3; // BOM link to DO
PICKLIST_DOID = 4; // pick-list link to DO
DO_MANIFESTID = 5; // DO link to manifest
PR_JOB = 6; // PR link to job
//DO_JOBPICKID = 6; // DO link to job-id

// General purpose to return string of other things with linking job-id (ijid)
String getLinkingJobID_others(int itype, String ijid)
{
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
}

// DOs link to bom/picklist link to job - can be used for other mods to comma-string something
// itype: 1=picklist, 2=boms, 3=PR, 4=GRN(iorigids=PR), 5=ADT->GCO, 6=job->RDO
String getDOLinkToJob(int itype, String iorigids)
{
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

		case 6: // get RDO by job-id
		sqlstm = "select id as doid from deliveryordermaster where job_id=" + iorigids;
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
}

// FC6: Get MRN linked to T.GRN. iwhat=T.GRNs
Object grnGetMRN(String iwhat)
{
/*
	sqlstm = "select voucherno from v_link4 where vouchertype=1280 and sortlinkid=" + 
	"(select top 1 links1 from data where vouchertype=1281 and voucherno='" + iwhat + "')";
*/
	sqlstm = "select distinct voucherno from v_link4 where vouchertype=1280 and sortlinkid in " + 
	"(select links1 from data where vouchertype=1281 and voucherno in (" + iwhat + "))";

//	return sqlhand.rws_gpSqlFirstRow(sqlstm);
	return sqlhand.rws_gpSqlGetRows(sqlstm);
}

// Get MRNs from GRNs. iwhat: GRNs - split and put quotes to be used in grnGetMRN()
String grnToMRN_str(String iwhat)
{
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
}

// Populate a listbox with usernames from portaluser
void populateUsernames(Listbox ilb, String discardname)
{
	sqlstm = "select username from portaluser where username<>'" + discardname + "' and deleted=0 and locked=0 order by username";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	ArrayList kabom = new ArrayList();
	for( d : recs)
	{
		kabom.add( kiboo.checkNullString(d.get("username")) );
		lbhand.insertListItems(ilb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	ilb.setSelectedIndex(0);
}

//GroovyRowResult getJobPicklist_byParentJob(String iwhat) throws SQLException
Object getJobPicklist_byParentJob(String iwhat)
{
	String sqlstm = "select * from rw_jobpicklist where parent_job=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getAssignment_rec(String iwhat)
{
	sqlstm = "select * from rw_assignment where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getnewDO_rec(String iwhat)
{
	sqlstm = "select * from deliveryordermaster where id=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

String getUser_email(String iwho)
{
	sqlstm = "select email from portaluser where username='" + iwho + "'";
	r = sqlhand.gpSqlFirstRow(sqlstm);
	return (r == null) ? null : r.get("email");
}

Object getMELGRN_rec(String iwhat)
{
	sqlstm = "select * from mel_grn where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getMELCSGN_rec(String iwhat)
{
	sqlstm = "select * from mel_csgn where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

void injectNotif(String unm, String ntx)
{
	today = kiboo.todayISODateString();
	injstm = "insert into rw_notifs (datecreated,notif_text,poster,astatus) values " +
	"('" + today + "','" + ntx + "','" + unm + "','PENDING');";
	sqlhand.gpSqlExecuter(injstm);
}

/**
 * Simplified string regex func to extract string by pattern
 * @param istring  the whole thing
 * @param ipattern the pattern to extract substring
 */
String doregex(String istring, String ipattern)
{
	Pattern pattern = Pattern.compile(ipattern);
	Matcher matcher = pattern.matcher(istring);
	retval = "";
	if(matcher.find())
	{
		retval = kiboo.replaceSingleQuotes(matcher.group(1).trim());
	}
	return retval;
}
