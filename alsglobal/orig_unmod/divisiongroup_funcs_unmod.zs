import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
3/7/2010: this one to store those funcs and vars for division-group_code and so on

Global vars and defs for ALS Technichem Malaysia
AccDatabase1 = production database
AccDatabase3 = development database

-- to be used in BIRT javascript
	case "EV":
		retval = "Environmental (EV)";
		break;
	case "BS":
		retval = "Banned Substances (BS)";
		break;
	case "IH":
		retval = "Industrial Hygiene (IH)";
		break;
	case "WC":
		retval = "Wearcheck (WC)";
		break;
	case "ASMA":
		retval = "ASMA";
		break;
	case "OF":
		retval = "Food & Pharma (OF)";
		break;
	case "MD":
		retval = "Medical Devices (MD)";
		break;	


*/

public class codeToLongNameObj
{
	String thecode;
	String thelongname;
	
	public codeToLongNameObj(String ithecode, String ithe_longname)
	{
		thecode = ithecode;
		thelongname = ithe_longname;
	}
}

Object[] als_divisions = {
	new codeToLongNameObj("0","Unsorted"),
	new codeToLongNameObj("EV","Environmental (EV)"),
	new codeToLongNameObj("BS","Banned Substances (BS)"),
	new codeToLongNameObj("IH","Industrial Hygiene (IH)"),
	new codeToLongNameObj("WC","Wearcheck (WC)"),
	new codeToLongNameObj("ASMA","ASMA"),
	new codeToLongNameObj("OF","Food & Pharma (OF)"),
	new codeToLongNameObj("MD","Medical Devices (MD)")
};

// Convert codes to its long name - uses codeToLongNameObj
String convertCodeToLongName(Object iobjs, String iwhich)
{
	retval = "Unknown";
	
	for(i=0; i<iobjs.length; i++)
	{
		if(iobjs[i].thecode.equals(iwhich))
		{
			retval = iobjs[i].thelongname;
			break;
		}
	}
	return retval;
}

// Same as convertCodeToLongName() but the reversal
String convertLongNameToCode(Object iobjs, String iwhich)
{
	retval = "Unknown";
	
	for(i=0; i<iobjs.length; i++)
	{
		if(iobjs[i].thelongname.equals(iwhich))
		{
			retval = iobjs[i].thecode;
			break;
		}
	}
	return retval;
}
