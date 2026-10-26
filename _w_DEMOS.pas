
const
block_word_sizeP   = 1000;
map_word_sizeP     = map_mlw*block_word_sizeP; //65000
block_word_sizeM   = 500;
map_word_sizeM     = map_mlw*block_word_sizeM; //32500

demo_timer1_period = 2;


function ps2w (x:single ):word   ;begin ps2w :=mm3w(0,round(x*block_word_sizeP),map_word_sizeP);end;
function ms2w (x:single ):word   ;begin ms2w :=mm3w(0,round(x*block_word_sizeM),map_word_sizeM);end;
function dir2i(x:single ):integer;begin dir2i:=round(x*90);end;

////////////////////////////////////////////////////////////////////////////////
//
//  COMMON GAME DATA: WRITE
//

procedure gdataw_roominfo(aproom:PTRoom;pf:pfile);
var p:byte;
begin
   with aproom^ do
   begin
      wudata_string(rname        ,pf);
      wudata_byte  (max_clients  ,pf);
      wudata_byte  (max_players  ,pf);
      wudata_card  (g_flags      ,pf);
      wudata_int   (g_fraglimit  ,pf);
      wudata_int   (g_spreadlimit,pf);
      wudata_byte  (g_timelimit  ,pf);
      wudata_byte  (g_teams      ,pf);
      wudata_byte  (cur_clients  ,pf);
      wudata_byte  (cur_players  ,pf);
      wudata_string(mapname      ,pf);
   end;
   for p:=0 to MaxPlayers do
     with g_players[p] do
       if(room=aproom)and(state>ps_spec)then
         wudata_string(name,pf);
   for p:=0 to MaxPlayers do
     with g_players[p] do
       if(room=aproom)and(state=ps_spec)then
         wudata_string(name,pf);
end;

procedure gdataw_pdata(aproom:PTRoom;pdata_player:pbyte;pf:pfile);
var pb:byte;
    pw:word;
    pl:PTPlayer;
begin
   pb:=pdata_player^;
   repeat
      pdata_player^+=1;
      if(pdata_player^>MaxPlayers)then pdata_player^:=0;
      pl:=@g_players[pdata_player^];
      if(pl^.room=aproom)and(pl^.state>ps_none)then break;
   until (pdata_player^=pb);
   wudata_byte(pdata_player^,pf);

   with pl^ do
   begin
      pw:=ping;
      SetWBit(@pw,15,menustate);
      wudata_word(pw,pf);
      if(state>ps_spec)then wudata_int(frags,pf);
      wudata_string(name,pf);
   end;
end;

procedure gdataw_RoomLog(aproom:PTRoom;plog_n,pause_var:pword;pause_time:word;pf:pfile);
var
li,l,
lc  :word;
   b:byte;
begin
   if(pause_var<>nil)then
     if(pause_var^>0)then
     begin
        wudata_byte(0,pf);
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

      wudata_byte(lc,pf);
      if(pf<>nil)
      then plog_n^+=lc
      else wudata_word(aproom^.log_n,pf);
      while(lc>0)do
      begin
         if(li=MaxRoomLog)
         then li:=0
         else li+=1;
         lc-=1;
         with aproom^.log_l[li] do
         begin
            b:=data_id;
            if(length(data_string)>0)
            then b:=b or  %10000000
            else b:=b and %01111111;
            wudata_byte(b,pf);
            if(b and %10000000)>0 then wudata_string(data_string,pf);
         end;
      end;

      if(pause_var<>nil)then pause_var^:=pause_time;
   end
   else wudata_byte(0,pf);
end;
procedure gdataw_roomitems_seg(aproom:PTRoom;pmdata_item:pword;pf:pfile);
var b,
    i:byte;
begin
   with aproom^    do
   if(r_item_n>0)then
   begin
      b:=0;
      for i:=0 to 7 do
      begin
         pmdata_item^:=(pmdata_item^+1) mod r_item_n;
         SetBBit(@b,i,r_item_l[pmdata_item^].irespt<=0);
      end;
      wudata_byte(b,pf);
   end;
