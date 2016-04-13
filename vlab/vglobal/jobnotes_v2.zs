/**
 * Job-notes handling function - new version
 * @author Victor Wong
 * @since 13/04/2016
 *
 */

JN_holder = null;
JN_listboxid = JN_linkcode = "";
selected_jn_id = selected_jn_user = "";

void jobNoteFunc(Object iwhat, String ilnkc, String inotes)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false; msgtext = sqlstm = "";

	if(itype.equals("deletejobn_b") && !ilnkc.equals(""))
	{
		if(selected_jn_id.equals("")) return;
		if(!selected_jn_user.equals(useraccessobj.username) && useraccessobj.accesslevel != 9)
			msgtext = "Not owner, cannot delete post..";
		else
		{
			if (Messagebox.show("Delete this post..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			sqlstm = "delete from jobnotes where origid=" + selected_jn_id;
			refresh = true;
		}
	}

	if(itype.equals("clearjobn_b"))
	{
		jn_towho.setValue("");
		jn_subject.setValue("");
		jn_msgbody.setValue("");
	}

	if(itype.equals("postjobn_b") && !ilnkc.equals(""))
	{
		if(ilnkc.equals("")) return;

		tw = kiboo.replaceSingleQuotes(jn_towho.getValue().trim());
		sj = kiboo.replaceSingleQuotes(jn_subject.getValue().trim());
		mb = kiboo.replaceSingleQuotes(jn_msgbody.getValue().trim());

		if(sj.equals("") || mb.equals("")) msgtext = "Jobnotes: Do enter something before posting..";
		else
		{
			sqlstm = "insert into jobnotes (datecreated,username,towho,subject,msgbody,linking_code,linking_sub) values " +
			"('" + todaydate + "','" + useraccessobj.username + "','" + tw + "','" + sj + "','" + mb + "'," +
			"'" + ilnkc + "','')";
			refresh = true;
		}
	}

	if(itype.equals("addjobnote_b") && !ilnkc.equals(""))
	{
		if(inotes.equals("")) return;
		sqlstm = "insert into jobnotes (datecreated,username,towho,subject,msgbody,linking_code,linking_sub) values " +
		"('" + todaydate + "','" + useraccessobj.username + "','','" + inotes + "',''," +
		"'" + ilnkc + "','')";
		refresh = true;
	}

	if(!sqlstm.equals("")) vsql_execute(sqlstm);
	if(refresh) showJobNotes(JN_linkcode,JN_holder,JN_listboxid); // uses prev saved vars
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

Object getJobNote_rec(String iwhat)
{
	sqlstm = "select * from rw_jobnotes where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm); 
}

/**
 * Job-note listbox click listener
 */
class jnClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		jobnote_onSelect_callBack(event.getReference());
		/*
			selected_jn_id = lbhand.getListcellItemLabel(isel,0);
			selected_jn_user = lbhand.getListcellItemLabel(isel,2);

			kr = getJobNote_rec(selected_jn_id);
			if(kr != null)
			{
				//jn_towho.setValue(
				jn_subject.setValue( "RE: " + kiboo.checkNullString(kr.get("subject")) );
				kmb = ">" + kiboo.checkNullString(kr.get("msgbody")).replaceAll("\n","\n>");
				jn_msgbody.setValue(kmb);
			}
		*/
	}
}
jnclidker = new jnClick();

/**
 * [showJobNotes description]
 * @param ilnkc     linking-code for job-note
 * @param ijnholder job-notes holder
 * @param ijnlbid   job-notes listbox id
 */
void showJobNotes(String ilnkc, Div ijnholder, String ijnlbid)
{
	Object[] jnlb_hds =
	{
		new listboxHeaderWidthObj("oid",false,""),
		new listboxHeaderWidthObj("Dated",true,"60px"),
		new listboxHeaderWidthObj("User",true,"60px"),
		new listboxHeaderWidthObj("Subject",true,""),
	};
	JN_holder = ijnholder; JN_listboxid = ijnlbid; JN_linkcode = ilnkc; // save for later use

	selected_jn_id = selected_jn_user = ""; // reset each time
	//jn_towho.setValue(""); jn_subject.setValue(""); jn_msgbody.setValue("");

	Listbox newlb = lbhand.makeVWListbox_Width(ijnholder, jnlb_hds, ijnlbid, 5);
	sqlstm = "select origid,datecreated,username,subject from jobnotes where linking_code='" + ilnkc + "'";
	rcs = vsql_GetRows(sqlstm); if(rcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", jnclidker);
	ArrayList kabom = new ArrayList();
	for(dpi : rcs)
	{
		kabom.add( dpi.get("origid").toString() );
		kabom.add( kiboo.dtf.format(dpi.get("datecreated")) );
		kabom.add( kiboo.checkNullString(dpi.get("username")) );
		kabom.add( kiboo.checkNullString(dpi.get("subject")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}
