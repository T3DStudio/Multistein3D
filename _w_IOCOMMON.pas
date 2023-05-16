

procedure _wudata_string(s:shortstring;pf:pfile);
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
      exit;
   end;
   net_writestring(s);
end;
procedure _wudata_byte  (bt:byte    ;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writebyte  (bt);end;
procedure _wudata_word  (bt:word    ;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writeword  (bt);end;
procedure _wudata_sint  (bt:shortint;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writesint  (bt);end;
procedure _wudata_int   (bt:integer ;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writeint   (bt);end;
procedure _wudata_card  (bt:cardinal;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writecard  (bt);end;
procedure _wudata_single(bt:single  ;pf:pfile);begin if(pf<>nil)then begin{$I-}BlockWrite(pf^,bt,SizeOf(bt));{$I+}exit;end;net_writesingle(bt);end;
function  _wudata_timer (bt:word    ;pf:pfile):byte;
begin
   if(bt>0)
   then bt:=mm3b(1,(bt div fr_fps)+1,255);
   _wudata_timer:=bt;
   _wudata_byte(bt,pf);
end;

function _rudata_string(pf:pfile):shortstring;
var sl,x:byte;
       c:char;
begin
   if(pf<>nil)then
   begin
      sl:=0;
      _rudata_string:='';
      {$I-}
      BlockRead(pf^,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=#0;
         BlockRead(pf^,c,SizeOf(c));
         _rudata_string:=_rudata_string+c;
      end;
      {$I+}
      exit;
   end;
   _rudata_string:=net_readstring;
end;
function _rudata_byte  (pf:pfile;d:byte    ):byte    ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_byte  ,SizeOf(_rudata_byte  ));if(ioresult<>0)then _rudata_byte  :=d;{$I+}exit;end;_rudata_byte  :=net_readbyte   end;
function _rudata_word  (pf:pfile;d:word    ):word    ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_word  ,SizeOf(_rudata_word  ));if(ioresult<>0)then _rudata_word  :=d;{$I+}exit;end;_rudata_word  :=net_readword   end;
function _rudata_sint  (pf:pfile;d:shortint):shortint;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_sint  ,SizeOf(_rudata_sint  ));if(ioresult<>0)then _rudata_sint  :=d;{$I+}exit;end;_rudata_sint  :=net_readsint   end;
function _rudata_int   (pf:pfile;d:integer ):integer ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_int   ,SizeOf(_rudata_int   ));if(ioresult<>0)then _rudata_int   :=d;{$I+}exit;end;_rudata_int   :=net_readint    end;
function _rudata_card  (pf:pfile;d:cardinal):cardinal;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_card  ,SizeOf(_rudata_card  ));if(ioresult<>0)then _rudata_card  :=d;{$I+}exit;end;_rudata_card  :=net_readcard   end;
function _rudata_single(pf:pfile;d:single  ):single  ;begin if(pf<>nil)then begin{$I-}BlockRead(pf^,_rudata_single,SizeOf(_rudata_single));if(ioresult<>0)then _rudata_single:=d;{$I+}exit;end;_rudata_single:=net_readsingle end;
function _rudata_timer (pf:pfile):word;
begin
   _rudata_timer:=_rudata_byte(pf,0);
   if(_rudata_timer>0)
   then _rudata_timer:=_rudata_timer*fr_fps-1;
end;

