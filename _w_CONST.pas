

const

DEGTORAD               = pi/180;

ver                    = 10;

str_NewLineChar        = #13;
str_ErrorLogSep        = '; ';
str_PathSlash          = '\';

////////////////////////////////////////////////////////////////////////////////
//
// Framerate

fr_fpsx1               = 60;
fr_fpsx2               = fr_fpsx1*2;
fr_fpsx3               = fr_fpsx1*3;
fr_fpsh1               = fr_fpsx1 div 2;
fr_fpsh2               = fr_fpsx1 div 4;
fr_fpsx5               = fr_fpsx1*5;

fr_fpsx1hh             = fr_fpsx1+fr_fpsh2;

fr_RateTicks           = 1000/fr_fpsx1;
fr_RateTicksI          = round(fr_RateTicks);

TicksPerMinute         = fr_fpsx1*60;

////////////////////////////////////////////////////////////////////////////////
//
// Map

map_mw                 = 64;           // 1-64
map_miw                = map_mw-1;     // 0-63
map_mlw                = map_mw+1;     // 0-65 grid borders
map_pl                 = 1.5;
map_pb                 = map_mw+0.5;   // 1.5 .. 64.5

mgr_empty              = ' ';

mgr_wih                = '?';                // infinity horizon
mgr_door               = '#';
mgr_bwalls             = ['A'..'Z',mgr_wih]; // walls for bullets
mgr_decors             = ['a'..'z'];
mgr_dwalls             = mgr_decors-['a'..'d','v','x','y'];// player/projectilles blocking decors

mgr_spawn_180          = '<';
mgr_spawn_270          = '^';
mgr_spawn_0            = '>';
mgr_spawn_90           = '.';
mgr_spawn_random       = '@';
mgr_spawns             = [
                          mgr_spawn_180,
                          mgr_spawn_270,
                          mgr_spawn_0,
                          mgr_spawn_90,
                          mgr_spawn_random
                          ];

mgr_item_armor         = '0';
mgr_item_mp40          = '1';
mgr_item_chaingun      = '2';
mgr_item_ammo          = '3';
mgr_item_ammobox       = '4';
mgr_item_dogfood       = '5';
mgr_item_food          = '6';
mgr_item_medkit        = '7';
mgr_item_mega          = '8';
mgr_item_rifle         = '9';
mgr_item_flame         = ':';
mgr_item_panzer        = '=';
mgr_item_tesla         = '+';
mgr_item_ammorifle     = '%';
mgr_item_ammoflame     = '$';
mgr_item_ammopanzer    = '*';
mgr_item_ammotesla     = '(';
mgr_items              = [
                          mgr_item_armor,
                          mgr_item_mp40,
                          mgr_item_chaingun,
                          mgr_item_ammo,
                          mgr_item_ammobox,
                          mgr_item_dogfood,
                          mgr_item_food,
                          mgr_item_medkit,
                          mgr_item_mega,
                          mgr_item_rifle,
                          mgr_item_flame,
                          mgr_item_panzer,
                          mgr_item_tesla,
                          mgr_item_ammorifle,
                          mgr_item_ammoflame,
                          mgr_item_ammopanzer,
                          mgr_item_ammotesla
                          ];

