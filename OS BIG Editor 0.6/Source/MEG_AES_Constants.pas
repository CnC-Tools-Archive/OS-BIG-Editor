unit MEG_AES_Constants;

interface

uses ElAES;

const
   C_AES_KEY_GREYGOO: TAESKey128 = ($63, $22, $34, $01, $b2, $7e, $fb, $50, $2e, $c6, $57, $b1, $34, $a9, $25, $61);
   C_IV_GREYGOO: TAESBuffer = ($95, $4f, $d9, $96, $43, $8b, $8f, $d0, $35, $a5, $c7, $ff, $b6, $f6, $06, $6b);

   C_AES_KEY_8BIT: TAESKey128 = ($1c, $b3, $fa, $fe, $67, $69, $20, $dc, $6b, $12, $e1, $5b, $23, $2d, $ad, $6d);
   C_IV_8BIT: TAESBuffer = ($6c, $f6, $b9, $ab, $e7, $87, $82, $12, $f5, $df, $ae, $e6, $cf, $8a, $1e, $18);

implementation

end.
