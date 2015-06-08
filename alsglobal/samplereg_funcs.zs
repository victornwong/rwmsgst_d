import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.victor.*;

sqlhand = new SqlFuncs();
//kiboo = new Generals();
//lbhandler = new ListboxHandler();
samphand = new SampleReg();
guihand = new GuiFuncs();

/*
Purpose: General purpose functions for sample-registration module we put them here
Written by : Victor Wong
Date : 11/08/2009

Notes:
29/6/2010: JOBFOLDERS_TABLE , JOBSAMPLES_TABLE and others def in alsglobal_sqlfuncs.zs
*/

// Same wrapper func to print SRA .. 
void printSRA(String ifoldi)
{
	// check all before printing the SRA
	if(ifoldi.equals("")) return;
	iod = samphand.convertFolderNoToInteger(ifoldi);
	theparam = "folder_id=" + iod.toString();
	uniqwindowid = kiboo.makeRandomId("xxprntsra");
	guihand.globalActivateWindow("//als_portal_main/","miscwindows","samplereg/print_sra.zul", uniqwindowid, theparam, useraccessobj);
	
} // end of printSRA()
	
void printSampleLabels(String ifoldi)
{
	if(ifoldi.equals("")) return;
	iod = samphand.convertFolderNoToInteger(ifoldi);
	theparam = "folder_id=" + iod.toString();
	uniqwindowid = kiboo.makeRandomId("xxprntlbls");
	guihand.globalActivateWindow("//als_portal_main/","miscwindows","samplereg/print_labels.zul", uniqwindowid, theparam, useraccessobj);
	
} // end of printSampleLabels()

// Database func - get rec from RunList , iorigid will be rec/runlist number
Object getRunList_Rec(String iorigid)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return null;
	retval = null;
	sqlstm = "select * from " + RUNLIST_TABLE + " where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func - remove everthing from RunList_Items, param: iorigid = runlist origid (ref holder)
void removeAll_RunlistItems(String iorigid)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	
	// update JobTestParameters.uploadToLIMS as well, otherwise they won't be available for dragging
	// get the list of run-list items..
	sqlst = "select * from " + RUNLISTITEMS_TABLE + " where RunList_id=" + iorigid;
	runlist_items = sql.rows(sqlst);

	if(runlist_items.size() > 0)
	{
		for(rlitem : runlist_items)
		{
			jobtestparameter_origid = rlitem.get("jobtestparam_id");
			sqlst2 = "update JobTestParameters set uploadToLIMS=0 where origid=" + jobtestparameter_origid; // make it assignable again
			sql.execute(sqlst2);
		}
	}

	// now delete the run-list items - 2-prong update!!!
	sqlst = "delete from " + RUNLISTITEMS_TABLE + " where RunList_id=" + iorigid;
	sql.execute(sqlst);
	sql.close();
}

// Delete a rec from the RunList_Items table - iorigid = which rec
void deleteRunListItem_Rec(String iorigid)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;
	sqlst2 = "delete from " + RUNLISTITEMS_TABLE + " where origid=" + iorigid;
	sql.execute(sqlst2);
	sql.close();
}

// Insert a rec into RunList_Items
// Struct: origid,RunList_id,sampleid,sampleid_str,jobtestparam_id,runitem_status
// RUNLIST_WIP def in samplereg_funcs.zs
// 29/6/2010: change raw SQL statement to prepareStatement()
void insertRunListItem_Rec(String irunlist_id, String isampleid, String isampleid_str, String ijobtestparam_id)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return;

	thecon = sql.getConnection();

	pstmt = thecon.prepareStatement("insert into " + RUNLISTITEMS_TABLE + " (RunList_id,sampleid,sampleid_str,jobtestparam_id,runitem_status) values (?,?,?,?,?)");
	pstmt.setInt(1,Integer.parseInt(irunlist_id));
	pstmt.setInt(2,Integer.parseInt(isampleid));
	pstmt.setString(3,isampleid_str);
	pstmt.setString(4,ijobtestparam_id);
	pstmt.setString(5,RUNLIST_WIP);

	pstmt.executeUpdate();

	// sqlst = "insert into " + RUNLISTITEMS_TABLE + " values (" + irunlist_id + "," + isampleid + ",'" + isampleid_str + "'," + ijobtestparam_id + ", '" + RUNLIST_WIP + "')" ;
	//sql.execute(sqlst);
	
	sql.close();
}

// Get the number of run-list items in a run-list, irunid = which run id to scour
int getRunListItems_Count(String irunid)
{
	sql = sqlhand.als_mysoftsql();
	if(sql == null) return 0;
	retval = 0;
	sqlstm = "select count(origid) as runitemscount from " + RUNLISTITEMS_TABLE + " where RunList_id=" + irunid;
	meto = sql.firstRow(sqlstm);
	sql.close();
	if(meto != null) retval = meto.get("runitemscount");
	return retval;
}

