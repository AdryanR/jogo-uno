unit FormEscolheCor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls,
  Vcl.Imaging.pngimage;

type
  TfrmEscolheCor = class(TForm)
    vermelho: TImage;
    azul: TImage;
    verde: TImage;
    amarelo: TImage;
    procedure AMARELOClick(Sender: TObject);
    procedure VERDEClick(Sender: TObject);
    procedure VERMELHOClick(Sender: TObject);
    procedure AZULClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    cor: String;
  end;

var
  frmEscolheCor: TfrmEscolheCor;

implementation

{$R *.dfm}

procedure TfrmEscolheCor.AMARELOClick(Sender: TObject);
begin
    cor:= 'AMARELO';
    Close;
end;

procedure TfrmEscolheCor.AZULClick(Sender: TObject);
begin
  cor:= 'AZUL';
  Close;
end;

procedure TfrmEscolheCor.VERDEClick(Sender: TObject);
begin
    cor:= 'VERDE';
    Close;
end;

procedure TfrmEscolheCor.VERMELHOClick(Sender: TObject);
begin
    cor:= 'VERMELHO';
    Close;
end;

end.
