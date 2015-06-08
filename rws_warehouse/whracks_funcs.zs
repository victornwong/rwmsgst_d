import java.util.*;
import java.text.*;
import java.io.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.geom.*;
import org.zkoss.image.*;
import javax.imageio.ImageIO;
import org.victor.*;

class areamap_Listener implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(org.zkoss.zk.ui.event.Event event) throws UiException
	{
		String areaid = event.getArea();
		if (areaid != null)
		{
			org.zkoss.zul.Area tarea = (org.zkoss.zul.Area)self.getFellow(areaid);
			/*
			alert("" + tarea.getId() + " : " + tarea.getTooltiptext() + " : " + tarea.getCoords()
			+ " : w" + globAimage.getWidth() + ", h"  + globAimage.getHeight() );
			*/
			//posorigid = area.getId().substring(3);

			glob_sel_cell = tarea.getTooltiptext();
			kdesc = globCellHash.get(glob_sel_cell);
			if(kdesc != null) showCell_Assets2(glob_sel_cell,kdesc,tarea,cellassets_holder);
		}
	}
}

// Show cell's tooltip. Remove 2-chr prefix
void showEmCellId(org.zkoss.zul.Imagemap imgmp, BufferedImage ibufimg)
{
	mchd = imgmp.getChildren().toArray();
	Graphics2D g2d = ibufimg.createGraphics();
	g2d.setColor(new Color(250,250,250));
	//g2d.setStroke(new BasicStroke(2));
	for(i=0; i<mchd.length; i++)
	{
		//celstr = mchd[i].getTooltiptext().substring(2,mchd[i].getTooltiptext().length());
		celstr = mchd[i].getTooltiptext();
		corr = mchd[i].getCoords().split(",");
		rx = Integer.parseInt(corr[0]);
		ry = Integer.parseInt(corr[1]);
		rwid = Integer.parseInt(corr[2]) - rx;
		rhei = Integer.parseInt(corr[3]) - ry;
		//g2d.drawRect(rx,ry,rwid,rhei);
		g2d.drawRect(rx,ry,rwid,19);
		g2d.drawString(celstr.toUpperCase(),rx+3,ry+15);
	}
	imgmp.setContent(ibufimg);
}

// Load image and get imagemaps recs from mapper_pos linked by iparentid
BufferedImage makeImagemapThing(Div idiv, String imapid, String imfn, String iparentid)
{
	pmapid = idiv.getFellowIfAny(imapid);
	if(pmapid != null) pmapid.setParent(null);
	if(imfn.equals("")) return;

	kfn = session.getWebApp().getRealPath(imfn);
	globAimage = new AImage(kfn);
	InputStream in = new ByteArrayInputStream( globAimage.getByteData() );

	ibufimg = new BufferedImage(globAimage.getWidth(),globAimage.getHeight(), BufferedImage.TYPE_INT_RGB);
	ibufimg = ImageIO.read(in);

	org.zkoss.zul.Imagemap kamage = new org.zkoss.zul.Imagemap();
	//kamage.setContent(globRackImage_f);
	kamage.setId(imapid);
	kamage.addEventListener("onClick", imagemapHandler);
	kamage.setParent(idiv);

	sqlstm = "select origid,area_id,shape,coords from mapper_pos where parent_id='" + iparentid + "'";
	maprecs = sqlhand.gpSqlGetRows(sqlstm);
	if(maprecs.size() == 0) return;

	for(mpi : maprecs)
	{
		org.zkoss.zul.Area marea = new org.zkoss.zul.Area();
		marea.setShape(mpi.get("shape"));
		marea.setCoords(mpi.get("coords"));
		//areaid = mpi.get("area_id").substring(2, mpi.get("area_id").length() );
		areaid = mpi.get("area_id");
		marea.setId("MAP" + mpi.get("origid").toString());
		marea.setTooltiptext(areaid);
		marea.setParent(kamage);
	}

	showEmCellId(kamage,ibufimg);
	return ibufimg;
}

// icel=cell id str, iqty=item quantity, ibmax=cell max - to calc bar-fill percentage
void liteUpCell(String icel, int iqty, int ibmax, org.zkoss.zul.Imagemap imgmp, BufferedImage ibufimg)
{
	mchd = imgmp.getChildren().toArray();
	Graphics2D g2d = ibufimg.createGraphics();
	RenderingHints rh = new RenderingHints(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	rh.put(RenderingHints.KEY_RENDERING,RenderingHints.VALUE_RENDER_QUALITY);
	g2d.setRenderingHints(rh);

	boxcolor = new Color(12,245,96,180);
	txtcolor = new Color(250,250,250);
	txt2color = new Color(0,0,0);

	for(i=0; i<mchd.length; i++)
	{
		celstr = mchd[i].getTooltiptext();
		if( celstr.equals(icel) )
		{
			corr = mchd[i].getCoords().split(",");
			rx = Integer.parseInt(corr[0]);
			ry = Integer.parseInt(corr[1]);
			rwid = Integer.parseInt(corr[2]) - rx;
			rhei = Integer.parseInt(corr[3]) - ry;

			kpct = (float)iqty / (float)ibmax;
			kct = kpct * (float)rhei;
			dy = Integer.parseInt(corr[3]) - kct;
/*
			dbgbox.setValue(dbgbox.getValue() + 
			"\ncelstr: " + celstr + " rhei: " + rhei.toString() + " kct: " + kct.toString() + " dy: " + dy.toString()
			+ " iqty: " + iqty.toString() + " ibmax: " + ibmax.toString()
			);
*/
			g2d.setColor(boxcolor);
			g2d.fillRect(rx, (int)dy, rwid, (int)(kct) );

			// fill-color can be customized for low-stock and etc
			g2d.setColor( (kpct < 0.95) ? txtcolor : txt2color );
			g2d.drawString(celstr.toUpperCase(),rx+4,ry+15);
		}
	}
}

Object[] rckmanfhds =
{
	new listboxHeaderWidthObj("Cell",true,"30px"),
	new listboxHeaderWidthObj("Stock Item",true,"160px"),
	new listboxHeaderWidthObj("Qty",true,"40px"),
};

class manifclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(org.zkoss.zk.ui.event.Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_cell = lbhand.getListcellItemLabel(isel,0);
		dsec = lbhand.getListcellItemLabel(isel,1);
		//showCell_Assets(glob_sel_cell,dsec,isel);
	}
}

