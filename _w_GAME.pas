
{$IFDEF FULLGAME}

procedure eff_Respawn(aplayer:PTPlayer);
begin
   with aplayer^ do
   begin
      cl_eff_add(x,y,0,1,eid_spawn);
      PlaySoundSource(snd_spawn,nil,nil,x,y);
   end;
end;

procedure eff_Shoot(aplayer:PTPlayer);
begin
   with aplayer^ do PlaySoundSource(snd_gun[gun_curr],@vx,@vy,0,0);
end;

procedure eff_Death(aplayer:PTPlayer);
begin
   with aplayer^ do
   begin
      if(pnum=cl_playeri)
      then PlaySoundSource(snd_death      ,@vx,@vy,0,0)
      else
        if(gids_death)
        then PlaySoundSource(snd_meat       ,@vx,@vy,0,0)
        else PlaySoundSource(snd_skinD[team],@vx,@vy,0,0);

      if(gids_death)
      then cl_dead_add(vx,vy,255 )
      else cl_dead_add(vx,vy,team);
   end;
end;

procedure player_cl_vars(aplayer:PTPlayer);
begin
   with aplayer^ do
   if(pnum<>cl_playeri)then
   begin
      if(state<=ps_dead)or(menu_locmatch)or(not player_smooth)then
      begin
         vx   :=x;
         vy   :=y;
         vdir:=dir;
      end
      else
      begin
         vx   :=(x+vx)/2;
         vy   :=(y+vy)/2;
         if(state=ps_attk)
         then vdir:=dir
         else vdir:=dir_turn(dir,vdir,dir_diff(dir,vdir)/2);
      end;
      if(state>ps_dead)then
       if(hits<>hits_sound)then
       begin
          if(hits<hits_sound)then PlaySoundSource(snd_skinP[team],@vx,@vy,0,0);
          hits_sound:=hits;
       end;
   end;
end;

procedure player_cl_Death(aplayer:PTPlayer);
begin
   with aplayer^ do
   begin
      if(hits>0)then hits:=0;
      if(hits>-128)then
      begin
         hits-=6;
         dir -=2;
         vdir-=2;
      end;
   end;
end;

procedure cl_ChatCommand(message:shortstring);
begin
   if(menu_locmatch)
   then room_log_add(sv_clroom,log_chat,message)
   else net_SendChat(message);
end;

{$ELSE}

procedure player_xybuffer(aplayer:PTPlayer);
begin
   with aplayer^ do
   begin
      ibuffer+=1;
      if(ibuffer>MaxXYBuffer)then ibuffer:=0;

      xbuffer[ibuffer]:=x;
      ybuffer[ibuffer]:=y;
   end;
end;

{$ENDIF}

procedure pl_state(aplayer:PTPlayer;nstate:byte;log:boolean);
var pstr,
    str2: shortstring;
   {$IFDEF FULLGAME}
     eff: boolean;
     std: integer;
   {$ENDIF}
begin
   pstr:='';
   str2:='';
   with aplayer^ do
   with room^ do
   begin
      {$IFDEF FULLGAME}
      std:=nstate-state;
      eff:=(-2<std);
      {$ENDIF}

      if(nstate>state)then
       while(nstate<>state)do
       begin
          case state of
    ps_none: begin
                cur_clients+=1;
                if(bot)then
                begin
                   bot_curt[team]+=1;
                   bot_cur       +=1;
                end;
                pstr:=str_pconnected;
                if(not bot)then
                  str2:='('+c2ip(ip)+') ';
             end;
    ps_spec: begin
                cur_players+=1;
                pstr:=str_pjoined;
             end;
    ps_dead: begin
                gun_rld  :=0;
                pause_gun:=fr_fpsh1;
                {$IFDEF FULLGAME}
                if(eff)then eff_Respawn(aplayer);
                tesla_eff:=0;
                {$ENDIF}
             end;
          end;
          state+=1;
       end;

      if(nstate<state)then
       while(nstate<>state)do
       begin
          case state of
    ps_spec: begin
                cur_clients-=1;
                if(bot)then
                begin
                   bot_curt[team]-=1;
                   bot_cur       -=1;
                end;

                if(ttl>=MaxPlayerTTL)
                then pstr:=str_ptimeout
                else pstr:=str_pdconnected;
             end;
    ps_dead: begin
                frags:=0;
                cur_players-=1;
                pstr:=str_pleave;
             end;
    ps_walk: begin
                {$IFDEF FULLGAME}
                if(eff)then eff_death(aplayer);
                if(pnum=cl_playeri)then cl_buffer_xy_clear;
                {$ENDIF}
                death_time:=g_deathtime;
             end;
          end;
          state-=1;
       end;

      if(log)and(length(pstr)>0)then room_log_add(room,log_common,name+str2+pstr);
   end;
end;


function RoomCollisionXY(aroom:PTRoom;x,y,px,py:single):byte;
var gx,
    gy:integer;
    c :char;
begin
   gx:=trunc(x);
   gy:=trunc(y);
   if(0<gx)and(gx<map_mlw)and(0<gy)and(gy<map_mlw)then
   begin
      RoomCollisionXY:=0;
      c:=aroom^.rgrid[gx,gy];
      if(c in mgr_dwalls)then RoomCollisionXY:=1;
      if(c in mgr_bwalls)then RoomCollisionXY:=2;
      if(c=mgr_wih      )then RoomCollisionXY:=3;
   end
   else RoomCollisionXY:=4;
end;

function BWallHit(aroom:PTRoom;psx,psy,bsx,bsy:single):byte;
begin
   BWallHit:=RoomCollisionXY(aroom,bsx,bsy,psx,psy);

   if(BWallHit<2)then
     if(abs(trunc(psx)-trunc(bsx))=1)
    and(abs(trunc(bsy)-trunc(psy))=1)then BWallHit:=max2(RoomCollisionXY(aroom,bsx,psy,psx,psy),RoomCollisionXY(aroom,psx,bsy,psx,psy));
end;

function collision_line(aroom:PTRoom;x0,y0,x1,y1:single):boolean;
var px,py,sx,sy,d:single;
begin
   collision_line:=false;
   if(x0=x1)and(y0=y1)then exit;

   d:=point_dist(x0,y0,x1,y1)*2;
   sx:=(x1-x0)/d;
   sy:=(y1-y0)/d;

   while true do
   begin
      px:=x0;
      py:=y0;
      x0:=x0+sx;
      y0:=y0+sy;

      d -=1;
      if(d<=0)then break;

      if(BWallHit(aroom,px,py,x0,y0)>1)then
      begin
         collision_line:=true;
         break;
      end;
   end;
end;

procedure SetNewXY(aroom:PTRoom;cx,cy:psingle;nx,ny,width:single;m:byte);
procedure SetMapBorder(cs:psingle);
begin
   if(cs^<map_pl)then cs^:=map_pl;
   if(cs^>map_pb)then cs^:=map_pb;
