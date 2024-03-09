

procedure ReMakeMenu;
procedure MenuAddLine(t:byte;s,v:shortstring);
var i:integer;
begin
   i:=menu_num;
   menu_num+=1;
   SetLength(menu_txtL,menu_num);
   SetLength(menu_txtR,menu_num);
   SetLength(menu_txtT,menu_num);
   menu_txtL[i]:=s;
   menu_txtR[i]:=v;
   menu_txtT[i]:=t;
end;
function zc(a1:byte;b:boolean):byte;begin if(b)then zc:=mi_inactive  else zc:=a1;end;
function zi(a1:byte;b:boolean):byte;begin if(b)then zi:=mi_inactive2 else zi:=a1;end;
function zr(a1:byte;b:boolean):byte;begin if(b)then zr:=mi_inactive3 else zr:=a1;end;

procedure MenuRoomsInfoLines;
const sb       : shortstring = '                                                       ';
      ric_num  : shortstring = '#';
      ric_name : shortstring = 'NAME';
      ric_map  : shortstring = 'MAP';
      ric_cl   : shortstring = 'CLIENTS';
      ric_pl   : shortstring = 'PLAYERS';
      ric_flags: shortstring = 'FLAGS';
      sbn_num  = 2;
      sbn_name = 16;
      sbn_map  = 9;
      sbn_cl   = 7;
      sbn_pl   = 7;
      sbn_flags= 8;
      sbi_num  = 1;
      sbi_name = sbi_num +sbn_num +1;
      sbi_map  = sbi_name+sbn_name+1;
      sbi_cl   = sbi_map +sbn_map +1;
      sbi_pl   = sbi_cl  +sbn_cl  +1;
      sbi_flags= sbi_pl  +sbn_pl  +1;
var sr:shortstring;
     r:integer;
begin
   if(sv_roomsinfo_n=0)then exit;
   sr:=sb;
   setchars1(@sr,sbi_num  ,sbn_num  ,@ric_num  );
   setchars1(@sr,sbi_name ,sbn_name ,@ric_name );
   setchars1(@sr,sbi_map  ,sbn_map  ,@ric_map  );
   setchars1(@sr,sbi_cl   ,sbn_cl   ,@ric_cl   );
   setchars1(@sr,sbi_pl   ,sbn_pl   ,@ric_pl   );
   setchars1(@sr,sbi_flags,sbn_flags,@ric_flags);

   MenuAddLine(mi_rCaptionInactive,'',str_FLAGS_str1);
   MenuAddLine(mi_rCaptionInactive,'',str_FLAGS_str2);
   MenuAddLine(mi_rCaptionInactive,'',str_FLAGS_str3);
   MenuAddLine(mi_roomcaption     ,sr,'');
   menu_roomi:=menu_num;
   for r:=0 to sv_roomsinfo_n-1 do
    with sv_roomsinfo[r] do
    begin
       sr:=sb;
       setchars2(@sr,sbi_num  ,sbn_num  ,i2s(r+1)  );
       setchars1(@sr,sbi_name ,sbn_name ,@rname    );
       setchars1(@sr,sbi_map  ,sbn_map  ,@mname    );
       setchars2(@sr,sbi_cl   ,sbn_cl   ,i2s(cur_clients)+'/'+i2s(max_clients));
       setchars2(@sr,sbi_pl   ,sbn_pl   ,i2s(cur_players)+'/'+i2s(max_players));
       setchars2(@sr,sbi_flags,sbn_flags,RFlags2Str(g_flags));

       if(r=cl_net_roomi)
       then MenuAddLine(mi_rooms,sr,'')
       else MenuAddLine(mi_room ,sr,'');
    end;
end;
procedure MenuDemoListLines;
const ric_name = 'NAME';
      ric_size = 'SIZE';
var d:word;
begin
   if(demos_n=0)then exit;
   MenuAddLine(mi_roomcaption,ric_name,ric_size);
   menu_demoi:=menu_num;
   for d:=0 to demos_n-1 do
     if(demos_l[d]=sv_clroom^.demo_fname)
     then MenuAddLine(mi_demos   ,demos_l[d],demos_s[d])
     else MenuAddLine(mi_demoplay,demos_l[d],demos_s[d]);
