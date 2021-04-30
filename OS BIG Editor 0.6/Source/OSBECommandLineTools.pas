unit OSBECommandLineTools;

interface

uses BIG_File;

type
   TOSBECommandLineTools = class
      private
         procedure Interpreter;
      public
         constructor Create;
   end;

implementation

constructor TOSBECommandLineTools.Create;
begin
   if ParamCount > 1 then
   begin
      Interpreter;
   end
   else
   begin
      // Show Help
      WriteLn('This program requires parameters');
   end;
end;

procedure TOSBECommandLineTools.Interpreter;
var
   i: integer;
   CurrentParam: string;
begin
   for i := 1 to ParamCount - 1 do
   begin
      CurrentParam := ParamStr(i);
      if CurrentParam[1] = '-' then
      begin
         case CurrentParam[2] of
            'o':
            begin
               // Output files.
            end;
            'e':
            begin
               // Extract files.
            end;
         end;
      end;
   end;
end;

end.
