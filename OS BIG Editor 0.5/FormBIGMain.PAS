unit FormBIGMain;

interface

uses Windows, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, BasicDataTypes, BIG_File, FormDestination, SysUtils,
  BasicFunctions, DragDrop, DragDropFormats, DropSource, ActiveX,
  BasicOptions, FormOptions, ShellAPI, Messages;

const
   APPLICATION_NAME = 'OS BIG Editor';
   APPLICATION_VERSION = '0.5 Beta';
   APPLICATION_AUTHORS = 'Banshee';
   APPLICATION_CONTRIBUTORS = 'Zlatko Minev (for coding the TGA Viewer) and Danny van Loon (helping with Drag and Drop)';

type
  TFrmBIGMain = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    TbFileNew: TToolButton;
    ToolButton1: TToolButton;
    TbFileSave: TToolButton;
    ToolButton3: TToolButton;
    TbEditCut: TToolButton;
    TbEditCopy: TToolButton;
    TbEditPaste: TToolButton;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    N2: TMenuItem;
    ExtractItem: TMenuItem;
    ExtractAllItem: TMenuItem;
    LbFiles: TListBox;
    SpContent: TSplitter;
    MmFileContent: TMemo;
    EditExtract: TAction;
    EditExtractAll: TAction;
    Options1: TMenuItem;
    WordWrapItem: TMenuItem;
    ImageTGA: TImage;
    OptionsCutImagePreview: TAction;
    CutImagePreviewItem: TMenuItem;
    OptionsWordWrap: TAction;
    OptionsSaveFullDir: TAction;
    SaveFullDirItem: TMenuItem;
    OptionsPreferences: TAction;
    PreferencesItem: TMenuItem;
    N3: TMenuItem;
    Contents1: TMenuItem;
    SupportForums1: TMenuItem;
    GetUpdates1: TMenuItem;
    N4: TMenuItem;
    procedure OptionsPreferencesExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OptionsSaveFullDirExecute(Sender: TObject);
    procedure OptionsWordWrapExecute(Sender: TObject);
    procedure OptionsCutImagePreviewExecute(Sender: TObject);
    procedure LbFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditExtractAllExecute(Sender: TObject);
    procedure EditExtractExecute(Sender: TObject);
    // Constructors and Destructors.
    procedure FormCreate(Sender: TObject);
    // I/O
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    // Gets
    // Sets
    procedure SetIsEditable(Value : Boolean);
    procedure SetOptPreviewImages(Value : Boolean);
    procedure SetOptWordWrap(Value : Boolean);
    procedure SetOptSaveFullDir(Value : Boolean);
    // Interface Events
    procedure SpContentMoved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LbFilesClick(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    // Help
    procedure HelpAbout1Execute(Sender: TObject);
    procedure GetUpdates1Click(Sender: TObject);
    procedure SupportForums1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    // Drag and Drop Aditional Support
    procedure DropEmptySource1AfterDrop(Sender: TObject; DragResult: TDragResult; Optimized: Boolean);
  private
    { Private declarations }
    IsEditable : Boolean;
    // Drag and Drop support.
    DropEmptySource: TDropEmptySource;
    DataFormatAdapter: TDataFormatAdapter;
    DropIDs : array of uint32;
    // I/O
    procedure LoadBIGFile(const _Filename : string);
    // Gets
    Function GetParamStr : String;
    // Misc
    procedure OpenHyperlink(HyperLink: PChar);
    // Drag and Drop Aditional procedures
    procedure OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat;	Index: integer; out AStream: IStream);
    procedure AcceptFiles( var msg : TMessage );  message WM_DROPFILES;   //drag-droppage 05-03-07
  public
    { Public declarations }
    CurrentFile : TBIGPackage;
    // OptionVariables.
    Options : TOptions;
  end;

var
  FrmBIGMain: TFrmBIGMain;

implementation

uses FormAboutBox, TARGA;

{$R *.dfm}

// Constructors and Destructors.
procedure TFrmBIGMain.FormCreate(Sender: TObject);
var
   MyParameter : string;
