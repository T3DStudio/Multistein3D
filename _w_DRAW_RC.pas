procedure rc_DrawWalls;
//const
//rc_doors = mgr_cdoors+[mgr_bdoor,mgr_odoor];
var cx,
rdx,rdy,
rdx1,rdy1,
rpx,rpy,
ddx,ddy,
sdx,sdy,
pWD,wX   : single;
zbpos    : psingle;
   swtex,
   pwtex,
    wtex : char;
mx0,my0,
ix,iy,
mx,my,
stx,sty,
stx0,sty0,
side,lh,texx,texy,
ds,de,
d2,iy2   : longint;
cc,fc    : cardinal;
ptextl   : pTRCTextureLine;
ptextw   : PTRCImage;
ppix,
cpix     : pcardinal;
begin
   FillChar(rc_vgrid ,SizeOf(rc_vgrid) ,false);

   cc:=sv_clroom^.r_ceil_color .c;
   fc:=sv_clroom^.r_floor_color.c;

   rpx:=rc_x;
   rpy:=rc_y;

   mx0:=trunc(rpx);
   my0:=trunc(rpy);

   if(0<=mx0)and(mx0<=map_mlw)
  and(0<=my0)and(my0<=map_mlw)then rc_vgrid[mx0,my0]:=true;

   if(0<mx0)and(mx0<=map_mw)
  and(0<my0)and(my0<=map_mw)
  then swtex:=sv_clroom^.rgrid[mx0,my0]
  else swtex:=mgr_wih;

   rc_plx:=-rc_vy*cam_fov;
   rc_ply:= rc_vx*cam_fov;
   cx :=-1;

   rc_iD := 1/(rc_plx*rc_vy-rc_vx*rc_ply);

   ZBufferMDW:=0;
   zbpos:=psingle(ZBuffer);

   cpix :=pcardinal(rc_buffer);
   wtex :=#0;
   pwtex:=#0;

   for ix:=0 to vid_iw do
   begin
      rdx :=rc_vx+rc_plx*cx;if(rdx=0)then rdx:=0.0001;
      rdy :=rc_vy+rc_ply*cx;if(rdy=0)then rdy:=0.0001;

      mx  :=mx0;
      my  :=my0;

      rdx1:=1/rdx;
      rdy1:=1/rdy;

      ddx :=abs(rdx1);
      ddy :=abs(rdy1);

      if(rdx<0)then begin stx:=-1;stx0:=1;sdx:=(rpx-mx)*ddx; end else begin stx:=1;stx0:=0;sdx:=(mx+1-rpx)*ddx; end;
      if(rdy<0)then begin sty:=-1;sty0:=1;sdy:=(rpy-my)*ddy; end else begin sty:=1;sty0:=0;sdy:=(my+1-rpy)*ddy; end;

      pwtex:=swtex;
      wtex :=swtex;

      while true do
      begin
         if(sdx<sdy)
         then begin sdX+=ddX;mx+=stX;side:=0;end
         else begin sdY+=ddY;my+=stY;side:=1;end;

         pwtex:=wtex;
         if(0<mx)and(mx<=map_mw)
        and(0<my)and(my<=map_mw)then
         begin
            wtex:=sv_clroom^.rgrid[mx,my];
            rc_vgrid[mx,my]:=true;
         end
         else wtex:=mgr_wih;

         if not(wtex in mgr_bwalls)then continue;

         //if(wtex in rc_doors){and(wtex<>mgr_bdoor)}then continue;

         if(side=1)
         then pWD:=(sty0+my-rpy)*rdy1
         else pWD:=(stx0+mx-rpx)*rdx1;

         if(pWD.IsNan     )
         or(pWD.IsInfinity)then pWD:=1000;
         if(pWD<0.01      )then pWD:=0.01;
         if(pWD>ZBufferMDW)then ZBufferMDW:=pwd;

         zbpos^:=pWD;
         ppix:=cpix;

         if(wtex<>mgr_wih)then
         begin
            {if(pwtex in rc_doors)
            then ptextw:=@spr_rcwall_doortrack[side]
            else
              if(wtex in rc_doors)
              then ptextw:=@spr_rcwall_door[side]
              else ptextw:=@spr_rcwall [side,wtex]; }

            if(pwtex=mgr_door)
            then ptextw:=@spr_rcwall_doortrack[side]
            else ptextw:=@spr_rcwall          [side,wtex];

            wx:=vid_rh/pWD;

            lh :=trunc(wx);

            de:=vid_rhh+trunc(cam_z*wx);
            ds:=de-lh;

            if(de>vid_ih)then de:=vid_ih;

            if(side=1)
            then wX:=rPX+pWD*rdx
            else wX:=rPY+pWD*rdy;

            texX:=trunc(wx*ptextw^.rc_w) mod ptextw^.rc_w;

            if((side=1)and(rdy>0))
            or((side=0)and(rdx<0))then texx:=ptextw^.rc_w-texx-1;

            d2:=trunc(ptextw^.rc_h/lh*rc_intI);

            ptextl:=@ptextw^.rctexture[texx];

            if(ds<0)then
            begin
               iy2:=-ds*d2;
               ds :=0;
            end
            else iy2:=0;

            iy:=0;

            while iy<ds do
            begin
               cpix^:=cc;
               cpix +=vid_rw;
               iy   +=1;
            end;
            while iy<=de do
            begin
               //texy:=iy2 shr rc_intS;
               //if(texy<rc_TextureWall_iw)then
               cpix^:=ptextl^[iy2 shr rc_intS];
               cpix +=vid_rw;
               iy   +=1;
               iy2  +=d2;
            end;
            while iy<=vid_ih do
            begin
               cpix^:=fc;
               cpix +=vid_rw;
               iy   +=1;
            end;
         end
         else
         begin
            for iy:=0         to vid_rhh do begin cpix^:=cc;cpix+=vid_rw;end;
            for iy:=vid_rhh+1 to vid_ih  do begin cpix^:=fc;cpix+=vid_rw;end;
         end;

         break;
      end;

      cpix :=ppix+1;
      cx   +=rc_cxt;
      zbpos+=1;
   end;
