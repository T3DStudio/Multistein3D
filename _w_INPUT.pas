
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
    if(cl_keys_t[i]=kt)and(cl_keys[i]=key)then
     case down of
     false: cl_acts[i]:=-1;
     true : if(cl_acts[i]<=0)then cl_acts[i]:=1;
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
     if(last_key_t=kt)and(last_key=key)then
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
   cam_turn+=x*(window_w/vid_log_w)*m_speed*0.0025;
end;

procedure ActKeysClear;
var i:byte;
begin
   for i:=0 to 255 do cl_acts[i]:=0;
end;

procedure G_Events;
var i:byte;
clear_keys:boolean;
begin
   clear_keys:=false;

   for i:=0 to 255 do
   ActKeyTime(@cl_acts[i],cl_keys_t[i]);

   ActKeyTime(@last_key_m,last_key_t);

   cam_turn:=0;

   while (SDL_PollEvent(_event)>0) do
   case (_event^.type_) of
      SDL_TEXTINPUT       : keyboard_string+=_event^.text.text;
      SDL_MOUSEMOTION     : if(game_mode=gm_game)then G_Mouse(_event^.motion.xrel);
      SDL_MOUSEBUTTONUP   : KeyCode(_event^.button.button      ,false,kt_mouseb  );
      SDL_MOUSEBUTTONDOWN : KeyCode(_event^.button.button      ,true ,kt_mouseb  );
      SDL_KEYUP           : KeyCode(_event^.key.keysym.sym     ,false,kt_keyboard);
      SDL_KEYDOWN         : KeyCode(_event^.key.keysym.sym     ,true ,kt_keyboard);
      SDL_MOUSEWHEEL      : KeyCode(wy2mwkey[_event^.wheel.y<0],true ,kt_mousewh );
      SDL_QUITEV          : _MC:=false;
      SDL_WINDOWEVENT     : case(_event^.window.event)of
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
                                                            window_w:=_event^.window.data1;
                                                            window_h:=_event^.window.data2;
                                                            make_screenshot_wh(window_w,window_h);
                                                            clear_keys:=true;
                                                            end;
                            end;
   else
   end;

   KeyboardStringRussian;

   if(clear_keys)then ActKeysClear;

   G_Mouse(cl_acts[a_TR]-cl_acts[a_TL]);
end;

procedure G_Chat;
begin
   if(cl_acts[a_menter1]=1)then
   begin
      GameCMDChat(chat_str);
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
begin
   if(cl_acts[a_menter1]=1)then
   begin
      if(not GameParseCmd(console_str))
      then net_sendcmd(console_str);

      if(console_historyi>MaxRoomLog)
      then console_historyi:=0;
      console_history[console_historyi]:=console_str;
      console_historyi+=1;
      if(console_historyi>MaxRoomLog)
      then console_historyi:=0;
      console_historyn:=console_historyi;

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
      if(cl_acts[a_C1    ]=1)then net_sendchat(player_chat1)else
      if(cl_acts[a_C2    ]=1)then net_sendchat(player_chat2)else
      if(cl_acts[a_C3    ]=1)then net_sendchat(player_chat3)else
      if(cl_acts[a_C4    ]=1)then net_sendchat(player_chat4)else
      if(cl_acts[a_C5    ]=1)then net_sendchat(player_chat5);

      if(cl_acts[a_votey ]=1)then net_sendcmd(cmd_voteyes)else
      if(cl_acts[a_voten ]=1)then net_sendcmd(cmd_voteno );
      end;

      if(cl_acts[a_dpause]=1)then demo_play_pause:=not demo_play_pause;
      if(cl_acts[a_dskipb]=1)then
      begin
         demo_setpos(_room,_room^.demo_fpos_t-(fr_fps*5));
         exit;
      end;
      if(cl_acts[a_dskipf]=1)then
      begin
         if(demo_play_pause)
         then demo_skip:=2
         else demo_skip:=(fr_fps div demo_timer1_period)*10;
         exit;
      end;
   end;

   ClientActions;
end;

procedure G_EditorInput;
begin
   if(cl_acts[a_menu]=1)then
   begin
      game_mode:=gm_menu;
      exit;
   end;
end;

function G_CommonInput:boolean;
const scroll_speed: word = 10;
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
       MakeScreenShot(_room^.mapname);
       ActKeysClear;
       exit;
    end;
   if(cl_acts[a_CO]=1)then
   begin
      hud_console:=not hud_console;
      chat_line:=false;
      ActKeysClear;
      MouseGrabCheck;
      exit;
   end;
   if(hud_console)then
   begin
      if(cl_acts[a_LN]>0)then
      begin
         hud_text_scrol+=scroll_speed;
         if(hud_text_scrol>MaxRoomLog)then hud_text_scrol:=MaxRoomLog;
         exit;
      end;
      if(cl_acts[a_LP]>0)then
      begin
         if(hud_text_scrol<=scroll_speed)
         then hud_text_scrol:=0
         else hud_text_scrol-=scroll_speed;
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
   case game_mode of
gm_game  : if(not hud_console)then
           G_GameInput;
gm_menu  : G_MenuInput;
gm_editor: G_EditorInput;
   end;

   keyboard_string:='';
end;

{$ELSE}

procedure G_Input;
begin
   while (SDL_PollEvent( _event )>0) do
    case (_event^.type_) of
    SDL_KEYDOWN : ;
    SDL_QUITEV  : _MC:=false;
    end;
end;

{$ENDIF}

