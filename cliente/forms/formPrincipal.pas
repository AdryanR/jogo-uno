unit formPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.Imaging.pngimage,
  Generics.Collections, uBaralho, uCarta, uJogador, uMonte, uJogo, Vcl.MPlayer,
  Vcl.Menus, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdThreadComponent, FireDAC.Comp.Client;

type
  Tfrm_Jogo = class(TForm)
    ImageCompra: TImage;
    ImageMonte: TImage;
    PanelFantasmaBot: TPanel;
    boxBot: TScrollBox;
    MediaPlayer1: TMediaPlayer;
    Menu: TMainMenu;
    Reiniciar1: TMenuItem;
    Sobre1: TMenuItem;
    BoxJogador: TScrollBox;
    lblICompra: TLabel;
    btnReinicia: TButton;
    lblCorAtual: TLabel;
    Client: TIdTCPClient;
    IdThreadComponent: TIdThreadComponent;
    lblNomeServer: TLabel;
    lblNomePlayer: TLabel;
    procedure ImageCompraClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BoxJogadorMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure BoxJogadorMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure Sobre1Click(Sender: TObject);
    procedure ClientConnected(Sender: TObject);
    procedure IdThreadComponentRun(Sender: TIdThreadComponent);
    procedure Reiniciar1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    { Public declarations }

    imagem: TImage;
    imagemBot: TImage;
    baralho: TBaralho;
    carta: TCarta;
    jogador: TJogador;
    monte: TMonte;
    jogo: TJogo;
    cartaCerta: Boolean;
    jogoEncerrado: boolean;
    CartasDoJogador: TList<TImage>;
    //CartasDoBot: TList<TImage>;
    CartasDoJogador2: TList<TImage>;
    corAtual: String;

    { Private declarations }

    codigoPartida:integer;

    procedure criaCartas(jogador: TJogador; ImagemCartasJogador: TList<Timage>; box: TScrollBox);
    procedure compraCarta(imagemBaralhoJogador: TList<TCarta>; iCartaCompra: integer; box: TScrollBox; ImagemCartasJogador: TList<Timage>);
    procedure OnClickTImage(Sender: TObject);
    function retornaIndexTImage(cartaName: string): integer;
    procedure setaImagemCompra;
    procedure encerraJogo(situacao: string);
    procedure iniciar();
    procedure Delay(msecs: Cardinal);
    procedure AtualizaCartasDoServer(qtde: integer; op: boolean);
    procedure AtualizaEMostraCarta(msgserver: string; StringList : TStringList);
    procedure EnviaInstrucoesServer(msg: string; instrucao: string);
    procedure desativaPlayerByJogada(cartaName: String);
    procedure ativaJogada;
    function obtemNomeOponenteByBanco : String;
  end;

var
  frm_Jogo: Tfrm_Jogo;

implementation

uses
  FormEscolheCor, frm_Lobby, dm;

{$R *.dfm}


{$R JogoUnoResource.RES}

procedure Tfrm_Jogo.EnviaInstrucoesServer(msg: string; instrucao: string);
var
  msgToServer: string;
begin
  msgToServer := Trim(instrucao + msg);
  Client.IOHandler.WriteLn(msgToServer);
end;

procedure Tfrm_Jogo.BoxJogadorMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  BoxJogador.HorzScrollBar.Position := BoxJogador.HorzScrollBar.ScrollPos + 8;
end;

procedure Tfrm_Jogo.BoxJogadorMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  BoxJogador.HorzScrollBar.Position := BoxJogador.HorzScrollBar.ScrollPos - 8;
end;

procedure Tfrm_Jogo.ClientConnected(Sender: TObject);
begin
  IdThreadComponent.Active := True;
end;

procedure Tfrm_Jogo.OnClickTImage(Sender: TObject);
var
  index: integer;
  cartaName:string;
begin
  jogoEncerrado := false;
  cartaName := (Sender as TImage).Name;
  index := self.retornaIndexTImage((Sender as TImage).Name);
  cartaCerta := jogo.JogaCarta(cartaName, index, jogo.jogador);
  if (cartaCerta) and (jogoEncerrado = false) then
      self.desativaPlayerByJogada(cartaName);
