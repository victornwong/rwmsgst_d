/**
 * Inject invoice into FOCUS6 - knockoff some codes from inject-DO , headers and other house-keeping
 * Take note of the hard-coded column names in all tables
 * Knock-up by Victor Wong
 * 
 * 	"select @domaxid=Max(VoucherNo)+1 from header with (ReadUnCommitted) " +
 *	"where VoucherType=" + DO_VOUCHERTYPE + " and len(VoucherNo) = (select Max(len(VoucherNo)) from header " +
 *	"with (ReadUnCommitted) where VoucherType=" + DO_VOUCHERTYPE + ");" +
 */

// Can customized these for other type of voucher, must check against vtypes and custflds

// FCVOUCHER_PREFIX = "'RW'"; // 0J0 only got prefix
FCVOUCHER_PREFIX = "";
VOUCHERTYPE = "3329"; // rental-invoice voucher type as defn in vtypes
EXTRAHEADEROFF_TBL = "u001b"; // rental-invoice extra header details table
EXTRAOFF_TBL = "u011b"; // rental-invoice extra item details table

INVINJ_EXTRAHEADEROFF_POS = 1;

/**
 * Inject rental-invoice header into FOCUS6
 * @param hdv hold return rec numbers from sql insert
 * hdv[0] = header.headerid
 * hdv[1] = EXTRAHEADEROFF_TBL.extraid = voucher header details offset
 * hdv[3] = the inserted rental-invoice voucher no. eg: RW12345
 */
void inject_Invoice_Headers(String[] hdv)
{
	kdate = calcFocusDate(kiboo.todayISODateString());
	FCVOUCHER_PREFIX = (TESTING_MODE) ? "'RW'" : "";
	lgn = "upload" + Math.round(Math.random() * 100).toString();

	grabnextno = "declare @domaxid varchar(20);" +
	"select @domaxid=Max(VoucherNo)+1 from header with (ReadUnCommitted) " +
 	"where VoucherType=" + VOUCHERTYPE + " and len(VoucherNo) = (select Max(len(VoucherNo)) from header " +
 	"with (ReadUnCommitted) where VoucherType=" + VOUCHERTYPE + ");";

	if(TESTING_MODE) grabnextno = "declare @domaxid varchar(20);" +
	"select @domaxid=" + FCVOUCHER_PREFIX + " + cast( (cast(substring((select Max(VoucherNo) from header with (ReadUnCommitted) " +
	"where VoucherType=" + VOUCHERTYPE + " and len(VoucherNo) = (select Max(len(VoucherNo)) from header " +
	"with (ReadUnCommitted) where VoucherType=" + VOUCHERTYPE + ")),3,10) as integer)+1) as varchar);";

	// data.headeroff = header.headerid
	sqlstm1 = grabnextno +

	"insert into header (" +
	"id, version, noentries, tnoentries, login, date_, time_," +
	"flags, flags2, defcurrency," +
	"vouchertype, voucherno, approvedby0, approvedby1, approvedby2) values (" +
	"0x0000, 0x5b, 0, 0, '" + lgn + "', " + kdate + ", 0x0a3b00," +
	"0x0027, 6208, 0x00," +
	VOUCHERTYPE + ", @domaxid, 30, 0, 0 );";

	if(TESTING_MODE) f30_gpSqlExecuter(sqlstm1);
	else sqlhand.rws_gpSqlExecuter(sqlstm1);

	sqlstm2 = "select headerid,voucherno from header where login='" + lgn + "';"; // get inserted header.headerid
	r = (TESTING_MODE) ? f30_gpSqlFirstRow(sqlstm2) : sqlhand.rws_gpSqlFirstRow(sqlstm2);
	hdv[0] = r.get("headerid").toString();
	hdv[3] = r.get("voucherno");

	sqlstm3 = "update header set login='su' where headerid=" + hdv[0];
	if(TESTING_MODE) f30_gpSqlExecuter(sqlstm3);
	else sqlhand.rws_gpSqlExecuter(sqlstm3);

	sqlstm4 = "declare @maxid int; set @maxid = (select max(extraid)+1 from " + EXTRAHEADEROFF_TBL + "); " +
	"insert into " + EXTRAHEADEROFF_TBL + " (extraid,RemarksYH,CustomerRefYH,ROCNoYH,DORefYH) " +
	"values (@maxid,'" + lgn + "','','','');";

	if(TESTING_MODE) f30_gpSqlExecuter(sqlstm4);
	else sqlhand.rws_gpSqlExecuter(sqlstm4);

	sqlstm5 = "select extraid from " + EXTRAHEADEROFF_TBL + " where RemarksYH='" + lgn + "';";
	r = (TESTING_MODE) ? f30_gpSqlFirstRow(sqlstm5) : sqlhand.rws_gpSqlFirstRow(sqlstm5);
	hdv[INVINJ_EXTRAHEADEROFF_POS] = r.get("extraid").toString();

}

