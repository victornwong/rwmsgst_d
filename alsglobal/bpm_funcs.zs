import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: BPM-like funcs and sql-func
Written by : Victor Wong
Date : 29/07/2010

Notes:

-- Check ident value
 	dbcc checkident(tbl_mqb_data_templates)
 -- Reset ident value
 	dbcc checkident(tbl_mqb_data_templates, reseed, 0)
*/

// Database func: BPM_Actions - check if assignee already assigned to assigner -- talking multiple assses
boolean assigneeExist_BPMActions(String iassignee, String iassigner)
{
	retval = false;
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstm = "select assignee from BPM_Actions where assignee='" + iassignee + "' and assigner='" + iassigner + "'";
	checkrec = sql.firstRow(sqlstm);
	sql.close();
	if(checkrec != null) retval = true;
	return retval;
}

// database func: get a rec from BPM_Actions
Object getBPMActions_Rec(String iwhich)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	sqlstm = "select * from BPM_Actions where origid=" + iwhich;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func: BPM_Actions insert a new rec - parameters pretty self-explainatory
void insertRec_BPM_Actions(String iassigner, String iassignee, String idatecreated, String iactiontype)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into BPM_Actions (assigner,assignee,datecreated,actiontype) values (?,?,?,?)");
	pstmt.setString(1,iassigner);
	pstmt.setString(2,iassignee);
	pstmt.setString(3,idatecreated);
	pstmt.setString(4,iactiontype);
	pstmt.executeUpdate();
	sql.close();
}

// Database func: BPM_Actions delete a rec, based on origid passed
void deleteRec_BPM_Actions(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlstatem = "delete from BPM_Actions where origid=" + iorigid;
	sql.execute(sqlstatem);
	sql.close();
}

// database func: set actionstatus,actiondate flag
void setBPMAction_Status_Date(String iwhich, String iactionstatus, String iactiondate)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstm = "update BPM_Actions set actionstatus='" + iactionstatus + "', actiondate='" + iactiondate + "' where origid=" + iwhich;
	sql.execute(sqlstm);
	sql.close();
}

// database func: set actionstatus,actiondate flag
void setBPMAction_Notes(String iwhich, String inotes)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	sqlstm = "update BPM_Actions set notes='" + inotes + "' where origid=" + iwhich;
	sql.execute(sqlstm);
	sql.close();
}

