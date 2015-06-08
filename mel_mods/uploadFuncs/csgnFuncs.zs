import org.victor.*;

// MEL upload consignment note general funcs

MEL_EQU_ROWS_START = 17;

void toggButts(boolean iwhat)
{
	Object[] bb = { uplassets_b, savelist_b };
	for(i=0;i<bb.length;i++)
	{
		bb[i].setDisabled(iwhat);
	}
}

void setCsgnLocation(String iwhere)
{
	if(glob_sel_csgn.equals("")) return;
	sqlstm = "update mel_csgn set rwlocation='" + iwhere + "' where origid=" + glob_sel_csgn;
	sqlhand.gpSqlExecuter(sqlstm);
	loadCSGN(last_list_csgn);
	locationpop.close();
}


Object[] csgnasshd =
{
	new listboxHeaderWidthObj("Contract #",true,""),
	new listboxHeaderWidthObj("Serial Number",true,""),
	new listboxHeaderWidthObj("Asset Number (MEL Ref)",true,""),
	new listboxHeaderWidthObj("Item Description",true,""),
	new listboxHeaderWidthObj("Asset Category",true,""),
	new listboxHeaderWidthObj("Make",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Processor Or Monitor Type",true,""),
	new listboxHeaderWidthObj("Processor Speed Or Monitor Size",true,""),
	new listboxHeaderWidthObj("HDD Size",true,""),
	new listboxHeaderWidthObj("RAM",true,""),
};

// Process the MEL csgn and insert items into table
void uploadMEL_CSGN()
{
	if(glob_sel_csgn.equals("")) return;

	csgn_upload_data = new uploadedWorksheet();
	csgn_upload_data.getUploadFileData();
	if(csgn_upload_data.thefiledata == null)
	{
		guihand.showMessageBox("ERR: Invalid worksheet");
		return;
	}
	//rental_sched_filename.setValue( kiboo.checkNullString(rentalsched_data.thefilename) );

	InputStream inps = null;
	org.apache.poi.hssf.usermodel.HSSFRow trow;
	Cell tcell;
	HashMap hm = new HashMap(); // check for dups s/nums

	try
	{
		if(csgn_upload_data == null) return;
		if(csgn_upload_data.thefiledata == null) return;
		if(csgn_upload_data.thefiledata instanceof java.io.ByteArrayInputStream)
			inps = csgn_upload_data.thefiledata;
		else
			inps = new ByteArrayInputStream(csgn_upload_data.thefiledata);
	}
	catch (Exception e) { guihand.showMessageBox("ERR: Invalid worksheet.."); return; }

	HSSFWorkbook excelWB = new HSSFWorkbook(inps);
	FormulaEvaluator evaluator = excelWB.getCreationHelper().createFormulaEvaluator();

	sht0 = excelWB.getSheetAt(0);
	numrows = sht0.getPhysicalNumberOfRows();

	String[] clm = new String[11];

	Listbox newlb = lbhand.makeVWListbox_Width(csgnasset_holder, csgnasshd, "csgnassets_lb", 20);
	uplocount = 0;
	unkwncount = 1; // to cater for unknown MEL serial-numbers
	usedmelassettag = false;

	for(i=MEL_EQU_ROWS_START; i<numrows; i++)
	{
		trow = sht0.getRow(i); if(trow == null) continue;
		tcell = trow.getCell(0); if(tcell == null) continue;

		clm[0] = "";
		try { clm[0] = POI_GetCellContentString(tcell,evaluator,"").trim(); } catch (Exception e) {}
		clm[0] = clm[0].toUpperCase();

		if(!clm[0].equals("") && !clm[0].equals("PACKING REMARK") && !clm[0].equals("REMARKS:")) // HARDCODED string checking
		{
			try
			{
				tcell = trow.getCell(1);
				clm[1] = POI_GetCellContentString(tcell,evaluator,"").trim(); // get snum
				clm[1] = clm[1].replaceAll(",",""); // 12/01/2015: sometimes snum imported as no. which contains , formatting
				if(!clm[1].equals(""))
				{
					for(x=2; x<11; x++)
					{
						tcell = trow.getCell(x);
						clm[x] = POI_GetCellContentString(tcell,evaluator,"").trim();
						if(x == 2) // MEL asset-tag formatted as no., remove ","
							clm[x] = clm[x].replaceAll(",","");
					}

					if(clm[1].toUpperCase().equals("NULL")) // if null/unknown MEL snums, take MEL asset-tag as snum
					{
						clm[1] = clm[2];
						usedmelassettag = true;
					}

					if( !hm.containsKey(clm[1]) && !hm.containsKey(clm[2]) ) // make sure no dup s/num and mel-asset-tag
					{
						lbhand.insertListItems(newlb,clm,"false","");
						hm.put(clm[1],1); // put s/num and mel-asset-tag into hashmap for dups checking
						hm.put(clm[2],1);
						uplocount++;
					}
					else
					{
						guihand.showMessageBox("ERR: Duplicates found : " + clm[1] + " / " + clm[2]);
						csgnassets_lb.setParent(null); // remove the listbox
						return;
					}
				}
			}
			catch (Exception e) {}
		}
	}
	uplcount_lbl.setValue("Items uploaded: " + uplocount.toString());

	mf = (usedmelassettag) ? "1" : "0";
	sqlstm = "update mel_csgn set usedmelassettag=" + mf + " where origid=" + glob_sel_csgn;
	sqlhand.gpSqlExecuter(sqlstm); // upload mel_csgn.usedmelassettag flag
	
	/* DO LATER
	java.io.ByteArrayInputStream
	Sql sql = sqlhand.als_mysoftsql();
	if(sql != null) // save uploaded worksheet
	{
		java.sql.Connection thecon = sql.getConnection();
		java.sql.PreparedStatement pstmt = thecon.prepareStatement("update mel_csgn set thefile=?, filename=? where origid=?");
		pstmt.setBinaryStream(1, inps, (int)inps.length()) 
		pstmt.setString(2, csgn_upload_data.thefilename);
		pstmt.setInt(3,Integer.parseInt(glob_sel_csgn));
		pstmt.executeUpdate();
		sql.close();
	}
	*/
}

void showConsignmentThings()
{
	if(csgnasset_holder.getFellowIfAny("csgnassets_lb") != null) csgnassets_lb.setParent(null); // remove prev lb

	if(!glob_csgn_qty.equals("") && !glob_csgn_qty.equals("0"))
	{
		Listbox newlb = lbhand.makeVWListbox_Width(csgnasset_holder, csgnasshd, "csgnassets_lb", 20);
		sqlstm = "select * from mel_inventory where parent_id=" + glob_sel_csgn;
		rcs = sqlhand.gpSqlGetRows(sqlstm);
		ArrayList kabom = new ArrayList();
		String[] fl = { "contract_no","serial_no","mel_asset","item_desc","item_type","brand_make","model","sub_type","sub_spec","hdd","ram" };
		for(d : rcs)
		{
			ngfun.popuListitems_Data(kabom,fl,d);
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			kabom.clear();
		}
	}

	toggButts( (!glob_csgn_stat.equals("COMMIT")) ? false : true );
	workarea.setVisible(true);
}

Object[] csgnlb_headers =
{
	new listboxHeaderWidthObj("Rec",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("MEL CSGN",true,"90px"),
	new listboxHeaderWidthObj("UplBy",true,"80px"),
	new listboxHeaderWidthObj("Location",true,"80px"),
	new listboxHeaderWidthObj("Status",true,"70px"), // 5
	new listboxHeaderWidthObj("Notes",true,""),
	new listboxHeaderWidthObj("Qty",true,"50px"),
	new listboxHeaderWidthObj("UseMEL",true,"40px"),
};

class csgnlbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_csgn = lbhand.getListcellItemLabel(isel,0);
		glob_sel_melcsgn = lbhand.getListcellItemLabel(isel,2);

		glob_sel_loca = lbhand.getListcellItemLabel(isel,4);
		glob_sel_notes = lbhand.getListcellItemLabel(isel,6);

		glob_csgn_stat = lbhand.getListcellItemLabel(isel,5);
		glob_csgn_qty = lbhand.getListcellItemLabel(isel,7); // to see got equips or not

		csgn_sel_item = isel;
		showConsignmentThings();
	}
}
csgnclkier = new csgnlbClick();

