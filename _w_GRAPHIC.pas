

procedure initColors;
begin
   c_white   := ColorRGBA(255,255,255,255);
   c_black   := ColorRGBA(0  ,0  ,0  ,255);
   c_ablack  := ColorRGBA(0  ,0  ,0  ,128);
   c_gray    := ColorRGBA(128,128,128,255);
   c_dgray   := ColorRGBA(80 ,80 ,80 ,255);
   c_ltgray  := ColorRGBA(200,200,200,255);
   c_red     := ColorRGBA(255,0  ,0  ,255);
   c_ltred   := ColorRGBA(255,128,128,255);
   c_blue    := ColorRGBA(0  ,0  ,255,255);
   c_ltblue  := ColorRGBA(128,128,255,255);
   c_aqua    := ColorRGBA(0  ,255,255,255);
   c_daqua   := ColorRGBA(0  ,64 ,64 ,255);
   c_green   := ColorRGBA(0  ,200,0  ,255);
   c_lgreen  := ColorRGBA(128,200,128,255);
   c_lime    := ColorRGBA(0  ,255,0  ,255);
   c_ltlime  := ColorRGBA(128,255,128,255);
   c_ddred   := ColorRGBA(90 ,0  ,0  ,255);
   c_dred    := ColorRGBA(150,0  ,0  ,255);
   c_orange  := ColorRGBA(255,150,20 ,255);
   c_yellow  := ColorRGBA(255,255,0  ,255);
   c_sred    := ColorRGBA(120,0  ,0  ,255);
   c_purple  := ColorRGBA(255,0  ,255,255);
   c_console := ColorRGBA(0  ,0  ,0  ,198);

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
   hud_rcw_charn  := vid_log_w div font_w;
   hud_chat_y     := vid_log_rh-font_h;
   hud_rch_lines  :=(hud_chat_y div font_lh)-1;

   menu_font_w    := round(font_w*menu_font_scale);
   menu_font_h    := round(font_h*menu_font_scale);

   menu_ystep     := menu_font_h+(menu_font_h div 2);

   vid_log_mtx    := vid_log_hw+menu_font_w*2;

   m_DRectX0      := vid_log_w div 8;
   m_DRectX1      := vid_log_w-m_DRectX0;
   m_DRectY0      := menu_ystep*3+(menu_font_h div 2);
   m_DRectY1      := vid_log_h-m_DRectY0;
   m_DRectW       := m_DRectX1-m_DRectX0;
   m_DRectH       := m_DRectY1-m_DRectY0;

   menu_ctrls_str1:= m_DRectY1+menu_ystep;
   menu_ctrls_str2:= m_DRectY1+menu_ystep*2;

   menu_inscr     :=(m_DRectH-menu_font_h*3) div menu_ystep;
end;

procedure CalcRCResolution;
begin
   if(vid_rctexture<>nil)
   then SDL_DestroyTexture(vid_rctexture);
   vid_rctexture:=SDL_CreateTexture(vid_renderer,SDL_PIXELFORMAT_RGBA8888,SDL_TEXTUREACCESS_STREAMING,vid_rw,vid_rh);

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
const sdl_windows_flags   = SDL_WINDOW_RESIZABLE;
      sdl_windows_flags_f : array[false..true] of cardinal = (sdl_windows_flags,sdl_windows_flags+SDL_WINDOW_FULLSCREEN);
begin
   if(vid_window=nil)then
   begin
      vid_window := SDL_CreateWindow(str_wcaption, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, window_w, window_h, sdl_windows_flags_f[vid_fullscreen]);
      if(vid_window=nil)then begin WriteSDLError('SDL_CreateWindow'); halt; end;
   end;

   vid_renderer := SDL_CreateRenderer(vid_window, -1,SDL_RENDERER_ACCELERATED or SDL_RENDERER_TARGETTEXTURE);

   SDL_RenderSetLogicalSize(vid_renderer,vid_log_w, vid_log_h);

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

   hud_txt_yscale:= vid_hud_scale*1.9;
   hud_fscale    := vid_hud_scale*1.3;
   hud_ifscale   := vid_hud_scale*0.74;
   hud_texty     := vid_log_rh+trunc(14*vid_hud_scale);
   hud_scorex    := trunc(40 *vid_hud_scale);
   hud_hitsx     := trunc(80 *vid_hud_scale);
   hud_armorx    := trunc(128*vid_hud_scale);
   hud_ammox     := trunc(213*vid_hud_scale);
   hud_invx      := trunc(262*vid_hud_scale);
   hud_invy      := vid_log_rh+trunc(4*vid_hud_scale);
   hud_invix     := round(hud_ifscale*9.5);
   hud_gunx      := trunc(266*vid_hud_scale);
   hud_guny      := vid_log_rh+trunc(9*vid_hud_scale);
   hud_teamx     := trunc(238*vid_hud_scale);
   hud_teamy     := vid_log_rh+trunc(14*vid_hud_scale);
   hud_hudhx     := trunc(146*vid_hud_scale);
   hud_hudhy     := vid_log_rh+trunc(1*vid_hud_scale)+1;

   SetRCResolution(vid_rw,vid_rh);
