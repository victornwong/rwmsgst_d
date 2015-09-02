/**
 * Stock items handling functions - tblStockInDetail and tblStockInMaster
 */

void refreshThings()
{
	listStockIn(last_show_stockin);
}

/**
 * Put numbering for certain column in a listbox - can be used by other modu
 * @param tlb      the listbox to meddle
 * @param icolumn  column to change
 * @param istartn  starting number
 * @param iwithdot true=put "." after numbering, false=no "."
 */
void renumberListbox(Listbox tlb, int icolumn, int istartn, boolean iwithdot)
{
	try
	{
		lbs = tlb.getItems().toArray();
		tnum = istartn;
		for(i=0;i<lbs.length;i++)
		{
			bs = (tnum+i).toString() + ( (iwithdot) ? "." : "" );
			lbhand.setListcellItemLabel(lbs[i],icolumn,bs);
		}
	} catch (Exception e) {}
}

Object[] stkinhds =
{
	new listboxHeaderWidthObj("STKIN",true,"80px"),
	new listboxHeaderWidthObj("Dated",true,"80px"),
	new listboxHeaderWidthObj("Ref",true,""),
	new listboxHeaderWidthObj("Supplier / Desc",true,""),
	new listboxHeaderWidthObj("StkItem",true,"200px"),
	new listboxHeaderWidthObj("Qty",true,"70px"),
	new listboxHeaderWidthObj("User",true,"80px"), // 6
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("Post",true,"70px"),
	new listboxHeaderWidthObj("stk_id",false,""),
};
STKIN_ID_POS = 0;
STKIN_REF_POS = 2;
STKIN_DESC_POS = 3;
STKIN_STOCKNAME_POS = 4;
STKIN_USER_POS = 6;
STKID_POS = 9;

class stkinclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_stkin_id = lbhand.getListcellItemLabel(isel,STKIN_ID_POS);
		glob_stkin_ref = lbhand.getListcellItemLabel(isel,STKIN_REF_POS);
		glob_stkin_description = lbhand.getListcellItemLabel(isel,STKIN_DESC_POS);
		glob_stkin_user = lbhand.getListcellItemLabel(isel,STKIN_USER_POS);
		glob_stkin_stkid = lbhand.getListcellItemLabel(isel,STKID_POS);
		glob_stkin_stockcode = lbhand.getListcellItemLabel(isel,STKIN_STOCKNAME_POS);

		w_id_lbl.setValue(glob_stkin_id);
		w_reference_tb.setValue(glob_stkin_ref);
		w_description_tb.setValue(glob_stkin_description);
		w_stock_code_tb.setValue( glob_stkin_stockcode ); // stock-code display name only - real linking in stk_id

		showItemcodes(glob_stkin_id, captureitemcodes_holder, "itemcodes_lb");
	}
}
stockinclicker = new stkinclik();

class stkindobuleclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
		} catch (Exception e) {}
	}
}
stkindoublecliker = new stkindobuleclik();

/**
 * [listStockIn description]
 * @param itype listing type - check switch statement
 */
void listStockIn(int itype)
{
	if(itype == 0) return;
	last_show_stockin = itype;

	st = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(stockins_holder, stkinhds, "stockin_lb", 3);
	sqlstm = "select Id,Reference,Description, (select Stock_Code from StockMasterDetails where ID=stk_id) as stock_code,Quantity,Posted,username,stk_id,EntryDate,status from tblStockInMaster where EntryDate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";
	if(!st.equals(""))
		sqlstm += " and (Reference like '%" + st + "%' or Description like '%" + st + "%');";

	r = gpWMS_GetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMold("paging"); // newlb.setMultiple(true); newlb.setCheckmark(true); 
	newlb.addEventListener("onSelect", stockinclicker);

	String[] fl = { "Id", "EntryDate", "Reference", "Description", "stock_code", "Quantity", "username", "status", "Posted","stk_id" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, stkindoublecliker);
}

/**
 * [checkDuplicateItems description]
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 * @param icolumn  which column to check for dups
 * @return          how many dups found
 */
int checkDuplicateItems(Div lbholder, String lbid, int icolumn)
{
	prvlb = lbholder.getFellowIfAny(lbid);
	if(prvlb == null) return;
	ts = prvlb.getItems().toArray();
	if(ts.length == 0) return;

	HashMap dc = new HashMap();
	dupsfound = 0;

	for(i=0; i<ts.length; i++)
	{
		chk = lbhand.getListcellItemLabel(ts[i],icolumn);
		if(dc.containsKey(chk)) // dups found
		{
			ts[i].setStyle("background:#F35111");
			dupsfound++;
		}
		else
		{
			dc.put(chk,1); // not dups, add to hashmap
		}
	}
	return dupsfound;
}

