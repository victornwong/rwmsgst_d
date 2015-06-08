import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import java.security.*;
import org.victor.*;

/*
Purpose: Global security / ACL functions
Written by : Victor Wong
Date : 11/01/2010

Design notes:

1. users are assigned main access level
2. users are included into groups
3. users will have individual group access level

to grant access, users must have the same access level or higher and must be in the group as specified by certain functions
group will have it's own access level for each user. if user's group access level is higher than the main access level, access granted

*NOTES*

07/10/2011: added stockcat and groupcode to userAccessObj - to be used to release results and other stuff

*/

//sqlhand = new SqlFuncs();

// Table names
TABLE_PORTALUSER = "PortalUser";
TABLE_PORTALUSERGROUP = "portalUsergroups";
TABLE_PORTALGROUPACCESS = "portalGroupAccess";

String[] dd_accesslevel = {"1","2","3","4","5","6","7","8","God-like"};
String[] dd_branches = {"SA","JB","KK","ALL" };

// usergroups access levels
SAMPREG_ACCESSLEVEL = 2;
SAMPREG_USERGROUP = "('OPER','SAMPREG','BILLING')";

RECEPTION_ACCESSLEVEL = 2;
RECEPTION_USERGROUP = "('OPER','FRONTDESK','BILLING')";

LAB_ACCESSLEVEL = 2;
LAB_USERGROUP = "('LAB','EV','FOOD','MB','METAL','ORGANIC','QC','QHSE')";

CREDIT_CONTROL_ACCESSLEVEL = 2;
CREDIT_CONTROL_USERGROUP = "('ACCTS','BILLING','CREDITC')";

ADMIN_BIRT_REPORTS_ACCESSLEVEL = 2;
ADMIN_BIRT_REPORTS_USERGROUP = "('ADMINOFFICE','ACCTS','BILLING','CREDITC')";

CREDIT_CONTROL_ACCESSLEVEL = 2;
CREDIT_CONTROL_USERGROUP = "('ADMINOFFICE','CREDITC')";

SALES_MARKETING_ACCESSLEVEL = 2;
SALES_MARKETING_USERGROUP = "('ADMINOFFICE','SALES')";

QCOFFICER_ACCESSLEVEL = 2;
QCOFFICER_USERGROUP = "('OPER','QC')";

REPORTGEN_ACCESSLEVEL = 2;
REPORTGEN_USERGROUP = "('OPER','REPORTING')";

STATICDATA_SETUP_ACCESSLEVEL = 3;
STATICDATA_SETUP_USERGROUP = "('OPER','DATASETUP')";

PURCHASING_ACCESSLEVEL = 2;
PURCHASING_USERGROUP = "('OPER','PURCHASES')";

