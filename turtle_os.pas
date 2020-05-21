unit turtle_os;

(******************************************************************

V 1.65 os (04627-dt) "magic cols" (T's Turtle)
2002 by Thomas Köhler, www.thkoehler.de TommySoft(TM)
Erzeugung eines OffScreenImages 'Bild' zur flackerfreien Animation
 !!! Do not modify !!!

Feel free to use this unit - only completely -
provided this header remains intact.
However, this unit is not for commercial use and may not be used
in programs with commercial purpose.

Neuheiten
---------
- rgbFarbe(s1,s2,h1,h2)
V. 1.6x (02a21)
- Farbverlauf horizontal oder radial
- vwBis(Farbe)
- Richtung zu einem Punkt
- Grauwertberechnung, grauer Bildausschnitt; Dithering
- optimierte Farbboperationen, 32 Bit-Farbeingabe, Transparentfarbe
- Zerlegung in R-G-B und T-R-G-B
- Farbtiefe zum Speichern
- Neigung mit fixem Polarwinkel in Vorbereitung
V. 1.5 (02919):
- ellipseZ (ohne Neigung)
V. 1.3:
- Ellipse2
V. 1.2:
- property Neigung
- Neigung
- Farboperationen
V. 1.1 (027xx):
- property Igel.Richtung

Bekannte Fehler und Probleme:
-----------------------------
1. Bei verstecktem Igel sind Ausführungsfehler nicht völlig
   ausgeschlossen, aber nicht zu erwarten.
   Abhilfe: Procedure zi

2. Die Verwendung der schnellen X-Proceduren (XFbogen...)
   kann zu metrischen Ungenauigkeiten (Verwerfungen von 1 px)
   führen.

*******************************************************************)

interface

uses Windows, SysUtils, Graphics, Forms, Clipbrd, Controls;

type  Tier=class
        farbe: TColor;
        groesse: integer;
        sichtbar: boolean;
        procedure zeige;
        procedure verstecke;
      private
       function gx: integer;
       function gy: integer;
       function gr: extended;
       function gn: extended;
       procedure sx(const Value: integer);
       procedure sy(const Value: integer);
       procedure sr(const Value: extended);
       procedure sn(const Value: extended);
      public
        constructor Create;
        property Richtung: extended read gr write sr;
        property Neigung: extended read gn write sn;
        property X: integer read gx write sx;
        property Y: integer read gy write sy;
      end;

const weiss=$FFFFFF; schwarz=$00; ohne=$1FFFFFFF;
      rot=TColor($0000FF); hrot=$008080FF; rosa=hrot; drot=TColor($000080);
      purpur=$008000FF; pink=$009010FF;
      gruen=$0000B000; hgruen=TColor($00FF00); dgruen=TColor($008000);
      smaragd=$0090C830;
      blau=TColor($FF0000); hblau=$00FFA0A0; dblau=TColor($800000);
      azur=$00F08030; royal=$00C06020;
      gelb=TColor($00FFFF); hgelb=$00A0FFFF; dgelb=TColor($008080); olive=dgelb;
      magenta=TColor($FF00FF); lila=magenta; violett=magenta;
      dmagenta=TColor($800080); dlila=dmagenta; dviolett=dmagenta;
      cyclam=$009830E8;
      cyan=TColor($FFFF00); blaugruen=cyan; tuerkis=cyan;
      dcyan=TColor($808000); dblaugruen=dcyan; dtuerkis=dcyan;
      orange=$0060A0FF;
      gelbgruen=$0040FF98;
      uv=$00FF3058; blauviolett=uv; indigo=uv;
      braun=$005070B0; hbraun=$006890E0;
      grau=TColor($808080); hgrau=TColor($C0C0C0); silber=$00E0E0E0;
      hintergrund=clBackground; hinter=clBackground;
      fenster=clWindow; standard=clBtnFace;
      (*** Muster: ***)
      voll=bsSolid; leer=bsClear; diagonal=bsFdiagonal;
      diag=bsFdiagonal; rdiagonal=bsBDiagonal; rdiag=bsBDiagonal;
      kreuz=bsCross; dkreuz=bsDiagCross;
      horizontal=bsHorizontal; hori=bsHorizontal; waagerecht=bsHorizontal;
      waag=bsHorizontal;
      vertikal=bsVertical; vert=bsVertical; senkrecht=bsVertical;
      senk=bsVertical;
      (*** Linie: ***)
      glatt=psSolid; durch=psSolid; strich=psDash; punkt=psDot;
      strichpunkt=psDashDot; spp=psDashDotDot; keine=psClear;
      raster=psInsideFrame;

var   Form1: Tform;
      Bild: TBitmap;
      Igel: Tier;
      hgFarbe: TColor=clBtnFace;             // Hintergrundfarbe

  Procedure init;                          // Anfangseinstellungen
  Procedure aufXY(x,y:extended);         // Igel auf Position ohne zu zeichnen
  Procedure zuXY(x,y:extended);            // Linie zum Punkt (x,y)
  Procedure vw(strecke:extended);          // vorwärts
  Procedure rw(strecke:extended);          // rückwärts
  procedure vwBis(farbe:TColor); overload; // bis zu dieser Farbe; langsam!
  procedure vwBis(rot,gruen,blau:byte); overload; // Farbe in Komponenten
  procedure vwBis(n:byte); overload;       // ...in 16-Farbpalette
  procedure dx(s:extended);                // Verschieben ohne zu zeichnen
  procedure dy(s:extended);
  Procedure li(alpha:extended=90);         // ZeichenRichtung drehen (Polar-
  Procedure re(alpha:extended=90);         // winkel bei 3D)
  Procedure sr(winkel:extended=0); overload; // setze Richtg in Grad
  Procedure sr(x,y:extended); overload;     // setze Richtg zum Punkt(x,y)
  Procedure aufKurs(winkel:extended=0); overload; // wie sr
  Procedure aufKurs(x,y:extended); overload
  Procedure sh;                            // Stift hoch;
  Procedure sa;                            // Stift ab
  procedure merke;                         // Richtg, Neigg, Position
  procedure erinnere;
  procedure schrift(groesse:integer; farbe:TColor); overload; // S.-Attribute
  procedure schrift(art:String; groesse:integer; farbe:TColor); overload;
  procedure schreibe(x,y:integer; txt:String); overload; // schreibe an (x,y)
  procedure schreibe(txt:String); overload; //  an akt. Position
  procedure fuelle(muster:TBrushStyle); overload;// eingeschl. Fläche füllen
  procedure fuelle(n:byte); overload       // n=Füllmuster
  procedure fuelle; overload               // mit aktuellem Füllmuster
  procedure fuelleBis(farbe:TColor); overload; // bis zu dieser Farbe
  procedure fuelleBis(r,g,b: byte); overload;
  procedure fuelleBis(n:byte); overload;
  procedure fuelleBis(HTMLstr:String); overload;
  procedure fuelleArM;                     // Füllfarbe vom Hintergr. abh.
  procedure warte(ms:Longword);            // warte ... Millisekunden
  procedure zi;                            // zeige Igel;
  procedure vi;                            // verstecke Igel
    (* Attribute *)
  function maxX:longInt;                   // rechter Formularrand
  function maxY:longInt;                   // unterer ~
  procedure stift(farbe:TColor=$00); overload; // Linienfarbe
  procedure stift(r,g,b:byte); overload;   // rot, grün, blau
  procedure stift(n:byte); overload;       // 16 Grundfarben
  procedure stift(HTMLstr:String); overload; // z.B. stift('80c7ff');
  procedure pinsel(farbe:TColor); overload;// Füllfarbe von Objekten
  procedure pinsel(r,g,b:byte); overload;
  procedure pinsel(n:byte); overload;
  procedure pinsel(HTMLstr:String); overload;
  procedure hg(farbe:TColor=$00FFFFFF); overload; // Hintergrund
  procedure hg(r,g,b:byte); overload;
  procedure hg(n:byte); overload;
  procedure hg(HTMLstr:String); overload;
  procedure linie(stil:TPenStyle=psSolid);        // Linienmuster
  procedure muster(m:TBrushStyle); overload;
  procedure muster(n:byte); overload;
  procedure dicke(n:extended=1);                  // Stiftdicke in px
  procedure transparent; overload;                // Hintergrund
  procedure transparent(farbe:TColor); overload;  // durchsichtige Farbe ...
  procedure transparent(r,g,b: byte); overload;   // ... transp.-Byte ohne
  procedure transparent(HTMLstr:String); overload;// ... Wirkung (-> 24 Bit)
    (* 2D-Geometrie *)               // nach links für Winkel >0 sonst n. rechts
  procedure vieleck(laenge:extended; ecken:integer=4); // n. links für ecken>0
  procedure bogen(r,winkel:extended);   // Kreisbogen
  procedure kreis(r:extended);
  procedure XFbogen(r,winkel:extended); // ~ gefüllt mit muster(), 1px ungenau
  procedure XFkreis(r:extended);        //  1px ungenau
  procedure ellipse2(a,b:extended); overload;  // beg. senkr. zum Halbmesser b
  procedure ellipse2(a,b,alpha1,alpha2:extended); overload; // von... bis
    (* 3D-Darstellungen *)
  procedure vwZ(strecke:extended);      // nach hinten in Kavalierperspektive
  procedure rwZ(strecke:extended);
  {procedure vwZN(strecke:extended);        // Beibehaltnug der Neigungsrichtg.}
  procedure neige(azimut:extended=90);     // NeigungsWinkel verändern
  procedure sn(azimut:extended);           // setze Neig.-winkel
  procedure vieleckZ(laenge:extended; ecken:integer=4);  // n. links für ecken>0
  procedure bogenZ(r,winkel:extended);     // Kreisbogen in K.-Perspektive
  procedure bogenY(r,winkel:extended);     // Kreisbogen senkrecht
  procedure ellipseZ(a,b:extended); overload; // E. in K.-Persp.
  procedure ellipseZ(a,b,alpha1,alpha2:extended); overload;
  procedure FbogenZ(r,winkel:extended);    // Kreissektor gefüllt mit muster()
    (* Farboperationen *)
  function fRGB(rot,gruen,blau:byte):TColor; overload; // z.B. 128,160,255
  function fRGB(HTMLstr:String):TColor; overload; // z.B. '80a0ff'
  function fTRGB(transp,rot,gruen,blau:byte):TColor; // mit Transparenz-Byte
  function farbeAdd(x,y:TColor):TColor;              // Farbaddition
  function farbeArM(x,y:TColor):TColor;              // arith. Mittel
  function rgbFarbe(s1:byte=0;s2:byte=255;h1:byte=0;h2:byte=255):TColor;//Zuf.-farbe
  function fGrau(farbe:TColor):TColor;               // Grauwert
  procedure inRGB(farbe:TColor; var r,g,b:byte);     // zerlegt in Komponenten
  procedure inTRGB(farbe:TColor; var t,r,g,b:byte);  // ... mit Transp.-Byte
  procedure farbVerlauf(farbe1,farbe2:TColor; a,b:extended); overload;//Rechteck
  procedure farbVerlauf(farbe1,farbe2:TColor; radius:extended);overload;//radial
  procedure dither;                                  // S/W gemustert
  procedure grauBild; overload;                      // Graustufen
  procedure grauBild(x1,y1,x2,y2:integer); overload; // ... im Rechteck
  function farbeVon(x,y:integer):TColor;             // Farbe des Bildpunktes
    (* Ein/Ausgabe *)
  procedure zeichne; overload;                       // Bildschirm
  procedure zeichne(x,y:integer); overload;          // Ausgabe an (x,y)
  procedure speichere(DateiName:String); overload;   // z.B. 'bild1.bmp'
  procedure speichere(DateiName:String; Bit:byte); overload; // Bit p. Pixel
  procedure lade(DateiName:String);            // dazu Tranzparenz einstellen!
  procedure zwischenablage;                          // Windows-Zwischenablage

implementation

const P180=PI/180;

var   mitIgel: boolean=false;    // Soll-Zustand
      xc,yc,                     // Koordinaten des GrafikKursors}
      Richtg,                    // ZeichenRichtung in Grad
      Neigg,                     // Neigungswinkel
      NeigRichtg,                // Polarwinkel in dem die Neigung erfolgt
      Rs,Nes,NRs,xcs,ycs: extended;
      StiftOben: boolean=False;

procedure SinCos(alpha: extended; var sinx, cosx: extended);
asm
  FLD     alpha
  FSINCOS
  FSTP    tbyte ptr [edx]
  FSTP    tbyte ptr [eax]
  FWAIT
end;

Procedure init;
var fw,fh: integer;
Begin
if mitIgel then Igel.verstecke;
fw:=Form1.Width div 2; fh:=Form1.Height div 2;
with Bild.Canvas do
  begin
  StiftOben:=False;
  Pen.Color:=clBlack; Pen.Mode:=pmCopy; Pen.Width:=1; Pen.Style:=psSolid;
  Brush.Color:=clLtGray; Brush.Style:=bsSolid;
  Font.Color:=clBlack; Font.Size:=12; Font.Name:='Times';
  moveTo(fw,fh);
  end;
Bild.PixelFormat:=pf32bit;
Bild.Width:=2*fw; Bild.Height:=2*fh;
Bild.Transparent:=False;
Richtg:=0; // nach rechts
Neigg:=0;
xc:=fw; yc:=fh;
if mitIgel then Igel.zeige;
End;

function fc(n:byte):TColor;
Begin
  case n of
  0: fc:=clBlack; 1: fc:=clNavy; 2: fc:=clGreen; 3: fc:=clMaroon;
  4: fc:=clTeal; 5: fc:=clPurple; 6: fc:=clOlive; 7: fc:=clDkGray;
  8: fc:=clLtGray; 9: fc:=clBlue; 10: fc:=clLime; 11: fc:=clRed;
  12: fc:=cyan; 13: fc:=clFuchsia; 14: fc:=clYellow; 15: fc:=clWhite;
  100: fc:=clNone; 101: fc:=clWindow;
  else fc:=clBlack;
  end;
End;

function fmuster(n:byte):TBrushStyle;
var m: TBrushStyle;
Begin
  case n of
  0: m:=bsSolid; 1,100: m:=bsClear; 2: m:=bsBDiagonal; 3: m:=bsFDiagonal;
  4: m:=bsCross; 5: m:=bsDiagCross; 6: m:=bsHorizontal; 7: m:=bsVertical;
  else m:=bsSolid;
  end;
  fmuster:=m;
End;

Procedure aufXY (x,y:extended);
Begin
  if mitIgel then Igel.verstecke;
  xc:=x; yc:=y;
  Bild.Canvas.MoveTo(round(xc), round(yc));
  if mitIgel then Igel.zeige;
End;

Procedure zuXY (x,y:extended);
Begin
  if mitIgel then Igel.verstecke;
  xc:=x; yc:=y;
  if stiftOben then
    Bild.Canvas.MoveTo(round(xc), round(yc)) else
    Bild.Canvas.LineTo(round(xc), round(yc));
  if mitIgel then Igel.zeige;
End;

Procedure vw(strecke:extended);
var sx,cx: extended;
Begin
  if mitIgel then Igel.verstecke;
  sincos(Richtg*P180,sx,cx);
  xc:=xc+Strecke*cx;
  yc:=yc-Strecke*sx;
  if stiftOben then
    Bild.Canvas.MoveTo(round(xc),round(yc)) else
    Bild.Canvas.LineTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
End;

Procedure rw(strecke:extended);
  Begin vw(-Strecke); End;

procedure vwBis(farbe:TColor); overload;
var Strecke,x,y,Smax:integer; sx,cx:extended;
Begin
  if mitIgel then Igel.verstecke;
  Smax:=Bild.Width+Bild.Height;
  sincos(Richtg*P180,sx,cx);
  Strecke:=0;
  repeat
    inc(Strecke);
    x:=round(xc+Strecke*cx); y:=round(yc-Strecke*sx);
  until (Bild.Canvas.Pixels[x,y]=farbe)or(Strecke>Smax);
  xc:=xc+Strecke*cx; yc:=yc-Strecke*sx;
  if stiftOben then
    Bild.Canvas.MoveTo(round(xc),round(yc)) else
    Bild.Canvas.LineTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
End;

procedure vwBis(rot,gruen,blau:byte); overload;
Begin vwBis(fRGB(rot,gruen,blau)); End;

procedure vwBis(n:byte); overload;
Begin vwBis(fc(n)); End;

procedure dx(s: extended);
Begin
  if mitIgel then Igel.verstecke;
  xc:=xc+s;
  Bild.Canvas.MoveTo(round(xc),round(yc));  // handle
  if mitIgel then Igel.zeige;
End;

procedure dy(s:extended);
Begin
  if mitIgel then Igel.verstecke;
  yc:=yc+s;
  Bild.Canvas.MoveTo(round(xc),round(yc));  // handle
  if mitIgel then Igel.zeige;
End;

Procedure li(alpha:extended=90);
Begin
  if mitIgel then Igel.verstecke;
  Richtg:=Richtg+alpha;
  if mitIgel then Igel.zeige;
End;

Procedure re(alpha:extended=90);
Begin li(-alpha); End;

Procedure sr(winkel:extended=0); overload;
Begin
  if mitIgel then Igel.verstecke;
  Richtg:=winkel;
  if mitIgel then Igel.Zeige;
End;

Procedure sr(x,y:extended); overload;
Begin
  if mitIgel then Igel.verstecke;
  x:=x-xc; y:=yc-y;
  if x=0 then
    if y>=0 tHen Richtg:=90 eLse Richtg:=270
    else
    begin
    Richtg:=arctan(y/x)/P180;
    if x<0 then Richtg:=Richtg+180;
    end;
  if mitIgel then Igel.Zeige;
End;

Procedure aufKurs(winkel:extended=0); overload
Begin sr(winkel); End;

Procedure aufKurs(x,y:extended); overload
Begin sr(x,y); End;

Procedure sh; Begin StiftOben:=True; End;
Procedure sa; Begin StiftOben:=False; End;

Procedure merke;
  Begin
  xcs:=xc; ycs:=yc; Rs:=Richtg; Nes:=Neigg; NRs:=NeigRichtg;
  End;

Procedure erinnere;
  Begin
  if mitIgel then Igel.verstecke;
  xc:=xcs; yc:=ycs;
  Richtg:=Rs; Neigg:=Nes; NeigRichtg:=NRs;
  Bild.Canvas.MoveTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
  End;

procedure schrift(groesse:integer; farbe:TColor); overload;
Begin schrift('Times',groesse,farbe); End;

procedure schrift(art:String; groesse:integer; farbe:TColor); overload;
Begin
  if art='' then art:='Times';
  with Bild.Canvas.Font do
    begin
    Name:=art; Size:=groesse; Color:=farbe;
    end;
End;

procedure schreibe(x,y:integer; txt:String); overload;
Begin Bild.Canvas.Textout(x,y,txt); End;

procedure schreibe(txt:String); overload;
Begin Bild.Canvas.Textout(round(xc),round(yc),txt); End;

procedure fuelle(muster:TBrushStyle); overload;
var Farbe: TColor; bs: TBrushStyle; x,y:integer;
Begin
  if mitIgel then Igel.verstecke;
  x:=round(xc); y:=round(yc);
  with Bild.Canvas do
    begin
    bs:=Brush.Style;
    Brush.Style:=muster;
    Farbe:=Pixels[x,y];
    Pixels[x,y]:=Farbe;   // handle
    if Brush.Color<>Farbe then
      FloodFill(x,y,Farbe,fssurface);
    Brush.Style:=bs;
    end;
  if mitIgel then Igel.zeige;
End;

procedure fuelle(n:byte); overload
Begin fuelle(fmuster(n)); End;

procedure fuelle; overload;
var Farbe: TColor; x,y: integer;
Begin
  if mitIgel then Igel.verstecke;
  x:=round(xc); y:=round(yc);
  with Bild.Canvas do
    begin
    Farbe:=Pixels[x,y];
    Pixels[x,y]:=Farbe;   // handle
    if Brush.Color<>Farbe then
      FloodFill(x,y,Farbe,fssurface);
    end;
  if mitIgel then Igel.zeige;
End;

procedure fuelleBis(farbe:TColor); overload;
var x,y: integer;
Begin
  if mitIgel then Igel.verstecke;
  x:=round(xc); y:=round(yc);
  Bild.Canvas.FloodFill(x,y,farbe,fsBorder);
  if mitIgel then Igel.zeige;
End;

procedure fuelleBis(r,g,b: byte); overload;
Begin fuelleBis(fRGB(r,g,b)); End;

procedure fuelleBis(n:byte); overload;
Begin fuelleBis(fc(n)); End;

procedure fuelleBis(HTMLstr:String); overload;
Begin fuelleBis(fRGB(HTMLstr)); End;

procedure fuelleArM;
var hFarbe,bc: TColor; x,y: integer;
Begin
  if mitIgel then Igel.verstecke;
  x:=round(xc); y:=round(yc);
  with Bild.Canvas do
    begin
    bc:=Brush.Color;
    hFarbe:=Pixels[x,y];
    Pixels[x,y]:=hFarbe;   // handle
    if hFarbe<>hgFarbe then
      Brush.Color:=farbeArM(hFarbe,bc);
    if Brush.Color<>hfarbe then
      FloodFill(x,y,hFarbe,fssurface);
    Brush.Color:=bc;
    end;
  if mitIgel then Igel.zeige;
End;

procedure warte(ms:Longword);
var i: Longword;
Begin
  i:=GetTickCount;
    repeat
    Application.ProcessMessages;
    until GetTickCount-i>=ms;
End;

procedure zi;
Begin
  if mitIgel=false then
    begin mitIgel:=True; Igel.zeige; end;
End;

procedure vi;
Begin
  if mitIgel then
    begin mitIgel:=False; Igel.verstecke; end;
End;

function maxX:longInt;
Begin result:=Form1.Width; End;

function maxY:longInt;
Begin result:=Form1.Height; End;

procedure stift(farbe:TColor=$00); overload;
Begin Bild.Canvas.Pen.Color:=farbe; End;

procedure stift(r,g,b:byte); overload;
Begin Bild.Canvas.Pen.Color:=fRGB(r,g,b); End;

procedure stift(n:byte); overload;
Begin Bild.Canvas.Pen.Color:=fc(n); End;

procedure stift(HTMLstr:String); overload;
Begin Bild.Canvas.Pen.Color:=fRGB(HTMLstr); End;

procedure pinsel(farbe:TColor); overload;
Begin Bild.Canvas.Brush.Color:=farbe; End;

procedure pinsel(r,g,b:byte); overload;
Begin Bild.Canvas.Brush.Color:=fRGB(r,g,b); End;

procedure pinsel(n:byte); overload;
Begin Bild.Canvas.Brush.Color:=fc(n); End;

procedure pinsel(HTMLstr:String); overload;
Begin Bild.Canvas.Brush.Color:=fRGB(HTMLstr); End;

procedure hg(farbe:TColor=$00FFFFFF); overload;
var bc,pc: TColor; bs:TBrushStyle;
Begin
  if mitIgel then Igel.verstecke;
  hgFarbe:=farbe;
  with Bild.Canvas do
    begin
    bc:=Brush.Color; Brush.Color:=farbe;
    pc:=Pen.Color; Pen.Color:=farbe;
    bs:=Brush.Style; Brush.Style:=bsSolid;
    Rectangle(0,0,Bild.Width,Bild.Height);
    Brush.Color:=bc; Pen.Color:=pc;
    Brush.Style:=bs;
    end;
  if mitIgel then Igel.zeige;
End;

procedure hg(r,g,b:byte); overload;
Begin hg(fRGB(r,g,b)); End;

procedure hg(n:byte); overload;
Begin hg(fc(n)); End;

procedure hg(HTMLstr:String); overload;
Begin hg(fRGB(HTMLstr)); End;

procedure linie(stil:TPenStyle=psSolid);
Begin Bild.Canvas.Pen.Style:=stil; End;

procedure muster(m:TBrushStyle); overload;
Begin Bild.Canvas.Brush.Style:=m; End;

procedure muster(n:byte); overload;
Begin Bild.Canvas.Brush.Style:=fmuster(n); End;

procedure dicke(n:extended=1);
Begin Bild.Canvas.Pen.Width:=round(n); End;

procedure transparent; overload;
Begin Bild.Transparent:=True; End;

procedure transparent(farbe:TColor); overload;
Begin
  Bild.Transparent:=True;
  Bild.TransparentColor:=farbe;
End;

procedure transparent(r,g,b: byte); overload;
Begin transparent(fRGB(r,g,b)); End;

procedure transparent(HTMLstr:String); overload;
Begin transparent(fRGB(HTMLstr)); End;

procedure vieleck(laenge:extended; ecken:integer=4);
var i: integer; w:extended;
Begin
w:=360/ecken;
for i:=1 to abs(ecken) do begin vw(laenge); li(w); end;
End;

procedure bogen(r,winkel:extended);
Begin ellipse2(r,r,0,winkel); End;

procedure kreis(r:extended);
Begin ellipse2(r,r,0,360); End;

procedure XFbogen(r,winkel:extended);
var x0,y0,x4,y4,sx,cx: extended;
Begin
  if mitIgel then Igel.verstecke;
  sincos(Richtg*P180,sx,cx);
  x0:=xc-r*sx; y0:=yc-r*cx;                // Mittelpunkt
  sincos((winkel+Richtg)*P180,sx,cx);
  x4:=x0+r*sx; y4:=y0+r*cx;
  if stiftOben=false then
    if winkel>0 then
      Bild.Canvas.pie(round(x0-r),round(y0-r),round(x0+r),round(y0+r),
      round(xc),round(yc),round(x4),round(y4))
    else
      Bild.Canvas.pie(round(x0-r),round(y0-r),round(x0+r),round(y0+r),
      round(x4),round(y4),round(xc),round(yc));
  xc:=x4; yc:=y4; Richtg:=Richtg+winkel;
  Bild.Canvas.MoveTo(round(xc),round(yc)); // handle
  if mitIgel then Igel.zeige;
End;

procedure XFkreis(r:extended);
var x0,y0,cp,sp: extended;
Begin
  if stiftOben then exit;
  if mitIgel then Igel.verstecke;
  sincos(Richtg*P180,sp,cp);
  x0:=xc-r*sp; y0:=yc-r*cp;
  Bild.Canvas.Ellipse(round(x0-r),round(y0-r),round(x0+r),round(y0+r));
  Bild.Canvas.MoveTo(round(xc),round(yc)); // handle
  if mitIgel then Igel.zeige;
End;

procedure ellipse2(a,b:extended); overload;
Begin ellipse2(a,b,0,360); End;

procedure ellipse2(a,b,alpha1,alpha2:extended); overload;
var x0,y0,x,y,alpha2b,w,dw,asp,acp,bsp,bcp,sw,cw: extended;
    flag: boolean;
Begin
  if (a<=0)or(b<=0) then exit;
  if mitIgel then Igel.verstecke;
  sincos(Richtg*P180,sw,cw);
  x0:=xc-b*sw; y0:=yc-b*cw;
  asp:=a*sw; acp:=a*cw; bsp:=b*sw; bcp:=b*cw;
  if a>b then dw:=1/a else dw:=1/b;
  flag:=alpha2<alpha1;
  if flag then
    bEgin x:=alpha1; alpha1:=alpha2; alpha2:=x; eNd;
  w:=alpha1*P180;
  if alpha1<>0 then
    bEgin
    sincos(w,sw,cw);
    x:=x0+acp*sw+bsp*cw; y:=y0+bcp*cw-asp*sw;
    Bild.Canvas.MoveTo(round(x),round(y));
    eNd;
  alpha2b:=alpha2*P180;
    Repeat
    w:=w+dw;
    sincos(w,sw,cw);
    x:=x0+acp*sw+bsp*cw; y:=y0+bcp*cw-asp*sw;
    if StiftOben=false then
      Bild.Canvas.LineTo(round(x),round(y));
    Until w>alpha2b;
  if flag then
    bEgin alpha2b:=alpha1*P180; alpha2:=alpha1; eNd;
  sincos(alpha2b,sw,cw);
  xc:=x0+acp*sw+bsp*cw; yc:=y0+bcp*cw-asp*sw;
  Richtg:=Richtg+alpha2;
  Bild.Canvas.MoveTo(round(xc),round(yc)); // handle ?
  if mitIgel then Igel.zeige;
End;

procedure vwZ(strecke:extended);
var a,b,sp,cp,hi:extended;
Begin
  if mitIgel then Igel.verstecke;
  sincos(Neigg*P180,b,a);
  a:=a*strecke; b:=b*strecke;
  sincos(Richtg*P180,sp,cp);
  hi:=a*sp*sqrt(0.125);
  xc:=xc+a*cp+hi; yc:=yc-b-hi;
  if stiftOben then
    Bild.Canvas.MoveTo(round(xc),round(yc)) else
    Bild.Canvas.LineTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
End;

procedure rwZ(strecke:extended);
Begin vwZ(-strecke); End;

procedure vwZN(strecke:extended);
var NOld,a,b,sp,cp,hi:extended;
Begin
  if mitIgel then Igel.verstecke;
  NOld:=Neigg;
  Neigg:=Neigg*cos((NeigRichtg-Richtg)*P180); // reicht nicht
  sincos(Neigg*P180,b,a);
  a:=a*strecke; b:=b*strecke;
  sincos(Richtg*P180,sp,cp);
  hi:=a*sp*sqrt(0.125);
  xc:=xc+a*cp+hi; yc:=yc-b-hi;
  if stiftOben then
    Bild.Canvas.MoveTo(round(xc),round(yc)) else
    Bild.Canvas.LineTo(round(xc),round(yc));
  Neigg:=NOld;
  if mitIgel then Igel.zeige;
End;

procedure neige(azimut:extended=90);
Begin
  Neigg:=Neigg+azimut;
  NeigRichtg:=Richtg;
End;

procedure sn(azimut:extended);
Begin
  Neigg:=azimut;
  NeigRichtg:=Richtg;
End;

procedure vieleckZ(laenge:extended; ecken:integer=4);
var i: integer; w:extended;
Begin
w:=360/ecken;
for i:=1 to abs(ecken) do begin vwZ(laenge); li(w) end;
End;

procedure bogenZ(r,winkel:extended);
Begin ellipseZ(r,r,0,winkel); End;

procedure bogenY(r,winkel:extended);
var i,k: integer; w:extended;
Begin
  k:=abs(round(r*winkel*P180));
  if k>0 then w:=winkel/k else exit;
  if winkel>0 then
    for i:=1 to k do
      begin vwz(1); neige(w); end else
    for i:=1 to k do
      begin vwz(-1); neige(w); end;
End;

procedure ellipseZ(a,b:extended); overload;
Begin ellipseZ(a,b,0,360); End;

procedure ellipseZ(a,b,alpha1,alpha2:extended); overload;
const w2v=0.353553390593273762;
var x0,y0,x,y,alpha2b,w,dw,asp,acp,bsp,bcp,sw,cw,L: extended;
    flag: boolean;
Begin
  if (a<=0)or(b<=0) then exit;
  if mitIgel then Igel.verstecke;
  sincos(Richtg*P180,sw,cw);
  x0:=xc-b*sw; y0:=yc-b*cw;
  asp:=a*sw; acp:=a*cw; bsp:=b*sw; bcp:=b*cw;
  if a>b then dw:=1/a else dw:=1/b;
  flag:=alpha2<alpha1;
  if flag then
    bEgin x:=alpha1; alpha1:=alpha2; alpha2:=x; eNd;
  w:=alpha1*P180;
  if alpha1<>0 then
    bEgin
    sincos(w,sw,cw);
    x:=x0+acp*sw+bsp*cw; y:=y0+bcp*cw-asp*sw;
    L:=(y-yc)*w2v; x:=x-L; y:=yc+L;
    Bild.Canvas.MoveTo(round(x),round(y));
    eNd;
  alpha2b:=alpha2*P180;
    Repeat
    w:=w+dw;
    sincos(w,sw,cw);
    x:=x0+acp*sw+bsp*cw; y:=y0+bcp*cw-asp*sw;
    L:=(y-yc)*w2v; x:=x-L; y:=yc+L;
    if StiftOben=false then
      Bild.Canvas.LineTo(round(x),round(y));
    Until w>alpha2b;
  if flag then
    bEgin alpha2b:=alpha1*P180; alpha2:=alpha1; eNd;
  sincos(alpha2b,sw,cw);
  x:=x0+acp*sw+bsp*cw; y:=y0+bcp*cw-asp*sw;
  L:=(y-yc)*w2v; xc:=x-L; yc:=yc+L;
  Richtg:=Richtg+alpha2;
  Bild.Canvas.MoveTo(round(xc),round(yc)); // handle ?
  if mitIgel then Igel.zeige;
End;

procedure FbogenZ(r,winkel:extended);
var rs,xs,ys,x0,y0: extended; pc: TColor;
Begin
  pc:=Bild.Canvas.Pen.Color; Bild.Canvas.Pen.Color:=$00FFFFFE;
  rs:=Richtg; xs:=xc; ys:=yc;
  li(90); vwZ(r+1);
  x0:=xc; y0:=yc;
  Bild.Canvas.Pixels[round(x0),round(y0)]:=$00FFFFFE;
  sh; vwZ(-r-1); re(90); sa;
  ellipseZ(r,r,0,winkel);
  li(90); zuXY(x0,y0);
  sh; re(winkel/2); vwZ(-r/2); sa;
  if mitIgel then Igel.verstecke;
  Bild.Canvas.Floodfill(round(xc),round(yc),$00FFFFFE,fsBorder);
  Richtg:=rs; xc:=xs; yc:=ys;
  Bild.Canvas.MoveTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
  Bild.Canvas.Pen.Color:=pc;
  li(90); vwZ(r+1);
  sh; vwZ(-r-1); re(90); sa;
  ellipseZ(r,r,0,winkel);
  rs:=Richtg; xs:=xc; ys:=yc;
  zuXY(x0,y0);
  Bild.Canvas.Pixels[round(x0),round(y0)]:=pc;
  if mitIgel then Igel.verstecke;
  Richtg:=rs; xc:=xs; yc:=ys;
  Bild.Canvas.MoveTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
End;

function fRGB(rot,gruen,blau:byte):TColor; overload;
asm
  AND    EDX, $FF
  SHL    EDX, $08 // 8 Bit-Ops langsamer
  AND    ECX, $FF
  SHL    ECX, $10
  AND    EAX, $FF
  ADD    EAX, ECX
  ADD    EAX, EDX
  //rot or (gruen shl 8) or (blau shl 16)
end;

function fRGB(HTMLstr:String):TColor; overload;
var s: String;
Begin
  s:='$'+HTMLstr;
  s[2]:=HTMLstr[5]; s[3]:=HTMLstr[6];
  s[6]:=HTMLstr[1]; s[7]:=HTMLstr[2];
  fRGB:=StrToInt(s);
End;

function fTRGB(transp,rot,gruen,blau:byte):TColor;
Begin
result:=rot+gruen*$100+blau*$10000+transp*$1000000;
End;
{asm
  PUSH    EBX
  SHL     EAX, $18
  MOV     EBX, [EBP+$08]
  AND     EBX, $FF
  SHL     EBX, $10
  ADD     EAX, EBX
  AND     ECX, $FF
  SHL     ECX, $08
  ADD     EAX, ECX
  AND     EDX, $FF
  ADD     EAX, EDX
  POP     EBX
end;}

function farbeAdd(x,y:TColor):TColor;
asm
  OR    EAX, EDX // not ready yet
end;

(* 1 ungenau, aber simpl *)
function farbeArM(x,y:TColor):TColor;
asm
  AND    EAX, $FEFEFEFE
  AND    EDX, $FEFEFEFE
  SHR    EAX, 1
  SHR    EDX, 1
  ADD    EAX, EDX
end;

function rgbFarbe(s1:byte=0;s2:byte=255;h1:byte=0;h2:byte=255):TColor;
var r,g,b,min,max,s,c,d:byte; f:TColor;
Begin
if s2<s1 then s2:=s1; if h2<h1 then h2:=h1;
//randomize;
c:=0; s:=0; f:=fRGB(h2,h2,h2);
  repeat
  inc(c);
  r:=random(1+h2); g:=random(1+h2); b:=random(1+h2);
  min:=r; max:=r;
  if g<min then min:=g; if g>max then max:=g;
  if b<min then min:=b; if b>max then max:=b;
  d:=max-min;
  if (d>=s)and(d<=s2) then
    begin f:=fRGB(r,g,b); s:=d; end;
  if (d>=s1)and(d<=s2)and(max>=h1) then f:=fRGB(r,g,b);
  until ((d>=s1)and(d<=s2)and(max>=h1))or(c>254);
  result:=f;
End;


function fGrau(farbe:TColor):TColor;
{1 ungenau, aber dreimal so schnell}
{var b: integer;
Begin
  b:=((farbe mod $100)*76+((farbe div $100) mod $100)*150+
  ((farbe div $10000)mod $100)*29) div $100; // $FF
  inc(b);                                    // Korr
  result:=b+b*$100+b*$10000;
End;}
asm
  PUSH   ESI
  PUSH   ECX
  PUSH   EBX
  MOV    ESI, EAX
  AND    EAX, $FF
  MOV    EBX, $4D  // $4C
  IMUL   EBX
  MOV    ECX, EAX
  MOV    EAX, ESI
  SHR    EAX, $08
  AND    EAX, $FF
  MOV    EBX, $96
  IMUL   EBX
  ADD    ECX, EAX
  MOV    EAX, ESI
  SHR    EAX, $10
  AND    EAX, $FF
  MOV    EBX, $1E  // $1D
  IMUL   EBX
  ADD    ECX, EAX
  MOV    EAX, ECX
  SHR    EAX, $08    // :255
  MOV    EBX, EAX
  SHL    EAX, $10
  MOV    AL,BL
  MOV    AH,BL
  POP    EBX
  POP    ECX
  POP    ESI
end;

procedure inRGB(farbe:TColor; var r,g,b:byte);
asm
  PUSH   EBX
  MOV    EBX, EAX
  MOV    BYTE PTR[EDX], BL
  MOV    BYTE PTR[ECX], BH
  SHR    EBX, $08
  MOV    EAX, [EBP+$08]
  MOV    BYTE PTR[EAX], BH
  POP    EBX
end;

procedure inTRGB(farbe:TColor; var t,r,g,b:byte);
Begin
  r:=farbe mod $100;
  g:=(farbe div $100)mod $100;
  b:=(farbe div $10000)mod $100;
  t:=(farbe div $1000000)mod $100;
End;

procedure farbVerlauf(farbe1,farbe2:TColor; a,b:extended); overload;
var r1,g1,b1,r2,g2,b2:byte;
    dr,dg,db,xs,ys,rs:extended;
    step,dicke0:integer; pc:TColor;
Begin
  pc:=Bild.Canvas.Pen.Color; dicke0:=Bild.Canvas.Pen.Width;
  inRGB(farbe1,r1,g1,b1); inRGB(farbe2,r2,g2,b2);
  a:=a-1; b:=b-1; dicke(2);
  sh; vw(1); sa;
  dr:=(r2-r1)/b; dg:=(g2-g1)/b; db:=(b2-b1)/b;
  step:=0;
  Bild.Canvas.Pen.Color:=farbe1;
    repeat
    xs:=xc; ys:=yc; rs:=Richtg;
    vw(a);
    if mitIgel then Igel.verstecke;
    xc:=xs; yc:=ys; Richtg:=rs;
    if mitIgel then Igel.zeige;
    Bild.Canvas.Pen.Color:=fRGB(r1+round(step*dr),g1+round(step*dg),b1+round(step*db));
    sh; li; vw(1); re; sa;
    inc(step);
    until step>=b;
  Bild.Canvas.Pen.Color:=pc; Bild.Canvas.Pen.Width:=dicke0;
End;

procedure farbVerlauf(farbe1,farbe2:TColor; radius:extended); overload;
var x0,y0,sp,cp,dr,dg,db:extended; r:integer;
    r1,g1,b1,r2,g2,b2:byte; bc,pc,farbe:TColor;
Begin
  if mitIgel then Igel.verstecke;
  bc:=Bild.Canvas.Brush.Color; pc:=Bild.Canvas.Pen.Color;
  if stiftOben then exit;
//  sh; re; vw(1); li; sa;          // Feinkorrektur
  sincos(Richtg*P180,sp,cp);
  x0:=xc-radius*sp; y0:=yc-radius*cp;
  inRGB(farbe1,r1,g1,b1); inRGB(farbe2,r2,g2,b2);
  dr:=(r2-r1)/radius; dg:=(g2-g1)/radius; db:=(b2-b1)/radius;
  r:=round(radius);
  with Bild.Canvas do
    repeat
    farbe:=fRGB(r1+round(r*dr),g1+round(r*dg),b1+round(r*db));
    Pen.Color:=farbe; Brush.Color:=farbe;
    Ellipse(round(x0-r),round(y0-r),round(x0+r),round(y0+r));
    dec(r);
    until r<0;
  Bild.Canvas.MoveTo(round(xc),round(yc)); // handle
  Bild.Canvas.Brush.Color:=bc;   Bild.Canvas.Pen.Color:=pc;
  if mitIgel then Igel.zeige;
End;

procedure dither;
Begin Bild.Monochrome:=True; End;

procedure grauBild; overload;
Begin grauBild(0,0,Bild.Width,Bild.Height); End;

procedure grauBild(x1,y1,x2,y2:integer); overload;
var x,y: integer; f,f0,g: TColor;
Begin
Screen.Cursor:=crHourglass;
f0:=0; g:=0;
for y:=y1 to y2 do
for x:=x1 to x2 do
  begin
  f:=Bild.Canvas.Pixels[x,y];
  if f=f0 then
    Bild.Canvas.Pixels[x,y]:=g
    else
      bEgin
      g:=fGrau(f);
      Bild.Canvas.Pixels[x,y]:=g;
      f0:=f;
      eNd;
  end;
Screen.Cursor:=CrDefault;
End;

function farbeVon(x,y:integer):TColor;
Begin result:=Bild.Canvas.Pixels[x,y]; End;

procedure zeichne(x,y:integer); overload;
Begin Form1.Canvas.Draw(x,y,Bild); End;

procedure zeichne; overload;
Begin Form1.Canvas.Draw(0,0,Bild); End;

procedure speichere(DateiName:String); overload;
Begin speichere(DateiName,24); End;

procedure speichere(DateiName:String; Bit:byte); overload;
Begin
case bit of
  0..1:   Bild.PixelFormat:=pf1bit;
  2..4:   Bild.PixelFormat:=pf4bit;
  5..8:   Bild.PixelFormat:=pf8bit;
  9..15:  Bild.PixelFormat:=pf15bit;
  16:     Bild.PixelFormat:=pf16bit;
  17..24: Bild.PixelFormat:=pf24bit;
  else Bild.PixelFormat:=pf32bit;   // obsolet
  end;
Bild.SaveToFile(DateiName);
Bild.PixelFormat:=pf32bit;
End;

procedure lade(DateiName:String);
Begin Bild.LoadFromFile(DateiName); End;

procedure zwischenablage;
Begin Clipboard.Assign(Bild); End;


constructor Tier.Create;
Begin
  inherited Create;
  sichtbar:=False;
  farbe:=$002050B0;
  groesse:=5;        // vorzugsweise ungeradzahlig
End;

function Tier.gx: integer; Begin gx:=round(xc); End;
function Tier.gy: integer; Begin gy:=round(yc); End;
function Tier.gr: extended; Begin gr:=Richtg; End;
function Tier.gn: extended; Begin gn:=Neigg; End;

procedure Tier.sx(const Value: integer);
Begin
  if mitIgel then verstecke;
  xc:=value;
  if mitIgel then zeige;
End;

procedure Tier.sy(const Value: integer);
Begin
  if mitIgel then verstecke;
  yc:=value;
  if mitIgel then zeige;
End;

procedure Tier.sr(const Value: extended);
Begin
  if mitIgel then verstecke;
  Richtg:=Value;
  if mitIgel then zeige;
End;

procedure Tier.sn(const Value: extended);
Begin
  Neigg:=Value;
End;

procedure Tier.zeige;
var pc,col:TColor; pm1:TPenMode;
    sx,cx,l:extended; x0,y0,x1,y1,pw:integer;
Begin
  if sichtbar=false then with Bild.Canvas
  do begin
  sichtbar:=True;
  col:=Pixels[x,y];
  pc:=Pen.Color; Pen.Color:=farbe;
  pw:=Pen.Width; Pen.Width:=groesse;
  pm1:=Pen.Mode; Pen.Mode:=pmNotXor;
  l:=5*groesse;
  x0:=round(xc); y0:=round(yc);
  sincos(Richtg*P180,sx,cx);
  x1:=round(xc-l*cx); y1:=round(yc+l*sx);
  moveTo(x1,y1); lineTo(x0,y0);
  sincos((Richtg+45)*P180,sx,cx);
  l:=l/2;
  x1:=round(xc-l*cx); y1:=round(yc+l*sx);
  moveTo(x1,y1); lineTo(x0,y0);
  sincos((Richtg-45)*P180,sx,cx);
  x1:=round(xc-l*cx); y1:=round(yc+l*sx);
  moveTo(x1,y1); lineTo(x0,y0);
  Pen.Mode:=pm1;
  Pen.Width:=pw;
  Pen.Color:=pc;
  Pixels[x,y]:=col;
  end;
End;

procedure Tier.verstecke;
Begin
  if sichtbar then
    begin sichtbar:=False; zeige; sichtbar:=False; end;
End;


initialization
Bild:=TBitmap.Create;
Igel:=Tier.Create;


finalization
Igel.Free;
Bild.Free;

{
(* nur für a<=b *)
procedure ellipseZ(a,b:extended);
var rs,xs,ys: extended;
Begin
  rs:=Richtg; xs:=xc; ys:=yc;
  if a>=b then
    bEgin
    li(7*b/a); dx(0.3938*b); dy(-0.025*b);
    ellipse2(1.0683*a,0.33125*b);
    eNd else exit;
  if mitIgel then Igel.verstecke;
  Richtg:=Rs; xc:=xs; yc:=ys;
  Bild.Canvas.MoveTo(round(xc),round(yc));
  if mitIgel then Igel.zeige;
End;
}
end.
