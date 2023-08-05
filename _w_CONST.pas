

const

DEGTORAD           = pi/180;

ver                = 7;

fr_fps             = 60;
fr_RateTicks       = 1000/fr_fps;
fr_RateTicksI      = round(fr_RateTicks);
fr_2fps            = fr_fps*2;
fr_hfps            = fr_fps div 2;
fr_5fps            = fr_fps*5;

TicksPerMinute     = fr_fps*60;

map_mw             = 64;           // 1-64
map_miw            = map_mw-1;     // 0-63
map_mlw            = map_mw+1;     // 0-65 grid borders
map_pl             = 1.5;
map_pb             = map_mw+0.5;   // 1.5 .. 64.5

MaxPlayers         = 128;
MaxMapBuffer       = map_mw*map_mw+12;
MaxTeams           = 4;
MaxTeamsI          = MaxTeams-1;
MaxNetBuffer       = MaxMapBuffer+12;
MaxRoomLog         = 200;
MaxPlayerTTL       = fr_fps*30;
NetMapParts        = 7;
NetMapPartSize     = (MaxMapBuffer div NetMapParts)+NetMapParts;

PlayerHitSetSize   = (MaxPlayers div 8);

net_advertise_port0= 63123;

AmmoTypesN         = 2; // 0..2
WeaponsN           = 4; // 0..4

NameLen            = 20;
ChatLen            = 200;

// player state
ps_none            = 0;
ps_spec            = 1;
ps_dead            = 2;
ps_walk            = 3;
ps_attk            = 4;
ps_data1           = 5; // demo name data
ps_data2           = 6; // demo ping data
ps_data3           = 7; // demo ping&score data

aid_w1             = 1;
aid_w2             = 2;
aid_w3             = 3;
aid_w4             = 4;
aid_w5             = 5;
aid_wN             = 10;
aid_wP             = 11;
aid_specjoin       = 12;
aid_attack         = 13;

str_outlogfn       = 'out.txt';
str_mapfolder      = 'maps\';
str_mapext         = '.m3dm';
str_mapext_len     = length(str_mapext);
str_demofolder     = 'demos\';
str_demoext        = '.m3dd';

str_mcaption       = 'Multistein 3D';
str_ver            = 'v1.63';
str_wcaption       = str_mcaption+' ('+str_ver+')';

//door_bar_closed    = vid_fps;

mgr_wih            = '?';                // infinity horizon
mgr_door           = '#';
mgr_bwalls         = ['A'..'Z',mgr_wih]; // walls for bullets
mgr_decors         = ['a'..'z'];
mgr_dwalls         = mgr_decors-['a'..'d','v','x','y'];// decorations-walls
mgr_spawns         = ['<','>','^','.','@'];
mgr_items          = ['0'..'9'];


// Players max values
Player_max_hits    = 100;
Player_max_armor   = 100;
Player_max_ammo    : array[0..AmmoTypesN] of integer = (0,250,10 );
Player_max_speed   : array[false..true  ] of single  = (0.115,0.23); // [spectator]
Player_WWidth      : single = 0.25; // collision box for walls
Player_BWidth      : single = 0.35; // collision box for bullets
Player_IWidth      : single = 0.45; // collision box for items

// LOG IDs

log_common         = 1;
log_chat           = 2;
log_endgame        = 3;
log_winner         = 4;
log_map            = 5;
log_local          = 6;
log_roomdata       = 7;

// room cfg common values

rcfg_servername    = 'servername';
rcfg_voteratio     = 'voteratio';
rcfg_roomname      = 'roomname';
rcfg_maxplayers    = 'maxplayers';
rcfg_maxclients    = 'maxclients';
rcfg_timelimit     = 'timelimit';
rcfg_fraglimit     = 'fraglimit';
rcfg_flags         = 'flags';
rcfg_resettime     = 'resettime';
rcfg_deathtime     = 'deathtime';

// commands
cmd_map            = 'map';
cmd_mapnext        = 'mapnext';
cmd_matchend       = 'matchend';
cmd_matchreset     = 'matchreset';
cmd_voteyes        = 'yes';
cmd_voteno         = 'no';


