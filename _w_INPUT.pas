
{$IFDEF FULLGAME}
procedure KeyCode(key:cardinal;down:boolean;kt:byte);
var i:byte;
begin
   case kt of
kt_keyboard: case key of
             SDLK_RCtrl : key:=SDLK_LCtrl;
             SDLK_RAlt  : key:=SDLK_LAlt;
             SDLK_RShift: key:=SDLK_LShift;
             1105       : key:=SDLK_BACKQUOTE;
             end;
   end;

   for i:=0 to 255 do
    if (cl_keys_t[i]=kt )
    and(cl_keys  [i]=key)then
      case down of
      false :    cl_acts[i]:=-1;
      true  : if(cl_acts[i]<=0)then cl_acts[i]:=1;
      end;

   if(key>0)then
    if(down)then
    begin
       if(last_key_m=0)then
       begin
          last_key_t:=kt;
          last_key  :=key;
          last_key_m:=1;
       end;
    end
    else
     if (last_key_t=kt )
     and(last_key  =key)then
     begin
        last_key_t:=0;
        last_key  :=0;
        last_key_m:=-1;
     end;
end;

procedure ActKeyTime(pkeystate:pinteger;keytype:byte);
begin
   if(pkeystate^<0)
   then pkeystate^:=0
   else
     if(0<pkeystate^)and(pkeystate^<32000)then
      if(keytype=kt_mousewh)
      then pkeystate^-=1
      else pkeystate^+=1;
end;

procedure G_Mouse(x:integer);
begin
   cam_turn+=x*(window_w/vid_w)*m_speed*0.0025;
end;

procedure G_Events;
var      i:byte;
clear_keys:boolean;
begin
   clear_keys:=false;

   for i:=0 to 255 do
   ActKeyTime(@cl_acts[i],cl_keys_t[i]);

   ActKeyTime(@last_key_m,last_key_t);

   cam_turn:=0;

   while (SDL_PollEvent(sys_event)>0) do
     case (sys_event^.type_) of
      SDL_TEXTINPUT       : keyboard_string+=sys_event^.text.text;
      SDL_MOUSEMOTION     : case(cl_mode)of
                            clm_game  : G_Mouse(sys_event^.motion.xrel);
                            clm_editor: editor_mouse(sys_event^.motion.x,sys_event^.motion.y);
                            end;
      SDL_MOUSEBUTTONUP   : KeyCode(sys_event^.button.button      ,false,kt_mouseb  );
      SDL_MOUSEBUTTONDOWN : KeyCode(sys_event^.button.button      ,true ,kt_mouseb  );
      SDL_KEYUP           : KeyCode(sys_event^.key.keysym.sym     ,false,kt_keyboard);
      SDL_KEYDOWN         : KeyCode(sys_event^.key.keysym.sym     ,true ,kt_keyboard);
      SDL_MOUSEWHEEL      : KeyCode(wy2mwkey[sys_event^.wheel.y<0],true ,kt_mousewh );
      SDL_QUITEV          : sys_cycle:=false;
      SDL_WINDOWEVENT     : case(sys_event^.window.event)of
                            SDL_WINDOWEVENT_SHOWN,
                            SDL_WINDOWEVENT_HIDDEN,
                            SDL_WINDOWEVENT_EXPOSED,
                            SDL_WINDOWEVENT_MINIMIZED,
                            SDL_WINDOWEVENT_MAXIMIZED,
                            SDL_WINDOWEVENT_RESTORED,
                            SDL_WINDOWEVENT_TAKE_FOCUS,
                            SDL_WINDOWEVENT_FOCUS_GAINED,
                            SDL_WINDOWEVENT_FOCUS_LOST    : clear_keys:=true;
                            SDL_WINDOWEVENT_RESIZED       : begin
                                                            window_w  :=sys_event^.window.data1;
                                                            window_h  :=sys_event^.window.data2;
                                                            MakeScreenShot_CalcSize(window_w,window_h);
                                                            clear_keys:=true;
                                                            end;
                            end;
     else
     end;

   KeyboardStringRussian;

   if(clear_keys)then ActKeysClear;

   // keyboard turn
   with sv_clroom^ do
     if(demo_cstate<>ds_read)
     then G_Mouse(cl_acts[a_TR]-cl_acts[a_TL]);
end;

procedure G_Chat;
begin
   if(cl_acts[a_menter1]=1)then
   begin
      client_ChatCommand(chat_str);
      chat_str :='';
      chat_line:=false;
   end
   else textedit(@chat_str ,chars_common ,ChatLen);
