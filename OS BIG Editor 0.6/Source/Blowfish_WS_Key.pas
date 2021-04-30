unit Blowfish_WS_Key;

interface

uses SysUtils;

const
   pubkey_str = 'AihRvNoIbTn85FZRYNZRcT+i6KpU+maCsEqr3Q5q+LDB5tH7Tz2qQ38V';

   char2num : array[0..255] of shortint = (
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

type
   bignum4 = array[0..3] of longword;
   bignum = array[0..63] of longword;
   bignum130 = array[0..129] of longword;
   Pbignum = ^bignum;
   Pbignum4 = ^bignum4;
   PoChar = ^char;
   ByteArray = array of byte;
   PByteArray = ^ByteArray;

   tpubkey = record
      key1 : bignum;
      key2 : bignum;
      len : longword;
   end;

var
   glob1 : PBignum;
   glob1_bitlen, glob1_len_x2 : longword;
   glob2 : bignum130;
   glob1_hi, glob1_hi_inv : PBignum4;
   glob1_hi_bitlen : longword;
   glob1_hi_inv_lo, glob1_hi_inv_hi : longword;
   pubkey : tpubkey;

   procedure get_blowfish_key(const s : array of byte; var d : array of byte);

implementation


// static void init_bignum(bignum n, dword val, dword len)
procedure init_bignum(var n: Bignum; val : longword; len : longword); overload;
begin
   Initialize(n,len * 4);
   n[0] := val;
end;

procedure init_bignum(var n: Bignum4; val : longword; len : longword); overload;
begin
   Initialize(n,len * 4);
   n[0] := val;
end;

function getWord(const n: PBignum): Word;
begin
	Result := Word(PWord(n)^);
end;

procedure writeWord(data : Word; const Dest : PBignum);
var
   x : PBignum;
begin
   x := Dest;
	x^[0] := data and $ff;
   inc(x);
	x^[0] := data shr 8;
   inc(x);
end;


// static void move_key_to_big(bignum n, char *key, dword klen, dword blen)
procedure move_key_to_big(var n: Bignum; key : PChar; klen : longword; blen : longword);
var
   sign: longword;
   i : integer;
begin
   if (Byte(key[0]) and $80) <> 0 then
      sign := $FF
   else
      sign := 0;

   i := blen*4;
   while (i > klen) do
   begin
      n[i-1] := Byte(sign);
      dec(i);
   end;
   while (i > 0) do
   begin
      n[i-1] := Byte(key[klen-i]);
      dec(i);
   end;
end;

// static void key_to_bignum(bignum n, char *key, dword len)
procedure key_to_bignum(n : Bignum; key : PChar; len: longword);
var
   keylen : longword;
   i,t : integer;
begin
   if (Byte(key[0]) <> 2) then exit;
   inc(key);

   if (Byte(key[0]) and $80) <> 0 then
   begin
      keylen := 0;
      i := 0;
      while (i < (Byte(key[0]) and $7f)) do
      begin
         keylen := (keylen shl 8) or Byte(key[i+1]);
         inc(i);
      end;
      key := key + (Byte(key[0]) and $7f) + 1;
   end
   else
   begin
      keylen := Byte(key[0]);
      inc(key);
   end;
   if (keylen <= len*4) then
       move_key_to_big(n, key, keylen, len);
end;

// static dword len_bignum(bignum n, dword len)
function len_bignum(var n : bignum; len: longword): longword; overload;
var
   i : integer;
begin
  i := len-1;
  while ((i >= 0) and (n[i] = 0)) do
      dec(i);
  result := i+1;
end;

function len_bignum(var n : bignum4; len: longword): longword; overload;
var
   i : integer;
begin
  i := len-1;
  while ((i >= 0) and (n[i] = 0)) do
      dec(i);
  result := i+1;
end;


// static dword bitlen_bignum(bignum n, dword len)
function bitlen_bignum(var n: bignum; len: longword): longword; overload;
var
   ddlen, bitlen, mask : longword;
begin
   ddlen := len_bignum(n, len);
   if (ddlen = 0) then
   begin
      result := 0;
      exit;
   end;
   bitlen := ddlen * 32;
   mask := $80000000;
   while ((mask and n[ddlen-1]) = 0) do
   begin
      mask := mask shr 1;
      dec(bitlen);
   end;
   result := bitlen;
end;

function bitlen_bignum(var n: bignum4; len: longword): longword; overload;
var
   ddlen, bitlen, mask : longword;
begin
   ddlen := len_bignum(n, len);
   if (ddlen = 0) then
   begin
      result := 0;
      exit;
   end;
   bitlen := ddlen * 32;
   mask := $80000000;
   while ((mask and n[ddlen-1]) = 0) do
   begin
      mask := mask shr 1;
      dec(bitlen);
   end;
   result := bitlen;
end;


procedure init_pubkey;
var
    i, i2, tmp: longword;
    keytmp : array[0..255] of char;
    pub_key : PBignum;
begin
    pub_key := @(pubkey.key2);
    init_bignum(pub_key^, $10001, 64);

    i := 0;
    i2 := 0;
    while (i < length(pubkey_str)) do
    begin
       tmp := char2num[StrToInt(pubkey_str[i])];
       inc(i);
       tmp := tmp shl 6;
       tmp := tmp or char2num[StrToInt(pubkey_str[i])];
       inc(i);
       tmp := tmp shl 6;
       tmp := tmp or char2num[StrToInt(pubkey_str[i])];
       inc(i);
       tmp := tmp shl 6;
       tmp := tmp or char2num[StrToInt(pubkey_str[i])];
       inc(i);
       keytmp[i2] := Char((tmp shr 16) and $ff);
       inc(i2);
       keytmp[i2] := Char((tmp shr 8) and $ff);
       inc(i2);
       keytmp[i2] := Char(tmp and $ff);
       inc(i2);
    end;
    key_to_bignum(pubkey.key1, keytmp, 64);
    pubkey.len := bitlen_bignum(pubkey.key1, 64) - 1;
end;

function len_predata(): longword;
var
   a : longword;
begin
   a := (pubkey.len - 1) shr 3;
   result := (55 div a + 1) * (a + 1);
end;

// static long int cmp_bignum(bignum n1, bignum n2, dword len)
function cmp_bignum(const n1: Bignum; const n2: Bignum; len: longword): integer; overload;
var
   i : longword;
begin
   i := len-1;
   while (len > 0) do
   begin
      if (n1[i] < n2[i]) then
      begin
         result := -1;
         exit;
      end;
      if (n1[i] > n2[i]) then
      begin
         result := 1;
         exit;
      end;
      dec(i);
      dec(len);
   end;
   result := 0;
end;

function cmp_bignum(const n1: Bignum4; const n2: Bignum4; len: longword): integer; overload;
var
   i : longword;
begin
   i := len-1;
   while (len > 0) do
   begin
      if (n1[i] < n2[i]) then
      begin
         result := -1;
         exit;
      end;
      if (n1[i] > n2[i]) then
      begin
         result := 1;
         exit;
      end;
      dec(i);
      dec(len);
   end;
   result := 0;
end;

procedure mov_bignum(var dest: Pbignum; var src: Pbignum; len: longword);
begin
   Move(dest^, src^, len*4);
end;

procedure shr_bignum(var n: bignum; bits: longword; len: longint); overload;
var
   i, i2: longword;
begin
   i2 := bits shr 5;
   if (i2 > 0) then
   begin
      i := 0;
      while (i < len - i2) do
      begin
         n[i] := n[i + i2];
         inc(i);
      end;
      while (i < len) do
      begin
         n[i] := 0;
         inc(i);
      end;
      bits := bits mod 32;
   end;
   if (bits = 0) then exit;

   for i := 0 to len - 2 do
      n[i] := (n[i] shr bits) or (n[i + 1] shl (32 - bits));
   n[i] := n[i] shr bits;
end;

procedure shr_bignum(var n: bignum4; bits: longword; len: longint); overload;
var
   i, i2: longword;
begin
   i2 := bits shr 5;
   if (i2 > 0) then
   begin
      i := 0;
      while (i < len - i2) do
      begin
         n[i] := n[i + i2];
         inc(i);
      end;
      while (i < len) do
      begin
         n[i] := 0;
         inc(i);
      end;
      bits := bits mod 32;
   end;
   if (bits = 0) then exit;

   for i := 0 to len - 2 do
      n[i] := (n[i] shr bits) or (n[i + 1] shl (32 - bits));
   n[i] := n[i] shr bits;
end;

procedure shl_bignum(var n: bignum; bits: longword; len: longword); overload;
var
   i, i2: longword;
begin
   i2 := bits shr 5;
   if (i2 > 0) then
   begin
      i := len - 1;
      while (i > i2) do
      begin
         n[i] := n[i - i2];
         dec(i);
      end;
      while (i > 0) do
      begin
         n[i] := 0;
         dec(i);
      end;
      bits := bits mod 32;
   end;
   if (bits = 0) then exit;
   i := len - 1;
   while (i > 0) do
   begin
      n[i] := (n[i] shl bits) or (n[i - 1] shr (32 - bits));
      dec(i);
   end;
   n[0] := n[0] shl bits;
end;

procedure shl_bignum(var n: bignum4; bits: longword; len: longword); overload;
var
   i, i2: longword;
begin
   i2 := bits shr 5;
   if (i2 > 0) then
   begin
      i := len - 1;
      while (i > i2) do
      begin
         n[i] := n[i - i2];
         dec(i);
      end;
      while (i > 0) do
      begin
         n[i] := 0;
         dec(i);
      end;
      bits := bits mod 32;
   end;
   if (bits = 0) then exit;
   i := len - 1;
   while (i > 0) do
   begin
      n[i] := (n[i] shl bits) or (n[i - 1] shr (32 - bits));
      dec(i);
   end;
   n[0] := n[0] shl bits;
end;

function get_word_from_bignum(const src : bignum; index : longword; bool : byte): word; overload;
begin
   case (bool) of
   0:
   begin
      result := src[index] and $FF;
   end;
   1:
   begin
      result := src[index] and $FF00;
   end;
   end;
end;

function get_word_from_bignum(const src : bignum4; index : longword; bool : byte): word; overload;
begin
   case (bool) of
   0:
   begin
      result := src[index] and $FF;
   end;
   1:
   begin
      result := src[index] and $FF00;
   end;
   end;
end;

procedure put_word_into_bignum(var src : bignum; index : longword; bool : byte; value: longword); overload;
begin
   case (bool) of
   0:
   begin
      src[index] := value and $FF;
   end;
   1:
   begin
      src[index] := (value shl 16) and $FF00;
   end;
   end;
end;

procedure put_word_into_bignum(var src : bignum4; index : longword; bool : byte; value: longword); overload;
begin
   case (bool) of
   0:
   begin
      src[index] := value and $FF;
   end;
   1:
   begin
      src[index] := (value shl 16) and $FF00;
   end;
   end;
end;

// static dword sub_bignum(bignum dest, bignum src1, bignum src2, dword carry, dword len)
function sub_bignum(var dest: bignum; const src1: bignum; const src2: bignum; carry: longword; len: longword): longword; overload;
var
   i1, i2: longword;
   x: longword;
   bool : byte;
begin
   len := len * 2;
   dec(len);
   x := 0;
   bool := 0;
   while (len <> -1) do
   begin
      i1 := get_word_from_bignum(src1,x,bool);
      i2 := get_word_from_bignum(src2,x,bool);
      put_word_into_bignum(dest,x,bool,i1 - i2 - carry);
      Bool := Bool xor 1;
      if Bool = 0 then
         inc(x);
      if ((i1 - i2 - carry) and $10000) <> 0 then
         carry := 1
      else
         carry := 0;
      dec(len);
  end;
  result := carry;
end;

function sub_bignum(var dest: bignum4; const src1: bignum4; const src2: bignum4; carry: longword; len: longword): longword; overload;
var
   i1, i2: longword;
   x: longword;
   bool : byte;
begin
   len := len * 2;
   dec(len);
   x := 0;
   bool := 0;
   while (len <> -1) do
   begin
      i1 := get_word_from_bignum(src1,x,bool);
      i2 := get_word_from_bignum(src2,x,bool);
      put_word_into_bignum(dest,x,bool,i1 - i2 - carry);
      Bool := Bool xor 1;
      if Bool = 0 then
         inc(x);
      if ((i1 - i2 - carry) and $10000) <> 0 then
         carry := 1
      else
         carry := 0;
      dec(len);
  end;
  result := carry;
end;

procedure inv_bignum(var n1, n2 : Pbignum; len: longword); overload;
var
  n_tmp : Pbignum;
  n2_bytelen, bit : longword;
  n2_bitlen : longint;
  n1index : byte;
begin
   init_bignum(n_tmp^, 0, len);
   init_bignum(n1^, 0, len);
   n1index := 0;
   n2_bitlen := bitlen_bignum(n2^, len);
   bit := 1 shl (n2_bitlen mod 32);
   n1index := ((n2_bitlen + 32) shr 5) - 1;
   n2_bytelen := ((n2_bitlen - 1) shr 5) shl 2;
   n_tmp[n2_bytelen shl 2] := n_tmp[n2_bytelen shl 2] or (1 shl ((n2_bitlen - 1) and $1f));

   while (n2_bitlen > 0) do
   begin
      dec(n2_bitlen);
      shl_bignum(n_tmp^, 1, len);
      if (cmp_bignum(n_tmp^, n2^, len) <> -1) then
      begin
         sub_bignum(n_tmp^, n_tmp^, n2^, 0, len);
         n1[n1index] := n1[n1index] or bit;
      end;
      bit := bit shr 1;
      if (bit = 0) then
      begin
         dec(n1index);
         bit := $80000000;
      end;
  end;
  init_bignum(n_tmp^, 0, len);
end;

procedure inv_bignum(var n1, n2 : pbignum4; len: longword); overload;
var
   n_tmp : pbignum4;
   n2_bytelen, bit : longword;
   n2_bitlen : longint;
   n1index : byte;
begin
   init_bignum(n_tmp^, 0, len);
   init_bignum(n1^, 0, len);
   n1index := 0;
   n2_bitlen := bitlen_bignum(n2^, len);
   bit := 1 shl (n2_bitlen mod 32);
   n1index := ((n2_bitlen + 32) shr 5) - 1;
   n2_bytelen := ((n2_bitlen - 1) shr 5) shl 2;
   n_tmp[n2_bytelen shl 2] := n_tmp[n2_bytelen shl 2] or (1 shl ((n2_bitlen - 1) and $1f));

   while (n2_bitlen > 0) do
   begin
      dec(n2_bitlen);
      shl_bignum(n_tmp^, 1, len);
      if (cmp_bignum(n_tmp^, n2^, len) <> -1) then
      begin
         sub_bignum(n_tmp^, n_tmp^, n2^, 0, len);
         n1[n1index] := n1[n1index] or bit;
      end;
      bit := bit shr 1;
      if (bit = 0) then
      begin
         dec(n1index);
         bit := $80000000;
      end;
  end;
  init_bignum(n_tmp^, 0, len);
end;


procedure inc_bignum(var n : bignum; len: longword); overload;
var
   index : word;
begin
   index := 0;
   dec(len);
   inc(n[index]);
   while ((n[index] = 0) and (len > 0)) do
   begin
      inc(index);
      inc(n[index]);
      dec(len);
   end;
end;

procedure inc_bignum(var n : bignum4; len: longword); overload;
var
   index : word;
begin
   index := 0;
   dec(len);
   inc(n[index]);
   while ((n[index] = 0) and (len > 0)) do
   begin
      inc(index);
      inc(n[index]);
      dec(len);
   end;
end;

procedure init_two_dw(var n: PBignum; len: longword);
var
   Glob1a : PBignum;
begin
   mov_bignum(glob1, n, len);
   glob1_bitlen := bitlen_bignum(glob1^, len);
   glob1_len_x2 := (glob1_bitlen + 15) shr 4;
   glob1a := glob1;
   inc(glob1,len_bignum(glob1^, len) - 2);
   mov_bignum(PBignum(glob1_hi),glob1, 2);
   glob1 := glob1a;
   glob1_hi_bitlen := bitlen_bignum(glob1_hi^, 2) - 32;
   shr_bignum(glob1_hi^, glob1_hi_bitlen, 2);
   inv_bignum(glob1_hi_inv, glob1_hi, 2);
   shr_bignum(glob1_hi_inv^, 1, 2);
   glob1_hi_bitlen := (glob1_hi_bitlen + 15) mod 16 + 1;
   inc_bignum(glob1_hi_inv^, 2);
   if (bitlen_bignum(glob1_hi_inv^, 2) > 32) then
   begin
      shr_bignum(glob1_hi_inv^, 1, 2);
      dec(glob1_hi_bitlen);
   end;
   glob1_hi_inv_lo := word(glob1_hi_inv);
   glob1_hi_inv_hi := word(glob1_hi_inv) + 1;
end;


procedure mul_bignum_word(var n1:PBignum; var n2: PBignum; mul : longword; len: longword);
var
  i, tmp:longword;
begin
   tmp := 0;
   for i := 0 to len-1 do
   begin
      tmp := mul * getWord(n2) + getWord(n1) + tmp;
      WriteWord(tmp,n1);
      WriteWord((GetWord(n1) + 1),n1);
      WriteWord((GetWord(n2) + 1),n2);
      tmp := tmp shr 16;
   end;
   WriteWord(GetWord(n1) + tmp,n1);
end;


procedure mul_bignum(var dest:PBignum; var src1, src2: PBignum; len: longword);
var
   i : longword;
begin
   init_bignum(dest^, 0, len*2);
   for i := 0 to ((len*2)-1) do
   begin
      mul_bignum_word(dest, src1, GetWord(src2), len*2);
      WriteWord((GetWord(src2) + 1),src2);
      WriteWord((GetWord(dest) + 1), dest);
   end;
end;


procedure not_bignum(var n: pbignum; len: longword);
var
   i : longword;
begin
   for i :=0 to (len-1) do
   begin
      n^[i]:= not n^[i];
   end;
end;

procedure neg_bignum(var n: pbignum; len : longword);
begin
   not_bignum(n, len);
   inc_bignum(n^, len);
end;

function get_mulword(var n: pbignum): longword;
var
   i : longword;
   wn,wnMinus1: ^word;
begin
   new(wn);
   wn^ := GetWord(n);
{
   wnMinus1 := pointer(longword(wn - 1));
   i := ((((((((((wnMinus1)^ xor $ffff) and $ffff) * glob1_hi_inv_lo + $10000) shr 1)
      + ((((wn-2)^ xor $ffff) * glob1_hi_inv_hi + glob1_hi_inv_hi) shr 1) + 1)
      shr 16) + (((((wn-1)^ xor $ffff) and $ffff) * glob1_hi_inv_hi) shr 1) +
      (((wn^ xor $ffff) * glob1_hi_inv_lo) shr 1) + 1) shr 14) + glob1_hi_inv_hi
      * (wn^ xor $ffff) * 2) shr glob1_hi_bitlen;
   if (i > $ffff) then
      i := $ffff;
}
   Result := i and $ffff;
end;

procedure dec_bignum(var n: pbignum; len: longword);
begin
{
    dec(n^);
    dec(len);
    while ((n^ = $ffffffff) and (len > 0)) do
    begin
       inc(n);
       dec(n^);
       dec(len);
    end;
}
end;


procedure calc_a_bignum(var n1: pbignum; var n2: pbignum; var n3: pbignum; len: longword);
var
    g2_len_x2, len_diff: longword;
    esi, edi: ^word;
    tmp: word;
begin
{
    mul_bignum(glob2, n2, n3, len);
    glob2[len*2] := 0;
    g2_len_x2 := len_bignum(glob2, len*2+1)*2;
    if (g2_len_x2 >= glob1_len_x2) then
    begin
       inc_bignum(glob2, len*2+1);
       neg_bignum(glob2, len*2+1);
       len_diff := g2_len_x2 + 1 - glob1_len_x2;
       esi := GetWord(glob2) + (1 + g2_len_x2 - glob1_len_x2);
       edi := GetWord(glob2) + (g2_len_x2 + 1);
       while (len_diff <> 0) do
       begin
          dec(edi);
          tmp := get_mulword((longword)(edi^));
          dec(esi);
          if (tmp > 0) then
          begin
             mul_bignum_word((longword)(esi^), glob1, tmp, 2*len);
             if ((edi^ and $8000) = 0) then
             begin
                if (sub_bignum((longword)(esi^), (longword)(esi^), glob1, 0, len)) <> 0 then
                  dec(edi^);
             end;
          end;
          dec(len_diff);
        end;
        neg_bignum(glob2, len);
        dec_bignum(glob2, len);
    end;
    mov_bignum(n1, glob2, len);
}
end;

procedure clear_tmp_vars(len: longword);
begin
{
   init_bignum(glob1, 0, len);
   init_bignum(glob2, 0, len);
   init_bignum(glob1_hi_inv, 0, 4);
   init_bignum(glob1_hi, 0, 4);
   glob1_bitlen := 0;
   glob1_hi_bitlen := 0;
   glob1_len_x2 := 0;
   glob1_hi_inv_lo := 0;
   glob1_hi_inv_hi := 0;
}
end;

procedure calc_a_key(var n1, n2, n3, n4: pbignum; len: longword);
var
    n_tmp: pbignum;
    n3_len, n4_len, n3_bitlen, bit_mask: longword;
begin
{
    init_bignum(n1, 1, len);
    n4_len := len_bignum(n4, len);
    init_two_dw(n4, n4_len);
    n3_bitlen := bitlen_bignum(n3, n4_len);
    n3_len := (n3_bitlen + 31) / 32;
    bit_mask := (((longword)(1)) shl ((n3_bitlen - 1) mod 32)) shr 1;
    n3 := n3 + n3_len - 1;
    dec(n3_bitlen);
    mov_bignum(n1, n2, n4_len);
    dec(n3_bitlen);
    while (n3_bitlen <> -1) do
    begin
       if (bit_mask = 0) then
       begin
          bit_mask := $80000000;
          dec(n3);
       end;
       calc_a_bignum(n_tmp, n1, n1, n4_len);
       if (n3^ and bit_mask) <> 0 then
          calc_a_bignum(n1, n_tmp, n2, n4_len)
       else
          mov_bignum(n1, n_tmp, n4_len);
       bit_mask = bit_mask shr 1;
       dec(n3_bitlen);
    end;
    init_bignum(n_tmp, 0, n4_len);
    clear_tmp_vars(len);
}
end;

// static void process_predata(const byte* pre, dword pre_len, byte *buf)
procedure process_predata(const pre : array of byte; pre_len: longword; buf: array of byte);
var
   n2, n3 : bignum;
   a : longword;
begin
{
   a := (pubkey.len - 1) shr 3;
   while ((a + 1) <= pre_len) do
   begin
      init_bignum(n2, 0, 64);
      Move(pre, n2, a + 1);
      calc_a_key(n3, n2, pubkey.key2, pubkey.key1, 64);

      Move(n3, buf, a);

      pre_len := pre_len - (a + 1);
      pre := pre + a + 1;
      buf := buf + a;
   end;
}
end;

// void get_blowfish_key(const byte* s, byte* d)
procedure get_blowfish_key(const s : array of byte; var d : array of byte);
var
   key : array[0..255] of byte;
   i : longword;
begin
   init_pubkey;
   process_predata(s, len_predata(), key);
   for i := 0 to 55 do
   begin
      d[i] := key[i];
   end;
end;

end.

