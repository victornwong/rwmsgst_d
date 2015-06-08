import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: Containers Requests and boxes funcs
Written by : Victor Wong
Date : 8/11/2010

Notes:

-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)
*/

CONTAINER_REQ_ID_PREFIX = "CTRQ";

CONTAINER_REQ_PENDING = "PENDING";
CONTAINER_REQ_PACKED = "PACKED";
CONTAINER_REQ_SHIPPED = "SHIPPED";

CONTAINER_REQ_VIAL_TYPE = "VIAL";

CONTAINER_VIAL_METHOD5035_DESC = "Vial for Method 5035";

// Database func: insert a rec into ContainerReq table
// rparams = array of parameters, refer to sql-statement for fields
insertContainerRequest_Rec(String[] rparams)
{
	sql = als_mysoftsql();
	if(sql == null) return;

	thecon = sql.getConnection();
	
	pstmt = thecon.prepareStatement("insert into ContainerReq (username,customer_name,contact_person,address1,address2,city,zipcode,state,country," + 
	"telephone,fax,email,req_type,req_status,deleted,datecreated) " +
	"values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

		
	pstmt.setString(1,rparams[0]);
	pstmt.setString(2,rparams[1]);
	pstmt.setString(3,rparams[2]);
	pstmt.setString(4,rparams[3]);
	pstmt.setString(5,rparams[4]);
	
	pstmt.setString(6,rparams[5]);
	pstmt.setString(7,rparams[6]);
	pstmt.setString(8,rparams[7]);
	pstmt.setString(9,rparams[8]);
	pstmt.setString(10,rparams[9]);
	
	pstmt.setString(11,rparams[10]);
	pstmt.setString(12,rparams[11]);
	pstmt.setString(13,rparams[12]);
	pstmt.setString(14,rparams[13]);
	
	pstmt.setInt(15,0);
	
	todaydate = getDateFromDatebox(hiddendatebox);
	pstmt.setString(16,todaydate);

	pstmt.executeUpdate();
	sql.close();
}

// Database func: get a rec from ContainerReq based on iorigid
Object getContainerReq_Rec(String iorigid)
{
	retval = null;
	sql = als_mysoftsql();
	if(sql == null) return null;
	sqlstm = "select * from ContainerReq where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func: update ContainerReq rec
// iwhatupdate = something like "deleted=0" , check sqlstm
void updateContainerReq_Rec(String iorigid, String iwhatupdate)
{
	if(iorigid.equals("") || iwhatupdate.equals("")) return;
	
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlstm = "update ContainerReq set " + iwhatupdate + " where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: insert a container-req item - refer to sql-statement for fields to use
// uses ContainerReq_Items
void insertContReqItem_Rec(String[] rparams)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into ContainerReq_Items (contreq_parent,description,quantity,field6,field7,field8) values (?,?,?,?,?,?)");

	pstmt.setString(1,rparams[0]);
	pstmt.setString(2,rparams[1]);
	pstmt.setInt(3,Integer.parseInt(rparams[2]));
	pstmt.setString(4,rparams[3]);
	pstmt.setString(5,rparams[4]);
	pstmt.setString(6,rparams[5]);
	
	pstmt.executeUpdate();
	sql.close();
}

String makeContainerReq_IDstr(String iorigid)
{
	return CONTAINER_REQ_ID_PREFIX + iorigid;
}
