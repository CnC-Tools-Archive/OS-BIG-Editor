unit MIX_File;

interface

uses BasicDataTypes, BasicConstants, BIG_File, Classes, Blowfish_WS_Key;

const
   cb_mix_key = 56;
   cb_mix_key_source = 80;
   cb_mix_checksum = 20;


function Encrypt(length : int32; const plaintext; var cyphertext): HRESULT; external 'BLOWFISH.DLL';
function Decrypt(length : int32; const cyphertext; var plaintext): HRESULT; external 'BLOWFISH.DLL';
function SetKey(length: int32; var key): HRESULT; external 'BLOWFISH.DLL';


implementation

procedure Load_MIXHeader(var _Data : puint8; var _NumFiles : uint32; var _Size: uint32);
var
   DecryptionFlag : uint32;
   KeySource,KeyP : pointer;
   Key : array [0..79] of byte;
   MyWord : puint8;
begin
   DecryptionFlag := uint32(puint32(_Data)^);
   if (DecryptionFlag and $00020000) <> 0 then
   begin
      // Our mix header is encrypted.
      inc(_Data,4);
      KeySource := _Data;
      KeyP := @Key;
//      get_blowfish_key(KeySource, KeyP);
      inc(_Data,cb_mix_key_source);
      KeyP := @Key;
      SetKey(cb_mix_key_source,Key);
      GetMem(MyWord, 8);
      Decrypt(8,_Data,MyWord);
   end
   else
   begin
      if ((DecryptionFlag and $00010000) <> 0) or (DecryptionFlag = 0) then
      begin
         inc(_Data,4);
      end;
      _NumFiles := uint16(puint16(_Data)^);
      inc(_Data,2);
      _Size := uint32(puint32(_Data)^);
   end;
end;
end.
