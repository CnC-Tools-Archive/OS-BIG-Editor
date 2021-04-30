unit FormOptions;

// This option form was imported and modified from Voxel Section Editor III
// by Banshee. This means that this part of the program also has some
// remaining codes from Stucuk.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Registry, BasicOptions;

const
   SYSTEM_NO_ADMIN_RIGHTS = 'OS BIG Editor was not able to associate .big files because you are under a non-administrative account or does not have enough rights to do it. Contact the system administrator if you need any help';

type
  TFrmOptions = class(TForm)
    GpbRightSide: TGroupBox;
    Pref_List: TTreeView;
    PageControl: TPageControl;
    FileAssociationTab: TTabSheet;
    AssociateCheck: TCheckBox;
    GpbIconSelect: TGroupBox;
    IconPrev: TImage;
    IconID: TTrackBar;
    BtnApply: TButton;
    BevelTop: TBevel;
    TopPanel: TPanel;
    OptionsImage: TImage;
    LblOptionsDescription: TLabel;
    LblOptionsTitle: TLabel;
    BevelBottom: TBevel;
    BottomPanel: TPanel;
    BtOK: TButton;
    BtCancel: TButton;
    IconList: TImageList;
    procedure BtCancelClick(Sender: TObject);
    // Constructors Destructors
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    // Interface events
    procedure BtnApplyClick(Sender: TObject);
    procedure IconIDChange(Sender: TObject);
    procedure Pref_ListClick(Sender: TObject);
    procedure Pref_ListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Pref_ListKeyPress(Sender: TObject; var Key: Char);
    procedure Pref_ListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IconPath: String;
    // Gets
    procedure GetSettings;
    // Misc
    procedure ExtractIcon;
  end;

implementation

{$R *.dfm}
uses FormBIGMain;

// Constructors and Destructors
procedure TFrmOptions.FormCreate(Sender: TObject);
begin
   TopPanel.DoubleBuffered := true;
end;

procedure TFrmOptions.FormShow(Sender: TObject);
begin
   GetSettings;
   PageControl.ActivePageIndex := 0;
   GpbRightSide.Caption := 'File Associations';
end;

// Gets
procedure TFrmOptions.GetSettings;
var
   Reg: TRegistry;
   MyData : string;