/**
 * Show 'em item-codes from tblStockInDetail by parent_id
 * @param istkin   stock-in voucher - parent_id
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void showItemcodes(String istkin, Div lbholder, String lbid)
{
	prvlb = lbholder.getFellowIfAny(lbid);
	if(prvlb != null) prvlb.setParent(null); // remove previous listbox

	newlb = lbhand.makeVWListbox_Width(lbholder, itmcodehds, lbid, 10);
	newlb.setMultiple(true); newlb.setCheckmark(true);

	sqlstm = "select ItemCode,Quantity,Cost from tblStockInDetail where parent_id=" + istkin;
	r = gpWMS_GetRows(sqlstm);
	if(r.size() == 0) return;
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		kabom.add("0"); kabom.add(d.get("ItemCode").trim());

		kabom.add( ((d.get("Quantity") == null) ? "1" : d.get("Quantity").toString()) );
		kabom.add( ((d.get("Cost") == null) ? "0" : d.get("Quantity").toString()) );

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	renumberListbox(newlb,0,1,true);
	lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker);
}

/**
 * [saveItemcodes description]
 * @param istkin   stock-in voucher id
 * @param istkid   stock-code id - as in stockmasterdetails
 * @param istkcode stock-code display name
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void saveItemcodes(String istkin, String istkid, String istkcode, Div lbholder, String lbid)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return;
	ts = newlb.getItems().toArray();
	if(ts.length == 0) return;

	df = checkDuplicateItems(lbholder,lbid,1);
	if(df > 0)
	{
		guihand.showMessageBox("ERR: duplicate item-codes detected, please check and remove duplicates before saving.");
		return;
	}

	sqlstm = "delete from tblStockInDetail where parent_id=" + istkin;
	gpWMS_execute(sqlstm); // delete previous item-codes by parent_id=istkin if any

	Sql sql = wms_Sql();
	Connection thecon = sql.getConnection();
	todaydate =  kiboo.todayISODateTimeString();

	for(i=0;i<ts.length;i++)
	{
		PreparedStatement pstmt = thecon.prepareStatement("insert into tblStockInDetail (parent_id,StockCode,stk_id,ItemCode,Quantity,Cost,Amount) " +
			"values (?,?,?,?,?,?,?);");

		pstmt.setInt(1,Integer.parseInt(istkin));
		pstmt.setString(2,istkcode);
		pstmt.setInt(3,Integer.parseInt(istkid));

		itmc = lbhand.getListcellItemLabel(ts[i],1);
		pstmt.setString(4,itmc);

		pstmt.setFloat(5,1); // quantity
		pstmt.setFloat(6,0); // cost
		pstmt.setFloat(7,0); // amount
		pstmt.executeUpdate();
	}
	sql.close();
	guihand.showMessageBox("Items saved into stock-in database");
}

/**
 * [removeItemcodes description]
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void removeItemcodes(Div lbholder, String lbid)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) return;
	ts = newlb.getSelectedItems().toArray();
	if(ts.length == 0) return;

	if(Messagebox.show("Remove all the selected items..", "Are you sure?",
		Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) != Messagebox.YES) return;

	for(i=0;i<ts.length;i++)
	{
		ts[i].setParent(null);
	}
	renumberListbox(newlb,0,1,true);
}

Object[] itmcodehds =
{
	new listboxHeaderWidthObj("No.",true,"70px"),
	new listboxHeaderWidthObj("Item code",true,""),
	new listboxHeaderWidthObj("Qty",true,"80px"),
	new listboxHeaderWidthObj("Cost",true,"80px"),
};
ITEM_CODE_POS = 1;
ITEM_QTY_POS = 2;
ITEM_COST_POS = 3;

class itemsdclick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			i_itemcode_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_CODE_POS) );
			i_quantity_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_QTY_POS) );
			i_cost_tb.setValue( lbhand.getListcellItemLabel(isel,ITEM_COST_POS) );
			itemcode_sel_obj = isel;
			edititem_pop.open(isel);
		} catch (Exception e) {}
	}
}
itemdoubleclicker = new itemsdclick();

/**
 * Insert item-codes in iks to listbox
 * @param iks      item-codes string delimited by \n
 * @param lbholder DIV holder for listbox
 * @param lbid     the listbox ID to use
 */
void insertItemcodes(String iks, Div lbholder, String lbid)
{
	newlb = lbholder.getFellowIfAny(lbid);
	if(newlb == null) // listbox not exist, create one
	{
		newlb = lbhand.makeVWListbox_Width(lbholder, itmcodehds, lbid, 10);
		newlb.setMultiple(true); newlb.setCheckmark(true);
	}

	ArrayList kabom = new ArrayList();
	itms = iks.split("\n");

	for(i=0; i<itms.length; i++)
	{
		kabom.add("0"); kabom.add(itms[i].trim());
		kabom.add("1"); kabom.add("0");
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, itemdoubleclicker);
	renumberListbox(newlb,0,1,true);
}
