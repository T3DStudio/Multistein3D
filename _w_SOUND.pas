const

MaxSoundSources = 32;

type

TSSource = record
   snd_psX,
   snd_psY  : psingle;
   snd_CamDist,
   snd_sX,
   snd_sY   : single;
   snd_oalsrc,
   snd_chunk: TALuint;
   snd_new  : boolean;
end;

var   MainDevice  : TALCdevice;
      MainContext : TALCcontext;
      SSources    : array[0..MaxSoundSources] of TSSource;

      SLpos       : array[0..2] of TALfloat;
      SLori       : array[0..5] of TALfloat;


function LoadSound(fname:shortstring):TALuint;
var str : shortstring;
SLformat: TALenum;
SLdata  : TALvoid;
SLsize  : TALsizei;
SLfreq  : TALsizei;
SLloop  : TALint;
begin
   Result:=0;
   str:=str_sound_dir+fname+str_sound_ext;
   if FileExists(str) then
   begin
      alGenBuffers   (1, @Result);
      alutLoadWAVFile(str   ,SLformat,SLdata,SLsize,SLfreq,SLloop);
      alBufferData   (Result,SLformat,SLdata,SLsize,SLfreq);
      alutUnloadWAV  (       SLformat,SLdata,SLsize,SLfreq);
   end
   else WriteLog(str+' not found!');
end;

function SourceIsPlaying(s:TALuint):boolean;
var i:TALint;
begin
   alGetSourcei(s,AL_SOURCE_STATE,@i);
   SourceisPlaying:=(i=AL_PLAYING);
end;

procedure PlaySoundSource(schunk:TALint;psx,psy:psingle;sx,sy:single);
var es,p:byte;
    d,di:single;
begin
   if(cl_mode>0)or(snd_volume=0)or(nosound)then exit;

   if(psx<>nil)and(psy<>nil)then
   begin
      sx:=psx^;
      sy:=psy^;
   end;
   d :=point_dist(cam_x,cam_y,sx,sy);

   es:=255;
   for p:=1 to MaxSoundSources do
    with SSources[p] do
    begin
       if(psx<>nil)and(psy<>nil)then
        if(snd_psX=psx)and(snd_psY=psy)then
        begin
           es:=p;
           break;
        end;
       if(snd_sX=sx)and(snd_sY=sy)then
       begin
          es:=p;
          break;
       end;
    end;

   if(es=255)then
    for p:=1 to MaxSoundSources do
     with SSources[p] do
      if(SourceIsPlaying(snd_oalsrc)=false)then
      begin
         es:=p;
         break;
      end;

   if(es=255)then
   begin
      di:=0;
      for p:=1 to MaxSoundSources do
       with SSources[p] do
        if(snd_CamDist>di)then
        begin
           es:=p;
           di:=snd_CamDist;
        end;
      if(d>=di)then es:=255;
   end;

   if(es<=MaxSoundSources)then
    with SSources[es] do
    begin
       snd_psX    :=psx;
       snd_psY    :=psy;
       snd_sX     := sx;
       snd_sY     := sy;
       snd_chunk  :=schunk;
       snd_CamDist:=d;
       snd_new    :=true;
    end;
end;

procedure PlaySoundGlobal(schunk:TALint);
begin
   if(nosound)or(snd_volume=0)then exit;

   with SSources[0] do
   begin
      snd_new  :=true;
      snd_chunk:=schunk;
   end;
end;

procedure SourcePos(s:TALuint;x,y:single);
begin
   SLpos[0]:=x;
   SLpos[1]:=y;
   alSourcefv(s, AL_POSITION, @SLpos);
end;

procedure SoundListenerPos;
begin
   SLPos[0]:=cam_x;
   SLPos[1]:=cam_y;

   SLOri[0]:=rc_vx;
   SLOri[1]:=rc_vy;

   alListenerfv(AL_POSITION   ,@SLPos);
   alListenerfv(AL_ORIENTATION,@SLOri);
end;

procedure SoundProc;
var p:byte;
begin
   if(nosound)then exit;

   SoundListenerPos;

   for p:=0 to MaxSoundSources do
    with SSources[p] do
    begin
       alSourcef(snd_oalsrc, AL_GAIN, snd_volume1);

       if(snd_psX<>nil)and(snd_psY<>nil)then
       begin
          snd_sX:=snd_psX^;
          snd_sY:=snd_psY^;
       end;
       snd_CamDist:=point_dist(cam_x,cam_y,snd_sX,snd_sY);

       SourcePos(snd_oalsrc,snd_sX,snd_sY);

       if(snd_new)then
       begin
          if(p>0)then
          alSourceStop(snd_oalsrc);

          alSourcei   (snd_oalsrc, AL_BUFFER, snd_chunk);
          alSourcePlay(snd_oalsrc);
          snd_new:=false;
       end;
    end;
end;

function InitSounds:boolean;
var i:byte;
begin
   InitSounds:=false;

   if(InitOpenAL=false)then exit;
   MainDevice  := alcOpenDevice(nil);
   MainContext := alcCreateContext(MainDevice,nil);
   alcMakeContextCurrent(MainContext);

   FillChar(SSources ,SizeOf(SSources),0);
   for i:=0 to MaxSoundSources do alGenSources(1,@SSources[i].snd_oalsrc);

   SLPos[2]:=0;
   SLori[2]:=0;
   SLori[3]:=0;
   SLori[4]:=0;
   SLori[5]:=-1;

   with SSources[0] do
   begin
     snd_psX:=@cam_x;
     snd_psY:=@cam_y;
     snd_sX := cam_x;
     snd_sY := cam_y;
   end;

   SoundProc;

   snd_meat   := LoadSound('snd_meat'   );
   snd_fire   := LoadSound('snd_fire'   );
   snd_weapon := LoadSound('snd_weapon' );
   snd_chain  := LoadSound('snd_chain'  );
   snd_death  := LoadSound('snd_death'  );
   snd_explode:= LoadSound('snd_explode');
   snd_noammo := LoadSound('snd_noammo' );
   snd_ammo   := LoadSound('snd_ammo'   );
   snd_chat   := LoadSound('snd_chat'   );
   snd_health := LoadSound('snd_health' );
   snd_armor  := LoadSound('snd_armor'  );
   snd_score  := LoadSound('snd_score'  );
   snd_spawn  := LoadSound('snd_spawn'  );
   snd_mmove  := LoadSound('snd_mmove'  );
   for i:=0 to WeaponsN do snd_gun[i] := LoadSound('snd_g'+b2s(i));
   for i:=0 to MaxTeamsI do
   begin
     snd_skinD[i] := LoadSound('snd_skinD'+b2s(i));
     snd_skinP[i] := LoadSound('snd_skinP'+b2s(i));
   end;

   InitSounds:=true;
end;
