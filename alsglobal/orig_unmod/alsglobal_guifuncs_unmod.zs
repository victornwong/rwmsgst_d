import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.image.*;
import org.zkoss.zk.ui.*;
import org.zkoss.util.media.AMedia;

import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFPrintSetup;

import org.victor.*;


/*
Purpose: Global GUI related functions we put them here
Written by : Victor Wong
Date : 11/08/2009

Notes:
getListcellItemLabel(
*/

kiboo = new Generals();

public class listboxHeaderObj
{
	public String header_str;
	public boolean header_visible;
	
	public listboxHeaderObj(String iheaderstr, boolean iheadvisible)
	{
		header_str = iheaderstr;
		header_visible = iheadvisible;
	}
}

public class listboxHeaderWidthObj
{
	public String header_str;
	public boolean header_visible;
	public String width;

	public listboxHeaderWidthObj(String iheaderstr, boolean iheadvisible, String iwidth)
	{
		header_str = iheaderstr;
		header_visible = iheadvisible;
		width = iwidth;
	}
}

// New class for creating listbox with db recs retrieval
public class dblb_HeaderObj
{
	public String header_str;
	public boolean header_visible;
	public String db_fieldname;
	public int db_fieldtype;

	// constructor: ifieldname = table fieldname, ifieldtype = field-type (1=varchar,2=int,3=date)
	public dblb_HeaderObj(String iheaderstr, boolean iheadvisible, String ifieldname, int ifieldtype)
	{
		header_str = iheaderstr;
		header_visible = iheadvisible;
		db_fieldname = ifieldname;
		db_fieldtype = ifieldtype;
	}
}

// Function to show pop-up message box, wrap for the system Messagebox.show class
void showMessageBox(String wmessage)
{
        Messagebox.show(wmessage,"Bong",Messagebox.OK,Messagebox.EXCLAMATION);
}

/****************************************************************************
TODO: ListboxHandler.java
Populate a listbox with items. Create new listcell for each string passed.
listbox can have multiple columns then.

Parameter:
wlistbox = listbox to populate
toput = string array to use
***************************************************************************
*/
void insertListItems(Listbox wlistbox, String[] toput, String dragdropCode)
{
	// 18/01/2010 - dragdropCode = for drag-drop function, to match name-identifier when dropped.
	if(dragdropCode.equals("")) dragdropCode = "true";

	Listitem litem = new Listitem();
	i = 0;

	for(tstr : toput)
	{
		Listcell lcell = new Listcell();
        tstr2 = tstr.trim();
		if(i == 0)
		{
			lcell.setDraggable(dragdropCode);
			i++;
		}
		
		lcell.setLabel(tstr2);
		// can modify
		lcell.setStyle("font-size:9px");
		lcell.setParent(litem);
	}
    // litem.setDraggable("true");
	litem.setParent(wlistbox);
}

// 1/4/2010: insert item into listbox but with dragdrop set to certain column
// icolumn = icolumn - 1 ( 1 = start)
// TODO: ListboxHandler.java
void insertListItems_DragDrop(Listbox wlistbox, String[] toput, String dragdropCode, int icolumn)
{
	if(dragdropCode.equals(""))
		dragdropCode = "true";

	Listitem litem = new Listitem();
	
	i = 0;
	iwcol = icolumn - 1;

	for(tstr : toput)
	{
		Listcell lcell = new Listcell();

        tstr2 = tstr.trim();
		
		if(i == iwcol)
			lcell.setDraggable(dragdropCode);
		
		lcell.setLabel(tstr2);
		// can modify
		lcell.setStyle("font-size:9px");
		lcell.setParent(litem);
		
		i++;
	}

    // litem.setDraggable("true");
	
	litem.setParent(wlistbox);
}

