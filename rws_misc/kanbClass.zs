
/**
 * Kanban main working class. Contains get/put to database, drag-drop handler and etc
 */
class kanbClass
{
	/**
	 * Add new backlog into pipe #1
	 */
	public void addBacklog()
	{
		styl = "font-size:9px";
		nrw = new org.zkoss.zul.Row(); nrw.setParent(glob_MyPipes[0]); nrw.setDraggable("pipefun");
		nrw.setContext(qtContextMenu);

		ngfun.gpMakeLabel(nrw,"","NEW BACKLOG",styl);
		//ngfun.gpMakeLabel(nrw,"",d.get("customer_name") + " [" + d.get("username") + "] / " + d.get("taskcount").toString() , styl);
		
		qtContextMenu.addEventListener("onOpen",QTcontextonOpen);
	}

	/**
	 * Simple hack to move grid.row around 
	 * @param event  the event object
	 * @param droped dropped into which Div
	 */
	public void pipeDrop(DropEvent event, Object droped)
	{
		Object dragged = event.getDragged();
		Object findrws = findgrd = null;

		if(droped instanceof Div)
		{
			cd1 = droped.getChildren().toArray();
			for(i=0; i<cd1.length; i++)
			{
				if(cd1[i] instanceof Grid)
				{
					findgrd = cd1[i];
					break;
				}
			}
			if(findgrd != null)
			{
				cd2 = findgrd.getChildren().toArray();
				for(i=0; i<cd2.length; i++)
				{
					if(cd2[i] instanceof Rows)
					{
						findrws = cd2[i];
						break;
					}
				}
			}
		}
		//alert(dragged + " :: " + droped + " :: " + findgrd + " :: " + findrws);

		if(findrws != null)
		{
			kx = dragged.getChildren().toArray();
			/*
			if(findrws.getId().equals("d_lostbin")) // strike-out quotation if dragged to lost-bin
				kx[1].setStyle( kx[1].getStyle() + ";text-decoration:line-through");
			else
				kx[1].setStyle( "font-size:9px" );
			*/
			dragged.setParent(findrws); // actually moving
		}
	}

	/**
	 * [saveBacklogs description]
	 */
	public void saveBacklogs()
	{

	}

	/**
	 * [loadBacklogs description]
	 */
	public void loadBacklogs()
	{

	}

}

/**
 * Backlog context-menu handler
 * @param iwhat the active object
 */
void qtContextDo(Object iwhat)
{
	itype = iwhat.getId();

	if(itype.equals("linkjob_m"))
	{
		contextSelectedRow = whopSelectedRow; // have to do double-assignment for other funcs to see the selected Row
		addbacklogpop.open(iwhat);
	}

	if(itype.equals("itask_m")) // internal tasks management
	{
		/*
		ki = contextSelectedRow.getChildren().toArray();
		glob_sel_quote = ki[0].getValue();
		inttask_lbl.setValue("Internal tasks for quotation : " + glob_sel_quote);
		showInternalTasksList(1,useraccessobj.username, JN_linkcode(), "", tasksfromyou_holder, "asstasks_lb");
		internaltasks_man_pop.open(contextSelectedRow);
		*/
	}
}

class ctxopen implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		 whopSelectedRow = event.getReference(); // save Row which fires the context-menu
	}
}
QTcontextonOpen = new ctxopen();

