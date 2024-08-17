

type

 integer = Smallint;
pinteger = ^integer;

pfile    = ^file;

{$IFDEF FULLGAME}

ppSDL_Texture = ^pSDL_Texture;

TSoC = set of char;

TColor = record
   r,g,
   b,a       : byte;
   c         : cardinal;
end;
PTColor = ^TColor;

TImage = record
   texture   : pSDL_Texture;
   surface   : pSDl_Surface;
    w, h,
   hw,hh     : integer;
end;
PTImage = ^TImage;

 TRCTextureLine = array[0..rc_Texture_iw] of cardinal;
pTRCTextureLine = ^TRCTextureLine;
 TRCTexture     = array[0..rc_Texture_iw] of TRCTextureLine;
pTRCTexture     = ^TRCTexture;

TRCImage = record
   rc_w,rc_hw,
   rc_h,rc_hh : integer;
   rctexture  : TRCTexture;
   sdltexture : pSDL_Texture;
   rc_z       : single;
   trunsColor : cardinal;
end;
pTRCImage = ^TRCImage;

TBufSpr = record
   bs_rcimage : pTRCImage;
   bs_x,
   bs_y,
   bs_z,
   bs_d,
   bs_scale,
   bs_v       : single;
   bs_flipx   : boolean;
end;
PTBufSpr = ^TBufSpr;

TDecor = record
   decor_x,
   decor_y    : single;
   decor_type : char;
end;

TEff = record
  eff_x,
  eff_y,
  eff_z,
  eff_scale,
  eff_ez_fallspd
              : single;
  eff_type,
  eff_anim    : byte;
end;

TRoomInfo = record
   mname,
   rname      : shortstring;

   g_fraglimit: integer;
   g_timelimit,
   cur_clients,
   cur_players,
   max_clients,
   max_players: byte;
   g_flags    : cardinal;
end;

TMapEditorGrid = array[0..map_miw,0..map_miw] of char;
{$ELSE}

TBan = record
   ban_ip      : cardinal;
   ban_comment : shortstring;
   ban_time    : cardinal;
end;
{$ENDIF}


TMap = record
   mbuff   : array[1..MaxMapBuffer] of char;
   mname   : shortstring;
end;

TSpawn = record
   spx,
   spy,
   spdir   : single;
end;

TItem = record
   iammo       : array[0..AmmoTypesN] of integer;
   ihealth,
   iarmor      : integer;
   iweapon     : byte;
   ix,iy       : single;
   irespm,
   irespt      : word;
   itype       : char;
   {$IFDEF FULLGAME}
   isprite     : byte;
   {$ENDIF}
end;

TPlayerHitSet  = array[0..PlayerHitSetSize] of byte;
PTPlayerHitSet = ^TPlayerHitSet;

TDemoPos = record
   dp_tick,
   dp_time_tick,
   dp_fpos     : cardinal;
   dp_demo_items,
   dp_time_scorepause
               : word;
end;

TLogMessage = record
   data_id     : byte;
   data_string : shortstring;
end;

TMissile = record
   mx,my,
   mvx,mvy,
   mspeed,
   mdir,
   mmaxdist,
   msplashr    : single;
   mplayer,
   mgun,
   mtype       : byte;
   mdamage     : integer;
   {$IFDEF FULLGAME}
   mtrail      : byte;
   mspriteScale: single;
   {$ENDIF}
end;
PTMissile = ^TMissile;

TRoom = record
   r_item_l    : array of TItem;
   r_spawn_l   : array of TSpawn;
   r_missile_l : array of TMissile;
   r_item_n,
   r_spawn_n,
   r_missile_n,
   time_scorepause,
   g_deathtime,
   g_scorepause
               : word;

   maplist_l   : array of word;
   map_cur,
   maplist_n,
   maplist_cur : word;
   mapname     : shortstring;

   vote_cmd,
   vote_arg    : shortstring;
   vote_time   : word;
   vote_ratio  : single;

   bot_skill_default,
   bot_cur     : byte;
   bot_curt    : array[0..MaxTeamsI] of byte;
   bot_maxt    : array[0..MaxTeamsI] of byte;

   g_fraglimit : integer;
   team_frags  : array[0..MaxTeamsI] of integer;

   g_timelimit : byte;
   time_min,
   time_min_prev,
   time_sec,
   time_tick   : cardinal;

   cur_clients,
   cur_players,
   max_clients,
   max_players,
   rnum        : byte;
   g_flags     : cardinal;

   rname       : shortstring;

   rgrid       : array[0..map_mlw,0..map_mlw] of char;

   log_l       : array[0..MaxRoomLog] of TLogMessage;
   log_i,
   log_n       : word;

   demo_file   : pfile;
   demo_size   : cardinal;
   demo_timer1,
   demo_timer2,
   demo_pdata,
   demo_cstate,
   demo_fstate : byte;
   demo_fpos_t ,
   demo_fpos_n : cardinal;
   demo_fpos_l : array of TDemoPos;
   demo_pfrags : array[1..MaxPlayers] of integer;
   demo_pnames : array[1..MaxPlayers] of shortstring;
   demo_ppause : word;
   demo_fname  : shortstring;
   demo_head   : boolean;
   demo_items,
   demo_logn   : word;

   {$IFDEF FULLGAME}
   r_decor_l   : array of TDecor;
   r_decor_n   : word;
   r_floor_color,
   r_ceil_color      : TColor;
   {$ELSE}
   scores_save_need  : boolean;
   scores_message    : shortstring;
   {$ENDIF}
end;
PTRoom = ^TRoom;

TPlayer = record
   name    : shortstring;

   x,y,
   dir     : single;

   {$IFDEF FULLGAME}
   dspx,dspy,
   vx,vy,
   vdir    : single;
   tesla_eff,
   hits_sound
           : integer;
   {$ELSE}
   net_moves
           : integer;
   xbuffer,
   ybuffer : array[0..MaxXYBuffer] of single;
   ibuffer : byte;
   pause_logsend,
   pause_ping
           : word;
   ping_t  : cardinal;
   ping_r  : boolean;
   vote    : byte;
   rcon_access    : boolean;
   {$ENDIF}

   log_n,
   pause_chat,
   pause_resp,
   pause_spec,
   pause_gun,
   pause_snap,
   death_time,
   mdata_item,
   ttl,
   ping    : word;

   frags,
   hits,
   armor   : integer;
   ammo    : array[0..AmmoTypesN] of integer;

   pnum,
   roomi,
   team,
   state,
   gun_rld,
   gun_next,
   gun_curr,
   gun_inv,
   pdata_player,
   bot_enemy,
   bot_reaction,
   bot_skill_aggression,
   bot_skill_reaction,
   bot_skill_shootfreq,
   bot_skill_moveskip,
   bot_skill_turnspeed,
   bot_skill_instspread
           : byte;
   bot_ax,
   bot_ay,
   bot_md,
   bot_mx,
   bot_my  : single;

   gids_death,
   net_fupd,
   wswitch,
   antilag,
   bot     : boolean;

   ip      : cardinal;
   port    : word;
   room    : PTRoom;
end;
PTPlayer = ^TPlayer;





