// Document manager sub-directory management funcs
// Written by Victor Wong

void showDocuTreeTitle(String iwhat, Object ilbl)
{
	sqlstm = "select folderid from folderstructure where origid=" + iwhat;
	k = dmshand.dmsgpSqlFirstRow(sqlstm);
	if(k == null) return;
	//ilbl.setValue( kiboo.checkNullString(k.get("folderid")) );
	westside.setTitle( kiboo.checkNullString(k.get("folderid")) );
}

// onSelect event-func for the main docu-tree
void subdirectoryOnSelect(Tree wTree)
{
	selitem = wTree.getSelectedItem();
	selected_subdirectory = guihand.getTreecellItemLabel(selitem,2);
	foldid = guihand.getTreecellItemLabel(selitem,0);
	selected_treeitem = selitem; // global save for later

	subdir_label.setValue(foldid);
	fillDocumentsList_DM(DOCUPREFIX, selected_subdirectory, docu_holder, "docus_lb");

	u_directoryname.setValue(foldid);
	u_description.setValue( guihand.getTreecellItemLabel(selitem,1) );

	hideDocumentSpace();

	// 22/08/2014: put selected directory-name in eastside
	eastside.setTitle(foldid);

	if(mainform_holder.getFellowIfAny("NEXTGFORM") != null) NEXTGFORM.setParent(null);
	glob_selected_form = glob_selected_form_user = ""; // reset the docu-linked form things
	form_workarea.setVisible(false);

	listFormStorage(2, JN_linkcode()); // show linked forms

} // end of subdirectoryOnSelect()

// 22/08/2014: save folderstructure action and date
void saveFolderActionDate()
{
	if(selected_subdirectory.equals("")) return;
	adate = kiboo.getDateFromDatebox( f_actiondate );
	atodo = kiboo.replaceSingleQuotes( f_actiontodo.getValue().trim() );
	if(atodo.equals("")) { guihand.showMessageBox("No action, not saving.."); return; }
	sqlstm = "update folderstructure set actiontodo='" + atodo + "', actiondate='" + adate + "' where origid=" + selected_subdirectory;
	dmshand.dmsgpSqlExecuter(sqlstm);
	dmshand.showSubdirectoryTree(maindir_parent, subdirectory_tree); // refresh
	colorizeActionDates();
}

void clearFolderActionDate()
{
	Object[] jkl = { f_actiontodo, f_actiondate };
	ngfun.clearUI_Field(jkl);
}