begin
   // Let's get the icon.
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   if Reg.OpenKey('\BIGEd\DefaultIcon\',false) then
   begin
      MyData := Reg.ReadString('');
      if Length(MyData) > 11 then
      begin
         IconID.Position := StrToIntDef(MyData[Length(MyData)-4],0);
      end;
   end
   else
   begin
      // Default Icon:
      IconID.Position := 0;
   end;
   IconIDChange(Self);
   // Let's find out if the program is associated or not.
   Reg.CloseKey;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   if Reg.OpenKey('\.big\',false) then
   begin
      MyData := Reg.ReadString('');
      Reg.CloseKey;
      if CompareStr(MyData,'BIGEd') = 0 then
      begin
         AssociateCheck.Checked := true;
      end
      else
      begin
         AssociateCheck.Checked := false;
         FrmBIGMain.Options.OldBIGRegSettings := MyData;
         Reg.RootKey := HKEY_CURRENT_USER;
         if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.big\',false) then
         begin
            MyData := Reg.ReadString('Application');
            Reg.CloseKey;
            FrmBIGMain.Options.OldBIGExplorerRegSettings := MyData;
         end
      end;
   end
   else
   begin
      AssociateCheck.Checked := false;
   end;
end;

// Miscelaneous
procedure TFrmOptions.ExtractIcon;
var
   sWinDir: String;
   iLength: Integer;
   {Res: TResourceStream; }
   MIcon: TIcon;
begin
   // Initialize Variable
   iLength := 255;
   setLength(sWinDir, iLength);
   iLength := GetWindowsDirectory(PChar(sWinDir), iLength);
   setLength(sWinDir, iLength);
   IconPath := sWinDir + '\osbiged'+inttostr(IconID.Position)+'.ico';

   MIcon := TIcon.Create;
   IconList.GetIcon(IconID.Position,MIcon);
   MIcon.SaveToFile(IconPath);
   MIcon.Free;
end;

// Interface Events
procedure TFrmOptions.BtnApplyClick(Sender: TObject);
var
  Reg: TRegistry;
begin
   ExtractIcon;
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;

   if Reg.OpenKey('\BIGEd\DefaultIcon\',true) then
   begin
      Reg.WriteString('',IconPath);
      Reg.CloseKey;
   end;

   if AssociateCheck.Checked = true then
   begin
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('\.big\',true) then
      begin
         Reg.WriteString('','BIGEd');
         Reg.CloseKey;
         Reg.RootKey := HKEY_CLASSES_ROOT;
         if Reg.OpenKey('\BIGEd\shell\',true) then
         begin
            Reg.WriteString('','Open');
            if Reg.OpenKey('\BIGEd\shell\open\command\',true) then
            begin
               Reg.WriteString('',ParamStr(0)+' %1');
            end;
            Reg.CloseKey;
            Reg.RootKey := HKEY_CURRENT_USER;
            if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.big\',true) then
            begin
               Reg.WriteString('Application',ParamStr(0)+' "%1"');
               Reg.CloseKey;
            end
            else
            begin
               ShowMessage(SYSTEM_NO_ADMIN_RIGHTS);
            end;
         end
         else
         begin
            ShowMessage(SYSTEM_NO_ADMIN_RIGHTS);
            close;
         end;
      end
      else
      begin
         ShowMessage(SYSTEM_NO_ADMIN_RIGHTS);
         close;
      end;
   end
   else
   begin
      Reg.RootKey := HKEY_CLASSES_ROOT;
      If Length(FrmBIGMain.Options.OldBIGRegSettings) > 0 then
      begin
         if Reg.OpenKey('\.big\',true) then
         begin
            Reg.WriteString('',FrmBIGMain.Options.OldBIGRegSettings);
            FrmBIGMain.Options.OldBIGRegSettings := '';
         end;
      end
      else
      begin
         Reg.DeleteKey('\.big\');
      end;
      Reg.CloseKey;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      Reg.DeleteKey('\BIGEd\');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CURRENT_USER;
      If Length(FrmBIGMain.Options.OldBIGExplorerRegSettings) > 0 then
      begin
         if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.big\',true) then
         begin
            Reg.WriteString('Application',FrmBIGMain.Options.OldBIGExplorerRegSettings);
            FrmBIGMain.Options.OldBIGExplorerRegSettings := '';
         end
      end
      else
      begin
         Reg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.big\');
      end;
      Reg.CloseKey;
   end;
   Reg.Free;
   FrmBIGMain.Options.Save;
end;

procedure TFrmOptions.IconIDChange(Sender: TObject);
var
   MIcon: TIcon;
begin
   MIcon := TIcon.Create;
   IconList.GetIcon(IconID.Position,MIcon);
   IconPrev.Picture.Icon := MIcon;
   MIcon.Free;
end;

procedure TFrmOptions.Pref_ListClick(Sender: TObject);
begin
   if pref_list.SelectionCount > 0 then
   begin
      if pref_list.Selected.Text = 'File Associations' then
         PageControl.ActivePageIndex := 0;
      GpbRightSide.Caption := pref_list.Selected.Text;
   end;
end;

procedure TFrmOptions.Pref_ListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmOptions.Pref_ListKeyPress(Sender: TObject;
  var Key: Char);
begin
   Pref_ListClick(sender);
end;

procedure TFrmOptions.Pref_ListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmOptions.BtOKClick(Sender: TObject);
begin
   BtnApplyClick(Sender);
   Close;
end;

procedure TFrmOptions.BtCancelClick(Sender: TObject);
begin
   Close;
end;

end.
