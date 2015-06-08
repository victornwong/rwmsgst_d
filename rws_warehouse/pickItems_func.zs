import java.util.*;
import java.text.*;
import org.apache.poi.hssf.usermodel.*;
import org.victor.*;
// Pick-items related funcs used by stockPickPack_v1.zul

inputbox_counter = 1; // stock-code/price input-box counter(global)

// Check if any items to pick
boolean pickItemsExist(String ipid)
{
	sqlstm = "select top 1 pick_items from rw_pickpack_items where parent_id=" + ipid;
	kr = sqlhand.gpSqlFirstRow(sqlstm);
	return (kr == null) ? false : true;
}

// return true when no pick-items-cat = null (must assign something)
boolean pickItemsCategorySet(String ipid)
{
	sqlstm = "select top 1 origid from rw_pickpack_items where " + 
	"(stock_cat is null or groupcode is null or classcode is null or class2code is null) " +
	"and parent_id=" + ipid;
	kr = sqlhand.gpSqlFirstRow(sqlstm);
	return (kr == null) ? true : false;
}

// Check pick-items stock-code against stockmaster. Chk also those linking-codes
boolean checkPickItems(String iparent)
{
	retv = false;
	if(glob_sel_picklist.equals("")) false;

	sqlstm = "select qty,stock_cat,groupcode,classcode,class2code,pick_items from rw_pickpack_items where parent_id=" + iparent;
	pks = sqlhand.gpSqlGetRows(sqlstm);

	if(pks.size() == 0) { guihand.showMessageBox("Nothing picked.."); return false; }
	errmsg = "COMMIT : Inventory Checks\n";
	errcount = 0;

	Sql sql = sqlhand.als_mysoftsql();
	if(sql == null) return false;

	for(di : pks)
	{
		itms = kiboo.checkNullString(di.get("pick_items"));
		if(itms.equals("")) continue;
		pxt = itms.split("::");
		acn = 0;
		for(i=0;i<pxt.length;i++) // check qty against pick-items
		{
			try
			{
				if(!pxt[i].trim().equals("")) acn++;
			} catch (Exception e) {}
		}

		scrm = kiboo.checkNullString_RetWat( di.get("stock_cat"),"0" ) + " > " +
				kiboo.checkNullString_RetWat( di.get("groupcode"),"0" ) + " > " +
				kiboo.checkNullString_RetWat( di.get("classcode"),"0" ) + " > " +
				kiboo.checkNullString_RetWat( di.get("class2code"),"0" );

		errmsg += "\n" + scrm + " = Picked: " + acn + " of " + di.get("qty").toString();

		if(acn != (int)di.get("qty"))
		{
			errmsg += "\n\tInsufficient items picked..";
			errcount++;
		}
		else
		{
			// if equ qty and items-count, do check on items stock-code against stockmaster
			for(i=0; i<pxt.length; i++)
			{
				try {
					stk = pxt[i].trim();
					if(!stk.equals(""))
					{
						// now chk deployed fields, chk also stock-cats
						csqls = "select bom_id,rma_id,pick_id from stockmasterdetails " + 
						"where stock_code='" + stk + "' and stock_cat='" + kiboo.checkNullString( di.get("stock_cat") ) + "' " +
						"and groupcode='" + kiboo.checkNullString( di.get("groupcode") ) + "' " + 
						"and classcode='" + kiboo.checkNullString( di.get("classcode") ) + "' " +
						"and class2code='" + kiboo.checkNullString( di.get("class2code") ) + "'";

						kc = sql.firstRow(csqls);

						if(kc != null)
						{
							if(kc.get("bom_id") != null || kc.get("rma_id") != null || kc.get("pick_id") != null)
							{
								smtx = "";
								if(kc.get("bom_id") != null) smtx = BOM_PREFIX + kc.get("bom_id").toString();
								if(kc.get("rma_id") != null) smtx = LOCALRMA_PREFIX + kc.get("rma_id").toString();
								if(kc.get("pick_id") != null) smtx = PICKLIST_PREFIX + kc.get("pick_id").toString();

								errmsg += "\n\tERR- " + stk + " found in " + smtx;
								errcount++;
							}
						}
						else
						{
							errmsg += "\n\t" + stk + " not found in inventory / different category";
							errcount++;
						}
					}

				} catch (Exception e) {}
			}
		}
	}

	if(errcount == 0) // no errors.. perfect
	{
		// update smd.pick_id
		for(di : pks)
		{
			pxt = di.get("pick_items").split("::");
			its = "";
			for(i=0; i<pxt.length; i++)
			{
			try {
				psc = pxt[i].trim();
				if(!psc.equals(""))
				{
					its += "'" + psc + "',";
				}
			} catch (Exception e) {}
			
			}

			its = its.substring(0,its.length()-1);
		}

		errmsg += "\n\tPASS";

		usqlst = "update stockmasterdetails set pick_id=" + iparent + " where stock_code in (" + its + ")";
		errmsg += "\ns: " + usqlst;
		sql.execute(usqlst);

		retv = true;
	}

	sql.close();
	checkitems_popup.open(complete_b);
	checkitems_lbl.setValue(errmsg);
	return retv;
}

