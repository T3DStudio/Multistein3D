
const
block_word_sizeP   = 1000;
map_word_sizeP     = map_mlw*block_word_sizeP; //65000
block_word_sizeM   = 500;
map_word_sizeM     = map_mlw*block_word_sizeM; //32500

demo_timer1_period = 2;
demo_timer2_period = fr_fpsx1 div demo_timer1_period;


function ps2w (x:single ):word   ;begin ps2w :=mm3w(0,round(x*block_word_sizeP),map_word_sizeP);end;
function ms2w (x:single ):word   ;begin ms2w :=mm3w(0,round(x*block_word_sizeM),map_word_sizeM);end;
function dir2i(x:single ):integer;begin dir2i:=round(x*90);end;

function pw2s (x:word   ):single ;begin pw2s :=x/block_word_sizeP;end;
function mw2s (x:word   ):single ;begin mw2s :=x/block_word_sizeM;end;
function i2dir(x:integer):single ;begin i2dir:=x/90;end;

////////////////////////////////////////////////////////////////////////////////
//
//  COMMON GAME DATA: WRITE
//

procedure gdataw_roominfo(aproom:PTRoom;pf:pfile);
begin
   with aproom^ do
   begin
      wudata_string(rname      ,pf);
      wudata_byte  (max_clients,pf);
      wudata_byte  (max_players,pf);
      wudata_card  (g_flags    ,pf);
      wudata_int   (g_fraglimit,pf);
      wudata_byte  (g_timelimit,pf);
      wudata_byte  (cur_clients,pf);
      wudata_byte  (cur_players,pf);
      wudata_string(mapname    ,pf);
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
      pl:=@g_players[pdata_player^];
      if(pl^.room=aproom)and(pl^.state>ps_none)then break;
   until (pdata_player^=pb);
   wudata_byte(pdata_player^,pf);

   with pl^ do
   begin
      wudata_word(ping,pf);
      if(state>ps_spec)then wudata_int(frags,pf);
      wudata_string(name,pf);
   end;
end;

procedure gdataw_RoomLog(aproom:PTRoom;plog_n,pause_var:pword;pause_time:word;pf:pfile);
var li,l,lc:word;
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
         end;
   end;
