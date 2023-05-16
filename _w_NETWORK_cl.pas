

procedure net_reqroomsinfo;
begin
   sv_ping_str:='--';
   sv_ping    :=sdl_GetTicks;
   menu_update:=true;
   net_clearbuffer;
   net_writebyte(nmid_roomsinfo);
   net_writebyte(ver);
   net_writecard(sv_ping);
   net_send(cl_net_svip,cl_net_svp);
end;

procedure net_disconnect;
begin
   net_clearbuffer;
   net_writebyte(nmid_cl_disconnect);
   net_send(cl_net_svip,cl_net_svp);
   cl_net_cstat:=cstate_none;
   cl_net_stat :=str_nconnected;
   cl_net_roomi:=255;
   menu_update :=true;
end;

procedure net_StartConnect(ri:integer);
begin
   if(cl_net_cstat>cstate_none)then net_disconnect;
   net_period    := 0;
   cl_net_roomi  := ri;
   cl_net_cstat  := cstate_init;
   cl_net_mpartn := 0;
   cl_net_stat   := str_connecting;
   menu_update   := true;
   menu_locmatch := false;
   ResetLocalGame;
   demo_break(_room,'');
   _room^.demo_cstate:=ds_none;
end;

procedure net_sendchat(str:shortstring);
begin
   if(cl_net_cstat<cstate_snap)or(length(str)=0)then exit;

   net_clearbuffer;
   net_writebyte(nmid_cl_chat);
   net_writestring(str);
   net_send(cl_net_svip,cl_net_svp);
end;

procedure net_sendcmd(str:shortstring);
begin
   if(cl_net_cstat<cstate_snap)or(length(str)=0)then exit;

   net_clearbuffer;
   net_writebyte(nmid_cl_cmd);
   net_writestring(str);
   net_send(cl_net_svip,cl_net_svp);
end;

procedure net_ReadSnapShot;
var pn,pi,pl,nstate,pg,
    st  :byte;
    _pi :PTPlayer;
begin
   with _room^ do
   begin
      cur_clients    :=0;
      cur_players    :=0;
      time_min       :=net_readbyte;
      time_sec       :=net_readbyte;
      time_tick      :=(time_min*ticksinminute)+(time_sec*fr_fps);
      time_scorepause:=_rudata_timer(nil);
      vote_time      :=_rudata_timer(nil);
      if(vote_time>0)then
      begin
         vote_cmd:=net_readstring;
         vote_arg:=net_readstring;
      end
      else
      begin
         vote_cmd:='';
         vote_arg:='';
      end;
   end;

   // this player
   cl_playeri:=net_readbyte;
   if(MaxPlayers<cl_playeri)then exit;

   // players number
   pn:=net_readbyte;
   if(MaxPlayers<pn)then exit;

   pi:=0;
   pl:=0;
   while(pn>0)do
   begin
      pi:=net_readbyte;
      if(pi=0)or(MaxPlayers<pi)then exit;
      _pi:=@_players[pi];

      while(pl<pi)do
      begin
         player_Null(pl);
         pl+=1;
      end;
      pl+=1;

      with _pi^ do
      begin
         roomi :=0;
         room  :=_room;
         pnum  :=pi;

         st    :=net_readbyte;
         nstate:=st and %00000111;

         if(nstate>=ps_dead)then team:=(st and %00011000) shr 3;
         if(nstate> ps_dead)then
         begin
            pg:=gun_curr;
            gun_curr:=(st and %11100000) shr 5;

            x   :=net_readsingle;
            y   :=net_readsingle;
            dir :=net_readsingle;
            hits:=net_readbyte;

            if(pi=cl_playeri)then
            begin
               if(player_antilag)and(gun_curr<>pg)then gun_rld:=0;
               if(not cl_buffer_check(x,y))and(room^.time_scorepause=0)then
               begin
                  vx  :=x;
                  vy  :=y;
                  vdir:=dir;
                  if(state<ps_walk)then cam_pl:=cl_playeri;
               end;
            end
            else
              if(state<ps_walk)then
              begin
                 vx  :=x;
                 vy  :=y;
                 vdir:=dir;
              end;
         end;

         pl_state(_pi,nstate,false);

         if(state>ps_none)then _room^.cur_clients+=1;
         if(state>ps_spec)then _room^.cur_players+=1;

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

   with _players[cl_playeri] do
   begin
      roomi:=0;
      room :=_room;
      pnum :=cl_playeri;

      if(state>ps_dead)then
      begin
         armor  :=net_readbyte;
         ammo[1]:=net_readbyte;
         ammo[2]:=net_readbyte;
         gun_inv:=net_readbyte;
      end;

      gdatar_pdata(nil);
      gdatar_roomlog  (_room,nil);
      gdatar_roomitems(_room,nil);
   end;

   if(cam_pl>MaxPlayers)
   then cam_pl:=cl_playeri
   else
     with _players[cam_pl] do
      if(state<=ps_spec)then cam_pl:=cl_playeri;

   if(RoomFlag(_room,sv_g_teams))then
    with _room^ do
    begin
       FillChar(team_frags,SizeOf(team_frags),0);
       for pn:=0 to MaxPlayers do
        with _players[pn] do
         if(state>ps_spec)then team_frags[team]+=frags;
    end;
