import org.victor.*;

sqlhand = new SqlFuncs();
menuhand = new MenuFuncs();
kiboo = new Generals();

// a knockoff from lookuptree.zs
class portalMenuTree
{
	Treechildren tobeshown;
	Sql mainSql;

	void portalMenuTree(Treechildren thechild, String iparentid)
	{
		mainSql = sqlhand.als_mysoftsql();
		if(mainSql == null) return;

		sqlstatement = "select origid,menulabel,accesslevel,usergroup,usergrouplevel,position from elb_menutree " + 
		"where menuname='" + iparentid + "' order by position";
		List catlist = mainSql.rows(sqlstatement);
		tobeshown = thechild;
		fillMyTree(thechild, catlist, 1);
		mainSql.close();
	}

	void fillMyTree(Treechildren tchild, List prolist, int itreelevel)
	{
		for (opis : prolist)
		{
			Treeitem titem = new Treeitem();
			titem.setOpen(false);

			Treerow newrow = new Treerow();

			Treecell newcell1 = new Treecell();
			Treecell newcell2 = new Treecell();
			Treecell newcell3 = new Treecell();
			Treecell newcell4 = new Treecell();
			Treecell newcell5 = new Treecell();
			Treecell newcell6 = new Treecell();

			thisbranchid = opis.get("origid").toString();
			menulabel = opis.get("menulabel");
			if(menulabel.length() > 40) menulabel = menulabel.substring(0,38) + "..";

			accesslevel = opis.get("accesslevel").toString();
			ugroup = kiboo.checkNullString(opis.get("usergroup"));
			//if(ugroup.equals("")) ugroup = "ALL";

			ugrouplvl = (opis.get("usergrouplevel") == null) ? "1" : opis.get("usergrouplevel").toString();
			mposi = (opis.get("position") == null) ? "" : opis.get("position").toString();

			sqlqueryline = "select origid,menulabel,accesslevel,usergroup,usergrouplevel,position from elb_menutree " + 
			"where menuparent=" + thisbranchid + " order by position";

			List subchild = mainSql.rows(sqlqueryline);
			highlite = false;

			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild,itreelevel+1);
				if(itreelevel == 1) highlite = true; // only hilite menu-tab
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			newcell6.setVisible(false);
			newcell6.setLabel(thisbranchid);

			itmstyle = "font-size:9px";
			if(highlite) itmstyle += ";background:#ff9922";

			newcell1.setLabel(menulabel);
			newcell1.setStyle(itmstyle);
			newcell1.setDraggable("menutreedrop");

			newcell2.setLabel(accesslevel);
			newcell2.setStyle(itmstyle);

			newcell3.setLabel(ugroup);
			newcell3.setStyle(itmstyle);

			newcell4.setLabel(ugrouplvl);
			newcell4.setStyle(itmstyle);

			newcell5.setLabel(mposi);
			newcell5.setStyle(itmstyle);

			newcell1.setParent(newrow);
			newcell2.setParent(newrow);
			newcell3.setParent(newrow);
			newcell4.setParent(newrow);
			newcell5.setParent(newrow);
			newcell6.setParent(newrow);

			newrow.setParent(titem);
			titem.setParent(tchild);
		}
	}
}
// end of class directoryTree

void showMenuTree(String parentname, Tree thetree)
{
	// Clear any child attached to tree before updating new ones.
	Treechildren tocheck = thetree.getTreechildren();
	if(tocheck != null) tocheck.setParent(null);

	// create a new treechildren for the tree
	Treechildren mychildrens = new Treechildren();
	mychildrens.setParent(thetree);

	//menu_tree.setRows(15);
	portalMenuTree incd_lookuptree = new portalMenuTree(mychildrens,parentname);
}


