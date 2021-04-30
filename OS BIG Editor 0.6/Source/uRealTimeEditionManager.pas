(*******************************************************************************
 * Author  Banshee
 *
 * Date    16/02/2008
 *
 * Copyright
 ******************************************************************************)
unit uRealTimeEditionManager;

interface

uses BasicDataTypes;

type
   TRTEMessage = record
      MessageType : uint32;
      AffectedID : int32;
   end;

   CRealTimeEditionManager = class
      protected
         FType : uint32;
         FMessages : array of TRTEMessage;
         // Deletes
         procedure MoveDownFiles(_ID : uint32);
         procedure DeleteMessage(_ID: uint32);
         // Copies
         procedure CopyMessage(_Source, _Destiny: uint32);
      public
         // Constructors
         constructor Create; virtual;
         procedure Reset; virtual;
         // Gets
         function GetType: uint32;
         // Adds
         procedure SendMessage(_Type, _ID: uint32); virtual;
         // Execute
         procedure Execute; virtual;
         // Public properties.
         property MyType: uint32 read GetType;
   end;

implementation

uses BIG_File;

// Constructors
constructor CRealTimeEditionManager.Create;
begin
   Reset;
end;

procedure CRealTimeEditionManager.Reset;
var
   i : uint32;
begin
   if High(FMessages) > -1 then
   begin
      for i := High(FMessages) downto Low(FMessages) do
      begin
         DeleteMessage(i);
      end;
   end;
   SetLength(FMessages,0);
end;


// Gets
function CRealTimeEditionManager.GetType: uint32;
begin
   Result := FType;
end;

// Adds
procedure CRealTimeEditionManager.SendMessage(_Type, _ID: uint32);
begin
   SetLength(FMessages,High(FMessages)+2);
   FMessages[High(FMessages)].MessageType := _Type;
   FMessages[High(FMessages)].AffectedID := _ID;
end;

// Deletes
procedure CRealTimeEditionManager.MoveDownFiles(_ID : uint32);
var
   i : int32;
begin
   i := _ID;
   while i < High(FMessages) do
   begin
      CopyMessage(i+1,i);
      inc(i);
   end;
end;

procedure CRealTimeEditionManager.DeleteMessage(_ID: uint32);
begin
   MoveDownFiles(_ID);
   SetLength(FMessages,High(FMessages));
end;

// Copies
procedure CRealTimeEditionManager.CopyMessage(_Source: Cardinal; _Destiny: Cardinal);
begin
   FMessages[_Destiny].MessageType := FMessages[_Source].MessageType;
   FMessages[_Destiny].AffectedID := FMessages[_Source].AffectedID;
end;

// Execute
procedure CRealTimeEditionManager.Execute;
begin
   // Clear messages. Make sure it is executed only in the very end.
   Reset;
end;

end.
