
procedure player_State(aplayer:PTPlayer;nstate:byte;log:boolean);forward;

function b2s (i:byte    ):shortstring;begin str(i,b2s );end;
function w2s (i:word    ):shortstring;begin str(i,w2s );end;
function i2s (i:integer ):shortstring;begin str(i,i2s );end;
function li2s(i:longint ):shortstring;begin str(i,li2s);end;
function c2s (i:cardinal):shortstring;begin str(i,c2s );end;
function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte    ;var t:integer;begin val(str,s2b,t);end;
function s2w (str:shortstring):word    ;var t:integer;begin val(str,s2w,t);end;
function s2i (str:shortstring):integer ;var t:integer;begin val(str,s2i,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c,t);end;

function max2(x1,x2   :integer):integer;begin if(x1>x2)then max2:=x1 else max2:=x2;end;
function max3(x1,x2,x3:integer):integer;begin max3:=max2(max2(x1,x2),x3);end;
function min2(x1,x2   :integer):integer;begin if(x1<x2)then min2:=x1 else min2:=x2;end;
function min3(x1,x2,x3:integer):integer;begin min3:=min2(min2(x1,x2),x3);end;

function mm3i(mnx,x,mxx:integer):integer;begin mm3i:=min2(mxx,max2(x,mnx)); end;
function mm3w(mnx,x,mxx:word   ):word   ;begin mm3w:=x;if(x<mnx)then mm3w:=mnx;if(x>mxx)then x:=mxx; end;
function mm3b(mnx,x,mxx:byte   ):byte   ;begin mm3b:=x;if(x<mnx)then mm3b:=mnx;if(x>mxx)then x:=mxx; end;

function i2b(i,max:integer):byte;begin i2b:=byte(mm3i(0,i,max));end;

procedure player_Reset(aplayer:PTPlayer); forward;

procedure demo_Processing(aproom:PTRoom); forward;
procedure demo_init_data(aproom:PTRoom);forward;
procedure demo_break(aproom:PTRoom;error_msg:shortstring;SwitchToMenu:boolean);forward;

function missile_Proc(aroom:PTRoom;amissile:PTMissile):boolean;forward;


procedure fr_init;
begin
   fr_LastTicks :=0;
   fr_BaseTicks :=0;
   fr_FrameCount:=0;
   fr_FPSSecond :=0;
   fr_FPSSecondN:=0;
   fr_FPSSecondC:=0;
end;

procedure fr_delay;
var
fr_TargetTicks,
fr_CurrentTicks: cardinal;
begin
   fr_FrameCount+=1;

   fr_CurrentTicks:=SDL_GetTicks;

   fr_FPSSecondD  :=fr_CurrentTicks-fr_LastTicks;
   fr_FPSSecond   +=fr_FPSSecondD;
   fr_FPSSecondN  +=1;
   if(fr_FPSSecond>=1000)then
   begin
      fr_FPSSecondC:=fr_FPSSecondN;
      fr_FPSSecondN:=0;
      fr_FPSSecond :=fr_FPSSecond mod 1000;
   end;

   fr_LastTicks   :=fr_CurrentTicks;

   fr_TargetTicks :=fr_BaseTicks + trunc(fr_FrameCount*fr_RateTicks);

   if(fr_CurrentTicks<=fr_TargetTicks)
   then sdl_Delay(fr_TargetTicks-fr_CurrentTicks)
   else
   begin
      fr_FrameCount:=0;
      fr_BaseTicks :=fr_CurrentTicks;
   end;
end;


function str_DateTime:shortstring;
var YY,MM,DD,H,M,S,MS:word;
begin
   DeCodeDate(Date,YY,MM,DD);
   DeCodeTime(Time,H,M,S,MS);
   str_DateTime:=w2s(YY)+'_'+w2s(MM)+'_'+w2s(DD)+' '+w2s(H)+'-'+w2s(M)+'-'+w2s(S)+'-'+w2s(MS);
end;

