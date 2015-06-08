import org.victor.*;
// General funcs for rwQuotation.zul

void checkMakeItemsGrid()
{
	String[] colws = { "15px","","60px","90px","80px","80px","100px" };
	String[] colls = { "", "Items and Specs", "Qty", "R.Month", "R.Period", "Dscnt", "Sub.Total" };

	if(qtitems_holder.getFellowIfAny("qtitems_grid") == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId("qtitems_grid");
		icols = new org.zkoss.zul.Columns();
		for(i=0;i<colws.length;i++)
		{
			ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(colws[i]);
			ico0.setLabel(colls[i]);
			//if(i != 1 || i != 2) ico0.setAlign("center");
			ico0.setStyle("background:#97b83a");
			ico0.setParent(icols);
		}
		icols.setParent(igrd);
		irows = new org.zkoss.zul.Rows();
		irows.setId("qtitems_rows");
		irows.setParent(igrd);
		igrd.setParent(qtitems_holder);
	}
}

DESC_IX = 0;
SPEC_IX = 2;
QTY_IX = 2;
UPR_IX = 3;
RNTP_IX = 4;
DISC_IX = 5;

void calcQTItems()
{
	if(qtitems_holder.getFellowIfAny("qtitems_grid") == null) return;
	cds = qtitems_rows.getChildren().toArray();
	gtotal = 0.0;
	for(i=0; i<cds.length; i++)
	{
		subtot = 0.0;
		c1 = cds[i].getChildren().toArray();
		qty = 0;
		try { qty = Integer.parseInt( c1[QTY_IX].getValue() ); } catch (Exception e) {}
		uprice = 0.0;
		try { uprice = Float.parseFloat( c1[UPR_IX].getValue() ); } catch (Exception e) {}
		discount = 0.0;
		try { discount = Float.parseFloat( c1[DISC_IX].getValue() ); } catch (Exception e) {}
		rentp = 1;
		try { rentp = Integer.parseInt( c1[RNTP_IX].getValue() ); } catch (Exception e) {}
		subtot = ((qty * uprice) - (qty * discount)) * rentp;
		gtotal += subtot;
		c1[6].setValue( nf2.format(subtot) );
	}
	grandtotal_lbl.setValue( nf2.format(gtotal) );
}

void saveQTItems(String iwhat)
{
	if(qtitems_holder.getFellowIfAny("qtitems_grid") == null) return;
	cds = qtitems_rows.getChildren().toArray();
	idesc = ispecs = iqty = idisc = iupr = irp = "";

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();

		dv1 = c1[1].getChildren().toArray();
		idesc += kiboo.replaceSingleQuotes( dv1[DESC_IX].getValue().replaceAll("~"," ") ) + "~";
		ispecs += kiboo.replaceSingleQuotes( dv1[SPEC_IX].getValue().replaceAll("~"," ") ) + "~";

		iqty += kiboo.replaceSingleQuotes( c1[QTY_IX].getValue().replaceAll("~"," ") ) + "~";
		iupr += kiboo.replaceSingleQuotes( c1[UPR_IX].getValue().replaceAll("~"," ") ) + "~";
		irp += kiboo.replaceSingleQuotes( c1[RNTP_IX].getValue().replaceAll("~"," ") ) + "~";
		idisc += kiboo.replaceSingleQuotes( c1[DISC_IX].getValue().replaceAll("~"," ") ) + "~";
	}

	try { idesc = idesc.substring(0,idesc.length()-1); } catch (Exception e) {}
	try { ispecs = ispecs.substring(0,ispecs.length()-1); } catch (Exception e) {}
	try { iqty = iqty.substring(0,iqty.length()-1); } catch (Exception e) {}
	try { iupr = iupr.substring(0,iupr.length()-1); } catch (Exception e) {}
	try { idisc = idisc.substring(0,idisc.length()-1); } catch (Exception e) {}
	try { irp = irp.substring(0,irp.length()-1); } catch (Exception e) {}

	sqlstm = "update rw_quotations set q_items='" + idesc + "', q_items_desc='" + ispecs + "', q_qty='" + iqty + "', " +
	"q_unitprice='" + iupr + "', q_discounts='" + idisc + "', q_rental_periods='" + irp + "' " +
	"where origid=" + iwhat;
	sqlhand.gpSqlExecuter(sqlstm);
}

// itype: 0=call from main, 1=call from other mods
void showQuoteMeta(String iwhat, int itype)
{
	qtr = getQuotation_rec(iwhat);
	glob_qt_rec = qtr; // for later
	if(qtr == null) { guihand.showMessageBox("DBERR: Cannot access quotations database"); return; }

	//q_origid.setValue(iwhat);
	Object[] uicomps = { customername, q_cust_address, q_contact_person1, q_telephone, q_fax, q_email, q_origid,
	q_creditterm, q_curcode, q_exchangerate, q_quote_discount, q_notes, q_qt_type, q_qt_validity, q_et_action, q_datecreated };

	String[] flds = { "customer_name", "cust_address", "contact_person1", "telephone", "fax", "email", "origid",
	"creditterm", "curcode", "exchangerate", "quote_discount", "notes", "qt_type", "qt_validity", "et_action","datecreated" };

	populateUI_Data(uicomps, flds, qtr);
	showQT_items(qtr);
	calcQTItems();

	if(itype == 0)
	{
		try { workarea.setVisible(true);
		blindTings_withTitle(blind_listarea,listarea_holder,listarea_header); // blindup the QTs LB
		} catch (Exception e) {}
	}
}

