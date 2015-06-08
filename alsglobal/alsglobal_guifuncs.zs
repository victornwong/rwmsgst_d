import java.io.*;
/*
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.image.*;
import org.zkoss.zk.ui.*;
*/

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
*/

kiboo = new Generals();
lbhand = new ListboxHandler();

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
			thevalue = lbhand.getListcellItemLabel(selitem,j);
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
				thevalue = lbhand.getListcellItemLabel(selitem,j);
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