/****************************************************************************
TODO: ListboxHandler.java
Global func to insert drop-down items into a Listbox type "select"
wlistb = listbox object
iarray = single-dim strings array
eg:
	<listbox mold="select" rows="1" id="wowo" />
	String[] mearr = { "this", "and", "that", "equals", "to", "nothing" };
	populateDropdownListbox(wowo, mearr);
****************************************************************************
*/
void populateDropdownListbox(Listbox wlistb, String[] iarray)
{
	String[] strarray = new String[1];
	
	for(i=0; i < iarray.length; i++)
	{
		strarray[0] = iarray[i];
		insertListItems(wlistb,strarray,"true");
	}
	
	// set selected-index for listbox to the first item
	// can recode this section to be able to select item which matches the one passed in arg.
	wlistb.setSelectedIndex(0);
}

// link new window or panel to parentdiv_name Div
// winfn = window
// windId = window id , hardcoded usually in the other modules on how the newid would be
// uParams = parameters to be passed to the new window - coded in html-POST format - raw, no preprocessing in here
void globalActivateWindow(String parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);
	
	includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);
	
	setUserAccessObj(newinclude, uAO); // securityfuncs.zs
	
	Div contdiv = Path.getComponent("//als_portal_main/" + parentdiv_name);
	newinclude.setParent(contdiv);
	
} // end of globalActivateWindow()

// For those subwindows opened in Div .. getcomponent is hardcoded
void globalCloseWindow(String theincludeid)
{
	// refering back to main page, hardcoded for now.
	Div contdiv = Path.getComponent("//als_portal_main/miscwindows");
	Include thiswin = contdiv.getFellow(theincludeid);

	// just set the include source to empty, should remove this window
	thiswin.setSrc("");
    contdiv.removeChild(thiswin);
}

// For those panels opened in Div.. hardcoded id
void globalClosePanel(String theincludeid)
{
	// refering back to main page, hardcoded for now.
	Div contdiv = Path.getComponent("//als_portal_main/worksandbox");
	Include thiswin = contdiv.getFellow(theincludeid);

	// just set the include source to empty, should remove this window
	thiswin.setSrc("");
    contdiv.removeChild(thiswin);
}

void localActivateWindow(Div parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);
	
	includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);
	
	setUserAccessObj(newinclude, uAO); // securityfuncs.zs
	
	newinclude.setParent(parentdiv_name);
	
} // end of globalActivateWindow()

// TODO: ListboxHandler.java
// Match listbox item with iwhatstr on which icolumn, return Listitem so caller can get whichever column's label
Listitem matchListboxReturnListItem(Listbox ilb, String iwhatstr, int icolumn)
{
	retval = null;
	
	icc = ilb.getItemCount();
	if(icc == 0) return null; // nothing.. return

	for(i=0; i<icc; i++)
	{
		ilabel = ilb.getItemAtIndex(i);
		
		kkk = getListcellItemLabel(ilabel, icolumn);
		
		// if match found
		if(kkk.equals(iwhatstr))
		{
			retval = ilabel;
			break;
		}
	}
	return retval;
}

// general purpose func to match string to listbox item and set selected index
void matchListboxItems(Listbox ilb, String iwhich)
{
	icc = ilb.getItemCount();
	if(icc == 0) return; // nothing.. return

	// incase of no match found, set selected index to 0 - first item
	ilb.setSelectedIndex(0);
	
	ifound = false;
	
	for(i=0; i<icc; i++)
	{
		ilabel = ilb.getItemAtIndex(i);
		
		// if match found
		if(ilabel.getLabel().equals(iwhich))
		{
			ilb.setSelectedIndex(i);
			ifound = true;
			break;
		}
	}
	
	/*
	if(ifound)
		alert("found match : " + iwhich);
	else
		alert("no match : " + iwhich);
	*/
}

void matchListboxItemsColumn(Listbox ilb, String iwhich, int icolumn)
{
	icc = ilb.getItemCount();
	if(icc == 0) return; // nothing.. return

	// incase of no match found, set selected index to 0 - first item
	ilb.setSelectedIndex(0);

	ifound = false;

	for(i=0; i<icc; i++)
	{
		ilabel = ilb.getItemAtIndex(i);

		kkk = getListcellItemLabel(ilabel, icolumn);

		// if match found
		if(kkk.equals(iwhich))
		{
			ilb.setSelectedIndex(i);
			ifound = true;
			break;
		}
	}
}

