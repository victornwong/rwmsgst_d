import org.zkoss.zk.ui.*;
import groovy.sql.Sql;
import org.victor.*;

kiboo = new Generals();

class LookupTree
{
	Treechildren tobeshown;
	Sql mainSql;

	void LookupTree(Treechildren thechild, String queryname, boolean showexpired)
	{
        // hardcoded -- need to change later if necessary
		//mainSql = Sql.newInstance("jdbc:mysql://localhost:3306/alsportal", "alsportal", "",
		//	"org.gjt.mm.mysql.Driver");
		
		// 24/2/2010: mod to use als_mysoftsql() in alsglobal_sqlfuncs.zs
		mainSql = als_mysoftsql();
		if(mainSql == NULL) return;

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
			if(opis.get("expired") == 1 && showexpired == false) continue;
			
			Treeitem titem = new Treeitem();
			Treerow newrow = new Treerow();
			Treecell newcell1 = new Treecell();
			Treecell newcell2 = new Treecell();

			lookname = opis.get("name");
			disptext = opis.get("disptext");
	
			sqlqueryline = "select * from lookups where myparent='" + lookname + "'";
			List subchild = mainSql.rows(sqlqueryline);

			newcell1.setLabel(lookname);
			newcell1.setStyle("font-size:10px");
			newcell1.setDraggable("treedrop");
			
			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild,showexpired);
		
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			expiredstr = "";
			
			if(opis.get("expired") == 1)
				expiredstr = "[INACTIVE] ";

			newcell2.setStyle("font-size:9px");
			newcell2.setLabel(expiredstr + disptext);
			// newcell2.setDraggable("treedrop");
			
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
	
	// 24/2/2010: to store lookup rec no.
	public int idlookups;

	String plb_id;
	public Tree lu_tree;

	public lookupInputs(Textbox iname, Textbox idisptext, Checkbox iexpired, Intbox ibox, Listbox iplbox, Tree itree)
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

	sql = als_mysoftsql();
	if(sql == null) return retval;

	sqlstatement = "select name from lookups where name='" + thecode + "'";
	subchild = sql.rows(sqlstatement);
	sql.close();

	if(subchild.size() == 0) retval = true;

	return retval;
}

Object getLookup_Rec(String iname)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	sqlstatem = "select * from lookups where name='" + iname + "'";
	therec = sql.firstRow(sqlstatem);
	sql.close();
	
	return therec;
}

// Return the selected item's parent. Should be unique and be used for inserting new
// items under the parent.
String getSelectedParent(String whichone)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstatem = "select * from lookups where name='" + whichone + "'";
	therec = sql.firstRow(sqlstatem);

	sql.close();
	return therec.get("myparent");
}

