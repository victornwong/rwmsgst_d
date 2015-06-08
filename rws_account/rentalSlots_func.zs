/**
 * Rental book slots management funcs
 * @author Victor Wong
 * @since 18/05/2015
 * 
 */
import org.victor.*;

// Slots grid column posisi
G_TICKER = 0;
G_SLOT_NO = 1;
G_NEXT_BILL = 2;
G_INV_NO = 3;
G_INV_DATE = 4;
G_REMARKS = 5;
G_PDFFILENAME = 6;

/**
 * Slots func dispenser
 * @param itype button ID
 */
void slotsFunc(String itype)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = msgtext = "";
	refresh = false;

	if(itype.equals("ins1slot_b")) // insert 1 slot
	{
		insert_BlankSlot(1);
		refresh = true;
	}

	if(itype.equals("ins12slot_b")) // insert 12 slots
	{
		insert_BlankSlot(12);
		refresh = true;
	}

	if(itype.equals("remslot_b")) // remove ticked slots
	{
		iterateSlots(slot_rows,1);
		refresh = true;
	}

	if(itype.equals("untick_b")) // untick checkboxes
	{
		iterateSlots(slot_rows,2);
	}

	if(itype.equals("viewpdfinv_b"))
	{
		iterateSlots(slot_rows,3);
	}

	if(refresh)
	{
		refreshSlot_Num();
	}
}

/**
 * Save whatever slots in grid to dbase. Will delete prev records in dbase and insert new ones
 * dbase: rw_rentalbook
 */
void saveSlots()
{
	if(glob_selected_lc.equals("")) return;
	slt = slotsholder.getFellowIfAny(SLOTS_GRID_ROWS_ID);
	if(slt == null) return;
	hx = slt.getChildren().toArray();
	if(hx.length == 0) return;
	sqlstm = "delete from rw_rentalbook where parent_lc=" + glob_selected_lc + ";";
	for(i=0; i<hx.length; i++)
	{
		jk = hx[i].getChildren().toArray();
		sqlstm += "insert into rw_rentalbook (parent_lc,sorter,notif_date,fc_invoice,invoice_date,remarks) values " +
		"(" + glob_selected_lc + "," + jk[G_SLOT_NO].getValue() + ",'" + jk[G_NEXT_BILL].getValue() + "','" + jk[G_INV_NO].getValue() + "','" +
		jk[G_INV_DATE].getValue() + "','" + jk[G_REMARKS].getValue() + "');";
	}

	sqlhand.gpSqlExecuter(sqlstm);
}

/**
 * Update input fields into slot's fields. Called in slotsedit_pop button
 * glob_sel_slot_obj set in slotdclik listener
 */
void updSlotDetails()
{
	if(glob_sel_slot_obj == null) return;
	kd = kiboo.dtf2.format(i_notif_date_dt.getValue());
	kr = kiboo.replaceSingleQuotes(i_remarks_tb.getValue().trim());

	hx = glob_sel_slot_obj.getChildren().toArray();
	hx[G_NEXT_BILL].setValue(kd);
	hx[G_REMARKS].setValue(kr);

	// when required, can allow user to modif invoice no and date grabbed from FC6
	// unhide rows in popup /*
	inv = kiboo.replaceSingleQuotes(i_fc_invoice_tb.getValue().trim());
	hx[G_INV_NO].setValue(inv);
	invd = kiboo.dtf2.format(i_invoice_date_dt.getValue());
	hx[G_INV_DATE].setValue(invd);
}

/**
 * Abit hardcoded to iterate over grid-rows and perform some func
 * @param irows the grid ROWS id
 * @param itype what func
 */