DefaultMap             : PChar =
'FCFCFC707070'+
' vvvvvvvvvv      IIIIIIII'        +str_NewLineChar+
' vJjWjXjWjKIIJIII666U  .I'        +str_NewLineChar+
' vjb3a   a       bS b S I'        +str_NewLineChar+
' vW383       b         1J'        +str_NewLineChar+
' vj 3b QQ  RQ1QR S T%TbSI'        +str_NewLineChar+
' vX      a QQ^QQ        I'        +str_NewLineChar+
' vj  Q     QQtQQ  U 7 U I'        +str_NewLineChar+
' vW  Q ab  QQRQQ    S   J'        +str_NewLineChar+
' vj a   a  RQQQQ    2   I'        +str_NewLineChar+
' vK       b4QQQQ bYYYY  I'        +str_NewLineChar+
'  I  RQQQR4b4RQQ  YZZY  I'        +str_NewLineChar+
'  I  QQQQQQ4b     YZZY  J'        +str_NewLineChar+
'  K b1<mRQQR   b%4YZZY  I'        +str_NewLineChar+
'  I  QQQQQRQ  YYYYYi>1b I  a'     +str_NewLineChar+
'  I  RQQQQfQ  1<gZZZZY  I'        +str_NewLineChar+
'  I     7Q.Q  YZZZZZZY  J'        +str_NewLineChar+
'  I      Q1Q  YYYYYYYY  n a ha'   +str_NewLineChar+
'  M  MM   b             V'        +str_NewLineChar+
' LL  MM4                n'        +str_NewLineChar+
' M%b tMMMMMM  J         V a'      +str_NewLineChar+
' L   MLtLMLM  s      c3 n   i'    +str_NewLineChar+
' M69          L      303V    a'   +str_NewLineChar+
' L66   b     4s4      3cn a'      +str_NewLineChar+
' MMMLML1LMLMLMJnVnVnVnVnO      i' +str_NewLineChar+
'      M^M                    h'   +str_NewLineChar+
'      MeM           a    a'       +str_NewLineChar+
'       J     a  a  h        a'    +str_NewLineChar+
'              a       a  h'       +str_NewLineChar+
'             i    a'              +str_NewLineChar+
'                  i         i';

////////////////////////////////////////////////////////////////////////////////
//
// Game

MaxPlayers             = 128;
MaxMapBuffer           = map_mw*map_mw+12;
MaxTeams               = 4;
MaxTeamsI              = MaxTeams-1;
MaxNetBuffer           = MaxMapBuffer+12;
MaxRoomLog             = 250;
MaxPlayerTTL           = fr_fpsx1*30;
NetMapParts            = 7;
NetMapPartSize         = (MaxMapBuffer div NetMapParts)+NetMapParts;
MaxMissiles            = 1024;

PlayerHitSetSize       = (MaxPlayers div 8);

WeaponsN               = 7; // 0..7

AmmoTypesN             = 5; // 0..5
ammo_knife             = 0;
ammo_bullet            = 1;
ammo_rifle             = 2;
ammo_flame             = 3;
ammo_rocket            = 4;
ammo_tesla             = 5;

NameLen                = 20;
ChatLen                = 200;

// Players max values
Player_max_hits        = 100;
Player_max_armor       = 100;
Player_max_ammo        : array[0..AmmoTypesN] of integer = (0,250,20,250,20,9);
Player_max_speed       : array[false..true  ] of single  = (0.115,0.23); // [spectator]
Player_WWidth          : single = 0.25; // collision box for walls
Player_BWidth          : single = 0.35; // collision box for bullets/projectilles
Player_IWidth          : single = 0.45; // collision box for items

gibs_hits              = -Player_max_hits div 2;

// player state
ps_none                = 0;
ps_spec                = 1;
ps_dead                = 2;
ps_walk                = 3;
ps_attk                = 4;

ps_gibs                = 5; // demo/network

ps_data1               = 6; // demo name data
ps_data2               = 7; // demo ping data

// action
aid_w1                 = 1;
aid_w2                 = 2;
aid_w3                 = 3;
aid_w4                 = 4;
aid_w5                 = 5;
aid_w6                 = 6;
aid_w7                 = 7;
aid_w8                 = 8;
aid_wN                 = 10;
aid_wP                 = 11;
aid_specjoin           = 12;
aid_attack             = 13;

// LOG IDs

log_common             = 1;
log_chat               = 2;
log_endgame            = 3;
log_winner             = 4;
log_suddendeath        = 5;
log_map                = 6;
log_local              = 7;
log_roomdata           = 8;
log_matchreset         = 9;

// game mode flags
sv_g_instagib          : cardinal = 1;
sv_g_teams             : cardinal = 2;
sv_g_itemrespawn       : cardinal = 4;
sv_g_weaponstay        : cardinal = 8;
sv_g_randommap         : cardinal = 16;
sv_g_teamdamage        : cardinal = 32;
sv_g_voting            : cardinal = 64;
sv_g_recording         : cardinal = 128;
sv_g_screensave        : cardinal = 256;

