

const

cfg_param_sep          = '=';

cfg_player_name        = 'player_name';
cfg_player_team        = 'player_team';
cfg_mouse_sens         = 'mouse_sens';
cfg_sound_volume       = 'sound_volume';
cfg_server_addr        = 'server_addr';
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
cfg_show_time          = 'show_time';
cfg_save_scores        = 'save_scores';
cfg_max_corpses        = 'max_corpses';
cfg_demo_record        = 'demo_record';
cfg_vid_w              = 'vid_w';
cfg_vid_h              = 'vid_h';
cfg_hud_scale          = 'hud_scale';

cfg_key                = 'key_';
cfg_key_t              : array[false..true] of char = ('s','t');

cfg_default_grp_path_n = 3;
cfg_default_grp_path_l : array[0..cfg_default_grp_path_n] of shortstring =
                         ('graphic',
                          'graphic_nonazi',
                          'graphic_original',
                          'graphic_original_nonazi');


var _temp_agraph:shortstring = '';

function cfgclks(i:byte;b:boolean):shortstring;
begin
   cfgclks:=cfg_key+cfg_key_t[b]+b2s(i);
end;

procedure cfg_add_agraph(s:shortstring);
var i:byte;
begin
   if(vid_agraph_dir_n<255)and(length(s)>0)then
   begin
      if(vid_agraph_dir_n>0)then
       for i:=0 to vid_agraph_dir_n-1 do
        if(vid_agraph_dir_l[i]=s)then exit;

      vid_agraph_dir_n+=1;
      setlength(vid_agraph_dir_l,vid_agraph_dir_n);
      vid_agraph_dir_l[vid_agraph_dir_n-1]:=s;
   end;
end;

procedure cfg_setval(vl,vr:shortstring);
var vrb:cardinal;
      i:byte;
begin
   vrb:=s2c(vr);
   case vl of
cfg_player_name    : player_name      := vr;
cfg_player_team    : player_team      := vrb;
cfg_mouse_sens     : m_speed          := s2i(vr);
cfg_sound_volume   : snd_volume       := vrb;
cfg_server_addr    : cl_net_svaddr    := vr;
cfg_cam_height     : vid_rc_newz      := vrb>0;
cfg_fullscreen     : vid_fullscreen   := vrb>0;
cfg_net_update     : player_netupd    := vrb>0;
cfg_weapon_switch  : player_wswitch   := vrb>0;
cfg_weapon_antilag : player_antilag   := vrb>0;
cfg_move_smooth    : player_smooth    := vrb>0;
cfg_show_time      : player_showtime  := vrb>0;
cfg_chat_sound     : player_chat_snd  := vrb>0;
cfg_chat1_str      : player_chat1     := vr;
cfg_chat2_str      : player_chat2     := vr;
cfg_chat3_str      : player_chat3     := vr;
cfg_chat4_str      : player_chat4     := vr;
cfg_chat5_str      : player_chat5     := vr;
cfg_show_fps       : player_showfps   := vrb>0;
cfg_agraph_dir     : cfg_add_agraph(vr);
cfg_agraph_dir_cur : _temp_agraph     := vr;
cfg_resolution_w   : vid_rw           := s2i(vr);
cfg_save_scores    : scores_save      := vrb>0;
cfg_max_corpses    : player_maxcorpses:= s2i(vr);
cfg_demo_record    : demo_record      := vrb>0;
cfg_vid_w          : vid_w            := s2i(vr);
cfg_vid_h          : vid_h            := s2i(vr);
cfg_hud_scale      : hud_scale_prsnt  := vrb;
   else
     for i:=0 to 255 do
      if(i in cfg_cl_keys)then
      begin
         if(vl=cfgclks(i,true ))then cl_keys_t[i]:=vrb;
         if(vl=cfgclks(i,false))then cl_keys  [i]:=s2c(vr);
      end;
   end;
end;

