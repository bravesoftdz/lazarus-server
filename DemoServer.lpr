program DemoServerProject;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, sockets, blcksock, Synautil;
type
  DemoServer = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ Sender }

procedure AttendConnection(ASocket: TTCPBlockSocket);
var
  timeout: integer;
  s: string;
begin
     timeout := 12000;
     s:= ASocket.RecvBlock(12000);
     writeln(s);
     // Отправить строку
     ASocket.SendString('Hello client!!!' + CRLF);
end;

procedure DemoServer.DoRun;
var
  ErrorMsg: String;
  ListenerSocket, ConnectionSocket: TTCPBlockSocket;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { My programm }

  writeln('SERVER: start on localhost:69555 OK!');

  try
    ListenerSocket := TTCPBlockSocket.Create;
    ConnectionSocket := TTCPBlockSocket.Create;

    ListenerSocket.CreateSocket;
    ListenerSocket.setLinger(true,10);
    ListenerSocket.bind('0.0.0.0','69555');
    ListenerSocket.listen;

    repeat
          if ListenerSocket.canread(1000) then
          begin
               ConnectionSocket.Socket := ListenerSocket.accept;
               WriteLn('SERVER: Connect client (0=Success): ',
                                              ConnectionSocket.lasterror);
               AttendConnection(ConnectionSocket);
          end;
    until false;

    ListenerSocket.Free;
    ConnectionSocket.Free;

  finally
    ListenerSocket.Free;
    ConnectionSocket.Free;
  end;

  Terminate;
end;

constructor DemoServer.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor DemoServer.Destroy;
begin
  inherited Destroy;
end;

procedure DemoServer.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: DemoServer;

{$R *.res}

begin
  Application:=DemoServer.Create(nil);
  Application.Run;
  Application.Free;
end.

