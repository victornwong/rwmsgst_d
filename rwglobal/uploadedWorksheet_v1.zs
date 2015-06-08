import java.util.*;
import java.text.*;
import java.io.*;

import org.apache.poi.xssf.usermodel.*;
import org.apache.poi.ss.util.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.hssf.usermodel.*;

import org.zkoss.zul.*;

public class uploadedWorksheet
{
	Object thefiledata;
	String thefilename,thecontenttype,theformat;

	public uploadedWorksheet()
	{
		thefiledata = null; // always null file-data
		thefilename = "";
		thecontenttype = "";
		theformat = "";
	}

	// Simple func to allow user upload something to server
	public void getUploadFileData()
	{
		uploaded_file = Fileupload.get(true);
		if(uploaded_file == null) { thefiledata = null; return; }

		theformat = uploaded_file.getFormat();
		thecontenttype = uploaded_file.getContentType();
		thefilename = uploaded_file.getName();

		int fileLength = 0;

		f_inmemory = uploaded_file.inMemory();
		f_isbinary = uploaded_file.isBinary();

		if(f_inmemory && f_isbinary)
		{
		//ByteArrayInputStream upfluf = new ByteArrayInputStream(uploaded_fluff);
			thefiledata = new ByteArrayInputStream(uploaded_file.getByteData());
			//alert("dddddd");
		}
		else
		{
			someff = uploaded_file.getStreamData(); // 14/08/2012: save uploaded file into byte[]
			fileLength = someff.available();
			thefiledata = new byte[fileLength];
			someff.read(thefiledata,0,fileLength);
		}
	}
} // ENDOF public class uploadedWorksheet

// General purpose func to get cell-content, based on POI guide. Won't do formula-cell
String POI_GetCellContentString(HSSFCell icell, FormulaEvaluator formeval, String numformat)
{
	String retval = "";
	DecimalFormat nf = new DecimalFormat(numformat);
	SimpleDateFormat sdfSource = new SimpleDateFormat("yyyy-MM-dd");

	switch(icell.getCellType())
	{
		case HSSFCell.CELL_TYPE_STRING:
			retval = icell.getRichStringCellValue().getString();
			break;

		case HSSFCell.CELL_TYPE_NUMERIC:
			if(DateUtil.isCellDateFormatted(icell))
			{
				retval = sdfSource.format(icell.getDateCellValue());
				//retval = icell.getRichStringCellValue().getString();
			}
			else
			{
				//alert("non-formula numeric");
				retval = nf.format( icell.getNumericCellValue() );
			}
			break;
			
		case HSSFCell.CELL_TYPE_FORMULA:
			cellval = formeval.evaluate(icell);
			//alert("formula celltype: " + cellval.getCellType() );

			switch(cellval.getCellType())
			{
				case HSSFCell.CELL_TYPE_STRING:
					retval = cellval.getStringValue();
					break;

				case HSSFCell.CELL_TYPE_NUMERIC:
				try
				{
					if(DateUtil.isCellDateFormatted(icell))
					{
						//alert("formula date");
						retval = sdfSource.format(icell.getDateCellValue());
					}
					else
					{
						//alert("formula numeric");
						retval = nf.format( cellval.getNumberValue() );
						//retval = nf.format( cellval.getCellFormula() );
					}
				}
				catch (java.lang.IllegalStateException e)
				{
				//alert("formula-numeric-exception");
				retval = cellval.formatAsString();
				}

					break;
			}
			break;
	}

	return retval;

} // ENDOF POI_GetCellContentString()

HSSFCell excelInsertString(Sheet isheet, int irow, int icol, String iwhat)
{
	org.apache.poi.hssf.usermodel.HSSFRow row = isheet.getRow(irow);
	if(row == null) row = isheet.createRow(irow);
	//row.setHeightInPoints((4*isheet.getDefaultRowHeightInPoints()));
	HSSFCell cell = row.getCell(icol);
	if(cell == null) cell = row.createCell(icol);
	cell.setCellType(Cell.CELL_TYPE_STRING);
	cell.setCellValue(iwhat);
	return cell;
}