// Make a random id for component - iprestr = prefix string
String makeRandomId(String iprestr)
{
	rannum = Math.round(Math.random() * 1000);
	retval = iprestr + rannum.toString();
	
	return retval;
}

// Insert a branch/leaf onto the tree
// ibranch : have to create manually this one in caller
// ilabel : label for the branch/leaf
// istyle : label style , css thang
Treeitem insertTreeLeaf(Treechildren ibranch, String ilabel, String istyle)
{
	Treeitem titem = new Treeitem();
	Treerow newrow = new Treerow();
	Treecell newcell1 = new Treecell();
	
	newcell1.setLabel(ilabel);
	
	if(!istyle.equals(""))
		newcell1.setStyle(istyle);

	newcell1.setParent(newrow);
	newrow.setParent(titem);
	titem.setParent(ibranch);
	
	return titem;
}

Treeitem insertTreeLeaf_Multi(Treechildren ibranch, String[] ilabel_array, String istyle)
{
	Treeitem titem = new Treeitem();
	Treerow newrow = new Treerow();
	
	String[] strarray = new String[1];
	
	for(i=0; i < ilabel_array.length; i++)
	{
		Treecell newcell1 = new Treecell();
		mylabel = ilabel_array[i];
		
		newcell1.setLabel(mylabel);
		
		if(!istyle.equals("")) newcell1.setStyle(istyle);

		newcell1.setParent(newrow);
	}

	newrow.setParent(titem);
	titem.setParent(ibranch);
	
	return titem;
}

// TODO: ListboxHandler.java
// Match item in listbox, set label for listitem
// iwhich = string to match in listbox
// cellpos = listcell position (starts 0)
// newlabel = label to set in this listcell
void matchItemUpdateLabel(Listbox ilistbox, String iwhich, int cellpos, String newlabel)
{
	for(i=0; i<ilistbox.getItemCount(); i++)
	{
		kkk = ilistbox.getItemAtIndex(i);
		kklbl = kkk.getLabel();
		
		if(kklbl.equals(iwhich))
		{
			kkchild = kkk.getChildren();
			kkchild.get(cellpos).setLabel(newlabel);
		}
	
	}
}

// TODO: ListboxHandler.java
// Set listitem -> listcell -> icolumn -> label
// icolumn: which column, 0 = column 1
void setListcellItemLabel(Listitem ilbitem, int icolumn, String iwhat)
{
	prevrc = ilbitem.getChildren();
	prevrc_2 = prevrc.get(icolumn); // get the second column listcell
	prevrc_2.setLabel(iwhat);
}

// TODO: ListboxHandler.java
// icolumn zero-start : 0 = column 1, 1 = column 2
// this one for listitem
String getListcellItemLabel(Listitem ilbitem, int icolumn)
{
	prevrc = ilbitem.getChildren();
	prevrc_2 = prevrc.get(icolumn);
	return prevrc_2.getLabel();
}

// Return treecell label - wcol=which column(0 start)
// 6/9/2010: try use this one
String getTreeItemLabel_Column(Treeitem titem, int wcol)
{
	retval = "";
	thechildren = titem.getChildren().toArray();
	if(thechildren.length > 0)
	{
		grandchildren = thechildren[0].getChildren().toArray();
		if(grandchildren.length >= wcol+1)
			retval = grandchildren[wcol].getLabel();
	}
	return retval;
}

// icolumn zero-start : 0 = column 1, 1 = column 2
// this one is used to get from Treeitem instead of Listitem .. hmmm, actually can combine them
// 8/7/2010: recode this bugga - scan treeitem.children
// 6/9/2010: dont use this one. need some debugging.
String getTreecellItemLabel(Treeitem ilbitem, int icolumn)
{
	done = false;
	retval = "";
	kkb = null;
	workme = ilbitem;

	while(!done)
	{
		thechildren = workme.getChildren().toArray();
		childsize = thechildren.length;
		for(i=0; i<childsize; i++)
		{
			kkb = thechildren[i];
			if(kkb instanceof Treerow) workme = kkb;

			if(kkb instanceof Treecell)
			{
				if(icolumn == i)
				{
					done = true;
					retval = kkb.getLabel();
				}
			}
		}
	}
	return retval;
}

