

type

 integer = Smallint;
pinteger = ^integer;

pfile    = ^file;

{$IFDEF FULLGAME}

TSoC = set of char;

TColor = record
   r,g,
   b,a     : byte;
   c       : cardinal;
end;
PTColor = ^TColor;

 TTextureLine = array[0..rc_tex_iw] of cardinal;
pTTextureLine = ^TTextureLine;
 TTexture = array[0..rc_tex_iw] of TTextureLine;

TRCWall = record
   rcw,rch:word;
   texture:TTexture;
end;
PTRCWall = ^TRCWall;

TImage = record
   texture : pSDL_Texture;
   surface : pSDl_Surface;
    w, h,
   hw,hh   : integer;
end;
PTImage = ^TImage;

 TSpriteLine   = array[0..rc_spr_iw] of cardinal;
PTSpriteLine   = ^TSpriteLine;
 TSpriteTexure = array[0..rc_spr_iw] of TSpriteLine;
PTSpriteTexure = ^TSpriteTexure;
TSprite = record
   pf      : cardinal;
   p       : TSpriteTexure;
   w,h     : integer;
   sm      : single;
end;
PTSprite = ^TSprite;

TBufSpr = record
    s      : PTSprite;
x,y,z,d,v   : single;
    a      : boolean;
end;
PTBufSpr = ^TBufSpr;

TDecor = record
   dx,dy   : single;
   t       : char;
end;

TEff = record
  ex,ey,ez,
  ezs      : single;
  t,a      : byte;
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
   iammo   : array[0..AmmoTypesN] of integer;
   ihealth,
   iarmor  : integer;
   iweapon : byte;
   ix,iy   : single;
   irespm,
   irespt  : word;
   itype   : char;
end;

TPlayerHitSet  = array[0..PlayerHitSetSize] of byte;
PTPlayerHitSet = ^TPlayerHitSet;

TDemoPos = record
   dp_tick,
   dp_time_tick,
   dp_fpos : cardinal;
   dp_demo_items,
   dp_time_scorepause
           : word;
end;

TRoom = record
   r_items    : array of TItem;
   r_spawns   : array of TSpawn;
   r_itemn,
   r_spawnn,
   time_scorepause,
   g_deathtime,
   g_scorepause
              : word;

   maplist    : array of word;
   mapi,
   maplistn,
   maplisti   : word;
   mapname    : shortstring;

   vote_cmd,
   vote_arg   : shortstring;
   vote_time  : word;
   vote_ratio : single;

   bot_cur    : byte;
   bot_curt   : array[0..MaxTeamsI] of byte;
   bot_maxt   : array[0..MaxTeamsI] of byte;

   g_fraglimit: integer;
   team_frags : array[0..MaxTeamsI] of integer;

   g_timelimit,
   time_min,
   time_min_prev,
   time_sec,
   time_tick  : cardinal;

   cur_clients,
   cur_players,
   max_clients,
   max_players,
   rnum       : byte;
   g_flags    : cardinal;

   rname      : shortstring;

   rgrid      : array[0..map_mlw,0..map_mlw] of char;

   log_l      : array[0..MaxRoomLog] of shortstring;
   log_t      : array[0..MaxRoomLog] of byte;
   log_i,
   log_n      : word;

   demo_file  : pfile;
   demo_size  : cardinal;
   demo_timer1,
   demo_timer2,
   demo_pdata,
   demo_cstate,
   demo_fstate: byte;
   demo_fpos_t,
   demo_fpos_n: cardinal;
   demo_fpos_l: array of TDemoPos;
   demo_pnames: array[1..MaxPlayers] of shortstring;
   demo_ppause: word;
   demo_fname : shortstring;
   demo_head  : boolean;
   demo_items,
   demo_logn  : word;

   {$IFDEF FULLGAME}
   r_decors   : array of TDecor;
   r_decorn   : word;
   r_floorc,
   r_ceilc    : TColor;
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
   bot_enemy
           : byte;
   bot_tpause
           : word;
   bot_ax,
   bot_ay,
   bot_md,
   bot_mx,
   bot_my  : single;

   net_fupd,
   wswitch,
   antilag,
   bot     : boolean;

   ip      : cardinal;
   port    : word;
   room    : PTRoom;
end;
PTPlayer = ^TPlayer;





