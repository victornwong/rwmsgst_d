/*
Menubar general purpose funcs
Written by Victor Wong
Dated: 08/10/2011
*/

/*
// GUI Func: Menubar maker
void menuBarMaker(String compoid, String istyle, String iwidth, Object iparent)
{
	tmenubar = new Menubar();
	if(!istyle.equals("")) tmenubar.setStyle(istyle);
	if(!iwidth.equals("")) tmenubar.setWidth(iwidth); else tmenubar.setWidth("100%");
	tmenubar.setId(compoid);
	tmenubar.setParent(iparent);
}
*/

/*
// GUI Func: make Menu component - as drop-down menu-tab
void menuTabMaker(String compoid, String ilabel, String istyle, Object iparent)
{
	menutab = new Menu();
	if(!compoid.equals("")) menutab.setId(compoid);
	if(!istyle.equals("")) menutab.setStyle(istyle);
	menutab.setLabel(ilabel);
	menutab.setParent(iparent);
}
*/

/*
// GUI Func: Menupopup() maker
void menuListMaker(String compoid, Object iparent)
{
	mpopup = new Menupopup();
	mpopup.setId(compoid);
	mpopup.setParent(iparent);
}

// GUI Func: menuitem maker - make program shorter in some way.. haha
// itype: 1=internal, 2=call def mods in database
void menuItemMaker(String compoid, String ilabel, String istyle, Object iparent, int itype)
{
	mitem = new Menuitem();
	if(!compoid.equals("")) mitem.setId(compoid);
	if(!istyle.equals("")) mitem.setStyle(istyle);

	if(itype == 1)
		mitem.addEventListener("onClick", new internalMenuItem_Clicker());
	else
		mitem.addEventListener("onClick", new externalMenuItem_Clicker());

	mitem.setLabel(ilabel);
	mitem.setParent(iparent);
}
*/