procedure cfg_parse_str(s:shortstring);
var vr,vl:shortstring;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos(cfg_param_sep,s);
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
   if FileExists(config_fname) then
   begin
      assign(f,config_fname);
      reset(f);
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);
   end;

   m_speed    :=mm3i(m_speed_min,m_speed,m_speed_max);

   snd_volume :=mm3b(0,snd_volume,100);
   snd_volume1:=snd_volume/100;

   if(player_team>MaxTeamsI)then player_team:=MaxTeamsI;

   if(length(player_name)>NameLen)then SetLength(player_name,NameLen);

   player_maxcorpses:=mm3i(-1,player_maxcorpses,rc_MaxEffects);

   cam_z  :=rc_camz[vid_rc_newz];

   hud_scale_prsnt:=mm3b(hud_scale_prsnt_min,hud_scale_prsnt,hud_scale_prsnt_max);

   txt_ValidateAddr;

   vid_w :=mm3i(vid_min_w,vid_w,vid_max_w);
   vid_h :=mm3i(vid_min_h,vid_h,vid_max_h);

   vid_rw:=mm3i(vid_min_rw,vid_rw,vid_max_rw);
   vid_rw:=mm3i(vid_min_rw,vid_rw,vid_w);
   vid_rh:=mm3i(vid_min_rh,round(vid_rw*(vid_h/vid_w)),vid_max_rh);

   menu_vid_w := vid_w;
   menu_vid_h := vid_h;
   menu_vid_ws:= i2s(menu_vid_w);
   menu_vid_hs:= i2s(menu_vid_h);

   // current selected
   if(vid_agraph_dir_n>0)then
    for i:=0 to vid_agraph_dir_n-1 do
     if(vid_agraph_dir_l[i]=_temp_agraph)then
     begin
        vid_agraph_dir_sel:=i;
        break;
     end;

   if(vid_agraph_dir_n=0)then
   begin
      vid_agraph_dir_sel:=cfg_default_grp_path_n;
      for i:=0 to cfg_default_grp_path_n do cfg_add_agraph(cfg_default_grp_path_l[i]);
   end;
end;

procedure cfg_save;
var f:text;
    i:byte;
begin
   assign(f,config_fname);
   rewrite(f);

   writeln(f,cfg_player_name    ,cfg_param_sep,player_name          );
   writeln(f,cfg_player_team    ,cfg_param_sep,player_team          );
   writeln(f,cfg_mouse_sens     ,cfg_param_sep,m_speed              );
   writeln(f,cfg_sound_volume   ,cfg_param_sep,snd_volume           );
   writeln(f,cfg_server_addr    ,cfg_param_sep,cl_net_svaddr        );
   writeln(f,cfg_cam_height     ,cfg_param_sep,byte(vid_rc_newz    ));
   writeln(f,cfg_fullscreen     ,cfg_param_sep,byte(vid_fullscreen ));
   writeln(f,cfg_net_update     ,cfg_param_sep,byte(player_netupd  ));
   writeln(f,cfg_weapon_switch  ,cfg_param_sep,byte(player_wswitch ));
   writeln(f,cfg_weapon_antilag ,cfg_param_sep,byte(player_antilag ));
   writeln(f,cfg_move_smooth    ,cfg_param_sep,byte(player_smooth  ));
   writeln(f,cfg_chat_sound     ,cfg_param_sep,byte(player_chat_snd));
   writeln(f,cfg_show_fps       ,cfg_param_sep,byte(player_showfps ));
   writeln(f,cfg_chat1_str      ,cfg_param_sep,player_chat1         );
   writeln(f,cfg_chat2_str      ,cfg_param_sep,player_chat2         );
   writeln(f,cfg_chat3_str      ,cfg_param_sep,player_chat3         );
   writeln(f,cfg_chat4_str      ,cfg_param_sep,player_chat4         );
   writeln(f,cfg_chat5_str      ,cfg_param_sep,player_chat5         );
   writeln(f,cfg_resolution_w   ,cfg_param_sep,vid_rw               );
   //writeln(f,cfg_resolution_h   ,cfg_param_sep,vid_rh               );
   writeln(f,cfg_show_time      ,cfg_param_sep,byte(player_showtime));
   writeln(f,cfg_save_scores    ,cfg_param_sep,byte(scores_save)    );
   writeln(f,cfg_max_corpses    ,cfg_param_sep,player_maxcorpses    );
   writeln(f,cfg_demo_record    ,cfg_param_sep,byte(demo_record)    );
   writeln(f,cfg_vid_w          ,cfg_param_sep,vid_w                );
   writeln(f,cfg_vid_h          ,cfg_param_sep,vid_h                );
   writeln(f,cfg_hud_scale      ,cfg_param_sep,hud_scale_prsnt      );

   if(vid_agraph_dir_n>0)then
     for i:=0 to vid_agraph_dir_n-1 do
       writeln(f,cfg_agraph_dir,cfg_param_sep,vid_agraph_dir_l[i]);
   writeln(f,cfg_agraph_dir_cur,cfg_param_sep,vid_agraph_dir_l[vid_agraph_dir_sel]);

   for i:=0 to 255 do
     if(i in cfg_cl_keys)then
     begin
        writeln(f,cfgclks(i,true ),cfg_param_sep,cl_keys_t[i]);
        writeln(f,cfgclks(i,false),cfg_param_sep,cl_keys  [i]);
     end;

   close(f);
end;