void showPickPack_items(String ilist)
{
	sqlstm = "select origid,qty,stock_cat,groupcode,classcode,class2code,pick_items,items_price,item_name from rw_pickpack_items " + 
	"where parent_id=" + ilist;

	ppis = sqlhand.gpSqlGetRows(sqlstm);

	rowtms = pl_rows.getChildren().toArray();
	if(rowtms.length != 0) // remove all previous row
	{
		for(i=0;i<rowtms.length;i++)
		{
			chim = rowtms[i];
			chim.setParent(null);
		}
	}

	if(ppis.size() == 0) return;
	firsto = true;

	itembuthandler = new itembuttClicker();

	for(di : ppis)
	{
		oi = di.get("origid").toString();

		pkirow = gridhand.gridMakeRow("","","",pl_rows); // pl_rows def at UI below
		idet = new Detail();
		//idet.setOpen(firsto);
		//if(firsto) firsto = false;

		// show stock-cat crumb
		scrm = kiboo.checkNullString( di.get("stock_cat") ) + " > " +
				kiboo.checkNullString( di.get("groupcode") ) + " > " +
				kiboo.checkNullString( di.get("classcode") ) + " > " +
				kiboo.checkNullString( di.get("class2code") );

		Div kdv = new Div();
		kdv.setStyle("background:#fcaf3e;padding:2px");
		kdv.setParent(pkirow);
		
		Hbox hb1 = new Hbox();
		hb1.setParent(kdv);
		gpMakeLabel(hb1,"CL" + oi,scrm,"font-weight:bold");

		gpMakeSeparator(1,"60px",hb1);

		gpMakeLabel(hb1,"","Quantity","font-size:9px;font-weight:bold;padding:2px");
		qrty = (di.get("qty") == null) ? "0" : di.get("qty").toString();
		gpMakeTextbox(hb1,"QB" + oi,qrty,"font-weight:bold;","60px");
		gpMakeButton(hb1,"UD" + oi,"Update qty","font-size:9px",itembuthandler);
		
		hb1 = new Hbox();
		hb1.setParent(kdv);
		gpMakeLabel(hb1,"","Model/Name","");
		gpMakeTextbox(hb1,"IN" + oi, kiboo.checkNullString(di.get("item_name")) ,"font-weight:bold;","350px"); // 03/10/2013: item-name to show model to pick

		Hbox hb0 = new Hbox();
		hb0.setParent(idet);

		Vbox vbx = new Vbox();
		vbx.setParent(hb0);

		Div hb2 = new Div();
		hb2.setParent(vbx);
		gpMakeButton(hb2,"CT" + oi,"Category","font-size:9px",itembuthandler);
		gpMakeButton(hb2,"RM" + oi,"Remove","font-size:9px",itembuthandler);
		gpMakeSeparator(2,"5px",hb2);
		gpMakeButton(hb2,"UP" + oi,"Upload","font-size:9px",itembuthandler);

		// disable these butts according to glob_sel_status

		fillPickItems_input(qrty,kiboo.checkNullString(di.get("pick_items")),kiboo.checkNullString(di.get("items_price")),
			hb0,"IB" + oi);

		idet.setParent(pkirow);
	}
}

