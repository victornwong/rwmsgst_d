import org.victor.*;

// Office-items request/management supporting funcs

String[] getDistinctItemCats()
{
	//sqlstm = "select distinct category from rw_partner_stockitems order by category";
	sqlstm = "select distinct category from rw_officeitems order by category";
	crs = sqlhand.gpSqlGetRows(sqlstm);
	if(crs.size() == 0) return;
	ArrayList kct = new ArrayList();
	for(d : crs)
	{
		kct.add(d.get("category"));
	}
	lmk = kiboo.convertArrayListToStringArray(kct);
	return lmk;
}

void showItemQtyLowLevel(Object iwhat)
{
	if(glob_sel_item.equals("")) return;
	ire = getOfficeItem_rec(glob_sel_item);
	if(ire == null) return;

	uqty_itm_lbl.setValue( ire.get("item_name") );
	uqty_qty_tb.setValue( ire.get("qty").toString() );
	uqty_lowlevel_tb.setValue( ire.get("low_level").toString() );
	itemupqty_pop.open(iwhat);
}

// make Combobox and attach categories from rw_officeitems. Can select or type new
void showItemCat()
{
	if(ccat_holder.getFellowIfAny("cnewcat_cb") != null) cnewcat_cb.setParent(null);

	cboj = new Combobox();
	cboj.setId("cnewcat_cb");
	cboj.setWidth("93%");
	cboj.setParent(ccat_holder);
	kkl = getDistinctItemCats();
	gridhand.makeComboitem(cboj,kkl);
}

void minusItemsStock(String irid)
{
	if(requestitems_holder.getFellowIfAny("reqitems_grid") == null) return;
	krws = reqitems_rows.getChildren().toArray();
	if(krws.length < 2) return;
	sqlstm = "";
	for(i=1;i<krws.length;i++)
	{
		rwi = krws[i].getChildren().toArray();
		itm = rwi[0].getLabel();
		qty = rwi[1].getValue();

		try {
		cty = Integer.parseInt(qty);
		} catch (Exception e) { qty = "0"; }

		sqlstm += "update rw_officeitems set qty=qty-" + qty + " where item_name='" + itm + "';";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		if(!glob_sel_cat.equals("")) showItemsByCategory(glob_sel_cat); // just refresh
	}
}

void removeRequestItems(String irid)
{
	krws = reqitems_rows.getChildren().toArray();
	if(krws.length < 2) return;
	for(i=1;i<krws.length;i++)
	{
		rwi = krws[i].getChildren().toArray();
		if(rwi[0].isChecked()) krws[i].setParent(null);
	}
}

void saveRequestItems(String irid)
{
	krws = reqitems_rows.getChildren().toArray();
	if(krws.length < 2)
	{
		sqlstm = "update rw_officerequests set req_items=null,req_qty=null where origid=" + irid;
		sqlhand.gpSqlExecuter(sqlstm);
		reqitems_grid.setParent(null);
		return;
	}

	itms = "";
	qtys = "";

	for(i=1;i<krws.length;i++)
	{
		rwi = krws[i].getChildren().toArray();
		itms += rwi[0].getLabel() + "::";
		qtys += rwi[1].getValue() + "::";
	}

	try { itms = itms.substring(0,itms.length()-2); } catch (Exception e) {}
	try { qtys = qtys.substring(0,qtys.length()-2); } catch (Exception e) {}

	sqlstm = "update rw_officerequests set req_items='" + itms + "',req_qty='" + qtys + "' where origid=" + irid;
	sqlhand.gpSqlExecuter(sqlstm);

	//alert("itms: " + itms + " qtys: " + qtys );
}

Rows makeReqItemsGrid()
{
	kgrd = new Grid();
	kgrd.setId("reqitems_grid");
	kgrd.setParent(requestitems_holder);
	rws = new Rows();
	rws.setId("reqitems_rows");
	rws.setParent(kgrd);

	rw = new Row();
	rw.setParent(rws);
	gpMakeLabel(rw, "", "Description","font-weight:bold");
	gpMakeLabel(rw, "", "Qty","font-weight:bold");

	return rws;
}

