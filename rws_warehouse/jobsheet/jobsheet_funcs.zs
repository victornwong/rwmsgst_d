// @Title Jobsheet related funcs
// @Author Victor Wong
// @Since 10/09/2014
// @Notes with extra checkings as functions will be used in JobSheetThing.zul, whPlayJobSheet_v1.zul
import org.victor.*;

String[] pl_colws = { "30px", "40px", ""         ,"40px"};
String[] pl_colls = { ""    , "No." , "Pick item","Qty" };

String[] wh_pl_colws = { "30px", "40px", ""         ,"40px", "" };
String[] wh_pl_colls = { ""    , "No." , "Pick item","Qty",  "Asset tags" };

String[] itm_colws = { "50px","",                "60px" ,"60px" };
String[] itm_colls = { "No." ,"Item description","Color","Qty"  };

Object getEquipLookup_rec_byname(String iwhat)
{
	sqlstm = "select * from rw_equiplookup where name='" + iwhat + "'";
	return sqlhand.gpSqlFirstRow(sqlstm);
}

class tbnulldrop implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
	}
}
textboxnulldrop = new tbnulldrop();

void toggButts(boolean iwhat)
{
	Component[] jkl = { pickup_b, pladd_b, plrem_b, plsave_b, plcommit_b };
	for(i=0;i<jkl.length;i++)
	{
		jkl[i].setDisabled(iwhat);
	}
}

void addUpItemQty(HashMap imp, String ikey, int iqt)
{
	if(!imp.containsKey(ikey)) imp.put(ikey,iqt);
	else // add-up qty
	{
		tqt = imp.get(ikey);
		tqt += iqt;
		imp.remove(ikey);
		imp.put(ikey,tqt); // re-put the item with add-up qty
	}
}

// Codes chopped from jobMaker_funcs.showJobItems()
void showJobItems_chopped(Object tjrc)
{
	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	saved_label.setVisible(false);
	grandtotalbox.setVisible(false);
	
	glob_icomponents_counter = 1; // reset for new grid

	if(tjrc.get("items") == null) return; // nothing to show

	ngfun.checkMakeGrid(itm_colws,itm_colls,items_holder,"items_grid","items_rows","background:#97b83a","",false);

	items = sqlhand.clobToString( tjrc.get("items") ).split("::");
	qtys = tjrc.get("qtys").split("::");
	colors = tjrc.get("colors").split("::");
	kk = "font-weight:bold;";

	for(i=0;i<items.length;i++)
	{
		cmid = glob_icomponents_counter.toString();

		irow = gridhand.gridMakeRow("IRW" + cmid ,"","",items_rows);
		ngfun.gpMakeLabel(irow,"",cmid + ".", kk + "font-size:14px");

		soms = "";
		try { soms = items[i]; } catch (Exception e) {}

		lk = ngfun.gpMakeLabel(irow,"",soms,"font-size:9px;font-weight:bold;");
		lk.setMultiline(true);

		soms = "";
		try { soms = colors[i]; } catch (Exception e) {}
		ngfun.gpMakeLabel(irow,"",soms,kk);

		soms = "";
		try { soms = qtys[i]; } catch (Exception e) {}
		ngfun.gpMakeLabel(irow,"",soms,kk);

		glob_icomponents_counter++;
	}
}

void drawPicklist(HashMap iplx)
{
	if(pl_holder.getFellowIfAny("pl_grid") != null) pl_grid.setParent(null); // remove prev
	p1 = pl_colws; p2 = pl_colls;
	if(reqitems_grid_type == 2)
	{
		p1 = wh_pl_colws; p2 = wh_pl_colls;
	}

	ngfun.checkMakeGrid(p1,p2,pl_holder,"pl_grid","pl_rows","background:#97b83a","",true);
	SortedSet keys = new TreeSet(iplx.keySet());
	ln = 1; ks = "font-size:9px;font-weight:bold";
	for (String key : keys)
	{
		String value = iplx.get(key).toString();
		nrw = new org.zkoss.zul.Row();
		nrw.setParent(pl_rows);
		ngfun.gpMakeCheckbox(nrw,"","","");
		ngfun.gpMakeLabel(nrw,"",ln.toString() + ".","");
		ngfun.gpMakeTextbox(nrw,"",key,ks,"99%",textboxnulldrop);
		ngfun.gpMakeTextbox(nrw,"",value,ks,"",textboxnulldrop);
		ln++;
	}
}