end;

procedure Tfrm_Jogo.Reiniciar1Click(Sender: TObject);
begin
  Client.Disconnect;
  frm_Jogo.Close;
end;

function Tfrm_Jogo.retornaIndexTImage(cartaName: string): integer;
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

procedure Tfrm_Jogo.setaImagemCompra;
var
  png: TPngImage;
begin
  png := TPngImage.Create;

  png.LoadFromResourceName(HInstance, 'uno_card_back');

  ImageCompra.Picture.Graphic := png;
end;

procedure Tfrm_Jogo.compraCarta(imagemBaralhoJogador: TList<TCarta>; iCartaCompra: integer; box: TScrollBox; ImagemCartasJogador: TList<Timage>);
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

procedure Tfrm_Jogo.criaCartas(jogador: TJogador; ImagemCartasJogador: TList<Timage>; box: TScrollBox);
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

end;

procedure Tfrm_Jogo.Delay(msecs: Cardinal);
var
  FirstTickCount: Cardinal;
begin
  FirstTickCount := GetTickCount;

  repeat

    Application.ProcessMessages;

  until ((GetTickCount - FirstTickCount) >= msecs);
end;

procedure Tfrm_Jogo.desativaPlayerByJogada(cartaName: String);
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

procedure Tfrm_Jogo.ativaJogada;
begin
  self.ImageCompra.Enabled := true;
  self.BoxJogador.Enabled := true;
end;

procedure Tfrm_Jogo.AtualizaCartasDoServer(qtde: integer; op: boolean);
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
      end;
  end
  else
   begin
    for i := 0 to qtde do
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

procedure Tfrm_Jogo.encerraJogo(situacao: string);
var
  rStream: TResourceStream;
  fStream: TFileStream;
  fname: string;
  msg: string;
begin
  jogo.CadastraRanking(frm_Jogo.lblNomePlayer.caption, situacao);
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
    Client.Disconnect;
    frm_Jogo.Close;
  end);
end;

procedure Tfrm_Jogo.FormCreate(Sender: TObject);
var
  resposta: string;
  cartadoservidor: string;
