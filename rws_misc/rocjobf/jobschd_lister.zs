/**
 * Main lister funcs for rwJobScheduler_v1.zul
 * @author Victor Wong
 * @since  19/06/2014
 */
import org.victor.*;

/**
 * Show ROC/SO meta-data and line items
 * @param iroc the ROC/SO voucher no. selected from the listbox
 */
void rocmetaThing(String iroc)
{
	showROC_meta(iroc, glob_vtype);

	lbid = ((glob_vtype == 2) ? "SOLB" : "ROCLB") + iroc;
	showROC_items(iroc, glob_vtype, rocitems_holder, lbid);
	roccustomer_lbl.setValue(glob_sel_roc + " :: " + glob_sel_customer);

	removeSubDiv(poitems_holder); // remove things from other panels
	removeSubDiv(ergprgs_holder);
	removeSubDiv(boms_holder);
	removeSubDiv(dos_holder);
	workarea.setVisible(true);
}

Object[] rocwinhds =
{
	new listboxHeaderWidthObj("Voucher",true,"70px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Cust.Ref",true,"80px"),
	new listboxHeaderWidthObj("ETD",true,"70px"),
	new listboxHeaderWidthObj("ETA",true,"70px"), // 5
	new listboxHeaderWidthObj("JOB",true,"50px"),
	new listboxHeaderWidthObj("Type",true,"60px"),
	new listboxHeaderWidthObj("Prty",true,"60px"),
	new listboxHeaderWidthObj("PO",true,"50px"),
	new listboxHeaderWidthObj("PO.GRN",true,"50px"), // 10
	new listboxHeaderWidthObj("ERG",true,"60px"),
	new listboxHeaderWidthObj("PRG",true,"60px"), // 12
	new listboxHeaderWidthObj("JPL",true,"60px"),
	new listboxHeaderWidthObj("BOM",true,"60px"),
	new listboxHeaderWidthObj("DO",true,"70px"), // 15
	new listboxHeaderWidthObj("DOS",true,"70px"),
	new listboxHeaderWidthObj("RDO",true,"70px"), // 17
	new listboxHeaderWidthObj("RDOS",true,"70px"),
	new listboxHeaderWidthObj("INV",true,"70px"),
	new listboxHeaderWidthObj("AMT",true,"80px"),
};
CUSTNAME_IDX = 2;
PO_IDX = 9;
ERG_IDX = 11;
PRG_IDX = 12;
DO_IDX = 15;
BOM_IDX = 13;
RDO_IDX = 17;

/**
 * showFCROCs() listbox on-click listener
 */
class roclciker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitm = event.getReference();
		glob_sel_roc = lbhand.getListcellItemLabel(selitm,0);
		glob_sel_customer = lbhand.getListcellItemLabel(selitm,CUSTNAME_IDX);
		glob_sel_ponos = lbhand.getListcellItemLabel(selitm,PO_IDX);
		glob_sel_erg = lbhand.getListcellItemLabel(selitm,ERG_IDX);
		glob_sel_prg = lbhand.getListcellItemLabel(selitm,PRG_IDX);
		glob_sel_do = lbhand.getListcellItemLabel(selitm,DO_IDX);
		glob_sel_bom = lbhand.getListcellItemLabel(selitm,BOM_IDX);
		glob_sel_rdo = lbhand.getListcellItemLabel(selitm,RDO_IDX);
		rocmetaThing(glob_sel_roc);
	}
}
roclbcliekr = new roclciker();

/**
 * List out ROC/SO from FOCUS
 * @param itype 1=by date(default), 2=search-text, 3=by roc
 * @param dtype 1=ROC, 2=SO
 */
