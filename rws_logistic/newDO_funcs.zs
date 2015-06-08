import org.victor.*;
// Genaral funcs for newDOmanager

String[] itm_colws = { "30px","",                "60px","","" };
String[] itm_colls = { ""    ,"Item description","Qty","AssTags","S/Nums" };

class tbnulldrop implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
	}
}
textboxnulldrop = new tbnulldrop();

// itype: 1=main butts, 2=items butts
void toggButts(int itype, boolean iwhat)
{
	Object[] itmsbutts = { asscust_b, impjobbutt, savedometa_b, additem_b, delitem_b,
		savedoitems_b, savedometa_b, impasstags_b, parseserials_b };

	switch(itype)
	{
		case 2:
			for(i=0; i<itmsbutts.length; i++)
			{
				itmsbutts[i].setDisabled(iwhat);
			}
			break;
	}
}

// gitems: grid-row converted to array, ichk: checkbox stat
void toggCheckbox(Object gitems, boolean ichk)
{
	for(i=0;i<gitems.length;i++)
	{
		ki = gitems[i].getChildren().toArray();
		if(ki[0] instanceof Checkbox) // assuming 1st obj is a checkbox
		{
			ki[0].setChecked(ichk);
		}
	}
}

// Get DOs tied to Job
String getJob_linkDO(int ijb)
{
	retv = "";
	sqlstm = "select id from deliveryordermaster where job_id=" + ijb.toString();
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() != 0)
	{
		for(d : r)
		{
			retv += d.get("id").toString() + ",";
		}
		try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
	}
	return retv;
}

void saveDO_Metadata(String iwhat)
{
	Object[] jkl = { customername, d_code, d_shipaddress1, d_shipaddress2, d_shipaddress3, d_shippingcontact, d_shippingphone, d_remark, d_transporter, d_airwaybill };
	dt = ngfun.getString_fromUI(jkl);

	sqlstm = "update deliveryordermaster set name='" + dt[0] + "', code='" + dt[1] + "'," +
	"shipaddress1='" + dt[2] + "', shipaddress2='" + dt[3] + "', shipaddress3='" + dt[4] + "'," +
	"shippingcontact='" + dt[5] + "', shippingphone='" + dt[6] + "', remark='" + dt[7] + "'," +
	"transporter='" + dt[8] + "', airwaybill='" + dt[9] + "' where id=" + iwhat;

	sqlhand.gpSqlExecuter(sqlstm);
	showDOList(last_showdo_type);
}

void saveDO_items(String ido)
{
	try
	{
		sqlstm = "delete from deliveryorder where dono='" + ido + "';";
		sqlhand.gpSqlExecuter(sqlstm); // remove all prev DO items first before saving new ones

		sqlstm = "";
		jk = items_rows.getChildren().toArray();
		ArrayList itms = new ArrayList();

		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			ti = kiboo.replaceSingleQuotes( ki[1].getValue().trim() ); // item
			atgs = kiboo.replaceSingleQuotes( ki[3].getValue().trim() ); // asset-tags
			snms = kiboo.replaceSingleQuotes( ki[4].getValue().trim() ); // s/nums
			tq = "1";
			try { kk = Integer.parseInt(kiboo.replaceSingleQuotes( ki[2].getValue().trim() ) ); tq = kk.toString(); }
			catch (Exception e) {}

			sqlstm += "insert into deliveryorder (dono,description,quantity,asset_tags,serial_numbers) values " +
			"('" + ido + "','" + ti + "'," + tq + ",'" + atgs + "','" + snms + "');";
		}
		if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);

	} catch (Exception e) {}
}

void showDO_items(String ido)
{
	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	ngfun.checkMakeGrid(itm_colws,itm_colls,items_holder,"items_grid","items_rows","background:#97b83a","",false);

	sqlstm = "select description,quantity,asset_tags,serial_numbers from deliveryorder where dono='" + ido + "';";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;

	for(d : r)
	{
		irow = gridhand.gridMakeRow("","","",items_rows);
		ngfun.gpMakeCheckbox(irow,"","","");
		ngfun.gpMakeTextbox(irow,"",d.get("description"),"font-size:9px;","99%",textboxnulldrop).setMultiline(true);
		ngfun.gpMakeTextbox(irow,"", GlobalDefs.nf0.format(d.get("quantity")),"font-size:9px;","60%",textboxnulldrop);
		ngfun.gpMakeTextbox(irow,"",sqlhand.clobToString(d.get("asset_tags")),"font-size:9px;","99%",textboxnulldrop).setMultiline(true);
		ngfun.gpMakeTextbox(irow,"",sqlhand.clobToString(d.get("serial_numbers")),"font-size:9px;","99%",textboxnulldrop).setMultiline(true);
	}
}

