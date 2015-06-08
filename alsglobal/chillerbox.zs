import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
ALS Technichem Malaysia Account Dept Utilities

Purpose: Box Manager SQL related functions we put them here
Written by : Victor Wong
Date : 18/01/2010

Notes:

(c)2009 ALS Technichem Malaysia Sdn Bhd

*/

// get rec from box_rental_form
// iwhichrec = origid (raw, it'll be chopped here)
Object getDispatchScheduleRec(String iwhichrec)
{
	if(iwhichrec.equals("")) return null;
	
	iextid = strip_PrefixID(iwhichrec);
	
	sql = als_mysoftsql();
	if(sql == NULL)
	{
		showMessage("getDispatchScheduleRec: Cannot connect to Mysoft database");
		return;
	}
		
	sqlstatem = "select * from box_rental_form where origid=" + iextid;
	retval = sql.firstRow(sqlstatem);
		
	sql.close();
	return retval;
}

// Get details from mysoft.box_available table
Object getDispatcherRec(String iwhichrec)
{
	if(iwhichrec.equals("")) return null;
	
	iextid = strip_PrefixID(iwhichrec);
	
	sql = als_mysoftsql();
	if(sql == NULL)
	{
		showMessage("getDispatcherRec: Cannot connect to Mysoft database");
		return;
	}
		
	sqlstatem = "select * from box_available where origid=" + iextid;
	retval = sql.firstRow(sqlstatem);
		
	sql.close();
	return retval;
}

