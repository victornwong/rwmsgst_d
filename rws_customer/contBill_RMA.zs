import org.victor.*;

// RMA related funcs for contractBillingTrack_v1.zul

// Knockoff from showLC_DO_recs(). make it standalone incase req to add more fields
void showLC_RMA_recs(String iwhat, Object irows)
{
	lcr = getLCNew_rec(iwhat);
	if(lcr.get("rma_records") == null) return;

	idog = sqlhand.clobToString(lcr.get("rma_records")).split("~");
	idod = sqlhand.clobToString(lcr.get("rma_dates")).split("~");

	for(i=0; i<idog.length; i++)
	{
		nrw = new org.zkoss.zul.Row();
		nrw.setParent(irows);

		pck = gpMakeCheckbox(nrw,"","","");

		donts = "";
		try { donst = idog[i]; } catch (Exception e) {}
		gpMakeTextbox(nrw,"",donst,"font-weight:bold;","99%"); // RMA no.

		dtbo = new Datebox(); // RMA date
		dtbo.setFormat("yyyy-MM-dd");
		dtbo.setParent(nrw);

		try {
			dodd = dtf2.parse(idod[i]);
			dtbo.setValue(dodd);
		} catch (Exception e) {}

		gpMakeButton(nrw,"","More","font-size:9px", glob_rma_butt_click);
	}
}

void rmaFunc(Object iwhat)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	msgtext = sqlstm = "";

	if(glob_selected_lc.equals("")) return;

	if(itype.equals("newrma_b"))
	{
		irow = gridhand.gridMakeRow("","","",rma_rows);
		gpMakeCheckbox(irow,"", "","");
		gpMakeTextbox(irow,"","","font-weight:bold;","99%"); // RMA no.
		dtbo = new Datebox(); // RMA date
		dtbo.setFormat("yyyy-MM-dd");
		dtbo.setParent(irow);
		kiboo.setTodayDatebox(dtbo);
		gpMakeButton(irow,"","More","font-size:9px", glob_rma_butt_click);
	}

	if(itype.equals("remrma_b"))
	{
		removeRowFromGrid(rma_rows);
	}

	if(itype.equals("saverma_b"))
	{
		rmns = concatRowsComp_str(1,"~",rma_rows);
		rmdt = concatRowsComp_str(2,"~",rma_rows);
		sqlstm = "update rw_lc_records set rma_records='" + rmns + "', rma_dates='" + rmdt + "' where origid=" + glob_selected_lc;
		msgtext = "RMA records updated..";
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}



