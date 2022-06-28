unit uMonteS;

interface

  uses uCartaS, System.Generics.Collections;

type
  TMonteS = class

    private
    FMonte: TList<TCartaS>;

    public

    property Monte : TList<TCartaS> read FMonte write FMonte;

  end;

implementation

{ TMonte }


{ TMonte }

end.
