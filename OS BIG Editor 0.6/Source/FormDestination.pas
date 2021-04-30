(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
unit FormDestination;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DirOutln, ComCtrls, ShellCtrls,
  FormNewDirName, FileCtrl;

type
  TFrmDestination = class(TForm)
    BtOK: TButton;
    BtCancel: TButton;
    BtNewDir: TButton;
    Directory: TDirectoryListBox;
    Drive: TDriveComboBox;
    procedure FormShow(Sender: TObject);
    procedure BtNewDirClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

uses
   FormBIGMain;
{$R *.dfm}

procedure TFrmDestination.BtCancelClick(Sender: TObject);
begin
   Changed := false;
   Close;
end;

procedure TFrmDestination.BtOKClick(Sender: TObject);
begin
   if DirectoryExists(Directory.Directory) then
      Changed := true;

   Close;
end;

procedure TFrmDestination.BtNewDirClick(Sender: TObject);
var
   Form : TFrmNewDirName;
begin
   Form := TFrmNewDirName.Create(self);
   Form.MyPath := Directory.Directory;
   Form.ShowModal;
   Form.Release;
   Directory.Update;
end;

procedure TFrmDestination.FormShow(Sender: TObject);
begin
   LoadLanguage;
end;

procedure TFrmDestination.LoadLanguage;
begin
   Caption := FrmBIGMain.Language.GetString('Destination','Destination');
   BtOK.Caption := FrmBIGMain.Language.GetString('Common','OK');
   BtCancel.Caption := FrmBIGMain.Language.GetString('Common','Cancel');
   BTNewDir.Caption := FrmBIGMain.Language.GetString('Common','NewDir');
end;

end.