void showDO_meta(String ido)
{
	r = getnewDO_rec(ido);
	if(r == null) { guihand.showMessageBox("ERR: cannot access DO table.."); return; }

	Object[] jkl = { customername, d_code, d_shipaddress1, d_shipaddress2, d_shipaddress3, d_shippingcontact, d_shippingphone, d_remark, d_transporter, d_airwaybill };
	String[] fl = { "Name", "Code", "ShipAddress1", "ShipAddress2", "ShipAddress3", "ShippingContact", "ShippingPhone", "Remark", "transporter", "airwaybill" };

	ngfun.populateUI_Data(jkl,fl,r);
	showDO_items(ido);
	fillDocumentsList(documents_holder,RWDO_PREFIX,ido);

	ks = kiboo.checkNullString(r.get("Status"));
	tg = true;
	if(ks.equals("DRAFT") || ks.equals("")) tg = false;
	toggButts(2,tg);

	rdotitle_lbl.setValue("RDO " + ido + " : " + r.get("Name") );
	workarea.setVisible(true);
}

Object[] dolbhds =
{
	new listboxHeaderWidthObj("RDO",true,"50px"),
	new listboxHeaderWidthObj("Date",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Stat",true,"70px"), // 3
	new listboxHeaderWidthObj("User",true,"70px"),
	new listboxHeaderWidthObj("Rfb",true,"30px"),
	new listboxHeaderWidthObj("Transp",true,"80px"),
	new listboxHeaderWidthObj("Deliver",true,"80px"),
	new listboxHeaderWidthObj("DelDate",true,"70px"),
	new listboxHeaderWidthObj("JobId",true,"80px"), // 9
	new listboxHeaderWidthObj("P.List",true,"80px"),
};
RDO_POS = 0;
RDO_CUSTNAME_POS = 2;
RDO_STAT_POS = 3;
RDO_DELSTAT_POS = 6;
RDO_JOBID_POS = 9;
RDO_PICKLIST_POS = 10;

class dolbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_do = lbhand.getListcellItemLabel(isel,RDO_POS);
		glob_sel_do_stat = lbhand.getListcellItemLabel(isel,RDO_STAT_POS);
		glob_sel_do_jobid = lbhand.getListcellItemLabel(isel,RDO_JOBID_POS);
		global_selected_customername = lbhand.getListcellItemLabel(isel,RDO_CUSTNAME_POS);
		glob_sel_picklist = lbhand.getListcellItemLabel(isel,RDO_PICKLIST_POS);

		showDO_meta(glob_sel_do);
	}
}
dolbclkier = new dolbClick();