void loadCSGN(int itype)
{
	last_list_csgn = itype;
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	loca = p_location.getSelectedItem().getLabel();

	Listbox newlb = lbhand.makeVWListbox_Width(csgnholder, csgnlb_headers, "csgn_lb", 3);

	sqlstm = "select mn.origid,mn.datecreated,mn.csgn,mn.mel_user,mn.mstatus,mn.extranotes,mn.rwlocation,mn.usedmelassettag," +
	"(select count(origid) from mel_inventory where parent_id=mn.origid) as qty " +
	"from mel_csgn mn ";

	switch(itype)
	{
		case 1: // by date range
			sqlstm += "where mn.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00'";
			break;
		case 2: // by partner location
			sqlstm += "where mn.rwlocation='" + loca + "'";
			break;
	}

	sqlstm += " order by mn.origid";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	newlb.addEventListener("onSelect", csgnclkier);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "csgn", "mel_user", "rwlocation", "mstatus", "extranotes","qty","usedmelassettag" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		if(d.get("mstatus").equals("CANCEL")) ki.setStyle("text-decoration: line-through;font-size:9px");
		kabom.clear();
	}
}

void reallySaveMEL_equiplist()
{
	// check for dups in prev uploaded csgn
	itms = csgnassets_lb.getItems().toArray();
	snm = matg = "";
	for(i=0; i<itms.length; i++)
	{
		kk = kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(itms[i],1));
		if(!kk.equals("")) snm += "'" + kk + "',";
		kk = kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(itms[i],2));
		if(!kk.equals("")) matg += "'" + kk + "',";
	}

	try
	{
		snm = snm.substring(0,snm.length()-1);
		matg = matg.substring(0,matg.length()-1);
	} catch (Exception e) { guihand.showMessageBox("ERR: Anamolies in equipments list.. Cannot SAVE!"); return; }

	sqlstm = "select origid from mel_inventory where serial_no in (" + snm + ") or mel_asset in (" + matg + ");";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() > 0)
	{
		guihand.showMessageBox("ERR: Some of the equipments are already in our database. No duplicates allowed!");
		return;
	}

	sqlstm = "delete from mel_inventory where parent_id=" + glob_sel_csgn;
	sqlhand.gpSqlExecuter(sqlstm);
	itms = csgnassets_lb.getItems().toArray();
	String[] clm = new String[11];
	sqlstm = "";
	for(i=0; i<itms.length; i++)
	{
		for(x=0; x<11; x++)
		{
			clm[x] = kiboo.replaceSingleQuotes(lbhand.getListcellItemLabel(itms[i],x));
		}

		sqlstm += "insert into mel_inventory (parent_id,contract_no,serial_no,mel_asset,item_desc,item_type,brand_make,model,sub_type,sub_spec,hdd,ram) values (" +
		glob_sel_csgn + ",'" + clm[0] + "','" + clm[1] + "','" + clm[2] + "','" + clm[3] + "','" + clm[4] + "','" + clm[5] + "'," +
		"'" + clm[6] + "','" + clm[7] + "','" + clm[8] + "','" + clm[9] + "','" + clm[10] + "');";
	}
	sqlhand.gpSqlExecuter(sqlstm);
	guihand.showMessageBox("Equipments list saved into consignment: " + glob_sel_csgn);
}

