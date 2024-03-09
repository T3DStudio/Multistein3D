
procedure map_AddDefault;
begin
   if(g_mapn=0)then
   begin
      g_mapn+=1;
      setlength(g_maps,g_mapn);
   end;

   with g_maps[0] do
   begin
      mname:='sd1.default';
      FillChar(mbuff,SizeOf(mbuff),#0);

      move(DefaultMap^,mbuff,length(DefaultMap));
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

      map_new(str_RemoveExt(fn));

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
               s :=s+str_NewLineChar;
            end;
         end;

         if(sl>0)then
          for i:=1 to sl do
           if(w<MaxMapBuffer)then
           begin
              w+=1;
              g_maps[g_mapn-1].mbuff[w]:=s[i];
           end;

         if(IOResult<>0)then break;
      end;

      close(f);

      if(w<MaxMapBuffer)then g_maps[g_mapn-1].mbuff[w]:=#0;
   end;
end;

procedure map_LoadAll;
var Info : TSearchRec;
       s : shortstring;
begin
   g_mapn:=0;
   setlength(g_maps,0);

   map_AddDefault;

   if(FindFirst(str_mapfolder+'*'+str_mapext,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       if(length(s)>0)then map_AddFromFile(s);
       if(g_mapn>=65534)then break;
    until (FindNext(info)<>0);
   FindClose(info);
end;

procedure map_SaveMap(mi:word);
var f:text;
    s:shortstring;
    p,n:word;
begin
   if(mi>=g_mapn)then exit;

   with g_maps[mi] do
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
            if(mbuff[p]=str_NewLineChar)or(n=map_miw)then
            begin
               if(mbuff[p]<>str_NewLineChar)then write(f,mbuff[p]);
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