end;
begin
   if(RoomCollisionXY(aroom,nx-width,cy^-width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,nx-width,cy^+width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,nx+width,cy^+width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,nx+width,cy^-width,cx^,cy^)<m)then cx^:=nx;

   if(RoomCollisionXY(aroom,cx^-width,ny-width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,cx^-width,ny+width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,cx^+width,ny+width,cx^,cy^)<m)
  and(RoomCollisionXY(aroom,cx^+width,ny-width,cx^,cy^)<m)then cy^:=ny;

   SetMapBorder(cx);
   SetMapBorder(cy);
end;

procedure PlayerMove(aroom:PTRoom;cur_x,cur_y:psingle;dir,width:single;spec:boolean);
var new_x,new_y,d:single;
begin
   if(aroom^.time_scorepause>0)then exit;

   d:=dir*DegToRad;
   new_x:=cur_x^+Player_max_speed[spec]*cos(d);
   new_y:=cur_y^+Player_max_speed[spec]*sin(d);

   if(spec)
   then SetNewXY(aroom,cur_x,cur_y,new_x,new_y,0    ,4)
   else SetNewXY(aroom,cur_x,cur_y,new_x,new_y,width,1);
end;

procedure PlayerMoveToSpawn(aplayer:PTPlayer);
var s:integer;
begin
   with aplayer^ do
    with room^ do
     if(r_spawn_n>0)then
     begin
        s:=random(r_spawn_n);
        with r_spawn_l[s] do
        begin
           x   :=spx;
           y   :=spy;
           dir :=spdir;
           {$IFDEF FULLGAME}
           vx  :=x;
           vy  :=y;
           vdir:=dir;
           {$ENDIF}
        end;
     end;
end;

function PlayerRespawn(aplayer:PTPlayer;forse:boolean):boolean;
begin
   PlayerRespawn:=false;
   with aplayer^ do
    if(pause_resp=0)or(forse)then
     with room^ do
      if(time_scorepause=0)then
      begin
         PlayerMoveToSpawn(aplayer);

         FillChar(ammo,SizeOf(ammo),0);
         armor  :=0;
         gun_rld:=0;
         pl_state(aplayer,ps_walk,true);

         if(Room_CheckFlag(room,sv_g_instagib))then
         begin
            hits    :=1;
            ammo[ammo_rifle] :=1;
            gun_inv :=gun_bit[4];
            gun_curr:=4;
         end
         else
         begin
            if(Room_CheckFlag(room,sv_g_itemrespawn))
            then ammo[ammo_bullet]:=20
            else ammo[ammo_bullet]:=60;
            hits    :=Player_max_hits;
            gun_inv :=gun_bit[0]+gun_bit[1];
            gun_curr:=1;
         end;
         //ammo[ammo_flame]:=250;
         gun_next     :=gun_curr;
         pause_resp   :=fr_fpsh1;
         PlayerRespawn:=true;
         bot_enemy    :=0;
      end;
end;

function PlayerDamage(aplayer:PTPlayer;damage:integer):boolean;
var dmg_armor,
    dmg_hits :integer;
begin
   PlayerDamage:=false;
   with aplayer^ do
   if(room^.time_scorepause=0)then
   begin
      dmg_hits :=damage div 3;
      dmg_armor:=damage-dmg_hits;

      armor-=dmg_armor;
      if(armor<0)then
      begin
         dmg_hits+=abs(armor);
         armor:=0;
      end;

      hits-=dmg_hits;
      if(hits<=0)then
      begin
         gids_death:=(hits<=gibs_hits);
         pl_state(aplayer,ps_dead,true);
         hits        :=0;
         PlayerDamage:=true;
         pause_resp  :=fr_fpsx1;
      end;
   end;
end;

procedure PlayerReset(aplayer:PTPlayer);
begin
   with aplayer^ do
    if(state>ps_spec)then
    begin
       //PlayerRespawn(aplayer,true);
       PlayerDamage(aplayer,1000);
       frags:=0;
    end;
end;

procedure PlayerSpecJoin(aplayer:PTPlayer);
begin
   with aplayer^ do
   with room^ do
    if(time_scorepause<=0)and(state>ps_none)and(pause_spec=0)then
     if(state=ps_spec)then
     begin
        if(cur_players<max_players)then
         if(PlayerRespawn(aplayer,false))then
         begin
            frags:=0;
            pause_spec:={$IFDEF FULLGAME}2{$ELSE}fr_fpsx1{$ENDIF};
         end;
     end
     else
     begin
        frags:=0;
        pl_state(aplayer,ps_spec,true);
        pause_spec:={$IFDEF FULLGAME}2{$ELSE}fr_fpsx1{$ENDIF};
     end;
end;

procedure SetPHS(phs:PTPlayerHitSet;p:byte);
var byt,
    bit:integer;
begin
   if(p<=MaxPlayers)then
   begin
      byt:=p div 8;
      bit:=p mod 8;
      SetBBit(@phs^[byt],bit,true);
   end;
end;

function CheckPHS(phs:PTPlayerHitSet;p:byte;byt,bit:pbyte):boolean;
begin
   CheckPHS:=false;
   if(p<=MaxPlayers)and(phs<>nil)then
   begin
      byt^:=p div 8;
      bit^:=p mod 8;
      CheckPHS:=GetBBit(@phs^[byt^],bit^);
   end;
end;

function PlayerInPoint(px,py:single;aroomi:integer;phs:PTPlayerHitSet{$IFNDEF FULLGAME};stepback:word{$ENDIF}):PTPlayer;
var p,
    byt,
    bit:byte;
_stx,
_sty:single;
{$IFNDEF FULLGAME}
i,b :byte;
{$ENDIF}
begin
   PlayerInPoint:=nil;

   {$IFNDEF FULLGAME}
   if(stepback>MaxXYBuffer)then stepback:=MaxXYBuffer;
   {$ENDIF}

   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(roomi=aroomi)and(state>ps_dead)then
      if(not CheckPHS(phs,p,@byt,@bit))then
      begin
         {$IFNDEF FULLGAME}
         if(stepback=0)then
         begin
            _stx:=x;
            _sty:=y;
         end
         else
         begin
            b:=ibuffer;
            for i:=1 to stepback do
             if(b=0)
             then b:=MaxXYBuffer
             else b-=1;
            _stx:=xbuffer[b];
            _sty:=ybuffer[b];
         end;
         {$ELSE}
         _stx:=x;
         _sty:=y;
         {$ENDIF}

         if(abs(px-_stx)<Player_BWidth)
        and(abs(py-_sty)<Player_BWidth)then
         begin
            PlayerInPoint:=@g_players[p];
            if(phs<>nil)then SetBBit(@phs^[byt],bit,true);
            break;
         end;
      end;
end;

function IncFrags(aplayer:PTPlayer;TeamPlay,TeamKill:boolean):boolean;
begin
   IncFrags:=false;
   with aplayer^ do
   begin
      if(TeamPlay)and(TeamKill)
      then frags-=1
      else frags+=1;

      with room^ do
      begin
         if(TeamPlay)and(TeamKill)
         then team_frags[team]-=1
         else team_frags[team]+=1;

         if(g_fraglimit>0)then
          if(frags>=g_fraglimit)
          or((TeamPlay)and(team_frags[team]>=g_fraglimit))then
          begin
             room_log_add(room,log_endgame,str_fraglimithit);
             Room_Score(room);
             IncFrags:=true;
          end;
      end;
   end;
