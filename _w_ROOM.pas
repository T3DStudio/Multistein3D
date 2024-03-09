
{$IFDEF FULLGAME}

procedure eff_MissileExplode(amissile:PTMissile);
begin
   with amissile^ do
   begin
      case mtype of
      gpt_fire  : begin
                     cl_eff_add(mx,my,0,1.15,eid_fire);
                     PlaySoundSource(snd_fire   ,nil,nil,mx,my);
                  end;
      gpt_rocket: begin
                     cl_eff_add(mx,my,0,1.75,eid_fire);
                     PlaySoundSource(snd_explode,nil,nil,mx,my);
                  end;
      end;
      mtype:=0;
   end;
end;

{$ENDIF}

procedure room_PlayersKickAll(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(room=aroom)and(state>ps_none)then pl_state(@g_players[p],ps_none,false);
   with aroom^ do FillChar(team_frags,SizeOf(team_frags),0);
end;

procedure room_PlayersSpecAll(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(room=aroom)and(state>ps_none)then
      pl_state(@g_players[p],ps_spec,false);
end;

procedure room_PlayersResetAll(aroom:PTRoom);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(room=aroom)and(state>ps_spec)then PlayerReset(@g_players[p]);
end;

procedure room_ObjectsResetAll(aroom:PTRoom);
var i:word;
begin
   with aroom^ do
   begin
      if(r_item_n>0)then
       for i:=0 to r_item_n-1 do
        with r_item_l[i] do irespt:=0;

      setlength(r_missile_l,0);r_missile_n:=0;
   end;
end;

procedure room_TimeUpdate(aroom:PTRoom);
begin
   with aroom^ do
   begin
      time_min_prev:=time_min;
      time_sec:=(time_tick div fr_fpsx1) mod 60;
      time_min:= time_tick div TicksPerMinute;
   end;
end;

procedure room_Reset(aroom:PTRoom;kick:boolean);
begin
   if(kick)
   then room_PlayersKickAll(aroom)
   else room_PlayersSpecAll(aroom);
   room_ObjectsResetAll    (aroom);
   with aroom^ do
   begin
      FillChar(team_frags,SizeOf(team_frags),0);
      time_scorepause:=0;
      time_tick      :=0;
      demo_break(aroom,'room reset');
   end;
   room_TimeUpdate(aroom);
   {$IFDEF FULLGAME}
   ClearClientEffects;
   {$ENDIF}
end;

procedure room_MatchReset(aroom:PTRoom);
begin
   with aroom^ do
   begin
      time_scorepause:=0;
      time_tick      :=0;
   end;
   room_TimeUpdate(aroom);
   room_ObjectsResetAll(aroom);
   with aroom^ do FillChar(team_frags,SizeOf(team_frags),0);
   room_PlayersResetAll(aroom);
   room_log_add(aroom,log_endgame,str_resetmatch);
   {$IFDEF FULLGAME}
   ClearClientEffects;
   {$ENDIF}
end;

procedure Room_BotKickAll(aroom:PTRoom;team_name:shortstring);
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(room=aroom)and(state>ps_none)and(bot)then
      pl_state(@g_players[p],ps_none,true);
   with aroom^ do
    if(length(team_name)=0)
    then FillChar(bot_maxt,sizeof(bot_maxt),0)
    else
      for p:=0 to MaxTeamsI do
       if(str_teams[p]=team_name)then bot_maxt[p]:=0;
end;
procedure Room_BotAdd(aroom:PTRoom;team_name:shortstring);
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

procedure room_LogClear(aroom:PTRoom);
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

procedure room_SetDefault(aroom:PTRoom);
begin
   room_PlayersKickAll(aroom);
   room_LogClear      (aroom);

   with aroom^ do
   begin
      FillChar(rgrid,SizeOf(rgrid),0);
      setlength(r_item_l   ,0);r_item_n   :=0;
      setlength(r_spawn_l  ,0);r_spawn_n  :=0;
      setlength(r_missile_l,0);r_missile_n:=0;
      setlength(maplist_l  ,0);maplist_n  :=0;

      maplist_cur :=0;
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
      g_scorepause:=fr_fpsx1*30;
      g_deathtime :=fr_fpsx1*10;
      scores_save_need:=false;
      vote_ratio  := 0.5;
      vote_time   := 0;
      vote_cmd    := '';

      bot_cur     :=0;
      FillChar(bot_curt  ,SizeOf(bot_curt  ),0);
      FillChar(bot_maxt  ,SizeOf(bot_maxt  ),0);
      FillChar(team_frags,SizeOf(team_frags),0);

      {$IFDEF FULLGAME}
      setlength(r_decor_l,0);r_decor_n:=0;
      {$ENDIF}
   end;
end;

procedure room_AddSpawn(aroom:PTRoom;ax,ay:integer;atype:char);
begin
   with aroom^ do
   if(r_spawn_n<r_spawn_n.MaxValue)then
   begin
      r_spawn_n+=1;
      setlength(r_spawn_l,r_spawn_n);

      with r_spawn_l[r_spawn_n-1] do
      begin
         spx := ax+0.5;
         spy := ay+0.5;
         case atype of
mgr_spawn_0      : spdir:=0;
mgr_spawn_270    : spdir:=270;
mgr_spawn_180    : spdir:=180;
mgr_spawn_90     : spdir:=90;
mgr_spawn_random : spdir:=r_spawn_n*45;
         else      spdir:=r_spawn_n*45;
         end;
      end;
   end;
end;

procedure room_AddItem(aproom:PTRoom;ax,ay:integer;atype:char);
begin
   with aproom^ do
   if(r_item_n<r_item_n.MaxValue)then
   begin
      if not(atype in mgr_items)then exit;

      r_item_n+=1;
      setlength(r_item_l,r_item_n);

      FillChar(r_item_l[r_item_n-1],Sizeof(TItem),0);

      with r_item_l[r_item_n-1] do
      begin
         {$IFDEF FULLGAME}
         isprite:=0;
         {$ENDIF}
         case atype of
mgr_item_armor     : begin  // armor
                     iarmor            := 50;
                     irespm            := fr_fpsx1*30;
    {$IFDEF FULLGAME}isprite           := 0;{$ENDIF}
                     end;
mgr_item_mp40      : begin  // mp40
                     iweapon           := gun_bit[2];
                     iammo[ammo_bullet]:= 15;
                     irespm            := fr_fpsx1*10;
    {$IFDEF FULLGAME}isprite           := 1;{$ENDIF}
                     end;
mgr_item_chaingun  : begin  // chaingun
                     iweapon           := gun_bit[3];
                     iammo[ammo_bullet]:= 30;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 2;{$ENDIF}
                     end;
mgr_item_ammo      : begin  // ammo bullets
                     iammo[ammo_bullet]:= 5;
                     irespm            := fr_fpsx1*10;
    {$IFDEF FULLGAME}isprite           := 3;{$ENDIF}
                     end;
mgr_item_ammobox   : begin  // big ammo bullets
                     iammo[ammo_bullet]:= 40;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 4;{$ENDIF}
                     end;
mgr_item_dogfood   : begin  // dog food
                     ihealth           := 5;
                     irespm            := fr_fpsx1*10;
    {$IFDEF FULLGAME}isprite           := 5;{$ENDIF}
                     end;
mgr_item_food      : begin  // food
                     ihealth           := 10;
                     irespm            := fr_fpsx1*15;
    {$IFDEF FULLGAME}isprite           := 6;{$ENDIF}
                     end;
mgr_item_medkit    : begin  // health
                     ihealth           := 20;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 7;{$ENDIF}
                     end;
mgr_item_mega      : begin  // mega
                     ihealth           := 100;
                     iarmor            := 50;
                     irespm            := fr_fpsx1*30;
    {$IFDEF FULLGAME}isprite           := 8;{$ENDIF}
                     end;
mgr_item_rifle     : begin  // rifle
                     iweapon           := gun_bit[4];
                     iammo[ammo_rifle] := 5;
                     irespm            := fr_fpsx1*10;
    {$IFDEF FULLGAME}isprite           := 9;{$ENDIF}
                     end;
mgr_item_flame     : begin  // flamethrower
                     iweapon           := gun_bit[5];
                     iammo[ammo_flame] := 30;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 10;{$ENDIF}
                     end;
mgr_item_panzer    : begin  // panzerfaust
                     iweapon           := gun_bit[6];
                     iammo[ammo_rocket]:= 5;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 11;{$ENDIF}
                     end;
mgr_item_tesla     : begin  // tesla
                     iweapon           := gun_bit[7];
                     iammo[ammo_tesla] := 5;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 12;{$ENDIF}
                     end;
mgr_item_ammorifle : begin  // ammo rifle
                     iammo[ammo_rifle] := 5;
                     irespm            := fr_fpsx1*10;
    {$IFDEF FULLGAME}isprite           := 13;{$ENDIF}
                     end;
mgr_item_ammoflame : begin  // ammo flame
                     iammo[ammo_flame] := 30;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 14;{$ENDIF}
                     end;
mgr_item_ammopanzer: begin  // ammo panzer
                     iammo[ammo_rocket]:= 5;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 15;{$ENDIF}
                     end;
mgr_item_ammotesla : begin  // ammo tesla
                     iammo[ammo_tesla] := 5;
                     irespm            := fr_fpsx1*20;
    {$IFDEF FULLGAME}isprite           := 16;{$ENDIF}
                     end;
         else
         end;

         ix   :=ax+0.5;
         iy   :=ay+0.5;
         itype:=atype;
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
      if(Room_CheckFlag(aroom,sv_g_teams))then
      begin
         for p:=0 to MaxTeamsI do
          if(team_frags[p]>=wf1)then
          begin
             wf2:=wf1;
             wp1:=p;
             wf1:=team_frags[p];
          end;
         if(wp1<255)and(logstr<>nil)then logstr^:=str_teams[wp1]+' '+str_team+' '+str_cwin+' ('+str_score+': '+i2s(wf1)+')';
      end
      else
      begin
         for p:=0 to MaxPlayers do
          with g_players[p] do
           if(state>ps_spec)and(aroom=room)and(frags>=wf1)then
           begin
              wf2:=wf1;
              wp1:=p;
              wf1:=frags;
           end;
         if(wp1<255)and(logstr<>nil)then logstr^:=g_players[wp1].name+str_cwin+' ('+str_score+': '+i2s(wf1)+')';
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

      fname   :='r'+b2s(rnum+1)+'_'+str_DateTime+'_'+mapname+str_report_ext;
      teamplay:=Room_CheckFlag(aroom,sv_g_teams);

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
          with g_players[S] do
           if(state>ps_spec)and(roomi=rnum)then
            if(teamplay)
            then _line(name+';'+i2s(frags)+';'+str_teams[team])
            else _line(name+';'+i2s(frags));

         _line('');
         _line('SPECTATORS');
         for S:=0 to MaxPlayers do
          with g_players[S] do
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
   then room_log_add(aroom,log_winner,winnerstr);

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
      room_TimeUpdate(aroom);

      if(g_timelimit>0)then
       if(time_min>=g_timelimit)then
        if(Room_GetWinner(aroom,nil))then
        begin
           room_log_add(aroom,log_endgame,str_timelimithit);
           Room_Score(aroom);
        end
        else
          if(time_min=g_timelimit)and(time_min_prev<time_min)then room_log_add(aroom,log_suddendeath,str_suddendeath);
   end
   else
   begin
      time_tick:=0;
      room_TimeUpdate(aroom);
   end;
end;

procedure room_Objects(aroom:PTRoom);
var i : word;
begin
   with aroom^ do
   begin
      if(r_item_n>0)then
       if(Room_CheckFlag(aroom,sv_g_itemrespawn))then
        for i:=0 to r_item_n-1 do
         with r_item_l[i] do
          if(irespt>0)then irespt-=1;

      if(r_missile_n>0)then
       for i:=0 to r_missile_n-1 do
        if(MissileProc(aroom,@r_missile_l[i]))then
        {$IFDEF FULLGAME}eff_MissileExplode(@r_missile_l[i]);{$ELSE};{$ENDIF}
   end;
end;

{$IFDEF FULLGAME}
procedure room_AddDecor(aproom:PTRoom;ax,ay:integer;atype:char);
begin
   with aproom^ do
   if(r_decor_n<r_decor_n.MaxValue)then
   begin
      r_decor_n+=1;
      setlength(r_decor_l,r_decor_n);

      with r_decor_l[r_decor_n-1] do
      begin
         decor_x   :=ax+0.5;
         decor_y   :=ay+0.5;
         decor_type:=atype;
      end;
   end;
end;

function hex2b(c:char):byte;
begin
   case c of
   '1'     : hex2b:=$1;
   '2'     : hex2b:=$2;
   '3'     : hex2b:=$3;
   '4'     : hex2b:=$4;
   '5'     : hex2b:=$5;
   '6'     : hex2b:=$6;
   '7'     : hex2b:=$7;
   '8'     : hex2b:=$8;
   '9'     : hex2b:=$9;
   'A','a' : hex2b:=$A;
   'B','b' : hex2b:=$B;
   'C','c' : hex2b:=$C;
   'D','d' : hex2b:=$D;
   'E','e' : hex2b:=$E;
   'F','f' : hex2b:=$F;
   else
   hex2b:=$00;
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
   if(im>=g_mapn)then exit;

   ix:=1;
   iy:=1;

   with aproom^ do
   with g_maps[im] do
   begin
      mapname:=mname;
      map_cur:=im;

      room_log_add(aproom,log_map,str_map+': '+mname);

      FillChar(rgrid,SizeOf(rgrid),0);
      setlength(r_item_l   ,0);r_item_n   :=0;
      setlength(r_spawn_l  ,0);r_spawn_n  :=0;
      setlength(r_missile_l,0);r_missile_n:=0;
      {$IFDEF FULLGAME}
      setlength(r_decor_l,0);r_decor_n:=0;

      r:=(hex2b(mbuff[1 ]) shl 4)+hex2b(mbuff[2 ]);
      g:=(hex2b(mbuff[3 ]) shl 4)+hex2b(mbuff[4 ]);
      b:=(hex2b(mbuff[5 ]) shl 4)+hex2b(mbuff[6 ]);
      r_ceil_color:=ColorRGBA(r,g,b,255);
      r:=(hex2b(mbuff[7 ]) shl 4)+hex2b(mbuff[8 ]);
      g:=(hex2b(mbuff[9 ]) shl 4)+hex2b(mbuff[10]);
      b:=(hex2b(mbuff[11]) shl 4)+hex2b(mbuff[12]);
      r_floor_color:=ColorRGBA(r,g,b,255);
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
                 if(mbuff[iw]=mgr_door)
                 then rgrid[ix,iy]:=mbuff[iw];

         ix+=1;
         if(mbuff[iw]=str_NewLineChar)or(ix>map_mw)then
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
   mi:=map_name2n(mname);
   if(mi>=g_mapn)then exit;
   map_LoadToRoomByN(aproom,mi);
   {$IFDEF FULLGAME}
   room_Reset(aproom,false);
   {$ELSE}
   room_Reset(aproom,true);
   {$ENDIF}
end;

procedure room_MapNext(aproom:PTRoom);
begin
   with aproom^ do
   if(maplist_n>0)then
   begin
      if(maplist_n>1)then
       if(Room_CheckFlag(aproom,sv_g_randommap))
       then maplist_cur:=random(maplist_n)
       else
       begin
          maplist_cur+=1;
          maplist_cur:=maplist_cur mod maplist_n;
       end;
      map_LoadToRoomByN(aproom,maplist_l[maplist_cur]);
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
    with g_players[p] do
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
       with g_players[p] do
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

         room_log_add(aproom,log_local,str_votepassed+vote_cmd+' '+vote_arg);
         case vote_cmd of
         cmd_map       : room_MapByName (aproom,vote_arg);
         cmd_mapnext   : room_MapNext   (aproom);
         cmd_matchreset: room_MatchReset(aproom);
         cmd_matchend  : Room_Score(aproom);
         end;
         exit;
      end;
      if(vote_time=0)then room_log_add(aproom,log_local,str_votefailed+'('+i2s(voted_yes)+' "yes"/'+i2s(voted_players-voted_yes)+' "no")'+vote_cmd+' '+vote_arg);
   end;
end;

procedure room_MapListAdd(aproom:PTRoom;map_name:shortstring);
var mi:word;
begin
   mi:=map_name2n(map_name);
   if(mi<mi.MaxValue)then
    with aproom^ do
    begin
       if(maplist_n=1)and(maplist_l[0]=0)
       then
       else
       begin
          maplist_n+=1;
          setlength(maplist_l,maplist_n);
       end;
       maplist_l[maplist_n-1]:=mi;
    end;
end;

procedure rooms_DefaultAll;
var  r:byte;
 proom:PTRoom;
begin
   if(sv_maxrooms>0)then
    for r:=0 to sv_maxrooms-1 do
    begin
       proom:=@sv_rooms[r];
       room_SetDefault(proom);
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
   setlength(sv_rooms,sv_maxrooms); // default 1
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
'maxrooms'     : if(r=255)then begin sv_maxrooms:=mm3w(1,s2b(vr),32);setlength(sv_rooms,sv_maxrooms);rooms_DefaultAll;end;
'room'         : begin r:=s2b(vr);if(r=0)or(r>sv_maxrooms)then r:=255;end;
'rcon_password': sv_rcon_pass:=vr;
         end;

         if(0<r)and(r<=sv_maxrooms)then
          with sv_rooms[r-1] do
           case vl of
'copyfrom'     : begin
                 i:=s2b(vr);
                 if(1<=i)and(i<=sv_maxrooms)then
                 begin
                    proom:=@sv_rooms[i-1];
                    rname       :=proom^.rname;
                    max_players :=proom^.max_players;
                    max_clients :=proom^.max_clients;
                    g_timelimit :=proom^.g_timelimit;
                    g_fraglimit :=proom^.g_fraglimit;
                    g_flags     :=proom^.g_flags;
                    g_scorepause:=proom^.g_scorepause;
                    bot_maxt    :=proom^.bot_maxt;
                    vote_ratio  :=proom^.vote_ratio;
                    maplist_n   :=proom^.maplist_n;
                    setlength(maplist_l,maplist_n);
                    for w:=0 to maplist_n-1 do maplist_l[w]:=proom^.maplist_l[w];
                 end;
                 end;
rcfg_voteratio : vote_ratio  := mm3w(0,s2b(vr),100)/100;
rcfg_roomname  : rname       := vr;
rcfg_maxplayers: max_players := mm3w(2,s2b(vr),MaxPlayers);
rcfg_maxclients: max_clients := mm3w(2,s2b(vr),MaxPlayers);
rcfg_timelimit : g_timelimit := mm3w(0,s2b(vr),60        );
rcfg_fraglimit : g_fraglimit := mm3i(0,s2i(vr),32000     );
rcfg_flags     : g_flags     := str2RFlags(vr);
rcfg_resettime : g_scorepause:= mm3w(5,s2b(vr),59)*fr_fpsx1;
rcfg_deathtime : g_deathtime := mm3w(0,s2b(vr),60)*fr_fpsx1;
'bots_SS'      : bot_maxt[0] := mm3w(0,s2b(vr),MaxPlayers);
'bots_MU'      : bot_maxt[1] := mm3w(0,s2b(vr),MaxPlayers);
'bots_SO'      : bot_maxt[2] := mm3w(0,s2b(vr),MaxPlayers);
'bots_OF'      : bot_maxt[3] := mm3w(0,s2b(vr),MaxPlayers);
'maplistadd'   : room_MapListAdd(@sv_rooms[r-1],vr);
           end;
      end;
      close(f);
      {$I+}
   end;

   writeln('Server: '     ,sv_name    );
   writeln('Rooms count: ',sv_maxrooms);

   for i:=0 to sv_maxrooms-1 do
   with sv_rooms[i] do
   begin
      if(maplist_n=0)then
      begin
         maplist_n:=1;
         setlength(maplist_l,maplist_n);
         maplist_l[0]:=0;
      end;
      writeln('Room #',i+1,': clients:',max_clients,', players: ',max_players,', flags: ',RFlags2str(g_flags));
      maplist_cur:=random(maplist_n);
      map_LoadToRoomByN(@sv_rooms[i],maplist_l[maplist_cur]);
   end;
end;
{$ELSE}

procedure ResetLocalGame;
var p:byte;
begin
   FillChar(g_players,SizeOf(g_players),0);
   for p:=0 to MaxPlayers do
    with g_players[p] do
    begin
       x:=1.5;vx:=x;
       y:=1.5;vy:=y;
       roomi:= 0;
       room := sv_clroom;
    end;
   ClearClientEffects;
   room_SetDefault(sv_clroom);
   with sv_clroom^ do
   begin
      rnum    :=0;
      map_cur    :=0;
      maplist_n:=1;
      setlength(maplist_l,maplist_n);
      maplist_l[0]:=menu_bmm;
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
