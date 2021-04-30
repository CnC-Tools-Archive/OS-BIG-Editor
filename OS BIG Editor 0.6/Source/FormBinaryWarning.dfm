object FrmBinaryWarning: TFrmBinaryWarning
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Do you wanna load this binary file?'
  ClientHeight = 142
  ClientWidth = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    597
    142)
  PixelsPerInch = 96
  TextHeight = 13
  object LbLagWarning: TLabel
    Left = 8
    Top = 16
    Width = 570
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'The file you are loading has 1111111 bytes  (about 1.1 mb). This' +
      ' is above the limit of 200000 bytes, which means that the progra' +
      'm will lag if it tries to load the entire file. If you trust the' +
      ' speed of your computer, you can change the lag limit in the opt' +
      'ions.'
    WordWrap = True
    ExplicitWidth = 561
  end
  object Bevel1: TBevel
    Left = 8
    Top = 70
    Width = 581
    Height = 11
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 89
    ExplicitWidth = 578
  end
  object BtLoadAll: TButton
    Left = 423
    Top = 111
    Width = 166
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Load The Whole File'
    TabOrder = 0
    OnClick = BtLoadAllClick
    ExplicitLeft = 414
    ExplicitTop = 88
  end
  object BtLoadLimit: TButton
    Left = 271
    Top = 111
    Width = 146
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Load Only The Limited Size'
    TabOrder = 1
    OnClick = BtLoadLimitClick
    ExplicitLeft = 262
    ExplicitTop = 88
  end
  object BtDontLoad: TButton
    Left = 129
    Top = 111
    Width = 136
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Don'#39't Load It'
    TabOrder = 2
    OnClick = BtDontLoadClick
    ExplicitLeft = 120
    ExplicitTop = 88
  end
  object CbDontAsk: TCheckBox
    Left = 480
    Top = 87
    Width = 109
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = 'Don'#39't ask it again.'
    TabOrder = 3
  end
end
