
Object[] g_mrnitmhds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Product",true,""),
	new listboxHeaderWidthObj("AssTag",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
	new listboxHeaderWidthObj("MRN",true,"60px"),
};

void gp_viewMRN(String iwhat, Object iwinholder)
{
	if(iwhat.equals("")) return;
	whstr = " d.voucherno='" + iwhat + "' ";
	if(iwhat.indexOf(",") != -1 || iwhat.indexOf("/") != -1 )
	{
		wa = iwhat;
		if(iwhat.indexOf("'") == -1) // no quotes, have to chipchop
		{
			wa = "";
			t = iwhat.split("[, /]");
			
			for(i=0; i<t.length; i++)
			{
				wa += "'" + t[i] + "',";
			}
			try { wa = wa.substring(0,wa.length()-1); } catch (Exception e) {}
		}
		whstr = " d.voucherno in (" + wa + ") ";
	}

	mwin = vMakeWindow(iwinholder,"MRN: " + iwhat,"0","center","500px","");
	kdiv = new Div();
	kdiv.setParent(mwin);
	Listbox newlb = lbhand.makeVWListbox_Width(kdiv, g_mrnitmhds, "gmrnitems_lb", 3);

	sqlstm = "select s.name as item_name, s.code2, iy.qty2, d.voucherno from data d " +
	"left join mr001 s on s.masterid = d.productcode " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"where d.vouchertype=1280 and " + whstr + " order by d.bodyid ";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.setRows(22);
	//newlb.addEventListener("onSelect", grnclikor);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	String[] fl = { "item_name", "code2", "qty2", "voucherno" };
	for(d : r)
	{
		kabom.add(lnc.toString() + "." );
		ngfun.popuListitems_Data(kabom,fl,d);
		/*
		kabom.add( kiboo.checkNullString(d.get("item_name")) );
		kabom.add( kiboo.checkNullString(d.get("code2")) );
		kabom.add( nf0.format(d.get("qty2")) );
		kabom.add( d.get("voucherno") );
		*/
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}

Object[] g_grnihds =
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Product",true,""),
	new listboxHeaderWidthObj("Qty",true,"40px"),
	new listboxHeaderWidthObj("GRN",true,"60px"),
};

void gp_viewGRN(String iwhat, Object iwinholder)
{
	if(iwhat.equals("")) return;
	whstr = " d.voucherno='" + iwhat + "' ";
	if(iwhat.indexOf(",") != -1 || iwhat.indexOf("/") != -1 )
	{
		wa = iwhat;
		if(iwhat.indexOf("'") == -1) // no quotes, have to chipchop
		{
			wa = "";
			t = iwhat.split("[, /]");
			
			for(i=0; i<t.length; i++)
			{
				wa += "'" + t[i] + "',";
			}
			try { wa = wa.substring(0,wa.length()-1); } catch (Exception e) {}
		}
		whstr = " d.voucherno in (" + wa + ") ";
	}

	mwin = vMakeWindow(iwinholder,"GRN: " + iwhat,"0","center","500px","");
	kdiv = new Div();
	kdiv.setParent(mwin);

	Listbox newlb = lbhand.makeVWListbox_Width(kdiv, g_grnihds, "ggrnitems_lb", 3);

	sqlstm = "select i.name as productname, iy.qty2, d.voucherno from data d " +
	"left join mr001 i on i.masterid = d.productcode " +
	"left join indta iy on iy.salesid = d.salesoff " +
	"where d.vouchertype=1281 and d.productcode<>0 " +
	"and " + whstr + " order by d.bodyid";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.setRows(22);
	//newlb.addEventListener("onSelect", grnclikor);
	lnc = 1;
	ArrayList kabom = new ArrayList();
	String[] fl = { "productname", "qty2", "voucherno" };
	for(d : r)
	{
		kabom.add(lnc.toString() + "." );
		ngfun.popuListitems_Data(kabom,fl,d);
		/*
		kabom.add( kiboo.checkNullString(d.get("productname")) ); 
		kabom.add( nf0.format(d.get("qty2")) );
		kabom.add( d.get("voucherno") );
		*/
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lnc++;
		kabom.clear();
	}
}



