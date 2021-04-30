(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
unit FormAboutBox;

interface

uses
   Graphics, Classes, Forms, Controls, StdCtrls, Buttons, ExtCtrls;

type
   AboutStringTypes = (astAbout,astVersion,astCreatedBy,astMajorContribution,astOtherContributions,astDragAndDrop,astTARGA,astTranslatedBy,lstTranslator,astMinev,astVanLoon,astIgi,astPrabab,astJonwil,astCRC,astPNG,astAES,cstOK);

   TFrmAboutBox = class(TForm)
      Panel1: TPanel;
      OKButton: TButton;
      ProgramIcon: TImage;
      ProductName: TLabel;
      Version: TLabel;
      Copyright: TLabel;
      Comments: TLabel;
      Contributions: TLabel;
      DragAndDrop: TLabel;
    TARGA: TLabel;
    MajorContributors: TLabel;
    TranslatedBy: TLabel;
    CRC32: TLabel;
    PNG: TLabel;
    AES: TLabel;
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
      // Private Variables
      MyLanguage : array[AboutStringTypes] of string;
      // Language functions
      procedure LoadLanguage;
   public
      { Public declarations }
   end;

implementation

{$R *.dfm}
uses
  FormBIGMain;


procedure TFrmAboutBox.FormShow(Sender: TObject);
begin
  LoadLanguage;
  Caption := MyLanguage[astAbout];
  ProductName.Caption := APPLICATION_NAME;
  Version.Caption := MyLanguage[astVersion] + ' ' + APPLICATION_VERSION;
  Copyright.Caption := MyLanguage[astCreatedBy] + ' ' + APPLICATION_AUTHORS;
  MajorContributors.Caption := MyLanguage[astMajorContribution] + ': Danny Van Loon (' + MyLanguage[astVanLoon] + ') and Igi (' + MyLanguage[astIgi] + ').';
  Contributions.Caption := MyLanguage[astOtherContributions] + ': Zlatko Minev (' + MyLanguage[astMinev] + ') and Prabab (' + MyLanguage[astPrabab] + ').';
  Comments.Caption := MyLanguage[astJonwil];
  DragAndDrop.Caption := MyLanguage[astDragAndDrop];
  TARGA.Caption := MyLanguage[astTARGA];
  CRC32.Caption := MyLanguage[astCRC];
  PNG.Caption := MyLanguage[astPNG];
  AES.Caption := MyLanguage[astAES];
  TranslatedBy.Caption := MyLanguage[astTranslatedBy] + ' ' + MyLanguage[lstTranslator];
end;

procedure TFrmAboutBox.LoadLanguage;
begin
   MyLanguage[astAbout] := FrmBIGMain.Language.GetString('About','About');
   MyLanguage[astVersion] := FrmBIGMain.Language.GetString('About','Version');
   MyLanguage[astCreatedBy] := FrmBIGMain.Language.GetString('About','CreatedBy');
   MyLanguage[astMajorContribution] := FrmBIGMain.Language.GetString('About','MajorContribution');
   MyLanguage[astOtherContributions] := FrmBIGMain.Language.GetString('About','OtherContributions');
   MyLanguage[astDragAndDrop] := FrmBIGMain.Language.GetString('About','DragAndDrop');
   MyLanguage[astTARGA] := FrmBIGMain.Language.GetString('About','TARGA');
   MyLanguage[astTranslatedBy] := FrmBIGMain.Language.GetString('About','TranslatedBy');
   MyLanguage[lstTranslator] := FrmBIGMain.Language.GetString('Language','Translator');
   MyLanguage[astMinev] := FrmBIGMain.Language.GetString('About','MinevAchievements');
   MyLanguage[astVanLoon] := FrmBIGMain.Language.GetString('About','VanLoonAchievements');
   MyLanguage[astIgi] := FrmBIGMain.Language.GetString('About','IgiAchievements');
   MyLanguage[astPrabab] := FrmBIGMain.Language.GetString('About','PrababAchievements');
   MyLanguage[astJonwil] := FrmBIGMain.Language.GetString('About','RefPackDecompressionByJonwil');
   MyLanguage[astCRC] := FrmBIGMain.Language.GetString('About','CRC32GenerationByOlaf');
   MyLanguage[astPNG] := FrmBIGMain.Language.GetString('About','PNGImageByGustavo');
   MyLanguage[astAES] := FrmBIGMain.Language.GetString('About','AdvancedEncryptionStandard');
   MyLanguage[cstOK] := FrmBIGMain.Language.GetString('Common','OK');
end;

end.

