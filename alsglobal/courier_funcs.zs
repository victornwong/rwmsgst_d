import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: Courier tracking related funcs
Written by : Victor Wong
Date : 23/08/2010

Notes:

-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)
*/

/*
Database func: insert rec into courier_tracking table - refer to prep-statement for fields position

String[] myballs = { ar_code, customer_name, recipient, notes, todaysdate,
		document_type, delivery_method, tracking_number, "OUT", "",
		"", "0.0", "", "0", "",
		"", useraccessobj.username };

	insertCourierTracking_Rec(myballs);
*/
void insertCourierTracking_Rec(String[] thevalues)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();

	pstmt = thecon.prepareStatement("insert into Courier_Tracking (ar_code,customer_name,recipient,notes,datecreated," + 
	"document_type,delivery_method,tracking_number,direction,invoice_link, container_do_link,amount,billed_date,billed,thirdparty_ar_code," +
	"thirdparty_customer_name,username,folder_link) values (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?)");

	pstmt.setString(1,thevalues[0]);
	pstmt.setString(2,thevalues[1]);
	pstmt.setString(3,thevalues[2]);
	pstmt.setString(4,thevalues[3]);
	pstmt.setString(5,thevalues[4]);

	pstmt.setString(6,thevalues[5]);
	pstmt.setString(7,thevalues[6]);
	pstmt.setString(8,thevalues[7]);
	pstmt.setString(9,thevalues[8]);
	pstmt.setString(10,thevalues[9]);

	pstmt.setString(11,thevalues[10]);
	pstmt.setFloat(12,Float.parseFloat(thevalues[11]));
	pstmt.setString(13,thevalues[12]);
	pstmt.setInt(14,Integer.parseInt(thevalues[13]));
	pstmt.setString(15,thevalues[14]);

	pstmt.setString(16,thevalues[15]);
	pstmt.setString(17,thevalues[16]);
	pstmt.setString(18,thevalues[17]);

	pstmt.executeUpdate();
	sql.close();
}

// Database func: get a rec from courier-tracking based on origid
Object getCourierTracking_Rec(String iorigid)
{
	if(iorigid.equals("")) return null;
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select * from Courier_Tracking where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func: delete rec from courier_tracking by origid
void delCourierTracking_Rec(String iorigid)
{
	if(iorigid.equals("")) return;
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstm = "delete from Courier_Tracking where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}
