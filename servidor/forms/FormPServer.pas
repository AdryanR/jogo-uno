unit FormPServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.Imaging.pngimage,
  Generics.Collections, uBaralhoS, uCartaS, uJogadorS, uMonteS, uJogoS, Vcl.MPlayer,
  Vcl.Menus, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdContext, IdTCPConnection, IdTCPClient, IdThreadComponent, FireDAC.Comp.Client,dm;

type
  TfrmJogoServer = class(TForm)
    lblNomePlayer: TLabel;
    lblNomeCliente: TLabel;
    ImageCompra: TImage;
    ImageMonte: TImage;
    PanelFantasmaBot: TPanel;
    boxBot: TScrollBox;
    MediaPlayer1: TMediaPlayer;
    Menu: TMainMenu;
    Reiniciar1: TMenuItem;
    BoxJogador: TScrollBox;
    lblICompra: TLabel;
    btnReinicia: TButton;
    lblCorAtual: TLabel;
    Server: TIdTCPServer;
    Sobre1: TMenuItem;
    procedure ImageCompraClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BoxJogadorMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure BoxJogadorMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure Sobre1Click(Sender: TObject);
    procedure ServerConnect(AContext: TIdContext);
    procedure ServerExecute(AContext: TIdContext);
    procedure Reiniciar1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    { Public declarations }

    imagem: TImage;
    baralho: TBaralhoS;
    carta: TCartaS;
    jogador: TJogadorS;
    monte: TMonteS;
    jogo: TJogoS;
    cartaCerta: Boolean;
    jogoEncerrado: boolean;
    CartasDoJogador: TList<TImage>;
    CartasDoJogador2: TList<TImage>;
    corAtual: String;
    conectado:Boolean;

    { Private declarations }

    codigoPartida:integer;

    procedure criaCartas(jogador: TJogadorS; ImagemCartasJogador: TList<Timage>; box: TScrollBox);
    procedure compraCarta(imagemBaralhoJogador: TList<TCartaS>; iCartaCompra: integer; box: TScrollBox; ImagemCartasJogador: TList<Timage>);
    procedure OnClickTImage(Sender: TObject);
    function retornaIndexTImage(cartaName: string): integer;
    procedure setaImagemCompra;
    procedure encerraJogo(situacao: string);
    procedure iniciar();
    procedure Delay(msecs: Cardinal);
    procedure EnviaInstrucaoClient(msg: string; instrucao: string);
    procedure AtualizaCartasdoClient(qtde : Integer; op: boolean);
    procedure AtualizaEMostraCarta(msgclient:string; StringList: TStringList);
    procedure desativaPlayerByJogada(cartaName : String);
    procedure ativaJogada;
    function obtemNomeOponenteByBanco : String;
    procedure ObtemNomeOponenteEApagaConexao;
  end;

var
  frmJogoServer: TfrmJogoServer;

implementation

uses
  frm_Lobby;

{$R *.dfm}


{$R JogoUnoResource.RES}

procedure TfrmJogoServer.EnviaInstrucaoClient(msg: string; instrucao: string);
var
  tmpList: TList;
  contexClient: TidContext;
  nClients: Integer;
  i: integer;
  msgToCliente: string;
begin
  tmpList := Server.Contexts.LockList;
  msgToCliente := Trim(instrucao + msg);

    try
    i := 0;
    while (i < tmpList.Count) do
    begin
      contexClient := tmpList[i];

      contexClient.Connection.IOHandler.WriteLn(msgToCliente);
      i := i + 1;
    end;
    finally
       Server.Contexts.UnlockList;
    end;

end;

procedure TfrmJogoServer.ativaJogada;
begin
  self.ImageCompra.Enabled := true;
  self.BoxJogador.Enabled := true;
end;

procedure TfrmJogoServer.AtualizaCartasdoClient(qtde : Integer; op: boolean);
var
  png: TPngImage;
  i: integer;
  cont: integer;
  c:integer;
begin
  if (op) then
    begin
        for cont := 0 to qtde do
        begin
          CartasDoJogador2[cont].Destroy;
          CartasDoJogador2.Delete(cont);
          //jogo.jogador2.baralhoJogador.Delete(cont);
        end;
    end
    else
     begin
      for i := 0 to qtde do // dar as cartas pro bot
      begin

        imagem := TImage.create(self);
        png := TPngImage.Create;

        imagem.Width := 81;

        imagem.Height := 113;
        imagem.Stretch := true;

        imagem.Parent := boxBot;
        imagem.Align := alLeft;

        png.LoadFromResourceName(HInstance, 'uno_card_back');

        imagem.Picture.Graphic := png;

        CartasDoJogador2.Add(imagem);
      end;

     end;