void showQT_items(Object irec)
{
	if(qtitems_holder.getFellowIfAny("qtitems_grid") != null) qtitems_grid.setParent(null);
	checkMakeItemsGrid(); // always make new items-grid

	ktg = sqlhand.clobToString(irec.get("q_items"));
	if(!ktg.equals(""))
	{
		idesc = sqlhand.clobToString(irec.get("q_items")).split("~");
		ispec = sqlhand.clobToString(irec.get("q_items_desc")).split("~");
		iqty = sqlhand.clobToString(irec.get("q_qty")).split("~");
		iupr = sqlhand.clobToString(irec.get("q_unitprice")).split("~");
		idisc = sqlhand.clobToString(irec.get("q_discounts")).split("~");
		iper = sqlhand.clobToString(irec.get("q_rental_periods")).split("~");

		qst = irec.get("qstatus");
		fb = "font-weight:bold;";

		for(i=0; i<idesc.length; i++)
		{
			nrw = new org.zkoss.zul.Row();
			nrw.setParent(qtitems_rows);

			qtys = "";
			try { qtys = iqty[i]; } catch (Exception e) {}
			upric = "";
			try { upric = iupr[i]; } catch (Exception e) {}
			disct = "";
			try { disct = idisc[i]; } catch (Exception e) {}
			ispcs = "";
			try { ispcs = ispec[i]; } catch (Exception e) {}
			tdesc = "";
			try { tdesc = idesc[i]; } catch (Exception e) {}
			tper = "";
			try { tper = iper[i]; } catch (Exception e) {}
			
			//alert(qtys + " :: " + upric + " :: " + disct + " :: " + ispcs + " :: " + tdesc);

			pck = gpMakeCheckbox(nrw,"","","");

			vbx1 = new Div();
			vbx1.setParent(nrw);

			if(qst.equals("DRAFT"))
			{
				desb = gpMakeTextbox(vbx1,"",tdesc,fb,"99%");
				gpMakeSeparator(2,"2px",vbx1);
				spcs = gpMakeTextbox(vbx1,"",ispcs,fb+"font-size:9px","99%");
				spcs.setMultiline(true);
				spcs.setHeight("70px");

				gpMakeTextbox(nrw,"",qtys,fb,"99%"); // qty
				gpMakeTextbox(nrw,"",upric,fb,"99%"); // unit price
				gpMakeTextbox(nrw,"",tper,fb,"99%"); // rental period
				gpMakeTextbox(nrw,"",disct,fb,"99%"); // discount
				gpMakeLabel(nrw,"","",fb); // sub-total
			}
			else
			{
				desb = gpMakeLabel(vbx1,"",tdesc,fb);
				desb.setMultiline(true);
				gpMakeSeparator(2,"2px",vbx1);
				spcs = gpMakeLabel(vbx1,"",ispcs,fb + "font-size:9px");
				spcs.setMultiline(true);

				gpMakeLabel(nrw,"",qtys,fb); // qty
				gpMakeLabel(nrw,"",upric,fb); // unit price
				gpMakeLabel(nrw,"",tper,fb); // rental period
				gpMakeLabel(nrw,"",disct,fb); // discount
				gpMakeLabel(nrw,"","",fb); // sub-total
			}
		}
	}
}

Object[] qtslb_hds =
{
	new listboxHeaderWidthObj("QT#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Q.Type",true,"80px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Status",true,"60px"),
	new listboxHeaderWidthObj("Validity",true,"60px"),
};

class qtlbclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_quote = lbhand.getListcellItemLabel(isel,0);
		glob_sel_qstatus = lbhand.getListcellItemLabel(isel,5);
		glob_sel_username = lbhand.getListcellItemLabel(isel,4);
		showQuoteMeta(glob_sel_quote,0);
	}
}
qtclicker = new qtlbclk();

void listQuotations()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(quotes_holder, qtslb_hds, "quotations_lb", 10);

	scsql = "";
	if(!scht.equals(""))
		scsql = "and (customer_name like '%" + scht + "%' " + 
		"or cast(q_items as varchar(max)) like '%" + scht + "%') ";

	sqlstm = "select origid,datecreated,customer_name,username,qstatus,qt_type,qt_validity from rw_quotations " +
	"where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " + scsql;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(22);
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.addEventListener("onSelect", qtclicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "customer_name", "qt_type", "username", "qstatus", "qt_validity" }; 
	for(dpi : screcs)
	{
		popuListitems_Data(kabom,fl,dpi);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