end;

{procedure debug_draw_sprite(spr:PTSprite);
var x,y:integer;
    c:TColor;
begin
   with spr^ do
   for x:=1 to w do
   for y:=1 to h do
   begin
      with c do
      begin
         // ABGR
         c:=p[x-1,y-1];

         b:=(c and $0000FF00) shr 8;
         g:=(c and $00FF0000) shr 16;
         r:=(c and $FF000000) shr 24;
         a:=255;
      end;
      draw_pixel(x,y,@c);
   end;
end;  }

procedure rc_spr1(sprx,spry,sprz,scale:single;spr:pTRCImage;Alx:boolean);
var sx,sy,tx,ty:single;
    ssx,ssy,sw,sh,shw,dsx,dsy,dex,dey,hmove,stx,sty:integer;
    texxc,texyc,tdx,tdy,tsdy:longInt;
    col,
    tcol:cardinal;
   ptexl:pTRCTextureLine;
   pstex:pTRCTexture;
   zbfs :psingle;
   ppix,
   cpix :pcardinal;
begin
   sx := sprx-rc_x;
   sy := spry-rc_y;

   ty := rc_iD*(rc_plx*sY-rc_ply*sX);

   if(0.01<=ty)and(ty<ZBufferMDW)then
   begin
      tx  := rc_iD*(rc_vy*sX-rc_vx*sY);

      ssx := trunc(vid_rhw*(1+tx/ty));
      ssy := vid_rhh-trunc(vid_rh/ty*(sprz+spr^.rc_z-cam_z)*scale);

      sw  := trunc((spr^.rc_w/ty*vid_scx)*scale);if(sw<2)then sw:=2;
      sh  := trunc((spr^.rc_h/ty*vid_scy)*scale);if(sh<2)then sh:=2;

      shw := sw shr 1;

      if (-shw<ssx)and(ssx<(vid_rw+shw))
      and(0   <ssy)and(ssy<(vid_rh+sh ))then
      begin

         dSX := sSX-sHw;   if(dSX < 0     )then dSX := 0;
         dEX := sSX+sHw-1; if(dEX > vid_iw)then dEX := vid_iw;

         dSY := sSY-sH;    if(dSY < 0     )then dSY := 0;
         dEY := sSY-1;     if(dEY > vid_ih)then dEY := vid_ih;

         texxc:=trunc(spr^.rc_w/sW*rc_intI);
         texyc:=trunc(spr^.rc_h/sh*rc_intI);

         hmove:=ssx-shw;
         if(hmove<0)
         then tdx:=-hmove*texxc
         else tdx:=0;

         if (alx) then
         begin
            texxc:=-texxc;
            tdx  :=(spr^.rc_w*rc_intI)-tdx-1;
         end;

         hmove:=ssy-sh;
         if(hmove<0)
         then tsdy:=-hmove*texyc
         else tsdy:=0;

         cpix:=pcardinal(rc_buffer);
         cpix+=(dSY*vid_rw)+dSX;

         tcol :=spr^.trunsColor;
         pstex:=@spr^.rctexture;

         zbfs:=psingle(ZBuffer);
         zbfs+=dSX;

         for stx:=dSX to dEX do
         begin
            tdy  :=tsdy;
            ppix :=cpix;
            ptexl:=@pstex^[tdx shr rc_intS];
            if(not zbfs^.IsNan)then
             if(zbfs^>ty)then
              for sty:=dSY to dEY do
              begin
                 col :=ptexl^[tdy shr rc_intS];
                 if(col<>tcol)then cpix^:=col;
                 tdy +=texyc;
                 cpix+=vid_rw;
              end;
            zbfs+=1;
            tdx +=texxc;
            cpix:=ppix+1;
         end;
      end;
   end;
