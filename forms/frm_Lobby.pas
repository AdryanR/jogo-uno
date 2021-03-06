unit frm_Lobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait,
  Vcl.StdCtrls, Data.DB, FireDAC.Comp.Client, Winsock, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, FireDAC.DApt, Vcl.Menus, IdGlobal,
  FormPServer, formPrincipal, FormEscolheCor, Vcl.Imaging.jpeg, Vcl.ExtCtrls, dm, ShellAPI,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  TEsperaConexao = class(TThread)
    procedure Execute; override;
    constructor Cria();
  end;

type
  Tfrm_Espera = class(TForm)
    lblCodigoPartida: TLabel;
    RestClient: TRESTClient;
    request: TRESTRequest;
    RestResponse: TRESTResponse;
    Menu: TMainMenu;
    CriarSala1: TMenuItem;
    Entraremumasala1: TMenuItem;
    Sobre1: TMenuItem;
    Ranking1: TMenuItem;
    lblNickname: TLabel;
    procedure CriarSala1Click(Sender: TObject);
    procedure Entraremumasala1Click(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Ranking1Click(Sender: TObject);
  private
    { Private declarations }
    procedure IniciaJogoServer();
    procedure IniciaJogoClient();
    function obterIp: string;
    procedure Ipv6NaoHabilitado;
  public
    { Public declarations }

    nickname:String;

  end;

var
  frm_Espera: Tfrm_Espera;

implementation

uses
  frm_login, frm_ranking;

{$R *.dfm}

{ TForm1 }

procedure Tfrm_Espera.CriarSala1Click(Sender: TObject);
begin
  self.IniciaJogoServer;
end;

procedure Tfrm_Espera.Entraremumasala1Click(Sender: TObject);
begin
  IniciaJogoClient;
end;

procedure Tfrm_Espera.FormShow(Sender: TObject);
begin
   if form_login = nil then
  form_login := Tform_login.Create(Application);

  form_login.showModal;
  FreeAndNil(form_login);
  form_login := nil;
  lblNickname.Caption := 'Seja bem vindo:  ' + nickname;
end;

procedure Tfrm_Espera.IniciaJogoClient;
var
  codigoPartida: string;
  qSelect: TFDQuery;
  qInsert: TFDQuery;
  ipClient: string;
  idSala:integer;
begin
  codigoPartida := InputBox('Conectar a sala, pronto?', 'Qual o c?digo da sala?', '');
  if (codigoPartida <> '') then
  begin
    qSelect := TFDQuery.Create(self);
    qSelect.Connection := dmDados.FdConexao;
    dmDados.FdConexao.Connected := true;
    qSelect.SQL.Add('select id, ipServer from conexao where codigoPartida = :codigoInformado');
    qSelect.ParamByName('codigoInformado').AsString := codigoPartida;

    qSelect.Open;

    if (qSelect.RecordCount > 0) then
    begin
      ipClient := qSelect.FindField('ipServer').AsString;
      idSala := qSelect.FindField('id').AsInteger;

      qInsert := TFDQuery.Create(self);
      qInsert.Connection := dmDados.FdConexao;
      dmDados.FdConexao.Connected := true;

      qInsert.SQL.Add('UPDATE conexao SET nick_cliente = :nick WHERE id = :id;');
      qInsert.ParamByName('id').AsInteger := idSala;
      qInsert.ParamByName('nick').AsString := nickname;

      qInsert.ExecSQL;

      if (frm_Jogo = nil) then
      begin
        frm_Jogo := Tfrm_Jogo.Create(Application);
        frm_Jogo.codigoPartida := StrToInt(codigoPartida);
        frm_Jogo.Client.Host := ipClient;
        frm_Jogo.Client.Port := 8080;
        frm_Jogo.Client.Connect;
        FreeAndNil(qSelect);
        FreeAndNil(qInsert);
        frm_Jogo.ShowModal;
        FreeAndNil(frm_Jogo);
        frm_Jogo := nil ;
      end;

    end
    else
    begin
      ShowMessage('C?digo de partida n?o encontrado, verifique e tente novamente ;)!');
    end;
  end;

end;

procedure Tfrm_Espera.IniciaJogoServer;
var
  codigoPartida: integer;
  qInsert: TFDQuery;
  ipServer: string;
begin
  ipServer := self.obterIp;
  if (ipServer = '') then
  begin
    exit;
  end
  else
  begin
    codigoPartida := Random(1000000); // c?digo de 6 digitos da sala
    lblCodigoPartida.Font.Size := 27;
    lblNickname.Visible := false;
    lblCodigoPartida.Font.Name := 'Agan?';
    lblCodigoPartida.Caption := 'Sua sala foi criada!' + #13
    + 'Envie o c?digo: ' + #13
    + IntToStr(codigoPartida) + #13 
    + ' para seu oponente!';
    qInsert := TFDQuery.Create(self);
    qInsert.Connection := dmDados.FdConexao;
    dmDados.FdConexao.Connected := true;
    qInsert.SQL.Add('insert into conexao (codigoPartida, ipServer, nick_server) values (:codigoPartida, :ipServer, :nick_server)');
    qInsert.ParamByName('codigoPartida').AsInteger := codigoPartida;
    qInsert.ParamByName('ipServer').AsString := ipServer;
    qInsert.ParamByName('nick_server').AsString := nickname;

    qInsert.ExecSQL;

    if (frmJogoServer = nil) then
    begin
      frmJogoServer := TfrmJogoServer.Create(Application);
      frmJogoServer.codigoPartida := codigoPartida;
      //frmJogoServer.Server.Bindings.Clear;
      with frmJogoServer.Server.Bindings.Add do
      begin
        frmJogoServer.Server.Bindings.Items[0].IP := ipServer;
        frmJogoServer.Server.Bindings.Items[0].Port := 8080;
        frmJogoServer.Server.Bindings.Items[0].IPVersion := Id_IPv6;
      end;
      frmJogoServer.Server.Active := true;
    end;
    FreeAndNil(qInsert);
    TEsperaConexao.Cria;
  end;

end;

procedure Tfrm_Espera.Ipv6NaoHabilitado;
begin
  ShowMessage('O jogo precisa de IPV6 habilitado, vamos abrir um tutorial para ajudar voc? a habilitar ele!');
  ShellExecute(Handle, 'open', 'https://www.att.com/support/article/u-verse-high-speed-internet/KM1053000', '', '', 1);
end;

function Tfrm_Espera.obterIp: string;
begin
  try
   request.Execute; 
  except on E: Exception do
    self.Ipv6NaoHabilitado;
  end;
  result := RestResponse.Content;
end;

procedure Tfrm_Espera.Ranking1Click(Sender: TObject);
begin
  if (form_ranking = nil) then
    begin
      form_ranking := Tform_ranking.Create(Application);
    end;
      form_ranking.showModal;
      FreeAndNil(form_ranking);
      form_ranking := nil;
end;

procedure Tfrm_Espera.Sobre1Click(Sender: TObject);
begin
  ShowMessage('Este jogo ? o TCS do 3? semestre de ADS' + #13 + 'na mat?ria de DpD realizado pelos alunos:' + #13 + 'Adryan Rafael da Silva' + #13 + 'Anderson Rafael Bruns' + #13 + 'F?bio Domingues' + #13 + 'Ricardo da Silva Amorin Filho.');
end;

{ TContaLabel }

constructor TEsperaConexao.Cria;
begin
  Create(False);
  FreeOnTerminate := True;
end;

procedure TEsperaConexao.Execute;
begin
  while (frmJogoServer.conectado = false) do
  begin
    Sleep(5000);
    if (frmJogoServer.conectado = true) then
    begin
      frmJogoServer.ShowModal;
      FreeAndNil(frmJogoServer);
      frmJogoServer := nil ;
      break;
    end;
  end;
end;

end.

