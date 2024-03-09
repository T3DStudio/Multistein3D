
////////////////////////////////////////////////////////////////////////////////
//
//   DRAW EDITOR
//


function InMapEditorBorders(gx,gy:integer):boolean;
begin
   InMapEditorBorders:=(0<=gx)and(gx<=map_miw)and(0<=gy)and(gy<=map_miw);
end;

procedure draw_EditorCell(x,y,cell_w,cell_hw:integer;rcimage:pTRCImage;flipx,selected:boolean);
var c  :single;
    w,h:integer;
begin
   if(rcimage=nil)then exit;
   with rcimage^ do
   begin
      c:=rc_w/rc_h;
      if(rc_w>rc_h)then
      begin
         if(rc_w>cell_w)then
         begin
            w:=cell_w;
            h:=trunc(w/c);
         end
         else
         begin
            w:=rc_w;
            h:=rc_h;
         end;
      end
      else
      begin
         if(rc_h>cell_w)then
         begin
            h:=cell_w;
            w:=trunc(h*c);
         end
         else
         begin
            w:=rc_w;
            h:=rc_h;
         end;
      end;

      draw_textureEx(x+cell_hw-(w div 2),
                     y+cell_hw-(h div 2),w,h,sdltexture,0,flipx,false);
      if(selected)then
      begin
         draw_rectangle(x  ,y  ,x+cell_w  ,y+cell_w  ,@c_lime);
         draw_rectangle(x+1,y+1,x+cell_w-1,y+cell_w-1,@c_lime);
      end;
   end;
end;

procedure draw_Editor;
var  x, y,
    gx,gy: integer;
  rcimage: pTRCImage;
  c      : char;
  xa     : boolean;
function by(n:integer):integer;
begin
   by:=editor_panel_w*n+1;
end;
begin
   x:=editor_panel_w-(editor_vx mod editor_grid_w);
   while(x<=vid_log_w)do
   begin
      gx:=(x+editor_vx-editor_panel_w) div editor_grid_w;

      y:=-(editor_vy mod editor_grid_w);
      while(y<=vid_log_h)do
      begin
         gy:=(y+editor_vy) div editor_grid_w;

         rcimage:=nil;
         xa     :=false;

         if(InMapEditorBorders(gx,gy))then
         begin
            c:=editor_map[gx,gy];
            rcimage:=char2rcimage(c,@xa);

            if(rcimage<>nil)
            then draw_EditorCell(x,y,editor_grid_w,editor_grid_hw,rcimage,xa,false);

            if(gx=editor_mouse_gx)and(gy=editor_mouse_gy)
            then draw_rectangle(x,y,x+editor_grid_w-1,y+editor_grid_w-1,@c_lime)
            else
            begin
               draw_line(x,y,x+editor_grid_w,y,@c_gray);
               draw_line(x,y,x,y+editor_grid_w,@c_gray);
            end;
         end;

         y+=editor_grid_w;
      end;

      x+=editor_grid_w;
   end;

   // pannel
   draw_box (0,0,editor_panel_wb,vid_log_h,@c_black ,false);

   draw_imageEx(1,by(editor_pb_mapload),@editor_icons[0],nil,false,editor_panel_iw,editor_panel_iw);
   draw_imageEx(1,by(editor_pb_save   ),@editor_icons[1],nil,false,editor_panel_iw,editor_panel_iw);

   rcimage:=char2rcimage(editor_brush_wall ,@xa);
   draw_EditorCell(0,by(editor_pb_bwalls ),editor_panel_w,editor_panel_hw,rcimage,xa,(editor_brush in mgr_bwalls)or(editor_brush=mgr_door));
   rcimage:=char2rcimage(editor_brush_decor,@xa);
   draw_EditorCell(0,by(editor_pb_bdecors),editor_panel_w,editor_panel_hw,rcimage,xa, editor_brush in mgr_decors);
   rcimage:=char2rcimage(editor_brush_item ,@xa);
   draw_EditorCell(0,by(editor_pb_bitems ),editor_panel_w,editor_panel_hw,rcimage,xa, editor_brush in mgr_items );
   rcimage:=char2rcimage(editor_brush_spawn,@xa);
   draw_EditorCell(0,by(editor_pb_bspawns),editor_panel_w,editor_panel_hw,rcimage,xa, editor_brush in mgr_spawns);

   draw_imageEx(1,by(editor_pb_hmove  ),@editor_icons[2],nil,false,editor_panel_iw,editor_panel_iw);
   draw_imageEx(1,by(editor_pb_vmove  ),@editor_icons[3],nil,false,editor_panel_iw,editor_panel_iw);

   draw_line(editor_panel_wb,0,editor_panel_wb,vid_log_h,@c_ltgray);
   y:=editor_panel_w;
   while(y<vid_log_h)do
   begin
      draw_line(0,y,editor_panel_wb,y,@c_ltgray);
      y+=editor_panel_w;
   end;

   draw_box(1,by(editor_pb_ceil ),editor_panel_iw,by(editor_pb_ceil )+editor_panel_iw,@editor_ceil_color ,false);
   draw_text(editor_panel_hw,by(editor_pb_ceil_r )+font_h,1,HexStr(editor_ceil_color .r,2),ta_middle,@c_white,nil);
   draw_text(editor_panel_hw,by(editor_pb_ceil_g )+font_h,1,HexStr(editor_ceil_color .g,2),ta_middle,@c_white,nil);
   draw_text(editor_panel_hw,by(editor_pb_ceil_b )+font_h,1,HexStr(editor_ceil_color .b,2),ta_middle,@c_white,nil);

   draw_box(1,by(editor_pb_floor),editor_panel_iw,by(editor_pb_floor)+editor_panel_iw,@editor_floor_color,false);
   draw_text(editor_panel_hw,by(editor_pb_floor_r)+font_h,1,HexStr(editor_floor_color.r,2),ta_middle,@c_white,nil);
   draw_text(editor_panel_hw,by(editor_pb_floor_g)+font_h,1,HexStr(editor_floor_color.g,2),ta_middle,@c_white,nil);
   draw_text(editor_panel_hw,by(editor_pb_floor_b)+font_h,1,HexStr(editor_floor_color.b,2),ta_middle,@c_white,nil);

   // bottoms hint
   case editor_panel_b of
   0 : with g_maps[editor_panel_mapi] do
         draw_text(editor_panel_wt,0,1,mname,ta_left,@c_white,@c_black);
   end;

   //editor_panel_b
   with g_maps[editor_mapi] do
     draw_text(editor_panel_wt,vid_log_h-font_lh,1,mname,ta_left,@c_white,@c_black);
   draw_text(editor_panel_wt,vid_log_h-font_lh*2,1,i2s(editor_mouse_gx)+','+i2s(editor_mouse_gy),ta_left,@c_white,@c_black);

   // cursor
   draw_line  (editor_mouse_x,editor_mouse_y,editor_mouse_x+10,editor_mouse_y+10,@c_white);
   draw_circle(editor_mouse_x,editor_mouse_y,5,@c_white);
end;


