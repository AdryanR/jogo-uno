unit frm_login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, FireDAC.Comp.Client, dm;

type
  Tform_login = class(TForm)
    lbl1: TLabel;
    lbeNick: TLabeledEdit;
    lbeSenha: TLabeledEdit;
    btnLogin: TButton;
    btnFormCad: TButton;
    btn1: TButton;
    procedure btnFormCadClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

    procedure login;

  public
    { Public declarations }
  end;

var
  form_login: Tform_login;

implementation

uses
  frm_cadastro, frm_Lobby;

{$R *.dfm}

procedure Tform_login.btnFormCadClick(Sender: TObject);
begin
  if (form_cadastro = nil) then
  begin
    form_cadastro := Tform_cadastro.Create(Application);
  end;
  form_cadastro.ShowModal;
  FreeAndNil(form_cadastro);
  form_cadastro := nil ; //apaga o Form1 da memoria...
end;

procedure Tform_login.btnLoginClick(Sender: TObject);
begin
  self.login;
end;

procedure Tform_login.Button1Click(Sender: TObject);
begin
  FreeAndNil(Application);
end;

procedure Tform_login.login;
var
qSelect:TFDQuery;
begin
  if ((lbeNick.Text = '') and (lbeSenha.Text = '')) then
  begin
    ShowMessage('Informe todos os campos por favor!');
  end
  else
  begin
    qSelect := TFDQuery.Create(self);
    qSelect.Connection := dmDados.FdConexao;
    dmDados.FdConexao.Connected := true;
    qSelect.Close;
    qSelect.SQL.Add('select * from player where nome = :nome and senha = :senha');
    qSelect.ParamByName('nome').AsString := lbeNick.Text;
    qSelect.ParamByName('senha').AsString := lbeSenha.Text;

    qSelect.Open();

    if (qSelect.RecordCount > 0) then
    begin
      frm_Espera.nickname := lbeNick.Text;
      FreeAndNil(qSelect);
      Self.Close;
    end
    else
    begin
      ShowMessage('N?o encontramos um match, verifique o login e senha informados!');
    end;
  end;
end;

end.