// Insert new lookup items to lookup table
void insertLookupItem(Tree itypetree, lookupInputs winputs)
{
	try
	{
		iname = kiboo.replaceSingleQuotes(winputs.name.getValue());
		idisptext = kiboo.replaceSingleQuotes(winputs.disptext.getValue());
		iexpired = winputs.expired.isChecked();
		intvalbox = winputs.intvalue;

        //zzintval = (intvalbox == null) ? 0 : intvalbox.intValue();
		zzintval = intvalbox.getValue();

        ivalue1 = kiboo.replaceSingleQuotes(winputs.value1.getValue());
        ivalue2 = kiboo.replaceSingleQuotes(winputs.value2.getValue());
        ivalue3 = kiboo.replaceSingleQuotes(winputs.value3.getValue());
        ivalue4 = kiboo.replaceSingleQuotes(winputs.value4.getValue());
        ivalue5 = kiboo.replaceSingleQuotes(winputs.value5.getValue());
        ivalue6 = kiboo.replaceSingleQuotes(winputs.value6.getValue());
        ivalue7 = kiboo.replaceSingleQuotes(winputs.value7.getValue());
        ivalue8 = kiboo.replaceSingleQuotes(winputs.value8.getValue());

		if(iname.equals("")) return;
		
		// 24/2/2010: expired field is tinyint, cannot hold boolean
		iexp = (iexpired == true) ? 1 : 0;

		selectedId = itypetree.getSelectedItem().getLabel();

		// Get parent of the selected item
		insparent = selectedId;

		// Check to make sure code is unique
		if(isUniqueCode(iname) == true)
		{
			//alert(iname + " is unique, can insert");

            sql = als_mysoftsql();
			if(sql == null) return;
			thecon = sql.getConnection();
			pstmt = thecon.prepareStatement("insert into lookups (myparent,name,disptext,intval,expired," + 
			"value1,value2,value3,value4,value5,value6,value7,value8) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");

			pstmt.setString(1,insparent);
			pstmt.setString(2,iname);
			pstmt.setString(3,idisptext);
			pstmt.setInt(4,zzintval);
			pstmt.setInt(5,iexp);

			pstmt.setString(6,ivalue1);
			pstmt.setString(7,ivalue2);
			pstmt.setString(8,ivalue3);
			pstmt.setString(9,ivalue4);
			pstmt.setString(10,ivalue5);

			pstmt.setString(11,ivalue6);
			pstmt.setString(12,ivalue7);
			pstmt.setString(13,ivalue8);

			pstmt.executeUpdate();
			sql.close();			

			// redraw lookup tree
			showLookupTree(winputs.plb_id,itypetree);
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
	iname = kiboo.replaceSingleQuotes(winputs.name.getValue());
	idisptext = kiboo.replaceSingleQuotes(winputs.disptext.getValue());
	iexpired = winputs.expired.isChecked();
	intvalbox = winputs.intvalue;

    zzintval = (intvalbox == null) ? 0 : intvalbox.intValue();
	
	// 24/2/2010: expired field is tinyint, cannot hold boolean
	iexp = (iexpired == true) ? "1" : "0";

    ivalue1 = kiboo.replaceSingleQuotes(winputs.value1.getValue());
    ivalue2 = kiboo.replaceSingleQuotes(winputs.value2.getValue());
    ivalue3 = kiboo.replaceSingleQuotes(winputs.value3.getValue());
    ivalue4 = kiboo.replaceSingleQuotes(winputs.value4.getValue());
    ivalue5 = kiboo.replaceSingleQuotes(winputs.value5.getValue());
    ivalue6 = kiboo.replaceSingleQuotes(winputs.value6.getValue());
    ivalue7 = kiboo.replaceSingleQuotes(winputs.value7.getValue());
    ivalue8 = kiboo.replaceSingleQuotes(winputs.value8.getValue());
	
		sql = als_mysoftsql();
		sqlstatem = "update lookups set disptext='"+ idisptext + "',expired=" + iexp +
		",intval=" + zzintval.toString() +
		",value1='" + ivalue1 + "'" +
		",value2='" + ivalue2 + "'" +
		",value3='" + ivalue3 + "'" +
		",value4='" + ivalue4 + "'" +
		",value5='" + ivalue5 + "'" +
		",value6='" + ivalue6 + "'" +
		",value7='" + ivalue7 + "'" +
		",value8='" + ivalue8 + "'" +
		",name='" + iname + "'" +
		" where idlookups=" + winputs.idlookups.toString();

		sql.execute(sqlstatem);
		sql.close();
	
		// redraw lookup tree
		showLookupTree(winputs.plb_id,winputs.lu_tree);

} // end of updateLookupItem()

// Delete lookup items from table.
void deleteLookupItem(Tree itypetree, lookupInputs winputs)
{
	selectedId = itypetree.getSelectedItem().getLabel();

	// check to see if others are link to this
	//isInUse(selectedId)

	sql = als_mysoftsql();

	sqlstatem = "delete from lookups where name='" + selectedId + "'";
	sql.execute(sqlstatem);

	// redraw lookup tree
	showLookupTree(winputs.plb_id,winputs.lu_tree);

	sql.close();

} // end of deleteLookupItem()

// Database func: insert a rec into Lookups w/o using the tree-structure-input-boxes
void insertLookups_Rec(String iname, String idisptext, String imyparent)
{
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "insert into Lookups (name,disptext,myparent,expired) values ('" + iname + "','" + idisptext + "','" + imyparent + "',0)";
	sql.execute(sqlstm);
	sql.close();
}

// Database func: get lookup rec by idlookups
Object getLookupRec_ByID(String theid)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	sqlstatem = "select * from lookups where idlookups=" + theid;
	therec = sql.firstRow(sqlstatem);
	sql.close();
	return therec;
}
