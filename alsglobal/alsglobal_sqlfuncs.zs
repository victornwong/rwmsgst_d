import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

import org.victor.*;

/*
ALS Technichem Malaysia Account Dept Utilities

Purpose: Global SQL related functions we put them here
Written by : Victor Wong
Date : 18/01/2010

Notes:

-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)

(c)2009,2010 ALS Technichem Malaysia Sdn Bhd

*/

/*
CHEMISTRY_RESULTS_TABLE = "elb_Chemistry_Results";
JOBFOLDERS_TABLE = "JobFolders";
JOBSAMPLES_TABLE =  "JobSamples";
JOBTESTPARAMETERS_TABLE = "JobTestParameters";
RUNLIST_TABLE = "RunList";
RUNLISTITEMS_TABLE = "RunList_Items";
CASHSALES_CUSTOMERINFO_TABLE = "CashSales_CustomerInfo";

// 24/08/2011: document management using a different database - AdminDocument. Tables struct same and with additional stuff
DMS_DATABASE = "AdminDocuments";
*/

/*
Sql DMS_Sql()
{
	try
	{
		dbstring = "jdbc:jtds:sqlserver://" + MYSOFTDATABASESERVER + "/" + DMS_DATABASE;
		return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
	}
	catch (SQLException e)
	{
		return null;
	}
}
*/

/*
Open a JDBC to Mysoft database
Uses JTDS JDBC driver to access MS-SQL database and groovy.Sql
*/
/*
Sql als_mysoftsql()
{
// driver = Class.forName("net.sourceforge.jtds.jdbc.Driver").newInstance();
// Connection conn = DriverManager.getConnection("jdbc:jtds:sqlserver://alsslws007:1433/AccDatabase1", "sa", "sa");

    try
    {
    // MYSOFTDATABASESERVER and MYSOFTDATABASENAME in alsglobaldefs.zs

    dbstring = "jdbc:jtds:sqlserver://" + MYSOFTDATABASESERVER + "/" + MYSOFTDATABASENAME;

    return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
    }
    catch (SQLException e)
    {
        showMessageBox("Cannot access Mysoft database");
    }
}
*/

/*
// 14/4/2010: open JDBC connection to DocumentStorage database
Sql als_DocumentStorage()
{
    try
    {
    // MYSOFTDATABASESERVER and DOCUMENTSTORAGE_DATABASE in alsglobaldefs.zs

    dbstring = "jdbc:jtds:sqlserver://" + MYSOFTDATABASESERVER + "/" + DOCUMENTSTORAGE_DATABASE;

    return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
    }
    catch (SQLException e)
    {
        showMessageBox("Cannot access DocumentStorage database");
    }
}

// 26/3/2010: added this one for development purposes
Sql als_mysoftsql_acctbase3()
{
    try
    {
    // MYSOFTDATABASESERVER and MYSOFT_DB_DEVELOP in alsglobaldefs.zs

    dbstring = "jdbc:jtds:sqlserver://" + MYSOFTDATABASESERVER + "/" + MYSOFT_DB_DEVELOP;

    return(Sql.newInstance(dbstring, "sa", "sa", "net.sourceforge.jtds.jdbc.Driver"));
    }
    catch (SQLException e)
    {
        showMessageBox("Cannot access Mysoft development database");
    }
}
*/

// Main routine to create a MYSQL jdbc connection
// Any changes to user/password, make here.
Sql alsportal_Mysql()
{
	try
	{
		return(Sql.newInstance("jdbc:mysql://172.18.107.8:3306/webreport_db", "webreport_user", "123890",
			"org.gjt.mm.mysql.Driver"));
	}
	catch (SQLException e)
	{
	}
}

