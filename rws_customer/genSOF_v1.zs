// Generate Service Order Form (SOF) v1 .. HARDCODED stuff mostly to inject data into template PDF
import java.util.*;
import java.text.*;
import java.lang.Float;
import java.awt.Color;
import java.io.FileOutputStream;

import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;

import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import org.victor.*;

SOF_TEMPLATE_FN = "rwimg/service_order_v1.pdf";

void genServiceOrderFormPdf(String itick)
{
	if(itick.equals("")) return;
	htr = getHelpTicket_rec(glob_selected_ticket);
	if(htr == null)
	{
		guihand.showMessageBox("ERR: cannot access helptickets table..");
		return;
	}

	templatefn = session.getWebApp().getRealPath(SOF_TEMPLATE_FN);
	fncm = "SERVICEORDER_" + glob_selected_ticket + ".pdf";
	outfn = session.getWebApp().getRealPath(TEMPFILEFOLDER + fncm);

	PdfReader pdfReader = new PdfReader(templatefn);
	PdfStamper pdfStamper = new PdfStamper(pdfReader,new FileOutputStream(outfn));
	//BaseFont bf_helv = BaseFont.createFont(BaseFont.COURIER, BaseFont.CP1257, BaseFont.EMBEDDED); // "Cp1252"
	BaseFont bf_helv = BaseFont.createFont();
	PdfContentByte cb = pdfStamper.getUnderContent(1);

	pageheight = 820; // take pageheight-ypos

	/* hardcoded fields position
	customer : 92,65			address : 92,80
	contact person : 92,125		csv# : 440,63
	call date : 440,82			call time : 440,103
	attended by : 440,122		asset tage : 83,153
	s/n : 263,153				product name: 83,173
	fault descript: 83,190		remarks : 83,245
	work-performed : 83,297		chargeable : 83,355
	descript item/service : 20,400	unit price : 365,400
	qty : 460,400				total : 510,400
	*/
	SimpleDateFormat datefm = new SimpleDateFormat("yyyy-MM-dd");
	SimpleDateFormat timefm = new SimpleDateFormat("HH:mm");

	// TODO have to optimize these codes -- make into some general func

	com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
	ct.setSimpleColumn(
	new Phrase(
	new Chunk( kiboo.checkNullString(htr.get("cust_name")),
	FontFactory.getFont(FontFactory.HELVETICA, 9, Font.NORMAL) ) ),
	(float)360, (float)741, (float)92, (float)765, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
	ct.go();

	if(htr.get("cust_location") != null)
	{
		com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
		ct.setSimpleColumn(
		new Phrase(
		new Chunk( kiboo.checkNullString(htr.get("cust_location")),
		FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
		(float)360, (float)700, (float)92, (float)745, (float)9, Element.ALIGN_LEFT | Element.ALIGN_TOP);
		ct.go();
	}
	
	contp = htr.get("cust_caller") + " (" + htr.get("cust_caller_des") + ")" +
	"\n(Tel:" + htr.get("cust_caller_phone") + " Email: " + htr.get("cust_caller_email") + " )";
	com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
	ct.setSimpleColumn(
	new Phrase(
	new Chunk( contp,
	FontFactory.getFont(FontFactory.HELVETICA, 9, Font.NORMAL) ) ),
	(float)360, (float)665, (float)92, (float)710, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
	ct.go();

	cb.beginText();
	cb.setFontAndSize(bf_helv,8);

	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, htr.get("origid").toString(),440,757,0);
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, datefm.format(htr.get("calldatetime")),440,738,0);
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, timefm.format(htr.get("calldatetime")),440,717,0);
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, htr.get("createdby"),440,698,0);
	
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, htr.get("asset_tag"),83,667,0);
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, htr.get("serial_no"),263,667,0);
	cb.showTextAligned(PdfContentByte.ALIGN_LEFT, htr.get("product_name"),83,647,0);
	
	cb.endText();
	
	com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
	ct.setSimpleColumn(
	new Phrase(
	new Chunk( htr.get("problem"),
	FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
	(float)570, (float)590, (float)83, (float)635, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
	ct.go();

	com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
	ct.setSimpleColumn(
	new Phrase(
	new Chunk( htr.get("action"),
	FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
	(float)570, (float)535, (float)83, (float)580, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
	ct.go();

	kitems = htr.get("charge_items");
	kunitp = htr.get("charge_unitprice");
	kqtys = htr.get("charge_qty");

	// descript item/service : 20,400 unit price : 365,400 qty : 460,400 total : 510,400
	if(kitems != null)
	{
		itms = kitems.split("::");
		iup = kunitp.split("::");
		iqtys = kqtys.split("::");
		gtotal = 0;
		rowcnt = 0;

		for(i=1; i<5; i++)
		{
			cnt = i.toString();
			
			try
			{
				com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
				ct.setSimpleColumn(
				new Phrase(
				new Chunk(cnt + ". " + itms[i-1],
				FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
				(float)330, (float)370 - rowcnt, (float)20, (float)420 - rowcnt, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
				ct.go();
			}
			catch (Exception e) {}
			
			try
			{
				mqty = Float.parseFloat(iqtys[i-1]);
				com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
				ct.setSimpleColumn(
				new Phrase(
				new Chunk(nf2.format(mqty),
				FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
				(float)500, (float)370 - rowcnt, (float)460, (float)420 - rowcnt, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
				ct.go();
			}
			catch (Exception e) { mqty = 0; }
			
			try
			{
				mup = Float.parseFloat(iup[i-1]);
				com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
				ct.setSimpleColumn(
				new Phrase(
				new Chunk(nf2.format(mup),
				FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
				(float)450, (float)370 - rowcnt, (float)365, (float)420 - rowcnt, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
				ct.go();

				stot = mqty * mup;
				gtotal += stot;

				com.itextpdf.text.pdf.ColumnText ct = new ColumnText(cb);
				ct.setSimpleColumn(
				new Phrase(
				new Chunk(nf2.format(stot),
				FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL) ) ),
				(float)590, (float)370 - rowcnt, (float)510, (float)420 - rowcnt, (float)8, Element.ALIGN_LEFT | Element.ALIGN_TOP);
				ct.go();
			}
			catch (Exception e) {}

			rowcnt += 60;
		}

		cb.beginText();
		cb.showTextAligned(PdfContentByte.ALIGN_LEFT, "GRAND TOTAL : RM " + nf2.format(gtotal),430,190,0);
		chrgtxt = (gtotal > 0) ? "YES" : "NO";
		cb.showTextAligned(PdfContentByte.ALIGN_LEFT,chrgtxt,83,465,0);
		cb.endText();
	}

	pdfStamper.close();
}

