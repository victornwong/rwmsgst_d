import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: Quotations / elb_Quotations related funcs
Written by : Victor Wong
Date : 14/07/2010

Notes:

-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)

*/

QUOTE_PREFIX = "QT";

QTSTAT_NEW = "NEW";
QTSTAT_COMMIT = "COMMITTED";
QTSTAT_RETIRED = "RETIRED";
QTSTAT_WIN = "WIN";
QTSTAT_LOSE = "LOSE";
QTSTAT_WAIT = "WAIT";

//String[] quoteWinLoseFlags = { QTSTAT_LOSE , QTSTAT_WIN, QTSTAT_WAIT };
String[] quoteWinLoseFlags = {
"WON",
"Pending via call - follow up",
"Pending via email - follow up",
"Pending via visit - follow up",
"Loss - client fail to respond",
"Loss - price not competitive",
"Loss - client lost the project",
"Loss - failure to follow up",
"Loss - poor service from lab or sales",
"Others"
};

// Database func: insert a new quotation into elb_Quotations
void insertQuotation_Rec(String iusername, String idatecreated)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into elb_Quotations (ar_code,customer_name,datecreated,username,deleted,qstatus,version) values (?,?,?,?,?,?,?)");
	pstmt.setString(1,"");
	pstmt.setString(2,"");
	pstmt.setString(3,idatecreated);
	pstmt.setString(4,iusername);
	pstmt.setInt(5,0);
	pstmt.setString(6,QTSTAT_NEW);
	pstmt.setInt(7,0);
	pstmt.executeUpdate();
	sql.close();
}

Object getQuotation_Rec(String iorigid)
{
	retval = null;
	sql = als_mysoftsql();
	if(sql == null ) return null;
	sqlstm = "select * from elb_Quotations where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Set only elb_Quotations.qstatus field
void setQuotation_Status(String iorigid, String iwhat)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	sqlstm = "update elb_Quotations set qstatus='" + iwhat + "' where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: insert a new rec into elb_quotation_items - params self-explanatory

void insertQuoteItem_Rec(String iq_parent, String imysoftcode, String idesc, String idesc2, String icurcode, Double iunitprice)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	thecon = sql.getConnection();

	pstmt = thecon.prepareStatement("insert into elb_Quotation_Items (mysoftcode,description,description2,LOR,quote_parent, quantity,curcode,unitprice,discount," +
	"total_net,total_gross) values (?,?,?,?,?, ?,?,?,?,?, ?)");

	pstmt.setInt(1,Integer.parseInt(imysoftcode));
	pstmt.setString(2,idesc);
	pstmt.setString(3,idesc2);
	pstmt.setString(4,"");
	pstmt.setInt(5, Integer.parseInt(iq_parent));

	pstmt.setInt(6,1);
	pstmt.setString(7,icurcode);
	pstmt.setDouble(8,iunitprice);

	pstmt.setDouble(9,0);
	pstmt.setDouble(10, iunitprice);
	pstmt.setDouble(11, iunitprice);

	pstmt.executeUpdate();
	sql.close();
}

void insertQuoteItem_Rec2(String iq_parent, String imysoftcode, String idesc, String idesc2, String icurcode, Double iunitprice, String iversion)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	thecon = sql.getConnection();

	pstmt = thecon.prepareStatement("insert into elb_Quotation_Items (mysoftcode,description,description2,LOR,quote_parent, quantity,curcode,unitprice,discount," +
	"total_net,total_gross,version) values (?,?,?,?,?, ?,?,?,?,?, ?,?)");

	pstmt.setInt(1,Integer.parseInt(imysoftcode));
	pstmt.setString(2,idesc);
	pstmt.setString(3,idesc2);
	pstmt.setString(4,"");
	pstmt.setInt(5, Integer.parseInt(iq_parent));

	pstmt.setInt(6,1);
	pstmt.setString(7,icurcode);
	pstmt.setDouble(8,iunitprice);
	pstmt.setDouble(9,0);
	pstmt.setDouble(10, iunitprice);
	pstmt.setDouble(11, iunitprice);
	pstmt.setInt(12, Integer.parseInt(iversion));

	pstmt.executeUpdate();
	sql.close();
}

// Database func: delete a quote-item
void deleteQuoteItem_Rec(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	sqlstm = "delete from elb_Quotation_Items where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: just quote-item rec
Object getQuoteItem_Rec(String iorigid)
{
	retval = null;
	sql = als_mysoftsql();
	if(sql == null ) return null;
	sqlstatem = "select * from elb_Quotation_Items where origid=" + iorigid;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

// Database func: just use to update prices x quantity thing and LOR
void updateQuoteItem_Value(String iorigid, String iunitprice, String idiscount, String iquantity, String ilor, String idesc, String idesc2)
{
	kunitp = Float.parseFloat(iunitprice);
	kquant = Integer.parseInt(iquantity);
	kdisct = Float.parseFloat(idiscount);
	total_gross = kunitp * kquant;
	total_net = total_gross - kdisct;
	sql = als_mysoftsql();
	if(sql == null ) return;
	sqlstm = "update elb_Quotation_Items set unitprice=" + kunitp.toString() + ", discount=" + kdisct.toString() + ", quantity=" + kquant.toString() +
	", total_net=" + total_net.toString() + ", total_gross=" + total_gross.toString() + ", LOR='" + ilor + "', description='" + idesc + "', description2='" + idesc2 + "' " + 
	"where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: toggle elb_Quotations.deleted flag
void toggleQuotation_DeletedFlag(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == null ) return null;
	sqlstm = "select deleted from elb_Quotations where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	if(retval != null)
	{
		toggler = (retval.get("deleted") == 1) ? 0 : 1;
		sqlstm2 = "update elb_Quotations set deleted=" + toggler.toString() + " where origid=" + iorigid;
		sql.execute(sqlstm2);
	}
	sql.close();
}

// Database func: Get quotation-package record
Object getQuotePackageRec(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == NULL) return null;
	sqlstm = "select * from elb_quotation_package where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Return 1 if any quote-items linked to quote else 0
int quotePackageItems_Avail(String iparent_qp)
{
	retval = 0;
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlstm = "select top 1 origid from elb_quotepackage_items where qpack_parent=" + iparent_qp;
	ll = sql.firstRow(sqlstm);
	sql.close();
	if(ll != null) retval = 1;
	return retval;
}

