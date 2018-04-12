#include <assert.h>
#include "sig_model.h"


void transform_higher_order(int64_t *in_poly,int32_t *out_poly, int32_t k){
    int64_t i;
    int64_t y0,y1;

    for(i=0;i<512;i++)
    {

        y0 = in_poly[i] % (2*(k -32) +1 );

        if (y0 < -(k-32)){
            y0 = y0 + (2*(k -32) +1 );
        }

        if (y0 > (k-32)){
            y0 = y0 - (2*(k -32) +1 );
        }

        y1 = (in_poly[i] - y0) / (2*(k -32) +1 );

        //printf("in %lld, y0 %lld, y1 %lld \n",in_poly[i], y0, y1);

        assert ((y1*(2*(k -32) +1 ) + y0) == in_poly[i]);
        assert (y0 <= (k-32));
        assert (y0 >= -(k-32));

        out_poly[i]= (int32_t) y1;

        }

    }

