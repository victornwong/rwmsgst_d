/*
03/04/2012: moved some db-funcs to DocuFuncs.java for byte-compl
*/
import java.io.*;
import org.victor.*;

String[] doculink_status = { "ACTIVE", "PENDING" , "EXPIRED" };

public class documentLinkObj
{
	public String global_doculink_origid;
	public String global_eq_origid;
	public String document_idprefix;
	public Object refreshListbox;

	public documentLinkObj()
	{
		global_doculink_origid = "";
		global_eq_origid = "";
	}
}

void setDocumentLink_DynamicProperty(Include whichinc, Object iwhich, Object userobj)
{
	sechand = new SecurityFuncs();
	whichinc.setDynamicProperty("doculink_property", iwhich);
	sechand.setUserAccessObj(whichinc, userobj);
}

Object getDocumentLink_DynamicProperty()
{
	return Executions.getCurrent().getAttribute("doculink_property");
}

// To store uploaded file into database.
// params: iusername, ibranch - from useraccessobj, to have an owner to document
//		idocdate = document upload date - should be today
//		doculink_str = document id prefix + whatever
//		docustatus_str = active,expired or whatever.. can be def in drop-down
boolean uploadLinkingDocument(String iusername, String ibranch, String idocdate, String doculink_str, String docustatus_str,String ftitle, String fdesc)
{
	sqlhand = new SqlFuncs();
	guihand = new GuiFuncs();

	uploaded_file = Fileupload.get(true);
	if(uploaded_file == null) return false;
	formatstr = uploaded_file.getFormat();
	contenttype = uploaded_file.getContentType();
	ufilename = uploaded_file.getName();
	Object uploaded_data;
	fileLength = 0;

	// 16/10/2012: truncate contenttype
	if(contenttype.length() > 50) contenttype = contenttype.substring(0,50);
	if(ufilename.length() > 50) ufilename = ufilename.substring(0,50);

	f_inmemory = uploaded_file.inMemory();
	f_isbinary = uploaded_file.isBinary();

	if(f_inmemory && f_isbinary)
	{
		uploaded_data = uploaded_file.getByteData();
	}

	if(!f_inmemory && f_isbinary)
	{
	/*
		InputStream inp = uploaded_file.getStreamData();
		fileLength = inp.available();
		ByteArrayOutputStream buffer = new ByteArrayOutputStream();

		int nRead;
		byte[] data = new byte[fileLength];

		while ((nRead = inp.read(data, 0, data.length)) != -1)
		{
			buffer.write(data, 0, nRead);
		}
		buffer.flush();
		uploaded_data = buffer.toByteArray();
	*/
		inp = uploaded_file.getStreamData();
		fileLength = inp.available();
		uploaded_data = new byte[fileLength];
		retl = inp.read(uploaded_data,0,fileLength);
	}

	if(uploaded_data == null)
	{
		guihand.showMessageBox("Invalid file-type uploaded..");
		return false;
	}

	ds_sql = sqlhand.als_DocumentStorage();
	if(ds_sql == null) return false;

	thecon = ds_sql.getConnection();

	//todaydate = getDateFromDatebox(ihiddendatebox);
	//ftitle = fileupl_file_title.getValue();
	//fdesc = fileupl_file_description.getValue();
	// doculink_str = EQID_PREFIX + doculink_prop.global_eq_origid;
	//doculink_str = doculink_prop.document_idprefix + doculink_prop.global_eq_origid;
	//docustatus_str = fileupl_docu_status.getSelectedItem().getLabel();

	pstmt = thecon.prepareStatement(
	"insert into DocumentTable(file_title,file_description,docu_link,docu_status,username,datecreated,version," +
	"file_name,file_type,file_extension,file_data,deleted,branch) values (?,?,?,?,?,?,?,?,?,?,?,?,?)"
	);

	pstmt.setString(1, ftitle);
	pstmt.setString(2, fdesc);
	pstmt.setString(3, doculink_str);
	pstmt.setString(4, docustatus_str);
	pstmt.setString(5, iusername);
	pstmt.setString(6,idocdate);
	pstmt.setInt(7,1);
	pstmt.setString(8,ufilename);
	pstmt.setString(9,contenttype);
	pstmt.setString(10,formatstr);
	pstmt.setBytes(11, uploaded_data);
	pstmt.setInt(12,0); // deleted flag
	pstmt.setString(13, ibranch);
	pstmt.executeUpdate();
	ds_sql.close();
	return true;
}