end;

procedure TfrmJogoServer.AtualizaEMostraCarta(msgclient: string; StringList: TStringList);
var
carta: TCartaS;
diferenca:Integer;
begin
  StringList.Delete(0);
  jogo.mostraMonte(jogo.GetCartaByName(msgclient, jogo.baralhoJogo.baralhoGeral), false);

  if (pred(StringList.Count) > pred(CartasDoJogador2.Count)) then
    begin
      diferenca:= (pred(StringList.Count) - pred(CartasDoJogador2.Count)-1);
      self.AtualizaCartasdoClient(diferenca, false);
    end
    else
    begin
       diferenca:= ( pred(CartasDoJogador2.Count) - pred(StringList.Count)-1);
       self.AtualizaCartasdoClient(diferenca, true);
    end;
end;

procedure TfrmJogoServer.BoxJogadorMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  BoxJogador.HorzScrollBar.Position := BoxJogador.HorzScrollBar.ScrollPos + 8;
end;

procedure TfrmJogoServer.BoxJogadorMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  BoxJogador.HorzScrollBar.Position := BoxJogador.HorzScrollBar.ScrollPos - 8;
end;

procedure TfrmJogoServer.ObtemNomeOponenteEApagaConexao;
var
qDelete:TFDQuery;
begin
  lblNomeCliente.Caption:= obtemNomeOponenteByBanco; // obtem nome do oponente
  qDelete := TFDQuery.Create(self);
  qDelete.Connection := dmDados.FdConexao;
  dmDados.FdConexao.Connected := true;
  qDelete.SQL.Add('delete from conexao where codigoPartida = :codigoP'); // deleta coluna de conexao;
  qDelete.ParamByName('codigoP').AsInteger := codigoPartida;

  qDelete.ExecSQL;

  FreeAndNil(qDelete);
end;

procedure TfrmJogoServer.OnClickTImage(Sender: TObject);
var
  index: integer;
  cartaName:String;
begin
  jogoEncerrado := false;
  cartaName := (Sender as TImage).Name;
  index := self.retornaIndexTImage((Sender as TImage).Name);
  cartaCerta := jogo.JogaCarta(cartaName, index, jogo.jogador);
  if (cartaCerta) and (jogoEncerrado = false) then
      self.desativaPlayerByJogada(cartaName);
end;

procedure TfrmJogoServer.Reiniciar1Click(Sender: TObject);
begin
  frmJogoServer.Server.StopListening;
  FreeAndNil(frmJogoServer);
end;

function TfrmJogoServer.retornaIndexTImage(cartaName: string): integer;
var
  i: integer;
begin
  for i := 0 to CartasDoJogador.Count do
  begin
    if (CartasDoJogador.Items[i].Name = cartaName) then
    begin
      result := i;
      exit;
    end;
  end;
end;

procedure TfrmJogoServer.ServerConnect(AContext: TIdContext);
var
  ip: string;
  port: Integer;
  peerIP: string;
  peerPort: Integer;
  nClients: Integer;
  msgToClient: string;
  typeClient: string;
begin
  ip := AContext.Binding.IP;
  port := AContext.Binding.Port;
  peerIP := AContext.Binding.PeerIP;
  peerPort := AContext.Binding.PeerPort;
  self.iniciar;
  conectado:= true;
end;

procedure TfrmJogoServer.ServerExecute(AContext: TIdContext);
var
  Port: Integer;
  PeerPort: Integer;
  PeerIP: string;
  msgToClient: string;
  StringList: TStringList;
  cartaMonte:String;
