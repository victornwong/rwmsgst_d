import java.util.*;
import java.text.*;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Global vars and defs for Rentwise Sdn Bhd
*/

// HARDCODED for now -- TODO move into lookup for easier modi
SYS_SMTPSERVER = "192.168.100.15";
SYS_EMAIL = "notification@rentwise.com";
SYS_EMAILUSER = "notification";
SYS_EMAILPWD = "rent2000wise";

GMAIL_username = "rentwisenotify@gmail.com";
GMAIL_password = "dellcomputer";

GMAIL_rwms_username = "rentwiserwms@gmail.com";
GMAIL_rwms_password = "dellcomputer";

GPF_PREFIX = "GPF"; // general-purpose-form prefix - use in doc-attach and etc

LC_PREFIX = "LC";
BOM_PREFIX = "BOM";
TICKETSV_PREFIX = "CSV";
PARTS_PREFIX = "PRT";
PICKLIST_PREFIX = "PPL";
JOBS_PREFIX = "JOB";
DO_PREFIX = "DO";
DISP_PREFIX = "DSP";
COLLECTION_PREFIX = "GCO";
GRN_PREFIX = "GRN";
PR_PREFIX = "PR";
PO_PREFIX = "RWPO";
QUOTE_PREFIX = "RWQT";
SENDOUT_PREFIX = "ST";
FC6CUST_PREFIX = "F6C";
COLDCALL_PREFIX = "CLD";
EQUIP_REQ_PREFIX = "ERG";
PARTS_REQ_PREFIX = "PRG";
AUDITITEM_PREFIX = "ADI";
MRN_PREFIX = "MRN";

CASEOPEN_STR = "OPEN";
CASECLOSE_STR = "CLOSE";
CASECANCEL_STR = "CANCEL";

LOCALRMA_PREFIX = "LRMA";
NORMAL_BACKGROUND = "background:#2e3436;";
CRITICAL_BACKGROUND = "background:#ef2929;";
URGENT_BACKGROUND = "background:#fcaf3e;";

TEMPFILEFOLDER = "tmp/";

mainPlayground = "//als_portal_main/";

// stuff transfered to GlobalDefs.java
DOCUMENTSTORAGE_DATABASE = "DocumentStorage";

MAINLOGIN_PAGE = "index.zul";
VERSION = "0.04.15d-vw";
SMTP_SERVER = "";
ELABMAN_EMAIL = "";

MAINPROCPATH = ".";

// GUI types
GUI_PANEL = 1;
GUI_WINDOW = 2;
GUI_REPORT = 3;

public class modulesObj
{
	public int module_num;
	public String module_name;
	public int accesslevel;
	
	public int module_gui;
	public String module_fn;
	public int modal_flag;
	public String parameters;
	
	public modulesObj(int imodule_num, String imodule_name, int iaccesslevel, int iguitype, String imodule_fn, int imodal_flag, String iparam)
	{
		module_num = imodule_num;
		module_name = imodule_name;
		accesslevel = iaccesslevel;
		module_gui = iguitype;
		module_fn = imodule_fn;
		modal_flag = imodal_flag;
		parameters = iparam;
	}
}

public class reportModulesObj
{
	public int module_num;
	public String module_name;
	public int accesslevel;
	
	public String parameters;
	
	public reportModulesObj(int imodule_num, String imodule_name, int iaccesslevel, String iparam)
	{
		module_num = imodule_num;
		module_name = imodule_name;
		accesslevel = iaccesslevel;
		parameters = iparam;
	}
}

SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat yearonly = new SimpleDateFormat("yyyy");
DecimalFormat nf2 = new DecimalFormat("#0.00");
DecimalFormat nf3 = new DecimalFormat("###,##0.00");
DecimalFormat nf = new DecimalFormat("###,##0.00");
DecimalFormat nf0 = new DecimalFormat("#");

BIRT_WEBVIEWER_SHORT = "/BIRT/frameset?__report=";
EXTERNAL_BIRTVIEWER = "http://192.168.130.198:8080/BIRT/frameset?__report=";

// Make the BIRT URL outta ZK Executions.getCurrent() stuff
String birtURL()
{
	callscheme = Executions.getCurrent().getScheme();
	theurl = Executions.getCurrent().getServerName();
	theport = Executions.getCurrent().getServerPort().toString();
	return callscheme + "://" + theurl + ":" + theport + BIRT_WEBVIEWER_SHORT;
	//return "http://localhost:8080";
}

// Make the BIRT URL outta ZK Executions.getCurrent() stuff
// 09/04/2012: to be used to access external BIRT server/container
String birtURL_external()
{
	return EXTERNAL_BIRTVIEWER;
}

int gpcountDiffDay(Calendar c1, Calendar c2)
{
	int returnInt = 0;
	while (!c1.after(c2))
	{
		c1.add(Calendar.DAY_OF_MONTH, 1);
		returnInt++;
	}

	if (returnInt > 0)
	{
		returnInt = returnInt - 1;
	}
	return (returnInt);
}

int gpCalcDateDiff(Date date1, Date date2)
{
	Calendar c1 = Calendar.getInstance();
	Calendar c2 = Calendar.getInstance();
	c1.setTime(date1);
	c2.setTime(date2);
	int diffDay = 0;

	if (c1.before(c2))
	{
		diffDay = gpcountDiffDay(c1, c2);
	}
	else
	{
		diffDay = gpcountDiffDay(c2, c1);
	}
	return diffDay;
}

/*
void DateDiff(Date date1, Date date2)
{
	int diffDay = diff(date1, date2);
}
*/
