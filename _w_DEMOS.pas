
const
block_word_size = 1000;
map_word_size   = map_mlw*block_word_size; //65000

demo_timer1_period = 2;
demo_timer2_period = fr_fps div demo_timer1_period;

function sX2W(x:single):word;
begin
   sX2W:=mm3w(0,round(x*block_word_size),map_word_size);
end;
function sD2I(x:single):integer;
begin
   sD2I:=round(x*90);
end;

function wX2S(x:word):single;
begin
   wX2S:=x/block_word_size;
end;
function wD2S(x:integer):single;
begin
   wD2S:=x/90;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  COMMON GAME DATA: WRITE
//

procedure gdataw_roominfo(aproom:PTRoom;pf:pfile);
begin
   with aproom^ do
   begin
      _wudata_string(rname      ,pf);
      _wudata_byte  (max_clients,pf);
      _wudata_byte  (max_players,pf);
      _wudata_card  (g_flags    ,pf);
      _wudata_int   (g_fraglimit,pf);
      _wudata_byte  (g_timelimit,pf);
      _wudata_byte  (cur_clients,pf);
      _wudata_byte  (cur_players,pf);
      _wudata_string(mapname    ,pf);
   end;
end;

procedure gdataw_pdata(aproom:PTRoom;pdata_player:pbyte;pf:pfile);
var pb:byte;
    pl:PTPlayer;
begin
   pb:=pdata_player^;
   repeat
      pdata_player^+=1;
      if(pdata_player^>MaxPlayers)then pdata_player^:=0;
      pl:=@_players[pdata_player^];
      if(pl^.room=aproom)and(pl^.state>ps_none)then break;
   until (pdata_player^=pb);
   _wudata_byte(pdata_player^,pf);

   with pl^ do
   begin
      _wudata_word(ping,pf);
      if(state>ps_spec)then _wudata_int(frags,pf);
      _wudata_string(name,pf);
   end;
end;

procedure gdataw_roomlog(aproom:PTRoom;plog_n,pause_var:pword;pause_time:word;pf:pfile);
var li,l,lc:word;
begin
   if(pause_var<>nil)then
     if(pause_var^>0)then
     begin
        _wudata_byte(0,pf);
        exit;
     end;

   if(aproom^.log_n>plog_n^)then
   begin
      lc:=aproom^.log_n-plog_n^;
      if(lc>MaxRoomLog)then lc:=MaxRoomLog;
      if(lc>255       )then lc:=255;
      li:=aproom^.log_i;
      for l:=1 to lc do
       if(li=0)
       then li:=MaxRoomLog
       else li-=1;

      _wudata_byte(lc,pf);
      if(pf<>nil)
      then plog_n^+=lc
      else _wudata_word(aproom^.log_n,pf);
      while(lc>0)do
      begin
         if(li=MaxRoomLog)
         then li:=0
         else li+=1;
         lc-=1;
         _wudata_byte  (aproom^.log_t[li],pf);
         _wudata_string(aproom^.log_l[li],pf);
      end;

      if(pause_var<>nil)then pause_var^:=pause_time;
   end
   else _wudata_byte(0,pf);
end;
procedure gdataw_roomitems_seg(aproom:PTRoom;pmdata_item:pword;pf:pfile);
var b,
    i:byte;
begin
   with aproom^    do
   if(r_itemn>0)then
   begin
      b:=0;
      for i:=0 to 7 do
      begin
         pmdata_item^:=(pmdata_item^+1) mod r_itemn;
         SetBBit(@b,i,r_items[pmdata_item^].irespt<=0);
      end;
      _wudata_byte(b,pf);
   end;