end;

procedure PlayerShot_Bullet(aplayer:PTPlayer{$IFDEF FULLGAME};fakeshoot:boolean{$ENDIF});
const init_dstep = 0.25;
var d,sx,sy,
    dstep,
max_dist,
    psx,psy,
    bsx,bsy :single;
damage,
dispersion  :integer;
teams,
rail        :boolean;
wall_hit
{$IFDEF FULLGAME}
   ,bstep
{$ENDIF}    :byte;
    tpl     :PTPlayer;
    phs     :TPlayerHitSet;
begin
   with aplayer^ do
   begin
      max_dist  :=gun_dist[gun_curr];
      dispersion:=gun_disp[gun_curr];
      damage    :=gun_dmg [gun_curr];
      rail      :=gun_curr=4;
      teams     :=Room_CheckFlag(room,sv_g_teams);

      bsx  := x;
      bsy  := y;
      dstep:= init_dstep;
      {$IFDEF FULLGAME}
      bstep:= 2;
      {$ENDIF}

      FillChar(phs,SizeOf(phs),0);
      SetPHS(@phs,pnum);

      if(dispersion>1)
      then d :=(dir-random(dispersion)+random(dispersion))*degtorad
      else d := dir*degtorad;
      sx:=cos(d)*dstep;
      sy:=sin(d)*dstep;

      while true do
      begin
         psx :=bsx;
         psy :=bsy;

         bsx +=sx;
         bsy +=sy;
         max_dist-=dstep;

         wall_hit:=BWallHit(room,psx,psy,bsx,bsy);

         {$IFDEF FULLGAME}
         if(bstep>0)then
          if(wall_hit>1)or(max_dist<=0)then
          begin
             bsx  -=sx;
             bsy  -=sy;
             max_dist +=bstep;
             sx   /=2;
             sy   /=2;
             max_dist /=2;
             bstep-=1;
             continue;
          end;

         case wall_hit of
      0,1: ;
        2: begin
              cl_eff_add(bsx-sx,bsy-sy,0,1,eid_puff);
              break;
           end;
         else break; // wall with sky texture
         end;
         {$ELSE}
         if(wall_hit> 1)then break;
         {$ENDIF}
         if(max_dist<=0)then break;

         {$IFDEF FULLGAME}
         tpl:=PlayerInPoint(bsx,bsy,roomi,@phs);
         {$ELSE}
         if(antilag)
         then tpl:=PlayerInPoint(bsx,bsy,roomi,@phs,round(ping/fr_RateTicks))
         else tpl:=PlayerInPoint(bsx,bsy,roomi,@phs,0);
         {$ENDIF}

         if(tpl<>nil)then
         begin
            {$IFDEF FULLGAME}
            cl_eff_add(bsx,bsy,0,1,eid_blood);
            if(not fakeshoot)then
            {$ENDIF}
              if(not teams)or(Room_CheckFlag(room,sv_g_teamdamage))or(team<>tpl^.team)then
               if(PlayerDamage(tpl,damage))then
               begin
                  room_log_add(room,log_common,name+' > '+gun_name[gun_curr]+' > '+tpl^.name);
                  if(IncFrags(aplayer,teams,team=tpl^.team))then exit;
               end;

            if(rail=false)then break;
         end;
      end;
   end;
end;

procedure PlayerShot_Missile(aplayer:PTPlayer{$IFDEF FULLGAME};fakeshot:boolean{$ENDIF});
var mi : word;
rdir   : single;
begin
   with aplayer^ do
   begin
      {$IFDEF FULLGAME}
      if(fakeshot)then exit;
      {$ENDIF}
      case gun_btype[gun_curr] of
gpt_fire,
gpt_rocket: with room^ do
            begin
               if(r_missile_n>=MaxMissiles)then exit;
               if(r_missile_n>0)then
               begin
                  mi:=0;
                  while(mi<r_missile_n)do
                  begin
                     with r_missile_l[mi] do
                      if(mtype=0)then break;
                     mi+=1;
                  end;
                  if(mi=r_missile_n)then
                  begin
                     r_missile_n+=1;
                     setlength(r_missile_l,r_missile_n);
                  end;
               end
               else
               begin
                  r_missile_n+=1;
                  setlength(r_missile_l,r_missile_n);
                  mi:=0;
               end;

               with r_missile_l[mi] do
               begin
                  mx      :=x;
                  my      :=y;
                  mdir    :=dir_360(dir);
                  mgun    :=gun_curr;
                  mtype   :=gun_btype[gun_curr];
                  mmaxdist:=gun_dist [gun_curr];
                  mdamage :=gun_dmg  [gun_curr];
                  mplayer :=aplayer^.pnum;

                  case mtype of
                  gpt_fire  : begin
                                 mspeed  :=gpt_fire_speed;
                                 msplashr:=gpt_fire_splashr;
                              end;
                  gpt_rocket: begin
                                 mspeed  :=gpt_rocket_speed;
                                 msplashr:=gpt_rocket_splashr;
                              end;
                  end;
                  if(gun_disp[gun_curr]>1)
                  then rdir :=(dir-random(gun_disp[gun_curr])+random(gun_disp[gun_curr]))*DEGTORAD
                  else rdir := dir*DEGTORAD;
                  mvx  :=cos(rdir)*mspeed;
                  mvy  :=sin(rdir)*mspeed;
               end;
            end;
      end;
   end;
end;

function MissileProc(aroom:PTRoom;amissile:PTMissile):boolean;
var px,
    py,
    ds  : single;
    pl  : byte;
damage  : integer;
teams   : boolean;
attacker: PTPlayer;
function CheckCollision:boolean;
var p:byte;
begin
   CheckCollision:=true;
   with amissile^ do
   begin
      if(BWallHit(aroom,px,py,mx,my)>1)then
      begin
         mx-=mvx;
         my-=mvy;
         exit;
      end;

      for p:=0 to MaxPlayers do
       with g_players[p] do
        if(room=aroom)and(state>ps_dead)and(p<>mplayer)then
         if (abs(mx-x)<=Player_BWidth)
         and(abs(my-y)<=Player_BWidth)
         then exit;
   end;
   CheckCollision:=false;
