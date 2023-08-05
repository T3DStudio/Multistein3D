procedure ClearScreen(color:PTColor);
begin
   with color^ do
   SDL_SetRenderDrawColor(_renderer,r,g,b,a);
   SDL_RenderClear(_renderer);
end;

{procedure draw_get_viewport(x,y,w,h:pinteger);
begin
   SDL_RenderGetViewport(_renderer,_rect);
   if(x<>nil)then x^:=_rect^.x;
   if(y<>nil)then y^:=_rect^.y;
   if(w<>nil)then w^:=_rect^.w;
   if(h<>nil)then h^:=_rect^.h;
end;  }

procedure draw_pixel    (x0,y0      :integer;color:PTColor);begin with color^ do SDL_SetRenderDrawColor(_renderer,r,g,b,a);SDL_SetRenderDrawBlendMode(_renderer,SDL_BLENDMODE_NONE);SDL_RenderDrawPoint(_renderer,x0,y0      );end;
procedure draw_line     (x0,y0,x1,y1:integer;color:PTColor);begin with color^ do SDL_SetRenderDrawColor(_renderer,r,g,b,a);SDL_SetRenderDrawBlendMode(_renderer,SDL_BLENDMODE_NONE);SDL_RenderDrawLine (_renderer,x0,y0,x1,y1);end;
procedure draw_box      (x0,y0,x1,y1:integer;color:PTColor;blend:boolean);
const bm : array[false..true] of cardinal = (SDL_BLENDMODE_NONE,SDL_BLENDMODE_BLEND);
begin
   _rect^.x:=x0;
   _rect^.y:=y0;
   _rect^.w:=x1-x0;
   _rect^.h:=y1-y0;
   with color^ do SDL_SetRenderDrawColor(_renderer,r,g,b,a);
   SDL_SetRenderDrawBlendMode(_renderer,bm[blend]);
   SDL_RenderFillRect(_renderer,_rect);
end;
procedure draw_rectangle(x0,y0,x1,y1:integer;color:PTColor);
begin
   draw_line(x0,y0,x0,y1,color);
   draw_line(x0,y1,x1,y1,color);
   draw_line(x1,y1,x1,y0,color);
   draw_line(x1,y0,x0,y0,color);
end;


procedure draw_texture(x,y,w,h:integer;tex:pSDL_Texture);
begin
   _rect^.x:=x;
   _rect^.y:=y;
   _rect^.w:=w;
   _rect^.h:=h;

   SDL_RenderCopy(_renderer,tex,nil,_rect);
end;

procedure draw_image(x,y:integer;img:PTImage;fcolor:PTColor;blend:boolean;xscale,yscale:single);
begin
   with img^ do
   begin
      if(blend)
      then SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_BLEND)
      else SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_NONE );
      with fcolor^ do
      begin
         SDL_SetTextureColorMod(texture,r,g,b);
         SDL_SetTextureAlphaMod(texture,a);
      end;
      draw_texture(x,y,trunc(w*xscale),trunc(h*yscale),texture);
   end;
end;

procedure draw_text(x,y:integer;size:single;s:shortstring;al:byte;fcolor,bcolor:PTColor);
var i,ss:byte;
    h,w :integer;
begin
   ss:=length(s);
   if(ss>0)then
   begin
      if(al=ta_middle)then x:=x-round(ss*font_w*size) div 2;
      if(al=ta_right )then x:=x-round(ss*font_w*size);

      w:=round(font_w*size);
      if(bcolor<>nil)then
      h:=round(font_h*size);
      for i:=1 to ss do
      begin
         if(bcolor<>nil)then draw_box(x,y,x+w,y+h,bcolor,false);
         if(s[i]<>' ')then draw_image(x,y,@font_ca[s[i]],fcolor,true,size,size);
         x+=w;
      end;
   end;
end;