void pickJob_reqitems()
{
	if(items_holder.getFellowIfAny("items_grid") == null) return;
	irs = items_rows.getChildren().toArray();
	ks = "";
	plx.clear(); // clear hashmap for new entries
	pl_itemtypes.clear();
	for(i=0; i<irs.length; i++)
	{
		ix = irs[i].getChildren().toArray();
		tm = ix[1].getValue(); // job item
		qt = Integer.parseInt(ix[3].getValue()); // item qty

		lpi = tm.split("\n"); // split items inline \n
		try
		{
			addUpItemQty(plx,lpi[0],qt);
			//ks += "[" + lpi[0] + "] [qty:" + qt.toString() +"]\n";

			eqr = getEquipLookup_rec_byname(lpi[0].trim());
			e_type = e_ramtype = e_hddtype = "";
			if(eqr != null)
			{
				e_type = eqr.get("item");
				e_ramtype = eqr.get("ram_type");
				e_hddtype = eqr.get("hdd_type");
			}

			sp = lpi[1].split("/"); // assuming line 1=item's specs
			for(j=0;j<sp.length;j++) // also assuming item0=RAM, item1=HDD, item2=onwards whatever
			{
				//ks += "[" + sp[j].trim() + "]";
				hitm = sp[j].trim();
				if(j == 0) hitm = e_ramtype + " " + sp[j].trim() + " " + e_type;
				if(j == 1) hitm = e_hddtype + " " + sp[j].trim() + " " + e_type;

				if(hitm.indexOf("DVD") != -1 || hitm.indexOf("CDR") != -1)
					hitm = sp[j].trim() + " " + e_type;

				addUpItemQty(plx,hitm,qt);
			}
			//ks += "\n";
		} catch (Exception e) {}
	}
	drawPicklist(plx);

	// update rw_jobs who pick-up the job
	sqlstm = "update rw_jobs set pickup_date='" + kiboo.todayISODateTimeString() + "', " +
	"pickup_by='" + useraccessobj.username + "' where origid=" + glob_sel_job;
	sqlhand.gpSqlExecuter(sqlstm);
	showJobs(last_joblist_type);
}

void showThings(String iwhat)
{
	jrec = rwsqlfun.getRWJob_rec(iwhat);
	showJobItems_chopped(jrec);

	if(pl_holder.getFellowIfAny("pl_grid") != null) pl_grid.setParent(null); // remove prev
	j_extranotes.setValue("");

	bx = (glob_sel_jstat.equals("")) ? false : ((glob_sel_jstat.equals("DRAFT")) ? false : true); // only DRAFT pick-list can do CRUD
	toggButts(bx);

	jobtitle_lb.setValue("JOB " + jrec.get("origid").toString() + " : " + jrec.get("customer_name"));

	// if got jobsheet no., show 'em
	if(!glob_sel_jobsheet.equals(""))
	{
		r = rwsqlfun.getJobPicklist_rec(glob_sel_jobsheet);
		if(r != null)
		{
			j_extranotes.setValue(kiboo.checkNullString(r.get("extranotes")));
			itms = sqlhand.clobToString(r.get("pl_items")).split("~");
			qtys = sqlhand.clobToString(r.get("pl_qty")).split("~");
			atgs = sqlhand.clobToString(r.get("pl_asset_tags")).split("~");

			p1 = pl_colws; p2 = pl_colls; centerme = true;
			if(reqitems_grid_type == 2)
			{
				p1 = wh_pl_colws; p2 = wh_pl_colls;
				centerme = false;
			}

			ngfun.checkMakeGrid(p1,p2,pl_holder,"pl_grid","pl_rows","background:#97b83a","",centerme);
			ln = 1; ks = "font-size:9px;font-weight:bold";
			for(i=0; i<itms.length; i++)
			{
				nrw = new org.zkoss.zul.Row();
				nrw.setParent(pl_rows);
				ngfun.gpMakeCheckbox(nrw,"","","");
				ngfun.gpMakeLabel(nrw,"",ln.toString() + ".","");

				if(reqitems_grid_type == 1) // prod-side
				{
					ngfun.gpMakeTextbox(nrw,"",itms[i],ks,"99%",textboxnulldrop);
					ngfun.gpMakeTextbox(nrw,"",qtys[i],ks,"",textboxnulldrop);
				}
				else
				if(reqitems_grid_type == 2) // wh-side
				{
					ngfun.gpMakeLabel(nrw,"",itms[i],ks);
					ngfun.gpMakeLabel(nrw,"",qtys[i],ks);

					u = "";
					try { u = atgs[i]; } catch (Exception e) {}
					n = ngfun.gpMakeTextbox(nrw,"",u,ks,"98%",textboxnulldrop); // fill-up asset-tags
					n.setMultiline(true); n.setHeight("50px");
				}

				ln++;
			}
		}
	}
	workarea.setVisible(true);
}

