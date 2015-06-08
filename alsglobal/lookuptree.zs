import org.zkoss.zk.ui.*;
import groovy.sql.Sql;

class LookupTree
{
	Treechildren tobeshown;
	Sql mainSql;

	void LookupTree(Treechildren thechild, String queryname, boolean showexpired)
	{
        // hardcoded -- need to change later if necessary
		mainSql = Sql.newInstance("jdbc:mysql://localhost:3306/alsportal", "alsportal", "kimc",
			"org.gjt.mm.mysql.Driver");
			
		sqlstatement = "SELECT * from lookups where myparent='" + queryname + "'";
		List catlist = mainSql.rows(sqlstatement);

		tobeshown = thechild;

		fillMyTree(thechild, catlist, showexpired);
		
		mainSql.close();

	}

	// showexpired : used in normal operation, if showexpired = 0, don't show, user cannot select
	// showexpired = 1 , show expired, during lookup configuratin only
	void fillMyTree(Treechildren tchild, List prolist, boolean showexpired)
	{
		for (opis : prolist)
		{
			if(opis.get("expired") == true && showexpired == false) continue;
			
			Treeitem titem = new Treeitem();
			Treerow newrow = new Treerow();
			Treecell newcell1 = new Treecell();
			Treecell newcell2 = new Treecell();

			lookname = opis.get("name");
			disptext = opis.get("disptext");
	
			sqlqueryline = "select * from lookups where myparent='" + lookname + "'";
			List subchild = mainSql.rows(sqlqueryline);

			newcell1.setLabel(lookname);
			
			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild,showexpired);
		
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			expiredstr = "";
			
			if(opis.get("expired") == true)
				expiredstr = "[INACTIVE] ";

			newcell2.setLabel(expiredstr + disptext);
			
			newcell1.setParent(newrow);
			newcell2.setParent(newrow);
			newrow.setParent(titem);
			titem.setParent(tchild);
		}

	}

	void myShowTreeChildren()
	{
		alert(tobeshown);
	}

}
// end of class LookupTree

// Container class for lookup items input boxes and such
class lookupInputs
{
	public Textbox name;
	public Textbox disptext;
	public Checkbox expired;
	public Intbox intvalue;
	public Listbox parentlistbox;

    public Textbox value1;
    public Textbox value2;
    public Textbox value3;
    public Textbox value4;
    public Textbox value5;
    public Textbox value6;
    public Textbox value7;
    public Textbox value8;

	String plb_id;
	public Tree lu_tree;

	public lookupInputs(Textbox iname, Textbox idisptext, Checkbox iexpired, Intbox ibox,
	Listbox iplbox, Tree itree)
	{
		name = iname;
		disptext = idisptext;
		expired = iexpired;
		intvalue = ibox;
		parentlistbox = iplbox;
		lu_tree = itree;
	}

	public lookupInputs(Textbox iname, Textbox idisptext, Checkbox iexpired, Intbox ibox,
    Textbox ivalue1,Textbox ivalue2,Textbox ivalue3,Textbox ivalue4,
    Textbox ivalue5,Textbox ivalue6,Textbox ivalue7,Textbox ivalue8,
	String iplboxid, Tree itree)
	{
		name = iname;
		disptext = idisptext;
		expired = iexpired;
		intvalue = ibox;
		parentlistbox = null;
		plb_id = iplboxid;
		lu_tree = itree;

        value1 = ivalue1;
        value2 = ivalue2;
        value3 = ivalue3;
        value4 = ivalue4;
        value5 = ivalue5;
        value6 = ivalue6;
        value7 = ivalue7;
        value8 = ivalue8;

	}

    void clearValues()
    {
        name.setValue("");
        disptext.setValue("");
        expired.setChecked(false);
        intvalue.setValue(0);

        value1.setValue("");
        value2.setValue("");
        value3.setValue("");
        value4.setValue("");
        value5.setValue("");
        value6.setValue("");
        value7.setValue("");
        value8.setValue("");

    }

	Listbox getParentListBox()
	{
		// if parentlistbox is null, use id string to get actual listbox
		if(parentlistbox == null)
		{
			parentlistbox = lu_tree.getFellowIfAny(plb_id);
		}

		return parentlistbox;

	}
}
// end of class lookupInputs

// Show the lookup table in tree
// melistbox : used to get parent name
// thethree : tree control to be populated
void showLookupTree(String parentname, Tree thetree)
{
	//alert(melist.getItemAtIndex(melist.getSelectedIndex());
	//alert(melistbox.getSelectedItem());

	// doname = melistbox.getSelectedItem().getId();

	// Clear any child attached to tree before updating new ones.
	Treechildren tocheck = thetree.getTreechildren();
	if(tocheck != null)
	{
		tocheck.setParent(null);
	}

	// create a new treechildren for the tree
	Treechildren mychildrens = new Treechildren();
	mychildrens.setParent(thetree);

	// Load the lookuptree from database
	LookupTree incd_lookuptree = new LookupTree(mychildrens,parentname,true);


}