end;

procedure ScreenToggleWindowed;
const sdl_windows_flags_f : array[false..true] of cardinal = (0, SDL_WINDOW_FULLSCREEN);
begin
   vid_fullscreen:=not vid_fullscreen;

   SDL_SetWindowFullscreen(vid_window,sdl_windows_flags_f[vid_fullscreen]);

   if(cl_mode=clm_menu)then menu_update:=true;
end;

procedure GFXDirNext(next:boolean);
begin
   if(vid_agraph_dir_n<=1)then exit;

   if(next)then
   begin
      vid_agraph_dir_sel+=1;
      vid_agraph_dir_sel:=vid_agraph_dir_sel mod vid_agraph_dir_n;
   end
   else
     if(vid_agraph_dir_sel=0)
     then vid_agraph_dir_sel:=vid_agraph_dir_n-1
     else vid_agraph_dir_sel-=1;
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
   c:=0;

   if(x<0)or(srf^.w<=x)
   or(y<0)or(srf^.h<=y)then exit;

   bpp:=srf^.format^.BytesPerPixel;
   move( (srf^.pixels+(y*srf^.pitch)+x*bpp)^, c, bpp);

   r:=c and srf^.format^.Rmask;
   r:=r shr srf^.format^.Rshift;
   r:=r shl srf^.format^.Rloss;

   g:=c and srf^.format^.Gmask;
   g:=g shr srf^.format^.Gshift;
   g:=g shl srf^.format^.Gloss;

   b:=c and srf^.format^.Bmask;
   b:=b shr srf^.format^.Bshift;
   b:=b shl srf^.format^.Bloss;

   SDL_GetColorForRC:=RGBA2Card(trunc(r*cof),trunc(g*cof),trunc(b*cof),255);
end;

function loadSurfEXT(fn:shortstring):pSDL_Surface;
begin
   loadSurfEXT:=nil;
   if(not FileExists(fn))then exit;
   fn:=fn+#0;
   loadSurfEXT:=img_load(@fn[1]);
end;

function loadSurf(fn:shortstring):pSDl_Surface;
const fextn = 2;
      fexts : array[0..fextn] of shortstring = ('.png','.jpg','.bmp');
var i:integer;
    s:shortstring;
begin
   loadSurf:=nil;

   s:=vid_agraph_dir_l[vid_agraph_dir_sel]+str_PathSlash;
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

procedure freeImage(target:PTImage);
begin
   with target^ do
   begin
      if (surface<>nil)
      and(surface<>vid_dtimage.surface)then SDL_FreeSurface(surface);
      if (texture<>nil)
      and(texture<>vid_dtimage.texture)then SDL_DestroyTexture(texture);
   end;
end;

procedure loadImage(target:PTImage;fn:shortstring;trans,log,reload:boolean);
var ts:pSDL_Surface;
begin
   if(reload)then freeImage(target);
   target^:=vid_dtimage;

   ts:=loadSurf(fn);
   if(ts<>nil)then
   with target^ do
   begin
      if(trans)then SDL_SetColorKey(ts,1,SDL_GETpixel(ts,0,0));
      texture:=SDL_CreateTextureFromSurface(vid_renderer,ts);
      w  :=ts^.w;
      h  :=ts^.h;
      hw :=w div 2;
      hh :=h div 2;
      surface:=ts;
      if(trans)
      then SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_NONE )
      else SDL_SetTextureBlendMode(texture,SDL_BLENDMODE_BLEND);
   end
   else
     if(log)then WriteLog(fn);
end;

procedure LoadRCImage(fn:shortstring;pRCImageL,pRCImageD:pTRCImage;transparent:boolean);
var surface:pSDL_SURFACE;
    x,y,
    w,h    :word;
procedure DefaultRCImage(pRCImage:pTRCImage);
begin
   with pRCImage^ do
   begin
      rc_w:=1;rc_hw:=0;
      rc_h:=1;rc_hh:=0;
      sdltexture:=nil;
      fillchar(rctexture,SizeOf(rctexture),0);
      rc_z:=0;
      trunsColor:=0;
   end;
