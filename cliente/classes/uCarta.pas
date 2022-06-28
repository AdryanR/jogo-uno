unit uCarta;

interface

  uses System.Classes, System.SysUtils, Windows, Vcl.Forms;

type
  TCarta = class

    private



    Fcor: String;
    FtipoEfeito: String;
    Fnum: integer;
    Fefeito: boolean;
    FImageIndex: String;


    public

    property cor : String read Fcor write Fcor;
    property num : integer read Fnum write Fnum;
    property efeito : boolean read Fefeito write Fefeito;
    property tipoEfeito : String read FtipoEfeito write FtipoEfeito;
    property ImageIndex : String read FImageIndex write FImageIndex;

  end;

implementation

{ TCarta }



end.
