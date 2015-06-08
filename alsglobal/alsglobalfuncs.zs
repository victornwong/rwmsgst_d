import java.util.*;
import java.text.*;

import java.sql.Connection;
import java.sql.DriverManager;
import javax.sql.DataSource;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;

/*
Purpose: Global general purpose functions we put them here
Written by : Victor Wong
Date : 11/08/2009
Notes:
*/

BLANK_REPLACER = "------";

// Check if file exist - ZK specific, uses session.getWebApp().getRealPath(thefilename) to get real-path in tombat
boolean realPath_FileExist(String thefn)
{
	File f = new File(session.getWebApp().getRealPath(thefn));
	return f.exists();
}

// Will format date string properly for MySQL
// Parameter: idatebox = zkoss datebox of which will construct the date YYYY-MM-DD
String getDateFromDatebox(Datebox idatebox)
{
	thed = idatebox.getValue();
	tcalendar = Calendar.getInstance();
	tcalendar.setTime(thed);
	thedd = tcalendar;

	datestr = "" + thedd.get(Calendar.YEAR) + "-" +
		(thedd.get(Calendar.MONTH)+1) + "-" +
		thedd.get(Calendar.DAY_OF_MONTH);

	return datestr;
}

void setTodayDatebox(Datebox datebox1)
{
	Calendar kkk = Calendar.getInstance();
	datebox1.setValue(kkk.getTime());
}

// Set Datebox value from date string passed "2010-01-01"
void setDateBox_FromString(Datebox iwhich, String idate)
{
	if(idate.equals("")) return;

	yyear = Integer.parseInt(idate.substring(0,4));
	ymonth = Integer.parseInt(idate.substring(5,7)) - 1;
	ydate = Integer.parseInt(idate.substring(8,10));
	
	Calendar tcalendar = Calendar.getInstance();
	tcalendar.set(yyear,ymonth,ydate);

	iwhich.setValue(tcalendar.getTime());
}

// Set Calendar from string : "2010-01-01" or "2010-1-1" .. setDateBox_FromString() will fail if string is different - fixed substring
Calendar stringToDate(String iwhat)
{
	Calendar retcal = Calendar.getInstance();
	try
	{
		kkk = iwhat.split("-");
		tyear = Integer.parseInt(kkk[0]);
		tmonth = Integer.parseInt(kkk[1]) - 1;
		tdate = Integer.parseInt(kkk[2]);
		retcal.set(tyear,tmonth,tdate);
	}
	catch (ParseException e) { }
	finally
	{
		return retcal;
	}
}

String mapWeekDayString(int iwhich)
{
	String[] myday = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
	return myday[iwhich-1];
}

// Add number of days to idateb and store new date in itoupdate
void addDaysToDate(Datebox idateb, Datebox itoupdate, int howmanydays)
{
	// get date value
	dcreat = idateb.getValue();

	Calendar iduedate = Calendar.getInstance();
	iduedate.setTime(dcreat);
	iduedate.add(iduedate.DAY_OF_MONTH, howmanydays);

	itoupdate.setValue(iduedate.getTime());

	/*
	datestr = "" + iduedate.get(Calendar.YEAR) + "-" +
		(iduedate.get(Calendar.MONTH)+1) + "-" +
		iduedate.get(Calendar.DAY_OF_MONTH);

	return datestr;
	*/

}

// Weekend checks.. to make sure due-date ain't weekends. nobody want to work!!!
// Will update ithedate
void weekEndCheck(Datebox ithedate)
{
	Calendar iduedatecheck = Calendar.getInstance();
	iduedatecheck.setTime(ithedate.getValue());
		
	iwday = iduedatecheck.get(iduedatecheck.DAY_OF_WEEK);
	addupweekends = 0;
	if(iwday == iduedatecheck.SUNDAY) addupweekends = 1;
	if(iwday == iduedatecheck.SATURDAY) addupweekends = 2;
		
	addDaysToDate(ithedate,ithedate,addupweekends);
}