end;

function ps(orig:shortstring):shortstring;
var i:byte;
begin
   ps:=orig;
   if(length(orig)>0)then
    for i:=1 to length(orig) do
     ps[i]:='*';
end;

begin
   SetLength(menu_txtL,0);
   SetLength(menu_txtR,0);
   SetLength(menu_txtT,0);
   menu_num  :=0;
   menu_roomi:=-1;
   menu_demoi:=-1;
//               menu item                        left/middle string            right string
{-}  MenuAddLine(mi_caption                      ,str_mnetwork                 ,''                     );  //-- Network
     MenuAddLine(zi(mi_serversrch,
     (net_socket_port<>net_advertise_port0))     ,str_msvslc                   ,b2yn[net_SearchLocalSV]);
     MenuAddLine(mi_serverIP                     ,str_msvip                    ,cl_net_svips           );
     MenuAddLine(mi_ServerPort                   ,str_msvport                  ,cl_net_svps            );
     MenuAddLine(mi_serverupd                    ,str_msvupd                   ,''                     );
     MenuAddLine(mi_servername                   ,str_svname                   ,sv_name                );
     MenuAddLine(mi_serverping                   ,str_svping                   ,sv_ping_str            );
     MenuAddLine(zr(mi_disconnect                ,
                 cl_net_cstat=0)                 ,str_mdconnect                ,''                     );
     MenuAddLine(mi_constatus                    ,str_constat                  ,cl_net_stat            );
     MenuRoomsInfoLines;
     MenuAddLine(mi_empty                        ,''                           ,''                     );

{-}  MenuAddLine(mi_caption                      ,str_localgame                ,''                     );  //-- Local game
     MenuAddLine(mi_localgame                    ,str_localmatch[menu_locmatch],''                     );
     MenuAddLine(mi_localmapr                    ,str_localmapr                ,''                     );  // reload maps
     MenuAddLine(zi(mi_localmap   ,menu_locmatch),str_localmap                 ,g_maps[menu_bmm].mname );  // map
     MenuAddLine(zi(mi_localteams ,menu_locmatch),str_localteams               ,b2yn[menu_lteams]      );
     MenuAddLine(zi(mi_localteamd ,menu_locmatch
                            or not menu_lteams  ),str_localteamd               ,b2yn[menu_lteamd]      );
     MenuAddLine(zi(mi_localinsta ,menu_locmatch),str_localinsta               ,b2yn[menu_linsta]      );
     MenuAddLine(zi(mi_localiresp ,menu_locmatch
                              or   menu_linsta  ),str_localiresp               ,b2yn[menu_itresp]      );
   if(menu_itresp)
then MenuAddLine(zi(mi_localwstay ,menu_locmatch
                              or   menu_linsta  ),str_localwstay               ,b2yn[menu_wstay ]      )
else MenuAddLine(zi(mi_localwstay ,true         ),str_localwstay               ,b2yn[true       ]      );
     MenuAddLine(zi(mi_fraglimit  ,menu_locmatch),str_localfragl               ,i2s(menu_lslimit)      );
     MenuAddLine(zi(mi_timelimit  ,menu_locmatch),str_localtimel               ,i2s(menu_ltlimit)      );
     MenuAddLine(zi(mi_localbotT1 ,menu_locmatch),str_teams[0]+str_localbots   ,i2s(menu_lbots[0])     );
     MenuAddLine(zi(mi_localbotT2 ,menu_locmatch),str_teams[1]+str_localbots   ,i2s(menu_lbots[1])     );
     MenuAddLine(zi(mi_localbotT3 ,menu_locmatch),str_teams[2]+str_localbots   ,i2s(menu_lbots[2])     );
     MenuAddLine(zi(mi_localbotT4 ,menu_locmatch),str_teams[3]+str_localbots   ,i2s(menu_lbots[3])     );
     MenuAddLine(zi(mi_empty      ,menu_locmatch),''                           ,''                     );