void showRackManifest(String irck, Div iholder, org.zkoss.zul.Imagemap imgmp, BufferedImage ibufimg )
{
	lbid = "rackmanflb_" + irck;
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, rckmanfhds, lbid, 20);

	sqlstm = "select distinct description, count(stock_code) as itemqty, palletno " +
	"from stockmasterdetails where palletno like '" + irck + "__' or palletno like '" + irck + "_' " +
	"group by description,palletno " +
	"order by palletno";

	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", manifestHandler);
	ArrayList kabom = new ArrayList();
	for(d : crecs)
	{
		kdes = kiboo.checkNullString(d.get("description")) ;
		kabom.add( d.get("palletno") );
		kabom.add(kdes);
		kabom.add( d.get("itemqty").toString() );
		globCellHash.put( d.get("palletno") , kdes );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		liteUpCell( d.get("palletno"), d.get("itemqty"), PALLET_SIZE, imgmp, ibufimg);
		kabom.clear();
	}
	imgmp.setContent(ibufimg);
}

Object[] assfhds =
{
	new listboxHeaderWidthObj("Asset Tags",true,"180px"),
	new listboxHeaderWidthObj("S/Number",true,"180px"),
	new listboxHeaderWidthObj("Desc",true,""),
};

void showCell_Assets(String icel, String idesc, Object iobj)
{
	kcl = icel.substring(0,1);
	kxl = iobj.getParent().getFellowIfAny("cellassets_holder_" + kcl);
	kahd = iobj.getParent().getFellowIfAny("assets_header_" + kcl);

	lbid = "cellasslb_" + kcl;
	Listbox newlb = lbhand.makeVWListbox_Width(kxl, assfhds, lbid, 20);
	sqlstm = "select stock_code,supplier_part_number from stockmasterdetails where palletno='" + icel + "' order by stock_code";
	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new manifclk());
	ArrayList kabom = new ArrayList();
	for(d : crecs)
	{
		kabom.add( d.get("stock_code") );
		kabom.add( kiboo.checkNullString(d.get("supplier_part_number")).toUpperCase() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}

	kahd.setValue("[ " + icel + " ] : " + idesc);
}

// show cell's contents with description..
void showCell_Assets2(String icel, String idesc, Object iobj, Div iholder)
{
	kcl = icel.substring(0,1);
	kxl = iobj.getParent().getFellowIfAny("cellassets_holder_" + kcl);
	kahd = iobj.getParent().getFellowIfAny("assets_header_" + kcl);
	lbid = "cellasslb_" + kcl;
	//Listbox newlb = lbhand.makeVWListbox_Width(kxl, assfhds, lbid, 20);
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, assfhds, "cellass_lb", 20);
	sqlstm = "select stock_code,supplier_part_number,description from stockmasterdetails where palletno='" + icel + "' order by stock_code";
	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setCheckmark(true);
	newlb.setMultiple(true);
	//newlb.addEventListener("onSelect", new manifclk());
	ArrayList kabom = new ArrayList();
	for(d : crecs)
	{
		kabom.add( d.get("stock_code") );
		kabom.add( kiboo.checkNullString(d.get("supplier_part_number")).toUpperCase() );
		kabom.add( kiboo.checkNullString(d.get("description")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","font-weight:bold");
		kabom.clear();
	}
	selectcell_id.setValue(icel); // compo def in popup
	drillcell_pop.open(iobj);
	assets_header.setValue("[ " + icel + " ] : " + idesc + " [Qty: " + crecs.size().toString() + "]");
	//kahd.setValue("[ " + icel + " ] : " + idesc);
}

void popuCell_lb(Listbox iwhat, int istart, int icount, int itype)
{
	String[] rckstr = { "A","B","C","D","E","F" };

	if(itype == 1)
	{
		for(i=0;i<rckstr.length;i++)
		{
			tlbitm = new Listitem();
			tlbitm.setLabel(rckstr[i]);
			tlbitm.setParent(iwhat);
		}
		iwhat.setSelectedIndex(0);
	}

	if(itype == 2)
	{
		for(i=istart; i<istart+icount; i++)
		{
			tlbitm = new Listitem();
			tlbitm.setLabel(i.toString());
			tlbitm.setParent(iwhat);
		}
		iwhat.setSelectedIndex(0);
	}
}


