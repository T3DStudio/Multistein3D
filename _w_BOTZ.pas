
var
bat_h2_ammo,
bat_h4_ammo  : array[0..AmmoTypesN] of integer;

procedure bot_Init;
var i:integer;
begin
   for i:=0 to AmmoTypesN do
   begin
      bat_h2_ammo[i]:=Player_max_ammo[i] div 2;
      bat_h4_ammo[i]:=Player_max_ammo[i] div 4;
   end;
end;

function bot_CheckEnemy(en:byte;aplayer:PTPlayer):boolean;
begin
   bot_CheckEnemy:=false;
   if(en<=MaxPlayers)then
     with g_players[en] do
       if(state>ps_dead)and(en<>aplayer^.pnum)and(bot)and(roomi=aplayer^.roomi)then
         if(team<>aplayer^.team)
         then bot_CheckEnemy:=true
         else
           if(not Room_CheckFlag(room,sv_g_teams))
           then bot_CheckEnemy:=true;
end;

function bot_PickEnemy(aplayer:PTPlayer):boolean;
var s:integer;
begin
   bot_PickEnemy:=false;
   if(bot_CheckEnemy(aplayer^.bot_enemy,aplayer))then
    with g_players[aplayer^.bot_enemy] do
     if(not collision_line(room,aplayer^.x,aplayer^.y,x,y))then
     begin
        bot_PickEnemy:=true;
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
   until (s<=0)or(bot_CheckEnemy(bot_enemy,aplayer));
end;

procedure bot_PickTarget(aplayer:PTPlayer);
const btt_health = 1;
      btt_ammo   = 2;
      btt_armor  = 3;
var   i,o : integer;
        w : byte;
      ni,d: single;
g_instagib: boolean;
function HaveGoodWeapons:boolean;
var n:byte;
begin
   HaveGoodWeapons:=false;
   with aplayer^ do
    for n:=2 to WeaponsN do
     if((gun_inv and gun_bit[n])>0)then
      if(ammo[gun_ammot[n]]>=bat_h4_ammo[gun_ammot[n]])then
      begin
         HaveGoodWeapons:=true;
         break;
      end;
end;
function HaveLowAmmo:boolean;
var n:byte;
begin
   HaveLowAmmo:=false;
   with aplayer^ do
    for n:=2 to WeaponsN do
     if((gun_inv and gun_bit[n])>0)then
       if(ammo[gun_ammot[n]]>=bat_h2_ammo[gun_ammot[n]])then
       begin
          HaveLowAmmo:=false;
          break;
       end
       else HaveLowAmmo:=true;
end;
function HaveNotFullAmmo:boolean;
var n:byte;
begin
   HaveNotFullAmmo:=false;
   with aplayer^ do
    for n:=2 to WeaponsN do
     if((gun_inv and gun_bit[n])>0)then
       if(ammo[gun_ammot[n]]=Player_max_ammo[gun_ammot[n]])then
       begin
          HaveNotFullAmmo:=false;
          break;
       end
       else HaveNotFullAmmo:=true;
end;
begin
   with aplayer^ do
   with room^ do
   begin
      g_instagib:=Room_CheckFlag(room,sv_g_instagib);
      if(bot_ax>0)then   // run for enemy
       if((hits>50)and(HaveGoodWeapons))or(g_instagib)then
        if(point_dist(bot_ax,bot_ay,x,y)<2)then
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

      if(r_item_n>0)then
      begin
         w:=0;

         if(not g_instagib)then
          if(hits<50)
          then w:=btt_health
          else
           if(HaveLowAmmo)
           then w:=btt_ammo
           else
             if(hits<Player_max_hits)
             then w:=btt_health
             else
              if(HaveNotFullAmmo)
              then w:=btt_ammo
              else
               if(armor<Player_max_armor)
               then w:=btt_armor;

         o :=random(r_item_n);
         ni:=1000;

         if(w>0)then
          for i:=0 to r_item_n-1 do
           with r_item_l[i] do
            if(irespt<fr_fpsx1)then
            begin
               case w of
      btt_health: if(ihealth <=0)and
                    (iarmor  <=0)then continue;
      btt_ammo  : if(iammo[1]> 0)
                  or(iammo[2]> 0)
                  or(iammo[3]> 0)
                  or(iammo[4]> 0)
                  or(iammo[5]> 0)then
                                 else continue;
      btt_armor : if(iarmor  <=0)then continue;
               end;

               if(not Room_CheckFlag(room,sv_g_itemrespawn))
               or(Room_CheckFlag(room,sv_g_weaponstay))
               then
                 if(iweapon>0)and((iweapon or gun_inv)=gun_inv)then continue;

               d:=point_dist(x,y,ix,iy);
               if(d<ni)then
               begin
                  ni:=d;
                  o :=i;
               end;
            end;

         if(ni=1000)then
          if(bot_mx>0)and(point_dist(bot_mx,bot_my,x,y)>1)then exit;

         with r_item_l[o] do
         begin
            bot_mx:=ix;
            bot_my:=iy;
         end;
         exit;
      end;
      if(r_spawn_n>0)then
      begin
         i:=random(r_spawn_n);
         with r_spawn_l[i] do
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

