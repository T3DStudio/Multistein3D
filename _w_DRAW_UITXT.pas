

function logID2Color(lid:byte):PTColor;
begin
   logID2Color:=@c_white;
   case lid of
   log_common     : ;
   log_chat       : logID2Color:=@c_ltlime;
   log_matchreset,
   log_winner,
   log_endgame    : logID2Color:=@c_yellow;
   log_suddendeath: logID2Color:=@c_red;
   log_map        : logID2Color:=@c_orange;
   log_local      : logID2Color:=@c_gray;
   log_roomdata   : logID2Color:=@c_aqua;
   end;
end;

procedure draw_console(onlylastlog,scroll:word);
var
dx,dy,p: integer;
w      : word;
procedure _addLine(str:shortstring;col:PTColor);
const passhidecmd : shortstring = 'rcon_password ';
var i,l:byte;
begin
   hud_textln+=1;
   if(hud_textln<scroll)
   or(hud_textn>hud_rch_lines)then exit;

   if(pos(passhidecmd,str)=1)then
   begin
      l:=length(str);
      i:=length(passhidecmd)+1;
      while(i<l)do
      begin
         str[i]:='*';
         i+=1;
      end;
   end;

   if(col=nil)then col:=@c_white;
   hud_textn+=1;
   setlength(hud_text ,hud_textn);
   setlength(hud_textc,hud_textn);
   hud_text [hud_textn-1]:=str;
   hud_textc[hud_textn-1]:=col;
end;
procedure _addStr(str:shortstring;col:PTColor);
var l:byte;
begin
   l:=length(str);
   while true do
    if(l<=hud_rcw_charn)then
    begin
       _addLine(str,col);
       break;
    end
    else
    begin
       _addLine(copy(str,1,hud_rcw_charn),col);
       delete(str,1,hud_rcw_charn);
       l-=hud_rcw_charn;
    end;
end;
begin
   hud_textln:=0;
   hud_textn :=0;
   setlength(hud_text ,hud_textn);
   setlength(hud_textc,hud_textn);

   w:=sv_clroom^.log_i;
   if(onlylastlog>0)then
     while(onlylastlog>0)do
     begin
        with sv_clroom^ do
          with log_l[w] do
           _addStr(data_string,logID2Color(data_id));

        onlylastlog-=1;
        if(w>0)
        then w-=1
        else w:=MaxRoomLog;
     end
   else
   begin
      for p:=0 to MaxRoomLog do
      begin
         w+=1;
         if(w>MaxRoomLog)then w:=0;
         with sv_clroom^ do
           with log_l[w] do
             _addStr(data_string,logID2Color(data_id));
      end;
      _addStr(console_str+lineCursorBlink,logID2Color(log_chat));
   end;

   dx:=0;
   dy:=4;
   if(hud_textn>0)then
   begin
      draw_box(0,0,vid_w,hud_textn*font_lh+dy,@c_console,true);
      for p:=0 to hud_textn-1 do
      begin
         draw_text(dx,dy,1,hud_text[p],ta_left,hud_textc[p],nil);
         dy+=font_lh;
      end;
   end;
end;

procedure draw_last_message;
begin
   if(hud_last_mesn>0)then
   begin
      draw_console((hud_last_mesn div hud_last_mess_1msg)+1,0);
      hud_last_mesn-=1;
   end;
end;

procedure draw_scoreboard;
const tt : array[false..true] of char = (' ','>');
var
player_list : array of PTPlayer;
player_listn: byte;
specs_list  : array of PTPlayer;
specs_listn : byte;
player_team,
p,i,t       : byte;
_pl         : PTPlayer;
dx,dy,dx0   : integer;
color       : PTColor;
str         : shortstring;
teams       : array[0..MaxTeamsI] of byte;
procedure draw_line(tx,ty,st:integer;s1,s2:shortstring;scolor:PTColor);
begin
   draw_text(tx   ,ty,1,s1,ta_left ,scolor,nil);
   draw_text(tx+st,ty,1,s2,ta_right,scolor,nil);
end;
function _n(p:byte):char;
begin
   if(p=cam_pl)
   then _n:='>'
   else
     if(p=cl_playeri)
     then _n:='*'
     else _n:=' ';
