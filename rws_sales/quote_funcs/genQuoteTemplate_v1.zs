// Generate quotation in excel-output - pretty hardcoded for RW only

void genPrintQuote(String iqt)
{
	qtr = getQuotation_rec(iqt);
	if(qtr == null) { guihand.showMessageBox("DBERR: Cannot access quotations database"); return; }

	vnm = (qtr.get("version") == null) ? "0" : qtr.get("version").toString();

	rwqtstr = QUOTE_PREFIX + qtr.get("origid").toString() + " (" + vnm + ")";

	templatefn = "rwimg/rwqt_general_v1.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	CellStyle tcellstyle =  excelWB.createCellStyle();
	tcellstyle.setAlignment(CellStyle.ALIGN_CENTER);
	tcellstyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
	tcellstyle.setFont(wfont);
	tcellstyle.setBorderLeft(CellStyle.BORDER_THIN);
	tcellstyle.setBorderRight(CellStyle.BORDER_THIN);
	tcellstyle.setBorderTop(CellStyle.BORDER_THIN);
	tcellstyle.setBorderBottom(CellStyle.BORDER_THIN);
	
	CellStyle pistyle =  excelWB.createCellStyle();
	pistyle.cloneStyleFrom(tcellstyle);
	pistyle.setAlignment(CellStyle.ALIGN_LEFT);
	pistyle.setWrapText(true);

	excelInsertString(sheet,0,1, kiboo.checkNullString(qtr.get("customer_name")) );
	excelInsertString(sheet,1,1, kiboo.checkNullString(qtr.get("cust_address")) );
	excelInsertString(sheet,5,1, kiboo.checkNullString(qtr.get("contact_person1")) );
	excelInsertString(sheet,6,1, kiboo.checkNullString(qtr.get("telephone")) + " / " + kiboo.checkNullString(qtr.get("email")) );

	excelInsertString(sheet,0,6, rwqtstr );
	excelInsertString(sheet,1,6, dtf2.format(qtr.get("datecreated")) );
	excelInsertString(sheet,2,6, kiboo.checkNullString(qtr.get("qt_validity")) );
	excelInsertString(sheet,3,6, kiboo.checkNullString(qtr.get("username")) );

	lnc = 1;
	rowc = 10;
	gtotal = 0.0;

	if( !sqlhand.clobToString(qtr.get("q_items")).equals("") )
	{
		idesc = sqlhand.clobToString(qtr.get("q_items")).split("~");
		ispec = sqlhand.clobToString(qtr.get("q_items_desc")).split("~");
		iqty = sqlhand.clobToString(qtr.get("q_qty")).split("~");
		iupr = sqlhand.clobToString(qtr.get("q_unitprice")).split("~");
		idisc = sqlhand.clobToString(qtr.get("q_discounts")).split("~");
		iper = sqlhand.clobToString(qtr.get("q_rental_periods")).split("~");

		irams = sqlhand.clobToString(qtr.get("q_rams")).split("~");
		ihdd = sqlhand.clobToString(qtr.get("q_hdd")).split("~");
		ios = sqlhand.clobToString(qtr.get("q_operatingsystem")).split("~");
		imso = sqlhand.clobToString(qtr.get("q_office")).split("~");

		for(i=0; i<idesc.length; i++)
		{
			tdesc = ""; try { tdesc = idesc[i]; } catch (Exception e) {}
			ispcs = ""; try { ispcs = ispec[i]; if(ispcs.equals("THE DETAIL SPECS")) ispcs = ""; } catch (Exception e) {}
			jhdd = ""; try { jhdd = ihdd[i]; } catch (Exception e) {}
			jram = ""; try { jram = irams[i]; } catch (Exception e) {}
			jios = ""; try { jios = ios[i]; if(jios.equals("NONE")) jios = ""; } catch (Exception e) {}
			jmso = ""; try { jmso = imso[i]; if(jmso.equals("NONE")) jmso = ""; } catch (Exception e) {}
			qtys = ""; try { qtys = iqty[i]; } catch (Exception e) {}
			upric = ""; try { upric = iupr[i]; } catch (Exception e) {}
			tper = ""; try { tper = iper[i]; } catch (Exception e) {}
			disct = ""; try { disct = idisc[i]; } catch (Exception e) {}

			fulldesc = tdesc +
			((ispcs.equals("")) ? "" : "\n" + ispcs) +
			((jhdd.equals("")) ? "" : "\nHDD: " + jhdd) +
			((jram.equals("")) ? "" : "\nRAM: " + jram) +
			((jios.equals("")) ? "" : "\nOS: " + jios) +
			((jmso.equals("")) ? "" : "\nMSO: " + jmso);

			excelInsertString(sheet,rowc,0,lnc.toString() + ".");

			mde = excelInsertString(sheet,rowc,1, fulldesc);
			//mrw = mde.getRow();
			//mrw.setHeightInPoints((5*sheet.getDefaultRowHeightInPoints()));
			mde.setCellStyle(pistyle);

			excelInsertString(sheet,rowc,2, qtys);
			excelInsertString(sheet,rowc,3, upric);
			excelInsertString(sheet,rowc,4, tper);
			excelInsertString(sheet,rowc,5, disct);

			cqty = 0; try { cqty = Integer.parseInt(qtys); } catch (Exception e) {}
			cuprice = 0.0; try { cuprice = Float.parseFloat(upric); } catch (Exception e) {}
			cdiscount = 0.0; try { cdiscount = Float.parseFloat(disct); } catch (Exception e) {}
			crentp = 1; try { crentp = Integer.parseInt(tper); } catch (Exception e) {}
			subtot = ((cqty * cuprice) - (cqty * cdiscount)) * crentp;
			gtotal += subtot;
			excelInsertString(sheet,rowc,6, nf2.format(subtot));

			rowc++; lnc++;
		}
	}

	sheet.autoSizeColumn((short)2);

	// Put the quote grand-total
	curcode = kiboo.checkNullString(qtr.get("curcode"));
	if(curcode.equals("")) curcode = "MYR";
	sheet.addMergedRegion(new CellRangeAddress(rowc,rowc,4,5));
	excelInsertString(sheet,rowc,4,"GRAND TOTAL: " + curcode);
	excelInsertString(sheet,rowc,6, nf2.format(gtotal) );

	POI_SetCellStyleRange(sheet,tcellstyle,rowc,4,6);
	POI_SetCellStyleRange(sheet,tcellstyle,rowc,6,7);

	for(i=10;i<rowc;i++) // do 'em border-lines for the items
	{
		POI_SetCellStyleRange(sheet,tcellstyle,i,0,1);
		//POI_SetCellStyleRange(sheet,tcellstyle,i,1,2);
		POI_SetCellStyleRange(sheet,tcellstyle,i,2,3);
		POI_SetCellStyleRange(sheet,tcellstyle,i,3,4);
		POI_SetCellStyleRange(sheet,tcellstyle,i,4,5);
		POI_SetCellStyleRange(sheet,tcellstyle,i,5,6);
		POI_SetCellStyleRange(sheet,tcellstyle,i,6,7);
	}

	tfname = rwqtstr + "_outp.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();
	downloadFile(kasiexport,tfname,outfn);

}