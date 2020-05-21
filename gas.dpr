program gas;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  turtle_os in 'turtle_os.pas',
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