{-}  MenuAddLine(mi_caption                      ,str_mplopt                   ,''                     );  //-- Player options
     MenuAddLine(mi_PlayerName                   ,str_mplname                  ,player_name            );
     MenuAddLine(mi_PlayerTeam                   ,str_mplteam                  ,str_teams[player_team] );
     MenuAddLine(mi_playerwswtch                 ,str_mplwsw                   ,b2yn[player_wswitch  ] );
     MenuAddLine(mi_playerantilag                ,str_mpantilag                ,b2yn[player_antilag  ] );
     MenuAddLine(mi_playersmooth                 ,str_mpsmooth                 ,b2yn[player_smooth   ] );
     MenuAddLine(mi_playertimer                  ,str_mptime                   ,b2yn[player_showtime ] );
     MenuAddLine(mi_scoresave                    ,str_mpsscores                ,b2yn[scores_save     ] );

     MenuAddLine(mi_empty                        ,''                           ,''                     );

{-}  MenuAddLine(mi_caption                      ,str_msndopt                  ,''                     );  //-- Sound options
     MenuAddLine(mi_SoundVolume                  ,str_msndvolume               ,b2s(snd_volume)        );
     MenuAddLine(mi_chat_sound                   ,str_msndchat                 ,b2yn[player_chat_snd]  );
     MenuAddLine(mi_empty                        ,''                           ,''                     );

{-}  MenuAddLine(mi_caption                      ,str_mvidopt                  ,''                     ); //-- Video options
     MenuAddLine(mi_resolution                   ,str_mvidres                  ,i2s(vid_rw)+'x'+i2s(vid_rh));
     MenuAddLine(mi_fullscreen                   ,str_mvidfscr                 ,b2yn[vid_fullscreen]   );
     MenuAddLine(mi_CameraZ                      ,str_mvidcamh                 ,str_camz[vid_rc_newz]  );
     MenuAddLine(mi_showfps                      ,str_mvidfps                  ,b2yn[player_showfps]   );
     MenuAddLine(mi_maxcorpses                   ,str_mvidmcorps               ,i2s(player_maxcorpses+1));
     MenuAddLine(mi_agrp_folder                  ,str_mvidagrp                 ,vid_agraph_dir_l[vid_agraph_dir_sel]);
     MenuAddLine(mi_agrp_reload                  ,str_mvidrgrp                 ,'');
     MenuAddLine(mi_empty                        ,''                           ,'');

{-}  MenuAddLine(mi_caption                      ,str_mnetopt                  ,'');                   //-- Network options
     MenuAddLine(mi_netupd                       ,str_mnetupd                  ,str_mnetupds[player_netupd]);
     MenuAddLine(mi_empty                        ,''                           ,'');