HSSFCell excelInsertNumber(Sheet isheet, int irow, int icol, String iwhat)
{
	parwb = isheet.getWorkbook();

	org.apache.poi.hssf.usermodel.HSSFRow row = isheet.getRow(irow);
	if(row == null) row = isheet.createRow(irow);
	HSSFCell cell = row.getCell(icol);
	if(cell == null) cell = row.createCell(icol);
	cell.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
	if(iwhat.equals(""))
	{
		cell.setCellType(HSSFCell.CELL_TYPE_STRING);
		cell.setCellValue(iwhat);
	}
	else
	{
		kdob = 0.0;
		try {
		kdob = Double.parseDouble(iwhat);
		} catch (Exception e) {}
		cell.setCellValue(kdob);
	}
	return cell;
}


// Funcs from POI-guide-page
void POI_CellSetAllBorders(HSSFWorkbook iwb, HSSFCell icell, Font ifont, boolean icenter, String inumf)
{
	if(inumf.equals("")) inumf = "###,##0.00";
	DataFormat numformat = iwb.createDataFormat();
	HSSFCellStyle style = iwb.createCellStyle();
	style.setDataFormat(numformat.getFormat(inumf));
	style.setFont(ifont);
	style.setWrapText(true);
	if(icenter) style.setAlignment(CellStyle.ALIGN_CENTER);
	style.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
	
	style.setBorderBottom(CellStyle.BORDER_THIN);
	//style.setBottomBorderColor(IndexedColors.BLACK.getIndex());
	style.setBorderLeft(CellStyle.BORDER_THIN);
	//style.setLeftBorderColor(IndexedColors.GREEN.getIndex());
	style.setBorderRight(CellStyle.BORDER_THIN);
	//style.setRightBorderColor(IndexedColors.BLUE.getIndex());
	style.setBorderTop(CellStyle.BORDER_THIN);
	//style.setTopBorderColor(IndexedColors.BLACK.getIndex());
	icell.setCellStyle(style);
}

void POI_CellSetBorders(HSSFWorkbook iwb, HSSFCell icell, Font ifont, int itop, int ibtm, int ileft, int iright, short ialign)
{
	HSSFCellStyle style = iwb.createCellStyle();
	if(itop == 1) style.setBorderTop(CellStyle.BORDER_THIN);
	if(ibtm == 1) style.setBorderBottom(CellStyle.BORDER_THIN);
	if(ileft == 1) style.setBorderLeft(CellStyle.BORDER_THIN);
	if(iright == 1) style.setBorderRight(CellStyle.BORDER_THIN);
	style.setAlignment(ialign);
	style.setFont(ifont);
	icell.setCellStyle(style);
}

void POI_SetCellStyleRange(HSSFSheet isheet, HSSFCellStyle istyle, int irow, int scost, int scend)
{
	org.apache.poi.hssf.usermodel.HSSFRow tRow = isheet.getRow(irow);
	if(tRow == null) tRow = isheet.createRow(irow);
	for(j=scost;j<scend;j++)
	{
		kcl = tRow.getCell(j);
		if(kcl == null) kcl = tRow.createCell(j);
		kcl.setCellStyle(istyle);
	}
}

// iwhat= listbox, iwhere= export-div, ilbhds= listbox headers, ioutfn= output filename, isheetname= excel sheet-name
void exportExcelFromListbox(Object iwhat, Object iwhere, Object ilbhds, String ioutfn, String isheetname)
{
	if(iwhat.getItemCount() == 0) return;

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet(isheetname);
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");
	rowcount = 0;

	for(i=0;i<ilbhds.length;i++)
	{
		POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,i,ilbhds[i].header_str),wfont,true,"");
	}

	rowcount++;
	rx = iwhat.getItems().toArray();

	for(i=0; i<rx.length; i++)
	{
		//cb = rx[i];
		for(j=0; j<ilbhds.length; j++)
		{

			try
			{
			kk = lbhand.getListcellItemLabel(rx[i],j);
			try
			{
				ck = Float.parseFloat(kk);
				excelInsertNumber(sheet,rowcount,j,kk);
			}
			catch (Exception e)
			{
				excelInsertString(sheet,rowcount,j,kk);
			}
			} catch (Exception e) {}
		}
		rowcount++;
	}
	//jjfn = "ProductAnalyReport.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + ioutfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();
	downloadFile(iwhere,ioutfn,outfn);

}