begin
   CurrentFile := TBIGPackage.Create;
   Caption := APPLICATION_NAME + ' ' + APPLICATION_VERSION;
   SetIsEditable(false);
   StatusBar.Panels.Add;
   // 0.5: Set Basic Options.
   Options := TOptions.Create(ExtractFileDir(ParamStr(0)) + '/options.opt');
   SetOptPreviewImages(Options.OptPreviewImages);
   SetOptWordWrap(Options.OptWordWrap);
   SetOptSaveFullDir(Options.OptSaveFullDir);

   // 0.5 Drag and Drop extraction support.
   // Using the:
   // -----------------------------------------
   // Drag and Drop Component Suite Version 4.0
   // Released 18-may-2001
   // © 1997-2001 Angus Johnson & Anders Melander
   // -----------------------------------------
   DataFormatAdapter    := TDataFormatAdapter.Create(self);
   DropEmptySource      := TDropEmptySource.Create(self);
	DataFormatAdapter.DragDropComponent := DropEmptySource;
	DataFormatAdapter.DataFormatName := 'TVirtualFileStreamDataFormat';

   DataFormatAdapter.Enabled := true;
   DropEmptySource.OnAfterDrop := DropEmptySource1AfterDrop;
	(DataFormatAdapter.DataFormat as TVirtualFileStreamDataFormat).OnGetStream := OnGetStream;
   // Drag and Drop Creation support ends here.

   // Quick load file through parameter;
   if ParamCount > 0 then
   begin
      MyParameter := GetParamStr;
      If FileExists(MyParameter) then
      Begin
         LoadBIGFile(MyParameter);
      end;
   End;

   // Dann Van Loon code for drag and drop goes here
   DragAcceptFiles( Handle, True ); 	//drag-droppage 05-03-07
end;

procedure TFrmBIGMain.FormDestroy(Sender: TObject);
begin
   Options.Free;
end;

// I/O
procedure TFrmBIGMain.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;

procedure TFrmBIGMain.LoadBIGFile(const _Filename : string);
var
   I : uint32;
   iFile : TBIGFileUnit;
begin
   if FileExists(_FileName) then
   begin
      SetIsEditable(false);
      LbFiles.Clear;
      MmFileContent.Clear;
      Options.OpenDirectory := ExtractFileDir(_FileName);
      CurrentFile.LoadFile(_FileName);
      if CurrentFile.IsValid then
      begin
         for I := 0 to (CurrentFile.GetNumFiles-1) do
         begin
            iFile := CurrentFile.GetFileInfo(i);
            LbFiles.Items.Add(iFile.Filename);
         end;
         lbFiles.ItemIndex := 0;
         LbFilesClick(nil);
         SetIsEditable(true);
      end
      else
         MessageDlg('Not a Valid BIG file',mtWarning,[mbOk],0); //drag-droppage 05-03-07
   end;
end;

procedure TFrmBIGMain.FileOpen1Execute(Sender: TObject);
begin
   if DirectoryExists(Options.OpenDirectory) then
      OpenDialog.InitialDir := Options.OpenDirectory;
   if OpenDialog.Execute then
   begin
      LoadBIGFile(OpenDialog.FileName);
   end;
end;

procedure TFrmBIGMain.FileSave1Execute(Sender: TObject);
begin
   SaveDialog.Execute;
end;

// Gets

// Ripped from Voxel Section Editor III 1.36 and all other OS Tools.
// Probably originally writen by Stucuk for OS SHP Builder.
Function TFrmBIGMain.GetParamStr : String;
var
   x : integer;
begin
   Result := '';
   for x := 1 to ParamCount do
      if Result <> '' then
         Result := Result + ' ' + ParamStr(x)
      else
         Result := ParamStr(x);
end;


// Sets
procedure TFrmBIGMain.SetIsEditable(Value : Boolean);
begin
   IsEditable := Value;
   FileNewItem.Enabled := false;
   TbFileNew.Enabled := false;
   FileSaveItem.Enabled := Value;
   FileSaveAsItem.Enabled := Value;
   TbFileSave.Enabled := Value;
   TbEditPaste.Enabled := false;
   PasteItem.Enabled := false;
   TbEditCopy.Enabled := false;
   CopyItem.Enabled := false;
   TbEditCut.Enabled := false;
   CutItem.Enabled := false;
   ExtractItem.Enabled := Value;
   ExtractAllItem.Enabled := Value;
   Options1.Visible := Value;
   CutImagePreviewItem.Visible := Value;
   WordWrapItem.Visible := Value;
