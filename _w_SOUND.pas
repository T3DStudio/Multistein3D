const

MaxSoundSources = 32;

type

TSSource = record
   _psx,_psy:psingle;
   camdist,
   _csx,_csy:single;
   snd_oalsrc,
   snd_chunk:TALuint;
   new      :boolean;
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

procedure PlaySoundSource(schunk:TALint;psx,psy:psingle;csx,csy:single);
var es,p:byte;
    d,di:single;
begin
   if(game_mode>0)or(snd_volume=0)or(nosound)then exit;

   if(psx<>nil)and(psy<>nil)then
   begin
      csx:=psx^;
      csy:=psy^;
   end;
   d :=dist_r(cam_x,cam_y,csx,csy);

   es:=255;
   for p:=1 to MaxSoundSources do
    with SSources[p] do
    begin
       if(psx<>nil)and(psy<>nil)then
        if(_psx=psx)and(_psy=psy)then
        begin
           es:=p;
           break;
        end;
       if(_csx=csx)and(_csy=csy)then
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
        if(camdist>di)then
        begin
           es:=p;
           di:=camdist;
        end;
      if(d>=di)then es:=255;
   end;

   if(es<=MaxSoundSources)then
    with SSources[es] do
    begin
       _psx:=psx;
       _psy:=psy;
       _csx:=csx;
       _csy:=csy;
       snd_chunk:=schunk;
       camdist:=d;
       new:=true;
    end;
end;

procedure PlaySoundGlobal(schunk:TALint);
begin
   if(nosound)or(snd_volume=0)then exit;

   with SSources[0] do
   begin
      new:=true;
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

       if(_psx<>nil)and(_psy<>nil)then
       begin
          _csx:=_psx^;
          _csy:=_psy^;
       end;
       camdist:=dist_r(cam_x,cam_y,_csx,_csy);

       SourcePos(snd_oalsrc,_csx,_csy);

       if(new)then
       begin
          if(p>0)then
          alSourceStop(snd_oalsrc);

          alSourcei   (snd_oalsrc, AL_BUFFER, snd_chunk);
          alSourcePlay(snd_oalsrc);
          new:=false;
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
     _psx:=@cam_x;
     _psy:=@cam_y;
     _csx:=cam_x;
     _csy:=cam_y;
   end;

   SoundProc;

   snd_weapon := LoadSound('snd_weapon');
   snd_chain  := LoadSound('snd_chain' );
   snd_death  := LoadSound('snd_death' );

   snd_noammo := LoadSound('snd_noammo');
   snd_ammo   := LoadSound('snd_ammo'  );
   snd_chat   := LoadSound('snd_chat'  );
   snd_health := LoadSound('snd_health');
   snd_armor  := LoadSound('snd_armor' );
   snd_score  := LoadSound('snd_score' );
   snd_spawn  := LoadSound('snd_spawn' );
   snd_mmove  := LoadSound('snd_mmove' );
   for i:=0 to 4 do snd_gun[i] := LoadSound('snd_g'+b2s(i));
   for i:=0 to 3 do
   begin
     snd_skinD[i] := LoadSound('snd_skinD'+b2s(i));
     snd_skinP[i] := LoadSound('snd_skinP'+b2s(i));
   end;

   InitSounds:=true;
end;
