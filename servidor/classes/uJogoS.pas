unit uJogoS;

interface

uses uBaralhoS, uCartaS, uJogadorS, uMonteS, System.Generics.Collections, FMX.Dialogs, System.SysUtils,
Vcl.Imaging.pngimage, Vcl.ExtCtrls, FormEscolheCor, vcl.dialogs, Windows, IdContext, classes, Vcl.Forms, FireDAC.Comp.Client, dm;

type
  TJogoS = class

    private

    public

    baralhoJogo : TBaralhoS;
    carta : TCartaS;
    jogador : TJogadorS;
    jogador2 : TJogadorS;
    monteJogo : TMonteS;

    procedure SetaObjetos();

    //procedure DistruiCartas();

    procedure RandomCartas(baralhoJogo : TBaralhoS; jogador : TJogadorS); // metodo que randomiza e d? as cartas

    function JogaCarta(cartaName: String; indexTImage:integer; jogador : TJogadorS) : Boolean;

    procedure mostraMonte(carta : TCartaS; op : boolean);

    procedure compraCarta(jogador : TJogadorS);

    function VerificaCorCarta(carta : TCartaS) : Boolean;

    function GetCartaByName(nomeCarta:String; listGenericoCartas: TList<TCartaS>) : TCartaS;

    procedure compraCartaEfeito(jogador:TjogadorS;cont:integer);

    function verificaBlockReverso(jogador : TJogadorS) : Boolean;

    procedure verificaCartaMais2(jogador : TJogadorS);

    procedure MaoJogadorToString(maoJogador : TList<TCartaS>; op: string);

    procedure AtualizaBaralhoClient(cartas : TStringList);

    function ValidaEfeitoByName(cartaName:string) : boolean;

    procedure EnviaInformacoesByEfeito(maoJogador : TList<TCartaS>; cartaMonte: String; op: string);

    procedure liberaJogadaByBlockReverso;

    procedure NaoCompraMaisDois;

    procedure CadastraRanking(nick:string; status:string);
  end;

implementation

{ TJogoS }

uses FormPServer;


procedure TJogoS.AtualizaBaralhoClient(cartas: TStringList);
var
i:integer;
cont:Integer;
carta:TCartaS;
begin
  cont:= 0;
  for carta in baralhoJogo.baralho do
  begin
    for i := 0 to pred(cartas.Count) do
    begin
       if (carta.ImageIndex.Equals(cartas[i])) then
       begin
         baralhoJogo.baralho.Delete(cont);
       end;

    end;
    inc(cont);
  end;
  //frmJogoServer.lblCount.Caption:= 'Qtde. de cartas: ' + IntToStr(baralhoJogo.baralho.Count);

end;

procedure TJogoS.CadastraRanking(nick, status: string);
var
  qInsert:TFDQuery;
begin
  qInsert := TFDQuery.Create(nil);
  qInsert.Connection := dmDados.FdConexao;
  dmDados.FdConexao.Connected := true;
  qInsert.SQL.Add('INSERT INTO ranking(player_id, status_id) SELECT r.id,:status FROM player r WHERE r.nome = :nickName;');
  qInsert.ParamByName('nickName').AsString := nick;
  if (status.Equals('ganhou')) then
  begin
    qInsert.ParamByName('status').AsInteger := 1;
  end
  else
  begin
    qInsert.ParamByName('status').AsInteger := 2;
  end;

  qInsert.ExecSQL;

end;

procedure TJogoS.compraCarta(jogador : TJogadorS);
var
num: integer;
carta: TCartaS;
begin
  num := Random(baralhoJogo.baralho.Count);
  jogador.baralhoJogador.Add(baralhoJogo.baralho[num]);

  frmJogoServer.compraCarta(baralhoJogo.baralho, num, frmJogoServer.BoxJogador, frmJogoServer.CartasDoJogador);

  baralhoJogo.baralho.Delete(num);

  //frmJogoServer.lblCount.Caption:= 'Qtde. de cartas: ' + IntToStr(baralhoJogo.baralho.Count);
end;


procedure TJogoS.compraCartaEfeito(jogador: TjogadorS; cont: integer);
var
icompra:integer;
begin
  for icompra := 0 to cont do
  begin
    compraCarta(self.jogador);
  end;
