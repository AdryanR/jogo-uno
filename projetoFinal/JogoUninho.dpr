program JogoUninho;

{$R *.dres}

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  frm_Lobby in '..\forms\frm_Lobby.pas' {frm_Espera},
  FormEscolheCor in '..\forms\FormEscolheCor.pas' {frmEscolheCor},
  FormPServer in '..\servidor\forms\FormPServer.pas' {frmJogoServer},
  uBaralhoS in '..\servidor\classes\uBaralhoS.pas',
  uCartaS in '..\servidor\classes\uCartaS.pas',
  uJogadorS in '..\servidor\classes\uJogadorS.pas',
  uJogoS in '..\servidor\classes\uJogoS.pas',
  uMonteS in '..\servidor\classes\uMonteS.pas',
  formPrincipal in '..\cliente\forms\formPrincipal.pas' {frm_Jogo},
  uBaralho in '..\cliente\classes\uBaralho.pas',
  uCarta in '..\cliente\classes\uCarta.pas',
  uJogador in '..\cliente\classes\uJogador.pas',
  uJogo in '..\cliente\classes\uJogo.pas',
  uMonte in '..\cliente\classes\uMonte.pas',
  frm_cadastro in '..\forms\frm_cadastro.pas' {form_cadastro},
  frm_login in '..\forms\frm_login.pas' {form_login},
  dm in '..\dao\dm.pas' {dmDados: TDataModule},
  frm_ranking in '..\forms\frm_ranking.pas' {form_ranking};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Green');
  Application.CreateForm(Tfrm_Espera, frm_Espera);
  Application.CreateForm(TfrmEscolheCor, frmEscolheCor);
  Application.CreateForm(TdmDados, dmDados);
  Application.CreateForm(Tform_ranking, form_ranking);
  Application.Run;
end.
