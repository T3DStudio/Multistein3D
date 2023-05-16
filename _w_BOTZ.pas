
function line_see(aroom:PTRoom;x0,y0,x1,y1:single):boolean;
var px,py,sx,sy,d:single;
begin
   line_see:=true;
   if(x0=x1)and(y0=y1)then exit;

   d:=dist_r(x0,y0,x1,y1)*2;
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
         line_see:=false;
         break;
      end;
   end;
end;

function _CheckEnemy(en:byte;aplayer:PTPlayer):boolean;
begin
   _CheckEnemy:=false;
   if(en<=MaxPlayers)then
    with _players[en] do
     if(state>ps_dead)and(en<>aplayer^.pnum){and(bot)}and(roomi=aplayer^.roomi)then
      if(RoomFlag(room,sv_g_teams)=false)
      then _CheckEnemy:=true
      else
        if(team<>aplayer^.team)then _CheckEnemy:=true;
end;

function _BotPlayerEnemy(aplayer:PTPlayer):boolean;
var s:integer;
begin
   _BotPlayerEnemy:=false;
   if(_CheckEnemy(aplayer^.bot_enemy,aplayer))then
    with _players[aplayer^.bot_enemy] do
     if(line_see(room,aplayer^.x,aplayer^.y,x,y))then
     begin
        _BotPlayerEnemy:=true;
        aplayer^.bot_ax:=x;
        aplayer^.bot_ay:=y;
        exit;
     end;
   s:=50;
   with aplayer^ do
   repeat
      bot_enemy+=1;
      if(bot_enemy>MaxPlayers)then bot_enemy:=0;
      s-=1;
   until (s<=0)or(_CheckEnemy(bot_enemy,aplayer));
end;

procedure _BotTarget(aplayer:PTPlayer);
const btt_health= 1;
      btt_ammo  = 2;
      btt_armor = 3;
var i,o:integer;
    w  :byte;
    ni,d:single;
    insta:boolean;
begin
   with aplayer^ do
   with room^ do
   begin
      insta:=RoomFlag(room,sv_g_instagib);
      if(bot_ax>0)then
       if((hits>50)and(ammo[1]>50)and((gun_inv and %11111100)>0))or(insta)then
        if(dist_r(bot_ax,bot_ay,x,y)<2)then
        begin
           bot_ax:=0;
           bot_ay:=0;
        end
        else
        begin
           bot_mx:=bot_ax;
           bot_my:=bot_ay;
           exit;
        end;
      if(r_itemn>0)then
      begin
         w:=0;

         if(not insta)then
          if(hits<50)
          then w:=btt_health
          else
           if(ammo[1]<50)
           then w:=btt_ammo
           else
             if(hits<Player_max_hits)
             then w:=btt_health
             else
              if(ammo[1]<100)
              then w:=btt_ammo
              else
               if(armor<Player_max_armor)
               then w:=btt_armor
               else
                if(ammo[1]<Player_max_ammo[1])
                then w:=btt_ammo;

         o :=random(r_itemn);
         ni:=1000;

         if(w>0)then
          for i:=0 to r_itemn-1 do
           with r_items[i] do
            if(irespt<fr_fps)then
            begin
               case w of
      btt_health: if(ihealth <=0)and
                    (iarmor  <=0)then continue;
      btt_ammo  : if(iammo[1]<=0)then continue;
      btt_armor : if(iarmor  <=0)then continue;
               end;

               if(RoomFlag(room,sv_g_itemrespawn)=false)or(RoomFlag(room,sv_g_weaponstay))then
                if(iweapon>0)and((iweapon or gun_inv)=gun_inv)then continue;

               d:=dist_r(x,y,ix,iy);
               if(d<ni)then
               begin
                  ni:=d;
                  o :=i;
               end;
            end;

         if(ni=1000)then
          if(bot_mx>0)and(dist_r(bot_mx,bot_my,x,y)>1)then exit;

         with r_items[o] do
         begin
            bot_mx:=ix;
            bot_my:=iy;
         end;
         exit;
      end;
      if(r_spawnn>0)then
      begin
         i:=random(r_spawnn);
         with r_spawns[i] do
         begin
            bot_mx:=spx;
            bot_my:=spy;
         end;
         exit;
      end;
      bot_mx:=random(map_mlw);
      bot_my:=random(map_mlw);
   end;
end;

