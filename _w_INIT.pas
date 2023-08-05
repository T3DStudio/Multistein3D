
{$IFDEF FULLGAME}
procedure G_Game;
begin
   net_clientcode;

   with _room^ do
   begin
      demo_Processing(_room);

      if(demo_cstate<>ds_read)then
      begin
         demo_cstate:=ds_none;
         if(demo_record)then
           if((cl_net_cstat=cstate_snap)and(cl_net_mpartn>NetMapParts))
           or(menu_locmatch)then demo_cstate:=ds_write;
      end;

      if(cl_net_cstat>0)or(demo_cstate=ds_read)
      then G_ClGame
      else
        if(game_mode=gm_game)and(menu_locmatch)then G_SvGame;
   end;

   MakeCameraAndHud;

   SoundProc;
end;


function G_InitVideo:boolean;
begin
   G_InitVideo:=false;

   new(_rect);

   if (SDL_Init(SDL_INIT_VIDEO)<0) then
   begin
      WriteSDLError('SDL_Init');
      exit;
   end;

   ScreenMake;

   LoadGFX(false);

   SDL_SetWindowGrab(_window,SDL_FALSE);
   SDL_ShowCursor(0);
   SDL_StartTextInput;

   G_InitVideo:=true;
end;

procedure G_InitMenu;
begin
   FillChar(cl_keys  ,SizeOf(cl_keys  ),0);
   FillChar(cl_keys_t,SizeOf(cl_keys_t),0);
   FillChar(menu2actkeys,SizeOf(menu2actkeys),0);

//             action    key type    key              menu item
   _setKeyMenu(a_FW     ,kt_keyboard,SDLK_W          ,mi_forward    );
   _setKeyMenu(a_BW     ,kt_keyboard,SDLK_S          ,mi_backward   );
   _setKeyMenu(a_SL     ,kt_keyboard,SDLK_A          ,mi_strafeleft );
   _setKeyMenu(a_SR     ,kt_keyboard,SDLK_D          ,mi_straferight);
   _setKeyMenu(a_TL     ,kt_keyboard,SDLK_Left       ,mi_turnleft   );
   _setKeyMenu(a_TR     ,kt_keyboard,SDLK_Right      ,mi_turnright  );
   _setKeyMenu(a_A      ,kt_mouseb  ,SDL_BUTTON_LEFT ,mi_attack     );
   _setKeyMenu(a_J      ,kt_keyboard,SDLK_G          ,mi_joinspec   );
   _setKeyMenu(a_T      ,kt_keyboard,SDLK_T          ,mi_chat       );
   _setKeyMenu(a_S      ,kt_keyboard,SDLK_TAB        ,mi_scores     );
   _setKeyMenu(a_WN     ,kt_mousewh ,mw_down         ,mi_wnext      );
   _setKeyMenu(a_WP     ,kt_mousewh ,mw_up           ,mi_wprev      );
   _setKeyMenu(a_W1     ,kt_keyboard,SDLK_1          ,mi_w1         );
   _setKeyMenu(a_W2     ,kt_keyboard,SDLK_2          ,mi_w2         );
   _setKeyMenu(a_W3     ,kt_keyboard,SDLK_3          ,mi_w3         );
   _setKeyMenu(a_W4     ,kt_keyboard,SDLK_4          ,mi_w4         );
   _setKeyMenu(a_W5     ,kt_keyboard,SDLK_5          ,mi_w5         );
   _setKeyMenu(a_SS     ,kt_keyboard,SDLK_PrintScreen,mi_screenshot );
   _setKeyMenu(a_US     ,kt_keyboard,SDLK_E          ,mi_use        );
   _setKeyMenu(a_CO     ,kt_keyboard,SDLK_BACKQUOTE  ,mi_console    );
   _setKeyMenu(a_LN     ,kt_mousewh ,mw_down         ,mi_logsnext   );
   _setKeyMenu(a_LP     ,kt_mousewh ,mw_up           ,mi_logsprev   );
   _setKeyMenu(a_C1     ,kt_keyboard,SDLK_F1         ,mi_chat1_key  );
   _setKeyMenu(a_C2     ,kt_keyboard,SDLK_F2         ,mi_chat2_key  );
   _setKeyMenu(a_C3     ,kt_keyboard,SDLK_F3         ,mi_chat3_key  );
   _setKeyMenu(a_C4     ,kt_keyboard,SDLK_F4         ,mi_chat4_key  );
   _setKeyMenu(a_C5     ,kt_keyboard,SDLK_F5         ,mi_chat5_key  );
   _setKeyMenu(a_dpause ,kt_keyboard,SDLK_Pause      ,mi_dpause     );
   _setKeyMenu(a_dskipb ,kt_keyboard,SDLK_Left       ,mi_dskipb     );
   _setKeyMenu(a_dskipf ,kt_keyboard,SDLK_Right      ,mi_dskipf     );
   _setKeyMenu(a_votey  ,kt_keyboard,SDLK_PageUp     ,mi_votey      );
   _setKeyMenu(a_voten  ,kt_keyboard,SDLK_PageDown   ,mi_voten      );

   _setKeyMenu(a_menu   ,kt_keyboard,SDLK_Escape     ,0);
   _setKeyMenu(a_mup1   ,kt_keyboard,SDLk_Up         ,0);
   _setKeyMenu(a_mdown1 ,kt_keyboard,SDLK_Down       ,0);
   _setKeyMenu(a_mup2   ,kt_mousewh ,mw_up           ,0);
   _setKeyMenu(a_mdown2 ,kt_mousewh ,mw_down         ,0);
   _setKeyMenu(a_mleft  ,kt_keyboard,SDLK_Left       ,0);
   _setKeyMenu(a_mright ,kt_keyboard,SDLK_Right      ,0);
   _setKeyMenu(a_menter1,kt_keyboard,SDLK_Return     ,0);
   _setKeyMenu(a_menter2,kt_mouseb  ,SDL_BUTTON_LEFT ,0);
   _setKeyMenu(a_mdel   ,kt_keyboard,SDLK_Delete     ,0);
   _setKeyMenu(a_mback  ,kt_keyboard,SDLK_Backspace  ,0);
   _setKeyMenu(a_mpgup  ,kt_keyboard,SDLK_PageUp     ,0);
   _setKeyMenu(a_mpgdn  ,kt_keyboard,SDLK_PageDown   ,0);
   _setKeyMenu(a_mend   ,kt_keyboard,SDLK_End        ,0);
   _setKeyMenu(a_mhome  ,kt_keyboard,SDLK_Home       ,0);
   _setKeyMenu(a_paste  ,kt_keyboard,SDLK_V          ,0);
   _setKeyMenu(a_tab    ,kt_keyboard,SDLK_Tab        ,0);
   _setKeyMenu(a_ctrl   ,kt_keyboard,SDLK_LCtrl      ,0);
   _setKeyMenu(a_alt    ,kt_keyboard,SDLK_LAlt       ,0);
   _setKeyMenu(a_enter  ,kt_keyboard,SDLK_Return     ,0);
   _setKeyMenu(a_tremove,kt_keyboard,SDLK_Backspace  ,0);
   _setKeyMenu(a_mrb    ,kt_mouseb  ,SDL_BUTTON_Right,0);
