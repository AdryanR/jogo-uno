unit uMonte;

interface

  uses uCarta, System.Generics.Collections;

type
  TMonte = class

    private
    FMonte: TList<TCarta>;

    public

    property Monte : TList<TCarta> read FMonte write FMonte;

  end;

implementation

{ TMonte }


{ TMonte }

end.
