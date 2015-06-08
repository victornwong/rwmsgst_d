import org.victor.*;

/*******
Job-notes related funcs -- can be used in other mods, remember put <div> and some required call-back

JN_linkcode() <--- to be def in calling module

	<div style="background:#555753; -moz-box-shadow: 4px 5px 7px #000000; -webkit-box-shadow: 4px 5px 7px #000000;
	box-shadow: 4px 5px 7px #000000;padding:3px;margin:3px" width="420px" id="jobnotes_div" visible="false" >
		<label sclass="subhead">JOB NOTES</label>
		<separator height="3px" />
		<div id="jobnotes_holder" />
		<separator height="2px" />
		<hbox>
			<button id="deletejobn_b" label="Delete" style="font-size:9px;font-weight:bold"
				onClick="jobNoteFunc(self,JN_linkcode())" />
		</hbox>
		<separator height="2px" />
		<div id="jobnotes_entry_holder">
			<grid>
				<rows>
					<row visible="false">
						<label value="To" style="font-size:9px" />
						<textbox id="jn_towho" width="99%" style="font-weight:bold" />
					</row>
					<row>
						<label value="Subject" style="font-size:9px" />
						<textbox id="jn_subject" width="99%" style="font-weight:bold" />
					</row>
					<row>
						<label value="Notes" style="font-size:9px" />
						<textbox id="jn_msgbody" width="99%" multiline="true" height="60px" />
					</row>
				</rows>
			</grid>
			<separator height="2px" />
			<button id="postjobn_b" label="Post" style="font-weight:bold" onClick="jobNoteFunc(self,JN_linkcode())" />
		</div>
	</div>
********/

// Job-notes var to store last things passed to showJobNotes()
JN_holder = null;
JN_listboxid = JN_linkcode = "";
selected_jn_id = selected_jn_user = "";

void jobNoteFunc(Object iwhat, String ilnkc)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	msgtext = sqlstm = "";

	if(itype.equals("deletejobn_b"))
	{
		if(selected_jn_id.equals("")) return;
		if(!selected_jn_user.equals(useraccessobj.username) && useraccessobj.accesslevel != 9)
			msgtext = "Not owner, cannot delete post..";
		else
		{
			if (Messagebox.show("Delete this post..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			sqlstm = "delete from rw_jobnotes where origid=" + selected_jn_id;
			refresh = true;
		}
	}

	if(itype.equals("clearjobn_b"))
	{
		jn_towho.setValue("");
		jn_subject.setValue("");
		jn_msgbody.setValue("");
	}

	if(itype.equals("postjobn_b"))
	{
		if(ilnkc.equals("")) return;

		tw = kiboo.replaceSingleQuotes(jn_towho.getValue().trim());
		sj = kiboo.replaceSingleQuotes(jn_subject.getValue().trim());
		mb = kiboo.replaceSingleQuotes(jn_msgbody.getValue().trim());

		if(sj.equals("") || mb.equals("")) msgtext = "Jobnotes: Do enter something before posting..";
		else
		{
			sqlstm = "insert into rw_jobnotes (datecreated,username,towho,subject,msgbody,linking_code,linking_sub) values " +
			"('" + todaydate + "','" + useraccessobj.username + "','" + tw + "','" + sj + "','" + mb + "'," +
			"'" + ilnkc + "','')";

			refresh = true;
		}
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
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
		isel = event.getReference();
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
		new listboxHeaderWidthObj("oid",false,"1px"),
		new listboxHeaderWidthObj("Dated",true,"60px"),
		new listboxHeaderWidthObj("User",true,"60px"),
		new listboxHeaderWidthObj("Subject",true,""),
	};
	JN_holder = ijnholder; // save for later use
	JN_listboxid = ijnlbid;
	JN_linkcode = ilnkc;

	selected_jn_id = selected_jn_user = ""; // reset each time
	jn_towho.setValue("");
	jn_subject.setValue("");
	jn_msgbody.setValue("");

	Listbox newlb = lbhand.makeVWListbox_Width(ijnholder, jnlb_hds, ijnlbid, 5);
	sqlstm = "select origid,datecreated,username,subject from rw_jobnotes where linking_code='" + ilnkc + "'";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", jnclidker);
	SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
	ArrayList kabom = new ArrayList();
	for(dpi : rcs)
	{
		kabom.add( dpi.get("origid").toString() );
		kabom.add( dtf2.format(dpi.get("datecreated")) );
		kabom.add( kiboo.checkNullString(dpi.get("username")) );
		kabom.add( kiboo.checkNullString(dpi.get("subject")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}


