

procedure initColors;
begin
   c_white := _RGBA(255,255,255,255);
   c_black := _RGBA(0  ,0  ,0  ,255);
   c_ablack:= _RGBA(0  ,0  ,0  ,128);
   c_gray  := _RGBA(128,128,128,255);
   c_dgray := _RGBA(80 ,80 ,80 ,255);
   c_ltgray:= _RGBA(200,200,200,255);
   c_red   := _RGBA(255,0  ,0  ,255);
   c_ltred := _RGBA(255,128,128,255);
   c_blue  := _RGBA(0  ,0  ,255,255);
   c_ltblue:= _RGBA(128,128,255,255);
   c_aqua  := _RGBA(0  ,255,255,255);
   c_daqua := _RGBA(0  ,64 ,64 ,255);
   c_green := _RGBA(0  ,200,0  ,255);
   c_lgreen:= _RGBA(128,200,128,255);
   c_lime  := _RGBA(0  ,255,0  ,255);
   c_ltlime:= _RGBA(128,255,128,255);
   c_ddred := _RGBA(90 ,0  ,0  ,255);
   c_dred  := _RGBA(150,0  ,0  ,255);
   c_orange:= _RGBA(255,150,20 ,255);
   c_yellow:= _RGBA(255,255,0  ,255);
   c_sred  := _RGBA(120,0  ,0  ,255);
   c_purple:= _RGBA(255,0  ,255,255);
   c_console:=_RGBA(0  ,0  ,0  ,198);

   team_color[0]:=@c_ltblue;
   team_color[1]:=@c_lgreen;
   team_color[2]:=@c_orange;
   team_color[3]:=@c_white;

   menu_scol [false]:=@c_ltgray;
   menu_scol [true ]:=@c_white;

   menu_scol2[false]:=@c_yellow;
   menu_scol2[true ]:=@c_white;
end;

procedure CalcMenuVars;
begin
   hud_rcw_charn:= vid_log_w div font_w;
   hud_chat_y   := vid_log_rh-font_h;
   hud_rch_lines:=(hud_chat_y div font_lh)-1;

   menu_font_w:=round(font_w*menu_font_scale);
   menu_font_h:=round(font_h*menu_font_scale);

   menu_ystep:=menu_font_h+(menu_font_h div 2);

   vid_log_mtx:=vid_log_hw+menu_font_w*2;

   m_DRectX0 := vid_log_w div 8;
   m_DRectX1 := vid_log_w-m_DRectX0;
   m_DRectY0 := menu_ystep*3+(menu_font_h div 2);
   m_DRectY1 := vid_log_h-m_DRectY0;
   m_DRectW  := m_DRectX1-m_DRectX0;
   m_DRectH  := m_DRectY1-m_DRectY0;

   menu_ctrls_str1:= m_DRectY1+menu_ystep;
   menu_ctrls_str2:= m_DRectY1+menu_ystep*2;

   menu_inscr:=(m_DRectH-menu_font_h*3) div menu_ystep;
end;

procedure CalcRCResolution;
begin
   if(_rctexture<>nil)
   then SDL_DestroyTexture(_rctexture);
   _rctexture:=SDL_CreateTexture(_renderer,SDL_PIXELFORMAT_RGBA8888,SDL_TEXTUREACCESS_STREAMING,vid_rw,vid_rh);

   if(ZBuffer<>nil)
   then freemem(ZBuffer,ZBuffer_size);
   ZBuffer_size:=SizeOf(Single)*vid_rw;
   ZBuffer     :=getmem(ZBuffer_size);

   if(rc_buffer<>nil)
   then freemem(rc_buffer,rc_buffer_size);

   rc_pitch      :=vid_rw*vid_bppb;
   rc_buffer_size:=rc_pitch*vid_rh;
   rc_buffer     :=getmem(rc_buffer_size);

   vid_iw        := vid_rw-1;
   vid_ih        := vid_rh-1;
   vid_rhw       := vid_rw div 2;
   vid_rhh       := vid_rh div 2;
   vid_scx       := vid_rw/112;
   vid_scy       := vid_rh/64;
   rc_cxt        := 2/vid_rw;
