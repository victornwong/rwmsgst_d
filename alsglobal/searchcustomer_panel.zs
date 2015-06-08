import org.victor.*;

lbhand = new ListboxHandler();
sqlhand = new SqlFuncs();
kiboo = new Generals();
guihand = new GuiFuncs();

// popup at bottom.. check and reuse
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
	public void onEvent(Event event) throws UiException
	{
		selitem = customers_lb.getSelectedItem();
		sarcode = lbhand.getListcellItemLabel(selitem,0);
		if(sarcode.equals("BLACKLIST")) return;

		// 24/02/2012: must be NEW quotation, can change customer
		if(!global_quote_status.equals(QTSTAT_NEW))
		{
			guihand.showMessageBox("Quotation already committed, cannot change customer!!");
			return;
		}

		comprec = sqlhand.getCompanyRecord(sarcode);
		if(comprec != null)
		{
			// customize this part if need to use in other module - where to show the selected client info
			qt_ar_code.setValue(comprec.get("ar_code"));

			// codes taken from dropAR_Code() - populate fields
			qt_customer_name.setValue(comprec.get("customer_name"));
			qt_contact_person1.setValue(comprec.get("contact_person1"));
			qt_address1.setValue(comprec.get("address1") + comprec.get("address2"));
			qt_address2.setValue(comprec.get("address3") + comprec.get("Address4"));
			qt_telephone.setValue(comprec.get("telephone_no"));
			qt_fax.setValue(comprec.get("fax_no"));
			qt_email.setValue(comprec.get("E_mail"));

			//qt_exchangerate.setValue(comprec.get("
			tterms = comprec.get("credit_period");
			ssman = comprec.get("Salesman_code");

			if(tterms != null) lbhand.matchListboxItems(qt_terms,tterms);
			if(ssman != null) lbhand.matchListboxItemsColumn(qt_salesperson,ssman,1);

			lbhand.matchListboxItems(qt_curcode,comprec.get("CurCode"));
		}
		selectcustomer_popup.close();
	}
}

void searchCustomers()
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
	"ar_code like '%" + schtext + "%' or " +
	"customer_name like '%" + schtext + "%' or " +
	"address1 like '%" + schtext + "%' or " +
	"address2 like '%" + schtext + "%' or " +
	"address3 like '%" + schtext + "%' or " +
	"address4 like '%" + schtext + "%' or " +
	"contact_person1 like '%" + schtext + "%' " +
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
		arcode = dpi.get("ar_code");
		if(credp.equals("BLACKLIST")) arcode = "BLACKLIST";
		kabom.add(arcode);
		kabom.add(dpi.get("customer_name"));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}

	dc_obj = new searchcustLBDoubleClick_Listener();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}
// ---- ENDOF Customer search popup stuff ----


/*
the popup:

<!-- select customer popup -->
<popup id="selectcustomer_popup">
<div style="padding:3px">
<hbox>
<groupbox width="400px">
	<caption label="Search" />
	<hbox>
		<label value="Search text" style="font-size:9px" />
		<textbox id="cust_search_tb" width="150px" style="font-size:9px" />
		<button label="Find" style="font-size:9px" onClick="searchCustomers()" />
	</hbox>
	<separator height="3px" />
	<div id="foundcustomer_holder" />
</groupbox>

<groupbox id="custinfo_gb" width="300px" >
	<caption label="Customer info" />
	<grid>
		<columns>
			<column label="" />
			<column label="" />
		</columns>
		<rows>
		<row>
			<label value="Company" style="font-size:9px" />
			<label id="cfind_company_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Address1" style="font-size:9px" />
			<label id="cfind_address1_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Address2" style="font-size:9px" />
			<label id="cfind_address2_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Address3" style="font-size:9px" />
			<label id="cfind_address3_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Contact " style="font-size:9px" />
			<label id="cfind_contact_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Email" style="font-size:9px" />
			<label id="cfind_email_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Tel" style="font-size:9px" />
			<label id="cfind_tel_lbl" style="font-size:9px" />
		</row>
		<row>
			<label value="Fax" style="font-size:9px" />
			<label id="cfind_fax_lbl" style="font-size:9px" />
		</row>
		</rows>
	</grid>
</groupbox>

</hbox>
<separator height="3px" />
<button label="X Close" style="font-size:9px" onClick="selectcustomer_popup.close()" />
</div>
</popup>
<!-- ENDOF select customer popup -->

*/

