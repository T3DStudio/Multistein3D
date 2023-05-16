
procedure map_AddDefault;
const DefMapBuf  : shortstring =
'444444AAAAAA'+
' ACAAmBBmAACA'+#13+
'E4    36    4N'+#13+
'H b3E     1b O'+#13+
'E 1<E    A^3 N'+#13+
'E  EF    BAA N'+#13+
'l    5  5    o'+#13+
'F6    28     P'+#13+
'F3    09    6P'+#13+
'l    5  5   3o'+#13+
'E IIK    PN  N'+#13+
'E 3.I    N>1 N'+#13+
'H b1     N3b O'+#13+
'E4    63    4N'+#13+
' IJIIsKKsIIJI'+#0;
var iw,sl:byte;
begin
   if(_mapn=0)then
   begin
      _mapn+=1;
      setlength(_maps,_mapn);
   end;

   sl:=length(DefMapBuf);
   with _maps[0] do
   begin
      mname:='.default';
      FillChar(mbuff,SizeOf(mbuff),#0);
      for iw:=1 to sl do mbuff[iw]:=DefMapBuf[iw];
   end;
end;

procedure map_AddFromFile(fn:shortstring);
var f   :text;
    s   :shortstring;
    i,sl:byte;
    w,t :word;
begin
   s:=str_mapfolder+fn;
   if(FileExists(s))then
   begin
      assign(f,s);
      {$I-}
      reset(f);
      {$I+}
      if(IOResult<>0)then
      begin
         close(f);
         exit;
      end;

      AddMap(RMExt(fn));

      t:=0;
      w:=0;
      while (not eof(f))and(w<MaxMapBuffer) do
      begin
         t+=1;
         {$I-}
         readln(f,s);
         {$I+}
         sl:=length(s);

         if(t=1)then
         begin
            if(sl>12)then setlength(s,12);
            while(sl<12)do
            begin
               sl+=1;
               s :=s+'0';
            end;
         end
         else
         begin
            if(sl>map_mw)then
            begin
               setlength(s,map_mw);
               sl:=map_mw;
            end;
            if(sl<map_mw)then
            begin
               sl+=1;
               s :=s+#13;
            end;
         end;

         if(sl>0)then
          for i:=1 to sl do
           if(w<MaxMapBuffer)then
           begin
              w+=1;
              _maps[_mapn-1].mbuff[w]:=s[i];
           end;

         if(IOResult<>0)then break;
      end;

      close(f);

      if(w<MaxMapBuffer)then _maps[_mapn-1].mbuff[w]:=#0;
   end;
end;

procedure map_LoadAll;
var Info : TSearchRec;
       s : shortstring;
begin
   _mapn:=0;
   setlength(_maps,0);

   map_AddDefault;

   if(FindFirst(str_mapfolder+'*'+str_mapext,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       if(s<>'')then map_AddFromFile(s);
       if(_mapn>=65534)then break;
    until (FindNext(info)<>0);
   FindClose(info);
end;

procedure map_SaveMap(mi:word);
var f:text;
    s:shortstring;
    p,n:word;
begin
   if(mi>=_mapn)then exit;

   with _maps[mi] do
   begin
      s:=str_mapfolder+mname+str_mapext;

      assign(f,s);
      {$I-}
      rewrite(f);
      {$I+}
      if(IOResult<>0)then
      begin
         close(f);
         exit;
      end;

      p:=1;
      n:=0;
      while(mbuff[p]<>#0)and(p<=MaxMapBuffer)do
      begin
         if(p<=12)then
         begin
            write(f,mbuff[p]);
            if(p=12)then writeln(f);
         end
         else
         begin
            if(mbuff[p]=#13)or(n=map_miw)then
            begin
               if(mbuff[p]<>#13)then write(f,mbuff[p]);
               writeln(f);
               n:=0;
            end
            else
            begin
               write(f,mbuff[p]);
               n+=1;
            end;
         end;

         p+=1;
      end;

      close(f);
   end;
end;


