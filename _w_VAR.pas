

var

sys_event         : PSDl_Event = nil;
sys_cycle         : boolean = false;

net_socket        : PUDPSocket = nil;
net_socket_port   : word = 0;
net_buffer        : PUDPpacket = nil;
net_buffer_pos    : LongInt = 0;

sv_name           : shortstring = '';
sv_maxrooms       : byte        = 1;
sv_rooms          : array of TRoom;

g_players         : array[0..MaxPlayers] of TPlayer;
g_maps            : array of TMap;
g_mapn            : word = 0;

gun_reload_s      : array[0..WeaponsN] of byte;

fr_FPSSecond,
fr_FPSSecondD,
fr_FPSSecondN,
fr_FPSSecondC,
fr_FPSSecondT,
fr_FrameCount,
fr_LastTicks,
fr_BaseTicks      : cardinal;

{$IFDEF FULLGAME}

demos_s           : array of shortstring;
demos_l           : array of shortstring;
demos_n           : word;

scores_save_need  : boolean = false;
scores_message    : shortstring = '';

nosound           : boolean = false;

net_packets_in    : word=0;
net_packets_out   : word=0;
net_packets_in0   : word=0;
net_packets_out0  : word=0;
net_packets_t     : word=0;
net_packetsid_in  : array[byte] of byte;
net_SearchLocalSV : boolean = false;

server_ping_p     : cardinal = 0;
server_ping_t     : cardinal = 0;
server_ping_r     : boolean = false;
server_ping       : cardinal = 0;
server_ttl        : cardinal = 0;

sv_clroom         : PTRoom;

gun_ganim         : array[0..WeaponsN] of byte;
gun_sanim         : array[0..WeaponsN] of byte;

vid_window        : PSDL_Window = nil;
vid_renderer      : PSDL_Renderer = nil;
vid_dtimage       : TImage;
vid_rect          : PSDL_rect;
vid_rctexture     : pSDL_Texture = nil;

show_player_id    : boolean = false;

vid_fullscreen    : boolean = false;
vid_rc_newz       : boolean = false;
vid_agraph_dir_l  : array of shortstring;
vid_agraph_dir_n  : byte = 0;
vid_agraph_dir_sel: byte = 0;

cl_mode           : byte = 1;

demo_skip         : word = 0;
demo_play_pause   : boolean = false;
demo_record       : boolean = true;
scores_save       : boolean = true;

menu              : boolean = true;
menu_locmatch     : boolean = false;
menu_linsta       : boolean = false;
menu_lteams       : boolean = false;
menu_lteamd       : boolean = false;
menu_itresp       : boolean = true;
menu_wstay        : boolean = true;
menu_lslimit      : integer = 0;
menu_ltlimit      : byte = 0;
menu_lbots        : array[0..MaxTeamsI] of byte;
menu_scol         : array[boolean] of PTColor;
menu_scol2        : array[boolean] of PTColor;
menu_s            : integer = 1;
menu_sfix         : integer = -1;
menu_scrol        : integer = 0;
menu_num          : integer = 0;
menu_txtL         : array of shortstring;
menu_txtR         : array of shortstring;
menu_txtT         : array of byte;
menu_bmm          : word = 0;
menu_inscr        : integer = 34;
menu_ystep        : integer = 0;
menu_font_h       : integer = 0;
menu_font_w       : integer = 0;

menu2actkeys      : array[byte] of byte;
menu_update       : boolean = true;
menu_ctrls_str1   : integer = 0;
menu_ctrls_str2   : integer = 0;
menu_roomi        : integer = 0;
menu_demoi        : integer = 0;

m_speed           : integer = 50;
move_dir          : array[false..true,false..true,false..true,false..true] of integer;

net_period        : byte = 0;

cl_group          : array[byte] of byte;
cl_keys_t         : array[byte] of byte;       // type (keyboard, mouse, mousewheel)
cl_keys           : array[byte] of cardinal;
cl_acts           : array[byte] of integer;
cl_playeri        : byte = 0;
cl_action         : byte = 0;

