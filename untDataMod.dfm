object DataMod: TDataMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 420
  Width = 674
  object SQLCon: TSQLConnection
    ConnectionName = 'Combic'
    DriverName = 'Interbase'
    GetDriverFunc = 'getSQLDriverINTERBASE'
    LibraryName = 'dbxint30.dll'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Interbase'
      'Database='
      'RoleName=RoleName'
      'User_Name=sysdba'
      'Password=masterkey'
      'ServerCharSet='
      'SQLDialect=3'
      'BlobSize=-1'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'ErrorResourceFile='
      'LocaleCode=0000'
      'Interbase TransIsolation=ReadCommited'
      'Trim Char=False')
    TableScope = [tsTable]
    VendorLib = 'gds32.dll'
    Left = 24
    Top = 16
  end
  object sqlCartela: TSQLDataSet
    SchemaName = 'SYSDBA'
    CommandText = 'select LINHA from CARTELAS order by 1'
    DbxCommandType = 'Dbx.SQL'
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLCon
    Left = 24
    Top = 88
    object sqlCartelaLINHA: TStringField
      FieldName = 'LINHA'
      Required = True
      Size = 200
    end
  end
  object dspCartela: TDataSetProvider
    DataSet = sqlCartela
    Left = 104
    Top = 88
  end
  object cdsCartela: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dspCartela'
    Left = 184
    Top = 88
    object cdsCartelaLINHA: TStringField
      FieldName = 'LINHA'
      Required = True
      Size = 200
    end
  end
  object sqlParam: TSQLDataSet
    CommandText = 'select NUM_CARTAO, NUM_COMB, NUM_FIXO from PARAMS'
    DbxCommandType = 'Dbx.SQL'
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLCon
    Left = 24
    Top = 144
    object sqlParamNUM_CARTAO: TIntegerField
      FieldName = 'NUM_CARTAO'
    end
    object sqlParamNUM_COMB: TStringField
      FieldName = 'NUM_COMB'
      Size = 200
    end
    object sqlParamNUM_FIXO: TStringField
      FieldName = 'NUM_FIXO'
      Size = 200
    end
  end
  object dspParam: TDataSetProvider
    DataSet = sqlParam
    Left = 104
    Top = 144
  end
  object cdsParam: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dspParam'
    Left = 184
    Top = 144
    object cdsParamNUM_CARTAO: TIntegerField
      FieldName = 'NUM_CARTAO'
    end
    object cdsParamNUM_COMB: TStringField
      FieldName = 'NUM_COMB'
      Size = 200
    end
    object cdsParamNUM_FIXO: TStringField
      FieldName = 'NUM_FIXO'
      Size = 200
    end
  end
end