// itype: 1=by date and search text, 2=by DO
void showDOList(int itype)
{
	last_showdo_type = itype;

	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	doid = kiboo.replaceSingleQuotes(doid_tb.getValue().trim());

	sqlstm = "select top 200 id,entrydate,name,user1,job_id,status,del_status,transporter,deliverydate, packing_flag, " +
	"(select origid from rw_jobpicklist where parent_job=job_id) as picklist " +
	"from DeliveryOrderMaster ";

	switch(itype)
	{
		case 1:
			sqlstm += "where entrydate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' and name like '%" + st + "%'";
			break;
		case 2:
			if(doid.equals("")) return;
			sqlstm += "where id=" + doid;
			break;
	}

	sqlstm += " order by entrydate";

	Listbox newlb = lbhand.makeVWListbox_Width(do_holder, dolbhds, "do_lb", 3);

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.addEventListener("onSelect", dolbclkier);
	ArrayList kabom = new ArrayList();
	String[] fl = { "id", "entrydate", "name", "status", "user1", "packing_flag", "transporter",
	"del_status", "deliverydate", "job_id", "picklist" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void chopInsertJobIntoDO(String iwhat)
{
	jrec = getRWJob_rec(iwhat);
	if(jrec == null)
	{
		guihand.showMessageBox("ERR: cannot access job database...");
		return;
	}

	// get/set job metadata into DO
	adrsp = jrec.get("deliver_address").split("\n");
	try { d_shipaddress1.setValue(adrsp[0]); } catch (Exception e) {}
	try { d_shipaddress2.setValue(adrsp[1]); } catch (Exception e) {}
	try { d_shipaddress3.setValue(adrsp[2]); } catch (Exception e) {}
	d_shippingcontact.setValue( jrec.get("contact") );
	d_shippingphone.setValue( jrec.get("contact_tel") );
	d_remark.setValue( jrec.get("notes") );

	sqlstm = "delete from deliveryorder where dono='" + glob_sel_do + "';";
	sqlhand.gpSqlExecuter(sqlstm); // remove all DO items first before importing new ones

	// get 'em job items
	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	ngfun.checkMakeGrid(itm_colws,itm_colls,items_holder,"items_grid","items_rows","background:#97b83a","",false);

	items = sqlhand.clobToString( jrec.get("items") ).split("::");
	qtys = jrec.get("qtys").split("::");
	//colors = jrec.get("colors").split("::");
	isql = "";

	for(i=0;i<items.length;i++)
	{
		irow = gridhand.gridMakeRow("","","",items_rows);

		ngfun.gpMakeCheckbox(irow,"","","");
		//ngfun.gpMakeLabel(irow,"",(i+1).toString() + ".", "font-size:14px;font-weight:bold;");

		itm = "";
		try { itm = items[i]; } catch (Exception e) {}

		isql += "insert into deliveryorder (dono,description,quantity) values ('" + glob_sel_do + "','" + itm + "',";

		lk = ngfun.gpMakeTextbox(irow,"",itm,"font-size:9px;","99%",textboxnulldrop);
		lk.setMultiline(true);

		qty = "";
		try { qty = qtys[i]; } catch (Exception e) {}
		ngfun.gpMakeTextbox(irow,"",qty,"font-size:9px;","60%",textboxnulldrop);

		isql += qty + ");";
	}

	isql += "update deliveryordermaster set job_id=" + iwhat + " where id=" + glob_sel_do + ";";
	sqlhand.gpSqlExecuter(isql);
}

Object[] jobdohds =
{
	new listboxHeaderWidthObj("Job",true,"70px"),
	new listboxHeaderWidthObj("Date",true,"70px"),
	new listboxHeaderWidthObj("ETA",true,"70px"),
	new listboxHeaderWidthObj("ETD",true,"70px"),
	new listboxHeaderWidthObj("DOs",true,"70px"),
};

class jobdodclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();

		if(Messagebox.show("Importing details from job.. will overwrite everything" , "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		chopInsertJobIntoDO(lbhand.getListcellItemLabel(isel,0));
	}
}
jobdodoubleclik = new jobdodclick();

void showJobsByCustomer()
{
	// HARDCODED to list submitted jobs - TODO need to change to approved-job when they start approving jobs
	sqlstm = "select origid, datecreated, eta, etd from rw_jobs where customer_name='" + global_selected_customername + "' " +
	"and status='SUBMIT' order by origid desc";

	Listbox newlb = lbhand.makeVWListbox_Width(jobsdolb_holder, jobdohds, "jobsdo_lb", 10);
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	//newlb.addEventListener("onSelect", jobdodoubleclik);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "eta", "etd" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		kabom.add( getJob_linkDO(d.get("origid")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb,jobdodoubleclik);
}

Object[] pichkstkhds =
{
	new listboxHeaderWidthObj("AssetTag",true,"90px"),
	new listboxHeaderWidthObj("Serial",true,"90px"),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("Pallet",true,"60px"),
	new listboxHeaderWidthObj("Qty",true,"60px"),
	new listboxHeaderWidthObj("Short",true,"60px"),
};

void postInventory_DO()
{
	postInventory_Map.clear(); // always clear the hashmap

	// if DO is link to job, get the asset-tags from jobpicklist
	if(glob_sel_do_jobid.equals("")) return; // now just return if not link to job

	jrc = getJobPicklist_byParentJob(glob_sel_do_jobid);

	if(jrc == null) // no job pick-list link to job
	{
		guihand.showMessageBox("ERR: No item pick-list associated to job.. cannot do inventory posting.");
		return;
	}

	// in jobpicklist, check invtstat, if set, do not update inventory -- TODO, reverse-out
	ivtbit = (jrc.get("invtstat") == null) ? false : jrc.get("invtstat");
	if(ivtbit && useraccessobj.accesslevel != 9)
	{
		guihand.showMessageBox("ERRR!! Asset-tags in job already shorted in inventory..");
		return;
	}

	kt = sqlhand.clobToString(jrc.get("pl_asset_tags")).split("~");
	qtys = sqlhand.clobToString(jrc.get("pl_qty")).split("~");
	itms = sqlhand.clobToString(jrc.get("pl_items")).split("~");

	for(i=0; i<kt.length; i++) // go through the asset-tags and check for dups first before hitting SQL
	{
		ti = kt[i].split("\n");

		for(j=0; j<ti.length; j++)
		{
			z = ti[j].trim();
			if(!z.equals(""))
			{
				if(!postInventory_Map.containsKey(z))
				{
					postInventory_Map.put(z,1);
				}
				else
				{
					guihand.showMessageBox("ERR: duplicate asset-tags found.. " + z + ", please check.");
					return;
				}
			}
			else // if empty asset-tags, have to check and update inventory by quantity
			{
				//postInventory_Map.put( itms[i], Integer.parseInt(qtys[i]) );
			}
		}
	}

	Listbox newlb = lbhand.makeVWListbox_Width(piscan_holder, pichkstkhds, "pichkstk_lb", 20);
	ArrayList kabom = new ArrayList();
	errchek = 0;

	// check all asset-tags pallet/loca and serial-no/type
	Set theset = postInventory_Map.entrySet();
	Iterator ck = theset.iterator();
	while(ck.hasNext())
	{
		Map.Entry me = (Map.Entry)ck.next();
		tg = me.getKey(); // asset-tag from hashmap
		tqy = me.getValue(); // the qty

		kabom.add(tg);

		sqlstm = "select name,qty,pallet,serial,item from partsall_0 where assettag='" + tg + "';";
		//qr = f30_gpSqlFirstRow(sqlstm);
		qr = sqlhand.rws_gpSqlFirstRow(sqlstm);
		p1 = p2 = p3 = p4 = p5 = "";
		if(qr != null)
		{
			p1 = kiboo.checkNullString( qr.get("name") ).trim();
			p2 = kiboo.checkNullString( qr.get("pallet") );
			p4 = kiboo.checkNullString( qr.get("serial") ).trim().toUpperCase();
			p5 = kiboo.checkNullString( qr.get("item") ).trim();

			if(!p2.equals(PROD_PALLET_STR)) // if asset-tag was not set to PROD, err, all to-be DO items must be in PROD
				errchek++;

			if( p5.equals("DT") || p5.equals("MT") || p5.equals("NB") ) // if item-type = things requiring serial-num
			{
				if( p4.equals("") || p4.equals("NOSN") || p4.equals("---") ) errchek++; // and no serial-num found.. Error!!
			}

			// Check if qty in DB can fulfill this posting
			if(qr.get("qty") < 0 || qr.get("qty") < tqy) errchek++;

			p3 = GlobalDefs.nf0.format(qr.get("qty"));
		}
		else
			errchek++;

		kabom.add(p4); // serial
		kabom.add(p1); // item name
		kabom.add(p5); // item type
		kabom.add(p2); // pallet
		kabom.add(p3); // qty
		kabom.add(tqy.toString());

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}

	realpostinventory_b.setVisible( (errchek > 0) ? false : true);
	posterr_lbl.setVisible( (errchek > 0) ? true : false);
	postinventory_pop.open(postinvt_b);

	if(useraccessobj.accesslevel == 9)
	{
		realpostinventory_b.setVisible(true); // admin can see the butts
		revertinventory_b.setVisible(true);
	}

	// in job picklist module, add check for invtstat bit, if set, cannot modify anything
}

// check newDOmanager.zul for some hardcoded constants
// make sure sqlstm in caller starts with "declare @_masterid int; "
// u0001.PalletNoYH hardcoded pallet-id.. 3=out, 4=unknown(for testing only), need to chg in main-db
// itype: 1=minus stock, 2=add stock
String minusAddFocus_Stock(String iatg, int itype, int qty)
{
	if(iatg.equals("")) return;
	if(itype == 1) qty *= -1;
	tdate = calcFocusDate( kiboo.todayISODateTimeString() ).toString();

	plt = (itype == 1) ? OUT_PALLET : GENERAL_WH_PALLET;

	sqlstm = "if exists(select 1 from mr001 where code2='" + iatg + "')" +
	"begin " +
	"set @_masterid = (select masterid from mr001 where code2='" + iatg + "'); " +
	"update u0001 set PalletNoYH='" + plt + "' where extraid=@_masterid;" +
	"insert into ibals (code,date_,dep,qiss,qrec,val,qty2) ";

	switch(itype)
	{
		case 1: // do QISS
			sqlstm +=
			"values (@_masterid," + tdate + ",0," + qty.toString() + ",0,0,0); " +
			"end; ";
			break;

		case 2: // do QREC
		sqlstm +=
			"values (@_masterid," + tdate + ",0,0," + qty.toString() + ",0,0); " +
			"end; ";
			break;
	}
	return sqlstm;
}

// itype: 1=minus stock, 2=add stock
void superDOInventoryUpdater(int itype)
{
	if(postInventory_Map.size() == 0) return;

	lgstr = ((itype == 1) ? "Short " : "Revert ") + "inventory via DO.\n";

	sqlstm = "declare @_masterid int; ";
	wps = "";

	Set theset = postInventory_Map.entrySet();
	Iterator ck = theset.iterator();
	while(ck.hasNext())
	{
		Map.Entry me = (Map.Entry)ck.next();
		tg = me.getKey();
		tqy = me.getValue();
		wps += tg + "(" + tqy + "), ";
		sqlstm += minusAddFocus_Stock(tg,itype,tqy);
	}

	try { wps = wps.substring(0,wps.length()-2); } catch (Exception e) {}
	add_RWAuditLog(JN_linkcode(), "", lgstr + wps, useraccessobj.username);

	//f30_gpSqlExecuter(sqlstm); // TODO - chg to main sql-handler
	sqlhand.rws_gpSqlExecuter(sqlstm);
}

// 31/12/2014: parse snums based on asset-tags and populate textbox
void parsePopulate_snums()
{
	jk = items_rows.getChildren().toArray();
	for(i=0;i<jk.length;i++) // go through asset-tags and grab 'em serials if any
	{
		wi = "";
		ki = jk[i].getChildren().toArray();
		atgs = kiboo.replaceSingleQuotes( ki[3].getValue().trim() ).split("\n"); // asset-tags
		if(atgs.length > 0)
		{
			for(x=0;x<atgs.length;x++)
			{
				nn = atgs[x].trim();
				if(!nn.equals("")) wi += "'" + nn + "',";
			}
			try
			{
				wi = wi.substring(0,wi.length()-1);
				sqlstm = "select assettag,serial from partsall_0 where assettag in (" + wi + ")";
				r = sqlhand.rws_gpSqlGetRows(sqlstm);
				if(r.size() > 0) // found some s/numbs
				{
					snm = "";
					for(d : r)
					{
						snm += kiboo.checkNullString(d.get("assettag")) + " (" + kiboo.checkNullString(d.get("serial"))  + ")\n";
					}
					ki[4].setValue(snm); // insert snumbs
				}
			} catch (Exception e) {}
		}
	}
	
	//guihand.showMessageBox("ERR: cannot parse serial-numbers");
}

void updateDO_deliveryStat(String istat)
{
	if(glob_sel_do.equals("")) return;
	if(glob_sel_do_stat.equals("STKOUT")) // Only DO stat=STKOUT can update delivery status
	{
		dt = kiboo.getDateFromDatebox(delstat_date);
		tdt = kiboo.todayISODateTimeString();
		sqlstm = "update deliveryordermaster set deliverydate='" + dt + "', del_status_date='" + tdt + "',del_status='" + istat + "' where id=" + glob_sel_do;
		sqlhand.gpSqlExecuter(sqlstm);
		showDOList(last_showdo_type);
		add_RWAuditLog(JN_linkcode(), "", "Update delivery status", useraccessobj.username);
	}
	else
	{
		guihand.showMessageBox("ERR: DO is not yet STKOUT, you cannot update the delivery status..");
	}
}

// 31/12/2014: populate serial_numbers field based on asset-tags
void printBIRT_DO(String ido)
{
	deliverystat_pop.close();
	if(ido.equals("")) return;

	if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("expassframe"); newiframe.setWidth("100%"); newiframe.setHeight("600px");

	bfn = "rwreports/rwms_DO_v1.rptdesign";
	thesrc = birtURL() + bfn + "&thedonum1=" + ido;

	newiframe.setSrc(thesrc); newiframe.setParent(expass_div);
	expasspop.open(printdo_b);
}
