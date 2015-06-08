import org.victor.*;
// Funcs for salesPipeFun

// Check if QT already exist in pipes
boolean qtExistsInPipes(String iqt)
{
	retv = false;
	for(p=0; p<glob_MyPipes.length; p++)
	{
		kp = glob_MyPipes[p].getChildren().toArray();
		if(kp.length > 0)
		{
			for(i=0; i<kp.length; i++)
			{
				kr = kp[i].getChildren().toArray();
				qtn = kr[0].getValue();
				if(iqt.equals(qtn))
				{
					retv = true;
					break;
				}
			}
		}
	}
	return retv;
}

// Get all existing QTs in the pipes
String existQTs()
{
	retv = "";
	for(p=0; p<glob_MyPipes.length; p++)
	{
		kp = glob_MyPipes[p].getChildren().toArray();
		if(kp.length > 0)
		{
			for(i=0; i<kp.length; i++)
			{
				kr = kp[i].getChildren().toArray();
				qtn = kr[0].getValue();
				retv += qtn + ",";
			}
		}
	}

	try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
	return retv;
}

// Construct sql-insert from grid.rows - to save quotation-no .. can be modded for others
String insertPipeThings(int ipipe, org.zkoss.zul.Rows iwhich )
{
	sqlstm = "";
	rw = iwhich.getChildren().toArray();
	if(rw.length > 0)
	{
		for(i=0; i<rw.length; i++)
		{
			if(rw[i] instanceof org.zkoss.zul.Row)
			{
				ris = rw[i].getChildren().toArray();
				sqlstm += "insert into rw_qt_pipeline (username,qt_no,pipe_pos) values " +
				"('" + glob_pipe_user + "'," + ris[0].getValue() + "," + ipipe.toString() + ");";
			}
		}
	}
	return sqlstm;
}

void clearPipes()
{
	for(p=0; p<glob_MyPipes.length; p++)
	{
		kp = glob_MyPipes[p].getChildren().toArray();
		if(kp.length > 0)
		{
			for(i=0; i<kp.length; i++)
			{
				kp[i].setParent(null);
			}
		}
	}
}

void populatePipes()
{
	// clear all pipes before loading new ones..
	clearPipes();
	userpipe_lbl.setValue(glob_pipe_user + "'s Pipeline");
	last_sel_qtrow = null; // reset once reload pipes
	glob_sel_quote = "";

	sqlstm = "select qtpip.qt_no,qt.customer_name,qtpip.pipe_pos,qt.username," +
	"(select count(itk.origid) from rw_int_tasks itk where " + 
	"itk.linking_code = 'RWQT' + cast(qtpip.qt_no as varchar(10)) ) as taskcount " +
	"from rw_quotations qt " +
	"left join rw_qt_pipeline qtpip on qtpip.qt_no = qt.origid " +
	"where qt.customer_name is not null and qtpip.username='" + glob_pipe_user + "';";
	//debugbox.setValue(sqlstm);
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	for( d : recs)
	{
		ppos = d.get("pipe_pos") - 1;
		krws = glob_MyPipes[ ppos ];
		if(krws != null)
		{
			nrw = new org.zkoss.zul.Row();
			nrw.setParent(krws);
			nrw.setDraggable("pipefun");
			//nrw.addEventListener("onDoubleClick", pipeQT_doubleClick);
			nrw.setContext(qtContextMenu);

			styl = "font-size:9px";
			if(ppos == 4) // HARDCODED: LOST bin
				styl += ";text-decoration:line-through";

			gpMakeLabel(nrw,"",d.get("qt_no").toString(),"font-size:9px");
			gpMakeLabel(nrw,"",d.get("customer_name") + " [" + d.get("username") + "] / " + d.get("taskcount").toString() , styl);
		}
	}
	
	qtContextMenu.addEventListener("onOpen",QTcontextonOpen);
}

