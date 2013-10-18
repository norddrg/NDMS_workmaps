procedure ICDUPDA
	SELECT icd_10
	SET FILTER TO
	delete all
	do CASE
	Case p_kieli='Com'
		append from C:\data\icd_com.dbf
		replace ALL code_w WITH code
	CASE p_kieli='Dan'
		append from C:\data\dan_icd.DBF 
	CASE p_kieli='Est'
		append from C:\data\est_icd.DBF 
	CASE p_kieli='Fin'
		append from C:\data\fin_icd.DBF 
	CASE p_kieli='Nor'
		append from C:\data\nor_icd.DBF 
	CASE p_kieli='Swe'
		append from C:\data\swe_icd.DBF 
	CASE p_kieli='Ice'
		append from C:\data\ice_icd.DBF 
	CASE p_kieli='Lat'
		append from C:\data\lat_icd.DBF 
	CASE p_kieli='Eng'
		append from C:\data\eng_icd.DBF 
	OTHERWISE
		WAIT WINDOW 'Does not work with current language version version'
		recall all
		do dgdrg
		return
	ENDCASE
	replace ALL valid WITH .t., prim WITH .t., headline WITH .f.
	DELETE ALL FOR code = '_'
	pack
	select icd_10
	lc_icd=dbf()
	use
	use c:\data\atc
	set filter to len(trim(atc))=5
	GOTO top
	do while not eof()
	 	INSERT INTO (lc_icd) (code,code_w, text, prim, valid, headline) VALUES (atc.atc, atc.atc, atc.text, .t., .t.,.f.)
		skip
	enddo
	do dgdrg
	select icd_10
	delete all for code=' '
	pack
	do dgpaiv
	return