end;

{
procedure rc_spr2(asx,asy,asd:single;wall:PTRCWall);
var sx,sy,
    sx2,sy2,
    sh1,sh2,
    tx1,ty1,
    tx2,ty2,
    ty,wh,sz,
    step_ty,
    step_wh,
    step_sz:single;

    ssx1,ssy1,sey1,
    ssx2,ssy2,sey2,
    ssh1,ssh2,
    ssz1,ssz2,
    ssw,
    texx,
    texy,
    stx,sty:integer;
    tdx,tdy,
    texxc,
    texyc  :longInt;

    col,
    pcol   :cardinal;
    ptexl  :pTTextureLine;
    alx    :boolean;
    cpix,
    ppix   :pcardinal;
begin
   if(wall=nil)then exit;

   alx:=false;

   sx := asx-cam_x;
   sy := asy-cam_y;

   // distance to eye
   ty  := rc_iD*(rc_plx*sy-rc_ply*sx);if(ty=0)then ty1:=0.001;
   if(tY<0.01)
   or(tY<ZBufferMDW)then exit;

   ty1 := rc_iD*(rc_plx*sy1-rc_ply*sx1);if(ty1<=0)then ty1:=0.01;
   ty2 := rc_iD*(rc_plx*sy2-rc_ply*sx2);if(ty2<=0)then ty2:=0.01;

   // x position on screen
   tx1 := rc_iD*(rc_vy*sx1-rc_vx*sy1);
   tx2 := rc_iD*(rc_vy*sx2-rc_vx*sy2);

   ssx1:= trunc(vid_rhw*(1+tx1/ty1));
   ssx2:= trunc(vid_rhw*(1+tx2/ty2));

   if(ssx1>ssx2)then
   begin
      sty:=ssx2;ssx2:=ssx1;ssx1:=sty;
      sy1:=ty1 ;ty1 :=ty2 ;ty2 :=sy1;
      alx:=true;
   end;

   ssw:=ssx2-ssx1;
   if(ssw=0)then exit;

   if(ssx2>vid_iw)then ssx2:=vid_iw;

   // wall height on screen
   sh1 :=vid_rch/ty1;
   sh2 :=vid_rch/ty2;

   ssz1:=trunc(cam_z*sh1);
   ssz2:=trunc(cam_z*sh2);

   step_ty:=(ty2 -ty1 )/ssw;
   step_wh:=(sh2 -sh1 )/ssw;
   step_sz:=(ssz2-ssz1)/ssw;

   ty:=ty1;
   wh:=sh1;
   sz:=ssz1;

   texxc:=trunc(wall^.rcw/ssw*rc_intI);
   tdx:=0;

   if(ssx1<0)then
   begin
      ty  -=step_ty*ssx1;
      wh  -=step_wh*ssx1;
      sz  -=step_sz*ssx1;
      tdx :=-texxc*ssx1;
      ssx1:=0;
   end;
   if(ssx1>ssx2)then exit;

   for stx:=ssx1 to ssx2 do
   begin
      if(ty>0.005)then
      begin
         texx :=tdx shr rc_intS;
         ptexl:=@wall^.texture[texx];

         ssy1 :=vid_rchh-trunc(sz);
         sey1 :=ssy1+trunc(wh);
         texyc:=trunc(wall^.rch/wh*rc_intI);
         tdy  :=0;

         if(ssy1<0)then
         begin
            tdy:=-texyc*ssy1;
            ssy1:=0;
         end;
         if(sey1>vid_rch)then sey1:=vid_rch;
         pcol:=((ssy1*vid_rw)+stx)*vid_bppb;
         //cpix:=@cardinal((@rc_buffer[ ((ssy1*vid_rw)+stx)*vid_bppb ])^);

         for sty:=ssy1 to sey1 do
         begin
            //texy:=;
            cardinal((@rc_buffer[pcol])^):=ptexl^[tdy shr rc_intS];
            pcol+=vid_rpitch;
            //cpix^:=ptexl^[tdy shr rc_intS];
            //cpix +=1;
            tdy  +=texyc;
         end;
      end;
      wh +=step_wh;
      ty +=step_ty;
      sz +=step_sz;
      tdx+=texxc;
   end;
end;  }

