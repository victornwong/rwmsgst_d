
import java.util.*;
import java.text.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

int calcFocusDate(String dstr)
{
	java.util.Calendar thedate = Calendar.getInstance();
	thedate.setTime(GlobalDefs.dtf2.parse(dstr));
	// ((2014-1950)*416) + ((9*32)+1) + (18 - 1);
	//alert("year=" + thedate.get(Calendar.YEAR).toString() + "\nmonth=" + thedate.get(Calendar.MONTH).toString() +
	//"\nday=" + thedate.get(Calendar.DAY_OF_MONTH).toString());
	retval = ((thedate.get(Calendar.YEAR)-1950)*416) + ((thedate.get(Calendar.MONTH)+1)*32) + (thedate.get(Calendar.DAY_OF_MONTH));
	return retval;
}

Sql FC5030_Sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus5010";
		return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
		alert("f5030 error!");
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

