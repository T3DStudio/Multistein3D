
procedure room_KickPlayers(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(room=aroom)and(state>ps_none)then pl_state(@_players[p],ps_none,false);
   with aroom^ do FillChar(team_frags,SizeOf(team_frags),0);
end;

procedure room_SpecPlayers(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(room=aroom)and(state>ps_none)then
      pl_state(@_players[p],ps_spec,false);
end;

procedure room_ResetPlayers(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(room=aroom)and(state>ps_spec)then PlayerReset(@_players[p]);
end;

procedure room_ResetObjects(aroom:PTRoom);
var i:word;
begin
   with aroom^ do
   begin
      if(r_itemn>0)then
       for i:=0 to r_itemn-1 do
        with r_items[i] do irespt:=0;
   end;
end;

procedure time_SecMin(aroom:PTRoom);
begin
   with aroom^ do
   begin
      time_min_prev:=time_min;
      time_sec:=(time_tick div fr_fps) mod 60;
      time_min:=time_tick div ticksinminute;
   end;
end;

procedure room_Reset(aroom:PTRoom;kick:boolean);
begin
   if(kick)
   then room_KickPlayers(aroom)
   else room_SpecPlayers(aroom);
   room_ResetObjects (aroom);
   with aroom^ do
   begin
      FillChar(team_frags,SizeOf(team_frags),0);
      time_scorepause:=0;
      time_tick  :=0;
      demo_break(aroom,'room reset');
   end;
   time_SecMin(aroom);
   {$IFDEF FULLGAME}
   ClearClientEffects;
   {$ENDIF}
end;

procedure room_ResetMatch(aroom:PTRoom);
begin
   with aroom^ do
   begin
      time_scorepause:=0;
      time_tick:=0;
   end;
   time_SecMin(aroom);
   room_ResetObjects (aroom);
   with aroom^ do FillChar(team_frags,SizeOf(team_frags),0);
   room_ResetPlayers(aroom);
   _log_add(aroom,log_endgame,str_resetmatch);
   {$IFDEF FULLGAME}
   ClearClientEffects;
   {$ENDIF}
end;

procedure Room_KickBots(aroom:PTRoom;team_name:shortstring);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(room=aroom)and(state>ps_none)and(bot)then
      pl_state(@_players[p],ps_none,true);
   with aroom^ do
    if(length(team_name)=0)
    then FillChar(bot_maxt,sizeof(bot_maxt),0)
    else
      for p:=0 to MaxTeamsI do
       if(str_teams[p]=team_name)then bot_maxt[p]:=0;
end;
procedure Room_AddBot(aroom:PTRoom;team_name:shortstring);
var p:byte;
begin
   with aroom^ do
    if(length(team_name)=0)
    then bot_maxt[random(MaxTeams)]+=1
    else
      for p:=0 to MaxTeamsI do
       if(str_teams       [p]=team_name)
       or(str_teams_shorts[p]=team_name)then bot_maxt[p]+=1;
end;

procedure room_ClearLog(aroom:PTRoom);
begin
   with aroom^ do
   begin
      {$IFNDEF FULLGAME}
      FillChar(log_l,SizeOf(log_l),0);
      log_i:=0;
      {$ENDIF}
      log_n:=0;
   end;
end;

procedure room_Default(aroom:PTRoom);
begin
   room_KickPlayers(aroom);
   room_ClearLog   (aroom);

   with aroom^ do
   begin
      FillChar(rgrid,SizeOf(rgrid),0);
      setlength(r_items ,0);r_itemn :=0;
      setlength(r_spawns,0);r_spawnn:=0;
      setlength(maplist ,0);maplistn:=0;

      maplisti    :=0;
      cur_clients :=0;
      cur_players :=0;
      max_clients :=MaxPlayers;
      max_players :=MaxPlayers;
      g_fraglimit :=0;
      g_timelimit :=0;
      g_flags     :=0;
      time_tick   :=0;
      time_sec    :=0;
      time_min    :=0;
      rname       :='Default room';
      g_scorepause:=fr_fps*30;
      g_deathtime :=fr_fps*10;
      scores_save_need:=false;
      vote_ratio  := 0.5;
      vote_time   := 0;
      vote_cmd    := '';

      bot_cur     :=0;
      FillChar(bot_curt  ,SizeOf(bot_curt  ),0);
      FillChar(bot_maxt  ,SizeOf(bot_maxt  ),0);
      FillChar(team_frags,SizeOf(team_frags),0);

      {$IFDEF FULLGAME}
      setlength(r_decors,0);r_decorn:=0;
      {$ENDIF}
   end;
end;

procedure room_AddSpawn(aroom:PTRoom;x,y:integer;tp:char);
begin
   with aroom^ do
   if(r_spawnn<65535)then
   begin
      r_spawnn+=1;
      setlength(r_spawns,r_spawnn);

      with r_spawns[r_spawnn-1] do
      begin
         spx := x+0.5;
         spy := y+0.5;
         case tp of
         '>' : spdir:=0;
         '^' : spdir:=270;
         '<' : spdir:=180;
         '.' : spdir:=90;
         else  spdir:=r_spawnn*45;
         end;
      end;
   end;
end;

procedure room_AddItem(aproom:PTRoom;x,y:integer;tp:char);
begin
   with aproom^ do
   if(r_itemn<65535)then
   begin
      r_itemn+=1;
      setlength(r_items,r_itemn);

      FillChar(r_items[r_itemn-1],Sizeof(TItem),0);

      with r_items[r_itemn-1] do
      begin
         case tp of
         '0' : begin  // armor
                  iarmor  := 50;
                  irespm  := fr_fps*30;
               end;
         '1' : begin  // mp40
                  iweapon := gun_bit[2];
                  iammo[1]:= 15;
                  irespm  := fr_fps*10;
               end;
         '2' : begin  // chaingun
                  iweapon := gun_bit[3];
                  iammo[1]:= 30;
                  irespm  := fr_fps*20;
               end;
         '3' : begin  // ammo
                  iammo[1]:= 5;
                  irespm  := fr_fps*10;
               end;
         '4' : begin  // big ammo
                  iammo[1]:= 40;
                  iammo[2]:= 5;
                  irespm  := fr_fps*20;
               end;
         '5' : begin  // dog food
                  ihealth := 5;
                  irespm  := fr_fps*10;
               end;
         '6' : begin  // food
                  ihealth := 10;
                  irespm  := fr_fps*15;
               end;
         '7' : begin  // health
                  ihealth := 20;
                  irespm  := fr_fps*20;
               end;
         '8' : begin  // mega
                  ihealth := 100;
                  iarmor  := 50;
                  irespm  := fr_fps*30;
               end;
         '9' : begin  // rifle
                  iweapon := gun_bit[4];
                  iammo[2]:= 5;
                  irespm  := fr_fps*10;
               end;
         else
         end;

         ix:=x+0.5;
         iy:=y+0.5;
         itype :=tp;
      end;
   end;
end;


function Room_GetWinner(aroom:PTRoom;logstr:pshortstring):boolean; // true if single winner
var p,wp1    :byte;
      wf1,wf2:integer;
begin
   with aroom^ do
   begin
      wf1:=-32000;
      wp1:=255;
      wf2:=-32000;
      if(RoomFlag(aroom,sv_g_teams))then
      begin
         for p:=0 to MaxTeamsI do
          if(team_frags[p]>=wf1)then
          begin
             wf2:=wf1;
             wp1:=p;
             wf1:=team_frags[p];
          end;
         if(wp1<255)and(logstr<>nil)then logstr^:=str_teams[wp1]+' '+str_team+' '+str_cwin+' (score: '+i2s(wf1)+')';
      end
      else
      begin
         for p:=0 to MaxPlayers do
          with _players[p] do
           if(state>ps_spec)and(aroom=room)and(frags>=wf1)then
           begin
              wf2:=wf1;
              wp1:=p;
              wf1:=frags;
           end;
         if(wp1<255)and(logstr<>nil)then logstr^:=_players[wp1].name+str_cwin+' (score: '+i2s(wf1)+')';
      end;
   end;
   Room_GetWinner:=wf1<>wf2;
end;

function str2RFlags(s:shortstring):cardinal;
begin
   str2RFlags:=0;
   if(pos('I',s)>0)then str2RFlags:=str2RFlags or sv_g_instagib;
   if(pos('T',s)>0)then str2RFlags:=str2RFlags or sv_g_teams;
   if(pos('R',s)>0)then str2RFlags:=str2RFlags or sv_g_itemrespawn;
   if(pos('W',s)>0)then str2RFlags:=str2RFlags or sv_g_weaponstay;
   if(pos('M',s)>0)then str2RFlags:=str2RFlags or sv_g_randommap;
   if(pos('D',s)>0)then str2RFlags:=str2RFlags or sv_g_teamdamage;
   if(pos('V',s)>0)then str2RFlags:=str2RFlags or sv_g_voting;
   if(pos('O',s)>0)then str2RFlags:=str2RFlags or sv_g_recording;
   if(pos('S',s)>0)then str2RFlags:=str2RFlags or sv_g_screensave;
end;
function RFlags2Str(f:cardinal):shortstring;
begin
   RFlags2Str:='--------';
   if((f and sv_g_instagib   )>0)then RFlags2Str[1]:='I'
   else
   begin
   if((f and sv_g_itemrespawn)>0)then RFlags2Str[1]:='R';
   if((f and sv_g_weaponstay )>0)then RFlags2Str[2]:='W';
   end;
   if((f and sv_g_teams      )>0)then RFlags2Str[3]:='T';
   if((f and sv_g_teamdamage )>0)then RFlags2Str[4]:='D';
   if((f and sv_g_randommap  )>0)then RFlags2Str[5]:='M';
   if((f and sv_g_voting     )>0)then RFlags2Str[6]:='V';
   if((f and sv_g_recording  )>0)then RFlags2Str[7]:='O';
   if((f and sv_g_screensave )>0)then RFlags2Str[8]:='S';
end;

{$IFNDEF FULLGAME}
procedure Room_WriteScores(aroom:PTRoom);
var flines  : array of shortstring;
    s,
    flinen  : word;
    fname   : shortstring;
    f       : text;
    teamplay: boolean;
procedure _line(s:shortstring);
begin
   flinen+=1;
   setlength(flines,flinen);
   flines[flinen-1]:=s;
end;
begin
   with aroom^ do
   if(scores_save_need)then
   begin
      flinen:=0;
      setlength(flines,flinen);

      fname   :='r'+b2s(rnum+1)+'_'+DateTimeStr+'_'+mapname+'.csv';
      teamplay:=RoomFlag(aroom,sv_g_teams);

      {$I-}
      assign(f,fname);
      rewrite(f);
      {$I+}
      if(ioresult=0)then
      begin
         _line(rcfg_servername+';'+sv_name    );
         _line(rcfg_roomname  +';'+rname      );
         _line(rcfg_maxplayers+';'+b2s(max_players));
         _line(rcfg_maxclients+';'+b2s(max_clients));
         _line(rcfg_timelimit +';'+c2s(g_timelimit));
         _line(rcfg_fraglimit +';'+i2s(g_fraglimit));
         _line(rcfg_flags     +';'+RFlags2Str(g_flags));
         _line('TIME'         +';'+w2s(time_min)+':'+w2s(time_sec));
         _line('');
         _line(scores_message);
         _line('');

         if(teamplay)then
         begin
            _line('TEAM;SCORE');
            for S:=0 to MaxTeamsI do _line(str_teams[S]+';'+i2s(team_frags[S]));
            _line('');
            _line('NAME;SCORE;TEAM');
         end
         else _line('NAME;SCORE');

         for S:=0 to MaxPlayers do
          with _players[S] do
           if(state>ps_spec)and(roomi=rnum)then
            if(teamplay)
            then _line(name+';'+i2s(frags)+';'+str_teams[team])
            else _line(name+';'+i2s(frags));

         _line('');
         _line('SPECTATORS');
         for S:=0 to MaxPlayers do
          with _players[S] do
           if(state=ps_spec)and(roomi=rnum)then _line(name);

         if(flinen>0)then
          for s:=0 to flinen-1 do
           writeln(f,flines[s]);
         close(f);
      end;

      scores_message  :='';
      scores_save_need:=false;
   end;
end;
{$ENDIF}

procedure Room_Score(aroom:PTRoom);
var winnerstr:shortstring;
begin
   aroom^.time_scorepause:=aroom^.g_scorepause;

   Room_GetWinner(aroom,@winnerstr);
   if(length(winnerstr)>0)
   then _log_add(aroom,log_winner,winnerstr);

   {$IFNDEF FULLGAME}
   Room_WriteScores(aroom);
   {$ENDIF}
end;

procedure room_Timer(aroom:PTRoom);
begin
   with aroom^ do
   if(cur_players>0)then
   begin
      time_tick+=1;
      time_SecMin(aroom);

      if(g_timelimit>0)then
       if(time_min>=g_timelimit)then
        if(Room_GetWinner(aroom,nil))then
        begin
           _log_add(aroom,log_endgame,str_timelimithit);
           Room_Score(aroom);
        end
        else
          if(time_min=g_timelimit)and(time_min_prev<time_min)then _log_add(aroom,log_endgame,str_suddendeath);
   end
   else
   begin
      time_tick:=0;
      time_SecMin(aroom);
   end;
end;

procedure room_Objects(aroom:PTRoom);
var i:word;
begin
   with aroom^ do
   begin
      if(r_itemn>0)then
       if(RoomFlag(aroom,sv_g_itemrespawn))then
        for i:=0 to r_itemn-1 do
         with r_items[i] do
          if(irespt>0)then irespt-=1;
   end;
end;

{$IFDEF FULLGAME}
procedure room_AddDecor(aproom:PTRoom;x,y:integer;tp:char);
begin
   with aproom^ do
   if(r_decorn<65535)then
   begin
      r_decorn+=1;
      setlength(r_decors,r_decorn);

      with r_decors[r_decorn-1] do
      begin
         dx:=x+0.5;
         dy:=y+0.5;
         t :=tp;
      end;
   end;
end;

function _hex2b(c:char):byte;
begin
   case c of
   '1'     : _hex2b:=$1;
   '2'     : _hex2b:=$2;
   '3'     : _hex2b:=$3;
   '4'     : _hex2b:=$4;
   '5'     : _hex2b:=$5;
   '6'     : _hex2b:=$6;
   '7'     : _hex2b:=$7;
   '8'     : _hex2b:=$8;
   '9'     : _hex2b:=$9;
   'A','a' : _hex2b:=$A;
   'B','b' : _hex2b:=$B;
   'C','c' : _hex2b:=$C;
   'D','d' : _hex2b:=$D;
   'E','e' : _hex2b:=$E;
   'F','f' : _hex2b:=$F;
   else
   _hex2b:=$00;
   end;
end;
{$ENDIF}

procedure map_LoadToRoomByN(aproom:PTRoom;im:word);
var ix,iy
    {$IFDEF FULLGAME}
    ,r,g,b
    {$ENDIF}
       :byte;
    iw :word;
begin
   if(im>=_mapn)then exit;

   ix:=1;
   iy:=1;

   with aproom^ do
   with _maps[im] do
   begin
      mapname:=mname;
      mapi:=im;

      _log_add(aproom,log_map,'map: '+mname);

      FillChar(rgrid,SizeOf(rgrid),0);
      setlength(r_items ,0);r_itemn :=0;
      //setlength(r_doors ,0);r_doorn :=0;
      setlength(r_spawns,0);r_spawnn:=0;
      {$IFDEF FULLGAME}
      setlength(r_decors,0);r_decorn:=0;

      r:=(_hex2b(mbuff[1 ]) shl 4)+_hex2b(mbuff[2 ]);
      g:=(_hex2b(mbuff[3 ]) shl 4)+_hex2b(mbuff[4 ]);
      b:=(_hex2b(mbuff[5 ]) shl 4)+_hex2b(mbuff[6 ]);
      r_ceilc:=_RGBA(r,g,b,255);
      r:=(_hex2b(mbuff[7 ]) shl 4)+_hex2b(mbuff[8 ]);
      g:=(_hex2b(mbuff[9 ]) shl 4)+_hex2b(mbuff[10]);
      b:=(_hex2b(mbuff[11]) shl 4)+_hex2b(mbuff[12]);
      r_floorc:=_RGBA(r,g,b,255);
      {$ENDIF}

      for iw:=13 to MaxMapBuffer do
      begin
         if(mbuff[iw]=#0)or(iy>map_mw)then break;

         if(mbuff[iw] in mgr_bwalls)
         then rgrid[ix,iy]:=mbuff[iw]
         else
           if(mbuff[iw] in mgr_decors)then
           begin
              rgrid[ix,iy]:=mbuff[iw];
              {$IFDEF FULLGAME}
              room_AddDecor(aproom,ix,iy,mbuff[iw]);
              {$ENDIF}
           end
           else
             if(mbuff[iw] in mgr_spawns)
             then room_AddSpawn(aproom,ix,iy,mbuff[iw])
             else
               if(mbuff[iw] in mgr_items)
               then room_AddItem(aproom,ix,iy,mbuff[iw])
               else
                 if(mbuff[iw]='#')
                 then rgrid[ix,iy]:=mbuff[iw];

         ix+=1;
         if(mbuff[iw]=#13)or(ix>map_mw)then
         begin
            ix:=1;
            iy+=1;
         end;
      end;

      {for ix:=1 to map_mw do
      for iy:=1 to map_mw do
       if(rgrid[ix,iy]='#')then room_AddDoor(aproom,ix,iy);}
   end;
end;

procedure room_MapByName(aproom:PTRoom;mname:shortstring);
var mi:word;
begin
   mi:=mname2n(mname);
   if(mi>=_mapn)then exit;
   map_LoadToRoomByN(aproom,mi);
   {$IFDEF FULLGAME}
   room_Reset(aproom,false);
   {$ELSE}
   room_Reset(aproom,true);
   {$ENDIF}
end;

procedure room_NextMap(aproom:PTRoom);
begin
   with aproom^ do
   if(maplistn>0)then
   begin
      if(maplistn>1)then
       if(RoomFlag(aproom,sv_g_randommap))
       then maplisti:=random(maplistn)
       else
       begin
          maplisti+=1;
          maplisti:=maplisti mod maplistn;
       end;
      map_LoadToRoomByN(aproom,maplist[maplisti]);
   end;
   {$IFDEF FULLGAME}
   room_reset(aproom,false);
   {$ELSE}
   room_Reset(aproom,true);
   {$ENDIF}
end;

{$IFNDEF FULLGAME}

procedure voteNoForAll(rnum:byte);
var p:integer;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(rnum=roomi)then vote:=0;
end;

procedure room_VoteProcess(aproom:PTRoom);
var voted_players,
    voted_yes   ,
    voted_no,
    p           : integer;
    ratio       : single;
begin
   with aproom^ do
   if(vote_time>0)then
   begin
      voted_players:=0;
      voted_yes    :=0;
      voted_no     :=0;

      vote_time-=1;
      for p:=0 to MaxPlayers do
       with _players[p] do
        if(state>ps_spec)and(not bot)and(rnum=roomi)then
        begin
           voted_players+=1;
           if(vote=vote_yes)then voted_yes+=1;
           if(vote=vote_no )then voted_no +=1;
        end;

      if(voted_players=0)
      then ratio:=-1
      else ratio:=voted_yes/voted_players;

      if(ratio>=vote_ratio)then
      begin
         vote_time:=0;

         _log_add(aproom,log_local,str_votepassed+vote_cmd+' '+vote_arg);
         case vote_cmd of
         cmd_map       : room_MapByName(aproom,vote_arg);
         cmd_mapnext   : room_NextMap(aproom);
         cmd_matchreset: room_ResetMatch(aproom);
         cmd_matchend  : Room_Score(aproom);
         end;
         exit;
      end;
      if(vote_time=0)then _log_add(aproom,log_local,str_votefailed+'('+i2s(voted_yes)+' "yes"/'+i2s(voted_players-voted_yes)+' "no")'+vote_cmd+' '+vote_arg);
   end;
end;

procedure room_MapListAdd(aproom:PTRoom;mname:shortstring);
var mi:word;
begin
   mi:=mname2n(mname);
   if(mi<65535)then
    with aproom^ do
    begin
       if(maplistn=1)and(maplist[0]=0)
       then
       else
       begin
          maplistn+=1;
          setlength(maplist,maplistn);
       end;
       maplist[maplistn-1]:=mi;
    end;
end;

procedure rooms_DefaultAll;
var  r:byte;
 proom:PTRoom;
begin
   if(sv_maxrooms>0)then
    for r:=0 to sv_maxrooms-1 do
    begin
       proom:=@_rooms[r];
       room_Default(proom);
       proom^.rnum:=r;
       demo_init_data(proom);
    end;
end;

procedure room_LoadCFG(fn:shortstring);
var f:text;
    w:word;
  i,r:byte;
vr,vl,
    s:shortstring;
proom:PTRoom;
begin
   sv_maxrooms:=1;
   setlength(_rooms,sv_maxrooms); // default 1
   rooms_DefaultAll;

   if(FileExists(fn))then
   begin
      {$I-}
      assign(f,fn);
      reset(f);

      if(IOResult<>0)then
      begin
         close(f);
         exit;
      end;

      r:=255;

      while (not eof(f)) do
      begin
         readln(f,s);
         vr:='';
         vl:='';
         i :=pos(' ',s);
         if(i>0)then
         begin
            vl:=copy(s,1,i-1);
            delete(s,1,i);
            vr:=s;
         end;

         case vl of
rcfg_servername: if(length(sv_name)=0)then begin sv_name:=vr;if(length(vr)>NameLen)then setlength(sv_name,NameLen); end;
'maxrooms'     : if(r=255)then begin sv_maxrooms:=mm3w(1,s2b(vr),32);setlength(_rooms,sv_maxrooms);rooms_DefaultAll;end;
'room'         : begin r:=s2b(vr);if(r=0)or(r>sv_maxrooms)then r:=255;end;
'rcon_password': rcon_pass:=vr;
         end;

         if(0<r)and(r<=sv_maxrooms)then
          with _rooms[r-1] do
           case vl of
'copyfrom'     : begin
                 i:=s2b(vr);
                 if(1<=i)and(i<=sv_maxrooms)then
                 begin
                    proom:=@_rooms[i-1];
                    rname       :=proom^.rname;
                    max_players :=proom^.max_players;
                    max_clients :=proom^.max_clients;
                    g_timelimit :=proom^.g_timelimit;
                    g_fraglimit :=proom^.g_fraglimit;
                    g_flags     :=proom^.g_flags;
                    g_scorepause:=proom^.g_scorepause;
                    bot_maxt    :=proom^.bot_maxt;
                    vote_ratio  :=proom^.vote_ratio;
                    maplistn:=proom^.maplistn;
                    setlength(maplist,maplistn);
                    for w:=0 to maplistn-1 do maplist[w]:=proom^.maplist[w];
                 end;
                 end;
rcfg_voteratio : vote_ratio  := mm3w(0,s2b(vr),100)/100;
rcfg_roomname  : rname       := vr;
rcfg_maxplayers: max_players := mm3w(2,s2b(vr),MaxPlayers);
rcfg_maxclients: max_clients := mm3w(2,s2b(vr),MaxPlayers);
rcfg_timelimit : g_timelimit := mm3w(0,s2b(vr),60        );
rcfg_fraglimit : g_fraglimit := mm3i(0,s2i(vr),32000     );
rcfg_flags     : g_flags     := str2RFlags(vr);
rcfg_resettime : g_scorepause:= mm3w(5,s2b(vr),59)*fr_fps;
rcfg_deathtime : g_deathtime := mm3w(0,s2b(vr),60)*fr_fps;
'bots_SS'      : bot_maxt[0] := mm3w(0,s2b(vr),MaxPlayers);
'bots_MU'      : bot_maxt[1] := mm3w(0,s2b(vr),MaxPlayers);
'bots_SO'      : bot_maxt[2] := mm3w(0,s2b(vr),MaxPlayers);
'bots_OF'      : bot_maxt[3] := mm3w(0,s2b(vr),MaxPlayers);
'maplistadd'   : room_MapListAdd(@_rooms[r-1],vr);
           end;
      end;
      close(f);
      {$I+}
   end;

   writeln('Server: '     ,sv_name    );
   writeln('Rooms count: ',sv_maxrooms);

   for i:=0 to sv_maxrooms-1 do
   with _rooms[i] do
   begin
      if(maplistn=0)then
      begin
         maplistn:=1;
         setlength(maplist,maplistn);
         maplist[0]:=0;
      end;
      writeln('Room #',i+1,': clients:',max_clients,', players: ',max_players,', flags: ',RFlags2str(g_flags));
      maplisti:=random(maplistn);
      map_LoadToRoomByN(@_rooms[i],maplist[maplisti]);
   end;
end;
{$ELSE}

procedure ResetLocalGame;
var p:byte;
begin
   FillChar(_players,SizeOf(_players),0);
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       x:=1.5;vx:=x;
       y:=1.5;vy:=y;
       roomi:= 0;
       room := _room;
    end;
   ClearClientEffects;
   room_Default(_room);
   with _room^ do
   begin
      rnum    :=0;
      mapi    :=0;
      maplistn:=1;
      setlength(maplist,maplistn);
      maplist[0]:=menu_bmm;
      time_scorepause:=0;
   end;
   cl_playeri:=0;
   cam_pl    :=0;
   server_ping_p:=0;
   server_ping_t:=0;
   server_ping_r:=false;
   server_ping  :=0;
   server_ttl   :=0;
end;

{$ENDIF}
