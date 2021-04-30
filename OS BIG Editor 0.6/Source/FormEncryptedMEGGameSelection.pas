unit FormEncryptedMEGGameSelection;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Language;

type
   TFrmEncryptedMEGGameSelection = class(TForm)
      LbSelectGameExplanation: TLabel;
      CbGame: TComboBox;
      Bevel1: TBevel;
      BtOK: TButton;
      procedure BtOKClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

implementation

{$R *.dfm}
uses FormBIGMain;

procedure TFrmEncryptedMEGGameSelection.BtOKClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmEncryptedMEGGameSelection.FormCreate(Sender: TObject);
begin
   // Load language here.
   BtOK.Caption := FrmBIGMain.Language.GetString('Common', 'OK');
   Caption := FrmBIGMain.Language.GetString('EncryptedMEG', 'SelectGame');
   LbSelectGameExplanation.Caption := FrmBIGMain.Language.GetString('EncryptedMEG', 'SelectGameExplanation');
end;

end.