end;
procedure gdataw_roomitems(aproom:PTRoom;pmdata_item:pword;pf:pfile);
begin
   with aproom^    do
   if(r_itemn>0)then
   begin
      if(pf=nil)then
      begin
      _wudata_word(pmdata_item^,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      end;
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
   end;
end;
function PlayerGetStateByte(p:byte):byte;
begin
   PlayerGetStateByte:=0;
   with _players[p] do
   if(state>ps_none)then
   begin
      if(state>ps_dead)and(gun_rld>gun_reload_s[gun_curr])
      then PlayerGetStateByte:=ps_attk
      else PlayerGetStateByte:=state;

      if(state>=ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((team     and %00000011) shl 3);
      if(state> ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((gun_curr and %00000111) shl 5);
   end;
end;

procedure gdataw_gamedata(aproom:PTRoom;pf:pfile);
var p,i:byte;
begin
   with aproom^    do
   begin
      demo_timer1:=(demo_timer1+1) mod demo_timer1_period;
      if(demo_timer1>0)then exit;

      demo_timer2:=(demo_timer2+2) mod demo_timer2_period;

      i:=0;
      for p:=1 to MaxPlayers do
       with _players[p] do
        if(room=aproom)and(state>ps_none)and(i<255)then i+=1;

      _wudata_byte(i,pf);
      if(i>0)then
       for p:=1 to MaxPlayers do
        with _players[p] do
         if(room=aproom)and(state>ps_none)then
         begin
            _wudata_byte(p,pf);

            if(name<>demo_pnames[p])then
            begin
               _wudata_byte(ps_data1,pf);
               _wudata_string(name,pf);
               demo_pnames[p]:=name;
            end
            else
              if(demo_timer2=0  )then
              begin
                 if(state=ps_spec)then
                 begin
                    _wudata_byte(ps_data2,pf);
                    _wudata_word(ping    ,pf);
                 end
                 else
                 begin
                    _wudata_byte(ps_data3,pf);
                    _wudata_word(ping    ,pf);
                    _wudata_int (frags   ,pf);
                 end;
              end
              else
              begin
                 _wudata_byte(PlayerGetStateByte(p),pf);
                 if(state>ps_dead)then
                 begin
                    _wudata_word(sX2W(x  ),pf);
                    _wudata_word(sX2W(y  ),pf);
                    _wudata_int (sD2I(dir),pf);
                    _wudata_byte(i2b(hits,Player_max_hits),pf);
                 end;
            end;

            i-=1;
            if(i=0)then break;
         end;

      gdataw_roomlog(aproom,@demo_logn,nil,0,pf);
      gdataw_roomitems(aproom,@demo_items,pf);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  COMMON GAME DATA: READ
//

{$IFDEF FULLGAME}
procedure demo_addpos(aproom:PTRoom);
var fpos:cardinal;
begin
   with aproom^ do
   if(demo_file<>nil)then
   begin
      fpos:=FilePos(demo_file^);
      if(demo_fpos_n>0)then
        if(demo_fpos_l[demo_fpos_n-1].dp_fpos>=fpos)then exit;

      demo_fpos_n+=1;
      setlength(demo_fpos_l,demo_fpos_n);

      with demo_fpos_l[demo_fpos_n-1] do
      begin
         dp_tick      :=demo_fpos_t;
         dp_fpos      :=fpos;
         dp_time_tick :=time_tick;
         dp_time_scorepause
                      :=time_scorepause;
         dp_demo_items:=demo_items;
      end;
   end;
end;

procedure demo_setpos(aproom:PTRoom;newpos:int64);
var i,ni: cardinal;
   vt,vi: int64;
begin
   with aproom^ do
   if(demo_file<>nil)and(demo_fpos_n>0)then
   begin
      ni:=0;
      vi:=0;
      for i:=0 to demo_fpos_n-1 do
       if(demo_fpos_l[i].dp_tick<=newpos)then
       begin
          vt:=abs(newpos-demo_fpos_l[i].dp_tick);
          if(vt<vi)or(ni=0)then
          begin
             vi:=vt;
             ni:=i;
          end;
       end;

      with demo_fpos_l[ni] do
      begin
         time_tick:=dp_time_tick;
         time_SecMin(aproom);

         time_scorepause:=dp_time_scorepause;
         demo_items:=dp_demo_items;

         demo_fpos_t:=dp_tick;

         Seek(demo_file^,dp_fpos);
      end;

      demo_skip:=2;
   end;
end;

procedure demos_RemakeList;
var Info : TSearchRec;
       s : shortstring;
begin
   demos_n:=0;
   setlength(demos_l,0);
   setlength(demos_s,0);

   if(FindFirst(str_demofolder+'*'+str_demoext,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       if(s<>'')then
       begin
          demos_n+=1;
          setlength(demos_l,demos_n);
          setlength(demos_s,demos_n);
          demos_l[demos_n-1]:=s;
          demos_s[demos_n-1]:=li2s(info.Size);
       end;
       if(demos_n>=65534)then break;
    until(FindNext(info)<>0);
   FindClose(info);
end;

procedure gdatar_roominfo(aproom:PTRoom;pf:pfile);
begin
   with aproom^ do
   begin
      rname      :=_rudata_string(pf);
      max_clients:=_rudata_byte  (pf,0);
      max_players:=_rudata_byte  (pf,0);
      g_flags    :=_rudata_card  (pf,0);
      g_fraglimit:=_rudata_int   (pf,0);
      g_timelimit:=_rudata_byte  (pf,0);
      cur_clients:=_rudata_byte  (pf,0);
      cur_players:=_rudata_byte  (pf,0);
      mapname    :=_rudata_string(pf);
   end;
end;

procedure gdatar_pdata(pf:pfile);
var pd:byte;
begin
   pd:=_rudata_byte(pf,0);
   if(pd<=MaxPlayers)then
   with _players[pd] do
   begin
      ping :=_rudata_word(pf,0);
      if(state>ps_spec)then
      frags:=_rudata_int(pf,0);
      name :=_rudata_string(pf);
   end;
end;

procedure gdatar_roomlog(aproom:PTRoom;pf:pfile);
var pl,pd:word;
    logt:byte;
begin
   pl:=_rudata_byte(pf,0);
   if(pl>0)then
   begin
      if(pf=nil)then pd:=_rudata_word(pf,0);
      while(pl>0)do
      begin
         logt:=_rudata_byte(pf,0);
         _log_add(aproom,logt,_rudata_string(pf));
         pl-=1;
      end;
      if(pf=nil)then aproom^.log_n:=pd;
   end;
end;

procedure gdatar_roomitems_seg(aproom:PTRoom;pitem:pword;pf:pfile);
var b,
    i :byte;
begin
   with aproom^ do
   begin
      b:=_rudata_byte(pf,0);
      for i:=0 to 7 do
      begin
         pitem^:=(pitem^+1) mod r_itemn;
         r_items[pitem^].irespt:=integer(not GetBBit(@b,i));
      end;
   end;
end;
procedure gdatar_roomitems(aproom:PTRoom;pf:pfile);
var item:word;
   pitem:pword;
begin
   with aproom^ do
   if(r_itemn>0)then
   begin
      if(pf=nil)then
      begin
         item :=_rudata_word(pf,0);
         pitem:=@item;
      end
      else pitem:=@demo_items;

      if(pf=nil)then
      begin
      gdatar_roomitems_seg(aproom,pitem,pf);
      gdatar_roomitems_seg(aproom,pitem,pf);
      gdatar_roomitems_seg(aproom,pitem,pf);
      end;
      gdatar_roomitems_seg(aproom,pitem,pf);
   end;
end;

procedure player_Null(pi:byte);
begin
   with _players[pi] do
   begin
      roomi:=0;
      room :=_room;
      pnum :=pi;
   end;
   pl_state(@_players[pi],ps_none,false);
end;

procedure gdatar_gamedata(aproom:PTRoom;pf:pfile);
var pi,pl,pn,st,nstate:byte;
    _pi:PTPlayer;
begin
   with aproom^ do
   begin
      demo_fpos_t+=1;
      if((demo_fpos_t mod fr_5fps)=0)
      then demo_addpos(aproom);

      if(time_scorepause<=0)and(cur_players>0)then
      begin
         time_tick+=1;
         time_SecMin(aproom);
      end;

      cur_clients    :=0;
      cur_players    :=0;

      demo_timer1:=(demo_timer1+1) mod demo_timer1_period;
      if(demo_timer1>0)then exit;
   end;

   pn  :=_rudata_byte(pf,0);

   if(MaxPlayers<pn)then
   begin
      demo_break(aproom,'wrong game data');
      exit;
   end;

   pi:=0;
   pl:=1;
   while(pn>0)do
   begin
      pi:=_rudata_byte(pf,0);
      if(pi=0)or(MaxPlayers<pi)then
      begin
         demo_break(aproom,'wrong game data');
         exit;
      end;
      _pi:=@_players[pi];

      while(pl<pi)do
      begin
         player_Null(pl);
         pl+=1;
      end;
      pl+=1;

      with _pi^ do
      begin
         roomi :=aproom^.rnum;
         room  :=aproom;
         pnum  :=pi;

         st    :=_rudata_byte(pf,0);
         nstate:=st and %00000111;

         case nstate of
ps_data1 : name :=_rudata_string(pf);
ps_data2 : ping :=_rudata_word(pf,9999);
ps_data3 : begin
           ping :=_rudata_word(pf,9999);
           frags:=_rudata_int (pf,0);
           end;
         else
           if(nstate>=ps_dead)then team:=(st and %00011000) shr 3;
           if(nstate> ps_dead)then
           begin
              gun_curr:=(st and %11100000) shr 5;

              x   :=wX2S(_rudata_word(pf,0));
              y   :=wX2S(_rudata_word(pf,0));
              dir :=wD2S(_rudata_int (pf,0));
              hits:=     _rudata_byte(pf,0);

              if(state<ps_walk)then
              begin
                 vx  :=x;
                 vy  :=y;
                 vdir:=dir;
              end;
           end;

           pl_state(_pi,nstate,false);
         end;

         if(state>ps_none)then aproom^.cur_clients+=1;
         if(state>ps_spec)then aproom^.cur_players+=1;

         armor   :=0;
         ammo[1] :=1;
         ammo[2] :=1;
         gun_next:=gun_curr;
         gun_inv :=255;
      end;

      pn-=1;
   end;

   pi+=1;
   while(pi<=MaxPlayers)do
   begin
      player_Null(pi);
      pi+=1;
   end;

   gdatar_roomlog(aproom,pf);
   gdatar_roomitems(aproom,pf);
end;

{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
//  DEMOS
//

procedure demo_init_data(aproom:PTRoom);
begin
   with aproom^ do
   begin
      demo_fstate:=ds_none;
      demo_cstate:=ds_none;
      demo_file  :=nil;
      demo_fname :='';
      demo_head  :=true;
      demo_items :=0;
      demo_ppause:=0;
   end;
end;

function demo_make_fname(aproom:PTRoom):shortstring;
begin
   with aproom^ do demo_make_fname:=
   {$IFDEF FULLGAME}
   'C'
   {$ELSE}
   'SR'+b2s(rnum+1)
   {$ENDIF}
   +'_'+DateTimeStr+'_'+mapname+str_demoext;
end;

procedure demo_break(aproom:PTRoom;error_msg:shortstring);
begin
   with aproom^ do
   begin
      if(demo_file<>nil)then
      begin
         if(length(error_msg)>0)then _log_add(aproom,log_local,'demo processing break ['+error_msg+'] ('+demo_fname+')');

         close(demo_file^);
         dispose(demo_file);
         if(demo_fstate=ds_read )then _log_add(aproom,log_local,'demo: stop play ('+demo_fname+')');
         if(demo_fstate=ds_write)then _log_add(aproom,log_local,'demo: stop record ('+demo_fname+')');

         demo_fpos_n:=0;
         setlength(demo_fpos_l,demo_fpos_n);
      end;
      demo_file  :=nil;
      demo_fname :='';
      demo_fstate:=ds_none;
      demo_ppause:=fr_fps;
   end;
end;

procedure demo_Processing(aproom:PTRoom);
var v:byte;
    t:shortstring;
   mi:word;
begin
   with aproom^ do
   begin
      if (demo_fstate >ds_none)
      and(demo_cstate >ds_none)
      and(demo_fstate<>demo_cstate)then demo_break(aproom,'');

      if(demo_ppause>0)then
      begin
         demo_ppause-=1;
         exit;
      end;

      case demo_cstate of
ds_none : demo_break(aproom,'');
ds_write: begin
             if(demo_file=nil)then
             begin
                new(demo_file);
                demo_fname:=str_demofolder+demo_make_fname(aproom);
                _log_add(aproom,log_local,'demo: start record ('+demo_fname+')');
                assign(demo_file^,demo_fname);
                {$I-}
                rewrite(demo_file^,1);
                {$I+}
                if(ioresult<>0)then
                begin
                   demo_break(aproom,'ds_write,ioresult='+w2s(ioresult));
                   exit;
                end;
                demo_fstate:=ds_write;
                demo_head  :=true;
             end;
             if(demo_head)then
             begin
                demo_logn:=log_n;
                _wudata_byte(ver,demo_file);
                gdataw_roominfo(aproom,demo_file);
                _wudata_byte(time_min,demo_file);
                _wudata_byte(time_sec,demo_file);
                {$I-}
                with _maps[mapi] do
                BlockWrite(demo_file^,mbuff,SizeOf(mbuff));
                {$I+}
                demo_head  :=false;
                demo_items :=0;
                demo_timer2:=0;
                FillChar(demo_pnames,SizeOf(demo_pnames),0);
             end;
             gdataw_gamedata(aproom,demo_file);
             if(ioresult<>0)then
             begin
                demo_break(aproom,'ds_write,ioresult='+w2s(ioresult));
                exit;
             end;
          end;
{$IFDEF FULLGAME}
ds_read : begin
             if(demo_file=nil)then
             begin
                t:=str_demofolder+demo_fname;
                _log_add(aproom,log_local,'demo: start play ('+t+')');
                if(not FileExists(t))then
                begin
                   demo_cstate:=ds_none;
                   _log_add(aproom,log_local,'demo: file don`t exists ('+t+')');
                   exit;
                end;
                new(demo_file);
                assign(demo_file^,t);
                {$I-}
                reset(demo_file^,1);
                {$I+}
                if(ioresult<>0)then
                begin
                   demo_break(aproom,'ds_read,ioresult='+w2s(ioresult));
                   exit;
                end;
                demo_size:=FileSize(demo_file^);
                demo_head:=true;
                demo_fstate:=ds_read;
                ResetLocalGame;
                menu_switch(0);
             end;
             if(demo_head)then
             begin
                v:=_rudata_byte(demo_file,0);
                if(v<>ver)then
                begin
                   demo_break(aproom,'wrong version');
                   exit;
                end;
                gdatar_roominfo(aproom,demo_file);
                time_min :=_rudata_byte(demo_file,0);
                time_sec :=_rudata_byte(demo_file,0);
                time_tick:=(time_min*TicksPerMinute)+(time_sec*fr_fps);
                mi       := mname2n(mapname);
                if(mi=65535)then mi:=AddMap(mapname);
                if(mi=65535)then mi:=0;
                with _maps[mi] do
                begin
                {$I-}
                BlockRead(demo_file^,mbuff,SizeOf(mbuff));
                {$I+}
                mname:=mapname;
                end;
                map_LoadToRoomByN(_room,mi);
                if(mi=0)
                then map_AddDefault
                else map_SaveMap(mi);
                _players[0].name:='Demo observer';
                pl_state(@_players[0],ps_spec,false);
                PlayerMoveToSpawn(@_players[0]);
                demo_items:=0;
                demo_head :=false;
                demo_play_pause:=false;
                demo_skip:=0;
                demo_addpos(aproom);
             end;
             if(game_mode=0)then
             begin
                if(demo_skip=0)and(not demo_play_pause)then demo_skip:=1;
                while(demo_skip>0)do
                begin
                   gdatar_gamedata(aproom,demo_file);
                   demo_skip-=1;
                end;
             end;
             if(eof(demo_file^)or(ioresult<>0))then
             begin
                demo_break(aproom,'demo end');
                demo_cstate:=ds_none;
                menu_update:=true;
             end;
          end;
{$ENDIF}
      end;
   end;
end;
{$IFDEF FULLGAME}
procedure demos_PlayDemo(demo_name:shortstring);
begin
   with _room^ do
   begin
      if(cl_net_cstat>0)
      or(menu_locmatch)then exit;

      demo_break(_room,'');
      demo_ppause:=2;

      demo_fname :=demo_name;
      demo_cstate:=ds_read;
   end;
end;
{$ENDIF}