end;


procedure TJogoS.EnviaInformacoesByEfeito(maoJogador: TList<TCartaS>; cartaMonte, op: string);
var
carta : TCartaS;
cartasNome : String;
msgToServer:String;
begin
  cartasNome := '';
  for carta in maoJogador do
  begin
     cartasNome := cartasNome + ';' + carta.ImageIndex;
  end;
  cartasNome := cartaMonte + cartasNome;

  frmJogoServer.EnviaInstrucaoClient(Trim(cartasNome), op);
end;

function TJogoS.GetCartaByName(nomeCarta:String; listGenericoCartas: TList<TCartaS>): TCartaS;
var
i:integer;
carta:TCartaS;
begin
  for carta in listGenericoCartas do
  begin
    if (carta.ImageIndex.Equals(nomeCarta)) then
    begin
       result := carta;
       exit;
    end;
  end;
end;

function TJogoS.JogaCarta(cartaName: String; indexTImage:integer; jogador : TJogadorS) : Boolean;
var
  carta: TCartaS;
  cont:integer;
  penultimaCarta:Integer;
begin
  Result := true;
  cont:= 0;
  penultimaCarta:= monteJogo.Monte.Count-1;
  if (jogador.bot = false) then
    delete(cartaName, 1, 1);

  if (monteJogo.Monte.Count = 0) or (cartaName.Contains('COMPRAM4'))
  or (cartaName.Contains('TROCACOR')) or
   (VerificaCorCarta(GetCartaByName(cartaName, baralhoJogo.baralhoGeral))) then
  begin

    if not (jogador.bot) then
    begin

      for carta in jogador.baralhoJogador do
      begin

        if (carta.ImageIndex.Equals(cartaName)) then
        begin
          jogador.baralhoJogador.Delete(cont);

          frmJogoServer.CartasDoJogador[indexTImage].Destroy;
          frmJogoServer.CartasDoJogador.Delete(indexTImage);

          if ((penultimaCarta >= 0) and monteJogo.Monte.Items[penultimaCarta].ImageIndex.Contains('F_2_') and cartaName.Contains('F_2_') and (frmJogoServer.CartasDoJogador.Count > 0)) then
          begin
            self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'NAOCOMPRAMAIS4;');
            mostraMonte(carta, false);
            exit;
          end;


          if (cartaName.contains('COMPRAM4')) or (cartaName.contains('TROCACOR') and (frmJogoServer.CartasDoJogador.Count > 0)) then
          begin
            carta.num := 7686;
            frmEscolheCor.ShowModal;
            carta.cor := frmEscolheCor.cor;
            frmJogoServer.lblCorAtual.Caption := 'Cor Atual: ' +  carta.cor;
            if (cartaName.contains('COMPRAM4')) then
            begin
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'EFEITO4' + ';' + frmEscolheCor.cor + ';');
            end
            else
            begin
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'CHANGECOLOR' + ';' + frmEscolheCor.cor + ';');
            end;
            mostraMonte(carta, false);
          end
          else
          begin
            mostraMonte(carta, true);
          end;

        end;
        inc(cont);
      end;
    end
    else
    begin
      self.liberaJogadaByBlockReverso;
      self.ValidaEfeitoByName(cartaName);
      exit;
    end;

  end
  else
  begin
    ShowMessage('Carta n?o corresponde a do monte do jogo, verifique e tente novamente!');
    result:= false;
    exit;
  end;
end;

procedure TJogoS.liberaJogadaByBlockReverso;
begin
  if (frmJogoServer.BoxJogador.Enabled = false) then
  begin
  //ShowMessage('Chegou sua vez novamente, pode jogar :) .');
  frmJogoServer.BoxJogador.Enabled := true;
  frmJogoServer.ImageCompra.Enabled := true;
  end;
end;

procedure TJogoS.MaoJogadorToString(maoJogador : TList<TCartaS>; op: string);
var
carta : TCartaS;
cartasNome : String;
begin
    cartasNome := '';
    for carta in maoJogador do
    begin
       cartasNome := cartasNome + ';' + carta.ImageIndex;
    end;

    if (op.Equals('iniciar')) then
    begin
     frmJogoServer.EnviaInstrucaoClient(Trim(cartasNome), 'BARALHO');
    end
    else
    begin
     frmJogoServer.EnviaInstrucaoClient(Trim(cartasNome), op);
    end;

