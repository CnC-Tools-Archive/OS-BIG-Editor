unit FormDestination;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Outline, DirOutln, ComCtrls, ShellCtrls,
  FormNewDirName;

type
  TFrmDestination = class(TForm)
    BtOK: TButton;
    BtCancel: TButton;
    Directory: TShellTreeView;
    BtNewDir: TButton;
    procedure BtNewDirClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

{$R *.dfm}

procedure TFrmDestination.BtCancelClick(Sender: TObject);
begin
   Changed := false;
   close;
end;

procedure TFrmDestination.BtOKClick(Sender: TObject);
begin
   if DirectoryExists(Directory.SelectedFolder.PathName) then
      Changed := true;
   close;
end;

procedure TFrmDestination.BtNewDirClick(Sender: TObject);
var
   Form : TFrmNewDirName;
begin
   Form := TFrmNewDirName.Create(self);
   Form.MyPath := Directory.SelectedFolder.PathName;
   Form.ShowModal;
   Form.Release;
end;

end.