cl_net_svip       : cardinal = 0;
cl_net_svips      : shortstring = '127.0.0.1';
cl_net_svp        : word = 0;
cl_net_svps       : shortstring = '35700';
cl_net_stat       : shortstring = '';
cl_net_cstat      : byte = 0;
cl_net_roomi      : byte = 255;
cl_net_mpartn     : byte = 0;
cl_net_mapi       : word = 65535;
cl_net_maprq_t    : byte = 0;

cl_buffer_xy_i    : byte;
cl_buffer_xy_x,
cl_buffer_xy_y    : array[0..cl_buffer_xy_n] of single;

sv_roomsinfo      : array of TRoomInfo;
sv_roomsinfo_n    : byte = 0;
sv_ping           : cardinal = 0;
sv_ping_str       : shortstring = '--';

player_name       : shortstring = str_DefaultPlayerName;
player_team       : byte = 0;
player_wswitch    : boolean = true;
player_netupd     : boolean = false;
player_antilag    : boolean = true;
player_smooth     : boolean = true;
player_chat_snd   : boolean = true;
player_showfps    : boolean = true;
player_showtime   : boolean = true;
player_maxcorpses : integer = rc_MaxEffects;
player_rcon       : shortstring = '';

player_chat1      : shortstring = ':D';
player_chat2      : shortstring = ':P';
player_chat3      : shortstring = ':(';
player_chat4      : shortstring = 'GG';
player_chat5      : shortstring = 'BG';

chat_line         : boolean = false;
chat_str          : shortstring = '';
console_str       : shortstring = '';

console_history   : array[0..MaxRoomLog] of shortstring;
console_historyi  : byte = 0;
console_historyn  : byte = 0;

last_key_t        : byte = 0;
last_key          : cardinal = 0;
last_key_m        : integer = 0;

hud_console       : boolean = false;
hud_last_mesn     : integer = 0;
hud_mask          : TColor;
hud_mask_t        : integer = 0;
hud_noammoclk     : integer = 0;
hud_chat_y        : integer = 0;
hud_guni,
hud_state         : byte;
hud_hits,
hud_armor         : integer;
hud_ammo          : array[0..AmmoTypesN] of integer;
hud_biggun        : byte = 0;
hud_text          : array of shortstring;
hud_textc         : array of PTColor;
hud_textln        : integer = 0;
hud_textn         : integer = 0;
hud_text_scrol    : word = MaxRoomLog-5;
hud_rcw_charn     : integer = 0;
hud_rch_lines     : integer = 0;

animation_tick    : cardinal = 0;

scboard_name_w,
scboard_frag_w,
scboard_ping_w,
scboard_col_w,
scboard_col_bh,
scboard_sx,
scboard_sy,
scboard_btw       : integer;

m_DRectX0,
m_DRectX1,
m_DRectY0,
m_DRectY1,
m_DRectW,
m_DRectH          : integer;

map_rc_sprite_l   : array of PTBufSpr;
map_rc_sprite_n   : integer = 0;
map_leffs         : word    = 0;
map_ldead         : integer = 0;
map_deads,
map_effs          : array[0..rc_MaxEffects] of TEff;

keyboard_string   : shortstring = '';

snd_volume        : byte = 50;
snd_volume1       : single = 0.5;

spr_rcwall_doortrack,
spr_rcwall_door   : array[0..1] of TRCImage;
spr_rcwall_hline  : TRCImage;
spr_rcwall        : array[0..1,'A'..'Z'] of TRCImage;
spr_rcdecor       : array['a'..'z' ] of TRCImage;
spr_rcitem        : array[0..16    ] of TRCImage;
spr_rceffect      : array[0..4,0..3] of TRCImage;
spr_rcflame       : array[0..2     ] of TRCImage;
spr_rcrocket      : array[0..7     ] of TRCImage;
spr_rcteam        : array[0..MaxTeamsI,0..SkinSprites] of TRCImage;
spr_rcelectro     : array[0..4     ] of TRCImage;
spr_rcmeat        : array[0..4     ] of TRCImage;
spr_HUDfont       : array['0'..';' ] of TImage;
spr_HUDfont_w     : byte = 8;
spr_HUDfunt_h     : byte = 15;
spr_HUDpanel      : TImage;
spr_HUDgun        : array[0..WeaponsN,0..1] of TImage;
spr_HUDgunX,
spr_HUDgunY       : array[0..WeaponsN,0..1] of integer;
spr_HUDgun_inv    : array[0..WeaponsN] of TImage;
spr_HUDteam       : array[0..MaxTeamsI] of TImage;
spr_HUDface       : array[0..22] of TImage;