void addItemsToRequest(Object isels)
{
	rws = null;

	if(requestitems_holder.getFellowIfAny("reqitems_grid") == null) // no request-items grid, create
		rws = makeReqItemsGrid();
	else
		rws = reqitems_grid.getFellowIfAny("reqitems_rows");

	if(rws == null) return;

	kis = isels.toArray();
	for(i=0;i<kis.length;i++)
	{
		try {
		rw = new Row();
		rw.setParent(rws);
		itn = lbhand.getListcellItemLabel(kis[i],0);
		iot = lbhand.getListcellItemLabel(kis[i],2);
		gpMakeCheckbox(rw,"RI" + iot, itn, "");
		gpMakeTextbox(rw,"","","","20%");
		} catch (Exception e) { rw.setParent(null); }
	}
}

void showOfficeRequestThings(String iwhat)
{
	sqlstm = "select * from rw_officerequests where origid=" + iwhat;
	rdt = sqlhand.gpSqlFirstRow(sqlstm);
	if(rdt == null) return;

	rq_origid.setValue( rdt.get("origid").toString() );
	rq_datecreated.setValue( dtf2.format(rdt.get("datecreated")) );
	rq_somenotes.setValue( rdt.get("somenotes") );
	reqworkarea.setVisible(true);

	if(requestitems_holder.getFellowIfAny("reqitems_grid") != null) reqitems_grid.setParent(null);

	ll = kiboo.checkNullString( rdt.get("req_items") );
	if(ll.equals("")) return;

	rws = makeReqItemsGrid();
	itms = rdt.get("req_items").split("::");
	qtys = rdt.get("req_qty").split("::");

	for(i=0; i<itms.length; i++)
	{
		try {
		rw = new Row();
		rw.setParent(rws);
		gpMakeCheckbox(rw,"", itms[i], "");
		gpMakeTextbox(rw,"", qtys[i], "","20%");
		} catch (Exception e) { rw.setParent(null); }
	}
}

class offrqclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_request = lbhand.getListcellItemLabel(isel,0);
		glob_sel_request_stat = lbhand.getListcellItemLabel(isel,3);
		showOfficeRequestThings(glob_sel_request);
	}
}
offldlclick = new offrqclk();

void showOfficeRequests()
{
Object[] offrq_hds = 
{
	new listboxHeaderWidthObj("REQ#",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Username",true,""),
	new listboxHeaderWidthObj("Status",true,"80px"),
	new listboxHeaderWidthObj("Give",true,"60px"),
};
	Listbox newlb = lbhand.makeVWListbox_Width(itemsreq_holder, offrq_hds, "officereqs_lb", 20);
	sqlstm = "select origid,datecreated,username,status,give_date from rw_officerequests order by datecreated desc";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", offldlclick);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "username", "status", "give_date" };
	for(d : rcs)
	{
		popuListitems_Data(kabom, fl, d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

class itmcatclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_cat = lbhand.getListcellItemLabel(isel,0);
		showItemsByCategory(glob_sel_cat);
		additemtoreq_b.setVisible(true);
	}
}
itmcatclierk = new itmcatclk();

void showItemsCategory()
{
Object[] itmcat_hds = 
{
	new listboxHeaderWidthObj("Categories",true,""),
};

	Listbox newlb = lbhand.makeVWListbox_Width(itemcats_holder, itmcat_hds, "itemcats_lb", 15);
	kkl = getDistinctItemCats();
	lbhand.populateDropdownListbox(itemcats_lb, kkl);
	newlb.addEventListener("onSelect", itmcatclierk);
}

class itemclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		isel = event.getReference();
		glob_sel_item = lbhand.getListcellItemLabel(isel,2);
		glob_sel_itemname = lbhand.getListcellItemLabel(isel,0);
		} catch (Exception e) {}
	}
}
itmcliker = new itemclk();

void showItemsByCategory(String icat)
{
Object[] itms_hds = 
{
	new listboxHeaderWidthObj("Items",true,""),
	new listboxHeaderWidthObj("Qty",true,"60px"),
	new listboxHeaderWidthObj("origid",false,""),
};
	Listbox newlb = lbhand.makeVWListbox_Width(items_holder, itms_hds, "items_lb", 15);
	sqlstm = "select origid,item_name,qty from rw_officeitems where category='" + icat + "' order by item_name";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", itmcliker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "item_name", "qty", "origid" };
	for(d : rcs)
	{
		popuListitems_Data(kabom, fl, d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}