// game mode flags
sv_g_instagib      : cardinal = %000000001;
sv_g_teams         : cardinal = %000000010;
sv_g_itemrespawn   : cardinal = %000000100;
sv_g_weaponstay    : cardinal = %000001000;
sv_g_randommap     : cardinal = %000010000;
sv_g_teamdamage    : cardinal = %000100000;
sv_g_voting        : cardinal = %001000000;
sv_g_recording     : cardinal = %010000000;
sv_g_screensave    : cardinal = %100000000;

// network packet IDs
nmid_sv_snapshot    = 100;
nmid_cl_connect     = 105;
nmid_roomsinfo      = 110;
nmid_sv_wrongver    = 115;
nmid_sv_badname     = 116;
nmid_sv_banlist     = 117;
nmid_sv_maplist     = 118;
nmid_sv_wrongroom   = 120;
nmid_sv_serverfull  = 125;
nmid_sv_connected   = 130;
nmid_sv_notconnected= 135;
nmid_cl_disconnect  = 140;
nmid_cl_datas       = 145;
nmid_cl_datap       = 146;
nmid_cl_chat        = 150;
nmid_cl_cmd         = 151;
nmid_sv_mappart     = 155;
nmid_cl_maprequest  = 160;
nmid_sv_ping        = 165;
nmid_cl_ping        = 166;
nmid_sv_advertise   = 200;

net_upd_time        : array[false..true] of word = (2,1);


str_pconnected     = ' connected!';
str_pdconnected    = ' disconnected!';
str_ptimeout       = ' time out!';
str_cwin           = ' WIN!';
str_team           = 'team';
str_pjoined        = ' joined the game';
str_pleave         = ' leave to spectators';
str_timelimithit   = 'Timelimit hit!';
str_fraglimithit   = 'Fraglimit hit!';
str_resetmatch     = 'RESET MATCH!';
str_endmatch       = 'END MATCH!';
str_suddendeath    = 'SUDDEN DEATH!';

str_teams          : array[0..MaxTeamsI] of shortstring = ('SS','Mutants','Soldiers','Officers');
str_teams_shorts   : array[0..MaxTeamsI] of shortstring = ('ss','mu'     ,'so'      ,'of'      );

gpt_bullet         = 0;
//gpt_fire           = 1;
//gpt_rocket         = 2;

//                                                        knife     ,pistol    ,mp40         ,chain         ,rifle
gun_ammot          : array[0..WeaponsN] of integer     = (0         ,1         ,1            ,1             ,2         ); // ammo type
gun_ammog          : array[0..WeaponsN] of integer     = (0         ,1         ,1            ,1             ,1         ); // ammo num
gun_dist           : array[0..WeaponsN] of single      = (0.5       ,100       ,100          ,100           ,100       ); // distance
gun_disp           : array[0..WeaponsN] of integer     = (0         ,0         ,0            ,10            ,0         ); // dispersion
gun_dmg            : array[0..WeaponsN] of integer     = (50        ,8         ,8            ,8             ,45        ); // reload time
gun_reload         : array[0..WeaponsN] of byte        = (fr_hfps   ,fr_hfps   ,fr_fps div 6 ,fr_fps div 12 ,fr_fps    ); //
gun_str            : array[0..WeaponsN] of shortstring = ('knife'   ,'pistol'  ,'mp40'       ,'chaingun'    ,'rifle'   );
gun_bit            : array[0..WeaponsN] of byte        = (%00000001 ,%00000010 ,%00000100    ,%00001000     ,%00010000 ); // inventory bit
gun_btype          : array[0..WeaponsN] of byte        = (gpt_bullet,gpt_bullet,gpt_bullet   ,gpt_bullet    ,gpt_bullet); // projectille type

ds_none            = 0;
ds_write           = 1;
ds_read            = 2;

{$IFDEF FULLGAME}

// game mode
gm_game            = 0;
gm_menu            = 1;
gm_editor          = 2;

// connection state
cstate_none        = 0;
cstate_init        = 1;
cstate_snap        = 2;

