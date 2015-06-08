
//---- File uploading funcs : written by Victor Wong
// Can be included in other mods - check ui-components and global-vars used ..
// document-prefix: iprefix in most func
// parent origid: iorigid
// **Updates**
// 06/09/2012: ONHOLD: add a DB indentifier for AdminDocuments or DocumentStorage selection

selected_file_id = ""; // global for attach-docu origid

// onSelect for filleDocumentsList()
class doculinks_lb_onSelect implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = doculinks_lb.getSelectedItem();
		selected_file_id = lbhand.getListcellItemLabel(selitem,0);

		updatefiledesc_label.setLabel(lbhand.getListcellItemLabel(selitem,1));
		update_file_description.setValue(lbhand.getListcellItemLabel(selitem,2));
	}
}

// iprefix=prefix for the document, iorigid=document parent id, iwhichdb=which db - 1=DocumentStorage, 2=AdminDocuments
void fillDocumentsList(String iprefix, String iorigid)
{
	Object[] documentLinks_lb_headers = {
	new dblb_HeaderObj("origid",false,"origid",2),
	new dblb_HeaderObj("File",true,"file_title",1),
	new dblb_HeaderObj("Description",true,"file_description",1),
	new dblb_HeaderObj("D.Created",true,"datecreated",3),
	new dblb_HeaderObj("Owner",true,"username",1),
	};

	selected_file_id = ""; // reset
	duclink = iprefix + iorigid;

	//ds_sql = (iwhichdb == 1) ? sqlhand.als_DocumentStorage() : sqlhand.DMS_Sql();
	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	sqlstm = "select origid,file_title,file_description,datecreated,username from DocumentTable " +
	"where docu_link='" + duclink + "' ";

	if(useraccessobj.accesslevel != 9) // non-admin can see only non-deleted files
	{
		sqlstm += "and deleted=0";
		//sqlstm = "select origid,file_title,file_description,datecreated,username from DocumentTable " +
		//"where docu_link='" + duclink + "' ";
	}

	Listbox newlb = lbhand.makeVWListbox_onDB(documents_holder,documentLinks_lb_headers,"doculinks_lb",5,ds_sql,sqlstm);
	//newlb.setMultiple(true);
	newlb.addEventListener("onSelect", new doculinks_lb_onSelect());
	ds_sql.close();

	//if(newlb.getItemCount() > 5) newlb.setRows(10);
}

void uploadFile(String iprefix, String iorigid)
{
	//if(global_selected_job.equals("")) return;
	doculink_str = iprefix + iorigid;
	docustatus_str = "ACTIVE";

	ftitle = kiboo.replaceSingleQuotes(fileupl_file_title.getValue());
	fdesc = kiboo.replaceSingleQuotes(fileupl_file_description.getValue());

	if(ftitle.equals(""))
	{
		guihand.showMessageBox("Please enter a filename..");
		return;
	}

	// dmsfuncs.zs
	dmshand.uploadFile(useraccessobj.username, useraccessobj.branch, kiboo.getDateFromDatebox(hiddendatebox),doculink_str,docustatus_str,ftitle,fdesc);
	fillDocumentsList(iprefix,iorigid);
	uploadfile_popup.close();
}

void showUploadPopup(String iorigid)
{
	if(iorigid.equals("")) return;
	uploadfile_popup.open(uploaddoc_btn);
}

void viewFile()
{
	if(selected_file_id.equals("")) return;
	theparam = "docid=" + selected_file_id;
	uniqid = kiboo.makeRandomId("vf");
	guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile.zul", uniqid, theparam, useraccessobj);
	/*
	if(iwhichdb == 2)
		guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile.zul", uniqid, theparam, useraccessobj);
	else
		guihand.globalActivateWindow(mainPlayground,"miscwindows","qc/viewlinkingdocument.zul", uniqid, theparam, useraccessobj);
	*/
}

void deleteFile(String iprefix, String iorigid)
{
	if(selected_file_id.equals("")) return;

	if (Messagebox.show("This is a hard-delete..", "Are you sure?", 
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) ==  Messagebox.NO) return;

	sqlstm = "delete from DocumentTable where origid=" + selected_file_id;
	dmshand.dmsgpSqlExecuter(sqlstm);
	fillDocumentsList(iprefix,iorigid); // refresh
}

void updateFileDescription(String iprefix, String iorigid)
{
	fdesc = kiboo.replaceSingleQuotes(update_file_description.getValue());
	sqlstm = "update DocumentTable set file_description='" + fdesc + "' where origid=" + selected_file_id;
	dmshand.dmsgpSqlExecuter(sqlstm);
	fillDocumentsList(iprefix, iorigid); // refresh
	updatefiledesc_popup.close();
}

