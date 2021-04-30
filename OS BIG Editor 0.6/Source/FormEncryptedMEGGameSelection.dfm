object FrmEncryptedMEGGameSelection: TFrmEncryptedMEGGameSelection
  Left = 0
  Top = 0
  Caption = 'Select Game'
  ClientHeight = 150
  ClientWidth = 302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LbSelectGameExplanation: TLabel
    Left = 15
    Top = 16
    Width = 267
    Height = 39
    Caption = 
      'The file that you are trying to open is encrypted and it  was cr' +
      'eated for a specific game. Select one of the supported games bel' +
      'ow, in order to decrypt it:'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 15
    Top = 99
    Width = 279
    Height = 14
    Shape = bsBottomLine
  end
  object CbGame: TComboBox
    Left = 32
    Top = 72
    Width = 217
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = '8-Bit Armies/Hordes/Invaders'
    Items.Strings = (
      '8-Bit Armies/Hordes/Invaders'
      'Grey Goo')
  end
  object BtOK: TButton
    Left = 219
    Top = 119
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
end
