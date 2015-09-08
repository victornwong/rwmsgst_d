import org.victor.*;
// General funcs for goodsReceive_v2.zul
// need to port codes from MEL_specUpdate_FC6.zs for temp.GRN injection
//  Written by Victor Wong

String[] scanitems_colws = { "30px", "",          "180px",     "100px", "40px" };
String[] scanitems_collb = { "",     "Item name", "Asset tag", "Serial","Qty" };

/**
 * Get specs by asset-tag passed
 * 07/09/2015: modif to get from 0J0 database if not found in 0J1
 * @param  iatg asset-tag to search for
 * @return      db record
 */
Object getExisting_inventoryRec(String iatg)
{
	/*
	sqlstm = "SELECT top 1 m.masterid, p.Name, m.Code2 AS AssetTag, m.Code AS serial, b.QtyBal AS Qty, u.ShipmentCodeYH AS ShipmentCode, u.GradeYH AS grade, pl.Name AS pallet, " +
	"pl.MasterId AS plmasterid, u.BrandYH AS Brand, u.ItemTypeYH AS Item, u.ModelYH AS Model, u.ProcessorYH AS Processor, u.MonitorSizeYH AS MonitorSize, " +
	"u.MonitorTypeYH AS MonitorType, u.ColourYH AS colour, u.CasingYH AS casing, u.COA1YH AS COA, u.COA2YH AS COA2, u.RAMSizeYH AS RAM, " +
	"u.HDDSizeYH AS HDD, u.CD1YH AS Cdrom1, u.CD2YH AS CDrom2, u.CommentsYH AS Comment " +
	"FROM dbo.mr001 AS m INNER JOIN " +
	"dbo.u0001 AS u ON m.Eoff = u.ExtraId INNER JOIN " +
	"dbo.mr008 AS p ON u.ProductNameYH = p.MasterId INNER JOIN " +
	"dbo.itembal AS b ON m.MasterId = b.code INNER JOIN " +
	"dbo.mr003 AS pl ON u.PalletNoYH = pl.MasterId " +
	"where m.Code2='" + iatg + "';";
	return f30_gpSqlFirstRow(sqlstm);

	TODO Focus5012 got more fields - bluetooth etc
	*/
	sqlstm = "SELECT top 1 m.masterid, p.Name, m.Code2 AS AssetTag, m.Code AS serial, b.QtyBal AS Qty, u.ShipmentCodeYH AS ShipmentCode, u.GradeYH AS grade, pl.Name AS pallet, " +
	"pl.MasterId AS plmasterid, u.BrandYH AS Brand, u.ItemTypeYH AS Item, u.ModelYH AS Model, u.ProcessorYH AS Processor, u.MonitorSizeYH AS MonitorSize, " +
	"u.MonitorTypeYH AS MonitorType, u.ColourYH AS colour, u.CasingYH AS casing, u.COA1YH AS COA, u.COA2YH AS COA2, u.RAMSizeYH AS RAM, " +
	"u.HDDSizeYH AS HDD, u.CD1YH AS Cdrom1, u.CD2YH AS CDrom2, u.CommentsYH AS Comment " +
	"FROM dbo.mr001 AS m INNER JOIN " +
	"dbo.u0001 AS u ON m.Eoff = u.ExtraId INNER JOIN " +
	"dbo.mr008 AS p ON u.ProductNameYH = p.MasterId INNER JOIN " +
	"dbo.itembal AS b ON m.MasterId = b.code INNER JOIN " +
	"dbo.mr003 AS pl ON u.PalletNoYH = pl.MasterId " +
	"where m.Code2='" + iatg + "';";

	retval = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(retval == null) // cannot source from default 0J1, source from 0J0
	{
		retval = fj0_gpSqlFirstRow(sqlstm); // in rws_warehouse/goodsreceive/injtest.zs
	}
	return retval;
}

void hidereset_workarea()
{
	glob_sel_grn = glob_sel_stat = "";
	grnmeta_holder.setVisible(false);
	grnitems_workarea.setVisible(false);
}

class tbnulldrop implements org.zkoss.zk.ui.event.EventListener
{	public void onEvent(Event event) throws UiException	{} }
textboxnulldrop = new tbnulldrop();