end;

procedure SetRCResolution(w,h:integer);
begin
   vid_rw:=w;
   vid_rh:=h;
   CalcRCResolution;
end;

procedure RCResolutionNext(next:boolean);
const resn = 7;
      resw : array[1..resn] of integer = (160,240,320,480,640,720,800);
var i,
resc:integer;
begin
   resc:=0;
   i   :=1;

   for i:=1 to resn do
    if(resw[i]=vid_rw)then
    begin
       resc:=i;
       break;
    end;

   if(next)
   then resc+=1
   else resc-=1;
   if(resc<1   )then resc:=resn;
   if(resc>resn)then resc:=1;

   SetRCResolution(resw[resc], round(resw[resc]/vid_aspect) );
end;

procedure ScreenMake;
const _vflags   = SDL_WINDOW_RESIZABLE;
      _vflags_f : array[false..true] of cardinal = (_vflags,_vflags+ SDL_WINDOW_FULLSCREEN);
begin
   if(_window=nil)then
   begin
      _window := SDL_CreateWindow(str_wcaption, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, window_w, window_h, _vflags_f[vid_fullscreen]);
      if(_window=nil)then begin WriteSDLError('SDL_CreateWindow'); halt; end;
   end;

   _renderer := SDL_CreateRenderer(_window, -1,SDL_RENDERER_ACCELERATED or SDL_RENDERER_TARGETTEXTURE);

   SDL_RenderSetLogicalSize(_renderer,vid_log_w, vid_log_h);

   vid_hud_scale := vid_log_w/320;
   vid_panelh    := trunc(32*vid_hud_scale);
   vid_log_rh    := vid_log_h-vid_panelh;
   vid_log_rih   := vid_log_rh-1;
   hud_pl_staty0 := vid_log_rh-40;
   hud_pl_staty1 := vid_log_rh-20;

   hud_gbrc_x    := hud_gborder_w;
   hud_gbrc_y    := hud_gborder_w;
   hud_gbrc_w    := vid_log_w-(hud_gborder_w*2);
   hud_gbrc_h    := vid_log_h-(vid_panelh+hud_gborder_w*2);
   hud_weapon_y  := vid_log_h-vid_panelh-hud_gborder_w;

   vid_aspect    := vid_log_w/vid_log_h;
   vid_aspecti   := trunc(vid_aspect*100);

   hud_txtyscale := vid_hud_scale*1.9;
   hud_fscale    := vid_hud_scale*1.3;
   hud_ifscale   := vid_hud_scale*0.8;
   hud_invix     := round(vid_hud_scale*12);
   hud_texty     := vid_log_rh+trunc(14*vid_hud_scale);
   hud_scorex    := trunc(40 *vid_hud_scale);
   hud_hitsx     := trunc(80 *vid_hud_scale);
   hud_armorx    := trunc(128*vid_hud_scale);
   hud_ammox     := trunc(213*vid_hud_scale);
   hud_invx      := trunc(262*vid_hud_scale);
   hud_invy      := vid_log_rh+trunc(4*vid_hud_scale);
   hud_gunx      := trunc(266*vid_hud_scale);
   hud_guny      := vid_log_rh+trunc(9*vid_hud_scale);
   hud_teamx     := trunc(238*vid_hud_scale);
   hud_teamy     := vid_log_rh+trunc(14*vid_hud_scale);
   hud_hudhx     := trunc(146*vid_hud_scale);
   hud_hudhy     := vid_log_rh+trunc(1*vid_hud_scale)+1;

   SetRCResolution(vid_rw,vid_rh);
end;

procedure ScreenToggleWindowed;
const _vflags_f : array[false..true] of cardinal = (0, SDL_WINDOW_FULLSCREEN);
begin
   vid_fullscreen:=not vid_fullscreen;

   SDL_SetWindowFullscreen(_window,_vflags_f[vid_fullscreen]);

   if(game_mode=gm_menu)then menu_update:=true;