// Trim list-item string.. to fit into a tiny-lil listbox
String trimListitemLabel(String istr, int maxleng)
{
	retval = istr;

	if(istr.length() > maxleng)
		retval = istr.substring(0,maxleng);

	return retval;
}

// 1/4/2010: check if iwhich is in ilb , can do column using icolumn (zero-start, check getListcellItem())
boolean ExistInListbox(Listbox ilb, String iwhich, int icolumn)
{
	icc = ilb.getItemCount();
	if(icc == 0) return false; // nothing.. return

	ifound = false;

	for(i=0; i<icc; i++)
	{
		ilabel = ilb.getItemAtIndex(i);
		
		kkk = getListcellItemLabel(ilabel, icolumn);
		
		// if match found
		if(kkk.equals(iwhich))
		{
			ifound = true;
			break;
		}
	}

	return ifound;
}

// 1/4/2010: remove an item from the listbox, iwhich = string to match, icolumn = which column to check iwhich (zero-start)
void removeItemFromListBox(Listbox ilb, String iwhich, int icolumn)
{
	icc = ilb.getItemCount();
	if(icc == 0) return false; // nothing.. return

	for(i=0; i<icc; i++)
	{
		ilabel = ilb.getItemAtIndex(i);
		
		kkk = getListcellItemLabel(ilabel, icolumn);
		
		// if match found
		if(kkk.equals(iwhich))
		{
			// remove from listbox
			ilb.removeItemAt(i);
			break;
		}
	}

}

// Make a listbox with headers - headers stuff def in listboxHeaderObj
// mDiv = where to put the listbox
// listbox_headers = array of listboxHeaderObj
// ilistbox_id = listbox id
// numorows = how many rows to set for listbox
Listbox makeVWListbox(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows)
{
	// if there's previously a listbox, remove before adding a new one
	Listbox oldlb = mDiv.getFellowIfAny(ilistbox_id);
	if(oldlb != null) oldlb.setParent(null);

    Listbox newlb = new Listbox();
    newlb.setId(ilistbox_id);
    newlb.setVflex(true);
	Listhead newhead = new Listhead();
    newhead.setSizable(true);
    newhead.setParent(newlb);

	for(i=0; i < listbox_headers.length; i++)
	{
	    Listheader mehd = new Listheader();
	    mehd.setLabel(listbox_headers[i].header_str);
		mehd.setVisible(listbox_headers[i].header_visible);
		mehd.setSort("auto");
		mehd.setParent(newhead);
	}
	newlb.setRows(numorows);
	newlb.setParent(mDiv);
	return newlb;
}

// 12/10/2011: modded func that take width string to form column - uses class listboxHeaderWidthObj
Listbox makeVWListbox_Width(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows)
{
	// if there's previously a listbox, remove before adding a new one
	Listbox oldlb = mDiv.getFellowIfAny(ilistbox_id);

	if(oldlb != null) oldlb.setParent(null);

    Listbox newlb = new Listbox();
    newlb.setId(ilistbox_id);
    newlb.setVflex(true);
	Listhead newhead = new Listhead();
    newhead.setSizable(true);
    newhead.setParent(newlb);

	for(i=0; i < listbox_headers.length; i++)
	{
	    Listheader mehd = new Listheader();
	    mehd.setLabel(listbox_headers[i].header_str);
		mehd.setVisible(listbox_headers[i].header_visible);
		mehd.setSort("auto");
		if(!listbox_headers[i].width.equals("")) mehd.setWidth(listbox_headers[i].width);
		mehd.setParent(newhead);
	}
	newlb.setRows(numorows);
	newlb.setParent(mDiv);
	return newlb;
}

// Same as makeVWListbox but with footer string - to show number of recs or whatever
Listbox makeVWListboxWithFooter(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows, String footstring)
{
	thelb = makeVWListbox(mDiv,listbox_headers,ilistbox_id,numorows);
	Listfoot newfooter = new Listfoot();
	newfooter.setParent(thelb);
	Listfooter fd1 = new Listfooter();
	fd1.setLabel("Found:");
	fd1.setParent(newfooter);
	Listfooter fd2 = new Listfooter();
	fd2.setLabel(footstring);
	fd2.setParent(newfooter);
	return thelb;
}

