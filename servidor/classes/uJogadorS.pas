unit uJogadorS;

interface

uses uCartaS, System.Generics.Collections;

type
  TJogadorS = class

    private

    Fnome: String;
    FbaralhoJogador: TList<TCartaS>;
    Fbot: boolean;

    public

    property nome : String read Fnome write Fnome;
    property baralhoJogador : TList<TCartaS> read FbaralhoJogador write FbaralhoJogador;
    property bot : boolean read Fbot write Fbot;

  end;

implementation

{ TJogador }

{ TJogador }


end.
