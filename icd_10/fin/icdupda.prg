PROCEDURE icdupda
CLEAR all
SELECT 0
USE ..\..\icd_10\fin\icd_10_2012.dbf ALIAS new
SELECT 0
use icd_10
SET ORDER TO code
SET FILTER TO d_code<>' ' OR (SUBSTR(code,4,1)='.' OR SUBSTR(code,4,1)=' ')
replace ALL valid WITH .f.
SET FILTER TO
SELECT new
SET FILTER TO not(lehtisolmu='F') AND voimassao1=CTOD('2020/12/31')GOTO TOP 
DO WHILE NOT EOF()
  lc_oir=' '
  IF AT('*',tunniste)>0
    lc_oir=SUBSTR(koodi2,1,6)
    lc_syy=SUBSTR(koodi1,1,6)
  ENDIF
  IF at('+',tunniste)>0 
    lc_oir=SUBSTR(koodi2,1,6)
    lc_syy=SUBSTR(koodi1,1,6)
  ENDIF 
  IF lc_oir=' '
    lc_oir=SUBSTR(koodi1,1,6)
    lc_syy=SPACE(6)
  ENDIF
  SELECT ICD_10
  SEEK lc_oir+lc_syy
  IF FOUND()
    replace valid WITH .t.
    IF TRIM(new.pitk__nimi)<>TRIM(text) OR TRIM(text)<>TRIM(new.pitk__nimi)
      replace text WITH new.pitk__nimi
      replace change WITH DATE()
    ENDIF 
  ELSE
    APPEND BLANK
    replace code WITH lc_oir, d_code WITH lc_syy, prim WITH .t., headline WITH .f., text WITH new.pitk__nimi, change WITH DATE(), valid WITH .t.
  ENDIF 
  IF AT('#', new.tunniste)>0
    replace ast with '#'
  ENDIF
  IF AT('&', new.tunniste)>0   
    replace ast WITH '&'
  ENDIF
  IF AT('*',new.tunniste)>0
    replace ast WITH '*'
  ENDIF 
  IF lc_syy<>' '
    replace ast WITH '*'
    SEEK lc_oir
    IF FOUND()
      replace valid WITH .t.
    ELSE
      APPEND BLANK
      replace code WITH lc_oir, prim WITH .t., headline WITH .f., text WITH new.pitk__nimi, change WITH DATE(), valid WITH .t.
    endif
    SEEK lc_syy
    IF FOUND()
      replace valid WITH .t.
    ELSE
      APPEND BLANK
      replace code WITH lc_syy, prim WITH .t., headline WITH .f., text WITH new.pitk__nimi, change WITH DATE(), valid WITH .t.
    ENDIF 
  ENDIF 
  SELECT new
  skip
ENDDO 
RETURN