/**
 * Inject rental-invoice, uses previous rental-invoice for header-details and items duplication
 * @param  prev_invoice previous rental-invoice to dup them items
 * @return              rental-invoice voucher no. or "ERROR" if cannot find previous rental-invoice
 */
String inject_RentalInvoice(String prev_invoice, String[] pInjectDetails)
{
	kdate = calcFocusDate(kiboo.todayISODateString());
	String[] headvals = new String[4];

	// get extraheaderoff from previous rental-invoice
	sqlstm = "select extraheaderoff from data where vouchertype=" + VOUCHERTYPE + " and voucherno='" + prev_invoice + "';";
	r = (TESTING_MODE) ? f30_gpSqlFirstRow(sqlstm) : sqlhand.rws_gpSqlFirstRow(sqlstm);
	
	if(r != null) // got the previous rental-invoice extraheaderoff
	{
		prw_extraheaderoff = r.get("extraheaderoff").toString();
		inject_Invoice_Headers(headvals); // inject rental invoice header

		if(TESTING_MODE) debugbox.setValue(headvals[0] + " :: " + headvals[1] + " :: " + headvals[2] + " :: " + headvals[3]);

		// dup invoice header details from previous invoice
		sqlstm = "update " + EXTRAHEADEROFF_TBL + " set RemarksYH = i.RemarksYH, CustomerRefYH = i.CustomerRefYH, ROCNoYH = i.ROCNoYH, DORefYH = i.DORefYH," +
		"ETAYH = i.ETAYH, ETDYH = i.ETDYH, OPSNoteYH = i.OPSNoteYH, PrepaidRentalYH = i.PrepaidRentalYH, RentalPaidYH = i.RentalPaidYH, " +
		"OrderTypeYH = i.OrderTypeYH, DepositAmtYH = i.DepositAmtYH, DepositRemarksYH = i.DepositRemarksYH, DeliveryToYH = i.DeliveryToYH, " +
		"InstTypeYH = i.InstTypeYH, LCNoYH = i.LCNoYH, WitnessYH = i.WitnessYH, Signatory1YH = i.Signatory1YH, Designation1YH = i.Designation1YH, " +
		"Designation2YH = i.Designation2YH, ReservationNoYH = i.ReservationNoYH, LCStatusYH = i.LCStatusYH, DeliveryDtYH = i.DeliveryDtYH, " +
		"NoofInstallmentYH = i.NoofInstallmentYH, FinancePICYH = i.FinancePICYH, ProjectPICYH = i.ProjectPICYH, ProjectSiteYH = i.ProjectSiteYH " +
		"from (select RemarksYH,CustomerRefYH,ROCNoYH,DORefYH,ETAYH,ETDYH,OPSNoteYH,PrepaidRentalYH,RentalPaidYH, " +
		"OrderTypeYH,DepositAmtYH,DepositRemarksYH,DeliveryToYH,InstTypeYH,LCNoYH,WitnessYH,Signatory1YH,Designation1YH, " +
		"Designation2YH,ReservationNoYH,LCStatusYH,DeliveryDtYH,NoofInstallmentYH,FinancePICYH,ProjectPICYH,ProjectSiteYH " +
		"from " + EXTRAHEADEROFF_TBL + " where extraid=" + prw_extraheaderoff + ") i where extraid=" + headvals[INVINJ_EXTRAHEADEROFF_POS];

		if(TESTING_MODE) f30_gpSqlExecuter(sqlstm);
		else sqlhand.rws_gpSqlExecuter(sqlstm);

		sqlstm2 = "select * from data where vouchertype=" + VOUCHERTYPE + " and voucherno='" + prev_invoice + "';"; // get entries from prev invoice
		prevdata = (TESTING_MODE) ? f30_gpSqlGetRows(sqlstm2) : sqlhand.rws_gpSqlGetRows(sqlstm2);

		if(prevdata.size() > 0) // got some rec from previous invoice - can work on them
		{
			indatasql = "";
			linecount = 0;
			for(pd : prevdata)
			{

				if(pd.get("SalesOff") == null) continue; // continue to next line item

				kksql = "";
				try { kksql = "select * from indta where salesid=" + pd.get("SalesOff").toString(); } // get prev indta rec
				catch (Exception e) { alert("tostring1"); }

				p = (TESTING_MODE) ? f30_gpSqlFirstRow(kksql) : sqlhand.rws_gpSqlFirstRow(kksql);
				if(p != null) // got prev indta rec
				{
					kksql = "select max(salesid)+1 as nextsalesid from indta;"; // get next indta.salesid no.
					n = (TESTING_MODE) ? f30_gpSqlFirstRow(kksql) : sqlhand.rws_gpSqlFirstRow(kksql);

					nextsalesid = "";
					try {	nextsalesid = n.get("nextsalesid").toString(); } catch (Exception e) { alert("tostring2"); }

					sqlstm3 = "insert into indta (" +
					"SalesId,Quantity,StockValue,Rate,Gross,Qty2,SubProcess,Unit," +
					"Input0,Output0,Input1,Output1,Input2,Output2,Input3,Output3,Input4,Output4,Input5,Output5," +
					"Input6,Output6,Input7,Output7,Input8,Output8,Input9,Output9,Input10,Output10,Input11,Output11," +
					"Input12,Output12,Input13,Output13,Input14,Output14,Input15,Output15,Input16,Output16,Input17,Output17," +
					"Input18,Output18,Input19,Output19) values (" +
					nextsalesid + "," + p.get("Quantity") + "," + p.get("StockValue") + "," + p.get("Rate") + "," + p.get("Gross") + "," + p.get("Qty2") + "," + p.get("SubProcess") + ",0x00," +
					p.get("Input0") + "," + p.get("Output0") + "," + p.get("Input1") + "," + p.get("Output1") + "," + p.get("Input2") + "," + p.get("Output2") + "," +
					p.get("Input3") + "," + p.get("Output3") + "," + p.get("Input4") + "," + p.get("Output4") + "," + p.get("Input5") + "," + p.get("Output5") + "," +
					p.get("Input6") + "," + p.get("Output6") + "," + p.get("Input7") + "," + p.get("Output7") + "," + p.get("Input8") + "," + p.get("Output8") + "," +
					p.get("Input9") + "," + p.get("Output9") + "," + p.get("Input10") + "," + p.get("Output10") + "," + p.get("Input11") + "," + p.get("Output11") + "," +
					p.get("Input12") + "," + p.get("Output12") + "," + p.get("Input13") + "," + p.get("Output13") + "," + p.get("Input14") + "," + p.get("Output14") + "," +
					p.get("Input15") + "," + p.get("Output15") + "," + p.get("Input16") + "," + p.get("Output16") + "," + p.get("Input17") + "," + p.get("Output17") + "," +
					p.get("Input18") + "," + p.get("Output18") + "," + p.get("Input19") + "," + p.get("Output19") + ");";

					// insert new indta(data.salesoff) rec by copying from prev invoice indta
					if(TESTING_MODE) f30_gpSqlExecuter(sqlstm3);
					else sqlhand.rws_gpSqlExecuter(sqlstm3);
					
					nextextraoff = "0";
					kksql = "select * from " + EXTRAOFF_TBL + " where extraid=" + pd.get("ExtraOff");
					er = (TESTING_MODE) ? f30_gpSqlFirstRow(kksql) : sqlhand.rws_gpSqlFirstRow(kksql);
					if(er != null)
					{
						kksql = "select max(extraid)+1 as nextextraid from " + EXTRAOFF_TBL;
						nid = (TESTING_MODE) ? f30_gpSqlFirstRow(kksql) : sqlhand.rws_gpSqlFirstRow(kksql);

						nextextraoff = "";
						try { nextextraoff = nid.get("nextextraid").toString(); } catch (Exception e) { alert("tostring3"); }

						// insert new data.extraoff record with data copied from prev invoice, rental-invoice = u011b
						sqlstm4 = "insert into " + EXTRAOFF_TBL + " (ExtraId,Spec1YH,Spec2YH,ContractStartYH,DiemStartYH,SplRemarksYH,ContractEndYH,TotalDiffDaysYH,DaysYH) values (" +
						nextextraoff + ",'" + er.get("Spec1YH") + "','" + er.get("Spec2YH") + "'," + er.get("ContractStartYH") + ",'" + er.get("DiemStartYH") + "','" +
						er.get("SplRemarksYH") + "'," + er.get("ContractEndYH") + "," + er.get("TotalDiffDaysYH") + "," + er.get("DaysYH") + ");";

						if(TESTING_MODE) f30_gpSqlExecuter(sqlstm4);
						else sqlhand.rws_gpSqlExecuter(sqlstm4);
					}

					// dup invoice items from previous invoice
					insql = "declare @dmaxid int; set @dmaxid = (select max(bodyid)+1 from data); " +
					"insert into data (" +
					"bodyid, date_, vouchertype, voucherno, bookno, productcode," +
					"tags0, tags1, tags2, tags3, amount1, amount2, originalamount, flags, billwiseoff, links0, tags6," +
					"headeroff, extraoff, extraheaderoff, salesoff," +
					"code, duedate, sizeofrec, links1, links2, links3, linktoprbatch, exchgrate, tags4, tags5, tags7, " +
					"binnoentries, reserveno, reservetype) values (" +
					"@dmaxid," + kdate + "," + VOUCHERTYPE + ",'" + headvals[3] + "'," + pd.get("BookNo") + "," + pd.get("ProductCode") + "," +
					pd.get("Tags0") + "," + pd.get("Tags1") + "," + pd.get("Tags2") + "," + pd.get("Tags3") + "," +
					pd.get("Amount1") + "," + pd.get("Amount2") + "," + pd.get("OriginalAmount") + ",2622464,0,0," + pd.get("Tags6") + "," +
					headvals[0] + "," + nextextraoff + "," + headvals[INVINJ_EXTRAHEADEROFF_POS] + "," + nextsalesid + "," +
					pd.get("Code") + "," + kdate + "," + pd.get("SizeofRec") + "," + pd.get("Links1") + "," + pd.get("Links2") + "," +
					pd.get("Links3") + "," + pd.get("LinkToPrBatch") + "," + pd.get("ExchgRate") + "," +
					pd.get("Tags4") + "," + pd.get("Tags5") + "," + pd.get("Tags7") + "," +
					pd.get("BinNoEntries") + "," + pd.get("ReserveNo") + "," + pd.get("ReserveType") + ");";

					// insert new invoice row using headers returned by inject_Invoice_Headers and salesoff from newly inserted
					if(TESTING_MODE) f30_gpSqlExecuter(insql);
					else sqlhand.rws_gpSqlExecuter(insql);

					linecount++;
				}
			}

			updsql = "update header set noentries=" + linecount.toString() + ", tnoentries=" + linecount.toString() +
			" where headerid=" + headvals[0] + ";"; // update no. lines in header

			if(TESTING_MODE) f30_gpSqlExecuter(updsql);
			else sqlhand.rws_gpSqlExecuter(updsql);
		}

		pInjectDetails[0] = headvals[0]; // store them headers offsets to be returned
		pInjectDetails[1] = headvals[1];
		pInjectDetails[2] = headvals[2];
		pInjectDetails[3] = headvals[3];

		return headvals[3]; // FOCUS rental-invoice voucher no. Note the index
	}
	return "ERROR";
}
