
{

procedure _wgiodata_string(s:shortstring;pf:pfile);
var sl,x:byte;
       c:char;
begin
   if(pf=nil)
   then net_writestring(s)
   else
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
   end;
end;

procedure _wgiodata_byte(bt:byte    ;pf:pfile);begin if(pf=nil)then net_writebyte  (bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;
procedure _wgiodata_word(bt:word    ;pf:pfile);begin if(pf=nil)then net_writeword  (bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;
procedure _wgiodata_sint(bt:shortint;pf:pfile);begin if(pf=nil)then net_writesint  (bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;
procedure _wgiodata_int (bt:integer ;pf:pfile);begin if(pf=nil)then net_writeint   (bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;
procedure _wgiodata_card(bt:cardinal;pf:pfile);begin if(pf=nil)then net_writecard  (bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;
procedure _wgiodata_single(bt:single;pf:pfile);begin if(pf=nil)then net_writesingle(bt)else begin {$I-} BlockWrite(pf^,bt,SizeOf(bt)); {$I+} end;end;

{
procedure net_svsnap;
var  r,p:byte;
  bufposcl,
  bufpos:integer;
  astate:byte;
   aroom:PTRoom;
begin
   if(sv_maxrooms>0)then
   for r:=0 to sv_maxrooms-1 do
   begin
      aroom:=@_rooms[r];
      with aroom^ do
      begin
         if(cur_clients<=bot_cur)then continue;

         net_clearbuffer;
         net_writebyte(nmid_sv_snapshot);
         net_writeword(time_scorepause );
         net_writecard(time_tick       );

         bufposcl:=net_bufpos;
         net_writebyte(0);
         net_writebyte(cur_clients     );
      end;

      for p:=0 to MaxPlayers do
       with _players[p] do
        if(room=aroom)and(state>ps_none)then
        begin
           net_writebyte(p);

           if(state>ps_dead)and(gun_rld>gun_reload_s[gun_curr])
           then astate:=ps_attk
           else astate:=state;

           if(state>=ps_dead)then astate:=astate or ((team     and %00000011) shl 3);
           if(state> ps_dead)then astate:=astate or ((gun_curr and %00000111) shl 5);

           net_writebyte(astate);
           if(state>ps_dead)then
           begin
              net_writesingle(x  );
              net_writesingle(y  );
              net_writesingle(dir);
              net_writebyte  (byte(mm3i(0,hits,Player_max_hits)));
           end;
        end;

      bufpos:=net_bufpos;

      for p:=1 to MaxPlayers do
       with _players[p] do
        if(state>ps_none)and(room=aroom)and(bot=false)and(ttl<vid_fps)and(pause_snap=0)then
        begin
           net_bufpos:=bufposcl;
           net_writebyte(p);
           net_bufpos:=bufpos;

           if(state>ps_dead)then
           begin
              net_writeint (armor);
              net_writeint (ammo[1]);
              net_writeint (ammo[2]);
              net_writebyte(gun_inv);
           end;

           net_svsnap_pdata (@_players[p]);
           net_svsnap_wlog  (@_players[p]);
           net_svsnap_witems(@_players[p]);

           net_send(ip,port);

           pause_snap:=net_upd_time[net_fupd];
        end;
   end;
end;
}

procedure _wgiodata_snapshot(pf:pfile);
var  r,p:byte;
  bufposcl,
  bufpos:longint;
  astate:byte;
   aroom:PTRoom;
begin
   if(sv_maxrooms>0)then
   for r:=0 to sv_maxrooms-1 do
   begin
      if(pf=nil)
      then net_clearbuffer;

      aroom:=@_rooms[r];
      with aroom^ do
      begin
         if(cur_clients<=bot_cur)then continue;


         net_writebyte(nmid_sv_snapshot);
         net_writeword(time_scorepause );
         net_writecard(time_tick       );

         bufposcl:=net_bufpos;
         net_writebyte(0);
         net_writebyte(cur_clients     );
      end;

   end;
end;

{$IFDEF FULLGAME}

function _rgiodata_string(pf:pfile):shortstring;
var sl,x:byte;
       c:char;
begin
   if(pf=nil)
   then _rgiodata_string:=net_readstring
   else
   begin
      sl:=0;
      _rgiodata_string:='';
      {$I-}
      BlockRead(pf^,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=#0;
         BlockRead(pf^,c,SizeOf(c));
         _rgiodata_string+=c;
      end;
      {$I+}
   end;
end;

function _rgiodata_byte(pf:pfile;def:byte):byte;
begin
   if(pf=nil)
   then _rgiodata_byte:=net_readbyte
   else begin {$I-} BlockRead(pf^,_rgiodata_byte,SizeOf(_rgiodata_byte));if(ioresult<>0)then _rgiodata_byte:=def; {$I+} end;
end;

function _rgiodata_word(pf:pfile;def:byte):word;
begin
   if(pf=nil)
   then _rgiodata_word:=net_readword
   else begin {$I-} BlockRead(pf^,_rgiodata_word,SizeOf(_rgiodata_word));if(ioresult<>0)then _rgiodata_word:=def; {$I+} end;
end;

function _rgiodata_sint(pf:pfile;def:shortint):shortint;
begin
   if(pf=nil)
   then _rgiodata_sint:=net_readsint
   else begin {$I-} BlockRead(pf^,_rgiodata_sint,SizeOf(_rgiodata_sint));if(ioresult<>0)then _rgiodata_sint:=def; {$I+} end;
end;

function _rgiodata_int(pf:pfile;def:integer):integer;
begin
   if(pf=nil)
   then _rgiodata_int:=net_readint
   else begin {$I-} BlockRead(pf^,_rgiodata_int ,SizeOf(_rgiodata_int ));if(ioresult<>0)then _rgiodata_int :=def; {$I+} end;
end;

function _rgiodata_card(pf:pfile;def:cardinal):cardinal;
begin
   if(pf=nil)
   then _rgiodata_card:=net_readcard
   else begin {$I-} BlockRead(pf^,_rgiodata_card,SizeOf(_rgiodata_card));if(ioresult<>0)then _rgiodata_card:=def; {$I+} end;
end;

function _rgiodata_single(pf:pfile;def:single):single;
begin
   if(pf=nil)
   then _rgiodata_single:=net_readsingle
   else begin {$I-} BlockRead(pf^,_rgiodata_single,SizeOf(_rgiodata_single));if(ioresult<>0)then _rgiodata_single:=def; {$I+} end;
end;



{$ENDIF}
         }