// GUI func: knockoff from makeVWListBox and with database access thing
// db fieldtype : 1=varchar, 2=int, 3=date
Listbox makeVWListbox_onDB(Div mDiv, Object[] listbox_headers, String ilistbox_id, int numorows, Sql isql, String isqlstm)
{
	//kiboo = new Generals();

	thelb = makeVWListbox(mDiv,listbox_headers,ilistbox_id,numorows);
	dbrecs = isql.rows(isqlstm);
	if(dbrecs.size() == 0) { return thelb; } // no recs, just return a blank listbox
	for(dpi : dbrecs)
	{
		ArrayList kabom = new ArrayList();
		for(i=0; i < listbox_headers.length; i++)
		{
			ftyp = listbox_headers[i].db_fieldtype;
			ffname = listbox_headers[i].db_fieldname;
			thevalue = dpi.get(ffname);
			tobeadded = "---";
			if(thevalue != null)
			{
				tobeadded = thevalue;
				switch(ftyp)
				{
					case 2:
						tobeadded = thevalue.toString();
						break;
					case 3:
						tobeadded = thevalue.toString().substring(0,10);
						break;
				}
			}
			kabom.add(tobeadded);
		}
		strarray = kiboo.convertArrayListToStringArray(kabom);
		insertListItems(thelb,strarray,"false");
	}
	return thelb;
}

// 7/7/2010: Try and load an image - have to catch non-exist-file error
AImage loadShowImage(String ifilename)
{
	FileInputStream finstream = new FileInputStream(session.getWebApp().getRealPath(ifilename));
	filesiz = finstream.available();
	AImage retimage = new AImage("wiki",finstream);
	//finstream.close();
	return retimage;
}

// 26/8/2010: GUI funcs: make all listitems to accept
void setDoubleClick_ListItems(Listbox wlistbox, Object eventfunc)
{
	itmc = wlistbox.getItemCount();
	if(itmc == 0) return;

	for(i=0; i<itmc; i++)
	{
		woki = wlistbox.getItemAtIndex(i);
		woki.addEventListener("onDoubleClick", eventfunc);
	}
}

// 17/9/2010: GUI func: check if listbox exist in DIV and selected item in listbox
boolean check_ListboxExist_SelectItem(Div idiv, String lbid)
{
	retval = false;
	if(idiv.getFellowIfAny(lbid) != null)
	{
		Listbox kkb = idiv.getFellowIfAny(lbid);
		if(kkb.getSelectedIndex() != -1) retval = true;
	}

	return retval;
}

// 29/9/2010: remove whatever in a DIV by component-ID
void removeComponentInDiv(Div idiv, String compid)
{
	if(idiv.getFellowIfAny(compid) != null)
	{
		kkb = idiv.getFellow(compid);
		kkb.setParent(null);
	}
}

