unit uJogo;

interface

uses uBaralho, uCarta, uJogador, uMonte, System.Generics.Collections, FMX.Dialogs, System.SysUtils,
Vcl.Imaging.pngimage, Vcl.ExtCtrls, vcl.dialogs, Windows, Classes, Vcl.Forms, FireDAC.Comp.Client, dm;

type
  TJogo = class

    private

    public

    baralhoJogo : TBaralho;
    carta : TCarta;
    jogador : TJogador;
    jogador2: Tjogador;
    monteJogo : TMonte;

    procedure SetaObjetos();

    procedure RandomCartas(baralhoJogo : TBaralho; jogador : TJogador); // metodo que randomiza e dá as cartas

    function JogaCarta(cartaName: String; indexTImage:integer; jogador : TJogador) : Boolean;

    procedure mostraMonte(carta : TCarta; opcao : boolean);

    procedure compraCarta(jogador : TJogador);

    function VerificaCorCarta(carta : TCarta) : Boolean;

    function GetCartaByName(nomeCarta:String; listGenericoCartas: TList<TCarta>) : TCarta;

    procedure compraCartaEfeito(jogador:Tjogador;cont:integer);

    function verificaBlockReverso(jogador : TJogador) : Boolean;

    procedure verificaCartaMais2(jogador : TJogador);

    procedure AtualizaBaralhoComecoServer(cartas : TStringList);

    procedure MaoJogadorToString(maoJogador : TList<TCarta>; op: string);

    function ValidaEfeitoByName(cartaName:String) : boolean;

    procedure EnviaInformacoesByEfeito(maoJogador : TList<TCarta>; cartaMonte: String; op: string);

    procedure liberaJogadaByBlockReverso;

    procedure NaoCompraMaisDois;

    procedure CadastraRanking(nick:string; status:string);
  end;

implementation

{ TJogo }

uses formPrincipal, FormEscolheCor;


procedure TJogo.AtualizaBaralhoComecoServer(cartas: TStringList);
var
i:integer;
cont:Integer;
carta:Tcarta;
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
  if (cont > 100) then
  begin
    frm_Jogo.AtualizaCartasDoServer(6, false);
  end;
  //frm_Jogo.lblCount.Caption:= 'Qtde. de cartas: ' + IntToStr(baralhoJogo.baralho.Count);

end;

procedure TJogo.CadastraRanking(nick, status: string);
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

procedure TJogo.compraCarta(jogador : TJogador);
var
num: integer;
carta: TCarta;
begin
  num := Random(baralhoJogo.baralho.Count);
  jogador.baralhoJogador.Add(baralhoJogo.baralho[num]);

  frm_Jogo.compraCarta(baralhoJogo.baralho, num, frm_Jogo.BoxJogador, frm_Jogo.CartasDoJogador);

  baralhoJogo.baralho.Delete(num);

  //frm_Jogo.lblCount.Caption:= 'Qtde. de cartas: ' + IntToStr(baralhoJogo.baralho.Count);
end;


procedure TJogo.compraCartaEfeito(jogador: Tjogador; cont: integer);
var
icompra:integer;
begin
  for icompra := 0 to cont do
  begin
    compraCarta(self.jogador);
  end;
end;


procedure TJogo.EnviaInformacoesByEfeito(maoJogador: TList<TCarta>; cartaMonte, op: string);
var
carta : Tcarta;
cartasNome : String;
msgToServer:String;
begin
  cartasNome := '';
  for carta in maoJogador do
  begin
     cartasNome := cartasNome + ';' + carta.ImageIndex;
  end;
  cartasNome := cartaMonte + cartasNome;

  msgToServer := Trim(op + ';' + Trim(cartasNome));
  frm_Jogo.Client.IOHandler.WriteLn(msgToServer);
end;

function TJogo.GetCartaByName(nomeCarta:String; listGenericoCartas: TList<TCarta>): TCarta;
var
i:integer;
carta:TCarta;
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

