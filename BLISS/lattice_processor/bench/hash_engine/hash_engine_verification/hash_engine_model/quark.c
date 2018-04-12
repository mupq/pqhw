#include <stdio.h>
#include "quark.h"




/* 17 bytes */
u8 iv_s[] = {0xD8,0xDA,0xCA,0x44,0x41,0x4A,0x09,0x97,
	     0x19,0xC8,0x0A,0xA3,0xAF,0x06,0x56,0x44,0xDB};

/* 22 bytes */
u8 iv_m[] = {0xCC,0x6C,0x4A,0xB7,0xD1,0x1F,0xA9,0xBD,
	     0xF6,0xEE,0xDE,0x03,0xD8,0x7B,0x68,0xF9,
	     0x1B,0xAA,0x70,0x6C,0x20,0xE9};

/* 32 bytes */
u8 iv_l[] = {0x39,0x72,0x51,0xCE,0xE1,0xDE,0x8A,0xA7,
	     0x3E,0xA2,0x62,0x50,0xC6,0xD7,0xBE,0x12,
	     0x8C,0xD3,0xE7,0x9D,0xD7,0x18,0xC2,0x4B,
	     0x8A,0x19,0xD0,0x9C,0x24,0x92,0xDA,0x5D};


void showstate( u32 * x ) {

  int i;
  u8 buf=0;
  for(i=0;i<8*WIDTH;++i) {
    buf ^= (1&x[i])<<(7-(i%8));
    if (((i%8)==7) && (i)) {
      printf("%02X",buf);
      buf=0;
    }
  }
  printf("\n");

}


