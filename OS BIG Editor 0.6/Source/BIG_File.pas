(*******************************************************************************
 * Author               Banshee
 *
 * Date                 02/03/2007
 *
 * Copyright
 ******************************************************************************)
unit BIG_File;

interface

uses
   BasicDataTypes, SysUtils, Classes, Dialogs, Math, RefPackFunctions, uCRC32,
   BasicConstants, ElAES;

type
   TMEGNameItem = record
      Name : string;
      CRC : uint32;
   end;
   TMEGNameList = array of TMEGNameItem;

   PBIGFileUnit = ^TBIGFileUnit;
   TBIGFileUnit = record
      Offset : uint32;
      Size : uint32;
      Filename : string;
      Index : int32;
      IsRepetition : Boolean;
      FirstRepetition : uint32;
      IsValid : Boolean;
      NextEqualFile : int32;//PBIGFileUnit;
      ExternalFileLocation : string;
      Compression : uint32;
   end;

   TBIGPackage = class
   private
      ValidFile : boolean;
      Filename  : string;
      BIGType   : uint32;
      Size      : uint32;
      Files     : array of TBIGFileUnit;
      AlphabeticOrder : auint32;//PBIGFileUnit;

      // AES Utils
      AESKey: PAESKey128;
      AESInitialVector: PAESBuffer;
      // Constructors and Destructors
      procedure Reset;
      // I/O
      procedure LoadBIGFile(var _File : TFileStream);
      procedure LoadMEGFile(var _File : TFileStream);
      function SaveAFile(_id : int32; var _Output : TStream; UseCompression : boolean): Boolean;
      procedure CommonAddFileTasks(FileNum : uint32);
      procedure AddFileFromBIG(FileNum : uint32; var PCurrentData : pint8);
      procedure AddFileFromMEG(FileNum : uint32; var PCurrentData : pint8; var FileNameList : array of string; const _Format: uint32 = 1);
      function ReadFile(_ID : int32; var _Data: puint8; var _DataSize: uint32): boolean;
      procedure ReadFileFromDisk(_ID : int32; var _Data : puint8; var _DataSize : uint32);
      procedure ReadFileFromExternalAddress(_ID : int32; var _Data : puint8; var _DataSize : uint32);
      function IsDataRefPackCompressed(var _Data : puint8; var _CompressedSize: uint32): boolean;
//      function GenerateHeaderSpace(var _Output : TStream): uint32;
      procedure SaveBIGFile(const _Filename : string; _UseCompression : boolean = false);
      procedure SaveMEGFile(const _Filename : string);
      procedure SaveBIGMainHeader(var _Output : TStream; _UseCompression : boolean; _Size,_NumFiles,_HeaderSize : uint32);
      procedure SaveMEGMainHeader(var _Output : TStream; _NumFiles : uint32);
      procedure SaveBIGFileHeaders(var _Output : TStream; _HeaderSize,_NonFileHeaderSize : uint32);
      procedure SaveBIG4Signature(var _Output : TStream);
      procedure SaveMEGFileNameList(var _Output : TStream; const FileList : TMegNameList);
      procedure SaveMEGFileHeaders(var _Output : TStream; _NumFiles,_HeaderSize : uint32; const _FileNameList : TMEGNameList; const _Pos : auint32);

      // RefPack
      procedure DecompressData(var _Input,_OutPut: puint8);
      function CompressFile(var source : puint8; var output : puint8; Size : uint32): Boolean;
      // CRC reorder (MEG)
      procedure mergeSortCRC(var _Vector : auint32; const _FileNameList : TMEGNameList);
      procedure mergeCRC(var _Vector : auint32; const _FileNameList : TMEGNameList; _left, _middle, _right: uint32);
      procedure mSortCRC (var _Vector: auint32; const _FileNameList : TMEGNameList; _left, _right: uint32);

      // Adds and Removes
      procedure AddPointerToAlphabeticOrder(_Value : int32{PBIGFileUnit}; Position : int32);
{$HINTS OFF} // We don't use this function yet, but we may need it later.
      procedure DeletePointerFromAlphabeticOrder(Position : uint32);
{$HINTS ON}
      procedure DeleteFileData(Position : uint32);
      function DeleteIDFromAlphabeticOrder(_ID : int32): boolean;
      // Extra
      function DoABinaryFileSearch(const _Name : string; var _previous: int32): int32; overload;
      function DoABinaryFileSearch(const _Name : string): int32; overload;
      function BinaryFileSearch(const _Name: string; _min, _max : int32; var _current,_previous : int32): int32;
      procedure CopyFiles(_Source,_Dest: uint32);
      function InvertInteger(_i: uint32): uint32;
      function InvertInteger16(_i: uint16): uint16;

   public
      // Constructors and Destructors
      constructor Create;
      // I/O
      procedure LoadFile(const _Filename : string);
      procedure SaveFile(const _Filename : string; _UseCompression : boolean = false);
      procedure NewFile;
      // Adds and Removes
      function AddFile(const _Filename : string; const _BaseDir: string; _ArchiveDir : string = ''): boolean;
      function CloneFile(_ID : int32): int32;
      procedure ExtractFileToTemp(_ID : int32);
      procedure DeleteFile(_ID: int32);
      procedure ClearUselessFiles;
      // Gets
      function GetNumFiles : uint32;
      function GetFileName : string;
      function GetFileInfo (_ID : int32): TBIGFileUnit;
      function GetFileInfoByName(_ID: string): TBIGFileUnit;
      function GetFileContents( _ID : int32; var _Data : TStream; var _DataSize : uint32; _DecompressData : boolean = true) : Boolean;
      function GetUseCompression : boolean;
      function GetPackageType : uint32;
      function IsValid : boolean;
      function IsFileInPackage(const _Filename : string): Boolean;
      function IsFileValid (_ID : int32): Boolean;
      function IsFileRepetition (_ID : int32): Boolean;
      function IsFileEditable(_ID : int32): Boolean;
      function IsRealTimeReady : boolean;
      // Sets
      procedure SetFilename(_ID : int32; _name : string);
   end;

implementation

uses
   FormBIGMain, MEG_AES_Constants, FormEncryptedMEGGameSelection;

// Constructors and Destructors
constructor TBIGPackage.Create;
begin
   Reset;
end;

procedure TBIGPackage.Reset;
begin
   ValidFile := false;
   SetLength(Files,0);
   SetLength(AlphabeticOrder,0);
   Filename := '';
   BIGType := C_BIGF;
   Size := 0;
   // Clean all temp files.
   FrmBIGMain.TempFiles.Reset;
end;

procedure TBIGPackage.NewFile;
begin
   Reset;
   ValidFile := true;
end;

{$HINTS OFF}
procedure TBIGPackage.LoadFile(const _Filename : string);
var
   MyFile       : TStream;
   FileSize     : uint32;
   MyExt       : string;
begin
   Reset;
   if (FileExists(_Filename)) then
   begin
      Filename := Copy(_Filename,1, Length(_Filename));
      MyFile   := TFileStream.Create(_Filename, fmOpenRead or fmShareDenyWrite); // Open file

      // Store the whole file in the memory
      FileSize := MyFile.Size;
      if (Filesize > 0) then
      begin
         MyExt := LowerCase(ExtractFileExt(Filename));
         if CompareStr(MyExt,'.big') = 0 then
         begin
            LoadBIGFile(TFileStream(MyFile));
         end
         else if CompareStr(MyExt,'.meg') = 0 then
         begin
            LoadMEGFile(TFileStream(MyFile));
         end
         else if CompareStr(MyExt,'.pgm') = 0 then
         begin
            LoadMEGFile(TFileStream(MyFile));
         end;
      end;
      MyFile.Free;
   end;
end;

// 0.6: code to read .big files now goes here.
procedure TBIGPackage.LoadBIGFile(var _File : TFileStream);
var
   PData        : pint8;
   PCurrentData : pint8;
   HeaderSize   : uint32;
   NumFiles     : uint32;
   i            : uint32;