void sendCsgn_Notif(int itype, String icsgn)
{
	r = getMELCSGN_rec(icsgn);
	if(r == null)
	{
		guihand.showMessageBox("ERR: send email notification failed - cannot retrieve consignment record.");
		return;
	}

	subj = topeople = "";
	/*
	emsg =
	"------------------------------------------------------" +
	"\nMEL CSGN REF : " + glob_sel_melcsgn +
	"\nRW warehouse : " + glob_sel_loca +
	"\nQty          : " + glob_csgn_qty +
	"\nNotes        : " + glob_sel_notes +
	"\n\nPlease login to check and process ASAP." +
	"\n------------------------------------------------------";
	*/

	mf = (r.get("usedmelassettag") == null) ? "NO" : ( (r.get("usedmelassettag")) ? "YES" : "NO");

	emsg =
	"------------------------------------------------------" +
	"\nMEL CSGN REF      : " + kiboo.checkNullString( r.get("csgn") ) +
	"\nRW warehouse      : " + kiboo.checkNullString( r.get("rwlocation") ) +
	"\nQty               : " + glob_csgn_qty +
	"\nUse MEL asset-tag : " + mf +
	"\nNotes             : " + kiboo.checkNullString( r.get("extranotes") ) +
	"\n\nPlease login to check and process ASAP." +
	"\n------------------------------------------------------";

	switch(itype)
	{
		case 1: // csgn commit notif
			subj = "[COMMITTED] MEL Consignment-note: " + icsgn;
			topeople = luhand.getLookups_ConvertToStr("MEL_RW_COORD",2,",");
			break;

		case 2: // cancel notif
			subj = "[CANCELLED] MEL Consignment-note: " + icsgn;
			topeople = luhand.getLookups_ConvertToStr("MEL_RW_COORD",2,",");
			break;

		case 3: // send test notif
			subj = "[TESTING] mel consignment-note";
			topeople = "victor@rentwise.com";
			break;
	}

	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, subj, emsg );
}