end;
function PlayerGetStateByte(p:byte):byte;
begin
   PlayerGetStateByte:=0;
   with g_players[p] do
   if(state>ps_none)then
   begin
      if(state>ps_dead)and(gun_rld>gun_reload_s[gun_curr])
      then PlayerGetStateByte:=ps_attk
      else
        if(state=ps_dead)and(gids_death)
        then PlayerGetStateByte:=ps_gibs
        else PlayerGetStateByte:=state;

      if(state>=ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((team     and %00000011) shl 3);
      if(state> ps_dead)then PlayerGetStateByte:=PlayerGetStateByte or ((gun_curr and %00000111) shl 5);
   end;
end;

procedure gdataw_gamedata(aproom:PTRoom;pf:pfile);
var p,i:byte;
      w:word;
begin
   with aproom^    do
   begin
      demo_timer1:=(demo_timer1+1) mod demo_timer1_period;
      if(demo_timer1>0)then exit;

      demo_timer2:=(demo_timer2+1) mod demo_timer2_period;

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
            if(name<>demo_pnames[p])then
            begin
               wudata_byte(ps_data1,pf);
               wudata_string(name,pf);
               demo_pnames[p]:=name;
            end
            else
              if(demo_timer2=0  )then
              begin
                 wudata_byte(ps_data2,pf);
                 w:=ping;
                 SetWBit(@w,15,(state>ps_spec)and(frags<>demo_pfrags[p]));
                 wudata_word(w,pf);
                 if(state>ps_spec)and(frags<>demo_pfrags[p])then
                 begin
                    wudata_int(frags,pf);
                    demo_pfrags[p]:=frags;
                 end;
              end
              else
              begin
                 wudata_byte(PlayerGetStateByte(p),pf);
                 if(state>ps_dead)then
                 begin
                    wudata_word(ps2w(x  ),pf);
                    wudata_word(ps2w(y  ),pf);
                    wudata_int (dir2i(dir),pf);
                    wudata_byte(i2b(hits,Player_max_hits),pf);
                 end;
            end;

            i-=1;
            if(i=0)then break;
         end;

      gdataw_RoomLog     (aproom,@demo_logn,nil,0,pf);
      gdataw_RoomItems   (aproom,@demo_items,pf);
      gdataw_RoomMissiles(aproom,pf);
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
         room_TimeUpdate(aproom);

         time_scorepause:=dp_time_scorepause;
         demo_items:=dp_demo_items;

         demo_fpos_t:=dp_tick;

         Seek(demo_file^,dp_fpos);
      end;

      demo_skip:=2;
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
begin
   with aproom^ do
   begin
      rname      :=rudata_string(pf);
      max_clients:=rudata_byte  (pf,0);
      max_players:=rudata_byte  (pf,0);
      g_flags    :=rudata_card  (pf,0);
      g_fraglimit:=rudata_int   (pf,0);
      g_timelimit:=rudata_byte  (pf,0);
      cur_clients:=rudata_byte  (pf,0);
      cur_players:=rudata_byte  (pf,0);
      mapname    :=rudata_string(pf);
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

      ping  :=rudata_word(pf,0);
      if(state>ps_spec)then
      frags :=rudata_int(pf,0);
      name  :=rudata_string(pf);

      if(frags>lfrags)then
      spec_LastFrager:=pd;
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
         room_log_add(aproom,data_id,data_string);
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
         r_item_l[pitem^].irespt:=integer(not GetBBit(@b,i));
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

         if(cm=255)then
         begin
            demo_break(aproom,str_demo_WrongData,true);
            exit;
         end;

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
            else mdir:=-1;

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

procedure gdatar_gamedata(aproom:PTRoom;pf:pfile);
var
pi,pl,
pn,st,
nstate : byte;
w      : word;
_pi    : PTPlayer;
begin
   with aproom^ do
   begin
      demo_fpos_t+=1;
      if((demo_fpos_t mod fr_fpsx5)=0)
      then demo_addpos(aproom);

      if(time_scorepause<=0)and(cur_players>0)then
      begin
         if(pf=nil)
         then time_tick+=1
         else time_tick+=2;
         room_TimeUpdate(aproom);
      end;

      cur_clients    :=0;
      cur_players    :=0;

      demo_timer1:=(demo_timer1+1) mod demo_timer1_period;
      if(demo_timer1>0)then exit;
   end;

   pn  :=rudata_byte(pf,0);

   if(MaxPlayers<pn)then
   begin
      demo_break(aproom,str_demo_WrongData,true);
      exit;
   end;

   pi:=0;
   pl:=1;
   while(pn>0)do
   begin
      pi:=rudata_byte(pf,0);
      if(pi=0)or(MaxPlayers<pi)then
      begin
         demo_break(aproom,str_demo_WrongData,true);
         exit;
      end;
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
         if(nstate<>ps_gibs)
         then gids_death:=false
         else
         begin
            gids_death:=true;
            nstate:=ps_dead;
         end;

         case nstate of
ps_data1 : name :=rudata_string(pf);
ps_data2 : begin
           w:=rudata_word(pf,0);
           if(GetWBit(@w,15))then frags:=rudata_int (pf,0);
           SetWBit(@w,15,false);
           ping:=w;
           end;
         else
           if(nstate>=ps_dead)then team:=(st and %00011000) shr 3;
           if(nstate> ps_dead)then
           begin
              gun_curr:=(st and %11100000) shr 5;

              x   :=pw2s(rudata_word(pf,0));
              y   :=pw2s(rudata_word(pf,0));
              dir :=i2dir(rudata_int (pf,0));
              hits:=     rudata_byte(pf,0);

              if(state<ps_walk)then
              begin
                 vx  :=x;
                 vy  :=y;
                 vdir:=dir;
              end;
           end;

           player_State(_pi,nstate,false);
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

   gdatar_RoomLog     (aproom,pf);
   gdatar_RoomItems   (aproom,pf);
   gdatar_RoomMissiles(aproom,pf);
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
         room_log_add(aproom,log_local,message);

         demo_fpos_n:=0;
         setlength(demo_fpos_l,demo_fpos_n);

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
{$IFDEF FULLGAME}
var t: shortstring;
    v: byte;
   mi: word;
{$ENDIF}
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
                room_log_add(aproom,log_local,str_demo_StartRecord+' ('+demo_fname+')');
                assign(demo_file^,demo_fname);
                {$I-}
                rewrite(demo_file^,1);
                {$I+}
                if(ioresult<>0)then
                begin
                   demo_break(aproom,str_demo_WriteError+w2s(ioresult),false);
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
                FillChar(demo_pnames,SizeOf(demo_pnames),0);
                FillChar(demo_pfrags,SizeOf(demo_pfrags),0);
             end;
             gdataw_gamedata(aproom,demo_file);
             if(ioresult<>0)then
             begin
                demo_break(aproom,str_demo_WriteError+w2s(ioresult),false);
                exit;
             end;
          end;
{$IFDEF FULLGAME}
ds_read : begin
             if(demo_file=nil)then
             begin
                t:=str_demofolder+demo_fname;
                room_log_add(aproom,log_local,str_demo_StartPlay+' ('+t+')');
                if(not FileExists(t))then
                begin
                   demo_cstate:=ds_none;
                   room_log_add(aproom,log_local,str_demo_FileNotExists+' ('+t+')');
                   exit;
                end;
                new(demo_file);
                assign(demo_file^,t);
                {$I-}
                reset(demo_file^,1);
                {$I+}
                if(ioresult<>0)then
                begin
                   demo_break(aproom,str_demo_ReadError+w2s(ioresult),true);
                   exit;
                end;
                demo_size:=FileSize(demo_file^);
                demo_head:=true;
                demo_fstate:=ds_read;
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
                player_State(@g_players[0],ps_spec,false);
                player_MoveToSpawn(@g_players[0]);
                demo_items:=0;
                demo_head :=false;
                demo_play_pause:=false;
                demo_skip :=0;
                demo_addpos(aproom);
             end;
             if(cl_mode=0)then
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
                demo_break(aproom,str_demo_End,false);
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