// 1/10/2010 : Export stuff in a listbox to Excel.xls - uses Apache POI
// idiv,lb_id = DIV where lb_id is in
// ifilename = to save in ./tmp/ifilename
// lbheader = listboxHeaderObj[]
// isheetname = the first-sheet name
// ioutdiv = to setparent of the Amedia compo.
// sheetsize = to set the ZOOM % in excel worksheet
void exportListboxExcel(Div idiv, String lb_id, String ifilename, Object[] lbheader, String isheetname, Div ioutdiv, int sheetsize)
{
	if(idiv.getFellowIfAny(lb_id) == null) return;

	Listbox thelistbox = idiv.getFellow(lb_id);
	itmcnt = thelistbox.getItemCount();
	if(itmcnt == 0) return;

	// Uses Apache POI stuff
	HSSFWorkbook wb = new HSSFWorkbook();
	thefn = session.getWebApp().getRealPath("tmp/" + ifilename);
	FileOutputStream fileOut = new FileOutputStream(thefn);
	sheet = wb.createSheet(isheetname);

	stylo = wb.createCellStyle();
	stylo.setFillBackgroundColor((short)999);

	// first row the listbox header thing lor
	row1 = sheet.createRow(0);
	for(i=0; i < lbheader.length; i++)
	{
		kkb = lbheader[i].header_str;
		hedc = row1.createCell(i);
		hedc.setCellValue(kkb);
		hedc.setCellStyle(stylo);
	}
	
	cellstylo = wb.createCellStyle();
	cellstylo.setWrapText(true);

	// loop through listbox, output stuff into excel file
	for(i=0; i<itmcnt; i++)
	{
		selitem = thelistbox.getItemAtIndex(i);
		row = sheet.createRow(i+1);

		for(j=0; j<lbheader.length; j++)
		{
			thevalue = getListcellItemLabel(selitem,j);
			row.createCell(j).setCellValue(thevalue);
			sheet.autoSizeColumn(j);
		}
	}
	
	ps = sheet.getPrintSetup();
	ps.setScale((short)sheetsize);

	wb.write(fileOut);
	fileOut.close();

	// long method to let user download a file	
	File f = new File(thefn);
	fileleng = f.length();
	finstream = new FileInputStream(f);
	byte[] fbytes = new byte[fileleng];
	finstream.read(fbytes,0,(int)fileleng);

	AMedia amedia = new AMedia(ifilename, "xls", "application/vnd.ms-excel", fbytes);
	Iframe newiframe = new Iframe();
	newiframe.setParent(ioutdiv);
	newiframe.setContent(amedia);
}

// 11/10/2010 : Export stuff in a listbox to Excel.xls - uses Apache POI - additional parameter
// idiv,lb_id = DIV where lb_id is in
// ifilename = to save in ./tmp/ifilename
// lbheader = listboxHeaderObj[]
// isheetname = the first-sheet name
// ioutdiv = to setparent of the Amedia compo.
// sheetsize = to set the ZOOM % in excel worksheet
// showhidden = show hidden listbox header/items
void exportListboxExcel_HideColumn(Div idiv, String lb_id, String ifilename, Object[] lbheader, String isheetname, Div ioutdiv, int sheetsize, boolean showhidden)
{
	if(idiv.getFellowIfAny(lb_id) == null) return;

	Listbox thelistbox = idiv.getFellow(lb_id);
	itmcnt = thelistbox.getItemCount();
	if(itmcnt == 0) return;

	// Uses Apache POI stuff
	HSSFWorkbook wb = new HSSFWorkbook();
	thefn = session.getWebApp().getRealPath("tmp/" + ifilename);
	FileOutputStream fileOut = new FileOutputStream(thefn);
	sheet = wb.createSheet(isheetname);

	stylo = wb.createCellStyle();
	stylo.setFillBackgroundColor((short)999);

	// first row the listbox header thing lor
	row1 = sheet.createRow(0);
	for(i=0; i < lbheader.length; i++)
	{
		// don't create column/header if header_visible=false
		if(lbheader[i].header_visible)
		{
			kkb = lbheader[i].header_str;
			hedc = row1.createCell(i);
			hedc.setCellValue(kkb);
			hedc.setCellStyle(stylo);
		}
	}
	
	cellstylo = wb.createCellStyle();
	cellstylo.setWrapText(true);

	// loop through listbox, output stuff into excel file
	for(i=0; i<itmcnt; i++)
	{
		selitem = thelistbox.getItemAtIndex(i);
		row = sheet.createRow(i+1);	

		for(j=0; j<lbheader.length; j++)
		{
			if(lbheader[j].header_visible)
			{
				thevalue = getListcellItemLabel(selitem,j);
				row.createCell(j).setCellValue(thevalue);
				sheet.autoSizeColumn(j);
			}
		}
	}
	
	ps = sheet.getPrintSetup();
	ps.setScale((short)sheetsize);

	wb.write(fileOut);
	fileOut.close();

	// long method to let user download a file	
	File f = new File(thefn);
	fileleng = f.length();
	finstream = new FileInputStream(f);
	byte[] fbytes = new byte[fileleng];
	finstream.read(fbytes,0,(int)fileleng);

	AMedia amedia = new AMedia(ifilename, "xls", "application/vnd.ms-excel", fbytes);
	Iframe newiframe = new Iframe();
	newiframe.setParent(ioutdiv);
	newiframe.setContent(amedia);
}

