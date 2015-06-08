import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Global vars and defs for ALS Technichem Malaysia

AccDatabase1 = production database
AccDatabase3 = development database

*/

MAINLOGIN_PAGE = "index.zul";

VERSION = "0.04.15d-vw";

MYSOFTDATABASESERVER = "alsslws007:1433";
MYSOFTDATABASENAME = "AccDatabase1";

SMTP_SERVER = "mail.alsglobal.com.my";
ELABMAN_EMAIL = "elabman@alsglobal.com.my";

DOCUMENTSTORAGE_DATABASE = "DocumentStorage";

MYSOFT_DB_DEVELOP = "AccDatabase3";

MAINPROCPATH = ".";

SAMPLES_PREFIX = "";
JOBTEST_PREFIX = "TSTP";

// 15/4/2010: branches job-folders prefix
JOBFOLDERS_PREFIX = "ALSM";
JB_JOBFOLDERS_PREFIX = "ALJB";
KK_JOBFOLDERS_PREFIX = "ALKK";

FOLDERLOGGED = "LOGGED";
FOLDERDRAFT = "DRAFT";
FOLDERCOMMITED = "COMMITED";
FOLDERRELEASED = "RELEASED";
FOLDERWIP = "WIP";
FOLDERRETEST = "RETEST";

OPENDESTINATION_ARCODE = "320X/XXX";

//-- billing modules
IMPORTLIMSTOMYSOFT = 1;
INVOICEDOMAN = 2;
BILLDOCSMAN = 3;
TESTPACKAGES = 4;
MARCHDOCTRACKING = 5;
CLIENT_TRACKING = 6;
BILLING_TAT_MONITORING = 7;
BILLING_BREAKDOWN_REPORT = 8;
CASHSALES_SENDOUT = 9;

QUOTATION_MAKER = 10;
INVOICEMODULE = 11;

STOCK_ITEMS_MANAGER = 12;

PURCHASE_REQ_MODULE = 13;
PURCHASE_REQ_TRACKER = 14;
PURCHASE_ITEMS_SETUP = 15;

CUSTOMER_APPLICATION = 16;
CUSTOMER_ACCOUNT_MANAGER = 17;
CUSTOMER_CREDIT_PERIOD = 18;
CUSTOMER_CATEGORY = 19;

ZEROTOLERANCECLIENTS = 150;
SETUP_CLIENT = 151;
QUOTATION_TRACKER = 152;
INVOICE_CREDITCONTROL_TRACKER = 153;
OLDMYSOFTQUOTES_BROWSER = 154;

// -- 10/09/2011
FOLDERTAGGER = 155;

//-- dispatch modules id
CUSTOMEREXTRA_ADDRESS = 20;
DISPATCHSCHEDULING = 21;
DISPATCHERMANAGER = 22;
TODAYDESTINATIONS = 23;
DISPATCHUPDATESTATUS = 24;
COURIER_OUTGOING_TRACKING = 25;
CLIENT_EXTRA_EMAIL = 26;
SEND_EMAIL_OUTSOURCE = 27;
DELIVERBYHAND_TRACKER = 28;
COLLECTCHEQUE_TRACKER = 29;

//-- box/containers modules id
BOX_MANAGER = 30;
PACKING_MANAGER = 31;
BOX_RENTAL = 32;
PACKING_RENTAL = 33;

USUAL_CONTAINTER_REQ = 34;
VIAL_METHOD5035_REQ = 35;

//-- sample registration modules id
SAMPLEREG = 40;
ASSIGNTESTS = 41;
FOLDERSMANAGER = 42;
BROWSEJOBS = 43;
FOLDERS_DAILY_REPORT = 44;
CHECK_SAMPLEID = 45;
FOLDERSAMPLES_COUNTER = 46;

ASSIGNTESTS_DEVELOP = 48;
SAMPLEREG_DEVELOP = 49;

EMAIL_SRN_DOCU = 140;

