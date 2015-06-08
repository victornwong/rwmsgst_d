import org.victor.*;

// Supporting and general-purpose funcs for goodsCollection_v1.zul

/*
itype:
1=submit, cannot update customer or add/remove items
2=completed, cannot save items status anymore
*/ 
void disableButts(int itype, boolean iwhat)
{
	Object[] ibuts = { assigncust_b, updategco_b, additem_b, removeitem_b, imptransient_b, imppartreq_b, impfromcsv_b, impfromdo_b };
	switch(itype)
	{
		case 1:
			for(i=0;i<ibuts.length;i++)
			{
				ibuts[i].setDisabled(iwhat);
			}
			//importitems_b.setDisabled(iwhat);
			break;
		case 2:
			saveitems_b.setDisabled(iwhat);
			break;
	}
}

void disableItemsTextbox(boolean iwhat)
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return;
	cds = items_rows.getChildren().toArray();
	if(cds.length < 2) return;
	for(i=1; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		for(j=1;j<5;j++)
		{
			c1[j].setDisabled(iwhat);
		}
	}
}

// Get all asset-tags in items-grid
ArrayList collectAssetTags()
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return null;
	cds = items_rows.getChildren().toArray();
	if(cds.length < 2) return null;
	ArrayList retv = new ArrayList();
	for(i=1; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		atg = c1[1].getValue().trim();
		if(!atg.equals("")) retv.add(atg);
	}
	return retv;
}

void checkCreateCollectGrid()
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") != null) return;
	grd = new Grid();
	grd.setMold("paging");
	grd.setPageSize(20);
	//grd.setHeight("480px");

	grd.setId("pickitems_grid");
	rws = new org.zkoss.zul.Rows();
	rws.setId("items_rows");
	rws.setParent(grd);

	String[] colhed = { "","Asset Tag","S/N","Description","Col","FromLC/DO" };
	kcols = new org.zkoss.zul.Columns();
	kcols.setParent(grd);
	for(i=0;i<colhed.length;i++)
	{
		//gpMakeLabel(rwm,"",colhed[i],"");
		kcl = new org.zkoss.zul.Column();
		kcl.setLabel(colhed[i]);
		kcl.setParent(kcols);
	}
/*
	rwm = new org.zkoss.zul.Row();
	rwm.setParent(rws);
	rwm.setStyle("background:#97b83a");
*/
	grd.setParent(pitems_holder);
}