end;

procedure ConsoleHistoryRoll(next:boolean);
begin
   repeat
     if(next)then
     begin
        if(console_historyn=0)
        then console_historyn:=MaxRoomLog
        else console_historyn-=1;
     end
     else
       if(console_historyn=MaxRoomLog)
       then console_historyn:=0
       else console_historyn+=1;
     if(length(console_history[console_historyn])<>0)then break;
   until console_historyn=console_historyi;
   console_str:=console_history[console_historyn];
end;

procedure G_Console;
var p:byte;
begin
   if(cl_acts[a_menter1]=1)then
   begin
      if(not GameParseCommand(console_str))then
       if(cl_net_cstat<cstate_snap)
       then room_log_add(sv_clroom,log_local,str_notallowedcmd)
       else net_SendCommand(console_str);

      if(console_historyi>MaxRoomLog)
      then console_historyi:=0;

      p:=console_historyi;
      if(p=0)
      then p:=MaxRoomLog
      else p-=1;

      if((console_str<>console_history[p])or(length(console_history[p])>0))and(length(console_str)>0)then
      begin
         console_history[console_historyi]:=console_str;
         console_historyi+=1;
         if(console_historyi>MaxRoomLog)
         then console_historyi:=0;
         console_historyn:=console_historyi;
      end;

      console_str :='';
   end
   else
     if(cl_acts[a_mup1  ]<>0)
     or(cl_acts[a_mdown1]<>0)then
     begin
        if (cl_acts[a_mup1  ]<>1)
        and(cl_acts[a_mdown1]<>1)
        then exit;

        if(cl_acts[a_mup1  ]=1)then ConsoleHistoryRoll(true );
        if(cl_acts[a_mdown1]=1)then ConsoleHistoryRoll(false);
     end
     else
       if(textedit(@console_str ,chars_common ,ChatLen))
       then console_historyn:=console_historyi;
end;

procedure G_GameInput;
begin
   if(cl_acts[a_menu]=1)then
    if(chat_line)
    then chat_line:=false
    else
    begin
       menu_switch(255);
       exit;
    end;

   if(chat_line)then
   begin
      G_Chat;
      exit;
   end
   else
   begin
      if(cl_acts[a_T]=1)then
      begin
         chat_line:=true;
         exit;
      end;

      if(cl_acts[a_alt]=0)then
      begin
      if(cl_acts[a_C1    ]=1)then client_ChatCommand(player_chat1)else
      if(cl_acts[a_C2    ]=1)then client_ChatCommand(player_chat2)else
      if(cl_acts[a_C3    ]=1)then client_ChatCommand(player_chat3)else
      if(cl_acts[a_C4    ]=1)then client_ChatCommand(player_chat4)else
      if(cl_acts[a_C5    ]=1)then client_ChatCommand(player_chat5);

      if(cl_acts[a_votey ]=1)then net_SendCommand(cmd_voteyes)else
      if(cl_acts[a_voten ]=1)then net_SendCommand(cmd_voteno );
      end;

      if(cl_acts[a_dpause]=1)then demo_play_pause:=not demo_play_pause;
      if(cl_acts[a_dskipb]=1)then
      begin
         demo_setpos(sv_clroom,sv_clroom^.demo_fpos_t-(fr_fpsx1*5));
         exit;
      end;
      if(cl_acts[a_dskipf]=1)then
      begin
         if(demo_play_pause)
         then demo_skip:=2
         else demo_skip:=(fr_fpsx1 div demo_timer1_period)*10;
         exit;
      end;
   end;

   ClientActions;
end;

