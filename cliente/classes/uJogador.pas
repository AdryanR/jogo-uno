unit uJogador;

interface

uses uCarta, System.Generics.Collections;

type
  TJogador = class

    private

    Fnome: String;
    FbaralhoJogador: TList<TCarta>;
    Fbot: boolean;

    public

    property nome : String read Fnome write Fnome;
    property baralhoJogador : TList<TCarta> read FbaralhoJogador write FbaralhoJogador;
    property bot : boolean read Fbot write Fbot;

  end;

implementation

{ TJogador }

{ TJogador }


end.
