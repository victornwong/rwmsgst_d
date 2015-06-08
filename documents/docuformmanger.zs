// Document manager's form management
// Knockoff from gpFormStore but modified to tie-up to folderstructure ID instead of individual ID
// functions dispenser in documan2_funcs.zs : doDocuForm(), some funcs req JN_linkcode()

flag1_fieldname = flag2_fieldname = "";
glob_selected_form = glob_selected_form_user = "";
last_list_type = 0;

// Docu-linked forms functions dispenser
void doDocuForm(int itype)
{
	boolean refresh = false;
	todate =  kiboo.todayISODateTimeString();
	sqlstm = msgtext = "";

	switch(itype)
	{
		case 1: // save docu-linked form
			if(glob_selected_form.equals("")) return;
			if(glob_formmaker == null) return;

			fmtitl = kiboo.replaceSingleQuotes(form_title_tb.getValue().trim());
			freezv = glob_formmaker.freezeFormValues();

			sqlstm = "update elb_formstorage set form_title='" + fmtitl + "', lastupdate='" + todate + "', " +
			"updateby='" + useraccessobj.username + "'," +
			"inputs_value='" + freezv + "' where origid=" + glob_selected_form;

			refresh = true;

			break;

		case 2: // delete docu-linked form
			if(glob_selected_form.equals("")) return;
			if(!glob_selected_form_user.equals(useraccessobj.username))
			{
				msgtext = "You are not the owner, cannot delete..";
				break;
			}
			else
			{
				if(Messagebox.show("Hard delete this form and data", "Are you sure?",
					Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

				sqlstm = "delete from elb_formstorage where origid=" + glob_selected_form;
				refresh = true;
			}
			break;

		case 3: // add a new docu-linked form
			if(selected_subdirectory.equals("")) return;
			if( !lbhand.check_ListboxExist_SelectItem(xmlfmholder,"xlformslb") ) return;
			isel = xlformslb.getSelectedItem(); 
			kk = lbhand.getListcellItemLabel(isel,0);
			formname = lbhand.getListcellItemLabel(isel,1);
			insertFormTypeToFolderstruct( JN_linkcode(), kk, formname );
			formselect_pop.close();
			refresh = true;
			break;
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	if(refresh) listFormStorage(2, JN_linkcode());
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

Object getFormStorage_rec(String iwhat)
{
	sqlstm = "select * from elb_formstorage where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

void showDocuFormsList()
{
	if(selected_subdirectory.equals("")) return;
	listFormStorage(2, JN_linkcode());
}

void showFormStorageMetadata(String iwhat) // knockoff gpformstore.zul
{
	fstrec = getFormStorage_rec(iwhat);
	if(fstrec == null) return;

	fkepid = fstrec.get("formkeeper_id");

	// load form-xml from formkeeper
	fmobj = sqlhand.getFormKeeper_rec(fkepid.toString());
	if(fmobj == null) { gui.showMessageBox("ERR: Cannot load XML-form definitions"); return; }

	formxml = sqlhand.clobToString(fmobj.get("xmlformstring"));
	glob_formmaker = new vicFormMaker(mainform_holder,"NEXTGFORM",formxml);
	glob_formmaker.generateForm();

	forminputs = sqlhand.clobToString(fstrec.get("inputs_value"));
	if(forminputs != null) glob_formmaker.populateFormValues(forminputs);

	form_workarea.setVisible(true); // documanager_v2.zul
}

class formsstorage_onSelect implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = forms_lb.getSelectedItem();
		glob_selected_form = lbhand.getListcellItemLabel(isel,0);
		glob_selected_form_user = lbhand.getListcellItemLabel(isel,3);
		showFormStorageMetadata(glob_selected_form);

		formdesc = lbhand.getListcellItemLabel(isel,2);
		form_title_tb.setValue(formdesc); // form-title textbox
		form_origid.setValue(glob_selected_form);
	}
}
fmclicker = new formsstorage_onSelect();

// knockoff from gpformstorage. modified
// itype: 1=just load, 2=search text
void listFormStorage(int itype, String iformid)
{
Object[] formslist_headers =
{
	new listboxHeaderWidthObj("ID#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Form.Description",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("FLAG1",true,"70px"),
	new listboxHeaderWidthObj("FLAG2",true,"70px"),
};

	last_list_type = itype;
	Listbox newlb = lbhand.makeVWListbox_Width(formslist_holder, formslist_headers, "forms_lb", 20);
	setxt = kiboo.replaceSingleQuotes(searchtext_tb.getValue());

	inp = "";
	chkinps = false;
	if(!flag1_fieldname.equals("") || !flag2_fieldname.equals(""))
	{
		inp = ",inputs_value";
		chkinps = true;
	}

	sqlstm = "select origid,form_title,updateby,lastupdate" + inp + " from elb_formstorage " +
	"where formparent_id='" +  iformid + "'";

	if(itype == 2) sqlstm += " and (inputs_value like '%" + setxt + "%' or form_title like '%" + setxt + "%') ";
	sqlstm += " order by origid desc";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", fmclicker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "lastupdate", "form_title", "updateby" };
	for(dpi : screcs)
	{
		ngfun.popuListitems_Data(kabom,fl,dpi);
		if(chkinps) // need to put extra FLAG fields to list
		{
			if(dpi.get("inputs_value") != null)
			{
				inps = sqlhand.clobToString(dpi.get("inputs_value"));
				irecs = inps.split("::");
				f1s = f2s = "";
				try {
					for(int i=0; i<irecs.length; i++)
					{
						tmpstr = irecs[i];
						iparts = tmpstr.split("\\|"); // split the field and data parts
						fieldpart = iparts[0].replace("\"","");
						datapart = iparts[1].replace("\"","");
						if(fieldpart.equals(flag1_fieldname)) f1s = datapart;
						if(fieldpart.equals(flag2_fieldname)) f2s = datapart;
					}
				} catch (Exception e) {}
				kabom.add(f1s);
				kabom.add(f2s);
			}
		}
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// param_formgroupi defined in documanager_v2.zul
void populateFormsList(Div idiv, String lbid)
{
Object[] formslist_headers = 
{
	new listboxHeaderWidthObj("No.",true,"40px"),
	new listboxHeaderWidthObj("Form",true,""),
	new listboxHeaderWidthObj("User",true,""),
};
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, formslist_headers, lbid, 20);
	sqlstm = "select origid,form_name,created_by from elb_formkeeper where groupi='" + param_formgroupi + "' order by origid desc";
	//debugbox.setValue(sqlstm);
	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", fmlisclik );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid","form_name","created_by" };
	for(d : screcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void insertFormTypeToFolderstruct(String ijn, String iformid, String iformname)
{
	todate =  kiboo.todayISODateTimeString();

	sqlstm = "insert into elb_formstorage (formparent_id,inputs_value,formkeeper_id,form_title,lastupdate,updateby,thisform_parent) values " +
	" ('" + ijn + "',''," + iformid + ",'" + iformname + " #" + iformid + "','" + todate + "','" +
	useraccessobj.username + "',0)";

	sqlhand.gpSqlExecuter(sqlstm);

	//alert(ijn + " :: " + iformid + " :: " + sqlstm);
}
