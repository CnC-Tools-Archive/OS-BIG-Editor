unit FormBinaryWarning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, BasicDataTypes, BasicOptions, BasicConstants;

type
  TFrmBinaryWarning = class(TForm)
    LbLagWarning: TLabel;
    Bevel1: TBevel;
    BtLoadAll: TButton;
    BtLoadLimit: TButton;
    BtDontLoad: TButton;
    CbDontAsk: TCheckBox;
    procedure BtLoadAllClick(Sender: TObject);
    procedure BtLoadLimitClick(Sender: TObject);
    procedure BtDontLoadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SaveOptionAndClose;
  public
    { Public declarations }
    Answer : int8;
    procedure LoadLanguage(_Size : uint32);
  end;

implementation

{$R *.dfm}
uses FormBIGMain;


procedure TFrmBinaryWarning.FormCreate(Sender: TObject);
begin
   Answer := FrmBIGMain.Options.OptDefBinDecision;
end;

procedure TFrmBinaryWarning.BtDontLoadClick(Sender: TObject);
begin
   Answer := C_FBW_DONT;
   SaveOptionAndClose;
end;

procedure TFrmBinaryWarning.BtLoadAllClick(Sender: TObject);
begin
   Answer := C_FBW_LALL;
   SaveOptionAndClose;
end;

procedure TFrmBinaryWarning.BtLoadLimitClick(Sender: TObject);
begin
   Answer := C_FBW_LLIMIT;
   SaveOptionAndClose;
end;

procedure TFrmBinaryWarning.LoadLanguage(_Size : uint32);
var
   MyMBSize : real;
begin
   MyMBSize := _Size / 1048576;
   Caption := FrmBIGMain.Language.GetString('Binary','WannaLoadThisBinary');
   LbLagWarning.Caption := FrmBIGMain.Language.GetString('Binary','FileWillLag1') + ' ' + IntToStr(_Size) + ' ' + FrmBIGMain.Language.GetString('Binary','FileWillLag2') + ' ' + FloatToStr(MyMBSize) + ' ' + FrmBIGMain.Language.GetString('Binary','FileWillLag3') + ' ' + IntToStr(FrmBIGMain.Options.OptMaxBinarySize) + ' ' + FrmBIGMain.Language.GetString('Binary','FileWillLag4');
   CBDontAsk.Caption := FrmBIGMain.Language.GetString('Common','DontAskMeAgain');
   BtLoadAll.Caption := FrmBIGMain.Language.GetString('Binary','LoadTheWholeFile');
   BtLoadLimit.Caption := FrmBIGMain.Language.GetString('Binary','LoadOnlyTheLimitedSize');
   BtDontLoad.Caption := FrmBIGMain.Language.GetString('Binary','DontLoadIt');
end;

procedure TFrmBinaryWarning.SaveOptionAndClose;
begin
   if CBDontAsk.Checked then
   begin
      FrmBIGMain.Options.OptDefBinDecision := Answer;
   end;
   close;
end;

end.
