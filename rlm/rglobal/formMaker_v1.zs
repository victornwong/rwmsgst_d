/**
 * @title ZUL-XML Form maker classes
 * @author Victor Wong
 * @since 01/08/2012
 * @version 0.1
 *
 * XML form defination store in database. Can be used in other modules by calling those utility funcs. Storing form-data back to file or
 * database is to be programmed individually on each module.
 *
 * 07/09/2015: this version access form-elements from MySQL
 * 
 */
import org.victor.*;
import java.util.*;
import java.io.IOException;
import java.io.StringReader;
import java.sql.SQLException;
import groovy.sql.*;
import groovy.lang.*;
import org.zkoss.zul.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.InputSource;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

// Form elements slicer thing - kinda like a rewrite of ZK's stuff - implement a subset of components only - not all
// SAXParser boiler-plate codes extracted from some website
public class FormXMLSplicer extends DefaultHandler
{
	Component formholder;
	Grid formgrid;
	org.zkoss.zul.Rows gridrows;
	org.zkoss.zul.Row cnewrow;
	org.zkoss.zul.Columns gridcolumns;

	String tmpValue;
	Listbox cnewlistbox;
	Listitem cnewlistitem;
	Label cnewlabel;
	Radiogroup cnewradiogroup;

	ListboxHandler lbhand;
	LookupFuncs luhand;
	GridHandler gridhand;

	String formid, append_id;
	HashMap localhashmap; // to store component ID

	public FormXMLSplicer(Component iholder, String iformid)
	{
		formholder = iholder;
		formid = iformid;
		append_id = "";

		localhashmap = new HashMap();

		lbhand = new ListboxHandler();
		luhand = new LookupFuncs();
		gridhand = new GridHandler();
	}

	public void clearFormFieldsAll()
	{
		rwcs = gridrows.getChildren().toArray();
		for(i=0; i<rwcs.length; i++)
		{
			orw = rwcs[i].getChildren().toArray();
			for(j=0; j<orw.length; j++)
			{
				icm = orw[j];
				if(icm instanceof Textbox || ics instanceof Combobox) icm.setValue("");
				if(icm instanceof Listbox) icm.setSelectedIndex(0);
			}
		}
	}

	public void setAppendID(String iwhat)
	{
		append_id = iwhat;
	}

