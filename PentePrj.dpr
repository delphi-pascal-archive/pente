program PentePrj;

uses
  Forms,
  MainU in 'MainU.pas' {frmMain},
  NewGameU in 'NewGameU.pas' {frmNewGame},
  PenteU in 'PenteU.pas',
  AboutU in 'AboutU.pas' {frmAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