end;

procedure TFrmBIGMain.SetOptPreviewImages(Value : Boolean);
begin
   Options.OptPreviewImages := value;
   CutImagePreviewItem.checked := not value;
end;

procedure TFrmBIGMain.SetOptWordWrap(Value : Boolean);
begin
   Options.OptWordWrap := Value;
   WordWrapItem.Checked := Value;
   if Value then
      mmFileContent.ScrollBars := ssVertical
   else
      mmFileContent.ScrollBars := ssBoth;
   mmFileContent.WordWrap := Value;
end;

procedure TFrmBIGMain.SetOptSaveFullDir(Value : Boolean);
begin
   Options.OptSaveFullDir := value;
   SaveFullDirItem.checked := value;
end;

// Interface Events
procedure TFrmBIGMain.FileExit1Execute(Sender: TObject);
begin
   Close;
end;

procedure TFrmBIGMain.HelpAbout1Execute(Sender: TObject);
begin
   FrmAboutBox.ShowModal;
end;

procedure TFrmBIGMain.LbFilesClick(Sender: TObject);
var
   Data : TStream;
   DataSize : uint32;
   Index : uint32;
   MyFileInfo : TBIGFileUnit;
   Bitmap:  TBitmap;
   MyFile : TStream;
begin
   Index := lbFiles.ItemIndex;
   MyFileInfo := CurrentFile.GetFileInfo(Index);
   CurrentFile.GetFileContents(Index,Data,DataSize);
   MmFileContent.Clear;
   Data.Seek(0,soFromBeginning);
   lbFiles.Hint := MyFileInfo.Filename;
   if DataSize = MyFileInfo.Size then
      lbFiles.Hint := (MyFileInfo.Filename +  ' - ' + IntToStr(DataSize) + ' bytes')
   else
      lbFiles.Hint := (MyFileInfo.Filename +  ' - ' + IntToStr(MyFileInfo.Size) + ' bytes compressed ' + ' - ' + IntToStr(DataSize) + ' bytes uncompressed (' + FloatToStrF((MyFileInfo.Size / DataSize) * 100,ffGeneral,4,4) + '%)');

   // This part was coded by Zlatko Minev and it was lightly modified by Banshee
   if(LowerCase(ExtractFileExt(MyFileInfo.Filename))='.tga') and Options.OptPreviewImages then
   begin
      Bitmap := TBitmap.Create;
      TRY
         MyFile := TFileStream.Create('c:\temp.tga',fmCreate);
         MyFile.Seek(0,soFromBeginning);
//         Data.Seek(0,soFromBeginning);
         MyFile.CopyFrom(Data,DataSize);
         MyFile.Free;
         LoadFromFileX('c:\temp.tga', Bitmap);
         ImageTGA.Picture.Graphic := Bitmap
      FINALLY
         MmFileContent.Hide;
         ImageTGA.show;
         Bitmap.Free
      END;
   end
   else
   begin //If it is not a tga file
      MmFileContent.Show;
      ImageTGA.Hide;
      mmFileContent.Lines.LoadFromStream(Data);
   end;
   // End of Zlatko Minev's code.
   Data.Free;
end;

procedure TFrmBIGMain.FormResize(Sender: TObject);
begin
   lbFiles.Left := 0;
   lbFiles.Width := SpContent.Left - lbFiles.Left - 1;
   mmFileContent.Left := spContent.Left + 1;
   mmFileContent.Width := Width - mmFileContent.Left - 5;
   ImageTGA.Left := mmFileContent.Left;
   ImageTGA.Width := mmFileContent.Width;
end;

procedure TFrmBIGMain.SpContentMoved(Sender: TObject);
begin
   FormResize(sender);
end;

procedure TFrmBIGMain.EditExtractExecute(Sender: TObject);
var
   Data : TStream;
   DataSize : uint32;
   Index : uint32;
   MyFileInfo : TBIGFileUnit;
   MyFile : TStream;
   MyFileName : string;
   MyDirectory : string;
   Form : TFrmDestination;