Object[] jobslbhds = 
{
	new listboxHeaderWidthObj("Job",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,"80px"),
	new listboxHeaderWidthObj("J.Type",true,"50px"),
	new listboxHeaderWidthObj("O.Type",true,"50px"), // 5
	new listboxHeaderWidthObj("Prty",true,"50px"),
	new listboxHeaderWidthObj("ETD",true,"70px"),
	new listboxHeaderWidthObj("ETA",true,"70px"),
	new listboxHeaderWidthObj("Pickup",true,"70px"),
	new listboxHeaderWidthObj("P.By",true,"70px"), // 10
	new listboxHeaderWidthObj("J.Sheet",true,"60px"),
	new listboxHeaderWidthObj("J.Stat",true,"60px"), // 12
	new listboxHeaderWidthObj("WH.Tx",true,"60px"),
	new listboxHeaderWidthObj("WH.User",true,"60px"),
};
JOBSHEET_POS = 11;
JOBSHEETSTAT_POS = 12;

class jbslbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_job = lbhand.getListcellItemLabel(isel,0);
		glob_sel_jobsheet = lbhand.getListcellItemLabel(isel,JOBSHEET_POS);
		glob_sel_jstat = lbhand.getListcellItemLabel(isel,JOBSHEETSTAT_POS);
		showThings(glob_sel_job);
	}
}
jobsclkier = new jbslbClick();

