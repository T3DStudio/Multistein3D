
////////////////////////////////////////////////////////////////////////////////
//
//  WRITE

procedure wudata_string(s:shortstring;pf:pfile);
var sl,x:byte;
       c:char;
begin
   if(pf<>nil)then
   begin
      sl:=length(s);
      {$I-}
      BlockWrite(pf^,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=s[x];
         BlockWrite(pf^,c,SizeOf(c));
      end;
      {$I+}
   end
   else net_writestring(s);
end;
procedure wudata_byte  (bt:byte    ;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writebyte  (bt);end;
procedure wudata_word  (bt:word    ;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writeword  (bt);end;
procedure wudata_sint  (bt:shortint;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writesint  (bt);end;
procedure wudata_int   (bt:integer ;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writeint   (bt);end;
procedure wudata_card  (bt:cardinal;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writecard  (bt);end;
procedure wudata_single(bt:single  ;pf:pfile);begin if(pf<>nil)then {$I-}BlockWrite(pf^,bt,SizeOf(bt)){$I+} else net_writesingle(bt);end;
function  wudata_timer (bt:word    ;pf:pfile):byte;
begin
   if(bt>0)
   then bt:=mm3b(1,(bt div fr_fpsx1)+1,255);
   wudata_timer:=bt;
   wudata_byte(bt,pf);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  READ

function rudata_string(pf:pfile):shortstring;
var sl,x:byte;
       c:char;
begin
   if(pf<>nil)then
   begin
      sl:=0;
      rudata_string:='';
      {$I-}
      BlockRead(pf^,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=#0;
         BlockRead(pf^,c,SizeOf(c));
         rudata_string+=c;
      end;
      {$I+}
   end
   else rudata_string:=net_readstring;
end;
function rudata_byte  (pf:pfile;d:byte    ):byte    ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_byte  ,SizeOf(rudata_byte  ));{$I+}if(ioresult<>0)then rudata_byte  :=d;end else rudata_byte  :=net_readbyte   end;
function rudata_word  (pf:pfile;d:word    ):word    ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_word  ,SizeOf(rudata_word  ));{$I+}if(ioresult<>0)then rudata_word  :=d;end else rudata_word  :=net_readword   end;
function rudata_sint  (pf:pfile;d:shortint):shortint;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_sint  ,SizeOf(rudata_sint  ));{$I+}if(ioresult<>0)then rudata_sint  :=d;end else rudata_sint  :=net_readsint   end;
function rudata_int   (pf:pfile;d:integer ):integer ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_int   ,SizeOf(rudata_int   ));{$I+}if(ioresult<>0)then rudata_int   :=d;end else rudata_int   :=net_readint    end;
function rudata_card  (pf:pfile;d:cardinal):cardinal;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_card  ,SizeOf(rudata_card  ));{$I+}if(ioresult<>0)then rudata_card  :=d;end else rudata_card  :=net_readcard   end;
function rudata_single(pf:pfile;d:single  ):single  ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,rudata_single,SizeOf(rudata_single));{$I+}if(ioresult<>0)then rudata_single:=d;end else rudata_single:=net_readsingle end;
function rudata_timer (pf:pfile):word;
begin
   rudata_timer:=rudata_byte(pf,0);
   if(rudata_timer>0)
   then rudata_timer:=rudata_timer*fr_fpsx1-1;
end;