{$IFDEF FULLGAME}
procedure Sound_PlaySource(schunk:TALint;psx,psy:psingle;sx,sy:single); forward;
procedure draw_last_message; forward;
procedure net_SendChat(str:shortstring);forward;
function str2RFlags(s:shortstring):cardinal;forward;
{$ELSE}
procedure net_add_ban(ip:cardinal;time:cardinal;comment:shortstring);forward;
procedure net_del_ban(b:word);forward;
procedure net_send_bans(ip:cardinal;port:word);forward;
procedure net_send_maplist(room:PTRoom;ip:cardinal;port:word);forward;
{$ENDIF}

procedure WriteLog(comment:shortstring);
var f:Text;
begin
   if(length(comment)=0)then exit;
   {$I-}
   assign(f,str_outlogfn);
   if FileExists(str_outlogfn) then append(f) else rewrite(f);
   writeln(f,comment);
   Close(f);
   {$I+}
end;

procedure WriteSDLError(comment:shortstring);
begin
   writeln(comment,str_ErrorLogSep,sdl_GetError);
   WriteLog(comment+str_NewLineChar+sdl_GetError);
   SDL_ClearError;
end;

function Room_CheckFlag(aroom:PTRoom;flag:cardinal):boolean;
begin
   Room_CheckFlag:=(aroom^.g_flags and flag)>0;
end;

function sign(x:integer):integer;
begin
   sign:=0;
   if(x>0)then sign:= 1;
   if(x<0)then sign:=-1;
end;

function point_dist(dx0,dy0,dx1,dy1:single):single;
begin
   point_dist:=sqrt(sqr(dx1-dx0)+sqr(dy1-dy0));
end;

function dir_360(s:single):single;
begin
   while true do
     if(s<0   )then s+=360
else if(s>=360)then s-=360
else break;
   dir_360:=s;
end;

function dir_diff(dir1,dir2:single):single;
begin
   dir_diff:=dir_360(dir_360(dir1-dir2)+540)-180;
end;

function dir_turn(d1,d2,spd:single):single;
var d:single;
begin
   dir_turn:=d1;
   d:=dir_diff(d2,d1);
   if(abs(d)<=spd)
   then dir_turn:=d2
   else
   begin
      if(d<0)then dir_turn-=spd;
      if(d>0)then dir_turn+=spd;
      dir_turn:=dir_360(dir_turn);
   end;
end;

function point_dir(x0,y0,x1,y1:single):single;
const e=0.0001;
var sc,lb,cs:single;
begin
   x1:=  x1-x0;
   y1:=-(y1-y0);
   x0:=1;
   y0:=0;

   lb:=sqrt(sqr(x1)+sqr(y1));

   point_dir:=0;

   if(lb=0)then exit;

   cs:=x1/lb;

   sc:=abs(cs);
   if(sc<e)then
    if(y1<0)
    then point_dir:=90
    else point_dir:=270
   else
   begin
      sc:=1-sc;
      if(sc<e)then
       if(x1>0)
       then point_dir:=0
       else point_dir:=180
      else
      begin
         if(cs>0)
         then point_dir:=arctan(sqrt(1-sqr(cs))/cs)/DEGTORAD
         else
           if(cs<0)
           then point_dir:=180+arctan(sqrt(1-sqr(cs))/cs)/DEGTORAD;

         if(y1>0)then point_dir:=360-point_dir;
      end;
   end;
end;

function str_RemoveExt(mname:shortstring):shortstring;
begin
   if(length(mname)>str_mapext_len)
   then setlength(mname,length(mname)-length(str_mapext));
   str_RemoveExt:=mname;
end;