begin
   Getmem(PData, 4);
   _File.Read(PData^, 4);
   PCurrentData := PData;

   // Let's start reading the file here.
   BIGType := uint32(puint32(PCurrentData)^);
   Inc(PCurrentData,4);
   if (BIGType = C_BIG4) or (BIGType = C_BIGF) then
   begin
      // 0.4 Beta Change. This reduces memory load.
      FreeMem(PData);
      Getmem(PData, 12);
      PCurrentData := PData;
      _File.Read(PData^, 12);
      // Old code resumes...
      Size := InvertInteger(uint32(puint32(PCurrentData)^));
      Inc(PCurrentData,4);
      NumFiles := InvertInteger(uint32(puint32(PCurrentData)^));
      Inc(PCurrentData,4);
      // 0.4 code again. Now we get the header size
      HeaderSize := InvertInteger(uint32(puint32(PCurrentData)^)) - 16;
      Inc(PCurrentData,4);
      FreeMem(PData);
      GetMem(PData,HeaderSize);
      PCurrentData := PData;
      _File.Read(PData^, HeaderSize);
      // Here we resume the old code.
      SetLength(Files,NumFiles);
      // Let's read each file
      for i := 0 to High(Files) do
      begin
         // 0.6 Repetition Detection support - by Banshee.
         AddFileFromBIG(i,PCurrentData);
      end;
      ValidFile := true;
   end;
   FreeMem(PData);
end;

// 0.6: code to read .meg files now goes here.
procedure TBIGPackage.LoadMEGFile(var _File : TFileStream);
var
   PData        : pint8;
   PCurrentData : pint8;
   PDecryptedData        : pint8;
   PCurrentDecryptedData : pint8;
   HeaderSize   : uint32;
   NumFiles     : uint32;
   i, c         : uint32;
   FileNameSize : uint16;
   FileNameList : array of string;
   FNListSize   : uint32;
   Format       : int8;
   Position     : int64;
   DecryptedData: TMemoryStream;
   Form: TFrmEncryptedMEGGameSelection;
begin
   Format := 1; // Default format. Once we figure out the data, we'll change it.
   Getmem(PData, 8);
   _File.Read(PData^, 8);
   PCurrentData := PData;
   BIGType := C_MEGF;
   // Get Filenames list and File info list.
   FNListSize := uint32(puint32(PCurrentData)^);
   if FNListSize >= $8FFFFFFF then
   begin
      if FNListSize = $8FFFFFFF then
      begin
         Format := 4; // It's 3 and it is encrypted. We're calling 4 for now.
      end
      else
      begin
         Format := 2; // It's either 2 or newer.
      end;
      FreeMem(PData);
      Getmem(PData, 12);
      _File.Read(PData^, 12);
      PCurrentData := PData;
      Inc(PCurrentData,4); // Skip $3F7D70A4 and data start.
      // Read number of filenames.
      FNListSize := uint32(puint32(PCurrentData)^);
   end;
   Inc(PCurrentData,4);
   // Get number of files.
   NumFiles := uint32(puint32(PCurrentData)^);
   SetLength(Files,NumFiles);
   SetLength(FilenameList,FNListSize);
   FreeMem(PData);
   if Format >= 2 then
   begin
      // in Format 2 the header ends on number of files. Format 3 has a couple of additional data.
      // Saves current position for Format 2.
      Position := _File.Position;
      Getmem(PData, 4);
      _File.Read(PData^, 4);
      PCurrentData := PData;
      // Get size of the filenames table record.
      HeaderSize := uint32(puint32(PCurrentData)^);
      FreeMem(PData);
      // Here we are checking if we can reach a flag from the first file record entry to verify if it is
      // format 2, 3 or 4.
      if Format < 4 then
      begin
         i := ($18 + HeaderSize);
         if _File.Size > (i + 2) then
         begin
            _File.Seek(i, soFromBeginning);
            Getmem(PData, 2);
            _File.Read(PData^, 2);
            PCurrentData := PData;
            c := uint16(puint16(PCurrentData)^);
            FreeMem(PData);
            if c = 0 then
            begin
               Format := 3;
               _File.Seek(Position + 4, soFromBeginning);
            end
            else if c = 1 then
            begin
               Format := 4;
               _File.Seek(Position + 4, soFromBeginning);
            end;
         end;
         if Format = 2 then
         begin
            _File.Seek(Position, soFromBeginning);
         end;
      end;
   end;
   if NumFiles > 0 then
   begin
      // Filenames table record starts here.
      if Format < 4 then
      begin
         for i := 0 to FNListSize - 1 do
         begin
            // Let's read the filename.
            Getmem(PData, 2);
            _File.Read(PData^, 2);
            PCurrentData := PData;
            FileNameSize := uint16(puint16(PCurrentData)^);
            FreeMem(PData);
            Getmem(PData, FileNameSize);
            _File.Read(PData^, FileNameSize);
            PCurrentData := PData;
            c := 0;
            while c < FileNameSize do
            begin
               FileNameList[i] := FileNameList[i] + char(PCurrentData^);
               inc(PCurrentData,1);
               inc(c);
            end;
            FreeMem(PData);
         end;
      end
      else
      begin
         Form := TFrmEncryptedMEGGameSelection.Create(nil);
         Form.ShowModal;
         if Form.CbGame.ItemIndex = 0 then
         begin
            AESKey := Addr(C_AES_KEY_8BIT);
            AESInitialVector := Addr(C_IV_8BIT);
         end
         else
         begin
            AESKey := Addr(C_AES_KEY_GREYGOO);
            AESInitialVector := Addr(C_IV_GREYGOO);
         end;
         Form.Release;
         // Decrypt it here.
         DecryptedData := TMemoryStream.Create;
         DecryptAESStreamCBC(_File, HeaderSize, AESKey^, AESInitialVector^, DecryptedData);
         DecryptedData.Seek(0, soFromBeginning);
         for i := 0 to FNListSize - 1 do
         begin
            // Let's read the filename.
            Getmem(PData, 2);
            DecryptedData.Read(PData^, 2);
            PCurrentData := PData;
            FileNameSize := uint16(puint16(PCurrentData)^);
            FreeMem(PData);
            Getmem(PData, FileNameSize);
            DecryptedData.Read(PData^, FileNameSize);
            PCurrentData := PData;
            c := 0;
            while c < FileNameSize do
            begin
               FileNameList[i] := FileNameList[i] + char(PCurrentData^);
               inc(PCurrentData,1);
               inc(c);
            end;
            FreeMem(PData);
         end;
//         _File.Seek(Headersize, soFromCurrent);
         DecryptedData.Free;
      end;
      // Now reads file info
      if Format < 3 then
      begin
         Getmem(PData, 20 * NumFiles);
         _File.Read(PData^, 20 * NumFiles);
         PCurrentData := PData;
         for i := 0 to NumFiles - 1 do
         begin
            // 0.6 Repetition Detection support - by Banshee.
            AddFileFromMEG(i,PCurrentData, FileNameList, Format);
            CommonAddFileTasks(i);
         end;
      end
      else
      begin
         // Check if it is encrypted
         for i := 0 to NumFiles - 1 do
         begin
            Getmem(PData, 2);
            _File.Read(PData^, 2);
            c := uint16(puint16(PData)^);
            FreeMem(PData);
            if c = 0 then
            begin
               // 0.6 Repetition Detection support - by Banshee.
               Getmem(PData, 18);
               _File.Read(PData^, 18);
               PCurrentData := PData;
               AddFileFromMEG(i,PCurrentData, FileNameList, 3);
               CommonAddFileTasks(i);
               FreeMem(PData);
            end
            else if c = 1 then
            begin
               DecryptedData := TMemoryStream.Create;
               DecryptAESStreamCBC(_File, 32, AESKey^, AESInitialVector^, DecryptedData);
               Getmem(PDecryptedData, DecryptedData.Size);
               DecryptedData.Seek(0, soFromBeginning);
               DecryptedData.Read(PDecryptedData^, DecryptedData.Size);
               PCurrentDecryptedData := PDecryptedData;
               AddFileFromMEG(i,PCurrentDecryptedData, FileNameList, 4);
               CommonAddFileTasks(i);
               FreeMem(PDecryptedData);
               DecryptedData.Free;
            end;
         end;
      end;
   end;
   ValidFile := true;
   SetLength(FileNameList,0);