end;
begin
   MissileProc:=false;
   with amissile^ do
   if(mtype>0)then
   begin
      if(mdamage<=0)then
      begin
         MissileProc:=true;
         exit;
      end;

      px:=mx;
      py:=my;
      mx+=mvx;
      my+=mvy;
      mmaxdist-=mspeed;

      if(CheckCollision)or(mmaxdist<=0)then
      begin
         attacker:=@g_players[mplayer];
         with attacker^ do teams:=Room_CheckFlag(room,sv_g_teams);

         MissileProc:=true;

         for pl:=0 to MaxPlayers do
          with g_players[pl] do
           if(room=aroom)and(state>ps_dead)then
           begin
              if(msplashr>0)then
              begin
                 ds:=point_dist(mx,my,x,y)-Player_BWidth;
                 if(ds>msplashr)then continue;
                 if(collision_line(room,mx,my,x,y))then continue;
                 if(ds<0)then ds:=0;
                 damage:=round(mdamage*(1-(ds/msplashr)));
              end
              else
              begin
                 if(pl=mplayer)then continue;
                 if(abs(mx-x)>Player_BWidth)
                 or(abs(my-y)>Player_BWidth)
                 then continue;
                 damage:=mdamage;
              end;

              if(damage<=0)then continue;

              if(not teams)
              or(Room_CheckFlag(room,sv_g_teamdamage))
              or(team<>attacker^.team)
              or(pl=mplayer)then
               if(PlayerDamage(@g_players[pl],damage))then
               begin
                  if(mgun<=WeaponsN)then
                  begin
                     if(pl=mplayer)
                     then room_log_add(room,log_common,attacker^.name+str_fsplit+str_suicide+str_fsplit+gun_name[mgun])
                     else room_log_add(room,log_common,attacker^.name+str_fsplit+gun_name[mgun]+str_fsplit+name);
                  end
                  else
                    if(pl=mplayer)
                    then room_log_add(room,log_common,attacker^.name+str_fsplit+str_suicide)
                    else room_log_add(room,log_common,attacker^.name+str_fsplit+name       );
                  if(IncFrags(attacker,teams or(pl=mplayer),team=attacker^.team))or(msplashr=0)then exit;
               end;
           end;
      end;
   end;
end;

procedure PlayerShot_Tesla(aplayer:PTPlayer{$IFDEF FULLGAME};fakeshot:boolean{$ENDIF});
var
pl    : byte;
ax,ay,
bx,by,
tdir,
dist,
fov     : single;
b,i     : byte;
stepback: word;
damage  : integer;
teams   : boolean;
begin
   with aplayer^ do
   begin
      fov     :=gun_disp[gun_curr];
      dist    :=gun_dist[gun_curr];
      damage  :=gun_dmg [gun_curr];
      ax      :=x;
      ay      :=y;
      tdir    :=dir;
      teams   :=Room_CheckFlag(room,sv_g_teams);
      stepback:=round(ping/fr_RateTicks) ;
   end;
   for pl:=0 to MaxPlayers do
    with g_players[pl] do
     if(room=aplayer^.room)and(state>ps_dead)and(pl<>aplayer^.pnum)then
     begin
        {$IFNDEF FULLGAME}
        if(aplayer^.antilag)and(stepback>0)then
        begin
           b:=ibuffer;
           for i:=1 to stepback do
            if(b=0)
            then b:=MaxXYBuffer
            else b-=1;
           bx:=xbuffer[b];
           by:=ybuffer[b];
        end
        else
        begin
           bx:=x;
           by:=y;
        end;
        {$ELSE}
        bx:=x;
        by:=y;
        {$ENDIF}

        if(point_dist(ax,ay,bx,by)>dist)then continue;
        if(abs(dir_diff(point_dir(ax,ay,bx,by),tdir))>fov)then continue;
        if(collision_line(room,ax,ay,bx,by))then continue;

        if(not teams)
        or(Room_CheckFlag(room,sv_g_teamdamage))
        or(team<>aplayer^.team)then
        begin
           {$IFDEF FULLGAME}
           tesla_eff:=tesla_eff_time;
           if(fakeshot)then continue;
           {$ENDIF}
           if(PlayerDamage(@g_players[pl],damage))then
           begin
              room_log_add(room,log_common,aplayer^.name+str_fsplit+gun_name[aplayer^.gun_curr]+str_fsplit+name);
              if(IncFrags(aplayer,teams,team=aplayer^.team))then continue;
           end;
        end;
     end;

end;

procedure PlayerShoot(aplayer:PTPlayer{$IFDEF FULLGAME};fakeshot:boolean{$ENDIF});
begin
   with aplayer^ do
    if(gun_rld=0)and(state>ps_dead)then
     with room^ do
     begin
        gun_rld:=gun_reload[gun_curr];
        case gun_btype[gun_curr] of
gpt_bullet : PlayerShot_Bullet (aplayer{$IFDEF FULLGAME},fakeshot{$ENDIF});
gpt_fire,
gpt_rocket : PlayerShot_Missile(aplayer{$IFDEF FULLGAME},fakeshot{$ENDIF});
gpt_tesla  : PlayerShot_Tesla  (aplayer{$IFDEF FULLGAME},fakeshot{$ENDIF});
        end;
        {$IFDEF FULLGAME}
        eff_Shoot(aplayer);
        {$ENDIF}
     end;
end;

function PlayerAttack(aplayer:PTPlayer{$IFDEF FULLGAME};fakeshot:boolean{$ENDIF}):boolean;
begin
   PlayerAttack:=false;
   with aplayer^ do
    if(gun_rld=0)and(state>ps_dead)and(pause_gun=0)then
     with room^ do
      if(time_scorepause<=0)then
      begin
         if(Room_CheckFlag(room,sv_g_instagib)=false)then
         begin
            if(ammo[gun_ammot[gun_curr]]<gun_ammog[gun_curr])then
            begin
               PlayerAttack:=true;
               exit;
            end;
            {$IFDEF FULLGAME}
            if(not fakeshot)then
            {$ENDIF}
            ammo[gun_ammot[gun_curr]]-=gun_ammog[gun_curr];
         end;
         PlayerShoot(aplayer{$IFDEF FULLGAME},fakeshot{$ENDIF});
      end;
end;

procedure PlayerWeaponSwitch(aplayer:PTPlayer);
begin
   with aplayer^ do
    if(gun_next>WeaponsN)
    then gun_next:=gun_curr
    else
     if(gun_next<>gun_curr)then
      if((gun_inv and gun_bit[gun_next])=0)
      then gun_next:=gun_curr
      else
       if(gun_rld=0)then gun_curr:=gun_next;
end;

{$INCLUDE _w_BOTZ.pas}

function item_proc(ap,cp:pinteger;mp,c:integer):boolean;
var np:integer;
begin
   item_proc:=false;

   np:=ap^*c;
   if(np>0)and(cp^<mp)then
   begin
      cp^:=min2(cp^+np,mp);
      item_proc:=true;
   end;
end;

function pl_item(aplayer:PTPlayer;i:word;c:integer):boolean;
var w:byte;
begin
   pl_item:=false;
   with aplayer^ do
   with room^ do
   with r_item_l[i] do
   begin
      for w:=0 to AmmoTypesN do
      if item_proc(@iammo[w],@ammo[w],Player_max_ammo[w],c)then pl_item:=true;
      if item_proc(@ihealth ,@hits   ,Player_max_hits   ,1)then pl_item:=true;
      if item_proc(@iarmor  ,@armor  ,Player_max_armor  ,1)then pl_item:=true;
   end;
end;

function Inv2BestGunN(inv:byte):byte;
var b:byte;
begin
   Inv2BestGunN:=255;
   for b:=7 downto 0 do
    if(inv and (1 shl b))>0 then
    begin
       Inv2BestGunN:=b;
       break;
    end;