{-}  MenuAddLine(mi_caption                      ,str_mctropt                  ,'');                   //-- Controls
     MenuAddLine(mi_MouseSpeed                   ,str_mctrms                   ,i2s(m_speed));         // mouse speed
     MenuAddLine(mi_attack                       ,str_mctrat                   ,GetKeyName(a_A ));     // attack
     MenuAddLine(mi_forward                      ,str_mctrmf                   ,GetKeyName(a_FW));     // forward
     MenuAddLine(mi_backward                     ,str_mctrmb                   ,GetKeyName(a_BW));     // backward
     MenuAddLine(mi_StrafeLeft                   ,str_mctrsl                   ,GetKeyName(a_SL));     // strafe left
     MenuAddLine(mi_StrafeRight                  ,str_mctrsr                   ,GetKeyName(a_SR));     // strafe right
     MenuAddLine(mi_turnleft                     ,str_mctrtl                   ,GetKeyName(a_TL));     // turn left
     MenuAddLine(mi_turnright                    ,str_mctrtr                   ,GetKeyName(a_TR));     // turn right
     MenuAddLine(mi_JoinSpec                     ,str_mctrjs                   ,GetKeyName(a_J ));     // spectate / join
     MenuAddLine(mi_chat                         ,str_mctrch                   ,GetKeyName(a_T ));     // chat
     MenuAddLine(mi_wnext                        ,str_mctrwn                   ,GetKeyName(a_WN));     // weapon next
     MenuAddLine(mi_wprev                        ,str_mctrwp                   ,GetKeyName(a_WP));     // weapon previous
     MenuAddLine(mi_w1                           ,str_mctrw1                   ,GetKeyName(a_w1));     // knife
     MenuAddLine(mi_w2                           ,str_mctrw2                   ,GetKeyName(a_w2));     // pistol
     MenuAddLine(mi_w3                           ,str_mctrw3                   ,GetKeyName(a_w3));     // mp40
     MenuAddLine(mi_w4                           ,str_mctrw4                   ,GetKeyName(a_w4));     // chaingun
     MenuAddLine(mi_w5                           ,str_mctrw5                   ,GetKeyName(a_w5));     // rifle
     MenuAddLine(mi_w6                           ,str_mctrw6                   ,GetKeyName(a_w6));     // Flamethrower
     MenuAddLine(mi_w7                           ,str_mctrw7                   ,GetKeyName(a_w7));     // Panzerfaust
     MenuAddLine(mi_w8                           ,str_mctrw8                   ,GetKeyName(a_w8));     // Teslagun
     MenuAddLine(mi_scores                       ,str_mctrss                   ,GetKeyName(a_S ));     // show scores
     MenuAddLine(mi_screenshot                   ,str_mctrscr                  ,GetKeyName(a_SS));     // screenshot
     MenuAddLine(mi_chat1_str                    ,str_chat1_str                ,player_chat1    );     // chat message 1
     MenuAddLine(mi_chat1_key                    ,str_chat1_key                ,GetKeyName(a_C1));     // chat message 1
     MenuAddLine(mi_chat2_str                    ,str_chat2_str                ,player_chat2    );     // chat message 2
     MenuAddLine(mi_chat2_key                    ,str_chat2_key                ,GetKeyName(a_C2));     // chat message 2
     MenuAddLine(mi_chat3_str                    ,str_chat3_str                ,player_chat3    );     // chat message 3
     MenuAddLine(mi_chat3_key                    ,str_chat3_key                ,GetKeyName(a_C3));     // chat message 3
     MenuAddLine(mi_chat4_str                    ,str_chat4_str                ,player_chat4    );     // chat message 4
     MenuAddLine(mi_chat4_key                    ,str_chat4_key                ,GetKeyName(a_C4));     // chat message 4
     MenuAddLine(mi_chat5_str                    ,str_chat5_str                ,player_chat5    );     // chat message 5
     MenuAddLine(mi_chat5_key                    ,str_chat5_key                ,GetKeyName(a_C5));     // chat message 5
     MenuAddLine(mi_votey                        ,str_vote_yes                 ,GetKeyName(a_votey));  // chat message 5
     MenuAddLine(mi_voten                        ,str_vote_no                  ,GetKeyName(a_voten));  // chat message 5
     MenuAddLine(mi_console                      ,str_mctrsc                   ,GetKeyName(a_CO));     // console
     MenuAddLine(mi_logsnext                     ,str_mctrlgn                  ,GetKeyName(a_LN));     // console next
     MenuAddLine(mi_logsprev                     ,str_mctrlgp                  ,GetKeyName(a_LP));     // console previous

     MenuAddLine(mi_caption                      ,str_dcontrol                 ,'');                   //-- Demo playback controls
     MenuAddLine(mi_dpause                       ,str_dpause                   ,GetKeyName(a_dpause)); // demo pause
     MenuAddLine(mi_dskipb                       ,str_dskipb                   ,GetKeyName(a_dskipb)); // demo backward
     MenuAddLine(mi_dskipf                       ,str_dskipf                   ,GetKeyName(a_dskipf)); // demo forward

