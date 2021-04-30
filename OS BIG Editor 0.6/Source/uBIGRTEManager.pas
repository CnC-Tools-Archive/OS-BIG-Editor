(*******************************************************************************
 * Author  Banshee
 *
 * Date    16/02/2008
 *
 * Copyright
 ******************************************************************************)
unit uBIGRTEManager;

interface

uses uRealTimeEditionManager, BasicDataTypes, BasicConstants;

type
   CBIGRTEManager = class (CRealTimeEditionManager)
      private
         AffectedHeaders : auint32;
         AffectedContents : auint32;
         AddedFiles : auint32;
         DeletedFiles : auint32;
         // Adds
         function AddToVector(_Value : uint32; var _Vector : auint32): boolean;
         // Deletes
         function DeleteFromVector(_Value : uint32; var _Vector : auint32): boolean;
         // Messages
         procedure MessageAdd(_ID: uint32);
         procedure MessageDelete(_ID: uint32);
         procedure MessageContent(_ID: uint32);
         procedure MessageRename(_ID: uint32);
         // Miscelaneous
         function BinaryFileSearch(const _Value : uint32; const _Vector: auint32; _min, _max : int32; var _current,_previous : int32): int32;
         function DoABinaryFileSearch(const _Value : uint32; const _Vector: auint32; var _previous: int32): int32;
         procedure MoveUpValues(_ID : uint32; var _Vector : auint32);
         procedure MoveDownValues(_ID : uint32; var _Vector : auint32);
      public
         // Constructors
         constructor Create; override;
         procedure Reset; override;
         destructor Destroy; override;
         // Adds
         procedure SendMessage(_Type, _ID: uint32); override;
         // Execute
         procedure Execute; override;
   end;

implementation

// Constructors
constructor CBIGRTEManager.Create;
begin
   Reset;
end;

procedure CBIGRTEManager.Reset;
begin
   SetLength(AffectedHeaders,0);
   SetLength(AffectedContents,0);
   SetLength(AddedFiles,0);
   SetLength(DeletedFiles,0);
   inherited Reset;
end;

destructor CBIGRTEManager.Destroy;
begin
   Reset;
   inherited Destroy;
end;

// Adds
procedure CBIGRTEManager.SendMessage(_Type: Cardinal; _ID: Cardinal);
begin
   inherited SendMessage(_Type, _ID);

   // Now, let's process the message.
   case (_Type) of
      C_MSG_ADD:
      begin
         MessageAdd(_ID);
      end;
      C_MSG_DELETE:
      begin
         MessageDelete(_ID);
      end;
      C_MSG_MODIFY_CONTENT:
      begin
         MessageContent(_ID);
      end;
      C_MSG_RENAME:
      begin
         MessageRename(_ID);
      end;
   end;
end;

function CBIGRTEManager.AddToVector(_Value : uint32; var _Vector : auint32): boolean;
var
   Position,Previous : int32;
begin
   // If _Value not in _Vector, add it.
   Result := false;
   if High(_Vector) > -1 then
   begin
      Position := DoABinaryFileSearch(_Value,_Vector,Previous);
      if Position = -1 then
      begin
         SetLength(_Vector,High(_Vector)+2);
         MoveUpValues(Previous+1,_Vector);
         _Vector[Previous+1] := _Value;
         Result := true;
      end;
   end
   else
   begin
      SetLength(_Vector,High(_Vector)+2);
      _Vector[High(_Vector)] := _Value;
      Result := true;
   end;
end;

// Deletes
function CBIGRTEManager.DeleteFromVector(_Value : uint32; var _Vector : auint32): boolean;
var
   Position,Previous : int32;
begin
   // If _Value not in _Vector, add it.
   Result := false;
   if High(_Vector) > -1 then
   begin
      Position := DoABinaryFileSearch(_Value,_Vector,Previous);
      if Position <> -1 then
      begin
         MoveDownValues(Position,_Vector);
         SetLength(_Vector,High(_Vector));
         Result := true;
      end;
   end;
end;

// Messages
procedure CBIGRTEManager.MessageAdd(_ID: uint32);
begin
   // If the file is on the delete list, we cancel the operation. Else, we add to
   // the added list.
   if not DeleteFromVector(_ID,DeletedFiles) then
      AddToVector(_ID,AddedFiles);
end;

procedure CBIGRTEManager.MessageDelete(_ID: uint32);
begin
   // If the file is on the added list, we cancel the operation. Else, we add to
   // the deleted list.
   if not DeleteFromVector(_ID,AddedFiles) then
      AddToVector(_ID,DeletedFiles);
end;

procedure CBIGRTEManager.MessageContent(_ID: uint32);
begin
   // We add to the AffectedHeaders
   AddToVector(_ID,AffectedHeaders);
   // We add it to the AffectedContent.
   AddToVector(_ID,AffectedContents);
end;

procedure CBIGRTEManager.MessageRename(_ID: uint32);
begin
   // We add it to the AffectedHeaders.
   AddToVector(_ID,AffectedHeaders);
end;

// Execute

procedure CBIGRTEManager.Execute;
begin
   // This is in the very end, when things are done.
   Reset;
end;


// Miscelaneous

// Ripped from BIG_File.pas
function CBIGRTEManager.BinaryFileSearch(const _Value : uint32; const _Vector: auint32; _min, _max : int32; var _current,_previous : int32): int32;
var
   Current : uint32;
begin
   if _Value = _Vector[_current] then
   begin
      _previous := _current - 1;
      Result := _current;
   end
   else if _Value > _Vector[_current] then
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _max) div 2;
         Result := BinaryFileSearch(_Value,_Vector,Current+1,_max,_current,_previous);
      end
      else
      begin
         _previous := _current;
         Result := -1;
      end;
   end
   else // <
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _min) div 2;
         Result := BinaryFileSearch(_Value,_Vector,_min,Current-1,_current,_previous);
      end
      else
      begin
         _previous := _current - 1;
         Result := -1;
      end;
   end;
end;

// Also Ripped and modified from BIG_File.pas
function CBIGRTEManager.DoABinaryFileSearch(const _Value : uint32; const _Vector: auint32; var _previous: int32): int32;
begin
   Result := (High(_Vector)+1) div 2;
   Result := BinaryFileSearch(_Value,_Vector,0,High(_Vector),Result,_previous);
end;

// Ripped from uRealTimeEditionManager and many other places.
procedure CBIGRTEManager.MoveUpValues(_ID : uint32; var _Vector : auint32);
var
   i : int32;
begin
   i := _ID;
   while i < High(_Vector) do
   begin
      _Vector[i+1] := _Vector[i];
      inc(i);
   end;
end;

procedure CBIGRTEManager.MoveDownValues(_ID : uint32; var _Vector : auint32);
var
   i : int32;
begin
   i := _ID;
   while i < High(_Vector) do
   begin
      _Vector[i] := _Vector[i+1];
      inc(i);
   end;
end;


end.