// network packet IDs
nmid_sv_snapshot       = 100;
nmid_cl_connect        = 105;
nmid_roomsinfo         = 110;
nmid_sv_wrongver       = 115;
nmid_sv_badname        = 116;
nmid_sv_banlist        = 117;
nmid_sv_maplist        = 118;
nmid_sv_wrongroom      = 120;
nmid_sv_serverfull     = 125;
nmid_sv_connected      = 130;
nmid_sv_notconnected   = 135;
nmid_cl_disconnect     = 140;
nmid_cl_datas          = 145;
nmid_cl_datap          = 146;
nmid_cl_chat           = 150;
nmid_cl_command        = 151;
nmid_sv_mappart        = 155;
nmid_cl_maprequest     = 160;
nmid_sv_ping           = 165;
nmid_cl_ping           = 166;
nmid_sv_advertise      = 200;

net_upd_time           : array[false..true] of word = (2,1);  // [fast update]

////  weapons data
// shot type
gpt_bullet             = 0;
gpt_fire               = 1;
gpt_rocket             = 2;
gpt_tesla              = 3;

gpt_fire_speed         = 0.25;
gpt_fire_splashr       = 0;
gpt_rocket_speed       = 0.5;
gpt_rocket_splashr     = 2;

//                                                            knife      ,pistol      ,mp40           ,chain           ,rifle      ,flame          ,panzer        ,tesla
gun_ammot              : array[0..WeaponsN] of integer     = (ammo_knife ,ammo_bullet ,ammo_bullet    ,ammo_bullet     ,ammo_rifle ,ammo_flame     ,ammo_rocket   ,ammo_tesla    ); // ammo type
gun_ammog              : array[0..WeaponsN] of integer     = (0          ,1           ,1              ,1               ,1          ,1              ,1             ,1             ); // ammo num
gun_dist               : array[0..WeaponsN] of single      = (0.5        ,100         ,100            ,100             ,100        ,100            ,100           ,13            ); // distance
gun_disp               : array[0..WeaponsN] of integer     = (0          ,0           ,0              ,10              ,0          ,0              ,0             ,45            ); // dispersion
gun_dmg                : array[0..WeaponsN] of integer     = (50         ,8           ,8              ,8               ,45         ,10             ,90            ,30            ); // base damage
gun_reload             : array[0..WeaponsN] of byte        = (fr_fpsh1   ,fr_fpsh1    ,fr_fpsx1 div 6 ,fr_fpsx1 div 12 ,fr_fpsx1   ,fr_fpsx1 div 12,fr_fpsx1      ,fr_fpsx1 div 2); // reload time
gun_bit                : array[0..WeaponsN] of byte        = (1          ,2           ,4              ,8               ,16         ,32             ,64            ,128           ); // inventory bit
gun_btype              : array[0..WeaponsN] of byte        = (gpt_bullet ,gpt_bullet  ,gpt_bullet     ,gpt_bullet      ,gpt_bullet ,gpt_fire       ,gpt_rocket    ,gpt_tesla     ); // shot type
gun_name               : array[0..WeaponsN] of shortstring = ('knife'    ,'pistol'    ,'mp40'         ,'chaingun'      ,'rifle'    ,'flamethrower' ,'panzerfaust' ,'teslagun'    ); // name

// demo state
ds_none                = 0;
ds_write               = 1;
ds_read                = 2;

////////////////////////////////////////////////////////////////////////////////
//
// common strings/chars


str_report_ext         = '.csv';

str_outlogfn           = 'out.txt';
str_mapfolder          = 'maps'+str_PathSlash;
str_mapext             = '.m3dm';
str_mapext_len         = length(str_mapext);
str_demofolder         = 'demos'+str_PathSlash;
str_demoext            = '.m3dd';

str_mcaption           = 'Multistein 3D';
str_ver                = 'v2.36';
str_wcaption           = str_mcaption+' ('+str_ver+')';

// room cfg common values

