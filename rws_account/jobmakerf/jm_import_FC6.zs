// JobMaker: import things from FC6 funcs
// 17/10/2014: put in

// itype: 1=ROC, 2=SO
boolean impFC6_SOROC_items(String ivn, String ijob, int itype)
{
	kk = kiboo.replaceSingleQuotes( ivn.trim() );
	if(kk.equals("")) return false;

	vtype = "5635"; // ROC
	exttb = "u011b";
	switch(itype)
	{
		case 2:
			vtype = "5632";
			exttb = "u0117";
			break;
	}

	// 17/08/2015: FC6 table mangled, indta.input0 = quantity, indta.quantity=rental period
	sqlstm = "select ro.name as product_name, u.spec1yh, u.spec2yh, iy.gross,iy.stockvalue, cast((iy.input0) as int) as unitqty, iy.rate as perunit, " +
	"(iy.quantity*-1) as rentperiod, iy.output2 as mthtotal from data d " +
	"left join mr008 ro on ro.masterid = d.tags6 left join indta iy on iy.salesid = d.salesoff " +
	"left join " + exttb + " u on u.extraid = d.extraoff " +
	"where d.vouchertype=" + vtype + " and d.voucherno='" + kk + "' order by d.bodyid";

	trs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return false;

	itms = qtys = rperiod = rpunit = colors = "";

	for(d : trs)
	{
		itms += kiboo.checkNullString(d.get("product_name")).trim() + "\n" +
		kiboo.checkNullString(d.get("spec1yh")).trim() + "\n" +
		kiboo.checkNullString(d.get("spec2yh")).trim() + "::";
		qtys += d.get("unitqty").toString() + "::";
		rperiod += d.get("rentperiod").toString() + "::";
		rpunit += d.get("perunit").toString() + "::";
	}

	sqlstm = "update rw_jobs set items='" + itms + "', qtys='" + qtys + "', rental_periods='" + 
	rperiod + "', rent_perunits='" + rpunit + "', colors='' where origid=" + ijob;

	sqlhand.gpSqlExecuter(sqlstm);
	return true;
}

// itype: 1=ROC, 2=SO
// 17/07/2014: prob with eta/etd, need to put some checks and modifs
boolean impFC6_SOROC_record(String ivn, String ijob, int itype)
{
	ivn = kiboo.replaceSingleQuotes( ivn.trim() );
	if(ivn.equals("")) return false;

	sqlstm = "";
	vtype = "5635"; // ROC
	exttb = "u001b";
	otype = "li.ordertypeyh";
	dto = "li.deliverytoyh as deliverytoyh,";

	switch(itype)
	{
		case 2: // SO
			vtype = "5632";
			exttb = "u0017";
			otype = "'USED' as ordertypeyh";
			dto = "li.delivertoyh as deliverytoyh,";
			break;
	}

	sqlstm = "select distinct d.voucherno, d.bookno, " +
	"ac.name as customer_name, aci.telyh, aci.contactyh, aci.emailyh, li.customerrefyh, li.opsnoteyh as deliverynotes, " +
	"li.remarksyh, " + otype + "," + dto +
	"case li.etdyh when 0 then null else convert(datetime, dbo.ConvertFocusDate(li.etdyh), 112) end as etd, " +
	"case li.etayh when 0 then null else convert(datetime, dbo.ConvertFocusDate(li.etayh), 112) end as eta " +
	"from data d left join mr000 ac on ac.masterid = d.bookno " +
	"left join u0000 aci on aci.extraid=ac.masterid " +
	"left join " + exttb + " li on li.extraid = d.extraheaderoff " +
	"left join header hh on hh.headerid = d.headeroff " +
	"where d.vouchertype=" + vtype + " and d.voucherno='" + ivn + "'";

	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null) return false;

	etastr = (r.get("eta") == null) ? "eta=''," : ("eta='" + r.get("eta") + "',");
	etdstr = (r.get("etd") == null) ? "etd=''," : ("etd='" + r.get("etd") + "',");

	i_deladdress = kiboo.replaceSingleQuotes( r.get("deliverytoyh") );
	i_remarks = kiboo.replaceSingleQuotes( r.get("remarksyh") );
	i_notes = kiboo.replaceSingleQuotes( r.get("deliverynotes") );

	sqlstm = "update rw_jobs set rwroc='" + r.get("voucherno") + "', fc6_custid=" + r.get("bookno").toString() + ", customer_name='" + r.get("customer_name") + "'," +
	"notes='" + i_notes + "\n" + i_remarks + "\n" + r.get("ordertypeyh") + "', deliver_address='" + i_deladdress + "'," +
	etastr + etdstr +
	"contact='" + kiboo.checkNullString(r.get("contactyh")) + "'," +
	"contact_tel='" + kiboo.checkNullString(r.get("telyh")) + "'," +
	"contact_email='" + kiboo.checkNullString(r.get("emailyh")) + "', cust_ref='" + r.get("customerrefyh") + "' where origid=" + ijob;

	sqlhand.gpSqlExecuter(sqlstm);
	return true;
}