end;

procedure pl_items(aplayer:PTPlayer);
const ammo_multiplier: array[false..true] of integer = (4,1);
var i:word;
    w:byte;
begin
   with aplayer^ do
    with room^ do
     if(r_item_n>0)then
      for i:=0 to r_item_n-1 do
       with r_item_l[i] do
        if(irespt=0)then
         if(abs(ix-x)<Player_IWidth)
        and(abs(iy-y)<Player_IWidth)then
         begin
            if(iweapon>0)then
            begin
               w:=gun_inv or iweapon;
               if(w<>gun_inv)then
               begin
                  gun_inv:=w;

                  if(wswitch)then gun_next:=Inv2BestGunN(iweapon);

                  if(Room_CheckFlag(room,sv_g_itemrespawn))and(not Room_CheckFlag(room,sv_g_weaponstay))
                  then irespt:=irespm
                  else
                  begin
                     pl_item(aplayer,i,ammo_multiplier[Room_CheckFlag(room,sv_g_itemrespawn)]);
                     continue;
                  end;
               end
               else
                 if(not Room_CheckFlag(room,sv_g_itemrespawn))or(Room_CheckFlag(room,sv_g_weaponstay))then continue;
            end;

            if(pl_item(aplayer,i,ammo_multiplier[Room_CheckFlag(room,sv_g_itemrespawn)]))then irespt:=irespm;
         end;
end;

procedure G_SvPlayers;
var  p:byte;
player:PTPlayer;
begin
   for p:=0 to MaxPlayers do
   begin
      player:=@g_players[p];
      with player^ do
      if(state>ps_none)then
      begin
         if(pause_snap   >0)then pause_snap   -=1;
         if(pause_resp   >0)then pause_resp   -=1;
         if(pause_chat   >0)then pause_chat   -=1;
         if(pause_gun    >0)then pause_gun    -=1;
         if(pause_spec   >0)then pause_spec   -=1;
         {$IFNDEF FULLGAME}
         if(pause_ping   >0)then pause_ping   -=1;
         if(pause_logsend>0)then pause_logsend-=1;
         {$ENDIF}
         if(gun_rld>0)then gun_rld-=1;

         if(bot)
         then bot_Think(player)
         {$IFNDEF FULLGAME}
         else
           if(room^.time_scorepause=0)then
           begin
              ttl+=1;
              if(ttl>=MaxPlayerTTL)then pl_state(player,ps_none,true);
              if(net_moves<fr_fpsx2)then net_moves+=1;
           end;
         {$ELSE};
         player_cl_vars(player);
         if(tesla_eff>0)then tesla_eff-=1;
         {$ENDIF};

         if(room^.time_scorepause=0)then
         begin
            if(state>ps_dead)then
            begin
               if(Room_CheckFlag(room,sv_g_instagib)=false)then pl_items(player);

               PlayerWeaponSwitch(player);
            end;
            if(state=ps_dead)then
             if(death_time>0)then
             begin
                death_time-=1;
                if(death_time=0)then PlayerRespawn(player,true);
             end;
         end;
         {$IFDEF FULLGAME}
         if(state=ps_dead)then player_cl_Death(player);
         {$ELSE}
         player_xybuffer(player);
         {$ENDIF}
      end;
   end;
end;

procedure pl_NextWeapon(aplayer:PTPlayer;next:boolean);
var cw:byte;
begin
   with aplayer^ do
   begin
      cw:=gun_next;
      while true do
      begin
         if(next)then
         begin
            if(gun_next>=WeaponsN)
            then gun_next:=0
            else gun_next+=1;
         end
         else
         begin
            if(gun_next=0)
            then gun_next:=WeaponsN
            else gun_next:=gun_next-1;
         end;

         if((gun_inv and gun_bit[gun_next])>0)or(gun_next=cw)then break;
      end;
   end;
end;

procedure G_SvDoClientAction(aplayer:PTPlayer;aid:byte);
begin
   with aplayer^ do
    case aid of
aid_w1,
aid_w2,
aid_w3,
aid_w4,
aid_w5,
aid_w6,
aid_w7,
aid_w8       : gun_next:=aid-aid_w1;
aid_wN       : pl_NextWeapon(aplayer,true );
aid_wP       : pl_NextWeapon(aplayer,false);
aid_specjoin : PlayerSpecJoin(aplayer);
aid_attack   : if(state>ps_dead)
               then PlayerAttack(aplayer{$IFDEF FULLGAME},false{$ENDIF})
               else
                 if(state=ps_dead)then PlayerRespawn(aplayer,false);
    end;

end;

procedure G_SvRooms;
var r:byte;
 room:PTRoom;
begin
   if(sv_maxrooms=0)then exit;

   for r:=0 to sv_maxrooms-1 do
   begin
      room:=@sv_rooms[r];
      with room^ do
       if(time_scorepause=0)then
       begin
          bot_RoomCountControl(room);
          room_Objects(room);
          room_Timer(room);
          {$IFDEF FULLGAME}
          animation_tick+=1;
          {$ENDIF}
       end
       else
       begin
          time_scorepause-=1;
          if(time_scorepause=0)then
          begin
             room_MapNext(room);
             time_tick:=0;
          end;
       end;
      {$IFNDEF FULLGAME}
      room_VoteProcess(room);
      demo_Processing(room);
      with room^ do
      begin
         demo_cstate:=ds_none;
         if(Room_CheckFlag(room,sv_g_recording))then
           if(cur_clients>bot_cur)then demo_cstate:=ds_write;
      end;
      {$ENDIF}
   end;
end;

procedure G_SvGame;
begin
   G_SvRooms;
   G_SvPlayers;
end;


{$IFNDEF FULLGAME}
procedure PlayerBan(pid:byte;time:cardinal;admin:byte;comment:shortstring);
begin
   if(pid<=MaxPlayers)and(pid<>admin)then
   with g_players[pid] do
   begin
      if(state=ps_none)then exit;
      if(bot)then
      begin
         with room^ do
          if(bot_maxt[team]>0)then
           bot_maxt[team]-=1;
      end
      else
        if(length(comment)>0)
        then net_add_ban(ip,time,name+': '+comment)
        else net_add_ban(ip,time,name);
      pl_state(@g_players[pid],ps_none,true);
   end;
end;

{$ENDIF}

function GameParseCommand(cmdline:shortstring{$IFNDEF FULLGAME};pid:byte{$ENDIF}):boolean;
var i,l:byte;
   argl:array of shortstring;
   argn:byte;
function sumargs(n:byte):shortstring;
begin
   sumargs:='';
   if(n<argn)then
    for n:=n to argn-1 do
     if(length(sumargs)=0)
     then sumargs:=argl[n]
     else sumargs:=sumargs+' '+argl[n];
