import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Purpose: General purpose functions for sample-registration module we put them here
Written by : Victor Wong
Date : 11/08/2009

Notes:
29/6/2010: JOBFOLDERS_TABLE , JOBSAMPLES_TABLE and others def in alsglobal_sqlfuncs.zs
*/

// Chop off ALSM(def in alsglobaldefs.zs) from the folder/job ID, eg ALSMXXXXX
// It will return from position 4 till end. Do not use this for full sample ID, eg ALSM0000100010 , it will return 0000100010
// use the other function
String extractFolderNo(String iwhich)
{
	retval = "";
	if(!iwhich.equals("")) retval = iwhich.substring(4,9);
	return retval;
}

// ALSM0000100010 -> returns 00001
String extractFolderNo_FromSampleID(String iwhich)
{
	retval = "";
	if(!iwhich.equals("") && iwhich.length() == 14) retval = iwhich.substring(4,9);
	return retval;
}

// ALSM000010010 -> returns ALSM00001
String extractFolderString_FromSampleID(String iwhich)
{
	retval = "";
	if(!iwhich.equals("") && iwhich.length() > 8) retval = iwhich.substring(0,9);
	return retval;
}

// chop out sample number . eg. ALSM0000100001 -> last 00001
// NOTES: if sample number increase to 6 digits.. change accordingly for substring(9,15) = 100000
String extractSampleNo(String iwhich)
{
	retval = "";
	//if(!iwhich.equals("")) retval = Integer.parseInt(iwhich.substring(9,14)).toString();
	if(!iwhich.equals(""))
	{
		// 10/03/2011: to cater for 6 digits sample-id
		if(iwhich.length() > 14)
			retval = Integer.parseInt(iwhich.substring(9,15)).toString();
		else
			retval = Integer.parseInt(iwhich.substring(9,14)).toString();
	}
	return retval;
}

int convertSampleNoToInteger(String iwhich)
{
	retval = 0;
	wopi = extractSampleNo(iwhich);
	if(!wopi.equals("")) retval = Integer.parseInt(wopi);
	return retval;
}

int convertFolderNoToInteger(String iwhich)
{
	retval = 0;
	wopi = extractFolderNo(iwhich);
	if(!wopi.equals("")) retval = Integer.parseInt(wopi);
	return retval;
}

// Get rec from database - mysoft.JobSamples
// iwhich = origid
Object getFolderSampleRec(String iwhich)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	retval = null;
	sqlstatem = "select * from " + JOBSAMPLES_TABLE + " where origid=" + iwhich;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;

} // end of getFolderSampleRec()

// get rec from mysoft.jobfolders - iwhich = origid
Object getFolderJobRec(String iwhich)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	retval = null;
	sqlstatem = "select * from " + JOBFOLDERS_TABLE + " where origid=" + iwhich;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

void updateJobFolder_COADate(String theorigid, String thedate)
{
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "update " + JOBFOLDERS_TABLE + " set coadate='" + thedate + "' where origid=" + theorigid;
	sql.execute(sqlstm);
	sql.close();
}

void updateJobFolder_labfolderstatus(String theorigid, String thestatus)
{
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "update " + JOBFOLDERS_TABLE + " set labfolderstatus='" + thestatus + "' where origid=" + theorigid;
	sql.execute(sqlstm);
	sql.close();
}

void updateJobFolder_COAPrintoutDate(String theorigid, String thedate)
{
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "update " + JOBFOLDERS_TABLE + " set coaprintdate='" + thedate + "' where origid=" + theorigid;
	sql.execute(sqlstm);
	sql.close();
}


/*
Actually insert rec into database - refer to mysoft.jobsamples table
origid, sampleid_str, samplemarking, matrix, extranotes, jobfolders_id, uploadToLIMS, uploadToMYSOFT, deleted, status
16/4/2010: added fields : releasedby, releaseddate
25/11/2010: change iwhich to folder's origid instead of full folder string
*/
void createNewSampleRec(String iwhich)
{
	ifolderno = convertFolderNoToInteger(iwhich);
	if(ifolderno == 0) return;

	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstatem = "insert into " + JOBSAMPLES_TABLE + " (sampleid_str,samplemarking,matrix,extranotes,jobfolders_id,uploadtolims,uploadtomysoft,deleted,status,releasedby,releaseddate) " + 
	"values ('','','',''," + ifolderno.toString() + ",0,0,0,'','','')";
	sql.execute(sqlstatem);
	sql.close();

} // end of createNewSamples()