SPECIAL_IDS_SAMPREG = 130;
SPECIAL_FONTERRA_SAMPREG = 131;
SPECIAL_ASMA_SAMPREG = 132;

COC_MANAGER = 133;

// -- lab modules id

FOLDERSCHEDULE = 50;
DUEFOLDERREPORT = 51;
RUNSLIST_MOD = 52;
FOLDERTRACK_BY_TEST = 53;
FOLDERTRACK_BY_DATE = 54;
FOLDERTRACK_BY_CLIENT = 55;
DRAFT_TEMPLATE_MOD = 56;
TESTSBREAKDOWN_REPORT = 57;
RELEASE_FOLDER_MANAGER = 58;
SAMPLES_TRACKER = 59;

//-- reporting / result-entry modules id
UPDATE_REALCOA_DATE = 60;
COA_REALDATE_SUMMARY = 61;
COA_POTRAIT_V1 = 62;
UPDATE_COAPRINTOUT_DATE = 63;

TRAILER_DOCUMENTS = 64;
TRAILER_BYCLIENT = 65;
TRAILER_BYFOLDER = 66;
LANDSCAPE_COA = 67;
SEND_EMAIL_COA = 68;
LANDSCAPE_COA_SAMP_TEST = 69;

LABCOATAT_SUMMARY = 170;

// -- lab stuf again
RESULT_METALS_LIQUID = 70;
RESULT_METALS_SOLID = 71;
RESULT_ENTRY_BYRUNLIST = 72;
RESULTENTRY_BY_FOLDER = 73;
GCMS_RESULT_ENTRY = 74;
BALANCE_DATA_ENTRY = 75;
MERCURY_RESULTS_ENTRY = 76;
BALANCE_ENTRY_EV = 77;
RESULT_ENTRY_V2 = 78;

//-- QC modules id
LABLOCATION_MANAGER = 180;
EQUIPMENT_MANAGER = 181;
MEASUREMENT_UNITS = 182;
EQUIPMENT_BROWSER = 183;
MATRIX_MANAGER = 184;
CAS_MANAGER = 185;
CAS_MAPPING = 186;

//-- admin modules id
DEPARTMENTSETUP = 90;
USERSETUP = 91;
USERGROUPSETUP = 92;
USERACCESS = 93;
SWITCH_BRANCH = 94;

WEBREPORT_USERSETUP = 95;
ADMIN_AUDIT_LOGS = 96;

USER_CONTROLLER = 97;

FOLDERS_DB_MAN = 110;

ABOUTBOX = 101;
HELPBOX = 102;

COLLAB_MESSAGE = 120;
COLLAB_REMINDERS = 121;
COLLAB_TASKS = 122;

// Document management modules
LABBRAIN_DOC_MANAGER = 300;
DOCUMANAGER = 301;

PROJECT_GHD_QATAR = 220;
PROJECT_ASMA = 221;

WP_METHOD_MAPPING = 230;

// -- Wearcheck modules
WC_PREPAIDKIT = 240;

// all these custom-made BIRT reports for admin office
//BIRT_INVOICES_BY_CLIENT_CODE = 500;
//BIRT_SAMPLES_IN_INVOICE = 501; // before system going online- they store samples ID in the "remarks" field
//BIRT_INVOICES_BY_BRANCH = 502;
//BIRT_SAMPLES_BY_CLIENT = 503;
//BIRT_USERNAME_INVOICE = 504;
//BIRT_COMMITEDFOLDERS = 505;
//BIRT_SEARCHCUSTOMERPO = 506;
BIRT_EXTRACT_MYSOFT_QUOTES = 507;
//BIRT_FOLDERINVOICECOA_LIST = 508;
//BIRT_INVOICEPAID_LIST = 509;

// Developement stuff
AMBANK_EDD = 900;
STOCKBROWSWER = 901;
STOCKDIVISIONGROUP = 902;
SUPPLIER_SETUP = 903;
GRNMAKER = 904;
USERCONT = 905;
SETUPWAREHOUSE = 906;
SUPPLIERCAT_SETUP = 907;
LGKPURREQ = 908;

