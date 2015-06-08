import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

/*
File: Tracking-Numbers database/general-purpose handling funcs
Written by: Victor Wong
Date started: 26/1/2011
*/

// Database func: get rec from elb_CodesTracker
Object getCodesTracker_Rec(String origid)
{
	sqlhand = new SqlFuncs();
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	sqlstm = "select * from elb_codestracker where origid=" + origid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

Object getTrackingNumber_Rec(String origid)
{
	sqlhand = new SqlFuncs();
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	sqlstm = "select * from elb_codestracker_items where origid=" + origid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func: check if tracking-number exists
boolean existTrackingNumber(String iwhat)
{
	sqlhand = new SqlFuncs();
	retval = false;
	sql = sqlhand.als_mysoftsql();
    if(sql == null) return retval;
    sqlstm = "select origid from elb_codestracker_items where tracking_number='" + iwhat + "'";
    kkk = sql.firstRow(sqlstm);
    if(kkk != null) retval = true;
    sql.close();
    return retval;
}