/*
// get company name based on ar_code passed
String getCompanyName(String tar_code)
{
	retval = "-Undefined-";
	
	sql = als_mysoftsql();
    if(sql == NULL) return;
	
	sqlstatem = "select customer_name from customer where ar_code='" + tar_code + "'";
	therec = sql.firstRow(sqlstatem);
	sql.close();
	
	if(therec != null)
		retval = therec.get("customer_name");
	
	return retval;
}
*/
/*
// get company customer record from mysoft.customer based on ar_code passed
Object getCompanyRecord(String tar_code)
{
	if(tar_code == null) return null;

	sql = als_mysoftsql();
    if(sql == NULL) return;
	
	sqlstatem = "select * from customer where ar_code='" + tar_code + "'";
	therec = sql.firstRow(sqlstatem);
	sql.close();
	
	return therec;
}
*/
/*
Object getMySoftMasterProductRec(String iwhich)
{
	retval = null;
	
	sql = als_mysoftsql();
	if(sql != null)
	{
		sqlstatem = "select * from stockmasterdetails where id=" + iwhich;
		retval = sql.firstRow(sqlstatem);
	
		sql.close();
	}
	
	return retval;

}
*/
/*
// get a rec from equipment table
Object getEquipmentRec(String iorigid)
{
	retval = null;
	
	sql = als_mysoftsql();
	if(sql == NULL) return;
	
	sqlstat = "select * from Equipments where origid=" + iorigid;
	retval = sql.firstRow(sqlstat);
	
	sql.close();
	
	return retval;

}
*/

/*
// Insert a rec into the Chemistry_Results table
void insertChemistryResult(String[] resarray)
{
	sql = als_mysoftsql();
	if(sql == null) return;

	thecon = sql.getConnection();

	// site_id = global_folderno	
	// samplecode = global_selected_sampleid

	// mod: 8/9/2010: change chemcode from analyte name to CAS
	// chemcode = CAS#

	// Result , Final = iresult (Final ain't doing any calc yet - just make them same)
	// Result_Unit = iunit
	// Method_Name = imethod
	// Analysed_Date = todaydate
	// EQID = ieqid
	// QA_Flag = iqaflag
	// username = useraccessobj.username
	// ResultStatus = "RESULT" // default for new entry
	// jobtestparameter_id = ijobtestparam_origid
	// reported = irepflag
	// mysoftcode = imysoftc

	// mod: 8/9/2010 - store originalchemname
	// originalchemname = ianalyte

	pstmt = thecon.prepareStatement("insert into " + CHEMISTRY_RESULTS_TABLE + "(Site_ID, SampleCode, ChemCode, Result, Result_Unit, Final, " + 
	"Method_Name, Analysed_Date, EQID, QA_Flag, username, ResultStatus, jobtestparameter_id, reported, mysoftcode, deleted, OriginalChemName) values " + 
	"(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

	pstmt.setString(1,resarray[0]);
	pstmt.setString(2,resarray[1]);
	pstmt.setString(3,resarray[2]);
	pstmt.setString(4,resarray[3]);
	pstmt.setString(5,resarray[4]);
	pstmt.setString(6,resarray[5]);
	pstmt.setString(7,resarray[6]);
	pstmt.setString(8,resarray[7]);

	pstmt.setString(9,resarray[8]);
	pstmt.setInt(10, Integer.parseInt(resarray[9]));
	pstmt.setString(11,resarray[10]);
	pstmt.setString(12,resarray[11]);
	pstmt.setInt(13, Integer.parseInt(resarray[12]));
	pstmt.setInt(14, Integer.parseInt(resarray[13]));
	pstmt.setInt(15, Integer.parseInt(resarray[14]));
	pstmt.setInt(16,0);
	pstmt.setString(17,resarray[15]);
	
	pstmt.executeUpdate();
	sql.close();	
}
*/

/*
// Update Chemistry_Results table
// resarray[] = ChemCode,Final,Result_Unit,QA_Flag,reported,Analysed_Date,origid(of chemistry_results)
void updateResultTrail(String[] resarray)
{
	sql = als_mysoftsql();
	if(sql == null) return;

	thecon = sql.getConnection();
	
	pstmt = thecon.prepareStatement("update " + CHEMISTRY_RESULTS_TABLE + " set ChemCode=? , Final=? , Result_Unit=? , QA_Flag=? , reported=? , Analysed_Date=? where origid=?");
		
	pstmt.setString(1,resarray[0]);
	pstmt.setString(2,resarray[1]);
	pstmt.setString(3,resarray[2]);
	pstmt.setString(4,resarray[3]);
	pstmt.setInt(5,Integer.parseInt(resarray[4]));
	pstmt.setString(6, resarray[5]);
	pstmt.setInt(7,Integer.parseInt(resarray[6]));
	
	pstmt.executeUpdate();
	
	sql.close();
}
*/
/*
Object getChemResult_Rec(String iorigid)
{
	retval = null;
	
	sql = als_mysoftsql();
	if(sql == null) return;

	sqlsta = "select * from " + CHEMISTRY_RESULTS_TABLE + " where origid=" + iorigid;
	retval = sql.firstRow(sqlsta);
	sql.close();
	
	return retval;
}
*/

