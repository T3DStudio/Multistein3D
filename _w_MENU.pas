

procedure makemenu;
procedure mmladd(t:byte;s,v:shortstring);
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

procedure RoomsInfo;
const sb :shortstring = '                                                       ';
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
   if(sv_roomsinfoc=0)then exit;
   sr:=sb;
   setchars1(@sr,sbi_num  ,sbn_num  ,@ric_num  );
   setchars1(@sr,sbi_name ,sbn_name ,@ric_name );
   setchars1(@sr,sbi_map  ,sbn_map  ,@ric_map  );
   setchars1(@sr,sbi_cl   ,sbn_cl   ,@ric_cl   );
   setchars1(@sr,sbi_pl   ,sbn_pl   ,@ric_pl   );
   setchars1(@sr,sbi_flags,sbn_flags,@ric_flags);

   mmladd(mi_rcaptioninactive,'',str_FLAGS_str1);
   mmladd(mi_rcaptioninactive,'',str_FLAGS_str2);
   mmladd(mi_rcaptioninactive,'',str_FLAGS_str3);
   mmladd(mi_roomcaption     ,sr,'');
   menu_roomi:=menu_num;
   for r:=0 to sv_roomsinfoc-1 do
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
       then mmladd(mi_rooms,sr,'')
       else mmladd(mi_room ,sr,'');
    end;
end;
procedure demos_list;
const
ric_name = 'NAME';
ric_size = 'SIZE';
var d:word;
begin
   if(demos_n=0)then exit;
   mmladd(mi_roomcaption,ric_name,ric_size);
   menu_demoi:=menu_num;
   for d:=0 to demos_n-1 do
     if(demos_l[d]=_room^.demo_fname)
     then mmladd(mi_demos,demos_l[d],demos_s[d])
     else mmladd(mi_demoplay ,demos_l[d],demos_s[d]);
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

{-}  mmladd(mi_caption       ,str_mnetwork    ,''          );         //-- Network
     mmladd(mi_serverip      ,str_msvip       ,cl_net_svips);
     mmladd(mi_serverport    ,str_msvport     ,cl_net_svps );
     mmladd(mi_serverupd     ,str_msvupd      ,''          );
     mmladd(mi_servername    ,str_svname      ,sv_name     );
     mmladd(mi_serverping    ,str_svping      ,sv_ping_str );
     mmladd(zr(mi_disconnect ,
            cl_net_cstat=0)  ,str_mdconnect   ,''          );
     mmladd(mi_constatus     ,str_constat     ,cl_net_stat );
     RoomsInfo;
     mmladd(mi_empty         ,''              ,'');

{-}  mmladd(mi_caption       ,str_localgame   ,'');                    //-- Local game
     mmladd(mi_localgame     ,str_localmatch[menu_locmatch],'');
     mmladd(mi_localmapr     ,str_localmapr   ,'');// reload maps
     mmladd(zi(mi_localmap   ,menu_locmatch)  ,str_localmap    ,_maps[menu_bmm].mname);// map
     mmladd(zi(mi_localteams ,menu_locmatch)  ,str_localteams  ,b2yn[menu_lteams  ]);
     mmladd(zi(mi_localteamd ,menu_locmatch
                         or not menu_lteams)  ,str_localteamd  ,b2yn[menu_lteamd  ]);
     mmladd(zi(mi_localinsta ,menu_locmatch)  ,str_localinsta  ,b2yn[menu_linsta  ]);
     mmladd(zi(mi_localiresp ,menu_locmatch
                         or     menu_linsta)  ,str_localiresp  ,b2yn[menu_itresp  ]);
   if(menu_itresp)
then mmladd(zi(mi_localwstay ,menu_locmatch
                         or     menu_linsta)  ,str_localwstay  ,b2yn[menu_wstay   ])