end;

// 0.6 code to add files that are inside the .BIG files here.
procedure TBIGPackage.AddFileFromBIG(FileNum : uint32; var PCurrentData : pint8);
var
   Data,iData : puint8;
   MyFile : TStream;
   CompressedSize : uint32;
begin
   Files[FileNum].Index  := FileNum;
   Files[FileNum].Offset := InvertInteger(uint32(puint32(PCurrentData)^));
   Inc(PCurrentData,4);
   Files[FileNum].Size := InvertInteger(uint32(puint32(PCurrentData)^));
   Inc(PCurrentData,4);
   // Now we need to read the filename.
   while (PCurrentData^ <> 0) do
   begin
      Files[FileNum].Filename := Files[FileNum].Filename + char(PCurrentData^);
      Inc(PCurrentData,1);
   end;
   Inc(PCurrentData,1);
   Files[FileNum].ExternalFileLocation := 'none';
   // Let's see quickly if it is compressed or not.
   GetMem(Data,32);
   MyFile := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite); // Open file
   MyFile.Seek(Files[FileNum].Offset,soFromBeginning);
   MyFile.Read(Data^,32);
   MyFile.Free;
   iData := Data;
   if IsDataRefPackCompressed(iData, CompressedSize) then
   begin
      Files[FileNum].Compression := C_REFPACK_COMPRESSION;
   end
   else
   begin
      Files[FileNum].Compression := C_NO_COMPRESSION;
   end;
   FreeMem(Data);
   CommonAddFileTasks(FileNum);
end;

procedure TBIGPackage.AddFileFromMEG(FileNum : uint32; var PCurrentData : pint8; var FileNameList : array of string; const _Format: uint32 = 1);
var
   checkFormat: int16;
   FNPointer16    : uint16;
   FNPointer    : uint32;
begin
   Files[FileNum].Index  := FileNum;
   // Skip CRC32 and Index
   inc(PCurrentData,8);
   Files[FileNum].Size := uint32(puint32(PCurrentData)^);
   Inc(PCurrentData,4);
   Files[FileNum].Offset := uint32(puint32(PCurrentData)^);
   Inc(PCurrentData,4);
   Files[FileNum].ExternalFileLocation := 'none';
   if _Format = 4 then
   begin
      Files[FileNum].Compression := C_AES128_COMPRESSION;
   end
   else
   begin
      Files[FileNum].Compression := C_NEVER_COMPRESSED;
   end;
   // Here we continue (can't be bothered to pass an array of string as parameter.
   if _Format < 3 then
   begin
      FNPointer := uint32(puint32(PCurrentData)^);
      Inc(PCurrentData,4);
      Files[FileNum].Filename := copy(FileNameList[FNPointer],1,Length(FileNameList[FNPointer]));
   end
   else
   begin
      FNPointer16 := uint16(puint16(PCurrentData)^);
      Inc(PCurrentData,2);
      Files[FileNum].Filename := copy(FileNameList[FNPointer16],1,Length(FileNameList[FNPointer16]));
   end;
end;

// This function only adds files from the hard disk.
function TBIGPackage.AddFile(const _Filename : string; const _BaseDir: string; _ArchiveDir : string = ''): boolean;
var
   Index,FileSize : uint32;
   QuickStream : TStream;
begin
   Result := false;
   if FileExists(_Filename) then
   begin
      QuickStream := TFileStream.Create(_Filename,fmOpenRead);
      FileSize := QuickStream.Size;
      QuickStream.Free;
      if FileSize > 0 then
      begin
         SetLength(Files,High(Files)+2);
         Index := High(Files);
         Files[Index].Index := Index;
         Files[Index].Size := FileSize;
         Files[Index].Filename := _ArchiveDir + ExtractRelativePath(IncludeTrailingBackslash(_BaseDir),_Filename);
         Files[Index].ExternalFileLocation := _Filename;
         Files[Index].Compression := C_NEVER_COMPRESSED;
         CommonAddFileTasks(Index);
         Result := true;
      end;
   end;
end;

function TBIGPackage.CloneFile(_ID : int32): int32;
var
   index : uint32;
begin
   // Here we clone a file.
   if (_ID > -1) and (_ID <= High(Files)) then
   begin
      SetLength(Files,High(Files)+2);
      Index := High(Files);
      CopyFiles(_ID,Index);
      Files[Index].Index := Index;
      CommonAddFileTasks(Index);
      Result := Index;
   end
   else
   begin
      Result := -1;
   end;
end;

// Every add file related function should call this one.
procedure TBIGPackage.CommonAddFileTasks(FileNum : uint32);
var
   Previous,Position : int32;
   i : int32;
   PreviousRepetition : PBIGFileUnit;
begin
   Files[FileNum].NextEqualFile := -1;
   // Now we determine the alphabetic position of the name
   if High(AlphabeticOrder) >= 0 then
   begin
      Position := (High(AlphabeticOrder)+1) div 2;
      Position := BinaryFileSearch(Files[FileNum].Filename,0,High(AlphabeticOrder),Position,Previous);
   end
   else
   begin
      Position := -1;
      Previous := -1;
   end;
   if (Position = (-1)) then
   begin
      AddPointerToAlphabeticOrder(FileNum,Previous+1); //Addr(Files[FileNum]),Previous+1);
      Files[FileNum].IsRepetition := false;
      Files[FileNum].FirstRepetition := FileNum;
   end
   else
   begin
      Files[FileNum].FirstRepetition := Position;
      PreviousRepetition := Addr(Files[Position]);
      while PreviousRepetition^.NextEqualFile <> -1 do
      begin
         PreviousRepetition := Addr(Files[PreviousRepetition^.NextEqualFile]);
      end;
      PreviousRepetition^.NextEqualFile := FileNum;
      Files[FileNum].IsRepetition := true;
   end;
   Files[FileNum].IsValid := true;
end;

// 0.6 code to save Files
procedure TBIGPackage.SaveFile(const _Filename : string; _UseCompression : boolean = false);
var
   TempFileCreated : boolean;
   MyExt : string;
begin
   if GetNumFiles > 0 then
   begin
      try
         // Are we writing over an existing file that contains the files
         // that we'll write?
         MyExt := Lowercase(ExtractFileExt(_Filename));
         if (CompareStr(Filename,_Filename) = 0) and FileExists(Filename) then
         begin // Yes? Makes a temp file.
            Filename := copy(_Filename,1,Length(_Filename) - 4) + '_tmp' + MyExt;
            while FileExists(FileName) do
            begin
               Filename := copy(Filename,1,Length(Filename) - 4) + '_tmp' + MyExt;
            end;
            RenameFile(_Filename,Filename);
            TempFileCreated := true;
         end
         else // No? Then, fine...
            TempFileCreated := false;

         if CompareStr(MyExt,'.big') = 0 then
         begin
            SaveBIGFile(_Filename,_UseCompression);
         end
         else if CompareStr(MyExt,'.meg') = 0 then
         begin
            SaveMEGFile(_Filename);
         end
         else if CompareStr(MyExt,'.pgm') = 0 then
         begin
            SaveMEGFile(_Filename);
         end;


         // If there was a temporary file, we wipe it.
         if TempFileCreated then
            SysUtils.DeleteFile(Filename);
         // This saved file will be the base of the next save.
         Filename := copy(_Filename,1,Length(_Filename));
         // Clear the trash.
         ClearUselessFiles;
      except
         ShowMessage(FrmBIGMain.Language.GetString('Warnings','CouldntSaveFile'));
      end;
   end;
