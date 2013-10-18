Procedure icd_upd
clear all
use icd_10
set order to code
replace ALL valid WITH .f.
select 0
use icd_est_2012 alias cha
goto top
do while not eof()
  select icd_10
  seek cha.c1
  IF NOT FOUND()
     SEEK TRIM(cha.c1)
     IF NOT FOUND()
       append blank
       replace code with cha.c1, text with cha.c7, change with ctod('2012/01/01'), valid with .t. , who with .f., prim with .t., headline with .f.
     endif
  else
     replace valid with .t.
     IF NOT (TRIM(text)=TRIM(cha.c7)) 
     *AND TRIM(cha.c6)=TRIM(text))
       replace text WITH cha.c7
    endif
  endif
  select cha
  skip
enddo
return