// GRN items insert new row - won't save into DB
void makeItemRow(Component irows, String iname, String iatg, String isn, String iqty, String istat)
{
	k9 = "font-size:9px";
	nrw = new org.zkoss.zul.Row();
	nrw.setParent(irows);
	ngfun.gpMakeCheckbox(nrw,"","","");
	//ngfun.gpMakeTextbox(nrw,"",iname,k9,"98%",textboxnulldrop); // item-name
	ngfun.gpMakeLabel(nrw,"",iname,k9); // item-name using label

	if(istat.equals("DRAFT")) // draft GRN, insert textboxes
	{
		ngfun.gpMakeTextbox(nrw,"",iatg,k9,"95%",textboxnulldrop); // asset-tag
		ngfun.gpMakeTextbox(nrw,"",isn,k9,"95%",textboxnulldrop); // serial
		ngfun.gpMakeTextbox(nrw,"",iqty,k9,"95%",textboxnulldrop); // qty
	}
	else // else only labels
	{
		ngfun.gpMakeLabel(nrw,"",iatg,k9);
		ngfun.gpMakeLabel(nrw,"",isn,k9);
		ngfun.gpMakeLabel(nrw,"",iqty,k9);
	}
}

// general purpose remove items from list
// itype: 1=ticked, 2=all
void itemsRemovalfunc(int itype)
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			toremove = false;
			ki = jk[i].getChildren().toArray();
			if(ki[0].isChecked() && itype == 1) toremove = true;
			if(itype == 2) toremove = true;
			if(toremove) jk[i].setParent(null);
		}
	} catch (Exception e) {}
}

class prdnsdblick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selecProduct_pop.close();
		isel = event.getTarget();
		ifnd = lbhand.getListcellItemLabel(isel,0); // stock name
		//istk = lbhand.getListcellItemLabel(isel,1); // stock code
		try
		{
			jk = grn_rows.getChildren().toArray();
			for(i=0;i<jk.length;i++)
			{
				ki = jk[i].getChildren().toArray();
				if(ki[0].isChecked())
				{
					ki[1].setValue(ifnd); // refer to makeItemRow() for item column posi
					//ki[5].setValue(istk);
				}
			}
		//itemFunc("clrticks_b");
		} catch (Exception e) {}
	}
}
prodsearch_dclick = new prdnsdblick();

void searchProductName_FC(String sct)
{
	Object[] pnhds =
	{
		new listboxHeaderWidthObj("Product name",true,""),
		//new listboxHeaderWidthObj("STK",false,""),
	};

	sct = sct.trim();
	if(sct.equals("")) return;
	Listbox newlb = lbhand.makeVWListbox_Width(selprods_holder, pnhds, "prodname_lb", 3);
	sct = sct.replace(" ","%");
	sqlstm = "select top 50 name,masterid from mr008 where name like '%" + sct + "%' order by masterid desc";
	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	//r = f30_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); newlb.setRows(20);
	ArrayList kabom = new ArrayList();
	String[] lbi = new String[1];
	for(d : r)
	{
		lbi[0] = d.get("name");
		//lbi[1] = d.get("masterid").toString();
		//ngfun.popuListitems_Data(kabom,flds,d);
		lbhand.insertListItems(newlb,lbi,"false","");
	}
	lbhand.setDoubleClick_ListItems(newlb, prodsearch_dclick);
}

// Split and insert scanned asset-tags and serials from textbox to grn-items list
// PROB: always insert blank row - dunno why!!
void fillUp_scanned_assets()
{
/* original-codes which uses asset-tags and serial-no textbox
	kk = main_scan_atgs.getValue().trim();
	if(kk.equals("")) return;
	atgs = kk.split("\n");

	kk2 = main_scan_serials.getValue().trim();
	snm = kk2.split("\n");

	if(atgs.length != snm.length) // imbalance asset-tags and serials
	{
		guihand.showMessageBox("Take note.. imbalance asset-tags and serials scanned.. but still insert");
	}

	for(i=0; i<atgs.length; i++)
	{
		tt = "";
		try { tt = snm[i]; } catch (Exception e) {}
		makeItemRow(grn_rows,"",atgs[i],tt,"1","DRAFT");
	}
*/
	kk = main_scan_atgs.getValue().trim();
	if(kk.equals("")) return;
	atgsns = kk.split("\n");
	t1 = t2 = "";

	for(i=0; i<atgsns.length; i+=2)
	{
		try
		{
			t1 = atgsns[i].trim();
			t2 = atgsns[i+1].trim();
			makeItemRow(grn_rows,"",t1,t2,"1","DRAFT");
	 } catch (Exception e) {}
	}
}

