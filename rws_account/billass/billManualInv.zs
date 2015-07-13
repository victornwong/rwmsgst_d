import org.victor.*;
// Manual invoice output with installment juggling and etc

Object getFC_RWMeta(String iwhat)
{
	sqlstm = "select distinct d.voucherno, ac.name as customer_name, aci.address1yh, aci.address2yh, aci.address3yh, " +
	"aci.address4yh, aci.telyh, aci.contactyh, aci.manumberyh, " +
	"convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, " +
	"convert(datetime, dbo.ConvertFocusDate(u.contractstartyh), 112) as cstart, " +
	"convert(datetime, dbo.ConvertFocusDate(u.contractendyh), 112) as cend, " +
	"li.rocnoyh, li.customerrefyh, li.insttypeyh from data d " +
	"left join mr000 ac on ac.masterid = d.bookno " +
	"left join u0000 aci on aci.extraid=ac.masterid " +
	"left join u001b li on li.extraid = d.extraheaderoff " +
	"left join u011b u on u.extraid = d.extraoff " +
	"where d.vouchertype=3329 " +
	"and d.voucherno='" + iwhat + "';";

	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getFC_RWitems(String iwhat)
{
	sqlstm = "select ro.name as product_name, u.spec1yh, u.spec2yh, iy.gross,iy.stockvalue, iy.input0 as unitqty, " +
	"iy.rate as perunit, iy.input1 as rentperiod, iy.output2 as mthtotal from data d " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"left join u011b u on u.extraid = d.extraoff " +
	"where d.vouchertype=3329 and d.voucherno='" + iwhat + "' order by d.bodyid;";

	return sqlhand.rws_gpSqlGetRows(sqlstm);
}

// itype: 1=by instalment no, 2=whole-schedule
void procInstalmentPrintout(int itype)
{
	instalmentprit_pop.close();
	kklc = glob_sel_lcid;

	if(kklc.equals(""))
	{
		kklc = kiboo.replaceSingleQuotes( manual_gstinvoice_tb.getValue().trim() ); // 08/07/2015: get manual entered GST invoice no
		if(kklc.equals("")) return; // not even manual-entered invoice no, return lor
	}
	//rwstr = "RW" + kklc;
	rwstr = kklc; // 0J1 rental-invoice no more RW prefix
	rwmeta = getFC_RWMeta(rwstr);
	if(fcmeta == null) { guihand.showMessageBox("ERR: Cannot access rental-invoice.."); return; }
	rwitems = getFC_RWitems(rwstr);

	instype = 1;
	kake = kiboo.checkNullString(rwmeta.get("insttypeyh")).toUpperCase();
	if(kake.equals("QUARTERLY")) instype = 3;

	templatefn = "rwimg/manInvTemp_3.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	// Insert inv meta-data
	excelInsertString(sheet,0,1, kiboo.checkNullString(rwmeta.get("customer_name")) );
	excelInsertString(sheet,1,1, kiboo.checkNullString(rwmeta.get("address1yh")) );
	excelInsertString(sheet,2,1, kiboo.checkNullString(rwmeta.get("address2yh")) );
	excelInsertString(sheet,3,1, kiboo.checkNullString(rwmeta.get("address3yh")) );
	excelInsertString(sheet,4,1, kiboo.checkNullString(rwmeta.get("address4yh")) );
	excelInsertString(sheet,5,1, kiboo.checkNullString(rwmeta.get("contactyh")) );
	excelInsertString(sheet,6,1, kiboo.checkNullString(rwmeta.get("telyh")) );

	excelInsertString(sheet,0,6, kiboo.checkNullString(rwmeta.get("manumberyh")) );
	excelInsertString(sheet,1,6, kiboo.checkNullString(rwmeta.get("manumberyh")) );
	excelInsertString(sheet,3,6, kklc );

	//excelInsertString(sheet,1,9, dtf2.format(rwmeta.get("vdate")) );
	excelInsertString(sheet,2,9, kiboo.checkNullString(rwmeta.get("customerrefyh")) );
	excelInsertString(sheet,3,9, kiboo.checkNullString(rwmeta.get("rocnoyh")) );
	excelInsertString(sheet,4,9, dtf2.format(rwmeta.get("cstart")) );
	excelInsertString(sheet,5,9, kake );

	rowcnt = 11; // items start row
	qtytot = rwper = 0;
	montot = 0.0;

	CellStyle tcellstyle =  excelWB.createCellStyle();
	tcellstyle.setAlignment(CellStyle.ALIGN_CENTER);
	tcellstyle.setFont(wfont);
	tcellstyle.setBorderLeft(CellStyle.BORDER_THIN);
	tcellstyle.setBorderRight(CellStyle.BORDER_THIN);

	CellStyle pistyle =  excelWB.createCellStyle();
	pistyle.cloneStyleFrom(tcellstyle);
	pistyle.setAlignment(CellStyle.ALIGN_LEFT);

	if(rwitems.size() > 0) // Insert 'em inv items
	{
		kc = 1;

		for( d : rwitems)
		{
			xct = 2;
			excelInsertString(sheet,rowcnt,0, kc.toString() + "." );

			sp1 = excelInsertString(sheet,rowcnt,1, kiboo.checkNullString(d.get("product_name")) + " " + kiboo.checkNullString(d.get("spec1yh")) );
			dsp2 = kiboo.checkNullString(d.get("spec2yh")).trim();

			if(!dsp2.equals(""))
			{
				sp2 = excelInsertString(sheet,rowcnt+1,1,dsp2);
				xct = 3;
			}
			for(k=0;k<xct;k++)
			{
				POI_SetCellStyleRange(sheet,pistyle,rowcnt+k,1,5);
			}

			sheet.addMergedRegion(new CellRangeAddress(rowcnt,rowcnt,1,4));
			sheet.addMergedRegion(new CellRangeAddress(rowcnt+1,rowcnt+1,1,4));
			sheet.addMergedRegion(new CellRangeAddress(rowcnt+2,rowcnt+2,1,4));

			kk = "0";
			try { kk = nf0.format(d.get("unitqty")); } catch (Exception e) {}
			excelInsertString(sheet,rowcnt,5, kk );

			excelInsertString(sheet,rowcnt,6, (instype == 1) ? "1 Month" : "3 Months" );

			kk = "";
			try { kk = (d.get("perunit") != null) ? "RM " + nf2.format(d.get("perunit")) : ""; } catch (Exception e) {}
			excelInsertString(sheet,rowcnt,7, kk );

			kk = "";
			try { kk = (d.get("mthtotal") != null) ? "RM " + nf2.format(d.get("mthtotal")) : ""; } catch (Exception e) {}
			excelInsertString(sheet,rowcnt,8, kk );

			//kk = "";
			//try { kk = (d.get("mthtotal") > 0) ? "RM " + nf2.format(d.get("mthtotal")) : ""; } catch (Exception e) {}
			excelInsertString(sheet,rowcnt,9, kk );

			if(d.get("unitqty") != null) qtytot += d.get("unitqty");
			if(d.get("mthtotal") != null) montot += d.get("mthtotal");

			kc++;
			rowcnt += xct; // blnk 1 row
			if(d.get("rentperiod") != null)
				if(d.get("rentperiod") != 0) rwper = d.get("rentperiod");
		}
	}

	for(i=11;i<rowcnt;i++) // do 'em border-lines for the items
	{
		POI_SetCellStyleRange(sheet,tcellstyle,i,0,1);
		POI_SetCellStyleRange(sheet,tcellstyle,i,5,6);
		POI_SetCellStyleRange(sheet,tcellstyle,i,6,7);
		POI_SetCellStyleRange(sheet,tcellstyle,i,7,8);
		POI_SetCellStyleRange(sheet,tcellstyle,i,8,9);
		POI_SetCellStyleRange(sheet,tcellstyle,i,9,10);
	}

	CellStyle st2 = excelWB.createCellStyle();
	st2.cloneStyleFrom(tcellstyle);
	st2.setBorderBottom(CellStyle.BORDER_THIN);
	POI_SetCellStyleRange(sheet,st2,rowcnt-1,0,10); // closing bottom border for items

	CellStyle st2 = excelWB.createCellStyle();
	st2.setFillForegroundColor(HSSFColor.LIGHT_YELLOW.index);
	st2.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	st2.setAlignment(CellStyle.ALIGN_CENTER);
	st2.setFont(wfont);
	POI_SetCellStyleRange(sheet,st2,rowcnt,0,10);

	excelInsertString(sheet,rowcnt,4, "TOTAL" );
	excelInsertString(sheet,rowcnt,5, nf0.format(qtytot) );
	excelInsertString(sheet,rowcnt,8, "RM " + nf2.format(montot) );
	excelInsertString(sheet,rowcnt,9, "RM " + nf2.format(montot) ); // end of inv-items totals line

	Font wfont2 = excelWB.createFont();
	wfont2.setFontHeightInPoints((short)12);
	wfont2.setFontName("Arial");
	wfont2.setColor(HSSFColor.WHITE.index);

	CellStyle st2 =  excelWB.createCellStyle();
	st2.setFillForegroundColor(HSSFColor.BLUE.index);
	st2.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	st2.setAlignment(CellStyle.ALIGN_CENTER);
	st2.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
	st2.setFont(wfont2);
	st2.setBorderBottom(CellStyle.BORDER_THIN);
	st2.setBorderTop(CellStyle.BORDER_THIN);
	st2.setBorderLeft(CellStyle.BORDER_THIN);
	st2.setBorderRight(CellStyle.BORDER_THIN);
	POI_SetCellStyleRange(sheet,st2,rowcnt+2,0,9);
	sheet.addMergedRegion( new CellRangeAddress(rowcnt+2,rowcnt+2,0,8) );
	rpsh = excelInsertString(sheet,rowcnt+2,0, "RENTAL PAYMENT SCHEDULE" );

	rowcnt += 3; // the months-spread thing
	stx = 0;
	for(x=0; x<3; x++) // do the header
	{
		excelInsertString(sheet,rowcnt,stx + x, "No." );
		excelInsertString(sheet,rowcnt,stx + 1 + x, "Month" );
		excelInsertString(sheet,rowcnt,stx + 2 + x, "Pymt Due" );
		stx += 2;
	}
	CellStyle st2 =  excelWB.createCellStyle();
	st2.setAlignment(CellStyle.ALIGN_CENTER);
	st2.setFont(wfont);
	st2.setBorderLeft(CellStyle.BORDER_THIN);
	st2.setBorderRight(CellStyle.BORDER_THIN);
	st2.setBorderBottom(CellStyle.BORDER_THIN);
	POI_SetCellStyleRange(sheet,st2,rowcnt,0,9);

	rowcnt++;

	java.util.Calendar startd = java.util.Calendar.getInstance();
	startd.setTime( rwmeta.get("cstart") );
	SimpleDateFormat myronly = new SimpleDateFormat("MMM-yyyy");
	chknow = myronly.format(new Date());

	CellStyle st3 =  excelWB.createCellStyle();
	st3.setFillForegroundColor(HSSFColor.GREY_40_PERCENT.index);
	st3.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	st3.setAlignment(CellStyle.ALIGN_CENTER);
	st3.setBorderLeft(CellStyle.BORDER_THIN);
	st3.setBorderRight(CellStyle.BORDER_THIN);
	st3.setBorderBottom(CellStyle.BORDER_THIN);
	st3.setFont(wfont);

	CellStyle st4 =  excelWB.createCellStyle();
	st4.cloneStyleFrom(st3);
	st4.setFillPattern(HSSFCellStyle.NO_FILL);

	tochk = instno_tb.getValue().trim();
	srow = clone_srow = rowcnt;
	scol = 0;
	gtotal = 0.0;
	curshetn = rwstr;

	for(i=0; i<rwper; i++) // do 'em schedule cells
	{
		nrm = 1;
		spdt = myronly.format(startd.getTime());
		excelInsertString(sheet,srow, scol, (i+1).toString() + "." );
		excelInsertString(sheet,srow, scol + 1, spdt );
		excelInsertString(sheet,srow, scol + 2, "RM " + nf2.format(montot) );
		gtotal += montot;

		if(tochk.equals(""))
		{
			if(chknow.equals(spdt)) nrm = 2;
		}
		else
		if(tochk.equals( (i+1).toString() )) nrm = 2;

		switch(nrm)
		{
			case 1:
				POI_SetCellStyleRange(sheet,st4,srow,scol,scol+3);
				break;
			case 2:
				curshetn = rwstr + " (" + (i+1).toString() + ")";
				excelInsertString(sheet,0,9, curshetn ); // put inv + instalment no.
				excelInsertString(sheet,1,9, spdt ); // put only MMM-yyyy
				POI_SetCellStyleRange(sheet, ((itype == 2) ? st4 : st3), srow, scol, scol+3);
				break;
		}

		startd.add(java.util.Calendar.MONTH,instype);
		srow++;
		if(((i+1)%12) == 0) { srow = rowcnt; scol += 3; }
	}

	rowcnt += 12;
	CellStyle st5 =  excelWB.createCellStyle();
	st5.setFillForegroundColor(HSSFColor.LIGHT_YELLOW.index);
	st5.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	st5.setWrapText(false);
	st5.setFont(wfont);
	st5.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
	excelInsertString(sheet,rowcnt,0, "GRAND TOTAL: RM " + nf2.format(gtotal));
	POI_SetCellStyleRange(sheet,st5,rowcnt,0,9);

	switch(itype)
	{
		case 2: // do sheets cloning and set cells data for whole-rental-schedule
			srow = clone_srow;
			scol = 1;
			debugbox.setValue("");
			for(i=0; i<rwper; i++)
			{
				if(i != 0) excelWB.cloneSheet(0);
				snm = rwstr + " (" + (i+1).toString() + ")";
				excelWB.setSheetName(i,snm);

				mysht = excelWB.getSheetAt(i);
				if(i != 0 && (i%12) == 0)
				{
					srow = clone_srow;
					scol += 3;
//debugbox.setValue(debugbox.getValue() + "i=" + i.toString() + " srow=" + srow.toString() + " scol=" + scol.toString() + "\n" );
				}

				ckrow = mysht.getRow(srow);
				ckcell = ckrow.getCell(scol);

				if(i != 0) POI_SetCellStyleRange(mysht, st3, srow, scol-1, scol+2); // do not hilite sheet0

				if(ckcell != null)
				{
					invd = POI_GetCellContentString(ckcell, evaluator, "#.00");
					excelInsertString(mysht,1,9,invd); // put only MMM-yyyy
					excelInsertString(mysht,0,9,snm); // put inv + instalment no.
				}
				srow++;
			}
			mysht = excelWB.getSheetAt(0);
			POI_SetCellStyleRange(mysht, st3, clone_srow, 0,3); // lastly only hilite sheet0
			break;

		case 1:
			excelWB.setSheetName(0,curshetn);
			break;
	}

	// set manual_inv flag -- next time can list automatically..
	sqlstm = "update rw_lc_records set manual_inv=1 where lc_id='" + glob_sel_lcid + "';";
	sqlhand.gpSqlExecuter(sqlstm);

	tfname = rwstr + "_outp.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();
	downloadFile(kasiexport,tfname,outfn);
}