function TJogo.JogaCarta(cartaName: String; indexTImage:integer; jogador : TJogador) : Boolean;
var
  carta: TCarta;
  cont:integer;
  penultimaCarta:integer;
  cartadoMonte:String;
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

          frm_Jogo.CartasDoJogador[indexTImage].Destroy;
          frm_Jogo.CartasDoJogador.Delete(indexTImage);

          if ((penultimaCarta >= 0) and monteJogo.Monte.Items[penultimaCarta].ImageIndex.Contains('F_2_') and cartaName.Contains('F_2_') and (frm_Jogo.CartasDoJogador.Count > 0))  then
          begin
            self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'NAOCOMPRAMAIS4');
            mostraMonte(carta, false);
            exit;
          end;


          if (cartaName.contains('COMPRAM4')) or (cartaName.contains('TROCACOR') and (frm_Jogo.CartasDoJogador.Count > 0)) then
          begin
            carta.num := 7686;
            frmEscolheCor.ShowModal;
            carta.cor := frmEscolheCor.cor;
            frm_Jogo.lblCorAtual.Caption := 'Cor Atual: ' +  carta.cor;
            if (cartaName.contains('COMPRAM4')) then
            begin
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'EFEITO4' + ';' + frmEscolheCor.cor);
            end
            else
            begin
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, cartaName, 'CHANGECOLOR' + ';' + frmEscolheCor.cor);
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
    end;

  end
  else
  begin
    ShowMessage('Carta não corresponde a do monte do jogo, verifique e tente novamente!');
    result:= false;
    exit;
  end;
end;

procedure TJogo.liberaJogadaByBlockReverso;
begin
  if (frm_Jogo.BoxJogador.Enabled = false) then
  begin
  //ShowMessage('Chegou sua vez novamente, pode jogar :) .');
  frm_Jogo.BoxJogador.Enabled := true;
  frm_Jogo.ImageCompra.Enabled := true;
  end;
end;

procedure TJogo.MaoJogadorToString(maoJogador: TList<TCarta>; op: string);
var
carta : Tcarta;
cartasNome : String;
begin
    cartasNome := '';
    for carta in maoJogador do
    begin
       cartasNome := cartasNome + ';' + carta.ImageIndex;
    end;

     frm_Jogo.EnviaInstrucoesServer(Trim(cartasNome), op);
end;

procedure TJogo.mostraMonte(carta : TCarta ; opcao : boolean);
var
  png: TPngImage;
  msgToServer:String;
begin
  if (frm_Jogo.CartasDoJogador.Count = 0) then
  begin
    msgToServer := Trim('ACABOU' + 'PERDEU');
    frm_Jogo.Client.IOHandler.WriteLn(msgToServer);
    frm_Jogo.EncerraJogo('ganhou');
    exit;
  end;

  if (frm_Jogo.CartasDoJogador2.Count = 0) then
  begin
    msgToServer := Trim('ACABOU' + 'GANHOU');
    frm_Jogo.Client.IOHandler.WriteLn(msgToServer);
    frm_Jogo.EncerraJogo('perdeu');
    exit;
  end;

  if (opcao) then
  begin
    self.MaoJogadorToString(jogador.baralhoJogador, carta.ImageIndex);
   end;

    monteJogo.Monte.Add(carta);
    png:=TPngImage.Create;
    png.LoadFromResourceName(HInstance, carta.ImageIndex);

    frm_Jogo.ImageMonte.Picture.Graphic:= png;
    frm_Jogo.lblCorAtual.Caption := 'Cor Atual: ' +  carta.cor;
end;

procedure TJogo.NaoCompraMaisDois;
var
retornomsg:integer;
carta:TCarta;
indexImage: integer;
cont: integer;
begin
  for carta in self.jogador.baralhoJogador do
  begin
      if (carta.ImageIndex.Contains('F_2_')) then
      begin
        {frm_Jogo.ImageCompra.Enabled := false;
        frm_Jogo.BoxJogador.Enabled := false;}
        retornomsg := Application.MessageBox('Você tem uma carta +2, deseja joga-la em cima?', 'Jogar?', MB_YESNO);

        if (retornomsg = 6) then
        begin
          IndexImage := frm_Jogo.retornaIndexTImage('C'+carta.ImageIndex);
          self.jogador.baralhoJogador.Delete(cont);
          frm_Jogo.CartasDoJogador[indexImage].Destroy;
          frm_Jogo.CartasDoJogador.Delete(indexImage);
          mostraMonte(carta, false);
          frm_Jogo.ImageCompra.Enabled := false;
          frm_Jogo.BoxJogador.Enabled := false;
          self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, carta.ImageIndex, 'EFEITO4;');
          exit
        end;
      end;
    inc(cont);
  end;
   TThread.Queue(nil, procedure
  begin
  ShowMessage('Você não tinha uma carta +2 para jogar em cima, então irá comprar mais duas cartas automaticamente!');
  end);
  self.compraCartaEfeito(self.jogador,1);
  self.liberaJogadaByBlockReverso;
  exit
