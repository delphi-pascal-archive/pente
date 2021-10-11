unit MainU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, ToolWin, ComCtrls, StdCtrls, Menus,penteU,NewGameU,
  ImgList,AboutU;

type
  tlineDir = (tldVertical,tldHorizontal,tldSlash,tldBackSlash);
  TfrmMain = class(TForm)
    pnlGame: TPanel;
    pnlWeight: TPanel;
    splMain: TSplitter;
    mmMain: TMainMenu;
    sgWeight: TStringGrid;
    pnlHigh: TPanel;
    Label1: TLabel;
    edtHighestCoord: TEdit;
    edtHighestValue: TEdit;
    pnlTurn: TPanel;
    Label2: TLabel;
    edtTurn: TEdit;
    File1: TMenuItem;
    miExit: TMenuItem;
    NewGame1: TMenuItem;
    dgboard: TDrawGrid;
    imPieces: TImageList;
    View1: TMenuItem;
    miMap: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure miExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewGame1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgBoardMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sgBoardClick(Sender: TObject);
    procedure dgboardDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure About1Click(Sender: TObject);
    procedure miMapClick(Sender: TObject);
  private
    { Private declarations }
    fgame:tpenteGame;
    fbitmap:tbitmap;
    fx,fy:integer;
    fstrategy:tstrategy;
    procedure SetupGrid(aGrid:tstringGrid);
    procedure drawValues;
    procedure drawPick(p:tpoint);
    procedure drawTurn;
  public
    { Public declarations }

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  fgame := nil;
  pnlWeight.visible := false;
  pnlgame.visible := false;
  splmain.Visible := false;
  fbitmap := tbitmap.Create;
end;

procedure TfrmMain.NewGame1Click(Sender: TObject);
var
  dlg:TfrmNewGame;
begin
  dlg := tfrmNewGame.Create(self);
  try
    dlg.showmodal;
    if dlg.ok then begin
      if fgame <> nil then begin
        fgame.Free;
        fgame := nil;
      end;
      fgame := tpentegame.create(dlg.size,dlg.linesize);
      if dlg.cbStyle.Text = 'Defensive' then begin
        fstrategy :=stgdefensive
      end
      else begin
        fstrategy :=stgofensiveDefensive;
      end;
      pnlgame.visible := true;
      SetupGrid(sgWeight);
      dgboard.ColCount := dlg.size+1;
      dgboard.RowCount := dlg.size+1;
      drawValues;
      drawTurn;
      dgboard.Repaint;
    end;
  finally
    dlg.free;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fgame.Free;
  fbitmap.free;
end;

procedure TfrmMain.sgBoardMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  fx:= x;
  fy:= y;
end;

procedure TfrmMain.sgBoardClick(Sender: TObject);
var
  cx,cy:integer;
  p:tpoint;
begin
  if fgame.isGameOver = false then begin
    dgBoard.MouseToCell(fx,fy,cx,cy);
    if fgame.getBoard(cx,cy)<> 0 then exit;

    fgame.setBoard(cx,cy,pente_oponent);
    dgboard.Repaint;
    if fgame.iswinningplayer(true) then begin
      application.MessageBox('You are victorious!!!','Message',mb_ok);
      exit;
    end;
    if fgame.ChooseCell(stgofensiveDefensive,p)then begin

      self.drawValues;    
      fgame.setBoard(p.x,p.y,pente_system);
      drawPick(p);
      dgboard.repaint;
    end;
    if fgame.iswinningplayer(false) then begin
      application.MessageBox('I am victorious!!!','Message',mb_ok);
      exit;
    end;
    if fgame.IsTie then begin
      application.MessageBox('Tie !!!','Message',mb_ok);
      exit;
    end;
    fgame.incTurn;
    self.drawTurn;
  end;
end;

procedure TfrmMain.SetupGrid(aGrid:tstringGrid);
var
  i:integer;
begin
  aGrid.ColCount := fgame.getSize+1;
  aGrid.RowCount := fgame.getSize+1;
  for i := 1 to fgame.getSize do begin
    aGrid.Cells[0,i] := intToStr(i);
    aGrid.Cells[i,0] := intTostr(i);
  end;
end;


procedure TfrmMain.drawValues;
var
  x,y:integer;
  v:double;
  s:string;
begin
  for y := 1 to fgame.getsize do begin
    for x := 1 to fgame.getsize do begin
      v:= fgame.getValue(x,y);
      s:= format('%5.2f',[v]);
      sgWeight.Cells[x,y]:=s;
    end;
  end;
end;

procedure TfrmMain.drawPick(p:tpoint);
var
  v:double;
  sv:string;
  sp:string;
begin
  sp := format('(%d,%d)',[p.x,p.y]);
  v:=fgame.getValue(p.x,p.y);
  sv:= format('%5.2f',[v]);
  edtHighestCoord.text := sp;
  edtHighestValue.text := sv;
end;

procedure TfrmMain.drawTurn;
begin
  edtTurn.Text := inttostr(fgame.getTurn);
end;

procedure TfrmMain.dgboardDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  i:integer;
  s:string;
begin
  dgboard.Canvas.Brush.Style := bsSolid;
  dgboard.canvas.brush.Color := clSilver;
  dgboard.Canvas.FillRect(Rect);
  dgboard.Canvas.Pen.Color := clblack;
  dgboard.canvas.Rectangle(Rect);
  if Arow = 0 then begin
    s:= intTostr(aCol);
    dgboard.Canvas.TextOut(Rect.Left,Rect.Top,s);
    exit;
  end;
  if Acol = 0 then begin
    s:= intToStr(aRow);
    dgboard.Canvas.TextOut(rect.Left,Rect.Top,s);
    exit;
  end;
  i:=fgame.getBoard(Acol,ARow);
  if i > 0 then begin
    imPieces.GetBitmap(i,fbitmap);
    dgboard.Canvas.Draw(Rect.left,rect.top,fbitmap);
  end;
end;

procedure TfrmMain.About1Click(Sender: TObject);
var
  f:TfrmAbout;
begin
  f:=TfrmAbout.create(self);
  try
    f.ShowModal;
  finally
    f.free;
  end;
end;

procedure TfrmMain.miMapClick(Sender: TObject);
begin
  if fgame = nil then exit;
  miMap.Checked := not miMap.Checked;

  if miMap.checked =false then begin
    pnlWeight.Visible := false;
    splMain.visible := false;
  end
  else begin
    pnlWeight.visible := true;
    splMain.Left := pnlWeight.Width;
    splMain.visible := true;
  end;
end;

end.