end;

procedure net_maprequest;
begin
   net_clearbuffer;
   net_writebyte(nmid_cl_maprequest);
   net_writebyte(cl_net_mpartn);
   net_send(cl_net_svip,cl_net_svp);
end;


procedure net_readmappart;
var p:byte;
i0,i1:integer;
   mi:word;
mname:shortstring;
begin
   p:=net_readbyte;

   if(p<>cl_net_mpartn)then exit;

   if(p=0)then
   begin
      menu_update:= true;
      mname      := net_readstring;
      mi         := mname2n(mname);
      if(mi=65535)then mi:=AddMap(mname);
      if(mi=65535)then
      begin
         net_disconnect;
         _log_add(_room,log_local,'Failed to add new map to list!');
         exit;
      end;
      cl_net_mapi:= mi;
   end;
   if(cl_net_mapi>=_mapn)then exit;

   cl_net_maprq_t:=0;

   i0:=p*NetMapPartSize+1;
   i1:=min2(i0+NetMapPartSize,MaxMapBuffer);
   with _maps[cl_net_mapi] do
    while(i0<=i1)do
    begin
       mbuff[i0]:=net_readchar;
       i0+=1;
    end;

   cl_net_mpartn+=1;
   if(cl_net_mpartn>NetMapParts)then
   begin
      map_LoadToRoomByN(_room,cl_net_mapi);
      if(cl_net_mapi>0)
      then map_SaveMap(cl_net_mapi);
      menu_update:=true;
   end;
end;

procedure net_readroomsinfo;
var i:byte;
begin
   sv_name    :=net_readstring;

   sv_ping    :=sdl_GetTicks-net_readcard;
   sv_ping_str:=c2s(sv_ping);

   sv_roomsinfoc:=net_readbyte;
   setlength(sv_roomsinfo,sv_roomsinfoc);
   if(sv_roomsinfoc>0)then
    for i:=0 to sv_roomsinfoc-1 do
     with sv_roomsinfo[i] do
     begin
        rname        :=net_readstring;
        max_clients  :=net_readbyte;
        max_players  :=net_readbyte;
        g_flags      :=net_readcard;
        g_fraglimit  :=net_readint;
        g_timelimit  :=net_readbyte;
        cur_clients  :=net_readbyte;
        cur_players  :=net_readbyte;
        mname        :=net_readstring;
     end;
   menu_update :=true;
end;

procedure net_StopConnection(s:shortstring);
begin
   cl_net_cstat:=cstate_none;
   cl_net_stat :=s;
   cl_net_roomi:=255;
   menu_update :=true;
   _log_add(_room,log_local,cl_net_stat);
   menu_switch(1);
end;

procedure net_read_bans;
var b,bn:word;
  ban_ip,
  ban_comment,
  sstr,
  lstr
        :shortstring;
begin
   lstr:='Banlist: ';
   bn:=net_readword;
   while(bn>0)do
   begin
      b:=net_readword;
      ban_ip:=c2ip(net_readcard);
      ban_comment:=net_readstring;
      sstr:=w2s(b)+':'+ban_ip;
      if(length(ban_comment)>0)then sstr:=sstr+':'+ban_comment;
      sstr+=',';
      if((length(lstr)+length(sstr))>255)then
      begin
         _log_add(_room,log_local,lstr);
         lstr:=sstr;
      end
      else lstr+=sstr;
      bn-=1;
   end;
   if(length(lstr)>0)
   then _log_add(_room,log_local,lstr);
end;

procedure net_read_maplist;
var m:word;
lstr,
mapname:shortstring;
begin
   m:=net_readword;
   lstr:='Maplist('+w2s(m)+'): ';
   while(m>0)do
   begin
      m-=1;
      mapname:=net_readstring;
      if(m>0)then mapname+=',';
      if((length(lstr)+length(mapname))>255)then
      begin
         _log_add(_room,log_local,lstr);
         lstr:=mapname;
      end
      else lstr+=mapname;
   end;
   if(length(lstr)>0)
   then _log_add(_room,log_local,lstr);
end;

procedure net_clientcode;
var mid:byte;
   ping_t:cardinal;
