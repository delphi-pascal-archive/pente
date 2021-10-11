unit NewGameU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Buttons, Spin;

type
  TfrmNewGame = class(TForm)
    Label1: TLabel;
    label2: TLabel;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    speSize: TSpinEdit;
    speLineSize: TSpinEdit;
    cbStyle: TComboBox;
    Label3: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ok:boolean;
    size,
    lineSize:integer;
  end;

var
  frmNewGame: TfrmNewGame;

implementation

{$R *.DFM}

procedure TfrmNewGame.btnOkClick(Sender: TObject);
begin
  size := speSize.Value;
  lineSize := speLineSize.Value;
  if (linesize < size) and (linesize < 4) then begin
    application.MessageBox('Line size mut be >= 4 when line size < size','Error',mb_ok);
    exit;
  end;
  if lineSize > size then begin
    application.MessageBox('Line Size must be <= Size','Error',mb_ok);
    exit;
  end;
  close;
  ok:= true;
end;

procedure TfrmNewGame.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmNewGame.FormShow(Sender: TObject);
begin
  ok:=false;
  cbStyle.ItemIndex := 0;
end;

end.
