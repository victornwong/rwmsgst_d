import org.victor.*;
// Check-list handler : by Victor Wong (05/12/2013)

// Callback by chklistClick. Copy and customize this in other mods
void checkListCallBack(Object iwhat)
{
}

class chklistClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		checkListCallBack(event.getTarget());
	}
}

chkclicker = new chklistClick();

// General func to show check-items from checklist_templates
// chklistid = checklist_templates.origid
void showChecklistItems(Div idiv, int chklistid, String igid, String igrows)
{
	prvg = idiv.getFellowIfAny(igid);
	if(prvg != null) prvg.setParent(null); // remove prev
	thegrid = new Grid();
	thegrid.setId(igid);
	grows = new org.zkoss.zul.Rows();
	grows.setId(igrows);
	grows.setParent(thegrid);
	ckrec = sqlhand.getChecklistTemplate_Rec(chklistid.toString());
	//debugbox.setValue(ckrec.toString());
	if(ckrec != null)
	{
		String[] chkitems = sqlhand.clobToString(ckrec.get("list_items")).split("~");
		for(i=0; i<chkitems.length; i++)
		{
			try {
				if(!chkitems[i].equals(""))
				{
					nrw = new org.zkoss.zul.Row();
					nrw.setParent(grows);
					ckbox = new Checkbox();
					ckbox.setStyle("font-size:9px");
					ckbox.setLabel(chkitems[i]);
					ckbox.setParent(nrw);
					ckbox.addEventListener("onCheck", chkclicker);
				}
			} catch (Exception e) {}
		}
	}
	thegrid.setParent(idiv);
}

String saveCheckedbox(Object irows)
{
	tked = "";
	arws = irows.getChildren().toArray();
	for(i=0; i<arws.length; i++)
	{
		krw = arws[i].getChildren().get(0);
		if(krw instanceof Checkbox)
		{
			if(krw.isChecked()) tked += krw.getLabel().replaceAll("~"," ") + "~";
		}
	}
	try { tked = tked.substring(0,tked.length()-1); } catch (Exception e) {}
	//alert(tked);
	return tked;
}
//--- ENDOF check-list handling stuff


