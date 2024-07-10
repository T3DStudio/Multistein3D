
const
Player_max_hhits  = Player_max_hits  div 2;
Player_max_harmor = Player_max_armor div 2;

var
Player_max_hammo,
Player_max_hhammo : array[0..AmmoTypesN] of integer;

procedure bot_Init;
var i:integer;
begin
   for i:=0 to AmmoTypesN do
   begin
      Player_max_hammo [i]:=Player_max_ammo[i] div 2;
      Player_max_hhammo[i]:=Player_max_ammo[i] div 4;
   end;
end;

function bot_CheckEnemy(en:byte;aplayer:PTPlayer):boolean;
begin
   bot_CheckEnemy:=false;
   if(en<=MaxPlayers)then
     with g_players[en] do
       if(state>ps_dead)and(en<>aplayer^.pnum){and(bot)}and(roomi=aplayer^.roomi)then
         if(team<>aplayer^.team)
         then bot_CheckEnemy:=true
         else
           if(not Room_CheckFlag(room,sv_g_teams))
           then bot_CheckEnemy:=true;
end;

procedure bot_Enemy_CheckPick(aplayer:PTPlayer);
var s:integer;
begin
   if(bot_CheckEnemy(aplayer^.bot_enemy,aplayer))then
     with g_players[aplayer^.bot_enemy] do
       if(not collision_line(room,aplayer^.x,aplayer^.y,x,y))then exit;
   s:=50;
   with aplayer^ do
   repeat
      bot_enemy+=1;
      if(bot_enemy>MaxPlayers)then bot_enemy:=0;
      s-=1;
   until (s<=0)or(bot_CheckEnemy(bot_enemy,aplayer));
end;
function bot_Enemy_CheckForAttack(aplayer:PTPlayer):boolean;
begin
   bot_Enemy_CheckForAttack:=false;
   if(bot_CheckEnemy(aplayer^.bot_enemy,aplayer))then
    with g_players[aplayer^.bot_enemy] do
     if(not collision_line(room,aplayer^.x,aplayer^.y,x,y))then
     begin
        aplayer^.bot_ax:=x;
        aplayer^.bot_ay:=y;
        bot_Enemy_CheckForAttack:=true;
        exit;
     end;
end;

procedure bot_PickMoveTarget(aplayer:PTPlayer);
var
i,o       : cardinal;
w,
pi,pn     : byte;
di,dn     : single;
g_weaponstay,
g_instagib: boolean;

function HaveGoodWeapons:boolean;
var n:byte;
begin
   HaveGoodWeapons:=false;
   with aplayer^ do
    for n:=2 to WeaponsN do
     if((gun_inv and gun_bit[n])>0)then
      if(ammo[gun_ammot[n]]>=Player_max_hhammo[gun_ammot[n]])then
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
       if(ammo[gun_ammot[n]]>=Player_max_hammo[gun_ammot[n]])then
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
      g_instagib  :=Room_CheckFlag(room,sv_g_instagib  );
      g_weaponstay:=Room_CheckFlag(room,sv_g_weaponstay);
      if(bot_ax>0)then   // run for enemy
       if((hits>bot_skill_aggression)and(HaveGoodWeapons))or(g_instagib)then
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

      if(g_instagib)then
      begin
         if(bot_mx>0)and(point_dist(bot_mx,bot_my,x,y)>1)then exit;

         if(r_item_n >0)
         or(r_spawn_n>0)then
         begin
            i:=random(r_item_n+r_spawn_n);
            if(i<r_item_n)then
            begin
               with r_item_l[i] do
               begin
                  bot_mx:=ix;
                  bot_my:=iy;
               end;
               exit;
            end
            else
            begin
               with r_spawn_l[i-r_item_n] do
               begin
                  bot_mx:=spx;
                  bot_my:=spy;
               end;
               exit;
            end;
         end;
      end
      else
      begin
         if(r_item_n>0)then
         begin
            o :=0;
            di:=1000;
            pi:=0;

            for i:=0 to r_item_n-1 do
             with r_item_l[i] do
              if(irespt<fr_fpsx1)then
              begin
                 dn:=point_dist(x,y,ix,iy);

                 pn:=0;
                 if(iweapon>0)then
                   if((iweapon or gun_inv)<>gun_inv)
                   then pn+=1
                   else
                     if(g_weaponstay)then continue;
                 if(ihealth>0)and(hits<Player_max_hits)then
                 begin
                    if(hits<Player_max_hhits)then pn+=4;
                    pn+=4;
                 end;
                 if(iarmor>0)and(armor<Player_max_armor)then
                 begin
                    if(armor<Player_max_harmor)then
                     if(hits<Player_max_hhits)
                     then pn+=3
                     else pn+=4;
                    pn+=4;
                 end;
                 for w:=1 to AmmoTypesN do
                  if(iammo[w]>0)and(ammo[w]<Player_max_ammo[w])then
                  begin
                     if(ammo[w]<Player_max_hhammo[w])then pn+=1;
                     if(ammo[w]<Player_max_hammo [w])then pn+=1;
                     pn+=1;
                  end;

                 if(pn<pi)
                 then continue
                 else
                   if(pn>pi)
                   then
                   else
                     if(dn>di)
                     then continue;

                 pi:=pn;
                 di:=dn;
                 o :=i;
              end;

             if(di<1000)then
              with r_item_l[o] do
              begin
                 bot_mx:=ix;
                 bot_my:=iy;
                 exit;
              end;
          end;
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

