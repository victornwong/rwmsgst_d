/*
@Title LC assets replacement tracker - RMA things
@Author Victor Wong
@Since 29/08/2014
*/
lcrp_selected = lcrp_selected_user = last_trk_lbid = last_fc6_code = "";
last_lb_holder = last_trk_rec = null;
lc_manager_flag = 0; // set 1 in contractbillingtrack.zul, when refresh LB will check this flag

Object getLCReplace_track_rec(String iwhat)
{
	sqlstm = "select * from rw_lc_replacements where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

void lcrepDo(String itype, String ifc6)
{
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	sqlstm = msgtext = "";
	unm = useraccessobj.username;
	Object[] jkl = { v_lc_id, v_in_assettag, v_out_assettag, v_action, v_act_date};

	if(itype.equals("updlcrep_b"))
	{
		if( ifc6 == null ) return;
		if( ifc6.equals("")) return;
		dt = ngfun.getString_fromUI(jkl);

		if(lcrp_selected.equals("")) // new insert
		{
			sqlstm = "insert into rw_lc_replacements (fc6_custid,username,lc_id,in_assettag,out_assettag,action,act_date) values " +
			"('" + ifc6 + "','" + unm + "','" + dt[0] + "','" + dt[1] + "','" + dt[2] + "','" + dt[3] + "','" + dt[4] + "')";
			ngfun.clearUI_Field(jkl);
		}
		else
		{
			sqlstm = "update rw_lc_replacements set lc_id='" + dt[0] + "',in_assettag='" + dt[1] + "',out_assettag='" + dt[2] + "'," +
			"action='" + dt[3] + "', act_date='" + dt[4] + "' where origid=" + lcrp_selected;
		}
	}

	if(itype.equals("remlcrep_b")) // delete LC-replacement track
	{
		alert("mememe");
		if(lcrp_selected.equals("")) return;
		if(!lcrp_selected_user.equals(unm)) msgtext = "Sorry, you're not the owner of this record";
		else
		{
			if(Messagebox.show("Remove this LC-replacement track record..", "Are you sure?", 
				Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			sqlstm = "delete from rw_lc_replacements where origid=" + lcrp_selected;
		}
	}

	if(itype.equals("updrec_b")) // rw_lc_replacements.record_up , for BA to mark replacements done in LC-rec
	{
		if(lcrp_selected.equals("")) return;
		sqlstm = "update rw_lc_replacements set record_up=1, update_user='" + unm + "' where origid=" + lcrp_selected;
	}

	if(itype.equals("clrlcrep_b"))
	{
		ngfun.clearUI_Field(jkl);
		lcrp_selected = "";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		if(lc_manager_flag == 1)
			showLCAss_RepTrack_2(last_trk_rec, last_lb_holder, last_trk_lbid, last_fc6_code);
		else
			showLCAss_RepTrack(last_trk_rec,last_lb_holder,last_trk_lbid);
	}
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

void showLCRep_metadata(String iwhat)
{
	r = getLCReplace_track_rec(iwhat);
	if(r == null) return;
	Object[] jkl = { v_lc_id, v_in_assettag, v_out_assettag, v_act_date, v_action };
	String[] fl = { "lc_id", "in_assettag", "out_assettag", "act_date", "action" };
	ngfun.populateUI_Data(jkl,fl,r);
}

Object[] lcasrephds = 
{
	new listboxHeaderWidthObj("LC.Id",true,"90px"),
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("I.Asset",true,"60px"),
	new listboxHeaderWidthObj("Replace",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("RECUp",true,"40px"), // 5 to be updated by BA
	new listboxHeaderWidthObj("GCO",true,"40px"),
	new listboxHeaderWidthObj("G.Stat",true,"50px"),
	new listboxHeaderWidthObj("Act",true,""),
	new listboxHeaderWidthObj("A.Date",true,"70px"),
};
LCIDPOS = 0;
ORIGPOS = 1;
INRECASSET = 2;
GCOPOS = 6;

class lcasrepClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		isel = event.getReference();
		lcrp_selected = lbhand.getListcellItemLabel(isel,ORIGPOS);
		lcrp_selected_user = lbhand.getListcellItemLabel(isel,4);
		showLCRep_metadata(lcrp_selected);
		} catch (Exception e) {}
	}
}
lcassrepcliker = new lcasrepClick();

void showLCAss_RepTrack(Object itkr, Div idiv, String lbid)
{
	last_trk_lbid = lbid; last_trk_rec = itkr; last_lb_holder = idiv;

	Listbox newlb = lbhand.makeVWListbox_Width(idiv, lcasrephds, lbid, 3);
	fc6 = itkr.get("fc6_custid");
	if(fc6 == null) return;

	sqlstm = "select *, (select status from rw_goodscollection where CONVERT(varchar(10),origid)=rlr.gco_id) as gstat from rw_lc_replacements rlr where fc6_custid='" + fc6 + "' order by origid desc";
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.setMultiple(true); newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", lcassrepcliker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "lc_id","origid","in_assettag","out_assettag","username","record_up","gco_id","gstat", "action","act_date" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// Use in LC manager
void showLCAss_RepTrack_2(Object itkr, Div idiv, String lbid, String ifc6)
{
	last_trk_lbid = lbid; last_trk_rec = itkr; last_lb_holder = idiv; last_fc6_code = ifc6;

	Listbox newlb = lbhand.makeVWListbox_Width(idiv, lcasrephds, lbid, 3);
	//fc6 = itkr.get("fc6_custid");
	//if(fc6 == null) return;

	sqlstm = "select *, (select status from rw_goodscollection where CONVERT(varchar(10),origid)=rlr.gco_id) as gstat from rw_lc_replacements rlr ";
	if(!ifc6.equals(""))
		sqlstm += "where fc6_custid='" + ifc6 + "' ";
	else // if no fc6 code, list non-updated replacements
		sqlstm += "where (record_up is null or record_up=0) ";

	sqlstm += "order by origid desc";

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging");
	newlb.setMultiple(true); newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", lcassrepcliker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "lc_id","origid","in_assettag","out_assettag","username","record_up","gco_id","gstat", "action","act_date" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// general purpose to check if LC-replacement LB got selections and etc..
Component checkLCRep_LB_things()
{
	tlb = last_lb_holder.getFellowIfAny(last_trk_lbid);
	if(tlb == null) return null;
	if(tlb.getSelectedCount() == 0) return null;
	if(glob_selected_ticket.equals("")) return null;
	return tlb;
}

// LC-replacements GCO-transient functions
void lcreplaceDo(String itype)
{
	tlb = checkLCRep_LB_things();
	if(tlb == null) return;
	if(global_selected_customerid.equals("")) { guihand.showMessageBox("ERR: customer ID not assigned"); return; }

	sqlstm = msgtext = "";

	for(d : tlb.getSelectedItems())
	{
		atg = lbhand.getListcellItemLabel(d,INRECASSET);
		lci = lbhand.getListcellItemLabel(d,LCIDPOS);
		if(atg.equals("")) continue;
		gcni = lbhand.getListcellItemLabel(d,GCOPOS);
		ori = lbhand.getListcellItemLabel(d,ORIGPOS);

		if(itype.equals("rplcsave_b")) // save LC-replace assets to transient-GCO
		{
			if(gcni.equals("") || gcni.equals("0")) // gcn-id must be blank to be saved in transient-table
			{
				kk = "";
				try { kk = glob_selected_ticket; } catch (Exception e) {}
				sqlstm += "insert into rw_gcn_transient (lc_id,serial_no,asset_tag,item_desc,fc6_custid,csv_id) values " +
				"('" + lci + "','','" + atg + "','','" + global_selected_customerid + "','" + kk + "');";
			}
		}

		if(itype.equals("rpclrgco_b")) // clear from transient-GCO
		{
			if(gcni.equals("") || gcni.equals("0")) continue;
			else
			{
				if (Messagebox.show("Remove selected from GCO-transient..", "Are you sure?", 
					Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

				sqlstm += "update rw_gcn_transient set gcn_id=null where lc_id='" + lci + "' " +
				"and asset_tag='" + atg + "' and fc6_custid='" + global_selected_customerid + "';";

				sqlstm += "update rw_lc_replacements set gco_id=null where origid=" + ori + ";";
			}
		}
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		if(itype.equals("rplcsave_b")) msgtext = "Assets saved for GCO-transient";
		if(itype.equals("rpclrgco_b")) msgtext = "Assets cleared from GCO-transient";
		showLCAss_RepTrack(last_trk_rec,last_lb_holder,last_trk_lbid);
	}
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

