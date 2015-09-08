
import java.util.*;
import java.text.*;
import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

Sql FC50J0_Sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/Focus50J0";
		return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
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
