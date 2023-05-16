
const
ban_forever =  $FFFFFFFF;

procedure net_writeroomsinfo;
var r     :byte;
    pingms:cardinal;
begin
   pingms:=net_readcard;
   net_clearbuffer;
   net_writebyte(nmid_roomsinfo);
   net_writestring(sv_name);
   net_writecard(pingms);
   net_writebyte(sv_maxrooms);
   if(sv_maxrooms>0)then
    for r:=0 to sv_maxrooms-1 do gdataw_roominfo(@_rooms[r],nil);
   net_send(net_lastinip,net_lastinport);
end;

procedure net_sendmappart(pid,p:byte);
var i0,i1:integer;
begin
   if(p>NetMapParts)then exit;

   net_clearbuffer;
   net_writebyte(nmid_sv_mappart);
   net_writebyte(p);

   with _players[pid] do
   with room^ do
   with _maps[mapi] do
   begin
      if(p=0)then net_writestring(mname);

      i0:=p*NetMapPartSize+1;
      i1:=min2(i0+NetMapPartSize,MaxMapBuffer);

      while(i0<=i1)do
      begin
         net_writechar(mbuff[i0]);
         i0+=1;
      end;

      net_send(ip,port);
   end;
end;

procedure net_servercode_snd;
var  r,p,clnum:byte;
  bufposcl,
  bufpos:integer;
   aroom:PTRoom;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)and(bot=false)and(pause_ping=0)then
     begin
        if(ping_t>0)and(ping_r=false)then ping+=sdl_GetTicks-ping_t;
        pause_ping:=fr_2fps;
        ping_r:=false;
        ping_t:=sdl_GetTicks;
        net_clearbuffer;
        net_writebyte(nmid_sv_ping);
        net_writecard(ping_t);
        net_send(ip,port);
     end;

   if(sv_maxrooms>0)then
   for r:=0 to sv_maxrooms-1 do
   begin
      aroom:=@_rooms[r];
      with aroom^ do
      begin
         if(cur_clients<=bot_cur)then continue;

         net_clearbuffer;
         net_writebyte(nmid_sv_snapshot);
         net_writebyte(time_min        );
         net_writebyte(time_sec        );
         _wudata_timer(time_scorepause,nil);
         if(_wudata_timer(vote_time,nil)>0)then
         begin
            net_writestring(vote_cmd);
            net_writestring(vote_arg);
         end;

         bufposcl:=net_bufpos;
         net_writebyte(0);
      end;

      clnum:=0;
      for p:=1 to MaxPlayers do
       with _players[p] do
        if(room=aroom)and(state>ps_none)and(clnum<255)then clnum+=1;

      net_writebyte(clnum);

      if(clnum>0)then
       for p:=1 to MaxPlayers do
        with _players[p] do
         if(room=aroom)and(state>ps_none)then
         begin
            net_writebyte(p);
            net_writebyte(PlayerGetStateByte(p));
            if(state>ps_dead)then
            begin
               net_writesingle(x  );
               net_writesingle(y  );
               net_writesingle(dir);
               net_writebyte  (i2b(hits,Player_max_hits));
            end;
            clnum-=1;
            if(clnum=0)then break;
         end;

      bufpos:=net_bufpos;

      for p:=1 to MaxPlayers do
       with _players[p] do
        if(state>ps_none)and(room=aroom)and(bot=false)and(ttl<fr_fps)and(pause_snap=0)then
        begin
           net_bufpos:=bufposcl;
           net_writebyte(p);
           net_bufpos:=bufpos;

           if(state>ps_dead)then
           begin
              net_writebyte(i2b(armor  ,Player_max_armor  ));
              net_writebyte(i2b(ammo[1],Player_max_ammo[1]));
              net_writebyte(i2b(ammo[2],Player_max_ammo[2]));
              net_writebyte(gun_inv);
           end;

           gdataw_pdata    (aroom,@pdata_player,nil);
           gdataw_roomlog  (aroom,@log_n,@pause_logsend,(ping div fr_RateTicksI)+5,nil);
           gdataw_roomitems(aroom,@mdata_item,nil);

           net_send(ip,port);

           pause_snap:=net_upd_time[net_fupd];
        end;
   end;
end;


procedure net_p_connected(pid:byte);
begin
   with _players[pid] do
   begin
      net_clearbuffer;
      net_writebyte(nmid_sv_connected);
      gdataw_roominfo(room,nil);
      _wudata_word(log_n,nil);
      net_send(ip,port);
   end;
end;
procedure net_p_notconnected(ip:cardinal;port:word);
begin
   net_clearbuffer;
   net_writebyte(nmid_sv_notconnected);
   net_send(ip,port);
end;

function net_readchatmsg:shortstring;
begin
   net_readchatmsg:=net_readstring;
   if(length(net_readchatmsg)>ChatLen)then setlength(net_readchatmsg,ChatLen);
end;

procedure net_ReadPlayerData(pid:byte;full:boolean);
var aid,ateam:byte;
  ax,ay,ad:single;
  lgn:word;
begin
   with _players[pid] do
   begin
      lgn:=net_readword;
      if(lgn>=log_n)or(log_n>room^.log_n)
      then lgn:=room^.log_n;
      log_n:=lgn;

      aid:=net_readbyte;

      wswitch :=(aid and %10000000)>0;
      ateam   :=(aid and %01100000) shr 5;
      net_fupd:=(aid and %00010000)>0;
      antilag :=(aid and %00001000)>0;

      with room^ do
      if(time_scorepause>0)then exit;

      aid:=net_readbyte;//client action

      if(state=ps_spec)and(aid=aid_specjoin)and(ateam<MaxTeams)then team:=ateam;

      if(full)and(state>ps_dead)then
      begin
         ad:=net_readsingle;
         ax:=net_readsingle;
         ay:=net_readsingle;
         player_CheckNewPos(@_players[pid],ax,ay,ad);
      end;

      G_SvDoClientAction(@_players[pid],aid);
   end;