void iterateSlots(Object irows, int itype)
{
	cds = irows.getChildren().toArray();
	ks = "";
	for(i=0; i<cds.length; i++)
	{
		cx = cds[i].getChildren().toArray();

		switch(itype)
		{
			case 1: // remove ticked slots
				if(cx[G_TICKER].isChecked())
				{
					inv = cx[G_INV_NO].getValue().trim();
					// check if there's already invoice, not allow to remove
					if(inv.equals("")) cds[i].setParent(null);
					else ks += "Slot: " + cx[G_SLOT_NO].getValue() + " has InvoiceNo: " + inv + ", cannot remove\n";
				}
				break;

			case 2: // untick checkboxes
				cx[G_TICKER].setChecked(false);
				break;

			case 3: // view PDF invoice if any
				if(cx[G_TICKER].isChecked())
				{
					fncm = cx[G_PDFFILENAME].getValue(); // tax-invoice pdf filename
					if(!fncm.equals(""))
					{
						//outfn = session.getWebApp().getRealPath(TEMPFILEFOLDER + fncm);
						theparam = "pfn=/taxinvoices/" + fncm;
						uniqid = kiboo.makeRandomId("lvf");
						guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile_Local_v1.zul", uniqid, theparam, useraccessobj);
					}
				}
		}
	}
	if(!ks.equals("")) guihand.showMessageBox(ks);
}

/**
 * double-clicker handler for slots 
 */
class slotdclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		glob_sel_slot_obj = event.getTarget();
		slotsedit_pop.open(glob_sel_slot_obj);
		//alert(seli.getChildren());
	}
}
slotdclicker = new slotdclik(); // pre-def global event listener

/** 
 * Insert blank slots/rows into grid. Hardcoded according to required columns
 * @param icount how many to insert
 */
void insert_BlankSlot(int icount)
{
	k9 = "font-size:9px";
	for(i=0; i<icount; i++)
	{
		nrw = new org.zkoss.zul.Row();
		nrw.setParent(slot_rows); // HARDCODED: see how to refer to SLOTS_GRID_ROWS_ID instead for future expansion
		ngfun.gpMakeCheckbox(nrw,"","","");
		ngfun.gpMakeLabel(nrw,"","",k9); // slot no.

		ngfun.gpMakeLabel(nrw,"","",k9); // next billing reminder date
		ngfun.gpMakeLabel(nrw,"","",k9); // invoice no. grabbed from FC6 when uploaded
		ngfun.gpMakeLabel(nrw,"","",k9); // invoice date from FC6
		kk = ngfun.gpMakeLabel(nrw,"","",k9); // remarks
		kk.setMultiline(true);

		// from email tax-invoice tracker rw_email_invoice
		ngfun.gpMakeLabel(nrw,"","",k9); // pdf-filename if any - search based on invoice number
		ngfun.gpMakeLabel(nrw,"","",k9); // emailed pdf date
		ngfun.gpMakeLabel(nrw,"","",k9); // resend date

		nrw.addEventListener("onDoubleClick", slotdclicker);
	}
	//doi = new Datebox(); doi.setStyle("font-size:9px"); doi.setFormat("yyyy-MM-dd"); doi.setParent(nrw);
}

/**
 * Refresh the numbering column of grid 
 */
void refreshSlot_Num()
{
	cds = null;
	try { cds = slot_rows.getChildren().toArray(); } catch (Exception e) { return; }
	lncount = 1;
	for(i=0; i<cds.length; i++)
	{
		cx = cds[i].getChildren().toArray();
		cx[G_SLOT_NO].setValue(lncount.toString());
		lncount++;
	}
}

/**
 * Make grid using hardcoded header defs
 * @param iholder grid DIV holder
 * @param islotid grid-id
 * HARDCODED SLOTS_GRID_ROWS_ID in billingEvo2.zul
 */
void checkCreateSlotsGrid(Div iholder, String islotid)
{
	String[] colhed = { "","No.","Next bill","Inv No","Inv Date","Remarks","PDF","Emailed","Resend" };
	String[] colwds = { "20px", "30px", "80px", "100px", "80px", "", "", "80px", "80px" };
	ngfun.checkMakeGrid(colwds, colhed, iholder, islotid, SLOTS_GRID_ROWS_ID, "", "800px", true);
}

