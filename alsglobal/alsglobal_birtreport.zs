/*
BIRT Report Templates and funcs
Specific for : ALS Technichem(M) Sdn Bhd

Written by	: Victor Wong

Revision notes:

03/03/2010: first creation, move all scattered birt reports filename here
16/05/2011: reorganize and put BIRT templates into an array.. use common report-browser window with dynamic URL
09/04/2012: added birtURL_external() to return EXTERNAL_BIRTVIEWER --

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

// BIRT webviewer location
BIRT_WEBVIEWER = "http://172.18.107.7:18080/BIRT/frameset?__report=";
BIRT_WEBVIEWER_SHORT = "/BIRT/frameset?__report=";

EXTERNAL_BIRTVIEWER = "http://172.18.107.15:8080/BIRT/frameset?__report=";

FOLDERS_DAILY_REPORT_FILENAME = "DailyFolders_List_v1.rptdesign";

// params: jobfolder_id = folder id origid only
BIRT_SRA_FILENAME = "SRA_v2.rptdesign";

// params: FolderNo = folder no 
//BIRT_SAMPLELABELS_FILENAME = "sampleLabel_v1_acctbase1.rptdesign";
BIRT_SAMPLELABELS_FILENAME = "sampleLabel_v2.rptdesign";
BIRT_SAMPLELABELS_FILENAME_V3 = "sampleLabel_v3_wk1.rptdesign";

// Due folders report
BIRT_DUEFOLDERREPORT_FILENAME = "duedate_fld_acctbase1.rptdesign";

// single sample single page COA
BIRT_COAPOT_V1 = "coapot_v2_acctbase1.rptdesign";
BIRT_COAPOT_WITHLOGO = "coapot_v6.rptdesign";
BIRT_COAPOT_WITHOUTLOGO = "coapot_v6_nologo.rptdesign";
BIRT_LANDSCAPE_V1 = "landscapeCOA_v2.rptdesign";

COAPOT_WITHLOGO_WITHSPECS = "coapot_v6_withspecs.rptdesign";
COAPOT_WITHOUTLOGO_WITHSPECS = "coapot_v6_nologo_withspecs.rptdesign";

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
BIRT_QUOTETEMPLATE_VERSION = "quotation_v4_version.rptdesign";

// 10/01/2012: new COA portrait template
COA_PORTRAIT_DISCLAIMERS = "alsReports/coapot_v7_final_disclaimers_nosign.rptdesign";
COA_PORTRAIT_NODISCLAIMERS = "alsReports/coapot_v7_final_nodisclaimers_nosign.rptdesign";
COA_PORTRAIT_EXISTINGPAPER = "alsReports/coapot_v7_final_nodisclaimers_nosign_noals.rptdesign";
COA_PORTRAIT_EXISTINGPAPER_CONTI = "alsReports/coapot_v7_final_nodisclaimers_nosign_noals_cont.rptdesign";

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

