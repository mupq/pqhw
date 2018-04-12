
/* uncomment to printf execution traces */
//#define DEBUG

/*

parameters of each flavor of quark:

       u-quark d-quark s-quark
RATE       1      2     4
WIDTH     17     22    32
DIGEST    17     22    32
*/


/* block size (bytes), at least one byte (to encode the lengths) */
#define RATE    4
/* state size (bytes): either 136/8=17, 176/8=22, or 256/8=32  */
#define WIDTH  32
/* digest size (bytes)  */
#define DIGEST 32
#ifndef MYTYPES
#define MYTYPES
typedef unsigned long long u64;
typedef unsigned int u32;
typedef unsigned char u8;
typedef struct {
  int pos; /* number of bytes read into x from current block */
  u32 x[ WIDTH*8 ]; /* one bit stored in each word */
} hashState;
#endif


int crypto_hash(unsigned char *out, const unsigned char *in, unsigned long long inlen);
