//---- docu/attachments uploading funcs

selected_file_id = ""; // global for attach-docu origid

// onSelect for filleDocumentsList()
class doculinks_lb_onSelect implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getReference();
		selected_file_id = lbhand.getListcellItemLabel(selitem,0);
		updatefiledesc_label.setLabel(lbhand.getListcellItemLabel(selitem,1));
		update_file_description.setValue(lbhand.getListcellItemLabel(selitem,2));
	}
}
docuclik = new doculinks_lb_onSelect();

void fillDocumentsList(Div idiv, String iprefix, String iorigid)
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
	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	incdel = " and deleted=0";
	if(useraccessobj.accesslevel == 9) incdel = ""; // admin can see everything..
	sqlstm = "select origid,file_title,file_description,datecreated,username from DocumentTable " +
	"where docu_link='" + duclink + "'" + incdel;
	Listbox newlb = lbhand.makeVWListbox_onDB(idiv,documentLinks_lb_headers,"doculinks_lb",15,ds_sql,sqlstm);
	//newlb.setMultiple(true);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", docuclik);
	ds_sql.close();
	//if(newlb.getItemCount() > 5) newlb.setRows(10);
}

void fillDocumentsList_2(Div idiv, String iprefix, String iorigid)
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
	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	incdel = " and deleted=0";
	if(useraccessobj.accesslevel == 9) incdel = ""; // admin can see everything..
	sqlstm = "select origid,file_title,file_description,datecreated,username from DocumentTable " +
	"where docu_link='" + duclink + "'" + incdel;
	Listbox newlb = lbhand.makeVWListbox_onDB(idiv,documentLinks_lb_headers,"doculinks_lb",15,ds_sql,sqlstm);
	newlb.setMultiple(true);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", docuclik);
	ds_sql.close();
	//if(newlb.getItemCount() > 5) newlb.setRows(10);
}

void uploadFile(Div idiv, String iprefix, String idocudx)
{
	if(idocudx.equals("")) return;
	doculink_str = iprefix + idocudx;
	docustatus_str = "ACTIVE";
	ftitle = kiboo.replaceSingleQuotes(fileupl_file_title.getValue());
	fdesc = kiboo.replaceSingleQuotes(fileupl_file_description.getValue());
	if(ftitle.equals(""))
	{
		guihand.showMessageBox("Please enter a filename..");
		return;
	}
	dmshand.uploadFile(useraccessobj.username, useraccessobj.branch, kiboo.todayISODateString(),
		doculink_str,docustatus_str,ftitle,fdesc); // dmsfuncs.zs
	fillDocumentsList(idiv,iprefix,idocudx);
	uploadfile_popup.close();
}

void showUploadPopup(String iprefix, String idocudx)
{
	if(idocudx.equals("")) return;
	uploadfile_popup.open(uploaddoc_btn);
}

void viewFile()
{
	if(selected_file_id.equals("")) return;
	theparam = "docid=" + selected_file_id;
	uniqid = kiboo.makeRandomId("vf");
	guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile.zul", uniqid, theparam, useraccessobj);
}

void deleteFile(Div idiv, String iprefix, String idocudx)
{
	if(selected_file_id.equals("")) return;
	if(useraccessobj.accesslevel < 9) { guihand.showMessageBox("Only admin can do hard-delete"); return; }

	if (Messagebox.show("This is a hard-delete..", "Are you sure?", 
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

	sqlstm = "delete from DocumentTable where origid=" + selected_file_id;
	dmshand.dmsgpSqlExecuter(sqlstm);
	fillDocumentsList(idiv,iprefix,idocudx); // refresh
}

void updateFileDescription(Div idiv, String iprefix, String idocudx)
{
	fdesc = kiboo.replaceSingleQuotes(update_file_description.getValue());
	sqlstm = "update DocumentTable set file_description='" + fdesc + "' where origid=" + selected_file_id;
	dmshand.dmsgpSqlExecuter(sqlstm);
	fillDocumentsList(idiv,iprefix,idocudx); // refresh
	updatefiledesc_popup.close();
}

// 14/11/2013: Save local file into DMS table - codes knockoff from DMSFuncs.java
void saveFileToDMS(String ilnkc, String ifilename, String ifullpath, String ifiletype, String ifileext)
{
	Sql ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return false;

	File file = new File(ifullpath);
	fis = new FileInputStream(file);
	fileLength = fis.available();

	java.sql.Connection thecon = ds_sql.getConnection();

	java.sql.PreparedStatement pstmt = thecon.prepareStatement(
	"insert into DocumentTable(file_title,file_description,docu_link,docu_status,username,datecreated,version," +
	"file_name,file_type,file_extension,file_data,deleted,branch) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");

	pstmt.setString(1, ifilename);
	pstmt.setString(2, "Processed SOA storage");
	pstmt.setString(3, ilnkc);
	pstmt.setString(4, "ACTIVE");
	pstmt.setString(5, useraccessobj.username);
	pstmt.setString(6, kiboo.todayISODateString() );
	pstmt.setInt(7,1);
	pstmt.setString(8, ifilename);
	pstmt.setString(9, ifiletype);
	pstmt.setString(10,ifileext);
	pstmt.setBinaryStream(11, (InputStream)fis, fileLength);
	pstmt.setInt(12,0); // deleted flag
	pstmt.setString(13, "HQ");

	pstmt.executeUpdate();
	ds_sql.close();
}