void showGCOMeta(String iwhat)
{
	grc = getGCO_rec(iwhat);
	if(grc == null) return;
	collection_id_lbl.setValue(iwhat);

	String[] fl = { "contact_person", "contact_tel", "contact_email", "location", "collection_notes", "customer_name",
	"lc_id", "transporter", "transp_ref", "tempgrn", "sv_no", "res_date" };

	Object[] ob = { contact_person, contact_tel, contact_email, location, collection_notes, customername,
	lc_id, g_transporter, g_transp_ref, g_tempgrn, g_sv_no, g_res_date };

	ngfun.populateUI_Data(ob,fl,grc);

	global_selected_customerid = kiboo.checkNullString( grc.get("fc6_custid") );
	fc6custid_lbl.setValue(global_selected_customerid);

	fillDocumentsList(documents_holder,COLLECTION_PREFIX,iwhat);

	// show the assets to be collected
	if(pitems_holder.getFellowIfAny("pickitems_grid") != null) pickitems_grid.setParent(null);
	checkCreateCollectGrid();

	kst = grc.get("status");
	lkk = lkk2 = false;
	if(!kst.equals("NEW")) lkk = true;
	if(kst.equals("COMPLETE")) lkk2 = true;

	disableButts(1,lkk);
	disableButts(2,lkk2);
	//disableItemsTextbox(lkk);

	ktg = sqlhand.clobToString(grc.get("items_code"));
	if(!ktg.equals(""))
	{
		itag = sqlhand.clobToString(grc.get("items_code")).split("~");
		idsc = sqlhand.clobToString(grc.get("items_desc")).split("~");
		isn = sqlhand.clobToString(grc.get("items_sn")).split("~");
		icol = kiboo.checkNullString(grc.get("items_coll")).split("~");
		ifrm = sqlhand.clobToString(grc.get("items_fromlc")).split("~");

		f9 = "font-size:9px";

		for(i=0; i<itag.length; i++)
		{
			nrw = new org.zkoss.zul.Row();
			nrw.setParent(items_rows);

			gpMakeCheckbox(nrw,"","","");

			tmsn = "";
			try { tmsn = isn[i]; } catch (Exception e) {}

			tmds = "";
			try { tmds = idsc[i]; } catch (Exception e) {}

			tfrm = "";
			try { tfrm = ifrm[i]; } catch (Exception e) {}

			if(!kst.equals("NEW"))
			{
				gpMakeLabel(nrw, "", itag[i], "");
				gpMakeLabel(nrw, "", tmsn, f9);
				klb = gpMakeLabel(nrw, "", tmds, f9);
				klb.setMultiline(true);
			}
			else
			{
				gpMakeTextbox(nrw,"",itag[i],"","99%");
				gpMakeTextbox(nrw,"",tmsn,f9,"99%");
				kbb = gpMakeTextbox(nrw,"",tmds,f9,"99%");
				kbb.setMultiline(true);
				kbb.setHeight("40px");
			}

			ckb = gpMakeCheckbox(nrw,"","","");
			if(!kst.equals("NEW"))
			{
				if(icol[i].equals("1")) ckb.setChecked(true);
			}
			else
			{
				ckb.setDisabled(true);
			}

			if(!kst.equals("NEW"))
			{
				gpMakeLabel(nrw, "", tfrm, f9);
			}
			else
			{
				gpMakeTextbox(nrw,"",tfrm,f9,"99%");
			}
		}
	}
	workarea.setVisible(true);
}

Object[] gdcols_headers =
{
	new listboxHeaderWidthObj("GCO",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Status",true,"60px"), // 3
	new listboxHeaderWidthObj("LC/CSV",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Ack",true,""),
	new listboxHeaderWidthObj("Pickup",true,""),
	new listboxHeaderWidthObj("Transp",true,""),
	new listboxHeaderWidthObj("Region",true,""),
	new listboxHeaderWidthObj("Comp",true,""),
	new listboxHeaderWidthObj("TempGRN",true,"70px"),
	new listboxHeaderWidthObj("MRN",true,"70px"),
	new listboxHeaderWidthObj("CSV",true,"60px"),
	new listboxHeaderWidthObj("ADT",true,"60px"),
	/*
	new listboxHeaderWidthObj("LOGSTAT",true,"60px"),
	new listboxHeaderWidthObj("OVERDUE",true,"60px"),
	new listboxHeaderWidthObj("adtchecker",true,"60px"),
	*/
};
adt_field = 14;
mrn_posi = 12;
tgrn_posi = 11;
stt_field = 3;

class gdcolOnC implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		//if(!glob_sel_gco.equals("") && !glob_sel_status.equals("COMPLETE") ) saveCollectItems(glob_sel_gco); // save previous GCO if any

		glob_sel_gcoli = event.getReference();
		glob_sel_gco = lbhand.getListcellItemLabel(glob_sel_gcoli,0);
		glob_sel_gco_user = lbhand.getListcellItemLabel(glob_sel_gcoli,5);
		glob_sel_status = lbhand.getListcellItemLabel(glob_sel_gcoli, stt_field);
		glob_sel_adt = lbhand.getListcellItemLabel(glob_sel_gcoli, adt_field);
		glob_sel_tgrn = lbhand.getListcellItemLabel(glob_sel_gcoli, tgrn_posi);
		glob_sel_mrn = lbhand.getListcellItemLabel(glob_sel_gcoli, mrn_posi);
		showGCOMeta(glob_sel_gco);
	}
}
gdcliker = new gdcolOnC();

