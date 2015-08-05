import java.io.*;
import java.util.*;
import java.text.*;
import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;

/*
Title: Email shortcut functions based on javax.mail
Written by : Victor Wong
Date : 4/8/2010

Design notes:
*/

// Simple email sendout func - no attachments
// return 0 = sent, else not
int simpleSendEmail(String ismtpserver, String ifrom, String ito, String isubj, String imessage)
{
	retval = 0;

	Properties props = new Properties();
	props.put("mail.smtp.host", ismtpserver);
	props.put("mail.from", ifrom);
	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, null);

	try
	{
    MimeMessage msg = new MimeMessage(mailsession);
    msg.setFrom();
    msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		// create and fill the first message part
		MimeBodyPart mbp1 = new MimeBodyPart();
		//mbp1.setHeader("Content-Type","text/html");
		mbp1.setText(imessage);

		// create the Multipart and add its parts to it - check in purchasereq_driller.zul, can attach file too!!
		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		// add the Multipart to the message
		msg.setContent(mp);

		Transport.send(msg);

	} catch (MessagingException mex)
	{
		retval = 1;
		//System.out.println("send failed, exception: " + mex);
	}
	
	return retval;
}

// Simple email sendout func - html
int simpleSendEmail_HTML(String ismtpserver, String ifrom, String ito, String isubj, String imessage)
{
	retval = 0;

	Properties props = new Properties();
	props.put("mail.smtp.host", ismtpserver);
	props.put("mail.from", ifrom);
	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, null);

	try
	{
        MimeMessage msg = new MimeMessage(mailsession);
        msg.setFrom();
        msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		// create and fill the first message part
		/*
		MimeBodyPart mbp1 = new MimeBodyPart();
		//mbp1.setHeader("Content-Type","text/html");
		mbp1.setText(imessage);

		// create the Multipart and add its parts to it - check in purchasereq_driller.zul, can attach file too!!
		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);
		*/

		// add the Multipart to the message
		msg.setContent(imessage,"text/html");

		Transport.send(msg);

	} catch (MessagingException mex)
	{
		retval = 1;
		//System.out.println("send failed, exception: " + mex);
	}
	
	return retval;
}

// Send email + attachements - attachments are store on local file system and filenames in ifnames[]
int sendEmailWithAttachment(String ismtpserver, String ifrom, String ito, String isubj, String imessage, String[] ifnames)
{
	retval = 0;

	Properties props = new Properties();
	props.put("mail.smtp.host", ismtpserver);
	props.put("mail.from", ifrom);
	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, null);

	try
	{
        MimeMessage msg = new MimeMessage(mailsession);
        msg.setFrom();
        msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		// create and fill the first message part
		MimeBodyPart mbp1 = new MimeBodyPart();
		mbp1.setText(imessage);

		// create the Multipart and add its parts to it - check in purchasereq_driller.zul, can attach file too!!
		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		// add the Multipart to the message
		msg.setContent(mp);

		// Loop through ifnames[] and attach the files
		for(i=0; i<ifnames.length; i++)
		{
			MimeBodyPart filepart = new MimeBodyPart();
			FileDataSource fds = new FileDataSource(ifnames[i]);
			filepart.setDataHandler(new DataHandler(fds));
			filepart.setFileName(fds.getName());
			mp.addBodyPart(filepart);
		}

		Transport.send(msg);

	} catch (MessagingException mex)
	{
		retval = 1;
		//System.out.println("send failed, exception: " + mex);
	}

	return retval;
}

class MS_MyAuth extends Authenticator
{
	public String ms_username;
	public String ms_password;

	void MS_MyAuth(String iusername, String ipassw)
	{
		ms_username = iusername;
		ms_password = ipassw;
	}

	protected PasswordAuthentication getPasswordAuthentication()
	{
		return new PasswordAuthentication(ms_username,ms_password);
	}
}

boolean simpleSendemail_MSEX(String ismtp, String iusername, String ipwd, String ifrom, String ito, String isubj, String imessage)
{
	retval = false;

	Properties props = new Properties();
	props.put("mail.smtp.host", ismtp);
	props.put("mail.smtp.auth", "true");
	props.put("mail.imap.auth.plain.disable","true");
	props.put("mail.debug", "true");
	props.put("mail.smtp.port", "25");
	props.put("mail.from", ifrom);

	//props.put("mail.smtp.starttls.enable", "true");
	//props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");

	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, new MS_MyAuth(iusername,ipwd) );

	try
	{
		MimeMessage msg = new MimeMessage(mailsession);
		msg.setFrom();
		//javax.mail.internet.InternetAddress[] address = {new javax.mail.internet.InternetAddress("wongvictor1998@gmail.com")};
		msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		// create and fill the first message part
		MimeBodyPart mbp1 = new MimeBodyPart();
		//mbp1.setHeader("Content-Type","text/html");
		mbp1.setText(imessage);

		// create the Multipart and add its parts to it - check in purchasereq_driller.zul, can attach file too!!
		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		// add the Multipart to the message
		msg.setContent(mp);
		Transport.send(msg);

		retval = true;
	}
	catch (MessagingException e) { alert("ERR: " + e); }

	return retval;
}

