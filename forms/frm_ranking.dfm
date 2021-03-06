object form_ranking: Tform_ranking
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = '   Jogo Uninho: Ranking'
  ClientHeight = 480
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    450
    480)
  PixelsPerInch = 115
  TextHeight = 16
  object lblCodigoPartida: TLabel
    Left = 8
    Top = 0
    Width = 434
    Height = 89
    Alignment = taCenter
    AutoSize = False
    Caption = 'RANKING GERAL'
    Color = 7012202
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -40
    Font.Name = 'REVOLUTION'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object dbGrid: TDBGrid
    Left = 8
    Top = 95
    Width = 434
    Height = 377
    Anchors = [akTop]
    Ctl3D = True
    DataSource = dsRanking
    DrawingStyle = gdsClassic
    FixedColor = clWindow
    GradientEndColor = clWindow
    GradientStartColor = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Raleway SemiBold'
    Font.Style = []
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'NickName'
        Title.Alignment = taCenter
        Width = 157
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Vit'#243'rias'
        Title.Alignment = taCenter
        Width = 135
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Derrotas'
        Title.Alignment = taCenter
        Width = 135
        Visible = True
      end>
  end
  object dsRanking: TDataSource
    DataSet = qrRanking
    Left = 376
    Top = 424
  end
  object qrRanking: TFDQuery
    Connection = dmDados.FdConexao
    SQL.Strings = (
      
        'select p.nome as '#39'NickName'#39', (select count(id) from ranking wher' +
        'e player_id = r.player_id and status_id = 1) as '#39'Vit'#243'rias'#39', (sel' +
        'ect count(id) from ranking where player_id = r.player_id and sta' +
        'tus_id = 2) as '#39'Derrotas'#39' from ranking r '#10'join player p on p.id ' +
        '= r.player_id'#10'join status s on s.id = r.status_id'#10'group by p.id'#10 +
        'order by Vit'#243'rias desc;')
    Left = 312
    Top = 424
  end
end
