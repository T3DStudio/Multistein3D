
{$IFDEF FULLGAME}
procedure G_ClientGame;
begin
   net_clientcode;

   demo_Processing(sv_clroom);
   with sv_clroom^ do
   begin
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
        if(cl_mode=clm_game)and(menu_locmatch)then G_SvGame;
   end;

   MakeCameraAndHud;

   SoundProc;
end;


function G_InitVideo:boolean;
begin
   G_InitVideo:=false;

   new(vid_rect);

   if (SDL_Init(SDL_INIT_VIDEO)<0) then
   begin
      WriteSDLError('SDL_Init');
      exit;
   end;

   ScreenMake;

   LoadGFX(false);

   SDL_SetWindowGrab(vid_window,SDL_FALSE);
   SDL_ShowCursor(0);
   SDL_StartTextInput;

   G_InitVideo:=true;
end;

procedure G_InitMenu;
begin
   FillChar(cl_keys  ,SizeOf(cl_keys  ),0);
   FillChar(cl_keys_t,SizeOf(cl_keys_t),0);
   FillChar(menu2actkeys,SizeOf(menu2actkeys),0);

//               action    key type     key               menu item       action group
   cl_setKeyMenu(a_FW     ,kt_keyboard ,SDLK_W           ,mi_forward     ,0);
   cl_setKeyMenu(a_BW     ,kt_keyboard ,SDLK_S           ,mi_backward    ,0);
   cl_setKeyMenu(a_SL     ,kt_keyboard ,SDLK_A           ,mi_StrafeLeft  ,0);
   cl_setKeyMenu(a_SR     ,kt_keyboard ,SDLK_D           ,mi_StrafeRight ,0);
   cl_setKeyMenu(a_TL     ,kt_keyboard ,SDLK_Left        ,mi_turnleft    ,0);
   cl_setKeyMenu(a_TR     ,kt_keyboard ,SDLK_Right       ,mi_turnright   ,0);
   cl_setKeyMenu(a_A      ,kt_mouseb   ,SDL_BUTTON_LEFT  ,mi_attack      ,0);
   cl_setKeyMenu(a_J      ,kt_keyboard ,SDLK_G           ,mi_JoinSpec    ,0);
   cl_setKeyMenu(a_T      ,kt_keyboard ,SDLK_T           ,mi_chat        ,0);
   cl_setKeyMenu(a_S      ,kt_keyboard ,SDLK_TAB         ,mi_scores      ,0);
   cl_setKeyMenu(a_WN     ,kt_mousewh  ,mw_down          ,mi_wnext       ,0);
   cl_setKeyMenu(a_WP     ,kt_mousewh  ,mw_up            ,mi_wprev       ,0);
   cl_setKeyMenu(a_W1     ,kt_keyboard ,SDLK_1           ,mi_w1          ,0);
   cl_setKeyMenu(a_W2     ,kt_keyboard ,SDLK_2           ,mi_w2          ,0);
   cl_setKeyMenu(a_W3     ,kt_keyboard ,SDLK_3           ,mi_w3          ,0);
   cl_setKeyMenu(a_W4     ,kt_keyboard ,SDLK_4           ,mi_w4          ,0);
   cl_setKeyMenu(a_W5     ,kt_keyboard ,SDLK_5           ,mi_w5          ,0);
   cl_setKeyMenu(a_W6     ,kt_keyboard ,SDLK_6           ,mi_w6          ,0);
   cl_setKeyMenu(a_W7     ,kt_keyboard ,SDLK_7           ,mi_w7          ,0);
   cl_setKeyMenu(a_W8     ,kt_keyboard ,SDLK_8           ,mi_w8          ,0);
   cl_setKeyMenu(a_SS     ,kt_keyboard ,SDLK_PrintScreen ,mi_screenshot  ,0);
   cl_setKeyMenu(a_US     ,kt_keyboard ,SDLK_E           ,mi_use         ,0);
   cl_setKeyMenu(a_CO     ,kt_keyboard ,SDLK_BACKQUOTE   ,mi_console     ,0);
   cl_setKeyMenu(a_LN     ,kt_mousewh  ,mw_down          ,mi_logsnext    ,2);
   cl_setKeyMenu(a_LP     ,kt_mousewh  ,mw_up            ,mi_logsprev    ,2);
   cl_setKeyMenu(a_C1     ,kt_keyboard ,SDLK_F1          ,mi_chat1_key   ,0);
   cl_setKeyMenu(a_C2     ,kt_keyboard ,SDLK_F2          ,mi_chat2_key   ,0);
   cl_setKeyMenu(a_C3     ,kt_keyboard ,SDLK_F3          ,mi_chat3_key   ,0);
   cl_setKeyMenu(a_C4     ,kt_keyboard ,SDLK_F4          ,mi_chat4_key   ,0);
   cl_setKeyMenu(a_C5     ,kt_keyboard ,SDLK_F5          ,mi_chat5_key   ,0);
   cl_setKeyMenu(a_dpause ,kt_keyboard ,SDLK_Pause       ,mi_dpause      ,1);
   cl_setKeyMenu(a_dskipb ,kt_keyboard ,SDLK_Left        ,mi_dskipb      ,1);
   cl_setKeyMenu(a_dskipf ,kt_keyboard ,SDLK_Right       ,mi_dskipf      ,1);
   cl_setKeyMenu(a_votey  ,kt_keyboard ,SDLK_PageUp      ,mi_votey       ,0);
   cl_setKeyMenu(a_voten  ,kt_keyboard ,SDLK_PageDown    ,mi_voten       ,0);

   cl_setKeyMenu(a_menu   ,kt_keyboard ,SDLK_Escape      ,0              ,9);
   cl_setKeyMenu(a_mup1   ,kt_keyboard ,SDLk_Up          ,0              ,9);
   cl_setKeyMenu(a_mdown1 ,kt_keyboard ,SDLK_Down        ,0              ,9);
   cl_setKeyMenu(a_mup2   ,kt_mousewh  ,mw_up            ,0              ,9);
   cl_setKeyMenu(a_mdown2 ,kt_mousewh  ,mw_down          ,0              ,9);
   cl_setKeyMenu(a_mleft  ,kt_keyboard ,SDLK_Left        ,0              ,9);
   cl_setKeyMenu(a_mright ,kt_keyboard ,SDLK_Right       ,0              ,9);
   cl_setKeyMenu(a_menter1,kt_keyboard ,SDLK_Return      ,0              ,9);
   cl_setKeyMenu(a_menter2,kt_mouseb   ,SDL_BUTTON_LEFT  ,0              ,9);
   cl_setKeyMenu(a_mdel   ,kt_keyboard ,SDLK_Delete      ,0              ,9);
   cl_setKeyMenu(a_mback  ,kt_keyboard ,SDLK_Backspace   ,0              ,9);
   cl_setKeyMenu(a_mpgup  ,kt_keyboard ,SDLK_PageUp      ,0              ,9);
   cl_setKeyMenu(a_mpgdn  ,kt_keyboard ,SDLK_PageDown    ,0              ,9);
   cl_setKeyMenu(a_mend   ,kt_keyboard ,SDLK_End         ,0              ,9);
   cl_setKeyMenu(a_mhome  ,kt_keyboard ,SDLK_Home        ,0              ,9);
   cl_setKeyMenu(a_paste  ,kt_keyboard ,SDLK_V           ,0              ,9);
   cl_setKeyMenu(a_tab    ,kt_keyboard ,SDLK_Tab         ,0              ,9);
   cl_setKeyMenu(a_ctrl   ,kt_keyboard ,SDLK_LCtrl       ,0              ,9);
   cl_setKeyMenu(a_alt    ,kt_keyboard ,SDLK_LAlt        ,0              ,9);
   cl_setKeyMenu(a_enter  ,kt_keyboard ,SDLK_Return      ,0              ,9);
   cl_setKeyMenu(a_tremove,kt_keyboard ,SDLK_Backspace   ,0              ,9);
   cl_setKeyMenu(a_mrb    ,kt_mouseb   ,SDL_BUTTON_Right ,0              ,9);

   cl_setKeyMenu(a_edit_left      ,kt_keyboard,SDLK_Left ,0              ,9);
   cl_setKeyMenu(a_edit_right     ,kt_keyboard,SDLK_Right,0              ,9);
   cl_setKeyMenu(a_edit_up        ,kt_keyboard,SDLK_Up   ,0              ,9);
   cl_setKeyMenu(a_edit_down      ,kt_keyboard,SDLK_Down ,0              ,9);
   cl_setKeyMenu(a_edit_mwheeldown,kt_mousewh ,mw_down   ,0              ,9);
   cl_setKeyMenu(a_edit_mwheelup  ,kt_mousewh ,mw_up     ,0              ,9);
   cl_setKeyMenu(a_edit_lmb       ,kt_mouseb  ,SDL_BUTTON_LEFT  ,0       ,9);
   cl_setKeyMenu(a_edit_rmb       ,kt_mouseb  ,SDL_BUTTON_Right ,0       ,9);
   cl_setKeyMenu(a_edit_mmb       ,kt_mouseb  ,SDL_BUTTON_Middle,0       ,9);
