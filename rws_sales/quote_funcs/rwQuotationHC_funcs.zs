import org.victor.*;
// General funcs for rwQuotation.zul

void toggQuoteButts(int itype, boolean iwhat)
{
	Object[] metabutts = { asssupp_b,impccallm_b,updqt_b,newqtitm_b,remqtitm_b,calcqtitems_b,saveitems_b };
	kk = null;
	switch(itype)
	{
		case 1:
			kk = metabutts;
			break;
	}

	if(kk != null)
	{
		for(i=0;i<kk.length;i++)
		{
			kk[i].setDisabled(iwhat);
		}
	}
}

void checkMakeItemsGrid()
{
	String[] colws = { "15px","","60px","90px","80px","80px","100px" };
	String[] colls = { "", "Items and Specs", "Qty", "Rental/Price", "Period", "Discount", "Sub.Total" };

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

// itype: 0=draft, 1=committed
void makeNewQuoteItemRow(Object irow, Object ival, int itype)
{
	kb = "font-weight:bold;font-size:9px";
	jb = "font-weight:bold;";
	if(ival == null) // if null values, make blanks
	{
		kk = new ArrayList();
		for(i=0;i<10;i++)
		{
			switch(i)
			{
				case 0:
					kk.add("ITEMS/MODEL/WHATEVER");
					break;
				case 1:
					kk.add("THE DETAIL SPECS");
					break;
				default:
					kk.add("");
					break;
			}
		}
		ival = kk.toArray();
	}

	gpMakeCheckbox(irow,"", "","");

	vbx1 = new Div();
	vbx1.setParent(irow);

	desb = (itype == 0) ? gpMakeTextbox(vbx1,"", ival[0], kb, "99%") : gpMakeLabel(vbx1,"",ival[0],jb);
	gpMakeSeparator(2,"2px",vbx1);

	hbm = new Hbox();
	hbm.setParent(vbx1);

	spcs = (itype == 0) ? gpMakeTextbox(hbm,"", ival[1], kb, "240px") : gpMakeLabel(hbm,"", ival[1],kb);
	if(spcs instanceof Textbox)
	{
		spcs.setMultiline(true);
		spcs.setHeight("70px");
	}

	// 15/04/2014: extra boxes for RAM,HDD,etc
	grd2 = new Grid();
	grd2.setParent(hbm);
	rows2 = new Rows();
	rows2.setParent(grd2);

	rw = gridhand.gridMakeRow("","","",rows2);
	gpMakeLabel(rw,"","HDD",kb);
	k = (itype == 0) ? gpMakeTextbox(rw,"",ival[2],kb,"99%") : gpMakeLabel(rw,"",ival[2],kb);

	rw = gridhand.gridMakeRow("","","",rows2);
	gpMakeLabel(rw,"","RAM",kb);
	k = (itype == 0) ? gpMakeTextbox(rw,"",ival[3],kb,"99%") : gpMakeLabel(rw,"",ival[3],kb);
/*
	rw = gridhand.gridMakeRow("","","",rows2);
	gpMakeLabel(rw,"","Monitor",kb);
	gpMakeTextbox(rw,"","",kb,"99%");
*/
	rw = gridhand.gridMakeRow("","","",rows2);
	gpMakeLabel(rw,"","OS",kb);
	ios = new Listbox();
	ios.setMold("select");
	ios.setStyle("font-size:9px;");
	ios.setParent(rw);
	luhand.populateListbox_ByLookup(ios, "OS_VERSION", 2);
	lbhand.matchListboxItems(ios, kiboo.checkNullString(ival[4]) );

	rw = gridhand.gridMakeRow("","","",rows2);
	gpMakeLabel(rw,"","MSOFFICE",kb);
	mso = new Listbox();
	mso.setMold("select");
	mso.setStyle("font-size:9px;");
	mso.setParent(rw);
	luhand.populateListbox_ByLookup(mso, "APPS_VERSION", 2);
	lbhand.matchListboxItems(mso, kiboo.checkNullString(ival[5]) );

	k = (itype == 0) ? gpMakeTextbox(irow,"",ival[6],jb,"90%") : gpMakeLabel(irow,"",ival[6],jb); // qty
	k = (itype == 0) ? gpMakeTextbox(irow,"",ival[7],jb,"90%") : gpMakeLabel(irow,"",ival[7],jb); // unit price
	k = (itype == 0) ? gpMakeTextbox(irow,"",ival[8],jb,"90%") : gpMakeLabel(irow,"",ival[8],jb); // rental period
	k = (itype == 0) ? gpMakeTextbox(irow,"",ival[9],jb,"90%") : gpMakeLabel(irow,"",ival[9],jb); // discount

	gpMakeLabel(irow,"","","font-weight:bold;"); // sub-total
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
	idesc = ispecs = iqty = idisc = iupr = irp = ihdd = irams = ios = imso = imoni = "";

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();

		dv1 = c1[1].getChildren().toArray();
		idesc += kiboo.replaceSingleQuotes( dv1[DESC_IX].getValue().replaceAll("~"," ") ) + "~";

		ksp = dv1[SPEC_IX].getChildren().get(0);
		ispecs += kiboo.replaceSingleQuotes( ksp.getValue().replaceAll("~"," ") ) + "~";

		// 15/04/2014: process the hdd,ram,etc
		kg = dv1[SPEC_IX].getChildren().get(1).getChildren().get(0).getChildren().toArray(); // BADBAD hardcoded way to get the grid->rows
		for(j=0; j<kg.length; j++)
		{
			trr = kg[j].getChildren().toArray();
			lb = trr[0].getValue();

			if(lb.equals("HDD"))
			{
				ihdd += kiboo.replaceSingleQuotes( trr[1].getValue().replaceAll("~"," ") ) + "~";
			}

			if(lb.equals("RAM"))
			{
				irams += kiboo.replaceSingleQuotes( trr[1].getValue().replaceAll("~"," ") ) + "~";
			}
/*
			if(lb.equals("Monitor"))
			{
				imoni += kiboo.replaceSingleQuotes( trr[1].getValue().replaceAll("~"," ") ) + "~";
			}
*/
			if(lb.equals("OS"))
			{
				ios += kiboo.replaceSingleQuotes( trr[1].getSelectedItem().getLabel().replaceAll("~"," ") ) + "~";
			}

			if(lb.equals("MSOFFICE"))
			{
				imso += kiboo.replaceSingleQuotes( trr[1].getSelectedItem().getLabel().replaceAll("~"," ") ) + "~";
			}
		}

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
	try { ihdd = ihdd.substring(0,ihdd.length()-1); } catch (Exception e) {}
	try { irams = irams.substring(0,irams.length()-1); } catch (Exception e) {}
	// try { imoni = imoni.substring(0,imoni.length()-1); } catch (Exception e) {}
	try { ios = ios.substring(0,ios.length()-1); } catch (Exception e) {}
	try { imso = imso.substring(0,imso.length()-1); } catch (Exception e) {}

	sqlstm = "update rw_quotations set q_items='" + idesc + "', q_items_desc='" + ispecs + "', q_qty='" + iqty + "', " +
	"q_unitprice='" + iupr + "', q_discounts='" + idisc + "', q_rental_periods='" + irp + "', q_rams='" + irams + "', q_hdd='" + ihdd + "', " +
	"q_operatingsystem='" + ios + "', q_office='" + imso + "' " +
	"where origid=" + iwhat;
	sqlhand.gpSqlExecuter(sqlstm);
	//alert(sqlstm);
}

// itype: 0=call from main, 1=call from other mods
void showQuoteMeta(String iwhat, int itype)
{
	qtr = getQuotation_rec(iwhat);
	glob_qt_rec = qtr; // for later
	if(qtr == null) { guihand.showMessageBox("DBERR: Cannot access quotations database"); return; }

	//q_origid.setValue(iwhat);
	Object[] uicomps = { customername, q_cust_address, q_contact_person1, q_telephone, q_fax, q_email, q_origid,
	q_creditterm, q_curcode, q_exchangerate, q_quote_discount, q_notes, q_qt_type, q_qt_validity, q_et_action, q_datecreated, q_version, q_order_type };

	String[] flds = { "customer_name", "cust_address", "contact_person1", "telephone", "fax", "email", "origid",
	"creditterm", "curcode", "exchangerate", "quote_discount", "notes", "qt_type", "qt_validity", "et_action","datecreated", "version", "order_type" };

	ngfun.populateUI_Data(uicomps, flds, qtr);
	showQT_items(qtr);
	calcQTItems();

	fillDocumentsList(documents_holder,QUOTE_PREFIX,iwhat);
	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb");
	jobnotes_div.setVisible(true);
	workarea.setVisible(true);

	// 17/10/2014: load and show jobs linked to QT. Future, 1 QT can have many jobs-entry
	kk = getJobs_byQuotation(iwhat);
	p_job_id.setValue(kk);

	if(itype == 1)
	{
		qtmainbox.setVisible(false);
		//blindTings_withTitle(blind_listarea,listarea_holder,listarea_header); // blindup the QTs LB
	}

	tt = false;
	if(qtr.get("qstatus").equals("COMMIT")) tt = true;

	toggQuoteButts(1,tt);
}

String getJobs_byQuotation(String iqt)
{
	sqlstm = "select origid from rw_jobs where quote_id=" + iqt;
	r = sqlhand.gpSqlGetRows(sqlstm);
	retv = "";
	if(r.size() > 0)
	{
		for(d : r)
		{
			retv += d.get("origid") + ", ";
		}
		try { retv = retv.substring(0,retv.length()-2); } catch (Exception e) {}
	}
	return retv;
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

		irams = sqlhand.clobToString(irec.get("q_rams")).split("~");
		ihdd = sqlhand.clobToString(irec.get("q_hdd")).split("~");
		ios = sqlhand.clobToString(irec.get("q_operatingsystem")).split("~");
		imso = sqlhand.clobToString(irec.get("q_office")).split("~");

		qst = irec.get("qstatus");
		fb = "font-weight:bold;";
		ArrayList kabom = new ArrayList();

		for(i=0; i<idesc.length; i++)
		{
			nrw = new org.zkoss.zul.Row();
			nrw.setParent(qtitems_rows);

			tdesc = "";
			try { tdesc = idesc[i]; } catch (Exception e) {}
			kabom.add(tdesc);

			ispcs = "";
			try { ispcs = ispec[i]; } catch (Exception e) {}
			kabom.add(ispcs);

			jhdd = "";
			try { jhdd = ihdd[i]; } catch (Exception e) {}
			kabom.add(jhdd);

			jram = "";
			try { jram = irams[i]; } catch (Exception e) {}
			kabom.add(jram);

			jios = "";
			try { jios = ios[i]; } catch (Exception e) {}
			kabom.add(jios);

			jmso = "";
			try { jmso = imso[i]; } catch (Exception e) {}
			kabom.add(jmso);

			qtys = "";
			try { qtys = iqty[i]; } catch (Exception e) {}
			kabom.add(qtys);

			upric = "";
			try { upric = iupr[i]; } catch (Exception e) {}
			kabom.add(upric);

			tper = "";
			try { tper = iper[i]; } catch (Exception e) {}
			kabom.add(tper);

			disct = "";
			try { disct = idisc[i]; } catch (Exception e) {}
			kabom.add(disct);

			makeNewQuoteItemRow(nrw, kabom.toArray(), (qst.equals("DRAFT")) ? 0 : 1);
			kabom.clear();
		}
	}
}