{-}  MenuAddLine(mi_empty                        ,''                           ,'');
     MenuAddLine(mi_caption                      ,str_ddemos                   ,'');                   //-- Demos
     MenuAddLine(mi_demorecord                   ,str_ddemosreq                ,b2yn[demo_record]);    // record games
     MenuAddLine(zc(mi_demoreset,
                 sv_clroom^.demo_cstate<>ds_read),str_ddemosrst                ,'');                   // demo playback reset
     MenuAddLine(mi_demoupdlist                  ,str_ddemosupd                ,'');
     MenuDemoListLines;

     MenuAddLine(mi_empty                        ,''                           ,'');
     MenuAddLine(zr(mi_editor,
           (cl_net_cstat<>0)or menu_locmatch)     ,str_meditor                  ,'');                   //-- Editor
{-}  MenuAddLine(mi_empty                        ,''                           ,'');
     MenuAddLine(mi_quit                         ,str_mquit                    ,'');                   //-- Quit
end;

procedure MenuMapRoll(next:boolean);
begin
   if(g_mapn>0)then
     case next of
   true : begin menu_bmm+=1;if(menu_bmm>=g_mapn)then menu_bmm:=0;end;
   false: if(menu_bmm=0)then menu_bmm:=g_mapn-1 else menu_bmm-=1;
     end;
end;

procedure menu_sel(step:integer);
var pms,s:integer;
begin
   if(step=0)then exit;

   pms:=menu_s;
   s  :=sign(step);
   while true do
   begin
      menu_s+=s;

      if(menu_s< 0       )then begin menu_s:=0;         break;end;
      if(menu_s>=menu_num)then begin menu_s:=menu_num-1;break;end;

      if not(menu_txtT[menu_s] in [mi_caption,mi_empty,0,mi_roomcaption,mi_inactive3,mi_constatus,mi_servername,mi_serverping,mi_rCaptionInactive])then
      begin
         pms:=menu_s;
         step-=s;
      end;

      if(step=0)then break;
   end;
   menu_s:=pms;

   if(menu_s-menu_scrol)>menu_inscr then menu_scrol:=menu_s-menu_inscr;
   if(menu_s-menu_scrol)<0          then menu_scrol:=menu_s;

   PlaySoundGlobal(snd_mmove);
end;


procedure menu_action(s:integer); // 2-enter, 1-right, -1-left
procedure _in(i:pinteger ;step,min,max:integer );begin i^+=step;i^:=mm3i(min,i^,max);end;
procedure _bn(b:pbyte;step:integer;min,max:byte);
begin
   b^:=byte(mm3i(min,b^+step,max));
