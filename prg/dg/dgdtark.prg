procedure dgdtark
if p_kieli='Com'
  wait window 'Common version cannot be compared with common version. Select a national version to be checked'
  return
endif
define window koodi from 5,5 to 25,120 FONT  max_foty,  max_fosi
select dg_oth
set order to code
select dg
set filter to valid
select icd_10
set filter to valid
do while not eof()
  lc_icd=icd_10.code+icd_10.d_code
  w_dgcat=.f.
  l_dgcat=.f.
  select dg
  seek upper(lc_icd)
  do while upper(dg.code)=upper(icd_10.code) and upper(dg.d_code)=upper(icd_10.d_code) and not eof()
    p_dgcat=.f.
    select dg_oth
    dgt_found=.f.
    if dg.vartype='DGCAT' and icd_10.d_code_w<>' '
      seek upper(icd_10.code_w+icd_10.d_code_w)+dg.vartype
      if found()
        p_dgcat=.t.
      endif
    endif
    seek upper(icd_10.code_w+icd_10.d_code_w)+dg.vartype+dg.varval
    if not found() and icd_10.d_code_w<>' ' and not p_dgcat
      seek upper(icd_10.code_w)+space(6)+dg.vartype+dg.varval
    endif
    if not found() and icd_10.d_code_w<>' ' and dg.vartype<>'DGCAT' and not p_dgcat
      seek upper(icd_10.d_code_w)+space(6)+dg.vartype+dg.varval
    endif
    if found()
      dgt_found=.t.
    endif
    if l_dgcat and dg_oth.vartype='DGCAT'
       dgt_found=.f.
    endif
    if found() and vartype='DGCAT'
      l_dgcat=.t.
    endif
    if not dgt_found
       activate window koodi
       clear
       @ 1,1 say 'Local ICD code'
       @ 2,1 say icd_10.code+' '+ icd_10.d_code +' '+substr(icd_10.text,1,70)
       @ 3,1 say 'Common ICD code'
       select icd_oth
       seek upper(icd_10.code_w + icd_10.d_code_w)
       if not found() and icd_10.d_code_w<>' '
         seek upper(icd_10.code_w)
         if found()
           seek upper(icd_10.d_code_w)
         endif
       endif
       if not found()
         if not (substr(icd_10.code,4,1)<>'.' and substr(icd_10.code,5,1)>'9')
           @ 4,1 say 'No mapping to common version'
           @ 12,1 say '(A)ccept and continue'
           @ 13,1 say '(E)dit the files manually'
           wait window 'Select the option'
           if not (lastkey()=65 or lastkey()=97)
             release window koodi
             select icd_10
             seek upper(lc_icd)
             do dgnaytto
             return
           endif
         endif
         select icd_10
         skip
         loop
       else
         @ 4,1 say icd_10.code_w+' '+icd_10.d_code_w+' '+substr(icd_oth.text,1,70)
         @ 6,1 say 'Property of local version does not exist in common version NordDRG'
         do case
         case dg.vartype='DGCAT'
           select dgkat
           seek (SUBSTR(dg.varval,1,2)+SUBSTR(dg.varval,4,2))
           lc_text=dgkat.english
         case dg.vartype='COMPL'
           select kompkat
           seek (SUBSTR(dg.varval,1,2)+SUBSTR(dg.varval,4,2))
           lc_text=kompkat.english
         case dg.vartype='PROCPR' 
           select tpomin
           seek dg.varval
           lc_text=tpomin.english
         case dg.vartype='DGPROP'
           select dgomin
           seek (SUBSTR(dg.varval,1,2)+SUBSTR(dg.varval,4,2)+SUBSTR(dg.varval,3,1))
           lc_text=dgomin.english
         case dg.vartype='PDGPRO'
           select pdgomin
           seek dg.varval
           lc_text=pdgomin.english
         case dg.vartype='OR'
           lc_text=' '
         otherwise
           lc_text=' '
         endcase
         select dg_oth
         @ 8,1 say 'Local vers. property:  '+dg.vartype+' '+dg.varval+' '+lc_text
         @ 9,1 say 'Common vers. property: ---'

         @11,1 say '(D)elete the local property'
         @ 12,1 say '(A)ccept the difference'
         @ 13,1 say '(E)dit the files manually'
         @ 14,1 say '(U)pdate the property to the common version'
         IF dg.varval='40P80'
         * 40P80 lis�ys common versioon
             select dg_oth
             set filter to
             seek upper(icd_10.code_w+icd_10.d_code_w)+dg.vartype+dg.varval
             if not found()
               insert into dg_oth (code, d_code, vartype, varval, chdate); 
               values (icd_10.code_w, icd_10.d_code_w, dg.vartype, dg.varval, date())
               replace valid with .t.
               select dg_oth
               set filter to valid
               SELECT icd_10
               SKIP
               loop            
             endif
         endif
         wait window 'Select the option' 
         *u=117 U=85
         *i=105 I=73
         *d=100 D=68
         *a=97 A=65
         *e=101 E=69
         do case
         case lastkey()=68 or lastkey()=100 
           wait window 'Do you want to delete the property? Yes/No'
           if lastkey()=89 or lastkey()=121
             select dg
             replace valid with .f.
           else 
             release window koodi
             select icd_10
             seek upper(lc_icd)
             do dgnaytto
             return
           endif
         case lastkey()= 65 or lastkey()=97
           wait window nowait 'OK'
         CASE LASTKEY()=85 OR LASTKEY()=117
           wait window 'Do you want to add the property? Yes/No'
           if lastkey()=89 or lastkey()=121
             select dg_oth
             set filter to
             seek upper(icd_10.code_w+icd_10.d_code_w)+dg.vartype+dg.varval
             if not found()
               insert into dg_oth (code, d_code, vartype, varval, chdate); 
               values (icd_10.code_w, icd_10.d_code_w, dg.vartype, dg.varval, date())
             endif
             replace valid with .t.
             select dg_oth
             set filter to valid
           ELSE 
             release window koodi
             select icd_10
             seek upper(lc_icd)
             do dgnaytto
             return
           ENDIF 
         otherwise
           release window koodi
           select icd_10
           seek upper(lc_icd)
           do dgnaytto
          return
         endcase
      endif
    endif
    select dg
    skip
  enddo
  select dg_oth
  dgt_codes=icd_10.code_w+icd_10.d_code_w
  seek upper(icd_10.code_w+icd_10.d_code_w)
  if not found()
    seek upper(icd_10.code_w)
    dgt_codes=icd_10.code_w+space(6)
  endif  
  dgt_loop=.t.
  do while code+d_code=dgt_codes
    if w_dgcat and dg_oth.vartype='DGCAT'
       skip
       loop
    endif
    select dg
    seek upper(icd_10.code+icd_10.d_code)+dg_oth.vartype+dg_oth.varval
    if not found() and icd_10.d_code<>' '
      seek upper(icd_10.code)+space(6)+dg_oth.vartype+dg_oth.varval
    endif
    if not found() and icd_10.d_code<>' ' and dg_oth.vartype<>'DGCAT'
      seek upper(icd_10.d_code)+space(6)+dg_oth.vartype+dg_oth.varval
    endif
    if found() and vartype='DGCAT'
      w_dgcat=.t.
    endif
    if not found() and not (dgt_codes=icd_10.d_code_w and dg_oth.vartype='DGCAT')
      activate window koodi
      clear
      @ 1,1 say 'Local ICD-10 code'
      @ 2,1 say icd_10.code + ' '+ icd_10.d_code +' '+substr(icd_10.text,1,70)
      @ 3,1 say 'Common ICD-10 code'
      select icd_oth
      seek upper(icd_10.code_w + icd_10.d_code_w)
      if not found()
        seek upper(icd_10.code_w)
        if found()
          seek upper(icd_10.d_code_w)
        endif
      endif
      if not found()
        @ 4,1 say 'Mapping error, ' + trim(icd_10.code_w) +'+'+icd_10.d_code_w + ' not found'
        wait window 'Mapping error'
        release window koodi
        select icd_10
        seek upper(lc_icd)
        do dgnaytto
        return
      else
        @ 4,1 say icd_oth.code+' '+icd_oth.d_code+' '+substr(icd_oth.text,1,70)
      endif
      
      @ 6,1 say 'Property of common NordDRG does not exist in local version '
      lc_orcc=.f.
      do case 
      case dg_oth.vartype='DGCAT'
        select dgkat
        seek (SUBSTR(dg_oth.varval,1,2)+SUBSTR(dg_oth.varval,4,2))
        lc_text=dgkat.english
      case dg_oth.vartype='COMPL'
        select kompkat
        seek (SUBSTR(dg_oth.varval,1,2)+SUBSTR(dg_oth.varval,4,2))+'C'
        lc_text=dgkat.english
      case dg_oth.vartype='PROCPR' 
        select tpomin
        seek dg_oth.varval
        lc_text=tpomin.english
      case dg_oth.vartype='DGPROP'
        select dgomin
        seek (SUBSTR(dg_oth.varval,1,2)+SUBSTR(dg_oth.varval,4,2)+SUBSTR(dg_oth.varval,3,1))
        lc_text=dgomin.english
      case dg_oth.vartype='PDGPRO'
        select pdgomin
        seek dg_oth.varval
        lc_text=pdgomin.english
      case dg_oth.vartype='OR'
        lc_text=' '
      otherwise
        lc_text=' '
      endcase
      @ 8,1 say 'Local vers. property:  ---'
      @ 9,1 say 'Common vers. property: '+dg_oth.vartype+' '+dg_oth.varval+' '+lc_text
      
      @11,1 say '(I)nsert the property to local version'
      @12,1 say '(A)ccept the difference'
      @13,1 say '(E)dit the files manually'
      @14,1 say '(R)emove the property from the common version'
      IF dg_oth.varval='40P80'
        select dg
        set filter to
        seek upper(icd_10.code+icd_10.d_code)+dg_oth.vartype+dg_oth.varval
        if not found()
          insert into dg (code, d_code, vartype, varval, chdate); 
          values (icd_10.code, icd_10.d_code, dg_oth.vartype, dg_oth.varval, date())
          replace valid with .t.
          select dg
          set filter to valid  
          select dg_oth
          skip
          loop
         endif
      ENDIF 
      wait window 'Select the option'
      *r=114 R=82
      do case
      case lastkey()=73 or lastkey()=105 
        select dg
        set filter to
        seek upper(icd_10.code+icd_10.d_code)+dg_oth.vartype+dg_oth.varval
        if not found()
          insert into dg (code, d_code, vartype, varval, chdate); 
          values (icd_10.code, icd_10.d_code, dg_oth.vartype, dg_oth.varval, date())
        endif
        replace valid with .t.
        select dg
        set filter to valid
      case lastkey()= 65 or lastkey()=97
        wait window nowait 'OK'
      CASE LASTKEY()=82 OR LASTKEY()=114
         wait window 'Do you want to delete the property? Yes/No'
         if lastkey()=89 or lastkey()=121
           select dg_oth
           replace valid with .f.
         else 
           release window koodi
           select icd_10
           seek upper(lc_icd)
           do dgnaytto
           return
         endif
      otherwise
        release window koodi
        select icd_10
        seek upper(lc_icd)
        do dgnaytto
        return
      endcase
    endif
    select dg_oth
    skip
    if upper(code+d_code)=upper(dgt_codes)
      loop
    else
      if icd_10.d_code_w<>' ' 
        do case
        case upper(dgt_codes)=upper(icd_10.code_w+icd_10.d_code_w)
          dgt_codes= icd_10.code_w+space(6)
          seek upper(dgt_codes)
        case upper(dgt_codes)=upper(icd_10.code_w+space(6))
          dgt_codes= icd_10.d_code_w+space(6)
          seek upper(dgt_codes)
        otherwise
          exit
        endcase
      else
        exit
      endif
    endif
  enddo
  select komplex
  set order to code
  set filter to valid
  seek upper(icd_10.code+icd_10.d_code)
  do while upper(code)=upper(icd_10.code)and upper(d_code)=upper(icd_10.d_code)
    select komplex_oth
    seek upper(icd_10.code_w+icd_10.d_code_w)+SUBSTR(komplex.compl,1,2)+SUBSTR(komplex.compl,4,2)
    if not found() and icd_10.d_code_w<>' '
      seek upper(icd_10.code_w)+space(6)+SUBSTR(komplex.compl,1,2)+SUBSTR(komplex.compl,4,2)    
    endif
    if not found() and icd_10.d_code_w<>' '
      seek upper(icd_10.d_code_w)+space(6)+SUBSTR(komplex.compl,1,2)+SUBSTR(komplex.compl,4,2)    
    endif
    if not found()
       activate window koodi
       clear
       @ 1,1 say 'Local ICD code'
       @ 2,1 say icd_10.code+' '+ icd_10.d_code +' '+substr(icd_10.text,1,70)
       @ 3,1 say 'Common ICD code'
       select icd_oth
       seek upper(icd_10.code_w + icd_10.d_code_w)
       if not found () and icd_10.d_code_w<>' '
         seek upper(icd_10.code_w)
         if found()
           seek upper(icd_10.d_code_w)
         endif
       endif
       if not found()
         @ 4,1 say 'Mapping error'
       else
         @ 4,1 say icd_10.code_w+' '+icd_10.d_code_w+' '+substr(icd_oth.text,1,70)
       endif
       
       @ 6,1 say 'CC exclusion of local version does not exist in common version NordDRG'
       select kompkat
       seek (SUBSTR(komplex.compl,1,2)+SUBSTR(komplex.compl,4,2)+substr(komplex.compl,3,1))
       lc_text=kompkat.english
       @ 8,1 say 'Local vers. CC-category exclusion:  '+komplex.compl+lc_text
       @ 9,1 say 'Common vers. property: ---'

       @ 11,1 say '(D)elete the local code from exclusions'
       @ 12,1 say '(A)ccept the difference'
       @ 13,1 say '(E)dit the files manually'
       @ 14,1 say '(U)pdate the exclusion to common version'
       wait window 'Select the option'
       do case
       case lastkey()=68 or lastkey()=100
         wait window 'Do you want to delete the diagnosis from the exclusions? Yes/No'
         if lastkey()=89 or lastkey()=121
           select komplex
           replace valid with .f.
         else 
           release window koodi
           select icd_10
           seek upper(lc_icd)
           do dgnaytto
           return
         endif
       case lastkey()= 65 or lastkey()=97
         wait window nowait 'OK'
       CASE LASTKEY()=85 OR LASTKEY()=117
        wait window 'Do you want to add the property? Yes/No'
        if lastkey()=89 or lastkey()=121
         select komplex_oth
         set filter to
         seek upper(icd_10.code_w+icd_10.d_code_w)+SUBSTR(komplex.compl,1,2)+SUBSTR(komplex.compl,4,2)
         if not found()
           insert into komplex_oth (code, d_code, compl, chdate); 
           values (icd_10.code_w, icd_10.d_code_w, komplex.compl, date())
         endif
         replace valid with .t.
         select komplex_oth
         set filter to valid       
        ELSE 
         release window koodi
         select icd_10
         seek upper(lc_icd)
         do dgnaytto
         return
        ENDIF 
       otherwise
         release window koodi
         select icd_10
         seek upper(lc_icd)
         do dgnaytto
         return
       endcase
    endif
    select komplex
    skip
  enddo
  select komplex_oth
  set order to code
  set filter to valid
  dgt_codes=icd_10.code_w+icd_10.d_code_w
  seek upper(icd_10.code_w+icd_10.d_code_w)
  if not found()
    seek upper(icd_10.code_w)+space(6)
    dgt_codes=icd_10.code_w+space(6)
    if not found()
      seek upper(icd_10.d_code_w)+space(6)
      dgt_codes=icd_10.d_code_w+space(6)
    endif
  endif  
  do while code+d_code=dgt_codes
    select komplex
    seek upper(icd_10.code+icd_10.d_code)+SUBSTR(komplex_oth.compl,1,2)+SUBSTR(komplex_oth.compl,4,2)
    if not found() and icd_10.d_code<>' '
      seek upper(icd_10.code)+space(6)+SUBSTR(komplex_oth.compl,1,2)+SUBSTR(komplex_oth.compl,4,2)
    endif
    if not found() and icd_10.d_code<>' '
      seek upper(icd_10.d_code)+space(6)+SUBSTR(komplex_oth.compl,1,2)+SUBSTR(komplex_oth.compl,4,2)
    endif
    if not found()
       activate window koodi
       clear
       @ 1,1 say 'Local ICD code'
       @ 2,1 say icd_10.code+' '+ icd_10.d_code +' '+substr(icd_10.text,1,70)
       @ 3,1 say 'Common ICD code'
       select icd_oth
       seek upper(icd_10.code_w + icd_10.d_code_w)
       if not found()
         seek upper(icd_10.code_w)
         if found()
           seek upper(icd_10.d_code_w)
         endif
       endif
       if not found()
         @ 4,1 say 'Mapping error'
       else
         @ 4,1 say icd_10.code_w+' '+icd_10.d_code_w+' '+substr(icd_oth.text,1,70)
       endif
       
       @ 6,1 say 'CC exclusion of common version does not exist in local version NordDRG'
       select kompkat
       seek (SUBSTR(komplex_oth.compl,1,2)+SUBSTR(komplex_oth.compl,4,2)+substr(komplex_oth.compl,3,1))
       lc_text=kompkat.english
       @ 9,1 say 'Common vers. CC-category exclusion:  '+komplex_oth.compl+lc_text
       @ 8,1 say 'Local vers. CC-category exclusion: ---'

       @ 11,1 say '(I)nsert the local code to CC-category exclusions'
       @ 12,1 say '(A)ccept the difference'
       @ 13,1 say '(E)dit the files manually'
       @ 14,1 say '(R)emove the exclusion from common version'
        wait window 'Select the option'
       do case
       case lastkey()=73 or lastkey()=105
         select komplex
         set filter to
         seek upper(icd_10.code+icd_10.d_code)+SUBSTR(komplex_oth.compl,1,2)+SUBSTR(komplex_oth.compl,4,2)
         if not found()
           insert into komplex (code, d_code, compl, chdate); 
           values (icd_10.code, icd_10.d_code, komplex_oth.compl, date())
         endif
         replace valid with .t.
         select komplex
         set filter to valid
       case lastkey()= 65 or lastkey()=97
         wait window nowait 'OK'
      CASE LASTKEY()=82 OR LASTKEY()=114
         wait window 'Do you want to delete the diagnosis from the exclusions? Yes/No'
         if lastkey()=89 or lastkey()=121
           select komplex_oth
           replace valid with .f.
         else 
           release window koodi
           select icd_10
           seek upper(lc_icd)
           do dgnaytto
           return
         endif
      
       otherwise
         release window koodi
         select icd_10
         seek upper(lc_icd)
         do dgnaytto
         return
       endcase
    endif
    select komplex_oth
    skip
    if code+d_code=dgt_codes
      loop
    else
      if icd_10.d_code_w<>' ' 
        do case
        case upper(dgt_codes)=upper(icd_10.code_w+icd_10.d_code_w)
          dgt_codes= icd_10.code_w+space(6)
          seek upper(dgt_codes)
        case upper(dgt_codes)=upper(icd_10.code_w+space(6))
          dgt_codes= icd_10.d_code_w+space(6)
          seek upper(dgt_codes)
        otherwise
          exit
        endcase
      else
        exit
      endif
    endif
  enddo
  
  select icd_10
  if not eof()
    skip
  endif
enddo
goto top
do dgnaytto
do dgohje
release window koodi
wait window 'End' nowait
return