// Docu sub-directory funcs dispenser
void dirFunc(String itype)
{
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	sqlstm = msgtext = "";
	unm = useraccessobj.username;

	if(itype.equals("saveaction_b"))
	{
		if(selected_subdirectory.equals("")) return;
		adate = kiboo.getDateFromDatebox( f_actiondate );
		atodo = kiboo.replaceSingleQuotes( f_actiontodo.getValue().trim() );
		if(atodo.equals(""))
		{
			msgtext = "No action, not saving..";
			break;
		}
		else
		{
			sqlstm = "update folderstructure set actiontodo='" + atodo + "', actiondate='" + adate + "' where origid=" + selected_subdirectory;
			refresh = true;
		}
	}

	if(itype.equals("insmdir_b"))
	{
		mn = kiboo.replaceSingleQuotes(m_directoryname.getValue().trim());
		ds = kiboo.replaceSingleQuotes(m_description.getValue().trim());
		if(mn.equals("")) return;
		sqlstm = "insert into folderstructure (folderid,datecreated,username,minlevelaccess,deleted,folderparent,folder_desc) values " +
		"('" + mn + "','" + todaydate + "','" + unm + "',1,0," + maindir_parent + ",'" + ds + "')";

		refresh = true;
		m_directoryname.setValue(""); m_description.setValue(""); // clear 'em after insert
	}

	if(itype.equals("inssubdir_b"))
	{
		if(selected_subdirectory.equals("")) return;
		mn = kiboo.replaceSingleQuotes(m_subdirectoryname.getValue().trim());
		ds = kiboo.replaceSingleQuotes(m_subdescription.getValue().trim());
		if(mn.equals("")) return;

		sqlstm = "insert into folderstructure (folderid,datecreated,username,minlevelaccess,deleted,folderparent,folder_desc) values " +
		"('" + mn + "','" + todaydate + "','" + unm + "',1,0," + selected_subdirectory + ",'" + ds + "')";

		refresh = true;
		m_subdirectoryname.setValue(""); m_subdescription.setValue(""); // clear 'em
	}

	if(itype.equals("delmdir_b"))
	{
		if(selected_subdirectory.equals("")) return;

		if( dmshand.directoryExistFiles(selected_subdirectory) )
			msgtext = "ERR: Files exist in this folder.. cannot delete";
		else
		if( dmshand.existBranch(selected_subdirectory) )
			msgtext = "ERR: Sub-folders exist, remove them first";
		else
		{
			if (Messagebox.show("Hard delete this folder", "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

			sqlstm = "delete from folderstructure where origid=" + selected_subdirectory;
			refresh = true;
		}
	}

	if(itype.equals("upddir_b"))
	{
		if(selected_subdirectory.equals("")) return;
		mn = kiboo.replaceSingleQuotes(u_directoryname.getValue().trim());
		ds = kiboo.replaceSingleQuotes(u_description.getValue().trim());
		if(mn.equals("")) return;
		sqlstm = "update folderstructure set folderid='" + mn + "', folder_desc='" + ds + "' where origid=" + selected_subdirectory;
		refresh = true;
	}

	if(itype.equals("markdir_b"))
	{
		if(selected_subdirectory.equals("")) return;
		marked_dir = selected_subdirectory;
		if(prev_sel_treeitem != null && prev_sel_treeitem != selected_treeitem) prev_sel_treeitem.setStyle("text-decoration:none");
		prev_sel_treeitem = selected_treeitem;
		// HARDCODED to get first-cell
		//tcel = selected_treeitem.getChildren().get(0).getChildren().get(0);
		selected_treeitem.setStyle("text-decoration:underline");
	}

	if(itype.equals("movedir_b"))
	{
		if(marked_dir.equals(selected_subdirectory)) return; // same dir-id, nothing to move
		sqlstm = "update folderstructure set folderparent=" + selected_subdirectory + " where origid=" + marked_dir;
		refresh = true;
	}

	if(itype.equals("mvmaindir_b")) // move marked dir to main-trunk
	{
		if(marked_dir.equals("")) return;
		sqlstm = "update folderstructure set folderparent=" + maindir_parent + " where origid=" + marked_dir;
		refresh = true;
	}

	if(!sqlstm.equals("")) dmshand.dmsgpSqlExecuter(sqlstm);
	if(refresh) { dmshand.showSubdirectoryTree(maindir_parent, subdirectory_tree); colorizeActionDates(); }
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

void colorizeActionDates()
{
	kk = subdirectory_tree.getItems().toArray();

	Calendar cal_chks = Calendar.getInstance(); // checking date
	Calendar cal_chke = Calendar.getInstance();
	Date todate = dtf2.parse(dtf2.format(new Date()));

	for(i=0;i<kk.length;i++)
	{
		try
		{
			itr = guihand.getTreecellItem(kk[i],4); // the treecell
			tdt = guihand.getTreecellItemLabel(kk[i],4); // treecell label
			adate = dtf2.parse(tdt);

			if(adate.compareTo(todate) == 0 || adate.compareTo(todate) < 0) // due-date is today or less then today
			{
				itr.setStyle("background:#D51010;font-weight:bold;font-style:italic");
				continue;
			}

			cal_chks.setTime(todate);
			cal_chke.setTime(todate);
			cal_chks.add(Calendar.DAY_OF_MONTH,7);
			cal_chke.add(Calendar.DAY_OF_MONTH,14);

			if( adate.compareTo( cal_chks.getTime() ) >= 0 && adate.compareTo( cal_chke.getTime() ) <= 0 )
			{
				itr.setStyle("background:#ED7D12;font-weight:bold");
				continue;
			}

			cal_chks.add(Calendar.DAY_OF_MONTH,8);
			cal_chke.add(Calendar.DAY_OF_MONTH,16);
			if( adate.compareTo( cal_chks.getTime() ) >= 0 && adate.compareTo( cal_chke.getTime() ) <= 0 )
			{
				itr.setStyle("background:#E1D70E;font-weight:bold");
				continue;
			}
		}
		catch (Exception e) {}
	}
}