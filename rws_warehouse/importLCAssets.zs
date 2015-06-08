import org.victor.*;

// 28/10/2013: new things to import from rw_gc_transient

// 02/09/2014: add/show new collect-items row
// iatg:assettag, isn:serial no, idesc:item desc, ilc:lc_id
void addRow_Imported_Things(String iatg, String isn, String idesc, String ilc)
{
	f9 = "font-size:9px";
	nrw = new org.zkoss.zul.Row();
	nrw.setParent(items_rows);
	gpMakeCheckbox(nrw,"","","");
	gpMakeTextbox(nrw,"",iatg,"","99%"); // ass-tag
	gpMakeTextbox(nrw,"",isn,f9,"99%"); // S/N
	kbb = gpMakeTextbox(nrw,"",idesc,f9,"99%");
	kbb.setMultiline(true);
	kbb.setHeight("40px");
	ckb = gpMakeCheckbox(nrw,"","","");
	ckb.setDisabled(true);
	gpMakeTextbox(nrw,"",ilc,f9,"99%");
	/*
	if(!ilc.equals("")) // show only if LC not blank
		gpMakeTextbox(nrw,"",ilc,"font-size:9px","99%"); // 25/06/2014: from-LC box
	*/
}

class transimpclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
	}
}

void showTransientItems_bycustomer()
{
Object[] imtrnhds =
{
	new listboxHeaderWidthObj("LC/ROC",true,""),
	new listboxHeaderWidthObj("Assets",true,""),
	new listboxHeaderWidthObj("frmlc",true,""),
};

	icustn = customername.getValue(); // HARDCODED in main-UI
	if(icustn.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(imptrans_holder, imtrnhds, "transimp_lb", 15);

	sqlstm =
	"select gcnt.lc_id, count(gcnt.asset_tag) as astc from rw_gcn_transient gcnt " +
	"left join rw_lc_records lcr on gcnt.lc_id = lcr.lc_id " +
	"where lcr.customer_name = '" + icustn + "' and gcnt.gcn_id is null " +
	"group by gcnt.lc_id";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setMultiple(true); newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new transimpclk());
	ArrayList kabom = new ArrayList();
	String[] fl = { "lc_id", "astc", "lc_id"};
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}
}