// Really save grn-items into DB
void saveGRN_items(String igrn)
{
	try
	{
		itms = atgs = srls = qtys = "";

		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();

			ii = kiboo.replaceSingleQuotes( ki[1].getValue().trim().replaceAll("~"," ") );
			itms += ((ii.equals("")) ? "NONAME" : ii) + "~";

			ii = kiboo.replaceSingleQuotes( ki[2].getValue().trim().replaceAll("~"," ") );
			atgs += ((ii.equals("")) ? "NOTAG" : ii) + "~";

			ii = kiboo.replaceSingleQuotes( ki[3].getValue().trim().replaceAll("~"," ") );
			srls += ((ii.equals("")) ? "NOSN" : ii) + "~";

			ii = kiboo.replaceSingleQuotes( ki[4].getValue().trim().replaceAll("~"," ") );
			qtys += ((ii.equals("")) ? "NOQTY" : ii) + "~";
		}

		sqlstm = "update rw_grn set item_names='" + itms + "',asset_tags='" + atgs + "',serials='" + srls + "',qtys='" + qtys + "' where origid=" + igrn;
		sqlhand.gpSqlExecuter(sqlstm);
		guihand.showMessageBox("OK: GRN items saved..");

	} catch (Exception e) { guihand.showMessageBox("ERR: cannot save the GRN items.."); }
}

/**
 * Show RWMS GRN meta-data
 * @param iwhat which GRN no.
 */
void showGRN_meta(String iwhat)
{
	r = getGRN_rec_NEW(iwhat);
	if(r == null) { guihand.showMessageBox("ERR: cannot access GRN database.."); return; }

	String[] fl = { "ourpo", "vendor", "vendor_do", "vendor_inv", "shipmentcode", "grn_remarks","origid" };
	Object[] jkl = { g_ourpo, g_vendor, g_vendor_do, g_vendor_inv, g_shipmentcode, g_grn_remarks, g_origid };
	ngfun.populateUI_Data(jkl,fl,r);

	fillDocumentsList(documents_holder,GRN_PREFIX,iwhat);
	
	itms = sqlhand.clobToString(r.get("item_names")).split("~"); // show 'em grn items
	atgs = sqlhand.clobToString(r.get("asset_tags")).split("~");
	srls = sqlhand.clobToString(r.get("serials")).split("~");
	qtys = sqlhand.clobToString(r.get("qtys")).split("~");

	if(scanitems_holder.getFellowIfAny("grn_grid") != null) grn_grid.setParent(null);

	ngfun.checkMakeGrid(scanitems_colws, scanitems_collb, scanitems_holder, "grn_grid", "grn_rows", "", "", false);

	for(i=0;i<itms.length; i++)
	{
		try {
		makeItemRow(grn_rows,itms[i],atgs[i],srls[i],qtys[i],r.get("status"));
		} catch (Exception e) {}
	}

	grnmeta_holder.setVisible(true);
	grnitems_workarea.setVisible(true);

	bx = (!glob_sel_stat.equals("DRAFT")) ? true : false;
	toggButts(bx);
}

void toggButts(boolean iwhat)
{
	Object[] jkl = { updgrn_b, fillupitems_b, clrticks_b, additem_b, remitem_b, remall_b,
		sourcedets_b, selprod_b, mainbutt_impgco, saveitems_b };

	for(i=0; i<jkl.length; i++)
	{
		jkl[i].setDisabled(iwhat);
	}
}

Object[] grnhds =
{
	new listboxHeaderWidthObj("GRN",true,"40px"),
	new listboxHeaderWidthObj("Date",true,"70px"),
	new listboxHeaderWidthObj("OurRef",true,"50px"),
	new listboxHeaderWidthObj("Stat",true,"60px"), // 3
	new listboxHeaderWidthObj("User",true,"70px"),
	new listboxHeaderWidthObj("Commit",true,"70px"),
	new listboxHeaderWidthObj("Vendor",true,""),
	new listboxHeaderWidthObj("V.DO",true,"60px"),
	new listboxHeaderWidthObj("V.Inv",true,"60px"),
	new listboxHeaderWidthObj("GCO",true,"60px"),

	new listboxHeaderWidthObj("A.Date",true,"70px"),
	new listboxHeaderWidthObj("A.Stat",true,"60px"), // 11
	new listboxHeaderWidthObj("A.User",true,"70px"),
	new listboxHeaderWidthObj("FC6 T.GRN",true,"80px"),
};
GRNSTAT_POS = 3;
AUDITSTAT_POS = 11;

class grnclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_grn = lbhand.getListcellItemLabel(isel,0);
		glob_sel_stat = lbhand.getListcellItemLabel(isel,GRNSTAT_POS);
		glob_sel_auditstat = lbhand.getListcellItemLabel(isel,AUDITSTAT_POS);

		if(grn_show_meta) showGRN_meta(glob_sel_grn);

		grn_Selected_Callback();
	}
}
grnclik = new grnclicker();

