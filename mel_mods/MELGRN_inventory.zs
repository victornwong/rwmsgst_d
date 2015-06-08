import org.victor.*;
// MEL-GRN inventory management funcs - knockoff from goodsReceive_v2.zul(local GRN module)

// 07/01/2015: knockoff from goodsReceive_v2.zul(local GRN module)
// Inject stock items and qtys, only item with pre-def product-name will work
// use palletid 4=UNKNOWN (TODO chg to "WH PALLET" id for fc5012)
// IMPORTANT chg pallet-loca to AUDIT . GRN->AUDIT process, F30 palletid = 4, F12=4452
void updateInventory_GRNItems()
{
	AUDIT_PALLET_ID = "4"; // testing on F30 db
	try
	{
		log_assettags = "";
		//shpc = kiboo.replaceSingleQuotes( g_shipmentcode.getValue().trim() );
		shpc = "TEST MEL SHIPIN";
		tdate = calcFocusDate( kiboo.todayISODateTimeString() ).toString();
		sqlstm = "declare @maxid int; declare @maxseq int; declare @prodid varchar(200); declare @_masterid int; ";
		qty = "1";

		ki = impsn_lb.getItems().toArray();
		for(i=0;i<ki.length;i++)
		{
			atg = lbhand.getListcellItemLabel(ki[i],PARSE_ASSETTAG_POS); // asset-tag
			snm = lbhand.getListcellItemLabel(ki[i],PARSE_SNUM_POS); // serial-no
			itm = lbhand.getListcellItemLabel(ki[i],PARSE_ITEMDESC_POS); // item-desc (must be def inside prod-name tbl mr008)
			//xcsgn = lbhand.getListcellItemLabel(ki[i],PARSE_CSGN_NO_POS); // csgn no.
			//xdr = lbhand.getListcellItemLabel(ki[i],PARSE_DATERECEIVED_POS); // date equip recv

			if(!itm.equals("")) // only entry with item-name
			{
				log_assettags += atg + "(" + snm + " / " + qty + "), ";

				sqlstm += "if not exists(select 1 from mr001 where code2='" + atg + "')" +
				"begin " +
				"set @maxid = (select max(masterid)+1 from mr001);" +
				"set @maxseq = (select max(sequence)+1 from mr001);" +
				"set @prodid = (select top 1 masterid from mr008 where name='" + itm + "'); " +

				"insert into mr001 (masterid,sequence,name,code,code2,limit,l2,type,attribute,eoff,doff,creditdays,date_,time_,limit2) " +
				"values (@maxid,@maxseq, " +
				"'" + itm + " - " + atg + "','" + snm + "','" + atg + "', " +
				"0,-1,131,0,@maxid,0,0," + tdate + ",0xe332e,0); " +

				"insert into u0001 (extraid,productnameyh,palletnoyh,shipmentcodeyh) values (@maxid,@prodid," + AUDIT_PALLET_ID + ",'" + shpc + "'); " +

				"insert into ibals (code,date_,dep,qiss,qrec,val,qty2) " +
				"values (@maxid," + tdate + ",0,0," + qty + ",0,0); " +

				"end else begin " +
				"set @_masterid = (select masterid from mr001 where code2='" + atg + "'); " +

				"insert into ibals (code,date_,dep,qiss,qrec,val,qty2) " +
				"values (@_masterid," + tdate + ",0,0," + qty + ",0,0); " +

				//"update mr001 set name='" + itm + "',code='" + snm + "' where code2='" + atg + "';" +
				"end;";
			}
		}

		f30_gpSqlExecuter(sqlstm);
		//sqlhand.rws_gpSqlExecuter(sqlstm);
		//lgstr = "Update inventory : " + log_assettags;
		//add_RWAuditLog(JN_linkcode(),"", lgstr, useraccessobj.username);

	} catch (Exception e) {}
}

// 07/01/2015: knockoff from goodsReceive_v2.zul(local GRN module)
// used by admin for now .. later put into another module to FAST add/minus stock
// itype: 1=minus stock, 2=add stock
void minusAddFocus_Stock(int itype, int qty)
{
	try
	{
		if(itype == 1) qty *= -1;

		tdate = calcFocusDate( kiboo.todayISODateTimeString() ).toString();

		sqlstm = "declare @_masterid int; ";
		ki = impsn_lb.getItems().toArray();
		for(i=0;i<ki.length;i++)
		{
			//ki = jk[i].getChildren().toArray();
			//atg = kiboo.replaceSingleQuotes( ki[2].getValue().trim() );
			atg = lbhand.getListcellItemLabel(ki[i],PARSE_ASSETTAG_POS); // asset-tag

			if(!atg.equals(""))
			{
				sqlstm += "if exists(select 1 from mr001 where code2='" + atg + "')" +
				"begin " +
				"set @_masterid = (select masterid from mr001 where code2='" + atg + "'); " +
				"insert into ibals (code,date_,dep,qiss,qrec,val,qty2) ";

				switch(itype)
				{
					case 1: // do QISS
						sqlstm +=
						"values (@_masterid," + tdate + ",0," + qty.toString() + ",0,0,0); " +
						"end; ";
						break;

					case 2: // do QREC
					sqlstm +=
						"values (@_masterid," + tdate + ",0,0," + qty.toString() + ",0,0); " +
						"end; ";
						break;
				}
			}
		}
		//sqlhand.rws_gpSqlExecuter(sqlstm);
		f30_gpSqlExecuter(sqlstm);
	} catch (Exception e) {}	
}

