// String mangler work in listbox - each line in a string inserted as a listbox item
// Uses some hardcoded things from calling module. Remember the popup too - got a copy at the end

Object[] mngitmhds =
{
	//new listboxHeaderWidthObj("No.",true,"70px"),
	new listboxHeaderWidthObj("Scan items",true,""),
};

mangleOriginalItems = "";
mangleTextboxObj = null;

/**
 * Get string from pTbox and parse into listbox items, assuming each line is an item
 * @param pTbox TEXTBOX to read from, also to re-populate
 */
void scanitems_Listbox_mangler(Textbox pTbox)
{
	mangleTextboxObj = pTbox; // save for later update button
	tx = pTbox.getValue().trim();
	mangleOriginalItems = tx.replaceAll("\n",","); // save the original items to comma separated string - for audit-log

	if(tx.equals("")) return; // nothing to parse, nothing to do
	Listbox newlb = lbhand.makeVWListbox_Width(mangleitems_holder, mngitmhds, "mangleitems_lb", 10);
	newlb.setMultiple(true); newlb.setCheckmark(true);
	ts = tx.split("\n"); kn = 1;
	ArrayList kabom = new ArrayList();
	for(i=0; i<ts.length; i++)
	{
		//kabom.add(kn.toString());
		kabom.add(ts[i].trim());
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
		kn++;
	}
	mangleitems_pop.open(pTbox);
}

/**
 * Just remove selected-items in mangleitems_lb - no confirmation
 */
void removeMangleitems()
{
	ilb = mangleitems_holder.getFellowIfAny("mangleitems_lb"); // HARDCODED ui elements in mangleitems_pop
	if(ilb == null) return;
	ts = ilb.getSelectedItems().toArray();
	for(i=0;i<ts.length;i++)
	{
		ts[i].setParent(null);
	}
}

/**
 * Add from textbox to mangle-item listbox. Uses manglenewitem_tb defined in popup.
 */
void addItemToMangleList()
{
	kk = manglenewitem_tb.getValue().trim();
	if(kk.equals("")) return;
	ilb = mangleitems_holder.getFellowIfAny("mangleitems_lb"); // HARDCODED ui elements in mangleitems_pop
	if(ilb == null) return;
	ArrayList kabom = new ArrayList();
	kabom.add(kk);
	lbhand.insertListItems(ilb,kiboo.convertArrayListToStringArray(kabom),"false","");
}

/**
 * Grab things in mangleitems_lb and make into a string, replace content of mangleTextboxObj(assuming it's a textbox)
 * Uses some hardcoded module specific stuff: useraccessobj, JN_linkcode()
 */
void updateMangleitemsBack_toTextbox()
{
	mangleitems_pop.close();
	tobe_itemslist = tobe_insert = "";
	ilb = mangleitems_holder.getFellowIfAny("mangleitems_lb"); // HARDCODED ui elements in mangleitems_pop
	ts = ilb.getItems().toArray();
	for(i=0; i<ts.length; i++)
	{
		kk = lbhand.getListcellItemLabel(ts[i],0);
		tobe_itemslist += kk + ",";
		tobe_insert += kk + "\n";
	}
	adts = "Original tags: " + mangleOriginalItems + "\nUPDATED to: " + tobe_itemslist;
	add_RWAuditLog(JN_linkcode(),"",adts,useraccessobj.username); // Add original-items and tobe_insert to audit-log
	mangleTextboxObj.setValue(tobe_insert); // replace things in textbox
	mangleItems_callback();
}

/*
	<popup id="mangleitems_pop">
		<div sclass="shadowbox" style="background:#3F7CBA" width="300px">
			<label value="Pick-items Return or Add" style="font-size:12px;font-weight:bold;color:#ffffff" />
			<grid sclass="GridLayoutNoBorder">
				<rows>
					<row style="background:#3F7CBA">
						<button label="Remove selected parts" sclass="k9mo" onClick="removeMangleitems()" />
						<button label="Update to pick-list" sclass="k9mo" onClick="updateMangleitemsBack_toTextbox()" />
						<button label="Close" sclass="k9mo" onClick="mangleitems_pop.close()" />
					</row>
					<row spans="1,2" style="background:#3F7CBA">
						<textbox id="manglenewitem_tb" sclass="k9" />
						<button label="Add new item to pick-list" sclass="k9mo" onClick="addItemToMangleList()" />
					</row>
				</rows>
			</grid>
			<separator height="3px" />
			<div id="mangleitems_holder" />
		</div>
	</popup>
 */
