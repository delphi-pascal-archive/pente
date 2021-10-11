unit PenteU;

interface

uses classes,sysutils,windows,math;
const
  pente_oponent :integer= 1;
  pente_system :integer = 2;
type

tlineDir = (tldVertical,tldHorizontal,tldSlash,tldBackSlash);
tstrategy = (stgdefensive,stgofensiveDefensive);

tpenteGame = class
private
  weights:array[1..100,1..100] of double; //weights to pick a cell
  board:array[0..101,0..101] of integer;  //the playing board
  fsize:integer;     // the board size
  flineSize:integer; // the number of pieces in the line
  fturn:integer;     // the current turn
  fwinningplayer:integer;
protected
  lweights :array[1..2,-1..100] of integer; //weights according to # of pieces
  function isblocked(lstop,x,y:integer):boolean;
  function getCoord(x,y,delta:integer;dir:tlinedir):tpoint;
  procedure setIncStop(var aInc,aStop:integer;AnOponent:boolean);
  procedure initBoard(asize,alinesize:integer);
  function line(x,y,size:integer;dir:tlinedir;
    AnOponent,AcalcWeight:boolean):integer;
  function getWeight(anOponent:boolean;PieceCount:integer):double;
  procedure addValue(x,y:integer;d:double);virtual;
  procedure filllweights;virtual;
  function IntCalclweights(Anoponent,calc:boolean):integer;
  function isfull:boolean;
  procedure DiscardUsed;
  procedure clearweights;
  procedure calcweights(anOponent:boolean);
public
  //Game end methods
  function IsGameOver:boolean;
  function IsTie:boolean;
  function iswinningplayer(Anoponent:boolean):boolean;
  //Turn methods
  function getTurn:integer;
  procedure incTurn;
  //Board methods
  function getSize:integer;
  function getLineSize:integer;
  function getBoard(x,y:integer):integer;
  procedure setBoard(x,y,value:integer);
  function getValue(x,y:integer):double;
  //Strategy methods
  function ChooseCell(strategy:tstrategy;var p:tpoint):boolean;

  constructor create(aSize,aLineSize:integer);
end;

implementation

function tpenteGame.getCoord(x,y,delta:integer;dir:tlinedir):tpoint;
begin
  result.x := x;
  result.y := y;
  if dir =tldVertical then begin
    result.y := result.y+delta;
  end
  else if dir = tldHorizontal then begin
    result.x := result.x+delta;
  end
  else if dir = tldSlash then begin
    result.x := result.x+delta;
    result.y := result.y+delta;
  end
  else if dir = tldBackSlash then begin
    result.x := result.x - delta;
    result.y := result.y + delta;
  end;
end;

procedure tpenteGame.addValue(x,y:integer;d:double);
begin
  if d > weights[x,y] then begin
    weights[x,y]:=d;
  end
  else begin
    weights[x,y]:=weights[x,y]+0.1;
  end;
end;

procedure tpenteGame.setIncStop(var aInc,aStop:integer;AnOponent:boolean);
begin
  if AnOponent = true then begin
    ainc := pente_oponent;
    astop := pente_system;
  end
  else begin
    ainc:= pente_system;
    astop:= pente_oponent;
  end;
end;

function tpenteGame.getWeight(anOponent:boolean;PieceCount:integer):double;
begin
  if anOponent then begin
    result := lweights[pente_oponent,piececount];
  end
  else begin
    result := lweights[pente_system,piececount];
  end;
end;

procedure tpenteGame.initBoard(asize,alinesize:integer);
begin
  fillchar(weights,sizeof(weights),0);
  fillchar(board,sizeof(board),0);
  fsize := aSize;
  flineSize := aLineSize;
end;


function tpenteGame.isblocked(lstop,x,y:integer):boolean;
begin
  result := false;
  if (x = 0) or (y=0)then begin
    result := true;
    exit;
  end;
  if (x > fsize) or (y>fsize) then begin
    result := true;
    exit;
  end;
  if self.board[x,y] = lstop then begin
    result := true;
  end;
end;

function tpenteGame.line(x,y,size:integer;dir:tlinedir;
  AnOponent,AcalcWeight:boolean):integer;
var
  i:integer;
  pieceCount:integer;
  linc,lstop:integer;
  n:integer;
  w:double;
  p:tpoint;
  b1,b2:boolean;
begin
  result := 1;
  //set the count incrementing piece and the
  //count stopping piece
  setIncStop(linc,lstop,anOponent);
  pieceCount:= 0;
  //Search blocks
  p:=self.getCoord(x,y,-1,dir);
  b1:=isblocked(lstop,p.x,p.y);
  p:=self.getCoord(x,y,size,dir);
  b2:=isblocked(lstop,p.x,p.y);
  //count pieces
  for i := 0 to size -1 do begin
    p:= self.getCoord(x,y,i,dir);
    n:= board[p.x,p.y];
    if n = linc then begin
      inc(PieceCount);
    end
    else if n= lstop then begin
      pieceCount := -1;
      result := 0;
      break;
    end;
  end;
  if pieceCount = self.flineSize then begin
    self.fwinningplayer := linc;
  end;
  //Update lweights
  if AcalcWeight then begin
    w:=getWeight(anOponent,piececount);
    if b1 or b2 then w := w -1;
    for i := 0 to size -1 do begin
      p:= self.getCoord(x,y,i,dir);
      addValue(p.x,p.y,w);
    end;
  end;
