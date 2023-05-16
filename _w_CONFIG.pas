

const

cfg_player_name        = 'player_name';
cfg_player_team        = 'player_team';
cfg_mouse_sens         = 'mouse_sens';
cfg_sound_volume       = 'sound_volume';
cfg_server_ip          = 'server_ip';
cfg_server_port        = 'server_port';
cfg_cam_height         = 'camera_height';
cfg_fullscreen         = 'fullscreen';
cfg_net_update         = 'net_fast_update';
cfg_weapon_switch      = 'weapon_switch';
cfg_weapon_antilag     = 'weapon_antilag';
cfg_move_smooth        = 'smooth_movement';
cfg_chat_sound         = 'chat_sound';
cfg_chat1_str          = 'chat_str1';
cfg_chat2_str          = 'chat_str2';
cfg_chat3_str          = 'chat_str3';
cfg_chat4_str          = 'chat_str4';
cfg_chat5_str          = 'chat_str5';
cfg_show_fps           = 'show_fps';
cfg_agraph_dir         = 'agraph_dir';
cfg_agraph_dir_cur     = 'agraph_dir_cur';
cfg_resolution_w       = 'rcw';
cfg_resolution_h       = 'rch';
cfg_show_time          = 'show_time';
cfg_save_scores        = 'save_scores';
cfg_max_corpses        = 'max_corpses';
cfg_demo_record        = 'demo_record';

var _temp_agraph:shortstring = '';

function cfgclks(i:byte;b:boolean):shortstring;
const b8 : array[false..true] of char = ('s','t');
begin cfgclks:='key_'+b8[b]+b2s(i);end;

procedure cfg_add_agraph(s:shortstring);
var i:byte;
begin
   if(vid_agraph_dirn<255)and(length(s)>0)then
   begin
      if(vid_agraph_dirn>0)then
       for i:=0 to vid_agraph_dirn-1 do
        if(vid_agraph_dirl[i]=s)then exit;

      vid_agraph_dirn+=1;
      setlength(vid_agraph_dirl,vid_agraph_dirn);
      vid_agraph_dirl[vid_agraph_dirn-1]:=s;
   end;
end;

procedure cfg_setval(vl,vr:shortstring);
var vrb:cardinal;
      i:byte;
begin
   vrb:=s2c(vr);
   case vl of
cfg_player_name    : player_name    := vr;
cfg_player_team    : player_team    := vrb;
cfg_mouse_sens     : m_speed        := s2i(vr);
cfg_sound_volume   : snd_volume     := vrb;
cfg_server_ip      : cl_net_svips   := vr;
cfg_server_port    : cl_net_svps    := vr;
cfg_cam_height     : vid_rc_newz    := vrb>0;
cfg_fullscreen     : vid_fullscreen := vrb>0;
cfg_net_update     : player_netupd  := vrb>0;
cfg_weapon_switch  : player_wswitch := vrb>0;
cfg_weapon_antilag : player_antilag := vrb>0;
cfg_move_smooth    : player_smooth  := vrb>0;
cfg_show_time      : player_showtime:= vrb>0;
cfg_chat_sound     : player_chat_snd:= vrb>0;
cfg_chat1_str      : player_chat1   := vr;
cfg_chat2_str      : player_chat2   := vr;
cfg_chat3_str      : player_chat3   := vr;
cfg_chat4_str      : player_chat4   := vr;
cfg_chat5_str      : player_chat5   := vr;
cfg_show_fps       : player_showfps := vrb>0;
cfg_agraph_dir     : cfg_add_agraph(vr);
cfg_agraph_dir_cur : _temp_agraph   := vr;
cfg_resolution_w   : vid_rw         := mm3i(32,vrb,800);
cfg_resolution_h   : vid_rh         := mm3i(24,vrb,600);
cfg_save_scores    : scores_save    := vrb>0;
cfg_max_corpses    : player_maxcorpses:= s2i(vr);
cfg_demo_record    : demo_record    := vrb>0;
   end;

   for i:=0 to 255 do
    if(i in cfg_cl_keys)then
    begin
       if(vl=cfgclks(i,true ))then cl_keys_t[i]:=vrb;
       if(vl=cfgclks(i,false))then cl_keys  [i]:=s2c(vr);
    end;
end;


