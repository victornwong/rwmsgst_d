import org.victor.*;

Object[] dnsi_hds =
{
	new listboxHeaderWidthObj("Dated",true,"35px"),
	new listboxHeaderWidthObj("Voucher",true,""),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Amt",true,""),
	new listboxHeaderWidthObj("RefNo",true,""),
	new listboxHeaderWidthObj("Remarks",true,""),
	new listboxHeaderWidthObj("Spec1&2",true,""),
};
vc_pos = 1;

void digCN(Object iwhat, Object iwhere, Object stdt, Object eddt)
{
	sdate = kiboo.getDateFromDatebox(stdt);
	edate = kiboo.getDateFromDatebox(eddt);
	st = kiboo.replaceSingleQuotes(searchtext_tb.getValue().trim());
	if(st.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox_Width(iwhere, dnsi_hds, "dnsi_lb", 10);
	newlb.setRows(20); newlb.setMold("paging");

	sqlstm = "select d.voucherno, convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) as vdate, " +
	"a.name as customer_name, d.amount1, cnu.refnoyh, cnu.remarksyh " +
	"from data d left join mr000 a on a.masterid = d.bookno left join u0111 cnu on cnu.extraid = d.extraoff " +
	"where d.vouchertype=4096 " +
	"and convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) between '" + sdate +"' and '" + edate + "' " +
	"and a.name like '%" + st + "%' " +
	"order by d.voucherno desc;";

	recs = sqlhand.rws_gpSqlGetRows(sqlstm);
	ArrayList kabom = new ArrayList();
	String[] fl = { "vdate", "voucherno", "customer_name", "amount1", "refnoyh", "remarksyh" }; 
	for(d : recs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lbhand.setListcellItemLabel(ki, vc_pos, "CN" + d.get("voucherno") );
		kabom.clear();
	}
}

// Dig DN and SI by remarks/narration -- spelling ain't right, no records
// iwhat:button(id is the search txt), iwhere=holder, stdt=start-date, eddt=end-date
void digDNSI(Object iwhat, Object iwhere, Object stdt, Object eddt)
{
	sdate = kiboo.getDateFromDatebox(stdt);
	edate = kiboo.getDateFromDatebox(eddt);
	itype = iwhat.getId();
	st = kiboo.replaceSingleQuotes(searchtext_tb.getValue().trim());
	Listbox newlb = lbhand.makeVWListbox_Width(iwhere, dnsi_hds, "dnsi_lb", 10);
	newlb.setRows(22); newlb.setMold("paging");

	byname = "";
	if(!st.equals(""))
	{
		byname = " and a.name like '%" + st + "%' ";
	}

	// Dig DN
	sqlstm = "select convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) as vdate, " +
	"a.name as customer_name, d.voucherno, d.amount1, dnu.refnoyh, dnu.remarksyh " +
	"from data d " +
	"left join mr000 a on a.masterid = d.bookno left join u0111 dnu on dnu.extraid = d.extraoff " +
	"where d.vouchertype=3840 " +
	"and convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) between '" + sdate + "' and '" + edate + "' " +
	"and dnu.remarksyh like '%" + itype + "%' " + byname;

	//debugbox.setValue(sqlstm);

	recs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(recs.size() > 0)
	{
		ArrayList kabom = new ArrayList();
		String[] fl = { "vdate", "voucherno", "customer_name", "amount1", "refnoyh", "remarksyh" }; 
		for(d : recs)
		{
			ngfun.popuListitems_Data(kabom,fl,d);
			kabom.add("");
			ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
			lbhand.setListcellItemLabel(ki, vc_pos, "DN" + d.get("voucherno") );
			kabom.clear();
		}
	}

	// Dig SI
	sqlstm = "select convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) as vdate, a.name as customer_name, " +
	"d.voucherno, d.amount1, siu.sonoyh, siu.remarksyh, di.spec1yh, di.spec2yh " +
	"from data d left join u0012 siu on siu.extraid=d.extraheaderoff " +
	"left join mr000 a on a.masterid = d.bookno " +
	"left join u0112 di on di.extraid = d.extraoff " +
	"where d.vouchertype=3328 " +
	"and convert(datetime, focus5012.dbo.ConvertFocusDate(d.date_), 112) between '" + sdate + "' and '" + edate + "' " +
	"and (siu.remarksyh like '%" + itype + "%' or siu.narrationyh like '%" + itype + "%' or " +
	"di.spec1yh like '%" + itype + "%' or di.spec2yh like '%" + itype + "%') " + byname;

	//debugbox.setValue(debugbox.getValue() + " \n\n" + sqlstm);

	recs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	ArrayList kabom = new ArrayList();
	String[] fl = { "vdate", "voucherno", "customer_name", "amount1", "sonoyh", "remarksyh" }; 
	for(d : recs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		kabom.add(d.get("spec1yh") + " " + d.get("spec2yh"));
		ki = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		//lbhand.setListcellItemLabel(ki, vc_pos, "SI" + d.get("voucherno") );
		kabom.clear();
	}
}

void exportDNSI_list(Object iwhere)
{
	if(dnsholder.getFellowIfAny("dnsi_lb") == null) return;
	if(dnsi_lb.getItemCount() == 0) return;

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("DNSI_recs");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");
	rowcount = 0;

	for(i=0;i<dnsi_hds.length;i++)
	{
		POI_CellSetAllBorders(wb,excelInsertString(sheet,rowcount,i,dnsi_hds[i].header_str),wfont,true,"");
	}

	rowcount++;
	rx = dnsi_lb.getItems().toArray();

	for(i=0; i<rx.length; i++)
	{
		//cb = rx[i];
		for(j=0; j<dnsi_hds.length; j++)
		{
			kk = lbhand.getListcellItemLabel(rx[i],j);
			try
			{
				ck = Float.parseFloat(kk);
				excelInsertNumber(sheet,rowcount,j,kk);
			}
			catch (Exception e)
			{
				excelInsertString(sheet,rowcount,j,kk);
			}
		}

		rowcount++;
	}
	jjfn = "DNSIrecords_t.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();
	downloadFile(iwhere,jjfn,outfn);
}

