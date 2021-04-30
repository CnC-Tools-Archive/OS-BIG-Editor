(*******************************************************************************
 * Author:  Banshee
 *
 * Date:    26/07/2007
 *
 * Copyright: This file adapts the refpack compression code from KUDr, which
 * follows the GPL.
 ******************************************************************************)

unit RefPackFunctions;

// This file brings some functions written by KUDr and converted to Delphi
// that helps to compress files with RefPack compression.

interface

uses BasicDataTypes, Math;

const
   cInvalidPos = $FFFFFFFF;
   cNextIndexLength = $8000;
   cBufferLength = 4 * cNextIndexLength;
   cMaxSubstringsInChain = $40;
   cHashEnd = $10000;
   cBufferShadowLength = cNextIndexLength;

type
   ByFirst2BytesIndexItem = record
		m_first: uint32;    // first (least recent) position of these 2 bytes in the stream
		m_last: uint32;     // last known (most recent) position of those 2 bytes in the stream
		m_num: uint32;      // number of occurrences of these 2 bytes inside the 'look back' window (0x20000 bytes)
		m_max_num: uint32;  // max of m_num
   end;
   ByFirst2BytesIndexArray = array of ByFirst2BytesIndexItem;

   var
      max_max_num : uint32;
      copylimit : uint32;
      copiedbytes : uint32;
      limitreached : boolean;

procedure WriteBuffer(const m_buf : puint8; var m_dst : puint8; pos: uint32; length: uint32);
procedure InitializeRefPackCompression(var m_src_pos, m_src_end_pos, m_buf_end_pos : uint32; var m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32;  var m_next_same : auint16; size : uint32);
procedure ReadAhead(var m_src : puint8; const m_buf : puint8; var m_src_end_pos, m_buf_end_pos : uint32; length: uint32);
function IsGoodScoreForDstOffset(score: uint32; offset: uint32): boolean;
function HashMe(pos: uint32; const m_buf: puint8): uint32;
function MatchingScore(pos1, pos2: uint32; min_score: uint32; const m_buf: puint8; m_buf_end_pos: uint32): uint32;
procedure AddKnownSubstring(pos: uint32; const m_buf: puint8; var m_buf_end_pos : uint32; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32; var m_next_same : auint16);
procedure RemoveKnownSubstring(pos: uint32; const m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : array of uint32);
function FindBestMatchingKnownSubstring(pos: uint32; var best_score: uint32; const m_buf: puint8; var m_buf_end_pos : uint32; var m_by_first_2_bytes: ByFirst2BytesIndexArray; const m_next : auint32; const m_next_same : auint16): uint32;
procedure CopySourceAndFinish(const m_buf : puint8; var m_dst: puint8; src_copy_from : uint32; src_copy_num_bytes: uint32);
procedure CombinedCopy(const m_buf : puint8; var m_dst: puint8; src_copy_from: uint32; src_copy_num_bytes: uint32; dst_copy_from: uint32; dst_copy_num_bytes: uint32);
function CompressionOneStep(const m_buf : puint8; var m_buf_end_pos : uint32; var m_dst: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32; var m_next_same : auint16; var m_src_pos, m_src_end_pos : uint32): boolean;
procedure FinalizeRefPackCompression(var m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32;  var m_next_same : auint16);

implementation

procedure WriteBuffer(const m_buf : puint8; var m_dst : puint8; pos: uint32; length: uint32);
var
   count : uint32;
   source : puint8;
begin
   count := length;
   source := m_buf;
   inc(source,pos mod cBufferLength);
   if (copiedbytes + length) > copylimit then
   begin
      limitreached := true;
   end
   else
   begin
      while count > 0 do
      begin
         m_dst^ := source^;
         inc(m_dst);
         inc(source);
         dec(count);
      end;
      inc(copiedbytes,length);
   end;
end;

procedure ReadAhead(var m_src : puint8; const m_buf : puint8; var m_src_end_pos, m_buf_end_pos : uint32; length: uint32);
var
   idx : uint32;
   i : uint32;
   endcopy : uint32;
   bufferspot : puint8;
   shadowspot : puint8;
