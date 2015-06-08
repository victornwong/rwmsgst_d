import org.victor.*;
// RW assignment-drawdown funcs -- used in rwBilling.zul

RWNOA_PREFIX = "RWNOA";

glob_sel_asgnlc = ""; // selected assignment record
assignment_lb_selitem = null; // lb selected item - other funcs need this

void clearAssignmentForm()
{
	Object[] jkl = { i_assigned, i_charge_out_date, i_charge_out_period, i_charge_out, i_fina_ref, i_fina_amount,
		i_co_assigned_name, i_co_do_ref, i_co_master_lc, i_noa_no, i_co_monthly_rental, i_co_instalment_count,
		i_co_due_date, i_co_deposit, i_co_recv_ex_deposit, i_co_recv_in_deposit, i_co_pv_drawdown, i_co_pv_drawdown_ex_deposit,
		i_co_assigned_interest, i_co_inv_to_financer };

		ngfun.clearUI_Field(jkl);
}

String getTopGroupi()
{
	sqlstm = "select case when max(groupi) is null then 1 else max(groupi) + 1 end as maxgpi from rw_assignment;";
	r = sqlhand.gpSqlFirstRow(sqlstm);
	return (r == null) ? "1" : r.get("maxgpi").toString();
}

// ilc=rw_lc_records.lc_id, iflag=asgn or not
void set_LCEquips_AssignFlag(String ilc, String iflag)
{
	sqlstm = "update rw_lc_equips set assigned=" + iflag +
	" where lc_parent=(select origid from rw_lc_records where lc_id='" + ilc + "')";

	sqlhand.gpSqlExecuter(sqlstm);
	guihand.showMessageBox("LC assets assignment-flag set " + iflag);
}

// return entries in rw_assignment not assigned
String getAssignment_LC_notassigned()
{
	if(assignments_lb.getSelectedCount() == 0) return null;
	kr = assignments_lb.getSelectedItems().toArray();
	aa = "";
	for(i=0; i<kr.length; i++)
	{
		nn = lbhand.getListcellItemLabel(kr[i],ASGNFLAG_IDX);
		if(nn.equals("N") || nn.equals(""))
		{
			aa += lbhand.getListcellItemLabel(kr[i],ASGNID_IDX) + ",";
		}
	}
	try { aa = aa.substring(0,aa.length()-1); } catch (Exception e) {}
	return aa;
}

