#include <stdio.h>
#include <stdlib.h>
#include "quark.h"
#include "sig_model.h"
#include <time.h>


void print_hex(int64_t val, int bytes){
    int i=0;

    i=bytes*8;
    while(i>0){
        printf("%01X", (val >> (i)) &0xF );
        i -= 4;
    }
}

void print_bin(int64_t val, int bits){
    int i=0, j=0;

    for(i=bits-1; i>=0;i--){
        printf("%d", (val >>i ) &0x01 );
    }

    /*
    i=(bytes/4);

    if((bytes % 4) != 0){
        byte= (val >> (i+4)) &0xF;
        for(j=(bytes % 4)-1;j>=0;j--){
            printf("%d", (byte >>j ) &0x01 );
        }
    }

    i=bytes %4;

    while(i>0){
        byte= (val >> (i)) &0xF;
        for(j=3;j>=0;j--){
            printf("%d", (byte >>j ) &0x01 );
        }
        i -= 4;
    }
    */
}


int main()
{

  #define LEN 400 // length of the data to hash
  #define MSG_LEN 4*6
  #define TEMP_LEN (int) (ceil((512*9.0)/8))
  #define PRIME 8383489
  #define DATA_LEN MSG_LEN+TEMP_LEN
  u8 data[DATA_LEN], out[DIGEST];
  int64_t in_poly[512];
  int32_t out_poly[512];
  int32_t temp[TEMP_LEN];

  u32 x[ WIDTH*8 ];
  int i;


  //Fill with zeros
  for(i=0;i<DATA_LEN; i++){
    data[i] = 0;
  }

   //Fill with zeros
  for(i=0;i<TEMP_LEN; i++){
    //temp[i] = 0;
  }



  //Fill in the message
  for(i=0;i<MSG_LEN; i++){
    data[i] = 0xFF;
  }

    printf("\n\n");
    for(i=0; i<MSG_LEN;i++){
        printf("%02X",data[i]);
    }
    printf("\n\n");

  //Get the polynomial: in range 0 .. 8383489
  srand(1);
  for(i=0;i<512;i++){
    in_poly[i] = 33333*(rand()) % PRIME;
    if (in_poly[i]>(PRIME-1)/2){
        in_poly[i] = in_poly[i] -PRIME;
    }
  }

   printf("in_poly\n");
   for(i=0; i<512;i++){
        //printf("x\"");
         printf("%lld ",in_poly[i]);

    }

    printf("\n\n\n");

    int64_t val;
   for(i=511; i>=0;i--){
        //printf("x\"");
        val = in_poly[i];
        if (val<0){
            val = val +PRIME;
        }
        print_bin(val,23);
        printf("#");
    }
    printf("\n");

  //Run transformation on polynomial
  transform_higher_order(in_poly, out_poly, 1<<14);

  printf("out_poly\n");
  for(i=0; i<512;i++){
        printf("%d ",out_poly[i]);
    }
    printf("\n");

  //Prepare date to be hashed
  int pack_ctr=0, block_ptr=0;
  int32_t overflow=0;
  int overflow_bits =0;
  int temp_val=0;


    //In the HW implementation we pack the result of the higer order transform in a speicfic way
    //    data[o] =  h3[5bits]h2[9bits]h1[9bits]h0[9bits]
    //    data[1] =   .....h5[9bits]h4[4bits]
    //The values are 9 bit signed integers
    printf("\n");
    while(block_ptr <512){
        if (overflow_bits > 0){
            temp[pack_ctr/8] = overflow & ((2<<overflow_bits)-1);
            pack_ctr +=  overflow_bits;

            if(overflow_bits==8){
                overflow_bits=0;
                continue;
            }
        }

        temp_val = out_poly[block_ptr];
        block_ptr++;

        temp[pack_ctr/8] |= (temp_val << overflow_bits)  & 0xFF;

        pack_ctr += 8-overflow_bits;
        overflow_bits = 9-(8-overflow_bits);

        overflow = ((temp_val >> (9-overflow_bits)) & ((1<<(overflow_bits))-1)) ;
    }

    if (overflow_bits > 0){
            temp[pack_ctr/8] = overflow & ((2<<overflow_bits)-1);
            pack_ctr +=  overflow_bits;
    }




    printf("\n");

    printf("\n\n");
    for(i=0; i<TEMP_LEN;i++){
        printf("%02X",temp[i]);
    }
    printf("\n\n");


    //Now put the data in little endian format into the data buffer
    int offset= MSG_LEN;
    int ptr =0;

    for(i=0;i<TEMP_LEN;i++){
        ptr = ((i+offset)/4)*4 +(3-((i+offset)%4));
        temp_val = temp[i] &0xFF;
        data[ptr] = temp_val;
    }

    for(i=0; i<DATA_LEN;i++){
        printf("%02X",data[i]);
    }
    printf("\n\n");


    //#### Message 1 #####
    //Fill in the message
    for(i=0;i<MSG_LEN; i++){
        data[i] = 0xFF;
    }

    printf("\n\n");
    for(i=0; i<MSG_LEN;i++){
        printf("%02X",data[i]);
    }
    printf("\n\n");

    crypto_hash( out, data, DATA_LEN);

    printf("Message 1 (160 bit)");
    for(i=0; i<5*4;i++){
        printf("%02X",out[i]);
    }

    //#### Message 2 #####
    //Fill in the message
    for(i=0;i<MSG_LEN; i++){
        data[i] = 0xFF;
    }
    data[0]=0;
    printf("\n\n");

    for(i=0; i<MSG_LEN;i++){
        printf("%02X",data[i]);
    }
    printf("\n\n");

    crypto_hash( out, data, DATA_LEN);

    printf("Message 2 (160 bit)");
    for(i=0; i<5*4;i++){
        printf("%02X",out[i]);
    }



    return 0;
}
