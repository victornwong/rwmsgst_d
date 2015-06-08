import org.victor.*;

kiboo = new Generals();
sqlhand = new SqlFuncs();
lbhand = new ListboxHandler();
guihand = new GuiFuncs();

// ---- Customer search popup stuff ---- can be used in other modules

void showCustomerInfo(String iarcode)
{
	comprec = sqlhand.getCompanyRecord(iarcode);
	if(comprec == null) return;

	cfind_company_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("customer_name"),"---UNDEFINED---"));
	cfind_address1_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("address1"),"------"));
	cfind_address2_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("address2"),"------"));
	cfind_address3_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("address3"),"------"));
	//cfind_address4_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("Address4"),"------"));
	cfind_tel_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("telephone_no"),"-----"));
	cfind_fax_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("fax_no"),"-----"));
	cfind_contact_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("contact_person1"),"-----"));
	cfind_email_lbl.setValue(kiboo.checkNullString_RetWat(comprec.get("E_mail"),"-----"));

	// if(iarcode.equals("BLACKLIST")) custinfo_gb.setStyle("background:#FF3333");
}

class searchcustomersLB_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getReference();
		tarcode = lbhand.getListcellItemLabel(selitem,0);
		showCustomerInfo(tarcode);
	}
}

// onDoubleClick listener for searchCustomers()
class searchcustLBDoubleClick_Listener implements org.zkoss.zk.ui.event.EventListener
{
	Object executeObject;

	public void onEvent(Event event) throws UiException
	{
		selitem = customers_lb.getSelectedItem();
		sarcode = lbhand.getListcellItemLabel(selitem,0);
		if(sarcode.equals("BLACKLIST")) return;

		comprec = sqlhand.getCompanyRecord(sarcode);
		if(comprec != null)
		{
			// do the caller's callmeobject
			executeObject.companyrec = comprec;
			executeObject.doSomething();
		}
	}
}

// 18/03/2011: sqlstatement put in check for inactive account = isinactive field
// 18/03/2011: 300P/086 and 300P/267 hardcoded to block
void searchCustomers(Object callwho)
{
Object[] clients_lb_headers = {
	new listboxHeaderObj("AR_CODE",true),
	new listboxHeaderObj("Company",true),
	};

	schtext = kiboo.replaceSingleQuotes(cust_search_tb.getValue());
	if(schtext.equals("")) return;

	Listbox newlb = lbhand.makeVWListbox(foundcustomer_holder, clients_lb_headers, "customers_lb", 5);

	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	sqlstm = "select top 50 ar_code,customer_name,credit_period from customer where " +
	"(ar_code like '%" + schtext + "%' or " +
	"customer_name like '%" + schtext + "%' or " +
	"address1 like '%" + schtext + "%' or " +
	"address2 like '%" + schtext + "%' or " +
	"address3 like '%" + schtext + "%' or " +
	"address4 like '%" + schtext + "%' or " +
	"contact_person1 like '%" + schtext + "%') and " +
	"isinactive=0 " +
	"order by customer_name";

	custrecs = sql.rows(sqlstm);
	sql.close();

	if(custrecs.size() == 0) return;
	newlb.setRows(10);
	newlb.addEventListener("onSelect", new searchcustomersLB_Listener());

	for(dpi : custrecs)
	{
		ArrayList kabom = new ArrayList();

		credp = dpi.get("credit_period");
		arcode = dpi.get("ar_code").trim();
		if(credp.equals("BLACKLIST")) arcode = "BLACKLIST";
		if(arcode.equals("300P/086") || arcode.equals("300P/267")) arcode = "BLOCKED";
		kabom.add(arcode);

		kabom.add(dpi.get("customer_name"));

		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
	
	dc_obj = new searchcustLBDoubleClick_Listener();
	dc_obj.executeObject = callwho;
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

// ---- ENDOF Customer search popup stuff ----

