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

Sql wms_Sql()
{
	String dbstring = "jdbc:mysql://localhost:3306/wms";
	try { return Sql.newInstance(dbstring, "wmsuser", "1qaz", "com.mysql.jdbc.Driver"); } catch (Exception e) { return null; }

	// ?useUnicode=true&characterEncoding=UTF-8
	//String dbstring = "jdbc:mysql://vwdbinstanceoregon.cxadgyaubug5.us-west-2.rds.amazonaws.com:3306/wfmdb?useUnicode=true&characterEncoding=UTF-8";
}

void gpWMS_execute(String isqlstm)
{
	Sql sql = wms_Sql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

ArrayList gpWMS_GetRows(String isqlstm)
{
	Sql sql = wms_Sql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

GroovyRowResult gpWMS_FirstRow(String isqlstm)
{
	Sql sql = wms_Sql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
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