void fillPickItems_input(String iqty, String ipitems, String iprices, Object iparent, String idivid)
{
	olddv = iparent.getFellowIfAny(idivid);
	if( olddv != null ) olddv.setParent(null); // remove old div

	Div itmdiv = new Div();
	itmdiv.setParent(iparent);
	itmdiv.setStyle("background:#d3d7cf");

	if(!idivid.equals("")) itmdiv.setId(idivid);
	qtc = Integer.parseInt(iqty);

	DecimalFormat nf = new DecimalFormat("000");

	// split items into array
	pxt = ipitems.split("::");
	pric = iprices.split("::");
	
	Hbox hbt = new Hbox();
	gpMakeLabel(hbt,"","No.","font-weight:bold");
	gpMakeSeparator(1,"30px",hbt);
	gpMakeLabel(hbt,"","Item stock-code","font-weight:bold");
	gpMakeSeparator(1,"90px",hbt);
	gpMakeLabel(hbt,"","Price","font-weight:bold");
	hbt.setParent(itmdiv);

	for(i=0; i<qtc; i++)
	{
		Hbox hb3 = new Hbox();
		hb3.setParent(itmdiv);
		gpMakeLabel(hb3,"",nf.format(i+1) + ".","");
		try {
			stkcod = pxt[i];
		} catch (Exception e) { stkcod = ""; }

		try {
			stkprice = pric[i];
		} catch (Exception e) { stkprice = ""; }

		gpMakeTextbox(hb3,"IC" + inputbox_counter,stkcod,"font-weight:bold;","200px"); // IC = Item Code
		gpMakeTextbox(hb3,"IP" + inputbox_counter,stkprice,"font-weight:bold;","80px"); // IP = Item Price

		inputbox_counter++;
	}
}

// Button-clicker multi-funcs
class itembuttClicker implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		ibtn = event.getTarget();
		bnm = ibtn.getId();
		bnt = bnm.substring(0,2);
		bnm = bnm.substring(2,bnm.length());
		sqlstm = "";
		refresh = false;
		qtyi = "";

		if(bnt.equals("CT"))
		{
			chgcat_store.setValue(bnm);
			chgstockgroup_popup.open(ibtn);
		}

		if(bnt.equals("UD"))
		{
			qtyb = pl_rows.getFellowIfAny("QB" + bnm);
			if(qtyb != null)
			{
				qtyi = kiboo.replaceSingleQuotes(qtyb.getValue().trim());
				if(qtyi.equals("")) return;
				sqlstm = "update rw_pickpack_items set qty=" + qtyi + " where origid=" + bnm;
				refresh = true;
			}
		}

		if(bnt.equals("RM"))
		{
			if (Messagebox.show("Remove this pick category and all items..", "Are you sure?", 
				Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			sqlstm = "delete from rw_pickpack_items where origid=" + bnm;
			ibtn.getParent().getParent().getParent().getParent().getParent().setParent(null); // HARDCODED
		}

		if(bnt.equals("UP"))
		{
			upload_Data = new uploadedWorksheet();
			upload_Data.getUploadFileData();
			if(upload_Data.thefiledata == null)
			{
				guihand.showMessageBox("ERR: Invalid worksheet");
				return;
			}
			doUploadWorksheet(bnm);
			refresh = true;
		}

		if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
		if(refresh) showPickPack_items(glob_sel_picklist);
	}
}

void doUploadWorksheet(String iorigid)
{
	HSSFWorkbook excelWB = new HSSFWorkbook(upload_Data.thefiledata);
	FormulaEvaluator evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	numsheets = excelWB.getNumberOfSheets();
	sheet = excelWB.getSheetAt(0);
	numrows = sheet.getPhysicalNumberOfRows();

	itc = "";
	itp = "";

	for(r=0;r<numrows;r++)
	{
		checkrow = sheet.getRow(r);
		kcell = checkrow.getCell(0);
		ki = "";
		if(kcell != null) ki = POI_GetCellContentString(kcell,evaluator,"#.00").trim();
		itc += ki + "::";

		ko = "";
		kcell = checkrow.getCell(1);
		if(kcell != null) ko = POI_GetCellContentString(kcell,evaluator,"#.00").trim();
		itp += ko + "::";
	}

	try {
		itc = itc.substring(0,itc.length()-2);
		itp = itp.substring(0,itp.length()-2);
	} catch (Exception e) {}

	sqlstm = "update rw_pickpack_items set pick_items='" + itc + "', items_price='" + itp + "', " + 
	"qty=" + numrows.toString() + " where origid=" + iorigid;

	sqlhand.gpSqlExecuter(sqlstm);

	//alert("pi: " + iorigid + " rows: " + numrows + " itc: " + itc + " itp: " + itp);
}