procedure G_EditorInput;
var pgrid_w:integer;
begin
   if(cl_acts[a_menu]=1)then
   begin
      cl_mode:=clm_menu;
      exit;
   end;

   if(cl_acts[a_edit_left ]>0)then begin editor_vx-=editor_vspeed;editor_ViewBorders;editor_mouse(editor_mouse_x,editor_mouse_y);end;
   if(cl_acts[a_edit_right]>0)then begin editor_vx+=editor_vspeed;editor_ViewBorders;editor_mouse(editor_mouse_x,editor_mouse_y);end;
   if(cl_acts[a_edit_up   ]>0)then begin editor_vy-=editor_vspeed;editor_ViewBorders;editor_mouse(editor_mouse_x,editor_mouse_y);end;
   if(cl_acts[a_edit_down ]>0)then begin editor_vy+=editor_vspeed;editor_ViewBorders;editor_mouse(editor_mouse_x,editor_mouse_y);end;

   if(cl_acts[a_edit_mwheeldown]>0)then
     case editor_panel_b of
                -1 : begin
                        pgrid_w:=editor_grid_w;
                        editor_grid_w :=mm3i(editor_grid_min,editor_grid_w-editor_grid_step,editor_grid_max);
                        editor_grid_hw:=editor_grid_w div 2;

                        pgrid_w-=editor_grid_w;
                        editor_vx-=round(vid_w/editor_grid_w*pgrid_w);
                        editor_vy-=round(vid_h/editor_grid_w*pgrid_w);

                        editor_ReCalcMapW;
                     end;
editor_pb_mapload  : editor_panel_mapi:=(editor_panel_mapi+1) mod g_mapn;

editor_pb_bwalls   : begin editor_RollBrush(mgr_bwalls,@editor_brush_wall ,true);editor_brush:=editor_brush_wall ;end;
editor_pb_bdecors  : begin editor_RollBrush(mgr_decors,@editor_brush_decor,true);editor_brush:=editor_brush_decor;end;
editor_pb_bitems   : begin editor_RollBrush(mgr_items ,@editor_brush_item ,true);editor_brush:=editor_brush_item ;end;
editor_pb_bspawns  : begin editor_RollBrush(mgr_spawns,@editor_brush_spawn,true);editor_brush:=editor_brush_spawn;end;

editor_pb_hmove    : editor_MoveMap(-1, 0);
editor_pb_vmove    : editor_MoveMap( 0,-1);

editor_pb_ceil_r,
editor_pb_ceil_g,
editor_pb_ceil_b   : begin
                     case editor_panel_b of
    editor_pb_ceil_r   : editor_ceil_color.r-=5;
    editor_pb_ceil_g   : editor_ceil_color.g-=5;
    editor_pb_ceil_b   : editor_ceil_color.b-=5;
                     end;
                     with editor_ceil_color do editor_ceil_color:=ColorRGBA(r,g,b,255);
                     end;
editor_pb_floor_r,
editor_pb_floor_g,
editor_pb_floor_b  : begin
                     case editor_panel_b of
    editor_pb_floor_r  : editor_floor_color.r-=5;
    editor_pb_floor_g  : editor_floor_color.g-=5;
    editor_pb_floor_b  : editor_floor_color.b-=5;
                     end;
                     with editor_floor_color do editor_floor_color:=ColorRGBA(r,g,b,255);
                     end;
     end;
   if(cl_acts[a_edit_mwheelup  ]>0)then
     case editor_panel_b of
                -1 : begin
                        pgrid_w:=editor_grid_w;
                        editor_grid_w :=mm3i(editor_grid_min,editor_grid_w+editor_grid_step,editor_grid_max);
                        editor_grid_hw:=editor_grid_w div 2;

                        pgrid_w-=editor_grid_w;
                        editor_vx-=round(vid_w/editor_grid_w*pgrid_w);
                        editor_vy-=round(vid_h/editor_grid_w*pgrid_w);

                        editor_ReCalcMapW;
                     end;
editor_pb_mapload  : if(editor_panel_mapi=0)then editor_panel_mapi:=g_mapn-1 else editor_panel_mapi-=1;

editor_pb_bwalls   : begin editor_RollBrush(mgr_bwalls,@editor_brush_wall ,false);editor_brush:=editor_brush_wall ;end;
editor_pb_bdecors  : begin editor_RollBrush(mgr_decors,@editor_brush_decor,false);editor_brush:=editor_brush_decor;end;
editor_pb_bitems   : begin editor_RollBrush(mgr_items ,@editor_brush_item ,false);editor_brush:=editor_brush_item ;end;
editor_pb_bspawns  : begin editor_RollBrush(mgr_spawns,@editor_brush_spawn,false);editor_brush:=editor_brush_spawn;end;

editor_pb_hmove    : editor_MoveMap( 1, 0);
editor_pb_vmove    : editor_MoveMap( 0, 1);

editor_pb_ceil_r,
editor_pb_ceil_g,
editor_pb_ceil_b   : begin
                     case editor_panel_b of
    editor_pb_ceil_r   : editor_ceil_color.r+=5;
    editor_pb_ceil_g   : editor_ceil_color.g+=5;
    editor_pb_ceil_b   : editor_ceil_color.b+=5;
                     end;
                     with editor_ceil_color do editor_ceil_color:=ColorRGBA(r,g,b,255);
                     end;
