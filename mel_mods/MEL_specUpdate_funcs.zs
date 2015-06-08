import org.victor.*;
// Funcs used in MEL_specUpdate_v1.zul. Knockoff and modif for MEL

class tbnulldrop implements org.zkoss.zk.ui.event.EventListener
{	public void onEvent(Event event) throws UiException	{} }
textboxnulldrop = new tbnulldrop();

void panel_Close() // main-panel onClose do something
{
	if(!glob_sel_grn.equals("")) // if GRN selected - save 'em specs
	{
		saveSpecs();
	}
}

org.zkoss.zul.Row makeItemRow_specup(Component irows, String iname, String iatg, String isn, String iqty)
{
	k9 = "font-size:9px";
	nrw = new org.zkoss.zul.Row();
	nrw.setParent(irows);
	ngfun.gpMakeCheckbox(nrw,"","","");
	ngfun.gpMakeLabel(nrw,"",iname,k9); // item-name using label

	ngfun.gpMakeLabel(nrw,"",iatg,k9);
	ngfun.gpMakeLabel(nrw,"",isn,k9);

	String[] kabom = new String[1];

	for(k=0;k<specs_fields.length;k++)
	{
		if(specs_field_type[k].equals("lb"))
		{
			klb = new Listbox();
			klb.setMold("select"); klb.setStyle("font-size:9px");
			klb.setParent(nrw);
			for(d : glob_focus6_grades)
			{
				kabom[0] = d.get("grade");
				if(kabom[0] != null) lbhand.insertListItems(klb,kabom,"false","");
			}
			klb.setSelectedIndex(0);
		}
		else
			ngfun.gpMakeTextbox(nrw,"","","font-size:9px","95%",textboxnulldrop);
	}
	return nrw;
}

void show_MELinventory(String iwhat) // get 'em recs from mel_inventory by melgrn_id
{
	if(glob_focus6_grades == null) glob_focus6_grades = getFocus_StockGrades(); // reload if null
	ngfun.checkMakeGrid(scanitems_colws, scanitems_collb, scanitems_holder, "grn_grid", "grn_rows", "", "", false);

	sqlstm = "select * from mel_inventory where melgrn_id=" + iwhat;
	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	for(d : rcs)
	{
		nrw = makeItemRow_specup(grn_rows, d.get("item_desc"), d.get("rw_assettag"), d.get("serial_no"), "1");
		ki = nrw.getChildren().toArray();
		for(k=0;k<MEL_invt_fields.length;k++)
		{
			try
			{
				if(d.get(MEL_invt_fields[k]) != null)
				{
					cix = k + 4;
					if(ki[cix] instanceof Listbox)
						lbhand.matchListboxItems(ki[cix], d.get(MEL_invt_fields[k]) );
					else
						ki[cix].setValue( d.get(MEL_invt_fields[k]) );
				}

			} catch (java.lang.ArrayIndexOutOfBoundsException e) {}
		}
	}

}

void show_MELGRN_meta(String iwhat) // knockoff from MELGRN_funcs.zs but with modif to refer to mel_inventory
{
	melgrn_no.setValue("MELGRN: " + iwhat);
	/*
	r = getMELGRN_rec(iwhat);
	if(r != null)
	{
	}
	*/

	show_MELinventory(iwhat);

	workarea.setVisible(true);
}

Object[] melgrnhds =
{
	new listboxHeaderWidthObj("MELGRN",true,"60px"),
	new listboxHeaderWidthObj("DATED",true,"70px"),
	new listboxHeaderWidthObj("MEL REF",true,"90px"),
	new listboxHeaderWidthObj("CSGN",true,"70px"), // 3
	new listboxHeaderWidthObj("BATCH",true,"70px"),
	new listboxHeaderWidthObj("RWLOCA",true,"70px"),
	new listboxHeaderWidthObj("USER",true,""),
	new listboxHeaderWidthObj("STAT",true,"70px"), // 7
	new listboxHeaderWidthObj("UNKWN",true,""),

	new listboxHeaderWidthObj("COMMIT",true,""),
	new listboxHeaderWidthObj("C.User",true,""),
	new listboxHeaderWidthObj("AUDIT",true,""),
	new listboxHeaderWidthObj("A.User",true,""),
	new listboxHeaderWidthObj("A.Id",true,""),

};
GRNSTAT_POS = 7;
CSGN_POS = 3;
BATCH_POS = 4;
UNKNOWN_POS = 8;

class grnclicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_grn = lbhand.getListcellItemLabel(isel,0);
		glob_sel_stat = lbhand.getListcellItemLabel(isel,GRNSTAT_POS);
		glob_sel_parentcsgn = lbhand.getListcellItemLabel(isel,CSGN_POS);
		glob_sel_batchno = lbhand.getListcellItemLabel(isel,BATCH_POS);
		glob_sel_unknown = lbhand.getListcellItemLabel(isel,UNKNOWN_POS);

		show_MELGRN_meta(glob_sel_grn);

		//if(grn_show_meta) showGRN_meta(glob_sel_grn);
		//grn_Selected_Callback();
	}
}
grnclik = new grnclicker();