int permute_s( u32 * x ) {
  /* state of 136=2x68 bits */
#define ROUNDS_S 4*136
#define N_LEN_S 68
#define L_LEN_S 10

  u32 X[N_LEN_S+ROUNDS_S];
  u32 Y[N_LEN_S+ROUNDS_S];
  u32 L[L_LEN_S+ROUNDS_S];
  u32 h;
  int i;

#ifdef DEBUG
    printf("enter permute_s\n");
#endif

  /* local copy of the state in the registers*/
  for(i=0; i< N_LEN_S; ++i) {
    X[i]=x[i];
    Y[i]=x[i+N_LEN_S];
  }

  /* initialize the LFSR to 11..11 */
  for(i=0; i< L_LEN_S; ++i)
    L[i]=0xFFFFFFFF;

  /* iterate rounds */
  for(i=0; i< ROUNDS_S; ++i) {

    /* indices up to i+59, for 8x parallelizibility*/

    /* need X[i] as linear term only, for invertibility */
    X[N_LEN_S+i]  = X[i] ^ Y[i];
    X[N_LEN_S+i] ^= X[i+9] ^ X[i+14] ^ X[i+21] ^ X[i+28] ^
      X[i+33] ^ X[i+37] ^ X[i+45] ^ X[i+52] ^ X[i+55] ^ X[i+50] ^
      ( X[i+59] & X[i+55] ) ^ ( X[i+37] & X[i+33] ) ^ ( X[i+15] & X[i+9] ) ^
      ( X[i+55] & X[i+52] & X[i+45] ) ^ (X[i+33] & X[i+28] & X[i+21] ) ^
      ( X[i+59] & X[i+45] & X[i+28] & X[i+9] ) ^
      ( X[i+55] & X[i+52] & X[i+37] & X[i+33] ) ^
      ( X[i+59] & X[i+55] & X[i+21] & X[i+15] ) ^
      ( X[i+59] & X[i+55] & X[i+52] & X[i+45] & X[i+37] ) ^
      ( X[i+33] & X[i+28] & X[i+21] & X[i+15] & X[i+9] ) ^
      ( X[i+52] & X[i+45] & X[i+37] & X[i+33] & X[i+28] & X[i+21] );

    /* need Y[i] as linear term only, for invertibility */
    Y[N_LEN_S+i]  = Y[i];
    Y[N_LEN_S+i] ^= Y[i+7] ^ Y[i+16] ^ Y[i+20] ^ Y[i+30] ^
      Y[i+35]  ^ Y[i+37] ^ Y[i+42] ^ Y[i+51] ^ Y[i+54] ^  Y[i+49] ^
      ( Y[i+58] & Y[i+54] ) ^ ( Y[i+37] & Y[i+35] ) ^ ( Y[i+15] & Y[i+7] ) ^
      ( Y[i+54] & Y[i+51] & Y[i+42] ) ^ (Y[i+35] & Y[i+30] & Y[i+20] ) ^
      ( Y[i+58] & Y[i+42] & Y[i+30] & Y[i+7] ) ^
      ( Y[i+54] & Y[i+51] & Y[i+37] & Y[i+35] ) ^
      ( Y[i+58] & Y[i+54] & Y[i+20] & Y[i+15] ) ^
      ( Y[i+58] & Y[i+54] & Y[i+51] & Y[i+42] & Y[i+37] ) ^
      ( Y[i+35] & Y[i+30] & Y[i+20] & Y[i+15] & Y[i+7] ) ^
      ( Y[i+51] & Y[i+42] & Y[i+37] & Y[i+35] & Y[i+30] & Y[i+20] );

    /* need L[i] as linear term only, for invertibility */
    /* sparse polynomial ok; use x^10 + x^7 + 1*/
    L[L_LEN_S+i]  = L[i];
    L[L_LEN_S+i] ^= L[i+3]; // linear feedback here

    /* compute output of the h function */
    h = X[i+25] ^ Y[i+59] ^ ( Y[i+3] & X[i+55] ) ^ (X[i+46] & X[i+55]) ^ (X[i+55] & Y[i+59]) ^
      (Y[i+3] & X[i+25] & X[i+46] ) ^ (Y[i+3] & X[i+46] & X[i+55] ) ^ (Y[i+3] & X[i+46] & Y[i+59] ) ^
      (X[i+25] & X[i+46] & Y[i+59] & L[i]) ^ (X[i+25] & L[i] );
    h ^= X[i + 1] ^ Y[i + 2] ^ X[i + 4] ^ Y[i + 10] ^ X[i + 31] ^ Y[i + 43] ^ X[i + 56] ^ L[i];

    /* feedback of h into the registers */
    X[N_LEN_S+i] ^= h;
    Y[N_LEN_S+i] ^= h;
  }

  /* copy final state into hashState */
  for(i=0; i< N_LEN_S; ++i) {
    x[i] = X[ROUNDS_S+i];
    x[i+N_LEN_S] = Y[ROUNDS_S+i];
  }

  return 0;
}


