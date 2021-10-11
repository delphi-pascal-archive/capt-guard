program Guard;

uses
  Forms,
  Ccntrol1 in 'Ccntrol1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Видеонаблюдение';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
