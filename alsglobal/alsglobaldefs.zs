import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Global vars and defs for ALS Technichem Malaysia

AccDatabase1 = production database
AccDatabase3 = development database

*/

mainPlayground = "//als_portal_main/";

// stuff transfered to GlobalDefs.java
MYSOFTDATABASESERVER = "alsslws007:1433";
MYSOFTDATABASENAME = "AccDatabase1";
DOCUMENTSTORAGE_DATABASE = "DocumentStorage";

FOLDERLOGGED = "LOGGED";
FOLDERDRAFT = "DRAFT";
FOLDERCOMMITED = "COMMITED";
FOLDERRELEASED = "RELEASED";
FOLDERWIP = "WIP";
FOLDERRETEST = "RETEST";

// 15/4/2010: branches job-folders prefix
JOBFOLDERS_PREFIX = "ALSM";
JB_JOBFOLDERS_PREFIX = "ALJB";
KK_JOBFOLDERS_PREFIX = "ALKK";

// ENDOF tx to globaldefs

MAINLOGIN_PAGE = "index.zul";
VERSION = "0.04.15d-vw";
SMTP_SERVER = "mail.alsglobal.com.my";
ELABMAN_EMAIL = "elabman@alsglobal.com.my";

MYSOFT_DB_DEVELOP = "AccDatabase3";

MAINPROCPATH = ".";

SAMPLES_PREFIX = "";
JOBTEST_PREFIX = "TSTP";

OPENDESTINATION_ARCODE = "320X/XXX";

// Codes prefix , used in other modules

// MANIFESTID_PREFIX = "DSPMFT";
SCHEDULEID_PREFIX = "DSPSCH";

EXTADR_PREFIX = "EXTADR";
DISPATCHER_PREFIX = "DSPRID";
DISPATCHMANIFEST_PREFIX = "DSPMAF";

// Used to determine tree trunk in Lookup table - lab-branches, SA = LOCATIONS
LOCATIONS_TREE_SHAHALAM = "LOCATIONS";
LOCATIONS_TREE_JB = "JBLOCATIONS";
LOCATIONS_TREE_KK = "KKLOCATIONS";

// Global path for modules

ACCTMOD_PATH = "acctmodules";
LABMOD_PATH = "labmodules";
SRMOD_PATH = "srmodules";
ADMINMOD_PATH = "adminmodules";

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

// General purpose lookups

String[] yesno_dropdown = { "NO" , "YES" };

String[] trail_types = { "NOTES", "INV", "COA" , "RESULTS", "RETEST", "COC", "PO", "DO", "CN" , "DN", "CANCEL", "FLUFF" };
String[] trail_status = { "PENDING", "WIP", "RELEASED", "DONE", "SHIPPED" };
String[] lu_DeliveryMethod = { "By hand", "CityLink", "FedEx", "DHL", "Registered Post", "Normal Post", "PJJ" };

String[] labfolderstatus_lookup = { "ALL" , "WIP" , "RESULT", "RELEASED" , "RETEST" };

// equipment prefix - equip manager module
EQID_PREFIX = "E";

// Run list status stuff
RUNLIST_DRAFT = "DRAFT";
RUNLIST_WIP = "WIP";
RUNLIST_RELEASED = "RELEASED";

String[] runliststatus_lookup = { "DRAFT","WIP","RELEASED" };

// COA signatories
String[] coa_signatories = {"nobody","ymkoh","leeyl","fadzillah","doc","sueann",
"zainab","wcfoong","sholah","hptan", "william","fadil","aisha","adila" };

// Purchase-req stuff
PURCHASE_REQ_PREFIX = "PRQ";

PR_STATUS_PENDING = "PENDING";
PR_STATUS_COMMITED = "COMMITTED";
PR_STATUS_APPROVED = "APPROVED";
PR_STATUS_DISAPPROVED = "DISAPPROVED";

String[] currencycode = { "MYR","IDR","USD","AUD","NZD","SGD","JPY","HKD" };

/*
String[] cashacct_email_notification = { "ymkoh@alsglobal.com.my", "sales@alsglobal.com.my", "marketing@alsglobal.com.my",
"invoice@alsglobal.com.my","foodpharma@alsglobal.com.my","finance@alsglobal.com.my","chong@alsglobal.com.my",
"liza@alsglobal.com.my", "tchin@alsglobal.com.my", "malia@pic.com.my", "oiltest@alsglobal.com.my",
"hygoh@alsglobal.com.my", "sajeeta@alsglobal.com.my", "zainab@alsglobal.com.my", "sharon@pic.com.my", "admin@alsglobal.com.my", "creditc@alsglobal.com.my",
"adminjb@alsglobal.com.my", "edwardleong@alsglobal.com.my" };

String[] blacklisted_notification = { "creditc@alsglobal.com.my", "tchin@alsglobal.com.my", "chong@alsglobal.com.my",
"liza@alsglobal.com.my","marketing@alsglobal.com.my", "sales@alsglobal.com.my", 
"ymkoh@alsglobal.com.my", "malia@pic.com.my", "adminjb@alsglobal.com.my", "edwardleong@alsglobal.com.my" };
*/

String[] sharesamplechop = { "CHEMICAL", "CHEMICAL_EH", "EV", "FOOD", "MICRO", "METALS", "METALS_BS", "CHEM_MICRO", 
"FOOD_MICRO", "EV_MICRO", "ORGANIC_FOOD", "ORGANIC", "ORGANIC_EV", "ORGANIC_MICRO", "EV_MB_ORGAN", "EV_FOOD_MB", 
"METALS_MB", "ORGAN_FOOD_MB", "BS_ORGANIC", "OF_MB_EV_OR", "WEARCHECK", "EV_FOOD" };

String[] supervisors = { "zainab", "padmin", "intan", "malia", "sharon", "connie", "nazirahcc", "metest" };

String[] signators = {
"NONE", "ymkoh", "lee", "sueann", "zainab", "wcfoong", "sholah", "tan",
"fadzillah", "adila", "sajeeta", "saminib", "goochoinyuk", "william", "fadil", "padmin" , "metest" };