// itype: 1=by search text, 2=by GRN id, 3=by asset-tag
void showGRN(int itype)
{
	last_showgrn_type = itype;
	sct = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	jid = kiboo.replaceSingleQuotes(grnid_tb.getValue().trim());
	batg = kiboo.replaceSingleQuotes( assettag_by.getValue().trim() );

	Listbox newlb = lbhand.makeVWListbox_Width(grnheaders_holder, grnhds, "grnheader_lb", 3);
	sqlstm = "select origid,datecreated,ourpo,status,vendor,vendor_do,vendor_inv,username," +
	"commitdate,audit_date,audit_user,audit_stat,gcn_id,fc_tempgrn from rw_grn ";
	switch(itype)
	{
		case 1 :
			sqlstm += "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!sct.equals(""))
				sqlstm += " and (vendor like '%" + sct + "%' or vendor_do like '%" + sct + "%' or " +
				"vendor_inv like '%" + sct + "% or ourpo like '%" + sct + "%' " +
				"or grn_remarks like '%" + sct + "%' or shipmentcode like '%" + sct + "%') ";
			break;
		case 2 : // by grn-id
			sqlstm += "where origid=" + jid;
			break;
		case 3 : // by asset-tag
			sqlstm += "where convert(nvarchar(max),asset_tags) like '%" + batg + "%' ";
			break;
	}

	try { if(!showgrn_extra_sql.equals("")) sqlstm += showgrn_extra_sql; } catch (Exception e) {}
	sqlstm += " order by origid desc";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;

	newlb.setRows(10); newlb.setMold("paging");
	newlb.addEventListener("onSelect", grnclik);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid","datecreated","ourpo","status","username","commitdate",
	"vendor","vendor_do","vendor_inv","gcn_id","audit_date","audit_stat","audit_user","fc_tempgrn"};
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// Import from GCO table. Item description got [DT],[NB],etc.. 
// use can source prev FC6 specs(from assettags) or set a new one
void import_FromGCO(String igcn)
{
	sqlstm = "select customer_name, collection_notes, items_code, items_desc from rw_goodscollection where origid=" + igcn;
	r = sqlhand.gpSqlFirstRow(sqlstm);

	if(r == null)
	{
		guihand.showMessageBox("ERR: cannot find GCO");
		return;
	}

	g_vendor.setValue(r.get("customer_name"));
	g_grn_remarks.setValue(r.get("collection_notes"));
	atgs = sqlhand.clobToString(r.get("items_code")).split("~");
	itms = sqlhand.clobToString(r.get("items_desc")).split("~");

	for(i=0; i<atgs.length; i++)
	{
		a1 = ""; try { a1 = itms[i]; } catch (Exception e) {}
		a2 = ""; try { a2 = atgs[i]; } catch (Exception e) {}
		makeItemRow(grn_rows,a1,a2,"","1",glob_sel_stat);
	}

	sqlstm = "update rw_grn set gcn_id=" + igcn + " where origid=" + glob_sel_grn;
	sqlhand.gpSqlExecuter(sqlstm); // update rw_grn.gcn_id
	grnFunc("updgrn_b"); // update GRN metadata too
}

// Try to source previous product-name and serials from mr001
void sourcePrevious_NameSerials()
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			py = getExisting_inventoryRec(ki[2].getValue());
			if(py != null)
			{
				ki[1].setValue(py.get("Name"));
				ki[3].setValue(py.get("serial"));
			}
		}
	} catch (Exception e) {}	
}

// 16/10/2014: generate GRN printout
void genPrint_GRN(igrn)
{
	r = getGRN_rec_NEW(igrn);
	if(r == null) { guihand.showMessageBox("ERR: cannot access GRN database.."); return; }

	itms = sqlhand.clobToString(r.get("item_names")).split("~");
	atgs = sqlhand.clobToString(r.get("asset_tags")).split("~");
	srls = sqlhand.clobToString(r.get("serials")).split("~");
	qtys = sqlhand.clobToString(r.get("qtys")).split("~");

	sqlstm = "delete from rw_grn_tags where grn_id=" + igrn;
	sqlhand.gpSqlExecuter(sqlstm); // delete prev rec from rw_grn_tags

	msql = "";
	for(i=0;i<itms.length; i++)
	{
		try {
			msql += "insert into rw_grn_tags (grn_id,g_actual_name,g_asset_tag,g_serial_no,g_qty) values " +
			"(" + igrn + ",'" + itms[i] + "','" + atgs[i] + "','" + srls[i] + "'," + qtys[i] + ");";
		} catch (Exception e) {}
	}
	sqlhand.gpSqlExecuter(msql);

	if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("expassframe"); newiframe.setWidth("100%"); newiframe.setHeight("600px");
	bfn = "rwreports/GRN_prnout_v1.rptdesign";
	thesrc = birtURL() + bfn + "&grn_id_1=" + igrn;
	newiframe.setSrc(thesrc);
	newiframe.setParent(expass_div);
	expasspop.open(genprn_b);
}