begin
	if (m_buf_end_pos >= m_src_end_pos) then
      exit;
	if (m_buf_end_pos + length > m_src_end_pos) then
   begin
		length := m_src_end_pos - m_buf_end_pos;
	end;
	idx := m_buf_end_pos mod cBufferLength;
   // Copy source to buffer.
   bufferspot := m_buf;
   inc(bufferspot,idx);
   endcopy := idx + length;
   for i := idx to endcopy do
   begin
      bufferspot^ := m_src^;
      inc(m_src);
      inc(bufferspot);
   end;
   // Copy buffer to shadow, if possible.
	if (idx < cBufferShadowLength) then
   begin
      endcopy := idx + min(length,cBufferShadowLength - idx);
      bufferspot := m_buf;
      inc(bufferspot,idx);
      shadowspot := bufferspot;
      inc(shadowspot,cBufferLength);
      for i := idx to endcopy do
      begin
         shadowspot^:= bufferspot^;
         inc(shadowspot);
         inc(bufferspot);
      end;
	end;
	inc(m_buf_end_pos,length);
end;

procedure InitializeRefPackCompression(var m_src_pos, m_src_end_pos, m_buf_end_pos : uint32; var m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32;  var m_next_same : auint16; size : uint32);
var
   i : uint32;
begin
   // Initialize arrays:
   setlength(m_by_first_2_bytes,cHashEnd);
   setlength(m_next,cNextIndexLength);
   setlength(m_next_same,cNextIndexLength);
   GetMem(m_buf,cBufferLength + cBufferShadowLength);

	m_src_pos := 0;
	m_src_end_pos := Size;
	m_buf_end_pos := 0;

	// clear our substring index
   for i := 0 to High(m_next) do
   begin
		m_next[i] := cInvalidPos;
	end;

	for i := 0 to  High(m_by_first_2_bytes) do
   begin
		m_by_first_2_bytes[i].m_first := cInvalidPos;
		m_by_first_2_bytes[i].m_last := cInvalidPos;
		m_by_first_2_bytes[i].m_num := 0;
		m_by_first_2_bytes[i].m_max_num := 0;
   end;

   max_max_num := 0;
   copylimit := Size;
   copiedbytes := 0;
   limitreached := false;
end;


function IsGoodScoreForDstOffset(score: uint32; offset: uint32): boolean;
begin
	Result := true;
   if (score < 3) then
   begin
		Result := false;
	end
   else if (score < 4) then
   begin
		Result := (offset <= $400);
	end
   else if (score < 5) then
   begin
		Result := (offset <= $4000);
   end;
end;

function HashMe(pos: uint32; const m_buf: puint8): uint32;
var
   c : puint8;
begin
	// hash (made from first 2 chars of substring) used as index into m_first and m_last
   c := Puint8(Cardinal(m_buf) + (pos mod cBufferLength));
	Result := (c^ shl 8);
   inc(c);
   inc(Result,c^);
end;

function MatchingScore(pos1, pos2: uint32; min_score: uint32; const m_buf: puint8; m_buf_end_pos: uint32): uint32;
var
   c1, c2 : puint8;
   score, max_score : uint32;
begin
	max_score := Min(m_buf_end_pos - pos2 - 1, cNextIndexLength);
	score := min_score;
	c1 := puint8(Cardinal(m_buf)+ (pos1 mod cBufferLength) + score);
	c2 := puint8(Cardinal(m_buf)+ (pos2 mod cBufferLength) + score);
	while (score < max_score) and (c1^ = c2^) do
   begin
		inc(score);
      inc(c1);
      inc(c2);
	end;
	Result := score;
end;

procedure AddKnownSubstring(pos: uint32; const m_buf: puint8; var m_buf_end_pos : uint32; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32; var m_next_same : auint16);
var
   hash : uint32;
   remove_from_pos : uint32;
   prev_pos : uint32;