procedure draw_chat_uiline;
var s:shortstring;
begin
   draw_box(0,hud_chat_y,vid_log_w,vid_log_rih,@c_ablack,true);
   s:=str_say+chat_str;
   if(length(s)<hud_rcw_charn)
   then draw_text(0        ,hud_chat_y,1,s,ta_left ,@c_white,nil)
   else draw_text(vid_log_w,hud_chat_y,1,s,ta_right,@c_white,nil);
end;

procedure draw_dHUDt(x,y:integer;s:shortstring;xscale,yscale:single);
var l,i:byte;
begin
   l:=length(s);
   for i:=l downto 1 do
   begin
      x-=trunc(spr_HUDnfw*xscale);
      if(s[i]='-')
      then draw_image(x,y,@spr_HUDnf[';'],@c_white,false,xscale,yscale)
      else
        if(s[i] in hudfont)
        then draw_image(x,y,@spr_HUDnf[s[i]],@c_white,false,xscale,yscale);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   DRAW EDITOR
//

{$INCLUDE _w_DRAW_EDITOR.pas}

////////////////////////////////////////////////////////////////////////////////
//
//   DRAW MENU
//

{$INCLUDE _w_DRAW_MENU.pas}

////////////////////////////////////////////////////////////////////////////////
//
//   DRAW HUD
//

function TimeStr(sec,min:byte):shortstring;
function b2ts(b:byte):shortstring;
begin
   if(b=0)
   then b2ts:='00'
   else
     if(b<10)
     then b2ts:='0'+b2s(b)
     else b2ts:=    b2s(b);
end;
begin
   TimeStr:=b2ts(min)+':'+b2ts(sec);
end;

{$INCLUDE _w_DRAW_UITXT.pas}

procedure draw_HUD_ColorMask;
begin
   if(hud_mask_t>0)then
   begin
      with hud_mask do a:=min2(hud_mask_t*3,255);
      hud_mask_t-=1;
   end
   else
     if(hud_mask_t=0)
     then exit
     else with hud_mask do a:=255;

   draw_box(
   hud_gbrc_x,
   hud_gbrc_y,
   hud_gbrc_x+hud_gbrc_w,
   hud_gbrc_y+hud_gbrc_h,@hud_mask,true);
end;

procedure draw_HUD;
const HHH : shortstring = ';;;';
var i,a:integer;
    t:shortstring;