void show_MELGRN(int itype) // knockoff from MELGRN_funcs.zs
{
	last_showgrn_type = itype;
	sct = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	jid = kiboo.replaceSingleQuotes(grnid_tb.getValue().trim());
	//batg = kiboo.replaceSingleQuotes( assettag_by.getValue().trim() );

	Listbox newlb = lbhand.makeVWListbox_Width(melgrnlb_holder, melgrnhds, "melgrn_lb", 3);

	sqlstm = "select mg.origid, mg.datecreated, mg.parent_csgn, mg.username, mg.gstatus, mg.rwlocation, mg.batch_no," +
	"mg.commitdate, mg.commituser, mg.auditdate, mg.audituser, mg.audit_id," +
	"(select csgn from mel_csgn where origid=mg.parent_csgn) as melref, case when unknown_snums is null then '' else 'YES' end as unknowns from mel_grn mg ";

	switch(itype)
	{
		case 1: // by date range and search-text if any
			sqlstm += "where mg.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
			//if(!sct.equals(""))
			break;

		case 2: // by grn-id
			if(jid.equals("")) return;
			try { kk = Integer.parseInt(jid); } catch (Exception e) { return; }
			sqlstm += "where mg.origid=" + jid;
			break;
	}

	sqlstm += showgrn_extra_sql + " order by mg.origid desc"; // showgrn_extra_sql defi in main

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(10); newlb.setMold("paging");
	newlb.addEventListener("onSelect", grnclik);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid","datecreated","melref","parent_csgn","batch_no","rwlocation","username","gstatus","unknowns",
	"commitdate","commituser","auditdate","audituser","audit_id" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void mpf_clearBoxes() // just clear 'em MPF mass-update specs boxes
{
	Object[] jkl = {
		m_grd, m_brand, m_type, m_model, m_processor, m_msize, m_mtype,
		m_color, m_case, m_coa, m_coa2, m_ram, m_hdd, m_cdrom1, m_comment,
		m_webcam, m_btooth, m_fprint, m_creader
	};
	for(i=0;i<jkl.length;i++)
	{
		jkl[i].setValue("");
	}
}

void mpfUpdate_specs(Component iob)
{
	mpf_pop.close();
	kk = iob.getId();
	kk = kk.substring(1,kk.length());
	tobj = mpf_pop.getFellowIfAny(kk);
	if(tobj == null) return;
	spt = kiboo.replaceSingleQuotes( tobj.getValue().trim() );
	if(spt.equals("")) return;

	mut = -1;
	for(k=0; k<specs_mpf_names.length;k++) // scan through field-names to get index
	{
		if( specs_mpf_names[k].equals(kk) )
		{
			mut = k;
			break;
		}
	}

	if(mut != -1)
	{
		try
		{
			jk = grn_rows.getChildren().toArray();
			for(i=0;i<jk.length;i++)
			{
				ki = jk[i].getChildren().toArray();
				if(ki[0].isChecked())
					ki[4+mut].setValue(spt);
			}
		} catch (Exception e) {}
	}
}

// Save the specs into mel_inventory - will be injected back to FC6 once item-name matched
// // d.get("item_desc"), d.get("rw_assettag"), d.get("serial_no")
boolean saveSpecs()
{
	sqlstm = "";
	try
	{
		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			itm = kiboo.replaceSingleQuotes( ki[1].getValue().trim() ); // to save if user matches MEL against FC6 item-name
			snm = kiboo.replaceSingleQuotes( ki[3].getValue().trim() );
			sx = ct = "";

			for(k=0; k<MEL_invt_fields.length;k++)
			{
				cix = k + 4;

				if(ki[cix] instanceof Listbox)
					ct = ki[cix].getSelectedItem().getLabel();
				else
					ct = kiboo.replaceSingleQuotes( ki[cix].getValue().trim() );

				sx += MEL_invt_fields[k] + "='" + ct + "',";
			}
			try { sx = sx.substring(0,sx.length()-1); } catch (Exception e) {}

			sqlstm += "update mel_inventory set item_desc='" + itm + "'," + sx +
			" where serial_no='" + snm + "' and melgrn_id=" + glob_sel_grn + ";";
		}
	} catch (Exception e) { return false; }

	sqlhand.gpSqlExecuter(sqlstm);
	return true;
}

void mpfToggCheckbox() // toggle checkboxes for 'em items
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			ki[0].setChecked( (ki[0].isChecked()) ? false : true ); // assume 1st item is checkbox!!
		}
	} catch (Exception e) {}
}

