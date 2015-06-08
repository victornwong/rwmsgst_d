import org.victor.*;

// DO related funcs for contractBillingTrack_v1.zul

void showLC_DO_recs(String iwhat, Object irows)
{
	lcr = getLCNew_rec(iwhat);
	if(lcr.get("do_records") == null) return;

	idog = sqlhand.clobToString(lcr.get("do_records")).split("~");
	idod = sqlhand.clobToString(lcr.get("do_dates")).split("~");

	for(i=0; i<idog.length; i++)
	{
		nrw = new org.zkoss.zul.Row();
		nrw.setParent(irows);

		pck = gpMakeCheckbox(nrw,"","","");

		donts = "";
		try { donst = idog[i]; } catch (Exception e) {}
		gpMakeTextbox(nrw,"",donst,"font-weight:bold;","99%"); // DO no.

		dtbo = new Datebox(); // DO date
		dtbo.setFormat("yyyy-MM-dd");
		dtbo.setParent(nrw);

		try {
			dodd = dtf2.parse(idod[i]);
			dtbo.setValue(dodd);
		} catch (Exception e) {}

		gpMakeButton(nrw,"","More","font-size:9px", glob_dorder_butt_click);
	}
}

// DeliveryOrder(DO) funcs
void deliveryOFunc(Object iwhat)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	msgtext = sqlstm = "";

	if(glob_selected_lc.equals("")) return;

	if(itype.equals("newdo_b"))
	{
		irow = gridhand.gridMakeRow("","","",dorder_rows);
		gpMakeCheckbox(irow,"", "","");
		gpMakeTextbox(irow,"","","font-weight:bold;","99%"); // DO no.
		//gpMakeTextbox(irow,"","","font-weight:bold;","99%"); // DO date
		dtbo = new Datebox();
		dtbo.setFormat("yyyy-MM-dd");
		dtbo.setParent(irow);
		kiboo.setTodayDatebox(dtbo);

		gpMakeButton(irow,"","More","font-size:9px", glob_dorder_butt_click);
	}

	if(itype.equals("remdo_b"))
	{
		// syslog watever DO removed
		cds = dorder_rows.getChildren().toArray();
		if(cds.length < 1) return;
		audstr = "Remove these DO: ";
		for(i=0; i<cds.length; i++)
		{
			c1 = cds[i].getChildren().toArray();
			if(c1[0].isChecked())
			{
				audstr += c1[1].getValue() + " / " + kiboo.getDateFromDatebox( c1[2] ) + ",\n";
			}
		}

		if (Messagebox.show(audstr, "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

		add_RWAuditLog(JN_linkcode(),"REMDO",audstr,useraccessobj.username); // syslog when DOs removed..
		removeRowFromGrid(dorder_rows);
		deliveryOFunc(savedos_b); // re-save DOs once removed
	}

	if(itype.equals("savedos_b"))
	{
		dons = concatRowsComp_str(1,"~",dorder_rows);
		dodt = concatRowsComp_str(2,"~",dorder_rows);
		sqlstm = "update rw_lc_records set do_records='" + dons + "', do_dates='" + dodt + "' where origid=" + glob_selected_lc;
		msgtext = "DO records updated..";
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	//if(refresh) listROCLC(last_list_type);
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