end;

// 0.6 Save a .BIG Files
procedure TBIGPackage.SaveBIGFile(const _Filename : string; _UseCompression : boolean = false);
var
   MyFile       : TStream;
   FileBuffer    : TMemoryStream;
   ID : uint32;
   HeaderSize,NonFileHeaderSize : uint32;
   NumFiles : uint32;
begin
   try
      // Now let's start the output file.
      MyFile := TFileStream.Create(_Filename,fmCreate);
      FileBuffer := TMemoryStream.Create;

      // First, we write the files into a file buffer, compressed or not.
      NonFileHeaderSize := 16;
      If _UseCompression then
         inc(NonFileHeaderSize,8);
      HeaderSize := NonFileHeaderSize;
      NumFiles := 0;
      for ID := Low(Files) to High(Files) do
      begin
         if Files[ID].IsValid and (not Files[ID].IsRepetition) then
         begin
            if SaveAFile(ID,TStream(FileBuffer),_UseCompression) then
            begin
               inc(NumFiles);
               inc(HeaderSize,9 + Length(Files[ID].Filename));
            end
            else
            begin
               Files[ID].IsValid := false;
            end;
         end;
      end;

      if NumFiles > 0 then
      begin
         // Now, we fix the file size, header size... in the main header.
         SaveBIGMainHeader(MyFile, _UseCompression, HeaderSize + FileBuffer.Size, NumFiles, HeaderSize);

         // Then, it's time to fix the screwed up offsets from the file
         // headers.
         SaveBIGFileHeaders(MyFile, HeaderSize, NonFileHeaderSize);
         if _UseCompression then
            SaveBIG4Signature(MyFile);

         // Merge FileBuffer with MyFile.
         FileBuffer.SaveToStream(MyFile);
      end;
      // And that's the end, where we close it.
   finally
      MyFile.Free;
      FileBuffer.Free;
   end;
end;

// 0.6 Save a .MEG Files
procedure TBIGPackage.SaveMEGFile(const _Filename : string);
var
   MyFile       : TStream;
   FileBuffer    : TMemoryStream;
   ID, i, c : uint32;
   HeaderSize : uint32;
   NumFiles : uint32;
   FileNameList : TMEGNameList;
   FileNamePos : auint32;
begin
   try
      // Now let's start the output file.
      MyFile := TFileStream.Create(_Filename,fmCreate);
      FileBuffer := TMemoryStream.Create;

      // First, we calculate the original offset, adding files to the buffer.
      HeaderSize := 8;
      NumFiles := 0;
      for ID := Low(Files) to High(Files) do
      begin
         if Files[ID].IsValid and (not Files[ID].IsRepetition) then
         begin
            if SaveAFile(ID,TStream(FileBuffer),false) then
            begin
               inc(NumFiles);
               inc(HeaderSize,22 + Length(Files[ID].Filename));
            end
            else
            begin
               Files[ID].IsValid := false;
            end;
         end;
      end;

      if NumFiles > 0 then
      begin
         // Now, we save the main header. FileCount and FileNames are equal.
         SaveMEGMainHeader(MyFile, NumFiles);

         // The file list is alphasorted.
         SetLength(FileNameList,High(AlphabeticOrder)+1);
         SetLength(FileNamePos, High(AlphabeticOrder)+1);
         c := Low(AlphabeticOrder);
         for ID := Low(AlphabeticOrder) to High(AlphabeticOrder) do
         begin
            i := AlphabeticOrder[ID];
            if Files[i].IsValid and (not Files[i].IsRepetition) then
            begin
               FileNameList[c].Name := copy(Files[i].Filename,1,Length(Files[i].Filename));
               FileNameList[c].CRC := Do_CRC32(FileNameList[c].name);
               FileNamePos[c] := i;
               inc(c);
            end;
         end;
         SetLength(FileNameList,c);

         // Now, let's save the FileNames.
         SaveMEGFileNameList(MyFile, FileNameList);

         // Then, it's time to fix the screwed up offsets from the file
         // headers.
         SaveMEGFileHeaders(MyFile, NumFiles, HeaderSize, FileNameList, FileNamePos);

         // Merge FileBuffer with MyFile.
         FileBuffer.SaveToStream(MyFile);
      end;
      // And that's the end, where we close it.
   finally
      MyFile.Free;
      FileBuffer.Free;
      SetLength(FileNameList,0);
      SetLength(FilenamePos,0);
   end;
end;


// 0.6 Save the main .BIG header in the output
procedure TBIGPackage.SaveBIGMainHeader(var _Output : TStream; _UseCompression : boolean; _Size,_NumFiles,_HeaderSize : uint32);
var
   PData, PCurrentData : puint8;
begin
   GetMem(PData,16);
   PCurrentData := PData;
   if _UseCompression then
      uint32(puint32(PCurrentData)^) := C_BIG4
   else
      uint32(puint32(PCurrentData)^) := C_BIGF;
   Inc(PCurrentData,4);
   uint32(puint32(PCurrentData)^) := InvertInteger(_Size);
   Inc(PCurrentData,4);
   uint32(puint32(PCurrentData)^) := InvertInteger(_NumFiles);
   Inc(PCurrentData,4);
   uint32(puint32(PCurrentData)^) := InvertInteger(_HeaderSize);
   _OutPut.Write(PData^,16);
   Size := _Size;
   FreeMem(PData);
end;

// 0.6 Save the main .BIG header in the output
procedure TBIGPackage.SaveMEGMainHeader(var _Output : TStream; _NumFiles : uint32);
var
   PData, PCurrentData : puint8;
begin
   GetMem(PData,8);
   PCurrentData := PData;
   uint32(puint32(PCurrentData)^) := _NumFiles;
   Inc(PCurrentData,4);
   uint32(puint32(PCurrentData)^) := _NumFiles;
   Inc(PCurrentData,4);
   _OutPut.Write(PData^,8);
   FreeMem(PData);
end;

// 0.6 Save the file headers in the output
procedure TBIGPackage.SaveBIGFileHeaders(var _Output : TStream; _HeaderSize,_NonFileHeaderSize : uint32);
var
   ID,i,StringSize : uint32;
   PData,PCurrentData : puint8;
begin
   GetMem(PData,_HeaderSize - _NonFileHeaderSize);
   PCurrentData := PData;
   // Now let's check each file of the package.
   for ID := Low(Files) to High(Files) do
   begin
      if Files[ID].IsValid and (not Files[ID].IsRepetition) then
      begin
         inc(Files[ID].Offset,_HeaderSize);
         uint32(puint32(PCurrentData)^) := InvertInteger(Files[ID].Offset);
         Inc(PCurrentData,4);
         uint32(puint32(PCurrentData)^) := InvertInteger(Files[ID].Size);
         Inc(PCurrentData,4);
         // Now we copy the filename...
         StringSize := Length(Files[ID].Filename);
         i := 1;
         while (i <= StringSize) do
         begin
            uint8(puint8(PCurrentData)^) := uint8(Files[ID].Filename[i]);
            Inc(PCurrentData,1);
            inc(i);
         end;
         PCurrentData^:= 0;
         Inc(PCurrentData,1);
      end;
   end;
   _OutPut.Write(PData^,_HeaderSize - _NonFileHeaderSize);
   FreeMem(PData);
end;

// 0.6b: .BIG4 files seems to have this kind of signature in the end of
// the file headers.
procedure TBIGPackage.SaveBIG4Signature(var _Output : TStream);
var
   PData,PCurrentData : puint8;
