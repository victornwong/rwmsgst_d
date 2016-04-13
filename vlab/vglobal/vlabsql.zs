/**
 * RLM MySQL access functions
 */

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.math.*;
import groovy.sql.*;
import java.util.*;
import java.text.*;
import org.victor.*;

//-------- vlab SQL funcs, move to byte-compile later ---
/**
 *  AWS connect string for chinese-chars
 * 	?useUnicode=true&characterEncoding=UTF-8
 * String dbstring = "jdbc:mysql://vwdbinstanceoregon.cxadgyaubug5.us-west-2.rds.amazonaws.com:3306/wfmdb?useUnicode=true&characterEncoding=UTF-8";
 * @return GROOVY SQL instance
 */
Sql v_Sql()
{
	String dbstring = "jdbc:mysql://localhost:13306/vlab";
	try { return Sql.newInstance(dbstring, "vlabuser", "1qaz", "com.mysql.jdbc.Driver"); } catch (Exception e) { return null; }
}

boolean vsql_execute(String isqlstm)
{
	Sql sql = v_Sql(); if(sql == null) return false;
	sql.execute(isqlstm); sql.close();
	return true;
}

ArrayList vsql_GetRows(String isqlstm)
{
	Sql sql = v_Sql(); if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close(); return retval;
}

GroovyRowResult vsql_FirstRow(String isqlstm)
{
	Sql sql = v_Sql(); if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close(); return retval;
}

Object getCustomer_Rec(String iwhat)
{
	sqlstm = "select * from Customer where Id=" + iwhat;
	return vsql_FirstRow(sqlstm);
}

Object get_CustomerByArCode(String iwhat)
{
	sqlstm = "select * from Customer where ar_code='" + iwhat + "' limit 1";
	return vsql_FirstRow(sqlstm);
}

Object get_JobFolders(String iwhat)
{
	sqlstm = "select * from JobFolders where origid=" + iwhat;
	return vsql_FirstRow(sqlstm);
}

//-------- old codes