/*
// Database func: to get elb_Chemical_Results.final only, jtp_origid = JobTestParameters.origid
String getChemResult_Final(String jtp_origid)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	// get only the latest final and also reported-flag set
	sqlstm = "select top 1 Final from " + CHEMISTRY_RESULTS_TABLE + " where jobtestparameter_id=" + jtp_origid + " and reported=1 order by origid desc";
	therec = sql.firstRow(sqlstm);
	sql.close();
	
	retval = "";
	if(therec != null)
		retval = therec.get("Final");
		
	return retval;
}
*/

/*
// Database func: will return the latest result - order by origid desc
Object getLatestResult(String isampid, String imysoftc)
{
	retval = null;
	sql = als_mysoftsql();
	if(sql == null) return;
	// select rec where reported=1 (need to report in COA) and deleted=0/null
	sqlsta = "select top 1 * from " + CHEMISTRY_RESULTS_TABLE + " where SampleCode='" + isampid + "' and mysoftcode=" + imysoftc + 
	" and reported=1 and (deleted=0  or deleted is null) order by origid desc";
	retval = sql.firstRow(sqlsta);
	sql.close();
	return retval;
}
*/

/*
// Useful database util func
// ifolderno = just the origid, not the whole string
// return false if number of results no equal to number of tests in samples
boolean checkForComplete_Results(String ifolderno)
{
	retval = false;
	sql = als_mysoftsql();
	if(sql == null) return;
	
	sqlstm = "select jobsamples.origid as jsorigid, jobtestparameters.origid as jtporigid, " +
		"jobtestparameters.mysoftcode, elb_chemistry_results.chemcode from " +
		"jobsamples left join jobtestparameters " +
		"on jobsamples.origid = jobtestparameters.jobsamples_id " +
		"left join elb_chemistry_results " +
		"on elb_chemistry_results.mysoftcode = jobtestparameters.mysoftcode " +
		"where jobsamples.jobfolders_id=" + ifolderno +
		" and jobsamples.deleted = 0";
		
	samprecs = sql.rows(sqlstm);
	sql.close();
	
	if(samprecs.size() > 0)
	{
		mecount = 0;
		
		for(smrec : samprecs)
		{
			if(smrec.get("chemcode") != null)
				mecount++;
		}

		if(mecount == samprecs.size())
			retval = true;
	}
	return retval;
}
*/

/*
// Database func: imagemap Mapper_Pos get a rec by origid
Object getMapperPos_Rec(String iorigid)
{
	if(iorigid.equals("")) return null;
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select * from Mapper_Pos where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}
*/
/*
// Database func: add an audit-trail into elb_SystemAudit table
void addAuditTrail(String ilinkcode, String iaudit_notes, String iusername, String itodaydate)
{
	kiboo = new Generals();

	sql = als_mysoftsql();
	if(sql == NULL) return;

	ilinkcode = kiboo.replaceSingleQuotes(ilinkcode);
	iaudit_notes = kiboo.replaceSingleQuotes(iaudit_notes);
	
	sqlstm = "insert into elb_SystemAudit (linking_code,audit_notes,username,datecreated,deleted) values " + 
	"('" + ilinkcode + "','" + iaudit_notes + "','" + iusername + "','" + itodaydate + "',0)";

	sql.execute(sqlstm);
	sql.close();
}
*/
/*
// Database func: just toggle elb_SystemAudit.deleted flag
void toggleDelFlag_AuditTrail(String iorigid, String iwhat)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlstm = "update elb_SystemAudit set deleted=" + iwhat + " where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}
*/
/*
// Database func: get rec from customer_emails by origid
Object getCustomerEmails_Rec(String iorigid)
{
	if(iorigid.equals("")) return null;
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "select * from customer_emails where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func: get rec from ZeroToleranceClients by origid
Object getZTC_Rec(String iorigid)
{
	if(iorigid.equals("")) return null;
	sql = als_mysoftsql();
    if(sql == NULL) return null;
	sqlstm = "select * from zerotoleranceclients where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}
*/

