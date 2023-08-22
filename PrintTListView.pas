// File name:   PrintTListView.pas  Last update: 2001-11-14
//
// Programmer:  A.C, Wolff
// Category:    Printing
//
// Copyright © 2001 A.C. Wolff (ac_wolff@hotmail.com)
//
// Description: See below after Procedure PrintListView
// Uploaded to http://codecentral.borland.com/  ID 17032
//#------------------------------------------------------------------------------

unit PrintTListView;

interface

uses ComCtrls, Printers;


Procedure PrintListView(Const aPrinter: TPrinter; Const aCaption: string;
    Const aListview: TListView; Const DrawHGridLines, DrawVGridLines: Boolean);

implementation

uses SysUtils, Windows, Classes, Graphics, Controls;

Procedure PrintListView(Const aPrinter: TPrinter; Const aCaption: string;
    Const aListview: TListView; Const DrawHGridLines, DrawVGridLines: Boolean);
//
// Prints the contents of aListView on printer aPrinter over one or more pages.
// If the listview is too wide for the printer, the printer orientation will be
// changed to landscape.
// If Length(aCaption)>0, the title aCaption will be printed above the table.
// If DrawHGridLines is true the system will print horizontal gridlines.
// If DrawVGridLines is true the system will print vertical gridlines.
// The ListView cannot contains more as 31 columns, see MaxNrColumns.
//
Const MaxNrColumns = 31;
      xMargin = 200;
      yMargin = 200;
var x, y, yTop, w, xTopLeft, xTopRight, th, tw, dy, xColmargin, i1, i2, PageNr: integer;
    r: TRect;
    Ready: boolean;
    OrgOrientation: TPrinterOrientation;
    ColPos: array[0..MaxNrColumns] of integer;
    ColWidth: array[0..MaxNrColumns] of integer;
    PrintCol: array[0..MaxNrColumns] of Boolean;
//
    Procedure PrintField(ColIndex: integer; FieldText: string);
    begin
      with aListView do
        if PrintCol[ColIndex] then
          case Columns.Items[ColIndex].Alignment of
            taRightJustify:
              aPrinter.Canvas.TextOut(ColPos[ColIndex+1] - tw -
                aPrinter.Canvas.TextWidth(FieldText), y, FieldText);
            taLeftJustify:
              aPrinter.Canvas.TextOut(ColPos[ColIndex] + tw, y, FieldText);
            else
              aPrinter.Canvas.TextOut(ColPos[ColIndex] +
                ((ColPos[ColIndex+1]-ColPos[ColIndex])-
               aPrinter.Canvas.TextWidth(FieldText)) div 2, y,FieldText);
          end;
      end; { PrintField }
//
    Procedure PrintCaptions;
    var aTitle: string;
        i: integer;
    begin
      inc(PageNr);
      y:= yMargin;
      with aPrinter, aListView do
      begin
        if pageNr>1 then
          NewPage;
        aPrinter.Canvas.Brush.Color := clWhite;
        aPrinter.Canvas.Pen.Color :=  clBlack;
        if length(aCaption)>0 then
        begin
          if pageNr>1 then
            aTitle:= aCaption + ' (' + IntToStr(PageNr) + ')'
          else
            aTitle:= aCaption;
          aPrinter.Canvas.TextOut(xTopLeft +
                    ((xTopRight-xTopLeft)-
                   aPrinter.Canvas.TextWidth(aTitle)) div 2, y, aTitle);
          y:= y + th + dy;
        end;
        yTop:= y;
        x:= xTopLeft;
        aPrinter.Canvas.Brush.Color :=  clLtGray;
        r := Rect(x, yTop, xTopRight, yTop + th + 2*dy);
        aPrinter.Canvas.Rectangle(r);
        aPrinter.Canvas.Pen.Color :=  clLtGray;  // for the gridlines
        y:= yTop + dy;
        for i := 0 to aListView.Columns.Count-1 do
          PrintField(i,Columns[i].Caption);
        y:= y + th + 2*dy;
        aPrinter.Canvas.Brush.Color :=  clWhite;
      end;
    end; { PrintCaptions }