end;
begin
   GameParseCommand:=true;
   argn:=0;
   setlength(argl,argn);

   l:=length(cmdline);
   while(l>0)do
   begin
      i:=pos(' ',cmdline);
      if(i=0)then
      begin
         argn+=1;
         setlength(argl,argn);
         argl[argn-1]:=cmdline;
         l:=0;
      end
      else
        if(i=1)then
        begin
           delete(cmdline,1,1);
           l-=1;
        end
        else
        begin
           argn+=1;
           setlength(argl,argn);
           argl[argn-1]:=copy(cmdline,1,i-1);
           delete(cmdline,1,i);
           l-=i;
        end;
   end;

   {$IFNDEF FULLGAME}
   if(pid<=MaxPlayers)then
   with g_players[pid] do
   with room^ do
   {$ENDIF}
   if(argn>0)then
   case argl[0] of
{$IFDEF FULLGAME}
'say'            : cl_ChatCommand(sumargs(1));
'quit'           : sys_cycle:=false;
'rcon_password'  : if(argn>1)then
                   begin
                      player_rcon:=argl[1];
                      GameParseCommand:=false;
                   end;
'maplistshow'    : GameParseCommand:=false;
'showplayersid'  : show_player_id:=not show_player_id;
    else
       if(not menu_locmatch)or(cl_net_cstat>cstate_none)
       then GameParseCommand:=false
       else
       case argl[0] of
       cmd_map          : if(argn>1)then room_MapByName(sv_clroom,argl[1]);
       cmd_mapnext      : room_MapNext(sv_clroom);
       cmd_matchreset   : room_MatchReset(sv_clroom);
       cmd_matchend     : Room_Score(sv_clroom);
       'botadd'         : if(argn>1)
                          then Room_BotAdd(sv_clroom,argl[1])
                          else Room_BotAdd(sv_clroom,'');
       'botkickall'     : if(argn>1)
                          then Room_BotKickAll(sv_clroom,argl[1])
                          else Room_BotKickAll(sv_clroom,'');
       else
       GameParseCommand:=false;
       end;
    end;
{$ELSE}
'callvote'       : if(argn>1)then
                    if(not Room_CheckFlag(room,sv_g_voting))
                    then room_log_add(room,log_local,str_novotes)
                    else
                     if(state=ps_spec)
                     then room_log_add(room,log_local,str_nospecvote)
                     else
                       if(vote_time>0)
                       then room_log_add(room,log_local,name+str_votealready)
                       else
                       begin
                          vote_cmd:='';
                          vote_arg:='';
                          case argl[1] of
                       cmd_map       : if(argn>2)then
                                       begin
                                       vote_cmd:=argl[1];
                                       vote_arg:=argl[2];
                                       end;
                       cmd_mapnext,
                       cmd_matchreset,
                       cmd_matchend  : vote_cmd:=argl[1];
                          end;
                          if(length(vote_cmd)>0)then
                          begin
                             room_log_add(room,log_local,name+str_votecall+vote_cmd+' '+vote_arg);
                             vote_time:=20*fr_fpsx1;
                             voteNoForAll(rnum);
                             vote:=vote_yes;
                             room_log_add(room,log_local,name+str_voteyes);
                          end;
                       end;
'yes'            : if(vote_time>0)then
                   begin
                      if(vote<>vote_yes)then room_log_add(room,log_local,name+str_voteyes);
                      vote:=vote_yes;
                   end;
'no'             : if(vote_time>0)then
                   begin
                      if(vote<>vote_no)then room_log_add(room,log_local,name+str_voteno );
                      vote:=vote_no;
                   end;
'rcon_password'  : if(sumargs(1)=sv_rcon_pass)and(length(sv_rcon_pass)>0)and(not rcon_access)then
                   begin
                      rcon_access:=true;
                      room_log_add(room,log_local,name+str_rconadmin);
                   end;
'maplistshow'    : net_send_maplist(room,ip,port);
'rcon' : if(argn>1)and(rcon_access)then
         case argl[1] of
         cmd_map       : if(argn>2)then room_MapByName(room,argl[2]);
         cmd_mapnext   : room_MapNext(room);
         cmd_matchreset: room_MatchReset(room);
         cmd_matchend  : begin
                         room_log_add(room,log_endgame,str_timelimithit{$IFDEF FULLGAME},false{$ENDIF});
                         Room_Score(room);
                         end;
         'maplistadd'  : if(argn>2)then
                          for i:=2 to argn-1 do room_MapListAdd(room,argl[i]);
         'maplistclear': begin maplist_n:=1;setlength(maplist_l,maplist_n);maplist_l[0]:=0; end;
         'banadd'      : if(argn>2)then PlayerBan(s2b(argl[2]),$FFFFFFFF,pid,sumargs(3));
         'banremove'   : if(argn>2)then net_del_ban(s2w(argl[2]));
         'kick'        : if(argn>2)then PlayerBan(s2b(argl[2]),fr_fpsx1,pid,sumargs(3));
         'botkickall'  : if(argn>2)
                         then Room_BotKickAll(room,argl[2])
                         else Room_BotKickAll(room,'');
         'botadd'      : if(argn>2)
                         then Room_BotAdd(room,argl[2])
                         else Room_BotAdd(room,'');
         'banshowall'  : net_send_bans(ip,port);
         'cancelvote'  : begin
                         room_log_add(room,log_local,name+str_votecancel);
                         vote_time:=0;
                         end;
         else
            if(argn>2)then
            case argl[1] of
            rcfg_roomname   : begin rname       :=argl[2];                         room_log_add(room,log_roomdata,rcfg_roomname  +'='+rname              );end;
            rcfg_maxplayers : begin max_players :=mm3w(2,s2b(argl[2]),MaxPlayers); room_log_add(room,log_roomdata,rcfg_maxplayers+'='+b2s(max_players)   );end;
            rcfg_maxclients : begin max_clients :=mm3w(2,s2b(argl[2]),MaxPlayers); room_log_add(room,log_roomdata,rcfg_maxclients+'='+b2s(max_clients)   );end;
            rcfg_fraglimit  : begin g_fraglimit :=mm3i(0,s2i(argl[2]),32000);      room_log_add(room,log_roomdata,rcfg_fraglimit +'='+i2s(g_fraglimit)   );end;
            rcfg_timelimit  : begin g_timelimit :=mm3w(0,s2b(argl[2]),60   );      room_log_add(room,log_roomdata,rcfg_timelimit +'='+c2s(g_timelimit)   );end;
            rcfg_flags      : begin g_flags     :=str2RFlags(argl[2]);             room_log_add(room,log_roomdata,rcfg_flags     +'='+RFlags2str(g_flags));end;
            rcfg_resettime  : g_scorepause      :=mm3w(5,s2b(argl[2]),60 )*fr_fpsx1;
            rcfg_deathtime  : g_deathtime       :=mm3w(0,s2b(argl[2]),60 )*fr_fpsx1;
            rcfg_voteratio  : vote_ratio        :=mm3w(0,s2b(argl[2]),100)/100;
            end;
         end;
   else
      GameParseCommand:=false;
   end;
  {$ENDIF}
end;