int permute_m( u32 * x ) {
  /* state of 176=2x88 bits */
#define ROUNDS_M 4*176
#define N_LEN_M 88
#define L_LEN_M 10

  u32 X[N_LEN_M+ROUNDS_M];
  u32 Y[N_LEN_M+ROUNDS_M];
  u32 L[L_LEN_M+ROUNDS_M];
  u32 h;
  int i;

#ifdef DEBUG
    printf("enter permute_m\n");
#endif

  /* local copy of the state in the registers*/
  for(i=0; i< N_LEN_M; ++i) {
    X[i]=x[i];
    Y[i]=x[i+N_LEN_M];
  }

  /* initialize the LFSR to 11..11 */
  for(i=0; i< L_LEN_M; ++i)
    L[i]=0xFFFFFFFF;

  /* iterate rounds */
  for(i=0; i< ROUNDS_M; ++i) {

    /* need X[i] as linear term only, for invertibility */
    X[N_LEN_M+i]  = X[i] ^ Y[i];
    X[N_LEN_M+i] ^= X[i+11] ^ X[i+18] ^ X[i+27] ^ X[i+36] ^
      X[i+42] ^ X[i+47] ^ X[i+58] ^ X[i+67] ^ X[i+71] ^ X[i+64] ^
      ( X[i+79] & X[i+71] ) ^ ( X[i+47] & X[i+42] ) ^ ( X[i+19] & X[i+11] ) ^
      ( X[i+71] & X[i+67] & X[i+58] ) ^ (X[i+42] & X[i+36] & X[i+27] ) ^
      ( X[i+79] & X[i+58] & X[i+36] & X[i+11] ) ^
      ( X[i+71] & X[i+67] & X[i+47] & X[i+42] ) ^
      ( X[i+79] & X[i+71] & X[i+27] & X[i+19] ) ^
      ( X[i+79] & X[i+71] & X[i+67] & X[i+58] & X[i+47] ) ^
      ( X[i+42] & X[i+36] & X[i+27] & X[i+19] & X[i+11] ) ^
      ( X[i+67] & X[i+58] & X[i+47] & X[i+42] & X[i+36] & X[i+27] );


    /* need Y[i] as linear term only, for invertibility */
    Y[N_LEN_M+i]  = Y[i];
    Y[N_LEN_M+i] ^= Y[i+9] ^ Y[i+20] ^ Y[i+25] ^ Y[i+38] ^
      Y[i+44]  ^ Y[i+47] ^ Y[i+54] ^ Y[i+67] ^ Y[i+69] ^  Y[i+63] ^
      ( Y[i+78] & Y[i+69] ) ^ ( Y[i+47] & Y[i+44] ) ^ ( Y[i+19] & Y[i+9] ) ^
      ( Y[i+69] & Y[i+67] & Y[i+54] ) ^ (Y[i+44] & Y[i+38] & Y[i+25] ) ^
      ( Y[i+78] & Y[i+54] & Y[i+38] & Y[i+9] ) ^
      ( Y[i+69] & Y[i+67] & Y[i+47] & Y[i+44] ) ^
      ( Y[i+78] & Y[i+69] & Y[i+25] & Y[i+19] ) ^
      ( Y[i+78] & Y[i+69] & Y[i+67] & Y[i+54] & Y[i+47] ) ^
      ( Y[i+44] & Y[i+38] & Y[i+25] & Y[i+19] & Y[i+9] ) ^
      ( Y[i+67] & Y[i+54] & Y[i+47] & Y[i+44] & Y[i+38] & Y[i+25] );

    /* need L[i] as linear term only, for invertibility */
    L[L_LEN_M+i]  = L[i];
    L[L_LEN_M+i] ^= L[i+3]; // linear feedback here

    /* compute output of the h function */
    h = X[i+35] ^ Y[i+79] ^ ( Y[i+4] & X[i+68] ) ^ (X[i+57] & X[i+68]) ^ (X[i+68] & Y[i+79]) ^
      (Y[i+4] & X[i+35] & X[i+57] ) ^ (Y[i+4] & X[i+57] & X[i+68] ) ^ (Y[i+4] & X[i+57] & Y[i+79] ) ^
      (X[i+35] & X[i+57] & Y[i+79] & L[i]) ^ (X[i+35] & L[i] );
    h ^= X[i + 1] ^ Y[i + 2] ^ X[i + 5] ^ Y[i + 12] ^ X[i + 40] ^ Y[i + 55] ^ X[i + 72] ^ L[i];
    h ^= Y[i+24] ^ X[i+48] ^ Y[i+61];

    /* feedback of h into the registers */
    X[N_LEN_M+i] ^= h;
    Y[N_LEN_M+i] ^= h;
  }

  /* copy final state into hashState */
  for(i=0; i< N_LEN_M; ++i) {
    x[i] = X[ROUNDS_M+i];
    x[i+N_LEN_M] = Y[ROUNDS_M+i];
  }


  return 0;
}