QUOTATION_MAKER_DEVELOPE = 909;
BILLDOCSMAN3 = 910;
FOLDERS_BROWSER_DEVELOPE = 911;
BILLING_MOD_DEVELOPE = 912;
RESULTENTRY_DEVELOPE = 913;
BILLING_UPLOAD_DEVELOPE = 914;
UPDATECOA_DATE_DEV = 915;
FRONTDESK_COLLECTION = 916;
ASSIGN_TEST_V5 = 917;
RELEASEFOLDERS_V2 = 918;

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

Object[] applicationModules = {

	new modulesObj(RELEASEFOLDERS_V2,"RELEASEFOLDERS_V2",9,GUI_PANEL,"lab/releasefolders_v2.zul",0, ""),
	new modulesObj(ASSIGN_TEST_V5,"ASSIGN_TEST_V5",9,GUI_PANEL,"samplereg/assign_tests_v5.zul",0, ""),

	new modulesObj(UPDATECOA_DATE_DEV,"UPDATECOA_DATE_DEV",9,GUI_PANEL,"reporting/update_realcoa_date_v2.zul",0, ""),
	new modulesObj(DOCUMANAGER,"DOCUMANAGER",9,GUI_PANEL,"documents/documanager_v1.zul",0, ""),
	new modulesObj(WC_PREPAIDKIT,"WC_PREPAIDKIT",9,GUI_PANEL,"wearcheck/prepaidkit_v1.zul",0, ""),
	new modulesObj(BILLING_UPLOAD_DEVELOPE,"BILLING_UPLOAD_DEVELOPE",9,GUI_PANEL,"acctmodules/billinguploader_develop.zul",0, ""),

	new modulesObj(RESULT_ENTRY_V2,"RESULT_ENTRY_V2",3,GUI_PANEL,"lab/resultentry_byfolder_v2.zul",0, ""),

	new modulesObj(FRONTDESK_COLLECTION,"FRONTDESK_COLLECTION",2,GUI_PANEL,"dispatch/frontdeskcollection.zul",0, ""),
	new modulesObj(COLLECTCHEQUE_TRACKER,"COLLECTCHEQUE_TRACKER",2,GUI_PANEL,"dispatch/collectcheque.zul",0, ""),

	new modulesObj(FOLDERTAGGER,"FOLDERTAGGER",3,GUI_PANEL,"samplereg/foldertagger_v1.zul",0, ""),
	new modulesObj(INVOICEDOMAN,"INVOICEDOMAN",3,GUI_PANEL,"acctmodules/browse_invoice.zul",0, ""),

	//new modulesObj(BIRT_INVOICEPAID_LIST,"BIRT_INVOICEPAID_LIST",3,GUI_WINDOW,"acctmodules/birt_invoicepaidlist.zul",0, ""),
	//new modulesObj(BIRT_FOLDERINVOICECOA_LIST,"BIRT_FOLDERINVOICECOA_LIST",3,GUI_WINDOW,"acctmodules/birt_folderinvoicecoa.zul",0, ""),
	new modulesObj(EMAIL_SRN_DOCU,"EMAIL_SRN_DOCU",3,GUI_PANEL,"samplereg/emaildocu_srn.zul",0, ""),
	new modulesObj(IMPORTLIMSTOMYSOFT,"importlimstomysoft",2,GUI_PANEL,"",0,"") ,

	new modulesObj(BILLING_MOD_DEVELOPE,"BILLING_MOD_DEVELOPE",9,GUI_PANEL,"acctmodules/billingbrowser_v1.zul",0, ""),
	new modulesObj(FOLDERS_BROWSER_DEVELOPE,"FOLDERS_BROWSER_DEVELOPE",9,GUI_PANEL,"samplereg/radbrowsejobs_v3.zul",0, ""),
	new modulesObj(ASSIGNTESTS_DEVELOP,"assigntests_develop",9,GUI_PANEL,"samplereg/assign_tests_v4.zul",0, ""),
	new modulesObj(SAMPLEREG_DEVELOP,"samplereg_develop",9,GUI_PANEL,"samplereg/registernew_samples_v5.zul",0, ""),
	new modulesObj(QUOTATION_MAKER_DEVELOPE,"QUOTATION_MAKER_DEVELOPE",9,GUI_PANEL,"sales/quotemaker_v3_develop.zul",0,""),
	new modulesObj(DELIVERBYHAND_TRACKER,"DELIVERBYHAND_TRACKER",9,GUI_PANEL,"dispatch/alsmairwaybill.zul",0,""),
	new modulesObj(BILLDOCSMAN3,"billdocsman3",9,GUI_PANEL,"acctmodules/billingdocsman_v3.zul",0, "") ,

	new modulesObj(INVOICE_CREDITCONTROL_TRACKER,"INVOICE_CREDITCONTROL_TRACKER",3,GUI_PANEL,"acctmodules/invoicetracker.zul",0,""),	

	new modulesObj(OLDMYSOFTQUOTES_BROWSER,"OLDMYSOFTQUOTES_BROWSER",9,GUI_PANEL,"sales/mysoftquotes_browser_v1.zul",0,""),
	new modulesObj(QUOTATION_MAKER,"QUOTATION_MAKER",3,GUI_PANEL,"sales/quotemaker_v2_develop.zul",0,""),
	new modulesObj(QUOTATION_TRACKER,"QUOTATION_TRACKER",3,GUI_PANEL,"sales/quotetracker.zul",0,""),

	new modulesObj(BIRT_EXTRACT_MYSOFT_QUOTES,"BIRT_EXTRACT_MYSOFT_QUOTES",3,GUI_WINDOW,"sales/birt_extractmysoftquotations.zul",0, ""),

	new modulesObj(BILLDOCSMAN,"billdocsman",1,GUI_PANEL,"acctmodules/billingdocsman.zul",0, "") ,
	new modulesObj(CASHSALES_SENDOUT,"cashsales_sendout",2,GUI_PANEL,"acctmodules/cashsales_sentout.zul",0, "") ,

	new modulesObj(CLIENT_TRACKING,"client_tracking",2,GUI_PANEL,"acctmodules/client_tracking.zul",0, "") ,
	new modulesObj(CUSTOMER_CREDIT_PERIOD,"customer_credit_period",3,GUI_WINDOW,"acctmodules/client_credit_period.zul",0, "") ,
	new modulesObj(CUSTOMER_CATEGORY,"customer_category",3,GUI_WINDOW,"acctmodules/client_category.zul",0, "") ,

	new modulesObj(ZEROTOLERANCECLIENTS,"zerotoleranceclients",3,GUI_PANEL,"acctmodules/ztcsetup.zul",0, "") ,
	new modulesObj(SETUP_CLIENT,"setup_client",9,GUI_PANEL,"acctmodules/setupclient.zul",0, "") ,

	new modulesObj(BILLING_TAT_MONITORING,"billing_tat_monitoring",3,GUI_PANEL,"acctmodules/billingtat_monitoring.zul",0, "") ,
	new modulesObj(MARCHDOCTRACKING,"marchdoctracking",9,GUI_PANEL,"acctmodules/marchdoctracking.zul",0, "") ,
	new modulesObj(TESTPACKAGES,"testpackages",3,GUI_PANEL,"samplereg/testpackages_man.zul",0, "") ,

	new modulesObj(STOCK_ITEMS_MANAGER,"stock_items_manager",3,GUI_PANEL,"acctmodules/stockserviceitems.zul",0, "") ,

	new modulesObj(PURCHASE_REQ_MODULE,"purchase_req_module",3,GUI_PANEL,"acctmodules/purchase_req.zul",0, "") ,
	new modulesObj(PURCHASE_ITEMS_SETUP,"purchase_items_setup",3,GUI_PANEL,"acctmodules/pr_items_manager.zul",0, "") ,
	
	new modulesObj(BILLING_BREAKDOWN_REPORT,"billing_breakdown_report",2,GUI_PANEL,"acctmodules/birt_billingbreakdown.zul",0, ""),

	new modulesObj(USERGROUPSETUP,"usergroupsetup",9,GUI_WINDOW,"adminmodules/usergroupsetup.zul",1, "") ,
	new modulesObj(USERSETUP,"usersetup",9,GUI_WINDOW,"adminmodules/usersetup.zul",1, "") ,
	new modulesObj(USERACCESS,"useraccess",9,GUI_WINDOW,"adminmodules/useraccess.zul",1, "") ,

	new modulesObj(USER_CONTROLLER,"user_controller",9,GUI_PANEL,"adminmodules/usercontroller.zul",0, ""),

	new modulesObj(WEBREPORT_USERSETUP,"webreport_usersetup",9,GUI_WINDOW,"adminmodules/webreport_usersetup.zul",1, "") ,

	new modulesObj(FOLDERS_DB_MAN,"folders_db_man",9,GUI_PANEL,"adminmodules/folderjobs_dbman.zul",1, "") ,
	new modulesObj(ADMIN_AUDIT_LOGS,"admin_audit_logs",9,GUI_PANEL,"adminmodules/adminauditlogs.zul",1, "") ,

	new modulesObj(CUSTOMEREXTRA_ADDRESS,"customerextraaddressman",3,GUI_PANEL,"dispatch/customer_extra_address.zul",0, ""),
	new modulesObj(DISPATCHSCHEDULING,"dispatchscheduling",3,GUI_PANEL,"dispatch/dispatchscheduling.zul",0, ""),
	new modulesObj(DISPATCHERMANAGER,"dispatchermanager",3,GUI_WINDOW,"dispatch/dispatcher_management.zul",0, ""),
	new modulesObj(TODAYDESTINATIONS,"todaydestinations",1,GUI_PANEL,"dispatch/todaydestinations.zul",0, ""),
	new modulesObj(DISPATCHUPDATESTATUS,"dispatchupdate_status",2,GUI_PANEL,"dispatch/dispatch_updatestatus.zul",0, ""),

	new modulesObj(SEND_EMAIL_OUTSOURCE,"send_email_outsource",2,GUI_WINDOW,"dispatch/sendemailoutsource.zul",0, ""),

	new modulesObj(CLIENT_EXTRA_EMAIL,"client_extra_email",3,GUI_WINDOW,"dispatch/client_extra_email.zul",0, ""),

	new modulesObj(COURIER_OUTGOING_TRACKING,"courier_outgoing_tracking",2,GUI_PANEL,"dispatch/courier_outgoing.zul",0, ""),

	new modulesObj(SAMPLEREG,"sampleregistration",3,GUI_PANEL,"samplereg/registernew_samples_v4.zul",0, ""),
	new modulesObj(ASSIGNTESTS,"assigntests",3,GUI_PANEL,"samplereg/assign_tests_v4.zul",0, ""),
	//new modulesObj(FOLDERSMANAGER,"foldersman",2,GUI_PANEL,"samplereg/folderjobs_man.zul",0, ""),
	new modulesObj(FOLDERSMANAGER,"foldersman",2,GUI_PANEL,"acctmodules/billinguploader.zul",0, ""),
	new modulesObj(BROWSEJOBS,"browsejobs",1,GUI_PANEL,"samplereg/browsejobs_v2.zul",0, ""),
	new modulesObj(FOLDERS_DAILY_REPORT,"folders_daily_report",1,GUI_PANEL,"samplereg/folders_daily_report.zul",0, ""),
	new modulesObj(CHECK_SAMPLEID,"check_sampleid",1,GUI_PANEL,"samplereg/checksampleid.zul",0, ""),
	new modulesObj(FOLDERSAMPLES_COUNTER,"foldersamples_counter",2,GUI_PANEL,"samplereg/foldersample_counter.zul",0, ""),
	new modulesObj(SPECIAL_IDS_SAMPREG,"SPECIAL_IDS_SAMPREG",2,GUI_PANEL,"samplereg/special_ids_sampreg.zul",0, ""),

	new modulesObj(COC_MANAGER,"coc_manager",9,GUI_PANEL,"samplereg/coc_manager.zul",0, ""),

	new modulesObj(FOLDERSCHEDULE,"folders_schedule",9,GUI_PANEL,"lab/folders_schedule.zul",0, ""),
	new modulesObj(DUEFOLDERREPORT,"duefolderreport",2,GUI_PANEL,"reporting/duefoldersview.zul",0, ""),
	new modulesObj(RUNSLIST_MOD,"runslist_mod",9,GUI_PANEL,"lab/runlist_v2.zul",0, ""),
	new modulesObj(DRAFT_TEMPLATE_MOD,"draft_template_mod",2,GUI_PANEL,"lab/draft_template.zul",0, ""),

	new modulesObj(TESTSBREAKDOWN_REPORT,"testsbreakdown_report",3,GUI_WINDOW,"lab/birt_testsbreakdown.zul",0, ""),

	new modulesObj(FOLDERTRACK_BY_TEST,"foldertrack_by_test",2,GUI_PANEL,"lab/foldertrack_bytest.zul",0, ""),
	new modulesObj(FOLDERTRACK_BY_DATE,"foldertrack_by_date",2,GUI_PANEL,"lab/foldertrack_bydate.zul",0, ""),
	new modulesObj(FOLDERTRACK_BY_CLIENT,"foldertrack_by_client",2,GUI_PANEL,"lab/foldertrack_byclient.zul",0, ""),

	new modulesObj(SAMPLES_TRACKER,"samples_tracker",2,GUI_PANEL,"lab/samplestracking.zul",0, ""),

	new modulesObj(RESULTENTRY_BY_FOLDER,"resultentry_by_folder",2,GUI_PANEL,"lab/resultentry_byfolder.zul",0, ""),
	new modulesObj(RESULT_ENTRY_BYRUNLIST,"result_entry_byrunlist",9,GUI_PANEL,"lab/runlist_result_entry.zul",0, ""),

	new modulesObj(RELEASE_FOLDER_MANAGER,"release_folder_manager",9,GUI_PANEL,"lab/releasefolders.zul",0, ""),

	new modulesObj(PROJECT_GHD_QATAR,"project_ghd_qatar",9,GUI_PANEL,"labprojects/specialproject.zul",0, "paneltitle=HACO&arcode=300H/131"),
	new modulesObj(PROJECT_ASMA,"project_asma",9,GUI_PANEL,"labprojects/specialproject.zul",0, "paneltitle=ASMA&arcode=300A/008"),

	new modulesObj(UPDATE_REALCOA_DATE,"update_realcoa_date",2,GUI_PANEL,"reporting/update_realcoa_date_v2.zul",0, ""),
	new modulesObj(COA_REALDATE_SUMMARY,"coa_realdate_summary",2,GUI_PANEL,"reporting/update_realcoa_date.zul",0, ""),
	new modulesObj(UPDATE_COAPRINTOUT_DATE,"update_coaprintout_date",2,GUI_PANEL,"reporting/update_coaprintout_date.zul",0, ""),

	new modulesObj(LABCOATAT_SUMMARY,"labcoatat_summary",3,GUI_WINDOW,"lab/folderscoatatlist.zul",0, ""),

	new modulesObj(COA_POTRAIT_V1,"coa_potrait_v1",3,GUI_PANEL,"reporting/potrait_single_coa.zul",0, ""),
	new modulesObj(LANDSCAPE_COA,"landscape_coa",3,GUI_PANEL,"reporting/landscape_coa.zul",0,"scapetype=1&wintitle=1"),
	new modulesObj(LANDSCAPE_COA_SAMP_TEST,"landscape_coa_samp_test",3,GUI_PANEL,"reporting/landscape_coa.zul",0,"scapetype=2&wintitle=2"),

	new modulesObj(SEND_EMAIL_COA,"send_email_coa",9,GUI_PANEL,"reporting/send_email_coa.zul",0, ""),

	new modulesObj(RESULT_METALS_LIQUID,"result_metals_liquid",2,GUI_PANEL,"lab/result_metals_liquid.zul",0, ""),
	new modulesObj(GCMS_RESULT_ENTRY,"gcms_result_entry",9,GUI_PANEL,"lab/result_gc_ms.zul",0, ""),
	
	new modulesObj(MERCURY_RESULTS_ENTRY,"MERCURY_RESULTS_ENTRY",9,GUI_PANEL,"lab/mercury_resultsentry_1.zul",0, ""),

	new modulesObj(BALANCE_DATA_ENTRY,"BALANCE_DATA_ENTRY",2,GUI_PANEL,"lab/balancedata_entry.zul",0, ""),
	new modulesObj(BALANCE_ENTRY_EV,"BALANCE_ENTRY_EV",9,GUI_PANEL,"lab/balancedata_entry_ev.zul",0, ""),

	new modulesObj(LABLOCATION_MANAGER,"lablocation_manager",2,GUI_WINDOW,"qc/locationmanager.zul",0, ""),
	new modulesObj(EQUIPMENT_MANAGER,"equipment_manager",2,GUI_PANEL,"qc/equipmentmanager.zul",0, ""),
	new modulesObj(EQUIPMENT_BROWSER,"EQUIPMENT_BROWSER",2,GUI_PANEL,"qc/equipbrowser.zul",0, ""),

	new modulesObj(MEASUREMENT_UNITS,"measurement_units",3,GUI_WINDOW,"qc/setup_units.zul",0, ""),
	new modulesObj(MATRIX_MANAGER,"matrix_manager",3,GUI_WINDOW,"qc/matrix_manager.zul",0, ""),
	new modulesObj(CAS_MANAGER,"cas_manager",3,GUI_WINDOW,"qc/casnumbers.zul",0, ""),
	new modulesObj(CAS_MAPPING,"cas_mapping",3,GUI_PANEL,"qc/casmapping.zul",0, ""),

	new modulesObj(VIAL_METHOD5035_REQ,"vial_method5035_req",3,GUI_PANEL,"containers/vialmethod5035_req.zul",0, ""),

	new modulesObj(USUAL_CONTAINTER_REQ,"usual_containter_req",9,GUI_PANEL,"containers/containersreq.zul",0, ""),

	new modulesObj(TRAILER_DOCUMENTS,"trailer_documents",2,GUI_PANEL,"acctmodules/documents_trailer.zul",0, ""),
	new modulesObj(TRAILER_BYCLIENT,"trailer_byclient",9,GUI_PANEL,"acctmodules/client_trails_browser.zul",0, ""),

	new modulesObj(LABBRAIN_DOC_MANAGER,"labbrain_doc_manager",9,GUI_PANEL,"elabbrain/braindocs_manager.zul",0, ""),

	new modulesObj(COLLAB_MESSAGE,"collab_message",9,GUI_WINDOW,"collab/messages.zul",0, ""),

	new modulesObj(ABOUTBOX,"aboutbox",1,GUI_WINDOW,"aboutbox.zul",1, ""),
	new modulesObj(HELPBOX,"helpbox",1,GUI_WINDOW,"helpbox.zul",1, ""),

	new modulesObj(WP_METHOD_MAPPING,"wp_method_mapping",3,GUI_PANEL,"edd/wp_method_mapping.zul",0, ""),

	new modulesObj(AMBANK_EDD,"ambank_edd",9,GUI_PANEL,"lgk_acctmods/ambank_inout.zul",0, ""),
	new modulesObj(STOCKBROWSWER,"stockbrowswer",9,GUI_PANEL,"lgk_acctmods/stockbrowser.zul",0, ""),
	new modulesObj(STOCKDIVISIONGROUP,"stockdivisiongroup",9,GUI_PANEL,"lgk_acctmods/stockdivisionsetup.zul",0, ""),
	new modulesObj(SUPPLIER_SETUP,"supplier_setup",9,GUI_PANEL,"lgk_acctmods/suppliersetup.zul",0, ""),
	new modulesObj(GRNMAKER,"grnmaker",9,GUI_PANEL,"lgk_acctmods/grnmaker.zul",0, ""),
	new modulesObj(USERCONT,"usercont",9,GUI_PANEL,"lgk_adminmods/usercontroller.zul",0, ""),
	new modulesObj(SETUPWAREHOUSE,"setupwarehouse",9,GUI_WINDOW,"lgk_acctmods/setupwarehouse.zul",0, ""),
	new modulesObj(SUPPLIERCAT_SETUP,"suppliercat_setup",9,GUI_WINDOW,"lgk_acctmods/suppliercatsetup.zul",0, ""),
	new modulesObj(LGKPURREQ,"lgkpurreq",9,GUI_PANEL,"lgk_acctmods/purchase_req.zul",0, ""),

	};

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
String[] coa_signatories = {"nobody","ymkoh","leeyl","fadzillah","dian","doc","azlina","sueann",
"zainab","wcfoong","swgoh","sholah","sychew","hptan","june"};

