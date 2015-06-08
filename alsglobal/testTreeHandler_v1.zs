// Test-tree handler
// Written by : Victor Wong
// Dated : 20/09/2012

TT_TEST = 0;
TT_METHOD = 1;
TT_STOCKCODE = 2;
TT_STOCKCAT = 3;
TT_GROUCODE = 4;
TT_ORIGID = 5;

glob_selected_subid = "";
glob_selected_subdetails = "";

public class TestTree
{
	private GuiFuncs guihand;
	private SqlFuncs sqlhand;

	Treechildren tobeshown;
	Sql mainSql;
	
	public TestTree(Treechildren thechild, String iparentid, org.zkoss.zk.ui.event.EventListener idoubleclick)
	{
		guihand = new GuiFuncs();
		sqlhand = new SqlFuncs();

		String sqlstm = "select ttree.origid, ttree.branchtitle, ttree.mysoftcode, " +
			"smd.description, smd.description2, smd.stock_code, smd.stock_cat,smd.groupcode " +
			"from elb_testtree ttree " +
			"left join stockmasterdetails smd on smd.id = ttree.mysoftcode " +
			"where ttree.parentid=" + iparentid;

		ArrayList catlist = (ArrayList)sqlhand.gpSqlGetRows(sqlstm);
		tobeshown = thechild;
		//alert(catlist);
		fillMyTree(thechild, catlist, idoubleclick);
	}

	void fillMyTree(Treechildren tchild, ArrayList prolist, org.zkoss.zk.ui.event.EventListener odclick)
	{
		//for(GroovyRowResult opis : (List<GroovyRowResult>)prolist)
		for(dpi : prolist)
		{
			Treeitem titem = new Treeitem();
			//titem.setOpen(false);
			Treerow newrow = new Treerow();
			if(odclick != null) newrow.addEventListener("onDoubleClick",odclick);

			Treecell cell_stockcode = new Treecell();
			Treecell cell_teststr = new Treecell();
			Treecell cell_methodstr = new Treecell();
			Treecell cell_origid = new Treecell();
			Treecell cell_stockcat = new Treecell();
			Treecell cell_groupcode = new Treecell();

			String thisbranchid = (String)dpi.get("origid").toString();
			String brhstr,methodstr;

			if(dpi.get("description") != null) brhstr = (String)dpi.get("description");
			else brhstr = (String)dpi.get("branchtitle");

			if(dpi.get("description2") != null) methodstr = (String)dpi.get("description2");
			else methodstr = "";

			//if(folderid.length() > 40) folderid = folderid.substring(0,38) + "..";

			String sqlstm = "select ttree.origid, ttree.branchtitle, ttree.mysoftcode, " +
			"smd.description, smd.description2, smd.stock_code, smd.stock_cat,smd.groupcode " +
			"from elb_testtree ttree " +
			"left join stockmasterdetails smd on smd.id = ttree.mysoftcode " +
			"where ttree.parentid=" + thisbranchid;

			ArrayList subchild = (ArrayList)sqlhand.gpSqlGetRows(sqlstm);

			boolean highlite = false;

			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild,odclick);
				highlite = true;
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			cell_origid.setVisible(false);
			cell_origid.setLabel(thisbranchid);

			String itmstyle = "font-size:9px";
			//if(highlite) itmstyle += ";background:#99AA88";

			mysoftcode = dpi.get("mysoftcode");
			//mystr = (mysoftcode == 0) ? "__" : mysoftcode.toString();
			//itmstyle += (mysoftcode == 0) ? ";background:#8ae234" : "";

			cell_stockcode.setLabel(kiboo.checkNullString(dpi.get("stock_code")));
			cell_stockcode.setStyle(itmstyle);

			cell_teststr.setLabel(brhstr);
			cell_teststr.setStyle(itmstyle);

			cell_methodstr.setLabel(methodstr);
			cell_methodstr.setStyle(itmstyle);

			cell_stockcat.setLabel(kiboo.checkNullString(dpi.get("stock_cat")));
			cell_stockcat.setStyle(itmstyle);

			cell_groupcode.setLabel(kiboo.checkNullString(dpi.get("groupcode")));
			cell_groupcode.setStyle(itmstyle);

			//newcell1.setDraggable("treedrop");

			cell_teststr.setParent(newrow);
			cell_methodstr.setParent(newrow);
			cell_stockcode.setParent(newrow);
			cell_stockcat.setParent(newrow);
			cell_groupcode.setParent(newrow);
			cell_origid.setParent(newrow);

			newrow.setParent(titem);
			titem.setParent(tchild);
		}
	}
}

// onSelect event for makeALSTestParametersListbox()
class testP_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget().getSelectedItem();
		glob_selected_mysoft = lbhand.getListcellItemLabel(selitem,0);
		showTestMetadata(); // testsTreeManager_v1.zul
	}
}

class testPDC_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget();
		if(glob_selected_subid.equals("")) return;
		glob_selected_mysoft = lbhand.getListcellItemLabel(selitem,0);
		sqlstm = "update elb_testtree set mysoftcode=" + glob_selected_mysoft + " where origid=" + glob_selected_subid;
		sqlhand.gpSqlExecuter(sqlstm);
		showTestSubDiv_tree(glob_selected_trunk, tests_tree); // refresh test-tree
	}
}

// save selected test-tree stuff to global-var. call by testTreeOnselect() and treeDC_Listener()
void saveTreeClickers(Object iwhat)
{
	glob_selected_subid = guihand.getTreecellItemLabel(iwhat,TT_ORIGID);
	glob_selected_subdetails = guihand.getTreecellItemLabel(iwhat,TT_TEST);
}

// test-tree onSelect
void testTreeOnselect(Tree itree)
{
	selitem = itree.getSelectedItem();
	saveTreeClickers(selitem);
}

// test-tree double-clicker
class treeDC_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget().getParent();
		saveTreeClickers(selitem);

		// branchdet_popup def in testsTreeManager_v1.zs
		branchdet_tb.setValue(glob_selected_subdetails);
		branchdet_popup.open(event.getTarget());
	}
}

// knock-off from dmsfuncs.java
void showTestSubDiv_tree(String parentname, Tree thetree)
{
	Treechildren tocheck = thetree.getTreechildren();
	if(tocheck != null) tocheck.setParent(null);
	Treechildren mychildrens = new Treechildren();
	mychildrens.setParent(thetree);
	thetree.setRows(20);

	treedc_obj = new treeDC_Listener(); // double-click listener
	TestTree testtreething = new TestTree(mychildrens,parentname,treedc_obj);
	glob_selected_subid = ""; // reset each time refresh the tree
}

