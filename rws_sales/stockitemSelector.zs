// Stock-items selector
import org.victor.*;

SELECT_DESKTOP = 1;
SELECT_NOTEBOOK = 2;
SELECT_MONITOR = 3;
SELECT_PARTS = 4;

Object[] fstkitmhjds =
{
	new listboxHeaderWidthObj("Stock name",true,""),
	new listboxHeaderWidthObj("QtyLeft",true,"70px"),
};

// itype: 1=desktop, 2=notebook, 3=monitor
void showStockSelection(int itype, String iwhat)
{
	if(iwhat.equals("")) return;
	iwhat = kiboo.replaceSingleQuotes(iwhat);
	typ = "'DT'";
	switch(itype)
	{
		case 2:
			typ = "'NB'";
			break;
		case 3:
			typ = "'MT'";
			break;
		case 4:
			typ = "'SPT','PT','SW'";
			break;
	}

	sqlstm = "select distinct name, sum(qty) as qtyleft from partsall_0 where item in (" + typ + ") and name like '%" + iwhat + "%' group by name,qty";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) { return; }

	mw = vMakeWindow(winsholder, "Stock-items : (" + iwhat + ")", "3px", "center", "450px","");
	dv = new Div();
	dv.setParent(mw);
	Listbox newlb = lbhand.makeVWListbox_Width(dv, fstkitmhjds, "findstkitems_lb", 20);
	ArrayList kabom = new ArrayList();
	String[] fl = { "name", "qtyleft" };
	for(d : r)
	{
		popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"mydrop","");
		kabom.clear();
	}
}
