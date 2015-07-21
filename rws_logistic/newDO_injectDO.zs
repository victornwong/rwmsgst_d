import org.victor.*;
// Inject DO into FC6. Codes copied over from adminmodules/injectFCtest.zul
// 21/07/2015: Modification for OJ1 database

DO_EXTRAHEADEROFF = "u001c";
DO_EXTRAOFF = "u011c";
DO_VOUCHERTYPE = "6144";

// Inject header, u001c, u011c
void inject_DO_Headers(String[] hdv)
{
	kdate = calcFocusDate("2007-03-31");
	lgn = "upload" + Math.round(Math.random() * 100).toString();

	// data.headeroff = header.headerid
	sqlstm1 = "declare @domaxid int;" +
	"set @domaxid = (select max(voucherno)+1 from header where vouchertype=" + DO_VOUCHERTYPE + ");" +
	"insert into header (" +
	"id, version, noentries, tnoentries, login, date_, time_," +
	"flags, flags2, defcurrency," +
	"vouchertype, voucherno, approvedby0, approvedby1, approvedby2) values (" +
	"0x0000, 0x5b, 0, 0, '" + lgn + "', " + kdate + ", 0x0a3b00," +
	"0x0027, 6208, 0x00," +
	DO_VOUCHERTYPE + ", @domaxid, 30, 0, 0 );";
	f30_gpSqlExecuter(sqlstm1);

	sqlstm2 = "select headerid,voucherno from header where login='" + lgn + "';"; // get inserted header.headerid
	r = f30_gpSqlFirstRow(sqlstm2);
	hdv[0] = r.get("headerid").toString();
	hdv[3] = r.get("voucherno");

	sqlstm3 = "update header set login='su' where headerid=" + hdv[0];
	f30_gpSqlExecuter(sqlstm3);

	// data.DO_EXTRAHEADEROFF - u001c.extraid
	sqlstm4 = "declare @maxid int; set @maxid = (select max(extraid)+1 from " + DO_EXTRAHEADEROFF + "); " +
	"insert into " + DO_EXTRAHEADEROFF + " (extraid,deliverymethodyh,transporteryh,deliveryrefyh,deliverystatusyh,narrationyh,deliveryaddressyh," +
	"referenceyh,dorefyh) values (@maxid, '', '', '', '', '', '', '', '" + lgn + "');";

	f30_gpSqlExecuter(sqlstm4);

	sqlstm5 = "select extraid from " + DO_EXTRAHEADEROFF + " where dorefyh='" + lgn + "';";
	r = f30_gpSqlFirstRow(sqlstm5);
	hdv[1] = r.get("extraid").toString();

	sqlstm6 = "update " + DO_EXTRAHEADEROFF + " set dorefyh='' where extraid=" + hdv[1];
	f30_gpSqlExecuter(sqlstm6);

	// data.DO_EXTRAOFF = u011c.extraid
	sqlstm7 = "declare @maxid int; set @maxid = (select max(extraid)+1 from " + DO_EXTRAOFF + ");" +
	"insert into " + DO_EXTRAOFF + " (extraid,remarksyh) values (@maxid,'" + lgn + "');";

	f30_gpSqlExecuter(sqlstm7);

	sqlstm8 = "select extraid from " + DO_EXTRAOFF + " where remarksyh='" + lgn + "';";
	r = f30_gpSqlFirstRow(sqlstm8);
	hdv[2] = r.get("extraid").toString();

	sqlstm9 = "update " + DO_EXTRAOFF + " set remarksyh='' where extraid=" + hdv[2];
	f30_gpSqlExecuter(sqlstm9);

}

// TODO make sure bookno is set properly or leave blank for user to select
void inject_FC6DO()
{
	kdate = calcFocusDate("2007-03-31");
	// headvals[0] = headerid, headvals[1] = DO_EXTRAHEADEROFF, headvals[2] = DO_EXTRAOFF, headvals[3] = voucherno
	String[] headvals = new String[4];

	inject_DO_Headers(headvals);
	kk = "headerid=" + headvals[0] + "\nu001c.extraid=" + headvals[1] + "\nu011c.extraid=" + headvals[2] + "\nvoucherno=" + headvals[3];
	scantags_tb.setValue(kk);
	/*
		return;
	 	asd = kiboo.replaceSingleQuotes( scantags_tb.getValue().trim() );
		if(asd.equals("")) return;
		atgs = asd.split("\n");
	*/

	/*
	headerid=116938
	u001c.extraid=2754
	u011c.extraid=2241
	voucherno=5267
	headvals[0] = "116932";
	headvals[1] = "2754";
	headvals[2] = "2240";
	headvals[3] = "5267";
	*/
	atgs = "'91003526','91003528','91003529','91003531','91003532','91003534','91003535'";
	mainsqlstm = "declare @dmaxid int; declare @imaxid int; ";

	sqlstm1 = "select m.masterid as pcode, p.masterid as tags6v from mr001 AS m INNER JOIN " +
	"dbo.u0001 AS u ON m.Eoff = u.ExtraId INNER JOIN dbo.mr008 AS p ON u.ProductNameYH = p.MasterId " +
	"where m.code2 in (" + atgs + ");";

	rx = f30_gpSqlGetRows(sqlstm1);
	// TODO have to check how recs found based on asset-tags, if not equal, error-return
	linecount = 0;

	for(d : rx)
	{
		prodcode = (d.get("pcode") == null) ? "0" : d.get("pcode").toString();
		tags6 = (d.get("tags6v") == null) ? "0" : d.get("tags6v").toString();

		// data.salesoff = indta.salesid
		mainsqlstm += "set @imaxid = (select max(salesid)+1 from indta); " +
		"insert into indta (salesid,quantity,stockvalue,rate,gross,qty2,subprocess,unit," +
		"input0,output0,input1,output1,input2,output2,input3,output3," +
		"input4,output4,input5,output5,input6,output6,input7,output7," +
		"input8,output8,input9,output9) values ( @imaxid,-1,0,0,0,-1,0,0x00, " +
		"0,0,0,0,0,0,0,0," +
		"0,0,0,0,0,0,0,0," +
		"0,0,0,0);";

		mainsqlstm += "set @dmaxid = (select max(bodyid)+1 from data); " +
		"insert into data (" +
		"bodyid, date_, vouchertype, voucherno, bookno, productcode," +
		"tags0, tags1, tags2, tags3, amount1, amount2, originalamount, flags, billwiseoff, links0, tags6," +
		"headeroff, extraoff, extraheaderoff, salesoff," +
		"code, duedate, sizeofrec, links1, links2, links3, linktoprbatch, exchgrate, tags4, tags5, tags7, " +
		"binnoentries, reserveno, reservetype) values (" +
		"@dmaxid, " + kdate + "," + DO_VOUCHERTYPE + ", '" + headvals[3] +"', 1251, " + prodcode + "," +
		"3, 3, 0, 9, 0, 0, 0, 2622464, 0, 0, " + tags6 + ", " +
		headvals[0] + "," + headvals[2] + "," + headvals[1] + ",@imaxid," +
		"1078," + kdate + ",240, 0, 0, 0, 0, 1, 0, 0, 0," +
		"0, 0, 0);";

		linecount++;
	}

	mainsqlstm += "update header set noentries=" + linecount.toString() + ", tnoentries=" + linecount.toString() +
	" where headerid=" + headvals[0] + ";"; // update no. lines in header

	f30_gpSqlExecuter(mainsqlstm);
	alert("boom..");
}