begin
   net_clearbuffer;

   FillChar(net_packetsid_in,SizeOf(net_packetsid_in),0);

   // IN
   while(net_Receive>0)do
   begin
      if(net_LastinIP  <>cl_net_svip)
      or(net_LastinPort<>cl_net_svp )then continue;

      mid:=net_readbyte;

      net_packets_in+=1;
      net_packetsid_in[mid]+=1;

      server_ttl:=0;

      case mid of
nmid_roomsinfo : net_readroomsinfo;
      end;

      if(cl_net_cstat=cstate_none)then continue;

      case mid of
nmid_sv_wrongver    : net_StopConnection(str_wversion);
nmid_sv_wrongroom   : net_StopConnection(str_wroom   );
nmid_sv_serverfull  : net_StopConnection(str_sfull   );
nmid_sv_badname     : net_StopConnection(str_badname );
nmid_sv_banlist     : net_read_bans;
nmid_sv_maplist     : net_read_maplist;

nmid_sv_ping        : begin
                         ping_t:=net_readcard;
                         net_clearbuffer;
                         net_writebyte(nmid_cl_ping);
                         net_writecard(ping_t);
                         net_send(cl_net_svip,cl_net_svp);
                      end;
nmid_cl_ping        : begin
                        ping_t:=net_readcard;
                        if(server_ping_t=ping_t)then
                        begin
                           server_ping  :=SDL_GetTicks-ping_t;
                           server_ping_r:=true;
                        end;
                     end;

nmid_sv_notconnected: if(cl_net_cstat>cstate_init)then
                      net_StartConnect(cl_net_roomi);
nmid_sv_connected   : if(cl_net_cstat=cstate_init)then
                      begin
                         gdatar_roominfo(_room,nil);
                         _room^.log_n :=_rudata_word(nil,_room^.log_n);

                         cl_net_cstat :=cstate_snap;
                         cl_net_stat  :=str_connected;
                         menu_update  :=true;
                      end;
      end;

      if(cl_net_cstat=cstate_snap)then
       case mid of
nmid_sv_snapshot  : net_ReadSnapShot;
nmid_sv_mappart   : net_readmappart;
       end;
   end;

   // OUT
   case cl_net_cstat of
cstate_init  : begin
                  if(net_period=0)then
                  begin
                     net_clearbuffer;
                     net_writebyte  (nmid_cl_connect);
                     net_writebyte  (ver);
                     net_writebyte  (cl_net_roomi);
                     net_writestring(player_name);
                     net_writestring(player_rcon);

                     net_send(cl_net_svip,cl_net_svp);
                  end;

                  net_period+=1;
                  net_period:=net_period mod fr_hfps;
               end;
cstate_snap  : begin
                  if(cl_net_mpartn<=NetMapParts)then
                   if(cl_net_maprq_t>0)
                   then cl_net_maprq_t-=1
                   else
                   begin
                      cl_net_maprq_t:=fr_hfps;
                      net_maprequest;
                   end;

                  server_ttl+=1;
                  if(server_ping_p=0)then
                  begin
                     if(server_ping_t>0)and(server_ping_r=false)and(server_ping<10000)then server_ping+=sdl_GetTicks-server_ping_t;
                     server_ping_p:=fr_2fps;
                     server_ping_r:=false;
                     server_ping_t:=sdl_GetTicks;

                     net_clearbuffer;
                     net_writebyte(nmid_sv_ping);
                     net_writecard(server_ping_t);
                     net_send(cl_net_svip,cl_net_svp);
                  end
                  else server_ping_p-=1;

                  if(net_period=0)then
                  if(cl_playeri<=MaxPlayers)then
                  with _players[cl_playeri] do
                  begin
                     net_clearbuffer;
                     if(state>ps_dead)
                     then net_writebyte(nmid_cl_datap)
                     else net_writebyte(nmid_cl_datas);

                     net_writeword(_room^.log_n);

                     mid:=0;

                     if(state=ps_spec )and(cl_action=aid_specjoin)then mid:=mid or ((player_team shl 5) and %01100000);
                     if(player_wswitch)then mid:=mid or %10000000;
                     if(player_netupd )then mid:=mid or %00010000;
                     if(player_antilag)then mid:=mid or %00001000;

                     net_writebyte(mid);
                     net_writebyte(cl_action);

                     if(state>ps_dead)then
                     begin
                        net_writesingle(vdir);
                        net_writesingle(vx);
                        net_writesingle(vy);
                        cl_buffer_add(vx,vy);
                     end;
                     net_send(cl_net_svip,cl_net_svp);

                     cl_action:=0;
                  end;

                  if(player_netupd)
                  then net_period:=0
                  else
                  begin
                     net_period+=1;
                     net_period:=net_period mod 2;
                  end;
               end;
   end;
end;


