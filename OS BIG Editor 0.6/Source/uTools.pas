(*******************************************************************************
 * Author  Danny van Loon
 *
 * Date    13/03/2007
 *
 * Copyright
 ******************************************************************************)
unit uTools;

interface

uses
	ComCtrls,sysUtils,classes, BasicDataTypes;
{

    Created By: 		D.van Loon
    Created On:			13-03-07
    Description:		Utility file to host all "tool" function
    								Saves other units from getting cluttered

    Modified by:
    Modified on:
    Modifications:

}

   function TreeSort(Node1, Node2: TTreeNode; Data: Integer): Integer stdcall;  //Treeview 13-03-07
   procedure ExtractStringsEx(delimiters:TSysCharSet;source:String;output:TStrings);
   procedure OpenHyperlink(HyperLink: PChar);
   procedure OpenProgram(_Program, _Parameters: PChar);
   function TreatLink(const _Link: string): string;
   Function GetParamStr : String;

implementation

uses
	shellApi,Forms,Windows;

// -----------------------------------------------------------------------------
// Copied from OS SHP Builder, probably coded by Stucuk.
procedure OpenHyperlink(HyperLink: PChar);
begin
   ShellExecute(Application.Handle,nil,HyperLink,'','',SW_SHOWNORMAL);
end;
// -----------------------------------------------------------------------------
// 0.6b: This was done to Open with Notepad feature. -- Banshee
procedure OpenProgram(_Program, _Parameters: PChar);
begin
   ShellExecute(Application.Handle,'open',_Program,_Parameters,'',SW_SHOWNORMAL);
end;
// -----------------------------------------------------------------------------
// 0.6b: This should avoid the link/parameters from mess up due to spaces. -- Banshee
function TreatLink(const _Link: string): string;
var
   i : int32;
   NeedsDoubleQuote : Boolean;
begin
   Result := '';
   NeedsDoubleQuote := false;
   i := 2;
   while (i < Length(_Link)) and (not NeedsDoubleQuote) do
   begin
      if _Link[i] = ' ' then
      begin
         NeedsDoubleQuote := true;
      end;
      inc(i);
   end;
   if NeedsDoubleQuote then
   begin
      Result := '"' + _Link + '"';
   end
   else
   begin
      Result := copy(_Link,1,Length(_Link));
   end;
end;
// -----------------------------------------------------------------------------
function TreeSort(Node1, Node2: TTreeNode; Data: Integer): Integer stdcall;
var
	isDir1,isDir2:Boolean;
begin
   //sort prefering directories. place those on top

	isDir1 := Node1.ImageIndex = 0;
   isDir2 := Node2.ImageIndex = 0;

   if (isDir1 and not isDir2) then
  	   Result := -1
   else if (not isDir1 and isDir2) then
  	   Result := 1
   else
  	   Result := CompareStr(Lowercase(Node1.Text),Lowercase(Node2.Text));
end;
// -----------------------------------------------------------------------------
procedure ExtractStringsEx(delimiters: TSysCharSet; source: String; output: TStrings);
var
	i :Integer;
  s:String;
begin
	if output = nil then exit;

   for i:=1 to (Length(source)) do
  	   if source[i] in delimiters then
      begin
    	   output.Add(s);
         s := '';
      end
      else
    	   s := s + source[i];

   if (s <> '') then
  	   output.Add(s);
end;
// -----------------------------------------------------------------------------
// Ripped from Voxel Section Editor III 1.36 and all other OS Tools.
// Probably originally writen by Stucuk for OS SHP Builder.
Function GetParamStr : String;
var
   x : integer;
begin
   Result := '';
   for x := 1 to ParamCount do
      if Result <> '' then
         Result := Result + ' ' + ParamStr(x)
      else
         Result := ParamStr(x);
end;
// -----------------------------------------------------------------------------
end.