int permute_l( u32 * x ) {
  /* state of 256=2x128 bits */
#define ROUNDS_L 4*256
#define N_LEN_L 128
#define L_LEN_L  10

  u32 X[N_LEN_L+ROUNDS_L];
  u32 Y[N_LEN_L+ROUNDS_L];
  u32 L[L_LEN_L+ROUNDS_L];
  u32 h;
  int i;

#ifdef DEBUG
    printf("enter permute_l\n");
#endif

  /* local copy of the state in the registers*/
  for(i=0; i< N_LEN_L; ++i) {
    X[i]=x[i];
    Y[i]=x[i+N_LEN_L];
  }

  /* initialize the LFSR to 11..11 */
  for(i=0; i< L_LEN_L; ++i)
    L[i]=0xFFFFFFFF;

  /* iterate rounds */
  for(i=0; i< ROUNDS_L; ++i) {

    /* need X[i] as linear term only, for invertibility */
    X[N_LEN_L+i]  = X[i] ^ Y[i];
    X[N_LEN_L+i] ^= X[i+16] ^ X[i+26] ^ X[i+39] ^ X[i+52] ^
      X[i+61] ^ X[i+69] ^ X[i+84] ^ X[i+97] ^ X[i+103] ^ X[i+94] ^
      ( X[i+111] & X[i+103] ) ^ ( X[i+69] & X[i+61] ) ^ ( X[i+28] & X[i+16] ) ^
      ( X[i+103] & X[i+97] & X[i+84] ) ^ (X[i+61] & X[i+52] & X[i+39] ) ^
      ( X[i+111] & X[i+84] & X[i+52] & X[i+16] ) ^
      ( X[i+103] & X[i+97] & X[i+69] & X[i+61] ) ^
      ( X[i+111] & X[i+103] & X[i+39] & X[i+28] ) ^
      ( X[i+111] & X[i+103] & X[i+97] & X[i+84] & X[i+69] ) ^
      ( X[i+61] & X[i+52] & X[i+39] & X[i+28] & X[i+16] ) ^
      ( X[i+97] & X[i+84] & X[i+69] & X[i+61] & X[i+52] & X[i+39] );

    /* need Y[i] as linear term only, for invertibility */
    Y[N_LEN_L+i]  = Y[i];
    Y[N_LEN_L+i] ^= Y[i+13] ^ Y[i+30] ^ Y[i+37] ^ Y[i+56] ^
      Y[i+65]  ^ Y[i+69] ^ Y[i+79] ^ Y[i+96] ^ Y[i+101] ^  Y[i+92] ^
      ( Y[i+109] & Y[i+101] ) ^ ( Y[i+69] & Y[i+65] ) ^ ( Y[i+28] & Y[i+13] ) ^
      ( Y[i+101] & Y[i+96] & Y[i+79] ) ^ (Y[i+65] & Y[i+56] & Y[i+37] ) ^
      ( Y[i+109] & Y[i+79] & Y[i+56] & Y[i+13] ) ^
      ( Y[i+101] & Y[i+96] & Y[i+69] & Y[i+65] ) ^
      ( Y[i+109] & Y[i+101] & Y[i+37] & Y[i+28] ) ^
      ( Y[i+109] & Y[i+101] & Y[i+96] & Y[i+79] & Y[i+69] ) ^
      ( Y[i+65] & Y[i+56] & Y[i+37] & Y[i+28] & Y[i+13] ) ^
      ( Y[i+96] & Y[i+79] & Y[i+69] & Y[i+65] & Y[i+56] & Y[i+37] );

    /* need L[i] as linear term only, for invertibility */
    L[L_LEN_L+i]  = L[i];
    L[L_LEN_L+i] ^= L[i+3]; // linear feedback here

    /* compute output of the h function */
    h = X[i+47] ^ Y[i+111] ^ ( Y[i+8] & X[i+100] ) ^ (X[i+72] & X[i+100]) ^ (X[i+100] & Y[i+111]) ^
      (Y[i+8] & X[i+47] & X[i+72] ) ^ (Y[i+8] & X[i+72] & X[i+100] ) ^ (Y[i+8] & X[i+72] & Y[i+111] ) ^
      (X[i+47] & X[i+72] & Y[i+111] & L[i]) ^ (X[i+47] & L[i] );
    h ^= X[i + 1] ^ Y[i + 3] ^ X[i + 7] ^ Y[i + 18] ^ X[i + 58] ^ Y[i + 80] ^ X[i + 105] ^ L[i];
    h ^= Y[i+34] ^ Y[i+71] ^ X[i+90] ^ Y[i+91];

    /* feedback of h into the registers */
    X[N_LEN_L+i] ^= h;
    Y[N_LEN_L+i] ^= h;
  }

  /* copy final state into hashState */
  for(i=0; i< N_LEN_L; ++i) {
    x[i] = X[ROUNDS_L+i];
    x[i+N_LEN_L] = Y[ROUNDS_L+i];
  }

  return 0;
}