begin
	// hash (made from first 2 chars of substring) used as index into
   // m_first and m_last
   hash := HashMe(pos, m_buf);
	//ByFirst2BytesIndexItem &by_first_2_bytes = m_by_first_2_bytes[hash];

	if (m_by_first_2_bytes[hash].m_num >= cMaxSubstringsInChain) then
   begin
		// too many such substrings in this chunk
		// - remove the oldest one (performance optimization)
		remove_from_pos := m_by_first_2_bytes[hash].m_first;
		RemoveKnownSubstring(remove_from_pos, m_buf, m_by_first_2_bytes, m_next);
   end;

	//by_first_2_bytes.m_num++;
   inc(m_by_first_2_bytes[hash].m_num);

	if (m_by_first_2_bytes[hash].m_num > m_by_first_2_bytes[hash].m_max_num) then
   begin
		m_by_first_2_bytes[hash].m_max_num := m_by_first_2_bytes[hash].m_num;
		if (m_by_first_2_bytes[hash].m_max_num > max_max_num) then
      begin
			max_max_num := m_by_first_2_bytes[hash].m_max_num;
		end;
   end;
   // previous occurrence of similar substring (with the same hash)
	prev_pos := m_by_first_2_bytes[hash].m_last;

	// new last in the chain will be our substring
	m_by_first_2_bytes[hash].m_last := pos;

	// ensure that there is some 'first' in the chain
	if (prev_pos = cInvalidPos) then
   begin
		// we found the first occurrence of the substring
		m_by_first_2_bytes[hash].m_first := pos;
		m_next_same[prev_pos mod cNextIndexLength] := 2;
	end
   else
   begin
      // it isn't the first occurrence of the substring
		// link the previous occurrence to the current one
		m_next[prev_pos mod cNextIndexLength] := pos;
		m_next_same[prev_pos mod cNextIndexLength] := MatchingScore(prev_pos, pos, 2, m_buf, m_buf_end_pos) and $FFFF;
	end;
end;

procedure RemoveKnownSubstring(pos: uint32; const m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : array of uint32);
var
   hash : uint32;
   position : uint32;
begin
	// hash (made from first 2 chars of substring) used as index into m_first
   // and m_last
   hash := HashMe(pos, m_buf);

	// the first known occurrence should be the one we are about to remove
	if (m_by_first_2_bytes[hash].m_first <> pos) then
   begin
		// this substring was probably not added due to cMaxSubstringsInChain
		exit;
   end;
   dec(m_by_first_2_bytes[hash].m_num);

	// find the next one
   position := pos mod cNextIndexLength;

	if (m_next[position] = cInvalidPos) then
   begin
		// it was also the last one (there is no next in the chain)
		// remove it
		m_by_first_2_bytes[hash].m_first := cInvalidPos;
		m_by_first_2_bytes[hash].m_last := cInvalidPos;
	end
   else
   begin
		// it wasn't the last one (there is some more in the chain)
		m_by_first_2_bytes[hash].m_first := m_next[position];
		m_next[position] := cInvalidPos;
	end;
end;

function FindBestMatchingKnownSubstring(pos: uint32; var best_score: uint32; const m_buf: puint8; var m_buf_end_pos : uint32; var m_by_first_2_bytes: ByFirst2BytesIndexArray; const m_next : auint32; const m_next_same : auint16): uint32;
var
   hash : uint32;
   best_pos : uint32;
   same_bytes : uint32;
   score : uint32;
   other_pos : uint32;
   min_score : uint32;
begin
	// hash (made from first 2 chars of substring) used as index into m_first and m_last
	hash := HashMe(pos, m_buf);

	// enumerate whole chain of all known substrings that have same 2 bytes at their start
	// and try to find the best matching known substring
	best_score := 0;
	best_pos := cInvalidPos;
	same_bytes := 2;
	score := 2;

   other_pos := m_by_first_2_bytes[hash].m_first;
   while (other_pos <> cInvalidPos) do
   begin
		min_score := Min(same_bytes, score);
		score := MatchingScore(other_pos, pos, min_score, m_buf, m_buf_end_pos);
		if (score >= best_score) then
      begin
   		best_score := score;
			best_pos := other_pos;
		end;
      same_bytes := m_next_same[other_pos mod cNextIndexLength];
      other_pos := m_next[other_pos mod cNextIndexLength];
	end;
	Result := best_pos;
