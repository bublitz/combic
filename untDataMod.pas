unit untDataMod;

interface

uses
  SysUtils, Classes, DBXpress, FMTBcd, DB, DBClient, Provider, SqlExpr, Forms, 
  Dialogs, WideStrings, DBXInterbase;

type
  TDataMod = class(TDataModule)
    SQLCon: TSQLConnection;
    sqlCartela: TSQLDataSet;
    dspCartela: TDataSetProvider;
    cdsCartela: TClientDataSet;
    sqlCartelaLINHA: TStringField;
    cdsCartelaLINHA: TStringField;
    sqlParam: TSQLDataSet;
    sqlParamNUM_CARTAO: TIntegerField;
    sqlParamNUM_COMB: TStringField;
    sqlParamNUM_FIXO: TStringField;
    dspParam: TDataSetProvider;
    cdsParam: TClientDataSet;
    cdsParamNUM_CARTAO: TIntegerField;
    cdsParamNUM_COMB: TStringField;
    cdsParamNUM_FIXO: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataMod: TDataMod;

implementation

{$R *.dfm}

procedure TDataMod.DataModuleCreate(Sender: TObject);
var
  banco: string;

begin
  SQLCon.SQLHourGlass := True;
  banco := 'localhost:' + ExtractFilePath(Application.ExeName) + 'combic.fdb';
  SQLCon.Connected := False;
  SQLCon.Params.Values['Database'] := banco;
  SQLCon.Params.Values['Password'] := 'masterkey';

  try
    SQLCon.Connected := True;
  except
    MessageDlg('Não consegui conectar ao banco de dados.', mtError, [mbOk], 0);
    Application.Terminate;
  end;

  cdsParam.Open;
  cdsCartela.Open;
end;

end.
