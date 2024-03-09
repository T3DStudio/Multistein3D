
procedure editor_savemap;
var   i,w: word;
      x,y,
last_line: integer;
        f: text;
   colors,
      tmp: shortstring;
map_lines: array[0..map_miw] of shortstring;
function chars_n(ps:pshortstring;c:char):byte;
var sl:byte;
begin
   sl:=length(ps^);
   chars_n:=0;
   while(sl>0)do
   begin
      if(ps^[i]=c)then chars_n+=1;
      sl-=1;
   end;
end;
begin
   with g_maps[editor_mapi] do
   begin
      tmp:=str_mapfolder+mname+str_mapext;
      assign(f,tmp);
      {$I-}
      rewrite(f);
      {$I+}
      if(IOResult<>0)then
      begin
         close(f);
         exit;
      end;

      colors:=HexStr(editor_ceil_color .r,2)+
              HexStr(editor_ceil_color .g,2)+
              HexStr(editor_ceil_color .b,2)+
              HexStr(editor_floor_color.r,2)+
              HexStr(editor_floor_color.g,2)+
              HexStr(editor_floor_color.b,2);
      for w:=1 to length(colors) do mbuff[w]:=colors[w];
      writeln(f,colors);

      last_line:=-1;
      for y:=0 to map_miw do
      begin
         map_lines[y]:='';
         tmp:='';
         for x:=0 to map_miw do
           if editor_map[x,y]=mgr_empty
           then tmp+=editor_map[x,y]
           else
           begin
              map_lines[y]+=tmp+editor_map[x,y];
              tmp:='';
           end;
         if(chars_n(@map_lines[y],mgr_empty)<=map_miw)and(length(map_lines[y])>0) then last_line:=y;
      end;

      if(last_line>-1)then
        for y:=0 to last_line do
        begin
           writeln(f,map_lines[y]);
           i:=length(map_lines[y]);
           if(i>0)then
             for x:=1 to i do
             begin
                w+=1;
                mbuff[w]:=map_lines[y][x];
             end;
           if(i<map_mw)then
           begin
              w+=1;
              mbuff[w]:=str_NewLineChar;
           end;
        end;
      w+=1;
      mbuff[w]:=#0;
      close(f);
   end;
end;

procedure editor_RollBrush(sob:TSoC;brush:pchar;next:boolean);
var stop:byte;
begin
   stop:=0;
   repeat
      stop+=1;
      if(stop=0)then exit;
      if(next)
      then brush^:=chr(byte(ord(brush^)+1))
      else brush^:=chr(byte(ord(brush^)-1));
   until(brush^ in sob);
end;

procedure editor_MoveMap(mx,my:shortint);
var x, y,
   cx,cy:integer;
map2:TMapEditorGrid;

begin
   for x:=0 to map_miw do
   for y:=0 to map_miw do
   begin
      cx:=x+mx;
      if(cx<0      )then cx:=map_miw+cx+1;
      if(cx>map_miw)then cx:=cx-map_miw-1;

      cy:=y+my;
      if(cy<0      )then cy:=map_miw+cy+1;
      if(cy>map_miw)then cy:=cy-map_miw-1;

      map2[x,y]:=editor_map[cx,cy];
   end;

   editor_map:=map2;
end;

procedure editor_ViewBorders;
begin
   editor_vx:=mm3i(0,editor_vx,editor_vw-vid_log_w+editor_panel_w);
   editor_vy:=mm3i(0,editor_vy,editor_vw-vid_log_h);
end;

procedure editor_mouse(newx,newy:integer);
begin
   editor_mouse_x :=newx;
   editor_mouse_y :=newy;
   editor_mouse_mx:=editor_vx+newx-editor_panel_w;
   editor_mouse_my:=editor_vy+newy;
   editor_mouse_gx:=editor_mouse_mx div editor_grid_w;
   editor_mouse_gy:=editor_mouse_my div editor_grid_w;
   if(editor_mouse_mx<0)then editor_mouse_gx-=1;
   if(editor_mouse_my<0)then editor_mouse_gy-=1;

   editor_panel_b:=-1;
   if (0<=editor_mouse_y)and(editor_mouse_y<=vid_log_h)
   and(0<=editor_mouse_x)and(editor_mouse_x<=editor_panel_w)then editor_panel_b:=editor_mouse_y div editor_panel_w;
end;

procedure editor_ReCalcMapW;
begin
   editor_vw:=editor_grid_w*map_mw;
   editor_ViewBorders;
   editor_mouse(editor_mouse_x,editor_mouse_y);
end;

procedure editor_LoadMapByN(im:word);
var iw: cardinal;
 ix,iy: integer;
     c: char;
 r,g,b: byte;
begin
   if(im>=g_mapn)then exit;

   editor_mapi:=im;
   editor_panel_mapi:=im;

   fillchar(editor_map,SizeOf(editor_map),mgr_empty);

   ix:=0;
   iy:=0;
   with g_maps[im] do
   begin
      r:=(hex2b(mbuff[1 ]) shl 4)+hex2b(mbuff[2 ]);
      g:=(hex2b(mbuff[3 ]) shl 4)+hex2b(mbuff[4 ]);
      b:=(hex2b(mbuff[5 ]) shl 4)+hex2b(mbuff[6 ]);
      editor_ceil_color:=ColorRGBA(r,g,b,255);
      r:=(hex2b(mbuff[7 ]) shl 4)+hex2b(mbuff[8 ]);
      g:=(hex2b(mbuff[9 ]) shl 4)+hex2b(mbuff[10]);
      b:=(hex2b(mbuff[11]) shl 4)+hex2b(mbuff[12]);
      editor_floor_color:=ColorRGBA(r,g,b,255);

      for iw:=13 to MaxMapBuffer do
      begin
         c:=mbuff[iw];

         if(c=#0)or(iy>map_miw)then break;

         if(c in mgr_bwalls)
         or(c in mgr_decors)
         or(c in mgr_spawns)
         or(c in mgr_items )
         or(c =  mgr_door  )
         then editor_map[ix,iy]:=c;

         ix+=1;
         if(mbuff[iw]=str_NewLineChar)or(ix>map_miw)then
         begin
            ix:=0;
            iy+=1;
         end;
      end;
   end;
end;

procedure editor_init;
begin
   editor_vx:=0;
   editor_vy:=0;

   editor_grid_w :=64;
   editor_grid_hw:=editor_grid_w div 2;

   editor_ReCalcMapW;

   editor_vspeed:=15;

   editor_LoadMapByN(editor_mapi);
end;


