unit FormNewDirName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BasicFunctions;

type
  TFrmNewDirName = class(TForm)
    EdDirName: TEdit;
    BtOK: TButton;
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MyPath : string;
  end;


implementation

{$R *.dfm}

procedure TFrmNewDirName.BtOKClick(Sender: TObject);
begin
   if CompareStr(EdDirName.Text,'') <> 0 then
   begin
      MakeMeADir(MyPath + '\' + EdDirName.Text);
      close;
   end;
end;

end.
