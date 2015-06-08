// Things lister for rwjobscheduler.zul

Object[] rocitmshds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("Spec1",true,""),
	new listboxHeaderWidthObj("Spec2",true,""),
	new listboxHeaderWidthObj("Qty",true,"60px"),
};

/**
 * Show ROC/SO items from FOCUS. Changes in how quantity is stored in 0J1, see the extra notes
 * @param ivn   voucher no.
 * @param itype 1=ROC, 2=SO
 * @param idiv  DIV to hold the listbox
 * @param ilbid the listbox ID
 */
void showROC_items(String ivn, int itype, Div idiv, String ilbid)
{
	kk = kiboo.replaceSingleQuotes( ivn.trim() );
	if(kk.equals("")) return false;

	vtype = "5635"; // ROC
	qtyfield = "cast((iy.input0) as int) as unitqty,"; // 08/06/2015: 0J1 ROC qty stored in input0

	if(itype == 2)
	{
		vtype = "5632"; // SO
		qtyfield = "cast((iy.quantity*-1) as int) as unitqty,"; // 08/06/2015: 0J1 SO, qty still in quantity
	}

	removeSubDiv(idiv); // remove any prev div
	kd = new Div(); kd.setParent(idiv);
	Listbox newlb = lbhand.makeVWListbox_Width(kd, rocitmshds, ilbid, 5);

	sqlstm = "select ro.name as product_name, u.spec1yh, u.spec2yh, iy.gross,iy.stockvalue," + qtyfield +
	"iy.rate as perunit, " +
	"iy.input1 as rentperiod, iy.output2 as mthtotal from data d " +
	"left join mr008 ro on ro.masterid = d.tags6 left join indta iy on iy.salesid = d.salesoff " +
	"left join u011b u on u.extraid = d.extraoff " +
	"where d.vouchertype=" + vtype + " and d.voucherno='" + kk + "' order by d.bodyid";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	String[] fl = { "product_name", "spec1yh", "spec2yh", "unitqty" };
	ArrayList kabom = new ArrayList();
	lnc = 1;
	for(d : trs)
	{
		kabom.add(lnc.toString() + ".");
		ngfun.popuListitems_Data2(kabom, fl, d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		lnc++;
	}
}

/**
 * Show ROC/SO metadata
 * @param ivn   the voucher number, ROC/SO
 * @param itype 1=ROC, 2=SO
 */
void showROC_meta(String ivn, int itype)
{
	kk = kiboo.replaceSingleQuotes( ivn.trim() );
	if(kk.equals("")) return;

	vtype = "5635";
	extratb = "u001b"; // def extra-table = ROC's
	xflds = ",li.ordertypeyh, li.deliverytoyh ";

	if(itype == 2) // 14/10/2014: put in the missing fields from SO extra-table, ordertypeyh and deliverytoyh as static string
	{
		vtype = "5632";
		extratb = "u0017";
		xflds = ",li.consignmentperiodyh, convert(datetime, dbo.ConvertFocusDate(li.csgnstartdateyh)) as csgnstart, " +
		"convert(datetime, dbo.ConvertFocusDate(li.csgnenddateyh)) as csgnend, li.delivertoyh, 'UNDEF' as ordertypeyh, 'UNDEF' as deliverytoyh ";
	}

	sqlstm = "select distinct d.voucherno, d.bookno, " +
	"ac.name as customer_name, aci.telyh, aci.contactyh, aci.emailyh, li.customerrefyh, li.opsnoteyh as deliverynotes, li.remarksyh, " +
	"convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112) as etd, " +
	"convert(datetime, dbo.ConvertFocusDate(li.etayh), 112) as eta " + xflds +
	"from data d left join mr000 ac on ac.masterid = d.bookno " +
	"left join u0000 aci on aci.extraid=ac.masterid " +
	"left join " + extratb + " li on li.extraid = d.extraheaderoff " +
	"left join header hh on hh.headerid = d.headeroff " +
	"where d.vouchertype=" + vtype + " and d.voucherno='" + kk + "'";

	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null) return;

	Object[] jkl = { roc_contactyh, roc_telyh, roc_emailyh, roc_etd, roc_eta, roc_customerrefyh, roc_ordertypeyh,
		roc_deliverynotes, roc_deliverytoyh, so_consignmentperiodyh, so_csgnstart, so_csgnend };
	String[] fl = { "contactyh", "telyh", "emailyh", "etd", "eta", "customerrefyh", "ordertypeyh",
		"deliverynotes", "deliverytoyh", "consignmentperiodyh", "csgnstart", "csgnend" };

	populateUI_Data(jkl, fl, r);
}

