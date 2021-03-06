unit uBaralho;

interface

  uses uCarta, System.Classes, System.SysUtils, Windows, Vcl.Forms, System.Generics.Collections,
  FMX.Dialogs;

type
  TBaralho = class

    private

    Fbaralho: TList<TCarta>;
    FbaralhoGeral: TList<TCarta>;

    public

    property baralho : TList<TCarta> read Fbaralho write Fbaralho;
    property baralhoGeral : TList<TCarta> read FbaralhoGeral write FbaralhoGeral;

    procedure DefineCartaByNome;

    //procedure DistribuiCartas(msgFromServer : string);

  end;


  var
    ResourcesList: TStringList;

implementation

uses
  formPrincipal;

{ TBaralho }


function EnumRCDataProc(hModule: HMODULE; lpszType, lpszName: PChar; lParam: NativeInt): BOOL; stdcall;
begin
  TStrings(lParam).Add(lpszName);
  Result := True;
end;


function EnumerateResourceNames: string;
var
  ExecutableHandle: HMODULE;
begin
  ExecutableHandle := LoadLibrary(PChar(Application.ExeName));
  try
    ResourcesList := TStringList.Create;
    try
      EnumResourceNames(ExecutableHandle, RT_RCDATA, @EnumRCDataProc, NativeInt(ResourcesList));
      Result := ResourcesList.Text;
    finally
    end;
  finally
  end;
end;

procedure TBaralho.DefineCartaByNome;
var
  loop:integer;
  carta: TCarta;
  ArrayStr: TArray<String>;
  num:integer;
  name:String;
begin

  EnumerateResourceNames;

  baralho := TList<TCarta>.Create; // baralho do jogo

  baralhoGeral := TList<TCarta>.Create;  // baralho geral, para obter as cartas jogadas pelo player 2;

  for Loop := 0 to pred(ResourcesList.Count) do
  begin

    ArrayStr :=  ResourcesList[Loop].Split(['_']);
    if (ArrayStr[0] = 'F') or (TryStrToInt(ArrayStr[0],num)) then
    begin
      carta := TCarta.Create;
      if (ArrayStr[0] = 'F') then
      begin
        carta.efeito := true;
        carta.tipoEfeito := ArrayStr[1];
      end;
      name:= ResourcesList[Loop];
      carta.ImageIndex := name;

      if (ArrayStr[0] = 'F') then
      begin
        carta.cor := ArrayStr[2];
        if (carta.tipoEfeito = '4') then
        begin
          carta.num := 999;
        end;
      end
      else
      begin
        carta.num := StrToInt(ArrayStr[0]);
        carta.cor := ArrayStr[1];
      end;
      baralho.Add(carta);
      baralhoGeral.Add(carta);
    end;

  end;


end;


end.