procedure _BotMove(aplayer:PTPlayer);
var px,py,pd:single;
begin
   with aplayer^ do
   with room^ do
   begin
      pd:=dist_r(x,y,bot_mx,bot_my);
      if(pd>1.3)
      then bot_md:=dir_turn(bot_md,p_dir(x,y,bot_mx,bot_my),random(10))
      else bot_md:=dir_turn(bot_md,p_dir(x,y,bot_mx,bot_my),random(20));
      px:=x;
      py:=y;

      PlayerMove(room,@x,@y,bot_md,Player_BWidth,false);
      bot_md:=p_dir(px,py,x,y);

      if(x=px)and(y=py)then
      begin
         bot_md:=bot_md+random(360);
         PlayerMove(room,@x,@y,bot_md,Player_BWidth,false);
      end;
   end;
end;

function _CheckWeapon(aplayer:PTPlayer;gn:byte):boolean;
begin
   _CheckWeapon:=false;
   with aplayer^ do
    if(gn<=WeaponsN)then _CheckWeapon:=((gun_inv and gun_bit[gn])>0)and(ammo[gun_ammot[gn]]>=gun_ammog[gn]);
end;

function _BotWeaponN(aplayer:PTPlayer;dist:single):byte;
const w_knife    = 0;
      w_pistol   = 1;
      w_mp40     = 2;
      w_chaingun = 3;
      w_rifle    = 4;
      knife_dist    = 0.7;
      chaingun_dist = 10;
begin
   with aplayer^ do
   begin
      if(dist<=knife_dist)
      then begin _BotWeaponN:=w_knife; exit; end
      else
        if(dist<chaingun_dist)and(_CheckWeapon(aplayer,w_chaingun))
        then begin _BotWeaponN:=w_chaingun; exit; end
        else
          if(dist>=chaingun_dist)then
           if(_CheckWeapon(aplayer,w_rifle))
           then begin _BotWeaponN:=w_rifle; exit; end
           else
             if(_CheckWeapon(aplayer,w_mp40))
             then begin _BotWeaponN:=w_mp40; exit; end;

      for _BotWeaponN:=WeaponsN downto 0 do
       if(_CheckWeapon(aplayer,_BotWeaponN))then break;
   end;
end;

procedure _BotAttackPoint(aplayer:PTPlayer;ex,ey:single);
const bot_att_disp = 8;
var endir,d:single;
    gun_prev:byte;
begin
   with aplayer^ do
   begin
      d    :=dist_r(x,y,ex,ey);
      //if(_players[bot_enemy].bot)
      //then endir:=p_dir (x,y,ex,ey)
      //else
      endir:=p_dir (x,y,ex,ey)-random(bot_att_disp)+random(bot_att_disp);
      dir:=dir_turn(dir,endir,random(bot_att_disp));

      gun_prev:=gun_curr;
      gun_next:=_BotWeaponN(aplayer,d);

      if(gun_next=gun_curr)and(gun_prev=gun_curr)then
       if(abs(dir_diff(endir,dir))<bot_att_disp)or(d<1)then
        if(d<=gun_dist[gun_curr])then PlayerAttack(aplayer{$IFDEF FULLGAME},false{$ENDIF});
   end
end;

procedure _BotAttack(aplayer:PTPlayer);
begin
   with aplayer^ do
   begin
      _BotAttackPoint(aplayer,_players[bot_enemy].x,_players[bot_enemy].y);
   end;
end;

procedure BotThink(aplayer:PTPlayer);
begin
   with aplayer^ do
   with room^ do
   if(time_scorepause=0)then
   case state of
ps_none: ;
ps_spec: if(cur_players>0)then PlayerSpecJoin(aplayer);
ps_dead: PlayerRespawn(aplayer,false);
ps_walk,
ps_attk: begin
            if(bot_tpause>0)
            then bot_tpause-=1
            else
            begin
               _BotTarget(aplayer);
               bot_tpause:=fr_fps;
            end;

            _BotMove(aplayer);
            if(_BotPlayerEnemy(aplayer))
            then _BotAttack(aplayer)
            else if(gun_rld=0)then dir:=dir_turn(dir,bot_md,5);
         end;
   end;
end;

procedure BotControl(aroom:PTRoom);
var t:byte;
begin
   with aroom^ do
    if(cur_clients<max_clients)then
     for t:=0 to MaxTeamsI do
      if(bot_curt[t]<bot_maxt[t])then net_NewPlayer(0,0,aroom^.rnum,'BOT '+str_teams[t]+' #'+b2s(bot_curt[t]+1),t,true,false);
end;
