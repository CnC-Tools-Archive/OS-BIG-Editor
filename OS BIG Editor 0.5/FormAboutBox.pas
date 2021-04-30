unit FormAboutBox;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
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
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAboutBox: TFrmAboutBox;

implementation

{$R *.dfm}
   uses FormBIGMain;


procedure TFrmAboutBox.FormShow(Sender: TObject);
begin
   ProductName.Caption := APPLICATION_NAME;
   Version.Caption := 'Version ' + APPLICATION_VERSION;
   Copyright.Caption := 'Created by ' + APPLICATION_AUTHORS;
   Contributions.Caption := 'Other Contributions: ' + APPLICATION_CONTRIBUTORS;
end;

end.