begin
   GetMem(PData,8);
   PCurrentData := PData;
   PCurrentData^ := $4c;
   inc(PCurrentData);
   PCurrentData^ := $32;
   inc(PCurrentData);
   PCurrentData^ := $38;
   inc(PCurrentData);
   PCurrentData^ := $30;
   inc(PCurrentData);
   PCurrentData^ := $15;
   inc(PCurrentData);
   PCurrentData^ := $5;
   inc(PCurrentData);
   PCurrentData^ := $0;
   inc(PCurrentData);
   PCurrentData^ := $1;
   inc(PCurrentData);
   _OutPut.Write(PData^,8);
   FreeMem(PData);
end;

// 0.6b: This saves the .meg file names list.
procedure  TBIGPackage.SaveMEGFileNameList(var _Output : TStream; const FileList : TMegNameList);
var
   i,c,Size,StringSize : uint32;
   PData,PCurrentData : puint8;
begin
   for i := Low(FileList) to High(FileList) do
   begin
      Size := 2 + Length(FileList[i].Name);
      GetMem(PData,Size);
      PCurrentData := PData;
      StringSize := Length(FileList[i].Name);
      uint16(puint16(PCurrentData)^) := StringSize;
      Inc(PCurrentData,2);
      c := 1;
      while (c <= StringSize) do
      begin
         uint8(puint8(PCurrentData)^) := uint8(FileList[i].Name[c]);
         Inc(PCurrentData,1);
         inc(c);
      end;
      _OutPut.Write(PData^,Size);
      FreeMem(PData);
   end;
end;

// 0.6 Save the file info list in the output
procedure TBIGPackage.SaveMEGFileHeaders(var _Output : TStream; _NumFiles, _HeaderSize : uint32; const _FileNameList : TMEGNameList; const _Pos : auint32);
var
   ID,i,Size,StringSize : uint32;
   PData,PCurrentData : puint8;
   CRCList : auint32;
begin
   Size := 20 * _NumFiles;
   GetMem(PData, Size);
   PCurrentData := PData;
   // Let's reorder all CRCs correctly.
   // First, we set it up.
   SetLength(CRCList,High(_FileNameList)+1);
   for ID := Low(CRCList) to High(CRCList) do
   begin
      CRCList[ID] := ID;
      inc(Files[ID].Offset,_HeaderSize);  // This is just conveniently placed here to update the Offsets quicker, but it has nothing to do with CRC.
   end;
   // Now, we do a proper reorder. (mergesort, because quicksort is bad for things that are almost sorted already)
   mergeSortCRC(CRCList,_FileNameList);

   // Now let's check each file of the package.
   for ID := Low(_FileNameList) to High(_FileNameList) do
   begin
      uint32(puint32(PCurrentData)^) := _FileNameList[CRCList[ID]].CRC;
      Inc(PCurrentData,4);
      uint32(puint32(PCurrentData)^) := ID;
      Inc(PCurrentData,4);
      uint32(puint32(PCurrentData)^) := Files[_Pos[CRCList[ID]]].Size;
      Inc(PCurrentData,4);
      uint32(puint32(PCurrentData)^) := Files[_Pos[CRCList[ID]]].Offset;
      Inc(PCurrentData,4);
      uint32(puint32(PCurrentData)^) := CRCList[ID];
      Inc(PCurrentData,4);
   end;
   _OutPut.Write(PData^,Size);
   FreeMem(PData);
end;


{$HINTS ON}
// This is how we reorder the CRCs from MEG files:
procedure TBIGPackage.mergeSortCRC(var _Vector : auint32; const _FileNameList : TMEGNameList);
begin
   mSortCRC(_Vector,_FileNameList,0,High(_Vector));
end;

procedure TBIGPackage.mergeCRC(var _Vector : auint32; const _FileNameList : TMEGNameList; _left, _middle, _right: uint32);
var
   i,end_left,num_elements,aux_pos: uint32;
   aux : auint32;
begin
   end_left := _middle-1;
   aux_pos := _left;
   num_elements := _right - _left + 1;
   SetLength(Aux,High(_Vector)+1);

   while ((_left <= end_left) and (_middle <= _right)) do
   begin
      if (_FileNameList[_Vector[_left]].CRC <= _FileNameList[_Vector[_middle]].CRC) then
      begin
         Aux[aux_pos] := _Vector[_left];
         inc(aux_pos);
         inc(_left);
      end
      else
      begin
         Aux[aux_pos] := _Vector[_middle];
         inc(aux_pos);
         inc(_middle);
      end;
   end;

   while (_left <= end_left) do
   begin
      Aux[aux_pos] := _Vector[_left];
      inc(_left);
      inc(aux_pos);
   end;

   while (_middle <= _right) do
   begin
      Aux[aux_pos] := _Vector[_middle];
      inc(_middle);
      inc(aux_pos);
   end;

   for i := 1 to num_elements do
   begin
      _Vector[_right] := Aux[_right];
      dec(_right);
   end;
end;

procedure TBIGPackage.mSortCRC (var _Vector: auint32; const _FileNameList : TMEGNameList; _left, _right: uint32);
var
   middle : uint32;
begin
   if (_right > _left) then
   begin
      middle := (_right + _left) div 2;
      mSortCRC(_Vector,_FileNameList,_left,middle);
      mSortCRC(_Vector,_FileNameList,middle+1,_right);
      mergeCRC(_Vector,_FileNameList,_left,middle+1,_right);
   end;
end;


// These are private functions and they have no check ups. Make sure the value
// passed to it won't be absurd.
procedure TBIGPackage.AddPointerToAlphabeticOrder(_Value : int32{PBIGFileUnit}; Position : int32);
var
   i : int32;
begin
   SetLength(AlphabeticOrder,High(AlphabeticOrder)+2);
   i := High(AlphabeticOrder);
   while (i > Position) do
   begin
      AlphabeticOrder[i] := AlphabeticOrder[i-1];
      dec(i);
   end;
   AlphabeticOrder[i] := _Value;
end;

procedure TBIGPackage.DeletePointerFromAlphabeticOrder(Position : uint32);
var
   i : int32;
begin
   i := Position;
   while (i < High(AlphabeticOrder)) do
   begin
      AlphabeticOrder[i] := AlphabeticOrder[i+1];
      inc(i);
   end;
   SetLength(AlphabeticOrder,High(AlphabeticOrder));
end;

function TBIGPackage.DoABinaryFileSearch(const _Name : string; var _previous: int32): int32;
var
   current : int32;
begin
   current := (High(AlphabeticOrder)+1) div 2;
   current := BinaryFileSearch(_Name,0,High(AlphabeticOrder),current,_previous);
   if current <> -1 then
   begin
      Result := Files[AlphabeticOrder[current]].Index;
   end
   else
   begin
      Result := -1;
   end;
end;

function TBIGPackage.DoABinaryFileSearch(const _Name : string): int32;
var
   current,previous : int32;
begin
   current := (High(AlphabeticOrder)+1) div 2;
   current := BinaryFileSearch(_Name,0,High(AlphabeticOrder),current,previous);
   if current <> -1 then
   begin
      Result := Files[AlphabeticOrder[current]].Index;
   end
   else
   begin
      Result := -1;
   end;
end;

function TBIGPackage.BinaryFileSearch(const _Name : string; _min, _max : int32; var _current,_previous : int32): int32;
var
   Comparison : int32;
   Current : uint32;
begin
   Comparison := CompareStr(_Name,Files[AlphabeticOrder[_current]].Filename);
   if Comparison = 0 then
   begin
      _previous := _current - 1;
      Result := _current;
   end
   else if Comparison > 0 then
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _max) div 2;
         Result := BinaryFileSearch(_Name,Current+1,_max,_current,_previous);
      end
      else
      begin
         _previous := _current;
         Result := -1;
      end;
   end
   else // < 0
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _min) div 2;
         Result := BinaryFileSearch(_Name,_min,Current-1,_current,_previous);
      end
      else
      begin
         _previous := _current - 1;
         Result := -1;
      end;
   end;