end;

procedure GFXDirNext(next:boolean);
begin
   if(vid_agraph_dirn<=1)then exit;

   if(next)then
   begin
      vid_agraph_dirs+=1;
      vid_agraph_dirs:=vid_agraph_dirs mod vid_agraph_dirn;
   end
   else
     if(vid_agraph_dirs=0)
     then vid_agraph_dirs:=vid_agraph_dirn-1
     else vid_agraph_dirs-=1;
end;

function SDL_GETpixel(srf:PSDL_SURFACE;x,y:integer):cardinal;
var bpp:byte;
begin
   SDL_GETpixel:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;

   move( (srf^.pixels+(y*srf^.pitch)+x*bpp)^, (@SDL_GETpixel)^, bpp);
end;

function SDL_GetColorForRC(srf:PSDL_SURFACE;x,y:integer;cof:single):cardinal;
var r,g,b,c:cardinal;
    bpp:integer;
begin
   SDL_GetColorForRC:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;
   move( (srf^.pixels+(y*srf^.pitch)+x*bpp)^, (@c)^, bpp);

   r:=c and srf^.format^.Rmask;
   r:=r shr srf^.format^.Rshift;
   r:=r shl srf^.format^.Rloss;

   g:=c and srf^.format^.Gmask;
   g:=g shr srf^.format^.Gshift;
   g:=g shl srf^.format^.Gloss;

   b:=c and srf^.format^.Bmask;
   b:=b shr srf^.format^.Bshift;
   b:=b shl srf^.format^.Bloss;

   SDL_GetColorForRC:=rgba2c(trunc(r*cof),trunc(g*cof),trunc(b*cof),255);
end;

function loadSurfEXT(fn:shortstring):pSDL_Surface;
begin
   loadSurfEXT:=nil;
   if(not FileExists(fn))then exit;
   fn:=fn+#0;
   loadSurfEXT:=img_load(@fn[1]);
end;

function loadSurf(fn:shortstring):pSDl_Surface;
const fexts : array[0..2] of shortstring = ('.png','.jpg','.bmp');
      fextn = 2;
var i:integer;
    s:shortstring;
begin
   loadSurf:=nil;

   s:=vid_agraph_dirl[vid_agraph_dirs]+'\';
   if(length(s)>1)and(s<>str_graphic_dir)then
    for i:=0 to fextn do
    begin
       loadSurf:=loadSurfEXT(s+fn+fexts[i]);
       if(loadSurf<>nil)then exit;
    end;

   for i:=0 to fextn do
   begin
      loadSurf:=loadSurfEXT(str_graphic_dir+fn+fexts[i]);
      if(loadSurf<>nil)then exit;
   end;
end;

procedure _freeST(target:PTImage);
begin
   with target^ do
   begin
      if (surface<>nil)
      and(surface<>_dtimage.surface)then SDL_FreeSurface(surface);
      if (texture<>nil)
      and(texture<>_dtimage.texture)then SDL_DestroyTexture(texture);
   end;
end;

procedure loadIMG(target:PTImage;fn:shortstring;trns,log,reload:boolean);
var ts:pSDL_Surface;
begin
   if(reload)then _freeST(target);
   target^:=_dtimage;

   ts:=loadSurf(fn);
   if(ts<>nil)then
   with target^ do
   begin
      if(trns)then SDL_SetColorKey(ts,1,SDL_GETpixel(ts,0,0));
      texture:=SDL_CreateTextureFromSurface(_renderer,ts);
      w  :=ts^.w;
      h  :=ts^.h;
      hw :=w div 2;
      hh :=h div 2;
      surface:=ts;
      if(trns=false)
      then SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_BLEND)
      else SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_NONE );
   end
   else
     if(log)then WriteLog(fn);
end;

