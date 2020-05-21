unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, turtle_os, StdCtrls, ExtCtrls, Buttons;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Bfuellen: TButton;
    LTemp: TLabel;
    SBTemp: TScrollBar;
    BL: TBitBtn;
    BR: TBitBtn;
    Bmax: TButton;
    BO: TBitBtn;
    BU: TBitBtn;
    Lpx: TLabel;
    Lpy: TLabel;
    Lpz: TLabel;
    Label1: TLabel;
    Lp: TLabel;
    LCPU: TLabel;
    Lx: TLabel;
    Ly: TLabel;
    Lz: TLabel;
    LV: TLabel;
    EAnzahl: TEdit;
    BStart: TBitBtn;
    Bexit: TBitBtn;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BfuellenClick(Sender: TObject);
    procedure BStartClick(Sender: TObject);
    procedure BExitClick(Sender: TObject);
    procedure SBTempChange(Sender: TObject);
    procedure BLClick(Sender: TObject);
    procedure BRClick(Sender: TObject);
    procedure BmaxClick(Sender: TObject);
    procedure BOClick(Sender: TObject);
    procedure BUClick(Sender: TObject);
    procedure EAnzahlChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

  Tball=class
    farbe:TColor;
    nummer:integer;
    r0,x,y,z,vx,vy,vz:extended;
    private
      function r:extended;
    public
      constructor create(typ:byte);
      procedure bewege;
    end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.dfm}

const rand=10;
var xe: integer=1000; ye:integer=600; ze:integer=500;
    ball:Array[1..1000] of Tball;
    stop:boolean=true; isexit:boolean=false;
    T:integer=293; // Temp
    anzahl: integer=500;
    TChanged: boolean=true;
    px,py,pz: extended;
    CPUFaktor: extended=1; // 0.5 fuer langsame CPUs

procedure TForm1.FormCreate(Sender: TObject);
var i:integer; t0,t:Longword;
begin
randomize;
t0:=GetTickCount;
anzahl:=StrToInt(EAnzahl.Text);
for i:=1 to 1000 do ball[i]:=Tball.Create(random(3));
Bfuellenclick(Form1);
Lx.Caption:=IntToStr(xe); Ly.Caption:=IntToStr(ye); Lz.Caption:=IntToStr(ze);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
Application.ProcessMessages;
for i:=1 to 1000000 do canvas.Ellipse(1,1,100,100);
t:=GetTickCount;
if t>t0 then CPUfaktor:=1100/(t-t0) else CPUfaktor:=2;
LCPU.Caption:='CPU '+FloatToStr(round(CPUFaktor*100)/100);
end;


procedure kasten;
begin
init; hg(grau);
dicke(rand);
aufXY(0,ye); vw(xe); li;
vw(ye);
dicke(0); //linie(keine);
end;

procedure TForm1.BfuellenClick(Sender: TObject);
var i:integer;
begin
isexit:=false; Bexit.Caption:='exit';
kasten;
pinsel(15); Bild.Canvas.Rectangle(0,0,xe-1,ye-1);
anzahl:=StrToInt(EAnzahl.Text);
for i:=1 to anzahl do with ball[i] do
  begin
  nummer:=i;
  x:=random(100)+r; y:=random(100)+r; z:=ze-random(100)-r;
  pinsel(farbe); aufXY(x,y);
  Bild.Canvas.Ellipse(round(x-r),round(y-r),round(x+r),round(y+r));
  end;
zeichne;
end;


procedure TForm1.BStartClick(Sender: TObject);
var i,c:integer; v,pxa,pya,pza: extended; t,t0:longWord;
begin
c:=0; t0:=GetTickCount; t:=0;
isexit:=false; Bexit.Caption:='exit';
if stop then begin stop:=false; BStart.Glyph.LoadFromFile('stop.bmp'); BStart.Caption:='stop'; end
else begin stop:=true; BStart.Glyph.LoadFromFile('start.bmp'); BStart.Caption:='start'; end;
repeat
  pinsel(15); Bild.Canvas.Rectangle(0,0,xe-1,ye-1);
  if TChanged then
    begin
    T:=SBTemp.Position;
    v:=sqrt(T)/CPUFaktor;
    for i:=1 to anzahl do with ball[i] do
      begin
      vx:=((0.1+0.9*random)-0.5)*v; vy:=((0.1+0.9*random)-0.5)*v; vz:=((0.1+0.9*random)-0.5)*v;
      end;
    TChanged:=false;
    end;
  inc(c);
  if c>64 then
    begin t:=GetTickCount-t0; c:=0; end;
  if t>=5000 then
    begin
    pxa:=px*100000/(ye*ze); pya:=py*100000/(xe*ze); pza:=pz*100000/(xe*ye);
    Lpx.Caption:=FloatToStr(round(pxa)); Lpy.Caption:=FloatToStr(round(pya));
    Lpz.Caption:=FloatToStr(round(pza)); Lp.Caption:=FloatToStr(round(sqrt(pxa*pxa+pya*pya+pza*pza)));
    t0:=t0+t; t:=0; px:=0; py:=0; pz:=0;
    end;
  for i:=1 to anzahl do  ball[i].bewege;
  zeichne;
  warte(2);
