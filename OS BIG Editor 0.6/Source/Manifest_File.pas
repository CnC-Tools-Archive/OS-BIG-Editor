(*******************************************************************************
 * Author                   Banshee
 *
 * Date                     11/03/2007
 *
 * Copyright
 ******************************************************************************)
unit Manifest_File;

// Library to possibly read Manifest packages from C&C3.

// This file uses portions of code from SDK Extras, by jonwil
{
	Command & Conquer 3 Tools
	cc3tools shared dll include file
	Copyright 2007 Jonathan Wilson
	Portions lifted from BinOpener and TerrainTextureCompiler copyright 2007 booto (temptemp91 at hotmail dot com)

	This file is part of cc3tools.

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	The Command & Conquer 3 Tools are distributed in the hope that they will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}


interface

uses BasicDataTypes;

type
   TManifestHeader = record
      IsBigEndian : boolean;
      IsLinked : boolean;
      Version : int16;       // $0005
      StreamChecksum : uint32;
      AllTypesHash : uint32; // F54ABCCF
      AssetCount : uint32;
      TotalInstanceDataSize: uint32;
      MaxInstanceChunkSize: uint32;
      MaxRelocationChunkSize: uint32;
      MaxImportsChunkSize: uint32;
      AssetReferenceBufferSize: uint32;
      ReferencedManifestNameBufferSize: uint32;
      AssetNameBufferSize: uint32;
      SourceFileNameBufferSize: uint32;
   end;

// Structure representing an asset in a .manifest file
   TAssetEntry = record
      TypeID : uint32;
      InstanceId : uint32;
      TypeHash : uint32;
      InstanceHash : uint32;
      AssetReferenceOffset : uint32;
      AssetReferenceCount : uint32;
      NameOffset : uint32;
      SourceFileNameOffset : uint32;
      InstanceDataSize : uint32;
      RelocationDataSize : uint32;
      ImportsDataSize : uint32;
   end;

// Structure representing a reference to an asset
   TAssetId = record
      TypeID : uint32;
      InstanceId: uint32;
   end;

// Structure representing a reference to another manifest
   TManifestReference = record
	   IsPatch: Boolean;
	   Path: string;
   end;

   TAsset = record
      Header : TAssetEntry;
      AssetReferences : array of TAssetId;
      Name : string;
      SourceFileName : string;
      ManifestName : string;
      InstanceData : array of uint8;
      RelocationData: array of uint32;
      ImportsData: array of uint32;
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
         FileName : string;
         Header : TManifestHeader;
         Assets:  array of TAsset;
         AssetReferences : array of TAssetId;
         ReferencedManifests : array of array of TManifestReference;
         AssetNames : array of string;
         SourceFileNames : array of string;
         ManifestName : string;
         InstanceData : array of uint8;
         RelocationData: array of uint32;
         ImportsData: array of uint32;
         // I/O
         procedure LoadFileFromBuffers(const PManifestBuffer, PImpBuffer, PReloBuffer, PBinBuffer: puint8);
         function LoadManifestHeader(var PManifestBuffer : puint8): boolean;
         function LoadAssetHeader(var PManifestBuffer : puint8; Index : uint32): boolean;
         function LoadManifestFileExtraEntries(var PManifestBuffer : puint8; FileIndex,ExtraEntryIndex : uint32): boolean;
   end;


implementation

constructor TManifestPackage.Create;
begin
   SetLength(Assets,0);
   Valid := false;
end;

destructor TManifestPackage.Destroy;
begin
   SetLength(Assets,0);
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
      for i := 0 to (Header.AssetCount-1) do
      begin
         LoadAssetHeader(PMan,i);
      end;
      // The next part is a bit more dynamic, so the pointer will start to
      // move around.
      for i := 0 to (Header.AssetCount-1) do
      begin
         if Assets[i].Header.AssetReferenceCount > 0 then
         begin
            PMan := PUint8(Cardinal(PManifestBuffer) + Cardinal(Assets[i].Header.AssetReferenceCount));
            for e := 0 to (Assets[i].Header.AssetReferenceCount - 1) do
            begin
               LoadManifestFileExtraEntries(PMan,i,e);
            end;
         end;
      end;
      Valid := true;
   end;
end;

function TManifestPackage.LoadManifestHeader(var PManifestBuffer : puint8): Boolean;
var
   temp: uint8;
begin
   temp := uint8(puint8(PManifestBuffer)^);
   Header.IsBigEndian := temp <> 0;
   inc(PManifestBuffer,1);
   temp := uint8(puint8(PManifestBuffer)^);
   Header.IsLinked := temp <> 0;
   inc(PManifestBuffer,1);

   Header.Version := uint16(puint16(PManifestBuffer)^);
   inc(PManifestBuffer,2);
   if Header.Version = $5 then
   begin
      Header.StreamChecksum := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.AllTypesHash := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.AssetCount := uint32(puint32(PManifestBuffer)^);
      SetLength(Assets,Header.AssetCount);
      inc(PManifestBuffer,4);
      Header.TotalInstanceDataSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.MaxInstanceChunkSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.MaxRelocationChunkSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.MaxImportsChunkSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.AssetReferenceBufferSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.ReferencedManifestNameBufferSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.AssetNameBufferSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Header.SourceFileNameBufferSize := uint32(puint32(PManifestBuffer)^);
      inc(PManifestBuffer,4);
      Result := true;
   end
   else
      Result := false;
end;

function TManifestPackage.LoadAssetHeader(var PManifestBuffer : puint8; Index : uint32): boolean;
begin
   Result := false;
   Assets[Index].Header.TypeID := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.InstanceId := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.TypeHash := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.InstanceHash := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.AssetReferenceOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.AssetReferenceCount := uint32(puint32(PManifestBuffer)^);
   SetLength(Assets[Index].AssetReferences,Assets[Index].Header.AssetReferenceCount);
   inc(PManifestBuffer,4);
   Assets[Index].Header.NameOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.SourceFileNameOffset := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.InstanceDataSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.RelocationDataSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Assets[Index].Header.ImportsDataSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Result := true;
end;

function TManifestPackage.LoadManifestFileExtraEntries(var PManifestBuffer : puint8; FileIndex,ExtraEntryIndex : uint32): boolean;
var
   i : uint32;
   PData : puint8;
begin
   Result := false;
{
   Files[FileIndex].AssetReferences[ExtraEntryIndex].DataSize := uint32(puint32(PManifestBuffer)^);
   inc(PManifestBuffer,4);
   Files[FileIndex].AssetReferences[ExtraEntryIndex].ExtraData := nil;
   if Files[FileIndex].AssetReferences[ExtraEntryIndex].DataSize > 0 then
   begin
      GetMem(Files[FileIndex].AssetReferences[ExtraEntryIndex].ExtraData,Files[FileIndex].AssetReferences[ExtraEntryIndex].DataSize);
      i := 0;
      PData := Files[FileIndex].AssetReferences[ExtraEntryIndex].ExtraData;
      while i < Files[FileIndex].AssetReferences[ExtraEntryIndex].DataSize do
      begin
         PData^ := PManifestBuffer^;
         inc(PData);
         inc(PManifestBuffer);
         inc(i);
      end;
   end;
}
   Result := true;
end;


end.
