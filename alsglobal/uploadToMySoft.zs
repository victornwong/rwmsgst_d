// funcs to upload DO to mysoft -- used by billinguploaded_v1_2.zul and unbilledFolders_v1.zul
// check 'em global vars being used

// Actual func to inject a rec into DeliveryOrderMaster
// 10/2/2010: version 1
void injectDeliveryOrderMaster(String ifoldno, Object ifolderRec, Object icompanyRec)
{
	todaysdate = kiboo.todayISODateString();
	thearcode = ifolderRec.get("ar_code");

	compname = icompanyRec.get("customer_name");
	attention = icompanyRec.get("contact_person1");
	addr1 = icompanyRec.get("address1");
	addr2 = icompanyRec.get("address2");
	addr3 = icompanyRec.get("address3");
	currcode = icompanyRec.get("CurCode");
	cterms = icompanyRec.get("credit_period");
	salesmancode = icompanyRec.get("Salesman_code");

	sqlstm = "insert into DeliveryOrderMaster (VoucherNo,DONo,DeliveryDate,Code,Name,Attention,Address1,Address2,Address3," +
	"PurchaseOrder,SalesOrderNo,InvoiceNo,IssuedInvoice,ReferenceNo,SalesMan,Terms,Remark,DiscountRate,Discount,Printed,Status," +
	"EntryDate,User1,Imported,Warehouse,GrossAmount,NetAmount,CurCode,ExchangeRate,BaseRate,ForeignRate,ReturnStatus,TransType," +
	"LoanWarehouse,Cancel,DocumentType,NewField1,NewField2,NewField3,NewField4,NewField5,NewField6,NewField7,NewField8,NewField9,NewField10," +
	"ShippingPhone,ShippingContact,ShipName,ShipAddress1,ShipAddress2,ShipAddress3,Notes) " +
	"values " +
	"('" + ifoldno + "','" + ifoldno + "','" + todaysdate + "','" + thearcode + "','" + compname + "','" + attention + "','" + 
	addr1 + "','" + addr2 + "','" + addr3 + "'," +
	"'','','',0,'','" + salesmancode + "','" + cterms +"','',0,0,0,''," +
	"'" + todaysdate +"','Manager',0,'None',0,0,'" + currcode + "',1,1,1,0,'DO'," +
	"'',0,'DO','','','','','','','','','',''," +
	"'','','','','','','')";

	sqlhand.gpSqlExecuter(sqlstm);

} // end of injectDeliveryOrderMaster(ilbfold,companyRec)

// Inject entries into delivery order based on folderno which is the DONo
// isampquant = samples quantity rec, refer uploadToMySoft() for select command
// 10/02/2010: version 1
// 18/03/2011: inject more fields into the DO - deptcode , salesmancode
// 22/06/2011: add field UOM = 'SAMPLE'
// 03/08/2011: if jobtestparameters.packageprice is 0, use stockmasterdetails.selling_price
void injectDeliveryOrder(String ifoldno, Object isampquant, Object icompanyRec)
{
	mysoftcode = isampquant.get("mysoftcode").toString();
	quantity = isampquant.get("samplesquantity").toString();

	// get stockmasterdetails.nominal_code to be used for deliveryorder.salescode
	stockmasterRec = samphand.getStockMasterDetails(mysoftcode);

	if(stockmasterRec == null) return;

	salescode = stockmasterRec.get("Nominal_Code");
	stockcode = stockmasterRec.get("Stock_Code");
	stockdesc = stockmasterRec.get("Description");

	sellprice = stockmasterRec.get("Selling_Price").toString();

	// 03/08/2011: use jobtestparameters.packageprice if not 0, else use stockmasterdetails.selling_price
	packageprice = isampquant.get("packageprice");
	if(packageprice != null)
		if(packageprice != 0)
			sellprice = packageprice.toString(); 

	salesmancode = icompanyRec.get("Salesman_code");
	deptcode = icompanyRec.get("DeptCode");

	sqlstm = "insert into deliveryorder (DONo,stockcode,Description," + 
	"unitprice,quantity,salescode,TransType,DeptCode,SalesPerson,UOM) " +
	"values ('" + ifoldno + "','" + stockcode + "','" + stockdesc + "'," + 
	sellprice + "," + quantity + ",'" + salescode + "','DO','" + deptcode + "','" + salesmancode + "','SAMPLE')" ;

	sqlhand.gpSqlExecuter(sqlstm);

} // end of injectDeliveryOrder()
	