font_ca           : array[char] of TImage;
font_w            : integer = 8;
font_h            : integer = 0;
font_hh           : integer = 0;
font_lh           : integer = 0;

cam_pl            : byte = 0;
cam_fov,
cam_dir,
cam_turn,
cam_x,
cam_y,
cam_z,
rc_iD,
rc_x,rc_y,
rc_vx,
rc_vy,
rc_plx,
rc_ply            : single;
rc_buffer_size    : cardinal = 0;
rc_buffer         : pointer = nil;
rc_pitch          : longint = 0;
ZBuffer_size      : cardinal = 0;
ZBuffer           : pointer = nil;
ZBufferMDW        : single = 0;
rc_vgrid          : array[0..map_mlw,0..map_mlw] of boolean;

window_w          : integer = vid_log_w;
window_h          : integer = vid_log_h;
screenshot_w      : integer = vid_log_w;
screenshot_h      : integer = vid_log_h;

vid_log_mtx       : integer = 0;
vid_log_rh        : integer = 0;
vid_log_rih       : integer = 0;

vid_rw            : longint = 640;
vid_rh            : longint = 480;
vid_scx,
vid_scy,
vid_hud_scale,
rc_cxt,
vid_aspect        : single;
vid_aspecti,
vid_panelh,
vid_rhw,
vid_rhh,
vid_iw,
vid_ih            : longint;

hud_weapon_y      : integer = 0;
hud_scorex,
hud_hitsx,
hud_armorx,
hud_ammox,
hud_invix,
hud_invx,
hud_invy,
hud_gunx,
hud_guny,
hud_teamx,
hud_teamy,
hud_hudhx,
hud_hudhy,
hud_texty,
hud_gbrc_x,
hud_gbrc_y,
hud_gbrc_w,
hud_gbrc_h,

hud_pl_staty0,
hud_pl_staty1
                  : integer;
hud_txt_yscale,
hud_fscale,
hud_ifscale       : single;


c_purple,
c_green,
c_lgreen,
c_white,
c_black,
c_ablack,
c_gray,
c_dgray,
c_aqua,
c_daqua,
c_ltgray,
c_orange,
c_yellow,
c_red,
c_ltred,
c_ddred,
c_sred,
c_dred,
c_blue,
c_ltblue,
c_ltlime,
c_console,
c_lime            : TColor;

team_color        : array[0..MaxTeamsI] of PTColor;

snd_meat,
snd_fire,
snd_weapon,
snd_chain,
snd_death,
snd_explode,
snd_noammo,
snd_ammo,
snd_chat,
snd_health,
snd_score,
snd_spawn,
snd_armor,
snd_mmove   : TALuint;
snd_gun     : array[0..WeaponsN] of TALuint;
snd_skinD   : array[0..3] of TALuint;
snd_skinP   : array[0..3] of TALuint;

editor_icons: array[0..editor_icons_n] of TImage;

editor_ceil_color,
editor_floor_color
            : TColor;

editor_vx,
editor_vy,
editor_vw,
editor_vspeed,
editor_panel_b,
editor_mouse_x,
editor_mouse_y,
editor_mouse_gx,
editor_mouse_gy,
editor_mouse_mx,
editor_mouse_my,
editor_grid_w,
editor_grid_hw
            : integer;
editor_mapi : word = 0;
editor_panel_mapi
            : word = 0;

editor_brush_wall : char = 'A';
editor_brush_decor: char = 'a';
editor_brush_item : char = '1';
editor_brush_spawn: char = '<';
editor_brush      : char = 'A';

editor_map        : TMapEditorGrid;

{$ELSE}

sv_bans                : array of TBan;
sv_bann                : word = 0;
sv_rcon_pass           : shortstring = 'wolfadmin';
sv_net_port            : word = 35700;
sv_room_config_fname   : shortstring = 'rooms.cfg';

net_advertise          : boolean = true;
net_advertise_timer    : integer = 0;
net_advertise_ip       : cardinal = cardinal.MaxValue;
net_advertise_port     : word = 0;

{$ENDIF}
