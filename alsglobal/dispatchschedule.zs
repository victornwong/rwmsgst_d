import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

/*
Purpose: Dispatch/Schedule SQL related functions we put them here
Written by : Victor Wong
Date : 18/01/2010

02/04/2012: ported to byte-compl

Notes:

*/

kiboo = new Generals();
sqlhand = new SqlFuncs();

// get rec from DispatchScheduleDetails
// iwhichrec = origid (raw, it'll be chopped here)
Object getDispatchScheduleRec(String iwhichrec)
{
	if(iwhichrec.equals("")) return null;
	iextid = kiboo.strip_PrefixID(iwhichrec);
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	sqlstatem = "select * from DispatchScheduleDetails where origid=" + iextid;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

// Get details from mysoft.DispatcherDetails table
Object getDispatcherRec(String iwhichrec)
{
	if(iwhichrec.equals("")) return null;
	iextid = kiboo.strip_PrefixID(iwhichrec);
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	sqlstatem = "select * from DispatcherDetails where origid=" + iextid;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