void showGoodsCollection(int itype)
{
	last_list_type = itype;
	bytp = bytransp_lb.getSelectedItem().getLabel();
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	st = kiboo.replaceSingleQuotes( asstga_tb.getValue().trim() );
	gcoi = kiboo.replaceSingleQuotes(searchgco_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	bunm = byuser_lb.getSelectedItem().getLabel();
	bstt = bystat_lb.getSelectedItem().getLabel();

	Listbox newlb = lbhand.makeVWListbox_Width(collections_holder, gdcols_headers, "goodscol_lb", 5);

	scsql = "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
	if(!scht.equals("")) scsql += " and (customer_name like '%" + scht + "%' or collection_notes like '%" + scht + "%' or location like '%" + scht + "%') ";

	switch(itype)
	{
		case 2: // by GCO
			scsql = "where origid=" + gcoi;
			break;
		case 3: // by date+transporter
			scsql += "and transporter='" + bytp + "' ";
			break;
		case 4: // by asset-tags
			if(!st.equals(""))
			scsql = "where convert(nvarchar(max),items_code) like '%" + st + "%' or convert(nvarchar(max),items_desc) like '%" + st +
			"%' or convert(nvarchar(max),items_sn) like '%" + st + "%' ";
			break;
		case 5: // by user
			scsql += "and username='" + bunm + "' ";
			break;
		case 6: // by status
			scsql += "and gc.status='" + bstt + "' ";
			break;
		case 7: // by user and status
			scsql += "and username='" + bunm + "' and gc.status='" + bstt + "' ";
			break;
	}

	sqlstm = "select gc.origid, gc.datecreated, gc.username, gc.customer_name, gc.status, gc.pickupdate, gc.completedate, gc.lc_id," +
	"gc.ackdate, gc.transporter, gc.tempgrn, gc.sv_no, gc.qc_id, gc.logregion, " +
	"case when gc.completedate is null then 'TNULL' else " +
	"	case when gc.logregion is null then 'TERR' " +
	"else " +
	"	case gc.logregion " +
	"	when 'KLANG_VALLEY' then " +
	"		CASE when " +
	"		convert(datetime,convert(varchar,gc.completedate,112),112) <= " +
	"		dbo.addworkdays(3,convert(datetime,convert(varchar,gc.datecreated,112),112)) " +
	"		then 'TKVOK' else 'TKVNOK' end " +
	"	when 'OUTSIDE_KLANG_VALLEY' then " +
	"		CASE when " +
	"		convert(datetime,convert(varchar,gc.completedate,112),112) <= " +
	"		dbo.addworkdays(5,convert(datetime,convert(varchar,gc.datecreated,112),112)) " +
	"		then 'OTKVOK' else 'OTKVNOK' end " +
	"	end " +
	"end " +
	"end as logstat, " +
	"case when gc.completedate is null then " +
	"CASE when " +
	"	convert(datetime,convert(varchar,getdate(),112),112) <= " +
	"	dbo.addworkdays(5,convert(datetime,convert(varchar,gc.datecreated,112),112)) " +
	"then 'ODOK' else 'ODNOK' end " +
	"end as overduestat, " +
	"case when gc.completedate is not null then " +
	"case when gc.qc_id is not null then " +
	"	case when gc.qc_id = 0 then " +
	"		'ADTERR' " +
	"	else " +
	"		'ADTOK' " +
	"	end " +
	"else " +
	"	'ADTNA' " +
	"end " +
	"else " +
	"	case when " +
	"		convert(datetime,convert(varchar,getdate(),112),112) <= " +
	"		dbo.addworkdays(11,convert(datetime,convert(varchar,gc.datecreated,112),112)) " +
	"		then 'ADTOK' " +
	"		else 'ADTOD' " +
	"	end " +
	"end as adtchecker " +
	"from rw_goodscollection gc " + scsql + " order by gc.origid";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	newlb.addEventListener("onSelect", gdcliker );
	ArrayList kabom = new ArrayList();

	String[] fl = { "origid", "datecreated", "customer_name", "status", "lc_id", "username", "ackdate",
	"pickupdate", "transporter", "logregion", "completedate", "tempgrn", "username", "sv_no", "qc_id" };
	// "logstat", "overduestat", "adtchecker"

	for(d : screcs)
	{
		sty = "font-size:9px;";
		if(d.get("tempgrn") != null)
		{
			if(d.get("tempgrn").equals(""))
			{
				if(d.get("logstat").equals("TERR")) // region not set but with transp-complete-date
					sty += "background:#C395F5;color:#000000;";
			}
			else
			{
				if(d.get("overduestat") != null)
				{
					if(d.get("logstat").equals("TNULL") && d.get("overduestat").equals("ODNOK")) sty += "background:#FA7E19;color:#000000;";
				}
			}
		}

		if(d.get("adtchecker").equals("ADTNA")) sty += "background:#FAEF55;color:#000000;";
		if(d.get("adtchecker").equals("ADTERR") || d.get("adtchecker").equals("ADTOD")) sty += "background:#F70C37;color:#ffffff;font-weight:bold";

		kss = "";
		if(!sty.equals("font-size:9px;")) kss = "font-size:9px;text-decoration:underline;";

		ngfun.popuListitems_Data2(kabom,fl,d);
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",kss);

		adts = getDOLinkToJob( 5, d.get("origid").toString() );
		lbhand.setListcellItemLabel(ki,adt_field,adts);
		for(i=1;i<4;i++)
		{
			setListcell_Style(ki,i,sty); // rwsqlfuncs.zs
		}

		mns = ""; // get MRNs if any..
		try { mns = grnToMRN_str(d.get("tempgrn")); } catch (Exception e) {}
		lbhand.setListcellItemLabel(ki,mrn_posi,mns);
		kabom.clear();
	}
}

// 25/06/2014: added rw_goodscollection.items_fromlc (to keep track of imported from which LC)
void saveCollectItems(String iwhat)
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return;
	cds = items_rows.getChildren().toArray();
	//if(cds.length < 1) return;
	icods = idesc = itik = isn = astgs = ifrmlc = "";
	colcount = 0;
	refresh = false;
	todaydate =  kiboo.todayISODateTimeString();

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		icods += kiboo.replaceSingleQuotes( c1[1].getValue().replaceAll("~"," ") ) + "~";
		isn += kiboo.replaceSingleQuotes( c1[2].getValue().replaceAll("~"," ") ) + "~";
		idesc += kiboo.replaceSingleQuotes( c1[3].getValue().replaceAll("~"," ") ) + "~";
		itik += ( c1[4].isChecked() ) ? "1~" : "0~";
		ifrmlc += kiboo.replaceSingleQuotes( c1[5].getValue().replaceAll("~"," ") ) + "~";

		if(c1[4].isChecked()) colcount++;

		if(!c1[1].getValue().equals("")) // 28/10/2013: use to update rw_lc_equips
			astgs += "'" + kiboo.replaceSingleQuotes( c1[1].getValue().trim() ) + "',";
	}

	try { icods = icods.substring(0,icods.length()-1); } catch (Exception e) {}
	try { idesc = idesc.substring(0,idesc.length()-1); } catch (Exception e) {}
	try { isn = isn.substring(0,isn.length()-1); } catch (Exception e) {}
	try { itik = itik.substring(0,itik.length()-1); } catch (Exception e) {}

	try { astgs = astgs.substring(0,astgs.length()-1); } catch (Exception e) {}
	try { ifrmlc = ifrmlc.substring(0,ifrmlc.length()-1); } catch (Exception e) {}

	jstat = "";
	lnkc = COLLECTION_PREFIX + iwhat;
	eml = getUser_email(glob_sel_gco_user);

	if(!glob_sel_status.equals("NEW") && colcount != 0) // Check GCO status by counting items == colcount(ticked item)
	{
		totl = cds.length;
		if(colcount == totl)
		{
			jstat = ", status='COMPLETE', completedate='" + todaydate + "'";
			glob_sel_status = "COMPLETE";

			add_RWAuditLog(lnkc, "", "COMPLETED collection", useraccessobj.username);

			if(eml != null)
			{
				subj = "RE: GCO collection COMPLETED - " + lnkc;
				emsg = "Do take the necessary action ASAP.";
				gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, eml, subj, emsg);
			}
		}

		if(colcount < totl)
		{
			jstat = ", status='PARTIAL'";
			glob_sel_status = "PARTIAL";

			if(eml != null)
			{
				subj = "RE: GCO collection PARTIAL - " + lnkc;
				emsg = "Do take the necessary action ASAP.";
				gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, eml, subj, emsg);
			}
		}
		refresh = true;
	}

	sqlstm = "";

	// Update rw_lc_equips.gcn_id to show linkage to this GCN
	lcid = kiboo.replaceSingleQuotes(lc_id.getValue().trim()); // lc_id def in formmak
	if(!lcid.equals(""))
	{
		if(!astgs.equals(""))
			sqlstm = "update rw_lc_equips set gcn_id=" + iwhat +
			" where lc_parent=(select origid from rw_lc_records where lc_id='" + lcid + "')" + 
			" and asset_tag in (" + astgs + ");";
	}

	sqlstm += "update rw_goodscollection set items_code='" + icods + "', items_desc='" + idesc + "', items_sn='" + isn + "', " + 
	"items_coll='" + itik + "', items_fromlc='" + ifrmlc + "'" + jstat + " where origid=" + iwhat;

	sqlhand.gpSqlExecuter(sqlstm);

	if(refresh) showGoodsCollection(last_list_type);
}

