Multistein3D - multiplayer game based on Wolfenstein3D.
Game not required original Wolfenstein3D resource files.

Only deathmatch modes available in current version.

Look for latest version here: t3dstudio.ru

Discord server of project: discord.gg/gCupVGM


Programs used:
- Lazarus 2.0.12 (i386-win32-win32/win64)  https://www.lazarus-ide.org/
- FPC: 3.2.0  https://www.freepascal.org/

DLLs(included):
- SDL2-2.0.16
- openAL

How to compile?
The simplest way(windows OS):
- install Lazarus 2.0.12(this contains FPC so you don't need to install it separately) using default options;
- download the project or make "git clone ...";
- copy sdl2 folder to "C:\lazarus\fpc\3.2.0\units\i386-win32\";
- open T3D_FPS.lpi and press F9(compile and run) or CTRL+F9(just compile).