end;
procedure gdataw_RoomItems(aproom:PTRoom;pmdata_item:pword;pf:pfile);
begin
   with aproom^    do
   if(r_item_n>0)then
   begin
      if(pf=nil)then
      begin
      wudata_word(pmdata_item^,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
      end;
      gdataw_roomitems_seg(aproom,pmdata_item,pf);
   end;
end;
procedure gdataw_RoomMissiles(aproom:PTRoom;pf:pfile);
var
w,
m       : word;
m_count : byte;
begin
   with aproom^ do
   begin
      m_count:=0;
      if(r_missile_n>0)then
       for m:=0 to r_missile_n-1 do
       begin
          if(m=255)then break;
          with r_missile_l[m] do
            if(mtype>0)then m_count+=1;
          if(m_count=255)then break;
       end;

      wudata_byte(m_count,pf);
      if(m_count>0)then
       for m:=0 to r_missile_n-1 do
        with r_missile_l[m] do
         if(mtype>0)then
         begin
            wudata_byte(m,pf);
            w:=ms2w(mx);
            SetWBit(@w,15,mtype=gpt_fire);
            wudata_word(w,pf);
            wudata_word(ms2w(my),pf);
            m_count-=1;
            if(m_count=0)then break;
         end;
   end;
end;
function PlayerGetStateByte(p:byte):byte;
begin
   PlayerGetStateByte:=0;
   with g_players[p] do
   if(state>ps_none)then
   begin
      if(state>ps_dead)and((gun_reload>gun_reload_s[gun_curr])or((gun_reload>0)and(hans_mode>0)))
      then PlayerGetStateByte:=ps_attk
      else PlayerGetStateByte:=state;
      if(state>ps_dead)and(hans_mode>0)then PlayerGetStateByte+=2;

      if(state>=ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((team     and %00000011) shl 3);
      if(state> ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((gun_curr and %00000111) shl 5);
   end;
end;

procedure gdataw_RoomPlayers(aproom:PTRoom;pf:pfile);
var
p,i,b: byte;
w_ping,
w_x,
w_y  : word;
begin
   i:=0;
   for p:=1 to MaxPlayers do
    with g_players[p] do
     if(room=aproom)and(state>ps_none)and(i<255)then i+=1;

   wudata_byte(i,pf);
   if(i>0)then
    for p:=1 to MaxPlayers do
     with g_players[p] do
      if(room=aproom)and(state>ps_none)then
      begin
         wudata_byte(p,pf);
         wudata_byte(PlayerGetStateByte(p),pf);
         b:=0;
         with aproom^.demo_pvars[p] do
         begin
            SetBBit(@b,0,dppi_name<>name);

            w_ping:=ping;
            SetWBit(@w_ping,15,menustate);
            SetBBit(@b,1,(aproom^.demo_timer2=0)and(dppi_ping<>w_ping));

            if(state>ps_spec)then
            begin
               w_x  :=ps2w(x);
               w_y  :=ps2w(y);

               SetBBit(@b,2, dppi_frags<>frags);
               SetBBit(@b,3, dppi_hits <>hits );
               if(state>ps_dead)then
               begin
                  SetBBit(@b,4,(dppi_x       <>w_x   )
                             or(dppi_y       <>w_y   ));
                  SetBBit(@b,5, dppi_armor   <>armor  );
                  SetBBit(@b,6, dppi_gun_inv <>gun_inv);
                  SetBBit(@b,7,(dppi_cur_ammo<>ammo[cdgun_ammot[gun_curr]])and(cdgun_ammot[gun_curr]>0));
               end;
            end;
            wudata_byte(b,pf);
            if(b>0)then
            begin
               if(GetBBit(b,0))then begin wudata_string(name       ,pf);dppi_name    :=name;   end;
               if(GetBBit(b,1))then begin wudata_word  (w_ping     ,pf);dppi_ping    :=w_ping; end;
               if(GetBBit(b,2))then begin wudata_int   (frags      ,pf);dppi_frags   :=frags;  end;
               if(GetBBit(b,3))then begin wudata_sint  (h2si(hits ),pf);dppi_hits    :=hits;   end;
               if(GetBBit(b,4))then begin wudata_word  (w_x        ,pf);dppi_x       :=w_x;
                                          wudata_word  (w_y        ,pf);dppi_y       :=w_y;    end;
               if(GetBBit(b,5))then begin wudata_sint  (h2si(armor),pf);dppi_armor   :=armor;  end;
               if(GetBBit(b,6))then begin wudata_byte  (gun_inv    ,pf);dppi_gun_inv :=gun_inv;end;
               if(GetBBit(b,7))then begin wudata_byte  (byte(ammo[cdgun_ammot[gun_curr]])
                                                                   ,pf);dppi_cur_ammo:=ammo[cdgun_ammot[gun_curr]]; end;
            end;
            if(state> ps_dead )then
            begin
               wudata_int (dir2i(dir),pf);
               if(hans_mode>0)then
               wudata_byte(byte(hans_mode div fr_fpsx1)+1,pf);
            end;
         end;
         i-=1;
         if(i=0)then break;
      end;
end;

procedure gdataw_gamedata(aproom:PTRoom;pf:pfile);
begin
   with aproom^    do
   begin
      demo_timer1:=(demo_timer1+1) mod demo_timer1_period; // every second tic / 30 tics per sec
      if(demo_timer1>0)then exit;

      demo_timer2+=demo_timer1_period;
      if(demo_timer2>=fr_fpsx1)then demo_timer2:=0;

      gdataw_RoomPlayers (aproom,pf);
      gdataw_RoomLog     (aproom,@demo_logn,nil,0,pf);
      if(cur_players>0)then
      begin
      gdataw_RoomItems   (aproom,@demo_items,pf);
      gdataw_RoomMissiles(aproom,pf);
      end;
   end;
end;

{$IFDEF FULLGAME}
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON GAME DATA: READ
//

function pw2s (x:word   ):single ;begin pw2s :=x/block_word_sizeP;end;
function mw2s (x:word   ):single ;begin mw2s :=x/block_word_sizeM;end;
function i2dir(x:integer):single ;begin i2dir:=x/90;end;

procedure demo_addpos(aproom:PTRoom);
var
fpos:cardinal;
   p:byte;
begin
   with aproom^ do
   if(demo_file<>nil)then
   begin
      if(eof(demo_file^))then exit;

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

         dp_players_N :=0;
         setlength(dp_players_L,0);
         for p:=1 to MaxPlayers do
          with g_players[p] do
           if(room=aproom)and(state>ps_none)then
           begin
              dp_players_N+=1;
              setlength(dp_players_L,dp_players_N);
              with dp_players_l[dp_players_N-1] do
              begin
                 pnum:=p;
                 dppi_name     :=name;
                 dppi_ping     :=ping;
                 dppi_x        :=x;
                 dppi_y        :=y;
                 dppi_hits     :=hits;
                 dppi_armor    :=armor;
                 dppi_gun_cur  :=gun_curr;
                 dppi_frags    :=frags;
                 dppi_gun_inv  :=gun_inv;
                 dppi_cur_ammo :=ammo[cdgun_ammot[gun_curr]];
                 dppi_menustate:=menustate;
                 dppi_hans     :=hans_mode;
              end;
           end;
      end;
   end;
end;

function demo_setpos(aproom:PTRoom;shift:int64):boolean;
var i,ni: cardinal;
   vt,vi,
  target: int64;
       p: byte;
begin
   demo_setpos:=false;
   with aproom^ do
   if(demo_file<>nil)and(demo_fpos_n>0)then
   begin
      target:=demo_fpos_t+shift;

      ni:=cardinal.MaxValue;
      vi:=0;
      for i:=0 to demo_fpos_n-1 do
      begin
         if(shift<0)and(demo_fpos_l[i].dp_tick>demo_fpos_t)then continue;
         if(shift>0)and(demo_fpos_l[i].dp_tick<demo_fpos_t)then continue;

         vt:=abs(target-demo_fpos_l[i].dp_tick);
         if(vt<vi)or(ni=cardinal.MaxValue)then
         begin
            vi:=vt;
            ni:=i;
         end;
      end;

      if(ni>=demo_fpos_n)then exit;

      demo_setpos:=true;

      with demo_fpos_l[ni] do
      begin
         time_tick:=dp_time_tick;
         room_TimeUpdate(aproom);

         time_scorepause:=dp_time_scorepause;
         demo_items:=dp_demo_items;

         if(dp_players_N>0)then
          for p:=0 to dp_players_N-1 do
           with dp_players_l[p] do
            with g_players[pnum] do
            begin
               name     := dppi_name;
               ping     := dppi_ping;
               x        := dppi_x;
               y        := dppi_y;
               hits     := dppi_hits;
               armor    := dppi_armor;
               gun_curr := dppi_gun_cur;
               frags    := dppi_frags;
               gun_inv  := dppi_gun_inv;
               ammo[cdgun_ammot[gun_curr]]
                        := dppi_cur_ammo;
               menustate:= dppi_menustate;
            end;

         demo_fpos_t:=dp_tick;
         Seek(demo_file^,dp_fpos);
      end;

      demo_skip:=2;
      demo_play_end:=false;
   end;
end;

procedure demos_RemakeMenuList;
var Info : TSearchRec;
       s : shortstring;
begin
   demos_n:=0;
   setlength(demos_l,0);
   setlength(demos_s,0);

   if(FindFirst(str_demofolder+'*'+str_demoext,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       if(length(s)>0)then
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

procedure gdatar_RoomInfo(aproom:PTRoom;pf:pfile);
var p:byte;
begin
   with aproom^ do
   begin
      rname        :=rudata_string(pf);
      max_clients  :=rudata_byte  (pf,0);
      max_players  :=rudata_byte  (pf,0);
      g_flags      :=rudata_card  (pf,0);
      g_fraglimit  :=rudata_int   (pf,0);
      g_spreadlimit:=rudata_int   (pf,0);
      g_timelimit  :=rudata_byte  (pf,0);
      g_teams      :=rudata_byte  (pf,0);
      cur_clients  :=rudata_byte  (pf,0);
      cur_players  :=rudata_byte  (pf,0);
      mapname      :=rudata_string(pf);
      if(cur_clients>0)then
        for p:=1 to cur_clients do rudata_string(pf);
   end;
end;

procedure gdatar_pdata(pf:pfile);
var pd:byte;
lfrags:integer;
begin
   pd:=rudata_byte(pf,0);
   if(pd<=MaxPlayers)then
   with g_players[pd] do
   begin
      lfrags:=frags;

      ping    :=rudata_word(pf,0);

      menustate:=GetWBit(@ping,15);
      SetWBit(@ping,15,false);

      if(state>ps_spec)then
      frags   :=rudata_int(pf,0);

      name    :=rudata_string(pf);

      if(frags>lfrags)then spec_LastFrager:=pd;
   end;
end;

procedure gdatar_RoomLog(aproom:PTRoom;pf:pfile);
var pl,pd  : word;
data_id    : byte;
data_string: shortstring;
begin
   pl:=rudata_byte(pf,0);
   if(pl>0)then
   begin
      if(pf=nil)then pd:=rudata_word(pf,0);
      while(pl>0)do
      begin
         data_id:=rudata_byte(pf,0);
         if((data_id and %10000000)>0)
         then data_string:=rudata_string(pf)
         else data_string:='';
         data_id:=data_id and %01111111;
         room_log_add(aproom,data_id,data_string,false);
         pl-=1;
      end;
      if(pf=nil)then aproom^.log_n:=pd;
   end;
end;

procedure gdatar_RoomItems_seg(aproom:PTRoom;pitem:pword;pf:pfile);
var b,
    i :byte;
begin
   with aproom^ do
   begin
      b:=rudata_byte(pf,0);
      for i:=0 to 7 do
      begin
         pitem^:=(pitem^+1) mod r_item_n;
         r_item_l[pitem^].irespt:=integer(not GetBBit(b,i));
      end;
   end;
end;
procedure gdatar_RoomItems(aproom:PTRoom;pf:pfile);
var item:word;
   pitem:pword;
begin
   with aproom^ do
   if(r_item_n>0)then
   begin
      if(pf=nil)then
      begin
         item :=rudata_word(pf,0);
         pitem:=@item;
      end
      else pitem:=@demo_items;

      if(pf=nil)then
      begin
      gdatar_RoomItems_seg(aproom,pitem,pf);
      gdatar_RoomItems_seg(aproom,pitem,pf);
      gdatar_RoomItems_seg(aproom,pitem,pf);
      end;
      gdatar_RoomItems_seg(aproom,pitem,pf);
   end;
end;
procedure gdatar_RoomMissiles(aproom:PTRoom;pf:pfile);
var
cm,pm,
ntype,
m_count : byte;
nx,ny   : single;
x       : word;
procedure MissileExplode(am:byte);
begin
   with aproom^.r_missile_l[am] do
   begin
      if(mtype>0)
      then eff_MissileExplode(@aproom^.r_missile_l[am]);
      mtype:=0;
      mdir :=-1;
   end;
end;
begin
   m_count:=rudata_byte(pf,0);
   with aproom^ do
   begin
      if(r_missile_n<>255)then
      begin
         r_missile_n:=255;
         setlength(r_missile_l,255);
         for cm:=0 to r_missile_n-1 do r_missile_l[cm].mtype:=0;
      end;

      pm:=0;
      cm:=0;
      while(m_count>0)do
      begin
         cm:=rudata_byte(pf,0);

         if(cm=255)then exit;

         while(pm<cm)do
         begin
            MissileExplode(pm);
            pm+=1;
         end;
         pm+=1;

         with r_missile_l[cm] do
         begin
            x :=rudata_word(pf,0);
            if(GetWBit(@x,15))
            then ntype:=gpt_fire
            else ntype:=gpt_rocket;
            SetWBit(@x,15,false);
            nx:=mw2s(x);
            ny:=mw2s(rudata_word(pf,0));

            if(mtype>0)then
            begin
               if(ntype<>mtype)
               then MissileExplode(cm)
               else mdir:=point_dir(mx,my,nx,ny);
            end
            else
            begin
               mdir:=-1;
               {$IFDEF FULLGAME}
               if(ntype=gpt_fire)then mspriteScale:=0.1;
               {$ENDIF}
            end;

            mx   :=nx;
            my   :=ny;
            mtype:=ntype;
         end;

         m_count-=1;
         cm+=1;
      end;

      while(cm<255)do
      begin
         MissileExplode(cm);
         cm+=1;
      end;
   end;
end;

procedure player_Null(pi:byte);
begin
   with g_players[pi] do
   begin
      roomi:=0;
      room :=sv_clroom;
      pnum :=pi;
   end;
   player_State(@g_players[pi],ps_none,false);
end;

procedure gdatar_RoomPlayers(aproom:PTRoom;pf:pfile);
var
pi,pl,
pn,st,
nstate : byte;
_pi    : PTPlayer;
nohans : boolean;
begin
   with aproom^ do
   begin
      cur_clients:=0;
      cur_players:=0;
   end;

   pn  :=rudata_byte(pf,0);

   if(MaxPlayers<pn)then exit;

   pi:=0;
   pl:=1;
   while(pn>0)do
   begin
      pi:=rudata_byte(pf,0);
      if(pi=0)or(MaxPlayers<pi)then exit;

      _pi:=@g_players[pi];

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

         st    :=rudata_byte(pf,0);
         nstate:=st and %00000111;
         nohans:=true;

         if(nstate>=ps_dead)then team    :=(st and %00011000) shr 3;
         if(nstate> ps_dead)then gun_curr:=(st and %11100000) shr 5;

         st    :=rudata_byte(pf,0);
         if(st>0)then
         begin
            if(GetBBit(st,0))then name   :=        rudata_string(pf);
            if(GetBBit(st,1))then begin
                                  ping   :=        rudata_word  (pf,0);
                                  menustate:=GetWBit(@ping,15);
                                  SetWBit(@ping,15,false);
                                  end;
            if(GetBBit(st,2))then begin
                                  frags  :=        rudata_int   (pf,0);
                                  spec_LastFrager:=pi;
                                  end;
            if(GetBBit(st,3))then hits   :=        rudata_sint  (pf,0);
            if(GetBBit(st,4))then begin
                                  x      := pw2s  (rudata_word  (pf,0));
                                  y      := pw2s  (rudata_word  (pf,0));end;
            if(GetBBit(st,5))then armor  :=        rudata_sint  (pf,0);
            if(GetBBit(st,6))then gun_inv:=        rudata_byte  (pf,0);
            if(GetBBit(st,7))then ammo[cdgun_ammot[gun_curr]]
                                         :=integer(rudata_byte  (pf,0));
         end;
         if(nstate> ps_dead )then dir :=i2dir(rudata_int(pf,0));

         if(nstate>=ps_hwalk)then
         begin
            hans_mode:=rudata_byte(pf,0)*fr_fpsx1-fr_fpsx1+1;
            nstate-=2;
            nohans:=false;
         end;

         if(nstate>ps_dead)and(state<ps_walk)then
         begin
            vx  :=x;
            vy  :=y;
            vdir:=dir;
         end;

         player_State(_pi,nstate,false);

         if(nohans)then hans_mode:=0;
         if(state>ps_none)then aproom^.cur_clients+=1;
         if(state>ps_spec)then aproom^.cur_players+=1;

         gun_next:=gun_curr;
      end;

      pn-=1;
   end;

   pi+=1;
   while(pi<=MaxPlayers)do
   begin
      player_Null(pi);
      pi+=1;
   end;
   RecountTeamFrags;
end;

procedure gdatar_gamedata(aproom:PTRoom;pf:pfile);
begin
   with aproom^ do
   begin
      demo_fpos_t+=1;
      if((demo_fpos_t mod fr_fpsx5)=0)
      then demo_addpos(aproom);

      if(time_scorepause<=0)and(cur_players>0)then
      begin
         time_tick+=1;
         room_TimeUpdate(aproom);
      end;

      demo_timer1:=(demo_timer1+1) mod demo_timer1_period;
      if(demo_timer1>0)then exit;
   end;

   gdatar_RoomPlayers (aproom,pf);
   gdatar_RoomLog     (aproom,pf);
   if(aproom^.cur_players>0)then
   begin
   gdatar_RoomItems   (aproom,pf);
   gdatar_RoomMissiles(aproom,pf);
   end;
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
   +'_'+str_DateTime+'_'+mapname+str_demoext;
end;

procedure demo_break(aproom:PTRoom;error_msg:shortstring;SwitchToMenu:boolean);
var message:shortstring;
begin
   with aproom^ do
   begin
      if(demo_file<>nil)then
      begin
         message:='';
         case demo_fstate of
         ds_none : message:=str_demo_Break;
         ds_read : message:=str_demo_BreakPlay;
         ds_write: message:=str_demo_BreakRecord;
         end;
         message+=' ('+demo_fname+')';
         if(length(error_msg)>0)then message+=' ['+error_msg+']';
         room_log_add(aproom,log_local,message,true);

         while(demo_fpos_n>0)do
         begin
            demo_fpos_n-=1;
            setlength(demo_fpos_l[demo_fpos_n].dp_players_l,0);
         end;
         setlength(demo_fpos_l,demo_fpos_n);
         demo_fpos_t:=0;

         close(demo_file^);
         dispose(demo_file);
      end;
      if(SwitchToMenu)then
      begin
         {$IFDEF FULLGAME}
         menu_update:=true;
         menu_switch(clm_menu);
         {$ENDIF}
         demo_cstate:=ds_none;
      end;
      demo_file  :=nil;
      demo_fname :='';
      demo_fstate:=ds_none;
      demo_ppause:=fr_fpsx1;
   end;
end;

procedure demo_Processing(aproom:PTRoom);
var
{$IFDEF FULLGAME}
    t: shortstring;
    v: byte;
   mi: word;
{$ENDIF}
ioerr: word;
begin
   with aproom^ do
   begin
      if (demo_fstate >ds_none)
      and(demo_cstate >ds_none)
      and(demo_fstate<>demo_cstate)then demo_break(aproom,'',false);

      if(demo_ppause>0)then
      begin
         demo_ppause-=1;
         exit;
      end;

      case demo_cstate of
ds_none : demo_break(aproom,'',false);
ds_write: begin
             if(demo_file=nil)then
             begin
                new(demo_file);
                demo_fname:=str_demofolder+demo_make_fname(aproom);
                room_log_add(aproom,log_local,str_demo_StartRecord+' ('+demo_fname+')',true);
                assign(demo_file^,demo_fname);
                {$I-}
                rewrite(demo_file^,1);
                {$I+}
                ioerr:=ioresult;
                if(ioerr<>0)then
                begin
                   demo_break(aproom,str_demo_WriteError+w2s(ioerr),false);
                   exit;
                end;
                demo_fstate:=ds_write;
                demo_head  :=true;
             end;
             if(demo_head)then
             begin
                demo_logn:=log_n;
                wudata_byte(ver,demo_file);
                gdataw_roominfo(aproom,demo_file);
                wudata_byte(time_min,demo_file);
                wudata_byte(time_sec,demo_file);
                {$I-}
                with g_maps[map_cur] do
                BlockWrite(demo_file^,mbuff,SizeOf(mbuff));
                {$I+}
                demo_head  :=false;
                demo_items :=0;
                demo_timer2:=0;
                FillChar(demo_pvars,SizeOf(demo_pvars),0);
             end;
             gdataw_gamedata(aproom,demo_file);
             ioerr:=ioresult;
             if(ioerr<>0)then
             begin
                demo_break(aproom,str_demo_WriteError+w2s(ioerr),false);
                exit;
             end;
          end;
{$IFDEF FULLGAME}
ds_read : begin
             if(demo_file=nil)then
             begin
                t:=str_demofolder+demo_fname;
                room_log_add(aproom,log_local,str_demo_StartPlay+' ('+t+')',true);
                if(not FileExists(t))then
                begin
                   demo_cstate:=ds_none;
                   room_log_add(aproom,log_local,str_demo_FileNotExists+' ('+t+')',true);
                   exit;
                end;
                new(demo_file);
                assign(demo_file^,t);
                {$I-}
                reset(demo_file^,1);
                {$I+}
                ioerr:=ioresult;
                if(ioerr<>0)then
                begin
                   demo_break(aproom,str_demo_ReadError+w2s(ioerr),true);
                   exit;
                end;
                demo_size_full:=FileSize(demo_file^);
                demo_head     :=true;
                demo_fstate   :=ds_read;
                ResetLocalGame;
                menu_switch(clm_game);
             end;
             if(demo_head)then
             begin
                v:=rudata_byte(demo_file,0);
                if(v<>ver)then
                begin
                   demo_cstate:=ds_none;
                   demo_break(aproom,str_demo_WrongVersion,true);
                   exit;
                end;
                gdatar_RoomInfo(aproom,demo_file);
                time_min :=rudata_byte(demo_file,0);
                time_sec :=rudata_byte(demo_file,0);
                time_tick:=(time_min*TicksPerMinute)+(time_sec*fr_fpsx1);
                mi       := map_name2n(mapname);
                if(mi=mi.MaxValue)then mi:=map_new(mapname);
                if(mi=mi.MaxValue)then mi:=0;
                with g_maps[mi] do
                begin
                   {$I-}
                   BlockRead(demo_file^,mbuff,SizeOf(mbuff));
                   {$I+}
                   mname:=mapname;
                end;
                map_LoadToRoomByN(sv_clroom,mi);
                if(mi=0)
                then map_AddDefault
                else map_SaveMap(mi);
                g_players[0].name:=str_demo_PlayerName;
                player_State      (@g_players[0],ps_spec,false);
                player_MoveToSpawn(@g_players[0]);
                demo_items     :=0;
                demo_head      :=false;
                demo_play_pause:=false;
                demo_play_end  :=false;
                demo_skip      :=0;
                demo_addpos(aproom);
                demo_size_body :=demo_size_full-demo_fpos_l[0].dp_fpos;
             end;
             if(cl_mode=0)then
             begin
                if(demo_play_end)
                then demo_skip:=0
                else
                  if(demo_skip=0)and(not demo_play_pause)then demo_skip:=1;
                while(demo_skip>0)do
                begin
                   gdatar_gamedata(aproom,demo_file);
                   demo_skip-=1;
                end;
             end;
             demo_play_end:=eof(demo_file^);
          end;
{$ENDIF}
      end;
   end;
end;
{$IFDEF FULLGAME}
procedure demos_PlayDemo(demo_name:shortstring);
begin
   with sv_clroom^ do
   begin
      if(cl_net_cstat>0)
      or(menu_locmatch)then exit;

      demo_break(sv_clroom,'',false);
      demo_ppause:=2;

      demo_fname :=demo_name;
      demo_cstate:=ds_read;
   end;
end;
{$ENDIF}