// 18/08/2014: remove GCO-id from LC's assets if GCO is partial and assets not collected - req Huiping
void updLC_GCO_links()
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return;

	gcor = getGCO_rec(glob_sel_gco); // re-get the latest gco meta
	if(gcor == null) return;
	stt = gcor.get("status");
	if(!stt.equals("PARTIAL")) { guihand.showMessageBox("Can only update PARTIAL GCO for LC-EOL"); return; }

	cds = items_rows.getChildren().toArray();
	sqlstm = "";

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		chklc = kiboo.replaceSingleQuotes( c1[5].getValue().trim() );
		if(!c1[4].isChecked())
		{
			if( !chklc.equals("") )
			{
				icods = kiboo.replaceSingleQuotes( c1[1].getValue().trim() );
				sqlstm += "update rw_lc_equips set gcn_id=null where lc_parent=(select origid from rw_lc_records where lc_id='" + chklc + "')" + 
				" and asset_tag='" + icods + "';";
			}
		}
	}
	sqlhand.gpSqlExecuter(sqlstm);
	guihand.showMessageBox("LC assets GCO-id cleared..");
}

void removeCollectItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		if(c1[0].isChecked()) cds[i].setParent(null);
	}
}

void genGCO_template(String igco)
{
	gcor = getGCO_rec(igco);
	if(gcro == null)
	{
		guihand.showMessageBox("DBERR: Cannot access GCO table!!");
		return;
	}

	startadder = 1;
	rowcount = 1 + startadder;

	templatefn = "rwimg/gcn_template_1.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	try { daddr = kiboo.checkNullString(gcor.get("location")).replaceAll(",,",","); } catch (Exception e) {}

	dets1 =
	"CUSTOMER:\n" + kiboo.checkNullString(gcor.get("customer_name")) + "\n" +
	daddr +
	"\nContact person: " + kiboo.checkNullString(gcor.get("contact_person")) + 
	"\nTEL: " + kiboo.checkNullString(gcor.get("contact_tel")) +
	"\nEMAIL: " + kiboo.checkNullString(gcor.get("contact_email"));

	excelInsertString(sheet,0,0, dets1 );

	dets2 = COLLECTION_PREFIX + ": " + igco +
	"\nDated: " + dtf2.format(gcor.get("datecreated")) +
	"\nSO/LC/ROC No.: " + kiboo.checkNullString(gcor.get("lc_id")) +
	"\nSV No.: " + kiboo.checkNullString(gcor.get("sv_no")) +
	"\nPacking Materials: YES / NO" +
	"\nTransporter: " + kiboo.checkNullString(gcor.get("transporter")) + " " + kiboo.checkNullString(gcor.get("transp_ref")) +
	"\nPickup Date: " + ((gcor.get("pickupdate") == null) ? "" : dtf2.format(gcor.get("pickupdate"))) +
	"\nReq.By: " + gcor.get("username") +
	"\nNotes: " + kiboo.checkNullString(gcor.get("collection_notes"));

	excelInsertString(sheet,0,4, dets2 );

	String[] colhd = { "No.", "FromLC", "Asset Tag","S/Number","Item description","Collected" };
	for(i=0;i<colhd.length;i++)
	{
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, 2, i, colhd[i] ),wfont,true,"");
	}

	itag = sqlhand.clobToString(gcor.get("items_code")).split("~");
	idsc = sqlhand.clobToString(gcor.get("items_desc")).split("~");
	isn = sqlhand.clobToString(gcor.get("items_sn")).split("~");
	ilc = sqlhand.clobToString(gcor.get("items_fromlc")).split("~");

	if(itag.length > 0)
	{
		for(i=0; i<itag.length; i++)
		{
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 0, (i+1).toString() + "." ),wfont,true,"");

		tmtg = "";
		try { tmtg = itag[i]; } catch (Exception e) {}

		tmsn = "";
		try { tmsn = isn[i]; } catch (Exception e) {}

		tmds = "";
		try { tmds = idsc[i]; } catch (Exception e) {}

		tmlc = "";
		try { tmlc = ilc[i]; } catch (Exception e) {}		

		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 1, tmlc ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 2, tmtg ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 3, tmsn ),wfont,false,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 4, tmds ),wfont,false,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 5, "" ),wfont,false,"");

		rowcount++;
		}
	}

	tfname = COLLECTION_PREFIX + igco + "_outp.xls";
	outfn = session.getWebApp().getRealPath("sharedocs/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();

	downloadFile(kasiexport,tfname,outfn);
}