/* permutation of the state */
static void permute(u32 * x) {


#ifdef DEBUG
    printf("enter permute\n");
    showstate( x );
#endif

  switch( WIDTH ) {
  case 17 : permute_s( x );break;
  case 22 : permute_m( x );break;
  case 32 : permute_l( x );break;
  default: printf("invalid WIDTH (%d), state unchanged\n",WIDTH);
    }



#ifdef DEBUG
    printf("permute done\n");
    showstate( x );
#endif

}


/* initialization of the IV */
int init(hashState *state)
{
  int i;
  u8 u;

#ifdef DEBUG
  printf("enter init\n");
#endif

  /* initialize state */
  switch( WIDTH ) {
  case 17 :
    for (i = 0;i < 136;++i) state->x[i] = (iv_s[i/8]>>(7-(i%8)))&1;
    break;
  case 22 :
    for (i = 0;i < 176;++i) state->x[i] = (iv_m[i/8]>>(7-(i%8)))&1;
    break;
  case 32 :
    for (i = 0;i < 256;++i) state->x[i] = (iv_l[i/8]>>(7-(i%8)))&1;
    break;
  default: printf("invalid WIDTH (%d), state unchanged\n",WIDTH);
    }


  state->pos = 0;

#ifdef DEBUG
  printf("init done\n");
  showstate( state->x );
#endif

  return 0;
}


int update(hashState *state, const u8 *data, int databytelen)
{
  /* caller promises us that previous data had integral number of bytes */
  /* so state->pos is a multiple of 8 */

  int i;

#ifdef DEBUG
  printf("enter update\n");
#endif

  while (databytelen > 0) {

    /* get next byte */
    u8 u = *data;

#ifdef DEBUG
    printf("get byte %02X at pos %d\n", u, state->pos);
#endif

    /* xor state with each bit */
    for(i=8*state->pos;i<8*state->pos+8;++i) {
      state->x[(8*(WIDTH-RATE))+i] ^= (u>>(i%8))&1;
    }

    data += 1;
    databytelen -= 1;
    state->pos += 1;

    if (state->pos == RATE) {
      permute(state->x);
      state->pos = 0;
    }
  }

#ifdef DEBUG
    printf("update done\n");
#endif

  return 0;
}


/* finalize (padding) and return digest */
int final(hashState *state, u8 *hashval)
{
  int i;
  int hashvalbytes=0;
  u8 u;

#ifdef DEBUG
    printf("enter final\n");
#endif

  /* append '1' bit */
    state->x[8*(WIDTH-RATE)+state->pos*8] ^= 1;

  /* permute to obtain first final state*/
  permute(state->x);

  /* zeroize output buffer */
  for(i=0;i<DIGEST;++i)
    hashval[i]=0;

  /* while output requested, extract RATE bytes and permute */
  while (hashvalbytes < DIGEST ) {


    /* extract one byte */
    for(i=0;i<8;++i) {
      u = state->x[8*(WIDTH-RATE)+i+8*(hashvalbytes%RATE)] &1;
      hashval[hashvalbytes] ^= (u << (7-i));
    }
#ifdef DEBUG
    printf("extracted byte %02X (%d)\n",hashval[hashvalbytes],hashvalbytes);
#endif

    hashvalbytes += 1;

    if (hashvalbytes == DIGEST )
      break;

    /* if RATE bytes extracted, permute again */
    if ( ! ( hashvalbytes % RATE ) ) {
      permute(state->x);
    }
  }
#ifdef DEBUG
      printf("final done\n");
#endif


  return 0;
}