function map_new(fn:shortstring):word;
begin
   map_new:=map_new.MaxValue;

   if(g_mapn>=65534)then exit;

   map_new:=g_mapn;

   g_mapn+=1;
   setlength(g_maps,g_mapn);

   with g_maps[g_mapn-1] do
   begin
      mname:=fn;
      FillChar(mbuff,SizeOf(mbuff),#0);
   end;
end;

function map_name2n(mn:shortstring):word;
var im:word;
begin
   map_name2n:=map_name2n.MaxValue;
   for im:=0 to g_mapn-1 do
    with g_maps[im] do
     if(mname=mn)then
     begin
        map_name2n:=im;
        break;
     end;
end;

{$IFDEF FULLGAME}
procedure ParseRoomDataStr(str:shortstring);
var i:byte;
  vr,vl:shortstring;
begin
   vr:='';
   vl:='';
   i :=pos('=',str);
   if(i>0)then
   begin
      vl:=copy(str,1,i-1);
      delete(str,1,i);
      vr:=str;
   end;
   with sv_clroom^ do
   case vl of
rcfg_roomname  : rname      := vr;
rcfg_maxplayers: max_players:= s2b(vr);
rcfg_maxclients: max_clients:= s2b(vr);
rcfg_timelimit : g_timelimit:= s2b(vr);
rcfg_fraglimit : g_fraglimit:= s2i(vr);
rcfg_flags     : g_flags    := str2RFlags(vr);
   end;
end;
{$ENDIF}

procedure room_log_add(aroom:PTRoom;arg_id:byte;arg_string:shortstring);
begin
   with aroom^ do
   begin
      {$IFNDEF FULLGAME}
      if(arg_id=log_local)then arg_string:='SERVER: '+arg_string;
      {$ELSE}
      if(menu_locmatch)then
      {$ENDIF}
      log_n+=1;

      log_i+=1;
      if(log_i>MaxRoomLog)then log_i:=0;

      with log_l[log_i] do
      begin
         data_id    :=arg_id;
         data_string:=arg_string;
      end;

      if{$IFDEF FULLGAME}
        (scores_save)
        {$ELSE}
        (Room_CheckFlag(aroom,sv_g_screensave))
        {$ENDIF}then
        if(arg_id=log_winner )then
        begin
           scores_save_need:=true;
           scores_message  :=arg_string;
        end;

      {$IFDEF FULLGAME}
      hud_last_mesn+=hud_last_mess_1msg-1;
      if(hud_last_mesn>hud_last_mess_max)
      then hud_last_mesn:=hud_last_mess_max-1;

      case arg_id of
log_winner     : Sound_PlaySource(snd_score,@cam_x,@cam_y,0,0);
log_chat       : if(player_chat_snd)then
                 Sound_PlaySource(snd_chat ,@cam_x,@cam_y,0,0);
log_roomdata   : ParseRoomDataStr(arg_string);
log_suddendeath: ;
      end;
      case arg_id of
log_matchreset : if(demo_cstate=ds_read)then
                 begin
                    time_scorepause:=0;
                    time_tick:=0;
                 end;
log_winner,
log_endgame    : if(demo_cstate=ds_read)
                 then time_scorepause:=1;
      end;
      {$ELSE}
      writeln('Room #',rnum+1,': ',arg_string);
      {$ENDIF}
   end;
end;

function net_NewPlayer(aip:cardinal;aport:word;aroomi:byte;aname:shortstring;ateam:byte;abot,admin:boolean):byte;
var p:byte;
begin
   net_NewPlayer:=0;
   if(aroomi<sv_maxrooms)then
    with sv_rooms[aroomi] do
     if(cur_clients<max_clients)then
      for p:=1 to MaxPlayers do
       with g_players[p] do
        if(state=ps_none)then
        begin
           ip         := aip;
           port       := aport;
           roomi      := aroomi;
           room       := @sv_rooms[aroomi];
           pnum       := p;
           ttl        := 0;
           log_n      := room^.log_n;
           bot        := abot;
           name       := aname;
           team       := ateam;
           ping       := 0;
           net_fupd   := false;
           pause_snap := net_upd_time[net_fupd];
           net_NewPlayer:=p;
           player_State(@g_players[p],ps_spec,true);
           {$IFNDEF FULLGAME}
           vote       := 0;
           pause_logsend:=0;
           net_moves  := 0;
           ping_t     := 0;
           ping_r     := false;
           rcon_access:= admin;
           if(rcon_access)then
           room_log_add(room,log_local,name+str_rconadmin);
           {$ENDIF}
           break;
        end;
end;

function net_Addr2Player(aip:cardinal;aport:word):byte;
var p:byte;
begin
   net_Addr2Player:=0;
   for p:=1 to MaxPlayers do
    with g_players[p] do
     if(state>ps_none)and(bot=false)and(ip=aip)and(port=aport)then
     begin
        net_Addr2Player:=p;
        ttl:=0;
        break;
     end;
end;

function ip2c(s:shortstring;isip:pboolean):cardinal;
{$IFNDEF FULLGAME}
const chars_digits           : set of Char = ['0'..'9'];
{$ENDIF}
var i,l,
     bn:byte;
     e :array[0..3] of byte = (0,0,0,0);
begin
   ip2c:=0;
   if(isip<>nil)then isip^:=false;
   bn:=0;
   l :=length(s);
   if(l>0)then
     for i:=1 to l do
       if(s[i]='.')then
       begin
          bn+=1;
          if(bn>3)then exit;
       end
       else
         if(s[i] in chars_digits)
         then e[bn]:=s2b(b2s(e[bn])+s[i])
         else exit;
   if(isip<>nil)then isip^:=true;
   ip2c:=cardinal((@e)^);
end;

function c2ip(c:cardinal):shortstring;
begin
   c2ip:=b2s (c and $000000FF)
    +'.'+b2s((c and $0000FF00) shr 8 )
    +'.'+b2s((c and $00FF0000) shr 16)
    +'.'+b2s((c and $FF000000) shr 24);
end;

{$IFDEF FULLGAME}

function char2rcimage(c:char;pxa:pboolean):pTRCImage;
begin
   char2rcimage:=nil;
   if(pxa<>nil)then pxa^:=false;

   if(c=mgr_wih)
   then char2rcimage:=@spr_rcwall_hline
   else
     if(c in mgr_bwalls)
     then char2rcimage:=@spr_rcwall[0,c]
     else
       if(c=mgr_door)
       then char2rcimage:=@spr_rcwall_door[0]
       else
         if(c in mgr_decors)
         then char2rcimage:=@spr_rcdecor[c]
         else
           case c of
   mgr_spawn_180       : char2rcimage:=@spr_rcteam[0,8 ];
   mgr_spawn_270       : char2rcimage:=@spr_rcteam[0,0 ];
   mgr_spawn_0         : begin
                         char2rcimage:=@spr_rcteam[0,8 ];
                         if(pxa<>nil)then pxa^:=true;
                         end;
   mgr_spawn_90        : char2rcimage:=@spr_rcteam[0,16];
   mgr_spawn_random    : char2rcimage:=@spr_rcteam[1,5 ];
   mgr_item_armor      : char2rcimage:=@spr_rcitem[0   ];
   mgr_item_mp40       : char2rcimage:=@spr_rcitem[1   ];
   mgr_item_chaingun   : char2rcimage:=@spr_rcitem[2   ];
   mgr_item_ammo       : char2rcimage:=@spr_rcitem[3   ];
   mgr_item_ammobox    : char2rcimage:=@spr_rcitem[4   ];
   mgr_item_dogfood    : char2rcimage:=@spr_rcitem[5   ];
   mgr_item_food       : char2rcimage:=@spr_rcitem[6   ];
   mgr_item_medkit     : char2rcimage:=@spr_rcitem[7   ];
   mgr_item_mega       : char2rcimage:=@spr_rcitem[8   ];
   mgr_item_rifle      : char2rcimage:=@spr_rcitem[9   ];
   mgr_item_flame      : char2rcimage:=@spr_rcitem[10  ];
   mgr_item_panzer     : char2rcimage:=@spr_rcitem[11  ];
   mgr_item_tesla      : char2rcimage:=@spr_rcitem[12  ];
   mgr_item_ammorifle  : char2rcimage:=@spr_rcitem[13  ];
   mgr_item_ammoflame  : char2rcimage:=@spr_rcitem[14  ];
   mgr_item_ammopanzer : char2rcimage:=@spr_rcitem[15  ];
   mgr_item_ammotesla  : char2rcimage:=@spr_rcitem[16  ];
           end;
end;

procedure KeyboardStringRussian;
const
  char_num = 65;
  utf  : array[0..char_num] of char = (
#192, // А
#193,#194,#195,#196,#197,#198,#199,#200,#201,#202,#203,#204,#205,#206,#207,
#208,#209,#210,#211,#212,#213,#214,#215,#216,#217,#218,#219,#220,#221,#222,
#223,  // Я

#224,  // а
#225,#226,#227,#228,#229,#230,#231,#232,#233,#234,#235,#236,#237,#238,#239,
#240,#241,#242,#243,#244,#245,#246,#247,#248,#249,#250,#251,#252,#253,#254,
#255, //я
#229, //ё
#197  //Ё
);
  unic : array[0..char_num] of string[2] = (
#208#144, // А
#208#145,#208#146,#208#147,#208#148,#208#149,#208#150,#208#151,#208#152,
#208#153,#208#154,#208#155,#208#156,#208#157,#208#158,#208#159,#208#160,
#208#161,#208#162,#208#163,#208#164,#208#165,#208#166,#208#167,#208#168,
#208#169,#208#170,#208#171,#208#172,#208#173,#208#174,
#208#175, // Я

#208#176, // а
#208#177,#208#178,#208#179,#208#180,#208#181,#208#182,#208#183,#208#184,
#208#185,#208#186,#208#187,#208#188,#208#189,#208#190,#208#191,#209#128,
#209#129,#209#130,#209#131,#209#132,#209#133,#209#134,#209#135,#209#136,
#209#137,#209#138,#209#139,#209#140,#209#141,#209#142,
#209#143, //я
#209#145, //ё
#208#129  //Ё
  );
var i,p:byte;
begin

   if(length(keyboard_string)>=2)then
   for i:=0 to char_num do
   begin
      while(true)do
      begin
         p:=pos(unic[i],keyboard_string);
         if(p=0)
         then break
         else
         begin
            delete(keyboard_string,p,length(unic[i]));
            insert(utf[i],keyboard_string,p);
         end;
      end;
   end;

   {
   а = #208#176      144
   б        177      145
   в        178      146
   г        179      147
   д        180      148
   е        181      149
   ж        182      150
   з        183      151
   и        184      152
   й        185      153
   к        186      154
   л        187      155
   м        188      156
   н        189      157
   о        190      158
   п        191      159
   р   #209#128      160
   с        129      161
   т        130      162
   у        131      163
   ф        132      164
   х        133      165
   ц        134      166
   ч        135      167
   ш        136      168
   щ        137      169
   ъ        138      170
   ы        139      171
   ь        140      172
   э        141      173
   ю        142      174
   я        143      175
   ё        144 #208#129
   }
end;

{function pchar2ss(pch:Pchar):shortstring;
type ch = array[0..0] of char;
var i  : byte;
begin
   pchar2ss:='';
   i:=0;
   while (ch(pch)[i]<>#0)and(i<255)  do
   begin
      pchar2ss:=pchar2ss+ch(pch)[i];
      i+=1;
   end;
end; }

function GetKeyName(k:byte):shortstring;
begin
   GetKeyName:=str_UnknownKey;
   case cl_keys_t[k] of
kt_keyboard : if(cl_keys[k]=0)
              then               GetKeyName:=str_KeyboradUnknown+c2s(cl_keys[k])
              else               GetKeyName:=sdl_GetKeyName(cl_keys[k]);
kt_mouseb   : case cl_keys[k] of
              SDL_BUTTON_left  : GetKeyName:=str_MouseLeftButton;
              SDL_BUTTON_right : GetKeyName:=str_MouseRightButton;
              SDL_BUTTON_middle: GetKeyName:=str_MouseMiddleButton;
              else               GetKeyName:=str_MouseUnknown+c2s(cl_keys[k]);
              end;
kt_mousewh  : case cl_keys[k] of
              mw_up            : GetKeyName:=str_MouseWheelUp;
              mw_down          : GetKeyName:=str_MouseWheelDown;
              else               GetKeyName:=str_MouseWheelUnknown+c2s(cl_keys[k]);
              end;
   end;
end;

procedure cl_buffer_xy_clear;
begin
   FillChar(cl_buffer_xy_x,SizeOf(cl_buffer_xy_x),0);
   FillChar(cl_buffer_xy_y,SizeOf(cl_buffer_xy_y),0);
end;
function cl_buffer_xy_check(x,y:single):boolean;
var i:byte;
begin
   cl_buffer_xy_check:=false;
   for i:=0 to cl_buffer_xy_n do
    if(x=cl_buffer_xy_x[i])and(y=cl_buffer_xy_y[i])then
    begin
       cl_buffer_xy_check:=true;
       break;
    end;
end;
procedure cl_buffer_xy_add(x,y:single);
begin
   cl_buffer_xy_i+=1;
   if(cl_buffer_xy_i>cl_buffer_xy_n)then cl_buffer_xy_i:=0;

   cl_buffer_xy_x[cl_buffer_xy_i]:=x;
   cl_buffer_xy_y[cl_buffer_xy_i]:=y;
end;


procedure setchars1(tar:pshortstring;start,mx:byte;src:pshortstring);
var i,tl,sl:byte;
begin
   if(start<1)or(mx<1)then exit;
   tl:=length(tar^);
   sl:=length(src^);
   i:=1;
   while(true)do
   begin
      if(start>tl)then break;
      if(i    >sl)
      or(i    >mx)then break;
      tar^[start]:=src^[i];
      start+=1;
      i    +=1;
   end;
end;
procedure setchars2(tar:pshortstring;start,mx:byte;src:shortstring);
begin
   setchars1(tar,start,mx,@src);
end;

procedure MouseGrabCheck;
begin
   if(cl_mode>clm_game)or(hud_console)then
   begin
      SDL_SetWindowGrab(vid_window,SDL_FALSE);
      SDL_SetRelativeMouseMode( SDL_FALSE);
   end
   else
   begin
      SDL_SetWindowGrab(vid_window,SDL_TRUE );
      SDL_SetRelativeMouseMode( SDL_TRUE );
   end;
end;

procedure ActKeysClear;
var i:byte;
begin
   for i:=0 to 255 do cl_acts[i]:=0;
   last_key_m:=0;
end;

procedure ToggleConsole;
begin
   hud_console:=not hud_console;
   chat_line:=false;
   ActKeysClear;
   MouseGrabCheck;
end;

procedure menu_switch(forcemode:byte);
begin
   if(forcemode<3)
   then cl_mode:=forcemode
   else
     case cl_mode of
clm_game  : cl_mode:=clm_menu;
clm_menu  : if(menu_locmatch)
            or(cl_net_cstat>0)
            or(sv_clroom^.demo_cstate=ds_read)then cl_mode:=0;
clm_editor: cl_mode:=clm_menu;
     end;

   MouseGrabCheck;
end;

procedure ClearClientEffects;
begin
   FillChar(map_effs ,SizeOf(map_effs ),0);
   FillChar(map_deads,SizeOf(map_deads),0);
   map_ldead :=0;
end;

procedure cl_eff_add(ax,ay,az,ascale:single;et:byte);
begin
   if(map_leffs>=rc_MaxEffects)
   then map_leffs:=0
   else map_leffs+=1;

   with map_effs[map_leffs] do
   begin
      eff_x    :=ax;
      eff_y    :=ay;
      eff_z    :=az;
      eff_scale:=ascale;
      eff_anim :=eff_ant;
      eff_type :=et;
      eff_ez_fallspd:=0;
      case eff_type of
      eid_blood  : eff_ez_fallspd:=-0.014;
      end;
   end;
end;

procedure cl_dead_add(ax,ay:single;et:byte);
begin
   if(player_maxcorpses<0)
   or(player_maxcorpses>rc_MaxEffects)then exit;

   if(map_ldead>=player_maxcorpses)
   then map_ldead:=0
   else map_ldead+=1;

   with map_deads[map_ldead] do
   begin
      eff_x   :=ax;
      eff_y   :=ay;
      eff_anim:=1;
      eff_type:=et;
   end;
end;

{procedure port_txt(port:pword;ports:pshortstring);
begin
   port^ :=swap(s2w (ports^));
   ports^:=w2s (swap(port^ ));
end;

procedure ip_txt(ip:pcardinal;ips:pshortstring);
begin
   ip^ :=ip2c(ips^);
   ips^:=c2ip(ip^ );
end;  }

procedure txt_ValidateAddr;
var
addrs,
ports: shortstring;
pansi:PAnsiChar;
    p: byte;
  ipc: cardinal;
 isip: boolean;
ipstruct:TIPaddress;
begin
   addrs:='';
   ports:='';
   p    :=pos(':',cl_net_svaddr);
   if(p>0)then
   begin
      addrs:=copy(cl_net_svaddr,1,p-1);
      delete(cl_net_svaddr,1,p);
      ports:=cl_net_svaddr;
   end
   else
   begin
      addrs:=cl_net_svaddr;
      ports:='35700';
   end;

   cl_net_svport:=swap(s2w(ports));
   ports:=w2s(swap(cl_net_svport));

   ipc:=ip2c(addrs,@isip);
   if(isip)then
   begin
      cl_net_svip  :=ipc;
      cl_net_svaddr:=c2ip(cl_net_svip)+':'+ports;
   end
   else
   begin
      cl_net_svaddr:=addrs+':'+ports;
      addrs+=#0;
      pansi:=@addrs[1];
      if(SDLNet_ResolveHost(@ipstruct,pansi,cl_net_svport)=0)then
      begin
         cl_net_svip:=ipstruct.host;
         room_log_add(sv_clroom,log_local,cl_net_svaddr+': resolved host to '+c2ip(cl_net_svip));
      end
      else
      begin
         cl_net_svip:=0;
         room_log_add(sv_clroom,log_local,cl_net_svaddr+': resolve host fail');
      end;
   end;
end;

procedure txt_ValidateWRes;
begin
   menu_vid_w:=mm3i(vid_min_w,s2i(menu_vid_ws),vid_max_w);
   menu_vid_h:=mm3i(vid_min_h,s2i(menu_vid_hs),vid_max_h);
   menu_vid_ws:=i2s(menu_vid_w);
   menu_vid_hs:=i2s(menu_vid_h);
end;

function RGBA2Card(r,g,b,a:byte):cardinal;
begin
   RGBA2Card:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

function ColorRGBA(ar,ag,ab,aa:byte):TColor;
begin
   with ColorRGBA do
   begin
      r:=ar;
      g:=ag;
      b:=ab;
      a:=aa;
      c:=RGBA2Card(r,g,b,a);
   end;
end;

procedure MakeScreenShot_CalcSize(w,h:integer);
var aspecti:single;
begin
   screenshot_w:=w;
   screenshot_h:=h;
   aspecti:=trunc((screenshot_w/screenshot_h)*100);
   if(vid_aspecti>aspecti)then screenshot_h:=trunc(screenshot_w/vid_aspect);
   if(vid_aspecti<aspecti)then screenshot_w:=trunc(screenshot_h*vid_aspect);
end;

procedure MakeScreenShot(mapname:shortstring);
var s: shortstring;
   tt: pSDL_Surface;
begin
   if(screenshot_w<=0)
   or(screenshot_h<=0)then exit;

   if(length(mapname)>0)
   then s:=str_screenshot+str_DateTime+'_'+mapname+str_ScreenShotExt
   else s:=str_screenshot+str_DateTime            +str_ScreenShotExt;
   room_log_add(sv_clroom,log_local,s+str_ScreenShotSaved);

   s:=s+#0;

   tt := SDL_CreateRGBSurface(0, screenshot_w, screenshot_h, vid_bpp, 0,0,0,0);
   SDL_RenderReadPixels(vid_renderer, nil, tt^.format^.format, tt^.pixels, tt^.pitch);
   IMG_SavePNG(tt,@s[1]);
   SDL_FreeSurface(tt);
end;

{$ENDIF}

