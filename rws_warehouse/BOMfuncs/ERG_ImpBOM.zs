// Import ERG items to BOM - used in rentalsBOM.zul

Object[] eqihds = 
{
	new listboxHeaderWidthObj("No.",true,"30px"),
	new listboxHeaderWidthObj("Item descrption",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
	new listboxHeaderWidthObj("Type",true,"40px"),
	new listboxHeaderWidthObj("salesid",false,""),
};

g_vouchertype = "7946"; // FC6 ERG vtype
g_extratbl = "u0140";
p_vtype = "ERG";
EQI_QTY_IDX = 2;
EQI_TYPE_IDX = 3;

// knockoff from equipRequest_tracker.zul -- choppedoff some
void showReqItems(String iwhat, Div idiv)
{
	kk = kiboo.replaceSingleQuotes(iwhat);
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, eqihds, "eqreqitems_lb", 21);
	sqlstm = "select iy.salesid, ro.name, iy.qty2," +
	"(SELECT top 1 u.ItemTypeYH AS Item FROM dbo.mr001 AS m INNER JOIN dbo.u0001 AS u ON m.Eoff = u.ExtraId INNER JOIN " + 
	"dbo.mr008 AS p ON u.ProductNameYH = p.MasterId where p.name=ro.name) as itemtype " +
	"from data d " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"where d.vouchertype=" + g_vouchertype + " and d.voucherno='" + kk + "';";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", pricliclker);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	String[] fl = { "name", "qty2", "itemtype", "salesid" };
	for(d : trs)
	{
		kabom.add( lnc.toString() + "." );
		popuListitems_Data(kabom, fl, d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
	ergcustomer_lbl.setValue( getCustomerName_ERG(iwhat) );
}

String getCustomerName_ERG(String iwhat)
{
	sqlstm = "select c.name as customer_name from data d " +
	"left join " + g_extratbl + " ri on ri.extraid = d.extraoff " +
	"left join mr000 c on c.masterid = CAST(ri.customernameyh AS INT) " +
	"left join reqthings_stat st on st.parent_id='" + p_vtype + "'+d.voucherno " +
	"where d.vouchertype=" + g_vouchertype + " and d.voucherno='" + iwhat + "'";

	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null) return "";
	return kiboo.checkNullString( r.get("customer_name") );
}

// inject DT,MT,NB builds for now -- later they'll ask for asset-tags which were picked
void impERG_toBOM()
{
	//if(global_selected_bom.equals("")) return;
	//if(eqreqitems_lb.getItemCount() == 0) return;
	r = eqreqitems_lb.getItems().toArray();
	sqlstm = "";
	for(i=0; i<r.length; i++)
	{
		typ = lbhand.getListcellItemLabel( r[i], EQI_TYPE_IDX);
		qty = 0;
		try
		{
			uu = lbhand.getListcellItemLabel( r[i], EQI_QTY_IDX).replaceAll(".00","");
			qty = Integer.parseInt(uu);
		} catch (Exception e) {}

		// knockoff from doFunc() and chip-chop
		blty = "";
		if(typ.equals("DT")) blty = "DESKTOP";
		if(typ.equals("NB")) blty = "NOTEBOOK";
		if(typ.equals("MT")) blty = "MONITOR";

		for(j=0; j<qty; j++)
		{
			sqlstm += "insert into stockrentalitems_det (parent_id,bomtype) values (" + global_selected_bom + ",'" + blty + "');";
		}
		//alert("typ=" + typ + " :: qty= " + qty.toString() + " :: blty= " + blty);
	}
	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showBuildItems(global_selected_bom);
		impERG_pop.close();
	}
}
