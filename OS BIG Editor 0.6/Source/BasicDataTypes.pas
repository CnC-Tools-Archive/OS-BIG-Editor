(*******************************************************************************
 * Author  Banshee
 *
 * Date    Since the creation of the universe.
 *
 * Copyright
 ******************************************************************************)
unit BasicDataTypes;

interface

type
   int8    = shortint;
   pint8   = ^shortint;
   uint8   = byte;
   puint8  = ^byte;
   int16   = smallint;
   pint16  = ^smallint;
   uint16  = word;
   puint16 = ^word;
   int32   = longint;
   pint32  = ^longint;
   uint32  = longword;
   puint32 = ^longword;

   // Arrays
   aint8    = array of shortint;
   apint8   = array of ^shortint;
   auint8   = array of byte;
   apuint8  = array of ^byte;
   aint16   = array of smallint;
   apint16  = array of ^smallint;
   auint16  = array of word;
   apuint16 = array of ^word;
   aint32   = array of longint;
   apint32  = array of ^longint;
   auint32  = array of longword;
   apuint32 = array of ^longword;

   // Others
   acrc32 = array [0..255] of uint32;

implementation

end.