editor_pb_floor_r,
editor_pb_floor_g,
editor_pb_floor_b  : begin
                     case editor_panel_b of
    editor_pb_floor_r  : editor_floor_color.r+=5;
    editor_pb_floor_g  : editor_floor_color.g+=5;
    editor_pb_floor_b  : editor_floor_color.b+=5;
                     end;
                     with editor_floor_color do editor_floor_color:=ColorRGBA(r,g,b,255);
                     end;
     end;

   // left press
   if(cl_acts[a_edit_lmb]>0)then
     case editor_panel_b of
  -1 : if(InMapEditorBorders(editor_mouse_gx,editor_mouse_gy))then editor_map[editor_mouse_gx,editor_mouse_gy]:=editor_brush;
     else
       if(cl_acts[a_edit_lmb]=1)then
         case editor_panel_b of
editor_pb_mapload : editor_LoadMapByN(editor_panel_mapi);
editor_pb_grid    : editor_grid:=not editor_grid;
editor_pb_save    : editor_savemap;
editor_pb_bwalls  : editor_brush:=editor_brush_wall;
editor_pb_bdecors : editor_brush:=editor_brush_decor;
editor_pb_bitems  : editor_brush:=editor_brush_item;
editor_pb_bspawns : editor_brush:=editor_brush_spawn;
         end;

     end;

   // right
   if(cl_acts[a_edit_rmb]>0)then
     case editor_panel_b of
     -1 : if(InMapEditorBorders(editor_mouse_gx,editor_mouse_gy))then editor_map[editor_mouse_gx,editor_mouse_gy]:=mgr_empty;
     end;

   // mid
   if(cl_acts[a_edit_mmb]>0)then
     case editor_panel_b of
     -1 : if(InMapEditorBorders(editor_mouse_gx,editor_mouse_gy))then
            if(editor_map[editor_mouse_gx,editor_mouse_gy]<>mgr_empty)then
            begin
               editor_brush:=editor_map[editor_mouse_gx,editor_mouse_gy];
               if(editor_brush in mgr_bwalls)then editor_brush_wall :=editor_brush;
               if(editor_brush in mgr_decors)then editor_brush_decor:=editor_brush;
               if(editor_brush in mgr_items )then editor_brush_item :=editor_brush;
               if(editor_brush in mgr_spawns)then editor_brush_spawn:=editor_brush;
            end;
     end;
end;

function G_CommonInput:boolean;
begin
   G_CommonInput:=false;

   if(cl_acts[a_alt]>1)then
    if(cl_acts[a_enter]=1)then
    begin
       ScreenToggleWindowed;
       ActKeysClear;
       exit;
    end;
   if(not hud_console)then
    if(cl_acts[a_SS]=1)then
    begin
       MakeScreenShot(sv_clroom^.mapname);
       ActKeysClear;
       exit;
    end;
   if(cl_acts[a_CO]=1)then
   begin
      ToggleConsole;

      exit;
   end;
   if(hud_console)then
   begin
      if(cl_acts[a_LN]>0)then
      begin
         hud_text_scrol+=console_scroll_speed;
         if(hud_text_scrol>MaxRoomLog)then hud_text_scrol:=MaxRoomLog;
         exit;
      end;
      if(cl_acts[a_LP]>0)then
      begin
         if(hud_text_scrol<=console_scroll_speed)
         then hud_text_scrol:=0
         else hud_text_scrol-=console_scroll_speed;
         exit;
      end;
      if(cl_acts[a_tab]>0)then
      begin
         if(cl_acts[a_tab]=1)then console_TAB;
         exit;
      end;
      G_Console;
      exit;
   end;

   G_CommonInput:=true;
end;

procedure G_Input;
begin
   G_Events;

   if(G_CommonInput)then
     case cl_mode of
clm_game  : if(not hud_console)then
            G_GameInput;
clm_menu  : G_MenuInput;
clm_editor: G_EditorInput;
     end;

   keyboard_string:='';
end;

{$ELSE}

procedure G_Input;
begin
   while(SDL_PollEvent( sys_event )>0)do
     case(sys_event^.type_)of
     SDL_KEYDOWN : ;
     SDL_QUITEV  : sys_cycle:=false;
     end;
end;

{$ENDIF}