void createNewSampleRec2(String iwhich)
{
	// ifolderno = convertFolderNoToInteger(iwhich);
	// if(ifolderno == 0) return;

	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstatem = "insert into " + JOBSAMPLES_TABLE + " (sampleid_str,samplemarking,matrix,extranotes,jobfolders_id,uploadtolims,uploadtomysoft,deleted,status,releasedby,releaseddate) " + 
	"values ('','','',''," + iwhich + ",0,0,0,'','','')";
	sql.execute(sqlstatem);
	sql.close();

} // end of createNewSamples()

void toggleSampleDeleteFlag(String iwhich, String iwhat)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlstatem = "update JobSamples set deleted=" + iwhat + " where origid=" + iwhich;
	sql.execute(sqlstatem);
	sql.close();
}


/*
MUST MOD THIS ONE -- 29/6/2010
Refer to mysoft.jobfolders for field names. First field, origid, no need to insert, it's auto-inc
2/2/2010: jobfolders -> fields
10/2/2010: added 2 more fields
29/3/2010: added branch field
origid,ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate,tat,extranotes,folderstatus,deleted, folderno_str,deliverymode
securityseal,noboxes,temperature,custreqdate,customerpo,customercoc,allgoodorder,paperworknot,paperworksamplesnot,samplesdamaged,attention,
priority, exportReportTemplate,branch, labfolderstatus, releasedby
16/4/2010: added labfolderstatus = WIP, RELEASED, RETEST
	added releasedby = username who released the folder
	added releaseddate = date of which folder is released
1/6/2010: added new field - JobFolders.coadate
3/6/2010: added new field - JobFolders.coaprintdate
*/
/*
void createNewFolderJob(Datebox ihiddendatebox, String ibranch)
{
	todaysdate = getDateFromDatebox(ihiddendatebox);

	sql = als_mysoftsql();
    if(sql == NULL) return;

	sqlstatem = "insert into " + JOBFOLDERS_TABLE + " values ('','" + todaysdate + "',0,0,'" + todaysdate + "',7,'','" + FOLDERDRAFT + "',0, '','','','','','" + todaysdate + 
		"','','',0,0,0,0,'','NORMAL',0,'" + ibranch + "', 'WIP', '', '', '', '' )";
	
	sql.execute(sqlstatem);
	sql.close();
	
} // end of createNewFolderJob()
*/

void createNewFolderJob(Datebox ihiddendatebox, String ibranch)
{
	todaysdate = getDateFromDatebox(ihiddendatebox);
	sql = als_mysoftsql();
    if(sql == NULL) return;
	
	thecon = sql.getConnection();
	
	pstmt = thecon.prepareStatement("insert into " + JOBFOLDERS_TABLE + 
	" (ar_code,datecreated,uploadToLIMS,uploadToMYSOFT,duedate, tat,extranotes,folderstatus,deleted,folderno_str, deliverymode,securityseal,noboxes,temperature," +
	" custreqdate, customerpo,customercoc,allgoodorder,paperworknot,paperworksamplesnot, samplesdamaged,attention,priority,exportReportTemplate," +
	" branch, labfolderstatus,releasedby,releaseddate,coadate,coaprintdate, jobnotes,lastjobnotesdate,share_sample) values (?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?)");

	pstmt.setString(1,"");
	pstmt.setString(2,todaysdate);
	pstmt.setInt(3,0);
	pstmt.setInt(4,0);
	pstmt.setString(5,todaysdate);

	pstmt.setInt(6,7);
	pstmt.setString(7,"");
	pstmt.setString(8,FOLDERDRAFT);
	pstmt.setInt(9,0);
	pstmt.setString(10,"");

	pstmt.setString(11,"");
	pstmt.setString(12,"");
	pstmt.setString(13,"");
	pstmt.setString(14,"");
	pstmt.setString(15,todaysdate);

	pstmt.setString(16,"");
	pstmt.setString(17,"");
	pstmt.setInt(18,0);
	pstmt.setInt(19,0);
	pstmt.setInt(20,0);

	pstmt.setInt(21,0);
	pstmt.setString(22,"");
	pstmt.setString(23,"NORMAL");
	pstmt.setInt(24,0);
	pstmt.setString(25,ibranch);

	pstmt.setString(26,"WIP");
	pstmt.setString(27,"");
	pstmt.setString(28,"");
	pstmt.setString(29,"");
	pstmt.setString(30,"");

	pstmt.setString(31,"");
	pstmt.setString(32,"");
	pstmt.setString(33,"");

	pstmt.executeUpdate();
	sql.close();
}