end;
procedure ApplyRCImage(pRCImage:pTRCImage);
begin
   with pRCImage^ do
   begin
      rc_w :=w;
      rc_hw:=rc_w div 2;
      rc_h :=h;
      rc_hh:=rc_h div 2;

      if(transparent)then
      begin
         SDL_SetColorKey(surface,1,SDL_GETpixel(surface,0,0));
         sdltexture:=SDL_CreateTextureFromSurface(vid_renderer,surface);
         SDL_SetTextureBlendMode(sdltexture,SDL_BLENDMODE_BLEND);
         trunsColor:=rctexture[0,0];
      end
      else
      begin
         sdltexture:=SDL_CreateTextureFromSurface(vid_renderer,surface);
         trunsColor:=trunsColor.MaxValue;
      end;

      rc_z      :=0;
      if(trunsColor=c_purple.c)then rc_z:= 1-(rc_h/rc_SpriteHeight);
      if(trunsColor=c_black.c )then rc_z:=(1-(rc_h/rc_SpriteHeight))/2;
   end;
end;
begin
   surface:=loadSurf(fn);
   if(surface=nil)then
   begin
      if(pRCImageL<>nil)then DefaultRCImage(pRCImageL);
      if(pRCImageD<>nil)then DefaultRCImage(pRCImageD);
      exit;
   end;
   w:=surface^.w;
   h:=surface^.h;
   if(w>rc_Texture_w)then w:=rc_Texture_w;
   if(h>rc_Texture_w)then h:=rc_Texture_w;
   for x:=0 to w-1 do
   for y:=0 to h-1 do
   begin
      if(pRCImageL<>nil)then pRCImageL^.rctexture[x,y]:=SDL_GetColorForRC(surface,x,y,1  );
      if(pRCImageD<>nil)then pRCImageD^.rctexture[x,y]:=SDL_GetColorForRC(surface,x,y,0.3);
   end;
   if(pRCImageL<>nil)then ApplyRCImage(pRCImageL);
   if(pRCImageD<>nil)then ApplyRCImage(pRCImageD);
   SDL_FREESURFACE(surface);
end;


procedure loadHUDfont(fn:shortstring;reload:boolean);
var i : byte;
    c : char;
 fspr : TImage;
begin
   loadImage(@fspr,fn,false,true,false);
   spr_HUDfont_w:=8;
   spr_HUDfunt_h:=max2(1,fspr.h);
   i:=0;
   for c:='0' to ';' do
   with spr_HUDfont[c] do
   begin
      if(reload)then freeImage(@spr_HUDfont[c]);

      surface:=sdl_createRGBSurface(0,spr_HUDfont_w,spr_HUDfunt_h,vid_bpp,0,0,0,0);
      SDL_FillRect(surface,nil,0);

      vid_rect^.x:=i*spr_HUDfont_w;
      vid_rect^.y:=0;
      vid_rect^.w:=spr_HUDfont_w;
      vid_rect^.h:=spr_HUDfunt_h;

      SDL_BLITSURFACE(fspr.surface,vid_rect,surface,nil);

      texture:=SDL_CreateTextureFromSurface(vid_renderer,surface);
      w :=font_w;
      h :=w;
      hw:=font_w div 2;
      hh:=hw;

      i+=1;
   end;

   freeImage(@fspr);
end;

procedure LoadBaseFont(fn:shortstring;reload:boolean);
var i:byte;
    c:char;
  ccc:cardinal;
 fspr:TImage;
begin
   loadImage(@fspr,fn,false,true,false);

   font_w :=max2(1,fspr.w div 256);
   font_h :=max2(1,fspr.h);
   font_lh:=font_h+2;
   font_hh:=font_h div 2;

   scboard_sx    :=font_w*5;
   scboard_sy    :=font_lh*2;
   scboard_btw   :=font_w*25;
   scboard_name_w:=font_w*NameLen+font_w*2;
   scboard_frag_w:=font_w*length(str_sb_frags)+font_w;
   scboard_ping_w:=font_w*length(str_sb_ping)+font_w;
   scboard_col_w :=scboard_name_w+scboard_frag_w+scboard_ping_w+font_w*6;
   scboard_col_bh:=font_lh*42;

   ccc :=sdl_getpixel(fspr.surface,0,0);
   for i:=0 to 255 do
   begin
      c:=chr(i);
      if(reload)then freeImage(@font_ca[c]);
      with font_ca[c] do
      begin
         surface:=sdl_createRGBSurface(0,font_w,font_h,vid_bpp,0,0,0,0);
         SDL_FillRect(surface,nil,0);

         vid_rect^.x:=ord(i)*font_w;
         vid_rect^.y:=0;
         vid_rect^.w:=font_w;
         vid_rect^.h:=font_h;

         SDL_BLITSURFACE(fspr.surface,vid_rect,surface,nil);
         SDL_SetColorKey(surface,1,ccc);

         texture:=SDL_CreateTextureFromSurface(vid_renderer,surface);
         w :=font_w;
         h :=w;
         hw:=font_h div 2;
         hh:=hw;
      end;
   end;

   freeImage(@fspr);
