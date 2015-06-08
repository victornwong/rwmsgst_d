import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: Test.Package related funcs
Written by : Victor Wong
Date : 7/7/2010

Notes:
-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)
*/

/*
// Database func: create a new test-package record
void createNewTestPackage(String itodate, String iar_code, String iusername)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into TestPackages (package_name,lastupdate,deleted,ar_code,username) values (?,?,?,?,?)");

	pstmt.setString(1,"");
	pstmt.setString(2,itodate);
	pstmt.setInt(3,0);
	pstmt.setString(4,iar_code);
	pstmt.setString(5,iusername);

	pstmt.executeUpdate();
	sql.close();
}
*/
/*
// Database func: create a new test-package record
void createNewTestPackage_packname(String itodate, String iar_code, String iusername, String packagename)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into TestPackages (package_name,lastupdate,deleted,ar_code,username) values (?,?,?,?,?)");

	pstmt.setString(1,packagename);
	pstmt.setString(2,itodate);
	pstmt.setInt(3,0);
	pstmt.setString(4,iar_code);
	pstmt.setString(5,iusername);

	pstmt.executeUpdate();
	sql.close();
}
*/
/*
// Database func: check if test-package name is uniq
boolean isUniqTestPackageName(String ichk)
{
	retval = true;
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlst = "select package_name from TestPackages where package_name='" + ichk + "'";
	therec = sql.firstRow(sqlst);
	if(therec != null) retval = false;
	sql.close();
	return retval;
}
*/
/*
// Database func: update testpackage->item
// 13/9/2010: added 2 fields, LOR and BILL
// 15/9/2010: added units field
// 03/08/2011: unitprice in testpackage_items
void updateTestPackage_ItemRec(String iorigid, String imysoftc, String ilor, String ibill, String iunits, String iunitprice)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	sqlst = "update TestPackage_Items set mysoftcode=" + imysoftc + ",lor='" + ilor + "', bill='" + ibill + "', " + 
	"units='" + iunits + "', unitprice=" + iunitprice + " where origid=" + iorigid;
	sql.execute(sqlst);
	sql.close();
}

void createTestPackage_ItemRec(String ipackage_id, String isorter)
{
	if(ipackage_id.equals("")) return;
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstatem = "insert into TestPackage_Items (mysoftcode,testpackage_id,deleted,sorter,lor,bill,units) values " + 
	"(0," + ipackage_id + ",0," + isorter + ",'','YES','')";
	sql.execute(sqlstatem);
	sql.close();
}

void cTestPackage_ItemRec_mysoftcode(String ipackage_id, String isorter, String imysoftc)
{
	if(ipackage_id.equals("")) return;
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstatem = "insert into TestPackage_Items (mysoftcode,testpackage_id,deleted,sorter,lor,bill,units) values " + 
	"(" + imysoftc + "," + ipackage_id + ",0," + isorter + ",'','YES','')";
	sql.execute(sqlstatem);
	sql.close();
}

void deleteTestPackage_ItemRec(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstatem = "delete from TestPackage_Items where origid=" + iorigid;
	sql.execute(sqlstatem);
	sql.close();
}
*/