//
    Procedure PrintBoundary;
    var i: integer;
    Begin
      y:= y+dy;
      r := Rect(xTopLeft,yTop,xTopRight,y);
      with aPrinter.Canvas do
      begin
        Brush.Color := clBlack;
        FrameRect(r);
        if DrawVGridLines then
          for i := 0 to aListView.Columns.Count-2 do
            if PrintCol[i] then
            begin
              MoveTo(ColPos[i+1],yTop);
              LineTo(ColPos[i+1],y);
            end;
      end;
   end; { PrintBoundary }
//
begin
  with aPrinter, aListView do
  begin
    OrgOrientation:= Orientation;
    tw:= aPrinter.Canvas.TextWidth('N');
    th:= aPrinter.Canvas.TextHeight('N');
    dy:= (th div 5);
    xColmargin:= tw;
    for i1 := 0 to aListView.Columns.Count-1 do
    begin
      PrintCol[i1]:= (Columns[i1].Width >0);
      if PrintCol[i1] then
        ColWidth[i1]:= aPrinter.Canvas.TextWidth(Columns[i1].Caption)
      else
        ColWidth[i1]:= 0;
    end;
    for i1 := 0 to aListView.Items.Count-1 do
    begin
      if PrintCol[0] and
            (aPrinter.Canvas.TextWidth(Items[i1].Caption)>ColWidth[0]) then
        ColWidth[0]:= aPrinter.Canvas.TextWidth(Items[i1].Caption);
      for i2 := 0 to (Items[i1].SubItems.Count - 1) do
        if PrintCol[i2+1] and
          (aPrinter.Canvas.TextWidth(Items[i1].SubItems[i2]) > ColWidth[i2+1]) then
          ColWidth[i2+1]:= aPrinter.Canvas.TextWidth(Items[i1].SubItems[i2]);
    end;
    x:= xMargin;
    for i1 := 0 to aListView.Columns.Count-1 do
    begin
      ColPos[i1]:= x;
      if PrintCol[i1] then
      begin
        ColWidth[i1]:= ColWidth[i1] + xColmargin;
        x:= x + ColWidth[i1];
      end;
    end;
    ColPos[aListView.Columns.Count]:= x; // End last column
    if (x > (PageWidth - xMargin)) and (Orientation<>poLandscape) then
      Orientation:= poLandscape;

    w:= (PageWidth-xMargin)-x;  // free space at the right of the table
    if w>0 then
      // Center the table on the page
      begin
        w:= w div 2;
        xTopLeft:= xMargin + w;
        for i1 := 0 to aListView.Columns.Count do
          ColPos[i1]:= ColPos[i1] + w;
      end
    else
      xTopLeft:= xMargin;
    xTopRight:= ColPos[aListView.Columns.Count];

    BeginDoc; // Start printing process
    PageNr:= 0;
    PrintCaptions;
    Ready:= false;
    i1 := 0;
    while not Ready do
    begin
      PrintField(0,Items[i1].Caption);
      for i2 := 0 to (Items[i1].SubItems.Count - 1) do
        PrintField(i2+1,Items[i1].SubItems[i2]);
      y:= y + th;
      if DrawHGridLines And (i1<>aListView.Items.Count-1) then
        begin
          aPrinter.Canvas.MoveTo(xTopLeft,y);
          aPrinter.Canvas.LineTo(xTopRight,y);
          y:= y+dy;
        end;
      inc(i1);
      Ready:= (i1>aListView.Items.Count-1);
      if (y > PageHeight-yMargin) and (not Ready) then
      begin
        PrintBoundary;
        PrintCaptions;
      end;
    end;
    PrintBoundary;
    EndDoc; // End printing process

    // Restore defaults:
    aPrinter.Canvas.Brush.Color := clWhite;
    aPrinter.Canvas.Pen.Color :=  clBlack;
    Orientation:= OrgOrientation;
  end;
end; { PrintListView }


end.