procedure bot_Turn(aplayer:PTPlayer);
var pd:single;
begin
   with aplayer^ do
   with room^ do
   begin
      pd:=point_dist(x,y,bot_mx,bot_my);
      if(pd>1.3)
      then bot_md:=dir_turn(bot_md,point_dir(x,y,bot_mx,bot_my),random(10))
      else bot_md:=dir_turn(bot_md,point_dir(x,y,bot_mx,bot_my),random(20));
   end;
end;

procedure bot_Move(aplayer:PTPlayer);
var px,py:single;
begin
   with aplayer^ do
   with room^ do
   begin
      px:=x;
      py:=y;

      player_Move(room,@x,@y,bot_md,Player_BWidth,false);
      bot_md:=point_dir(px,py,x,y);

      if(x=px)and(y=py)then
      begin
         bot_md:=bot_md+random(360);
         player_Move(room,@x,@y,bot_md,Player_BWidth,false);
      end;
   end;
end;

function bot_PickWeaponN(aplayer:PTPlayer;dist:single):byte;
const w_knife    = 0;
    //w_pistol   = 1;
      w_mp40     = 2;
      w_chaingun = 3;
      w_rifle    = 4;
      w_flame    = 5;
    //w_panzer   = 6;
      w_tesla    = 7;
      knife_dist    = 0.6;
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
        if(CheckAndSetWeapon(i,100))then break;
   end;
end;

procedure bot_AttackToPoint(aplayer:PTPlayer;ex,ey:single;attack:boolean);
var endir,d :single;
    t,
    gun_prev:byte;
begin
   with aplayer^ do
   begin
      d    :=point_dist(x,y,ex,ey);
      endir:=point_dir (x,y,ex,ey);
      if(d<1)
      then dir:=endir
      else
      begin
         if(Room_CheckFlag(room,sv_g_instagib))
         then endir+=random(bot_skill_instspread)-random(bot_skill_instspread);
         t  :=round(8/d);
         dir:=dir_turn(dir,endir,random(integer(bot_skill_turnspeed+t)));
      end;

      gun_prev:=gun_curr;
      gun_next:=bot_PickWeaponN(aplayer,d);

      if(gun_next=gun_curr)and(gun_prev=gun_curr)and(attack)then
       if(abs(dir_diff(endir,dir))<8)or(d<1)then
        if(d<=gun_dist[gun_curr])then player_Attack(aplayer{$IFDEF FULLGAME},false{$ENDIF});
   end
end;

procedure bot_Think(aplayer:PTPlayer);
var shoot:boolean;
begin
   with aplayer^ do
   with room^ do
   if(time_scorepause=0)then
   case state of
ps_none: ;
ps_spec: if(cur_players>0)then player_SpecJoin(aplayer);
ps_dead: player_Respawn(aplayer,false);
ps_walk,
ps_attk: begin
            if(bot_reaction>0)
            then bot_reaction-=1
            else
            begin
               bot_PickMoveTarget (aplayer);
               bot_Enemy_CheckPick(aplayer);
               bot_reaction:=bot_skill_reaction;
            end;

            if(bot_skill_shootfreq<2)
            then shoot:=true
            else shoot:=(bot_reaction mod bot_skill_shootfreq)=0;

            bot_Turn(aplayer);

            if(bot_reaction<=bot_skill_moveskip)then bot_Move(aplayer);
            if(bot_Enemy_CheckForAttack(aplayer))
            then bot_AttackToPoint(aplayer,g_players[bot_enemy].x,
                                           g_players[bot_enemy].y,shoot)
            else
              if(gun_rld=0)then dir:=dir_turn(dir,bot_md,8);
         end;
   end;
end;

procedure bot_SetSkill(aplayer:PTPlayer;skill:byte);
begin
   with aplayer^ do
   begin
      if(skill>100)then skill:=100;
      if(skill<1  )then skill:=1;

      bot_skill_turnspeed :=round(2+skill/8);
      bot_skill_moveskip  :=70;

      skill:=100-skill;
      bot_skill_reaction  :=skill;
      bot_skill_shootfreq :=bot_skill_reaction div 4;
      bot_skill_aggression:=skill;
      bot_skill_instspread:=round(skill/5);

      bot_reaction:=random(bot_skill_reaction);
   end;
end;

procedure bot_RoomCountControl(aroom:PTRoom);
var t,bn:byte;
begin
   with aroom^ do
    if(cur_clients<max_clients)then
     for t:=0 to MaxTeamsI do
      if(bot_curt[t]<bot_maxt[t])then
      begin
         bn:=net_NewPlayer(0,0,aroom^.rnum,str_BotBaseName+'['+b2s(bot_skill_default)+'] '+str_teams[t]+' #'+b2s(bot_curt[t]+1),t,true,false);
         if(bn>0)then bot_SetSkill(@g_players[bn],bot_skill_default);
      end;
end;

