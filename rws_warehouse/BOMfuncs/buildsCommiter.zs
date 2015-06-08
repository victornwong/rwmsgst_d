// 23/06/2014: new BOM commit func

// get some stock details from focus5012.partsall_0. isql need to be created by caller -- to save open/close sql-pipe traffic
Object getFC6_stockdets(Object isql, String ipartn)
{
	fsql = "select top 1 name,grade from partsall_0 where assettag='" + ipartn + "';";
	return isql.firstRow(fsql);
}

Object[] cmbuldhds = 
{
	new listboxHeaderWidthObj("No.",true,"50px"),
	new listboxHeaderWidthObj("Bld",true,"50px"),
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("Grade",true,""),
};

void newBOMCommiter()
{
	if(global_selected_bom.equals("")) return;
	sqlstm = "select srd.asset_tag, srd.ram, srd.ram2, srd.ram3, srd.ram4, srd.hdd, srd.hdd2, srd.hdd3, srd.hdd4, " +
	"srd.battery, srd.poweradaptor, srd.gfxcard " +
	"from stockrentalitems_det srd where srd.parent_id=" + global_selected_bom;

	Listbox newlb = lbhand.makeVWListbox_Width(cm_bomitems_holder, cmbuldhds, "buildsassets_lb", 10);
	r = sqlhand.gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setMold("paging");
	newlb.setRows(21);
	ArrayList kabom = new ArrayList();
	String[] fl = { "asset_tag", "ram", "ram2", "ram3", "ram4", "hdd", "hdd2", "hdd3", "hdd4", "battery", "poweradaptor", "gfxcard" };
	fcs = sqlhand.rws_Sql();
	notfoundi = 0;
	lnc = bld = 1;

	for(d : r)
	{
		itm = grd = sty = "";
		kk = kiboo.checkNullString(d.get(fl[0]));
		atg = kk.trim();
		if(kk.equals(""))
		{
			notfoundi++;
			sty = "background:#F50F26;font-weight:bold;font-size:9px;color:#ffffff";
		}
		else
		{
			frx = getFC6_stockdets(fcs,atg);
			if(frx != null)
			{
				itm = kiboo.checkNullString(frx.get("name"));
				grd = kiboo.checkNullString(frx.get("grade"));
			}
			if(itm.equals(""))
			{
				notfoundi++;
				sty = "background:#F50F26;font-weight:bold;font-size:9px;color:#ffffff";
			}
		}

		kabom.add(lnc.toString() + ".");
		kabom.add(bld.toString());
		kabom.add(atg);
		kabom.add(itm);
		kabom.add(grd);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
		kabom.clear();
		lnc++;

		for(i=1; i<fl.length; i++)
		{
			kk = kiboo.checkNullString(d.get(fl[i]));
			itm = grd = sty = "";
			atg = kk.trim();
			if(!atg.equals(""))
			{
				frx = getFC6_stockdets(fcs,atg);
				if(frx != null)
				{
					itm = kiboo.checkNullString(frx.get("name"));
					grd = kiboo.checkNullString(frx.get("grade"));
				}

				if(itm.equals(""))
				{
					notfoundi++; // count asset-tags not in FC6
					sty = "background:#F50F26;font-weight:bold;font-size:9px;color:#ffffff";
				}
				kabom.add(lnc.toString() + ".");
				kabom.add(bld.toString());
				kabom.add(atg);
				kabom.add(itm);
				kabom.add(grd);
				lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",sty);
				kabom.clear();
				lnc++;
			}
		}
		bld++;
	}
	fcs.close();
	doit = false;
	errmsg = "";

	if(notfoundi > 0)
	{
		errmsg = "ERRORS - cannot commit";
		doit = true; // disable actual-commit button
	}
	realcommit_b.setDisabled(doit);
	cm_error_lbl.setValue(errmsg);
	bomcommiterpopup.open(commitbom_butt);
}