// 02/09/2014: show transient assets saved from CSV
void showTransientItems_byCSV(String ifc6id, Div iwhere)
{
Object[] pimtrnhds =
{
	new listboxHeaderWidthObj("CSV",true,"80px"),
	new listboxHeaderWidthObj("LC",true,"80px"),
	new listboxHeaderWidthObj("AssetTag",true,"80px"),
	new listboxHeaderWidthObj("origid",false,""),
};
	if(ifc6id.equals("")) return;
	Listbox newlb = lbhand.makeVWListbox_Width(iwhere, pimtrnhds, "csvrepitems_lb", 15);

	sqlstm = "select origid,asset_tag,csv_id,lc_id from rw_gcn_transient where " +
	"fc6_custid=" + ifc6id + " and csv_id is not null and gcn_id is null;";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setMultiple(true); newlb.setCheckmark(true); newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new transimpclk());
	ArrayList kabom = new ArrayList();
	String[] fl = { "csv_id", "lc_id", "asset_tag", "origid" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// 02/09/2014: import transient assets for CSV
void impFromCSV_replacements(String igco)
{
	if(csvrepitems_lb.getSelectedCount() == 0) return;
	sqlstm = "";
	HashMap csvada = new HashMap();

	for( k : csvrepitems_lb.getSelectedItems() )
	{
		atg = lbhand.getListcellItemLabel(k,2);
		oi = lbhand.getListcellItemLabel(k,3);
		lc = lbhand.getListcellItemLabel(k,1);
		csv = lbhand.getListcellItemLabel(k,0).trim();

		addRow_Imported_Things( atg, "", "", lc );

		if(!csvada.containsKey(csv)) csvada.put(csv,1);

		sqlstm += "update rw_gcn_transient set gcn_id=" + igco + " where origid=" + oi + ";";
		sqlstm += "update rw_lc_replacements set gco_id=" + igco +
		" where lc_id='" + lc + "' and in_assettag='" + atg + "';";
	}

	Set set = csvada.entrySet();
	Iterator i = set.iterator();
	csvlist = "";
	while(i.hasNext())
	{
		Map.Entry me = (Map.Entry)i.next();
		csvlist += me.getKey() + ",";
	}
	try { csvlist = csvlist.substring(0,csvlist.length()-1); } catch (Exception e) {}
	g_sv_no.setValue(csvlist);

	sqlstm += "update rw_goodscollection set sv_no='" + csvlist + "' where origid=" + igco;
	sqlhand.gpSqlExecuter(sqlstm);
}

// 27/12/2013: show transient-items from partner's replacement requests
void showTransientItems_bypartner(String ifc6id, Div iwhere)
{
Object[] pimtrnhds =
{
	new listboxHeaderWidthObj("Parts Replacement",true,""),
	new listboxHeaderWidthObj("GCN",true,"60px"),
};
	if(ifc6id.equals("")) return;
	Listbox newlb = lbhand.makeVWListbox_Width(iwhere, pimtrnhds, "partreqimp_lb", 15);

	sqlstm = "select distinct partner_pr,gcn_id from rw_gcn_transient where fc6_custid=" + ifc6id;
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	//newlb.addEventListener("onSelect", new transimpclk());
	ArrayList kabom = new ArrayList();
	for(d : rcs)
	{
		kabom.add( d.get("partner_pr").toString() );
		kabom.add( (d.get("gcn_id") == null) ? "" : d.get("gcn_id").toString() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// Import things supposed to be at partners' place .. RMA stuff
void impFromPartnersReplacements(String igco)
{
	if(partreqimp_lb.getSelectedIndex() == -1) return;
	isel = partreqimp_lb.getSelectedItem();
	preq = lbhand.getListcellItemLabel(isel,0);
	gci = lbhand.getListcellItemLabel(isel,1);

	//if(!gci.equals("")) { guihand.showMessageBox("Items in partner-request " + preq + " already assigned in " + gci); return; }

	sqlstm = "select asset_tag,item_desc,serial_no from rw_gcn_transient where partner_pr=" + preq;
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;

	for(d : rcs)
	{
		addRow_Imported_Things( d.get("asset_tag"), kiboo.checkNullString(d.get("serial_no")), d.get("item_desc"), "" );
	}

	sqlstm = "update rw_gcn_transient set gcn_id=" + igco + " where partner_pr=" + preq + ";";
	sqlstm += "update rw_partner_partsreq set gcn_id=" + igco + " where origid=" + preq;
	sqlhand.gpSqlExecuter(sqlstm);

	imppartnerreq_pop.close();
}

void impTransientAssets()
{
	if(glob_sel_gco.equals("")) return;
	if(transimp_lb.getSelectedCount() == 0) return;

	if (Messagebox.show("Confirm import asset-tags", "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	si = transimp_lb.getSelectedItems().toArray();
	lcid = "";
	for(i=0;i<si.length;i++)
	{
		lcid += "'" + lbhand.getListcellItemLabel(si[i],0) + "',";
	}
	try { lcid = lcid.substring(0,lcid.length()-1); } catch (Exception e) {}

	sqlstm = "select lc_id, asset_tag, serial_no, item_desc from rw_gcn_transient where (gcn_id is null or gcn_id=0) and lc_id in (" + lcid + ")";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	astgs = usql = "";
	for(d : rcs)
	{
		addRow_Imported_Things( d.get("asset_tag"), d.get("serial_no"), d.get("item_desc"), d.get("lc_id") );

		usql += "update rw_lc_equips set gcn_id=" + glob_sel_gco +
		" where lc_parent=(select origid from rw_lc_records where lc_id='" + d.get("lc_id") + "')"  +
		" and asset_tag='" + d.get("asset_tag") + "';";

	}
	imptransient_pop.close();

	usql += "update rw_gcn_transient set gcn_id=" + glob_sel_gco + " where lc_id in (" + lcid + ");";

/*
	sqlstm2 =
	"update rw_lc_equips set gcn_id=" + glob_sel_gco +
	" where lc_parent=(select origid from rw_lc_records where lc_id='" + lcid + "')" + 
	" and asset_tag in (" + astgs + ");";

	sqlstm2 +=
	"update rw_gcn_transient set gcn_id=" + glob_sel_gco + " where lc_id='" + lcid + "'";
*/
	sqlhand.gpSqlExecuter(usql); // update transient-items gcn_id and rw_lc_equips.gcn_id

	//if(lcid.length() > 15) lcid = "MULTIPLE LCs";
	lcid = lcid.replaceAll("'","");
	lc_id.setValue(lcid); // def in formmaker.12

	saveCollectItems(glob_sel_gco); // just save collection-items after importing
	doFunc(updategco_b); // update meta-data to save lc_id 
}

void impTransientAssets_1by1()
{
	if(glob_sel_gco.equals("")) return;
	if(!lbhand.check_ListboxExist_SelectItem(imptrans_holder,"transimp_lb")) return;

	lcid = transimp_lb.getSelectedItem().getLabel();

	if (Messagebox.show("Confirm import asset-tags from " + lcid, "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	sqlstm = "select asset_tag, serial_no, item_desc from rw_gcn_transient where lc_id='" + lcid + "'";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;

	astgs = "";
	for(d : rcs)
	{
		addRow_Imported_Things( d.get("asset_tag"), d.get("serial_no"), d.get("item_desc"), "" );
	}

	imptransient_pop.close();
	lc_id.setValue(lcid); // def in formmaker.12

	sqlstm2 =
	"update rw_lc_equips set gcn_id=" + glob_sel_gco +
	" where lc_parent=(select origid from rw_lc_records where lc_id='" + lcid + "')" + 
	" and asset_tag in (" + astgs + ");";

	sqlstm2 +=
	"update rw_gcn_transient set gcn_id=" + glob_sel_gco + " where lc_id='" + lcid + "'";

	sqlhand.gpSqlExecuter(sqlstm2); // update transient-items gcn_id and rw_lc_equips.gcn_id

	saveCollectItems(glob_sel_gco); // just save collection-items after importing
	doFunc(updategco_b); // update meta-data to save lc_id 
}

Object[] asslb_hds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("SerialNo",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Remarks",true,""),
	new listboxHeaderWidthObj("origid",false,""),
};

class assClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
	}
}

void showLCMeta(String iwhat)
{
	lcr = getLC_rec(iwhat);
	if(lcr == null) { guihand.showMessageBox("DBERR: cannot access LC/ROC table"); return; }
	tmeta = "Customer: " + kiboo.checkNullString(lcr.get("customer_name")) +
	"\nStart date: " + dtf2.format(lcr.get("lstartdate")) + " End date: " + dtf2.format(lcr.get("lenddate")) +
	"\nPeriod: " + lcr.get("period").toString() + " Status: " + kiboo.checkNullString(lcr.get("lstatus")) +
	"\nRemarks: " + kiboo.checkNullString(lcr.get("remarks"));

	implc_meta.setValue(tmeta);
}

void loadShowLCAssets(Object itxtb)
{
	iwhat = kiboo.replaceSingleQuotes( itxtb.getValue().trim() );
	if(iwhat.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(impassets_holder, asslb_hds, "lcassets_lb", 20);
	sqlstm = "select origid,asset_tag,serial_no,type,brand,model,remarks from rw_leaseequipments " +
	"where lc_parent=" + iwhat;

	asrs = sqlhand.gpSqlGetRows(sqlstm);
	if(asrs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new assClick());

	showLCMeta(iwhat);
	ArrayList kabom = new ArrayList();
	String[] fl = { "asset_tag", "serial_no", "type", "brand", "model" };
	for(dpi : asrs)
	{
		ngfun.popuListitems_Data(kabom,fl,dpi);
		krem = kiboo.checkNullString(dpi.get("remarks"));
		if(krem.length() > 40) krem = krem.substring(0,40) + "..";
		kabom.add(krem);
		kabom.add(dpi.get("origid").toString());
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// Store selected asset-tags/remarks and exec call-back in other mods
void procImpAssetTags()
{
	if(lcassets_lb.getSelectedCount() < 1) return;
	ArrayList sats = new ArrayList();
	ArrayList sdes = new ArrayList();
	ArrayList ssn = new ArrayList();

	sels = lcassets_lb.getSelectedItems().toArray();
	for(i=0;i<sels.length;i++)
	{
		ast = lbhand.getListcellItemLabel(sels[i],0);
		asn = lbhand.getListcellItemLabel(sels[i],1);
		asd = "[ " + lbhand.getListcellItemLabel(sels[i],2) + " ] " + lbhand.getListcellItemLabel(sels[i],4);

		sats.add(ast);
		ssn.add(asn);
		sdes.add(asd);
	}
	//alert(sats + ":: " + ssn + "::" +sdes);

	impasset_pop.close();
	impLCAssets_callback(sats,ssn,sdes);
}

// 08/12/2014: import from FC6-DO .. everything, then user can remove unwanted
void importFromFC6_DO()
{
	if(flexi_impdoass_holder.getFellowIfAny("flximpfc6dolb") == null) return;
	sels = flximpfc6dolb.getItems().toArray();
	don = "DO" + flexfc6do_tb.getValue().trim();
	for(i=0; i<sels.length; i++)
	{
		ast = lbhand.getListcellItemLabel(sels[i],0);
		asn = lbhand.getListcellItemLabel(sels[i],1);
		asd = lbhand.getListcellItemLabel(sels[i],2);
		addRow_Imported_Things(ast,asn,asd,don);
	}

}

/*
Load/Pick assets from LC/ROC funcs - can be used in other mods
remember the needed popup--

<button id="importitems_b" label="Import" style="font-size:9px" onClick="impasset_pop.open(additem_b)" />

<popup id="impasset_pop">
<div style="background:#f57900; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
	box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px" width="600px" >

<div style="background:#2e3436;padding:2px">
<label style="color:#ffffff" value="IMPORT Asset-tags from LC/ROC" />
</div>
<separator height="3px" />
<hbox>
<label value="LC/ROC No." />
<textbox id="implcasset_tb" value="1209" />
<button label="Load" style="font-size:9px" onClick="loadShowLCAssets(implcasset_tb)" />
</hbox>
<separator height="3px" />
<label id="implc_meta" multiline="true" style="font-size:9px;font-weight:bold;color:#000000" />
<separator height="3px" />
<button label="Import" onClick="procImpAssetTags()" />
<separator height="2px" />
<div id="impassets_holder" />

</div>
</popup>

*/