else mmladd(zi(mi_localwstay ,true         )  ,str_localwstay  ,b2yn[true         ]);
     mmladd(zi(mi_fraglimit  ,menu_locmatch)  ,str_localfragl  ,i2s(menu_lslimit  ));
     mmladd(zi(mi_timelimit  ,menu_locmatch)  ,str_localtimel  ,i2s(menu_ltlimit  ));
     mmladd(zi(mi_localbott1 ,menu_locmatch)  ,str_teams[0]+str_localbots,i2s(menu_lbots[0]));
     mmladd(zi(mi_localbott2 ,menu_locmatch)  ,str_teams[1]+str_localbots,i2s(menu_lbots[1]));
     mmladd(zi(mi_localbott3 ,menu_locmatch)  ,str_teams[2]+str_localbots,i2s(menu_lbots[2]));
     mmladd(zi(mi_localbott4 ,menu_locmatch)  ,str_teams[3]+str_localbots,i2s(menu_lbots[3]));
     mmladd(zi(mi_empty      ,menu_locmatch)  ,''             ,'');

{-}  mmladd(mi_caption       ,str_mplopt      ,'');                   //-- Player options
     mmladd(mi_playername    ,str_mplname     ,player_name           );
     mmladd(mi_playerteam    ,str_mplteam     ,str_teams[player_team]);
     mmladd(mi_playerwswtch  ,str_mplwsw      ,b2yn[player_wswitch  ]);
     mmladd(mi_playerantilag ,str_mpantilag   ,b2yn[player_antilag  ]);
     mmladd(mi_playersmooth  ,str_mpsmooth    ,b2yn[player_smooth   ]);
     mmladd(mi_playertimer   ,str_mptime      ,b2yn[player_showtime ]);
     mmladd(mi_scoresave     ,str_mpsscores   ,b2yn[scores_save     ]);

     mmladd(mi_empty         ,''              ,'');

{-}  mmladd(mi_caption       ,str_msndopt     ,'');                   //-- Sound options
     mmladd(mi_soundvolume   ,str_msndvolume  ,b2s(snd_volume));
     mmladd(mi_chat_sound    ,str_msndchat    ,b2yn[player_chat_snd]);
     mmladd(mi_empty         ,''              ,'');

{-}  mmladd(mi_caption       ,str_mvidopt     ,'');                   //-- Video options
     mmladd(mi_resolution    ,str_mvidres     ,i2s(vid_rw)+'x'+i2s(vid_rh));
     mmladd(mi_fullscreen    ,str_mvidfscr    ,b2yn[vid_fullscreen]);
     mmladd(mi_cameraz       ,str_mvidcamh    ,str_camz[vid_rc_newz]);
     mmladd(mi_showfps       ,str_mvidfps     ,b2yn[player_showfps]);
     mmladd(mi_maxcorpses    ,str_mvidmcorps  ,i2s(player_maxcorpses+1));
     mmladd(mi_agrp_folder   ,str_mvidagrp    ,vid_agraph_dirl[vid_agraph_dirs]);
     mmladd(mi_agrp_reload   ,str_mvidrgrp    ,'');
     mmladd(mi_empty         ,''              ,'');

{-}  mmladd(mi_caption       ,str_mnetopt     ,'');                   //-- Network options
     mmladd(mi_netupd        ,str_mnetupd     ,str_mnetupds[player_netupd]);
     mmladd(mi_empty         ,''              ,'');