end;

procedure TJogoS.mostraMonte(carta : TCartaS; op : boolean);
var
  png: TPngImage;
  qtdeDeCartas: integer;
begin

  if (frmJogoServer.CartasDoJogador.Count = 0) then
  begin
    monteJogo.Monte.Add(carta);
    frmJogoServer.EnviaInstrucaoClient('ACABOU', 'PERDEU');
    frmJogoServer.EncerraJogo('ganhou');
    exit;
  end;

  if (frmJogoServer.CartasDoJogador2.Count = 0) then
  begin
    monteJogo.Monte.Add(carta);
    frmJogoServer.EnviaInstrucaoClient('ACABOU', 'GANHOU');
    frmJogoServer.EncerraJogo('perdeu');
    exit;
  end;

  if (op) then
  begin
    self.MaoJogadorToString(jogador.baralhoJogador, carta.ImageIndex);
  end;

  monteJogo.Monte.Add(carta);

  png:=TPngImage.Create;
  png.LoadFromResourceName(HInstance, carta.ImageIndex);

  frmJogoServer.ImageMonte.Picture.Graphic:= png;
  frmJogoServer.lblCorAtual.Caption := 'Cor Atual: ' +  carta.cor;

end;

procedure TJogoS.NaoCompraMaisDois;
var
retornomsg:integer;
carta:TCartaS;
indexImage: integer;
cont: integer;
begin
  for carta in self.jogador.baralhoJogador do
  begin
      if (carta.ImageIndex.Contains('F_2_')) then
      begin
        {frmJogoServer.ImageCompra.Enabled := false;
        frmJogoServer.BoxJogador.Enabled := false; }
        retornomsg := Application.MessageBox('Voc? tem uma carta +2, deseja joga-la em cima?', 'Jogar?', MB_YESNO);
        if (retornomsg = 6) then
        begin
          IndexImage := frmJogoServer.retornaIndexTImage('C'+carta.ImageIndex);
          self.jogador.baralhoJogador.Delete(cont);
          frmJogoServer.CartasDoJogador[indexImage].Destroy;
          frmJogoServer.CartasDoJogador.Delete(indexImage);
          mostraMonte(carta, false);
          frmJogoServer.ImageCompra.Enabled := false;
          frmJogoServer.BoxJogador.Enabled := false;
          self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, carta.ImageIndex, 'EFEITO4;');
          exit
        end;
      end;
    inc(cont);
  end;
   TThread.Queue(nil, procedure
  begin
  ShowMessage('Voc? n?o tinha uma carta +2 para jogar em cima, ent?o ir? comprar mais duas cartas automaticamente!');
  end);
  self.compraCartaEfeito(self.jogador,1);
  self.liberaJogadaByBlockReverso;
  exit
end;

procedure TJogoS.RandomCartas(baralhoJogo : TBaralhoS; jogador : TJogadorS) ;
var
  i:integer;
  cont:integer;
  num:integer;
begin
  for cont := 0 to 6 do
  begin
    num := Random(baralhoJogo.baralho.Count);

    jogador.baralhoJogador.Add(baralhoJogo.baralho.Items[num]);
    baralhoJogo.baralho.Delete(num);
  end;

end;

procedure TJogoS.SetaObjetos;
var
  carta: TCartaS;
begin
  baralhoJogo := TBaralhoS.Create;
  monteJogo := TMonteS.Create;
  jogador := TJogadorS.Create;
  jogador2 := TJogadorS.Create;
  jogador.baralhoJogador := TList<TCartaS>.Create;
  jogador2.bot := true;
  jogador2.nome := 'JOGADOR2_CLIENT';
  monteJogo.Monte := TList<TCartaS>.Create;
  baralhoJogo.DefineCartaByNome;
  RandomCartas(baralhoJogo, jogador);
  MaoJogadorToString(jogador.baralhoJogador, 'iniciar');
end;