rcfg_servername        = 'servername';
rcfg_voteratio         = 'voteratio';
rcfg_roomname          = 'roomname';
rcfg_maxplayers        = 'maxplayers';
rcfg_maxclients        = 'maxclients';
rcfg_timelimit         = 'timelimit';
rcfg_fraglimit         = 'fraglimit';
rcfg_flags             = 'flags';
rcfg_resettime         = 'resettime';
rcfg_deathtime         = 'deathtime';

// commands
cmd_map                = 'map';
cmd_mapnext            = 'mapnext';
cmd_matchend           = 'matchend';
cmd_matchreset         = 'matchreset';
cmd_voteyes            = 'yes';
cmd_voteno             = 'no';
cmd_botadd             = 'botadd';

str_notallowedcmd      = 'unknown command/command not allowed in current game state';

str_pconnected         = ' connected!';
str_pdconnected        = ' disconnected!';
str_ptimeout           = ' time out!';
str_cwin               = ' WIN!';
str_team               = 'team';
str_pjoined            = ' joined the game';
str_pleave             = ' leave to spectators';
str_timelimithit       = 'Timelimit hit!';
str_fraglimithit       = 'Fraglimit hit!';
str_resetmatch         = 'RESET MATCH!';
str_endmatch           = 'END MATCH!';
str_suddendeath        = 'SUDDEN DEATH!';

str_score              = 'score';
str_map                = 'map';
str_nomap              = 'there is map named ';

str_fsplit             = ' > ';
str_suicide            = 'suicide';
str_BotBaseName        = 'BOT';

str_teams              : array[0..MaxTeamsI] of shortstring = ('SS','Mutants','Soldiers','Officers');
str_teams_shorts       : array[0..MaxTeamsI] of shortstring = ('ss','mu'     ,'so'      ,'of'      );


str_demo_Break         = 'demo processing break';
str_demo_BreakPlay     = 'demo: stop play';
str_demo_BreakRecord   = 'demo: stop record';
str_demo_StartRecord   = 'demo: start record';
str_demo_WriteError    = 'ds_write,ioresult=';

////////////////////////////////////////////////////////////////////////////////
//
// NET

net_advertise_port0    = 63123;


