unit wmeu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, pngimage, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, math, CommDlg, Buttons, ComCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Image3: TImage;
    Image4: TImage;
    ColorDialog1: TColorDialog;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    Label11: TLabel;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
      MS = 63;
  walls  : set of char = ['A'..'Z','?','#'];
  decors : set of char = ['a'..'z'];
  decorsw: set of char = ['a'..'d','v','x','y'];
  items  : set of char = ['0'..'9'];
  spawns : set of char = ['@','<','^','>','.'];

  VK_1   = ord('1');
  VK_2   = ord('2');
  VK_3   = ord('3');
  VK_A   = ord('A');
  VK_D   = ord('D');
  VK_W   = ord('W');
  VK_S   = ord('S');


  type TMap = array[0..MS,0..MS] of char;

///////////////////////////////////////////////////

var WSprs   : array['A'..'Z'] of TBitMap;
    IHSpr   : TBitMap;
    DTSpr   : TBitMap;
    DSprs   : array['a'..'z'] of TBitMap;
    ISprs   : array['0'..'9'] of TBitMap;
    SSprs   : array[ 0 .. 4 ] of TBitMap;

    map     : TMap;
    map_fc  : array[0..5] of byte;
    mp      : TPoint;
    mpg     : TPoint;

    MGS     : integer = 24;
    MGHS    : integer = 12;

    newMGS  : integer = 24;

    needgrid: boolean = true;

    vbx     : integer;
    vby     : integer;

    tspr    : TBitMap;
ui_keypress : array[byte] of byte;
    view    : TPoint;
    view_spd: byte = 60;
    brsh    : char = 'A';
    pname   : string = 'Multistein3D(v3) Map Editor';
    drw     : byte = 1;
  file_name : string = '';

function b2s(i:byte    ):string;begin str(i,result);end;
function w2s(i:word    ):string;begin str(i,result);end;
function c2s(i:cardinal):string;begin str(i,result);end;
function i2s(i:integer ):string;begin str(i,result);end;
function s2b(str:string):byte;var t:integer;begin val(str,result,t);end;
function s2w(str:string):word;var t:integer;begin val(str,result,t);end;
function s2i(str:string):integer;var t:integer;begin val(str,result,t);end;

procedure ui_keypress_cycle;
var b:byte;
begin
    for b:=0 to 255 do
    if (ui_keypress[b]>0)and(ui_keypress[b]<255) then inc(ui_keypress[b],1);
end;

procedure DrawFlCe;
begin
   form1.image3.Canvas.Brush.Color:=RGB(map_fc[0],map_fc[1],map_fc[2]);
   form1.image3.Canvas.Rectangle(0,0,33,33);
   form1.image4.Canvas.Brush.Color:=RGB(map_fc[3],map_fc[4],map_fc[5]);
   form1.image4.Canvas.Rectangle(0,0,33,33);
end;

procedure move_map(mx,my:shortint);
var x,y,cx,cy:integer;
map2:TMap;

begin
   for x:=0 to MS do
    for y:=0 to MS do
    begin
       cx:=x+mx;
       if(cx<0 )then cx:=MS+cx+1;
       if(cx>MS)then cx:=cx-MS-1;

       cy:=y+my;
       if(cy<0 )then cy:=MS+cy+1;
       if(cy>MS)then cy:=cy-MS-1;

       map2[x,y]:=map[cx,cy];
    end;

    map:=map2;
    drw:=1;
end;

procedure objcounter;
var bc,dc,ic,sc:word;
    x,y:byte;
begin
   bc:=0;
   dc:=0;
   ic:=0;
   sc:=0;
   for x:=0 to ms do
    for y:=0 to ms do
    begin
       if map[x,y] in walls  then inc(bc,1);
       if map[x,y] in decors then inc(dc,1);
       if map[x,y] in items  then inc(ic,1);
       if map[x,y] in spawns then inc(sc,1);
    end;
   form1.Label7.Caption:='walls: '  +w2s(bc);

   form1.Label8.Caption:='decors: ' +w2s(dc);
   form1.Label8.Font.Color:=clBlack;

   form1.Label9.Caption:='items: '  +w2s(ic);
   form1.Label9.Font.Color:=clBlack;

   form1.Label10.Caption:='spawns: '+w2s(sc);
   form1.Label10.Font.Color:=clBlack;