begin
  PeerIP := AContext.Binding.PeerIP;
  PeerPort := AContext.Binding.PeerPort;

  msgToClient := AContext.Connection.IOHandler.ReadLn;

  StringList := TStringList.Create;

  StringList.Delimiter := ';';
  StringList.DelimitedText := msgToClient;

  if (msgToClient.Contains('ACABOU')) then
  begin
    if (msgToClient.Contains('PERDEU')) then
    begin
      self.encerraJogo('perdeu');
      exit;
    end
    else
    begin
      self.encerraJogo('ganhou');
      exit;
    end;

  end;

  if (msgToClient.Contains('EFEITO4')) then
  begin
    if (StringList[2].Contains('COMPRAM4')) then
    begin
       TThread.Queue(nil, procedure
      begin
        ShowMessage('o JOGADOR_CLIENT jogou uma carta +4, ent?o voc? ir? comprar mais 4 cartas automaticamente e a cor pode ter mudado ;) !');
      end);
      jogo.compraCartaEfeito(jogo.jogador, 3);
      corAtual := StringList[1];
      StringList.Delete(0);
      StringList.Delete(0);
    end
    else
    begin
      TThread.Queue(nil, procedure
      begin
        ShowMessage('o JOGADOR_CLIENT jogou uma carta +2 em cima da sua, ent?o voc? ir? comprar mais 4 cartas automaticamente!');
      end);
      jogo.compraCartaEfeito(jogo.jogador, 3);
      StringList.Delete(0);
      StringList.Delete(0);
    end;
  end;

  if (msgToClient.Contains('CHANGECOLOR')) then
  begin
   TThread.Queue(nil, procedure
    begin
      ShowMessage('o JOGADOR_CLIENT jogou uma carta "Troca Cor", ent?o a cor pode ter mudado ;) !');
    end);
    corAtual := StringList[1];
    StringList.Delete(0);
    StringList.Delete(0);
  end;

  if (msgToClient.Contains('NAOCOMPRAMAIS4')) then
    begin
      StringList.Delete(0);

      cartaMonte:= StringList[0];
      StringList.Delete(0);
      self.AtualizaEMostraCarta(cartaMonte, StringList);
      jogo.AtualizaBaralhoClient(StringList);
      jogo.NaoCompraMaisDois;
      exit;
    end;

  cartaMonte:= StringList[0];

  self.AtualizaEMostraCarta(cartaMonte, StringList);
  jogo.AtualizaBaralhoClient(StringList);
  self.ativaJogada;
  jogo.JogaCarta(cartaMonte,0,jogo.jogador2);

end;

procedure TfrmJogoServer.setaImagemCompra;
var
  png: TPngImage;
begin
  png := TPngImage.Create;

  png.LoadFromResourceName(HInstance, 'uno_card_back');

  ImageCompra.Picture.Graphic := png;
end;

procedure TfrmJogoServer.compraCarta(imagemBaralhoJogador: TList<TCartaS>; iCartaCompra: integer; box: TScrollBox; ImagemCartasJogador: TList<Timage>);
var
  i: integer;
  png: TPngImage;
  sla: string;
  cont: integer;
begin
  imagem := TImage.create(self);
  png := TPngImage.Create;

  imagem.Width := 83;

  imagem.Height := 130;
  imagem.Stretch := true;
  imagem.Parent := box;
  imagem.name := 'C' + imagemBaralhoJogador.Items[iCartaCompra].ImageIndex;
  imagem.Align := alLeft;

  imagem.OnClick := OnClickTImage;

  png.LoadFromResourceName(HInstance, imagemBaralhoJogador.Items[iCartaCompra].ImageIndex);

  imagem.Picture.Graphic := png;

  ImagemCartasJogador.Add(imagem);

end;

procedure TfrmJogoServer.criaCartas(jogador: TJogadorS; ImagemCartasJogador: TList<Timage>; box: TScrollBox);
var
  png: TPngImage;
  i: integer;
begin
  for i := 0 to 6 do // dar as cartas pros player
  begin
    imagem := TImage.create(self);
    png := TPngImage.Create;

    imagem.Width := 83;

    imagem.Height := 130;
    imagem.Stretch := true;

    imagem.Parent := box;

    imagem.name := 'C' + jogador.baralhoJogador.Items[i].ImageIndex;

    imagem.Align := alLeft;

    imagem.OnClick := OnClickTImage;

    png.LoadFromResourceName(HInstance, jogador.baralhoJogador.Items[i].ImageIndex);

    imagem.Picture.Graphic := png;

    ImagemCartasJogador.Add(imagem);
  end;
   conectado:= true;
end;

procedure TfrmJogoServer.Delay(msecs: Cardinal);
var
  FirstTickCount: Cardinal;
begin
  {FirstTickCount := GetTickCount;

  repeat

    Application.ProcessMessages;

  until ((GetTickCount - FirstTickCount) >= msecs); }
end;