void assignmentFunc(String itype)
{
	asgn_adminpop.close();
	todaydate =  kiboo.todayISODateTimeString();
	refresh = false;
	msgtext = sqlstm = "";

	if(itype.equals("asg_remove_b"))
	{
		if(assignments_lb.getSelectedCount() == 0) return;

		if(Messagebox.show("Remove unassigned LC(s) ONLY from juggler..", "Are you sure?",
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

		kr = getAssignment_LC_notassigned();
		if(kr == null || kr.equals("")) return;
		sqlstm = "delete from rw_assignment where origid in (" + kr + ");";
	}

	if(itype.equals("asg_toggleasgna_b")) // admin: toggle assignment flag in rw_lc_records
	{
		if(assignments_lb.getSelectedCount() == 0) return;
		kr = assignments_lb.getSelectedItems().toArray();
		aa = "";
		for(i=0; i<kr.length; i++)
		{
			d = lbhand.getListcellItemLabel(kr[i],LCID_IDX);
			aa += "'" + d + "',";
		}
		try { aa = aa.substring(0,aa.length()-1); } catch (Exception e) {}
		sqlstm = "update rw_lc_records set assigned=1-assigned where lc_id in (" + aa + ");";
	}

	if( itype.equals("asg_setasgnasset_b") || itype.equals("asg_unsetasgnasset_b") ) // set/unset rw_lc_equips.assigned
	{
		if(assignments_lb.getSelectedCount() == 0) return;
		kr = assignments_lb.getSelectedItems().toArray();
		flg = (itype.equals("asg_setasgnasset_b")) ? "1" : "0";
		for(i=0;i<kr.length;i++)
		{
			rwno = lbhand.getListcellItemLabel(kr[i],LCID_IDX);
			set_LCEquips_AssignFlag(rwno,flg);
		}
	}

	if(itype.equals("asg_clrgroupi_b")) // admin: clr groupi
	{
		kr = getAssignment_LC_notassigned();
		if(kr == null) return;
		sqlstm = "update rw_assignment set groupi=null where origid in (" + kr + ");";
	}

	if(itype.equals("asg_updatear_b")) // mass-update postoffice AR no.
	{
		arc = kiboo.replaceSingleQuotes( a_artext.getValue().trim() );
		if(arc.equals("")) return;
		if(assignments_lb.getSelectedCount() == 0) return;
		kr = assignments_lb.getSelectedItems().toArray();
		aa = "";
		for(i=0;i<kr.length;i++)
		{
			d = lbhand.getListcellItemLabel(kr[i],ASGNID_IDX);
			aa += d + ",";
		}
		try { aa = aa.substring(0,aa.length()-1); } catch (Exception e) {}
		sqlstm = "update rw_assignment set ar_reg='" + arc + "' where origid in (" + aa + ");";
	}

	if(itype.equals("asg_groupi_b"))
	{
		kr = getAssignment_LC_notassigned();
		if(kr == null) return;
		mgx = getTopGroupi();
		sqlstm = "update rw_assignment set groupi=" + mgx + " where origid in (" + kr + ");";
	}

	if(itype.equals("asg_noa_b"))
	{
		if(assignments_lb.getSelectedCount() == 0) return;
		kr = assignments_lb.getSelectedItems().toArray();
		aa = "";
		for(i=0; i<kr.length; i++)
		{
			aix = lbhand.getListcellItemLabel(kr[i],ASGNID_IDX);
			cnm = lbhand.getListcellItemLabel(kr[i],CUSTNAME_IDX);
			updateAssignment_customerDetails(aix,cnm);
		}
	}

	if(itype.equals("asg_clrnoadate_b")) // admin: clear NOA date
	{

	}

	if(itype.equals("updasgndata_b")) // update assignment metadata - from assignmentMeta_pop
	{
		if(glob_sel_asgnlc.equals("")) return;
		Object[] jkl = { i_charge_out_date, i_fina_amount, i_charge_out, i_fina_ref, i_assigned };
		dt = ngfun.getString_fromUI(jkl);
		fd = asgnformthing.freezeFormValues();

		try { fv = Float.parseFloat(dt[1]); } catch (Exception e) { dt[1] = "0"; } // make sure draw_amount is valid

		sqlstm = "update rw_assignment set draw_date='" + dt[0] + "', draw_amount=" + dt[1] + ", " +
		"financer='" + dt[2] + "', financer_ref='" + dt[3] + "', form_data='" + fd + "' where origid=" + glob_sel_asgnlc + ";";

		af = (dt[4].equals("YES")) ? "1" : "0";
		rwno = lbhand.getListcellItemLabel(assignment_lb_selitem,LCID_IDX);
		sqlstm += "update rw_lc_records set assigned=" + af + " where lc_id='" + rwno + "';";

		if(af.equals("1")) set_LCEquips_AssignFlag(rwno,"1");

		msgtext = "Assignment metadata saved..";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssignmentJuggler();
	}
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

// update rw_assignment.mra_no, mra_date and customer address as stored in FC6
void updateAssignment_customerDetails(String iaix, String icnm)
{
	sqlstm = "select top 1 cust.name, custd.address1yh, custd.address2yh, custd.address3yh, custd.address4yh," +
	"custd.manumberyh, cust.code2 from mr000 cust " +
	"left join u0000 custd on custd.extraid = cust.masterid " +
	"where cust.name='" + icnm + "';";

	r = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(r == null)
	{
		guihand.showMessageBox("ERR: cannot access FC6 customer details..");
		return;
	}

	adr = kiboo.checkNullString(r.get("address1yh")) + "\n" +
	kiboo.checkNullString(r.get("address2yh")) + "\n" +
	kiboo.checkNullString(r.get("address3yh")) + "\n" +
	kiboo.checkNullString(r.get("address4yh"));

	cmpn = kiboo.checkNullString( r.get("code2") );
	// take out ( )
	//cmpn = cmpn.replaceAll('(','').replaceAll(')','');

	ma = kiboo.checkNullString(r.get("manumberyh"));
	ma_n = ma_d = "";
	if(!ma.equals(""))
	{
		kk = ma.split(" "); // PROBLEM!! not standardized data entry
		try { ma_n = kk[0]; } catch (Exception e) {}
		try { ma_d = kk[1]; } catch (Exception e) {}
	}
	sqlstm = "update rw_assignment set address='" + adr + "', mra_no='" + ma_n + "'," +
	"mra_date='" + ma_d + "', company_no='" + cmpn + "' where origid=" + iaix;
	sqlhand.gpSqlExecuter(sqlstm);
}

void assignmentCreate()
{
	if(mainlc_tree.getSelectedCount() == 0) return;
	ki = mainlc_tree.getSelectedItems().toArray();
	sqlstm = "";
	for(i=0; i<ki.length; i++)
	{
		mi = ki[i].getChildren().toArray();
		for(j=0; j<mi.length; j++)
		{
			if(mi[j] instanceof Treerow)
			{
				ba = mi[j].getChildren().toArray();
				atg = ba[0].getLabel();
				cnm = ba[1].getLabel();
				sqlstm += "If Not Exists(select origid from rw_assignment where lc_id='" + atg + "') Begin " + 
				"insert into rw_assignment (lc_id,datecreated,customer_name) values ('" + atg + "','" + kiboo.todayISODateTimeString() +"','" + cnm + "') End;";
			}
		}
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		mainlc_tree.clearSelection();
		showAssignmentJuggler();
		guihand.showMessageBox("LC/RWs inserted into assignment juggler..");
	}
}

class asgndoublecliker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		clearAssignmentForm();
		assignment_lb_selitem = event.getTarget();
		glob_sel_asgnlc = lbhand.getListcellItemLabel(assignment_lb_selitem,0);

		r = getAssignment_rec(glob_sel_asgnlc); // rwsqlfuncs.zs
		if(r == null) return;

		asgnformthing.populateFormValues( sqlhand.clobToString(r.get("form_data")) );
		assignmentMeta_pop.open(assignment_lb_selitem);
	}
}
asgnboudbleciker = new asgndoublecliker();

class asgnclike implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		assignment_lb_selitem = event.getReference();
		glob_sel_asgnlc = lbhand.getListcellItemLabel(assignment_lb_selitem,0);
		} catch (Exception e) {}
	}
}
asgnCliker = new asgnclike();

