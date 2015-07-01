import org.victor.*;
// import data from multiple source -- used in contractBillingTrack

void popOp_suckContractcare(Object iwhat)
{
	cclcno_tb.setValue(i_lc_no.getValue());
	if(ccareqs_holder.getFellowIfAny("contcareqs_lb") != null) contcareqs_lb.setParent(null);
	contcarepop.open(iwhat);
}

void actualSuckContractcare()
{
	sqlstm = "";
	try { kx = contcareqs_lb.getItems().toArray(); } catch (Exception e) { return; }
	for(i=0;i<kx.length;i++)
	{
		atg = kiboo.replaceSingleQuotes( lbhand.getListcellItemLabel(kx[i],0) );
		sqlstm += "insert into rw_lc_equips (lc_parent,asset_tag, billable, buyout) values (" + glob_selected_lc + ",'" + atg + "',0,0);";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
		contcarepop.close();
		contcareqs_lb.setParent(null);
	}
}

// contractcare equips listing imported as of 20/02/2014
void impContractcare()
{
Object[] ccqhds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("Model",true,""),
};
	Listbox newlb = lbhand.makeVWListbox_Width(ccareqs_holder, ccqhds, "contcareqs_lb", 20);
	lcn = kiboo.replaceSingleQuotes( cclcno_tb.getValue().trim() );
	if(lcn.equals("")) return;
	sqlstm = "select ca.asset_tag, (select name from mr001 where code2 = ca.asset_tag) as equip_name " +
	"from contractcare_eqs ca where ca.lc_no='" + lcn + "';";
	drs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(drs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.setMultiple(true);
	//newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new assClick());
	ArrayList kabom = new ArrayList();
	for(d : drs)
	{
		kabom.add( kiboo.checkNullString(d.get("asset_tag")) );
		kabom.add( kiboo.checkNullString(d.get("equip_name")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// import items from FC6 DO
void impFC6_DO_Assets(String ilc, int itype)
{
	mylb = null;

	switch(itype)
	{
		case 1:
			mylb = impfc6dolb; // LBs hardcoded in contractBillingTrack_v1.zul
			break;
		case 2:
			mylb = flximpfc6dolb;
			break;
	}

	String[] k = new String[11];
	sqlstm = "";
	kx = mylb.getItems().toArray();
	for(i=0;i<kx.length;i++)
	{
		lx = kx[i];
		for(j=0;j<11;j++)
		{
			k[j] = kiboo.replaceSingleQuotes( lbhand.getListcellItemLabel(lx,j) );
		}
		sqlstm += "insert into rw_lc_equips (asset_tag,serial_no,brand,model,type,color,hdd,ram,lc_parent,cust_location,billable,buyout) values " +
		"('" + k[0] + "', '" + k[1] + "','" + k[3] + "','" + k[4] + "','" + k[5] + "'," +
		"'" + k[6] + "','" + k[7] + "','" + k[8] + "'," + ilc + ",'" + k[10] + "',0,0);";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(ilc);
		importdoassets_pop.close();
		fleximportfc6_pop.close();
	}
}

// Actually importing BOM's builds into LC
// TODO 29/08/2013 just assume BOM is VERIFIED, but still need do checks later
void importBOMToLC(String ilcid, String ibid)
{
	pmsg = "Processing BOM import";
	ierr = 0; blnkastg = 0;
	assettags = "";

	sqlstm = 
	"select srid.asset_tag, srid.bomtype, smd.supplier_part_number as serial_no," +
	"smd.brandname as brand, smd.description as model, " +
	"srid.ram, srid.ram2, srid.ram3, srid.ram4," +
	"srid.hdd, srid.hdd2, srid.hdd3, srid.hdd4, srid.monitor," +
	"srid.battery, srid.poweradaptor, srid.mouse, srid.keyboard, srid.gfxcard, srid.misc," +
	"srid.osversion, srid.offapps, srid.coa1, srid.coa2, srid.coa3, srid.coa4 " +
	"from stockrentalitems_det srid " +
	"left join stockmasterdetails smd on smd.stock_code=srid.asset_tag " +
	"where parent_id=" + ibid;

	rcs = sqlhand.gpSqlGetRows(sqlstm);

	if(rcs.size() == 0)
	{
		pmsg += "\nNothing to import..";
		ierr++;
	}

	for(d : rcs)
	{
		astg = kiboo.checkNullString(d.get("asset_tag")).trim();
		if(astg.equals("")) blnkastg++;
		else
		{
			pmsg += "\n\t" + astg;
			ast = assetLinkToLC(astg);
			switch(ast)
			{
				case 0:
					pmsg += " NOT FOUND in stock-master";
					ierr++;
					break;
				case 1:
					pmsg += " OK";
					assettags += "'" + astg + "',";
					break;
				case 2:
					pmsg += " ALREADY LINKED to ";
					lnlc = assetExistInLC(astg);
					if(!lnlc.equals(""))
					{
						pmsg += " record " + lnlc;
					}
					ierr++;
					break;
			}
		}
	}

	if(blnkastg > 0)
		pmsg += "\nERR: Found " + blnkastg.toString() + " blank build(s)/asset-tag";

	if(ierr == 0 && blnkastg == 0) // if no error found - can insert LC-id into asset
	{
		usqlstm = "";

		for(d : rcs) // insert assets into rw_leaseequipments
		{
			btype = "DT";
			if( kiboo.checkNullString(d.get("bomtype")).equals("NOTEBOOK") ) btype = "NB";
			if( kiboo.checkNullString(d.get("bomtype")).equals("MONITOR") ) btype = "MT";
			
			usqlstm +=
			"insert into rw_lc_equips (lc_parent,asset_tag,serial_no,type,brand,model,bom_id," +
			"ram,ram2,ram3,ram4,hdd,hdd2,hdd3,hdd4,battery,poweradaptor,gfxcard," +
			"mouse,keyboard,osversion,offapps,coa1,coa2,coa3,coa4,monitor,billable,buyout) values " +
			"(" + ilcid + ",'" + d.get("asset_tag") + "','" + kiboo.checkNullString(d.get("serial_no")) + "'," +
			"'" + btype + "','" + kiboo.checkNullString(d.get("brand")) + "'," + 
			"'" + kiboo.checkNullString(d.get("model")) + "'," + ibid +

			",'" + kiboo.checkNullString(d.get("ram")) + "','" + kiboo.checkNullString(d.get("ram2")) + "','" + 
			kiboo.checkNullString(d.get("ram3")) + "','" + kiboo.checkNullString(d.get("ram4")) + "','" +
			kiboo.checkNullString(d.get("hdd")) + "','" + kiboo.checkNullString(d.get("hdd2")) + "','" +
			kiboo.checkNullString(d.get("hdd3")) + "','" + kiboo.checkNullString(d.get("hdd4")) + "','" +
			kiboo.checkNullString(d.get("battery")) + "','" + kiboo.checkNullString(d.get("poweradaptor")) + "','" +
			kiboo.checkNullString(d.get("gfxcard")) + "','" + kiboo.checkNullString(d.get("mouse")) + "','" +
			kiboo.checkNullString(d.get("keyboard")) + "','" + kiboo.checkNullString(d.get("osversion")) + "','" +
			kiboo.checkNullString(d.get("offapps")) + "','" + kiboo.checkNullString(d.get("coa1")) + "','" +
			kiboo.checkNullString(d.get("coa2")) + "','" + kiboo.checkNullString(d.get("coa3")) + "','" +
			kiboo.checkNullString(d.get("coa4")) + "','" + kiboo.checkNullString(d.get("monitor")) + "', 0, 0)";
		}

		try { assettags = assettags.substring(0,assettags.length()-1); } catch (Exception e) {}

		// update smd.lc_id (every asset-tag)
		usqlstm += "update stockmasterdetails set lc_id=" + ilcid + " where stock_code in (" + assettags + ");";
		// update stockrentalitems.lc_id (BOM main rec)		
		usqlstm += "update stockrentalitems set lc_id=" + ilcid + " where origid=" + ibid;

		//pmsg += "\n\n" + usqlstm;
		pmsg += "\n\nBOM's build(s) imported into LC" + ilcid;

		sqlhand.gpSqlExecuter(usqlstm);
		showAssets(ilcid); // refresh
	}

	importbom_stat_lbl.setValue(pmsg);
	importbom_statpop.open(assimpbom_b);
}

class assbtnclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		alert("as:" + isel.getParent());
	}
}

class dobtnclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		kchs = isel.getParent().getChildren().toArray();
		donum = kchs[1].getValue().trim();
		//alert("lc: " + glob_selected_lc + " == do: " + donum );

		dexp_do_no_lbl.setValue(donum);
		do_extra_pop.open(assigncustomer_b);
	}
}

class rmabtnclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		kchs = isel.getParent().getChildren().toArray();
		donum = kchs[1].getValue().trim();
	}
}

glob_asset_butt_click = new assbtnclik();
glob_dorder_butt_click = new dobtnclik();
glob_rma_butt_click = new rmabtnclik();

Object[] ido_hds =
{
	new listboxHeaderWidthObj("Asset.Tag",true,"80px"),
	new listboxHeaderWidthObj("S/Num",true,"100px"),
	new listboxHeaderWidthObj("Product",true,""),
	new listboxHeaderWidthObj("brandyh",false,""),
	new listboxHeaderWidthObj("modelyh",false,""),
	new listboxHeaderWidthObj("itemtypeyh",false,""),
	new listboxHeaderWidthObj("colouryh",false,""),
	new listboxHeaderWidthObj("hddsizeyh",false,""),
	new listboxHeaderWidthObj("ramsizeyh",false,""),
	new listboxHeaderWidthObj("DO",true,"60px"),
	new listboxHeaderWidthObj("Dlvr",false,""),
};

/**
 * [show_FC_DO description]
 * @param iwher      pop-up open at position
 * @param itype      type of listing
 * @param iassholder assets holder
 * @param ilbid      listbox ID string
 */

void show_FC_DO(Object iwher, int itype, Div iassholder, String ilbid )
{
	sqlstm = "select d.voucherno, p.name, p.code, p.code2, " +
	"pd.brandyh, pd.modelyh, pd.itemtypeyh, pd.colouryh, pd.hddsizeyh, pd.ramsizeyh " +
	"from data d left join mr001 p on p.masterid = d.productcode " +
	"left join u0001 pd on pd.extraid = d.productcode " +
	"where d.vouchertype=6144 and productcode<>0 ";

	do_deliveryto = "";

	if(itype == 1)
	{
		if(glob_lcmeta_rec == null) return; // no LC-rec, just ret
		rwn = kiboo.checkNullString(glob_lcmeta_rec.get("rwno")).replaceAll("RWI:","").trim();
		if(rwn.indexOf("RW") == -1) rwn = "RW" + rwn;

		fc6 = glob_lcmeta_rec.get("fc6_custid");

		// "select convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as voucherdate, d.vouchertype, d.extraheaderoff, ri.dorefyh
		sqlstm2 = "select top 1 convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) as voucherdate," +
		"ri.dorefyh, ri.deliverytoyh from data d " +
		"left join u001b ri on ri.extraid=d.extraheaderoff " +
		"where d.voucherno='" + rwn + "';";

		//alert(glob_lcmeta_rec + " :: " + rwn + " :: " + fc6 + " :: " + sqlstm2);
		drc = sqlhand.rws_gpSqlFirstRow(sqlstm2);
		dorf = kiboo.checkNullString(drc.get("dorefyh")).trim();
		do_deliveryto = kiboo.checkNullString(drc.get("deliverytoyh")).trim();
		if(dorf.equals("")) return;

		kk = dorf.split("[,/ ]");
		mdo = "";

		for(i=0;i<kk.length;i++)
		{
			try { mdo += "'" + kk[i].trim() + "',"; } catch (Exception e) {}
		}

		try { mdo = mdo.substring(0,mdo.length()-1); } catch (Exception e) {}
		sqlstm += "and d.voucherno in (" + mdo + ");";
	}

	idon = kiboo.replaceSingleQuotes( flexfc6do_tb.getValue().trim() );

	// Flexi-DO import function type
	if(itype == 2 || itype == 3)
	{
		if(idon.equals("")) return;
		/*
		rwn = i_rwno.getValue().replaceAll("RWI:","").trim();
		if(rwn.indexOf("RW") == -1) rwn = "RW" + rwn;
		// "left join u001c di on di.extraid = d.extraheaderoff " +
		sqlstm2 = "select top 1 ri.deliverytoyh from data d " +
		"left join u001b ri on ri.extraid=d.extraheaderoff " +
		"where d.voucherno='" + rwn + "';";
		drc = sqlhand.rws_gpSqlFirstRow(sqlstm2);
		do_deliveryto = kiboo.checkNullString(drc.get("deliverytoyh")).trim();
		*/
		sqlstm2 = "select top 1 ri.deliveryaddressyh from data d " +
		"left join u001c ri on ri.extraid=d.extraheaderoff " +
		"where d.voucherno='" + idon + "' and d.vouchertype=6144;";

		drc = null;
		if(itype == 2) drc = sqlhand.rws_gpSqlFirstRow(sqlstm2);
		if(itype == 3) drc = fj0_gpSqlFirstRow(sqlstm2);

		do_deliveryto = kiboo.checkNullString(drc.get("deliveryaddressyh")).trim();
		sqlstm += "and d.voucherno='" + idon + "';";
		// TODO check DO really belongs to customer
	}

	prds = null;

	if(itype == 2) prds = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(itype == 3) prds = fj0_gpSqlGetRows(sqlstm); // rws_warehouse/goodsreceive/injtest.zs

	if(prds.size() == 0) return;

	imp_do_lbl.setValue("FC6 DO : " + dorf);
	Listbox newlb = lbhand.makeVWListbox_Width(iassholder, ido_hds, ilbid, 13);

	String[] flds = { "code2","code","name","brandyh","modelyh","itemtypeyh","colouryh","hddsizeyh","ramsizeyh","voucherno" };
	ArrayList kabom = new ArrayList();
	for(d : prds)
	{
		ngfun.popuListitems_Data(kabom, flds, d);
		kabom.add(do_deliveryto);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	if(itype == 1) importdoassets_pop.open(iwher);
}

// 19/06/2014: Show 'em LCs in batch-billing-LC box - i_batch_lc def in XML-form
void listBatchBillingLC()
{
	kk = makeQuotedFromComma( kiboo.replaceSingleQuotes(i_batch_lc.getValue().trim()) );
	if(kk.equals("")) return;
	search_txt.setValue(kk);
	listROCLC(4); // show all comma-separated LCs
}

// 20/06/2014: import assets def in batch_lc -- for MISC mostly - i_batch_lc def in XML-form
void impBatchLCAssets()
{
	kk = makeQuotedFromComma( kiboo.replaceSingleQuotes(i_batch_lc.getValue().trim()) );
	if(kk.equals("")) return;

	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor,billable,buyout,impfromlc) " +

	"select " + glob_selected_lc + ", lce.asset_tag, lce.serial_no, lce.type, lce.brand, lce.model, lce.capacity, lce.color, lce.coa1, lce.ram, lce.hdd, lce.others," +
	"lce.cust_location, lce.qty, lce.replacement, lce.replacement_date, lce.rma_qty, lce.remarks, lce.collected," +
	"lce.RM_Asset, lce.RM_Month, lce.latest_replacement, lce.roc_no, lce.do_no, lce.cn_no, lce.asset_status," +
	"lce.coa2, lce.coa3, lce.coa4, lce.ram2, lce.ram3, lce.ram4, lce.hdd2, lce.hdd3, lce.hdd4," +
	"lce.osversion, lce.offapps, lce.poweradaptor, lce.battery, lce.estatus, lce.gfxcard, lce.mouse, lce.keyboard, lce.monitor, lce.billable, lce.buyout, lcr.lc_id " +
	"from rw_lc_equips lce left join rw_lc_records lcr on lce.lc_parent = lcr.origid " +
	"WHERE lce.lc_parent in (select origid from rw_lc_records where lc_id in (" + kk + ") ) " +
	"and lce.billable=1;";

	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
	guihand.showMessageBox("Kabooomm... batch-imported 'em assets");
}