begin
   draw_image(0,vid_log_rh,@spr_hudpanel,@c_white,false,vid_hud_scale,vid_hud_scale);

   with _players[cam_pl] do
   if(state>ps_spec)then
   begin
      draw_dHUDt(hud_scorex,hud_texty,i2s(frags),hud_fscale,hud_txtyscale);
      draw_image(hud_teamx,hud_teamy,@spr_hudt[team],@c_white,false,vid_hud_scale,vid_hud_scale);

      if(gun_curr<=WeaponsN)and(state>ps_dead)then
      begin
         if(cam_pl=cl_playeri)or(bot)then
         begin
            if(0<gun_ammot[gun_curr])and(gun_ammot[gun_curr]<=AmmoTypesN)
            then draw_dHUDt(hud_ammox,hud_texty,i2s(hud_ammo[gun_ammot[gun_curr]]),hud_fscale,hud_txtyscale)
            else draw_dHUDt(hud_ammox,hud_texty,HHH,hud_fscale,hud_txtyscale);
         end
         else draw_dHUDt(hud_ammox,hud_texty,HHH,hud_fscale,hud_txtyscale);

         i:=byte(gun_rld>gun_ganim[gun_curr]);
         draw_image(spr_HUDgunx[gun_curr,i],spr_HUDguny[gun_curr,i],@spr_HUDgun[gun_curr,i],@c_white,true,vid_hud_scale,vid_hud_scale);

         draw_image(hud_gunx,hud_guny,@spr_hudw[gun_curr],@c_white,false,vid_hud_scale,vid_hud_scale);
      end;

      draw_dHUDt(hud_hitsx ,hud_texty,i2s(mm3i(0,hud_hits ,Player_max_hits )),hud_fscale,hud_txtyscale);

      if(cam_pl=cl_playeri)or(bot)then
      begin
         draw_dHUDt(hud_armorx,hud_texty,i2s(mm3i(0,hud_armor,Player_max_armor)),hud_fscale,hud_txtyscale);

         if(state>ps_dead)then
          for i:=0 to WeaponsN do
           if(i=gun_curr)
           then draw_text(hud_invx+(i*hud_invix),hud_invy,hud_ifscale,b2s(i+1),ta_left,@c_yellow,nil)
           else
             if(hud_guni and (1 shl i))>0
             then draw_text(hud_invx+(i*hud_invix),hud_invy,hud_ifscale,b2s(i+1),ta_left,@c_green ,nil)
             else draw_text(hud_invx+(i*hud_invix),hud_invy,hud_ifscale,b2s(i+1),ta_left,@c_dgray ,nil);
      end
      else draw_dHUDt(hud_armorx,hud_texty,HHH,hud_fscale,hud_txtyscale);

      if(hits<=0)
      then i:=21
      else
       if(hud_biggun>0)
       then i:=22
       else
       begin
          {
          0  1  2    90-100
          3  4  5    75-89
          6  7  8    60-74
          9  10 11   45-59
          12 13 14   30-44
          15 16 17   15-29
          18 19 20   0 -14
          }
          a:=(animation_tick mod vid_3fps) div fr_fps;
          if(RoomFlag(room,sv_g_instagib))
          then i:=a
          else i:=((6-mm3i(0,hits div 15,6))*3)+a;
       end;
      draw_image(hud_hudhx,hud_hudhy,@spr_hudh[i],@c_white,false,vid_hud_scale,vid_hud_scale);
   end;

   draw_HUD_ColorMask;

   if(server_ttl>fr_2fps)
   then draw_text(vid_msg_x,vid_msg_y,menu_font_scale,str_awaitingsrv,ta_middle,@c_white,nil)
   else
     if(cl_net_cstat=cstate_snap)and(cl_net_mpartn<=NetMapParts)
     then draw_text(vid_msg_x,vid_msg_y,menu_font_scale,str_mapdownload,ta_middle,@c_white,nil);

   with _room^ do
    if(vote_time>0)then
    begin
       t:=str_vote+vote_cmd;
       if(length(vote_arg)>0)then t+=' '+vote_arg;
       t+=' ('+w2s(vote_time div fr_fps)+')';

       draw_text(vid_vote_x,vid_vote_y,menu_font_scale,t,ta_middle,@c_white,nil);
    end;

   with _players[cl_playeri] do
    if(state=ps_spec)then
    begin
       with _room^ do
        if(cl_net_cstat>0)or(menu_locmatch)then
         if(cur_players>=max_players)
         then draw_text(vid_log_hw,hud_pl_staty0,menu_font_scale,str_specmode+str_roomfull,ta_middle,@c_white,@c_black)
         else draw_text(vid_log_hw,hud_pl_staty0,menu_font_scale,str_specmode+str_tojoin+'"'+GetKeyName(a_J)+'"',ta_middle,@c_white,@c_black);

       if(cam_pl<>cl_playeri)then draw_text(vid_log_hw,hud_pl_staty1,menu_font_scale,str_following+_players[cam_pl].name,ta_middle,@c_white,@c_black);
    end
    else
      if(cl_net_cstat>0)or(menu_locmatch)then
        if(state=ps_dead)and(cam_pl=cl_playeri)and(hits<=0)then draw_text(vid_log_hw,hud_pl_staty1,menu_font_scale,str_respawn+'"'+GetKeyName(a_A)+'"',ta_middle,@c_white,@c_black);

   with _room^ do
    if(demo_cstate=ds_read)and(demo_file<>nil)and(demo_size>0)then
     Draw_Box(0,vid_log_h-font_hh,round(vid_log_w*FilePos(demo_file^)/demo_size),vid_log_h,@c_yellow,false);

   if(player_showtime)then
    with _room^ do draw_text(vid_log_hw,vid_log_h-font_h,1,TimeStr(time_sec,time_min),ta_middle,@c_white,@c_black);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   DRAW RC