void showFCROCs(int itype, int dtype)
{
	lastlisttype = itype;
	totalinvoices_lbl.setValue(""); // clear invoice-total always
	glob_vtype = (vtype_dd.getSelectedItem().getLabel().equals("ROC")) ? 1 : 2;
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	brc = kiboo.replaceSingleQuotes(sbyrocno_tb.getValue().trim());
	unm = useraccessobj.username;
	otherwhere = "and convert(datetime, dbo.ConvertFocusDate(d.date_), 112) between '" + sdate + "' and '" + edate + "' ";

	extratb = "u001b"; // default extra-table = ROC's
	vtype = "5635";
	if(glob_vtype == 2) // if for SO
	{
		extratb = "u0017";
		vtype = "5632";
	}

	switch(itype)
	{
		case 2: // by search-text
			if(st.equals("")) return;
			otherwhere += "and (ac.name like '%" + st + "%' or li.customerrefyh like '%" + st + "%') ";
			break;
		case 3: // by roc-no
			if(brc.equals("")) return;
			if(glob_vtype == 1)
				otherwhere = "and d.voucherno like 'ROC%" + brc + "' "; // NOTE chg ROC0 to ROC
			else
				otherwhere = "and d.voucherno='SO0" + brc + "' ";
			break;
	}

	Listbox newlb = lbhand.makeVWListbox_Width(rocsholder, rocwinhds, "rocs_lb", 5);

	//  hh.login, (select top 1 login from headerdeleted where voucherno = d.voucherno order by headerid desc) as lastrans,
	// convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112)
	// 5635 ROC 5632 SO
	sqlstm = "select distinct d.voucherno, convert(datetime, dbo.ConvertFocusDate(d.date_), 112) as vdate, " +
	"ac.name as customer_name, li.customerrefyh, " +
	"convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112) as etd, convert(datetime, dbo.ConvertFocusDate(li.etayh), 112) as eta " +
	"from data d left join mr000 ac on ac.masterid = d.bookno " +
	"left join u0000 aci on aci.extraid=ac.masterid left join " + extratb + " li on li.extraid = d.extraheaderoff " +
	"left join header hh on hh.headerid = d.headeroff " +
	"where d.vouchertype=" + vtype + " and d.flags<>0 " +
	otherwhere +
	//"and hh.flags=0x0024 order by convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112) ;";
	//" order by convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112) ;";
	" order by convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112), d.voucherno ;";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging"); newlb.addEventListener("onSelect", roclbcliekr);
	ArrayList kabom = new ArrayList();
	invoicetotal = 0.0; showinvoicetotal = false;
	String[] fl = { "voucherno", "vdate", "customer_name", "customerrefyh", "etd", "eta", };
	tody = kiboo.todayISODateString();
	for(d : trs)
	{
		sty = "";

		ngfun.popuListitems_Data(kabom, fl, d); // TODO

		rr = getrwJobRec(d.get("voucherno")); // get rw-Job things
		jid = prit = jtyp = "";
		if(rr != null)
		{
			jid = rr.get("origid").toString();
			prit = kiboo.checkNullString( rr.get("priority") );
			jtyp = kiboo.checkNullString( rr.get("order_type") );
		}
		kabom.add(jid); kabom.add(jtyp); kabom.add(prit);

		rpo = getDOLinkToJob(3, jid); // get PR/PO by jobs. rwsqlfuncs.zs
		kabom.add(rpo);
		kabom.add(getDOLinkToJob(4, rpo)); // PO's GRN (TODO MUST tie to RWMS goods-receival also)

		kabom.add( getERGPRG_by_roc_2(d.get("voucherno"),1,glob_vtype) ); // ERG modif 08/06/2015
		kabom.add( getERGPRG_by_roc_2(d.get("voucherno"),2,glob_vtype) ); // PRG

		kabom.add( (!jid.equals("")) ? getPicklist_ByJob(jid) : ""); // 13/10/2014: RWMS pick-list linked to Job (rwjobfuncs.zs)

		kabom.add( getBOM_byJob(jid) );
		kabom.add( getDO_fromROC_2( d.get("voucherno"), glob_vtype ) ); // 08/06/2015: modif to use new func
		dost = checkDOs_Delivered_byROC_2( d.get("voucherno"), glob_vtype ); // 08/06/2015: modif to use new func
		kabom.add(dost);

		rdo = (!jid.equals("")) ? getDOLinkToJob(6,jid) : "";
		kabom.add(rdo); // 13/10/2014: RDO things

		rdostat = (!jid.equals("")) ? getRDO_DeliveryStatus(jid) : ""; // rwjobfuncs.zs
		kabom.add(rdostat);

		dinv = getInv_fromROC(d.get("voucherno"), glob_vtype);
		kabom.add( dinv );

		kk = "";
		if(unm.equals("leanne") || unm.equals("padmin") || unm.equals("mandy") || unm.equals("carmen"))
		{
			showinvoicetotal = true;
			ivr = getTotal_fromRWISI(dinv, glob_vtype);
			try
			{
				if(ivr != null)
				{
					kk = GlobalDefs.nf2.format(ivr.get("invtotal"));
					invoicetotal += Float.parseFloat( kk );
				}
			} catch (Exception e) {}
		}
		kabom.add( kk ); // RWI/SI amount

		etds = dtf2.format(d.get("etd"));
		if(dost.equals("PENDING") &&  etds.compareTo(tody) < 0 ) sty = "background:#0CDFF7;font-size:9px;font-weight:bold";
		if(dost.equals("DELIVERED") && dinv.equals("")) sty = "background:#F7240C;text-decoration:underline;font-weight:bold";

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
		kabom.clear();
	}

	if(showinvoicetotal) // 09/06/2015: show invoices total
		totalinvoices_lbl.setValue("Invoice total: " + GlobalDefs.nf2.format(invoicetotal));
}