end;

procedure CopySourceAndFinish(const m_buf : puint8; var m_dst: puint8; src_copy_from : uint32; src_copy_num_bytes: uint32);
var
   num_bytes : uint32;
   tag : puint8;//array of byte;
begin
	while (src_copy_num_bytes > 3) do
   begin
		// more than 3 bytes need to be copied from source
		num_bytes := src_copy_num_bytes and (not 3); // long copy allows num_bytes with step 4
		if (num_bytes > $70) then
         num_bytes := $70; // max num_bytes for long copy is $70
      GetMem(tag,1);
      tag^ := $E0 or ((num_bytes shr 2) - 1);
      WriteBuffer(tag, m_dst,0, 1);
		WriteBuffer(m_buf, m_dst, src_copy_from, num_bytes);
		inc(src_copy_from, num_bytes);
		dec(src_copy_num_bytes, num_bytes);
      FreeMem(tag);
	end;
   GetMem(tag,1);
   tag^ := $FC or src_copy_num_bytes;
   WriteBuffer(tag, m_dst,0, 1);
	WriteBuffer(m_buf, m_dst, src_copy_from, src_copy_num_bytes);
//	inc(src_copy_from, src_copy_num_bytes);
//	src_copy_num_bytes := 0;
   FreeMem(tag);
end;

procedure CombinedCopy(const m_buf : puint8; var m_dst: puint8; src_copy_from: uint32; src_copy_num_bytes: uint32; dst_copy_from: uint32; dst_copy_num_bytes: uint32);
var
   num_bytes : uint32;
   tag, ptag : puint8;//array of byte;
   dst_copy_offset : uint32;
begin
	while (src_copy_num_bytes > 3) do
   begin
		// more than 3 bytes need to be copied from source
		num_bytes := src_copy_num_bytes and (not 3); // long copy allows num_bytes with step 4
		if (num_bytes > $70) then
         num_bytes := $70; // max num_bytes for long copy is $70
      GetMem(tag,1);
      tag^ := $E0 or ((num_bytes shr 2) - 1);
      WriteBuffer(tag,m_dst,0,1);
		WriteBuffer(m_buf, m_dst, src_copy_from, num_bytes);
      FreeMem(tag);
		inc(src_copy_from,num_bytes);
		dec(src_copy_num_bytes,num_bytes);
   end;

   dst_copy_offset := src_copy_from + src_copy_num_bytes - dst_copy_from;
	while (dst_copy_num_bytes > 0) or (src_copy_num_bytes > 0) do
   begin
		if (dst_copy_offset > $4000) or (dst_copy_num_bytes > $43) then
      begin
			// use large dst copy
         num_bytes := dst_copy_num_bytes;
			// max num_bytes for huge dst copy is $404
         if (num_bytes > $404) then
         begin
            num_bytes := $404;
            // not less than 5 bytes should remain
            if (dst_copy_num_bytes - num_bytes < 5) then
            begin
               num_bytes := dst_copy_num_bytes - 5;
            end;
         end;
         GetMem(tag,4);
         ptag := tag;
         ptag^ := $C0 or (((dst_copy_offset - 1) shr 12) and $10) or (((num_bytes - 5) shr 6) and $0C) or (src_copy_num_bytes and $03);
         inc(ptag);
         ptag^ := (dst_copy_offset - 1) shr 8;
         inc(ptag);
         ptag^ := (dst_copy_offset - 1);
         inc(ptag);
         ptag^ := num_bytes - 5;
         WriteBuffer(tag,m_dst,0,4);
         WriteBuffer(m_buf, m_dst, src_copy_from, src_copy_num_bytes);
         FreeMem(tag);
         inc(src_copy_from, src_copy_num_bytes);
         src_copy_num_bytes := 0;
         dec(dst_copy_num_bytes, num_bytes);
      end
      else if (dst_copy_offset > $400) or (dst_copy_num_bytes > $0A) then
      begin
         // medium dst copy
         num_bytes := dst_copy_num_bytes;
			// max num_bytes for huge dst copy is $404
         GetMem(tag,3);
         ptag := tag;
         ptag^ := $80 or (num_bytes - 4);
         inc(ptag);
         ptag^ := (src_copy_num_bytes shl 6) or (dst_copy_offset - 1) shr 8;
         inc(ptag);
         ptag^ := dst_copy_offset - 1;
         WriteBuffer(tag,m_dst,0,3);
         WriteBuffer(m_buf, m_dst, src_copy_from, src_copy_num_bytes);
         FreeMem(tag);
         inc(src_copy_from,src_copy_num_bytes);
         src_copy_num_bytes := 0;
         dec(dst_copy_num_bytes,num_bytes);
      end
      else
      begin
			// short dst copy
         num_bytes := dst_copy_num_bytes;
			// max num_bytes for huge dst copy is $404
         GetMem(tag,2);
         ptag := tag;
         ptag^ := $00 or (((dst_copy_offset - 1) shr 3) and $60) or (((num_bytes - 3) shl 2) and $1C) or (src_copy_num_bytes and $03);
         inc(ptag);
         ptag^ := dst_copy_offset - 1;
         WriteBuffer(tag,m_dst,0,2);
         WriteBuffer(m_buf, m_dst, src_copy_from, src_copy_num_bytes);
         FreeMem(tag);
         inc(src_copy_from, src_copy_num_bytes);
         src_copy_num_bytes := 0;
         dec(dst_copy_num_bytes, num_bytes);
      end;
   end;
