/*
BIRT Report Templates and funcs
Specified for : ALS Technichem(M) Sdn Bhd

Written by	: Victor Wong

Revision notes:

03/03/2010: first creation, move all scattered birt reports filename here
16/05/2011: reorganize and put BIRT templates into an array.. use common report-browser window with dynamic URL

*/

// Knockoff and trimmed from modulesObj in alsglobaldefs.zs
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

// Index to birtReportTemplates[] - clearer manipulation in funcs
JOBSAMPLETESTS_DUMP = 0;
BIRT_INVOICES_BY_CLIENT_CODE = 1;
BIRT_INVOICES_BY_BRANCH = 2;
BIRT_SAMPLES_IN_INVOICE = 3;
BIRT_SEARCHCUSTOMERPO = 4;
BIRT_USERNAME_INVOICE = 5;
BIRT_SAMPLES_BY_CLIENT = 6;
BIRT_COMMITEDFOLDERS = 7;
BIRT_FOLDERINVOICECOA_LIST = 8;
BIRT_INVOICEPAID_LIST = 9;
BIRT_DEBTLEDGER_EXTRACT = 10;
BIRT_FOLDERDOINV_CROSSREF = 11;
BIRT_QUOTEDUMPTRACKS = 12;
BIRT_DISPATCH_COLLECTCHEQ = 13;
BIRT_CONVERTEDCASHFOLDER = 14;

// 16/05/2011: put all birt templates into string array..
String[] birtReportTemplates = {
	"alsReports/jobsamplestests_dump.rptdesign",			// 0
	"alsReports/extractInvoices_by_ClientCode.rptdesign",	// 1
	"alsReports/extractInvoices_by_Branch.rptdesign",		// 2
	"alsReports/SampleInvoice.rptdesign",					// 3
	// 12/4/2010: Search customer PO - uses PurchaseOrder field in Invoice table
	"alsReports/SearchCustomerPO.rptdesign",				// 4
	"alsReports/username_invoice_acctbase1.rptdesign",		// 5
	"alsReports/samplesby_client_acctbase1.rptdesign",		// 6
	"alsReports/commitedfolders_acctbase1.rptdesign",		// 7
	"alsReports/billingcoaTAT_v3_3.rptdesign",				// 8
	"alsReports/invoicepayment_list_v1.rptdesign",			// 9
	"alsReports/debtLedgerExtracts.rptdesign",				// 10
	"alsReports/DOInvoiceCrossRef.rptdesign",				// 11
	"alsReports/quotetrackdump_v1.rptdesign",				// 12
	"alsReports/dispatch_cheqcollect.rptdesign",			// 13
	"alsReports/convertedCashFolder_v1_4.rptdesign",			// 14
	};

Object[] allReportModules =
{
	new reportModulesObj(JOBSAMPLETESTS_DUMP,"Samples-Tests Check List",2,""),
	new reportModulesObj(BIRT_INVOICES_BY_CLIENT_CODE,"Retrieve invoices by client-code(AR Code)",2,""),
	new reportModulesObj(BIRT_INVOICES_BY_BRANCH,"Retrieve invoices by branch (HQ/JB)",2,""),
	new reportModulesObj(BIRT_SAMPLES_IN_INVOICE,"Check samples ID in Invoices (12/02/2010 backwards)",2,""),
	new reportModulesObj(BIRT_SEARCHCUSTOMERPO,"Find customer PO# in invoices",2,""),
	new reportModulesObj(BIRT_USERNAME_INVOICE,"Mysoft username gen invoice",2,""),
	new reportModulesObj(BIRT_SAMPLES_BY_CLIENT,"Samples by client list",2,""),
	new reportModulesObj(BIRT_COMMITEDFOLDERS,"Committed/Uploaded report",2,""),
	new reportModulesObj(BIRT_FOLDERINVOICECOA_LIST,"Billing/TAT v.3",2,""),
	new reportModulesObj(BIRT_INVOICEPAID_LIST,"Invoice and Payment Listing",2,""),
	new reportModulesObj(BIRT_DEBTLEDGER_EXTRACT,"Debtor Ledger Data Extractor",2,""),
	new reportModulesObj(BIRT_FOLDERDOINV_CROSSREF,"Combined billing cross-ref",2,""),
	new reportModulesObj(BIRT_QUOTEDUMPTRACKS,"Quotations Trackers",2,""),
	new reportModulesObj(BIRT_DISPATCH_COLLECTCHEQ,"Dispatcher - Collect Cheque Listing",2,""),
	new reportModulesObj(BIRT_CONVERTEDCASHFOLDER,"Converted cash folders report",2,""),
};

