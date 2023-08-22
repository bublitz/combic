program Combic;

uses
  Forms,
  untMain in 'untMain.pas' {frmMain},
  untDataMod in 'untDataMod.pas' {DataMod: TDataModule},
  PrintTListView in 'PrintTListView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Combinação de Números';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDataMod, DataMod);
  Application.Run;
end.