int crypto_hash(unsigned char *out, const unsigned char *in, unsigned long long inlen) {
  /* inlen in bytes */

  hashState state;
  init(&state);
  update(&state, in, inlen);
  final(&state, out);

  return 0;
}


//
//int main() {
//
//#define LEN 400 // length of the data to hash
//  u8 data[LEN], out[DIGEST];
//  u32 x[ WIDTH*8 ];
//  int i;
//
//  u8 digest_empty_s[] = {0x12,0x6B,0x75,0xBC,0xAB,0x23,0x14,0x47,
//			 0x50,0xD0,0x8B,0xA3,0x13,0xBB,0xD8,0x00,
//			 0xA4};
//  u8 digest_empty_m[] = {0x82,0xC7,0xF3,0x80,0xE2,0x31,0x57,0x8E,
//			 0x2F,0xF4,0xC2,0xA4,0x02,0xE1,0x8B,0xF3,
//			 0x7A,0xEA,0x84,0x77,0x29,0x8D};
//  u8 digest_empty_l[] = {0x03,0x25,0x62,0x14,0xB9,0x2E,0x81,0x1C,
//			 0x32,0x1A,0xE8,0x6B,0xAB,0x4B,0x0E,0x7A,
//			 0xE9,0xC2,0x2C,0x42,0x88,0x2F,0xCC,0xDE,
//			 0x8C,0x22,0xBF,0xF6,0xA0,0xA1,0xD6,0xF1};
//
//    int j;
//
//    for(i=0;i<400;i=i++){
//        data[i] = i & 0xFF;
//    }
//
//
//    for(i=0;i<DIGEST;++i)
//        printf("%02X",data[i]);
//    printf("\n");
//
//
//
//    crypto_hash( out, data, 8);
//
//  for(i=0;i<DIGEST;++i)
//    printf("%02X",out[i]);
//  printf("\n");
//
//  return 0;
//
//
//
//
//    for(j=0;j<100;j=j+4){
//        printf("x\"");
//        for(i=0;i<j;++i){
//            printf("%02X",data[i]);
//        }
//        printf("\",");
//
//        printf("\n");
//    }
//
//
//
//
//    for(j=0;j<100;j=j+4){
//        crypto_hash( out, data, j);
//
//        printf("x\"");
//        for(i=0;i<DIGEST;++i) {
//            printf("%02X",out[i]);
//        }
//        printf("\",");
//        printf("\n");
//
//
//    }
//
//  crypto_hash( out, data, 8);
//
//  for(i=0;i<DIGEST;++i)
//    printf("%02X",out[i]);
//  printf("\n");
//
//
//
//
//    return 0;
//
//  /* digests of empty messages (ie, process blocs 0x80, 0x8000, 0x80000000 */
//  switch( WIDTH ) {
//  case 17 :
//    for(i=0;i<DIGEST;++i)
//      if (out[i]!=digest_empty_s[i]) { printf("digest error\n");return 0; }
//    printf("digest ok\n");
//    break;
//  case 22 :
//    for(i=0;i<DIGEST;++i)
//      if (out[i]!=digest_empty_m[i]) { printf("digest error\n");return 0; }
//    printf("digest ok\n");
//    break;
//  case 32 :
//    for(i=0;i<DIGEST;++i)
//      if (out[i]!=digest_empty_l[i]) { printf("digest error\n");return 0; }
//    printf("digest ok\n");
//    break;
//  default: printf("invalid WIDTH (%d), state unchanged\n",WIDTH);
//  }
//
//  return 0;
//}