boolean MS_sendEmailWithAttachment(String ismtp, String iusername, String ipwd, 
	String ifrom, String ito, String isubj, String imessage, String[] ifnames)
{
	retval = false;
	
	Properties props = new Properties();
	props.put("mail.smtp.host", ismtp);
	props.put("mail.smtp.auth", "true");
	props.put("mail.imap.auth.plain.disable","true");
	props.put("mail.debug", "true");
	props.put("mail.smtp.port", "25");
	props.put("mail.from", ifrom);
	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, new MS_MyAuth(iusername,ipwd) );

	try
	{
		MimeMessage msg = new MimeMessage(mailsession);
		msg.setFrom();
		msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		// create and fill the first message part
		MimeBodyPart mbp1 = new MimeBodyPart();
		mbp1.setText(imessage);

		// create the Multipart and add its parts to it - check in purchasereq_driller.zul, can attach file too!!
		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		// add the Multipart to the message
		msg.setContent(mp);

		// Loop through ifnames[] and attach the files
		for(i=0; i<ifnames.length; i++)
		{
			MimeBodyPart filepart = new MimeBodyPart();
			FileDataSource fds = new FileDataSource(ifnames[i]);
			filepart.setDataHandler(new DataHandler(fds));
			filepart.setFileName(fds.getName());
			mp.addBodyPart(filepart);
		}

		Transport.send(msg);
		retval = true;
	} catch (MessagingException mex) { alert("ERR: " + mex); }

	return retval;
}

// Codes to use GMAIL smtp server
// gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, "victor@rentwise.com","RE: TESTING gmailsend","Just testing..");
boolean gmail_sendEmail(String ismtp, String iusername, String ipwd, String ifrom, String ito, String isubj, String imessage)
{
	retval = false;

	Properties props = new Properties();
	props.put("mail.smtp.auth", "true");
	props.put("mail.smtp.starttls.enable", "true");
	props.put("mail.smtp.host", "smtp.gmail.com");
	props.put("mail.smtp.port", "587");

	//props.put("mail.smtp.starttls.enable", "true");
	//props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");

	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, new MS_MyAuth(iusername,ipwd) );

	try
	{
		MimeMessage msg = new MimeMessage(mailsession);
		msg.setFrom(new InternetAddress(ifrom));
		//javax.mail.internet.InternetAddress[] address = {new javax.mail.internet.InternetAddress("wongvictor1998@gmail.com")};
		msg.setRecipients(Message.RecipientType.TO,ito);
		msg.setSubject(isubj);
		msg.setSentDate(new Date());

		MimeBodyPart mbp1 = new MimeBodyPart();
		//mbp1.setHeader("Content-Type","text/html");
		mbp1.setText(imessage);

		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);
		msg.setContent(mp);
		Transport.send(msg);
		retval = true;
	}
	catch (MessagingException e) { alert("ERR: " + e); }

	return retval;
}

boolean gmail_sendEmailWithAttachment(String ismtp, String iusername, String ipwd, 
	String ifrom, String ito, String isubj, String imessage, String[] ifnames)
{
	retval = false;
	Properties props = new Properties();
	props.put("mail.smtp.auth", "true");
	props.put("mail.smtp.starttls.enable", "true");
	props.put("mail.smtp.host", "smtp.gmail.com");
	props.put("mail.smtp.port", "587");

	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, new MS_MyAuth(iusername,ipwd) );

	try {

        MimeMessage msg = new MimeMessage(mailsession);
		msg.setFrom(new InternetAddress(ifrom));
		msg.setRecipients( Message.RecipientType.TO, ito );
		msg.setSubject(isubj);
		//msg.setReplyTo(Address[] addresses)
		msg.setSentDate(new Date());

		MimeBodyPart mbp1 = new MimeBodyPart();
		mbp1.setText(imessage);

		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		msg.setContent(mp);

		// Loop through ifnames[] and attach the files
		for(i=0; i<ifnames.length; i++)
		{
			MimeBodyPart filepart = new MimeBodyPart();
			FileDataSource fds = new FileDataSource(ifnames[i]);
			filepart.setDataHandler(new DataHandler(fds));
			filepart.setFileName(fds.getName());
			mp.addBodyPart(filepart);
		}

		Transport.send(msg);
		retval = true;

	} catch (MessagingException mex) {
		alert("ERR: " + mex);
	}
	
	return retval;
}

boolean gmail_sendEmailWithAttachment_2(String ismtp, String iusername, String ipwd, 
	String ifrom, String ito, String isubj, String imessage, String[] ifnames, String ireplyto)
{
	retval = false;
	Properties props = new Properties();
	props.put("mail.smtp.auth", "true");
	props.put("mail.smtp.starttls.enable", "true");
	props.put("mail.smtp.host", "smtp.gmail.com");
	props.put("mail.smtp.port", "587");
	
	javax.mail.Session mailsession = javax.mail.Session.getInstance(props, new MS_MyAuth(iusername,ipwd) );

	try {
        MimeMessage msg = new MimeMessage(mailsession);
		msg.setFrom(new InternetAddress(ifrom));
		msg.setRecipients( Message.RecipientType.TO, ito );
		msg.setSubject(isubj);

		Address[] kreplyto = { new InternetAddress(ireplyto) };
		msg.setReplyTo(kreplyto);

		msg.setSentDate(new Date());

		MimeBodyPart mbp1 = new MimeBodyPart();
		//mbp1.setText(imessage);
		mbp1.setContent(imessage,"text/html;charset=utf-8");

		Multipart mp = new MimeMultipart();
		mp.addBodyPart(mbp1);

		msg.setContent(mp);

		// Loop through ifnames[] and attach the files
		for(i=0; i<ifnames.length; i++)
		{
			MimeBodyPart filepart = new MimeBodyPart();
			FileDataSource fds = new FileDataSource(ifnames[i]);
			filepart.setDataHandler(new DataHandler(fds));
			filepart.setFileName(fds.getName());
			mp.addBodyPart(filepart);
		}

		Transport.send(msg);
		retval = true;

	} catch (MessagingException mex) {
		alert("ERR: " + mex);
	}
	
	return retval;
}
