unit frm_cadastro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Comp.Client, dm;

type
  Tform_cadastro = class(TForm)
    lbeNick: TLabeledEdit;
    lbeSenha: TLabeledEdit;
    btnCad: TButton;
    lbl1: TLabel;
    btnFormCad: TButton;
    btn1: TButton;
    procedure btnCadClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnFormCadClick(Sender: TObject);
  private
    { Private declarations }

    procedure cadastro;

  public
    { Public declarations }
  end;

var
  form_cadastro: Tform_cadastro;

implementation

{$R *.dfm}

procedure Tform_cadastro.btn1Click(Sender: TObject);
begin
  FreeAndNil(Application);
end;

procedure Tform_cadastro.btnCadClick(Sender: TObject);
begin
  self.cadastro;
end;

procedure Tform_cadastro.btnFormCadClick(Sender: TObject);
begin
  self.Close;
end;

procedure Tform_cadastro.Button1Click(Sender: TObject);
begin
  FreeAndNil(Application);
end;

procedure Tform_cadastro.cadastro;
var
qInsert:TFDQuery;
begin
  if ((lbeNick.Text = '') and (lbeSenha.Text = '')) then
  begin
    ShowMessage('Informe todos os campos por favor!');
  end
  else
  begin
    qInsert := TFDQuery.Create(self);
    qInsert.Connection := dmDados.FdConexao;
    dmDados.FdConexao.Connected := true;
    qInsert.Close;
    qInsert.SQL.Add('insert into player (nome,senha) values (:nome, :senha)');
    qInsert.ParamByName('nome').AsString := lbeNick.Text;
    qInsert.ParamByName('senha').AsString := lbeSenha.Text;

    qInsert.ExecSQL;

    if (qInsert.RowsAffected > 0) then
    begin
      ShowMessage('Deu boa, voc? est? pronto para jogar!');
    end;

    FreeAndNil(qInsert);
    self.Close;
  end;
end;

end.