{-}  mmladd(mi_caption       ,str_mctropt     ,'');                   //-- Controls
     mmladd(mi_mousespeed    ,str_mctrms      ,i2s(m_speed));         // mouse speed
     mmladd(mi_attack        ,str_mctrat      ,GetKeyName(a_A ));     // attack
     mmladd(mi_forward       ,str_mctrmf      ,GetKeyName(a_FW));     // forward
     mmladd(mi_backward      ,str_mctrmb      ,GetKeyName(a_BW));     // backward
     mmladd(mi_strafeleft    ,str_mctrsl      ,GetKeyName(a_SL));     // strafe left
     mmladd(mi_straferight   ,str_mctrsr      ,GetKeyName(a_SR));     // strafe right
     mmladd(mi_turnleft      ,str_mctrtl      ,GetKeyName(a_TL));     // turn left
     mmladd(mi_turnright     ,str_mctrtr      ,GetKeyName(a_TR));     // turn right
     mmladd(mi_joinspec      ,str_mctrjs      ,GetKeyName(a_J ));     // spectate / join
     mmladd(mi_chat          ,str_mctrch      ,GetKeyName(a_T ));     // chat
     mmladd(mi_wnext         ,str_mctrwn      ,GetKeyName(a_WN));     // weapon next
     mmladd(mi_wprev         ,str_mctrwp      ,GetKeyName(a_WP));     // weapon previous
     mmladd(mi_w1            ,str_mctrw1      ,GetKeyName(a_w1));     // knife
     mmladd(mi_w2            ,str_mctrw2      ,GetKeyName(a_w2));     // pistol
     mmladd(mi_w3            ,str_mctrw3      ,GetKeyName(a_w3));     // mp40
     mmladd(mi_w4            ,str_mctrw4      ,GetKeyName(a_w4));     // chaingun
     mmladd(mi_w5            ,str_mctrw5      ,GetKeyName(a_w5));     // rifle
     mmladd(mi_scores        ,str_mctrss      ,GetKeyName(a_S ));     // show scores
     mmladd(mi_console       ,str_mctrsc      ,GetKeyName(a_CO));     // console
     mmladd(mi_logsnext      ,str_mctrlgn     ,GetKeyName(a_LN));     // console next
     mmladd(mi_logsprev      ,str_mctrlgp     ,GetKeyName(a_LP));     // console previous
     mmladd(mi_screenshot    ,str_mctrscr     ,GetKeyName(a_SS));     // screenshot
     mmladd(mi_chat1_str     ,str_chat1_str   ,player_chat1    );     // chat message 1
     mmladd(mi_chat1_key     ,str_chat1_key   ,GetKeyName(a_C1));     // chat message 1
     mmladd(mi_chat2_str     ,str_chat2_str   ,player_chat2    );     // chat message 2
     mmladd(mi_chat2_key     ,str_chat2_key   ,GetKeyName(a_C2));     // chat message 2
     mmladd(mi_chat3_str     ,str_chat3_str   ,player_chat3    );     // chat message 3
     mmladd(mi_chat3_key     ,str_chat3_key   ,GetKeyName(a_C3));     // chat message 3
     mmladd(mi_chat4_str     ,str_chat4_str   ,player_chat4    );     // chat message 4
     mmladd(mi_chat4_key     ,str_chat4_key   ,GetKeyName(a_C4));     // chat message 4
     mmladd(mi_chat5_str     ,str_chat5_str   ,player_chat5    );     // chat message 5
     mmladd(mi_chat5_key     ,str_chat5_key   ,GetKeyName(a_C5));     // chat message 5
     mmladd(mi_votey         ,str_vote_yes    ,GetKeyName(a_votey));  // chat message 5
     mmladd(mi_voten         ,str_vote_no     ,GetKeyName(a_voten));  // chat message 5

     mmladd(mi_caption       ,str_dcontrol    ,'');                   //-- Demo playback controls
     mmladd(mi_dpause        ,str_dpause      ,GetKeyName(a_dpause)); // demo pause
     mmladd(mi_dskipb        ,str_dskipb      ,GetKeyName(a_dskipb)); // demo backward
     mmladd(mi_dskipf        ,str_dskipf      ,GetKeyName(a_dskipf)); // demo forward

{-}  mmladd(mi_empty         ,''              ,'');
     mmladd(mi_caption       ,str_ddemos      ,'');                   //-- Demos
     mmladd(mi_demorecord    ,str_ddemosreq   ,b2yn[demo_record]);    // record games
     mmladd(zc(mi_demoreset,_room^.demo_cstate<>ds_read)
                             ,str_ddemosrst   ,'');                   // demo playback reset
     mmladd(mi_demoupdlist   ,str_ddemosupd   ,'');
     demos_list;