{procedure rc_wall(wx1,wy1,wx2,wy2:single;wall:PTRCWall);
var sx1,sy1,
    sx2,sy2,
    tx1,ty1,
    tx2,ty2,
    ty,wh,sz,
    step_ty:single;

    ssx1,ssy1,sey1,
    ssx2,ssy2,sey2,
    ssh1,ssh2,
    ssw,
    texx,
    texy,
    stx,sty:integer;
    tdx,tdy,
    texxc,
    texyc  :longInt;

    col,
    pcol   :cardinal;
    ptexl  :pTTextureLine;
    alx    :boolean;
    cpix,
    ppix   :pcardinal;
begin
   if(wall=nil)then exit;
   if(wx1=wx2)
   and(wy1=wy2)then exit;

   alx:=false;

   sx1 := wx1-cam_x;
   sy1 := wy1-cam_y;
   sx2 := wx2-cam_x;
   sy2 := wy2-cam_y;

   // distance to eye
   ty1 := rc_iD*(rc_plx*sy1-rc_ply*sx1);
   ty2 := rc_iD*(rc_plx*sy2-rc_ply*sx2);

   // x position on screen
   tx1 := rc_iD*(rc_vy*sx1-rc_vx*sy1);
   tx2 := rc_iD*(rc_vy*sx2-rc_vx*sy2);

   ssx1:= trunc(vid_rhw*(1+tx1/ty1));
   ssx2:= trunc(vid_rhw*(1+tx2/ty2));

   if(ssx1>ssx2)then
   begin
      sty:=ssx2;ssx2:=ssx1;ssx1:=sty;
      sy1:=ty1 ;ty1 :=ty2 ;ty2 :=sy1;
      alx:=true;
   end;

   ssw:=abs(ssx2-ssx1);
   if(ssw=0)then exit;
   if(ssx2>vid_iw)then ssx2:=vid_iw;

   step_ty:=(ty2-ty1)/ssw;

   ty:=ty1;

   texxc:=trunc(wall^.rcw/ssw*rc_intI);
   tdx:=0;

   if(ssx1<0)then
   begin
      ty  -=step_ty*ssx1;
      tdx :=-texxc*ssx1;
      ssx1:=0;
   end;
   if(ssx1>=ssx2)then exit;

   for stx:=ssx1 to ssx2 do
   begin
      if(ty>0.01)then
      begin
         texx :=tdx shr rc_intS;
         ptexl:=@wall^.texture[texx];

         wh   :=vid_rch/ty;
         ssy1 :=vid_rchh-trunc(cam_z*wh);
         sey1 :=ssy1+trunc(wh);
         texyc:=trunc(wall^.rch/wh*rc_intI);
         tdy  :=0;

         if(ssy1<0)then
         begin
            tdy:=-texyc*ssy1;
            ssy1:=0;
         end;
         if(sey1>vid_rch)then sey1:=vid_rch;
         pcol:=((ssy1*vid_rw)+stx)*vid_bppb;
         //cpix:=@cardinal((@rc_buffer[ ((ssy1*vid_rw)+stx)*vid_bppb ])^);

         for sty:=ssy1 to sey1 do
         begin
            //texy:=;
            cardinal((@rc_buffer[pcol])^):=ptexl^[tdy shr rc_intS];
            pcol+=vid_rpitch;
            //cpix^:=ptexl^[tdy shr rc_intS];
            //cpix +=1;
            tdy  +=texyc;
         end;
      end;
      ty +=step_ty;
      tdx+=texxc;
   end;
end;    }