// Purchase-req stuff
PURCHASE_REQ_PREFIX = "PRQ";

PR_STATUS_PENDING = "PENDING";
PR_STATUS_COMMITED = "COMMITTED";
PR_STATUS_APPROVED = "APPROVED";
PR_STATUS_DISAPPROVED = "DISAPPROVED";

String[] currencycode = { "MYR","IDR","USD","AUD","NZD","SGD","JPY","HKD" };

String[] cashacct_email_notification = { "ymkoh@alsglobal.com.my", "sales@alsglobal.com.my", "marketing@alsglobal.com.my",
"invoice@alsglobal.com.my","foodpharma@alsglobal.com.my","finance@alsglobal.com.my","chong@alsglobal.com.my",
"liza@alsglobal.com.my", "tchin@alsglobal.com.my", "malia@pic.com.my", "oiltest@alsglobal.com.my",
"hygoh@alsglobal.com.my", "sajeeta@alsglobal.com.my", "zainab@alsglobal.com.my", "sharon@pic.com.my", "admin@alsglobal.com.my", "creditc@alsglobal.com.my",
"adminjb@alsglobal.com.my", "edwardleong@alsglobal.com.my" };

String[] blacklisted_notification = { "creditc@alsglobal.com.my", "tchin@alsglobal.com.my", "chong@alsglobal.com.my",
"liza@alsglobal.com.my","chen@alsglobal.com.my", "marketing@alsglobal.com.my", "sales@alsglobal.com.my", 
"ymkoh@alsglobal.com.my", "malia@pic.com.my", "adminjb@alsglobal.com.my", "edwardleong@alsglobal.com.my" };

String[] sharesamplechop = { "CHEMICAL", "CHEMICAL_EH", "EV", "FOOD", "MICRO", "METALS", "METALS_BS", "CHEM_MICRO", 
"FOOD_MICRO", "EV_MICRO", "ORGANIC_FOOD", "ORGANIC", "ORGANIC_EV", "ORGANIC_MICRO", "EV_MB_ORGAN", "EV_FOOD_MB", 
"METALS_MB", "ORGAN_FOOD_MB", "BS_ORGANIC", "OF_MB_EV_OR", "WEARCHECK", "EV_FOOD" };

String[] supervisors = { "zainab", "sajeeta", "padmin", "intan", "malia", "sharon", "connie" };