	public void startElement(String s, String s1, String elementName, Attributes attributes) throws SAXException
	{
		boolean gotattrib = false;
		if(attributes.getLength() != 0) gotattrib = true;
		Component whatobj = null;
		Component myparent = null;
		String[] strarray;

		if(elementName.equalsIgnoreCase("theform")) // magic starts
		{
			formgrid = new Grid();

			fwidth = attributes.getValue("width");
			if(fwidth != null) formgrid.setWidth(fwidth);

			if(!formid.equals("")) formgrid.setId(formid);

			gridrows = new org.zkoss.zul.Rows();
			gridrows.setParent(formgrid);
		}

		if(elementName.equalsIgnoreCase("header"))
		{
			ftitle = attributes.getValue("title");
			ftstyle = attributes.getValue("titlestyle");
			fstyle = attributes.getValue("style");
			fspans = attributes.getValue("spans");

			org.zkoss.zul.Row titrow = new org.zkoss.zul.Row();
			titrow.setStyle( (fstyle == null) ? "" : fstyle );
			titrow.setSpans( (fspans == null) ? "" : fspans );

			titlabel = new Label();
			titlabel.setValue( (ftitle == null) ? "" : ftitle );
			titlabel.setStyle( (ftstyle == null) ? "" : ftstyle );
			titlabel.setParent(titrow);

			titrow.setParent(gridrows);
		}

		if(elementName.equalsIgnoreCase("row"))
		{
			cnewrow = new org.zkoss.zul.Row();
			if(gotattrib)
			{
				spanstring = attributes.getValue("spans");
				if(spanstring != null) cnewrow.setSpans(spanstring);
				stylestr = attributes.getValue("style");
				if(stylestr != null) cnewrow.setStyle(stylestr);
			}
		}

		myparent = cnewrow;

		if(elementName.equalsIgnoreCase("columns"))
		{
			gridcolumns = new org.zkoss.zul.Columns();
			whatobj = gridcolumns;
			myparent = formgrid;
		}

		if(elementName.equalsIgnoreCase("column"))
		{
			whatobj = new org.zkoss.zul.Column();
			myparent = gridcolumns;
		}

		if(elementName.equalsIgnoreCase("button"))
		{
			whatobj = new Button();
		}

		if(elementName.equalsIgnoreCase("textbox")) { whatobj = new Textbox(); whatobj.setDroppable("true"); }
		if(elementName.equalsIgnoreCase("label"))
		{
			cnewlabel = new Label();
			whatobj = cnewlabel;
		}

		if(elementName.equalsIgnoreCase("datebox"))
		{
			whatobj = new Datebox();
			whatobj.value = new Date();
		}

		if(elementName.equalsIgnoreCase("listbox"))
		{
			cnewlistbox = new Listbox();
			whatobj = cnewlistbox;
		}

		if(elementName.equalsIgnoreCase("listitem"))
		{
			cnewlistitem = new Listitem();
			whatobj = cnewlistitem;
			myparent = cnewlistbox;
		}

		if(elementName.equalsIgnoreCase("listcell"))
		{
			whatobj = new Listcell();
			myparent = cnewlistitem;
		}
		
		if(elementName.equalsIgnoreCase("radiogroup"))
		{
			cnewradiogroup = new Radiogroup();
			whatobj = cnewradiogroup;
		}
		
		if(elementName.equalsIgnoreCase("radio"))
		{
			whatobj = new Radio();
			myparent = cnewradiogroup;
		}
		
		if(elementName.equalsIgnoreCase("image"))
		{
			imgsrc = attributes.getValue("src");
			if(imgsrc != null)
			{
				whatobj = new Image();
				whatobj.setSrc(imgsrc);
			}
		}

		if(elementName.equalsIgnoreCase("combobox")) { whatobj = new Combobox(); whatobj.setDroppable("true"); }
		if(elementName.equalsIgnoreCase("checkboxes")) whatobj = new Vbox();

		if(whatobj != null)
		{
			// if type datebox, set the default format
			if(whatobj instanceof Datebox) whatobj.setFormat("yyyy-MM-dd");

			if(gotattrib)
			{
				theid = attributes.getValue("id");
				if(theid != null)
				{
					// append-id if available
					if(!append_id.equals("")) theid += append_id;
					whatobj.setId(theid);
					// store into hashmap for use later
					theid_checkstring = attributes.getValue("checkstr");
					if(theid_checkstring != null) localhashmap.put(theid_checkstring, new String(theid) );
				}
				
				theval = attributes.getValue("tabindex");
				if(theval != null) whatobj.setTabindex(Integer.parseInt(theval));
				
				theval = attributes.getValue("onClick");
				if(theval != null)
				{
					// something..
				}

				theval = attributes.getValue("value");
				if(theval != null) whatobj.setValue(theval);

				thestyle = attributes.getValue("style");
				if(thestyle != null) whatobj.setStyle(thestyle);

				themulti = attributes.getValue("multiline");
				if(themulti != null) whatobj.setMultiline(true);

				thewidth = attributes.getValue("width");
				if(thewidth != null) whatobj.setWidth(thewidth);

				theheight = attributes.getValue("height");
				if(theheight != null) whatobj.setHeight(theheight);

				themold = attributes.getValue("mold");
				if(themold != null) whatobj.setMold(themold);
				
				thelabel = attributes.getValue("label");
				if(thelabel != null) whatobj.setLabel(thelabel);

				therows = attributes.getValue("rows");
				if(therows != null) whatobj.setRows(Integer.parseInt(therows));
				
				thedisabled = attributes.getValue("disabled");
				if(thedisabled != null) whatobj.setDisabled(true);

				thecolumn = attributes.getValue("column");
				thetitle = (attributes.getValue("title") == null) ? "" : attributes.getValue("title");
				thetitlestyle = (attributes.getValue("titlestyle") == null) ? "" : attributes.getValue("titlestyle");
				
				thesizable = attributes.getValue("sizable");
				if(thesizable != null) whatobj.setSizable( (thesizable.equals("true")) ? true : false );
				
				thevalign = attributes.getValue("valign");
				if(thevalign != null) whatobj.setValign(thevalign);

				// for listitem - get items from lookup table
				thelookup = attributes.getValue("lookup");
				if(thelookup != null)
				{
					if(whatobj instanceof Listbox) luhand.populateListbox_ByLookup(whatobj,thelookup,2);

					// h/vbox checkboxes
					if(whatobj instanceof Vbox || whatobj instanceof Hbox)
					{
						if(thecolumn == null) luhand.populateCheckbox_ByLookup(whatobj,thelookup,thestyle,2);
						if(thecolumn != null)
						{
							whatobj = new Div();
							if(theid != null) whatobj.setId(theid);
							luhand.drawMultiColumnTickboxes_2(thelookup,whatobj,theid,
							Integer.parseInt(thecolumn),thestyle,thetitle,thetitlestyle);
						}
					}

					// combobox with lookups
					if(whatobj instanceof Combobox && thelookup != null)
					{
						strarray = luhand.getLookupChildItems_StringArray(thelookup,2);
						gridhand.makeComboitem(whatobj,strarray);
					}

					// radiogroup with lookups and not multi-column
					if(whatobj instanceof Radiogroup)
					{
						if(thelookup != null && thecolumn == null)
						{
							strarray = luhand.getLookupChildItems_StringArray(thelookup,2);
							for(int i=0; i<strarray.length; i++)
							{
								rlabel = strarray[i];
								Radio cradio = new Radio();
								cradio.setLabel(rlabel);
								if(thestyle != null) cradio.setStyle(thestyle);
								cradio.setParent(whatobj);
							}
						}

						if(thelookup != null && thecolumn != null)
						{
							luhand.drawMultiColumnRadios(thelookup,whatobj,theid,Integer.parseInt(thecolumn),thestyle,thetitle,thetitlestyle);
						}
					}
				}
			}

			whatobj.setParent(myparent);
		}
	}