// get the full rec from database -> JobTestParameters
// iwhich = which origid id
Object getJobTestParametersRec(String iwhich)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	retval = null;
	sqlstatem = "select * from " + JOBTESTPARAMETERS_TABLE + " where origid=" + iwhich;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

// get a rec from StockMasterDetails based on which ID/iwhich
Object getStockMasterDetails(String iwhich)
{
	sql = als_mysoftsql();
	if(sql == null) return null;
	retval = null;
	sqlstatem = "select * from stockmasterdetails where id=" + iwhich;
	retval = sql.firstRow(sqlstatem);
	sql.close();
	return retval;
}

// Same wrapper func to print SRA .. 
void printSRA(String ifoldi)
{
	// check all before printing the SRA
	if(ifoldi.equals("")) return;
	iod = convertFolderNoToInteger(ifoldi);
	theparam = "folder_id=" + iod.toString();
	uniqwindowid = makeRandomId("xxprntsra");
	globalActivateWindow("miscwindows","samplereg/print_sra.zul", uniqwindowid, theparam, useraccessobj);
	
} // end of printSRA()
	
void printSampleLabels(String ifoldi)
{
	if(ifoldi.equals("")) return;
	iod = convertFolderNoToInteger(ifoldi);
	theparam = "folder_id=" + iod.toString();
	uniqwindowid = makeRandomId("xxprntlbls");
	globalActivateWindow("miscwindows","samplereg/print_labels.zul", uniqwindowid, theparam, useraccessobj);
	
} // end of printSampleLabels()

// To save folder->samples full id string..
// isamplb = samples listbox to go thru
void saveFolderSamplesNo_Main(Listbox isamplb)
{
	// go through the isamplb
	numrec = isamplb.getItemCount();
	if(numrec == 0) return; // nothing, return lo

	sql = als_mysoftsql();
	if(sql == null) return;

	for(i=0; i<numrec; i++)
	{
		// get the sample-id
		//selitem = isamplb.getItemAtIndex(i);
		//iorigid = getListcellItemLabel(selitem,0);
		//yobo = getListcellItemLabel(selitem,1);
		yobo = isamplb.getItemAtIndex(i).getLabel();
		iorigid = convertSampleNoToInteger(yobo);
		sqlstatem = "update " + JOBSAMPLES_TABLE + " set sampleid_str='" + yobo + "' where origid=" + iorigid.toString();
		sql.execute(sqlstatem);
	}
	sql.close();
}

void saveFolderSamplesNo_Main2(Listbox isamplb)
{
	// go through the isamplb
	numrec = isamplb.getItemCount();
	if(numrec == 0) return; // nothing, return lo

	sql = als_mysoftsql();
	if(sql == null) return;

	for(i=0; i<numrec; i++)
	{
		// get the sample-id
		selitem = isamplb.getItemAtIndex(i);
		iorigid = getListcellItemLabel(selitem,0);
		yobo = getListcellItemLabel(selitem,2);
		//iorigid = convertSampleNoToInteger(yobo);
		sqlstatem = "update " + JOBSAMPLES_TABLE + " set sampleid_str='" + yobo + "' where origid=" + iorigid;
		sql.execute(sqlstatem);
	}
	sql.close();
}

int getNumberOfSamples_InFolder(int ifolderno)
{
	sql = als_mysoftsql();
    if(sql == NULL) return 0;
	retval = 0;
	sqlstatem = "select count(origid) as samplecount from " + JOBSAMPLES_TABLE + " where deleted=0 and jobfolders_id=" + ifolderno.toString();
	merec = sql.firstRow(sqlstatem);
	sql.close();
	if(merec != null) retval = merec.get("samplecount");
	return retval;
}

// Database func - get rec from RunList , iorigid will be rec/runlist number
Object getRunList_Rec(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == NULL) return null;
	retval = null;
	sqlstm = "select * from " + RUNLIST_TABLE + " where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// Database func - remove everthing from RunList_Items, param: iorigid = runlist origid (ref holder)
