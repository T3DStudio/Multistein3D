program wme;

uses
  Forms,
  wmeu in 'wmeu.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Multistein3D Map Editor';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
