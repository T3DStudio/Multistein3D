program T3D_FPS;

{$DEFINE FULLGAME}
//{$UNDEF FULLGAME}

{$IFDEF FULLGAME}
  {$APPTYPE CONSOLE}
  //{$APPTYPE GUI}
{$ELSE}
  {$APPTYPE CONSOLE}
{$ENDif}

uses SysUtils, crt, sdl2, sdl2_net
{$IFDEF FULLGAME}
,sdl2_image,openal
{$ENDIF};

{$INCLUDE _w_CONST.pas}
{$INCLUDE _w_TYPE.pas}
{$INCLUDE _w_VAR.pas}
{$INCLUDE _w_COMMON.pas}
{$INCLUDE _w_NETWORK_c.pas}
{$INCLUDE _w_IOCOMMON.pas}
{$IFDEF FULLGAME}
        {$INCLUDE _w_SOUND.pas}
        {$INCLUDE _w_CONFIG.pas}
{$ENDIF}
{$INCLUDE _w_ROOM.pas}
{$INCLUDE _w_MAP.pas}
{$INCLUDE _w_GAME.pas}
{$INCLUDE _w_DEMOS.pas}
{$IFDEF FULLGAME}
        {$INCLUDE _w_NETWORK_cl.pas}
{$ELSE}
        {$INCLUDE _w_NETWORK_sv.pas}
{$ENDIF}
{$IFDEF FULLGAME}
        {$INCLUDE _w_EDITOR.pas}
        {$INCLUDE _w_DRAW.pas}
        {$INCLUDE _w_GRAPHIC.pas}
        {$INCLUDE _w_MENU.pas}
{$ENDIF}
{$INCLUDE _w_INPUT.pas}
{$INCLUDE _w_INIT.pas}

{$R *.res}

begin
   G_Init;

   while(sys_cycle)do
   begin
      fr_FPSSecondD:=SDL_GetTicks;
      {$IFDEF FULLGAME}
      G_Input;
      G_ClientGame;
      G_Draw;
      {$ELSE}
      net_servercode_rcv;
      G_SvGame;
      net_servercode_snd;
      G_Input;
      {$ENDIF}
      fr_FPSSecondT:=SDL_GetTicks-fr_FPSSecondD;

      fr_delay;
   end;

   {$IFDEF FULLGAME}
   if(cl_net_cstat>cstate_none)
   then net_Disconnect;
   cfg_save;
   {$ENDIF}
end.

