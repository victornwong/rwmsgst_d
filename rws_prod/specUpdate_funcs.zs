import org.victor.*;
// Funcs used in specUpdate_v1.zul

Object glob_focus6_grades = null;

void toggButts_specupdate(boolean iwhat)
{
	Object[] butts = { savespecs_b, sourcepecs_b, postspecs_b, mpfbutt, getstkname_b };
	for(i=0; i<butts.length; i++)
	{
		butts[i].setDisabled(iwhat);
	}
}

// Get Focus6 available inventory grades
Object getFocus_StockGrades()
{
	sqlstm = "select distinct grade from partsall_0 order by grade";
	return sqlhand.rws_gpSqlGetRows(sqlstm);
}

// GRN items insert new row - won't save into DB
// knockoff for spec-update with additional fields
org.zkoss.zul.Row makeItemRow_specup(Component irows, String iname, String iatg, String isn, String iqty, String istat)
{
	k9 = "font-size:9px";
	nrw = new org.zkoss.zul.Row();
	nrw.setParent(irows);
	ngfun.gpMakeCheckbox(nrw,"","","");
	//ngfun.gpMakeTextbox(nrw,"",iname,k9,"98%",textboxnulldrop); // item-name
	ngfun.gpMakeLabel(nrw,"",iname,k9); // item-name using label

	if(istat.equals("DRAFT")) // draft GRN, insert textboxes
	{
		//ngfun.gpMakeTextbox(nrw,"",iatg,k9,"95%",textboxnulldrop); // asset-tag
		//ngfun.gpMakeTextbox(nrw,"",isn,k9,"95%",textboxnulldrop); // serial
		//ngfun.gpMakeTextbox(nrw,"",iqty,k9,"95%",textboxnulldrop); // qty
		ngfun.gpMakeLabel(nrw,"",iatg,k9);
		ngfun.gpMakeLabel(nrw,"",isn,k9);
	}
	else // else only labels
	{
		ngfun.gpMakeLabel(nrw,"",iatg,k9);
		ngfun.gpMakeLabel(nrw,"",isn,k9);
		//ngfun.gpMakeLabel(nrw,"",iqty,k9);
	}

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

/**
 * knockoff from goodsrecv_funcs.showGRN_meta() with some modif
 * @param iwhat the selected GRN
 */
void showGRN_things(String iwhat)
{
	r = getGRN_rec_NEW(iwhat);
	if(r == null) return;

	if(glob_focus6_grades == null) glob_focus6_grades = getFocus_StockGrades(); // reload if null

	/*
		String[] fl = { "ourpo", "vendor", "vendor_do", "vendor_inv", "shipmentcode", "grn_remarks","origid" };
		Object[] jkl = { g_ourpo, g_vendor, g_vendor_do, g_vendor_inv, g_shipmentcode, g_grn_remarks, g_origid };
		ngfun.populateUI_Data(jkl,fl,r);
		fillDocumentsList(documents_holder,GRN_PREFIX,iwhat);
	*/
	itms = sqlhand.clobToString(r.get("item_names")).split("~");
	atgs = sqlhand.clobToString(r.get("asset_tags")).split("~");
	srls = sqlhand.clobToString(r.get("serials")).split("~");
	qtys = sqlhand.clobToString(r.get("qtys")).split("~");
	specs = sqlhand.clobToString( r.get("specs") ).split("::");

	if(scanitems_holder.getFellowIfAny("grn_grid") != null) grn_grid.setParent(null);
	ngfun.checkMakeGrid(scanitems_colws, scanitems_collb, scanitems_holder, "grn_grid", "grn_rows", "", "", false);

	for(i=0;i<itms.length; i++) // show 'em grn items
	{
		p1 = ""; try { p1 = itms[i]; } catch (java.lang.ArrayIndexOutOfBoundsException e) {}
		p2 = ""; try { p2 = atgs[i]; } catch (java.lang.ArrayIndexOutOfBoundsException e) {}
		p3 = ""; try { p3 = srls[i]; } catch (java.lang.ArrayIndexOutOfBoundsException e) {}
		p4 = ""; try { p4 = qtys[i]; } catch (java.lang.ArrayIndexOutOfBoundsException e) {}

		nrw = makeItemRow_specup(grn_rows,p1,p2,p3,p4,r.get("status"));

		js = null;
		try { if(specs[i] != null) js = specs[i].split("\n"); } catch (java.lang.ArrayIndexOutOfBoundsException e) {}

		ki = nrw.getChildren().toArray();

		for(k=0;k<specs_fields.length;k++)
		{
			if(js != null)
			{
				cix = k + 4;
				try {
				if(ki[cix] instanceof Listbox)
					lbhand.matchListboxItems(ki[cix], js[k]);
				else
					ki[cix].setValue(js[k]);
				} catch (java.lang.ArrayIndexOutOfBoundsException e) {}
			}
		}
	}
	workarea.setVisible(true);
	//grnmeta_holder.setVisible(true);
	//grnitems_workarea.setVisible(true);
}

boolean postSpecs()
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		sqlstm = "";
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			atg = ki[2].getValue();

			if(!atg.equals("NOTAG") && !atg.equals("")) // ignore NOTAG or blank asset-tags -- inserted by RWMS
			{
				sqlstm += "update u0001 set ";
				fql = "";
				for(k=0; k<specs_fields.length;k++)
				{
					cix = k + 4;

					if(ki[cix] instanceof Listbox)
						ct = ki[cix].getSelectedItem().getLabel();
					else
						ct = kiboo.replaceSingleQuotes( ki[k+4].getValue().trim() );

					fql += specs_sql_fields[k] + "='" + ct + "',";
				}
				try { fql = fql.substring(0,fql.length()-1); } catch (Exception e) {}
				sqlstm += fql + " where extraid=(select eoff from mr001 where code2='" + atg + "');";
			}
		}

		if(TESTING_MODE)
			f30_gpSqlExecuter(sqlstm);
		else
			sqlhand.rws_gpSqlExecuter(sqlstm);

		return true;

	} catch (Exception e) { return false; }
}