	public void endElement(String s, String s1, String elementName) throws SAXException
	{
		if(elementName.equalsIgnoreCase("theform")) formgrid.setParent(formholder);
		if(elementName.equalsIgnoreCase("row")) cnewrow.setParent(gridrows);
		if(elementName.equalsIgnoreCase("label"))
		{
			if(tmpValue.indexOf(":::") != -1)
			{
				cnewlabel.setMultiline(true);
				tmpValue = tmpValue.replace(":::","\n");
				cnewlabel.setValue(tmpValue);
			}
		}
	}

	public void characters(char[] ac, int i, int j) throws SAXException
	{
		tmpValue = new String(ac,i,j);
	}
}

public class vicFormMaker
{
	private Div formholder;
	private String formid;
	private String thexmlstring;
	private boolean removeprevious;
	private String appendid;

	public FormXMLSplicer wolipar;

	ListboxHandler lbhand;
	LookupFuncs luhand;
	GridHandler gridhand;

	HashMap thehashmap;

	public vicFormMaker(Div iholder, String iformid, String ixmlstring)
	{
		formholder = iholder;
		formid = iformid;
		thexmlstring = ixmlstring.replace("\n","");
		removeprevious = true;
		appendid = "";

		lbhand = new ListboxHandler();
		luhand = new LookupFuncs();
		gridhand = new GridHandler();
	}

	public void setRemovePreviousForm(boolean iwhat)
	{
		removeprevious = iwhat;
	}

	public void setAppendID(String iwhat)
	{
		appendid= iwhat;
	}