procedure TfrmJogoServer.desativaPlayerByJogada(cartaName: String);
begin
  if (cartaName.Contains('BLOCK') or (cartaName.Contains('REVERSO'))) then
  begin
    //// nada  ////
  end
  else
  begin
    self.ImageCompra.Enabled := false;
    self.BoxJogador.Enabled := false;
  end;

end;

procedure TfrmJogoServer.encerraJogo(situacao: string);
var
  rStream: TResourceStream;
  fStream: TFileStream;
  fname: string;
  msg: string;
begin
  jogo.CadastraRanking(frmJogoServer.lblNomePlayer.caption, situacao);
  if (situacao.Equals('ganhou')) then
  begin
    fname := ExtractFileDir(Paramstr(0)) + 'win.mp3';
    rStream := TResourceStream.Create(hInstance, 'ganhou', RT_RCDATA);
    msg := 'Ganhooou!';
  end;

  if (situacao.Equals('perdeu')) then
  begin
    fname := ExtractFileDir(Paramstr(0)) + 'loss.mp3';
    rStream := TResourceStream.Create(hInstance, 'loss', RT_RCDATA);
    msg := 'Perdeuuu!';
  end;

  try
    fStream := TFileStream.Create(fname, fmCreate);
    try
      fStream.CopyFrom(rStream, 0);
    finally
      fStream.Free;
    end;
  finally
    rStream.Free;
  end;

  MediaPlayer1.Close;
  MediaPlayer1.FileName := fname;
  MediaPlayer1.Open;
  MediaPlayer1.Play;
  TThread.Queue(nil, procedure
  begin
    ShowMessage(msg);
    MediaPlayer1.Stop;
    Sleep(2000);
    frmJogoServer.Server.StopListening;
    frm_Espera.lblCodigoPartida.Font.Name := 'REVOLUTION';
    frm_Espera.lblCodigoPartida.Font.size := 40;
    frm_Espera.lblCodigoPartida.Caption := 'Jogo Uninho';
    FreeAndNil(frmJogoServer);
  end);
end;

procedure TfrmJogoServer.FormCreate(Sender: TObject);
var
  resposta: string;
begin
  {repeat
    resposta := InputBox('Pronto?', 'Qual seu nome?', '');
  until resposta <> ''; }
  ShowMessage('Sua sala foi criada com sucesso, envie o c?digo gerado para o seu oponente,' +#13
  + 'E alonge-se, pois o jogo vai come?ar!');
  lblNomePlayer.Caption := frm_Espera.nickname;
end;

procedure TfrmJogoServer.FormShow(Sender: TObject);
begin
  self.ObtemNomeOponenteEApagaConexao;
end;

procedure TfrmJogoServer.ImageCompraClick(Sender: TObject);
begin
  jogo.compraCarta(jogo.jogador);
end;

procedure TfrmJogoServer.iniciar;
begin
  CartasDoJogador := TList<TImage>.Create;
  CartasDoJogador2 := TList<TImage>.Create;
  jogo := TJogoS.Create;
  jogo.SetaObjetos;
  self.criaCartas(jogo.jogador, CartasDoJogador, BoxJogador);
  self.AtualizaCartasdoClient(6, false);
  self.setaImagemCompra;
  self.cartaCerta := false;
  conectado:= true;
  //frmJogoServer.lblCount.Caption:= 'Qtde. de cartas: ' + IntToStr(jogo.baralhoJogo.baralho.Count);
end;

function TfrmJogoServer.obtemNomeOponenteByBanco : String;
var
qSelect:TFDQuery;
nickCliente:string;
begin
  qSelect := TFDQuery.Create(self);
  qSelect.Connection := dmDados.FdConexao;
  dmDados.FdConexao.Connected := true;

  qSelect.SQL.Add('select nick_cliente from conexao where codigoPartida = :codPartida');
  qSelect.ParamByName('codPartida').AsInteger := codigoPartida;

  qSelect.Open();

  if (qSelect.RecordCount > 0) then
  begin
    nickCliente := qSelect.FindField('nick_cliente').AsString;
  end;

  FreeAndNil(qSelect);
  result:= nickCliente;
end;

procedure TfrmJogoServer.Sobre1Click(Sender: TObject);
begin
 ShowMessage('Este jogo ? o TCS do 3? semestre de ADS' + #13 + 'na mat?ria de DpD realizado pelos alunos:' + #13 + 'Adryan Rafael da Silva' + #13 + 'Anderson Rafael Bruns' + #13 + 'F?bio Domingues' + #13 + 'Ricardo da Silva Amorin Filho.');
end;

end.