void showJobs(int itype)
{
	last_joblist_type = itype;

	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	jid = kiboo.replaceSingleQuotes( jobid_tb.getValue().trim() );

	jpl = "";
	try {	jpl = kiboo.replaceSingleQuotes( picklist_tb.getValue().trim() ); }
	catch (Exception e) {}

	Listbox newlb = lbhand.makeVWListbox_Width(jobs_holder, jobslbhds, "jobs_lb", 3);

	sqlstm = "select top 50 rj.origid, rj.datecreated, rj.customer_name, rj.username, rj.jobtype, rj.priority, " +
	"rj.eta, rj.etd, rj.order_type, rj.pickup_date, rj.pickup_by, " +
	/*
	"(select top 1 origid from rw_jobpicklist where parent_job=rj.origid) as jobsheet, " +
	"(select top 1 pstatus from rw_jobpicklist where parent_job=rj.origid) as jobstat " +
	*/
	"jpl.origid as jobsheet, jpl.pstatus as jobstat, jpl.ackby, jpl.ackdate " +
	"from rw_jobs rj " +
	"left join rw_jobpicklist jpl on jpl.parent_job=rj.origid ";

	switch(itype)
	{
		case 1: // by date and search-text
			sqlstm += "where rj.datecreated between '" + sdate + "' and '" + edate + "' ";
			if(!scht.equals("")) sqlstm += "and rj.customer_name like '%" + scht + "%' ";
			break;

		case 2: // by job-id
			if(jid.equals("")) return;
			try {
				k = Integer.parseInt(jid); // make sure it's a number
				sqlstm += "where rj.origid=" + jid;
			} catch (Exception e) { return; }
			break;

		case 3: // by job pick-list no.
			if(jpl.equals("")) return;
			try {
				k = Integer.parseInt(jpl);
				sqlstm += "where jpl.origid=" + jpl;

			} catch (Exception e) { return; }
			break;
	}

	sqlstm += listjobs_extrasql + " order by rj.eta, rj.origid"; // listjobs_extrasql def in main modu-file

	rcs = sqlhand.gpSqlGetRows(sqlstm);
	if(rcs.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	newlb.addEventListener("onSelect", jobsclkier);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid","datecreated","customer_name","username","jobtype","order_type",
	"priority","etd","eta","pickup_date", "pickup_by", "jobsheet", "jobstat", "ackdate", "ackby" };
	for(d : rcs)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void showCheckstock_win(Div idiv, ArrayList titems)
{
	Object[] cstkhds1 =
	{
		new listboxHeaderWidthObj("No.",true,"40px"),
		new listboxHeaderWidthObj("Items found",true,""),
		//new listboxHeaderWidthObj("Type",true,"40px"),
		//new listboxHeaderWidthObj("Pallet",true,"60px"),
		new listboxHeaderWidthObj("Qty",true,"60px"),
	};
	String[] fl_t1 = { "name", "instk" }; // "item", "pallet", 

	Object[] cstkhds2 =
	{
		new listboxHeaderWidthObj("No.",true,"40px"),
		new listboxHeaderWidthObj("Items found",true,""),
		new listboxHeaderWidthObj("Type",true,"40px"),
		new listboxHeaderWidthObj("Pallet",true,"60px"),
		new listboxHeaderWidthObj("Qty",true,"60px"),
	};
	String[] fl_t2 = { "name", "item", "pallet", "instk" };

	lbhds = cstkhds1; flds = fl_t1;
	if(reqitems_grid_type == 2)
	{
		lbhds = cstkhds2; flds = fl_t2;
	}

	mwin = ngfun.vMakeWindow(idiv,"Check + pick item","0","center","500px","");
	kdiv = new Div();
	kdiv.setParent(mwin);
	Listbox newlb = lbhand.makeVWListbox_Width(kdiv, lbhds, "chkstock_lb", 3);

	csqlstm = "select distinct name,item,pallet,sum(qty) as instk from partsall_0 " +
	"where name not like '(DO NOT%' and name not like '%EIS%' and (";

	ik = titems.toArray();
	wops = "";
	for(i=0;i<ik.length;i++)
	{
		b = ik[i].trim().replace(" ","%");
		wops += "name like '%" + b + "%' or ";
	}
	try { wops = wops.substring(0,wops.length()-4); } catch (Exception e) {}

	csqlstm += wops + ") and pallet not like 'EIS%' and pallet<>'PROD' and pallet<>'WH PALLET' and pallet<>'OUT'" +
	"group by name,item,pallet " +
	"having sum(qty) > 0 " +
	"order by item,pallet,name";

	//alert(csqlstm); return;

	r = sqlhand.rws_gpSqlGetRows(csqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging"); newlb.setRows(20);
	ArrayList kabom = new ArrayList();
	lnc = 1;
	for(d : r)
	{
		kabom.add(lnc.toString() + "." );
		ngfun.popuListitems_Data(kabom,flds,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		lnc++;
	}

	if(checkitems_doubleclicker != null) // set double-cliker if available
		lbhand.setDoubleClick_ListItems(newlb, checkitems_doubleclicker);
}

void js_adminDo(String itype)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = msgtext = "";
	refresh = refresh_joblist = false;
	unm = useraccessobj.username;

	if(!glob_sel_job.equals(""))
	{
		if(itype.equals("admclrpckup_b")) // clear rw_jobs pickup
			sqlstm = "update rw_jobs set pickup_date=null, pickup_by=null where origid=" + glob_sel_job;
	}

	if(!glob_sel_jobsheet.equals(""))
	{
		if(itype.equals("admclrcommit_b")) // clear commit
		{
			sqlstm = "update rw_jobpicklist set pstatus='DRAFT', commitdate=null where origid=" + glob_sel_jobsheet;
			// TODO audit
		}

		if(itype.equals("admclrack_b")) // clear WH ackby/ackdate
			sqlstm = "update rw_jobpicklist set ackby=null,ackdate=null where origid=" + glob_sel_jobsheet;
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showJobs(last_joblist_type);
	}
	if(refresh) drawPicklist(plx);
}
