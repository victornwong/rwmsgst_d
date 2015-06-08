import java.lang.Float;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import java.math.BigDecimal;
import org.zkoss.util.media.AMedia;

// Documents manager related funcs -- knockoff from uploadDocu_v1.zs

selected_file_id = selected_file_owner = "";

class doculinks_lb_onSelect_DM implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getReference();
		selected_file_id = lbhand.getListcellItemLabel(selitem,0);
		selected_file_owner = lbhand.getListcellItemLabel(selitem,4);
		//updatefiledesc_label.setLabel(lbhand.getListcellItemLabel(selitem,1));
		//update_file_description.setValue(lbhand.getListcellItemLabel(selitem,2));
	}
}
doculbcliker = new doculinks_lb_onSelect_DM();

void fillDocumentsList_DM(String iprefix, String iwhat, Div idiv, String ilbid)
{
	Object[] documentLinks_lb_headers = {
	new dblb_HeaderObj("origid",false,"origid",2),
	new dblb_HeaderObj("File",true,"file_title",1),
	new dblb_HeaderObj("Description",true,"file_description",1),
	new dblb_HeaderObj("Dated",true,"datecreated",3),
	new dblb_HeaderObj("Owner",true,"username",1),
	};

	selected_file_id = ""; // reset
	duclink = iprefix + iwhat;

	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	sqlstm = "select origid,file_title,datecreated,username,file_description from DocumentTable " +
	"where docu_link='" + duclink + "' and deleted=0";

	if(useraccessobj.accesslevel == 9) // admin can see everything..
	{
		sqlstm = "select origid,file_title,file_description,datecreated,username from DocumentTable " +
		"where docu_link='" + duclink + "' ";
	}

	Listbox newlb = lbhand.makeVWListbox_onDB(idiv,documentLinks_lb_headers,ilbid,10,ds_sql,sqlstm);
	newlb.addEventListener("onSelect", doculbcliker);
	ds_sql.close();
}

void docuFunc_DM(String itype)
{
	refresh = false;
	unm = useraccessobj.username;

	if(itype.equals("uploaddoc_btn"))
	{
		if(selected_subdirectory.equals("")) return;
		doculink_str = DOCUPREFIX + selected_subdirectory;
		docustatus_str = "ACTIVE";
		ftitle = kiboo.replaceSingleQuotes(fileupl_file_title.getValue().trim());
		fdesc = kiboo.replaceSingleQuotes(fileupl_file_description.getValue().trim());

		if(ftitle.equals("")) { guihand.showMessageBox("Please enter a filename.."); return; }

		dmshand.uploadFile(useraccessobj.username, useraccessobj.branch, kiboo.todayISODateString(),doculink_str,docustatus_str,ftitle,fdesc);
		refresh = true;
	}

	if(itype.equals("deletedoc_btn"))
	{
		if(selected_file_id.equals("")) return;
		if(!selected_file_owner.equals(unm))
		{
			if(!unm.equals("padmin")) // padmin can delete other user's file
			{
				guihand.showMessageBox("ERR: cannot delete, you're not the owner..");
				return;
			}
		}

		if (Messagebox.show("This is a hard-delete..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		sqlstm = "delete from DocumentTable where origid=" + selected_file_id;
		dmshand.dmsgpSqlExecuter(sqlstm);
		refresh = true;
	}

	if(itype.equals("editdoc_btn"))
	{
		fdesc = kiboo.replaceSingleQuotes(update_file_description.getValue().trim());
		sqlstm = "update DocumentTable set file_description='" + fdesc + "' where origid=" + selected_file_id;
		dmshand.dmsgpSqlExecuter(sqlstm);
		refresh = true;
	}

	if(itype.equals("viewdoc_btn"))
	{
		if(selected_file_id.equals("")) return; // selected_file_id set in doculinks_lb_onSelect_DM()
		viewTheDocument_DM(viewdoc_div, selected_file_id);
	}

	if(itype.equals("viewdocfile_btn"))
	{
		if(selected_file_id.equals("")) return;
		theparam = "docid=" + selected_file_id;
		uniqid = kiboo.makeRandomId("vf");
		guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile.zul", uniqid, theparam, useraccessobj);
	}

	if(refresh) fillDocumentsList_DM(DOCUPREFIX, selected_subdirectory, docu_holder, "docus_lb");
}

// knockoff from viewfile.zul - show document inline, no need to run external window
void viewTheDocument_DM(Div iparentdiv, String docid)
{
	if(iparentdiv.getFellowIfAny("viewframe_id") != null) viewframe_id.setParent(null);

	Iframe newiframe = new Iframe();
	newiframe.setWidth("100%"); newiframe.setHeight("600px");
	newiframe.setId("viewframe_id");

	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	sqlst = "select * from DocumentTable where origid=" + docid;
	krec = ds_sql.firstRow(sqlst);
	ds_sql.close();

	kfilename = krec.get("file_name");
	ktype = krec.get("file_type");
	kexten = krec.get("file_extension");
	kblob = krec.get("file_data");
	kbarray = kblob.getBytes(1,(int)kblob.length());

	docutitle_lbl.setValue(":: " + krec.get("file_title") );
	docudesc_lbl.setValue( kiboo.checkNullString(krec.get("file_description")) );

	AMedia am_doc = new AMedia(kfilename, kexten, ktype, kbarray);
	newiframe.setContent(am_doc);
	newiframe.setParent(iparentdiv);
}

// view-document in-DIV, multiple docs can be loaded
void viewTheDocument_DM_mini(Div iparentdiv, String docid, String iwidth, String iheight)
{
	Iframe newiframe = new Iframe();
	newiframe.setWidth(iwidth); newiframe.setHeight(iheight);

	ds_sql = sqlhand.DMS_Sql();
	if(ds_sql == null) return;
	sqlst = "select * from DocumentTable where origid=" + docid;
	krec = ds_sql.firstRow(sqlst);
	ds_sql.close();

	kfilename = krec.get("file_name");
	ktype = krec.get("file_type");
	kexten = krec.get("file_extension");
	kblob = krec.get("file_data");
	kbarray = kblob.getBytes(1,(int)kblob.length());

	AMedia am_doc = new AMedia(kfilename, kexten, ktype, kbarray);
	newiframe.setContent(am_doc);
	newiframe.setParent(iparentdiv);
}

// ENDOF Documents related funcs -- knockoff from uploadDocu_v1.zs