end;

procedure ClearMap;
var x,y:byte;
begin
   for x:=0 to ms do
    for y:=0 to ms do
     map[x,y]:=' ';

   form1.Caption:=pname+': new map';
   drw:=1;
   file_name:='';
end;

function _hex2b(c:char):byte;
begin
   case c of
   '1'     : _hex2b:=$1;
   '2'     : _hex2b:=$2;
   '3'     : _hex2b:=$3;
   '4'     : _hex2b:=$4;
   '5'     : _hex2b:=$5;
   '6'     : _hex2b:=$6;
   '7'     : _hex2b:=$7;
   '8'     : _hex2b:=$8;
   '9'     : _hex2b:=$9;
   'A','a' : _hex2b:=$A;
   'B','b' : _hex2b:=$B;
   'C','c' : _hex2b:=$C;
   'D','d' : _hex2b:=$D;
   'E','e' : _hex2b:=$E;
   'F','f' : _hex2b:=$F;
   else
   _hex2b:=$00;
   end;
end;

function _b2hex(b:byte):char;
begin
   _b2hex:=#0;

   case b of
    0..9 : _b2hex:=chr(ord('0')+b);
   10..15: _b2hex:=chr(ord('A')+(b-10));
   end;
end;

function _b2shex(c:byte):string;
begin
   _b2shex:=_b2hex(c shr 4) + _b2hex(c and $0F);
end;

procedure LoadMap;
var f:text;
    s,fn:string;
    sl,i,x,y:byte;
    c:char;
begin
   form1.OpenDialog1.execute;
   fn:=form1.OpenDialog1.FileName;
   if (fn='') then exit;


   if FileExists(fn) then
   begin
      ClearMap;
      assign(f,fn);
      reset(f);
      x:=0;
      y:=0;
      readln(f,s);
      map_fc[0]:=(_hex2b(s[1 ]) shl 4)+_hex2b(s[2 ]);
      map_fc[1]:=(_hex2b(s[3 ]) shl 4)+_hex2b(s[4 ]);
      map_fc[2]:=(_hex2b(s[5 ]) shl 4)+_hex2b(s[6 ]);
      map_fc[3]:=(_hex2b(s[7 ]) shl 4)+_hex2b(s[8 ]);
      map_fc[4]:=(_hex2b(s[9 ]) shl 4)+_hex2b(s[10]);
      map_fc[5]:=(_hex2b(s[11]) shl 4)+_hex2b(s[12]);
      drawFlCe;
      while (not Eof(f)) do
      begin
         readln(f,s);
         if (y<=MS) then
         begin
            x:=0;
            sl:=length(s);
            for i:=1 to sl do
             if (x<=MS) then
             begin
                if (s[i] in walls)or(s[i] in decors)or(s[i] in items)or(s[i] in spawns)
                then map[x,y]:=s[i] else map[x,y]:=' ';
                inc(x,1);
             end;
             Inc(y,1);
         end;
      end;
      close(f);
   end;
   file_name:=fn;
   form1.Caption:=pname+': '+fn;
   objcounter;
   drw:=1;
end;

function charn(s:string;c:char):byte;
var i,sl:byte;
begin
   sl:=length(s);
   result:=0;
   for i:=1 to sl do if (s[i]=c) then inc(result,1);
end;

procedure SaveMap(fn:string);
var f:text;
  s: array[0..ms] of string[ms+1];
  sp:string[ms+1];
  x,y,yn:byte;
begin
   yn:=0;
   for y:=0 to ms do
   begin
      s[y]:='';
      sp:='';
      for x:=0 to ms do
      begin
         if map[x,y]=' '
         then sp:=sp+' '
         else begin
            s[y]:=s[y]+sp+map[x,y];
            sp:='';
         end;
      end;
      if (charn(s[y],' ')<=MS)and(s[y]<>'') then yn:=y;
   end;

   assign(f,fn);
   rewrite(f);
   for x:=0 to 5 do write(f,_b2shex(map_fc[x]));
   writeln(f);
   for y:=0 to yn do
    if (y=yn)
    then write(f,s[y])
    else writeln(f,s[y]);
   close(f);
