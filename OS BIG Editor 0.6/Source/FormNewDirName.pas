(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
unit FormNewDirName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BasicFunctions;

type
  TFrmNewDirName = class(TForm)
    EdDirName: TEdit;
    BtOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  public
    { Public declarations }
    MyPath : string;
  end;


implementation

uses
   FormBIGMain;
{$R *.dfm}

procedure TFrmNewDirName.BtOKClick(Sender: TObject);
begin
   if CompareStr(EdDirName.Text,'') <> 0 then
   begin
      MakeMeADir(MyPath + '\' + EdDirName.Text);
      Close;
   end;
end;

procedure TFrmNewDirName.FormShow(Sender: TObject);
begin
   LoadLanguage;
end;

procedure TFrmNewDirName.LoadLanguage;
begin
   Caption := FrmBIGMain.Language.GetString('NewDirName','NewDirName');
   BtOK.Caption := FrmBIGMain.Language.GetString('Common','OK');
end;

end.