	public void setXMLString(String ixmlstring)
	{
		thexmlstring = ixmlstring.replace("\n","");
	}

	public void removeForm()
	{
		reuseit = formholder.getFellowIfAny(formid);
		if(reuseit != null) reuseit.setParent(null); // remove prev form
	}

	public void generateForm()
	{
		Component reuseit;

		if(removeprevious)
		{
			reuseit = formholder.getFellowIfAny(formid);
			if(reuseit != null) reuseit.setParent(null); // remove prev form
		}

		//FormXMLSplicer wolipar = new FormXMLSplicer(formholder,formid);
		wolipar = new FormXMLSplicer(formholder,formid);
		if(!appendid.equals("")) wolipar.setAppendID(appendid);

		SAXParserFactory factory = SAXParserFactory.newInstance();

		SAXParser parser = factory.newSAXParser();
		try
		{
			InputSource inpsr = new InputSource(new StringReader(thexmlstring));
			//alert(wolipar + " == " + inpsr);
			parser.parse(inpsr,wolipar);
			thehashmap = wolipar.localhashmap;
		}
		catch (ParserConfigurationException e) {}
		catch (SAXException e) {}
		catch (IOException e) {}
		//catch (NullPointerException e) {alert("runcount: " + wolipar.retruncount());}
	}

	// Generate a huge string of the form input components by id and delimited
	// format of frozen input = "component-id"|"whatever input, could be ticked-boxes text"::
	// :: = separator, data must be enclosed in " and " in input will be replaced by `
	// ticked item separated by ~ within the input-data
	// input string will be trimmed
	public String freezeFormValues() throws NullPointerException
	{
		String retval = "";
		String compid = "";
		String inputstring = "";
		boolean addme = false;
		java.util.List trows;
		Component tgr;

		SimpleDateFormat sdformat = new SimpleDateFormat("yyyy-MM-dd");

		tgr = formholder.getFellowIfAny(formid);
		if(tgr == null) return retval;
		trows = tgr.getChildren().get(0).getChildren(); // sorta hard-coded to get <rows> children

		for(Component dpi : trows)
		{
			java.util.List rowchis = dpi.getChildren();

			for(Component kki : rowchis)
			{
				compid = kki.getId();
				inputstring = "";
				addme = false;

			try
			{
				if(kki instanceof Textbox)
				{
					inputstring = kki.getValue().trim();
					inputstring = inputstring.replace("\"","`").replace("|","_").replace("~","_").replace("::","__");
					addme = true;
				}

				if(kki instanceof Listbox)
				{
					if(kki.getSelectedIndex() != -1)
					{
						inputstring = kki.getSelectedItem().getLabel();
						addme = true;
					}
				}

				if(kki instanceof Datebox)
				{
					Date dval = kki.getValue();
					inputstring = sdformat.format(dval);
					addme = true;
				}

				// for checkboxes 2 types of saving - usual div/vbox/hbox and the multicolumn div-grid-based !!
				if(kki instanceof Vbox || kki instanceof Hbox)
				{
					inputstring = luhand.saveCheckboxTicked(kki);
					addme = true;
				}

				// TODO: hard-coded to find checkboxes, Div could be holder for other components in future
				if(kki instanceof Div)
				{
					// kludgy-code
					kaka = kki.getChildren().get(0).getChildren().get(0).getChildren().toArray();

					for(int i=0;i<kaka.length;i++)
					{
						String miks = luhand.saveCheckboxTicked(kaka[i]);
						if(miks.length() > 0) inputstring += miks + "~";
					}
					addme = true;
				}

				if(kki instanceof Radiogroup)
				{
					if(kki.getSelectedItem() != null)
					{
						inputstring = kki.getSelectedItem().getLabel();
						addme = true;
					}
				}

				if(addme)
				{
					retval += "\"" + compid + "\"|\"" + inputstring + "\"::";
				}

			} // try
			catch (NullPointerException e) {}

			}
		}

		return retval;
	}

