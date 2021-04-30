unit BasicOptions;

interface

uses SysUtils, BasicDataTypes, Classes;

const
   OPTIONS_VERSION = '2.0';

type
   TOptions = class
      public
         // Option Variables
         OptPreviewImages : Boolean;
         OptWordWrap : Boolean;
         OptSaveFullDir : Boolean;
         // Directories
         OpenDirectory : string;
         SaveDirectory : string;
         ExtractDirectory : string;
         ExtractAllDirectory : string;
         OldBIGRegSettings : string;
         OldBIGExplorerRegSettings : string;
         // Options Place on your HD
         Filename : string;

         // Constructors and Destructors
         constructor Create(const _Filename : string);
         destructor Destroy; override;
         procedure Reset;
         // I/O
         procedure Load;
         procedure Save;
         // Gets
         function GetString(var _PCurrentData : puint8): string;
         function GetBoolean(_Data,_CompareFactor : uint8) : Boolean;
         // Sets
         procedure SetString(var _PCurrentData : puint8; const _Data : string);
         procedure SetBoolean(var _PCurrentData : puint8; const _CompareFactor : uint8);
      private
   end;

implementation

// Constructors and Destructors
constructor TOptions.Create(const _Filename: string);
begin
   Filename := _Filename;
   if FileExists(Filename) then
      Load
   else
      Reset;
end;

destructor TOptions.Destroy;
begin
   Save;
   inherited Destroy;
end;

procedure TOptions.Reset;
begin
   OptPreviewImages := true;
   OptWordWrap := false;
   OptSaveFullDir := true;
   OpenDirectory := '';
   SaveDirectory := '';
   ExtractDirectory := '';
   ExtractAllDirectory := '';
   OldBIGRegSettings := '';
   OldBIGExplorerRegSettings := '';
end;

// I/O
procedure TOptions.Load;
var
   OptionsFile : TStream;
   FileSize : uint32;
   PData, PCurrentData: puint8;
   Version : string;
begin
   OptionsFile := TFileStream.Create(Filename, fmOpenRead);
   FileSize := OptionsFile.Size;
   if Filesize > 3 then
   begin
      Getmem(PData, FileSize);
      PCurrentData := PData;
      OptionsFile.Read(PData^, FileSize);
      OptionsFile.Free;
      Version := GetString(PCurrentData);
      if CompareStr(Version,OPTIONS_VERSION) = 0 then
      begin
         // Load boolean variables
         OptPreviewImages := GetBoolean(PCurrentData^,1);
         OptWordWrap := GetBoolean(PCurrentData^,2);
         OptSaveFullDir := GetBoolean(PCurrentData^,4);
         inc(PCurrentData,1);
         // Load Directories
         OpenDirectory := GetString(PCurrentData);
         SaveDirectory := GetString(PCurrentData);
         ExtractDirectory := GetString(PCurrentData);
         ExtractAllDirectory := GetString(PCurrentData);
         OldBIGRegSettings := GetString(PCurrentData);
         OldBIGExplorerRegSettings := GetString(PCurrentData);
      end
      else
         Reset;
   end
   else
      Reset;
end;

procedure TOptions.Save;
var
   OptionsFile : TStream;
   FileSize : uint32;
   PData, PCurrentData: puint8;
begin
   // The 8 below is the amount of strings (7) + 1 byte from the boolean settings.
   FileSize := Length(OPTIONS_VERSION) + 8 + Length(OpenDirectory) + Length(SaveDirectory) + Length(ExtractDirectory) + Length(ExtractAllDirectory) + Length(OldBIGRegSettings) + Length(OldBIGExplorerRegSettings);
   OptionsFile := TFileStream.Create(Filename,fmCreate);
   GetMem(PData,FileSize);
   PCurrentData := PData;
   SetString(PCurrentData,OPTIONS_VERSION);
   PCurrentData^ := 0;
   if OptPreviewImages then
      SetBoolean(PCurrentData,1);
   if OptWordWrap then
      SetBoolean(PCurrentData,2);
   if OptSaveFullDir then
      SetBoolean(PCurrentData,4);
   inc(PCurrentData);
   SetString(PCurrentData,OpenDirectory);
   SetString(PCurrentData,SaveDirectory);
   SetString(PCurrentData,ExtractDirectory);
   SetString(PCurrentData,ExtractAllDirectory);
   SetString(PCurrentData,OldBIGRegSettings);
   SetString(PCurrentData,OldBIGExplorerRegSettings);
   OptionsFile.WriteBuffer(PData^,FileSize);
   OptionsFile.Free;
end;

// Gets
function TOptions.GetString(var _PCurrentData : puint8): string;
begin
   Result := '';
   while (_PCurrentData^ <> 0) do
   begin
      Result := Result + char(_PCurrentData^);
      inc(_PCurrentData,1);
   end;
   inc(_PCurrentData,1);
end;

function TOptions.GetBoolean(_Data,_CompareFactor : uint8) : Boolean;
begin
   if (_Data and _CompareFactor) > 0 then
      Result := true
   else
      Result := false;
end;

// Sets
procedure TOptions.SetString(var _PCurrentData : puint8; const _Data : string);
var
   i : uint32;
begin
   // write string contents
   if Length(_Data) > 0 then
      for i := 1 to Length(_Data) do
      begin
         _PCurrentData^ := Uint8(_Data[i]);
         inc(_PCurrentData);
      end;
   // write 0;
   _PCurrentData^ := 0;
   inc(_PCurrentData);
end;

procedure TOptions.SetBoolean(var _PCurrentData : puint8; const _CompareFactor : uint8);
begin
   _PCurrentData^ := _PCurrentData^ or _CompareFactor;
end;

end.