// BIRT webviewer location
BIRT_WEBVIEWER = "http://alsslws007:18080/BIRT/frameset?__report=";
BIRT_WEBVIEWER_SHORT = "/BIRT/frameset?__report=";

FOLDERS_DAILY_REPORT_FILENAME = "DailyFolders_List_v1.rptdesign";

// params: jobfolder_id = folder id origid only
BIRT_SRA_FILENAME = "SRA_v2.rptdesign";

// params: FolderNo = folder no 
BIRT_SAMPLELABELS_FILENAME = "sampleLabel_v1_acctbase1.rptdesign";

// Due folders report
BIRT_DUEFOLDERREPORT_FILENAME = "duedate_fld_acctbase1.rptdesign";

// single sample single page COA
BIRT_COAPOT_V1 = "coapot_v2_acctbase1.rptdesign";
BIRT_COAPOT_WITHLOGO = "coapot_v6.rptdesign";
BIRT_COAPOT_WITHOUTLOGO = "coapot_v6_nologo.rptdesign";
BIRT_LANDSCAPE_V1 = "landscapeCOA_v2.rptdesign";

// 27/05/2011: put back the prev template with little method-refs
BIRT_COAPOT_LOGO_LILREF = "coapotv6_lilmethods.rptdesign";
BIRT_COAPOT_NOLOGO_LILREF = "coapotv6nologo_lilmethods.rptdesign";

BIRT_LANDSCAPE_SAMP_TEST = "landscapeCOA_smp_test_v1.rptdesign";

// 2/6/2010: DO/COA/Invoice TAT report - for billing div only - with prices - lab use another one
BIRT_DOCOAINVTAT_FILENAME = "DOInvoiceCOA_TAT_elabman.rptdesign";

// 9/11/2010: Lab-side folder-release -> COA TAT list
BIRT_LABCOATAT_FILENAME = "COA_TAT_v1.rptdesign";

// 10/6/2010: run list template - final version will be programmed as Excel-import
BIRT_RUNLISTTEMPLATE_FILENAME = "RunList_v1.rptdesign";

// 2/7/2010: draft template + others
BIRT_DRAFT_TEMPLATE = "draft_template_v2.rptdesign";

BIRT_CUSTOMERADDRESS_LABEL = "customeraddress_label.rptdesign";
BIRT_CITILINK_LABEL = "citilink_label_v1.rptdesign";
BIRT_POSLAJU_LABEL = "poslaju_label_v1.rptdesign";

// 20/7/2010: Tests breakdown lab report
BIRT_TESTSBREAKDOWN_FILENAME = "testsBreakdownLabReport_v1.rptdesign";

// 27/7/2010: billing breakdown + tests/samples counter
BIRT_BILLING_BREAKDOWN_FILENAME = "billingbreakdown_v1.rptdesign";

// 26/8/2010: purchase-requisition hardcopy template v1
BIRT_PURCHASE_REQ = "PurchaseReq_v1.rptdesign";

// 8/11/2010: quotation template
BIRT_QUOTETEMPLATE = "quotation_v4.rptdesign";
BIRT_QUOTETRACK = "quote_track_v1.rptdesign";
EXTRACT_MYSOFT_QUOTATIONS = "extractQuotationsByMonth.rptdesign";

// Make the BIRT URL outta ZK Executions.getCurrent() stuff
String birtURL()
{
	callscheme = Executions.getCurrent().getScheme();
	theurl = Executions.getCurrent().getServerName();
	theport = Executions.getCurrent().getServerPort().toString();
	return callscheme + "://" + theurl + ":" + theport + BIRT_WEBVIEWER_SHORT;
	//return "http://localhost:8080";
}

