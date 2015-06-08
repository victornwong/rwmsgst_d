import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Global defs and funcs for Document trails management
Done by: Victor

*/

// Database func: get a rec from DocumentTrack - diff from Doculink thing
Object get_TrailRecord(String iorig)
{
	retval = null;
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlst = "select * from DocumentTrack where origid=" + iorig;
	retval = sql.firstRow(sqlst);
	sql.close();
	return retval;
}

void createNewClientTracker(String iar_code)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	
	idatecreated = getDateFromDatebox(hiddendatebox);
	
	sqlst = "insert into CustomerTracking values ('" + iar_code + "','" + useraccessobj.username + "','" + idatecreated + "',0)" ;
	sql.execute(sqlst);
	
	sql.close();
}
