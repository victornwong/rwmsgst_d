/**
 * Find-load Customer into popup for selection - the popup must be defined in the modu main file
 * Event clicker will execute call-back func specified for each modu using these : 
 * findcustomer_Callback(Object isel, String icid, String iarcode, String icustn)
 *
 <popup id="selcustomer_pop">
	<div sclass="shadowbox" style="background:#F0D126" width="650px" >
		<hbox>
			<label value="Search" sclass="k9" />
			<textbox id="searchcust_tb" sclass="k9" />
			<button label="Find / Load" sclass="k9mo" onClick="findCustomers(searchcust_tb,foundcusts_holder,selectcustid)" />
		</hbox>
		<separator height="3px" />
		<hbox>
			<div id="foundcusts_holder" width="400px" />
			<div>
				<label id="selectcustid" sclass="k9mo" multiline="true" />
			</div>
		</hbox>
	</div>
</popup>
 */

CUSTSEL_ID_POS = 0;
CUSTSEL_ARCODE_POS = 1;
CUSTSEL_CUSTOMER = 2;

findcustomer_showdetails_lbl = null; // customer-details label defined in calling modu

class fndcustcliker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		cid = lbhand.getListcellItemLabel(isel,CUSTSEL_ID_POS);
		arcode = lbhand.getListcellItemLabel(isel,CUSTSEL_ARCODE_POS);
		cname = lbhand.getListcellItemLabel(isel,CUSTSEL_CUSTOMER);
		r = getCustomer_Rec(cid);

		custdets =
		kiboo.checkNullString(r.get("customer_name")) + "\n" +
		kiboo.checkNullString(r.get("address1")) + "\n" +
		kiboo.checkNullString(r.get("address2")) + "\n" +
		kiboo.checkNullString(r.get("address3")) + "\n" +
		kiboo.checkNullString(r.get("Address4")) + "\n" +
		"Tel: " + kiboo.checkNullString(r.get("telephone_no")) + "\n" +
		"Fax: " + kiboo.checkNullString(r.get("fax_no")) + "\n" +
		"Contact: " + kiboo.checkNullString(r.get("contact_person1")) + "\n" +
		"Email: " + kiboo.checkNullString(r.get("E_mail")) + "\n" +
		"SalesRep: " + kiboo.checkNullString(r.get("Salesman_code"));

		findcustomer_showdetails_lbl.setValue(custdets);
	}
}
findcust_cliker = new fndcustcliker();

class fndcustdclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			cid = lbhand.getListcellItemLabel(isel,CUSTSEL_ID_POS);
			arcode = lbhand.getListcellItemLabel(isel,CUSTSEL_ARCODE_POS);
			cname = lbhand.getListcellItemLabel(isel,CUSTSEL_CUSTOMER);
			findcustomer_Callback(isel,cid,arcode,cname);
		} catch (Exception e) {}
	}
}
findcust_dcliker = new fndcustdclicker();

/**
 * Find customer button clicked in selcustomer_pop. Search by itb and populate listbox. Limit to 50 recs
 * @param itb     search text
 * @param iholder listbox DIV holder
 */
void findCustomers(Textbox itb, Div iholder, Label ilbl)
{
	SEARCHCUSTOMER_LIMITER = "limit 50";
	Object[] custlb_headers = {
		new listboxHeaderWidthObj("custid",false,""),
		new listboxHeaderWidthObj("ARCODE",true,"90px"),
		new listboxHeaderWidthObj("Customer",true,""),
	};
	findcustomer_showdetails_lbl = ilbl;
	st = kiboo.replaceSingleQuotes(itb.getValue().trim());
	sqlstm = "select Id,ar_code,customer_name from Customer where ar_code like '%" + st + "%' or customer_name like '%" + st + "%' or " + 
	"address1 like '%" + st + "%' or address2 like '%" + st + "%' or address3 like '%" + st + "%' or contact_person1 like '%" + st + "%' or " +
	"Address4 like '%" + st + "%' " + SEARCHCUSTOMER_LIMITER;

	Listbox newlb = lbhand.makeVWListbox_Width(iholder, custlb_headers, "customers_lb", 15);
	newlb.addEventListener("onSelect", findcust_cliker);
	r = vsql_GetRows(sqlstm);
	ArrayList kabom = new ArrayList();
	String[] fl = { "Id","ar_code","customer_name" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, findcust_dcliker);
}