end;

procedure LoadGFX(reload:boolean);
const mingunflash = fr_fpsx1 div 6;
var c:char;
  i,o:byte;
begin
   if(not reload)then
   begin
      with vid_dtimage do
      begin
         w :=1;
         h :=1;
         hw:=1;
         hh:=1;
         surface:=sdl_createRGBSurface(0,w,h,vid_bpp,0,0,0,0);
         texture:=SDL_CreateTextureFromSurface(vid_renderer,surface);
      end;

      initColors;

      for i:=0 to WeaponsN do
      begin
         if(gun_reload[i]<mingunflash)
         then gun_ganim[i]:=max2(1,gun_reload[i] div 2)
         else gun_ganim[i]:=max2(3,gun_reload[i]-mingunflash);
         gun_sanim[i]:=max2(0,gun_ganim[i]-(fr_fpsx1 div 4));
      end;

   end;

   loadHUDfont ('hudnf',reload);
   LoadBaseFont('font' ,reload);

   CalcMenuVars;

                        LoadRCImage('wdt'                ,@spr_rcwall_doortrack[0],@spr_rcwall_doortrack[1],false);
                        LoadRCImage('wd0'                ,@spr_rcwall_door     [0],@spr_rcwall_door     [1],false);
   for c:='A' to 'Z' do LoadRCImage('w'+c                ,@spr_rcwall [0,c]       ,@spr_rcwall[1,c]        ,false);
   for c:='a' to 'z' do LoadRCImage('d'+c                ,@spr_rcdecor[c  ]       ,nil                     ,true );
                        LoadRCImage('w_'                 ,@spr_rcwall_hline       ,nil                     ,false);
   for i:=0   to 16  do LoadRCImage('it'+b2s(i)          ,@spr_rcitem [i  ]       ,nil                     ,true );
   for i:=0   to 4   do
   for o:=0   to 3   do LoadRCImage('e'+b2s(i)+'_'+b2s(o),@spr_rceffect [i,3-o]   ,nil                     ,true );
   for i:=0   to 2   do LoadRCImage('flame_'+b2s(i)      ,@spr_rcflame  [i    ]   ,nil                     ,true );
   for i:=0   to 7   do LoadRCImage('rocket_'+b2s(i)     ,@spr_rcrocket [i    ]   ,nil                     ,true );
   for i:=0   to 4   do LoadRCImage('electro_'+b2s(i)    ,@spr_rcelectro[i    ]   ,nil                     ,true );
   for i:=0   to 4   do LoadRCImage('meat_'+b2s(i)       ,@spr_rcmeat   [i    ]   ,nil                     ,true );

   for i:=0 to WeaponsN do
   begin
      loadImage(@spr_HUDgun_inv[i],'hud_w'+b2s(i+1),true,true,reload);
      for o:=0 to 1 do
      begin
         loadImage(@spr_HUDgun[i,o],'hud_g'+b2s(i+1)+'_'+b2s(o),true,true,reload);
         spr_HUDgunX[i,o]:=vid_log_hw-round(spr_HUDgun[i,o].w*vid_hud_scale) div 2;
         spr_HUDgunY[i,o]:=hud_weapon_y-trunc(spr_HUDgun[i,o].h*vid_hud_scale);
      end;
   end;

   for i:=0 to MaxTeamsI  do
   begin
      for o:=0 to SkinSprites do LoadRCImage('skin_'+b2s(i)+'_'+b2s(o),@spr_rcteam[i,o],nil,true);
      loadImage(@spr_HUDteam[i],'hud_team_'+b2s(i),true,true,reload);
   end;

   for i:=0 to 22 do loadImage(@spr_HUDface[i],'h'+b2s(i),true,true,reload);

   loadImage(@spr_HUDpanel,'hudpanel',false,true,reload);

   for i:=0 to editor_icons_n do loadImage(@editor_icons[i],'editor_ico'+b2s(i),false,true,reload);
end;