until stop;
end;


procedure TForm1.BExitClick(Sender: TObject);
begin
if isexit then begin Application.Terminate; halt; end
else
  begin
  isexit:=true; Bexit.Caption:='ja?';
  stop:=true; BStart.Glyph.LoadFromFile('start.bmp'); BStart.Caption:='start';
  end;
end;

procedure TForm1.SBTempChange(Sender: TObject);
begin
T:=SBTemp.Position;
LTemp.Caption:='T = '+IntToStr(T)+' K ('+IntToStr(T-273)+'°C)';
TChanged:=true;
//BStartClick(Form1);
end;


procedure TForm1.BLClick(Sender: TObject);
var i:integer;
begin
if xe>160 then xe:=xe-40;
for i:=1 to anzahl do with Ball[i] do
  if x+r>xe then x:=xe-r;
kasten;
Lx.Caption:=IntToStr(xe);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
if stop then zeichne;
end;

procedure TForm1.BRClick(Sender: TObject);
begin
if xe<1980 then xe:=xe+20;
kasten;
Lx.Caption:=IntToStr(xe);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
if stop then zeichne;
end;

procedure TForm1.BOClick(Sender: TObject);
var i:integer;
begin
if ye>140 then ye:=ye-40;
for i:=1 to anzahl do with Ball[i] do
  if y+r>ye then y:=ye-r;
kasten;
Ly.Caption:=IntToStr(ye);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
if stop then zeichne;
end;

procedure TForm1.BUClick(Sender: TObject);
begin
if ye<1980 then ye:=ye+20;
kasten;
Ly.Caption:=IntToStr(ye);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
if stop then zeichne;
end;

procedure TForm1.BmaxClick(Sender: TObject);
begin
if Bild.Width<xe then Bfuellenclick(Form1) else
if Bild.Height<ye then Bfuellenclick(Form1);
xe:=10*round((Bild.Width-20)/10-0.5);
ye:=10*round((Bild.height-140)/10-0.5);
kasten;
Lx.Caption:=IntToStr(xe);
Ly.Caption:=IntToStr(ye);
LV.Caption:=FloatToStr(xe*ye*ze/1000000)+' M';
if stop then zeichne;
end;

(*
procedure TForm1.BKKeyPress(Sender: TObject; var key: char); // Tastenbedienung
{onKeyPress...}
begin
if key='4' then begin if b then BKleft.setFocus; BKleftClick(Form1); end;
if key='6' then begin if b then BKright.setFocus; BKrightClick(Form1); end;
if key='8' then begin if b then BKup.setFocus; BKupClick(Form1); end;
if key='2' then begin if b then BKdown.setFocus; BKdownClick(Form1); end;
if key='5' then
  begin Kx:=330; Ky:=300; IKnight.Top:=Ky; IKnight.Left:=Kx; end;
end;
 ----


 procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
 Shift: TShiftState);
begin
//showMessage(intToStr(key));
 if (shift = ([ssAlt, ssCtrl])) then Form1.color := clAqua;
end;

//KeyPreview auf true setzen

 *)


constructor Tball.create(typ:byte);
{random funktioniert hier nicht}
begin
inherited create;
case typ of
 0: begin farbe:=pink; r0:=6; end;
 1: begin farbe:=smaragd; r0:=10; end;
 2: begin farbe:=uv; r0:=12; end;
 end;
end;

procedure Tball.bewege;
begin
if x+vx+r>xe then begin px:=px+vx; vx:=-vx; end;
if y+vy+r>ye then begin py:=py+vy; vy:=-vy; end;
if z+vz+r>ze then begin pz:=pz+vz; vz:=-vz; end;
if x+vx-r<0 then begin vx:=-vx; px:=px+vx; end;
if y+vy-r<0 then begin vy:=-vy; py:=py+vy; end;
if z+vz-r<0 then begin vz:=-vz; pz:=pz+vz; end;
x:=x+vx; y:=y+vy; z:=z+vz;
pinsel(farbe); aufXY(x,y);
Bild.Canvas.Ellipse(round(x-r),round(y-r),round(x+r),round(y+r));
end;

function Tball.r:extended;
begin
r:=r0*(1-2*z/(3*ze));
end;


procedure TForm1.EAnzahlChange(Sender: TObject);
begin
if StrToInt(EAnzahl.Text)>500 then EAnzahl.Text:='500';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Form2.show;
end;

end.
