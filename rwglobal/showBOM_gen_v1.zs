import org.victor.*;

// General purpose stuff to view BOM in any module -- remember the popup
// Written by : Victor Wong

Object[] builds_headers = 
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("##",true,"30px"),
	new listboxHeaderWidthObj("Builds",true,"70px"),
	new listboxHeaderWidthObj("AssetTag",true,"80px"),
	new listboxHeaderWidthObj("Grd",true,"40px"),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("CPU",true,""),
	new listboxHeaderWidthObj("HDD",true,""),
	new listboxHeaderWidthObj("RAM",true,""),
	new listboxHeaderWidthObj("BATT",true,""),
	new listboxHeaderWidthObj("PWRADPT",true,""),
	new listboxHeaderWidthObj("GFX",true,""),
	new listboxHeaderWidthObj("MON",true,""),
	
};

void showBuildItems(String ibomid, Div iholder)
{
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, builds_headers, "builds_lb", 8);

	sqlstm = "select origid,bomtype,grade,description,asset_tag,cpu,hdd,ram,battery, " + 
	"poweradaptor,gfxcard,monitor " +
	"from stockrentalitems_det where parent_id=" + ibomid;
	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;

	//newlb.addEventListener("onSelect", new buildsClick());
	lncnt = 1;

	for(dpi : screcs)
	{
		ArrayList kabom = new ArrayList();
		kabom.add(dpi.get("origid").toString());
		kabom.add(lncnt.toString() + ".");
		kabom.add(dpi.get("bomtype"));

		kabom.add( kiboo.checkNullString(dpi.get("asset_tag")) );
		kabom.add(kiboo.checkNullString(dpi.get("grade")));
		kabom.add(kiboo.checkNullString(dpi.get("description")));
		kabom.add(kiboo.checkNullString(dpi.get("cpu")));
		kabom.add(kiboo.checkNullString(dpi.get("hdd")));
		kabom.add(kiboo.checkNullString(dpi.get("ram")));
		kabom.add(kiboo.checkNullString(dpi.get("battery")));
		kabom.add(kiboo.checkNullString(dpi.get("poweradaptor")));
		kabom.add(kiboo.checkNullString(dpi.get("gfxcard")));
		kabom.add(kiboo.checkNullString(dpi.get("monitor")));

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
		lncnt++;
	}
}