Object getWorkOrderRec(String iwhat) throws SQLException
{
	sqlstm = "select * from workorders where origid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getSupplierRec(String iwhat) throws SQLException
{
	sqlstm = "select * from SupplierDetail where ID=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getPurchaseReqRec(String iwhat) throws SQLException
{
	sqlstm = "select * from PurchaseRequisition where origid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getClientRec(String iwhat)
{
	sqlstm = "select * from clients where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getAgentRec(String iwhat)
{
	sqlstm = "select * from foreignagent where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getSendoutRec(String iwhat)
{
	sqlstm = "select * from sendout where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getMastervisaRec(String iwhat)
{
	sqlstm = "select * from myh where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getSubconRec(String iwhat)
{
	sqlstm = "select * from myc where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getWorkRec(String iwhat)
{
	sqlstm = "select * from myw where origid=" + iwhat;
	return gpWMS_FirstRow(sqlstm);
}

Object getOutboundRec(String iwhat)
{
	sqlstm = "select * from tblStockOutMaster where Id=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

/**
 * Get tblStockOutMaster.stage
 * @param  iob stkout voucher no.
 * @return     stage
 */
String getStkout_stage(String iob)
{
	sqlstm = "select stage from tblStockOutMaster where Id=" + iob;
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	return (r == null) ? "" : kiboo.checkNullString(r.get("stage"));
}

String getStockMaster_descriptionById(String istkid)
{
	if(istkid.equals("") || istkid.equals("0")) return "";
	sqlstm = "select Description from StockMasterDetails where ID=" + istkid;
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	try { return kiboo.checkNullString( r.get("Description") ); } catch (Exception e) { return ""; }
}

Object getDispatch_rec(String iwhat)
{
	sqlstm = "select * from pickupdisp where origid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

/**
 * Get location/Bin from StockList by Itemcode/serial-no.
 * @param  isnum the serial no.
 * @return the Bin/location
 */
String getInventoryLastLoca(String isnum)
{
	sqlstm = "select Bin from StockList where Itemcode='" + isnum + "';";
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	try { return kiboo.checkNullString( r.get("Bin") ); } catch (Exception e) { return ""; }
}

void massDisableComponents(Object[] icomps, boolean iwhat)
{
	for(i=0;i<icomps.length;i++)
	{
		icomps[i].setDisabled(iwhat);
	}
}

void popuListitems_Data(ArrayList ikb, String[] ifl, Object ir)
{
	for(i=0; i<ifl.length; i++)
	{
		kk = ir.get(ifl[i]);
		if(kk == null) kk = "";
		else
		if(kk instanceof Date) kk = dtf2.format(kk);
		else
		if(kk instanceof Integer || kk instanceof Double) kk = nf0.format(kk);
		else
		if(kk instanceof Float || kk instanceof Long || kk instanceof BigDecimal) kk = kk.toString();
		else
		if(kk instanceof Boolean) kk = (kk == true) ? "Y" : "N";
		ikb.add( kk );
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
		}
		catch (Exception e) {}
		
		if(iob[i] instanceof Datebox && rdt[i].equals("")) rdt[i]="1900-01-01";
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
			if(kk instanceof Date) kk = dtf.format(kk);
			else
			if(kk instanceof Integer || kk instanceof Double || kk instanceof Long) kk = kk.toString();
			else
			if(kk instanceof Float) kk = nf2.format(kk);

			iob[i].setValue(kk);
		}

		if(iob[i] instanceof Listbox) lbhand.matchListboxItems( iob[i], kiboo.checkNullString( ir.get(ifl[i]) ) );
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

// itype: 1=width, 2=height
gpMakeSeparator(int itype, String ival, Object iparent)
{
	sep = new Separator();
	if(itype == 1) sep.setWidth(ival);
	if(itype == 2) sep.setHeight(ival);
	sep.setParent(iparent);
}

Textbox gpMakeTextbox(Object iparent, String iid, String ivalue, String istyle, String iwidth)
{
	Textbox retv = new Textbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) retv.setValue(ivalue);
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	retv.setParent(iparent);
	return retv;
}

Intbox gpMakeIntbox(Object iparent, String iid, String ivalue, String istyle, String iformat, String iwidth)
{
	Intbox retv = new Intbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) retv.setValue(ivalue);
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	if(!iformat.equals("")) retv.setFormat(iformat);
	retv.setParent(iparent);
	return retv;
}

Decimalbox gpMakeDecimalbox(Object iparent, String iid, String ivalue, String istyle, String iformat, String iwidth)
{
	Decimalbox retv = new Decimalbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) { kk = new java.math.BigDecimal(ivalue); retv.setValue(kk); }
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	if(!iformat.equals("")) retv.setFormat(iformat);
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

Datebox gpMakeDatebox(Object iparent, String iid, String iformat, String istyle)
{
	Datebox retv = new Datebox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!iformat.equals("")) retv.setFormat(iformat);
	retv.setParent(iparent);
	return retv;
}

/**
 * TODO Need to move this into byte-compiled
 * @param  itbn                  [description]
 * @param  ifl                   [description]
 * @param  ilb                   [description]
 * @throws java.sql.SQLException [description]
 */
void fillListbox_uniqField(String itbn, String ifl, Listbox ilb) throws java.sql.SQLException
{
	ilb.getItems().clear();
	ListboxHandler lbhand = new ListboxHandler();
	String sqlstm = "select distinct " + ifl + " from " + itbn;
	ArrayList r = gpWMS_GetRows(sqlstm);
	if(r.size() == 0) return;
	String[] kabom = new String[1];
	String dk; GroovyRowResult kk;
	for(Object d : r)
	{
		kk = (GroovyRowResult)d;
		dk = (String)kk.get(ifl);
		if(dk != null)
		{
			kabom[0] = dk;
			lbhand.insertListItems(ilb,kabom,"false","");
		}
	}
	ilb.setSelectedIndex(0);
}

void fillComboboxUniq(String itbn, String ifield, Combobox icombo) throws java.sql.SQLException
{
	Generals kiboo = new Generals();
	GridHandler gridhand = new GridHandler();

	String isqlstm = "select distinct " + ifield + " from " + itbn;

	ArrayList recs = gpWMS_GetRows(isqlstm);
	if(recs.size() == 0) return;

	// clear any previous comboitem if any
	Object[] remi = icombo.getItems().toArray();
	Comboitem myk;
	for(int i=0; i<remi.length; i++)
	{
		myk = (Comboitem)remi[i]; 
		myk.setParent(null);
	}

	ArrayList kabom = new ArrayList();
	for( Object d : recs)
	{
		GroovyRowResult kk = (GroovyRowResult)d;
		kabom.add( kiboo.checkNullString( (String)kk.get(ifield)) );
	}
	gridhand.makeComboitem(icombo, kiboo.convertArrayListToStringArray(kabom) );
}

/**
 * Put numbering for certain column in a listbox - can be used by other modu
 * @param tlb      the listbox to meddle
 * @param icolumn  column to change
 * @param istartn  starting number
 * @param iwithdot true=put "." after numbering, false=no "."
 */
void renumberListbox(Listbox tlb, int icolumn, int istartn, boolean iwithdot)
{
	try
	{
		lbs = tlb.getItems().toArray();
		tnum = istartn;
		for(i=0;i<lbs.length;i++)
		{
			bs = (tnum+i).toString() + ( (iwithdot) ? "." : "" );
			lbhand.setListcellItemLabel(lbs[i],icolumn,bs);
		}
	} catch (Exception e) {}
}

/**
 * [removeItemcodes description]
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void removeItemcodes(Div lbholder, String lbid)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return;
	ts = newlb.getSelectedItems().toArray();
	if(ts.length == 0) return;

	if(Messagebox.show("Remove all the selected items..", "Are you sure?",
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	for(i=0;i<ts.length;i++)
	{
		ts[i].setParent(null);
	}
	renumberListbox(newlb,0,1,true);
}

/**
 * Recalculate subtotal by listbox items , will set cell item to "0" if not number
 * More flexible, able to calc subtotal for single list-item or the whole listbox
 * @param isel      single list-item or listbox to process
 * @param qtypos    quantity column
 * @param upricepos unit-price column
 * @param subtotpos sub-total column, put qty * unitprice
 */
void recalcSubtotal(Object isel, int qtypos, int upricepos, int subtotpos)
{
	Object[] ts = new Object[1];

	if(isel instanceof Listbox) ts = isel.getItems().toArray();
	else ts[0] = isel;

	for(i=0;i<ts.length;i++)
	{
		qty = 0;
		try { qty = Integer.parseInt(lbhand.getListcellItemLabel(ts[i],qtypos)); } catch (Exception e) { lbhand.setListcellItemLabel(ts[i],qtypos,"0"); }
		uprice = 0.0;
		try { uprice = Float.parseFloat(lbhand.getListcellItemLabel(ts[i],upricepos)); } catch (Exception e) { lbhand.setListcellItemLabel(ts[i],upricepos,"0"); }

		lbhand.setListcellItemLabel(ts[i],subtotpos, kiboo.nf2.format((qty * uprice)) );
	}
}

/**
 * Check listbox for duplicate items text, hi-lite using style passed
 * @param ilb     listbox to process
 * @param icol    column to check
 * @param ihilite hi-lite CSS style
 */
void checkListItemsDups(Listbox ilb, int icol, String ihilite)
{
	HashMap k = new HashMap();
	jk = ilb.getItems().toArray();
	for(i=0;i<jk.length;i++)
	{
		ck = lbhand.getListcellItemLabel(jk[i],icol);
		if(!k.containsKey(ck))
		{
			k.put(ck,1);
		}
		else
		{
			if(!ihilite.equals("")) jk[i].setStyle(ihilite);
		}
	}
}

/**
 * Calc grand-total from sub-total column in listbox
 * @param  ipilb     the listbox to process
 * @param  subtotpos subtotal column position
 * @param  ilabel    Label to update
 * @return           grand-total
 */
float gp_calcPOTotal(Listbox ipilb, int subtotpos, Label ilabel, String iprstr)
{
	if(ipilb.getItemCount() == 0) return (float)0.0;
	ts = ipilb.getItems().toArray();
	float retval = 0.0;
	for(i=0;i<ts.length;i++)
	{
		try { retval += Float.parseFloat( lbhand.getListcellItemLabel(ts[i],subtotpos) ); } catch (Exception e) {}
	}
	ilabel.setValue(iprstr + kiboo.nf2.format(retval)) ;
	return retval;
}

float gp_calcGST(Label itotal, float igst, Label ilabel, String iprstr)
{
	retval = 0.0;
	try { retval = Float.parseFloat(itotal.getValue().trim()) * igst; } catch (Exception e) {}
	ilabel.setValue(iprstr + kiboo.nf2.format(retval)) ;
	return (float)retval;
}

/**
 * [checkDuplicateItems description]
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 * @param icolumn  which column to check for dups
 * @return          how many dups found
 */
int checkDuplicateItems(Div lbholder, String lbid, int icolumn)
{
	prvlb = lbholder.getFellowIfAny(lbid);
	if(prvlb == null) return;
	ts = prvlb.getItems().toArray();
	if(ts.length == 0) return;

	HashMap dc = new HashMap();
	dupsfound = 0;

	for(i=0; i<ts.length; i++)
	{
		chk = lbhand.getListcellItemLabel(ts[i],icolumn);
		if(dc.containsKey(chk)) // dups found
		{
			ts[i].setStyle("background:#F35111");
			dupsfound++;
		}
		else
		{
			dc.put(chk,1); // not dups, add to hashmap
		}
	}
	return dupsfound;
}

/**
 * [setListcellItemStyle description]
 * @param ilbitem [description]
 * @param icolumn [description]
 * @param istyle  [description]
 */
void setListcellItemStyle(Listitem ilbitem, int icolumn, String istyle)
{
	List prevrc = ilbitem.getChildren();
	Listcell prevrc_2 = (Listcell)prevrc.get(icolumn); // get the second column listcell
	prevrc_2.setStyle(istyle);
}

int calcDayDiff(java.util.Date id1, java.util.Date id2)
{
	try
	{
		long diff = id2.getTime() - id1.getTime();
		long diffDays = diff / (24 * 60 * 60 * 1000);
		return (int)diffDays;
	}
	catch (Exception e) { return 0; }
}

/**
 * Check listbox column for empty list-item, if empty, return false. Else iterate till end, return true
 * lbholder : Div holder
 * lbid : listbox string ID
 * icolumn : column to check
*/
boolean checkListboxEmptyColumn(Div lbholder, String lbid, int icolumn)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return false;
	ts = newlb.getItems().toArray();
	if(ts.length == 0) return false;
	for(i=0;i<ts.length;i++)
	{
		ck = lbhand.getListcellItemLabel(ts[i],icolumn).trim();
		if(ck.equals("")) return false;
	}
	return true;
}

/**
 * Locate iwhat in ilb by icolumn - hilite and move listbox cursor to that position. Scan from bottom up - as moving to first item detected
 * Can use for other modu
 * @param ilb     the listbox to iterate
 * @param icolumn column to check
 * @param iwhat   what string to match
 * @param istyle hilite style
 */
void locateShiftListbox(Listbox ilb, int icolumn, String iwhat, String istyle)
{
	if(ilb.getItemCount() == 0) return; // nothing in listbox, return je
	ts = ilb.getItems().toArray();
	tock = iwhat.trim().toUpperCase();
	for(i=0;i<ts.length;i++)
	{
		ck = lbhand.getListcellItemLabel(ts[i],icolumn).trim().toUpperCase();
		if(ck.indexOf(tock) != -1) // match something..
		{
			ts[i].setStyle(istyle);
		}
	}
}

/**
 * // Nag-bar timer things - define the timer in calling module
	<div id="nagbar" style="background:#EDDB25">
			<hbox>
			<separator width="10px" />
			<label id="nagtext" multiline="true" sclass="blink" style="font-size:9px;font-weight:bold" />
		</hbox>
	</div>
	<timer id="nagtimer" delay="${NAG_TIMER_DELAY}" repeats="true" onTimer="nagtimerFunc()" />
 */
NAG_BAR_STYLE = "background:#EDDB25";
NAG_TIMER_DELAY = 5000;
nagcount = 0;

/**
 * Add nag text to nag-bar. Reset nagcount each time text added
 * @param inagtext text to be added
 */
void putNagText(String inagtext)
{
	k = nagtext.getValue();
	if(k.equals("")) k = inagtext;
	else k = k + "\n" + inagtext;
	nagcount = 0; nagtext.setValue(k);
}

/**
 * Nag-bar timer called by timer obj
 */
void nagtimerFunc()
{
	nagcount++;
	if(nagcount > 2) nagtext.setValue(""); 
}

/**
 * Get dispatch/pickup order no. link to work-order
 * @param iwo : the work-order no.
 * @return : dispatch/pickup no. else ""
 */
String getDispatch_byWorkOrder(String iwo)
{
	sqlstm = "select origid from pickupdisp where job_id=" + iwo;
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	return (r == null) ? "" : r.get("origid").toString();
}

/**
 * Check new stock-code exist in StockMasterDetails.stock_code
 * @param  :istk stock_code to check
 * @param  icategory [description]
 * @param  igroup    [description]
 * @param  iclass    [description]
 * @return :false not exist, true for exist
 */
boolean stockCodeExist(String istk, String icategory, String igroup, String iclass)
{
	retval = false;
	cq = "select stock_code from StockMasterDetails where stock_code='" + istk + "' " +
	"and Stock_Cat='" + icategory + "' and GroupCode='" + igroup + "' and ClassCode='" + iclass + "' limit 1;";
	r = sqlhand.rws_gpSqlFirstRow(cq);
	if(r != null) retval = true; // stock-code exists - return
	return retval;
}

/**
 * Get stock-master struct. category>group>class
 * @param  istkid stock-id
 * @return        struct string
 */
String getStockMasterStruct(String istkid)
{
	retval = "";
	sqlstm = "select Stock_Cat,GroupCode,ClassCode from StockMasterDetails where ID=" + istkid;
	d = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(d != null)
	{
		retval = kiboo.checkNullString(d.get("Stock_Cat")) + ">" + kiboo.checkNullString(d.get("GroupCode")) + ">" + kiboo.checkNullString(d.get("ClassCode"));
	}
	return retval;
}

String getStockMasterStruct_withstockcode(String istkid)
{
	retval = "";
	sqlstm = "select Stock_Cat,GroupCode,ClassCode,Stock_Code from StockMasterDetails where ID=" + istkid;
	d = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(d != null)
	{
		retval = kiboo.checkNullString(d.get("Stock_Cat")) + ">" + kiboo.checkNullString(d.get("GroupCode")) + ">" + 
		kiboo.checkNullString(d.get("ClassCode")) + "> " + kiboo.checkNullString(d.get("Stock_Code"));
	}
	return retval;
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

/**
 * Get the next tblStockInMaster.grn_id , when null, return 1, the first GRN
 * @return the next grn_id
 */
String getNext_GRN_id()
{
	retval = "";
	sqlstm = "select max(grn_id)+1 as nextgrnid from tblStockInMaster;";
	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r.get("nextgrnid") == null) retval = "1";
	else retval = r.get("nextgrnid").toString();
	return retval;
}

/**
 * Get selected listbox items, column values. Either return quoted or unquoted string -
 * use in SQL statement or audit-log usually
 * @param  pLb     listbox with selected items
 * @param  pCol    which column to get value from
 * @param  pQuoted true=single-quote the value, false=no quote
 * @return         selected items value separated by comma and quoted/unquotec
 */
String getListbox_SelectedColValue(Listbox pLb, int pCol, boolean pQuoted)
{
	retval = "";
	ts = pLb.getSelectedItems().toArray();
	for(i=0; i<ts.length; i++)
	{
		tval = lbhand.getListcellItemLabel(ts[i],pCol);
		retval += ((pQuoted) ? ("'" + tval + "',") : (tval + ","));
	}
	try { retval = retval.substring(0,retval.length()-1); } catch (Exception e) {}
	return retval;
}
