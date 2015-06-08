import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Client Access Point
User access object and such
*/

MAINPROCPATH = "mainproc";

public class userAccessObj
{
    public String companycode;
	public String fullname;
    public String telno;
    public String maintree;
	public boolean adminflag;
	
	public clearAll()
	{
		username = "";
		hospitalid = "";
		hospitalname = "";
		accesslevel = 0;
	}
}

// get user access obj, hardcoded "uao" as attribute name
Object getUserAccessObject()
{
	return(Executions.getCurrent().getAttribute("uao"));
}

void setUserAccessObj(Include wInc, userAccessObj tuaobj)
{
	wInc.setDynamicProperty("uao",tuaobj);
}