Object[] rwassgnhds =
{
	new listboxHeaderWidthObj("REC",true,"60px"),
	new listboxHeaderWidthObj("GRP",true,"60px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("LC/RW",true,"70px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Amount",true,"80px"), // 5
	new listboxHeaderWidthObj("NOA",true,"70px"),
	new listboxHeaderWidthObj("C.Let",true,"70px"),
	new listboxHeaderWidthObj("DrawD",true,"70px"),
	new listboxHeaderWidthObj("DrawA",true,"80px"),
	new listboxHeaderWidthObj("F/Ref",true,"100px"), // 10
	new listboxHeaderWidthObj("ASGN",true,"50px"), // 11
};
ASGNID_IDX = 0;
GRP_IDX = 1;
LCID_IDX = 3;
CUSTNAME_IDX = 4;
ASGNFLAG_IDX = 11;

void showAssignmentJuggler()
{
	Listbox newlb = lbhand.makeVWListbox_Width(asgn_holder, rwassgnhds, "assignments_lb", 5);
	sqlstm = "select rwa.origid, rwa.datecreated, rwa.lc_id, rwa.customer_name, rwa.groupi, " +
	"rwa.noa_submit, rwa.coverletter_submit, rwa.draw_date, rwa.draw_amount, rwa.financer_ref, " +
	"rwl.assigned, rwl.rm_contract " + 
	"from rw_assignment rwa " +
	"left join rw_lc_records rwl on ltrim(rtrim(rwa.lc_id)) = ltrim(rtrim(rwl.lc_id)) " +
	"order by rwa.groupi, rwa.origid desc";

	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(21); newlb.setMold("paging");
	newlb.setMultiple(true); newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", asgnCliker);
	ArrayList kabom = new ArrayList();
	String[] fl = { "origid", "groupi", "datecreated", "lc_id", "customer_name", "rm_contract", 
	"noa_submit", "coverletter_submit", "draw_date", "draw_amount", "financer_ref", "assigned" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		sty = "";
		if(d.get("assigned")) sty = "font-size:9px;background:#3DB9DB";
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, asgnboudbleciker);
}

// itype: 0=MRA, 1=MA, 2=AR type 1, 3=AR type 2
// AR types can have multi LC, use groupi to determine when selected
void genNOA(int itype)
{
	if(glob_sel_asgnlc.equals("")) return;

	aix = lbhand.getListcellItemLabel(assignment_lb_selitem,ASGNID_IDX);
	cnm = lbhand.getListcellItemLabel(assignment_lb_selitem,CUSTNAME_IDX);
	lcid = lbhand.getListcellItemLabel(assignment_lb_selitem,LCID_IDX);
	updateAssignment_customerDetails(aix,cnm); // update rw_assignment

	String[] noafn = { "NOA_MRA_v1.rptdesign", "NOA_MA_v1.rptdesign", "NOA_AR_T1_v1.rptdesign", "NOA_AR_T2_v1.rptdesign" };
	tfn = noafn[itype] + "&assignment_no_1=" + glob_sel_asgnlc;
	gpi = ux = "";

	if(itype == 2 || itype == 3) // get groupi LCs for birt.groupi_1
	{
		kk = lbhand.getListcellItemLabel(assignment_lb_selitem,GRP_IDX);
		if(!kk.equals("")) // selected NOA is in a groupi, so get the rest
		{
			sqlstm = "select origid,lc_id from rw_assignment where groupi=" + kk;
			gr = sqlhand.gpSqlGetRows(sqlstm);
			for(d : gr)
			{
				gpi += d.get("lc_id") + ", ";
				ux += d.get("origid").toString() + ",";
			}
			try { gpi = gpi.substring(0,gpi.length()-2); } catch (Exception e) {}
			try { ux = ux.substring(0,ux.length()-1); } catch (Exception e) {}
		}
		else
		{
			gpi = lcid;
			ux = glob_sel_asgnlc;
		}
	}
	else
	{
		ux = glob_sel_asgnlc;
	}

	todaydate = kiboo.todayISODateTimeString();
	sqlstm = "update rw_assignment set noa_submit='" + todaydate + "' where origid in (" + ux + ")";
	sqlhand.gpSqlExecuter(sqlstm);

	gpi = gpi.replaceAll(" ","%20");

	tfn += "&groupi_1=" + gpi;

	if(expass_div.getFellowIfAny("expassframe") != null) expassframe.setParent(null);
	Iframe newiframe = new Iframe();
	newiframe.setId("expassframe"); newiframe.setWidth("100%"); newiframe.setHeight("600px");
	thesrc = birtURL() + "rwreports/" + tfn;
	newiframe.setSrc(thesrc);
	newiframe.setParent(expass_div);
	expasspop.open(noabutt);
}

// knock-off from contractbillingtrack_funcs.exportAssetsList()
// some of the params need juggling. Modi to cater multi selected LC
void genAssetListing(int itype)
{
	if(assignments_lb.getSelectedCount() == 0) return;

	bfn = "rwreports/lc_assetslist_v1.rptdesign";
	switch(itype)
	{
		case 2:
			bfn = "rwreports/lc_assetslist_amt_v1.rptdesign";
			break;
		case 3: // evf w/o specs but with location
			bfn = "rwreports/lc_assetslist_v2.rptdesign";
			break;
		case 4:
			bfn = "rwreports/lc_assetslist_amt_v2.rptdesign";
			break;
		case 5: // evf with specs
			bfn = "rwreports/lc_assetslist_v3.rptdesign";
			break;
		case 6: // multi-LC EVF with grouping (mainly for MISC or other big customers)
			bfn = "rwreports/multilcgroupy_1.rptdesign&userdef_inv=---";
			break;
	}

	kr = assignments_lb.getSelectedItems().toArray();
	ort = "-";

	for(i=0; i<kr.length; i++)
	{
		rwno = lbhand.getListcellItemLabel(kr[i],LCID_IDX);
		cnm = lbhand.getListcellItemLabel(kr[i],CUSTNAME_IDX).replaceAll(" ","%20");

		sqlstm = "select top 1 origid from rw_lc_records where lc_id='" + rwno + "';";
		r = sqlhand.gpSqlFirstRow(sqlstm);
		if(r != null)
		{
			lcid = r.get("origid").toString();
			mwin = vMakeWindow(windsholder,"AssetList/EVF : LC " + rwno,"0","center","700px","");
			kdiv = new Div(); kdiv.setParent(mwin);

			Iframe newiframe = new Iframe();
			newiframe.setWidth("100%"); newiframe.setHeight("600px");

			thesrc = birtURL() + bfn + "&lcid=" + lcid + 
			"&customername=" + cnm + "&ordertype=" + ort + "&rwno=" + rwno;

			newiframe.setSrc(thesrc);
			newiframe.setParent(kdiv);
		}
	}
}