end;

procedure TJogo.RandomCartas(baralhoJogo : TBaralho; jogador : TJogador) ;
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


procedure TJogo.SetaObjetos;
var
  carta: TCarta;
begin
  baralhoJogo := TBaralho.Create;
  monteJogo := TMonte.Create;
  jogador := TJogador.Create;
  jogador2 := TJogador.Create;
  jogador.baralhoJogador := TList<TCarta>.Create;
  jogador2.bot := true;
  jogador2.nome := 'JOGADOR2_SERVER';
  monteJogo.Monte := TList<TCarta>.Create;
  baralhoJogo.DefineCartaByNome;

end;


function TJogo.ValidaEfeitoByName(cartaName:String) : boolean;
var
carta:TCarta;
cartaAtualMonte:integer;
begin
result:= false;
  carta := TCarta.Create;
  carta.ImageIndex:= cartaName;
  if (carta.ImageIndex.Contains('BLOCK') = true) or (carta.ImageIndex.Contains('REVERSO') = true)  then
  begin
    carta.num := 8686;
    result:= verificaBlockReverso(jogador);
    exit;
  end;

  if (cartaName.Contains('F_2_')) then
  begin
        carta.num := 8778;
        self.verificaCartaMais2(jogador2);
        exit;
  end;

  if (cartaName.contains('COMPRAM4')) or (cartaName.contains('TROCACOR')) then
  begin
      cartaAtualMonte:= monteJogo.Monte.Count-1;
      monteJogo.Monte.Items[cartaAtualMonte].cor := frm_Jogo.corAtual;
      frm_Jogo.lblCorAtual.Caption := 'Cor Atual: ' +  frm_Jogo.corAtual;
    end;
  Exit

end;

function TJogo.verificaBlockReverso(jogador: TJogador): Boolean;
begin
    TThread.Queue(nil, procedure
    begin
      ShowMessage('Sua vez foi bloqueada, o jogador2 vai jogar de novo :)');
    end);
    frm_Jogo.BoxJogador.Enabled := false;
    frm_Jogo.ImageCompra.Enabled := false;
    result:= true;
end;

procedure TJogo.verificaCartaMais2(jogador : TJogador);
var
carta : TCarta;
retornomsg:integer;
indexImage: integer;
cont: integer;
penultimaCarta:integer;
begin
  retornomsg:= 0;
  cont:=0;
  penultimaCarta:= monteJogo.Monte.Count-2;
  if(penultimaCarta >= 0) and monteJogo.Monte.Items[penultimaCarta].ImageIndex.Contains('F_2_') then
  begin
    exit;
  end;
  if (jogador.bot) then
  begin
      for carta in self.jogador.baralhoJogador do
      begin
          if (carta.ImageIndex.Contains('F_2_')) then
          begin
            {frm_Jogo.ImageCompra.Enabled := false;
            frm_Jogo.BoxJogador.Enabled := false; }
            retornomsg := Application.MessageBox('Você tem uma carta +2, deseja joga-la em cima?', 'Jogar?', MB_YESNO);

            if (retornomsg = 6) then
            begin
              IndexImage := frm_Jogo.retornaIndexTImage('C'+carta.ImageIndex);
              self.jogador.baralhoJogador.Delete(cont);
              frm_Jogo.CartasDoJogador[indexImage].Destroy;
              frm_Jogo.CartasDoJogador.Delete(indexImage);
              mostraMonte(carta, false);
              frm_Jogo.ImageCompra.Enabled := false;
              frm_Jogo.BoxJogador.Enabled := false;
              self.EnviaInformacoesByEfeito(Self.jogador.baralhoJogador, carta.ImageIndex, 'EFEITO4;');
              exit
            end;
            break
          end;
        inc(cont);
      end;
      TThread.Queue(nil, procedure
      begin
      ShowMessage('Você não tinha/não quis jogar uma carta +2, então irá comprar mais duas cartas automaticamente!');
      end);
      self.compraCartaEfeito(self.jogador,1);
      exit
  end
end;


function TJogo.VerificaCorCarta(carta: TCarta): Boolean;
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