// 17/03/2015: req by Nurul, generate GCO items list
void genGCOItems_list()
{
	sdate = kiboo.getDateFromDatebox(gco_startdate);
	edate = kiboo.getDateFromDatebox(gco_enddate);

	sqlstm = "select origid as gcono,datecreated,customer_name,username,items_code,items_desc,items_coll from rw_goodscollection " +
	"where datecreated between '" + sdate + "' and '" + edate + "' order by origid;";

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0)
	{
		guihand.showMessageBox("No records..");
		return;
	}

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("gcoitems");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");
	rowcount = 1;
	String[] hds = { "GCO", "Date", "Customer", "User", "AssetTag", "Desc", "Collect" };

	for(i=0;i<hds.length;i++)
	{
		POI_CellSetAllBorders(wb,excelInsertString(sheet,0,i,hds[i]),wfont,true,"");
	}

	for(d : r)
	{
		gcono = d.get("gcono").toString();
		dtc = kiboo.dtf2.format(d.get("datecreated"));
		unm = d.get("username");
		cnm = kiboo.checkNullString(d.get("customer_name"));

		itag = sqlhand.clobToString(d.get("items_code")).split("~");
		idsc = sqlhand.clobToString(d.get("items_desc")).split("~");
		icol = kiboo.checkNullString(d.get("items_coll")).split("~");

		for(i=0; i<itag.length; i++)
		{
			excelInsertString(sheet,rowcount,0,gcono);
			excelInsertString(sheet,rowcount,1,dtc);
			excelInsertString(sheet,rowcount,2,cnm);
			excelInsertString(sheet,rowcount,3,unm);

			ks = "";
			try { ks = itag[i]; } catch (Exception e) {}
			excelInsertString(sheet,rowcount,4,ks);

			ks = "";
			try { ks = idsc[i]; } catch (Exception e) {}
			excelInsertString(sheet,rowcount,5,ks);

			ks = "0";
			try { ks = icol[i]; } catch (Exception e) {}
			excelInsertString(sheet,rowcount,6, ((ks.equals("0")) ? "N" : "Y") );

			rowcount++;
		}
	}

	outfn = session.getWebApp().getRealPath("tmp/gcoitemslist.xls");
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();
	downloadFile(kasiexport,"gcoitemslist.xls",outfn);
}