procedure LoadWall(fn:shortstring;tt,dt:PTRCWall);
var sur:pSDL_SURFACE;
    x,y,
    w,h:word;
begin
   sur:=loadSurf(fn);
   if(sur=nil)then
   begin
      if(tt<>nil)then begin tt^.rcw:=1;tt^.rch:=1;end;
      if(dt<>nil)then begin dt^.rcw:=1;dt^.rch:=1;end;
      exit;
   end;
   w:=sur^.w;
   h:=sur^.h;
   if(w>rc_tex_w)then w:=rc_tex_w;
   if(h>rc_tex_w)then h:=rc_tex_w;
   if(tt<>nil)then begin tt^.rcw:=w;tt^.rch:=h;end;
   if(dt<>nil)then begin dt^.rcw:=w;dt^.rch:=h;end;
   for x:=0 to w-1 do
   for y:=0 to h-1 do
   begin
      if(tt<>nil)then tt^.texture[x,y]:=SDL_GetColorForRC(sur,x,y,1  );
      if(dt<>nil)then dt^.texture[x,y]:=SDL_GetColorForRC(sur,x,y,0.3);
   end;
   SDL_FREESURFACE(sur);
end;

procedure LoadSprite(fn:shortstring;spr:PTSprite);
var bmp:pSDL_SURFACE;
    x,y:byte;
    w,h:integer;
begin
   spr^.w:=1;
   spr^.h:=1;
   bmp:=loadSurf(fn);
   if(bmp=nil)then exit;
   w:=bmp^.w;
   h:=bmp^.h;
   if(rc_spr_w<w)then w:=rc_spr_w;
   if(rc_spr_w<h)then h:=rc_spr_w;
   spr^.w:=w;
   spr^.h:=h;
   for x:=0 to w-1 do
    for y:=0 to h-1 do
     spr^.p[x,y]:=SDL_GetColorForRC(bmp,x,y,1);
   SDL_FREESURFACE(bmp);
   with spr^ do
   begin
      pf:=p[0,0];
      sm:=0;
      if(pf=c_purple.c)then sm:= 1-(h/rc_spr_w);
      if(pf=c_black.c )then sm:=(1-(h/rc_spr_w))/2;
   end;
end;

procedure loadHUDnf(fn:shortstring;reload:boolean);
var i:byte;
    c:char;
 fspr:TImage;
begin
   loadIMG(@fspr,fn,false,true,false);
   spr_HUDnfw:=8;
   spr_HUDnfh:=max2(1,fspr.h);
   i:=0;
   for c:='0' to ';' do
   with spr_HUDnf[c] do
   begin
      if(reload)then _freeST(@spr_HUDnf[c]);

      surface:=sdl_createRGBSurface(0,spr_HUDnfw,spr_HUDnfh,vid_bpp,0,0,0,0);
      SDL_FillRect(surface,nil,0);

      _rect^.x:=i*spr_HUDnfw;
      _rect^.y:=0;
      _rect^.w:=spr_HUDnfw;
      _rect^.h:=spr_HUDnfh;

      SDL_BLITSURFACE(fspr.surface,_rect,surface,nil);

      texture:=SDL_CreateTextureFromSurface(_renderer,surface);
      w :=font_w;
      h :=w;
      hw:=font_w div 2;
      hh:=hw;

      i+=1;
   end;

   _freeST(@fspr);
end;

procedure LoadFont(fn:shortstring;reload:boolean);
var i:byte;
    c:char;
  ccc:cardinal;
 fspr:TImage;