end;


function net_check_bans(ip:cardinal;skip_time:boolean):word;
var b:word;
begin
   net_check_bans:=0;

   if(_bann>0)then
    for b:=0 to _bann-1 do
     with _bans[b] do
      if(ban_ip=ip)then
       if(ban_time>0)or(skip_time)then
       begin
          net_check_bans:=b+1;
          break;
       end;
end;
procedure net_add_ban(ip,time:cardinal;comment:shortstring);
var b:word;
begin
   if(_bann=65535)then exit;
   b:=net_check_bans(ip,true);
   if(b=0)then
   begin
      _bann+=1;
      setlength(_bans,_bann);
      b:=_bann;
   end;
   with _bans[b-1] do
   begin
      ban_ip     :=ip;
      ban_time   :=time;
      ban_comment:=comment;
   end;
end;
procedure net_del_ban(b:word);
begin
   if(b<_bann)then
    with _bans[b] do ban_time:=0;
end;
procedure net_send_bans(ip:cardinal;port:word);
var b,bn:word;
bufpos0,
bufpos1:integer;
begin
   bn:=0;
   net_clearbuffer;
   net_writebyte(nmid_sv_banlist);
   bufpos0:=net_bufpos;
   net_writeword(0);
   if(_bann>0)then
    for b:=0 to _bann-1 do
     with _bans[b] do
      if(ban_time>0)then
      begin
         bn+=1;
         net_writeword(b);
         net_writecard(ban_ip);
         net_writestring(ban_comment);
      end;
   bufpos1:=net_bufpos;
   net_bufpos:=bufpos0;
   net_writeword(bn);
   net_bufpos:=bufpos1;
   net_send(ip,port);
end;
procedure net_send_maplist(room:PTRoom;ip:cardinal;port:word);
var m,i:word;
begin
   net_clearbuffer;
   net_writebyte(nmid_sv_maplist);
   with room^ do
   begin
      net_writeword(maplistn);
      for m:=0 to maplistn-1 do
      begin
         i:=maplist[m];
         if(i>=_mapn)
         then net_writestring('???')
         else net_writestring(_maps[i].mname);
      end;
   end;
   net_send(ip,port);
end;


procedure net_p_new;
var pname,rconp:shortstring;
    pid,
    rid  :byte;
begin
   rid:=net_readbyte;
   if(rid<>ver)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_sv_wrongver);
      net_send(net_lastinip,net_lastinport);
      exit;
   end;
   rid:=net_readbyte;
   if(rid>=sv_maxrooms)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_sv_wrongroom);
      net_send(net_lastinip,net_lastinport);
      exit;
   end;
   pname:=net_readstring;
   if(length(pname)>NameLen)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_sv_badname);
      net_send(net_lastinip,net_lastinport);
      exit;
   end;
   rconp:=net_readstring;
   pid:=net_NewPlayer(net_lastinip,net_lastinport,rid,pname,0,false,rconp=rcon_pass);
   if(pid=0)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_sv_serverfull);
      net_send(net_lastinip,net_lastinport);
      exit;
   end;
   net_p_connected(pid);
end;

procedure net_servercode_rcv;
var vr,
    mid,
    pid:byte;
    pt:cardinal;
begin
   if(_bann>0)then
    for pt:=0 to _bann-1 do
     with _bans[pt] do
      if(0<ban_time)and(ban_time<ban_forever)then ban_time-=1;

   net_clearbuffer;

   while(net_Receive>0)do
   begin
      if(net_check_bans(net_lastinip,false)>0)then continue;

      mid:=net_readbyte;

      case mid of
nmid_roomsinfo : begin
                    vr:=net_readbyte;
                    if(vr<>ver)then
                    begin
                       net_clearbuffer;
                       net_writebyte(nmid_sv_wrongver);
                       net_send(net_lastinip,net_lastinport);
                       continue;
                    end;
                    net_writeroomsinfo;
                    continue;
                 end;
      end;

      pid:=net_Addr2Player(net_lastinip,net_lastinport);

      case mid of
nmid_cl_connect    : if(pid>0)
                     then net_p_connected(pid)
                     else net_p_new;
nmid_cl_disconnect : if(pid>0)then pl_state(@_players[pid],ps_none,true);
nmid_cl_chat       : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else
                      with _players[pid] do
                       if(pause_chat=0)or(rcon_access)then
                       begin
                          pause_chat:=0;//room^.time_pause_chat;
                          _log_add(room,log_chat,name+': '+net_readchatmsg);
                       end
                       else pause_chat+=fr_fps;
nmid_cl_cmd        : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else GameParseCmd(net_readstring,pid);
nmid_cl_maprequest : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else
                     begin
                        vr:=net_readbyte;
                        net_sendmappart(pid,vr);
                     end;
nmid_cl_ping       : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else
                      with _players[pid] do
                      begin
                         pt:=net_readcard;
                         if(pt=ping_t)then
                         begin
                            ping  :=SDL_GetTicks-ping_t;
                            ping_r:=true;
                         end;
                      end;
nmid_sv_ping       : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else
                      with _players[pid] do
                      begin
                         pt:=net_readcard;
                         net_clearbuffer;
                         net_writebyte(nmid_cl_ping);
                         net_writecard(pt);
                         net_send(ip,port);
                      end;
nmid_cl_datap,
nmid_cl_datas      : if(pid=0)
                     then net_p_notconnected(net_lastinip,net_lastinport)
                     else net_ReadPlayerData(pid,mid=nmid_cl_datap);
      end;
   end;
end;