end;

procedure DrawBrush(img:TImage;bx,by:integer;c:char);
begin
    with img do
    begin
      Canvas.draw(bx,by,tspr);
      if(c in walls )then
       case c of
       '?': Canvas.draw(bx,by,IHSpr);
       '#': Canvas.draw(bx,by,DTSpr);
       else Canvas.draw(bx,by,WSprs[c]);
       end;
      if(c in decors)then
      begin
         Canvas.draw(bx,by,DSprs[c]);
         if not(c in decorsw)then
         begin
            Canvas.pen.Color:=clRed;
            Canvas.MoveTo(bx,by);
            Canvas.LineTo(bx+MGS-1,by+MGS-1);
         end;
      end;
      if(c in items )then Canvas.draw(bx,by,ISprs[c]);
      if(c in spawns)then case c of
                          '@': Canvas.draw(bx,by,SSprs[0]);
                          '<': Canvas.draw(bx,by,SSprs[1]);
                          '^': Canvas.draw(bx,by,SSprs[2]);
                          '>': Canvas.draw(bx,by,SSprs[3]);
                          '.': Canvas.draw(bx,by,SSprs[4]);
                          end;
   end;
end;

function png2bitmap(tpng:TPNGImage):TBitMap;
var c:single;
  w,h:byte;
   cl:TColor;
begin
   result:=TBitMap.Create;
   result.width :=MGS;
   result.height:=MGS;

   with tpng do
   begin
      cl:=Canvas.Pixels[0,0];
      if width =0 then width :=1;
      if height=0 then height:=1;
      c:=width/height;
      if (width>height) then
      begin
         if (width>MGS) then
         begin
            w:=MGS;
            h:=trunc(w/c);
         end else
         begin
            w:=width;
            h:=height;
         end;
      end else
      begin
         if (height>MGS) then
         begin
            h:=MGS;
            w:=trunc(h*c);
         end else
         begin
            w:=width;
            h:=height;
         end;
      end;
   end;

   result.canvas.draw(0,0,tpng);
   result.canvas.pen.style:=psClear;
   result.canvas.Brush.Color:=clWhite;
   result.Canvas.Rectangle(0,0,MGS,MGS);
   result.canvas.CopyRect(rect(MGHS-(w div 2),MGHS-(h div 2),MGHS+(w div 2),MGHS+(h div 2)) ,tpng.Canvas, rect(0,0,tpng.Width,tpng.Height) );
   result.TransparentColor:=cl;
end;

function LoadBMP(fn:string):TBitMap;
var c:single;
  w,h:byte;
   cl:TColor;
   bmp:TBitMap;
begin
   result:=TBitMap.Create;
   result.width:=MGS;
   result.height:=MGS;

   bmp:=TBitMap.Create;
   if FileExists(fn) then bmp.LoadFromFile(fn);
   with bmp do
   begin
      cl:=Canvas.Pixels[0,0];
      if width =0 then width :=1;
      if height=0 then height:=1;
      c:=width/height;
      if (width>height) then
      begin
         if (width>MGS) then
         begin
            w:=MGS;
            h:=trunc(w/c);
         end else
         begin
            w:=width;
            h:=height;
         end;
      end else
      begin
         if (height>MGS) then
         begin
            h:=MGS;
            w:=trunc(h*c);
         end else
         begin
            w:=width;
            h:=height;
         end;
      end;
   end;
   result.canvas.draw(0,0,tspr);
   result.canvas.CopyRect(rect(MGHS-(w div 2),MGHS-(h div 2),MGHS+(w div 2),MGHS+(h div 2)) ,bmp.Canvas, rect(0,0,bmp.Width,bmp.Height) );
   result.TransparentColor:=cl;
   bmp.free;
end;


