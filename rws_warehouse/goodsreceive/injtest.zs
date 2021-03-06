
import java.util.*;
import java.text.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

/**
 * Extracted from SQL stored-functions
 * @param  dstr the date string to convert into FOCUS date format
 * @return      FOCUS int date format
 */
int calcFocusDate(String dstr)
{
	java.util.Calendar thedate = Calendar.getInstance();
	thedate.setTime(GlobalDefs.dtf2.parse(dstr));
	// ((2014-1950)*416) + ((9*32)+1) + (18 - 1);
	retval = ((thedate.get(Calendar.YEAR)-1950)*416) + ((thedate.get(Calendar.MONTH)+1)*32) + (thedate.get(Calendar.DAY_OF_MONTH));
	return retval;
}

Sql FC5030_Sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.88:1433;DatabaseName=Focus5020";
		return(Sql.newInstance(dbstring, "sa", "focus@123", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
		alert("f50J0 error!");
		return null;
	}
}

void f30_gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

ArrayList f30_gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

GroovyRowResult f30_gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = FC5030_Sql();
	if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

//----SQL functions for 0J0 ------------------------

Sql FC50J0_Sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.88:1433;DatabaseName=Focus5020";
		return(Sql.newInstance(dbstring, "sa", "focus@123", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
		alert("f50J0 error!");
		return null;
	}
}

void fj0_gpSqlExecuter(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return;
	sql.execute(isqlstm);
	sql.close();
}

ArrayList fj0_gpSqlGetRows(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return null;
	ArrayList retval = (ArrayList)sql.rows(isqlstm);
	sql.close();
	return retval;
}

GroovyRowResult fj0_gpSqlFirstRow(String isqlstm) throws SQLException
{
	Sql sql = FC50J0_Sql(); if(sql == null) return null;
	GroovyRowResult retval = (GroovyRowResult)sql.firstRow(isqlstm);
	sql.close();
	return retval;
}

