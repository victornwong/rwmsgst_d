/**
 * Rental book slots management funcs
 * @author Victor Wong
 * @since 18/05/2015
 * 
 */
import org.victor.*;

// Slots grid column posisi
G_TICKER = 0; G_SLOT_NO = 1; G_NEXT_BILL = 2; G_INV_NO = 3; G_INV_DATE = 4; G_REMARKS = 5;
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

	if(itype.indexOf("insslot") != -1) // insert slots buttons activated
	{
		kbt = 1;
		try {	kbt = Integer.parseInt(itype.replaceAll("insslot_b_","")); } catch (Exception e) {}
		insert_BlankSlot(kbt);
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

	if(itype.equals("clearslot_b")) // clear slot details ONLY
	{
		iterateSlots(slot_rows,4);
	}

	if(refresh)
	{
		refreshSlot_Num();
	}
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

		if(itype == 2) // checkboxes toggler
		{
			cx[G_TICKER].setChecked( (cx[G_TICKER].isChecked()) ? false : true);
		}
		else
		{
			if(cx[G_TICKER].isChecked())
			{
				switch(itype)
				{
					case 1: // remove ticked slots
						inv = cx[G_INV_NO].getValue().trim();
						// check if there's already invoice, not allow to remove
						if(inv.equals("")) cds[i].setParent(null);
						else ks += "Slot: " + cx[G_SLOT_NO].getValue() + " has InvoiceNo: " + inv + ", cannot remove\n";
						break;

					case 3: // view PDF invoice if any
						fncm = cx[G_PDFFILENAME].getValue(); // tax-invoice pdf filename
						if(!fncm.equals(""))
						{
							//outfn = session.getWebApp().getRealPath(TEMPFILEFOLDER + fncm);
							theparam = "pfn=/taxinvoices/" + fncm;
							uniqid = kiboo.makeRandomId("lvf");
							guihand.globalActivateWindow(mainPlayground,"miscwindows","documents/viewfile_Local_v1.zul", uniqid, theparam, useraccessobj);
						}
						break;

					case 4: // clear slot details ONLY starting from invoice-no. onwards
						for(k=G_INV_NO; k<G_PDFFILENAME+1; k++)
						{
							try { cx[k].setValue(""); } catch (Exception e) {}
						}
						break;
				}
			}
		}
	}
	if(!ks.equals("")) guihand.showMessageBox(ks);
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
 * 
 * @param itype 1=update all, 2=upd only next-billing-date
 */
void updSlotDetails(int itype)
{
	if(glob_sel_slot_obj == null) return;
	hx = glob_sel_slot_obj.getChildren().toArray();
	kd = kiboo.dtf2.format(i_notif_date_dt.getValue());

	switch(itype)
	{
		case 1: // update all
			kr = kiboo.replaceSingleQuotes(i_remarks_tb.getValue().trim());
			hx[G_NEXT_BILL].setValue(kd);
			hx[G_REMARKS].setValue(kr);

			// when required, can allow user to modif invoice no and date grabbed from FC6
			// unhide rows in popup
			inv = kiboo.replaceSingleQuotes(i_fc_invoice_tb.getValue().trim());
			hx[G_INV_NO].setValue(inv);
			invd = kiboo.dtf2.format(i_invoice_date_dt.getValue());
			hx[G_INV_DATE].setValue(invd);
			break;

		case 2: // update next-billing date notif
			hx[G_NEXT_BILL].setValue(kd);
			break;
	}
}

/**
 * double-clicker handler for slots 
 */
class slotdclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			invoiceSlot_dclick_callback(isel);
		} catch (Exception e) {}
	}
}
slotdclicker = new slotdclik(); // pre-def global event listener

/**
 * Call-back from slot d-clicker - can be customized for other modu
 * @param isel [description]
 */
void invoiceSlot_dclick_callback(Object isel)
{
	glob_sel_slot_obj = isel;
	cx = isel.getChildren().toArray();
	
	nrd = cx[G_NEXT_BILL].getValue().trim();
	if(!nrd.equals(""))
	{
		i_notif_date_dt.setValue( kiboo.dtf2.parse(nrd) );
	}

	i_fc_invoice_tb.setValue(cx[G_INV_NO].getValue().trim()); // textboxes in popup
	ivd = cx[G_INV_DATE].getValue().trim();
	if(!ivd.equals(""))
	{
		i_invoice_date_dt.setValue( kiboo.dtf2.parse(ivd) );
	}

	i_remarks_tb.setValue(cx[G_REMARKS].getValue().trim());
	slotsedit_pop.open(glob_sel_slot_obj);
}

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
	/*
	String[] colhed = { "","No.","Next bill","Inv No","Inv Date","Remarks","PDF","Emailed","Resend" };
	String[] colwds = { "20px", "30px", "80px", "100px", "80px", "", "", "80px", "80px" };
	*/
	String[] colhed = { "","No.","Next bill","Inv No","Inv Date","Remarks" };
	String[] colwds = { "20px", "30px", "80px", "100px", "80px", "" };

	ngfun.checkMakeGrid(colwds, colhed, iholder, islotid, SLOTS_GRID_ROWS_ID, "", "800px", true);
}

/**
 * Insert string to next empty slot - can cater for other modu
 * @param irows GRID ROWS
 * @param icol  which column to check and update
 * @param iwhat string to put into empty slot
 */
Object insertIntoNextEmptySlot(Object irows, int icol, String iwhat)
{
	cx = null;
	cds = irows.getChildren().toArray();
	for(i=0; i<cds.length; i++)
	{
		cx = cds[i].getChildren().toArray();
		kk = cx[icol].getValue().trim();
		if(kk.equals("")) // found empty slot
		{
			cx[icol].setValue(iwhat);
			break;
		}
	}
	return cx;
}

String getSlotValue_byEmptySlot(Object irows, int icheckcol, int iretcol)
{
	cx = null;
	retval = "";
	cds = irows.getChildren().toArray();
	for(i=0; i<cds.length; i++)
	{
		cx = cds[i].getChildren().toArray();
		kk = cx[icheckcol].getValue().trim();
		if(kk.equals("")) // found empty slot
		{
			retval = cx[iretcol].getValue();
			break;
		}
	}
	return retval;
}

/**
 * Get last lastest rental-invoice in the slots - sorted descending
 */
String getLastRentalInvoice_inslot()
{
	retval = "";
	try
	{
		cds = slot_rows.getChildren().toArray();
		ArrayList inva = new ArrayList();
		for(i=0; i<cds.length; i++)
		{
			cx = cds[i].getChildren().toArray();
			inv = cx[G_INV_NO].getValue().trim();
			if(!inv.equals("")) inva.add(inv);
		}
		Collections.sort(inva);
		Collections.reverse(inva);
		retval = inva.get(0);
	} catch (Exception e) {}
	return retval;
}