// menu items
mi_quit            = 1;
mi_inactive        = 2;
mi_connect         = 3;
mi_disconnect      = 4;
mi_serverip        = 5;
mi_serverport      = 6;
mi_playername      = 7;
mi_playerteam      = 8;
mi_soundvolume     = 9;
mi_fullscreen      = 10;
mi_cameraz         = 11;
mi_mousespeed      = 12;
mi_attack          = 13;
mi_forward         = 14;
mi_backward        = 15;
mi_strafeleft      = 16;
mi_straferight     = 17;
mi_joinspec        = 18;
mi_chat            = 19;
mi_w1              = 20;
mi_w2              = 21;
mi_w3              = 22;
mi_w4              = 23;
mi_w5              = 24;
mi_scores          = 25;
mi_screenshot      = 26;
mi_localgame       = 27;
mi_localmap        = 28;
mi_localteams      = 29;
mi_localinsta      = 30;
mi_fraglimit       = 31;
mi_timelimit       = 32;
mi_localbott1      = 33;
mi_localbott2      = 34;
mi_localbott3      = 35;
mi_localbott4      = 36;
mi_rooms           = 37;
mi_room            = 38;
mi_wnext           = 39;
mi_wprev           = 40;
mi_serverupd       = 41;
mi_inactive2       = 42;
mi_localiresp      = 43;
mi_localwstay      = 44;
mi_inactive3       = 45;
mi_constatus       = 46;
mi_turnleft        = 47;
mi_turnright       = 48;
mi_roomcaption     = 49;
mi_servername      = 50;
mi_serverping      = 51;
mi_logsnext        = 52;
mi_logsprev        = 53;
mi_editor          = 54;
mi_playerwswtch    = 55;
mi_netupd          = 56;
mi_console         = 57;
mi_playerantilag   = 58;
mi_playersmooth    = 59;
mi_chat_sound      = 60;
mi_chat1_str       = 61;
mi_chat1_key       = 62;
mi_chat2_str       = 63;
mi_chat2_key       = 64;
mi_chat3_str       = 65;
mi_chat3_key       = 66;
mi_chat4_str       = 67;
mi_chat4_key       = 68;
mi_chat5_str       = 69;
mi_chat5_key       = 70;
mi_showfps         = 71;
mi_localmapr       = 72;
mi_rcaptioninactive= 73;
mi_agrp_folder     = 74;
mi_agrp_reload     = 75;
mi_resolution      = 76;
mi_localteamd      = 77;
mi_use             = 78;
mi_playertimer     = 79;
mi_scoresave       = 80;
mi_maxcorpses      = 81;
mi_demoplay        = 82;
mi_demoreset       = 83;
mi_demoupdlist     = 84;
mi_demorecord      = 85;
mi_demos           = 86;
mi_dpause          = 87;
mi_dskipf          = 88;
mi_dskipb          = 89;
mi_votey           = 90;
mi_voten           = 91;
mi_serversrch      = 92;

mi_caption         = 253;
mi_empty           = 254;


// game actions
a_FW               = 1;
a_BW               = 2;
a_SL               = 3;
a_SR               = 4;
a_TL               = 5;
a_TR               = 6;
a_A                = 7;
a_J                = 8;
a_T                = 9;
a_S                = 10;
a_WN               = 11;
a_WP               = 12;
a_W1               = 13;
a_W2               = 14;
a_W3               = 15;
a_W4               = 16;
a_W5               = 17;
a_SS               = 18;
a_LN               = 19;
a_LP               = 20;
a_C1               = 21;
a_C2               = 22;
a_C3               = 23;
a_C4               = 24;
a_C5               = 25;
a_votey            = 26;
a_voten            = 27;
a_dpause           = 28;
a_dskipf           = 29;
a_dskipb           = 30;
a_US               = 31;
a_CO               = 32;


cfg_cl_keys = [a_FW..a_CO];

a_menu             = 216;
a_mup1             = 217;
a_mdown1           = 218;
a_mup2             = 219;
a_mdown2           = 220;
a_mleft            = 221;
a_mright           = 222;
a_menter1          = 223;
a_menter2          = 224;
a_mdel             = 225;
a_mback            = 226;
a_mpgup            = 227;
a_mpgdn            = 228;
a_mend             = 229;
a_mhome            = 230;

a_enter            = 249;
a_mrb              = 250;
a_tab              = 251;
a_paste            = 252;
a_alt              = 253;
a_ctrl             = 254;
a_tremove          = 255;

menu_acts          = [a_menu..a_mhome,a_enter..a_tremove,a_SS];

// graphic constants
vid_60fps          = fr_fps*60;
vid_3hfps          = fr_fps div 3;
vid_3fps           = fr_fps*3;

cl_buffer_n        = fr_hfps;

vid_bpp            = 32;
vid_bppb           = vid_bpp div 8;