procedure bot_Move(aplayer:PTPlayer);
var px,py,pd:single;
begin
   with aplayer^ do
   with room^ do
   begin
      pd:=point_dist(x,y,bot_mx,bot_my);
      if(pd>1.3)
      then bot_md:=dir_turn(bot_md,point_dir(x,y,bot_mx,bot_my),random(10))
      else bot_md:=dir_turn(bot_md,point_dir(x,y,bot_mx,bot_my),random(20));
      px:=x;
      py:=y;

      PlayerMove(room,@x,@y,bot_md,Player_BWidth,false);
      bot_md:=point_dir(px,py,x,y);

      if(x=px)and(y=py)then
      begin
         bot_md:=bot_md+random(360);
         PlayerMove(room,@x,@y,bot_md,Player_BWidth,false);
      end;
   end;
end;

function bot_PickWeaponN(aplayer:PTPlayer;dist:single):byte;
const w_knife    = 0;
      w_pistol   = 1;
      w_mp40     = 2;
      w_chaingun = 3;
      w_rifle    = 4;
      w_flame    = 5;
      w_panzer   = 6;
      w_tesla    = 7;
      knife_dist    = 0.7;
      chaingun_dist = 10;
var i:byte;
function CheckAndSetWeapon(gn:byte;gdist:single):boolean;
begin
   CheckAndSetWeapon:=false;
   if(dist>gdist)then exit;
   with aplayer^ do
     if(gn<=WeaponsN)then
     begin
        CheckAndSetWeapon:=((gun_inv and gun_bit[gn])>0)and(ammo[gun_ammot[gn]]>=gun_ammog[gn]);
        if(CheckAndSetWeapon)then bot_PickWeaponN:=gn;
     end;
end;
begin
   with aplayer^ do
   begin
      bot_PickWeaponN:=255;

      if(not CheckAndSetWeapon(w_knife   ,knife_dist       ))then
      if(not CheckAndSetWeapon(w_tesla   ,gun_dist[w_tesla]))then
      if(not CheckAndSetWeapon(w_chaingun,chaingun_dist    ))then
      if(not CheckAndSetWeapon(w_flame   ,chaingun_dist    ))then
      if(not CheckAndSetWeapon(w_rifle   ,100              ))then
      if(not CheckAndSetWeapon(w_mp40    ,100              ))then
       for i:=WeaponsN downto 0 do
        if(CheckAndSetWeapon(100,i))then break;
   end;
end;

procedure bot_AttackToPoint(aplayer:PTPlayer;ex,ey:single);
const bot_att_disp = 8;
var endir,d :single;
    gun_prev:byte;
begin
   with aplayer^ do
   begin
      d    :=point_dist(x,y,ex,ey);
      //if(g_players[bot_enemy].bot)
      //then endir:=point_dir (x,y,ex,ey)
      //else
      endir:=point_dir (x,y,ex,ey)-random(bot_att_disp)+random(bot_att_disp);
      dir  :=dir_turn(dir,endir,random(bot_att_disp));

      gun_prev:=gun_curr;
      gun_next:=bot_PickWeaponN(aplayer,d);

      if(gun_next=gun_curr)and(gun_prev=gun_curr)then
       if(abs(dir_diff(endir,dir))<bot_att_disp)or(d<1)then
        if(d<=gun_dist[gun_curr])then PlayerAttack(aplayer{$IFDEF FULLGAME},false{$ENDIF});
   end
end;

procedure bot_Attack(aplayer:PTPlayer);
begin
   with aplayer^ do
   bot_AttackToPoint(aplayer,g_players[bot_enemy].x,
                             g_players[bot_enemy].y);
end;

procedure bot_Think(aplayer:PTPlayer);
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
            if(bot_reaction>0)
            then bot_reaction-=1
            else
            begin
               bot_PickTarget(aplayer);
               bot_reaction:=fr_fpsx1;
            end;

            bot_Move(aplayer);
            if(bot_PickEnemy(aplayer))
            then //bot_Attack(aplayer)
            else
              if(gun_rld=0)then dir:=dir_turn(dir,bot_md,5);
         end;
   end;
end;

procedure bot_RoomCountControl(aroom:PTRoom);
var t:byte;
begin
   with aroom^ do
    if(cur_clients<max_clients)then
     for t:=0 to MaxTeamsI do
      if(bot_curt[t]<bot_maxt[t])then net_NewPlayer(0,0,aroom^.rnum,str_BotBaseName+str_teams[t]+' #'+b2s(bot_curt[t]+1),t,true,false);
end;
