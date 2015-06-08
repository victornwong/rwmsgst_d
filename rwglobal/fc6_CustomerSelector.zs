
//--- Customer picker - uses Focus6 database (focus1012 10/07/2013)
// def these globals global_selected_customerid, global_selected_customername, customername(Label)
class fcustomerslbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		icustid = lbhand.getListcellItemLabel(isel,0);
		custr = getFocus_CustomerRec(icustid);

		selectcustid.setValue(icustid);
		fcustomername.setValue( kiboo.checkNullString(custr.get("name")) );
		custds =  kiboo.checkNullString(custr.get("address1yh")) + "\n" +
		kiboo.checkNullString(custr.get("address2yh")) + "\n" +
		kiboo.checkNullString(custr.get("address3yh")) + "\n" +
		kiboo.checkNullString(custr.get("address4yh")) + "\n\n" +
		"Tel: " + kiboo.checkNullString(custr.get("telyh")) + "\nFax: " + kiboo.checkNullString(custr.get("faxyh")) + "\n" +
		"Contact: " + kiboo.checkNullString(custr.get("contactyh")) + "\nDeliverTo: " + kiboo.checkNullString(custr.get("deliverytoyh")) + "\n" +
		"Customer Email: " + kiboo.checkNullString(custr.get("emailyh")) + "\nSalesRep: " + kiboo.checkNullString(custr.get("salesrepyh"));

		fcustomerdetails.setValue(custds);
		custfound_wa.setVisible(true);
	}
}
fcustclicker = new fcustomerslbClick();

void findCustomers()
{
Object[] custlb_headers = 
{
	new listboxHeaderWidthObj("mstid",true,""),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Code",true,"60px"),
};
	scht = kiboo.replaceSingleQuotes(searchcust_tb.getValue());
// (cust.type=195 or cust.type=179)
	sqlstm = "select cust.masterid,cust.name,cust.code2 from mr000 cust " +
	"left join u0000 custd on custd.extraid = cust.masterid where " +
	"(cust.name like '%" + scht + "%' or custd.address1yh like '%" + scht + "%' " + 
	"or custd.address2yh like '%" + scht + "%' " +
	"or custd.address3yh like '%" + scht + "%' or custd.address4yh like '%" + scht + "%' " +
	"or custd.contactyh like '%" + scht + "%' or custd.deliverytoyh like '%" + scht + "%' " + 
	"or custd.emailyh like '%" + scht + "%') " +
	"order by cust.name";

	focsql = sqlhand.rws_Sql();
	if(focsql == null) return;
	cures = focsql.rows(sqlstm);
	focsql.close();
	if(cures.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(foundcusts_holder, custlb_headers, "customers_lb", 20);
	newlb.addEventListener("onSelect", fcustclicker);
	newlb.setMold("paging");
	ArrayList kabom = new ArrayList();
	String[] fl = { "masterid", "name", "code2" };
	for(d : cures)
	{
		popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void assignCustomer()
{
	global_selected_customerid = selectcustid.getValue();
	global_selected_customername = fcustomername.getValue();
	global_selected_customer = fcustomername.getValue();
	customername.setValue(global_selected_customer);
	pickcustomer_popup.close();
	pickcustomer_Callback();
}

//--- ENDOF Customer picker - uses Focus6 database (focus1012)

