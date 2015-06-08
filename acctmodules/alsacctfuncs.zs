import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
ALS Technichem Malaysia Account Dept Utilities

Purpose: Global and useful functions we put them here
Written by : Victor Wong
Date : 11/08/2009

Notes:


(c)2009 ALS Technichem Malaysia Sdn Bhd

*/

void showMessageBox(String wmessage)
{
        Messagebox.show(wmessage,"Bong",Messagebox.OK,Messagebox.EXCLAMATION);
}



Sql als_mysoftsql()
{
// driver = Class.forName("net.sourceforge.jtds.jdbc.Driver").newInstance();
// Connection conn = DriverManager.getConnection("jdbc:jtds:sqlserver://alsslws007:1433/AccDatabase1", "sa", "sa");

    try
    {
    // DATABASESERVER and DATABASENAME in alsacctglobal.zs

    dbstring = "jdbc:jtds:sqlserver://" + DATABASESERVER + "/" + DATABASENAME;

    return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
    }
    catch (SQLException e)
    {
    }
}

