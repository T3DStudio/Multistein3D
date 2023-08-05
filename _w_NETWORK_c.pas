procedure net_clearbuffer;
begin
   net_buffer^.len:=0;
   net_bufpos     :=0;
end;

procedure net_DownSocket;
begin
   if(net_socket<>nil)then
   begin
      SDLNet_UDP_Close(net_socket);
      net_socket:=nil;
   end;
end;

function net_UpSocket(port:word;force:boolean):boolean;
begin
   net_UpSocket:=false;

   if(port<>net_socket_port)or(net_socket=nil)or(force)then
   begin
      net_DownSocket;

      net_socket:=SDLNet_UDP_Open(port);
      if(net_socket=nil)then
      begin
         WriteSDLError('SDLNet_UDP_Open');
         exit;
      end;
      net_socket_port:=port;
   end;

   net_UpSocket:=true;
end;

function InitNET:boolean;
begin
   InitNET:=false;

   if(SDLNet_Init<>0)then
   begin
      WriteSDLError('InitNET');
      exit;
   end;

   net_buffer:=SDLNet_AllocPacket(MaxNetBuffer);
   if(net_buffer=nil)then
   begin
      WriteSDLError('SDLNet_AllocPacket');
      exit;
   end;

   InitNET:=true;
end;

////////////////////////////////////////////////////////////////////////////////

procedure net_send(ip:cardinal; port:word);
begin
   net_buffer^.len         :=net_bufpos;
   net_buffer^.address.host:=ip;
   net_buffer^.address.port:=port;
   SDLNet_UDP_Send(net_socket,-1,net_buffer);

   {$IFDEF FULLGAME}
   net_packets_out+=1;
   {$ENDIF}
end;


function net_receive:integer;
begin
   net_clearbuffer;
   net_receive:=SDLNet_UDP_Recv(net_socket,net_buffer);
   net_bufpos:=0;
end;

// READ   //////////////////////////////////////////////////////////////////

procedure net_buff(w:boolean;vs:integer;p:pointer);
begin
   if(net_bufpos>MaxNetBuffer)then exit;
   if((MaxNetBuffer-net_bufpos)<vs)then exit;
   if(w=false)and((net_buffer^.len-net_bufpos)<vs)then exit;

   if(w)
   then move(p^,(net_buffer^.data+net_bufpos)^,     vs)
   else move(   (net_buffer^.data+net_bufpos)^, p^, vs);
   net_bufpos+=vs;
end;

function net_readbyte:byte;
begin
   net_readbyte:=0;
   net_buff(false,SizeOf(net_readbyte),@net_readbyte);
end;

function net_readsint:shortint;
begin
   net_readsint:=0;
   net_buff(false,SizeOf(net_readsint),@net_readsint);
end;

function net_readchar:char;
begin
   net_readchar:=chr(net_readbyte);
end;

function net_readbool:boolean;
begin
   net_readbool:=(net_readbyte>0);
end;

function net_readint:integer;
begin
   net_readint:=0;
   net_buff(false,SizeOf(net_readint),@net_readint);
end;

function net_readword:word;
begin
   net_readword:=0;
   net_buff(false,SizeOf(net_readword),@net_readword);
end;

function net_readcard:cardinal;
begin
   net_readcard:=0;
   net_buff(false,SizeOf(net_readcard),@net_readcard);
end;

function net_readsingle:single;
begin
   net_readsingle:=0;
   net_buff(false,SizeOf(net_readsingle),@net_readsingle);
end;

function GetBBit(pb:pbyte;nb:byte):boolean;
begin
   GetBBit:=(pb^ and (1 shl nb))>0;
end;


function net_readstring:shortstring;
var sl:byte;
begin
   net_readstring:='';
   sl:=net_readbyte;
   if((net_bufpos+sl)>MaxNetBuffer)then sl:=MaxNetBuffer-net_bufpos;
   while(sl>0)do
   begin
      net_readstring:=net_readstring+net_readchar;
      sl-=1;
   end;
end;

// WRITE       /////////////////////////////////////////////////////////////////

procedure net_writebyte(b:byte);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure net_writesint(b:shortint);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure net_writechar(b:char);
begin
   net_writebyte(ord(b));
end;

procedure net_writebool(b:boolean);
begin
   net_writebyte(byte(b));
end;

procedure net_writeint(b:integer);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure net_writeword(b:word);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure net_writecard(b:cardinal);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure net_writesingle(b:single);
begin
   net_buff(true,SizeOf(b),@b);
end;

procedure SetBBit(pb:pbyte;nb:byte;nozero:boolean);
var i:byte;
begin
   i:=(1 shl nb);
   if(nozero)
   then pb^:=pb^ or i
   else
     if((pb^ and i)>0)then pb^:=pb^ xor i;
end;

procedure net_writestring(s:shortstring);
var sl,x:byte;
begin
   sl:=length(s);
   x :=1;

   net_writebyte(sl);

   while (net_bufpos<=MaxNetBuffer)and(x<=sl) do
   begin
      net_writechar(s[x]);
      x+=1;
   end;
end;

////////////////

function net_LastinIP:cardinal;
begin
   net_LastinIP:=net_buffer^.address.host;
end;

function net_LastinPort:word;
begin
   net_LastinPort:=net_buffer^.address.port;
end;