end;
// 0.6 File Repetition Support code ends here.

function TBIGPackage.InvertInteger(_i: uint32): uint32;
begin
   Result := (_i and $ff) shl 24;
   _i := _i shr 8;
   Result := Result + ((_i and $ff) shl 16);
   _i := _i shr 8;
   Result := Result + ((_i and $ff) shl 8);
   _i := _i shr 8;
   Result := Result + _i;
end;


function TBIGPackage.InvertInteger16(_i: uint16): uint16;
begin
   Result := (_i and $ff) shl 8;
   _i := _i shr 8;
   Result := Result + _i;
end;

// 0.6 aditions here. Or should it be removals? -- By Banshee
procedure TBIGPackage.DeleteFile(_ID: int32);
begin
   // Just mark it as invalid.
   Files[_ID].IsValid := false;
end;

procedure TBIGPackage.CopyFiles(_Source,_Dest: uint32);
begin
   Files[_Dest].Offset := Files[_Source].Offset;
   Files[_Dest].Size := Files[_Source].Size;
   Files[_Dest].Filename := Files[_Source].Filename;
   Files[_Dest].IsRepetition := Files[_Source].IsRepetition;
   Files[_Dest].IsValid := Files[_Source].IsValid;
   Files[_Dest].NextEqualFile := Files[_Source].NextEqualFile;
   Files[_Dest].ExternalFileLocation := Files[_Source].ExternalFileLocation;
end;

procedure TBIGPackage.DeleteFileData(Position : uint32);
var
   i : int32;
   MyNextFile : int32;
begin
   i := Position;
   MyNextFile := Files[i].NextEqualFile;
   if MyNextFile > i then
      dec(MyNextFile);
   while (i < High(Files)) do
   begin
      CopyFiles(i+1,i);
      // 0.6: we need to keep the integrity of NextEqualFile.
      if Files[i].NextEqualFile > int32(Position) then
         dec(Files[i].NextEqualFile)
      else if Files[i].NextEqualFile = int32(Position) then
         Files[i].NextEqualFile := MyNextFile;
      // Treat repetitions.
      if MyNextFile <> -1 then
      begin
         if Files[i].FirstRepetition = Position then
            Files[i].FirstRepetition := MyNextFile;
      end
      else
      begin
         if Files[i].FirstRepetition = Position then
         begin
            Files[i].FirstRepetition := i;
            Files[i].IsRepetition := false;
         end;
      end;
      inc(i);
   end;
   SetLength(Files,High(Files));
end;

function TBigPackage.DeleteIDFromAlphabeticOrder(_ID : int32): boolean;
var
   Previous, Position : int32;
begin
   if High(AlphabeticOrder) >= 0 then
   begin
      Position := (High(AlphabeticOrder)+1) div 2;
      Position := BinaryFileSearch(Files[_ID].Filename,0,High(AlphabeticOrder),Position,Previous);
   end
   else
   begin
      Position := -1;
      Previous := -1;
   end;
   if (Position = (-1)) then
   begin
      Result := false;
   end
   else
   begin
      DeletePointerFromAlphabeticOrder(Position);
      Result := true;
   end;
end;

procedure TBIGPackage.ClearUselessFiles;
var
   i : int32;
begin
   // Let's scan and remove the useles files first.
   i := High(Files);
   while (i > -1) do
   begin
      if Files[i].IsRepetition or (not Files[i].IsValid) then
      begin
         DeleteFileData(i);
      end;
      dec(i);
   end;
   // Now we update the Alphabetic Order.
   SetLength(AlphabeticOrder,0);
   for i := 0 to High(Files) do
   begin
      CommonAddFileTasks(i);
   end;
end;




// Gets
function TBIGPackage.GetNumFiles: uint32;
begin
   Result := High(Files)+1;
end;

function TBIGPackage.GetFileName: string;
begin
   Result := Filename;
end;

function TBIGPackage.GetUseCompression : boolean;
begin
   Result := (BIGType = C_BIG4);
end;

function TBIGPackage.GetPackageType: uint32;
begin
   Result := BIGType;
end;

function TBIGPackage.GetFileInfo (_ID : int32): TBIGFileUnit;
begin
		//D.van Loon AV fix  12-03-07
   if (_ID >= Low(Files)) and (_ID <= High(Files)) then
   begin
      Result := Files[_ID];
   end
   else
      raise Exception.Create(FrmBIGMain.Language.GetString('Exceptions','InvalidFileIndex'));
end;

// Originally written by Igi, modified by Banshee for faster action
function TBIGPackage.GetFileInfoByName(_ID : string): TBIGFileUnit;
var
   i : int32;
begin
   Result.Index := -1;

   if (_ID[1] = '\') then
   begin
      _ID := copy(_ID, 2, length(_ID));
   end;

   // Here I (Banshee) have modified Igi's code to use the new and faster
   // binary search
   i := DoABinaryFileSearch(_ID);
   if i <> -1 then
   begin
      Result := Files[i];
   end;
end;

// I/O :: Loading Files.
function TBIGPackage.ReadFile(_ID : int32; var _Data: puint8; var _DataSize: uint32): boolean;
begin
   result := false;
   if ValidFile and (_ID <= High(Files)) then
   begin
      if CompareStr(Files[_ID].ExternalFileLocation,'none') = 0 then
      begin
         ReadFileFromDisk(_ID,_Data,_DataSize);
      end
      else
      begin
         ReadFileFromExternalAddress(_ID,_Data,_DataSize);
      end;
      if (_DataSize > 0) then
         result := true;
   end;
end;


procedure TBIGPackage.ReadFileFromDisk(_ID : int32; var _Data : puint8; var _DataSize : uint32);
var
   MyFile: TStream;
   CompressedSize: integer;
begin
   MyFile := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite); // Open file

   // Store the whole file in the memory
   _DataSize := MyFile.Size;
   if _DataSize > 0 then
   begin
      if Files[_ID].Compression = C_AES128_COMPRESSION then
      begin
         if (Files[_ID].Size mod sizeof(TAESBuffer)) <> 0 then
         begin
            CompressedSize := Files[_ID].Size + (SizeOf(TAESBuffer) - (Files[_ID].Size mod SizeOf(TAESBuffer)));
         end
         else
         begin
            CompressedSize := Files[_ID].Size;
         end;
         Getmem(_Data, CompressedSize);
         MyFile.Seek(Files[_ID].Offset,soFromBeginning);
         MyFile.Read(_Data^, CompressedSize);
      end
      else
      begin
         Getmem(_Data, Files[_ID].Size);
         MyFile.Seek(Files[_ID].Offset,soFromBeginning);
         MyFile.Read(_Data^, Files[_ID].Size);
      end;
      _DataSize := Files[_ID].Size;
   end;
   MyFile.Free;
end;

procedure TBIGPackage.ReadFileFromExternalAddress(_ID : int32; var _Data : puint8; var _DataSize : uint32);
var
   MyFile: TStream;
begin
    MyFile := TFileStream.Create(Files[_ID].ExternalFileLocation, fmOpenRead or fmShareDenyWrite); // Open file

    // Store the whole file in the memory
    _DataSize := MyFile.Size;
    if _DataSize > 0 then
    begin
       // Get Memory for Original File
       Getmem(_Data, _DataSize);
       // Get original file.
       MyFile.Read(_Data^, _DataSize);
    end;
    MyFile.Free;
end;

function TBIGPackage.IsDataRefPackCompressed(var _Data : puint8; var _CompressedSize: uint32): boolean;
var
   FileWord : uint16;