void impFC6_SOROC(int itype, Object itb)
{
	if(glob_sel_job.equals("")) return;
	kk = itb.getValue();
	errmsg = "ERR: cannot import data from Focus6";

	if(impFC6_SOROC_record(kk, glob_sel_job, itype)) // can import fc6.voucher -- continue import items
	{
		if(!impFC6_SOROC_items(kk, glob_sel_job, itype))
		{
			guihand.showMessageBox(errmsg);
		}
	}
	else
		guihand.showMessageBox(errmsg);

	showJobs();
	showJobMetadata(glob_sel_job);
}

void impRWMS_CSV(String isv)
{
	if(glob_sel_job.equals("")) return;
	isv = kiboo.replaceSingleQuotes(isv);
	if(isv.equals("")) return;

	r = getHelpTicket_rec(isv);
	if(r == null)
	{
		guihand.showMessageBox("ERR: cannot load customer service-ticket!!");
		return;
	}

	String[] flds = { "cust_name", "cust_caller", "cust_caller_phone", "cust_caller_email", "cust_location", "action", "fc6_custid" };
	Object[] jkl = { customername, j_contact, j_contact_tel, j_contact_email, j_deliver_address, j_do_notes, j_fc6_custid };
	ngfun.populateUI_Data(jkl, flds, r);

	lbhand.matchListboxItems(j_jobtype,"RMA"); // auto select RMA job-type

	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	checkMakeItemsGrid();
	glob_icomponents_counter = 1; // reset for new grid
	kk = "font-size:9px;font-weight:bold;";

	// these codes knockoff from jobmaker_funcs.showJobItems() - 06/11/2014: only 1 asset-tag imported from CSV
	cmid = glob_icomponents_counter.toString();
	irow = gridhand.gridMakeRow("IRW" + cmid ,"","",items_rows);
	gpMakeCheckbox(irow,"CBX" + cmid, cmid + ".", kk + "font-size:14px");

	jtm = r.get("product_name") + "\n" + "(Original: " + r.get("asset_tag") + " SN: " + r.get("serial_no") + ")\n" +
	r.get("problem") + "\n" + r.get("action") + "\n" + r.get("resolve_type");

	desb = gpMakeTextbox(irow,"IDE" + glob_icomponents_counter.toString(),jtm,kk,"99%");
	desb.setMultiline(true); desb.setHeight("70px"); desb.setDroppable("true");
	//desb.addEventListener("onDrop",new dropModelName());

	gpMakeTextbox(irow,"ICL" + cmid ,"", kk,"99%"); // color
	gpMakeTextbox(irow,"IQT" + cmid,"1",kk,"99%"); // qty
	gpMakeTextbox(irow,"IRP" + cmid,"0",kk,"99%"); // rental-period
	gpMakeTextbox(irow,"IRU" + cmid,"0",kk,"99%"); // rental per unit
	gpMakeLabel(irow,"MON" + cmid,"",kk); // per month total
	gpMakeLabel(irow,"RTO" + cmid,"",kk); // rental all total

	glob_icomponents_counter++;

	doFunc(updatejob_b); // save things
	jobItems(ji_save_b);
}