// Remove existing DO from DeliveryOrderMaster and DeliveryOrder
void removeExistingDO(String ifullfolderno, String ifoldno)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	// see if it really exsit
	sqlst = "select DONo from DeliveryOrderMaster where DONo='" + ifullfolderno + "'";
	ifounde = sql.firstRow(sqlst);

	// found a rec .. do the stuff
	if(ifounde != null)
	{
		// remove samples entry in DeliveryOrder
		sqlst2 = "delete from DeliveryOrder where DONo='" + ifullfolderno + "'";
		sql.execute(sqlst2);

		// remove DO rec from DeliveryOrderMaster
		sqlst3 = "delete from DeliveryOrderMaster where DONo='" + ifullfolderno + "'";
		sql.execute(sqlst3);

		// change jobfolders.uploadtomysoft flag
		sqlst4 = "update JobFolders set uploadToMYSOFT=0 where origid=" + ifoldno;
		sql.execute(sqlst4);
	}
	sql.close();
}

// 24/8/2010: inject courier-bill into DO
// use 311 = StockMasterDetails.ID - stockcode = FREIGHT CHARGES - hardcoded for ALS
// salescode = stockmasterdetails.nominal_code = 51100.740
void injectCourierBill(String ifolderno)
{
	// lookup any folder_link and not billed in Courier_Tracking first
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	sqlstm = "select origid,delivery_method,tracking_number,amount from Courier_Tracking where folder_link='" + ifolderno + "'";
	cobills = sql.rows(sqlstm);

	// some courier_tracking recs linking to folder and not billed
	if(cobills.size() != 0)
	{
		stockcode = "FREIGHT CHARGES";
		salescode = "51100.740";

		billdate = kiboo.getDateFromDatebox(hiddendatebox);

		for(dpi : cobills)
		{
			stockdesc = "FREIGHT CHARGES: " + dpi.get("delivery_method") + " Tracking#: " + dpi.get("tracking_number");

			DecimalFormat df = new DecimalFormat("#.##");
			sellprice = df.format(dpi.get("amount"));

			sqlstatem = "insert into deliveryorder (DONo,stockcode,Description,unitprice,quantity,salescode,TransType) " +
			"values ('" + ifolderno + "','" + stockcode + "','" + stockdesc + "'," + sellprice + ",1,'" + salescode + "','DO')" ;

			sql.execute(sqlstatem);

			// update courier_tracking billing fields
			sqlstm = "update Courier_Tracking set billed=1, billed_date='" + billdate + "' where origid=" + dpi.get("origid").toString();
			sql.execute(sqlstm);
		}
	}

	sql.close();

} // end of injectCourierBill()