// Make a new label component and attach to parent
void makeLabelToParent(String ivalue, String istyle, Object iparent)
{
	thelabel = new Label();
	thelabel.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	thelabel.setStyle(istyle);
	thelabel.setParent(iparent);
}

// Make a new label component and attach to parent
void makeLabelMultilineToParent(String ivalue, String istyle, Object iparent)
{
	thelabel = new Label();
	thelabel.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	thelabel.setStyle(istyle);
	thelabel.setMultiline(true);
	thelabel.setParent(iparent);
}

// <GRID> related : make <ROWS> object
Object gridMakeRows(String theid, String istyle, Object iparent)
{
	therows = new Rows();
	if(!istyle.equals("")) therows.setStyle(istyle);
	if(!theid.equals("")) therows.setId(theid);
	therows.setParent(iparent);
	return therows;
}

// <GRID> related : make <ROW> object
Object gridMakeRow(String theid, String istyle, String ispans, Object iparent)
{
	therow = new Row();
	if(!istyle.equals("")) therow.setStyle(istyle);
	if(!theid.equals("")) therow.setId(theid);
	if(!ispans.equals("")) therow.setSpans(ispans);
	therow.setParent(iparent);
	return therow;
}

Object makeTextboxToParent(String ivalue, String istyle, String iwidth, String iheight, boolean imultiline, Object iparent)
{
	thetextbox = new Textbox();
	thetextbox.setValue(ivalue);
	if(istyle.equals("")) istyle="font-size:9px";
	
	if(imultiline)
	{
		thetextbox.setMultiline(imultiline);
		thetextbox.setHeight(iheight);
	}
			
	if(!iwidth.equals("")) thetextbox.setWidth(iwidth);
	thetextbox.setStyle(istyle);
	thetextbox.setParent(iparent);

	return thetextbox;
}

// class copied from ZK website for comparing stuff - works for <grid><column>
class Comp implements Comparator
{
	private boolean _asc;
	private int _columnindex;

	public Comp(boolean asc, int icolm)
	{
		_asc = asc;
		_columnindex = icolm;
	}

	public int compare(Object o1, Object o2)
	{
		String s1 = o1.getChildren().get(_columnindex).getValue(),
			s2 = o2.getChildren().get(_columnindex).getValue();
		int v = s1.compareTo(s2);
		return _asc ? v: -v;
	}
}

void makeGridHeaderColumns(String[] icols, Object iparent)
{
	colms = new Columns();
	for(i=0; i<icols.length; i++)
	{
		hcolm = new Column();
		hcolm.setLabel(icols[i]);

		Comp asc = new Comp(true,i);
		Comp dsc = new Comp(false,i);

		hcolm.setSortAscending(asc);
		hcolm.setSortDescending(dsc);

		hcolm.setStyle("font-size:9px");
		hcolm.setParent(colms);	
	}
	colms.setParent(iparent);
}

// Create and attach Comboitem to Combobox .. uses string-array iwhat
void makeComboitem(Object icombobox, String[] iwhat)
{
	for(i=0;i<iwhat.length;i++)
	{
		citem = new Comboitem();
		citem.setLabel(iwhat[i]);
		citem.setParent(icombobox);
	}	
}

// knock-off from above, but with ID string and parent obj
void makeComboitem2(Object icombobox, String[] iwhat, String itheid, Object itheparent)
{
	for(i=0;i<iwhat.length;i++)
	{
		citem = new Comboitem();
		citem.setLabel(iwhat[i]);
		citem.setParent(icombobox);
	}

	icombobox.setStyle("font-size:9px");
	icombobox.setId(itheid);
	icombobox.setParent(itheparent);
}

// Make blank-label to fill-up column in <grid><rows><row>
void grid_makeBlankColumn(Object theparent, int howmany)
{
	for(i=0;i<howmany;i++)
		makeLabelToParent("","",theparent);
}

