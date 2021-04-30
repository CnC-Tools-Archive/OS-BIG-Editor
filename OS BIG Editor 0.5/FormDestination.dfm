object FrmDestination: TFrmDestination
  Left = 0
  Top = 0
  Width = 339
  Height = 298
  Caption = 'Select The Destination...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BtOK: TButton
    Left = 248
    Top = 240
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 168
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object Directory: TShellTreeView
    Left = 8
    Top = 8
    Width = 313
    Height = 225
    ObjectTypes = [otFolders]
    Root = 'rfMyComputer'
    UseShellImages = True
    AutoRefresh = False
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 2
  end
  object BtNewDir: TButton
    Left = 80
    Top = 240
    Width = 83
    Height = 25
    Caption = 'New Directory'
    TabOrder = 3
    OnClick = BtNewDirClick
  end
end