begin
   if lbFiles.SelCount > 0 then
   begin
      Form := TFrmDestination.Create(self);
      if DirectoryExists(Options.ExtractDirectory) then
         Form.Directory.Root := Options.ExtractDirectory;
      Form.ShowModal;
      if Form.Changed then
      begin
         Options.ExtractDirectory := Form.Directory.Path;
         for Index := 0 to CurrentFile.GetNumFiles-1 do
         begin
            if lbFiles.Selected[Index] then
            begin
               MyFileInfo := CurrentFile.GetFileInfo(Index);
               CurrentFile.GetFileContents(Index,Data,DataSize);
               Data.Seek(0,soFromBeginning);
               if Options.OptSaveFullDir then
                  MyFilename := Form.Directory.Path + '\' + MyFileInfo.Filename
               else
                  MyFilename := Form.Directory.Path + '\' + ExtractFileName(MyFileInfo.Filename);
               MyDirectory := ExtractFileDir(MyFileName);
               if not DirectoryExists(MyDirectory) then
                  MakeMeADir(MyDirectory);
               MyFile := TFileStream.Create(MyFileName,fmCreate);
               MyFile.Seek(0,soFromBeginning);
               MyFile.CopyFrom(Data,DataSize);
               MyFile.Free;
               Data.Free;
            end;
         end;
      end;
   end
   else
   begin
      Index := LbFiles.ItemIndex;
      if DirectoryExists(Options.ExtractDirectory) then
         SaveDialog.InitialDir := Options.ExtractDirectory;
      MyFileInfo := CurrentFile.GetFileInfo(Index);
      if Options.OptSaveFullDir then
         SaveDialog.FileName := MyFileInfo.Filename
      else
         SaveDialog.FileName := ExtractFileName(MyFileInfo.Filename);
      if SaveDialog.Execute() then
      begin
         Options.ExtractDirectory := ExtractFileDir(SaveDialog.FileName);
         CurrentFile.GetFileContents(Index,Data,DataSize);
         Data.Seek(0,soFromBeginning);
         MyDirectory := ExtractFileDir(SaveDialog.FileName);
         if not DirectoryExists(MyDirectory) then
            MakeMeADir(MyDirectory);
         MyFile := TFileStream.Create(SaveDialog.FileName,fmCreate);
         MyFile.Seek(0,soFromBeginning);
         MyFile.CopyFrom(Data,DataSize);
         MyFile.Free;
         Data.Free;
      end;
   end;
end;

procedure TFrmBIGMain.EditExtractAllExecute(Sender: TObject);
var
   Data : TStream;
   DataSize : uint32;
   Index : uint32;
   MyFileInfo : TBIGFileUnit;
   MyFile : TStream;
   Form : TFrmDestination;
   MyFileName : string;
   MyDirectory : string;
begin
   Form := TFrmDestination.Create(self);
   Form.ShowModal;
   if Form.Changed then
   begin
      Options.ExtractAllDirectory := Form.Directory.Path;
      for Index := 0 to CurrentFile.GetNumFiles-1 do
      begin
         MyFileInfo := CurrentFile.GetFileInfo(Index);
         CurrentFile.GetFileContents(Index,Data,DataSize);
         Data.Seek(0,soFromBeginning);
         if Options.OptSaveFullDir then
            MyFilename := Form.Directory.Path + '\' + MyFileInfo.Filename
         else
            MyFilename := Form.Directory.Path + '\' + ExtractFileName(MyFileInfo.Filename);
         MyDirectory := ExtractFileDir(MyFilename);
         if not DirectoryExists(MyDirectory) then
            MakeMeADir(MyDirectory);
         MyFile := TFileStream.Create(MyFilename,fmCreate{and fmOpenWrite});
         MyFile.Seek(0,soFromBeginning);
         MyFile.CopyFrom(Data,DataSize);
         MyFile.Free;
         Data.Free;
      end;
   end;
   Form.Release;
end;

procedure TFrmBIGMain.OptionsPreferencesExecute(Sender: TObject);
var
   Form : TFrmOptions;
begin
   Form := TFrmOptions.Create(self);
   Form.ShowModal;
   Form.Release;
end;

procedure TFrmBIGMain.OptionsCutImagePreviewExecute(Sender: TObject);
begin
   SetOptPreviewImages(not Options.OptPreviewImages);
end;

procedure TFrmBIGMain.OptionsWordWrapExecute(Sender: TObject);
begin
   SetOptWordWrap(not Options.optWordWrap);
