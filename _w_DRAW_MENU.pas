
////////////////////////////////////////////////////////////////////////////////
//
//   DRAW MENU
//

procedure draw_menu;
var i,m,y:integer;
    s:boolean;
begin
   draw_box(0        ,0        ,vid_w    ,vid_h    ,@c_dred ,false);
   draw_box(m_DRectX0,m_DRectY0,m_DRectX1,m_DRectY1,@c_ddred,false);

   draw_text(vid_log_hw,menu_ystep,menu_font_scale*2,str_mcaption,ta_middle,@c_white ,nil);

   for i:=0 to menu_inscr do
   begin
      y:=m_DRectY0+i*menu_ystep+menu_font_h;
      m:=menu_scrol+i;
      if(m<0)or(m>=menu_num)then break;
      s:=(menu_s=m);

      if(s)then
       if(m=menu_sfix)
       then draw_box(m_DRectX0,y-2,m_DRectX1,y+menu_font_h+2,@c_dgray,false)
       else draw_box(m_DRectX0,y-2,m_DRectX1,y+menu_font_h+2,@c_sred ,false);

      case menu_txtT[m] of
      mi_inactive3: draw_text(vid_log_hw,y,menu_font_scale,menu_txtL[m],ta_middle,@c_dgray     ,nil);
      mi_inactive : draw_text(vid_log_hw,y,menu_font_scale,menu_txtL[m],ta_middle,menu_scol [s],nil); //ltgray/white
      mi_localgame,
      mi_localmapr,
      mi_quit,
      mi_editor,
      mi_connect,
      mi_serverupd,
      mi_disconnect,
      mi_agrp_reload,
      mi_resolutiona,
      mi_demoreset,
      mi_demoupdlist
                  : draw_text(vid_log_hw,y,menu_font_scale,menu_txtL[m],ta_middle,menu_scol2[s],nil); //yellow/white
      mi_caption  : draw_text(vid_log_hw,y,menu_font_scale,menu_txtL[m],ta_middle,@c_orange    ,nil);
      mi_empty    : ;
      mi_servername,
      mi_serverping,
      mi_constatus,
      mi_inactive2: begin
                    draw_text(vid_log_hw ,y,menu_font_scale,menu_txtL[m],ta_right,@c_dgray,nil);
                    draw_text(vid_log_mtx,y,menu_font_scale,menu_txtR[m],ta_left ,@c_dgray,nil);
                    end;
      mi_rcaptioninactive:
                    begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_gray,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_gray,nil);
                    end;
      mi_roomcaption
                  : begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_ltgray,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_ltgray,nil);
                    end;
      mi_room     : begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_ltlime,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_ltlime,nil);
                    end;
      mi_rooms    : begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_ltblue,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_ltblue,nil);
                    end;
      mi_demoplay     : begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_ltlime,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_ltlime,nil);
                    end;
      mi_demos    : begin
                       draw_text(m_DRectX0,y,menu_font_scale,menu_txtL[m],ta_left ,@c_ltblue,nil);
                       draw_text(m_DRectX1,y,menu_font_scale,menu_txtR[m],ta_right,@c_ltblue,nil);
                    end;
      else
        draw_text(vid_log_hw ,y,menu_font_scale,menu_txtL[m],ta_right,menu_scol[s],nil);
        draw_text(vid_log_mtx,y,menu_font_scale,menu_txtR[m],ta_left ,menu_scol[s],nil);
      end;
   end;

   draw_text(vid_log_hw,menu_ctrls_str1      ,menu_font_scale,str_menucontrol1,ta_middle,@c_ltgray,nil);
   draw_text(vid_log_hw,menu_ctrls_str2      ,menu_font_scale,str_menucontrol2,ta_middle,@c_ltgray,nil);
   draw_text(2         ,vid_h-menu_font_h    ,menu_font_scale,str_ver         ,ta_left  ,@c_ltgray,nil);

   if(not hud_console)
   then draw_last_message;
end;


