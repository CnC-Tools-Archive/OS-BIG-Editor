unit BasicFunctions;

interface

uses SysUtils;

procedure MakeMeADir(_Dir : string);

implementation

procedure MakeMeADir(_Dir : string);
var
   NewDir : string;
begin
   if not CreateDir(_Dir) then
   begin
      NewDir := ExtractFileDir(copy(_Dir,1,Length(_dir)-1));
      MakeMeADir(NewDir);
      CreateDir(_Dir);
   end;
end;

end.
