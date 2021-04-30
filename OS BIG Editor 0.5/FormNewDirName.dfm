object FrmNewDirName: TFrmNewDirName
  Left = 0
  Top = 0
  Width = 392
  Height = 77
  BorderIcons = [biSystemMenu]
  Caption = 'FrmNewDirName'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object EdDirName: TEdit
    Left = 8
    Top = 16
    Width = 265
    Height = 21
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 296
    Top = 16
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
end
