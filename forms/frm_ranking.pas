unit frm_ranking;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, dm;

type
  Tform_ranking = class(TForm)
    lblCodigoPartida: TLabel;
    dbGrid: TDBGrid;
    dsRanking: TDataSource;
    qrRanking: TFDQuery;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  form_ranking: Tform_ranking;

implementation

{$R *.dfm}

procedure Tform_ranking.FormCreate(Sender: TObject);
begin
  qrRanking.Connection := dmDados.FdConexao;
  dmDados.FdConexao.Connected := true;
  qrRanking.Active := true;
end;

end.