procedure rc_spr_add(ax,ay,az,aminD,ascale:single;spr:pTRCImage;aflipX:boolean);
var mx,
    my:integer;
    md:single;
begin
   if(map_rc_sprite_n>=rc_MaxVisSprites)then exit;

   mx:=trunc(ax);
   my:=trunc(ay);
   if(mx<0)or(map_mlw<mx)
   or(my<0)or(map_mlw<my)
   then exit
   else
     if(not rc_vgrid[mx,my])then exit;

   md:=point_dist(ax,ay,rc_x,rc_y);
   if(md<aminD)then exit;

   map_rc_sprite_n+=1;
   setlength(map_rc_sprite_l,map_rc_sprite_n);
   new(map_rc_sprite_l[map_rc_sprite_n-1]);

   with map_rc_sprite_l[map_rc_sprite_n-1]^ do
   begin
      bs_x      :=ax;
      bs_y      :=ay;
      bs_z      :=az;
      bs_v      :=-1;
      bs_scale  :=ascale;
      bs_flipx  :=aflipX;
      bs_rcimage:=spr;
      bs_d      :=md
   end;
end;


procedure rc_DrawSprites;
var i,j,da:word;
    dum   :PTBufSpr;
    an,
    xa    :boolean;
begin
   while(map_rc_sprite_n>0)do
   begin
      map_rc_sprite_n-=1;
      dispose(map_rc_sprite_l[map_rc_sprite_n]);
   end;

   with sv_clroom^ do
   begin
      for i:=0 to MaxPlayers do
       with g_players[i] do
       if(state>ps_dead)and(i<>cam_pl)then
       begin
          an:=((dspx<>vx)or(dspy<>vy))and(time_scorepause<=0);

          dspx:=vx;
          dspy:=vy;

          da:=((trunc(point_dir(rc_x,rc_y,x,y)-dir_360(dir))+428) mod 360) div 45;

          xa:=da in [0,6,7];

          j:=0;
          case da of
          0:j:=1;
          1:j:=0;
          2:j:=1;
          3:j:=2;
          4:j:=3;
          5:j:=4;
          6:j:=3;
          7:j:=2;
          end;

          if(tesla_eff>0)
          then rc_spr_add(vx,vy,0,0,1,@spr_rcelectro[j],xa)
          else
          begin
             if(an)
             then da:=((animation_tick+i) div 7) mod 4
             else da:=0;

             if(gun_rld<=gun_sanim[gun_curr])
             then da:=(j*4)+da
             else da:=j+20;

             rc_spr_add(vx,vy,0,0,1,@spr_rcteam[team,da],xa);
          end;
       end;

      if(not Room_CheckFlag(sv_clroom,sv_g_instagib))then
       for i:=1 to r_item_n do
        with r_item_l[i-1] do
         if(itype<>#0)and(irespt=0)then
          rc_spr_add(ix,iy,0,0,1,@spr_rcitem[isprite],false);

      for i:=1 to r_decor_n do
       with r_decor_l[i-1] do
        if(decor_type<>#0)then
         rc_spr_add(decor_x,decor_y,0,0,1,@spr_rcdecor[decor_type],false);

      if(r_missile_n>0)then
       for i:=0 to r_missile_n-1 do
        with r_missile_l[i] do
         if(mtype>0)then
          case mtype of
          gpt_fire  : rc_spr_add(mx,my,0,0.5,1,@spr_rcflame [(animation_tick div 4) mod 3],false);
          gpt_rocket: begin
                      if(mdir>-1)then
                      rc_spr_add(mx,my,0,0.5,1,@spr_rcrocket[((trunc(point_dir(rc_x,rc_y,mx,my)-dir_360(mdir))+383) mod 360) div 45],false);

                      j:=(animation_tick div 3) mod 255;
                      if(j<>mtrail)then
                      begin
                         mtrail:=j;
                         cl_eff_add(mx,my,0,1,eid_trail);
                      end;
                      end;
          end;
   end;

   for i:=0 to rc_MaxEffects do
    with map_effs[i] do
     if(eff_anim>0)then
     begin
        eff_anim-=1;
        eff_z:=eff_z+eff_ez_fallspd;
        rc_spr_add(eff_x,eff_y,eff_z,0,eff_scale,@spr_rceffect[eff_type,eff_anim div eff_ans],false);
     end;
   if(player_maxcorpses>=0)then
    for i:=0 to player_maxcorpses do
     with map_deads[i] do
     if(eff_anim>0)then
     begin
        if(eff_anim<eff_dant)then eff_anim+=1;
        if(eff_type<=MaxTeamsI)
        then rc_spr_add(eff_x,eff_y,0,0,1,@spr_rcteam[eff_type,25+(eff_anim div eff_dans)],false)
        else rc_spr_add(eff_x,eff_y,0,0,1,@spr_rcmeat[eff_anim div eff_dans]              ,false);
     end;

   if(map_rc_sprite_n>0)then
   begin
      if(map_rc_sprite_n>1)then
       for i:=0 to map_rc_sprite_n-2 do
        for j:=0 to (map_rc_sprite_n-i-2) do
         if(map_rc_sprite_l[j]^.bs_d<map_rc_sprite_l[j+1]^.bs_d)then
         begin
            dum:=map_rc_sprite_l[j];
            map_rc_sprite_l[j  ]:=map_rc_sprite_l[j+1];
            map_rc_sprite_l[j+1]:=dum;
         end;

      for i:=0 to map_rc_sprite_n-1 do
        with map_rc_sprite_l[i]^ do
          if(bs_d>0)then
            rc_spr1(bs_x,bs_y,bs_z,bs_scale,bs_rcimage,bs_flipx);
   end;

   //rc_wall(7,7,8,7,@spr_rcwall[0,'A']);
end;

procedure draw_rc;
begin
   rc_DrawWalls;

   rc_DrawSprites;

   SDL_UpdateTexture(vid_rctexture,nil,rc_buffer,rc_pitch);
   vid_rect^.x:=hud_gbrc_x;
   vid_rect^.y:=hud_gbrc_y;
   vid_rect^.w:=hud_gbrc_w;
   vid_rect^.h:=hud_gbrc_h;
   SDL_RenderCopy(vid_renderer,vid_rctexture,nil,vid_rect);
end;
