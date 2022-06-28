program JogoUnoCLIENT;






{$R *.dres}

uses
  Vcl.Forms,
  Windows,
  Sysutils,
  classes,
  formPrincipal in '..\forms\formPrincipal.pas' {frm_Jogo},
  uCarta in '..\classes\uCarta.pas',
  uJogador in '..\classes\uJogador.pas',
  uBaralho in '..\classes\uBaralho.pas',
  uMonte in '..\classes\uMonte.pas',
  uJogo in '..\classes\uJogo.pas',
  FormEscolheCor in '..\forms\FormEscolheCor.pas' {frmEscolheCor},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}
{$R JogoUnoResource.RES}



begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Green');
  Application.Title := 'Jogo Uninho diz:';
  Application.CreateForm(Tfrm_Jogo, frm_Jogo);
  Application.CreateForm(TfrmEscolheCor, frmEscolheCor);
  Application.Run;
end.
