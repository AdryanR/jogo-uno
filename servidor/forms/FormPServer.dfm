object frmJogoServer: TfrmJogoServer
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = '  Jogo Uninho'
  ClientHeight = 546
  ClientWidth = 1163
  Color = 5737262
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  Menu = Menu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 115
  TextHeight = 16
  object lblNomePlayer: TLabel
    Left = 8
    Top = 380
    Width = 59
    Height = 22
    Alignment = taCenter
    Caption = 'Player:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Raleway'
    Font.Style = []
    ParentFont = False
  end
  object lblNomeCliente: TLabel
    Left = 8
    Top = 137
    Width = 61
    Height = 22
    Alignment = taCenter
    Caption = 'Cliente'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Raleway'
    Font.Style = []
    ParentFont = False
  end
  object ImageCompra: TImage
    Tag = 1
    Left = 304
    Top = 209
    Width = 86
    Height = 130
    Stretch = True
    OnClick = ImageCompraClick
  end
  object ImageMonte: TImage
    Tag = 1
    Left = 500
    Top = 149
    Width = 161
    Height = 225
    Stretch = True
  end
  object lblICompra: TLabel
    Left = 301
    Top = 345
    Width = 90
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Compre aqui'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Raleway'
    Font.Style = []
    ParentFont = False
  end
  object lblCorAtual: TLabel
    Left = 500
    Top = 380
    Width = 161
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Cor Atual:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Raleway'
    Font.Style = []
    ParentFont = False
  end
  object boxBot: TScrollBox
    Left = 8
    Top = 1
    Width = 1147
    Height = 130
    BevelInner = bvNone
    BorderStyle = bsNone
    Color = 5737262
    Padding.Left = 1
    Padding.Right = 1
    ParentColor = False
    TabOrder = 2
  end
  object PanelFantasmaBot: TPanel
    Left = 569
    Top = 0
    Width = 136
    Height = 49
    Caption = 'PanelFantasmaBot'
    TabOrder = 0
    Visible = False
  end
  object MediaPlayer1: TMediaPlayer
    Left = 569
    Top = 55
    Width = 253
    Height = 20
    DoubleBuffered = True
    Visible = False
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object BoxJogador: TScrollBox
    Left = 8
    Top = 408
    Width = 1147
    Height = 130
    BorderStyle = bsNone
    Padding.Left = 1
    Padding.Right = 1
    TabOrder = 3
    OnMouseWheelDown = BoxJogadorMouseWheelDown
    OnMouseWheelUp = BoxJogadorMouseWheelUp
  end
  object btnReinicia: TButton
    Left = 1169
    Top = 283
    Width = 35
    Height = 25
    Caption = 'encerrar'
    TabOrder = 4
    Visible = False
  end
  object Menu: TMainMenu
    Left = 504
    Top = 24
    object Reiniciar1: TMenuItem
      Caption = 'Sair da partida'
      OnClick = Reiniciar1Click
    end
    object Sobre1: TMenuItem
      Caption = 'Sobre'
      OnClick = Sobre1Click
    end
  end
  object Server: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    MaxConnections = 2
    OnConnect = ServerConnect
    OnExecute = ServerExecute
    Left = 40
    Top = 280
  end
end