/**
 * Save the specs into rw_grn ONLY -- not posting to Focus
 * 08/09/2015: need to save item-name too for use later to inject into FOCUS
 * @return save is successful = true
 */
boolean saveSpecs()
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		spc = itnms = "";
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			itnms += ki[1].getValue() + "~"; // save them item-names for FOCUS injection
			for(k=0; k<specs_fields.length;k++)
			{
				cix = k + 4;
				ct = "";

				if(ki[cix] instanceof Listbox)
					ct = ki[cix].getSelectedItem().getLabel();
				else
					ct = kiboo.replaceSingleQuotes( ki[cix].getValue().trim() );

				if(ct.equals("")) ct = "---";
				spc += ct + "\n";
			}
			spc += "::";
		}

		sqlstm = "update rw_grn set item_names='" + itnms + "', specs='" + spc + "' where origid=" + glob_sel_grn;
		sqlhand.gpSqlExecuter(sqlstm);
		return true;

	} catch (Exception e) { return false; }
}

// Source previous specs from u0001
void sourcePrevious_NameSerials()
{
	try
	{
		jk = grn_rows.getChildren().toArray();
		for(i=0;i<jk.length;i++)
		{
			ki = jk[i].getChildren().toArray();
			py = getExisting_inventoryRec(ki[2].getValue());
			if(py != null)
			{
				for(k=0; k<specs_fields.length;k++)
				{
					ct = kiboo.checkNullString( py.get(specs_fields[k]) );
					cix = k + 4;
					if(ki[cix] instanceof Listbox)
						lbhand.matchListboxItems(ki[cix], ct);
					else
						ki[cix].setValue(ct);
				}
			}
		}
	} catch (Exception e) {}
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

void panel_Close() // main-panel onClose do something
{
	if(!glob_sel_grn.equals("")) // if GRN selected - save 'em specs into rw_grn
	{
		saveSpecs();
	}
}
