// BOM auto-populate funcs

void sumbatAssetTagToBuilds(String iastg, int itype)
{
	Object[] ram = { m_ram, m_ram2, m_ram3, m_ram4 };
	Object[] hdd = { m_hdd, m_hdd2, m_hdd3, m_hdd4 };
	wo = ram;
	if(itype == 2) wo = hdd;
	for(i=0; i<wo.length; i++)
	{
		nn = wo[i].getValue().trim();
		if(nn.equals("")) { wo[i].setValue(iastg); break; }
	}
}

void autoPopulateParts()
{
	ma = fastscan_tb.getValue().trim();
	if(ma.equals("")) return;

	Object[] en1 = { m_asset_tag, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_battery, m_poweradaptor, m_gfxcard };

	kk = ma.split("\n");
	clearUI_Field(en1); // maybe no need to clear parts asset-tags
	for(i=0; i<kk.length; i++)
	{
		astg = kk[i].trim().toUpperCase();
		if(astg.indexOf("N0",0) != -1 || astg.indexOf("A0",0) != -1 || astg.indexOf("M0",0) != -1) // equips
		{
			m_asset_tag.setValue(astg);
		}
		if(astg.indexOf("R0",0) != -1) sumbatAssetTagToBuilds(astg,1); // found RAM
		if(astg.indexOf("HD0",0) != -1 || astg.indexOf("HN0",0) != -1) sumbatAssetTagToBuilds(astg,2); // found HDD for NB or DT
		if(astg.indexOf("B0",0) != -1) m_battery.setValue(astg); // found battery
		if(astg.indexOf("ADP0",0) != -1) m_poweradaptor.setValue(astg); // found adaptor
		if(astg.indexOf("GC0",0) != -1) m_gfxcard.setValue(astg); // found gfx-card
	}
}

// Auto insert monitors only into BOM list - asset-tags start with M0xxxxx ONLY
// itype: 1=monitor .. get ready if need to auto insert NB or DT
void bomAutoInsertEquips(int itype)
{
	bty = "";
	switch(itype)
	{
		case 1:
			bty = "MONITOR";
			break;
	}
	ma = fastscan_tb.getValue().trim();
	if(ma.equals("")) return;
	if(global_selected_bom.equals("")) return;
	kk = ma.split("\n");
	sqlstm = "";
	for(i=0; i<kk.length; i++)
	{
		atg = kk[i].trim().toUpperCase();
		if(atg.indexOf("M0",0) != -1)
		{
			sqlstm += "insert into stockrentalitems_det (parent_id,bomtype,asset_tag) values " +
				"(" + global_selected_bom + ",'" + bty + "','" + atg + "');";
		}
	}
	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showBuildItems(global_selected_bom);
		//fastscan_tb.setValue(""); // done clear tb
		guihand.showMessageBox("Scanned " + bty + "(ONLY) inserted..");
	}
}

