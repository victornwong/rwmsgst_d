/**
 * * Samples handling functions
 * 
 * @author Victor Wong
 * @since 14/04/2016
 */

Object[] sampleshds1 =
{
	new listboxHeaderWidthObj("NO.",true,"90px"),
	new listboxHeaderWidthObj("MARKING",true,""),
	new listboxHeaderWidthObj("NOTES",true,""),
};
SMP_INDEXNO = 0; SMP_MARKING = 1; SMP_NOTES = 2;

class sampleonselect implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException { samples_callBack(event.getReference()); }
}
sampleslb_onselect = new sampleonselect();

/**
 * Show samples tied to job-folder. Make this generic so a module can show multiple job-folders' samples listbox
 * @param pJn       the job-folder id
 * @param pHolder   DIV holder for listbox
 * @param pLbid     listbox ID
 * @param pLbheader listbox header defs
 * @param pRowcount how many rows for listbox
 */
void showJob_Samples(String pJn, Div pHolder, String pLbid, Object pLbheader, int pRowcount)
{
	Listbox newlb = lbhand.makeVWListbox_Width(pHolder, pLbheader, pLbid, pRowcount); // always start with empty samples listbox
	newlb.setCheckmark(true); newlb.setMultiple(true); newlb.addEventListener("onSelect", sampleslb_onselect);

	if(pJn.equals("")) return;
	sqlstm = "select samplemarking, extranotes, samp_index from JobSamples where jobfolders_id=" + pJn + " order by samp_index;";
	r = vsql_GetRows(sqlstm); if(r.size() == 0) return;
	ArrayList kabom = new ArrayList();
	String[] fl = { "samp_index", "samplemarking", "extranotes" };
	for(d : r)
	{
		ngfun.popuListitems_Data(kabom,fl,d);
		li = lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

/**
 * Save samples in listbox tie to job-folder. Assumming all sample-marking and whatever extra notes / instructions
 * have been entered
 * @param pJn     the parent job-folder no.
 * @param pSamplb samples listbox
 */
void saveFolder_Samples(String pJn, Listbox pSamplb)
{
	if(pJn.equals("")) return;
	renumberListbox(pSamplb,0,1,false); // re-number the samples list-box before saving it

	sqlstm = "delete from JobSamples where jobfolders_id=" + pJn;
	vsql_execute(sqlstm); // remove all samples before saving new ones
	kls = pSamplb.getItems().toArray();

	todaydate =  kiboo.todayISODateTimeString();
	Sql sql = v_Sql();
	Connection thecon = sql.getConnection();
	PreparedStatement pstmt = thecon.prepareStatement("insert into JobSamples (samplemarking,extranotes,jobfolders_id,status,samp_index) values " +
	"(?,?,?,'NEW',?);");

	for(i=0; i<kls.length; i++)
	{
		pstmt.setString(1, lbhand.getListcellItemLabel(kls[i],SMP_MARKING));
		pstmt.setString(2, lbhand.getListcellItemLabel(kls[i],SMP_NOTES));
		pstmt.setInt(3, Integer.parseInt(pJn));
		pstmt.setInt(4, Integer.parseInt( lbhand.getListcellItemLabel(kls[i],SMP_INDEXNO) ));
		pstmt.addBatch();
	}
	pstmt.executeBatch(); pstmt.close(); sql.close();
	jobfolder_dirtyflag = false;
}

