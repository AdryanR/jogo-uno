program JogoUnoSERVER;






{$R *.dres}

uses
  Vcl.Forms,
  Windows,
  Sysutils,
  classes,
  FormPServer in '..\forms\FormPServer.pas' {frmJogoServer},
  uCartaS in '..\classes\uCartaS.pas',
  uJogadorS in '..\classes\uJogadorS.pas',
  uBaralhoS in '..\classes\uBaralhoS.pas',
  uMonteS in '..\classes\uMonteS.pas',
  uJogoS in '..\classes\uJogoS.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}
{$R JogoUnoResource.RES}



begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Green');
  Application.Title := 'Jogo Uninho diz:';
  Application.CreateForm(TfrmJogoServer, frmJogoServer);
  Application.Run;
end.