//

{$INCLUDE _w_DRAW_RC.pas}

procedure debug_draw_map;
const cw  = 9;
var ix,iy:integer;
begin
   with _room^ do
    for ix:=0 to map_mlw do
     for iy:=0 to map_mlw do
      if(rgrid[ix,iy] in mgr_bwalls)then
       draw_box(ix*cw,iy*cw,ix*cw+cw,iy*cw+cw,@c_gray,false);

  { for ix:=1 to map_vsprs do
    with map_vspr[ix]^ do
     if(d>0)then draw_pixel(trunc(x)*cw+chw,trunc(y)*cw+chw,@c_white);  }

   ix:=trunc(cam_x*cw);
   iy:=trunc(cam_y*cw);
   draw_line(ix,iy,ix+trunc(cw*cos(cam_dir*degtorad)),iy+trunc(cw*sin(cam_dir*degtorad)),@c_red);
end;

procedure draw_Game;
begin
   draw_box(0,0,vid_log_w,vid_log_rh,@c_daqua,false);

   draw_rc;
   draw_HUD;

   if(chat_line)then draw_chat_uiline;

   if(not hud_console)then
   begin
      if(cl_acts[a_S]>0)
      or(_room^.time_scorepause>0)
      then draw_scoreboard;

      draw_last_mess;
   end;


   //debug_draw_map;
   //debug_draw_sprite(@spr_ef[eid_puff,2]);
end;

procedure G_Draw;
begin
   if(scores_save_need)then
   begin
      ClearScreen(@c_black);

      debug_draw_map;
      draw_scoreboard;
      draw_text(0,4,1,scores_message,ta_left,@c_yellow,@c_black);

      scores_save_need:=false;
      scores_message  :='';
      MakeScreenShot(_room^.mapname);
   end;

   ClearScreen(@c_black);

   case game_mode of
   gm_game  : draw_Game;
   gm_menu  : draw_Menu;
   gm_editor: draw_Editor;
   end;

   // debug

   if(player_showfps)then
   begin
      draw_text(vid_log_w,0 ,1,c2s(fr_FPSSecondC),ta_right,@c_white,@c_black);
      draw_text(vid_log_w,10,1,c2s(fr_FPSSecondT),ta_right,@c_white,@c_black);
   end;

   if(hud_console)
   then draw_console(0,hud_text_scrol);

   {draw_text(vid_log_w,10,1,i2s(menu_num) ,ta_right,@c_white);
   draw_text(vid_log_w,20,1,i2s(console_historyn) ,ta_right,@c_white);
   draw_text(vid_log_w,30,1,b2s(menu_s) ,ta_right,@c_white);
   draw_text(vid_log_w,40,1,b2s(cl_playeri ) ,ta_right,@c_white);
   draw_text(vid_log_w,50,1,i2s(hud_text_scrol ) ,ta_right,@c_white);
   draw_text(vid_log_w,60,1,w2s(net_packets_in0 ) ,ta_right,@c_lime);
   draw_text(vid_log_w,70,1,w2s(net_packets_out0) ,ta_right,@c_red ); }

   {if(cl_playeri<=MaxPlayers)then
   with _players[cl_playeri] do
   begin
   draw_text(vid_log_w,80,1,si2s(x),ta_right,@c_white );
   draw_text(vid_log_w,90,1,si2s(x),ta_right,@c_white );
   end;

   y:=100;
   for b:=0 to 255 do
    if(net_packetsid_in[b]>0)then
    begin
       draw_text(vid_log_w,y,1,b2s(b)+' '+b2s(net_packetsid_in[b]),ta_right,@c_lime);
       y+=10;
    end;

   if(net_packets_t>0)
   then net_packets_t-=1
   else
   begin
      net_packets_in0 :=net_packets_in;
      net_packets_out0:=net_packets_out;
      net_packets_in  :=0;
      net_packets_out :=0;
      net_packets_t   :=fr_fps;
   end; }


   SDL_RenderPresent(_renderer);
end;