// Save moved-around things in pipefun
void savePipeFun()
{
	// remove all belongs to user before saving new pipes
	sqlstm = "delete from rw_qt_pipeline where username='" + glob_pipe_user + "'";
	sqlhand.gpSqlExecuter(sqlstm);
	sqlstm = insertPipeThings(1,d_rows1);
	sqlstm += insertPipeThings(2,d_rows2);
	sqlstm += insertPipeThings(3,d_rows3);
	sqlstm += insertPipeThings(4,d_rows4);
	sqlstm += insertPipeThings(5,d_lostbin);
	sqlhand.gpSqlExecuter(sqlstm);
}

// When user close panel -- auto save the pipes
void closePanelSave()
{
	savePipeFun();
}

// Simple hack to move grid.row around
void pipeDrop(DropEvent event, Object droped)
{
	Object dragged = event.getDragged();
	Object findrws = findgrd = null;

	if(droped instanceof Div)
	{
		cd1 = droped.getChildren().toArray();
		for(i=0; i<cd1.length; i++)
		{
			if(cd1[i] instanceof Grid)
			{
				findgrd = cd1[i];
				break;
			}
		}
		if(findgrd != null)
		{
			cd2 = findgrd.getChildren().toArray();
			for(i=0; i<cd2.length; i++)
			{
				if(cd2[i] instanceof Rows)
				{
					findrws = cd2[i];
					break;
				}
			}
		}
	}
	//alert(dragged + " :: " + droped + " :: " + findgrd + " :: " + findrws);
	if(findrws != null)
	{
		kx = dragged.getChildren().toArray();
		if(findrws.getId().equals("d_lostbin")) // strike-out quotation if dragged to lost-bin
			kx[1].setStyle( kx[1].getStyle() + ";text-decoration:line-through");
		else
			kx[1].setStyle( "font-size:9px" );

		dragged.setParent(findrws); // actually moving
	}
}

class pipeqtdclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		showQTworkout(isel);
	}
}

pipeQT_doubleClick = new pipeqtdclk();

// Populate quotations - can be used for others, set iholder and lbid accordingly
void populateQuotationsBox(Div iholder, String lbid, String iexistqt)
{
Object[] qtlbhds =
{
	new listboxHeaderWidthObj("QT#",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,"70px"),
};
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, qtlbhds, lbid, 22);
	sqlstm = "select origid,datecreated,username,customer_name from rw_quotations ";
	if(!iexistqt.equals("")) sqlstm += "where origid not in (" + iexistqt + ")";

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setCheckmark(true);
	newlb.setMultiple(true);
	//newlb.addEventListener("onSelect", new lclbClick());
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "datecreated", "customer_name", "username" };
	for(d : recs)
	{
		popuListitems_Data(kabom,fl,d);
		/*
		kabom.add(d.get("origid").toString());
		kabom.add( kiboo.checkNullDate(d.get("datecreated"),"") );
		kabom.add( kiboo.checkNullString(d.get("customer_name")) );
		kabom.add( kiboo.checkNullString(d.get("username")) );
		*/
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

// populate and show QT workout popup
void showQTworkout(Object isqt)
{
	if(last_sel_qtrow != null) last_sel_qtrow.setStyle("");
	isqt.setStyle("background:#ad7fa8");
	last_sel_qtrow = isqt;

	ki = isqt.getChildren().toArray();
	glob_sel_quote = ki[0].getValue();
	showQuoteMeta(glob_sel_quote,1);
	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	qtwork_pop.open(isqt);
}

Object contextSelectedRow = null;
class ctxopen implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		contextSelectedRow = isel; // save Row which fires the context-menu
	}
}
QTcontextonOpen = new ctxopen();

void qtContextDo(Object iwhat)
{
	itype = iwhat.getId();

	if(itype.equals("viewqt_m")) showQTworkout(contextSelectedRow);

	if(itype.equals("itask_m")) // internal tasks management
	{
		ki = contextSelectedRow.getChildren().toArray();
		glob_sel_quote = ki[0].getValue();
		inttask_lbl.setValue("Internal tasks for quotation : " + glob_sel_quote);
		showInternalTasksList(1,useraccessobj.username, JN_linkcode(), "", tasksfromyou_holder, "asstasks_lb");
		internaltasks_man_pop.open(contextSelectedRow);
	}
	
	if(itype.equals("otherthing_m")) guihand.showMessageBox("Don't know what else to put.. later will think");
}
