
import org.victor.*;

Object[] pvitemslb_hds =
{
	new listboxHeaderWidthObj("No.",true,"50px"),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("Rate",true,""),
	new listboxHeaderWidthObj("Insurance",true,""),
	new listboxHeaderWidthObj("Freight",true,""),
	new listboxHeaderWidthObj("Rfb Cost",true,""),
	new listboxHeaderWidthObj("Accm Depr",true,""),
	new listboxHeaderWidthObj("Qty",true,""),
	new listboxHeaderWidthObj("salesid",false,""), // 8
	new listboxHeaderWidthObj("bodyid",false,""), // 9
};
PVITMSLB_IDX_RATE = 2;
PVITMSLB_IDX_SALESID = 8;
PVITMSLB_BODYID = 9;
PVITMSLB_IDX_ITEM = 1;
PVITMSLB_IDX_ACCMDEPR = 6;

class pvitmdcliekr implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		glob_sel_pvitem_listitem = event.getTarget();
		if(glob_sel_pvitem_listitem != null)
		{
			glob_sel_pv_item = lbhand.getListcellItemLabel(glob_sel_pvitem_listitem,PVITMSLB_IDX_SALESID);

			for(i=0;i<5;i++) // fill-up textbox from selected listbox item's column
			{
				kk = lbhand.getListcellItemLabel(glob_sel_pvitem_listitem, i+2);
				uptbs[i].setValue(kk);
			}
			upditem_pop.open(glob_sel_pvitem_listitem);
		}
	}
}
pvitmsdblicker = new pvitmdcliekr();

/**
 * [show_PVItems description]
 * @param ipv the selected PV no.
 */
void show_PVItems(String ipv)
{
	edited_pv_values = false; // reset PV-values edited flag every load
	selectedpv_lbl.setValue("PV: " + ipv);
	workarea.setVisible(true);

	Listbox newlb = lbhand.makeVWListbox_Width(pvitems_holder, pvitemslb_hds, "pvitems_lb", 20);

	sqlstm = "select d.bodyid, d.originalamount, y.salesid, s.name, y.rate, y.input0 as insurance, y.input1 as freight, y.input2 as refurbcost, y.input3 as accmdepr, y.quantity " +
	"from data d left join indta y on y.salesid = d.salesoff left join mr001 s on s.masterid = d.productcode " +
	"where d.vouchertype=" + FOCUS_PV_VOUCHERTYPE + " and d.voucherno='" + ipv + "' and y.salesid is not null order by d.bodyid;";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); newlb.setMultiple(true); newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", pvlbonclicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "name", "originalamount", "insurance", "freight", "refurbcost", "accmdepr", "quantity", "salesid","bodyid" };
	lnc = 1;
	for(d : r)
	{
		kabom.add(lnc.toString() + ".");
		ngfun.popuListitems_Data(kabom,fl,d);
		//supdeld = kiboo.checkNullDate(dpi.get("sup_actual_deldate"),"");
		//stt = kiboo.checkNullString(dpi.get("pr_status"));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		lnc++;
	}
	lbhand.setDoubleClick_ListItems(newlb,pvitmsdblicker);
}

Object[] pvlb_hds =
{
	new listboxHeaderWidthObj("PV",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Account",true,""),
	new listboxHeaderWidthObj("T.GRN",true,""),
	new listboxHeaderWidthObj("SuppBill",true,""),
	new listboxHeaderWidthObj("Narration",true,""),
};

class pvlbclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_pv_listitem = isel;
		glob_sel_pv = lbhand.getListcellItemLabel(isel,0);
		show_PVItems(glob_sel_pv);
	}
}
pvlbonclicker = new pvlbclicker();

/**
 * List FOCUS purchase-voucher to play-play
 * @param itype type of listing, 1=by date and search-text, 2=by PV
 */
void listPurchaseVoucher(int itype)
{
	last_list_pv = itype;
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	bpv = kiboo.replaceSingleQuotes(bypv_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(pvs_holder, pvlb_hds, "pvs_lb", 20);

	sqlstm = "select distinct d.voucherno, c.name, di.grnnoyh, di.suppbillnoyh, di.narrationyh," +
	"convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate from data d " +
	"left join mr000 c on c.masterid = d.bookno left join u0013 di on di.extraid = d.extraheaderoff " +
	"where d.vouchertype=" + FOCUS_PV_VOUCHERTYPE;

	switch(itype)
	{
		case 1: // by date and search-text if any
			sqlstm += " and convert(datetime, dbo.ConvertFocusDate(d.date_), 112) between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			if(!st.equals(""))
			{
				sqlstm += " and (c.name like '%" + st + "%' or di.grnnoyh like '%" + st + "%' or di.suppbillnoyh like '%" + st + "%' or " +
					"di.narrationyh like '%" + st + "%') ";
			}
			break;

		case 2: // by PV
			if(bpv.equals("")) return;
			try { kk = Integer.parseInt(bpv); sqlstm += " and d.voucherno='" + bpv + "' "; } catch (Exception e) {}
			break;
	}

	sqlstm += "order by d.voucherno";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); newlb.addEventListener("onSelect", pvlbonclicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "voucherno", "vdate", "name", "grnnoyh", "suppbillnoyh", "narrationyh" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		//supdeld = kiboo.checkNullDate(dpi.get("sup_actual_deldate"),"");
		//stt = kiboo.checkNullString(dpi.get("pr_status"));
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

/**
 * [runMarketPrice_window description]
 */
void runMarketPrice_window()
{
	guihand.globalActivateWindow(mainPlayground,"miscwindows","rws_sales/marketPricebook_v1.zul",kiboo.makeRandomId("vmp"),"",useraccessobj);
}

/**
 * Load,show PO details in a separate window. PO number entered in viewpo_pop.rwmspo_tb
 */
void loadViewPO()
{
	tpo = kiboo.replaceSingleQuotes(rwmspo_tb.getValue().trim());
	if(tpo.equals("")) return;
	try
	{
		kk = Integer.parseInt(tpo);
		mwin = ngfun.vMakeWindow(winsholder,"PO " + tpo,"0","center","680px","");
		pdiv = new Div(); pdiv.setParent(mwin);
		showPOitems(tpo, pdiv); // to show PO details, jobMaker_funcs.zs
	} catch (Exception e) {}
}

/**
 * Calc break-down remainder of an item
 * @param itype 1=normal calc, 2=clear boxes, 3=copy remainder to Cpu-box
 */
void breakdownCalc(int itype)
{
	Object[] ibx = { m_cpubox, m_monitor, m_ram1, m_ram2, m_ram3, m_ram4, m_hdd1, m_hdd2, m_hdd3, m_hdd4, m_battery, m_adaptor, m_graphic };
	switch(itype)
	{
		case 1: // do the calculation
			btotal = uprice = 0.0;
			try { uprice = Float.parseFloat(m_unit_price.getValue().trim()); } catch (Exception e) {}

			if(uprice == 0)
			{
				guihand.showMessageBox("Please enter unit price");
				return;
			}

			for(i=0;i<ibx.length;i++)
			{
				kk = 0;
				try { kk = Float.parseFloat(ibx[i].getValue().trim()); } catch (Exception e) {}
				btotal += kk;
			}

			rmdr = uprice - btotal;
			m_remainder.setValue( kiboo.nf2.format(rmdr) );

			break;

		case 2: // clear boxes
			ngfun.clearUI_Field(ibx);
			break;

		case 3: // copy remainder to cpu-box
			m_cpubox.setValue(m_remainder.getValue());
			break;
	}
}