end;
begin
   case menu_txtT[menu_s] of
    mi_quit         : if(s=2)then sys_cycle:=false;
    mi_editor       : cl_mode:=clm_editor;
    mi_fullscreen   : ScreenToggleWindowed;
    mi_CameraZ      : begin vid_rc_newz:=not vid_rc_newz;cam_z:=rc_camz[vid_rc_newz];end;
    mi_PlayerTeam   : if(s<>2)then _bn(@player_team,sign(s),0,MaxTeamsI);
    mi_playerwswtch : player_wswitch    :=not player_wswitch;
    mi_playerantilag: player_antilag    :=not player_antilag;
    mi_playersmooth : player_smooth     :=not player_smooth;
    mi_chat_sound   : player_chat_snd   :=not player_chat_snd;
    mi_showfps      : player_showfps    :=not player_showfps;
    mi_playertimer  : player_showtime   :=not player_showtime;
    mi_scoresave    : scores_save       :=not scores_save;
    mi_maxcorpses   : if(s<>2)then begin _in(@player_maxcorpses,sign(s)*5,-1,rc_MaxEffects);FillChar(map_deads,SizeOf(map_deads),0);end;
    mi_agrp_folder  : GFXDirNext(s>-1);
    mi_agrp_reload  : LoadGFX(true);
    mi_demoupdlist  : demos_RemakeMenuList;
    mi_demorecord   : demo_record:=not demo_record;
    mi_resolution   : RCResolutionNext(s>-1);
    mi_localmapr    : menu_reload_maps;
    mi_serversrch   : net_SearchLocalSV:=not net_SearchLocalSV;
    mi_SoundVolume  : if(s<>2)then
                             begin _bn(@snd_volume ,sign(s),0,100); snd_volume1:=snd_volume/100;end;
    mi_MouseSpeed   : if(s<>2)then _in(@m_speed    ,sign(s),1,500);
    mi_localgame    : if(s= 2)then begin if(cl_net_cstat>0)then net_Disconnect;StartLocalGame;menu_switch(255);end;
    mi_localmap     : if(menu_locmatch=false)and(s<>2)then MenuMapRoll(s>0);
    mi_fraglimit    : if(menu_locmatch=false)and(s<>2)then with sv_clroom^ do _in(@menu_lslimit,sign(s),0,1000);
    mi_timelimit    : if(menu_locmatch=false)and(s<>2)then with sv_clroom^ do _in(@menu_ltlimit,sign(s),0,60);
    mi_localbotT1   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[0],sign(s),0,255 );
    mi_localbotT2   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[1],sign(s),0,255 );
    mi_localbotT3   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[2],sign(s),0,255 );
    mi_localbotT4   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[3],sign(s),0,255 );
    mi_localteams   : if(menu_locmatch=false)then menu_lteams:=not menu_lteams;
    mi_localteamd   : if(menu_locmatch=false)then menu_lteamd:=not menu_lteamd;
    mi_localinsta   : if(menu_locmatch=false)then menu_linsta:=not menu_linsta;
    mi_localiresp   : if(menu_locmatch=false)then menu_itresp:=not menu_itresp;
    mi_localwstay   : if(menu_locmatch=false)then menu_wstay :=not menu_wstay;
    mi_netupd       : player_netupd:=not player_netupd;
    mi_serverupd    : if(s=2)then       net_RequestRoomsInfo;
    mi_room         : if(s=2)then begin net_StartConnect(menu_s-menu_roomi);menu_switch(255);end;
    mi_demoplay     : if(s=2)then begin demos_PlayDemo(demos_l[menu_s-menu_demoi]); end;
    mi_demoreset    : if(s=2)then begin demo_break(sv_clroom,str_demo_MenuReset);sv_clroom^.demo_cstate:=ds_none;end;
    mi_disconnect   : if(s=2)then       net_Disconnect;
    mi_chat1_key,
    mi_chat2_key,
    mi_chat3_key,
    mi_chat4_key,
    mi_chat5_key,
    mi_chat1_str,
    mi_chat2_str,
    mi_chat3_str,
    mi_chat4_str,
    mi_chat5_str,
    mi_logsnext,
    mi_logsprev,
    mi_serverIP,
    mi_ServerPort,
    mi_PlayerName,
    mi_attack,
    mi_forward,
    mi_backward,
    mi_StrafeLeft,
    mi_StrafeRight,
    mi_turnleft,
    mi_turnright,
    mi_JoinSpec,
    mi_chat,
    mi_wnext,
    mi_wprev,
    mi_w1,
    mi_w2,
    mi_w3,
    mi_w4,
    mi_w5,
    mi_w6,
    mi_w7,
    mi_w8,
    mi_dpause,
    mi_dskipf,
    mi_dskipb,
    mi_scores,
    mi_console,
    mi_votey,
    mi_voten,
    mi_screenshot   : if(s=2)then menu_sfix:=menu_s;
   end;
   PlaySoundGlobal(snd_mmove);
end;


function textedit(s:pshortstring;charset:TSoC;ml:byte):boolean;
var sl,
     i:byte;
begin
   textedit:=false;
   sl:=length(s^);
   if(sl>0)and((cl_acts[a_tremove]=1)or(cl_acts[a_tremove]>fr_fpsh1))then
   begin
      delete(s^,sl,1);
      textedit:=true;
   end
   else
   begin
      if(cl_acts[a_ctrl]>0)and(cl_acts[a_paste]=1)then
      begin
         keyboard_string:='';
         if(SDL_HasClipboardText=SDL_TRUE)
         then keyboard_string:=SDL_GetClipboardText;
         KeyboardStringRussian;
      end;
      for i:=1 to length(keyboard_string) do
       if(keyboard_string[i] in charset)and(sl<ml)then
       begin
          s^:=s^+keyboard_string[i];
          sl+=1;
          textedit:=true;
          if(sl=ml)then break;
       end;
   end;
end;