end;

procedure BuildMoveDirArray;
var w,a,
    s,d: boolean;
    vx,
    vy : integer;
begin
   FillByte(move_dir,sizeof(move_dir),0);
   //mforw mback sleft sright
   for w:=false to true do
   for a:=false to true do
   for s:=false to true do
   for d:=false to true do
   begin
      vx:=0;
      vy:=0;
      if(w)then vx+=1;
      if(s)then vx-=1;
      if(d)then vy+=1;
      if(a)then vy-=1;
      if(vx=0)and(vy=0)
      then move_dir[w,s,a,d]:=-1
      else move_dir[w,s,a,d]:=round(point_dir(0,0,vx,vy));
   end;
end;

{$ENDIF}

procedure ReadParam(s,v:shortstring);
begin
   case s of
{$IFDEF FULLGAME}
'-nosound'       : nosound:=true;
{$ELSE}
'-port'          : sv_net_port  :=s2w(v);
'-roomscfg'      : sv_room_config_fname :=v;
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
   sys_cycle:=false;

   StartParams;

   randomize;

   new(sys_event);

   if(not InitNET)then exit;

   map_LoadAll;

   {$IFDEF FULLGAME}
   sv_maxrooms:=1;
   setlength(sv_rooms,sv_maxrooms);
   sv_clroom:=@sv_rooms[0];
   demo_init_data(sv_clroom);

   FillChar(console_history,SizeOf(console_history),0);

   BuildMoveDirArray;

   G_InitMenu;
   editor_init;

   cfg_load;

   if(not G_InitVideo)then exit;

   if(not nosound)then
   if(not InitSounds )then exit;

   menu_update:=true;

   cam_fov:=0.905;

   sv_roomsinfo_n:=0;
   setlength(sv_roomsinfo,0);

   ResetLocalGame;
   demos_RemakeMenuList;

   if(not net_UpSocket(net_advertise_port0,true))then
   begin
      room_log_add(sv_clroom,log_local,str_AdvPortError);
      if(not net_UpSocket(0,true))then exit;
   end;

   cl_net_stat:=str_nconnected;

   {$ELSE}
   writeln(str_wcaption,str_UDP_port,sv_net_port);

   if(not net_UpSocket(sv_net_port,true))then exit;

   net_advertise_ip  :=ip2c(net_advertise_ip0  );
   net_advertise_port:=swap(net_advertise_port0);

   room_loadcfg(sv_room_config_fname);
   {$ENDIF}

   G_Data;

   fr_init;

   sys_cycle:=true;
end;