function LoadSprite(fn:string):TBitMap;
const folders_n = 2;
      folders_l : array[1..folders_n] of string = ('graphic_nonazi\','graphic\');
var tpng:TPNGImage;
      fs:string;
       n:integer;
begin
   for n:=1 to folders_n do
   begin
      fs:=folders_l[n]+fn+'.png';
      if(FileExists(fs))then
      begin
         tpng:=TPNGImage.Create();
         tpng.LoadFromFile(fs);
         result:= png2bitmap(tpng);
         tpng.Destroy();
         exit;
      end
      else
      begin
         fs:=fn+'.bmp';
         if(FileExists(fs))then
         begin
            result:=LoadBMP(fs);
            exit;
         end;
      end;
   end;
   result:=TBitMap.Create;
   result.width :=MGS;
   result.height:=MGS;
end;

procedure CalcBorder;
begin
   vbx:=MGS*MS-form1.image1.Width +MGS;
   vby:=MGS*MS-form1.image1.Height+MGS;
end;

procedure SetNewBlockSize(bx:integer);
begin
   if(bx<8  )then bx:=8;
   if(bx>128)then bx:=128;

   MGS :=bx;
   MGHS:=MGS div 2;

   CalcBorder;
   form1.Label12.Caption:='Grid size: '+i2s(MGS);
end;

procedure ReloadGraph(first:boolean);
var c:char;
   fn:string;
begin
   if(not first)then
   begin
      tspr.Destroy;

      for c:='A' to 'Z' do WSprs[c].Destroy;

      IHSpr.Destroy;
      DTSpr.Destroy;

      for c:='a' to 'z' do DSprs[c].Destroy;
      for c:='0' to '9' do ISprs[c].Destroy;

      for c:=#0 to #4 do SSprs[ord(c)].Destroy;
   end;


   tspr:=TBitMap.Create;
   tspr.Width :=MGS;
   tspr.Height:=MGS;
   tspr.canvas.pen.style:=psClear;
   tspr.canvas.Brush.Color:=clWhite;
   tspr.canvas.Rectangle(0,0,MGS,MGS);

   for c:='A' to 'Z' do WSprs[c]:=LoadSprite('w'+c);

   IHSpr:=LoadSprite('w_');
   DTSpr:=LoadSprite('wd0');
   for c:='a' to 'z' do
   begin
      DSprs[c]:=LoadSprite('d'+c);
      DSprs[c].Transparent:=true;
   end;
   for c:='0' to '9' do
   begin
      ISprs[c]:=LoadSprite('it'+c);
      ISprs[c].Transparent:=true;
   end;

   for c:=#0 to #4 do
   begin
      SSprs[ord(c)]:=TBitMap.Create;
      with SSprs[ord(c)] do
      begin
         width :=MGS;
         height:=MGS;
         canvas.pen.style:=psClear;
         canvas.Brush.Color:=clWhite;
         canvas.Rectangle(0,0,MGS,MGS);
         canvas.pen.style:=psSolid;
         canvas.pen.color:=clRed;
         canvas.pen.width:=4;
      end;
   end;
   SSprs[0].canvas.moveTo(0,0);
   SSprs[0].canvas.LineTo(MGS,MGS);
   SSprs[0].canvas.moveTo(0,MGS);
   SSprs[0].canvas.LineTo(MGS,0);

   SSprs[1].canvas.moveTo(MGS,0);
   SSprs[1].canvas.LineTo(0,MGHS);
   SSprs[1].canvas.LineTo(MGS,MGS);

   SSprs[2].canvas.moveTo(0,MGS);
   SSprs[2].canvas.LineTo(MGHS,0);
   SSprs[2].canvas.LineTo(MGS,MGS);

   SSprs[3].canvas.moveTo(0,0);
   SSprs[3].canvas.LineTo(MGS,MGHS);
   SSprs[3].canvas.LineTo(0,MGS);

   SSprs[4].canvas.moveTo(0,0);
   SSprs[4].canvas.LineTo(MGHS,MGS);
   SSprs[4].canvas.LineTo(MGS,0);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   form1.DoubleBuffered:=true;
   Form1.Left := (Screen.Width  shr 1) - (Form1.Width  shr 1);
   Form1.Top  := (Screen.Height shr 1) - (Form1.Height shr 1);

   SetNewBlockSize(32);
   ReloadGraph(true);


   view.x:=0;
   view.y:=0;

   timer1.Enabled:=true;
   form1.image1.Canvas.Font.size:=10;

   clearmap;
   DrawBrush(form1.image2,0,0,brsh);
   drawFlCe;
   objcounter;
end;

procedure mouseProc;
var ui_m_f:TPoint;
begin
   ui_m_f.x:=0;
   ui_m_f.y:=0;
   ScreenToClient(form1.Handle,ui_m_f);
   with Form1 do
   begin
      ui_m_f.x:=max(0,min(Image1.Width  , ui_m_f.x + Mouse.CursorPos.x - Image1.left));
      ui_m_f.y:=max(0,min(Image1.height , ui_m_f.y + Mouse.CursorPos.y - Image1.Top));
   end;

   mp.x:=view.x+ui_m_f.x;
   mp.y:=view.y+ui_m_f.y;
   mpg.x:=min(mp.x div MGS,MS);
   mpg.y:=min(mp.y div MGS,MS);

   form1.label2.Caption:=b2s(mpg.x)+','+b2s(mpg.y);
end;

procedure drawgrid;
var x,y:word;
begin
   if(not needgrid)then exit;
   x:=MGS-(view.x mod MGS);
   y:=MGS-(view.y mod MGS);
   with form1.image1 do
   begin
      canvas.pen.Color:=clGray;
      while x<width do
      begin
         canvas.MoveTo(x,0);
         canvas.LineTo(x,height);
         inc(x,mgs);
      end;
      while y<height do
      begin
         canvas.MoveTo(0,y);
         canvas.LineTo(width,y);
         inc(y,mgs);
      end;
   end;
end;

procedure RedrawMap;
var x0,y0,x1,y1,y,x:byte;
    tx,ty:integer;
begin

   with form1.image1 do
   begin
      Canvas.draw(0,0,tspr);
      Canvas.brush.Color:=clWhite;
      Canvas.FillRect(rect(0,0,width,height));
   end;

   x0:=view.x div MGS;
   y0:=view.y div MGS;
   x1:=min(ms,(view.x+form1.ClientWidth ) div MGS);
   y1:=min(ms,(view.y+form1.ClientHeight) div MGS);
   for x:=x0 to x1 do
    for y:=y0 to y1 do
    begin
       tx:=(x-x0)*MGS-(view.x mod MGS);
       ty:=(y-y0)*MGS-(view.y mod MGS);
       DrawBrush(form1.image1,tx,ty,map[x,y]);
    end;

   drawgrid;
end;

procedure viewborders;
begin
   view.x:=max(0,min(view.x,vbx));
   view.y:=max(0,min(view.y,vby));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   ui_keypress_cycle;
   mouseProc;

   if(newMGS<>MGS)then
   begin
      SetNewBlockSize(newMGS);
      newMGS:=MGS;

      ReloadGraph(false);
      drw:=1;
   end;

   if(ui_keypress[ord('G')]=2)then
   begin
      drw:=1;
      needgrid:=not needgrid;
   end;

   if (ui_keypress[VK_LEFT ]>0)or(ui_keypress[VK_A]>0) then begin view.x:=view.x-view_spd; drw:=1;end;
   if (ui_keypress[VK_RIGHT]>0)or(ui_keypress[VK_D]>0) then begin view.x:=view.x+view_spd; drw:=1;end;
   if (ui_keypress[VK_UP   ]>0)or(ui_keypress[VK_W]>0) then begin view.y:=view.y-view_spd; drw:=1;end;
   if (ui_keypress[VK_DOWN ]>0)or(ui_keypress[VK_S]>0) then begin view.y:=view.y+view_spd; drw:=1;end;

   viewborders;

   if ui_keypress[VK_LBUTTON]>0 then begin map[mpg.x,mpg.y]:=brsh; drw:=1;objcounter;end;
   if ui_keypress[VK_RBUTTON]>0 then begin map[mpg.x,mpg.y]:=' ';  drw:=1;objcounter;end;
   if ui_keypress[VK_MBUTTON]>0 then
   if map[mpg.x,mpg.y]<>' ' then
   begin
      brsh:=map[mpg.x,mpg.y];
      DrawBrush(form1.image2,0,0,brsh);
      if (brsh in walls ) then form1.SpeedButton4 .Down:=True;
      if (brsh in decors) then form1.SpeedButton5 .Down:=True;
      if (brsh in items ) then form1.SpeedButton6 .Down:=True;
      if (brsh in spawns) then form1.SpeedButton12.Down:=True;
   end;

   if drw>0 then RedrawMap;
   drw:=0;
end;

procedure BrushNext(next:boolean);
var r: set of char;
begin
   if (brsh in walls ) then r:=walls;
   if (brsh in decors) then r:=decors;
   if (brsh in items ) then r:=items;
   if (brsh in spawns) then r:=spawns;

   repeat
      if(next)
      then inc(brsh)
      else dec(brsh);
   until (brsh in r);
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;MousePos: TPoint; var Handled: Boolean);
begin
   if(ui_keypress[vk_control]>0)then
   begin
      //newMGS:=newMGS-8;
   end
   else
   begin
      BrushNext(true);
      DrawBrush(form1.image2,0,0,brsh);
   end;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   if(ui_keypress[vk_control]>0)then
   begin
      //newMGS:=newMGS+8;
   end
   else
   begin
      BrushNext(false);
      DrawBrush(form1.image2,0,0,brsh);
   end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