void removeAll_RunlistItems(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	
	// update JobTestParameters.uploadToLIMS as well, otherwise they won't be available for dragging
	// get the list of run-list items..
	sqlst = "select * from " + RUNLISTITEMS_TABLE + " where RunList_id=" + iorigid;
	runlist_items = sql.rows(sqlst);

	if(runlist_items.size() > 0)
	{
		for(rlitem : runlist_items)
		{
			jobtestparameter_origid = rlitem.get("jobtestparam_id");
			sqlst2 = "update " + JOBTESTPARAMETERS_TABLE + " set uploadToLIMS=0 where origid=" + jobtestparameter_origid; // make it assignable again
			sql.execute(sqlst2);
		}
	}

	// now delete the run-list items - 2-prong update!!!
	sqlst = "delete from " + RUNLISTITEMS_TABLE + " where RunList_id=" + iorigid;
	sql.execute(sqlst);
	sql.close();
}

// Update JobTestParameters.uploadToLIMS flaggy
// params: iorigid = which jtp origid
//		iwhat = flaggy, 0 or 1 or whatever if needed later
void updateJTP_uploadtolims_flag(String iorigid, int iwhat)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
	sqlst2 = "update " + JOBTESTPARAMETERS_TABLE + " set uploadToLIMS=" + iwhat.toString() + " where origid=" + iorigid;
	sql.execute(sqlst2);
	sql.close();
}

// Delete a rec from the RunList_Items table - iorigid = which rec
void deleteRunListItem_Rec(String iorigid)
{
	sql = als_mysoftsql();
	if(sql == NULL) return;
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
	sql = als_mysoftsql();
	if(sql == NULL) return;

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
	sql = als_mysoftsql();
	if(sql == NULL) return 0;
	retval = 0;
	sqlstm = "select count(origid) as runitemscount from " + RUNLISTITEMS_TABLE + " where RunList_id=" + irunid;
	meto = sql.firstRow(sqlstm);
	sql.close();
	if(meto != null) retval = meto.get("runitemscount");
	return retval;
}

// 11/6/2010: get rec from CashSales_CustomerInfo by iwhich=folderno_str
Object getCashSalesCustomerInfo_Rec(String iwhich)
{
	retval = null;
	sql = als_mysoftsql();
    if(sql == NULL) return retval;
	sqlstm = "select * from " + CASHSALES_CUSTOMERINFO_TABLE + " where folderno_str='" + iwhich + "'";
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

void deleteCashSalesCustomerInfo_Rec(String iwhich)
{
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "delete from " + CASHSALES_CUSTOMERINFO_TABLE + " where folderno_str='" + iwhich + "'";
	sql.execute(sqlstm);
	sql.close();
}

// Database func: insert a test into JobTestParameters table
// later need to add more stuff, LOR and shit like that
void insertJobTestParameters_Rec(String iorigid, String imysoftcode)
{
	sql = als_mysoftsql();
	if(sql == null) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into JobTestParameters (jobsamples_id,mysoftcode,starlimscode,status,uploadToMYSOFT,uploadToLIMS) values (?,?,?,?,?,?)");
	pstmt.setInt(1,Integer.parseInt(iorigid));
	pstmt.setInt(2,Integer.parseInt(imysoftcode));
	pstmt.setInt(3,0);
	pstmt.setString(4,"");
	pstmt.setInt(5,0);
	pstmt.setInt(6,0);
	pstmt.executeUpdate();
	sql.close();
}

// Database func: remove a rec from JobTestParameters table based on origid passed
void deleteJobTestParameters_Rec(String iorigid)
{
	if(iorigid.equals("")) return;
	sql = als_mysoftsql();
    if(sql == NULL) return;
	sqlstm = "delete from JobTestParameters where origid=" + iorigid;
	sql.execute(sqlstm);
	sql.close();
}

// Database func: insert new rec into JobNotes_History
void insertJobNotesHistory_Rec(String ifolderorigid, String ioldjobnotes, String inewjobnotes, String ithedate, String iusername)
{
	sql = als_mysoftsql();
	if(sql == null ) return;
	thecon = sql.getConnection();
	pstmt = thecon.prepareStatement("insert into JobNotes_History (jobfolders_id,oldjobnotes,newjobnotes,change_date,user_changed) values (?,?,?,?,?)");
	pstmt.setInt(1,Integer.parseInt(ifolderorigid));
	pstmt.setString(2,ioldjobnotes);
	pstmt.setString(3,inewjobnotes);
	pstmt.setString(4,ithedate);
	pstmt.setString(5,iusername);
	pstmt.executeUpdate();
	sql.close();
}

// Database func: read a rec from JobNotes_History
Object getJobNotesHistory_Rec(String iorigid)
{
	retval = null;
	sql = als_mysoftsql();
    if(sql == NULL) return retval;
	sqlstm = "select * from JobNotes_History where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}