procedure G_Data;
const gun_min_rld = fr_fpsx1 div 5;
var g,s:byte;
begin
   for g:=0 to WeaponsN do
   begin
      s:=gun_reload[g] div 5;
      if(s<gun_min_rld)then s:=gun_min_rld;

      if(s<gun_reload  [g])
      then gun_reload_s[g]:=gun_reload[g]-s
      else gun_reload_s[g]:=0;
   end;
   bot_Init;
end;

{$IFDEF FULLGAME}

procedure console_TAB;
const
cmd_num = 40;
cmd_all : array[0..cmd_num] of shortstring = (
'quit',
'maplistshow',
'callvote',
'callvote '+cmd_map,
'callvote '+cmd_mapnext,
'callvote '+cmd_matchend,
'callvote '+cmd_matchreset,
cmd_voteyes,
cmd_voteno,
'rcon',
'rcon '+rcfg_roomname,
'rcon '+rcfg_maxplayers,
'rcon '+rcfg_maxclients,
'rcon '+rcfg_fraglimit,
'rcon '+rcfg_timelimit,
'rcon '+rcfg_flags,
'rcon '+rcfg_voteratio,
'rcon botadd',
'rcon botkickall',
'rcon '+rcfg_resettime,
'rcon '+rcfg_deathtime,
'rcon '+cmd_matchend,
'rcon '+cmd_matchreset,
'rcon '+cmd_map,
'rcon maplistadd',
'rcon maplistclear',
'rcon '+cmd_mapnext,
'rcon banadd',
'rcon banremove',
'rcon banshowall',
'rcon kick',
'rcon cancelvote',
'rcon_password',
'map',
'mapnext',
'matchreset',
'matchend',
'showplayersid',
'botadd',
'botkickall',
'say'
);
cmd_options : array[0..cmd_num] of shortstring = (
'',
'',
'<vote option>',
'<map name>',
'',
'',
'',
'',
'',
'<rcon command>',
'<name>',
'<2-128>',
'<2-128>',
'<0-32000>',
'<0-59, minutes>',
'<ITRWDMV>',
'<0-100>',
'[ss,mu,so,of]',
'',
'<5-60, seconds>',
'<0-60, seconds>',
'',
'',
'<map name>',
'<map1 map2 map3 ...>',
'',
'',
'<player ID>',
'<ban ID>',
'',
'<player ID>',
'',
'<password>',
'<map name>',
'',
'',
'',
'',
'[ss,mu,so,of]',
'',
'<string>'
);
var i,n:integer;
    l:byte;
ccmdp,
ccmds:array of shortstring;
begin
   n:=0;
   setlength(ccmds,n);
   setlength(ccmdp,n);
   l:=length(console_str);
   if(l=0)then exit;

   for i:=0 to cmd_num do
    if(length(cmd_all[i])>=l)then
     if(pos(console_str,cmd_all[i])=1)then
     begin
        n+=1;
        setlength(ccmds,n);
        setlength(ccmdp,n);
        ccmds[n-1]:=cmd_all    [i];
        ccmdp[n-1]:=cmd_options[i];
     end;

   if(n=1)then
   begin
      if(length(ccmdp[0])>0)then
      begin
         room_log_add(sv_clroom,log_local,'---------------');
         room_log_add(sv_clroom,log_local,ccmds[0]+' '+ccmdp[0]);
         console_str:=ccmds[0]+' ';
      end
      else console_str:=ccmds[0];
   end
   else
   begin
      if(n>0)then room_log_add(sv_clroom,log_local,'---------------');
      while(n>0)do
      begin
         n-=1;
         room_log_add(sv_clroom,log_local,ccmds[n]+' '+ccmdp[n]);
      end;
   end;
end;


procedure StartLocalGame;
var lplayer:PTPlayer;
begin
   ResetLocalGame;
   demo_break(sv_clroom,'');
   sv_clroom^.demo_cstate:=ds_none;
   if(menu_locmatch)
   then menu_locmatch:=false
   else
   begin
      map_LoadToRoomByN(sv_clroom,menu_bmm);
      with sv_clroom^ do
      begin
         g_flags      :=0;
         if(menu_linsta)then g_flags:=g_flags or sv_g_instagib;
         if(menu_lteams)then g_flags:=g_flags or sv_g_teams;
         if(menu_lteamd)then g_flags:=g_flags or sv_g_teamdamage;
         if(menu_itresp)then g_flags:=g_flags or sv_g_itemrespawn;
         if(menu_wstay )then g_flags:=g_flags or sv_g_weaponstay;
         g_fraglimit  :=menu_lslimit;
         g_timelimit  :=menu_ltlimit;
         bot_maxt     :=menu_lbots;
         map_cur         :=menu_bmm;
         maplist_n     :=1;
         setlength(maplist_l,maplist_n);
         maplist_l[0]   :=menu_bmm;
      end;

      cl_playeri:=net_NewPlayer(0,0,sv_clroom^.rnum,player_name,player_team,false,false);
      cam_pl    :=cl_playeri;
      lplayer   :=@g_players[cl_playeri];

      pl_state(lplayer,ps_spec,true);
      PlayerMoveToSpawn(lplayer);

      menu_locmatch:=true;
   end;
end;

procedure MakeCameraAndHud;
var cdir:single;
    i:byte;
begin
   with g_players[cam_pl] do
   begin
      cam_dir:=vdir;
      cam_x  :=vx;
      cam_y  :=vy;

      cdir :=cam_dir*DEGTORAD;
      rc_vx:=cos(cdir);
      rc_vy:=sin(cdir);
      rc_x :=cam_x-rc_vx/4;
      rc_y :=cam_y-rc_vy/4;

      if(state=hud_state)and(state>=ps_walk)then
      begin
         if(hits<hud_hits)then
         begin
            hud_mask_t:=(hud_hits-hits)*2;
            with hud_mask do begin r:=255;g:=0;  b:=0  ;end;
         end;
         if(hits>hud_hits)then
         begin
            hud_mask_t:=fr_fpsh1;
            with hud_mask do begin r:=0;  g:=0;  b:=255;end;
            PlaySoundSource(snd_health,@cam_x,@cam_y,0,0);
         end;
         if(armor>hud_armor)then
         begin
            hud_mask_t:=fr_fpsh1;
            with hud_mask do begin r:=0;  g:=255;b:=0  ;end;
            PlaySoundSource(snd_armor,@cam_x,@cam_y,0,0);
         end;
         for i:=0 to AmmoTypesN do
         if(ammo[i]>hud_ammo[i])then
         begin
            hud_mask_t:=fr_fpsh1;
            with hud_mask do begin r:=255;g:=255;b:=0  ;end;
            PlaySoundSource(snd_ammo,@cam_x,@cam_y,0,0);
         end;

         if(hud_hits>0)and(hits>0)then
          if(cam_pl=cl_playeri)and(hud_guni<>gun_inv)then
           if(((hud_guni and gun_bit[3])=0)and((gun_inv and gun_bit[3])>0))
           or(((hud_guni and gun_bit[6])=0)and((gun_inv and gun_bit[6])>0))
           or(((hud_guni and gun_bit[7])=0)and((gun_inv and gun_bit[7])>0))then
           begin
              hud_biggun:=fr_fpsx1;
              PlaySoundSource(snd_chain,@cam_x,@cam_y,0,0);
           end
           else PlaySoundSource(snd_weapon,@cam_x,@cam_y,0,0);

         if(gun_curr=7)and(gun_reload[gun_curr]=(gun_rld+1))then
         begin
            hud_mask_t:=fr_fpsh1;
            with hud_mask do begin r:=128;g:=128;b:=255;end;
         end;
      end
      else
        if(state=ps_dead)then
        begin
           hud_mask_t:=mm3i(0,-hits,128);
           with hud_mask do begin r:=255;g:=0;  b:=0;end;
        end
        else hud_mask_t:=0;


      hud_hits :=hits;
      hud_armor:=armor;
      hud_guni :=gun_inv;
      hud_ammo :=ammo;
      hud_state:=state;
   end;

   if(hud_noammoclk>0)then hud_noammoclk-=1;
   if(hud_biggun   >0)then hud_biggun   -=1;