// Make sure the code entered is unique.
// cannot have duplicates else the whole system will break.
boolean isUniqueCode(String thecode)
{
	boolean retval = false;

	try
	{
		sql = alsportal_Mysql();

		sqlstatement = "select name from lookups where name='" + thecode + "'";
		subchild = sql.rows(sqlstatement);

		if(subchild.size() == 0)
			retval = true;
	}
	catch (SQLException se) {}

	sql.close();
	return retval;

}

// Return the selected item's parent. Should be unique and be used for inserting new
// items under the parent.
String getSelectedParent(String whichone)
{
	try
	{
		sql = alsportal_Mysql();
		sqlstatem = "select * from lookups where name='" + whichone + "'";
		therec = sql.firstRow(sqlstatem);
	}
	catch (SQLException e) {}
	finally
	{
		sql.close();
		return therec.get("myparent");
	}
}

// Insert new lookup items to lookup table
void insertLookupItem(Tree itypetree, lookupInputs winputs)
{
	try
	{
		iname = winputs.name.getValue();
		idisptext = winputs.disptext.getValue();
		iexpired = winputs.expired.isChecked();
		intvalbox = winputs.intvalue;

        zzintval = (intvalbox == null) ? 0 : intvalbox.intValue();

        ivalue1 = winputs.value1.getValue();
        ivalue2 = winputs.value2.getValue();
        ivalue3 = winputs.value3.getValue();
        ivalue4 = winputs.value4.getValue();
        ivalue5 = winputs.value5.getValue();
        ivalue6 = winputs.value6.getValue();
        ivalue7 = winputs.value7.getValue();
        ivalue8 = winputs.value8.getValue();

		if(iname == null || iname == "")
		{
			return;
		}

		selectedId = itypetree.getSelectedItem().getLabel();

		// Get parent of the selected item
		insparent = selectedId;

		// Check to make sure code is unique
		if(isUniqueCode(iname) == true)
		{
			//alert(iname + " is unique, can insert");

			try
			{
            sql = alsportal_Mysql();

			sqlstatem = "insert into lookups (myparent,name,disptext,intval,expired,value1,value2,value3,value4,value5,value6,value7,value8) values ('"+
			insparent + "','" + iname + "','" + idisptext + "'," + zzintval + "," + iexpired + ",'" +
            ivalue1 + "','" + ivalue2 + "','" + ivalue3 + "','" + ivalue4 + "','" + ivalue5 + "','" + ivalue6 + "','" + ivalue7 + "','" + ivalue8+ "'" +
            ")";

            // alert(sqlstatem);

			sql.execute(sqlstatem);

			// redraw lookup tree
			showLookupTree(winputs.plb_id,itypetree);

			}
			catch (SQLException se) {}

			sql.close();

		}
		else
		{
			alert("Code in use, duplicates not allowed");
		}
	}
	catch (NullPointerException nex) {}

} // end of insertLookupItem(Tree itypetree, lookupInputs winputs)

// Update lookup items
void updateLookupItem(Tree itypetree, lookupInputs winputs)
{
	iname = winputs.name.getValue();
	idisptext = winputs.disptext.getValue();
	iexpired = winputs.expired.isChecked();
	intvalbox = winputs.intvalue;

    zzintval = (intvalbox == null) ? 0 : intvalbox.intValue();

    ivalue1 = winputs.value1.getValue();
    ivalue2 = winputs.value2.getValue();
    ivalue3 = winputs.value3.getValue();
    ivalue4 = winputs.value4.getValue();
    ivalue5 = winputs.value5.getValue();
    ivalue6 = winputs.value6.getValue();
    ivalue7 = winputs.value7.getValue();
    ivalue8 = winputs.value8.getValue();

	try
	{
		sql = alsportal_Mysql();
		sqlstatem = "update lookups set disptext='"+ idisptext + "',expired="+iexpired+
			",intval=" + zzintval +
            ",value1='" + ivalue1 + "'" +
            ",value2='" + ivalue2 + "'" +
            ",value3='" + ivalue3 + "'" +
            ",value4='" + ivalue4 + "'" +
            ",value5='" + ivalue5 + "'" +
            ",value6='" + ivalue6 + "'" +
            ",value7='" + ivalue7 + "'" +
            ",value8='" + ivalue8 + "'" +
            " where name='" + iname + "'";

		sql.executeUpdate(sqlstatem);

		// redraw lookup tree
		showLookupTree(winputs.plb_id,winputs.lu_tree);
	}
	catch (SQLException e) {}
	finally
	{
		sql.close();
	}

} // end of updateLookupItem()

// Delete lookup items from table.
void deleteLookupItem(Tree itypetree, lookupInputs winputs)
{
	try
	{
		selectedId = itypetree.getSelectedItem().getLabel();

		// check to see if others are link to this
		//isInUse(selectedId)

		try
		{
			sql = alsportal_Mysql();

			sqlstatem = "delete from lookups where name='" + selectedId + "'";
			sql.execute(sqlstatem);

			// redraw lookup tree
			showLookupTree(winputs.plb_id,winputs.lu_tree);

		}
		catch (SQLException se) {}

		sql.close();

	}
	catch (NullPointerException nex) {}

} // end of deleteLookupItem()

