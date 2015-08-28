/**
 * Stock master lister things - can be used by other modu with some modif
 */

Object[] stkitemshds =
{
	new listboxHeaderWidthObj("Stock-code",true,""),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("Category",true,"80px"),
	new listboxHeaderWidthObj("Group",true,"80px"),
	new listboxHeaderWidthObj("Class",true,"80px"),
	new listboxHeaderWidthObj("Entry",true,"70px"), // 5
	new listboxHeaderWidthObj("Act",true,"60px"),
	new listboxHeaderWidthObj("id",false,""),
};
ITM_ID = 7;

/**
 * onSelect for stock_items_lb
 * TODO need to add call-back for other modu
 */
class stkitemclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_stock_code = lbhand.getListcellItemLabel(isel,0);
		glob_sel_description = lbhand.getListcellItemLabel(isel,1);
		glob_sel_stock_cat = lbhand.getListcellItemLabel(isel,2);
		glob_sel_groupcode = lbhand.getListcellItemLabel(isel,3);
		glob_sel_classcode = lbhand.getListcellItemLabel(isel,4);
		glob_sel_id = lbhand.getListcellItemLabel(isel,ITM_ID);

		stockItemListbox_callback(isel);
	}
}
stockitemclicker = new stkitemclik();

class stkitemdoubelclik implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		try
		{
			glob_sel_stock_code = lbhand.getListcellItemLabel(isel,0);
			glob_sel_description = lbhand.getListcellItemLabel(isel,1);
			glob_sel_stock_cat = lbhand.getListcellItemLabel(isel,2);
			glob_sel_groupcode = lbhand.getListcellItemLabel(isel,3);
			glob_sel_classcode = lbhand.getListcellItemLabel(isel,4);
			glob_sel_id = lbhand.getListcellItemLabel(isel,ITM_ID);

			e_stock_code_tb.setValue(glob_sel_stock_code);
			e_description_tb.setValue(glob_sel_description);
			e_stock_cat_cb.setValue(glob_sel_stock_cat);
			e_groupcode_cb.setValue(glob_sel_groupcode);
			e_classcode_cb.setValue(glob_sel_classcode);

			editstockitem_pop.open(isel);

			stockItemListbox_callback(isel);

		} catch (Exception e) {}
	}
}
stkitem_doubclik = new stkitemdoubelclik();

/**
 * [listStockItems description]
 * @param itype list type to perform - check switch-case
 */
void listStockItems(int itype)
{
	if(itype == 0) return;
	last_show_stockitems = itype;
	Listbox newlb = lbhand.makeVWListbox_Width(stockitems_holder, stkitemshds, "stock_items_lb", 3);

	sqlstm = "select Stock_Code,Description,Stock_Cat,GroupCode,ClassCode,EntryDate,ID,IsActive from StockMasterDetails ";
	wherestr = "";

	switch(itype)
	{
		// all listing by drop-downs plung here
		case 1: // by stock-cat
		case 2: // by group-code
		case 3: // by class-code
			Object[] lsto = { m_stock_cat_lb, m_groupcode_lb, m_classcode_lb };
			String[] lstn = { "Stock_Cat", "GroupCode", "ClassCode" };
			fln = lstn[itype-1]; k = "";

			try { k = lsto[itype-1].getSelectedItem().getLabel(); } catch (Exception e) {}

			if(k.equals(""))
			{
				wherestr = "where " + fln + " is null or " + fln + "='' ";
			}
			else
			{
				wherestr = "where " + fln + "='" + kiboo.replaceSingleQuotes(k) + "' ";
			}
			break;

		case 4: // by search-text or just dump everything -- need to limit
			k = kiboo.replaceSingleQuotes( m_searchtext_tb.getValue().trim() );
			if(!k.equals(""))
			{
				wherestr = "where Stock_Code like '%" + k + "%' or Description like '%" + k + "%' ";
			}
			else
			{
				wherestr = "limit 100";
			}
			break;
	}

	sqlstm += wherestr;

	r = gpWMS_GetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(20); newlb.setMultiple(true); newlb.setCheckmark(true); newlb.setMold("paging");
	newlb.addEventListener("onSelect", stockitemclicker);

	String[] fl = { "Stock_Code", "Description", "Stock_Cat", "GroupCode", "ClassCode", "EntryDate", "IsActive", "ID" };
	ArrayList kabom = new ArrayList();

	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, stkitem_doubclik);
}
