unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, Grids, DBGrids, DB, StdCtrls, Spin, Buttons, ComCtrls,
  Printers, ExtCtrls, jpeg;

type
  TfrmMain = class(TForm)
    XPManifest1: TXPManifest;
    labTotal: TLabel;
    List: TListView;
    Panel1: TPanel;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtNum: TSpinEdit;
    edtFixo: TSpinEdit;
    grdFixo: TStringGrid;
    edtComb: TSpinEdit;
    grdComb: TStringGrid;
    btnExportar: TBitBtn;
    btnImprimir: TBitBtn;
    btnSave: TBitBtn;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    Image2: TImage;
    Image1: TImage;
    procedure btnSaveClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCombChange(Sender: TObject);
    procedure edtFixoChange(Sender: TObject);
    procedure Combina(inicio, fim, prof: integer);
  private
    { Private declarations }
    //procedure Arruma;
    res: array of integer;
    fixo, comb: string;
    qtd, cart: integer;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses untDataMod, PrintTListView;

{$R *.dfm}

{
procedure TfrmMain.Arruma;
var
  i, t, a, b: integer;

begin
  for i := 1 to 14 do
    for t := i+1 to 15 do
    begin
      a := num[i];
      b := num[t];
      if a > b then
      begin
        num[i] := b;
        num[t] := a;
      end;
    end;
end;
}

procedure TfrmMain.btnExportarClick(Sender: TObject);
var
  i: integer;

begin
  if Application.MessageBox('Confirma a geração dos jogos?', 'Atenção',
    MB_YESNO) = IDYES then
  begin
    Screen.Cursor := crSQLWait;
    DataMod.cdsCartela.Close;
    DataMod.SQLCon.ExecuteDirect('delete from CARTELAS');
    DataMod.cdsCartela.Open;

    fixo := '';
    for i := 0 to edtFixo.Value-1 do
      fixo := fixo + grdFixo.Cells[0, i] + ' ';

    comb := '';
    for i := 0 to edtComb.Value-1 do
      comb := comb + grdComb.Cells[0, i] + ' ';

    DataMod.cdsParam.Edit;
    DataMod.cdsParamNUM_CARTAO.AsInteger := edtNum.Value;
    DataMod.cdsParamNUM_FIXO.AsString := fixo;
    DataMod.cdsParamNUM_COMB.AsString := comb;
    DataMod.cdsParam.Post;
    DataMod.cdsParam.ApplyUpdates(0);

    List.Items.Clear;
    Memo1.Lines.Clear;
    with List.Items.Add do
    begin
      Caption := 'Fixos (' + edtFixo.Text + ')';
      SubItems.Add(fixo);
      ImageIndex := -1;
    end;
    with List.Items.Add do
    begin
      Caption := 'Comb (' + edtComb.Text + ')';
      SubItems.Add(comb);
      ImageIndex := -1;
    end;
    with List.Items.Add do ImageIndex := -1;

    Application.ProcessMessages;
    qtd := edtNum.Value-edtFixo.Value;
    SetLength(res, edtNum.Value-edtFixo.Value);

    cart := 0;
    Combina(0, edtComb.Value-edtNum.Value+edtFixo.Value, 0);
    Application.ProcessMessages;

    DataMod.cdsCartela.ApplyUpdates(0);
    DataMod.cdsCartela.First;

    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.btnImprimirClick(Sender: TObject);
begin
  if Application.MessageBox('Impressora pronta?', 'Atenção', MB_ICONQUESTION +
    MB_YESNO) = IDYES then
    PrintListView(Printer, 'Cartelas - ', List, True, True);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
    ShowMessage('Arquivo salvo!!!');
  end;
end;

procedure TfrmMain.Combina(inicio, fim, prof: integer);
var
  linha: string;
  x, i: integer;

begin
  if (prof + 1) >= qtd then
  begin
    for x := inicio to fim do
    begin
      res[prof] := StrToInt(grdComb.Cells[0, x]);
      linha := '';
      for i := 1 to qtd do
        linha := linha + IntToStr(res[i-1]) + ' ';

      DataMod.cdsCartela.Append;
      DataMod.cdsCartelaLINHA.Value := fixo + linha;
      DataMod.cdsCartela.Post;

      inc(cart);
      labTotal.Caption := 'Nº de Cartelas: ' + IntToStr(cart);

      with List.Items.Add do
      begin
        Caption := 'Cartela ' + IntToStr(cart);
        SubItems.Add(fixo + linha);
        Memo1.Lines.Add(fixo + linha);
        ImageIndex := -1;
      end;
      //Application.ProcessMessages;

    end;
  end
  else
  begin
    for x := inicio to fim do
    begin
      res[prof] := StrToInt(grdComb.Cells[0, x]);
      Combina(x+1, fim+1, prof+1);
    end;
  end;
end;

procedure TfrmMain.edtCombChange(Sender: TObject);
begin
  grdComb.RowCount := edtComb.Value;
end;

procedure TfrmMain.edtFixoChange(Sender: TObject);
begin
  grdFixo.RowCount := edtFixo.Value;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  l: string;
  i, t: integer;

begin
  labTotal.Caption := 'Nº de Cartelas: ' +
    IntToStr(DataMod.cdsCartela.RecordCount);

  edtNum.Value := DataMod.cdsParamNUM_CARTAO.AsInteger;

  t := 0;
  l := DataMod.cdsParamNUM_FIXO.AsString;
  i := Pos(' ', l);
  while i > 0 do
  begin
    inc(t);
    grdFixo.RowCount := t;
    grdFixo.Cells[0, t-1] := Copy(l, 1, i-1);
    l := Copy(l, i+1, 200);
    i := Pos(' ', l);
  end;
  edtFixo.Value := t+1;
  grdFixo.Cells[0, t] := l;

  t := 0;
  l := DataMod.cdsParamNUM_COMB.AsString;
  i := Pos(' ', l);
  while i > 0 do
  begin
    inc(t);
    grdComb.RowCount := t;
    grdComb.Cells[0, t-1] := Copy(l, 1, i-1);
    l := Copy(l, i+1, 200);
    i := Pos(' ', l);
  end;
  edtComb.Value := t+1;
  grdComb.Cells[0, t] := l;

  List.Items.Clear;
  Memo1.Lines.Clear;
  with List.Items.Add do
  begin
    Caption := 'Fixos (' + edtFixo.Text + ')';
    SubItems.Add(DataMod.cdsParamNUM_FIXO.AsString);
    ImageIndex := -1;
  end;
  with List.Items.Add do
  begin
    Caption := 'Comb (' + edtComb.Text + ')';
    SubItems.Add(DataMod.cdsParamNUM_COMB.AsString);
    ImageIndex := -1;
  end;
  with List.Items.Add do ImageIndex := -1;


  i := 0;
  DataMod.cdsCartela.First;
  while not DataMod.cdsCartela.Eof do
  begin
    inc(i);
    with List.Items.Add do
    begin
      Caption := 'Cartela ' + IntToStr(i);
      SubItems.Add(DataMod.cdsCartelaLINHA.AsString);
      Memo1.Lines.Add(DataMod.cdsCartelaLINHA.AsString);
      ImageIndex := -1;
    end;
    DataMod.cdsCartela.Next;
  end;
end;

end.