procedure cfg_parse_str(s:shortstring);
var vr,vl:shortstring;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos('=',s);
   if(i>0)then
   begin
      vl:=copy(s,1,i-1);
      delete(s,1,i);
      vr:=s;
   end;
   cfg_setval(vl,vr);
end;

procedure cfg_load;
var f:text;
    s:shortstring;
    i:byte;
begin
   if FileExists(cfgfn) then
   begin
      assign(f,cfgfn);
      reset(f);
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);
   end;

   m_speed:=mm3i(1,m_speed,500);

   snd_volume :=mm3b(0,snd_volume,100);
   snd_volume1:=snd_volume/100;

   if(player_team>MaxTeamsI)then player_team:=MaxTeamsI;

   if(length(player_name)>NameLen)then SetLength(player_name,NameLen);

   player_maxcorpses:=mm3i(-1,player_maxcorpses,MaxVisSprites);

   cam_z  :=rc_camz[vid_rc_newz];

   ip_txt(@cl_net_svip,@cl_net_svips);
 port_txt(@cl_net_svp ,@cl_net_svps );

   if(vid_agraph_dirn=0)then
   begin
      vid_agraph_dirs:=3;
      cfg_add_agraph('graphic');
      cfg_add_agraph('graphic_nonazi');
      cfg_add_agraph('graphic_original');
      cfg_add_agraph('graphic_original_nonazi');
   end;
   if(vid_agraph_dirn>0)then
    for i:=0 to vid_agraph_dirn-1 do
     if(vid_agraph_dirl[i]=_temp_agraph)then
     begin
        vid_agraph_dirs:=i;
        break;
     end;
end;

procedure cfg_save;
var f:text;
    i:byte;
begin
   assign(f,cfgfn);
   rewrite(f);

   writeln(f,cfg_player_name    ,'=',player_name    );
   writeln(f,cfg_player_team    ,'=',player_team    );
   writeln(f,cfg_mouse_sens     ,'=',m_speed        );
   writeln(f,cfg_sound_volume   ,'=',snd_volume     );
   writeln(f,cfg_server_ip      ,'=',cl_net_svips   );
   writeln(f,cfg_server_port    ,'=',cl_net_svps    );
   writeln(f,cfg_cam_height     ,'=',byte(vid_rc_newz    ));
   writeln(f,cfg_fullscreen     ,'=',byte(vid_fullscreen ));
   writeln(f,cfg_net_update     ,'=',byte(player_netupd  ));
   writeln(f,cfg_weapon_switch  ,'=',byte(player_wswitch ));
   writeln(f,cfg_weapon_antilag ,'=',byte(player_antilag ));
   writeln(f,cfg_move_smooth    ,'=',byte(player_smooth  ));
   writeln(f,cfg_chat_sound     ,'=',byte(player_chat_snd));
   writeln(f,cfg_show_fps       ,'=',byte(player_showfps));
   writeln(f,cfg_chat1_str      ,'=',player_chat1   );
   writeln(f,cfg_chat2_str      ,'=',player_chat2   );
   writeln(f,cfg_chat3_str      ,'=',player_chat3   );
   writeln(f,cfg_chat4_str      ,'=',player_chat4   );
   writeln(f,cfg_chat5_str      ,'=',player_chat5   );
   writeln(f,cfg_resolution_w   ,'=',vid_rw );
   writeln(f,cfg_resolution_h   ,'=',vid_rh );
   writeln(f,cfg_show_time      ,'=',byte(player_showtime));
   writeln(f,cfg_save_scores    ,'=',byte(scores_save));
   writeln(f,cfg_max_corpses    ,'=',player_maxcorpses);
   writeln(f,cfg_demo_record    ,'=',byte(demo_record));

   if(vid_agraph_dirn>0)then
    for i:=0 to vid_agraph_dirn-1 do
     writeln(f,cfg_agraph_dir,'=',vid_agraph_dirl[i]);
   writeln(f,cfg_agraph_dir_cur,'=',vid_agraph_dirl[vid_agraph_dirs]);

   for i:=0 to 255 do
    if(i in cfg_cl_keys)then
    begin
       writeln(f,cfgclks(i,true ),'=',cl_keys_t[i]);
       writeln(f,cfgclks(i,false),'=',cl_keys  [i]);
    end;

   close(f);
end;


