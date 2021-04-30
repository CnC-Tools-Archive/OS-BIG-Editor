program bigeditor;

uses
  Forms,
  FormBIGMain in 'FormBIGMain.PAS' {FrmBIGMain},
  FormAboutBox in 'FormAboutBox.pas' {FrmAboutBox},
  BIG_File in 'BIG_File.pas',
  BasicDataTypes in 'BasicDataTypes.pas',
  FormDestination in 'FormDestination.pas' {FrmDestination},
  FormNewDirName in 'FormNewDirName.pas' {FrmNewDirName},
  BasicFunctions in 'BasicFunctions.pas',
  DropTarget in 'DragDrop\DropTarget.pas',
  DragDrop in 'DragDrop\DragDrop.pas',
  DragDropFormats in 'DragDrop\DragDropFormats.pas',
  DropSource in 'DragDrop\DropSource.pas',
  TARGA in 'TARGA.PAS',
  Manifest_File in 'Manifest_File.pas',
  FormOptions in 'FormOptions.pas' {FrmOptions},
  BasicOptions in 'BasicOptions.pas',
  language in 'language.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'OS Big Editor';
  Application.CreateForm(TFrmBIGMain, FrmBIGMain);
  Application.CreateForm(TFrmAboutBox, FrmAboutBox);
  Application.Run;
end.
 