begin
  {repeat
    resposta := InputBox('Pronto?', 'Qual seu nome?', '');
  until resposta <> '';  }
  ShowMessage('Seja bem vindo ao Uno, ' + 'NOME' + '!' + #13 + 'Alonge-se, o jogo vai come?ar!');
  lblNomePlayer.Caption := 'NOMEJOGADOR';
  lblNomePlayer.Caption := frm_Espera.nickname;
end;

procedure Tfrm_Jogo.FormShow(Sender: TObject);
begin
   lblNomeServer.Caption:= obtemNomeOponenteByBanco;
end;

procedure Tfrm_Jogo.IdThreadComponentRun(Sender: TIdThreadComponent);
var
  msgDoServer: string;
  StringList: TStringList;
  cartaMonte: string;
  diferenca:integer;
begin
  msgDoServer := Trim(Client.IOHandler.ReadLn());
  StringList := TStringList.Create;
 if (msgDoServer.Contains('BARALHO')) then
  begin
    StringList.Delimiter := ';';
    StringList.DelimitedText := msgDoServer;
    StringList.Delete(0);
    StringList.Delete(0);

    CartasDoJogador := TList<TImage>.Create;
    CartasDoJogador2 := TList<TImage>.Create;
    jogo := TJogo.Create;
    jogo.SetaObjetos;
    jogo.AtualizaBaralhoComecoServer(StringList);
    jogo.RandomCartas(jogo.baralhoJogo, jogo.jogador);
    self.criaCartas(jogo.jogador, CartasDoJogador, BoxJogador);
    self.setaImagemCompra;
  end
  else
  begin
    StringList.Delimiter := ';';
    StringList.DelimitedText := msgDoServer;

    if (msgDoServer.Contains('ACABOU')) then
    begin
      if (msgDoServer.Contains('PERDEU')) then
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

    if (msgDoServer.Contains('EFEITO4')) then
    begin
      if (StringList[2].Contains('COMPRAM4')) then
      begin
         TThread.Queue(nil, procedure
        begin
          ShowMessage('o JOGADOR_SERVER jogou uma carta +4, ent?o voc? ir? comprar mais 4 cartas automaticamente e a cor pode ter mudado ;) !');
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
          ShowMessage('o JOGADOR_SERVER jogou uma carta +2 em cima da sua, ent?o voc? ir? comprar mais 4 cartas automaticamente!');
        end);
        jogo.compraCartaEfeito(jogo.jogador, 3);
        StringList.Delete(0);
      end;
    end;

    if (msgDoServer.Contains('CHANGECOLOR')) then
    begin
     TThread.Queue(nil, procedure
      begin
        ShowMessage('o JOGADOR_SERVER jogou uma carta "Troca Cor", ent?o a cor pode ter mudado ;) !');
      end);
      corAtual := StringList[1];
      StringList.Delete(0);
      StringList.Delete(0);
    end;

    if (msgDoServer.Contains('NAOCOMPRAMAIS4')) then
    begin
      StringList.Delete(0);

      cartaMonte:= StringList[0];
      StringList.Delete(0);
      self.AtualizaEMostraCarta(cartaMonte, StringList);
      jogo.AtualizaBaralhoComecoServer(StringList);
      jogo.NaoCompraMaisDois;
      exit;
    end;

    cartaMonte:= StringList[0];
    self.AtualizaEMostraCarta(cartaMonte, StringList);

    jogo.AtualizaBaralhoComecoServer(StringList);
    jogo.JogaCarta(cartaMonte,0,jogo.jogador2);

  end;

end;

procedure Tfrm_Jogo.ImageCompraClick(Sender: TObject);
begin
  jogo.compraCarta(jogo.jogador);
end;

procedure Tfrm_Jogo.iniciar;
begin
  CartasDoJogador := TList<TImage>.Create;
  CartasDoJogador2 := TList<TImage>.Create;
  jogo := TJogo.Create;
  jogo.SetaObjetos;
  self.criaCartas(jogo.jogador, CartasDoJogador, BoxJogador);
  self.setaImagemCompra;

  self.cartaCerta := false;
end;

function Tfrm_Jogo.obtemNomeOponenteByBanco: String;
var
qSelect:TFDQuery;
nickServer:string;
begin
  qSelect := TFDQuery.Create(self);
  qSelect.Connection := dmDados.FdConexao;
  dmDados.FdConexao.Connected := true;

  qSelect.SQL.Add('select nick_server from conexao where codigoPartida = :codPartida');
  qSelect.ParamByName('codPartida').AsInteger := codigoPartida;

  qSelect.Open();

  if (qSelect.RecordCount > 0) then
  begin
    nickServer := qSelect.FindField('nick_server').AsString;
  end;

  FreeAndNil(qSelect);
  result:= nickServer;
end;

procedure Tfrm_Jogo.AtualizaEMostraCarta(msgserver: string; StringList : TStringList); // mostra a carta jogada pelo server
var
carta: Tcarta;
diferenca:integer;
begin
  StringList.Delete(0);
  jogo.mostraMonte(jogo.GetCartaByName(msgserver, jogo.baralhoJogo.baralhoGeral), false);

  if (pred(StringList.Count) > pred(CartasDoJogador2.Count)) then
  begin
    diferenca:= (pred(StringList.Count) - pred(CartasDoJogador2.Count)-1);
    self.AtualizaCartasDoServer(diferenca, false);
  end
  else
    begin
       diferenca:= ( pred(CartasDoJogador2.Count) - pred(StringList.Count)-1);
       self.AtualizaCartasDoServer(diferenca, true);
    end;
end;

procedure Tfrm_Jogo.Sobre1Click(Sender: TObject);
begin
  ShowMessage('Este jogo ? o TCS do 3? semestre de ADS' + #13 + 'na mat?ria de DpD realizado pelos alunos:' + #13 + 'Adryan Rafael da Silva' + #13 + 'Anderson Rafael Bruns' + #13 + 'F?bio Domingues' + #13 + 'Ricardo da Silva Amorin Filho.');
end;

end.