end;

procedure TFrmBIGMain.OptionsSaveFullDirExecute(Sender: TObject);
begin
   SetOptSaveFullDir(not Options.OptSaveFullDir);
end;

/////////////////////////////////////////////////////////////////
// Important Note from Banshee:                                //
/////////////////////////////////////////////////////////////////
// This section is the minimum that I can get for my efforts.  //
// Do not remove this from the program! Never!!!               //
/////////////////////////////////////////////////////////////////

// And also, people need to know where they should get updated versions
// and support for the program.

// Copied from OS SHP Builder, probably coded by Stucuk.
procedure TFrmBIGMain.OpenHyperlink(HyperLink: PChar);
begin
  ShellExecute(Application.Handle,nil,HyperLink,'','',SW_SHOWNORMAL);
end;

procedure TFrmBIGMain.Contents1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/index.php?go=osbigeditorhelp'));
end;

procedure TFrmBIGMain.SupportForums1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://cnceditingtools.ppmsite.com/'));
end;

procedure TFrmBIGMain.GetUpdates1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/index.php?go=osbigeditorinfo'));
end;

// Drag And Drop Support Goes here
procedure TFrmBIGMain.OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat; Index: integer; out AStream: IStream);
var
   Data : TStream;
   DataSize : uint32;
   FileIndex : uint32;
begin
   // This event handler is called by TFileContentsStreamOnDemandClipboardFormat
   // when the drop target requests data from the drop source (that's us).
   try
      FileIndex := DropIDs[Index];
      CurrentFile.GetFileContents(FileIndex,Data,DataSize);
      Data.Position := 0;
      // ...and return the stream back to the target as an IStream. Note that the
      // target is responsible for deleting the stream (via reference counting).
      AStream := TFixedStreamAdapter.Create(Data, soOwned);
   except
      Data.Free;
      raise;
   end;
end;

procedure TFrmBIGMain.DropEmptySource1AfterDrop(Sender: TObject; DragResult: TDragResult; Optimized: Boolean);
begin
	Cursor := crArrow;
end;

procedure TFrmBIGMain.LbFilesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   i,total : uint32;
begin
   if (DragDetectPlus(Handle,Point(x,y))) then
   begin
      // Transfer the file names to the data format. The content will be extracted
      // by the target on-demand.
      with TVirtualFileStreamDataFormat(DataFormatAdapter.DataFormat) do
      begin
         FileNames.Clear;
         SetLength(DropIDs,0);
         total := 0;
         for i:= 0 to (LbFiles.Items.count-1) do
      	   if (LbFiles.Selected[i]) then
            begin
               if Options.OptSaveFullDir then
		            FileNames.Add(lbFiles.Items.Strings[i])
               else
		            FileNames.Add(ExtractFileName(lbFiles.Items.Strings[i]));
               inc(total);
               SetLength(DropIDs,total);
               DropIDs[total-1] := i;
            end;
      end;
   end;
   // ...and let it rip!
   // Note by Banshee: This must be here even if there is no drag and drop
   // or the program will lock the window.
   DropEmptySource.Execute;
   LbFilesClick(nil);
end;

// Danny von Loon code starts here.
// -----------------------------------------------------------------------------
//							drag-droppage 05-03-07
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.AcceptFiles( var msg : TMessage );
const
  cnMaxFileNameLen = 255;
var
  i,
  nCount     : integer;
  acFileName : array [0..cnMaxFileNameLen] of char;
begin
  // find out how many files we're accepting
  nCount := DragQueryFile( msg.WParam,
                           $FFFFFFFF,
                           acFileName,
                           cnMaxFileNameLen );

  if (nCount > 1) then
  begin
    MessageDlg('Can only accept one file at a time.',mtWarning,[mbOk],0);
    exit;
  end;


  // query Windows one at a time for the file name
  for i := 0 to nCount-1 do
  begin
    DragQueryFile( msg.WParam, i,
                   acFileName, cnMaxFileNameLen );

    // do your thing with the acFileName
    LoadBIGFile(acFileName);
  end;

  // let Windows know that you're done
  DragFinish( msg.WParam );
end;
// -----------------------------------------------------------------------------
//							drag-droppage 05-03-07
// -----------------------------------------------------------------------------
end.


end.
