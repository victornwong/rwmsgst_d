import java.util.*;
import java.sql.*;
import groovy.sql.*;
import org.zkoss.zk.ui.*;
import org.victor.*;

// rWs-tempchk database specific SQL funcs
// Crank-up by : Victor Wong (25/04/2013)

Sql rwstempchk_sql()
{
	try
	{
		String dbstring = "jdbc:jtds:sqlserver://192.168.100.201:1433/tempchk";
		return(Sql.newInstance(dbstring, "testme", "9090", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (Exception e)
	{
		return null;
	}
}

boolean rwGpSqlExecute(String iwhat)
{
	sql = rwstempchk_sql();
	if(sql == null) return false;
	sql.execute(iwhat);
	sql.close();
	return true;
}

Object rwGpFirstRow(String iwhat)
{
	sql = rwstempchk_sql();
	if(sql == null) return null;
	retval = sql.firstRow(iwhat);
	sql.close();
	return retval;
}

Object rwGpRows(String iwhat)
{
	sql = rwstempchk_sql();
	if(sql == null) return null;
	retval = sql.rows(iwhat);
	sql.close();
	return retval;
}


