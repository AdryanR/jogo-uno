object frm_Espera: Tfrm_Espera
  Left = 0
  Top = 0
  Anchors = []
  BorderStyle = bsToolWindow
  Caption = '   Jogo Uninho'
  ClientHeight = 339
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = Menu
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 115
  TextHeight = 16
  object lblCodigoPartida: TLabel
    Left = 0
    Top = 0
    Width = 833
    Height = 337
    Alignment = taCenter
    AutoSize = False
    Caption = 'Jogo Uninho'
    Color = 7012202
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -64
    Font.Name = 'REVOLUTION'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object lblNickname: TLabel
    Left = 192
    Top = 208
    Width = 449
    Height = 20
    Alignment = taCenter
    AutoSize = False
    Caption = 'Seja bem vindo:'
    Color = 7012202
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Raleway ExtraBold'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object RestClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://v6.ipv6-test.com/api/myip.php'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 720
    Top = 272
  end
  object request: TRESTRequest
    Client = RestClient
    Params = <>
    Response = RestResponse
    SynchronizedEvents = False
    Left = 776
    Top = 272
  end
  object RestResponse: TRESTResponse
    ContentType = 'text/html'
    Left = 640
    Top = 272
  end
  object Menu: TMainMenu
    Left = 768
    Top = 8
    object CriarSala1: TMenuItem
      Caption = 'Criar Sala'
      OnClick = CriarSala1Click
    end
    object Entraremumasala1: TMenuItem
      Caption = 'Entrar em uma sala'
      OnClick = Entraremumasala1Click
    end
    object Sobre1: TMenuItem
      Caption = 'Sobre'
      OnClick = Sobre1Click
    end
    object Ranking1: TMenuItem
      Caption = 'Ranking'
      OnClick = Ranking1Click
    end
  end
end