var key:byte;
begin
   key:=0;
   if (Button=mbLeft  ) then key:=1;
   if (Button=mbRight ) then key:=2;
   if (Button=mbMiddle) then key:=4;
   if (ui_keypress[key]=0) then ui_keypress[key]:=1;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
var key:byte;
begin
   key:=0;
   if (Button=mbLeft  ) then key:=1;
   if (Button=mbRight ) then key:=2;
   if (Button=mbMiddle) then key:=4;
   ui_keypress[key]:=0;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);begin if (ui_keypress[key]=0) then ui_keypress[key]:=1;end;
procedure TForm1.FormKeyUp  (Sender: TObject; var Key: Word;  Shift: TShiftState);begin ui_keypress[key]:=0;end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
   brsh:='A';
   DrawBrush(form1.image2,0,0,brsh);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
   brsh:='a';
   DrawBrush(form1.image2,0,0,brsh);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
   brsh:='1';
   DrawBrush(form1.image2,0,0,brsh);
end;

procedure TForm1.SpeedButton12Click(Sender: TObject);
begin
   brsh:='@';
   DrawBrush(form1.image2,0,0,brsh);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var fn:string;
begin
   form1.SaveDialog1.execute;
   fn:=form1.SaveDialog1.FileName;
   if (fn='') then exit;
   if (extractfileext(fn)<>'.m3dm') then fn:=fn+'.m3dm';
   form1.Caption:=pname+': '+fn;

   SaveMap(fn);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
   LoadMap;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
   ClearMap;
