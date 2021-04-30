(*******************************************************************************
 * Author  Banshee
 *
 * Date    17/02/2008
 *
 * Copyright
 ******************************************************************************)
unit BasicConstants;

interface

const
   // Let's start with file type constants.
   C_BIG4 = $34474942;
   C_BIGF = $46474942;
   C_MEGF = $4647454D;    // just a random number, for identification purposes.

   // Options
   C_OPT_MAX_BINARY_SIZE = 5242880; // = 5 megabytes

   // Language
   LANG_NO_STRING = 'Unknown string';

   // Selections
   C_SEL_NONE = 0;
   C_SEL_COPY = 1;
   C_SEL_MOVE = 2;

   // Form Binary Warning constants
   C_FBW_USER = 0;
   C_FBW_DONT = 1;
   C_FBW_LLIMIT = 2;
   C_FBW_LALL = 3;

   // Real Time Edition Messages
   C_MSG_ADD = 0;
   C_MSG_DELETE = 1;
   C_MSG_MODIFY_CONTENT = 2;
   C_MSG_RENAME = 3;

   // Compresssion Optimization Constants
   C_NEVER_COMPRESSED = 0;
   C_NO_COMPRESSION = 1;
   C_REFPACK_COMPRESSION = 2;
   C_AES128_COMPRESSION = 3;

implementation

end.