function menu_act:byte;
var i:byte;
begin
   menu_act:=0;
   for i:=0 to 255 do
    if(i in menu_acts)then
     if(cl_acts[i]=1)or(cl_acts[i]>fr_fpsh1)then
     begin
        menu_act:=i;
        break;
     end;
end;

procedure menu_check_values;
begin
   case menu_txtT[menu_sfix] of
   mi_serverIP  :   ip_txt(@cl_net_svip,@cl_net_svips);
   mi_ServerPort: port_txt(@cl_net_svp ,@cl_net_svps );
   end;
end;

procedure cl_setKey(action,key_type:byte;key:cardinal);
begin
   cl_keys  [action]:=key;
   cl_keys_t[action]:=key_type;
end;
procedure cl_setKeyMenu(action,key_type:byte;key:cardinal;menu_item,action_group:byte);
begin
   cl_setKey(action,key_type,key);
   if(menu_item>0)then menu2actkeys[menu_item]:=action;
   cl_group[action]:=action_group;
end;
function cl_setLastKey(action:byte):boolean;
begin
   cl_setLastKey:=false;
   if(last_key_m<>1)then exit;
   cl_keys  [action]:=last_key;
   cl_keys_t[action]:=last_key_t;
   cl_setLastKey :=true;
end;
procedure cl_RemoveGroupKey(action:byte);
var i : byte;
begin
   for i:=0 to 255 do
     if (i<>action)
     and(cl_group [i]=cl_group [action])
     and(cl_keys  [i]=cl_keys  [action])
     and(cl_keys_t[i]=cl_keys_t[action])then
     begin
        cl_keys  [i]:=0;
        cl_keys_t[i]:=255;
     end;
end;

procedure G_MenuInput;
var a:byte;
begin
   a:=menu_act;

   if(menu_sfix<0)then
    case a of
a_menter1,
a_menter2: menu_action( 2);
a_mleft  : menu_action(-1);
a_mright : menu_action( 1);
a_mup1,
a_mup2   : menu_sel(-1);
a_mdown1,
a_mdown2 : menu_sel( 1);
a_menu   : menu_switch(255);
a_mpgup  : menu_sel(-menu_inscr);
a_mpgdn  : menu_sel( menu_inscr);
a_mhome  : begin menu_s:=0;         menu_scrol:=0;                end;
a_mend   : begin menu_s:=menu_num-1;menu_scrol:=menu_s-menu_inscr;end;
a_mdel   : if(menu2actkeys[menu_txtT[menu_s]]>0)then cl_setKey(menu2actkeys[menu_txtT[menu_s]],0,0);
a_mback  : if(menu)then menu_switch(255);
    end
   else
   begin
      if(menu2actkeys[menu_txtT[menu_sfix]]=0)then
      case a of
a_menter1,
a_menter2,
a_menu  : begin
             menu_check_values;
             menu_sfix:=-1;
          end;
a_mback,
a_tremove,
a_paste,
0       : begin
          menu_update:=true;
          case menu_txtT[menu_sfix] of
mi_serverIP    : textedit(@cl_net_svips,chars_addr   ,15     );
mi_ServerPort  : textedit(@cl_net_svps ,chars_digits ,5      );
mi_PlayerName  : textedit(@player_name ,chars_common ,NameLen);
mi_chat1_str   : textedit(@player_chat1,chars_common ,NameLen);
mi_chat2_str   : textedit(@player_chat2,chars_common ,NameLen);
mi_chat3_str   : textedit(@player_chat3,chars_common ,NameLen);
mi_chat4_str   : textedit(@player_chat4,chars_common ,NameLen);
mi_chat5_str   : textedit(@player_chat5,chars_common ,NameLen);
          else
          end;
          end;
      end
      else
        if(a=a_menu)
        then menu_sfix:=-1
        else
         if(cl_setLastKey(menu2actkeys[menu_txtT[menu_sfix]]))then
         begin
            cl_RemoveGroupKey(menu2actkeys[menu_txtT[menu_sfix]]);
            menu_sfix  :=-1;
            menu_update:=true;
         end;
   end;

   if(a>0)then menu_update:=true;

   if(menu_update)then
   begin
      menu_update:=false;
      ReMakeMenu;
   end;
end;


