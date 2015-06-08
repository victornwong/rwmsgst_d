// grnPO_tracker sub-funcs

void showGRNmeta(String iwhat)
{
	fillDocumentsList(documents_holder,GRN_PREFIX,iwhat);
	showGRNitems(iwhat);
	grnitms_lbl.setValue("GRN: " + iwhat);
	poitems_div.setVisible(false);
	workarea.setVisible(true);
}

Object[] grndhds = 
{
	new listboxHeaderWidthObj("GRN",true,"70px"),
	new listboxHeaderWidthObj("Stat",true,"70px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Vendor/Customer",true,""),
	new listboxHeaderWidthObj("Reference",true,""),
	new listboxHeaderWidthObj("RecvBy",true,""),
	new listboxHeaderWidthObj("Our.PO",true,""),
	new listboxHeaderWidthObj("MRN",true,""),
	new listboxHeaderWidthObj("Qty",true,""),
	new listboxHeaderWidthObj("Ship.Code",true,""),
	new listboxHeaderWidthObj("Remarks",true,""),
};
i_opo = 6;
i_mrn = 7;

class grnclike implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		grn_seli = event.getReference();
		glob_sel_grn = lbhand.getListcellItemLabel(grn_seli,0);
		glob_sel_pono = lbhand.getListcellItemLabel(grn_seli,i_opo);
		glob_sel_mrn = lbhand.getListcellItemLabel(grn_seli,i_mrn);
		showGRNmeta(glob_sel_grn);
	}
}
grnclikor = new grnclike();

// itype: 1=all by date, 2=by date got 'PO'
void listGRN(int itype)
{
	lastlisttype = itype;
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
    st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	Listbox newlb = lbhand.makeVWListbox_Width(grn_holder, grndhds, "grns_lb", 22);

	whstr = "";
	switch(itype)
	{
		case 2:
			whstr = " and tg.ponoyh like 'PO%' ";
			break;
		case 3:
			whstr = " and (d.voucherno like '%" + st + "%' or ac.name like '%" + st + "%' or tg.vendorrefyh like '%" + st + "%' " +
			"or tg.receivedbyyh like '%" + st + "%' or tg.ponoyh like '%" + st + "%' or tg.shipmentcodeyh like '%" + st + "%' " +
			"or tg.grnremarksyh like '%" + st + "%') ";
			break;
		case 4:
			whstr = " and (tg.vendorrefyh like '%RMA%' or tg.ponoyh like '%RMA%' or tg.shipmentcodeyh like '%RMA%' or " +
			"tg.grnremarksyh like '%RMA%') ";
			break;
		case 5:
			whstr = " and (tg.vendorrefyh like '%EOL%' or tg.ponoyh like '%EOL%' or tg.shipmentcodeyh like '%EOL%' or " +
			"tg.grnremarksyh like '%EOL%') ";
			break;
		case 6:
			whstr = " and (tg.vendorrefyh like '%GC%' or tg.ponoyh like '%GC%' or " +
			"tg.shipmentcodeyh like '%GC%' or tg.grnremarksyh like '%GC%') ";
			break;
	}

	sqlstm = "select convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, " +
	"case cast(h.flags as int) & 0x0004 when 0x0004 then 'APPROVED' else 'SUSPENDED' end as tgrnstat, " +
	"d.voucherno, ac.name as vendor, tg.vendorrefyh, tg.receivedbyyh, tg.ponoyh, tg.shipmentcodeyh, tg.grnremarksyh, " +
	"sum(iy.qty2) as unitc " +
	//"(select voucherno from v_link4 where vouchertype=1280 and sortlinkid = d.links1) as mrn_no, " +
	//"vl.voucherno as mrn_no " +
	"from data d " +
	"left join u002c tg on tg.extraid = d.extraheaderoff " +
	"left join mr000 ac on ac.masterid = d.bookno " +
	"left join mr001 i on i.masterid = d.productcode " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"left join header h on h.headerid=d.headeroff " +
	"left join indta iy on iy.salesid = d.salesoff " +
	//"left join v_link4 vl on d.links1 = vl.sortlinkid " +
	"where d.vouchertype=1281 " +
	//"and cast(h.flags as int) & 0x0004 = 0x0004 " +
	"and convert(datetime, dbo.ConvertFocusDate(d.date_), 112) between '" + sdate + "' and '" + edate + "' " +
	whstr +
	//" and vl.vouchertype=1280 " +
	"group by d.voucherno, h.flags, d.date_, d.bookno, ac.name, " +
	"tg.vendorrefyh, tg.receivedbyyh, tg.ponoyh, tg.shipmentcodeyh, tg.grnremarksyh " +
	"order by d.voucherno ";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", grnclikor);
	ArrayList kabom = new ArrayList();

	String[] fl = { "voucherno", "tgrnstat", "vdate", "vendor", "vendorrefyh", "receivedbyyh", "ponoyh", "unitc", "unitc", "shipmentcodeyh",
	"grnremarksyh" };

/*
	vnums = "";
	for(d : r)
	{
		vnums += "'" + d.get("voucherno") + "',";
	}
	try { vnums = vnums.substring(0,vnums.length()-1); } catch (Exception e) {}
	kkk = grnGetMRN(vnums);
	alert(kkk); return;
*/

	focsql = sqlhand.rws_Sql();

	for(d : r)
	{
		popuListitems_Data(kabom,fl,d);
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		
		slq = "select voucherno from v_link4 where vouchertype=1280 and sortlinkid=" + 
		"(select top 1 links1 from data where vouchertype=1281 and voucherno='" + d.get("voucherno") + "')";

		mrc = focsql.firstRow(slq);
		kx = (mrc == null) ? "" : mrc.get("voucherno");
		if(kx.equals("")) ki.setStyle("background:#FAA80F");
		lbhand.setListcellItemLabel(ki, i_mrn, kx); // inject MRN-no if any

		if( !d.get("tgrnstat").equals("APPROVED") ) ki.setStyle("background:#FA0905");
		kabom.clear();
	}
	focsql.close();

	poitems_div.setVisible(false);
	tgrn_div.setVisible(true);
}

Object[] grnihds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Product",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
};

void showGRNitems(String iwhat)
{
	Listbox newlb = lbhand.makeVWListbox_Width(grnitems_holder, grnihds, "grnitems_lb", 3);
	sqlstm = "select i.name as productname, iy.qty2 from data d " +
	"left join mr001 i on i.masterid = d.productcode " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"where d.vouchertype=1281 and d.productcode<>0 " +
	"and d.voucherno='" + iwhat + "'";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.setRows(22);
	//newlb.addEventListener("onSelect", grnclikor);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add(lnc.toString() + "." );
		kabom.add( kiboo.checkNullString(d.get("productname")) ); 
		kabom.add( nf0.format(d.get("qty2")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}

