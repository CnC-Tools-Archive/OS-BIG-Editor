unit uFileViewer;

interface

uses
   Windows, Classes, Graphics, Targa, StdCtrls, ExtCtrls, BasicFunctions,
   SysUtils, PNGImage, jpeg, BasicDataTypes, FormBinaryWarning, BasicOptions,
   uTempFileManager, BasicConstants;

// Images
procedure PreviewTGA (var _Stream : TStream; var _Image : TImage; var _Memo : TMemo);
procedure PreviewPNG (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
procedure PreviewJPG (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
procedure PreviewBMP (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
// Binary
procedure PreviewBinary (var _Stream : TStream;  var _Memo : TMemo; _Size : uint32);
procedure PreviewText (var _Stream : TStream;  var _Memo : TMemo; _Size : uint32);

// The big thing:
procedure ShowFileContent (var _Stream : TStream; const _Size : uint32; var _Ext : string; var _Image : TImage; var _Memo : TMemo);


implementation

uses FormBIGMain;

procedure ShowFileContent (var _Stream : TStream; const _Size : uint32; var _Ext : string; var _Image : TImage; var _Memo : TMemo);
var
   FormWarning : TFrmBinaryWarning;
   BinDecision : uint8;
begin
   if FrmBIGMain.Options.OptPreviewImages then
   begin
      if CompareStr(_Ext,'.tga') = 0 then
      begin
         PreviewTGA(_Stream,_Image,_Memo);
         exit;
      end
      else if CompareStr(_Ext,'.png') = 0 then
      begin
         PreviewPNG(_Stream,_Image,_Memo);
         exit;
      end
      else if (CompareStr(_Ext,'.jpg') = 0) or (CompareStr(_Ext,'.jpeg') = 0) then
      begin
         PreviewJPG(_Stream,_Image,_Memo);
         exit;
      end
      else if CompareStr(_Ext,'.bmp') = 0 then
      begin
         PreviewBMP(_Stream,_Image,_Memo);
         exit;
      end;
   end;
   // Text and Binary files goes here.
   FrmBIGMain.SetWordWrap(FrmBIGMain.Options.OptWordWrap);
   _Memo.Lines.LoadFromStream(_Stream);
   _Image.Hide;
   if uint32(Length(_Memo.Lines.Text)) < _Size then
   begin
      // if the file has changed.
      if uint32(FrmBIGMain.TreeFiles.Selected.Data) <> FrmBIGMain.LastPreviewedFile then
      begin
         FrmBIGMain.LastPreviewedFile := uint32(FrmBIGMain.TreeFiles.Selected.Data);
         FrmBIGMain.ViewAsText := false;
      end;

      // This is for traditional binary files.
      if FrmBIGMain.ViewAsText then
      begin
         _Memo.Clear;
         PreviewText(_Stream,_Memo,_Stream.Size);
      end
      else if (_Size > FrmBIGMain.Options.OptMaxBinarySize) then
      begin
         if FrmBIGMain.Options.OptDefBinDecision = C_FBW_USER then
         begin
            FormWarning := TFrmBinaryWarning.Create(FrmBIGMain);
            FormWarning.LoadLanguage(_Size);
            FormWarning.ShowModal;
            BinDecision := FormWarning.Answer;
            FormWarning.Release;
         end
         else
         begin
            BinDecision := FrmBIGMain.Options.OptDefBinDecision;
         end;
         case (BinDecision) of
            C_FBW_LALL:
            begin
               _Memo.Clear;
               PreviewBinary(_Stream,_Memo,_Stream.Size);
            end;
            C_FBW_LLIMIT:
            begin
               _Memo.Clear;
               PreviewBinary(_Stream,_Memo,FrmBIGMain.Options.OptMaxBinarySize);
            end;
         end;
      end
      else
      begin
         _Memo.Clear;
         PreviewBinary(_Stream,_Memo,_Stream.Size);
      end;
   end;
   _Memo.Show;
end;

// This part was coded by Zlatko Minev and it was somewhat modified by Banshee
// although the original code was on FormBIGMain.
procedure PreviewTGA (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
var
   TempFile : string;
   MyFile : TStream;
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;
   try
      TempFile := GetTempFile('.tga');
      MyFile := TFileStream.Create(TempFile,fmCreate);
      MyFile.Seek(0,soFromBeginning);
      MyFile.CopyFrom(_Stream,_Stream.Size);
      MyFile.Free;
      LoadFromFileX(TempFile,Bitmap);
      _Image.Picture.Graphic := Bitmap
   finally
      _Memo.Hide;
      _Image.show;
      DeleteFile(TempFile);
      Bitmap.Free;
   end;
end;
// End of Zlatko Minev's modified code.


procedure PreviewPNG (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
var
   PNGObject : TPNGObject;
begin
   PNGObject := TPNGObject.Create;
   try
      PNGObject.LoadFromStream(_Stream);
      _Image.Picture.Graphic := PNGObject;
   finally
      _Memo.Hide;
      _Image.show;
      PNGObject.Free;
   end;
end;

procedure PreviewJPG (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
var
   JPEGImage : TJPEGImage;
begin
   JPEGImage := TJPEGImage.Create;
   try
      JPEGImage.LoadFromStream(_Stream);
      _Image.Picture.Graphic := JPEGImage;
   finally
      _Memo.Hide;
      _Image.show;
      JPEGImage.Free;
   end;
end;

procedure PreviewBMP (var _Stream : TStream;  var _Image : TImage; var _Memo : TMemo);
var
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;
   try
      Bitmap.LoadFromStream(_Stream);
      _Image.Picture.Graphic := Bitmap;
   finally
      _Memo.Hide;
      _Image.show;
      Bitmap.Free;
   end;
end;

procedure PreviewBinary (var _Stream : TStream;  var _Memo : TMemo; _Size : uint32);
var
   Address, BytesRead : uint32;
   MyNewLine : string;
   MyNextChars : array [0..15] of uint8;
   i : uint8;
   PData, PCurrentData : Puint8;
begin
   // Let's write line 1.
   FrmBIGMain.SetWordWrap(false);
   _Memo.Lines.BeginUpdate;
   _Memo.Lines.Add('     Address     | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 | +8 | +9 | +A | +B | +C | +D | +E | +F |     Dump');
   Address := 0;
   GetMem(PData,_Size);
   PCurrentData := PData;
   _Stream.Seek(0,soFromBeginning);
   _Stream.ReadBuffer(PData^,_Size);
   MyNewLine := '';
   while Address < _Size do
   begin
      // Get data from buffer.
      BytesRead := _Size - Address;
      if BytesRead > 16 then
         BytesRead := 16;
      i := 0;
      while i < BytesRead do
      begin
         MyNextChars[i] := PCurrentData^;
         inc(PCurrentData);
         inc(i);
      end;
      // Let's start with the address.
      MyNewLine := MyNewLine + IntToHex(Address,16) + ' | ';
      // Let's get the numbers.
      i := 0;
      while i < BytesRead do
      begin
         MyNewLine := MyNewLine + IntToHex(MyNextChars[i],2) + ' | ';
         inc(i);
      end;
      // Here we complete the line, if necessary.
      while i < 16 do
      begin
         MyNewLine := MyNewLine + '   | ';
         inc(i);
      end;
      // Now, we fill the dump part.
      i := 0;
      while i < BytesRead do
      begin
         if (MyNextChars[i] < 32) then
         begin
            MyNewLine := MyNewLine + ' ';
         end
         else
         begin
            MyNewLine := MyNewLine + char(MyNextChars[i]);
         end;
         inc(i);
      end;
      // Here we add the line
      MyNewLine := MyNewLine + char($D) + char($A);
      // Increment the address.
      inc(Address,16);
   end;
   // write the memo.
   _Memo.Lines.Add(MyNewLine);
   FreeMem(PData);
   _Memo.Lines.EndUpdate;
end;

procedure PreviewText (var _Stream : TStream;  var _Memo : TMemo; _Size : uint32);
var
   MyContent: string;
   BytesRead : uint32;
   PData, PCurrentData : Puint8;
begin
   GetMem(PData,_Size);
   PCurrentData := PData;
   _Stream.Seek(0,soFromBeginning);
   _Stream.ReadBuffer(PData^,_Size);
   MyContent := '';
   BytesRead := 0;
   while BytesRead < _Size do
   begin
      if PCurrentData^ = 0 then
      begin
         MyContent := MyContent + ' ';
      end
      else
      begin
         MyContent := MyContent + char(PCurrentData^);
      end;

      // Next char.
      inc(PCurrentData);
      inc(BytesRead);
   end;
   _Memo.Lines.BeginUpdate;
   _Memo.Lines.Add(MyContent);
   FreeMem(PData);
   _Memo.Lines.EndUpdate;
end;

end.
