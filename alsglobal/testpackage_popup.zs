// Written by Victor Wong
//-------- Test Package popup and selection related ------

void showTestsForTestPackage(Div idiv, String itpo)
{
	Object[] tests_tp_lb_headers = {
	new listboxHeaderObj("Params",true),
	new listboxHeaderObj("LOR",true)
	};

	Listbox newlb = lbhand.makeVWListbox(idiv, tests_tp_lb_headers, "tests_tp_lb", 5);

	sqlstatem = "select stockmasterdetails.description, testpackage_items.lor from testpackage_items " +
	"left join stockmasterdetails on testpackage_items.mysoftcode = stockmasterdetails.id " +
	"where testpackage_items.testpackage_id=" + itpo + " order by testpackage_items.sorter";

	tp_recs = sqlhand.gpSqlGetRows(sqlstatem);
	if(tp_recs.size() == 0) return;

	for(tpi : tp_recs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(kiboo.checkNullString_RetWat(tpi.get("description"),"------"));
		kabom.add(kiboo.checkNullString(tpi.get("lor")));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
}

// doubleClicker for populateTestPackages()
class testpackageDoubleClick_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		//selitem = testpackages_lb.getSelectedItem();
		crampTestPackage(); // cramp tests from test-package into sample
	}
}

// onSelect listner for populateTestPackages()
class testpackageOnSelect_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getReference();
		tporigid = lbhand.getListcellItemLabel(selitem,0);
		showTestsForTestPackage(tp_tests_holder,tporigid);
	}
}

// Show test-packages linked to ar_code, if ar_code == "", show all
void populateTestPackages(Div idiv, String iarcode)
{
	Object[] testpackages_lb_headers = {
	new listboxHeaderObj("Origid",false),
	new listboxHeaderObj("Name",true),
	new listboxHeaderObj("LastUpdate",true)
	};

	Listbox newlb = lbhand.makeVWListbox(idiv, testpackages_lb_headers, "testpackages_lb", 5);
	sqlstatem = "select origid,package_name,lastupdate from TestPackages where ar_code='" + iarcode + "' and deleted=0 order by package_name";

	if(iarcode.equals("")) // show all test-packages
		sqlstatem = "select origid,package_name,lastupdate from TestPackages where deleted=0 order by package_name";

	tp_recs = sqlhand.gpSqlGetRows(sqlstatem);

	if(tp_recs.size() == 0) return;
	newlb.setRows(10);
	newlb.addEventListener("onSelect", new testpackageOnSelect_Listener());

	for(tpi : tp_recs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(tpi.get("origid").toString());

		pckname = tpi.get("package_name");
		if(pckname.equals("")) pckname = "-undefined-";
		kabom.add(lbhand.trimListitemLabel(pckname,30));

		kabom.add(tpi.get("lastupdate").toString().substring(0,10));

		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
	
	dc_obj = new testpackageDoubleClick_Listener();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

// onSelect listner for showClientToTestPackage()
class tp2clients_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getReference();
		ar_code = lbhand.getListcellItemLabel(selitem,0);
		populateTestPackages(testpackages_div,ar_code);
	}

}

// Show test-packages linked to client - will show ALL
void showClientToTestPackage(Div idiv)
{
	Object[] tp2client_lb_headers = {
	new listboxHeaderObj("ar_code",false),
	new listboxHeaderObj("Customer",true),
	};

	Listbox newlb = lbhand.makeVWListbox(idiv, tp2client_lb_headers, "tp2clients_lb", 5);

	sqlstatem = "select distinct testpackages.ar_code, customer.customer_name from TestPackages " +
	"left join customer on testpackages.ar_code=customer.ar_code " +
	"where testpackages.deleted=0 order by customer.customer_name";
	custrecs = sqlhand.gpSqlGetRows(sqlstatem);

	if(custrecs.size() == 0) return;
	newlb.setRows(20);
	newlb.addEventListener("onSelect", new tp2clients_Listener());

	for(dpi : custrecs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(kiboo.checkNullString(dpi.get("ar_code")));
		kabom.add(kiboo.checkNullString_RetWat(dpi.get("customer_name"),"--ALL--"));
		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false","");
	}
}

// 03/08/2011: insert unitprice def in testpackage_items into jobtestparameters. testpackage_id stored too

void crampTestPackage()
{
	// make sure selected a sample-id
	isampid = sampleid.getValue();
	if(isampid.equals("")) return;

	this_sampidint = samphand.convertSampleNoToInteger(isampid).toString();

	// make sure selected a test package
	if(testpackages_lb.getSelectedIndex() == -1) return;

	testpack = testpackages_lb.getSelectedItem().getLabel(); // which test package selected

	// get list of test parameters (mysoftcode) as def in test-package
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	sqlst = "select mysoftcode,sorter,lor,bill,units,unitprice from TestPackage_Items where deleted=0 and testpackage_id=" + testpack;
	tp_items = sql.rows(sqlst);
	
	// 14/9/2010: get the last sorter num. from listbox
	lbindex = testparameters_lb.getItemCount()-1;
	lastsorter = 0;
	if(lbindex != -1)
	{
		lastitem = testparameters_lb.getItemAtIndex(lbindex);
		lastsorter = Integer.parseInt(lbhand.getListcellItemLabel(lastitem,1));
	}

	if(tp_items != null)
	{
		for(tpi : tp_items)
		{
			tp_mysc = tpi.get("mysoftcode").toString();
			tp_sorter = (lastsorter + tpi.get("sorter")).toString();

			tp_lor = tpi.get("lor");
			tp_bill = tpi.get("bill");
			tp_units = tpi.get("units");
			tp_price = tpi.get("unitprice");

			//insertTestParameter(this_sampidint, tp_mysc); // need to optimize this.. calling the func will open/close sql-obj, waste processing
			
			sqlstatem = "insert into JobTestParameters (jobsamples_id,mysoftcode,starlimscode,status," + 
			"uploadtomysoft,uploadtolims,sorter,lor,bill,price,units,testpackageid,packageprice) values " + 
			"(" + this_sampidint + "," + tp_mysc + ",0,'DRAFT',0,0," + tp_sorter + ",'" + 
			tp_lor + "','" + tp_bill + "', 0.0, '" + tp_units + "'," + testpack + "," + tp_price + ")";

			sql.execute(sqlstatem);
		}
	}

	sql.close();
	startTestParametersSearch(sampleid); // refresh
}

void showTestPackages_clicker()
{
	showClientToTestPackage(tp2client_holder);
	testPackagePopup.open(testpackage_btn);
}
//-------- End of Test Package related ------