// 09/01/2015: import RDO assets
void importRDO(String ilc)
{
	sedutRDOpop.close();
	if(ilc.equals("")) return;
	rdo = kiboo.replaceSingleQuotes( imprdo_tb.getValue().trim() );
	try { k = Integer.parseInt(rdo); } catch (Exception e) { guihand.showMessageBox("We need RDO nombor to work"); return; }
	sqlstm = "select serial_numbers from deliveryorder where dono='" + rdo + "';";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) { guihand.showMessageBox("Nothing to import from this RDO!"); return; }

	drc = getnewDO_rec(rdo);
	sadr = ""; // shipment address
	if(drc != null)
	{
		sadr = kiboo.checkNullString(drc.get("ShipAddress1")) + "\n" +
		kiboo.checkNullString(drc.get("ShipAddress2")) + "\n" + 
		kiboo.checkNullString(drc.get("ShipAddress3"));
	}

	sqlstm = "";
	for(d : r)
	{
		m = sqlhand.clobToString( d.get("serial_numbers") );
		snp = m.split("\n");
		//for(i=0; i<snp.length; i++)
		for(i=0; i<snp.length; i++)
		{
			xp = snp[i].split(" ");
			try { atg = xp[0]; } catch (Exception e) { atg = ""; }
			try { snm = xp[1].replaceAll("\\(","").replaceAll("\\)",""); } catch (Exception e) { snm =""; }

			if(!atg.equals("")) // must have rw ass-tag to insert
				sqlstm += "insert into rw_lc_equips (asset_tag,serial_no,lc_parent,billable,buyout,cust_location,do_no) values " +
				"('" + atg + "','" + snm + "'," + ilc + ",0,0,'" + sadr + "','" + rdo + "');";
		}
	}
	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(ilc);
		imprdo_tb.setValue("");
		guihand.showMessageBox("RDO asset-tags imported..");
	}
}