end;
begin
   player_team:=255;
   if(Room_CheckFlag(sv_clroom,sv_g_teams))and(cl_playeri<=MaxPlayers)then
    with g_players[cam_pl] do
     if(state>ps_spec)
     then player_team:=team
     else player_team:=254;

   setlength(player_list,0);player_listn:=0;
   setlength(specs_list ,0);specs_listn :=0;

   for p:=0 to MaxPlayers do
   begin
      _pl:=@g_players[p];
      if(_pl^.state>ps_spec)then
      begin
         player_listn+=1;
         setlength(player_list,player_listn);
         player_list[player_listn-1]:=_pl;
      end;
      if(_pl^.state=ps_spec)then
      begin
         specs_listn+=1;
         setlength(specs_list,specs_listn);
         specs_list[specs_listn-1]:=_pl;
      end;
   end;

   if(player_listn>1)then
    for p:=0 to player_listn-1 do
     for i:=0 to player_listn-1 do
      if(p<>i)then
      begin
         if(player_list[p]^.frags<player_list[i]^.frags)then continue;
         if(player_list[p]^.frags=player_list[i]^.frags)then
           if(player_list[p]^.pnum<player_list[i]^.pnum)then continue;

         _pl:=player_list[p];
         player_list[p]:=player_list[i];
         player_list[i]:=_pl;
      end;

   draw_box(0,0,vid_w,hud_chat_y,@c_ablack,true);
   dx:=scboard_sx;
   dy:=scboard_sy;

   with sv_clroom^ do
   begin
      color:=@c_ltred;

      draw_line(dx,dy,scboard_btw,str_sb_roomname,rname,color);dy+=font_lh;

      if(cl_playeri<=MaxPlayers)then
      if(server_ping<10000)
      then draw_line(dx,dy,scboard_btw,str_sb_ping,c2s(server_ping),color)
      else draw_line(dx,dy,scboard_btw,str_sb_ping,'???'           ,color);

      dy+=font_lh;

      draw_line(dx,dy,scboard_btw,str_sb_map ,mapname                    ,color);dy+=font_lh;

      if(g_timelimit>0)then
      draw_line(dx,dy,scboard_btw,str_sb_timelimit,TimeStr(0,g_timelimit),color);dy+=font_lh;

      draw_line(dx,dy,scboard_btw,str_sb_time,TimeStr(time_sec,time_min) ,color);dy+=font_lh;

      if(g_fraglimit>0)then
      draw_line(dx,dy,scboard_btw,str_sb_fraglimit,b2s(g_fraglimit),color);

      dy+=font_lh;

      if(time_scorepause>0)and(demo_cstate<>ds_read)then
      draw_line(dx,dy,scboard_btw,str_sb_resettime,b2s((time_scorepause div fr_fpsx1)+1),color);

      dy+=font_lh*2;

      color:=@c_white;

      draw_line(dx,dy,scboard_btw,str_sb_players,b2s(player_listn),color);

      dy+=font_lh*2;

      draw_text(dx,dy,1,str_sb_name ,ta_left ,color,nil);dx+=scboard_name_w;
      draw_text(dx,dy,1,str_sb_frags,ta_left ,color,nil);dx+=scboard_frag_w+scboard_ping_w;
      draw_text(dx,dy,1,str_sb_ping ,ta_right,color,nil);

      dx0:=scboard_sx;
      dx :=dx0;
      dy+=font_lh;

      if(player_team<255)then
      begin
         for p:=0 to MaxTeamsI do teams[p]:=p;

         for p:=0 to MaxTeamsI do
          for i:=0 to MaxTeamsI do
           if(p<>i)then
           begin
              if(team_frags[teams[i]]>team_frags[teams[p]])then continue;
              if(team_frags[teams[i]]=team_frags[teams[p]])then
                if(teams[i]<teams[p])then continue;

              t:=teams[p];
              teams[p]:=teams[i];
              teams[i]:=t;
           end;

         for p:=0 to MaxTeamsI do
         begin
            t:=teams[p];
            dy+=font_lh;

            draw_text(dx,dy,1,tt[t=player_team]+str_teams[t],ta_left,team_color[t],nil);dx+=scboard_name_w;
            draw_text(dx,dy,1,i2s(team_frags[t])            ,ta_left,team_color[t],nil);
            dx:=dx0;
         end;
         dy+=font_lh;
      end;

      if(player_listn>0)then
       for p:=0 to player_listn-1 do
       begin
          dy+=font_lh;
          if(dy>=scboard_col_bh)then
          begin
             dx0+=scboard_col_w;
             dy :=scboard_sy;
             if(dx0>=vid_w)then break;
          end;
          dx:=dx0;

          with player_list[p]^ do
          begin
             if(player_team<255)
             then color:=team_color[team]
             else color:=@c_white;

             if(show_player_id)then
             draw_text(dx-font_w,dy,1,b2s(pnum),ta_right,color,nil);

             draw_text(dx,dy,1,_n(pnum)+name,ta_left ,color,nil);dx+=scboard_name_w;
             draw_text(dx,dy,1,i2s(frags)   ,ta_left ,color,nil);dx+=scboard_frag_w+scboard_ping_w;
             draw_text(dx,dy,1,c2s(ping)    ,ta_right,color,nil);
          end;
       end;

      color:=@c_white;
      dy:=scboard_col_bh+font_lh;

      draw_line(scboard_sx,dy,scboard_btw,str_sb_specs,b2s(specs_listn),color);

      dx:=0;
      dy+=font_lh*2;

      if(specs_listn>0)then
       for p:=0 to specs_listn-1 do
       begin
          with specs_list[p]^ do
           if(show_player_id)
           then str:=b2s(pnum)+':'+name+'('+c2s(ping)+')'
           else str:=name+'('+c2s(ping)+')';
          dx0:=length(str)*font_w+font_w;
          if((dx+dx0)>vid_w)then
          begin
             dx:=0;
             dy+=font_lh;
             if((dy+font_lh)>=hud_chat_y)then break;
             draw_text(dx,dy,1,str,ta_left,color,nil);
          end
          else draw_text(dx,dy,1,str,ta_left,color,nil);
          dx+=dx0;
       end;
   end;
end;