{$IFDEF FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
// CLIENT

m_speed_min            = 1;
m_speed_max            = 500;

// client mode
clm_game               = 0;
clm_menu               = 1;
clm_editor             = 2;

// connection state
cstate_none            = 0;
cstate_init            = 1;
cstate_snap            = 2;

console_scroll_speed   = 10;

cl_buffer_xy_n         = fr_fpsh1;

////////////////////////////////////////////////////////////////////////////////
//
// EDITOR

editor_panel_w         = 33;
editor_panel_iw        = editor_panel_w -1;
editor_panel_hw        = editor_panel_w div 2;
editor_panel_wb        = editor_panel_w+1;
editor_panel_wt        = editor_panel_w+3;

editor_icons_n         = 4;

editor_pb_mapload      = 0;
editor_pb_save         = 1;
editor_pb_grid         = 2;
editor_pb_bwalls       = 3;
editor_pb_bdecors      = 4;
editor_pb_bitems       = 5;
editor_pb_bspawns      = 6;
editor_pb_hmove        = 7;
editor_pb_vmove        = 8;
editor_pb_ceil         = 10;
editor_pb_ceil_r       = editor_pb_ceil+1;
editor_pb_ceil_g       = editor_pb_ceil+2;
editor_pb_ceil_b       = editor_pb_ceil+3;
editor_pb_floor        = 14;
editor_pb_floor_r      = editor_pb_floor+1;
editor_pb_floor_g      = editor_pb_floor+2;
editor_pb_floor_b      = editor_pb_floor+3;

editor_grid_step       = 2;
editor_grid_min        = 10;
editor_grid_max        = 64;


////////////////////////////////////////////////////////////////////////////////
//
// MENU

mi_quit                = 1;
mi_inactive            = 2;
mi_connect             = 3;
mi_disconnect          = 4;
mi_serverAddr          = 5;
mi_PlayerName          = 7;
mi_PlayerTeam          = 8;
mi_SoundVolume         = 9;
mi_fullscreen          = 10;
mi_CameraZ             = 11;
mi_MouseSpeed          = 12;
mi_attack              = 13;
mi_forward             = 14;
mi_backward            = 15;
mi_StrafeLeft          = 16;
mi_StrafeRight         = 17;
mi_JoinSpec            = 18;
mi_chat                = 19;
mi_w1                  = 20;
mi_w2                  = 21;
mi_w3                  = 22;
mi_w4                  = 23;
mi_w5                  = 24;
mi_scores              = 25;
mi_screenshot          = 26;
mi_localgame           = 27;
mi_localmap            = 28;
mi_localteams          = 29;
mi_localinsta          = 30;
mi_fraglimit           = 31;
mi_timelimit           = 32;
mi_localbotT1          = 33;
mi_localbotT2          = 34;
mi_localbotT3          = 35;
mi_localbotT4          = 36;
mi_rooms               = 37;
mi_room                = 38;
mi_wnext               = 39;
mi_wprev               = 40;
mi_serverupd           = 41;
mi_inactive2           = 42;
mi_localiresp          = 43;
mi_localwstay          = 44;
mi_inactive3           = 45;
mi_constatus           = 46;
mi_turnleft            = 47;
mi_turnright           = 48;
mi_roomcaption         = 49;
mi_servername          = 50;
mi_serverping          = 51;
mi_logsnext            = 52;
mi_logsprev            = 53;
mi_editor              = 54;
mi_playerwswtch        = 55;
mi_netupd              = 56;
mi_console             = 57;
mi_playerantilag       = 58;
mi_playersmooth        = 59;
mi_chat_sound          = 60;
mi_chat1_str           = 61;
mi_chat1_key           = 62;
mi_chat2_str           = 63;
mi_chat2_key           = 64;
mi_chat3_str           = 65;
mi_chat3_key           = 66;
mi_chat4_str           = 67;
mi_chat4_key           = 68;
mi_chat5_str           = 69;
mi_chat5_key           = 70;
mi_showfps             = 71;
mi_localmapr           = 72;
mi_rCaptionInactive    = 73;
mi_agrp_folder         = 74;
mi_agrp_reload         = 75;
mi_rcresolution        = 76;
mi_localteamd          = 77;
mi_use                 = 78;
mi_playertimer         = 79;
mi_scoresave           = 80;
mi_maxcorpses          = 81;
mi_demoplay            = 82;
mi_demoreset           = 83;
mi_demoupdlist         = 84;
mi_demorecord          = 85;
mi_demos               = 86;
mi_dpause              = 87;
mi_dskipf              = 88;
mi_dskipb              = 89;
mi_votey               = 90;
mi_voten               = 91;
mi_serversrch          = 92;
mi_w6                  = 93;
mi_w7                  = 94;
mi_w8                  = 95;
mi_botskill            = 96;
mi_resolutionw         = 97;
mi_resolutionh         = 98;
mi_resolutiona         = 99;
mi_hudscale            = 100;

mi_caption             = 253;
mi_empty               = 254;

////////////////////////////////////////////////////////////////////////////////
//
// ACTIONS

a_FW                   = 1;
a_BW                   = 2;
a_SL                   = 3;
a_SR                   = 4;
a_TL                   = 5;
a_TR                   = 6;
a_A                    = 7;
a_J                    = 8;
a_T                    = 9;
a_S                    = 10;
a_WN                   = 11;
a_WP                   = 12;
a_W1                   = 13;
a_W2                   = 14;
a_W3                   = 15;
a_W4                   = 16;
a_W5                   = 17;
a_W6                   = 18;
a_W7                   = 19;
a_W8                   = 20;
a_SS                   = 21;
a_LN                   = 22;
a_LP                   = 23;
a_C1                   = 24;
a_C2                   = 25;
a_C3                   = 26;
a_C4                   = 27;
a_C5                   = 28;
a_votey                = 29;
a_voten                = 30;
a_dpause               = 31;
a_dskipf               = 32;
a_dskipb               = 33;
a_US                   = 34;
a_CO                   = 35;

// configurable game keys
cfg_cl_keys            = [a_FW..a_CO];

a_edit_lmb             = 207;
a_edit_rmb             = 208;
a_edit_mmb             = 209;
a_edit_mwheeldown      = 210;
a_edit_mwheelup        = 211;
a_edit_left            = 212;
a_edit_right           = 213;
a_edit_up              = 214;
a_edit_down            = 215;

a_menu                 = 216;
a_mup1                 = 217;
a_mdown1               = 218;
a_mup2                 = 219;
a_mdown2               = 220;
a_mleft                = 221;
a_mright               = 222;
a_menter1              = 223;
a_menter2              = 224;
a_mdel                 = 225;
a_mback                = 226;
a_mpgup                = 227;
a_mpgdn                = 228;
a_mend                 = 229;
a_mhome                = 230;

a_enter                = 249;
a_mrb                  = 250;
a_tab                  = 251;
a_paste                = 252;
a_alt                  = 253;
a_ctrl                 = 254;
a_tremove              = 255;

menu_acts              = [a_menu..a_mhome,a_enter..a_tremove,a_SS];

// key type
kt_keyboard            = 1;
kt_mouseb              = 2;
kt_mousewh             = 3;

// mouse wheel action type
mw_up                  = 1;
mw_down                = 2;

wy2mwkey               : array[false..true] of cardinal = (mw_up,mw_down);

////////////////////////////////////////////////////////////////////////////////
//
// CLIENT GRAPHICS

fr_fpsx60              = fr_fpsx1*60;
fr_fpsh3               = fr_fpsx1 div 3;
vf_fpsx3               = fr_fpsx1*3;

tesla_eff_time         = fr_fpsx1 div 5;

vid_bpp                = 32;              // bits  per pixel
vid_bppb               = vid_bpp div 8;   // bytes per pixel

vid_max_w              = 1024;
vid_max_h              = 768;
vid_min_w              = 640;
vid_min_h              = 400;

vid_max_rw             = vid_max_w;
vid_max_rh             = vid_max_h;
vid_min_rw             = 32;
vid_min_rh             = 20;

hud_gborder_w          = 0;               // border around RC canvas
hud_scale_prsnt_max    = 100;
hud_scale_prsnt_min    = 50;

hud_last_mess_1msg     = fr_fpsx1*2;           // log last message time
hud_last_mess_max      = hud_last_mess_1msg*4; // log last messages count

rc_MaxVisSprites       = 512;
rc_MaxEffects          = 128;
SkinSprites            = 29;

// client effects
eff_ans                = 5;
eff_ant                = eff_ans*4-1;

eff_dans               = 8;
eff_dant               = eff_dans*5-1;

eid_blood              = 0;
eid_puff               = 1;
eid_spawn              = 2;
eid_fire               = 3;
eid_trail              = 4;

// text alignment
ta_left                = 0;
ta_middle              = 1;
ta_right               = 2;

// raycasting
rc_Texture_w           = 512;            // max wall texture resolution
rc_Texture_iw          = rc_Texture_w-1;
rc_SpriteHeight        = 64;

rc_intS                = 13;             // int arithmetic
rc_intI                = 1 shl rc_intS;

menu_font_scale        : single = 1.4;

////////////////////////////////////////////////////////////////////////////////
//
// CLIENT STRINGS/CHARS

str_ScreenShotExt      = '.png';
str_ScreenShotSaved    = ' saved';

str_UnknownKey         = '???';
str_KeyboradUnknown    = 'Key #';
str_MouseLeftButton    = 'Mouse left button';
str_MouseRightButton   = 'Mouse right button';
str_MouseMiddleButton  = 'Mouse middle button';
str_MouseUnknown       = 'Mouse button #';

str_MouseWheelUp       = 'Mouse wheel up';
str_MouseWheelDown     = 'Mouse wheel down';
str_MouseWheelUnknown  = 'Mouse wheel event #';

config_fname           = 'config';

str_sound_dir          = 'sounds'+str_PathSlash;
str_sound_ext          = '.wav';

str_graphic_dir        = 'graphic'+str_PathSlash;

str_meditor            = 'Map editor';
str_mquit              = 'Quit';
str_mdconnect          = 'Disconnect';
str_mnetwork           = 'Multiplayer';
str_msvaddr            = 'Server address';
str_msvupd             = 'Update rooms list';
str_msvslc             = 'Search for local server';
str_mplopt             = 'Player options';
str_mplname            = 'Name';
str_mplteam            = 'Team/skin';
str_mplwsw             = 'Autoswitch to new weapon';
str_mpantilag          = 'Weapon unlag';
str_mpsmooth           = 'Players move interpolation';
str_mptime             = 'Show timer';
str_mpsscores          = 'Scores screenshot';
str_msndopt            = 'Sound options';
str_msndvolume         = 'Volume';
str_msndchat           = 'Chat sound';
str_mvidopt            = 'Video options';
str_mvidrcres          = 'Raycasting resolution';
str_mvidwresw          = 'Window resolution (width)';
str_mvidwresh          = 'Window resolution (height)';
str_mvidwresa          = 'Apply window resolution';
str_mvidfscr           = 'Fullscreen';
str_mvidhudsc          = 'HUD scale(%)';
str_mvidcamh           = 'Camera height';
str_mvidfps            = 'Show FPS';
str_mvidmcorps         = 'Max corpses';
str_mvidagrp           = 'Additional graphics folder';
str_mvidrgrp           = 'Reload graphics';
str_mnetopt            = 'Network options';
str_mnetupd            = 'Network update';
str_mnetupds           : array[false..true] of
                         shortstring =('Every 2nd tick(30/sec)','Every tick(60/sec)');
str_mctropt            = 'Player controls';
str_mctrms             = 'Mouse speed(1-500)';
str_mctrat             = 'Attack/Respawn';
str_mctrmf             = 'Move forward';
str_mctrmb             = 'Move backward';
str_mctrsl             = 'Strafe left';
str_mctrsr             = 'Strafe right';
str_mctrtl             = 'Turn left';
str_mctrtr             = 'Turn right';
str_mctrjs             = 'Join/Spectate';
str_mctrch             = 'Chat';
str_mctrwn             = 'Next weapon';
str_mctrwp             = 'Previous weapon';
str_mctrw1             = 'Knife';
str_mctrw2             = 'Pistol';
str_mctrw3             = 'MP40';
str_mctrw4             = 'Chaingun';
str_mctrw5             = 'Rifle';
str_mctrw6             = 'Flamethrower';
str_mctrw7             = 'Panzerfaust';
str_mctrw8             = 'Teslagun';
str_mctrsc             = 'Show console';
str_mctrlgn            = 'Scroll console down';
str_mctrlgp            = 'Scroll console up';
str_mctrss             = 'Show scores';
str_mctrscr            = 'Screenshot';
str_chat1_str          = 'Chat message 1';
str_chat1_key          = 'Chat message 1 key';
str_chat2_str          = 'Chat message 2';
str_chat2_key          = 'Chat message 2 key';
str_chat3_str          = 'Chat message 3';
str_chat3_key          = 'Chat message 3 key';
str_chat4_str          = 'Chat message 4';
str_chat4_key          = 'Chat message 4 key';
str_chat5_str          = 'Chat message 5';
str_chat5_key          = 'Chat message 5 key';
str_vote_yes           = 'Vote yes';
str_vote_no            = 'Vote no';
str_dcontrol           = 'Demo playback controls';
str_ccontrol           = 'Console controls';
str_dpause             = 'Pause';
str_dskipb             = 'Skip backward';
str_dskipf             = 'Skip forward';

str_localgame          = 'Botmatch';
str_localmatch         : array[false..true] of
                         shortstring =('Start botmatch','Stop botmatch');
str_localmapr          = 'Reload maps';
str_localmap           = 'Map';
str_localteams         = 'Teams';
str_localteamd         = 'Team damage';
str_localinsta         = 'Instagib';
str_localiresp         = 'Item respawn';
str_localwstay         = 'Weapon stay';
str_localfragl         = 'Fraglimit';
str_localtimel         = 'Timelimit';
str_localbskill        = 'Bot skill(1-100)';
str_localbots          = ' bots';
str_constat            = 'Connection status';
str_svname             = 'Server name';
str_svping             = 'Ping';

str_ddemos             = 'Demos';
str_ddemosreq          = 'Record games';
str_ddemosrst          = 'Reset playback';
str_ddemosupd          = 'Update list';

str_screenshot         = 'M3DScrs_';
str_awaitingsrv        = 'Awaiting server...';

str_wversion           = 'Wrong version!';
str_wroom              = 'Wrong room number!';
str_badname            = 'Bad name!';
str_sfull              = 'Room or server is full!';
str_connected          = 'Connected!';
str_nconnected         = 'Not connected!';
str_connecting         = 'Connecting...';
str_mapdownload        = 'Downloading map...';
str_specmode           = 'Spectator mode. ';
str_roomfull           = 'Can`t join: room is full. ';
str_tojoin             = 'To join the game press ';
str_follow_use         = 'Use';
str_follow_cycle       = 'to cycle players';
str_following          = 'Following ';
str_followingk         = 'Following(last killer) ';
str_followingl         = 'Following(leader) ';
str_respawn            = 'To respawn press ';
str_AdvPortError       = 'Cannot use a port (63123) to browse the local server!';
str_DefaultPlayerName  = 'WolfPlayer';
str_NewMapError        = 'Failed to add new map to list!';
str_BanList            = 'Banlist: ';
str_MapList            = 'Maplist';

str_FLAGS_str1         = 'R - items respawn, W - weapon stay, I - instagib';
str_FLAGS_str2         = 'T - teams, M - random map, V - votes enabled';
str_FLAGS_str3         = 'O - record demos, S - save game results';
str_menucontrol1       = 'Menu control keys: arrows, enter, backspace,';
str_menucontrol2       = 'escape, delete, page up, page down, end, home';

str_demo_MenuReset     = 'menu reset';
str_demo_ReadError     = 'ds_read,ioresult=';
str_demo_StartPlay     = 'demo: start play';
str_demo_FileNotExists = 'demo: file don`t exists';
str_demo_WrongVersion  = 'wrong version';
str_demo_PlayerName    = 'Demo observer';
str_demo_End           = 'demo end';
str_demo_WrongData     = 'wrong game data';

str_say                = 'Say: ';

str_sb_resettime       = 'RESET TIME:';
str_sb_roomname        = 'ROOM:';
str_sb_fraglimit       = 'FRAGLIMIT:';
str_sb_timelimit       = 'TIMELIMIT:';
str_sb_players         = 'PLAYERS: ';
str_sb_frags           = 'FRAGS';
str_sb_time            = 'TIME:';
str_sb_ping            = 'PING';
str_sb_name            = 'NAME';
str_sb_map             = 'MAP:';
str_sb_specs           = 'SPECTATORS:';

str_vote               = 'VOTE: ';

b2yn                   : array[boolean] of shortstring = ('NO' ,'YES');

str_camz               : array[boolean] of shortstring = ('old','new');
rc_camz                : array[boolean] of single      = ( 0.5 , 0.7 );

chars_common           : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','!','^','[',']','{','}',' ','_',',','.','(',')','~','<','>','-','+','`','@','#','%','?',':','$',';','\','/','|','*'];
chars_digits           : set of Char = ['0'..'9'];

hudfont                = ['0'..';'];

{$ELSE}

////////////////////////////////////////////////////////////////////////////////
//
// dedicated server

vote_yes               = 2;
vote_no                = 1;

net_advertise_Period   = fr_fpsx1*2;

MaxXYBuffer            = fr_fpsx1;

net_advertise_ip0      = '255.255.255.255';

// strings/chars

str_UDP_port           = ' UDP port: ';

str_rconadmin          = ': rcon access granted!';
str_voteyes            = ': vote yes';
str_voteno             = ': vote no';
str_votealready        = ': another vote already in progress';
str_votecancel         = ': canceled the vote';
str_votecall           = ': called vote for: ';
str_votefailed         = 'server: vote failed for';
str_votepassed         = 'server: vote passed for: ';
str_nospecvote         = 'spectators can`t start a vote';
str_novotes            = 'votes not enabled';

{$ENDIF}