function TJogoS.ValidaEfeitoByName(cartaName: string): boolean;
var
carta:TCartaS;
penultimaCarta:Integer;
cartaAtualMonte:Integer;
begin
  result:= false;
  carta := TCartaS.Create;
  carta.ImageIndex:= cartaName;
  if (carta.ImageIndex.Contains('BLOCK') = true) or (carta.ImageIndex.Contains('REVERSO') = true)  then
  begin
    result:= verificaBlockReverso(jogador);
    exit;
  end;

  if (cartaName.Contains('F_2_')) then
  begin
      self.verificaCartaMais2(jogador2);
      exit;
  end;

  if (cartaName.contains('COMPRAM4')) or (cartaName.contains('TROCACOR')) then
  begin
      cartaAtualMonte:= monteJogo.Monte.Count-1;
      monteJogo.Monte.Items[cartaAtualMonte].cor := frmJogoServer.corAtual;
      frmJogoServer.lblCorAtual.Caption := 'Cor Atual: ' +  frmJogoServer.corAtual;
    end;
  Exit
end;

function TJogoS.verificaBlockReverso(jogador: TJogadorS): Boolean;
begin
    TThread.Queue(nil, procedure
    begin
      ShowMessage('Sua vez foi bloqueada, o jogador2 vai jogar de novo :)');
    end);
    frmJogoServer.BoxJogador.Enabled := false;
    frmJogoServer.ImageCompra.Enabled := false;
    result:= true;
end;

procedure TJogoS.verificaCartaMais2(jogador: TJogadorS);
var
carta : TCartaS;
retornomsg:integer;
indexImage: integer;
cont: integer;
penultimaCarta:integer;
begin
  retornomsg:= 0;
  cont:=0;
  penultimaCarta:= monteJogo.Monte.Count-2;
  if (jogador.bot) then
  begin
    if(penultimaCarta >= 0) and monteJogo.Monte.Items[penultimaCarta].ImageIndex.Contains('F_2_') then
    begin
      exit;
    end
    else
    begin
      for carta in self.jogador.baralhoJogador do
      begin
          if (carta.ImageIndex.Contains('F_2_')) then
          begin
            {frmJogoServer.ImageCompra.Enabled := false;
            frmJogoServer.BoxJogador.Enabled := false;}
            retornomsg := Application.MessageBox('Voc? tem uma carta +2, deseja joga-la em cima?', 'Jogar?', MB_YESNO);

            if (retornomsg = 6) then
            begin
              IndexImage := frmJogoServer.retornaIndexTImage('C'+carta.ImageIndex);
              self.jogador.baralhoJogador.Delete(cont);
              frmJogoServer.CartasDoJogador[indexImage].Destroy;
              frmJogoServer.CartasDoJogador.Delete(indexImage);
              mostraMonte(carta, false);
              frmJogoServer.ImageCompra.Enabled := false;
              frmJogoServer.BoxJogador.Enabled := false;
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, carta.ImageIndex, 'EFEITO4;');
              exit
            end;
            break
          end;
        inc(cont);
      end;
      TThread.Queue(nil, procedure
      begin
      ShowMessage('Voc? n?o tinha/n?o quis jogar uma carta +2, ent?o ir? comprar mais duas cartas automaticamente!');
      end);
      self.compraCartaEfeito(self.jogador,1);
      exit
    end;
  end
end;

function TJogoS.VerificaCorCarta(carta: TCartaS): Boolean;
var
  ultimoIndex: integer;
  corcartaMonte: String;
  numCartaMonte: integer;
  tipoEfeitoMonte : String;
begin
  ultimoIndex:= monteJogo.Monte.Count-1;
  result := false;
  corcartaMonte := monteJogo.Monte.Items[ultimoIndex].cor;
  numCartaMonte := monteJogo.Monte.Items[ultimoIndex].num;
  tipoEfeitoMonte := monteJogo.Monte.Items[ultimoIndex].tipoEfeito;

  if (carta.cor.Equals(corcartaMonte) or (carta.num = numCartaMonte) and (carta.efeito = false))
  or (carta.tipoEfeito.Equals(tipoEfeitoMonte) and (carta.efeito = true)) then
  begin
    result := true;
  end;

end;

end.
