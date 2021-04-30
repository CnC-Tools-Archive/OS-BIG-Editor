(*******************************************************************************
 * Author            Banshee
 *
 * Date              01/03/2007
 *
 * Copyright
 ******************************************************************************)
unit FormBIGMain;

interface

uses
   Windows, Classes, Graphics, Forms, Controls, Menus, Dialogs, StdCtrls, Buttons,
   ExtCtrls, ComCtrls, ImgList, StdActns, ActnList, ToolWin, BasicDataTypes,
   BIG_File, FormDestination, SysUtils, BasicFunctions, DragDrop, DragDropFormats,
   DropSource, ActiveX, BasicOptions, FormOptions, ShellAPI, Messages, XPMan,
   Language, uIconHelper{treeview D.van Loon 13-03-07}, uFileViewer, uSelectedNodes,
   uTempFileManager, BasicConstants;

const
   APPLICATION_NAME = 'OS BIG Editor';
   APPLICATION_VERSION = '0.584 SVN Beta';
   APPLICATION_PATCH_AUTHORS = 'Banshee, Igi and Danny van Loon';
   APPLICATION_AUTHORS = 'Carlos E. V. Muniz (Banshee)';

type
   TFrmBIGMain = class(TForm)
      OpenDialog: TOpenDialog;
      SaveDialog: TSaveDialog;
      ToolBar1: TToolBar;
      TbFileNew: TToolButton;
    TbFileOpen: TToolButton;
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
      ContentsItem: TMenuItem;
      SupportForumsItem: TMenuItem;
      GetUpdatesItem: TMenuItem;
    MyLanguageSupportForumsItem: TMenuItem;
      XPManifest1: TXPManifest;
      N5: TMenuItem;
      popupTree: TPopupMenu;
      imgListIcons: TImageList;
    SVNItem: TMenuItem;
    EditAddDirectory: TAction;
    N4: TMenuItem;
    AddDirectoryItem: TMenuItem;
    EditDeleteSelectedFiles: TAction;
    DeleteFilesItem: TMenuItem;
    OptionsRealTimeEdition: TAction;
    RealTimeEditionItem: TMenuItem;
    TreeFiles : TTreeView;
    N6: TMenuItem;
    NewDirectoryPopup: TMenuItem;
    AddDirectoryPopup: TMenuItem;
    RenamePopup: TMenuItem;
    DeleteFilesPopup: TMenuItem;
    EditRename: TAction;
    RenameItem: TMenuItem;
    NewDirectoryItem: TMenuItem;
    EditNewDirectory: TAction;
    N7: TMenuItem;
    ViewAsTextPopup: TMenuItem;
    OpenWithNotepadPopup: TMenuItem;
    OpenPopup: TMenuItem;
    EditOpen: TAction;
    N8: TMenuItem;
    OpenItem: TMenuItem;
    EditOpenWithNotepad: TAction;
    OpenWithNotepadItem: TMenuItem;
    EditViewAsText: TAction;
    ToolButton1: TToolButton;
    procedure FileSaveAs1Execute(Sender: TObject);
    procedure EditViewAsTextExecute(Sender: TObject);
    procedure EditOpenWithNotepadExecute(Sender: TObject);
    procedure EditOpenExecute(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
    procedure treeFilesEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure EditCut1Execute(Sender: TObject);
    procedure EditCopy1Execute(Sender: TObject);
    procedure MmFileContentMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure treeFilesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure treeFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EditNewDirectoryExecute(Sender: TObject);
    procedure EditRenameExecute(Sender: TObject);
    procedure OptionsRealTimeEditionExecute(Sender: TObject);
    procedure EditDeleteSelectedFilesExecute(Sender: TObject);
    procedure EditAddDirectoryExecute(Sender: TObject);
    procedure SVNItemClick(Sender: TObject);
    procedure treeFilesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
      procedure OptionsPreferencesExecute(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure OptionsSaveFullDirExecute(Sender: TObject);
      procedure OptionsWordWrapExecute(Sender: TObject);
      procedure OptionsCutImagePreviewExecute(Sender: TObject);
//      procedure LbFilesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure EditExtractAllExecute(Sender: TObject);
      procedure EditExtractExecute(Sender: TObject);
      // Constructors and Destructors.
      procedure FormCreate(Sender: TObject);
      procedure LoadLanguage; // This is public to allow use to switch language
      // I/O
      procedure FileNew1Execute(Sender: TObject);
      procedure FileOpen1Execute(Sender: TObject);
      procedure FileSave1Execute(Sender: TObject);
      // Gets
      // Sets
      procedure SetIsEditable(Value : Boolean);
      procedure SetOptPreviewImages(Value : Boolean);
      procedure SetWordWrap(Value : Boolean);
      procedure SetOptWordWrap(Value : Boolean);
      procedure SetOptSaveFullDir(Value : Boolean);
      procedure SetRealTimeEdition(Value : Boolean);
      procedure SetOpen;
      procedure SetOpenWithNotepad;
      procedure SetViewAsText;
      // Interface Events
      procedure SpContentMoved(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure treeFilesClick(Sender: TObject);
      procedure FileExit1Execute(Sender: TObject);
      procedure treeFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      // Help
      procedure HelpAbout1Execute(Sender: TObject);
      procedure GetUpdatesItemClick(Sender: TObject);
      procedure SupportForumsItemClick(Sender: TObject);
      procedure MyLanguageSupportForumsItemClick(Sender: TObject);
      procedure ContentsItemClick(Sender: TObject);
      // Drag and Drop Aditional Support
      procedure DropEmptySource1AfterDrop(Sender: TObject; DragResult: TDragResult; Optimized: Boolean);
      procedure mniExpandSelClick(Sender: TObject);
      procedure mniCollapseSelClick(Sender: TObject);
      procedure mniExpandAllClick(Sender: TObject);
      procedure mniCollapseAllClick(Sender: TObject);
      procedure treeFilesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure treeFilesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure treeFilesEdited(Sender: TObject; Node: TTreeNode; var S: string);
      function GetFullFilename(aNode: TTreeNode): String; //Treeview 13-03-07
   private
      { Private declarations }
      isEditable : Boolean;
      _appDir, _appTempDir :String;
      // Drag and Drop support.
      dropEmptySource: TDropEmptySource;
      dataFormatAdapter: TDataFormatAdapter;
      dropIDs : array of uint32;
      //treeview  13-03-07 D.van Loon
      iconHelper : TIconHelper;
      previousIndex : uint32;

      // Dir and Node caching
      fileLastDirName : string;
      fileLastDirNode : TTreeNode;

      // Copy / Cut / Paste cache.
      selectedNodes : CSelectedNodes;
      selectOp : uint8;

      //mouse controls
      MouseLmbDown:boolean;      //treeview drag 14-03-07
      MouseIsDragging:Boolean;   //treeview drag 14-03-07
      InitiatedDrag:Boolean;     //treeview drag 14-03-07
      // I/O
      procedure LoadBIGFile(const _Filename : string);
      procedure CommonSaveTasks;
      // Gets
      // Misc
      procedure UpdateCaption;
      procedure UpdateTreeFiles;
      procedure ReloadTreeFiles;
      procedure ReOrderNode(var Node : TTreeNode; const NodeNewName : string);
      function IsNodeInsideSelections(const _Node: TTreeNode): boolean;
      function CopyNodeWithoutRepetition(const _Source: TTreeNode; var _Dest : TTreeNode): TTreeNode;
      procedure CopyNodes(var _Dest: TTreeNode; var _Source: array of TTreeNode);
      procedure MoveNodes(var _Dest: TTreeNode; var _Source: array of TTreeNode);
      function GetFirstSibling(const Node : TTreeNode): TTreeNode;
      // Drag and Drop Aditional procedures
      procedure OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat;	Index: integer; out AStream: IStream);
      procedure AcceptFiles( var msg : TMessage );  message WM_DROPFILES;
      function AddDirectoriesToBIG (const _Directory, _BaseDir : string; const _ArchiveDir : string = ''): uint32;
     // Tree View procedures
      function AddFile(filename:String;fileIndex:Integer): TTreeNode; //Treeview 13-03-07
      function FindNode(parent:TTreeNode;title:String):TTreeNode; //Treeview 13-03-07
      procedure InitiateDrag;	//Treeview drag 14-03-07
      procedure DeleteSelectedFiles;
      procedure DeleteADirectory(const _Directory : TTreeNode);
   public
      { Public declarations }
      CurrentFile : TBIGPackage;
      Language : TLanguage;
      // OptionVariables.
      Options : TOptions;
      TreeFilesIsEditing : boolean;
      // TempFiles Manager.
      TempFiles : CTempFileManager;
      // View as Text variables
      ViewAsText : Boolean;
      LastPreviewedFile : uint32;
      property appDir:string read _appDir;
      property appTempDir: string read _appTempDir;
   end;

var
   FrmBIGMain: TFrmBIGMain;

implementation

uses
   FormAboutBox, TARGA, uTools;

{$R *.dfm}

// Constructors and Destructors.
procedure TFrmBIGMain.FormCreate(Sender: TObject);
const
   OPTIONS_FILE : string = 'options.ini';
var
   MyParameter : string;
begin
   // Reset variables.
   SelectedNodes := CSelectedNodes.Create;
   TempFiles := CTempFileManager.Create;
   CurrentFile := TBIGPackage.Create;

   // Setup and lock interface
   UpdateCaption;
   SetIsEditable(false);
   StatusBar.Panels.Add;
   //win98 / winXP safe app-dir code from Danny van Loon
   _appDir := ExtractFilePath(Application.exename);
   _appTempDir := _appDir + 'temp\';
   MakeMeADir(_appTempDir);
   IncludeTrailingPathDelimiter(_appDir);

   // Quick name caching:
   FileLastDirNode := nil;

   // 0.5: Set Basic Options.
   Options := TOptions.Create(_appDir + OPTIONS_FILE);
   SetOptPreviewImages(Options.OptPreviewImages);
   SetOptWordWrap(Options.OptWordWrap);
   SetOptSaveFullDir(Options.OptSaveFullDir);
   SetRealTimeEdition(Options.OptRealTimeEdition);
   SetOpenWithNotepad;
   SetViewAsText;
   PreviousIndex := 999999;

   Language := TLanguage.Create;
   Language.SetFilename(_appDir +  'languages\' + LowerCase(Options.Language) + '.ini' );
   LoadLanguage;

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

   MouseLmbDown		:= false;         //treeview drag 14-03-07
   MouseIsDragging   := false;         //treeview drag 14-03-07
   InitiatedDrag	   := false;         //treeview drag 14-03-07

   // Dann Van Loon code for drag and drop goes here
   DragAcceptFiles( Handle, True ); 	//drag-droppage 05-03-07
   iconHelper := TIconHelper.create(imgListIcons);   //tree view 13-03-07

   // Drag and Drop Creation support ends here.

   // Quick load file through parameter;
   if (ParamCount > 0) then
   begin
      MyParameter := GetParamStr;
      if (FileExists(MyParameter)) then
      begin
         LoadBIGFile(MyParameter);
      end;
   end;

   // 0.6: Starts a new file if nothing was loaded.
   If not CurrentFile.IsValid then
       FileNew1Execute(sender);
end;

procedure TFrmBIGMain.UpdateCaption;
begin
   if CurrentFile.IsValid then
   begin
      Caption := APPLICATION_NAME + ' ' + APPLICATION_VERSION + ' - ' + CurrentFile.GetFileName;
   end
   else
   begin
      Caption := APPLICATION_NAME + ' ' + APPLICATION_VERSION;
   end;
end;


procedure TFrmBIGMain.LoadLanguage;
begin
   // igi code starts here.

   File1.Caption := Language.GetString('MainMenu', 'File');
   FileNewItem.Caption := Language.GetString('MainMenu', 'New');
   FileNewItem.Hint    := Language.GetString('MainMenu', 'New|Createanewfile');
   TbFileNew.Hint := FileNewItem.Hint;
   FileOpenItem.Caption := Language.GetString('MainMenu', 'Open');
   FileOpenItem.Hint    := Language.GetString('MainMenu', 'Open|Openafile');
   TbFileOpen.Hint := FileOpenItem.Hint;
   FileSaveItem.Caption := Language.GetString('MainMenu', 'Save');
   FileSaveItem.Hint    := Language.GetString('MainMenu', 'Save|Savecurrentfile');
   TbFileSave.Hint := FileSaveItem.Hint;
   FileSaveAsItem.Caption := Language.GetString('MainMenu', 'SaveAs');
   FileSaveAsItem.Hint    := Language.GetString('MainMenu', 'SaveAs|Savecurrentfilewithadifferentname');
   N1.Caption := '-';
   FileExitItem.Caption := Language.GetString('MainMenu', 'Exit');
   FileExitItem.Hint    := Language.GetString('MainMenu', 'Exit|Exitapplication');

   Edit1.Caption := Language.GetString('MainMenu', 'Edit');
   CutItem.Caption := Language.GetString('MainMenu', 'Cut');
   CutItem.Hint := Language.GetString('MainMenu', 'Cut|CutsTheSelectionAndPutsItOnTheClipboard');
   TbEditCut.Hint := CutItem.Hint;
   CopyItem.Caption := Language.GetString('MainMenu', 'Copy');
   CopyItem.Hint := Language.GetString('MainMenu','Copy|CopiesTheSelectionAndPutsItOnTheClipboard');
   TbEditCopy.Hint := CopyItem.Hint;
   PasteItem.Caption := Language.GetString('MainMenu', 'Paste');
   PasteItem.Hint := Language.GetString('MainMenu','Paste|InsertsClipboardContents');
   TbEditPaste.Hint := PasteItem.Hint;
   N2.Caption := '-';
   ExtractItem.Caption := Language.GetString('MainMenu', 'Extract');
   ExtractItem.Hint := Language.GetString('MainMenu', 'Extract|ExtractTheSelectedFilesFromTheBIGFile');
   ExtractAllItem.Caption := Language.GetString('MainMenu', 'ExtractAll');
   ExtractAllItem.Hint := Language.GetString('MainMenu', 'ExtractAll|ExtractAllFilesFromTheBIGFile');
   NewDirectoryItem.Caption := Language.GetString('MainMenu','NewDirectory');
   NewDirectoryItem.Hint := Language.GetString('MainMenu', 'NewDirectory|NewDirectoryToTheBIGFile');
   NewDirectoryPopup.Caption := Language.GetString('MainMenu','NewDirectory');
   NewDirectoryPopup.Hint := Language.GetString('MainMenu', 'NewDirectory|NewDirectoryToTheBIGFile');
   AddDirectoryItem.Caption := Language.GetString('MainMenu','AddDirectory');
   AddDirectoryItem.Hint := Language.GetString('MainMenu', 'AddDirectory|AddADirectoryToTheBIGFile');
   AddDirectoryPopup.Caption := Language.GetString('MainMenu','AddDirectory');
   AddDirectoryPopup.Hint := Language.GetString('MainMenu', 'AddDirectory|AddADirectoryToTheBIGFile');
   RenameItem.Caption := Language.GetString('MainMenu','Rename');
   RenameItem.Hint := Language.GetString('MainMenu', 'Rename|RenameSelection');
   RenamePopup.Caption := Language.GetString('MainMenu','Rename');
   RenamePopup.Hint := Language.GetString('MainMenu', 'Rename|RenameSelection');
   DeleteFilesItem.Caption := Language.GetString('MainMenu','DeleteFiles');
   DeleteFilesItem.Hint := Language.GetString('MainMenu', 'DeleteFiles|DeleteSelectedFiles');
   DeleteFilesPopup.Caption := Language.GetString('MainMenu','DeleteFiles');
   DeleteFilesPopup.Hint := Language.GetString('MainMenu', 'DeleteFiles|DeleteSelectedFiles');
   OpenItem.Caption := Language.GetString('MainMenu','Open');
   OpenItem.Hint := Language.GetString('MainMenu', 'Open|OpenWithDefault');
   OpenPopup.Caption := Language.GetString('MainMenu','Open');
   OpenPopup.Hint := Language.GetString('MainMenu', 'Open|OpenWithDefault');
   OpenWithNotepadItem.Caption := Language.GetString('MainMenu','OpenWithNotepad');
   OpenWithNotepadItem.Hint := Language.GetString('MainMenu', 'OpenWithNotepad|OpenWithNotepad');
   OpenWithNotepadPopup.Caption := Language.GetString('MainMenu','OpenWithNotepad');
   OpenWithNotepadPopup.Hint := Language.GetString('MainMenu', 'OpenWithNotepad|OpenWithNotepad');

   Options1.Caption := Language.GetString('MainMenu', 'Options');
   Options1.Hint := Language.GetString('MainMenu', 'Options|ProgramSettings');
   PreferencesItem.Caption := Language.GetString('MainMenu', 'Preferences');
   PreferencesItem.Hint := Language.GetString('MainMenu', 'Preferences|SetupTheProgra');
   N3.Caption := '-';
   WordWrapItem.Caption := Language.GetString('MainMenu', 'ActivateWordWrap');
   WordWrapItem.Hint := Language.GetString('MainMenu', 'ActivateWordWrap|WordWrapTheTextFromTextFiles');
   CutImagePreviewItem.Caption := Language.GetString('MainMenu', 'CutImagePreview');
   SaveFullDirItem.Caption := Language.GetString('MainMenu', 'SaveFullDirectoryOnExtraction');
   RealTimeEditionItem.Caption := Language.GetString('MainMenu', 'RealTimeEdition');
   RealTimeEditionItem.Hint := Language.GetString('MainMenu', 'RealTimeEdition|AutoSaveTheFileAsSoonAsYouChangeIt');

   Help1.Caption := Language.GetString('MainMenu', 'Help');
   ContentsItem.Caption := Language.GetString('MainMenu', 'OnlineHelp');
   SupportForumsItem.Caption := Language.GetString('MainMenu', 'SupportForum');
   MyLanguageSupportForumsItem.Caption := Language.GetString('MainMenu','MyLanguageSupportForum');
   MyLanguageSupportForumsItem.Hint := Language.GetString('MainMenu','MyLanguageSupportForumHint');
   SVNItem.Caption := Language.GetString('MainMenu','SVNLink');
   SVNItem.Hint := Language.GetString('MainMenu','SVNLinkHint');
   if CompareStr(MyLanguageSupportForumsItem.Caption,LANG_NO_STRING) <> 0 then
      MyLanguageSupportForumsItem.Visible := true
   else
      MyLanguageSupportForumsItem.Visible := false;
   GetUpdatesItem.Caption := Language.GetString('MainMenu', 'GetUpdates');
   N5.Caption := '-';
   HelpAboutItem.Caption := Language.GetString('MainMenu', 'About');

   OpenDialog.Filter := Language.GetString('Common','AllValidFiles') + '|*.meg;*.pgm;*.big;|' + Language.GetString('Common','BIGFiles') + '|*.big;|' + Language.GetString('Common','MEGFiles') + '|*.meg;*.pgm;';
end;

procedure TFrmBIGMain.MmFileContentMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   TreeFiles.DragMode := dmManual;
end;

procedure TFrmBIGMain.FormDestroy(Sender: TObject);
begin
   TreeFilesIsEditing := false;
   Options.Free;
   SelectedNodes.Free;
   TempFiles.Free;
   ClearDir(_appTempDir);
   RemoveDir(_appTempDir);
end;


// I/O
procedure TFrmBIGMain.FileNew1Execute(Sender: TObject);
begin
   // Lock interface
   SetIsEditable(false);

   // Clear interface
   treeFiles.Items.Clear;
   MmFileContent.Clear;

   // Reset BIG Data
   CurrentFile.NewFile;

   // Unlock interface
   SetIsEditable(true);
end;

procedure TFrmBIGMain.LoadBIGFile(const _Filename : string);
var
   MyExt : string;
begin
   if (FileExists(_FileName)) then
   begin
      SetIsEditable(false);
      MmFileContent.Clear;
      Options.OpenDirectory := ExtractFileDir(_FileName);
      CurrentFile.LoadFile(_FileName);
      if CurrentFile.IsValid then
      begin
         ReloadTreeFiles;
         UpdateCaption;
         SetIsEditable(true);
      end
      else
      begin
         MyExt := ExtractFileExt(_Filename);
         if CompareStr(MyExt,'.big') = 0 then
            MessageDlg(Language.GetString('Warnings','InvalidBIGFile'),mtWarning,[mbOk],0) //drag-droppage 05-03-07
         else if CompareStr(MyExt,'.meg') = 0 then
            MessageDlg(Language.GetString('Warnings','InvalidMEGFile'),mtWarning,[mbOk],0)
         else if CompareStr(MyExt,'.pgm') = 0 then
            MessageDlg(Language.GetString('Warnings','InvalidMEGFile'),mtWarning,[mbOk],0)
         else
            MessageDlg(Language.GetString('Warnings','InvalidFile'),mtWarning,[mbOk],0);
      end;
   end;
end;

procedure TFrmBIGMain.FileOpen1Execute(Sender: TObject);
begin
   if (DirectoryExists(Options.OpenDirectory)) then
   begin
      OpenDialog.InitialDir := Options.OpenDirectory;
   end;

   if (OpenDialog.Execute) then
   begin
      LoadBIGFile(OpenDialog.FileName);
   end;
end;

procedure TFrmBIGMain.FileSave1Execute(Sender: TObject);
begin
   if Length(CurrentFile.GetFileName) = 0 then
   begin
      FileSaveAs1Execute(Sender);
   end
   else
   begin
      SetIsEditable(false);
      CurrentFile.SaveFile(CurrentFile.GetFileName,CurrentFile.GetUseCompression);
      CommonSaveTasks;
      SetIsEditable(true);
   end;
end;

procedure TFrmBIGMain.FileSaveAs1Execute(Sender: TObject);
begin
   SaveDialog.Filter := Language.GetString('Common','BIGFilesGenerals') + '|*.big;|' + Language.GetString('Common','BIGFilesCnC3') + '|*.big;|' + Language.GetString('Common','MEGFiles') + '|*.meg;*.pgm;';
   SaveDialog.FilterIndex := 1; // Default for BIGF.
   if CurrentFile.IsValid then
   begin
      if CurrentFile.GetPackageType = C_BIGF then
      begin
         SaveDialog.FilterIndex := 1;
      end
      else if CurrentFile.GetPackageType = C_BIG4 then
      begin
         SaveDialog.FilterIndex := 2;
      end
      else if CurrentFile.GetPackageType = C_MEGF then
      begin
         SaveDialog.FilterIndex := 3;
      end;
   end;
   if (SaveDialog.Execute) then
   begin
      SetIsEditable(false);
      if SaveDialog.FilterIndex = 1 then
      begin
         CurrentFile.SaveFile(SaveDialog.FileName,false);
      end
      else
      begin
         CurrentFile.SaveFile(SaveDialog.FileName,true);
      end;
      CommonSaveTasks;
      SetIsEditable(true);
   end;
end;

procedure TFrmBIGMain.CommonSaveTasks;
begin
   MmFileContent.Clear;
   ReloadTreeFiles;
end;

procedure TFrmBIGMain.ReloadTreeFiles;
var
   i     : uint32;
   iFile : TBIGFileUnit;
begin
   FileLastDirName := '';
   FileLastDirNode := nil;
   try
      treeFiles.Items.Clear;
      LockWindowUpdate(TreeFiles.Handle);
      for i := 0 to (CurrentFile.GetNumFiles-1) do
      begin
         iFile := CurrentFile.GetFileInfo(i);
         AddFile(iFile.Filename,I);
      end;
   finally
      treeFiles.CustomSort(@treeSort,0);
      LockWindowUpdate(0);
   end;
   TreeFiles.FullExpand;
   treeFilesClick(nil);
end;

// Gets


// Sets
procedure TFrmBIGMain.SetIsEditable(Value : Boolean);
begin
   IsEditable             := Value;
   FileSaveItem.Enabled   := Value;
   FileSaveAsItem.Enabled := Value;
   TbFileSave.Enabled     := Value;
   TbEditPaste.Enabled    := Value;
   PasteItem.Enabled      := Value;
   TbEditCopy.Enabled     := Value;
   CopyItem.Enabled       := Value;
   TbEditCut.Enabled      := Value;
   CutItem.Enabled        := Value;
   ExtractItem.Enabled    := Value;
   ExtractAllItem.Enabled := Value;
   NewDirectoryItem.Enabled := Value;
   AddDirectoryItem.Enabled := Value;
   DeleteFilesItem.Enabled := Value;
   RenameItem.Enabled := Value;
   // Left Listbox fix by Banshee. The one written by prabab would cause trouble if an opened file wasn't valid.
   TreeFiles.Enabled      := Value;
   // Disable popup menu when not editable.
   if Value then
   begin
      TreeFiles.PopupMenu := PopupTree;
      SelectedNodes.Reset;
      SelectOp := C_SEL_NONE;
   end
   else
      TreeFiles.PopupMenu := nil;
end;

procedure TFrmBIGMain.SetOptPreviewImages(Value : Boolean);
begin
   Options.OptPreviewImages    := Value;
   CutImagePreviewItem.checked := not Value;
end;

procedure TFrmBIGMain.SetWordWrap(Value : Boolean);
begin
   if (Value) then
      mmFileContent.ScrollBars := ssVertical
   else
      mmFileContent.ScrollBars := ssBoth;
   mmFileContent.WordWrap := Value;
end;

procedure TFrmBIGMain.SetOptWordWrap(Value : Boolean);
begin
   Options.OptWordWrap  := Value;
   WordWrapItem.Checked := Value;

   SetWordWrap(Value);
   mmFileContent.WordWrap := Value;
end;

procedure TFrmBIGMain.SetOptSaveFullDir(Value : Boolean);
begin
   Options.OptSaveFullDir  := Value;
   SaveFullDirItem.checked := Value;
end;

procedure TFrmBIGMain.SetRealTimeEdition(Value : Boolean);
begin
   Options.OptRealTimeEdition := Value;
   RealTimeEditionItem.Checked := Value;
end;

procedure TFrmBIGMain.SetOpen;
begin
   OpenItem.Enabled := false;
   OpenPopup.Enabled := false;
   if TreeFiles.Selected <> nil then
   begin
      if TreeFiles.Selected.ImageIndex <> 0 then
      begin
         OpenItem.Enabled := true;
         OpenPopup.Enabled := true;
      end;
   end;
end;

procedure TFrmBIGMain.SetOpenWithNotepad;
begin
   if FileExists(Options.OptNotepadAddress) then
   begin
      OpenWithNotepadItem.Visible := true;
      OpenWithNotepadItem.Enabled := false;
      OpenWithNotepadPopup.Visible := true;
      OpenWithNotepadPopup.Enabled := false;
      if TreeFiles.Selected <> nil then
      begin
         if TreeFiles.Selected.ImageIndex <> 0 then
         begin
            OpenWithNotepadItem.Enabled := true;
            OpenWithNotepadPopup.Enabled := true;
         end;
      end;
   end
   else
   begin
      OpenWithNotepadItem.Visible := false;
      OpenWithNotepadPopup.Visible := false;
   end;
end;

procedure TFrmBIGMain.SetViewAsText;
begin
   ViewAsTextPopup.Visible := false;
   ViewAsTextPopup.Enabled := false;
   if TreeFiles.Selected <> nil then
   begin
      if TreeFiles.Selected.ImageIndex <> 0 then
      begin
         ViewAsTextPopup.Visible := true;
         if LastPreviewedFile = uint32(TreeFiles.Selected.Data) then
         begin
            ViewAsTextPopup.Enabled := true;
            if ViewAsText then
            begin
               ViewAsTextPopup.Caption := Language.GetString('MainMenu', 'ViewWithBinary');
               ViewAsTextPopup.Hint := Language.GetString('MainMenu', 'ViewWithBinary|ViewWithBinary');
            end
            else
            begin
               ViewAsTextPopup.Caption := Language.GetString('MainMenu', 'ViewAsText');
               ViewAsTextPopup.Hint := Language.GetString('MainMenu', 'ViewAsText|ViewAsText');
            end;
         end;
      end;
   end;
end;

// Interface Events
procedure TFrmBIGMain.FileExit1Execute(Sender: TObject);
begin
   Close;
end;

procedure TFrmBIGMain.HelpAbout1Execute(Sender: TObject);
var
   Form : TFrmAboutBox;
begin
   Form := TFrmAboutBox.Create(self);
   Form.ShowModal;
   Form.Release;
end;

procedure TFrmBIGMain.UpdateTreeFiles;
begin
   if Options.OptRealTimeEdition and CurrentFile.IsRealTimeReady then
   begin
      CurrentFile.SaveFile(CurrentFile.GetFileName,CurrentFile.GetUseCompression);
      CommonSaveTasks;
   end;
   SelectOp := C_SEL_NONE;
   SelectedNodes.Reset;
end;

procedure TFrmBIGMain.treeFilesClick(Sender: TObject);
var
   Data : TStream;
   DataSize : uint32;
   MyFileInfo : TBIGFileUnit;
   MyExt : string;
   Index : uint32;
begin
   //selection checks  // D.van Loon 13-03-07
	if (CurrentFile.IsValid) then
   begin
      if (treeFiles.Selected <> nil) then
      begin
         if (treeFiles.Selected.ImageIndex <> 0) then
         begin
            Index := Integer(treeFiles.Selected.Data);    // data is abused to store the file index // D.van Loon
            if Index = PreviousIndex then
               exit;
            PreviousIndex := Index;
            StatusBar.SimpleText := IntToStr(index);
            MyFileInfo := CurrentFile.GetFileInfo(Index);
            Data := TMemoryStream.Create;
            MmFileContent.Clear;
            try
               CurrentFile.GetFileContents(Index,Data,DataSize);
               Data.Seek(0,soFromBeginning);

               TreeFiles.Hint := MyFileInfo.Filename;
               if DataSize = MyFileInfo.Size then
  	               TreeFiles.Hint := (MyFileInfo.Filename +  ' - ' + IntToStr(DataSize) + ' ' + Language.GetString('Common', 'Bytes'))
               else
  	               TreeFiles.Hint := (MyFileInfo.Filename +  ' - ' + IntToStr(MyFileInfo.Size) + ' ' + Language.GetString('Common', 'BytesCompressed') + ' - ' + IntToStr(DataSize) + ' ' + Language.GetString('Common', 'BytesUncompressed') + ' - ' + Language.GetString('Common', 'CompressionRate') + ': ' + FloatToStrF((MyFileInfo.Size / DataSize) * 100,ffGeneral,4,4) + '%)');

               // Here we deal with filetype.
               MyExt := LowerCase(ExtractFileExt(MyFileInfo.Filename));

               // Here's our new file preview code.
               ShowFileContent(Data,DataSize,MyExt,ImageTGA,MmFileContent);
            except
               TreeFiles.Hint := (MyFileInfo.Filename +  ' - ' + IntToStr(MyFileInfo.Size) + ' ' + Language.GetString('Common', 'BytesCompressed'));
               MmFileContent.Text := Language.GetString('Warnings', 'CouldntViewFile');
               SetWordWrap(true);
            end;

            Data.Free;
         end;
      end;
      // Now we deal with selections, etc.
      SetOpen;
      SetOpenWithNotepad;
      SetViewAsText;
   end;
end;

function TFrmBIGMain.IsNodeInsideSelections(const _Node: TTreeNode): boolean;
var
   MyNode : TTreeNode;
   i : uint32;
begin
   // Assume false.
   Result := false;
   MyNode := _Node;
   while MyNode <> nil do
   begin
      i := 0;
      while i < TreeFiles.SelectionCount do
      begin
         if MyNode = TreeFiles.Selections[i] then
         begin
            Result := true;
            exit;
         end;
         inc(i);
      end;
      MyNode := MyNode.Parent;
   end;
end;

function TFrmBIGMain.CopyNodeWithoutRepetition(const _Source: TTreeNode; var _Dest : TTreeNode): TTreeNode;
var
   CopyNode, MyNode, Dest : TTreeNode;
   Dir1, Dir2 : boolean;
begin
   Result := nil;
   if _Source = nil then exit;
   // Does the destination exists?
   CopyNode := FindNode(_Dest,_Source.Text);
   if CopyNode <> nil then
      Dir1 := CopyNode.ImageIndex = 0
   else
      Dir1 := false;
   Dir2 := _Source.ImageIndex = 0;

   if not ((CopyNode <> nil) and (Dir1 = Dir2)) then
   begin
      // Let's copy the source to its destiny.
      CopyNode := TreeFiles.Items.AddChild(_Dest,_Source.Text);
      CopyNode.ImageIndex := _Source.ImageIndex;
      CopyNode.SelectedIndex := CopyNode.ImageIndex;
      if _Source.ImageIndex <> 0 then
      begin
         CopyNode.Data := _Source.Data;
      end;
      ReOrderNode(CopyNode,CopyNode.Text);
   end;

   CopyNode.Selected := _Source.Selected;
   if CopyNode.ImageIndex = 0 then
   begin
      Dest := CopyNode;
   end
   else
      Dest := _Dest;

   MyNode := _Source.getFirstChild;
   while MyNode <> nil do
   begin
      _Dest := Dest;
      CopyNodeWithoutRepetition(MyNode,_Dest);
      MyNode := MyNode.getNextSibling;
   end;
   Result := CopyNode;
end;

procedure TFrmBIGMain.treeFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   DestNode : TTreeNode;
   i : uint32;
   SourceNodes : array of TTreeNode;
begin
   // These are the basic checkups.
   // ---> Is there anything selected to be moved?
   if TreeFiles.Selected = nil then Exit;
   // Check if destination is inside the selection
   DestNode := TreeFiles.GetNodeAt(X, Y);
   if DestNode.ImageIndex <> 0 then
      DestNode := DestNode.Parent;
   if isNodeInsideSelections(DestNode) then exit;
   // Copy selection into buffer.
   i := 0;
   while i < TreeFiles.SelectionCount do
   begin
      SourceNodes[i] := TreeFiles.Selections[i];
      inc(i);
   end;

   MoveNodes(DestNode,SourceNodes);
   // Empty buffer.
   SetLength(SourceNodes,0);
   UpdateTreeFiles;
end;

procedure TFrmBIGMain.treeFilesDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   Accept := (TreeFiles.Selected <> nil) and (TreeFiles.GetNodeAt(X, Y) <> nil);
end;

procedure TFrmBIGMain.treeFilesEdited(Sender: TObject; Node: TTreeNode;
  var S: string);
var
   MyNode,TempNode : TTreeNode;
   MyLevel : int32;
   MyName,MyNewName : string;
begin
   // First of all, is the name valid?
   LockWindowUpdate(TreeFiles.Handle);
   if Length(s) > 0 then
   begin
      // Does the name really changes?
      if CompareStr(Node.Text,s) <> 0 then
      begin
         // The name changes.
         // Is it a root node? We'll use this to catch the new names needed later
         if Node.Parent <> nil then
         begin
            // This is not a root node. We need to get the directory.
            MyName := GetFullFileName(Node);
            MyName := IncludeTrailingBackSlash(ExtractFileDir(copy(MyName,1,Length(MyName)-1))) + s;
         end
         else
         begin
            // This is a root node.
            MyName := s;
         end;

         // Let's see the nature of the node. File or Paste?
         if Node.ImageIndex <> 0 then
         begin
            // This is a file. We'll just pass the new name and order Big_file.pas
            // to do the rest of the job.
            CurrentFile.SetFilename(int32(Node.data),MyName);
         end
         else
         begin
            // This is a paste (directory), not a real file. We'll rename all
            // files inside it.
            MyName := IncludeTrailingBackSlash(MyName);
            MyNode := Node.getFirstChild;
            MyLevel := Node.Level;
            while MyNode <> nil do
            begin
               // If ìt's a file, rename it.
               if MyNode.ImageIndex <> 0 then
               begin
                  TempNode := MyNode.Parent;
                  MyNewName := MyNode.Text;
                  while (TempNode <> Node) and (TempNode <> nil) do
                  begin
                     MyNewName := IncludeTrailingBackSlash(TempNode.Text) + MyNewName;

                     TempNode := TempNode.Parent;
                  end;
                  MyNewName := MyName + MyNewName;
                  CurrentFile.SetFilename(int32(MyNode.data),MyNewName);
               end;


               // goes to next Node and check if it's out of the range.
               MyNode := MyNode.GetNext;
               if MyNode <> nil then
                  if MyNode.Level <= MyLevel then
                     MyNode := nil;
            end;
         end;
         // Now that we renamed the Node, we need to re-order the Node in the TreeView.
         ReOrderNode(Node,S);
      end;
   end
   else
   begin
      s := Node.Text;
   end;
   LockWindowUpdate(0);
   EditCopy1.ShortCut := 16451;
   EditCut1.ShortCut := 16472;
   EditPaste1.ShortCut := 16470;
   UpdateTreeFiles;
end;


procedure TFrmBIGMain.treeFilesEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
   EditCopy1.ShortCut := 0;
   EditCut1.ShortCut := 0;
   EditPaste1.ShortCut := 0;
   SelectedNodes.Reset;
   SelectOp := C_SEL_NONE;
end;

procedure TFrmBIGMain.FormResize(Sender: TObject);
begin
	treeFiles.Left := 0;
   treeFiles.Width := SpContent.Left - treeFiles.Left - 1;
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
   Data        : TStream;
   DataSize    : uint32;
   Index       : uint32;
   FileIndex   : int32;
   MyFileInfo  : TBIGFileUnit;
   MyFile      : TStream;
   MyFileName  : string;
   MyDirectory : string;
   Form        : TFrmDestination;
begin
   if  (treeFiles.SelectionCount > 1) then
   begin
      Form := TFrmDestination.Create(self);
      if DirectoryExists(Options.ExtractDirectory) then
         Form.Directory.Directory := Options.ExtractDirectory;

      Form.ShowModal;
      if Form.Changed then
      begin
         Options.ExtractDirectory := Form.Directory.Directory;
         for Index := 0 to (treeFiles.SelectionCount - 1 ) do
         begin
    	      FileIndex := Integer(TreeFiles.Selections[Index].Data);
            if (FileIndex <> -1 ) then
            begin
               MyFileInfo := CurrentFile.GetFileInfo(FileIndex);
               CurrentFile.GetFileContents(FileIndex,Data,DataSize);
               Data.Seek(0,soFromBeginning);
               if Options.OptSaveFullDir then
                  MyFilename := Form.Directory.Directory + '\' + MyFileInfo.Filename
               else
                  MyFilename := Form.Directory.Directory + '\' + ExtractFileName(MyFileInfo.Filename);

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
      Index := Integer(treeFiles.Selected.Data);    // data is abused to store the file index // D.van Loon
      if DirectoryExists(Options.ExtractDirectory) then
         SaveDialog.InitialDir := Options.ExtractDirectory;

      SaveDialog.Filter := Language.GetString('Common','AllFiles') + '|*.*';
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

procedure TFrmBIGMain.EditNewDirectoryExecute(Sender: TObject);
var
   Node : TTreeNode;
   NewDirString : string;
begin
   // Let's add a new directory at the next simblings.
   NewDirString := Language.GetString('MainMenu','NewDirectory');
   if TreeFiles.Selected <> nil then
   begin
      if TreeFiles.Selected.ImageIndex <> 0 then
      begin
         Node := TreeFiles.items.AddFirst(TreeFiles.Selected,NewDirString);
      end
      else
      begin
         Node := TreeFiles.items.AddChildFirst(TreeFiles.Selected,NewDirString);
      end;
   end
   else
   begin
      Node := TreeFiles.items.AddFirst(nil,NewDirString);
   end;
   LockWindowUpdate(TreeFiles.Handle);
   ReOrderNode(Node,NewDirString);
   LockWindowUpdate(0);
   Node.EditText;
end;

procedure TFrmBIGMain.EditOpenExecute(Sender: TObject);
var
   MyFileInfo  : TBIGFileUnit;
begin
   // Let's check the selection.
   if TreeFiles.Selected <> nil then
   begin
      if TreeFiles.Selected.ImageIndex <> 0 then
      begin
         // We have a valid file. Is it already in the hard disk or temp file?
         if not CurrentFile.IsFileEditable(uint32(TreeFiles.Selected.Data)) then
         begin
            CurrentFile.ExtractFileToTemp(uint32(TreeFiles.Selected.Data));
         end;

         // Now, we open with the default program
         MyFileInfo := CurrentFile.GetFileInfo(uint32(TreeFiles.Selected.Data));
         OpenHyperlink(PAnsiChar(MyFileInfo.ExternalFileLocation));
      end;
   end;
end;

procedure TFrmBIGMain.EditOpenWithNotepadExecute(Sender: TObject);
var
   MyFileInfo  : TBIGFileUnit;
begin
   // Let's check the selection.
   if (TreeFiles.Selected <> nil) and (FileExists(Options.OptNotepadAddress)) then
   begin
      if TreeFiles.Selected.ImageIndex <> 0 then
      begin
         // We have a valid file. Is it already in the hard disk or temp file?
         if not CurrentFile.IsFileEditable(uint32(TreeFiles.Selected.Data)) then
         begin
            CurrentFile.ExtractFileToTemp(uint32(TreeFiles.Selected.Data));
         end;

         // Now, we open with Notepad.
         MyFileInfo := CurrentFile.GetFileInfo(uint32(TreeFiles.Selected.Data));
         OpenProgram(PAnsiChar(Options.OptNotepadAddress),PAnsiChar(TreatLink(MyFileInfo.ExternalFileLocation)));
      end;
   end;
end;

procedure TFrmBIGMain.EditPaste1Execute(Sender: TObject);
var
   Dest : TTreeNode;
   Source : array of TTreeNode;
   i : uint32;
begin
   // Let's paste here.
   if not TreeFiles.IsEditing then
   begin
      if TreeFiles.Selected <> nil then
      begin
         if SelectedNodes.GetNumNodes > 0 then
         begin
            Dest := TreeFiles.Selected;
            i := 0;
            SetLength(Source,SelectedNodes.GetNumNodes);
            while i < SelectedNodes.GetNumNodes do
            begin
               Source[i] := SelectedNodes.Nodes[i];
               inc(i);
            end;
            if Dest.ImageIndex <> 0 then
               Dest := Dest.Parent;
            case SelectOp of
               C_SEL_COPY: CopyNodes(Dest,Source);
               C_SEL_MOVE: MoveNodes(Dest,Source);
            end;
            SelectedNodes.Reset;
            SelectOp := C_SEL_NONE;
            UpdateTreeFiles;
            SetLength(Source,0);
         end;
      end;
   end;
end;

procedure TFrmBIGMain.EditRenameExecute(Sender: TObject);
begin
   // Let's rename files here.
   if TreeFiles.Selected <> nil then
   begin
      TreeFiles.Selected.EditText;
   end;
end;

procedure TFrmBIGMain.EditViewAsTextExecute(Sender: TObject);
begin
   ViewAsText := not ViewAsText;
   TreeFilesClick(Sender);
end;

procedure TFrmBIGMain.EditExtractAllExecute(Sender: TObject);
var
   Data        : TStream;
   DataSize    : uint32;
   Index       : uint32;
   MyFileInfo  : TBIGFileUnit;
   MyFile      : TStream;
   Form        : TFrmDestination;
   MyFileName  : string;
   MyDirectory : string;
begin
   Form := TFrmDestination.Create(self);
   Form.ShowModal;
   if Form.Changed then
   begin
      Options.ExtractAllDirectory := Form.Directory.Directory;
      for Index := 0 to CurrentFile.GetNumFiles-1 do
      begin
         MyFileInfo := CurrentFile.GetFileInfo(Index);
         CurrentFile.GetFileContents(Index,Data,DataSize);
         Data.Seek(0,soFromBeginning);

         if Options.OptSaveFullDir then
            MyFilename := Form.Directory.Directory + '\' + MyFileInfo.Filename
         else
            MyFilename := Form.Directory.Directory + '\' + ExtractFileName(MyFileInfo.Filename);

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

procedure TFrmBIGMain.EditAddDirectoryExecute(Sender: TObject);
var
   Form        : TFrmDestination;
   NumFiles    : uint32;
   FirstFileID : uint32;
   i           : uint32;
   iFile       : TBIGFileUnit;
begin
   Form := TFrmDestination.Create(self);
   Form.BtNewDir.Visible := false;
   Form.ShowModal;
   Form.Caption := Language.GetString('Destination','Directory');
   if Form.Changed then
   begin
      if DirectoryExists(IncludeTrailingBackSlash(Form.Directory.Directory)) and (not FileExists(IncludeTrailingBackSlash(Form.Directory.Directory))) then
      begin
         FirstFileID := CurrentFile.GetNumFiles;
         NumFiles := AddDirectoriesToBIG(IncludeTrailingBackSlash(Form.Directory.Directory),IncludeTrailingBackSlash(Form.Directory.Directory));
         if NumFiles > 0 then
         begin
            LockWindowUpdate(TreeFiles.Handle);
            for i := 0 to (NumFiles - 1) do
            begin
               iFile := CurrentFile.GetFileInfo(FirstFileID + i);
               AddFile(iFile.Filename,FirstFileID + i);
            end;
             treeFiles.CustomSort(@treeSort,0);
            UpdateTreeFiles;
            LockWindowUpdate(0);
         end;
      end;
   end;
   Form.Release;
end;

procedure TFrmBIGMain.EditCopy1Execute(Sender: TObject);
var
   i : uint32;
begin
   if not TreeFiles.IsEditing then
   begin
      if TreeFiles.SelectionCount > 0 then
      begin
         i := 0;
         while i < TreeFiles.SelectionCount do
         begin
            SelectedNodes.AddNode(TreeFiles.Selections[i]);
            inc(i);
         end;
         SelectOp := C_SEL_COPY;
      end
      else
      begin
         SelectedNodes.Reset;
      end;
   end;
end;

procedure TFrmBIGMain.EditCut1Execute(Sender: TObject);
var
   i : uint32;
begin
   if not TreeFiles.IsEditing then
   begin
      if TreeFiles.SelectionCount > 0 then
      begin
         SelectOp := C_SEL_MOVE;
         i := 0;
         while i < TreeFiles.SelectionCount do
         begin
            SelectedNodes.AddNode(TreeFiles.Selections[i]);
            TreeFiles.Selections[i].Cut := true;
            inc(i);
         end;
      end
      else
      begin
         SelectedNodes.Reset;
         SelectOp := C_SEL_NONE;
      end;
   end;
end;

procedure TFrmBIGMain.EditDeleteSelectedFilesExecute(Sender: TObject);
begin
   DeleteSelectedFiles;
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

procedure TFrmBIGMain.OptionsRealTimeEditionExecute(Sender: TObject);
begin
   SetRealTimeEdition(not Options.OptRealTimeEdition);
end;

/////////////////////////////////////////////////////////////////
// Important Note from Banshee:                                //
/////////////////////////////////////////////////////////////////
// This section is the minimum that I can get for my efforts.  //
// Do not remove this from the program! Never!!!               //
/////////////////////////////////////////////////////////////////

// And also, people need to know where they should get updated versions and support for the program.
procedure TFrmBIGMain.ContentsItemClick(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/index.php?go=osbigeditorhelp'));
end;

procedure TFrmBIGMain.SupportForumsItemClick(Sender: TObject);
begin
   OpenHyperlink(PChar('http://cnceditingtools.ppmsite.com/'));
end;

procedure TFrmBIGMain.GetUpdatesItemClick(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/index.php?go=osbigeditorinfo'));
end;

// This is the local language support item
procedure TFrmBIGMain.MyLanguageSupportForumsItemClick(Sender: TObject);
begin
   OpenHyperlink(PChar(AnsiString(Language.GetString('MainMenu','MyLanguageSupportForumLink'))));
end;

procedure TFrmBIGMain.SVNItemClick(Sender: TObject);
begin
   OpenHyperlink(PChar('http://svn.ppmsite.com/listing.php?repname=OS%20Big%20Editor&path=%2F&sc=1'));
end;



// Drag And Drop Support Goes here
procedure TFrmBIGMain.OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat; Index: integer; out AStream: IStream);
var
   Data      : TStream;
   DataSize  : uint32;
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

// Danny von Loon code starts here.
// -----------------------------------------------------------------------------
//							drag-droppage 05-03-07
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.treeFilesMouseDown(Sender: TObject; Button: TMouseButton;    //14-03-07
  Shift: TShiftState; X, Y: Integer);
begin
	if (Button = mbLeft) then
  	   MouseLmbDown := true;
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.treeFilesMouseMove(Sender: TObject;                         //14-03-07
  Shift: TShiftState; X, Y: Integer);
const
   C_CORNER_LIMIT = 20;
begin
	if MouseLmbDown then
   begin
  	   MouseIsDragging := true;
      TreeFiles.DragMode := dmAutomatic;
   end
   else
      MouseIsDragging := false;

   if MouseIsDragging and not InitiatedDrag then
   begin
      // Banshee change here to fix the drag and drop.
  	   InitiatedDrag := true;
      if (DragDetectPlus(Handle,Point(x,y))) then
      begin
         InitiateDrag;
      end;
      DropEmptySource.Execute;
      InitiatedDrag := false;
      MouseIsDragging := false;
      MouseLmbDown := false;
      treeFilesClick(sender);
      // Banshee changes ends here.
   end;
end;
//------------------------------------------------------------------------------
procedure TFrmBIGMain.treeFilesMouseUp(Sender: TObject;                           //14-03-07
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	if (Button >= mbLeft) then
  	   MouseLmbDown := false;
   MouseIsDragging := false;
end;
// -----------------------------------------------------------------------------
// Danny van Loon code starts here.
// -----------------------------------------------------------------------------
//							drag-droppage 05-03-07
// -----------------------------------------------------------------------------
//							Treeview dragging 14-03-07
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.InitiateDrag;
var
   i,total : uint32;
   node :TTreeNode;
   level : int32;
   SelectableNodes : array of TTreeNode;
   DesselectableNodes : array of TTreeNode;
begin
   // Transfer the file names to the data format. The content will be extracted
   // by the target on-demand.
   with TVirtualFileStreamDataFormat(DataFormatAdapter.DataFormat) do
   begin
  	   FileNames.Clear;
      SetLength(DropIDs,0);
      total := 0;
      SetLength(SelectableNodes,0);
      SetLength(DesselectableNodes,0);

      for i:= 0 to (treeFiles.SelectionCount -1) do
      begin
         if (treeFiles.Selections[i].ImageIndex <> 0) then
         begin
            if Options.OptSaveFullDir then
        	      FileNames.Add(GetFullFilename(treeFiles.Selections[i]))
            else
        	      FileNames.Add(treeFiles.Selections[i].Text);

            inc(total);
            SetLength(DropIDs,total);
            DropIDs[total-1] := Integer(treeFiles.Selections[i].data); // data points to the actual index
         end
         else //else its a directory, perhaps add directory support
         begin
            // Banshee's directory support starts here.
            level := TreeFiles.Selections[i].Level;
            node := TreeFiles.Selections[i].getFirstChild;
            while node <> nil do
            begin
               if node.Level > level then
               begin
                  if (node.ImageIndex <> 0) then
                  begin
                     SetLength(SelectableNodes,High(SelectableNodes)+2);
                     SelectableNodes[High(SelectableNodes)] := node;
                     if Options.OptSaveFullDir then
           	            FileNames.Add(GetFullFilename(node))
                     else
        	               FileNames.Add(node.Text);

                     inc(total);
                     SetLength(DropIDs,total);
                     DropIDs[total-1] := Integer(node.data); // data points to the actual index
                  end;
                  node := node.getNext;
               end
               else // get out of the loop.
                  node := nil;
            end;
            SetLength(DesselectableNodes,High(DesselectableNodes)+2);
            DesselectableNodes[High(DesselectableNodes)] := TreeFiles.Selections[i];
         end;
      end;
   end;

   if High(SelectableNodes) >= 0 then
      for i := 0 to High(SelectableNodes) do
         SelectableNodes[i].Selected := true;

   if High(DesselectableNodes) >= 0 then
      for i := 0 to High(DesselectableNodes) do
         DesselectableNodes[i].Selected := false;
end;
// -----------------------------------------------------------------------------
function TFrmBIGMain.AddDirectoriesToBIG (const _Directory, _BaseDir, _ArchiveDir : string): uint32;
var
   DirFile : TSearchRec;
   Name : string;
begin
   Result := 0;
   if FindFirst(IncludeTrailingBackslash(_Directory) + '*.*',faAnyFile,DirFile) = 0 then
   begin
      repeat
         if (DirFile.Attr and $FF) <> faDirectory then
         begin
            Name := IncludeTrailingBackslash(_Directory) + DirFile.Name;
            if FileExists(Name) then
            begin
               if CurrentFile.AddFile(Name,_BaseDir,_ArchiveDir) then
               begin
                  inc(Result);
               end;
            end;
         end
         else if (Length(DirFile.Name) > 0) and (CompareStr(DirFile.Name,'..') <> 0) and (CompareStr(DirFile.Name,'.') <> 0) then
         begin
            inc(Result,AddDirectoriesToBIG(IncludeTrailingBackSlash(_Directory) + DirFile.Name, _BaseDir,_ArchiveDir));
         end;
      until FindNext(DirFile) <> 0;
   end;
end;

procedure TFrmBIGMain.AcceptFiles( var msg : TMessage );
const
   cnMaxFileNameLen = 255;
var
   i,
   nCount,addCount     : integer;
   acFileName : array [0..cnMaxFileNameLen] of char;
   FileExt : string;
   BaseDir : string;
   CurrentDir : string;
   FirstFileID : int32;
   iFile : TBIGFileUnit;
   Node : TTreeNode;
begin
   // find out how many files we're accepting
   nCount := DragQueryFile( msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen );

   if nCount > 0 then
   begin
      // query Windows one at a time for the file name
      addCount := 0;
      FirstFileID := CurrentFile.GetNumFiles;
      DragQueryFile( msg.WParam, 0, acFileName, cnMaxFileNameLen );
      BaseDir := ExtractFileDir(acFileName);

      if TreeFiles.SelectionCount > 0 then
      begin
         if TreeFiles.Selected.Level > 0 then
         begin
            CurrentDir := IncludeTrailingBackslash(ExtractFileDir(GetFullFilename(TreeFiles.Selected)));
         end
         else
         begin
            CurrentDir := '';
         end;
      end
      else
      begin
         CurrentDir := '';
      end;

      for i := 0 to nCount-1 do
      begin
         DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );
         // do your thing with the acFileName
         FileExt := Ansilowercase(ExtractFileExt(acFilename));
         if (CompareStr(FileExt,'big') = 0) and  (addCount = 0) then
         begin
            LoadBIGFile(acFileName);
            exit;
         end
         else if IsDirectory(acFileName) then
         begin
            // This is supposed to be a directory.
            inc(addCount,AddDirectoriesToBIG(acFilename,BaseDir,CurrentDir));
         end
         else // Now, we add files to the current .BIG file.
         begin
            CurrentFile.AddFile(acFilename,BaseDir,CurrentDir);
            inc(addCount);
         end;
      end;

      if addCount > 0 then
      begin
         LockWindowUpdate(TreeFiles.Handle);
         for i := 0 to (addCount - 1) do
         begin
            iFile := CurrentFile.GetFileInfo(FirstFileID + i);
            Node := AddFile(iFile.Filename,FirstFileID + i);
            ReOrderNode(Node,iFile.Filename);
         end;
         LockWindowUpdate(0);
         treeFiles.CustomSort(@treeSort,0);
         UpdateTreeFiles;
      end;
   end;

   // let Windows know that you're done
   DragFinish( msg.WParam );
end;
// -----------------------------------------------------------------------------
//							Tree View helper code
// -----------------------------------------------------------------------------
function TFrmBIGMain.AddFile(filename: String;fileIndex:Integer): TTreeNode;
var
  tempList:TStringList;
  title,MyDir:String;
  i :int32;
  parent,node: TTreeNode;
begin
   tempList := TStringList.Create;
   parent := nil;
   // Here we check if the file should be added.
   if CurrentFile.IsFileValid(FileIndex) and (not CurrentFile.IsFileRepetition(FileIndex)) then
   begin
      try
         MyDir := IncludeTrailingBackSlash(ExtractFileDir(filename));
         if CompareStr(MyDir,FileLastDirName) <> 0 then
         begin
            // Old code from Danny Van Loon returns here
            FileLastDirName := MyDir;
            ExtractStrings(['/','\'],[],PChar(filename),tempList);

            // Banshee's edition starts here. This function will no longer
            // checks for repetitions of the final string. The if in the top
            // already does that in a much faster speed (binary search pwnz
            // sequential search on ordered vectors).
            if TempList.Count > 1 then
            begin
               for i:= 0 to (tempList.Count - 2) do
               begin
                  // Danny van Loon's code return here.
                  title := tempList.Strings[i];
    	            node 	:= FindNode(parent,title);
                  //node does not exist.. add node
                  if (node = nil) then
                  begin
                     // Minor edit from Banshee: ChildFirst, because we only sort it in the end.
      	            parent := TreeFiles.Items.AddChildFirst(parent,title);
                     //get the image Icon
                     parent.ImageIndex := 0;
                     parent.SelectedIndex := parent.ImageIndex ;
                     parent.Data	:= TObject(fileIndex);
                     //else, node exists.
                  end
                  else
                  begin
           	         parent := node;
                  end;
               end;
            end;
            FileLastDirNode := parent;
            // cheap copy and paste and adaptation from the code above.
            title := tempList.Strings[tempList.Count - 1];
         end
         else
         begin
            parent := FileLastDirNode;
            if parent = nil then
            begin
               title := filename;
            end
            else
            begin
               title := copy(filename,Length(MyDir)+1,Length(filename) - Length(MyDir));
            end;
         end;
 	      parent := TreeFiles.Items.AddChildFirst(parent,title);
         //get the image Icon
         parent.ImageIndex := iconHelper.GetImageIndex(title);
         if parent.ImageIndex = 0 then
         begin
            // minor bug fix when a file is detected as a directory
            parent.ImageIndex := 1;
         end;
         parent.SelectedIndex := parent.ImageIndex ;
         parent.Data	:= TObject(fileIndex);
         // Danny's code return here.
      finally
         tempList.Free;
      end;
   end;
   Result := parent;
end;
// -----------------------------------------------------------------------------
function TFrmBIGMain.FindNode(parent:TTreeNode;title: String): TTreeNode;
begin
   //determine the parent
	Result := nil;
   if Parent = nil then
   begin
  	   if treeFiles.Items.GetFirstNode <> nil then
	  	   Result := treeFiles.Items.GetFirstNode;
   end
   else
  	   Result := parent.getFirstChild;

   while (Result <> nil) do
   begin
      if AnsiCompareText(Result.Text, title) = 0 then
      begin
         exit;
  	   end;
      Result := Result.getNextSibling;
   end;
end;
// -----------------------------------------------------------------------------
function TFrmBIGMain.GetFullFilename(aNode: TTreeNode): String;
var
   current:TtreeNode;
begin
   current := aNode;
   if (current = nil) then
   begin
  	   Result := '';
      exit;
   end;

   Result := current.Text;
   current := current.Parent;

   while (current <> nil) do
   begin
      Result := current.Text + '\' + Result;
  	   current := current.Parent;
   end;
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.mniExpandSelClick(Sender: TObject);
var
	i:Integer;
begin
   if treeFiles.SelectionCount = 0 then exit;

	for i:=0 to (treeFiles.SelectionCount - 1 ) do
  	   treeFiles.Selections[i].Expand(true);
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.mniCollapseSelClick(Sender: TObject);
var
	i:Integer;
begin
   if treeFiles.SelectionCount = 0 then exit;

  	for i:=0 to (treeFiles.SelectionCount - 1 ) do
  	   treeFiles.Selections[i].Collapse(true);
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.mniExpandAllClick(Sender: TObject);
begin
	treeFiles.FullExpand;
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.mniCollapseAllClick(Sender: TObject);
begin
	treeFiles.FullCollapse;
end;
// -----------------------------------------------------------------------------
procedure TFrmBIGMain.treeFilesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
      VK_F2:
      begin
         if (TreeFiles.Selected <> nil) then
         begin
            TreeFiles.Selected.EditText;
         end;
      end;
      VK_DELETE:
      begin
         if (TreeFiles.Selected <> nil) then
         begin
            if (not TreeFiles.IsEditing) then
            begin
               DeleteSelectedFiles;
            end
         end;
      end

      else
      begin
         TreeFilesClick(Sender);
      end;
   end;
end;

procedure TFrmBIGMain.DeleteADirectory(const _Directory : TTreeNode);
var
   Node : TTreeNode;
   Level : int32;
begin
   // blah blah blah
   Level := _Directory.Level;
   Node := _Directory.getFirstChild;
   while Node <> nil do
   begin
      if Node.Level > Level then
      begin
         if Node.ImageIndex <> 0 then
         begin
            CurrentFile.DeleteFile(int32(Node.Data));
         end;
         Node := Node.GetNext;
      end
      else
         Node := nil;
   end;
end;

procedure TFrmBIGMain.DeleteSelectedFiles;
var
   DelCount,i : uint32;
   DeleteMeList : array of TTreeNode;
begin
   DelCount := 0;
   for i := 0 to (treeFiles.SelectionCount-1) do
   begin
      if treeFiles.Selections[i].ImageIndex <> 0 then
      begin
         CurrentFile.DeleteFile(int32(treeFiles.Selections[i].Data));
         inc(DelCount);
         SetLength(DeleteMeList,DelCount);
         DeleteMeList[High(DeleteMeList)] := treeFiles.Selections[i];
      end
      else
      begin
         DeleteADirectory(treeFiles.Selections[i]);
         inc(DelCount);
         SetLength(DeleteMeList,DelCount);
         DeleteMeList[High(DeleteMeList)] := treeFiles.Selections[i];
      end;
   end;
   if DelCount > 0 then
   begin
      LockWindowUpdate(TreeFiles.Handle);
      for i := 0 to High(DeleteMeList) do
      begin
         DeleteMeList[i].Delete;
      end;
      LockWindowUpdate(0);
      UpdateTreeFiles;
   end;
end;

procedure TFrmBIGMain.CopyNodes(var _Dest: TTreeNode; var _Source: array of TTreeNode);
var
   i,NumNodes : uint32;
   NewDestNode, MyNode : TTreeNode;
begin
   // Lock window. We do not want to waste time refreshing it.
   LockWindowUpdate(TreeFiles.Handle);
   // Now, we start the dirty job.

   // Let's do a recursive Node copying here.
   i := 0;
   NewDestNode := _Dest;
   NumNodes := High(_Source)+1;
   while i < NumNodes do
   begin
      MyNode := CopyNodeWithoutRepetition(_Source[i],NewDestNode);
      CurrentFile.CloneFile(uint32(_Source[i].Data));
      CurrentFile.SetFilename(uint32(_Source[i].Data),GetFullFilename(MyNode));
      CurrentFile.ExtractFileToTemp(uint32(_Source[i].Data));
      inc(i);
   end;

   LockWindowUpdate(0);
end;

procedure TFrmBIGMain.MoveNodes(var _Dest: TTreeNode; var _Source: array of TTreeNode);
var
   NodesToBeDeleted : array of TTreeNode;
   i,NumNodes : uint32;
   NewDestNode, MyNode : TTreeNode;
begin
   // Lock window. We do not want to waste time refreshing it.
   LockWindowUpdate(TreeFiles.Handle);
   // Now, we start the dirty job.

   // Step 1: Save the currently selection scheme.
   i := 0;
   NumNodes := High(_Source)+1;
   SetLength(NodesToBeDeleted,NumNodes);
   while i < NumNodes do
   begin
      NodesToBeDeleted[i] := _Source[i];
      inc(i);
   end;

   // Step 2: Let's do a recursive Node copying here.
   i := 0;
   NewDestNode := _Dest;
   while i < NumNodes do
   begin
      MyNode := CopyNodeWithoutRepetition(_Source[i],NewDestNode);
      CurrentFile.SetFilename(uint32(_Source[i].Data),GetFullFilename(MyNode));
      inc(i);
   end;

   // Step 3: Let's wipe the Selected Nodes.
   if High(NodesToBeDeleted) >= 0 then
   begin
      for i := Low(NodesToBeDeleted) to High(NodesToBeDeleted) do
      begin
         if Assigned(NodesToBeDeleted[i]) then
            NodesToBeDeleted[i].Delete;
      end;
   end;
   LockWindowUpdate(0);
end;

function TFrmBIGMain.GetFirstSibling(const Node : TTreeNode): TTreeNode;
begin
   if Node.Level > 0 then
   begin
      // If it is not root, get the first child of he parent.
      Result := Node.Parent.getFirstChild;
   end
   else
   begin
      // if it is root node, get the first item.
      Result := TreeFiles.Items.GetFirstNode;
   end;
end;

procedure TFrmBIGMain.ReOrderNode(var Node : TTreeNode; const NodeNewName : string);
var
   MyNode, PrevNode : TTreeNode;
begin
   // Now that we renamed the Node, we need to re-order the Node in the TreeView.
   // Let's get the first child of the parent node.
   MyNode := GetFirstSibling(Node);
   // and the parent.
   PrevNode := Node.Parent;
   // Here we have two situations: normal files and paste files.
   if Node.ImageIndex <> 0 then
   begin
      // Files need to be ordered according to other files.
      while MyNode <> nil do
      begin
         if (MyNode.ImageIndex <> 0) then
         begin
            PrevNode := MyNode;
            if (MyNode <> Node) and (CompareStr(LowerCase(NodeNewName),LowerCase(MyNode.Text)) < 0) then
            begin
               Node.MoveTo(MyNode,NaInsert);
               LockWindowUpdate(0);
               exit;
            end;
         end;
         MyNode := MyNode.getNextSibling;
      end;
   end
   else
   begin
      // Directories need to be ordered according to other directories.
      while MyNode <> nil do
      begin
         if (MyNode.ImageIndex = 0) then
         begin
            if (MyNode <> Node) then
            begin
               PrevNode := MyNode;
               if (CompareStr(LowerCase(NodeNewName),LowerCase(MyNode.Text)) < 0) then
               begin
                  Node.MoveTo(MyNode,NaInsert);
                  LockWindowUpdate(0);
                  exit;
               end;
            end;
         end;
         MyNode := MyNode.getNextSibling;
      end;
   end;
   if PrevNode <> nil then
   begin
      if PrevNode <> Node.Parent then
      begin
         if PrevNode.getNextSibling <> nil then
            Node.MoveTo(PrevNode.getNextSibling,NaInsert)
         else
            Node.MoveTo(PrevNode,NaAdd);
      end
      else
      begin
         Node.MoveTo(Node.Parent,NaAddChildFirst);
      end;
   end
   else
      Node.MoveTo(TreeFiles.TopItem,NaAdd);
end;

end.

