import org.victor.*;

//---------- THESE CODES TO SHOW DIVISION->SECTION->TEST-PARAMETERS PANELS -----
ALS_stock_cat = "";
ALS_group_code = "";

global_selected_folder = "";
global_selected_mysoftcode = "";

lbhandler = new ListboxHandler();
kiboo = new Generals();
sqlhand = new SqlFuncs();

// onSelect event for makeALSTestParametersListbox()
class ALSTestParametersLB_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		global_selected_mysoftcode = tests_description_lb.getSelectedItem().getLabel(); // 1st col is mysoftcode
		insertitem_btn.setVisible(true);
	}
}

class testParam_DoubleClicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = tests_description_lb.getSelectedItem();
		global_selected_mysoftcode = lbhandler.getListcellItemLabel(selitem,0);
		addQuoteItems_clicker();
	}
}


Object[] testparameters_lb_headers = {
	new listboxHeaderObj("mysoftcode",false),
	new listboxHeaderObj("Test",true),
	new listboxHeaderObj("Method",true),
	new listboxHeaderObj("Price",true),
};

// Populate division column - refer to mysoft.stockmasterdetails.stock_cat
// nominal_code=glcode=5xxxxx = services we sell
// istock_cat = as in stockmasterdetails.stock_cat
void populateTestParametersColumn(Div iwhichdiv, String istock_cat, String igroupcode)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;

	sqlstatem = "select id,description,description2,selling_price from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
		"and stock_cat='" + istock_cat + "' " +
		"and groupcode='" + igroupcode + "' " +
		"order by description" ;

	tlist = sql.rows(sqlstatem);
	sql.close();

	if(tlist.size() < 1) return;

	Listbox newlb = lbhandler.makeVWListbox(iwhichdiv, testparameters_lb_headers, "tests_description_lb", 12);
	newlb.addEventListener("onSelect", new ALSTestParametersLB_Listener());

	for(ilist : tlist)
	{
		ArrayList kabom = new ArrayList();
		
		desc1 = (ilist.get("description") != null) ? ilist.get("description") : "";
		desc2 = (ilist.get("description2") != null) ? ilist.get("description2") : "";

		kabom.add(ilist.get("id").toString());
		kabom.add(desc1);
		kabom.add(desc2);
		kabom.add("RM " + ilist.get("selling_price").toString());

		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhandler.insertListItems(newlb,strarray,"true","");
	}

	dc_obj = new testParam_DoubleClicker();
	lbhandler.setDoubleClick_ListItems(newlb, dc_obj);
	
} // end of populateTestParametersColumn()

// onSelect event for makeALSSectionListbox()
class ALSSectionLB_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		ALS_group_code = section_groupcode_lb.getSelectedItem().getLabel();
		// populate section column
		//iwhatcode = convertLongNameToCode(als_divisions, iwhat);
		populateTestParametersColumn(testparameters_column, ALS_stock_cat, ALS_group_code);
	}
}

Object[] alssection_lb_headers = {
	new listboxHeaderObj("",true)
};

// Populate division column - refer to mysoft.stockmasterdetails.stock_cat
// nominal_code=glcode=5xxxxx = services we sell
// istock_cat = as in stockmasterdetails.stock_cat
void populateSectionColumn(Div iwhichdiv, String istock_cat)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;

	sqlstatem = "select distinct groupcode from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' " + 
		"and stock_cat='" + istock_cat + "' order by groupcode" ;

	tlist = sql.rows(sqlstatem);
	sql.close();

	// save istock_cat , to be used later in ALSSectionLB_Listener
	ALS_stock_cat = istock_cat;

	if(tlist.size() == 0) return;

	Listbox newlb = lbhandler.makeVWListbox(iwhichdiv, alssection_lb_headers, "section_groupcode_lb", 14);
	newlb.addEventListener("onSelect", new ALSSectionLB_Listener());

	String[] strarray = new String[1];

	for(ilist : tlist)
	{
		// strarray[0] = convertCodeToLongName(als_divisions,ilist.get("stock_cat"));
		strarray[0] = ilist.get("groupcode");
		lbhandler.insertListItems(newlb,strarray,"true","");
	}
} // end of populateSectionColumn()

// onSelect event for makeALSDivisionListbox()
class ALSDivisionLB_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		iwhat = division_stockcat_lb.getSelectedItem().getLabel();
		// populate section column
		iwhatcode = convertLongNameToCode(als_divisions, iwhat);
		populateSectionColumn(section_column,iwhatcode);
	}
}

Object[] alsdivision_lb_headers = {
	new listboxHeaderObj("",true)
};

// Populate division column - refer to mysoft.stockmasterdetails.stock_cat
// nominal_code=glcode=5xxxxx = services we sell
void populateDivisionColumn(Div iwhichdiv)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null ) return;
	sqlstatem = "select distinct stock_cat from stockmasterdetails where item_type='Service Item' and nominal_code like '5%' order by stock_cat" ;
	tlist = sql.rows(sqlstatem);
	sql.close();
	if(tlist.size() == 0) return;
	Listbox newlb = lbhandler.makeVWListbox(iwhichdiv, alsdivision_lb_headers, "division_stockcat_lb", 14);
	newlb.addEventListener("onSelect", new ALSDivisionLB_Listener());
	String[] strarray = new String[1];
	for(ilist : tlist)
	{
		strarray[0] = convertCodeToLongName(als_divisions,ilist.get("stock_cat"));
		lbhandler.insertListItems(newlb,strarray,"true","");
	}
} // end of populateDivisionColumn()

//------------- END OF SHOW DIVISION->SECTION->TEST-PARAMETERS PANELS -----------------

