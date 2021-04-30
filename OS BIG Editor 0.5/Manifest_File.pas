(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
unit Manifest_File;

// Library to possibly read Manifest packages from C&C3.
// This is a work in progress that is being written so far by Carlos
// "Banshee" Muniz.

interface

uses BasicDataTypes;

type
   TManifestHeader = record
      Version : uint32;   //$050100
      Signature : uint32;
      ManifestSignature : uint32; // F54ABCCF
      ItemCount : uint32;
      BinSize: uint32;
      Unknown1: uint32;
      ReloSize: uint32;
      ImpSize: uint32;
      ExtraEntriesSize: uint32;
      IncludeNameSize: uint32;
      StreamNameSize: uint32;
      SourceNameSize: uint32;
   end;

   TManifestFileHeader = record
      FilenameHash1 : uint32;
      FilenameHash2 : uint32;
      FilenameHash3 : uint32;
      FilenameHash4 : uint32;
      ExtraEntryOffset : uint32;
      ExtraEntryCount : uint32;
      StreamNameOffset : uint32;
      SourceNameOffset : uint32;
      StreamSize : uint32;
      ReloEntrySize : uint32;
      ExtraEntrySize : uint32;
   end;

   TManifestFileExtraEntryHeader = record
      Zero : Uint32;
      Size : uint32;
      DataSize : uint32;
      ExtraData : puint8;
   end;

   TManifestFileUnit = record
      Header : TManifestFileHeader;
      ExtraEntries : array of TManifestFileExtraEntryHeader;
      StreamName : string;
      SourceName : string;
   end;

   TManifestPackage = class
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Gets
         // Sets

      private
         Valid : Boolean;
         Files : array of TManifestFileUnit;
         MainHeader : TManifestHeader;
         // I/O
         procedure LoadFileFromBuffers(const PManifestBuffer, PImpBuffer, PReloBuffer, PBinBuffer: puint8);
         function LoadManifestHeader(var PManifestBuffer : puint8): boolean;
         function LoadManifestFileHeader(var PManifestBuffer : puint8; Index : uint32): boolean;
         function LoadManifestFileExtraEntries(var PManifestBuffer : puint8; FileIndex,ExtraEntryIndex : uint32): boolean;
   end;


implementation

constructor TManifestPackage.Create;
begin
   SetLength(Files,0);
   Valid := false;
end;

destructor TManifestPackage.Destroy;
begin
   SetLength(Files,0);
   inherited Destroy;
end;

procedure TManifestPackage.LoadFileFromBuffers (const PManifestBuffer, PImpBuffer, PReloBuffer, PBinBuffer: puint8);
var
   PMan,PBin,PImp,PRel : puint8;
   i,e : uint32;
begin
   PMan := PManifestBuffer;
   PImp := PImpBuffer;
   PRel := PReloBuffer;
   PBin := PBinBuffer;

   // Let's read the manifest
   if LoadManifestHeader(PMan) then
   begin
      for i := 0 to (MainHeader.ItemCount-1) do
      begin
         LoadManifestFileHeader(PMan,i);
      end;
      // The next part is a bit more dynamic, so the pointer will start to
      // move around.
      for i := 0 to (MainHeader.ItemCount-1) do
      begin
         if Files[i].Header.ExtraEntryCount > 0 then
         begin
            PMan := PUint8(Cardinal(PManifestBuffer) + Cardinal(Files[i].Header.ExtraEntryOffset));
            for e := 0 to (Files[i].Header.ExtraEntryCount - 1) do
            begin
               LoadManifestFileExtraEntries(PMan,i,e);
            end;
         end;
      end;
      Valid := true;
   end;
end;

function TManifestPackage.LoadManifestHeader(var PManifestBuffer : puint8): Boolean;
begin
   MainHeader.Version := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   if MainHeader.Version = $050100 then
   begin
      MainHeader.Signature := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.ManifestSignature := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.ItemCount := uint32(puint32(PManifestBuffer)^);
      SetLength(Files,MainHeader.ItemCount);
      inc(PManifestBuffer,4);
      MainHeader.BinSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.Unknown1 := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.ReloSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.ImpSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.ExtraEntriesSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.IncludeNameSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.StreamNameSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      MainHeader.SourceNameSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Result := true;
   end
   else
      Result := false;
end;

function TManifestPackage.LoadManifestFileHeader(var PManifestBuffer : puint8; Index : uint32): boolean;
begin
   Result := false;
   Files[Index].Header.FilenameHash1 := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.FilenameHash2 := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.FilenameHash3 := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.FilenameHash4 := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.ExtraEntryOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.ExtraEntryCount := uint32(puint32(PManifestBuffer)^);
   SetLength(Files[Index].ExtraEntries,Files[Index].Header.ExtraEntryCount);
   inc(PManifestBuffer,4);
   Files[Index].Header.StreamNameOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.SourceNameOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.StreamSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.ReloEntrySize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[Index].Header.ExtraEntrySize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Result := true;
end;

function TManifestPackage.LoadManifestFileExtraEntries(var PManifestBuffer : puint8; FileIndex,ExtraEntryIndex : uint32): boolean;
var
   i : uint32;
   PData : puint8;
begin
   Result := false;
   Files[FileIndex].ExtraEntries[ExtraEntryIndex].Zero := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[FileIndex].ExtraEntries[ExtraEntryIndex].Size := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[FileIndex].ExtraEntries[ExtraEntryIndex].DataSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[FileIndex].ExtraEntries[ExtraEntryIndex].ExtraData := nil;
   if Files[FileIndex].ExtraEntries[ExtraEntryIndex].DataSize > 0 then
   begin
      GetMem(Files[FileIndex].ExtraEntries[ExtraEntryIndex].ExtraData,Files[FileIndex].ExtraEntries[ExtraEntryIndex].DataSize);
      i := 0;
      PData := Files[FileIndex].ExtraEntries[ExtraEntryIndex].ExtraData;
      while i < Files[FileIndex].ExtraEntries[ExtraEntryIndex].DataSize do
      begin
         PData^ := PManifestBuffer^;
         inc(PData);
         inc(PManifestBuffer);
         inc(i);
      end;
   end;
   Result := true;
end;


end.
