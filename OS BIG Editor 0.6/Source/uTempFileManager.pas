(*******************************************************************************
 * Author  Banshee
 *
 * Date    14/02/2008
 *
 * Copyright
 ******************************************************************************)
unit uTempFileManager;

interface

Uses Windows, SysUtils, BasicDataTypes;

type
   TTempFileUnit = record
      Valid : boolean;
      FileLocation : string;
   end;

   CTempFileManager = class
      private
         FFiles : array of TTempFileUnit;
         procedure DeleteMyFile(_ID : int32);
         procedure AddMyFile(const _Location : string);
         procedure MoveUpFiles(_ID : int32);
      protected
         function GetFile(_ID: uint32): TTempFileUnit;
         function GetCount: uint32;
         function GetLastFileID: uint32;
      public
         // Properties
         property Files[Ind: uint32]:TTempFileUnit read GetFile; default;
         property Count: uint32 read GetCount;
         property Last: uint32 read GetLastFileID;
         // Constructors
         constructor Create;
         procedure Reset;
         destructor Destroy; override;
         // Removes
         function DeleteFile(_ID : int32): boolean;
         // Adds
         function AddFile(const _Location: string): Boolean;
   end;

implementation

// constructors
constructor CTempFileManager.Create;
begin
   SetLength(FFiles,0);
end;

destructor CTempFileManager.Destroy;
begin
   Reset;
   inherited Destroy;
end;

procedure CTempFileManager.Reset;
var
   i : uint32;
begin
   if High(FFiles) > -1 then
   begin
      for i := High(FFiles) downto Low(FFiles) do
      begin
         DeleteMyFile(i);
      end;
   end;
   SetLength(FFiles,0);
end;

// Gets
function CTempFileManager.GetFile(_ID: uint32): TTempFileUnit;
begin
   Result := FFiles[_ID];
end;

function CTempFileManager.GetCount: uint32;
begin
   Result := High(FFiles)+1;
end;

function CTempFileManager.GetLastFileID: uint32;
begin
   Result := High(FFiles);
end;

// Removes
function CTempFileManager.DeleteFile(_ID: int32): boolean;
begin
   if (_ID <= High(FFiles)) then
   begin
      DeleteMyFile(_ID);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

procedure CTempFileManager.DeleteMyFile(_ID : int32);
begin
   if FileExists(FFiles[_ID].FileLocation) then
   begin
      SysUtils.DeleteFile(FFiles[_ID].FileLocation);
   end;
   MoveUpFiles(_ID);
   SetLength(FFiles,High(FFiles));
end;

// Adds
function CTempFileManager.AddFile(const _Location: string): Boolean;
begin
   if FileExists(_Location) then
   begin
      AddMyFile(_Location);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

procedure CTempFileManager.AddMyFile(const _Location: string);
begin
   SetLength(FFiles,High(FFiles)+2);
   FFiles[High(FFiles)].FileLocation := copy(_Location,1,Length(_Location));
   FFiles[High(FFiles)].Valid := true;
end;


// Misc
procedure CTempFileManager.MoveUpFiles(_ID : int32);
var
   i : int32;
begin
   i := _ID;
   while i < High(FFiles) do
   begin
      FFiles[i].Valid := FFiles[i+1].Valid;
      FFiles[i].FileLocation := '';
      FFiles[i].FileLocation := copy(FFiles[i+1].FileLocation,1,Length(FFiles[i+1].FileLocation));
      inc(i);
   end;
end;

end.