vid_log_w          = 800;
vid_log_h          = 600;
vid_log_hw         = vid_log_w div 2;
vid_log_hh         = vid_log_h div 2;
vid_msg_x          = vid_log_w div 2;
vid_msg_y          = vid_log_h div 2;
vid_vote_x         = vid_log_w div 2;
vid_vote_y         = vid_log_h div 6;

hud_gborder_w      = 0;


hud_last_mess_1msg = fr_fps*2;
hud_last_mess_max  = hud_last_mess_1msg*4;

MaxVisSprites      = 255;
SkinSprites        = 29;

eff_ans            = 5;
eff_ant            = eff_ans*4-1;

eff_dans           = 8;
eff_dant           = eff_dans*5-1;

eid_blood          = 0;
eid_puff           = 1;
eid_spawn          = 2;

ta_left            = 0;
ta_middle          = 1;
ta_right           = 2;

rc_tex_w           = 512;
rc_tex_iw          = rc_tex_w-1;
rc_intS            = 13;
rc_intI            = 1 shl rc_intS;

rc_spr_w           = 64;
rc_spr_iw          = rc_spr_w-1;

menu_font_scale    : single = 1.4;

cfgfn              = 'cfg';

str_sound_dir      ='sounds\';
str_sound_ext      ='.wav';

str_graphic_dir    ='graphic\';

{--}str_mquit      ='Quit';
{--}str_mdconnect  ='Disconnect';
{--}str_mnetwork   ='Multiplayer';
    str_msvip      ='Server ip';
    str_msvport    ='Server port';
    str_msvupd     ='Update rooms list';
    str_msvslc     ='Search for local server';
{--}str_mplopt     ='Player options';
    str_mplname    ='Name';
    str_mplteam    ='Team';
    str_mplwsw     ='Autoswitch to new weapon';
    str_mpantilag  ='Weapon unlag';
    str_mpsmooth   ='Players move interpolation';
    str_mptime     ='Show timer';
    str_mpsscores  ='Scores screenshot';
{--}str_msndopt    ='Sound options';
    str_msndvolume ='Volume';
    str_msndchat   ='Chat sound';
{--}str_mvidopt    ='Video options';
    str_mvidres    ='Raycasting resolution';
    str_mvidfscr   ='Fullscreen';
    str_mvidcamh   ='Camera height';
    str_mvidfps    ='Show FPS';
    str_mvidmcorps ='Max corpses';
    str_mvidagrp   ='Additional graphics folder';
    str_mvidrgrp   ='Reload graphics';
{--}str_mnetopt    ='Network options';
    str_mnetupd    ='Network update';
    str_mnetupds   : array[false..true] of
                     shortstring =('Every 2nd tick(30/sec)','Every tick(60/sec)');
{--}str_mctropt    ='Controls';
    str_mctrms     ='Mouse speed';
    str_mctrat     ='Attack/Respawn';
    str_mctrmf     ='Move forward';
    str_mctrmb     ='Move backward';
    str_mctrsl     ='Strafe left';
    str_mctrsr     ='Strafe right';
    str_mctrtl     ='Turn left';
    str_mctrtr     ='Turn right';
    str_mctrjs     ='Join/Spectate';
    str_mctrch     ='Chat';
    str_mctrwn     ='Next weapon';
    str_mctrwp     ='Previous weapon';
    str_mctrw1     ='Knife';
    str_mctrw2     ='Pistol';
    str_mctrw3     ='MP40';
    str_mctrw4     ='Chaingun';
    str_mctrw5     ='Rifle';
    str_mctrsc     ='Show console';
    str_mctrlgn    ='Scroll console down';
    str_mctrlgp    ='Scroll console up';
    str_mctrss     ='Show scores';
    str_mctrscr    ='Screenshot';
    str_chat1_str  ='Chat message 1';
    str_chat1_key  ='Chat message 1 key';
    str_chat2_str  ='Chat message 2';
    str_chat2_key  ='Chat message 2 key';
    str_chat3_str  ='Chat message 3';
    str_chat3_key  ='Chat message 3 key';
    str_chat4_str  ='Chat message 4';
    str_chat4_key  ='Chat message 4 key';
    str_chat5_str  ='Chat message 5';
    str_chat5_key  ='Chat message 5 key';
    str_vote_yes   ='Vote yes';
    str_vote_no    ='Vote no';
    str_dcontrol   ='Demo playback controls';
    str_dpause     ='Pause';
    str_dskipb     ='Skip backward';
    str_dskipf     ='Skip forward';