Object[] eqihds = 
{
	new listboxHeaderWidthObj("salesid",false,""),
	new listboxHeaderWidthObj("No.",true,"30px"),
	new listboxHeaderWidthObj("Item descrption",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
};

/**
 * Show ERG/PRG from FOCUS
 * knockoff from equipRequest_tracker - modded so others can use later
 * @param ivn   ERG/PRG voucher no.
 * @param itype 1=erg, 2=prg
 * @param idiv  DIV to hold the listbox
 * @param ilbid the listbox ID
 */
void showReqItems(String ivn, int itype, Div idiv, String ilbid)
{
	g_vouchertype = "7946"; // ERG
	if(itype == 2) g_vouchertype = "7947"; // PRG

	Listbox newlb = lbhand.makeVWListbox_Width(idiv, eqihds, ilbid, 6);

	sqlstm = "select iy.salesid, ro.name, iy.qty2 from data d " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"where d.vouchertype=" + g_vouchertype + " and d.voucherno='" + ivn + "';";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	//newlb.setMold("paging"); newlb.addEventListener("onSelect", pricliclker);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	for(d : trs)
	{
		kabom.add( d.get("salesid").toString() );
		kabom.add( lnc.toString() + "." );
		kabom.add( kiboo.checkNullString(d.get("name")) ); 
		kabom.add( GlobalDefs.nf0.format(d.get("qty2")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}

// itype: 1=ERG, 2=PRG
String getAssetTagsFromERGPRG(String ivn, int itype)
{
	if(ivn.equals("")) return "";
	vpx = "ERG";
	if(itype == 2) vpx = "PRG";
	r = getEqReqStat_rec(vpx+ivn);
	if(r == null) return "";
	return kiboo.checkNullString(r.get("extra1"));
	return "";
}

// Show ERG/PRG and also the saved asset-tags
void showERGPRG_things(String iprg, String ierg, Div idivholder)
{
	removeSubDiv(idivholder);
	pons = iprg.split(","); // PRGs first
	for(i=0; i<pons.length; i++)
	{
		kk = pons[i].trim();
		if(!kk.equals(""))
		{
			khb = new Hbox(); khb.setParent(idivholder);
			kd = new Div(); kd.setWidth("500px"); kd.setParent(khb);
			kl = new Label(); kl.setValue("PRG: " + kk); kl.setStyle("color:#ffffff;font-weight:bold"); kl.setParent(kd);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd);
			lbid = "PRGLB" + i;
			showReqItems(kk,2,kd,lbid);

			kd2 = new Div(); kd2.setSclass("shadowbox"); kd2.setStyle("background:#F5D922"); kd2.setWidth("400px"); kd2.setParent(khb);
			kl = new Label(); kl.setValue("Captured Asset-tags"); kl.setStyle("font-weight:bold"); kl.setParent(kd2);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd2);
			kl = new Label(); kl.setMultiline(true); kl.setParent(kd2);
			kl.setValue(getAssetTagsFromERGPRG(kk,2));
		}
	}

	pons = ierg.split(","); // ERGs
	for(i=0; i<pons.length; i++)
	{
		kk = pons[i].trim();
		if(!kk.equals(""))
		{
			khb = new Hbox(); khb.setParent(idivholder);
			kd = new Div(); kd.setWidth("500px"); kd.setParent(khb);
			kl = new Label(); kl.setValue("ERG: " + kk); kl.setStyle("color:#ffffff;font-weight:bold"); kl.setParent(kd);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd);
			lbid = "ERGLB" + i;
			showReqItems(kk,1,kd,lbid);

			kd2 = new Div(); kd2.setSclass("shadowbox"); kd2.setStyle("background:#F5D922"); kd2.setWidth("400px"); kd2.setParent(khb);
			kl = new Label(); kl.setValue("Captured Asset-tags"); kl.setStyle("font-weight:bold"); kl.setParent(kd2);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd2);
			kl = new Label(); kl.setMultiline(true); kl.setParent(kd2);
			kl.setValue(getAssetTagsFromERGPRG(kk,1));

		}
	}
}

