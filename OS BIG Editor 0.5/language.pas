unit language;

interface

uses SysUtils,Dialogs;

const
   DEBUG_MAX = 46;

type
   TLangChunks = (lcgHierarchy,lcgHierarchies,lcgMesh,lcgMeshes,lcgAnimation,lcgAnimations,lcgCompAnimations,lcgAggregate,lcgAggregates,lcgHLOD,lcgHLODS,lcgBox,lcgBoxes,lcgEmitter,lcgEmitters,lcgDazzles,lcgB00);

var
   DebugString : array[0..DEBUG_MAX] of string;
   ChunkString : array[TLangChunks] of string;

type
   TLangCategory = (lcUnknown,lcMain,lcDebugWords,lcMenu,lcFileMenu,lcDebugMenu,lcHelpMenu,lcToolBar,lcActionModeMenu,lcAnimationModeMenu,lcLeftSectionCats,lcChunkTypes);

   function LoadLanguage(const Filename : string): boolean;

implementation

uses FormBIGMain;

function LoadLanguage(const Filename : string): boolean;
var
   TextFile : Text;
   Line : string;
   CatNum : longword;
   CurrentCat : TLangCategory;
begin
   result := false;
   CurrentCat := lcUnknown;
   CatNum := 0;
   if not FileExists(Filename) then
   begin
      ShowMessage('The Language You Are Trying To Load Does Not Exist');
      exit;
   end;
   AssignFile(TextFile,Filename);
   Reset(TextFile);
   while not EOF(TextFile) do
   begin
      readln(TextFile,Line);
      // Check the type of this line
      if Length(Line) > 0 then
      case (Line[1]) of
         '#': // Coments. Do Nothing.
         begin
         end;
         ' ': // Coments. Do Nothing.
         begin
         end;
         '[': // Change Category
         begin
            CatNum := 0;
            if CompareStr(Line,'[Main]') = 0 then
               CurrentCat := lcMain
            else if CompareStr(Line,'[DebugWords]') = 0 then
               CurrentCat := lcDebugWords
            else if CompareStr(Line,'[Menu]') = 0 then
               CurrentCat := lcMenu
            else if CompareStr(Line,'[FileMenu]') = 0 then
               CurrentCat := lcFileMenu
            else if CompareStr(Line,'[DebugMenu]') = 0 then
               CurrentCat := lcDebugMenu
            else if CompareStr(Line,'[HelpMenu]') = 0 then
               CurrentCat := lcHelpMenu
            else if CompareStr(Line,'[ToolBar]') = 0 then
               CurrentCat := lcToolBar
            else if CompareStr(Line,'[ActionModeMenu]') = 0 then
               CurrentCat := lcActionModeMenu
            else if CompareStr(Line,'[AnimationModeMenu]') = 0 then
               CurrentCat := lcAnimationModeMenu
            else if CompareStr(Line,'[LeftSectionCats]') = 0 then
               CurrentCat := lcLeftSectionCats
            else if CompareStr(Line,'[ChunkTypes]') = 0 then
               CurrentCat := lcChunkTypes
            else
               CurrentCat := lcUnknown;
         end;
         else
         begin
            // Unknown category also becomes comments
            if CurrentCat <> lcUnknown then
            begin
               // Now we add the names for each category.
               case CurrentCat of
                  lcMain:
                  begin
                     AplicationName := Copy(Line,0,Length(Line));
                     FormBIGMain.Caption := AplicationName + ' ' + APP_VERSION;
                  end;
                  lcDebugWords:
                  begin
                     if CatNum < DEBUG_MAX then
                     begin
                        DebugString[CatNum] := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcMenu:
                  begin
                     case CatNum of
                        0: FormBIGMain.File1.Caption := Copy(Line,0,Length(Line));
                        1: FormBIGMain.Debug1.Caption := Copy(Line,0,Length(Line));
                        2: FormBIGMain.Help1.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcFileMenu:
                  begin
                     case CatNum of
                        0 :
                        begin
                           FormBIGMain.Open2.Caption := Copy(Line,0,Length(Line));
                           FormBIGMain.ToolOpenUnit.Hint := Copy(Line,0,Length(Line));
                        end;
                        1: FormBIGMain.Close1.Caption := Copy(Line,0,Length(Line));
                        2: FormBIGMain.File2.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcDebugMenu:
                  begin
                     case CatNum of
                        0: FormBIGMain.Open1.Caption := Copy(Line,0,Length(Line));
                        1: FormBIGMain.Evaluate1.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcHelpMenu:
                  begin
                     case CatNum of
                        0:
                        begin
                           FormBIGMain.HelpContents1.Caption := Copy(Line,0,Length(Line));
                           FormBIGMain.ToolHelp.Hint := Copy(Line,0,Length(Line));
                        end;
                        1:
                        begin
                           FormBIGMain.About1.Caption := Copy(Line,0,Length(Line));
                           FormBIGMain.ToolAbout.Hint := Copy(Line,0,Length(Line));
                        end;
                     end;
                  end;
                  lcToolBar:
                  begin
                     case CatNum of
                        0: FormBIGMain.ComboUnit.Hint := Copy(Line,0,Length(Line));
                        1: FormBIGMain.ToolNewCamera.Hint := Copy(Line,0,Length(Line));
                        2: FormBIGMain.ComboCamera.Hint := Copy(Line,0,Length(Line));
                        3: FormBIGMain.ToolMode.Hint := Copy(Line,0,Length(Line));
                        4: FormBIGMain.ToolX.Hint := Copy(Line,0,Length(Line));
                        5: FormBIGMain.ToolY.Hint := Copy(Line,0,Length(Line));
                        6: FormBIGMain.ToolZ.Hint := Copy(Line,0,Length(Line));
                        7: FormBIGMain.ToolXY.Hint := Copy(Line,0,Length(Line));
                        8: FormBIGMain.ToolFloor.Hint := Copy(Line,0,Length(Line));
                        9: FormBIGMain.ToolSky.Hint := Copy(Line,0,Length(Line));
                        10: FormBIGMain.ToolAnimMode.Hint := Copy(Line,0,Length(Line));
                        11: FormBIGMain.ToolAnimPlay.Hint := Copy(Line,0,Length(Line));
                        12: FormBIGMain.ToolAnimPause.Hint := Copy(Line,0,Length(Line));
                        13: FormBIGMain.ToolAnimStop.Hint := Copy(Line,0,Length(Line));
                        14: FormBIGMain.ToolScreenshot.Hint := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcActionModeMenu:
                  begin
                     case CatNum of
                        0: FormBIGMain.Camera1.Caption := Copy(Line,0,Length(Line));
                        1: FormBIGMain.Unit1.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcAnimationModeMenu:
                  begin
                     case CatNum of
                        0: FormBIGMain.Animation1.Caption := Copy(Line,0,Length(Line));
                        1: FormBIGMain.Emitter1.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcLeftSectionCats:
                  begin
                     case CatNum of
                        0: FormBIGMain.TabContents.Caption := Copy(Line,0,Length(Line));
                        1: FormBIGMain.TabAction.Caption := Copy(Line,0,Length(Line));
                        2: FormBIGMain.TabDebug.Caption := Copy(Line,0,Length(Line));
                     end;
                  end;
                  lcChunkTypes:
                  begin
                     if CatNum <= Cardinal(High(ChunkString)) then
                     begin
                        ChunkString[TLangChunks(CatNum)] := Copy(Line,0,Length(Line));
                     end;
                  end;
               end;
               inc(CatNum);
            end;
         end;
      end;
   end;
   CloseFile(TextFile);
   result := true; // Language read
end;

end.