// Returns the date string "yyyy-mm-dd" to be used in SQL or display
// itodaydate = today's date - set always at top - eg
//
// TimeZone zone=TimeZone.getTimeZone("GMT+08");
// Date currentDate=new Date();
// DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
// String DATE_FORMAT = "yyyy-MM-dd";
// SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);
// Calendar todayDate = Calendar.getInstance();
// todayDate.setTime(currentDate);
//
// dateformat = SimpleDateFormat as defined above too
// numdays = number of days to add(4 = add) or minus (-4 = minus) from today's date.
String getDateString(Calendar itodaydate, SimpleDateFormat isdf, int numdays)
{
	Calendar temptodate = itodaydate.clone();

	if(numdays != 0)
		temptodate.add(Calendar.DATE,numdays);
		
    retval = isdf.format(temptodate.getTime());
	return retval;
}

// Convert a string array into comma-separated string
String convertStringArrayToString(String[] iwhat)
{
	retval = "";
	for(i=0; i<iwhat.length; i++)
	{
		retval += iwhat[i] + ",";
	}
	
	return retval.substring(0,retval.length()-1);
}

// To be used to replace ' to ` during SQL operation
String replaceSingleQuotes(String thestring)
{
	return thestring.replace("'","`");
}

// To strip first 6 chars off any rec number .. eg DSPSCHxxx . we just need the rec number only.
String strip_PrefixID(String iwhat)
{
	retval = "";
	
	if(!iwhat.equals(""))
		retval = iwhat.substring(6);
	
	return retval;
}

// Convert integer to string and 0-pad. String.format() just won't work here, not sure why, otherwise the codes won't be this kludgy.
// up to 6 digits 000001 (updated 12/4/2010)
String padZeros5(int iwhich)
{
	retval = iwhich.toString();
	padstr = "";

	if(iwhich < 10) padstr = "0000";
	if(iwhich > 9) padstr = "000";
	if(iwhich > 99) padstr = "00";
	if(iwhich > 999) padstr = "0";
	if(iwhich > 9999) padstr = "";
		
	return padstr + retval;
}

String padZeros3(int iwhich)
{
	retval = iwhich.toString();
	padstr = "";

	if(iwhich < 10) padstr = "00";
	if(iwhich > 9) padstr = "0";
		
	return padstr + retval;
}

// Check if ioo = "" , return "--UnD--" , else return ioo . Simple func to streamline codes.
// useful when populating listbox from database and column is ""
// eg. strarray[1] = checkEmptyString(eqsatu.get("EQ_name"));
String checkEmptyString(String ioo)
{
	return (ioo.equals("")) ? BLANK_REPLACER : ioo;
}

String checkNullString(String ioo)
{
	if(ioo == null) return "";
	else return ioo;
}

String checkNullString_RetWat(String ioo, String retval)
{
	if(ioo == null) return retval;
	else return ioo;
}

// Return the folder prefix - all def in alsglobaldefs.zs - JOBFOLDERS_PREFIX, JB_JOBFOLDERS_PREFIX, KK_JOBFOLDERS_PREFIX
String folderPrefixByBranch(String ibranch)
{
	folderprefix = JOBFOLDERS_PREFIX;
	
	if(ibranch.equals("JB"))
		folderprefix = JB_JOBFOLDERS_PREFIX;

	if(ibranch.equals("KK"))
		folderprefix = KK_JOBFOLDERS_PREFIX;
		
	return folderprefix;

}

// Convert ArrayList to String[]
String[] convertArrayListToStringArray(ArrayList iwhat)
{
	arsz = iwhat.size();
	String[] retarray = new String[arsz];
	
	wopa = iwhat.toArray();
	
	for(i=0; i<arsz; i++)
	{
		retarray[i] = wopa[i];
	}
	
	return retarray;
}

// 22/03/2011: check null date(from sql) return some string or the chopped date string
String checkNullDate(Object thedate, String nullstring)
{
	retval = nullstring;
	if(thedate != null) retval = thedate.toString().substring(0,10);
	return retval;
}


