(*******************************************************************************
 * Author
 *
 * Date
 *
 * Copyright
 ******************************************************************************)
unit BasicFunctions;

interface

uses
   SysUtils, ComCtrls, Windows, Dialogs;

procedure MakeMeADir(_Dir : string);
function GetTempDirectory: string;
function GetTempFile(FileExtension: string): string;
function IsDirectory(_Filename : string): boolean;
function CheckPath (Path: string): string;
function ClearDir (Path: string): boolean;

implementation


procedure MakeMeADir(_Dir : string);
begin
   // igi [11/03/2007] Use ForceDirectories rather than recursion
   ForceDirectories(_Dir);
end;

// igi codes continue here.
function GetTempDirectory: string;
var
   Len : integer;
   Dir : array[0..MAX_PATH] of char;
begin
   Result := '';
   Len    := GetTempPath(MAX_PATH, Dir);
   if (Len > 0) then
   begin
      Dir[Len] := #0;
      Result   := IncludeTrailingBackslash(Dir);
   end;
end;


function GetTempFile(FileExtension: string): string;
var
   TempFile   : array[0..MAX_PATH] of char;
   TempPrefix : array[0..6] of char;
   TempPath   : array[0..MAX_PATH] of char;
begin
   TempPrefix := 'osbig~'#0;

   StrPCopy(TempPath, IncludeTrailingBackslash(GetTempDirectory));

   if (GetTempFileName(TempPath, TempPrefix, 0, TempFile) > 0) then
   begin
      if (FileExtension <> '') then
      begin
         if (FileExists(TempFile)) then
         begin
            DeleteFile(TempFile);
         end;
         Result := ChangeFileExt(TempFile, FileExtension);
      end
      else
      begin
         Result := TempFile;
      end;
   end;
end;

function NodeAsPath(Node: TTreeNode): string;
var
   TempNode : TTreeNode;
begin
   Result := '';

   TempNode := Node;
   while (TempNode <> nil) do
   begin
      if (Result <> '') then
      begin
         Result := TempNode.Text + '\' + Result
      end
      else
      begin
         Result := TempNode.Text;
      end;

      TempNode := TempNode.Parent;
   end;
end;


function PathToNode(const Path: string; Tree: TTreeView): TTreeNode;
begin
   Result := nil;

   if (Tree.Items.Count > 0) then
   begin
      Result := Tree.Items[0];
      while (Result <> nil) and (AnsiCompareText(NodeAsPath(result), Path) <> 0) do
      begin
         Result := Result.GetNext;
      end;
   end;
end;


procedure TreeAddFolderPath(const Path: string; Tree: TTreeView);
var
   TempNode : TTreeNode;
   s        : string;
   i        : integer;
   buffer   : string;
begin
   buffer := ExcludeTrailingBackSlash(Path);

   if (buffer <> '') and (buffer[1] = '\') then
   begin
      Delete(buffer, 1, 1);
   end;

   if (buffer <> '') then
   begin
      s := buffer;
      TempNode := PathToNode(s, Tree);
      while ((s <> '') and (ExtractFilePath(s) <> s) and (TempNode = nil)) do
      begin
         s := ExcludeTrailingBackSlash(ExtractFilePath(s));
         TempNode := PathToNode(s, Tree);
      end;

      if (TempNode <> nil) then
      begin
         Delete(buffer, 1, Length(s));
      end;

      if ((buffer <> '') and (buffer[1] = '\')) then
      begin
         Delete(buffer, 1, 1);
      end;

      if ((buffer <> '') and (buffer[Length(buffer)] <> '\')) then
      begin
         buffer := buffer +'\';
      end;

      while (buffer <> '') do
      begin
         i := Pos('\', buffer);
         if (i > 1) then
         begin
            s := Copy(buffer, 1, i -1);
            Delete(buffer, 1, i);

            if (TempNode = nil) then
            begin
               TempNode := Tree.Items.Add(nil, s)
            end
            else
            begin
               TempNode := Tree.Items.AddChild(TempNode, s);
            end;
         end;
      end;
   end;
end;

function IsDirectory(_Filename : string): boolean;
begin
   Result := not FileExists(_Filename);
end;


// Both functions below were made by Marius le Roux
// langbaba_le_roux@hotmail.com

// And taken from http://www.torry.net/dpfl/system.html
// Note from Banshee: I couldn't be arsed to code these

  { Make sure given file path is ended with backslash ("\") }
function CheckPath (Path: string): string;
begin
   Path := trim (Path);
   if Path <> '' then
      if Path[length (Path)] <> '\' then
         Path := Path + '\';
   Result := Path;
end;

  { Make sure given file path is ended with backslash ("\") }
 { Clears Directory: Removes all files and directories contained }
function ClearDir (Path: string): boolean;
var
  Res: integer;
  SRec: TSearchRec;
begin
   Result := false;
   try
      Path := CheckPath (Path);
      Res := FindFirst (Path + '*.*', faAnyFile, SRec);
      while Res = 0 do
      begin
         if (SRec.Attr and faDirectory <> 0) and (SRec.Name[1] <> '.') then
         begin
            ClearDir (Path + SRec.Name); { Clear before removing }
            if not RemoveDir (pchar(Path + SRec.Name)) then
               exit;
         end
         else
            SysUtils.DeleteFile(Path + SRec.Name);
         Res := FindNext(SRec);
      end;
      SysUtils.FindClose(SRec);
      Result := true;
   except
      on e:Exception do
         MessageDlg (e.Message, mtError, [mbOk], 0);
   end;
end;

end.