void impRWMS_QT(String iqt)
{
	if(glob_sel_job.equals("")) return;
	iqt = kiboo.replaceSingleQuotes( iqt );
	if(iqt.equals("")) return;
	qtr = getQuotation_rec(iqt);

	// NOTE rw_quotation.qt_type must map to job-type TODO
	String[] flds = { "customer_name", "contact_person1", "telephone", "email", "cust_address", "notes" };
	Object[] jkl = { customername, j_contact, j_contact_tel, j_contact_email, j_deliver_address, j_do_notes };
	ngfun.populateUI_Data(jkl, flds, qtr);

	ktg = sqlhand.clobToString(qtr.get("q_items"));
	if(ktg.equals("")) { guihand.showMessageBox("No items to import.."); return; }

	idesc = sqlhand.clobToString(qtr.get("q_items")).split("~");
	//ispec = sqlhand.clobToString(qtr.get("q_items_desc")).split("~");
	iqty = sqlhand.clobToString(qtr.get("q_qty")).split("~");
	iupr = sqlhand.clobToString(qtr.get("q_unitprice")).split("~");
	//idisc = sqlhand.clobToString(qtr.get("q_discounts")).split("~");
	iper = sqlhand.clobToString(qtr.get("q_rental_periods")).split("~");
	irams = sqlhand.clobToString(qtr.get("q_rams")).split("~");
	ihdd = sqlhand.clobToString(qtr.get("q_hdd")).split("~");
	ios = sqlhand.clobToString(qtr.get("q_operatingsystem")).split("~");
	imso = sqlhand.clobToString(qtr.get("q_office")).split("~");

	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	checkMakeItemsGrid();
	glob_icomponents_counter = 1; // reset for new grid
	kk = "font-size:9px;font-weight:bold;";

	for(i=0; i<idesc.length; i++) // imp qt items
	{
		try { p1 = irams[i]; } catch (Exception e) { p1 = "NONE"; }
		try { p2 = ihdd[i]; } catch (Exception e) { p2 = "NONE"; }
		try { p3 = ios[i]; } catch (Exception e) { p3 = "NONE"; }
		try { p4 = imso[i]; } catch (Exception e) { p4 = "NONE"; }

		jtm = idesc[i] + "\n" + p1 + "/" + p2 + "/" + p3 + "/" + p4;

		// these codes knockoff from jobmaker_funcs.showJobItems()
		cmid = glob_icomponents_counter.toString();
		irow = gridhand.gridMakeRow("IRW" + cmid ,"","",items_rows);
		gpMakeCheckbox(irow,"CBX" + cmid, cmid + ".", kk + "font-size:14px");

		desb = gpMakeTextbox(irow,"IDE" + glob_icomponents_counter.toString(),jtm,kk,"99%");
		desb.setMultiline(true); desb.setHeight("70px"); desb.setDroppable("true");
		//desb.addEventListener("onDrop",new dropModelName());

		gpMakeTextbox(irow,"ICL" + cmid ,"", kk,"99%"); // color
		gpMakeTextbox(irow,"IQT" + cmid,iqty[i],kk,"99%"); // qty
		gpMakeTextbox(irow,"IRP" + cmid,iper[i],kk,"99%"); // rental-period
		gpMakeTextbox(irow,"IRU" + cmid,iupr[i],kk,"99%"); // rental per unit
		gpMakeLabel(irow,"MON" + cmid,"",kk); // per month total
		gpMakeLabel(irow,"RTO" + cmid,"",kk); // rental all total
		glob_icomponents_counter++;
	}

	jobItems(ji_calc_b); // Do items total/rental calcs

	// get fc6_id by customer-name in QT and save into rw_jobs.fc6_custid
	cnm = kiboo.checkNullString( qtr.get("customer_name") ).trim();
	fc6 = (cnm.equals("")) ? "" : getFocus_CustomerID(cnm);
	j_fc6_custid.setValue(fc6); // hidden element defi in XML-form(5)

	// update rw_jobs.quote_id. fc6_custid, let doFunc() handle it
	sqlstm = "update rw_jobs set quote_id=" + iqt + " where origid=" + glob_sel_job;
	sqlhand.gpSqlExecuter(sqlstm);
}
