object FrmDestination: TFrmDestination
  Left = 0
  Top = 0
  Caption = 'Select The Destination...'
  ClientHeight = 267
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
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
  object BtNewDir: TButton
    Left = 80
    Top = 240
    Width = 83
    Height = 25
    Caption = 'New Directory'
    TabOrder = 2
    OnClick = BtNewDirClick
  end
  object Directory: TDirectoryListBox
    Left = 8
    Top = 33
    Width = 307
    Height = 201
    ItemHeight = 16
    TabOrder = 3
  end
  object Drive: TDriveComboBox
    Left = 8
    Top = 8
    Width = 307
    Height = 19
    DirList = Directory
    TabOrder = 4
  end
end
