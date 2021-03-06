unit uBaralhoS;

interface

  uses uCartaS, System.Classes, System.SysUtils, Windows, Vcl.Forms, System.Generics.Collections, IdContext,
  FMX.Dialogs;

type
  TBaralhoS = class

    private

    Fbaralho: TList<TCartaS>;
    FbaralhoGeral: TList<TCartaS>;

    public

    property baralho : TList<TCartaS> read Fbaralho write Fbaralho;
    property baralhoGeral : TList<TCartaS> read FbaralhoGeral write FbaralhoGeral;

    procedure DefineCartaByNome;

    procedure DistribuiCartas;

  end;

   TMachinInfoRec = record
      cartas : TList<TCartaS>;
    end;


  var
    ResourcesList: TStringList;

implementation

uses
  FormPServer;

{ TBaralhoS }


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

procedure TBaralhoS.DefineCartaByNome;
var
  loop:integer;
  carta: TCartaS;
  ArrayStr: TArray<String>;
  num:integer;
  name:String;
begin

  EnumerateResourceNames;

  baralho := TList<TCartaS>.Create;

  baralhoGeral := TList<TCartaS>.Create;  // baralho geral, para obter as cartas jogadas pelo player 2;

  for Loop := 0 to pred(ResourcesList.Count) do
  begin

    ArrayStr :=  ResourcesList[Loop].Split(['_']);
    if (ArrayStr[0] = 'F') or (TryStrToInt(ArrayStr[0],num)) then
    begin
      carta := TCartaS.Create;
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
  self.DistribuiCartas;

end;


procedure TBaralhoS.DistribuiCartas;
var
tmpList      : TList;
contexClient : TidContext;
nClients     : Integer;
i            : integer;
msRecInfo: TMemoryStream;
MIRec: TMachinInfoRec;
begin
  MIRec.cartas := baralho;
  msRecInfo := TMemoryStream.Create;
  msRecInfo.Write(MIRec, SizeOf(MIRec));

  tmpList  := frmJogoServer.Server.Contexts.LockList;
  try
      i := 0;
      while ( i < tmpList.Count ) do begin
          // ... get context (thread of i-client)
          contexClient := tmpList[i];

          // ... send message to client
            msRecInfo.Position := 0;
          contexClient.Connection.IOHandler.Write(msRecInfo);
          i := i + 1;
      end;

  finally
      // ... unlock list of clients!
      frmJogoServer.Server.Contexts.UnlockList;
  end;

end;
end.