begin
   FileWord := InvertInteger16(uint16(puint16(_Data)^));
   if ((FileWord and $3EFF) = $10FB) then
   begin
      Inc(_Data,2);
      if (FileWord and $8000) = 0 then
      begin
         _CompressedSize := _Data^ shl 16;
         Inc(_Data);
         _CompressedSize := _CompressedSize or (_Data^ shl 8);
         Inc(_Data);
         _CompressedSize := _CompressedSize or _Data^;
         Inc(_Data);
         if (FileWord and $100) > 0 then
            Inc(_Data,3);
      end
      else
      begin
         _CompressedSize := InvertInteger(uint32(puint32(_Data)^));
         if (FileWord and $100) > 0 then
         begin
            Inc(_Data,4);
         end;
         Inc(_Data,4);
      end;
      Result := true;
   end
   else
      Result := false;
end;

// 0.58b: I've splitted the code of this function into smaller ones to allow
// optimized file saving.
function TBIGPackage.GetFileContents( _ID : int32; var _Data : TStream; var _DataSize : uint32; _DecompressData : boolean = true) : Boolean;
var
   PData          : puint8;
   iPData         : puint8;
   PCData         : puint8;
   ZeroData       : puint8;
   CZeroData       : puint8;
   i               : integer;
   DataToBeDecrypted: TMemoryStream;
   BufferSize: integer;
begin
   Result := false;
   _DataSize := 0;
   if ReadFile(_ID,PData,_DataSize) then
   begin
      // Now, we create the contents and copy the interesting part.
      _Data := TMemoryStream.Create;
      iPData := PData;
      case Files[_ID].Compression of
         C_REFPACK_COMPRESSION:
         begin
            if IsDataRefPackCompressed(iPData,_DataSize) then
            begin
               GetMem(PCData,_DataSize);
               DecompressData(iPData, PCData);
               _Data.Write(PCData^, _DataSize);
               FreeMem(PCData);
            end;
         end;
         C_AES128_COMPRESSION:
         begin
            DataToBeDecrypted := TMemoryStream.Create;
            if (_DataSize mod SizeOf(TAESBuffer) <> 0) then
            begin
               BufferSize := _DataSize + (SizeOf(TAESBuffer) - (_DataSize mod SizeOf(TAESBuffer)));
            end
            else
            begin
               BufferSize := _DataSize;
            end;
            DataToBeDecrypted.Write(PData^, BufferSize);
            DataToBeDecrypted.Seek(0, soFromBeginning);
            DecryptAESStreamCBC(DataToBeDecrypted, BufferSize, AESKey^, AESInitialVector^, _Data);
            _Data.Size := _DataSize;
            _Data.Seek(0, soFromBeginning);
            DataToBeDecrypted.Free;
         end
         else
         begin
            _Data.Write(PData^,_DataSize);
         end;
      end;
      FreeMem(PData);
      Result := true;
   end;
end;

{$HINTS OFF}
procedure TBIGPackage.ExtractFileToTemp(_ID : int32);
var
   MyFile : TStream;
   Data : TStream;
   FileName, FileDir: string;
   DataSize : uint32;
begin
   if (_ID <= High(Files)) then
   begin
      if Files[_ID].IsValid then
      begin
         // Let's get the file name first
         FileName := FrmBIGMain.appTempDir + Files[_ID].Filename;
         FileDir := ExtractFileDir(FileName);
         ForceDirectories(FileDir);

         // Ok, let's extract the file contents.
         MyFile := TFileStream.Create(FileName,fmCreate);
         Data := TMemoryStream.Create;
         if GetFileContents(_ID,Data,DataSize) then
         begin
            Data.Seek(0,soFromBeginning);
            MyFile.Seek(0,soFromBeginning);
            MyFile.CopyFrom(Data,DataSize);
            // With the file created, we use the TempFileManager.
            // This should make the file be deleted when the package closes.
            FrmBIGMain.TempFiles.AddFile(Filename);

            // Now, let's update the File data to the temp file.
            Files[_ID].ExternalFileLocation := Filename;
            Files[_ID].Size := DataSize;
            Files[_ID].Offset := 0;
            Files[_ID].IsValid := true;
         end;
         MyFile.Free;
         Data.Free;
         Filename := '';
         FileDir := '';
      end;
   end;
end;
{$HINTS ON}

function TBIGPackage.IsFileInPackage(const _Filename : string): Boolean;
var
   Position : int32;
begin
   Position := DoABinaryFileSearch(_Filename);
   Result := (Position <> -1);
end;

function TBIGPackage.IsFileValid (_ID : int32): Boolean;
begin
   Result := Files[_ID].IsValid;
end;

function TBIGPackage.IsFileRepetition (_ID : int32): Boolean;
begin
   Result := Files[_ID].IsRepetition;
end;

function TBIGPackage.IsFileEditable(_ID : int32): Boolean;
begin
   Result := CompareStr(Files[_ID].ExternalFileLocation,'none') <> 0;
end;

// RefPack decompression function written by jonwil.
// Conversion from C to Delphi by Banshee.
{$HINTS OFF}
procedure TBIGPackage.DecompressData(var _Input,_Output : puint8);
var
   CurrInput,CurrOutput : puint8;
   Flags : uint32;
   code,code2,code3,code4 : uint8;
   count : uint32;
   TempBuffer : puint8;
   i : uint32;
begin
	flags := 0;
	code  := 0;
	code2 := 0;
	count := 0;
	code3 := 0;
	code4 := 0;
  CurrInput := _Input;
  CurrOutput := _Output;
	while (true) do
	begin
		code := CurrInput^;
   	inc(CurrInput);
		if (code and $80) = 0 then
		begin
			code2 := CurrInput^;
			inc(CurrInput);
			count := code and 3;
			for i := 1 to count do
			begin
				CurrOutput^ := CurrInput^;
				inc(CurrOutput);
				inc(CurrInput);
			end;
			TempBuffer := Puint8((Cardinal(CurrOutput) - 1) - (code2 + (code and $60) * 8));
			count := ((code and $1C) div 4) + 2;
			for i := 0 to count do
			begin
            try
				   CurrOutput^ := TempBuffer^;
            except
               ShowMessage(IntToStr(Cardinal(TempBuffer)));
               exit;
            end;
				inc(CurrOutput);
				inc(TempBuffer);
			end;
		end
		else if (code and $40) = 0 then
		begin
			code2 := CurrInput^;
			inc(CurrInput);
			code3 := CurrInput^;
			inc(CurrInput);
			count := code2 shr 6;
			for i := 1 to count do
			begin
				CurrOutput^ := CurrInput^;
				inc(CurrOutput);
				inc(CurrInput);
			end;
			TempBuffer :=PuInt8((Cardinal(CurrOutput) - 1) - (((code2 and $3F) shl 8) + code3));
			count := (code and $3F) + 3;
			for i := 0 to count do
			begin
				CurrOutput^ := TempBuffer^;
				inc(CurrOutput);
				inc(TempBuffer);
			end;
		end
		else if (code and $20) = 0 then
		begin
			code2 := CurrInput^;
			inc(CurrInput);
			code3 := CurrInput^;
			inc(CurrInput);
			code4 := CurrInput^;
			inc(CurrInput);
			count := code and 3;
			for i := 1 to count do
			begin
				CurrOutput^ := CurrInput^;
				inc(CurrOutput);
				inc(CurrInput);
			end;
			TempBuffer := PuInt8((Cardinal(CurrOutput) - 1) - ((((code and $10) shr 4) shl $10) + (code2 shl 8) + code3));
			count := (((code and $0C) shr 2) shl 8) + code4 + 4;
  			for i := 0 to count do
			begin
            try
				   CurrOutput^ := TempBuffer^;
            except
               ShowMessage(IntToStr(Cardinal(TempBuffer)));
               exit;
            end;
				inc(CurrOutput);
				inc(TempBuffer);
			end;
		end
		else
		begin
			count := ((code and $1F) * 4) + 4;
			if (count <= $70) then
			begin
				for i := 1 to count do
				begin
					CurrOutput^ := CurrInput^;
					inc(CurrOutput);
					inc(CurrInput);
				end;
			end
			else
			begin
				count := code and 3;
				for i := 1 to count do
				begin
					CurrOutput^ := CurrInput^;
					inc(CurrOutput);
					inc(CurrInput);
				end;
				exit;
			end;
		end;
	end;
