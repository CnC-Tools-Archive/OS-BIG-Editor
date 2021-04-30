(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
program bigeditor;

uses
  Forms,
  FormAboutBox in '..\FormAboutBox.pas' {FrmAboutBox},
  BIG_File in '..\BIG_File.pas',
  BasicDataTypes in '..\BasicDataTypes.pas',
  FormDestination in '..\FormDestination.pas' {FrmDestination},
  FormNewDirName in '..\FormNewDirName.pas' {FrmNewDirName},
  BasicFunctions in '..\BasicFunctions.pas',
  DropTarget in '..\DragDrop\DropTarget.pas',
  DragDrop in '..\DragDrop\DragDrop.pas',
  DragDropFormats in '..\DragDrop\DragDropFormats.pas',
  DropSource in '..\DragDrop\DropSource.pas',
  TARGA in '..\TARGA.PAS',
  Manifest_File in '..\Manifest_File.pas',
  FormOptions in '..\FormOptions.pas' {FrmOptions},
  BasicOptions in '..\BasicOptions.pas',
  Language in '..\Language.pas',
  uIconHelper in '..\uIconHelper.pas',
  uTools in '..\uTools.pas',
  RefPackFunctions in '..\RefPackFunctions.pas',
  FormBIGMain in '..\FormBIGMain.PAS' {FrmBIGMain},
  uCRC32 in '..\uCRC32.pas',
  uFileViewer in '..\uFileViewer.pas',
  pngimage in '..\pngimage.pas',
  pnglang in '..\pnglang.pas',
  pngzlib in '..\pngzlib.pas',
  FormBinaryWarning in '..\FormBinaryWarning.pas' {FrmBinaryWarning},
  uSelectedNodes in '..\uSelectedNodes.pas',
  uTempFileManager in '..\uTempFileManager.pas',
  uRealTimeEditionManager in '..\uRealTimeEditionManager.pas',
  uBIGRTEManager in '..\uBIGRTEManager.pas',
  BasicConstants in '..\BasicConstants.pas',
  MIX_File in '..\MIX_File.pas',
  Blowfish_WS_Key in '..\Blowfish_WS_Key.pas',
  ElAES in '..\ElAES.pas',
  MEG_AES_Constants in '..\MEG_AES_Constants.pas',
  FormEncryptedMEGGameSelection in '..\FormEncryptedMEGGameSelection.pas' {FrmEncryptedMEGGameSelection};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'OS BIG Editor';
  Application.CreateForm(TFrmBIGMain, FrmBIGMain);
  Application.Run;
end.
                                                                              