Object[] qtslb_hds =
{
	new listboxHeaderWidthObj("QT#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Q.Type",true,"80px"),
	new listboxHeaderWidthObj("Ord.Type",true,"80px"),
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
		glob_sel_qstatus = lbhand.getListcellItemLabel(isel,6);
		glob_sel_username = lbhand.getListcellItemLabel(isel,5);
		showQuoteMeta(glob_sel_quote,0);
	}
}
qtclicker = new qtlbclk();

// itype: 1=by date and search-text if any, 2=by QT, 3=by user
void listQuotations(int itype)
{
	last_listqt_type = itype;
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	bqt = kiboo.replaceSingleQuotes(byqt_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	byu = byuser_lb.getSelectedItem().getLabel();
	Listbox newlb = lbhand.makeVWListbox_Width(quotes_holder, qtslb_hds, "quotations_lb", 5);

	scsql = "";

	switch(itype)
	{
		case 1: // by date and search-text if any
			scsql = "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

			if(!scht.equals(""))
				scsql += "and (customer_name like '%" + scht + "%' " + 
				"or cast(q_items as varchar(max)) like '%" + scht + "%') ";

			break;

		case 2: // by QT
			scsql = "where origid=" + bqt;
			break;

		case 3: // by user
			scsql = "where username='" + byu + "' ";
			break;
	}

	sqlstm = "select origid,datecreated,customer_name,username,qstatus,qt_type,qt_validity,order_type from rw_quotations " + scsql;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;

	rws = (screcs.size() < 20) ? screcs.size() : 20;
	newlb.setRows(rws); newlb.setMold("paging"); newlb.setMultiple(true);
	newlb.addEventListener("onSelect", qtclicker );
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "customer_name", "qt_type", "order_type", "username", "qstatus", "qt_validity" }; 
	for(d : screcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// -- Cold-call related
void popColdCallContacts_combo(Object tcombo)
{
	sqlstm = "select distinct cust_name from rw_activities_contacts;";
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add(d.get("cust_name"));
	}
	gridhand.makeComboitem(tcombo, kiboo.convertArrayListToStringArray(kabom) );
}

void importColdCallDetails(String iwho)
{
	impcoldcal_pop.close();
	k = kiboo.replaceSingleQuotes(iwho.trim());
	if(k.equals("")) return;
	sqlstm = "select contact_person, cust_address1, cust_address2, cust_address3, cust_address4, cust_tel, cust_fax, cust_email " +
	"from rw_activities_contacts " +
	"where cust_name='" + k + "'";

	r = sqlhand.gpSqlFirstRow(sqlstm);
	if(r == null) return;

	locstr = kiboo.checkNullString(r.get("cust_address1")) + ",\n" + kiboo.checkNullString(r.get("cust_address2")) + ",\n" +
	kiboo.checkNullString(r.get("cust_address3")) + ",\n" + kiboo.checkNullString(r.get("cust_address4"));

	locstr = locstr.replaceAll(",,",",");
	q_cust_address.setValue(locstr);
	q_contact_person1.setValue( kiboo.checkNullString(r.get("contact_person")) );
	q_telephone.setValue( kiboo.checkNullString(r.get("cust_tel")) );
	q_fax.setValue( kiboo.checkNullString(r.get("cust_fax")) );
	q_email.setValue( kiboo.checkNullString(r.get("cust_email")) );

	global_selected_customer = k;
	global_selected_customerid = "";
	customername.setValue(global_selected_customer);
}