end;

procedure TForm1.Image3Click(Sender: TObject);
var c,i:TColor;
begin
   ColorDialog1.Options:=[cdFullopen];
   ColorDialog1.Color:=image3.Canvas.pixels[1,1];
   if ColorDialog1.Execute=false then exit;
   c:=ColorDialog1.Color;
   map_fc[0]:=GetRValue(c);
   map_fc[1]:=GetGValue(c);
   map_fc[2]:=GetBValue(c);
   for i:=0 to 5 do map_fc[i]:=28*(map_fc[i] div 28);
   DrawFlCe;
end;

procedure TForm1.Image4Click(Sender: TObject);
var c,i:TColor;
begin
   ColorDialog1.Options:=[cdFullopen];
   ColorDialog1.Color:=image4.Canvas.Pixels[1,1];
   if ColorDialog1.Execute=false then exit;
   c:=ColorDialog1.Color;
   map_fc[3]:=GetRValue(c);
   map_fc[4]:=GetGValue(c);
   map_fc[5]:=GetBValue(c);
   for i:=0 to 5 do map_fc[i]:=28*(map_fc[i] div 28);
   DrawFlCe;
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
   move_map(0 ,1 );
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
   move_map(0 ,-1);
end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
begin
   move_map(-1,0 );
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
begin
   move_map(1 ,0 );
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
begin
   if(FileExists(file_name))then SaveMap(file_name);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
   image1.Width :=ClientWidth -image1.Left;
   image1.Height:=ClientHeight-image1.Top;

   image1.Picture.Bitmap.Width :=image1.Width;
   image1.Picture.Bitmap.Height:=image1.Height;

   CalcBorder;

   SetNewBlockSize(MGS);

   drw:=1;
end;


end.