end;
{$HINTS ON}

// 0.58: rewritten for Real Time Edition optimization.
function TBIGPackage.SaveAFile(_id : int32; var _Output : TStream; UseCompression : boolean): Boolean;
var
   DataSize       : uint32;
   PData          : puint8;
   PCData         : puint8;
   iPData         : puint8;
   iPCData        : puint8;
   CompressedSize : uint32;
begin
   Result := false;
   if ValidFile and (_ID <= High(Files)) then
   begin
      if ReadFile(_ID,PData,DataSize) then
      begin
         Files[_ID].Offset := uint32(_OutPut.Position);
         if not UseCompression then
         begin
            Files[_ID].Compression := C_NEVER_COMPRESSED;
            iPData := PData;
            if IsDataRefPackCompressed(iPData,DataSize) then
            begin
               GetMem(PCData,DataSize);
               DecompressData(iPData, PCData);
               _OutPut.Write(PCData^, DataSize);
               FreeMem(PCData);
            end
            else // Not compressed
            begin
               _OutPut.Write(PData^, DataSize);
            end;
            Files[_ID].Size := DataSize;
         end
         else // UseCompression
         begin
            iPData := PData;
            if IsDataRefPackCompressed(iPData,CompressedSize) then
            begin
               Files[_ID].Compression := C_REFPACK_COMPRESSION;
               _OutPut.Write(PData^, DataSize);
               Files[_ID].Size := DataSize;
            end
            else // Not Compressed.
            begin
               if Files[_ID].Compression = C_NO_COMPRESSION then
               begin
                  _OutPut.Write(PData^, DataSize);
                  Files[_ID].Size := DataSize;
               end
               else  // We never tried to compress it, so let's compress it.
               begin
                  // Get Memory for Compressed File (if it's bigger than that,
                  // it's not worth compressing at all)
                  Getmem(PCData, DataSize+8);
                  // Now, reset pointers.
                  iPData := PData;
                  iPCData := PCData;
                  if DataSize > 6 then
                  begin
                     // Set header.
                     if DataSize > $FFFFFF then
                     begin
                        iPCData^ := $90; //($10 and $80)
                        inc(IPCData);
                        iPCData^ := $FB;
                        inc(IPCData);
                        // Write source file size (4 bytes)
                        iPCData^:= (DataSize and $FF000000) shr 24;
                        inc(IPCData);
                        iPCData^:= (DataSize and $FF0000) shr 16;
                        inc(IPCData);
                        iPCData^:= (DataSize and $FF00) shr 8;
                        inc(IPCData);
                        iPCData^:= DataSize and $FF;
                        inc(IPCData);
                     end
                     else // filesize is 24bits or lower
                     begin
                        iPCData^ := $10;
                        inc(IPCData);
                        iPCData^ := $FB;
                        inc(IPCData);
                        // Write source file size (3 bytes)
                        iPCData^:= (DataSize and $FF0000) shr 16;
                        inc(IPCData);
                        iPCData^:= (DataSize and $FF00) shr 8;
                        inc(IPCData);
                        iPCData^:= DataSize and $FF;
                        inc(IPCData);
                     end;
                     if CompressFile(IPData,IPCData,DataSize) then
                     begin
                        CompressedSize := Cardinal(IPCData) - Cardinal(PCData);
                        if (CompressedSize >= DataSize) then
                        begin // the compressed file is bigger than the original
                           _OutPut.Write(PData^, DataSize);
                           Files[_ID].Size := DataSize;
                           Files[_ID].Compression := C_NO_COMPRESSION;
                        end
                        else  // compressed sucessfully.
                        begin
                           _OutPut.Write(PCData^, CompressedSize);
                           Files[_ID].Size := CompressedSize;
                           Files[_ID].Compression := C_REFPACK_COMPRESSION;
                        end;
                     end
                     else // could not compress it.
                     begin
                        _OutPut.Write(PData^, DataSize);
                        Files[_ID].Size := DataSize;
                        Files[_ID].Compression := C_NO_COMPRESSION;
                     end;
                  end
                  else // impossible to compress it. Too small.
                  begin
                     _OutPut.Write(PData^, DataSize);
                     Files[_ID].Size := DataSize;
                     Files[_ID].Compression := C_NO_COMPRESSION;
                  end;
                  FreeMem(PCData);
               end;
            end;
         end;
      end;
      FreeMem(PData);
      Result := true;
   end;
end;

function TBIGPackage.CompressFile(var source : puint8; var output : puint8; Size : uint32): Boolean;
var
   m_src_pos, m_src_end_pos, m_buf_end_pos : uint32;
   m_buf : puint8;
   m_by_first_2_bytes: ByFirst2BytesIndexArray;
   m_next : auint32;
   m_next_same : auint16;
begin
   Result := false;
   // This function compresses the file with Refpack
   try
      InitializeRefPackCompression(m_src_pos, m_src_end_pos, m_buf_end_pos, m_buf, m_by_first_2_bytes, m_next, m_next_same, Size);

      ReadAhead(source, m_buf, m_src_end_pos, m_buf_end_pos,2 * cNextIndexLength);
      while m_src_pos < m_src_end_pos do
      begin
         if not CompressionOneStep(m_buf, m_buf_end_pos, output, m_by_first_2_bytes, m_next, m_next_same, m_src_pos, m_src_end_pos) then
            exit;

		   if ((m_src_pos + cNextIndexLength) >= m_buf_end_pos) and (m_buf_end_pos < m_src_end_pos) then
			   ReadAhead(source, m_buf, m_src_end_pos, m_buf_end_pos, cNextIndexLength);
      end;
      Result := true;
   finally
      FinalizeRefPackCompression(m_buf, m_by_first_2_bytes, m_next, m_next_same);
   end;
end;

function TBIGPackage.IsValid : boolean;
begin
   Result := ValidFile;
end;

function TBIGPackage.IsRealTimeReady : boolean;
begin
   Result := IsValid and (Length(Filename) > 0);
end;

// Sets
procedure TBIGPackage.SetFilename(_ID : int32; _name : string);
var
   position,i : int32;
begin
   if (_ID > High(Files)) or (_ID < 0) then
      exit;
   // Check if current edited file is a repetition or not.
   if int32(Files[_ID].FirstRepetition) <> _ID then
   begin
      // This file is a repetition. Let's cut it from its cycle.
      i := Files[_ID].FirstRepetition;
      while Files[i].NextEqualFile <> -1 do
      begin
         if Files[i].NextEqualFile = _ID then
         begin
            Files[i].NextEqualFile := Files[_ID].NextEqualFile;
         end;
         i := Files[i].NextEqualFile;
      end;
   end
   else
   begin
      // We have two situations here: This file is alone or has repetitions.
      if Files[_ID].NextEqualFile = -1 then
      begin
         // Let's remove the ID from the alphabetic list:
         DeleteIDFromAlphabeticOrder(_ID);
      end
      else
      begin
         // Let's modify the alphabetic order.
         Position := DoABinaryFileSearch(Files[_ID].Filename);
         AlphabeticOrder[Position] := Files[_ID].NextEqualFile;

         // Next equal file will become Non Repetition.
         Files[Files[_ID].NextEqualFile].IsRepetition := false;

         // Now, let's browse all repetitions and modify them properly.
         i := Files[_ID].NextEqualFile;
         while Files[i].NextEqualFile <> -1 do
         begin
            Files[i].FirstRepetition := Files[_ID].NextEqualFile;
            // increment i
            i := Files[i].NextEqualFile;
         end;
      end;

   end;

   // Here we end renaming the element and CommonAddFileTasks will look up for
   // repetitions.
   Files[_ID].Filename := _name;
   CommonAddFileTasks(_ID);
end;

end.
