(*******************************************************************************
 * Author    Banshee
 *
 * Date      Unknown
 *
 * Copyright   This file was heavily modified by igi for INI support.
 ******************************************************************************)
unit BasicOptions;

interface

uses
   SysUtils, BasicDataTypes, Classes, INIFiles, BasicConstants;

const
   OPTIONS_VERSION = '2.1';

type
   TOptions = class
   public
      // Option Variables
      OptSaveFullDir      : boolean;
      OptRealTimeEdition  : boolean;
      // Directories
      OpenDirectory       : string;
      SaveDirectory       : string;
      ExtractDirectory    : string;
      ExtractAllDirectory : string;
      OldBIGRegSettings   : string;
      OldBIGExplorerRegSettings : string;
      Language            : string;
      // Browser variables
      OptPreviewImages    : boolean;
      OptWordWrap         : boolean;
      OptMaxBinarySize    : uint32;
      OptDefBinDecision   : uint32;
      OptNotepadAddress   : string;

      // Options Place on your HD
      Filename : string;

      // Constructors and Destructors
      constructor Create(const _Filename : string);
      destructor  Destroy; override;
      procedure   Reset;
      // I/O
      procedure Load;
      procedure Save;
   private

   end;

implementation


// Constructors and Destructors
constructor TOptions.Create(const _Filename: string);
begin
   Filename := _Filename;
   if FileExists(Filename) then
   begin
      Load;
   end
   else
   begin
      Reset;
   end;
end;


destructor TOptions.Destroy;
begin
   Save;
   inherited Destroy;
end;


procedure TOptions.Reset;
begin
   OptPreviewImages    := true;
   OptWordWrap         := false;
   OptSaveFullDir      := true;
   OptRealTimeEdition  := false;
   OpenDirectory       := '';
   SaveDirectory       := '';
   ExtractDirectory    := '';
   ExtractAllDirectory := '';
   OldBIGRegSettings   := '';
   OldBIGExplorerRegSettings := '';
   Language            := 'English';
   OptMaxBinarySize    := C_OPT_MAX_BINARY_SIZE;
   OptDefBinDecision   := C_FBW_USER;
   OptNotepadAddress   := '';
end;


procedure TOptions.Load;
var
   OptionsFile : TINIFile;
begin
   if (FileExists(Filename)) then
   begin
      OptionsFile := TINIFile.Create(Filename);
      try
         OptionsFile.ReadString('Settings', 'Version', OPTIONS_VERSION);
         OptPreviewImages          := OptionsFile.ReadBool('Settings', 'PreviewImages', true);
         OptWordWrap               := OptionsFile.ReadBool('Settings', 'WordWrap', false);
         OptSaveFullDir            := OptionsFile.ReadBool('Settings', 'SaveFullDir', true);
         OptRealTimeEdition        := OptionsFile.ReadBool('Settings', 'RealTimeEdition', false);
         OpenDirectory             := OptionsFile.ReadString('Settings', 'OpenDirectory', '');
         SaveDirectory             := OptionsFile.ReadString('Settings', 'SaveDirectory', '');
         ExtractDirectory          := OptionsFile.ReadString('Settings', 'ExtractDirectory', '');
         ExtractAllDirectory       := OptionsFile.ReadString('Settings', 'ExtractAllDirectory', '');
         OldBIGRegSettings         := OptionsFile.ReadString('Settings', 'OldBIGRegSettings', '');
         OldBIGExplorerRegSettings := OptionsFile.ReadString('Settings', 'OldBIGExplorerRegSettings', '');
         Language                  := OptionsFile.ReadString('Settings', 'Language', 'English');
         OptMaxBinarySize          := OptionsFile.ReadInteger('Settings', 'MaxBinaryBrowsableSize', C_OPT_MAX_BINARY_SIZE);
         OptDefBinDecision         := OptionsFile.ReadInteger('Settings', 'DefaultBinaryWarningDecision', C_FBW_USER);
         OptNotepadAddress         := OptionsFile.ReadString('Settings', 'NotepadAddress', '');
      finally
         FreeAndNil(OptionsFile);
      end;
   end
   else
   begin
      Reset;
   end;
end;


procedure TOptions.Save;
var
   OptionsFile : TINIFile;
begin
   OptionsFile := TINIFile.Create(Filename);
   try
      OptionsFile.WriteString('Settings', 'Version', OPTIONS_VERSION);
      OptionsFile.WriteBool('Settings', 'PreviewImages', OptPreviewImages);
      OptionsFile.WriteBool('Settings', 'WordWrap', OptWordWrap);
      OptionsFile.WriteBool('Settings', 'SaveFullDir', OptSaveFullDir);
      OptionsFile.WriteBool('Settings', 'RealTimeEdition', OptRealTimeEdition);
      OptionsFile.WriteString('Settings', 'OpenDirectory', OpenDirectory);
      OptionsFile.WriteString('Settings', 'SaveDirectory', SaveDirectory);
      OptionsFile.WriteString('Settings', 'ExtractDirectory', ExtractDirectory);
      OptionsFile.WriteString('Settings', 'ExtractAllDirectory', ExtractAllDirectory);
      OptionsFile.WriteString('Settings', 'OldBIGRegSettings', OldBIGRegSettings);
      OptionsFile.WriteString('Settings', 'OldBIGExplorerRegSettings', OldBIGExplorerRegSettings);
      OptionsFile.WriteString('Settings', 'Language', Language);
      OptionsFile.WriteInteger('Settings','MaxBinaryBrowsableSize', OptMaxBinarySize);
      OptionsFile.WriteInteger('Settings','DefaultBinaryWarningDecision', OptDefBinDecision);
      OptionsFile.WriteString('Settings', 'NotepadAddress', OptNotepadAddress);
   finally
      FreeAndNil(OptionsFile);
   end;
end;


end.
