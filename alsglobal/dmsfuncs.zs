/*
// a knockoff from lookuptree.zs
class directoryTree
{
	Treechildren tobeshown;
	Sql mainSql;

	void directoryTree(Treechildren thechild, String iparentid)
	{
		mainSql = DMS_Sql();
		if(mainSql == NULL) return;

		sqlstatement = "select origid,folderid,folder_desc from folderstructure where deleted=0 and folderparent=" + iparentid;
		List catlist = mainSql.rows(sqlstatement);
		tobeshown = thechild;
		fillMyTree(thechild, catlist);
		mainSql.close();
	}

	void fillMyTree(Treechildren tchild, List prolist)
	{
		for (opis : prolist)
		{
			Treeitem titem = new Treeitem();
			Treerow newrow = new Treerow();

			Treecell newcell1 = new Treecell();
			Treecell newcell2 = new Treecell();
			Treecell newcell3 = new Treecell();

			thisbranchid = opis.get("origid").toString();
			folderid = opis.get("folderid");
			if(folderid.length() > 40) folderid = folderid.substring(0,38) + "..";

			folderdesc = opis.get("folder_desc");
			if(folderdesc.length() > 30) folderdesc = folderdesc.substring(0,28) + "..";

			sqlqueryline = "select origid,folderid,folder_desc from folderstructure where folderparent=" + thisbranchid;
			List subchild = mainSql.rows(sqlqueryline);

			highlite = false;

			if(subchild.size() > 0)
			{
				Treechildren newone = new Treechildren();
				newone.setParent(titem);
				fillMyTree(newone,subchild);
				highlite = true;
				//newcell1.setLabel("${subchild.size()} ${opis[2]}");
			}

			newcell3.setVisible(false);
			newcell3.setLabel(thisbranchid);

			itmstyle = "font-size:9px";
			if(highlite) itmstyle += ";background:#99AA88";

			newcell1.setLabel(folderid);
			newcell1.setStyle(itmstyle);
			newcell1.setDraggable("treedrop");

			newcell2.setLabel(folderdesc);
			newcell2.setStyle("font-size:9px");

			newcell1.setParent(newrow);
			newcell2.setParent(newrow);
			newcell3.setParent(newrow);
			newrow.setParent(titem);
			titem.setParent(tchild);
		}
	}
}
// end of class directoryTree

void showSubdirectoryTree(String parentname, Tree thetree)
{
	// Clear any child attached to tree before updating new ones.
	Treechildren tocheck = thetree.getTreechildren();
	if(tocheck != null) tocheck.setParent(null);

	// create a new treechildren for the tree
	Treechildren mychildrens = new Treechildren();
	mychildrens.setParent(thetree);

	subdirectory_tree.setRows(15);

	// Load the lookuptree from database
	directoryTree incd_lookuptree = new directoryTree(mychildrens,parentname);
}
*/
/*
// DBFunc: insert new directory into folderstructure
boolean insertNewDirectory(String iname, String imyparent, String idate)
{
	sql = DMS_Sql();
	if(sql == null) return false;
	sqlstm = "insert into folderstructure (folderid,datecreated,folderstatus,folderparent,folder_desc," + 
	"username,minlevelaccess,deleted,search_keywords) " +
	"values ('" + iname + "','" + idate + "','ACTIVE'," + imyparent + ",'','" + useraccessobj.username + "',1,0,'')";
	sql.execute(sqlstm);
	sql.close();
	return true;
}

// DBFunc: get directory rec from folderstructure
Object getDirectoryRec(String iorigid)
{
	sql = DMS_Sql();
	if(sql == null) return null;
	sqlstm = "select * from folderstructure where origid=" + iorigid;
	retval = sql.firstRow(sqlstm);
	sql.close();
	return retval;
}

// DBFunc: check if there's a branch attached to folder-rec
boolean existBranch(String iorigid)
{
	retval = false;
	sql = DMS_Sql();
	if(sql == null) return retval;
	sqlstm = "select top 1 origid from folderstructure where folderparent=" + iorigid;
	trec = sql.firstRow(sqlstm);
	sql.close();
	if(trec != null) retval = true;
	return retval;
}

// knockoff from doculink_funcs.zs - modded to work on different db
// To store uploaded file into database.
// params: iusername, ibranch - from useraccessobj, to have an owner to document
//		idocdate = document upload date - should be today
//		doculink_str = document id prefix + whatever
//		docustatus_str = active,expired or whatever.. can be def in drop-down
boolean uploadFile(String iusername, String ibranch, String idocdate, String doculink_str, String docustatus_str,String ftitle, String fdesc)
{
	uploaded_file = Fileupload.get(true);
	
	if(uploaded_file == null) return false;
	
	formatstr = uploaded_file.getFormat();
	contenttype = uploaded_file.getContentType();
	ufilename = uploaded_file.getName();
	
	Object uploaded_data;
	int fileLength = 0;
	
	f_inmemory = uploaded_file.inMemory();
	f_isbinary = uploaded_file.isBinary();
	
	if(f_inmemory && f_isbinary)
	{
		uploaded_data = uploaded_file.getByteData();
	}
	else
	{
		uploaded_data = uploaded_file.getStreamData();
		fileLength = uploaded_data.available(); 
	}
	
	if(uploaded_data == null)
	{
		showMessageBox("Invalid file-type uploaded..");
		return;
	}
	
	// alert("formatstr: " + formatstr + " | contenttype: " + contenttype + " | filename: " + ufilename);
		
	ds_sql = DMS_Sql();
	if(ds_sql == NULL) return;
	
	thecon = ds_sql.getConnection();

	pstmt = thecon.prepareStatement("insert into DocumentTable(file_title,file_description,docu_link,docu_status,username,datecreated,version," +
		"file_name,file_type,file_extension,file_data,deleted,branch) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");

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

	if(f_inmemory && f_isbinary)
		pstmt.setBytes(11, uploaded_data);
	else
		pstmt.setBinaryStream(11, uploaded_data, fileLength);

	pstmt.setInt(12,0); // deleted flag
	pstmt.setString(13, ibranch);

	pstmt.executeUpdate();
	ds_sql.close();
	
	return true;
}
*/