Object[] doitmhds = 
{
	new listboxHeaderWidthObj("No.",true,"30px"),
	new listboxHeaderWidthObj("Item description",true,""),
	new listboxHeaderWidthObj("Asset.Tag",true,"100px"),
	new listboxHeaderWidthObj("Qty",true,"70px"),
};

/**
 * Show DO items from FOCUS
 * knockoff from FCDO_tracker.zul
 * @param ivn   DO voucher no.
 * @param idiv  DIV to hold the listbox
 * @param ilbid the listbox ID
 */
void showDO_items(String ivn, Div idiv, String ilbid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, doitmhds, ilbid, 21);

	sqlstm = "select s.name as product_name, s.code2, iy.qty2 from data d " +
	"left join mr000 c on c.masterid = d.bookno " +
	"left join mr001 s on s.masterid = d.productcode " +
	"left join u001c di on di.extraid = d.extraheaderoff " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"where d.vouchertype=6144 and d.productcode<>0 and d.voucherno='" + ivn + "'";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", doclikor);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	for(d : trs)
	{
		kabom.add( lnc.toString() + "." );
		kabom.add( kiboo.checkNullString(d.get("product_name")) );
		kabom.add( kiboo.checkNullString(d.get("code2")) );
		qty = nf0.format(d.get("qty2")).replaceAll("-","");
		kabom.add(qty);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}

void showDO_details(String ido, Div idivholder)
{
	removeSubDiv(idivholder);

	pons = ido.split(","); // ERGs
	for(i=0; i<pons.length; i++)
	{
		kk = pons[i].trim();
		if(!kk.equals(""))
		{
			khb = new Hbox(); khb.setParent(idivholder);
			kd = new Div(); kd.setWidth("500px"); kd.setParent(khb);
			kl = new Label(); kl.setValue("DO: " + kk); kl.setStyle("color:#ffffff;font-weight:bold"); kl.setParent(kd);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd);
			showDO_items(kk,kd,"DOLB"+kk);

			dr = getFC6DO_rec(kk);
			if(dr != null)
			{
				kd2 = new Div(); kd2.setSclass("shadowbox"); kd2.setStyle("background:#F5D922"); kd2.setWidth("400px"); kd2.setParent(khb);
				kl = new Label(); kl.setValue("DO Stats"); kl.setStyle("font-weight:bold"); kl.setParent(kd2);
				ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd2);
				kl = new Label(); kl.setMultiline(true); kl.setParent(kd2);

				dstr = "Reference: " + dr.get("referenceyh") + "\n" +
				"Narration: " + dr.get("narrationyh") + "\n" +
				"Transporter: " + dr.get("transporteryh") + "\n" +
				"DeliveryRef: " + dr.get("deliveryrefyh") + "\n" +
				"Del.Status: " + dr.get("deliverystatusyh") + "\n" +
				"Del.Date: " +  dr.get("deliverydateyh") + "\n" +
				"Del.Addr: " + dr.get("deliveryaddressyh");

				kl.setValue(dstr);
			}
		}
	}
}