//     mmladd(mi_empty         ,''              ,'');
//     mmladd(mi_editor        ,str_meditor     ,'');                 //-- Editor
{-}  mmladd(mi_empty         ,''              ,'');
     mmladd(mi_quit          ,str_mquit       ,'');                   //-- Quit
end;

procedure _bm_map_next(next:boolean);
begin
   if(_mapn>0)then
   case next of
   true : begin menu_bmm+=1;if(menu_bmm>=_mapn)then menu_bmm:=0;end;
   false: if(menu_bmm=0)then menu_bmm:=_mapn-1 else menu_bmm-=1;
   end;
end;

procedure menu_sel(i:integer);
var pms,s:integer;
begin
   if(i=0)then exit;

   pms:=menu_s;
   s  :=sign(i);
   while true do
   begin
      menu_s+=s;

      if(menu_s< 0       )then begin menu_s:=0;         break;end;
      if(menu_s>=menu_num)then begin menu_s:=menu_num-1;break;end;

      if not(menu_txtT[menu_s] in [mi_caption,mi_empty,0,mi_roomcaption,mi_inactive3,mi_constatus,mi_servername,mi_serverping,mi_rcaptioninactive])then
      begin
         pms:=menu_s;
         i-=s;
      end;

      if(i=0)then break;
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
    mi_quit         : if(s=2)then _MC:=false;
    mi_editor       : game_mode:=gm_editor;
    mi_fullscreen   : ScreenToggleWindowed;
    mi_cameraz      : begin vid_rc_newz:=not vid_rc_newz;cam_z:=rc_camz[vid_rc_newz];end;
    mi_playerteam   : if(s<>2)then _bn(@player_team,sign(s),0,MaxTeamsI);
    mi_playerwswtch : player_wswitch    :=not player_wswitch;
    mi_playerantilag: player_antilag    :=not player_antilag;
    mi_playersmooth : player_smooth     :=not player_smooth;
    mi_chat_sound   : player_chat_snd   :=not player_chat_snd;
    mi_showfps      : player_showfps    :=not player_showfps;
    mi_playertimer  : player_showtime   :=not player_showtime;
    mi_scoresave    : scores_save       :=not scores_save;
    mi_maxcorpses   : if(s<>2)then begin _in(@player_maxcorpses,sign(s)*5,-1,MaxVisSprites);FillChar(map_deads,SizeOf(map_deads),0);end;
    mi_agrp_folder  : GFXDirNext(s>-1);
    mi_agrp_reload  : LoadGFX(true);
    mi_demoupdlist  : demos_RemakeList;
    mi_demorecord   : demo_record:=not demo_record;
    mi_resolution   : RCResolutionNext(s>-1);
    mi_localmapr    : menu_reload_maps;
    mi_soundvolume  : if(s<>2)then
                             begin _bn(@snd_volume ,sign(s),0,100); snd_volume1:=snd_volume/100;end;
    mi_mousespeed   : if(s<>2)then _in(@m_speed    ,sign(s),1,500);
    mi_localgame    : if(s= 2)then begin if(cl_net_cstat>0)then net_disconnect;StartLocalGame;menu_switch(255);end;
    mi_localmap     : if(menu_locmatch=false)and(s<>2)then _bm_map_next(s>0);
    mi_fraglimit    : if(menu_locmatch=false)and(s<>2)then with _room^ do _in(@menu_lslimit,sign(s),0,1000);
    mi_timelimit    : if(menu_locmatch=false)and(s<>2)then with _room^ do _in(@menu_ltlimit,sign(s),0,60);
    mi_localbott1   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[0],sign(s),0,255 );
    mi_localbott2   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[1],sign(s),0,255 );
    mi_localbott3   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[2],sign(s),0,255 );
    mi_localbott4   : if(menu_locmatch=false)and(s<>2)then _bn(@menu_lbots[3],sign(s),0,255 );
    mi_localteams   : if(menu_locmatch=false)then menu_lteams:=not menu_lteams;
    mi_localteamd   : if(menu_locmatch=false)then menu_lteamd:=not menu_lteamd;
    mi_localinsta   : if(menu_locmatch=false)then menu_linsta:=not menu_linsta;
    mi_localiresp   : if(menu_locmatch=false)then menu_itresp:=not menu_itresp;
    mi_localwstay   : if(menu_locmatch=false)then menu_wstay :=not menu_wstay;
    mi_netupd       : player_netupd:=not player_netupd;
    mi_serverupd    : if(s=2)then       net_reqroomsinfo;
    mi_room         : if(s=2)then begin net_StartConnect(menu_s-menu_roomi);menu_switch(255);end;
    mi_demoplay     : if(s=2)then begin demos_PlayDemo(demos_l[menu_s-menu_demoi]); end;
    mi_demoreset    : if(s=2)then begin demo_break(_room,'menu reset');_room^.demo_cstate:=ds_none;end;
    mi_disconnect   : if(s=2)then       net_disconnect;
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
    mi_serverip,
    mi_serverport,
    mi_playername,
    mi_attack,
    mi_forward,
    mi_backward,
    mi_strafeleft,
    mi_straferight,
    mi_turnleft,
    mi_turnright,
    mi_joinspec,
    mi_chat,
    mi_wnext,
    mi_wprev,
    mi_w1,
    mi_w2,
    mi_w3,
    mi_w4,
    mi_w5,
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
   if(sl>0)and((cl_acts[a_tremove]=1)or(cl_acts[a_tremove]>fr_hfps))then
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
     if(cl_acts[i]=1)or(cl_acts[i]>fr_hfps)then
     begin
        menu_act:=i;
        break;
     end;