{--}str_localgame  ='Botmatch';
    str_localmatch : array[false..true] of
                     shortstring =('Start botmatch',
                                   'Stop botmatch');
    str_localmapr  ='Reload maps';
    str_localmap   ='Map';
    str_localteams ='Teams';
    str_localteamd ='Team damage';
    str_localinsta ='Instagib';
    str_localiresp ='Item respawn';
    str_localwstay ='Weapon stay';
    str_localfragl ='Fraglimit';
    str_localtimel ='Timelimit';
    str_localbots  =' bots';
    str_constat    ='Connection status';
    str_svname     ='Server name';
    str_svping     ='Ping';

{--}str_ddemos     ='Demos';
    str_ddemosreq  ='Record games';
    str_ddemosrst  ='Reset playback';
    str_ddemosupd  ='Update list';

    str_screenshot ='M3DScrs_';
    str_awaitingsrv='Awaiting server...';

    str_wversion   ='Wrong version!';
    str_wroom      ='Wrong room number!';
    str_badname    ='Bad name!';
    str_sfull      ='Room or server is full!';
    str_connected  ='Connected!';
    str_nconnected ='Not connected!';
    str_connecting ='Connecting...';
    str_mapdownload='Downloading map...';
    str_specmode   ='Spectator mode. ';
    str_roomfull   ='Can`t join: room is full. ';
    str_tojoin     ='To join the game press ';
    str_following  ='Following ';
    str_respawn    ='To respawn press ';
    str_AdvPortError= 'Cannot use a port (63123) to browse the local server!';

    str_FLAGS_str1    = 'R - items respawn, W - weapon stay, I - instagib';
    str_FLAGS_str2    = 'T - teams, M - random map, V - votes enabled';
    str_FLAGS_str3    = 'O - record demos, S - save game results';
    str_menucontrol1  = 'Menu control keys: arrows, enter, backspace,';
    str_menucontrol2  = 'escape, delete, page up, page down, end, home';

    str_say           ='Say: ';

    str_sb_resettime  = 'RESET TIME:';
    str_sb_roomname   = 'ROOM:';
    str_sb_fraglimit  = 'FRAGLIMIT:';
    str_sb_timelimit  = 'TIMELIMIT:';
    str_sb_players    = 'PLAYERS: ';
    str_sb_frags      = 'FRAGS';
    str_sb_time       = 'TIME:';
    str_sb_ping       = 'PING';
    str_sb_name       = 'NAME';
    str_sb_map        = 'MAP:';
    str_sb_specs      = 'SPECTATORS:';

    str_vote          = 'VOTE: ';

b2yn               : array[boolean] of shortstring = ('NO' ,'YES');

str_camz           : array[boolean] of shortstring = ('old','new');
rc_camz            : array[boolean] of single      = ( 0.5 , 0.7 );

chars_common       : set of Char = [#192..#255,'A'..'Z','a'..'z','0'..'9','"','!','^','[',']','{','}',' ','_',',','.','(',')','~','<','>','-','+','`','@','#','%','?',':','$',';','\','/','|','*'];
chars_digits       : set of Char = ['0'..'9'];
chars_addr         : set of Char = ['0'..'9','.'];

hudfont            = ['0'..';'];

kt_keyboard        = 1;
kt_mouseb          = 2;
kt_mousewh         = 3;

mw_up              = 1;
mw_down            = 2;

wy2mwkey           : array[false..true] of cardinal = (mw_up,mw_down);

{$ELSE}

vote_yes           = 2;
vote_no            = 1;

net_advertise_Period=fr_fps*2;

MaxXYBuffer        = fr_fps;
str_rconadmin      = ': rcon access granted!';
str_voteyes        = ': vote yes';
str_voteno         = ': vote no';
str_votealready    = ': another vote already in progress';
str_votecancel     = ': canceled the vote';
str_votecall       = ': called vote for: ';
str_votefailed     = 'server: vote failed for';
str_votepassed     = 'server: vote passed for: ';
str_nospecvote     = 'spectators can`t start a vote';
str_novotes        = 'votes not enabled';

{$ENDIF}
