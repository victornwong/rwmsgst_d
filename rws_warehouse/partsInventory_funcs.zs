import org.victor.*;

// General purpose funcs for parts inventory management

// Simplified general-purpose listbox maker TODO include into .java
Listbox simpleListboxMaker(Div imyholder, String imyid, int irows, String imywidth)
{
	oldlb = imyholder.getFellowIfAny(imyid);
	if( oldlb != null) oldlb.setParent(null);
	Listbox newlb = new Listbox();
	newlb.setRows(irows);
	newlb.setStyle(";background:#d3d7cf");
	newlb.setParent(imyholder);
	newlb.setId(imyid);
	newlb.setMold("select");
	newlb.setWidth(imywidth);
	return newlb;
}

// General purpose func to hide listbox in div TODO include into .java
void gpHideListbox(Div idiv, String ilbid)
{
	clslb = idiv.getFellowIfAny(ilbid);
	if(clslb != null) clslb.setParent(null);
}

void autoPointCategories(String[] isels, Div[] idivs, String[] ilbids, Object[] iclickf)
{
	//alert(isels[0] + " :: " + isels[1] + " :: " + isels[2] + " :: " + isels[3]);
	//newpop_StockSelector(1, isels[0] + "_GROUPCODE", grouplb_holder, "group_lb", new grpcodeClick(), mnstkdiv, mnstklbs);

	if(grouplb_holder.getFellowIfAny("group_lb") == null) return;

	newpop_StockSelector(1, isels[0] + "_GROUPCODE", idivs[1], ilbids[1], iclickf[1], idivs, ilbids);
	group_lb.setRows(STOCKGROUP_LBROWS); // only main stock-group lbs inc rows

	scl1 = isels[0] + "_" + isels[1];
	if(isels[0].equals("RAM") || isels[0].equals("HDD")) scl1 = isels[0] + "_CLASS1";

	//newpop_StockSelector(2,scl1,class1lb_holder,"class1_lb",new class1Click(),mnstkdiv,mnstklbs);
	newpop_StockSelector(2, scl1, idivs[2], ilbids[2], iclickf[2], idivs, ilbids);
	class1_lb.setRows(STOCKGROUP_LBROWS);

	newpop_StockSelector(3, isels[2], idivs[3], ilbids[3], null, idivs, ilbids);
	class2_lb.setRows(STOCKGROUP_LBROWS);

	for(int i=0; i<4; i++)
	{
		thlb = idivs[i].getFellowIfAny(ilbids[i]);
		if(thlb != null) lbhand.matchListboxItems(thlb,isels[i]);
	}
}

String[] getSelected_StockGroup(Div[] idivs, String[] ilbids)
{
	String[] retval = { "","0","0","0" };
	
	for(i=0;i<4;i++)
	{
		if(lbhand.check_ListboxExist_SelectItem(idivs[i],ilbids[i]))
		{
			thlb = idivs[i].getFellowIfAny(ilbids[i]);
			retval[i] = thlb.getSelectedItem().getLabel();
		}
	}
	//alert(retval[0] + " :: " + retval[1] + " :: " + retval[2] + " :: " + retval[3]);
	return retval;
}

// Populate stock-cat-group selectors listbox
void newpop_StockSelector(int itype, String iluid, Div lbholder, String lbid, Object iclickf,
Div[] iholder, String[] ilbid)
{
	Listbox newlb = simpleListboxMaker(lbholder, lbid, 1, "100%");
	String[] strarray = new String[2];
	strarray[0] = "0";
	strarray[1] = "0";

	if(iluid.equals("0") || iluid.equals(""))
	{
		lbhand.insertListItems(newlb,strarray,"false","");

		// get parent-lookup codes (for class2 code only)
		if(itype == 3)
		{
			stklb = iholder[0].getFellowIfAny(ilbid[0]);
			grplb = iholder[1].getFellowIfAny(ilbid[1]);
			cls1lb = iholder[2].getFellowIfAny(ilbid[2]);

			stkc = stklb.getSelectedItem().getLabel();
			grpc = grplb.getSelectedItem().getLabel();
			cls1 = cls1lb.getSelectedItem().getLabel();
			parcd = stkc + "_" + grpc + "_" + cls1;
			luhand.populateListBox_ValueSelection(newlb,parcd,2,8);
		}
	}
	else
	{
		lurec = luhand.getLookupRec_ByID(iluid);
		if(lurec == null) // cannot find by lookup-id, use the same param instead
		{
			//alert("lb: " + newlb + " makelb: " + iluid + " lbid: " + lbid);
			luhand.populateListBox_ValueSelection(newlb,iluid,2,8);
			if(newlb.getItemCount() == 0)
			{
				lbhand.insertListItems(newlb,strarray,"false","");
				newlb.setSelectedIndex(0);
			}
		}
		else
		{
			luhand.populateListBox_ValueSelection(newlb,kiboo.checkNullString(lurec.get("name")),2,8);
		}
	}

	if(iclickf != null) newlb.addEventListener("onSelect",iclickf);
}