end;

procedure menu_check_values;
begin
   case menu_txtT[menu_sfix] of
   mi_serverip  :   ip_txt(@cl_net_svip,@cl_net_svips);
   mi_serverport: port_txt(@cl_net_svp ,@cl_net_svps );
   end;
end;

procedure _setKey(act,tp:byte;k:cardinal);
begin
   cl_keys  [act]:=k;
   cl_keys_t[act]:=tp;
end;
procedure _setKeyMenu(act,tp:byte;k:cardinal;menu:byte);
begin
   _setKey(act,tp,k);
   if(menu>0)then menu2actkeys[menu]:=act;
end;
function _setLastKey(act:byte):boolean;
begin
   _setLastKey:=false;
   if(last_key_m<>1)then exit;
   cl_keys  [act]:=last_key;
   cl_keys_t[act]:=last_key_t;
   _setLastKey:=true;
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
a_mdel   : if(menu2actkeys[menu_txtT[menu_s]]>0)then _setKey(menu2actkeys[menu_txtT[menu_s]],0,0);
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
mi_serverip    : textedit(@cl_net_svips  ,chars_addr   ,15     );
mi_serverport  : textedit(@cl_net_svps   ,chars_digits ,5      );
mi_playername  : textedit(@player_name   ,chars_common ,NameLen);
mi_chat1_str   : textedit(@player_chat1  ,chars_common ,NameLen);
mi_chat2_str   : textedit(@player_chat2  ,chars_common ,NameLen);
mi_chat3_str   : textedit(@player_chat3  ,chars_common ,NameLen);
mi_chat4_str   : textedit(@player_chat4  ,chars_common ,NameLen);
mi_chat5_str   : textedit(@player_chat5  ,chars_common ,NameLen);
          else
          end;
          end;
      end
      else
        if(a=a_menu)
        then menu_sfix:=-1
        else
         if(_setLastKey(menu2actkeys[menu_txtT[menu_sfix]]) )then
         begin
            menu_sfix  :=-1;
            menu_update:=true;
         end;
   end;

   if(a>0)then menu_update:=true;

   if(menu_update)then
   begin
      menu_update:=false;
      makemenu;
   end;
end;