	// Populate form input components from data(retrieve from DB - outside func, or file or anything) passed.
	// population based on component-id map to data->fieldname
	// 02/08/2012: can use GroovyRowResult, Hashmap and String for ifieldmaps, String = generated by freezeFormValues()
	public void populateFormValues(Object ifieldmaps)
	{
		Object formdata;
		Object themaps;
		String compid, tmpstr, fieldpart, datapart;
		String[] irecs, iparts;
		HashMap myhmap;

		// if form-values passed as string(generated by freezeFormValues()) , convert to hashmap
		if(ifieldmaps instanceof String && !ifieldmaps.equals(""))
		{
			myhmap = new HashMap();
			irecs = ifieldmaps.split("::"); // split by ::
			for(int i=0; i<irecs.length; i++)
			{
				tmpstr = irecs[i];
				iparts = tmpstr.split("\\|"); // split the field and data parts
				fieldpart = iparts[0].replace("\"","");
				datapart = iparts[1].replace("\"","");
				//alert(fieldpart + " = " + datapart);
				myhmap.put(fieldpart,datapart);
			}
		}

		themaps = ifieldmaps;
		if(ifieldmaps instanceof String) { themaps = myhmap; }

		Component tgr = formholder.getFellowIfAny(formid);
		if(tgr == null) return;

		// go through the form components and populate
		trows = tgr.getChildren().get(0).getChildren(); // sorta hard-coded to get <rows> children

		for(Component dpi : trows)
		{
			java.util.List rowchis = dpi.getChildren();
			for(Component kki : rowchis)
			{
				try
				{
					formdata = null;
					compid = kki.getId();
					formdata = themaps.get(compid);

					if(kki instanceof Textbox || kki instanceof Combobox || kki instanceof Datebox)
					{
						// if date is string, must parse to Date before setting Datebox
						if(kki instanceof Datebox && formdata instanceof String)
						{
							SimpleDateFormat sdformt = new SimpleDateFormat("yyyy-MM-dd",Locale.ROOT);
							Date prsdate = sdformt.parse(formdata);
							kki.setValue(prsdate);
						}
						else
						if(formdata != null) kki.setValue(formdata);
					}

					if(kki instanceof Listbox) lbhand.matchListboxItems(kki,formdata);

					// checkboxes maybe..
					if(kki instanceof Vbox || kki instanceof Hbox) luhand.tickCheckboxes(kki,formdata);

					//  multi-column checkboxes
					if(kki instanceof Div)
					{
						kaka = kki.getChildren().get(0).getChildren().get(0).getChildren().toArray(); // bad hard-coded thing
						for(int i=0;i<kaka.length;i++)
						{
							luhand.tickCheckboxes(kaka[i],formdata);
						}
					}

					if(kki instanceof Radiogroup)
					{
						try
						{
						kaka = kki.getChildren().get(0).getChildren().get(0).getChildren().toArray();
						for(int i=0;i<kaka.length;i++)
						{
							luhand.tickRadioButton(kaka[i],formdata);
						}
						} catch (IndexOutOfBoundsException e)
						{
							luhand.tickRadioButton(kki,formdata);
						}
					}
				}
				catch (MissingPropertyException e) {}
				catch (NullPointerException e) {}
			}
		}
	}
}

/**
 * Take note of rlmsql.gpWMS_FirstRow() - change this to point to different database
 * @param  iformholder [description]
 * @param  iformid     [description]
 * @param  idbformid   [description]
 * @return             [description]
 */
vicFormMaker dynamicForm(Div iformholder, String iformid, String idbformid) 
{
	sqlstm = "select * from elb_FormKeeper where origid=" + idbformid;
	fmobj = gpWMS_FirstRow(sqlstm);
	formxml = fmobj.get("xmlformstring"); //sqlhand.clobToString(fmobj.get("xmlformstring"));
	vicFormMaker retobj = new vicFormMaker(iformholder,iformid,formxml);
	retobj.generateForm();
	return retobj;
}