end;

function CompressionOneStep(const m_buf : puint8; var m_buf_end_pos : uint32; var m_dst: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32; var m_next_same : auint16; var m_src_pos, m_src_end_pos : uint32): boolean;
var
   pos, src_copy_start, score, dst_copy_from_pos : uint32;
begin
   Result := false;
	pos := m_src_pos;
	src_copy_start := pos;
	score := 0;
	dst_copy_from_pos := cInvalidPos;
	while (not IsGoodScoreForDstOffset(score, pos - dst_copy_from_pos)) do
   begin
		dst_copy_from_pos := FindBestMatchingKnownSubstring(pos, score, m_buf, m_buf_end_pos, m_by_first_2_bytes, m_next, m_next_same);
		if (pos >= cNextIndexLength) then
      begin
			RemoveKnownSubstring(pos - cNextIndexLength, m_buf, m_by_first_2_bytes, m_next);
      end;
      AddKnownSubstring(pos, m_buf, m_buf_end_pos, m_by_first_2_bytes, m_next, m_next_same);
		inc(pos);
		if (pos >= (m_src_pos + $70)) then
      begin
			CombinedCopy(m_buf, m_dst, m_src_pos, pos - m_src_pos, m_src_pos, 0);
			m_src_pos := pos;
         if not limitreached then
            Result := True;
			exit;
      end;
      if (pos < m_src_end_pos) then
      begin
			continue;
      end;
		// eof found
		CopySourceAndFinish(m_buf, m_dst, src_copy_start, pos - src_copy_start);
		m_src_pos := pos;
      if not limitreached then
         Result := True;
		exit;
   end;
	// score was at least 3
	CombinedCopy(m_buf, m_dst, src_copy_start, pos - 1 - src_copy_start, dst_copy_from_pos, score);
   if limitreached then exit;
	while ( score > 1) do
   begin
		if (pos >= cNextIndexLength) then
      begin
			RemoveKnownSubstring(pos - cNextIndexLength, m_buf, m_by_first_2_bytes, m_next);
      end;
		AddKnownSubstring(pos, m_buf, m_buf_end_pos, m_by_first_2_bytes, m_next, m_next_same);
		inc(pos);
      dec(score);
   end;
	m_src_pos := pos;
   if not limitreached then
      Result := true;
end;

procedure FinalizeRefPackCompression(var m_buf: puint8; var m_by_first_2_bytes: ByFirst2BytesIndexArray; var m_next : auint32;  var m_next_same : auint16);
begin
   // Initialize arrays:
   setlength(m_by_first_2_bytes,0);
   setlength(m_next,0);
   setlength(m_next_same,0);
   FreeMem(m_buf);
end;

end.