Object[] bldsdehds = 
{
	new listboxHeaderWidthObj("bomtype",true,""),	new listboxHeaderWidthObj("asset_tag",true,""),
	new listboxHeaderWidthObj("f_ename",true,""),	new listboxHeaderWidthObj("f_grade",true,""),
	new listboxHeaderWidthObj("ram1",true,""), new listboxHeaderWidthObj("f_ram1",true,""),
	new listboxHeaderWidthObj("ram2",true,""), new listboxHeaderWidthObj("f_ram2",true,""),
	new listboxHeaderWidthObj("ram3",true,""), new listboxHeaderWidthObj("f_ram3",true,""),
	new listboxHeaderWidthObj("ram4",true,""), new listboxHeaderWidthObj("f_ram4",true,""),
	new listboxHeaderWidthObj("hdd1",true,""), new listboxHeaderWidthObj("f_hdd1",true,""),
	new listboxHeaderWidthObj("hdd2",true,""), new listboxHeaderWidthObj("f_hdd2",true,""),
	new listboxHeaderWidthObj("hdd3",true,""), new listboxHeaderWidthObj("f_hdd3",true,""),
	new listboxHeaderWidthObj("hdd4",true,""), new listboxHeaderWidthObj("f_hdd4",true,""),
	new listboxHeaderWidthObj("battery",true,""), new listboxHeaderWidthObj("f_battery",true,""),
	new listboxHeaderWidthObj("poweradaptor",true,""), new listboxHeaderWidthObj("f_power",true,""),
	new listboxHeaderWidthObj("gfxcard",true,""), new listboxHeaderWidthObj("f_gfxcard",true,""),
	new listboxHeaderWidthObj("osversion",true,""), new listboxHeaderWidthObj("coa1",true,""),
	new listboxHeaderWidthObj("offapps",true,""), new listboxHeaderWidthObj("coa2",true,""),
	new listboxHeaderWidthObj("coa3",true,""), new listboxHeaderWidthObj("coa4",true,""),
	new listboxHeaderWidthObj("misc",true,""), new listboxHeaderWidthObj("description",true,""),
};

void showBuildsLikeExcel(String ibom, Div idiv, String ilbid) // knockoff from rentalsBOM_funcs.zs - modded for others
{
	sqlstm = "select srd.bomtype, srd.asset_tag, " +
	"(select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.asset_tag) as f_ename, " +
	"(select top 1 grade from Focus5012.dbo.partsall_0 where assettag=srd.asset_tag) as f_grade, " +
	"srd.ram, (select top 1  name from Focus5012.dbo.partsall_0 where assettag=srd.ram) as f_ram1, " +
	"srd.ram2, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram2) as f_ram2, " +
	"srd.ram3, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram3) as f_ram3, " +
	"srd.ram4, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.ram4) as f_ram4, " +
	"srd.hdd, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd) as f_hdd1, " +
	"srd.hdd2, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd2) as f_hdd2, " +
	"srd.hdd3, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd3) as f_hdd3, " +
	"srd.hdd4, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.hdd4) as f_hdd4, " +
	"srd.battery, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.battery) as f_battery, " +
	"srd.poweradaptor, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.poweradaptor) as f_power, " +
	"srd.gfxcard, (select top 1 name from Focus5012.dbo.partsall_0 where assettag=srd.gfxcard) as f_gfxcard, " +
	"srd.misc, srd.description, srd.osversion, srd.coa1, srd.offapps, srd.coa2, srd.coa3, srd.coa4 " +
	"from stockrentalitems_det srd where parent_id=" + ibom;

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, bldsdehds, ilbid, 21);
	ArrayList kabom = new ArrayList();
	String[] fl = { "bomtype", "asset_tag", "f_ename", "f_grade", "ram", "f_ram1", "ram2", "f_ram2", "ram3", "f_ram3", "ram4", "f_ram4",
	"hdd", "f_hdd1", "hdd2", "f_hdd2", "hdd3", "f_hdd3", "hdd4", "f_hdd4", "battery", "f_battery", "poweradaptor", "f_power",
	"gfxcard", "f_gfxcard", "osversion", "coa1", "offapps", "coa2", "coa3", "coa4", "misc", "description" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);

		for(i=0;i<kabom.size();i++)
		{
			kk = kabom.get(i);
			if(kk.equals("COMBO")) kabom.set(i,"");
		}
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-size:6px");
		kabom.clear();
	}
	//buildsnombor_lbl.setValue(global_selected_bom);
}

void showEmBOMS(String ibom)
{
	removeSubDiv(boms_holder);
	pons = ibom.split(",");
	for(i=0; i<pons.length; i++)
	{
		kk = pons[i].trim();
		if(!kk.equals(""))
		{
			kd = new Div(); kd.setParent(boms_holder);
			kl = new Label(); kl.setValue("BOM: " + kk); kl.setStyle("color:#ffffff;font-weight:bold"); kl.setParent(kd);
			ks = new Separator(); ks.setHeight("2px"); ks.setParent(kd);
			showBuildsLikeExcel(kk,kd,"BOM"+kk);
		}
	}
	
}