end;

{$ENDIF}

procedure ReadParam(s,v:shortstring);
begin
   case s of
{$IFDEF FULLGAME}
'-nosound'       : nosound:=true;
{$ELSE}
'-port'          : sv_net_port  :=s2w(v);
'-roomscfg'      : sv_roomcfgfn :=v;
'-localadvertise': net_advertise:=s2i(v)<>0;
{$ENDIF}
   end;
end;

procedure StartParams;
var i,pc:integer;
    v,s :shortstring;
begin
   pc:=ParamCount;
   if(pc>0)then
   for i:=1 to pc do
   begin
      s:=ParamStr(i-1);
      v:=ParamStr(i);
      ReadParam(s,v);
      if(i=pc)then ReadParam(v,'');
   end;
end;


procedure G_Init;
begin
   _MC:=false;

   StartParams;

   randomize;

   new(_event);

   if(InitNET=false)then exit;

   map_LoadAll;

   {$IFDEF FULLGAME}
   sv_maxrooms:=1;
   setlength(_rooms,sv_maxrooms);
   _room:=@_rooms[0];
   demo_init_data(_room);
   //rooms_DefaultAll;

   FillChar(console_history,SizeOf(console_history),0);

   // W S A D  move dirs
   FillByte(move_dir,sizeof(move_dir),0);
   //       mforw mback sleft sright
   move_dir[false,false,false,false]:=-1;
   move_dir[true ,true ,false,false]:=-1;
   move_dir[true ,true ,true ,true ]:=-1;
   move_dir[false,false,true ,true ]:=-1;
   move_dir[true ,false,false,false]:=0;
   move_dir[false,true ,false,false]:=180;
   move_dir[false,false,true ,false]:=270;
   move_dir[false,false,false,true ]:=90;
   move_dir[true ,false,true ,false]:=315;
   move_dir[true ,false,false,true ]:=45;
   move_dir[false,true ,false,true ]:=135;
   move_dir[false,true ,true ,false]:=225;

   G_InitMenu;

   cfg_load;

   if(not G_InitVideo)then exit;

   if(not nosound)then
   if(not InitSounds )then exit;

   menu_update:=true;

   cam_fov:=0.905;

   sv_roomsinfoc:=0;
   setlength(sv_roomsinfo,0);

   ResetLocalGame;
   demos_RemakeList;

   if(not net_UpSocket(net_advertise_port0,true))then
   begin
      _log_add(_room,log_local,str_AdvPortError);
      if(not net_UpSocket(0,true))then exit;
   end;

   cl_net_stat:=str_nconnected;

   {$ELSE}
   writeln(str_wcaption,' UDP port: ',sv_net_port);

   if(not net_UpSocket(sv_net_port,true))then exit;

   net_advertise_ip  :=ip2c('255.255.255.255');
   net_advertise_port:=swap(net_advertise_port0);

   room_loadcfg(sv_roomcfgfn);
   {$ENDIF}

   G_Data;

   fr_init;

   _MC:=true;
end;