end;

procedure CamNext(next:boolean);
begin
   while true do
   begin
      if(next)then
      begin
         if(cam_pl<MaxPlayers)
         then cam_pl+=1
         else cam_pl:=0
      end
      else
        if(cam_pl>0)
        then cam_pl-=1
        else cam_pl:=MaxPlayers;

      if(cam_pl=cl_playeri)
      or(g_players[cam_pl].state>ps_spec)then break;
   end;
end;

procedure ClientActions;
var _mdir: integer;
      _ip: PTPlayer;
      _ir: PTRoom;
      _px,
      _py,
      _pd: single;
begin
   _mdir:=-1;

   if(cl_playeri>MaxPlayers)then exit;

   _ip:=@g_players[cl_playeri];
   _ir:=_ip^.room;

   if(_ir=nil)then exit;

   with _ip^ do
    if(state>ps_none)then
     if(state>ps_spec)
     then cam_pl:=cl_playeri
     else
     begin
        if(cl_acts[a_WN]=1)then CamNext(true );
        if(cl_acts[a_WP]=1)then CamNext(false);
     end;

   if(_ir^.time_scorepause>0)then exit;

   if(cl_action=0)and(_ir^.demo_cstate<>ds_read)then
   begin
   if(cl_acts[a_A ]>0)then cl_action:=aid_attack;
   if(cl_acts[a_WN]=1)then cl_action:=aid_wN;
   if(cl_acts[a_WP]=1)then cl_action:=aid_wP;
   if(cl_acts[a_w1]=1)then cl_action:=aid_w1;
   if(cl_acts[a_w2]=1)then cl_action:=aid_w2;
   if(cl_acts[a_w3]=1)then cl_action:=aid_w3;
   if(cl_acts[a_w4]=1)then cl_action:=aid_w4;
   if(cl_acts[a_w5]=1)then cl_action:=aid_w5;
   if(cl_acts[a_w6]=1)then cl_action:=aid_w6;
   if(cl_acts[a_w7]=1)then cl_action:=aid_w7;
   if(cl_acts[a_w8]=1)then cl_action:=aid_w8;
   if(cl_acts[a_J ]=1)then cl_action:=aid_specjoin;
   end;

   if(cam_pl=cl_playeri)then
   with _ip^ do
   begin
      if(state=ps_spec)or(state>ps_dead)then
      begin
         vdir:=dir_360(vdir+cam_turn);

         _mdir:=move_dir[cl_acts[a_FW]>0,
                         cl_acts[a_BW]>0,
                         cl_acts[a_SL]>0,
                         cl_acts[a_SR]>0];

         if(_mdir>-1)
         then PlayerMove(_ir,@vx,@vy,_mdir+vdir,Player_WWidth,state=ps_spec);
      end;

      if(_ir^.demo_cstate=ds_read)then exit;

      if(state>ps_dead)and(cl_action=aid_attack)and(hud_noammoclk=0)and(gun_rld=0)then
       if(ammo[gun_ammot[gun_curr]]<gun_ammog[gun_curr])then
       begin
          hud_noammoclk:=fr_fpsh1;
          PlaySoundSource(snd_noammo,@cam_x,@cam_y,0,0);
       end;

      if(menu_locmatch)then
      begin
         x   :=vx;
         y   :=vy;
         dir :=vdir;
         wswitch:=player_wswitch;
         G_SvDoClientAction(_ip,cl_action);
         vx  :=x;
         vy  :=y;
         vdir:=dir;
         cl_action:=0;
      end
      else
        if(player_antilag)and(gun_rld=0)and(state>ps_dead)and(cl_action=aid_attack)then
        begin
           _px  :=x;
           _py  :=y;
           _pd  :=dir;
           x    :=vx;
           y    :=vy;
           dir  :=vdir;
           PlayerAttack(_ip,true);
           x  :=_px;
           y  :=_py;
           dir:=_pd;
           net_period:=0;
        end;
   end;
end;

procedure G_ClGame;
var p:byte;
  _pi:PTPlayer;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(state>ps_none)then
     begin
        _pi:=@g_players[p];
        player_cl_vars(_pi);
        if(gun_rld  >0)then gun_rld  -=1;
        if(pause_gun>0)then pause_gun-=1;
        if(tesla_eff>0)then tesla_eff-=1;
        if(state=ps_attk)then
        begin
           if(pnum<>cl_playeri)
           or((pnum=cl_playeri)and(not player_antilag))
           then PlayerShoot(_pi,true);
           state:=ps_walk;
        end;
        if(state=ps_dead)then player_cl_Death(_pi);
     end;

   with sv_clroom^ do
    if(time_scorepause=0)then animation_tick+=1;
end;

procedure menu_reload_maps;
var curmap: shortstring;
begin
   curmap:=g_maps[menu_bmm].mname;
   map_LoadAll;
   menu_bmm:=map_name2n(curmap);
   if(menu_bmm=menu_bmm.MaxValue)then menu_bmm:=0;
end;

{$ELSE}

procedure player_CheckNewPos(aplayer:PTPlayer;nx,ny,ndir:single);
const step  : array[false..true] of integer = (2,1);
{      e     : single = 0.01;
var
cur_step,
max_step: single; }
begin
   with aplayer^ do
   if(state>ps_dead)then
   begin
      if(net_moves<0)
      then exit
      else net_moves-=step[net_fupd];

      {max_step:=Player_max_speed[not net_fupd]+e;
      cur_step:=dist_r(x,y,nx,ny);
      if(cur_step>max_step)then exit;}

      if(RoomCollisionXY(room,nx-Player_WWidth,ny-Player_WWidth,x,y)>=1)
      or(RoomCollisionXY(room,nx-Player_WWidth,ny+Player_WWidth,x,y)>=1)
      or(RoomCollisionXY(room,nx+Player_WWidth,ny+Player_WWidth,x,y)>=1)
      or(RoomCollisionXY(room,nx+Player_WWidth,ny-Player_WWidth,x,y)>=1)then exit;

      x  :=nx;
      y  :=ny;
      dir:=ndir;
   end;
end;

{$ENDIF}