void uploadToMysoft()
{
	if(selected_folderno.equals("")) return;
	if(!selected_folder_status.equals(FOLDERCOMMITED))
	{
		guihand.showMessageBox("Folder is not committed, cannot bill..");
		return;
	}

	ilbfold = selected_folderno; // lazy to change codes below.. hohoho
	foldno = selected_folder_origid;

	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	// get jobfolder rec
	folderRec = samphand.getFolderJobRec(foldno); // samplereg_funcs.zs
	the_arcode = folderRec.get("ar_code");

	// if already uploaded.. prompt for reupload
	if(folderRec.get("uploadToMYSOFT") == 1)
	{
		if (Messagebox.show(ilbfold + " is already uploaded to MySoft. Do you want to upload again?", "Are you sure?", 
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) ==  Messagebox.NO)
			return;
	}

	// delete existing DO with same folderno(DeliveryOrderMaster) and DO-items-entry(DeliveryOrder) first
	removeExistingDO(ilbfold,foldno);

	// collect samples origid
	sqlstatem = "select origid from jobsamples where deleted=0 and jobfolders_id=" + foldno;
	samprecs = sql.rows(sqlstatem);
	if(samprecs == null) { sql.close(); return; }

	// extract and made samples origid string
	sampstr = "(";
	for(kki : samprecs)
	{
		sampstr = sampstr + kki.get("origid") + ",";
	}
	// chop off extra , at the end
	ism = sampstr.substring(0,sampstr.length()-1);
	sampstr = ism + ")";

	// get mysoftcode * samples-quantity
	sqlstatem2 = "select distinct mysoftcode, count(origid) as samplesquantity, price, testpackageid, packageprice " + 
	"from jobtestparameters where jobsamples_id in " + sampstr + " group by mysoftcode,price,testpackageid,packageprice";

	sampquant = sql.rows(sqlstatem2);

	// get customer rec from ar_code in jobfolders -> customer table
	companyRec = sqlhand.getCompanyRecord(the_arcode); // alsglobal_sqlfuncs.zs

	// create entry in DeliveryOrderMaster - samples markings will be placed into DeliveryOrderMaster->Notes ..
	// hmmm. but mysoft will not transfer notes here to invoice.
	injectDeliveryOrderMaster(ilbfold,folderRec,companyRec);

	// cycle through sampquant (samples x mysoftcode) to insert
	for(llo : sampquant)
	{
		injectDeliveryOrder(ilbfold,llo,companyRec);
	}

	// update jobfolders->uploadtomysoft field
	sqlstatem4 = "update JobFolders set uploadToMYSOFT=1 where origid=" + foldno;
	sql.execute(sqlstatem4);
	sql.close();

	// 24/8/2010: inject courier-bill
	//injectCourierBill(ilbfold);

	// refresh folder/jobs listbox
	listFoldersByClient(selected_arcode);
	guihand.showMessageBox(ilbfold + " has been uploaded to MySoft now");

	// 17/9/2010: audit-trail
	todaydate = kiboo.todayISODateString();
	sqlhand.addAuditTrail(ilbfold,"Billing: Upload to MySoft", useraccessobj.username, todaydate);

} // end of uploadToMysoft()

// General purpose upload DO to mysoft for billing - called by mods other than billinguploader_v1_2.zul
void gpUploadToMySoft(String forigid)
{
	folderRec = samphand.getFolderJobRec(forigid); // samplereg_funcs.zs
	if(folderRec == null) return;

	folderno_str = folderRec.get("folderno_str");

	// if already uploaded.. prompt for reupload
	if(folderRec.get("uploadToMYSOFT") == 1)
	{
		if (Messagebox.show(folderno_str + " is already uploaded to MySoft. Do you want to upload again?", "Are you sure?", 
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) ==  Messagebox.NO)
			return false;
	}
	
	removeExistingDO(folderno_str,forigid); // remove existing DO in mysoft

	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	// collect samples origid
	sqlstm = "select origid from jobsamples where deleted=0 and jobfolders_id=" + forigid;
	samprecs = sql.rows(sqlstm);
	if(samprecs == null) { sql.close(); return; }

	// extract and made samples origid string
	sampstr = "(";
	for(kki : samprecs)
	{
		sampstr = sampstr + kki.get("origid") + ",";
	}
	// chop off extra , at the end
	ism = sampstr.substring(0,sampstr.length()-1);
	sampstr = ism + ")";

	// get mysoftcode * samples-quantity
	sqlstm2 = "select distinct mysoftcode, count(origid) as samplesquantity, price, testpackageid, packageprice " + 
	"from jobtestparameters where jobsamples_id in " + sampstr + " group by mysoftcode,price,testpackageid,packageprice";

	sampquant = sql.rows(sqlstm2);
	
	companyRec = sqlhand.getCompanyRecord(folderRec.get("ar_code")); // alsglobal_sqlfuncs.zs
	injectDeliveryOrderMaster(folderno_str,folderRec,companyRec);

	// cycle through sampquant (samples x mysoftcode) to insert
	for(llo : sampquant)
	{
		injectDeliveryOrder(folderno_str,llo,companyRec);
	}

	// update jobfolders->uploadtomysoft field
	sqlstatem4 = "update JobFolders set uploadToMYSOFT=1 where origid=" + forigid;
	sql.execute(sqlstatem4);
	sql.close();
	
	todaydate = kiboo.todayISODateString();
	sqlhand.addAuditTrail(folderno_str,"Billing: Upload to MySoft", useraccessobj.username, todaydate);

}






