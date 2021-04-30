(*******************************************************************************
 * Author  Danny van Loon
 *
 * Date    Unknown
 *
 * Copyright
 ******************************************************************************)
unit uIconHelper;

interface

uses
	Classes,Controls,SysUtils,Windows,Graphics;

type
   PHICON = ^HICON;


  	TIconHelper = class(TObject)
   private
  	   referenceList :TStringList;
      sourceList:TImageList;

      procedure GetAssociatedIcon(FileName: TFilename;  PSmallIcon: PHICON);
   public
  		Constructor create(aSourceList:TImageList);
      destructor Destroy; override;

      function GetImageIndex(fileName: String): Integer;
   end;

implementation

uses
	FormBIGMain,registry,ShellAPI;

{ TIconHelper }
// -----------------------------------------------------------------------------
constructor TIconHelper.create(aSourceList: TImageList);
begin
	referenceList := TStringList.Create;
   SourceList := aSourceList;

   if (sourceList.Count < 2) then
  	   raise Exception.Create(	FrmBIGMain.Language.GetString('Exceptions','IconHelperLackingIconsPart1') + ' '+#10#13 + FrmBIGMain.Language.GetString('Exceptions','IconHelperLackingIconsPart2'));
end;
// -----------------------------------------------------------------------------
destructor TIconHelper.Destroy;
begin
	referenceList.Free;
   inherited Destroy;
end;
// -----------------------------------------------------------------------------
function TIconHelper.GetImageIndex(fileName: String): Integer;
var
	ext:String;
  SmallIcon: HICON;
  smallObject:TIcon;
  iconIndex:Integer;
begin
	ext := ExtractFileExt(Filename);
   //folder
   if (ext = '') then
   begin
  	   Result := 0;
      exit;
   end;

   //quick list   (uses the object indicator as an integer index for imagelist)
   iconIndex := referenceList.IndexOf(ext);
   if (iconIndex <> -1) then
  	   Result := Integer(referenceList.Objects[iconIndex])
   //windows reference
   else
   begin
		GetAssociatedIcon(fileName, @SmallIcon);
  	   if (SmallIcon <> 0) then
      begin
        	//create a TIcon to be added to the imagelist
    	   smallObject := TIcon.Create;
         smallObject.Handle := smallIcon;

         //add the icon to the imagelist
         Result := sourceList.AddIcon(smallObject);

         //save the itemIndex in our quick reference, saves the integer index as a pointer
         referenceList.AddObject(ext,TObject(Result));
      end
      else
 			Result := 1;
   end;
end;
// -----------------------------------------------------------------------------
procedure TIconHelper.GetAssociatedIcon(FileName: TFilename;  PSmallIcon: PHICON);
// Gets the icons of a given file
var
   IconIndex: UINT;  // Position of the icon in the file
   FileExt, FileType: string;
   Reg: TRegistry;
   PLargeIcon:PHICON;
   p: integer;
   p1, p2: pchar;
label
   noassoc;
begin
   IconIndex := 0;
   PLargeIcon:= nil;
   // Get the extension of the file
   FileExt := UpperCase(ExtractFileExt(FileName));
   if ((FileExt <> '.EXE') and (FileExt <> '.ICO')) or
      not FileExists(FileName) then
   begin
      // If the file is an EXE or ICO and it exists, then
      // we will extract the icon from this file. Otherwise
      // here we will try to find the associated icon in the
      // Windows Registry...
      Reg := nil;
      try
         Reg := TRegistry.Create(KEY_QUERY_VALUE);
         Reg.RootKey := HKEY_CLASSES_ROOT;
         if FileExt = '.EXE' then
            FileExt := '.COM';
         if Reg.OpenKeyReadOnly(FileExt) then
         try
            FileType := Reg.ReadString('');
         finally
            Reg.CloseKey;
         end;
         if (FileType <> '') and Reg.OpenKeyReadOnly(FileType + '\DefaultIcon') then
         try
            FileName := Reg.ReadString('');
         finally
            Reg.CloseKey;
         end;
      finally
         Reg.Free;
      end;

      // If we couldn't find the association, we will
      // try to get the default icons
      if FileName = '' then goto noassoc;

      // Get the filename and icon index from the
      // association (of form '"filaname",index')
      p1 := PChar(FileName);
      p2 := StrRScan(p1, ',');
      if p2 <> nil then
      begin
         p := p2 - p1 + 1; // Position of the comma
         IconIndex := StrToInt(Copy(FileName, p + 1,Length(FileName) - p));
         SetLength(FileName, p - 1);
      end;
   end;
   // Attempt to get the icon
   if ExtractIconEx(pchar(FileName), IconIndex, PLargeIcon^, PSmallIcon^, 1) <> 1 then
   begin
      noassoc:
      // The operation failed or the file had no associated
      // icon. Try to get the default icons from SHELL32.DLL
      FileName := '%SYSTEM%\SHELL32.DLL';

      // Determine the default icon for the file extension
      if      (FileExt = '.DOC') then
         IconIndex := 1
      else if (FileExt = '.EXE') or (FileExt = '.COM') then
         IconIndex := 2
      else if (FileExt = '.HLP') then
         IconIndex := 23
      else if (FileExt = '.INI') or (FileExt = '.INF') then
         IconIndex := 63
      else if (FileExt = '.TXT') then
         IconIndex := 64
      else if (FileExt = '.BAT') then
         IconIndex := 65
      else if (FileExt = '.DLL') or (FileExt = '.SYS') or (FileExt = '.VBX') or (FileExt = '.OCX') or (FileExt = '.VXD') then
         IconIndex := 66
      else if (FileExt = '.FON') then
         IconIndex := 67
      else if (FileExt = '.TTF') then
         IconIndex := 68
      else if (FileExt = '.FOT') then
         IconIndex := 69
      else
         IconIndex := 0;
      // Attempt to get the icon.
      if ExtractIconEx(pchar(FileName), IconIndex, PLargeIcon^, PSmallIcon^, 1) <> 1 then
      begin
         // Failed to get the icon. Just "return" zeroes.
         if PLargeIcon <> nil then
            PLargeIcon^ := 0;
         if PSmallIcon <> nil then
            PSmallIcon^ := 0;
      end;
   end;
end;
// -----------------------------------------------------------------------------
end.