// 10/01/2012: lookup space-separated string to tick items
void findAndTick(Object ilistbox, String istring, String isepchar)
{
	splito = istring.split(isepchar);
	
	for(i=0; i < splito.length; i++)
	{
		spitem = splito[i];
		
		for(j=0; j < ilistbox.getItemCount(); j++)
		{
			lbitem = ilistbox.getItemAtIndex(j);
			titem = lbitem.getLabel();
			
			if(titem.equals(spitem)) ilistbox.toggleItemSelection(lbitem);
		}
	}
}

// 02/03/2012: grab name,disptext from lookups to populate listbox
// iwhich: 1=show names, 2=show disptext
void populateListbox_ByLookup(Object ilistbox, String ilookname, int iwhich)
{
	sql = als_mysoftsql();
	if(sql == null ) return;

	sqlstm = "select name,disptext from lookups where " + 
	"myparent = cast((select idlookups from lookups where name='" + ilookname + "') as varchar) " +
	"and expired=0 order by name,disptext";

	retvs = sql.rows(sqlstm);
	sql.close();
	if(retvs.size() == 0) return;

	// remove previous list-items
	if(ilistbox.getChildren() != null)
	{
		woo = ilistbox.getChildren().toArray();
		for(i=0; i<woo.length; i++)
		{
			ilistbox.removeChild(woo[i]);
		}
	}

	String[] strarray = new String[1];

	for(dpi : retvs)
	{
		strarray[0] = (iwhich == 1) ? dpi.get("name") : dpi.get("disptext");
		insertListItems(ilistbox,strarray,"true");
	}

	ilistbox.setSelectedIndex(0);
}

// 06/03/2012: grab name,disptext from lookups to populate checkboxes
// iwhich: 1=show names, 2=show disptext
void populateCheckbox_ByLookup(Object iboxholder, String ilookname, String istyle, int iwhich)
{
	sql = als_mysoftsql();
	if(sql == null ) return;

	sqlstm = "select name,disptext from lookups where " + 
	"myparent = cast((select idlookups from lookups where name='" + ilookname + "') as varchar) " +
	"and expired=0 order by name,disptext";

	retvs = sql.rows(sqlstm);
	sql.close();
	if(retvs.size() == 0) return;

	// remove previous items
	if(iboxholder.getChildren() != null)
	{
		woo = iboxholder.getChildren().toArray();
		for(i=0; i<woo.length; i++)
		{
			iboxholder.removeChild(woo[i]);
		}
	}

	for(dpi : retvs)
	{
		chkboxstr = (iwhich == 1) ? dpi.get("name") : dpi.get("disptext");
		chkbox = new Checkbox(chkboxstr);
		chkbox.setStyle(istyle);
		chkbox.setParent(iboxholder);
	}
}

// 06/03/2012: Save checkboxes in holder which are ticked into string, separated by ~
String saveCheckboxTicked(Object iholder)
{
	ett = "";
	woo = iholder.getChildren().toArray();
	for(i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			if(woo[i].isChecked()) ett += woo[i].getLabel() + "~";
		}
	}

	if(ett.equals("")) return "";
	return ett.substring(0,ett.length()-1);
}

// 06/03/2012: Untick whatever checkboxes in holder
void clearCheckboxTicked(Object iholder)
{
	woo = iholder.getChildren().toArray();
	for(i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox) woo[i].setChecked(false);
	}
}

// 06/03/2012: Tick checkboxes in holder by itickstring, eg "kaka~kiki" produced by saveCheckboxTicked()
void tickCheckboxes(Object iholder, String itickstring)
{
	woo = iholder.getChildren().toArray();
	for(i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox)
		{
			if(itickstring.indexOf(woo[i].getLabel()) != -1) woo[i].setChecked(true);
		}
	}
}

// 06/03/2012: toggle disabled flag for whatever checkboxes in holder
void disableCheckboxTicked(Object iholder, boolean iwhat)
{
	woo = iholder.getChildren().toArray();
	for(i=0; i<woo.length; i++)
	{
		if(woo[i] instanceof Checkbox) woo[i].setDisabled(iwhat);
	}
}

