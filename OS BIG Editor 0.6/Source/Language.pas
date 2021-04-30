(*******************************************************************************
 * Author      igi
 *
 * Date        11/03/2007
 *
 * Copyright
 ******************************************************************************)
unit Language;

interface

uses
   BasicConstants;
// -------------------- Removed by Banshee --- 14/03/3007
// Added by Banshee, let's organize the strings that we won't load in the
// beggining of the program. So, I'm separating by forms, one for common, one
// for language names and one for the random warnings that may appear outside
// the form files.
{
type
   BasicStringTypes = (bstCommon,bstDestination,bstOptions,bstAbout,bstNewDir,bstWarnings,bstLanguages);
   CommonStringTypes = (cstOK,cstCancel,cstNewDir,cstApply);
   WarningsStringTypes = (wstNoAdminRights);
   DestinationStringTypes = (cstSelectNewDest);
   OptionsStringTypes = (ostPreferences,ostPreferencesDescription,ostFileAssociation,ostAssociateMeWithBIGFiles,ostIcon,ostLanguage,ostSelectLanguage);
   AboutStringTypes = (astAbout,astVersion,astCreatedBy,astMajorContribution,astOtherContributions,astDragAndDrop,astTARGA,astTranslatedBy,astTranslator,astMinev,astVanLoon,astIgi,astPrabab);
   NewDirStringTypes = (ndstNewDir);
   LanguageStringTypes = (lstEnglish,lstBrazilian,lstPolish,lstSpanish,lstGerman,lstFrench,lstDutch,lstRussian,lstBulgarian,lstPortuguese,lstItalian,lstJapanese,lstChinese,lstHebrew,lstArab,lstUKEnglish,lstGreek,lstUSEnglish,lstSwedish,lstDanish,lstFinish,lstNorwegian);
}
// -------------------- End Of Removal from Banshee --- 14/03/3007

// Banshee's Multi-Language support starts here
type
   TLanguage = class
   public
      // Constructors and Destructors
      constructor Create;
      // I/O
      // Gets
      function GetString(_Category : string; _StringIdent : string) : widestring;
      function GetFilename: string;
      // Sets
      procedure SetFilename(const _Filename : string);
   private
      // Basic Variables
      Filename: string;
   end;


implementation

uses
   SysUtils, INIFiles;

// Constructors and Destructors
constructor TLanguage.Create;
begin
   Filename := '';
end;

// Gets
function TLanguage.GetString(_Category : string; _StringIdent : string): widestring;
var
   LanguageFile : TINIFile;
begin
   Result := LANG_NO_STRING;

   if (FileExists(Filename)) then
   begin
      LanguageFile := TINIFile.Create(Filename);
      try
         Result := LanguageFile.ReadString(_Category, _StringIdent, LANG_NO_STRING);
      finally
         FreeAndNil(LanguageFile);
      end;
   end;
end;

function TLanguage.GetFilename: string;
begin
   Result := Filename;
end;

// Sets
procedure TLanguage.SetFilename(const _Filename : string);
begin
   Filename := _Filename;
end;

end.