end;


procedure tpenteGame.filllweights;
var
  cont:integer;
  base:integer;
begin
  base := flinesize *4;
  for cont := self.flineSize-1 downto 1 do begin
    lweights[pente_oponent,cont] := base;
    if base >=(cont*2) then begin
      base := base div 2;
    end
    else begin
      base := cont;
    end;
  end;
  base := flinesize *3;
  for cont := self.flineSize-1 downto 1 do begin
    lweights[pente_system,cont] := base;
    if base >(cont*2) then begin
      base := base div 2;
    end
    else begin
      base := cont;
    end;
  end;
  // Only one more piece needed for victory . Give it a significantly high weight 
  lweights[pente_system,flineSize-1]:=lweights[pente_system,flineSize-1] *2;
end;


function tpenteGame.IsGameOver:boolean;
begin
  result := false;
  if iswinningplayer(true) or
  iswinningplayer(false) then begin
    result := true;
    exit;
  end;
  if istie then result := true;
end;

function tpenteGame.IsTie:boolean;
var
  n:integer;
begin
  result := false;
  n := IntCalclweights(true,false)
    +intCalclWeights(false,false);
  if (iswinningplayer(true) = false) and
  (iswinningplayer(false) =false) and
  (n = 0) then result := true;
end;

function tpenteGame.isfull:boolean;
var
  x,y:integer;
  isfull:boolean;
begin
  //tie
  result :=true;
  for y := 1 to fsize do begin
    for x := 1 to fsize do begin
      if board[x,y] = 0 then begin
        result := false;
        break;
      end;
    end;
  end;
end;


function tpenteGame.getTurn:integer;
begin
  result := fturn;
end;

procedure tpenteGame.incTurn;
begin
  inc(fturn);
end;

function tpenteGame.getSize:integer;
begin
  result := fsize;
end;

function tpenteGame.getLineSize:integer;
begin
  result := flineSize;
end;

function tpenteGame.getValue(x,y:integer):double;
begin
  result := weights[x,y];
end;

function tpenteGame.getBoard(x,y:integer):integer;
begin
  result := board[x,y];
end;

procedure tpenteGame.DiscardUsed;
var
  x,y:integer;
begin
  for y := 1 to fsize do begin
    for x := 1 to fsize do begin
      if board[x,y] > 0 then weights[x,y]:= -1;
    end;
  end;
end;

procedure tpenteGame.setBoard(x,y,value:integer);
begin
  if board[x,y] = 0 then begin
    board[x,y] := value;
  end;
end;

function tpenteGame.Iswinningplayer(Anoponent:boolean):boolean;
begin
  result := false;
  IntCalclweights(Anoponent,false);
  if fwinningplayer <> 0 then begin
    result := true;
  end;
end;

procedure tpenteGame.clearweights;
begin
  fillchar(weights,sizeof(weights),0);
end;

function tpenteGame.IntCalclweights(Anoponent,calc:boolean):integer;
var
  x,y:integer;
  itop:integer;
begin
  itop := (self.fsize - self.flineSize)+1;
  result := 0;
  //horizontal
  for y := 1 to self.fsize  do begin
    for x := 1 to itop do begin
      result := result+line(x,y,flinesize,tldhorizontal,anOponent,calc);
    end;
  end;
  //Vertical
  for y := 1 to itop do begin
    for x := 1 to self.fsize do begin
      result := result+line(x,y,flinesize,tldvertical,anOponent,calc);
    end;
  end;
  //slash
  for y := 1 to itop do begin
    for x := 1 to itop do begin
      result := result+line(x,y,flinesize,tldslash,anOponent,calc);
    end;
  end;
  //backslash
  for y := 1 to itop do begin
    for x := self.fsize downto (self.fsize +1 )-itop do begin
      result := result+line(x,y,flinesize,tldbackslash,anOponent,calc);
    end;
  end;
end;

procedure tpenteGame.calcweights(anOponent:boolean);
begin
  IntCalclweights(anOponent,true);
end;

function tpenteGame.ChooseCell(strategy:tstrategy;var p:tpoint):boolean;
var
  value:double;
  x,y:integer;
begin
  clearWeights;
  CalcWeights(true);
  if strategy = stgofensiveDefensive then begin
    CalcWeights(false);
  end;
  DiscardUsed;

  p.x := 0;
  p.y:= 0;
  if self.isfull then begin
    result :=false;
    exit;
  end;
  result := true;
  value := 0;
  for y := 1 to fsize do begin
    for x := 1 to fsize do begin
      if weights[x,y] >= value then begin
        value := weights[x,y];
        p.x:= x;
        p.y:= y;
      end;
    end;
  end;
end;

constructor tpenteGame.create(aSize,aLineSize:integer);
begin
  if aLineSize > aSize then begin
    raise Exception.create('Invalid Line size > size');
  end;
  initBoard(asize,alinesize);
  fturn := 1;
  fwinningplayer:=0;
  fillchar(lweights,sizeof(lweights),0);
  filllweights;
end;

end.