// scan through TB for parts+equips asset-tags , "-" will move to next equip
void autoInsertEquips()
{
	ma = fastscan_tb.getValue().trim();
	if(ma.equals("")) return;
	if(global_selected_bom.equals("")) return;
	kk = ma.split("\n");
	sqlstm = "";
	HashMap arec = new HashMap();
	rc = hd = 1;
	foundass = false;
	for(i=0; i<kk.length; i++)
	{
		astg = kk[i].trim().toUpperCase();
		if((astg.indexOf("N0",0) != -1 || astg.indexOf("A0",0) != -1 || astg.indexOf("M0",0) != -1) && !foundass)
		{
			bty = "DESKTOP";
			foundass = true;
			if(astg.indexOf("N0",0) != -1) bty = "NOTEBOOK";
			if(astg.indexOf("M0",0) != -1) bty = "MONITOR";
			arec.put("ASSETTYPE",bty);
			arec.put("ASSETTAG",astg);
		}

		if(foundass)
		{
			if(astg.indexOf("R0",0) != -1 && astg.indexOf("WSVR03",0) == -1)
			{
				while(rc < 5)
				{
					kstr = "RAM" + rc.toString();
					if(arec.containsKey(kstr))
						rc++;
					else
						break;
				}
				kstr = "RAM" + rc.toString();
				arec.put(kstr,astg);
			}

			if(astg.indexOf("HD0",0) != -1 || astg.indexOf("HN0",0) != -1)
			{
				while(hd < 5)
				{
					kstr = "HDD" + hd.toString();
					if(arec.containsKey(kstr))
						hd++;
					else
						break;
				}
				kstr = "HDD" + hd.toString();
				arec.put(kstr,astg);
			}

			if(astg.indexOf("B0",0) != -1) arec.put("BATTERY",astg);
			if(astg.indexOf("ADP0",0) != -1) arec.put("ADAPTOR",astg);
			if(astg.indexOf("GC0",0) != -1)  arec.put("GFXCARD",astg);

			// scan ms-win and mso things

			if(astg.indexOf("WXPP-",0) != -1) { arec.put("COA1", astg.replaceAll("WXPP-","")); arec.put("COA1N", "WINDOWS XP PRO"); }
			if(astg.indexOf("W7P-",0) != -1) { arec.put("COA1", astg.replaceAll("W7P-","")); arec.put("COA1N", "WINDOWS 7 PRO"); }
			if(astg.indexOf("W7U-",0) != -1) { arec.put("COA1", astg.replaceAll("W7U-","")); arec.put("COA1N", "WINDOWS 7 ULTIMATE"); }
			if(astg.indexOf("WVS-",0) != -1) { arec.put("COA1", astg.replaceAll("WVS-","")); arec.put("COA1N", "WNDOWS VISTA"); }
			if(astg.indexOf("WSVR03-",0) != -1) { arec.put("COA1", astg.replaceAll("WSVR03-","")); arec.put("COA1N", "WINDOWS SERVER 2003"); }
			if(astg.indexOf("WSVR12-",0) != -1) { arec.put("COA1", astg.replaceAll("WSVR12-","")); arec.put("COA1N", "WINDOWS SERVER 2012"); }
			if(astg.indexOf("W8P-",0) != -1) { arec.put("COA1", astg.replaceAll("W8P-","")); arec.put("COA1N", "WINDOWS 8 PRO"); }
			if(astg.indexOf("W7PR-",0) != -1) { arec.put("COA1", astg.replaceAll("W7PR-","")); arec.put("COA1N", "WINDOWS 7 PRO REFURB"); }

			if(astg.indexOf("MSO13 H&B-",0) != -1) { arec.put("COA2", astg.replaceAll("MSO13 H&B-","")); arec.put("COA2N", "MSOFFICE 2013 H&B"); }
			if(astg.indexOf("MSO10 PRO-",0) != -1) { arec.put("COA2", astg.replaceAll("MSO10 PRO-","")); arec.put("COA2N", "MSOFFICE 2010 PRO"); }
			if(astg.indexOf("MSO10 H&B-",0) != -1) { arec.put("COA2", astg.replaceAll("MSO10 H&B-","")); arec.put("COA2N", "MSOFFICE 2010 H&B"); }
			if(astg.indexOf("MSO13 PP-",0) != -1) { arec.put("COA2", astg.replaceAll("MSO13 PP-","")); arec.put("COA2N", "MSOFFICE 2013 PRO"); }
			if(astg.indexOf("MSO 07 PRO-",0) != -1) { arec.put("COA2", astg.replaceAll("MSO 07 PRO-","")); arec.put("COA2N", "MSOFFICE 2007 PRO"); }
		}

		if(astg.equals("-"))
		{
			try { gast = arec.get("ASSETTAG"); } catch (Exception e) { gast = ""; }
			if(!gast.equals("")) // must have an equip asset-tag to process sqlstm
			{
				bty = ""; try { if(arec.containsKey("ASSETTYPE")) bty = arec.get("ASSETTYPE"); } catch (Exception e) {}
				ram1 = ""; try { if(arec.containsKey("RAM1")) ram1 = arec.get("RAM1"); } catch (Exception e) {}
				ram2 = ""; try { if(arec.containsKey("RAM2")) ram2 = arec.get("RAM2"); } catch (Exception e) {}
				ram3 = ""; try { if(arec.containsKey("RAM3")) ram3 = arec.get("RAM3"); } catch (Exception e) {}
				ram4 = ""; try { if(arec.containsKey("RAM4")) ram4 = arec.get("RAM4"); } catch (Exception e) {}
				hdd1 = ""; try { if(arec.containsKey("HDD1")) hdd1 = arec.get("HDD1"); } catch (Exception e) {}
				hdd2 = ""; try { if(arec.containsKey("HDD2")) hdd2 = arec.get("HDD2"); } catch (Exception e) {}
				hdd3 = ""; try { if(arec.containsKey("HDD3")) hdd3 = arec.get("HDD3"); } catch (Exception e) {}
				hdd4 = ""; try { if(arec.containsKey("HDD4")) hdd4 = arec.get("HDD4"); } catch (Exception e) {}
				adp = ""; try { if(arec.containsKey("ADAPTOR")) adp = arec.get("ADAPTOR"); } catch (Exception e) {}
				batt = ""; try { if(arec.containsKey("BATTERY")) batt = arec.get("BATTERY"); } catch (Exception e) {}
				gfx = ""; try { if(arec.containsKey("GFXCARD")) gfx = arec.get("GFXCARD"); } catch (Exception e) {}

				c1 = cn1 = ""; try { if(arec.containsKey("COA1")) { c1 = arec.get("COA1"); cn1 = arec.get("COA1N"); } } catch (Exception e) {}
				c2 = cn2 = ""; try { if(arec.containsKey("COA2")) { c2 = arec.get("COA2"); cn2 = arec.get("COA2N"); } } catch (Exception e) {}

				sqlstm += "insert into stockrentalitems_det (parent_id,bomtype,asset_tag,ram,ram2,ram3,ram4,hdd,hdd2,hdd3,hdd4,poweradaptor,battery,gfxcard," +
				"osversion,coa1,offapps,coa3) values " +
				"(" + global_selected_bom + ",'" + bty + "','" + gast + "','" + ram1 + "','" + ram2 + "','" + ram3 + "','" + ram4 + "'," +
				"'" + hdd1 + "','" + hdd2 + "','" + hdd3 + "','" + hdd4 + "','" + adp + "','" + batt + "','" + gfx + "'," +
				"'" + cn1 + "','" + c1 + "','" + cn2 + "','" + c2 + "');";
			}
			arec.clear();
			foundass = false;
			rc = hd = 1;
		}
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showBuildItems(global_selected_bom);
		//fastscan_tb.setValue(""); // done clear tb
		guihand.showMessageBox("Assets and parts inserted..");
	}

}

/*
a012003020
r010203
hd0102093
r0983822
hd020203
gc0391882
WSVR03-0d003 02--3-109029 3-2--
MSO 07 PRO-as0df0 0012 las0df 0 0l3l
-
m02003920
-
n093939
r0489848
r028729
hn02020893
hn02029893
b029838
adp0918823
W7U-1234 93992 991020 03029
MSO13 H&B-kaksdf 0202 0asd lkl20 las39
-
*/