begin
   loadIMG(@fspr,fn,false,true,false);

   font_w :=max2(1,fspr.w div 256);
   font_h :=max2(1,fspr.h);
   font_lh:=font_h+2;
   font_hh:=font_h div 2;

   scboard_sx :=font_w*5;
   scboard_sy :=font_lh*2;
   scboard_btw:=font_w*25;
   scboard_name_w:=font_w*NameLen+font_w*2;
   scboard_frag_w:=font_w*length(str_sb_frags)+font_w;
   scboard_ping_w:=font_w*length(str_sb_ping)+font_w;
   scboard_col_w :=scboard_name_w+scboard_frag_w+scboard_ping_w+font_w*6;
   scboard_col_bh:=font_lh*42;

   ccc :=sdl_getpixel(fspr.surface,0,0);
   for i:=0 to 255 do
   begin
      c:=chr(i);
      if(reload)then _freeST(@font_ca[c]);
      with font_ca[c] do
      begin
         surface:=sdl_createRGBSurface(0,font_w,font_h,vid_bpp,0,0,0,0);
         SDL_FillRect(surface,nil,0);

         _rect^.x:=ord(i)*font_w;
         _rect^.y:=0;
         _rect^.w:=font_w;
         _rect^.h:=font_h;

         SDL_BLITSURFACE(fspr.surface,_rect,surface,nil);
         SDL_SetColorKey(surface,1,ccc);

         texture:=SDL_CreateTextureFromSurface(_renderer,surface);
         w :=font_w;
         h :=w;
         hw:=font_h div 2;
         hh:=hw;
      end;
   end;

   _freeST(@fspr);
end;

procedure LoadGFX(reload:boolean);
const mingunflash = fr_fps div 6;
var c:char;
  i,o:byte;
begin
   if(not reload)then
   begin
      with _dtimage do
      begin
         w :=1;
         h :=1;
         hw:=1;
         hh:=1;
         surface:=sdl_createRGBSurface(0,w,h,vid_bpp,0,0,0,0);
         texture:=SDL_CreateTextureFromSurface(_renderer,surface);
      end;

      initColors;

      for i:=1 to MaxVisSprites do new(map_vspr[i]);

      for i:=0 to WeaponsN do
      begin
         if(gun_reload[i]<mingunflash)
         then gun_ganim[i]:=max2(1,gun_reload[i] div 2)
         else gun_ganim[i]:=max2(3,gun_reload[i]-mingunflash);
         gun_sanim[i]:=max2(0,gun_ganim[i]-(fr_fps div 4));
      end;

   end;

   loadHUDnf('hudnf',reload);
   LoadFont ('font' ,reload);

   CalcMenuVars;

   LoadWall('wdt',@spr_wdt[0],@spr_wdt[1]);
   LoadWall('wd0',@spr_wd0[0],@spr_wd0[1]);
   for c:='A' to 'Z' do LoadWall  ('w' +c,@spr_wt[0,c],@spr_wt[1,c]);
   for c:='a' to 'z' do LoadSprite('d' +c,@spr_dt[c  ]);
   for c:='0' to '9' do LoadSprite('it'+c,@spr_it[c  ]);

   for i:=0 to 2 do
   for o:=0 to 3 do LoadSprite('e'+b2s(i)+'_'+b2s(o),@spr_ef[i,3-o]);

   for i:=0 to WeaponsN do
   begin
      loadIMG(@spr_hudw[i],'hud_w'+b2s(i+1),true,true,reload);
      for o:=0 to 1 do
      begin
         loadIMG(@spr_HUDgun[i,o],'hud_g'+b2s(i+1)+'_'+b2s(o),true,true,reload);
         spr_HUDgunX[i,o]:=vid_log_hw-round(spr_HUDgun[i,o].w*vid_hud_scale) div 2;
         spr_HUDgunY[i,o]:=hud_weapon_y-trunc(spr_HUDgun[i,o].h*vid_hud_scale);
      end;
   end;

   for i:=0 to MaxTeamsI  do
   begin
      for o:=0 to SkinSprites do LoadSprite('skin_'+b2s(i)+'_'+b2s(o),@spr_ps[i,o]);
      loadIMG(@spr_hudt[i],'hud_team_'+b2s(i),true,true,reload);
   end;

   for i:=0 to 22 do loadIMG(@spr_hudh[i],'h'+b2s(i),true,true,reload);

   loadIMG(@spr_hudpanel,'hudpanel',false,true,reload);
end;
