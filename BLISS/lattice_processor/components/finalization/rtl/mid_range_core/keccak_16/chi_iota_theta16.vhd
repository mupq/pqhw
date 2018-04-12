-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Michaël Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Implementation by the designers,
-- hereby denoted as "the implementer".

-- To the extent possible under law, the implementer has waived all copyright
-- and related or neighboring rights to the source code in this file.
-- http://creativecommons.org/publicdomain/zero/1.0/


library work;
	use work.keccak_globals16.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity chi_iota_theta16 is

port (

    chi_inp     : in  sub_state;
    theta_inp     : in  sub_state;
    k_slice_theta_p_in: in k_slice;
    theta_parity_inp     : in  k_row;
    first_round : in std_logic;
    first_block : in std_logic;
    round_constant_signal    : in sub_lane;
    theta_parity_bit_iota_inp : in std_logic;
    theta_parity_outp     : out  k_row;
    iota_outp     : out  sub_state;
    theta_outp     : out  sub_state);

end chi_iota_theta16;

architecture rtl of chi_iota_theta16 is


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

 
  signal theta_in,theta_out,chi_in,chi_out,iota_in,iota_out : sub_state;
  signal theta_parity,theta_parity_after_chi,theta_parity_first_round: k_row;
  signal sum_sheet: sub_plane;
  signal chi_out_for_theta_p: k_slice;
 
  
begin  -- Rtl


--connecitons

--order theta, pi, rho, chi, iota
theta_in<=theta_inp when (first_round='1')
		else iota_out;



chi_in<=chi_inp;
iota_in<=chi_out;
iota_outp<=iota_out;

theta_outp<=theta_out;

--chi
i0000: for y in 0 to 4 generate
	i0001: for x in 0 to 2 generate
		i0002: for i in 0 to (bit_per_sub_lane-1) generate
			chi_out(y)(x)(i)<=chi_in(y)(x)(i) xor  ( not(chi_in (y)(x+1)(i))and chi_in (y)(x+2)(i));
		
		end generate;	
	end generate;
end generate;

	i0011: for y in 0 to 4 generate
		i0021: for i in 0 to (bit_per_sub_lane-1) generate
			chi_out(y)(3)(i)<=chi_in(y)(3)(i) xor  ( not(chi_in (y)(4)(i))and chi_in (y)(0)(i));
		
		end generate;	
	end generate;
	
	i0012: for y in 0 to 4 generate
		i0022: for i in 0 to (bit_per_sub_lane-1) generate
			chi_out(y)(4)(i)<=chi_in(y)(4)(i) xor  ( not(chi_in (y)(0)(i))and chi_in (y)(1)(i));
		
		end generate;	
	end generate;
-- compute chi on the slice for theta parity

i0020: for y in 0 to 4 generate
	i0021: for x in 0 to 2 generate
		
		chi_out_for_theta_p(y)(x)<=k_slice_theta_p_in(y)(x) xor  ( not(k_slice_theta_p_in (y)(x+1))and k_slice_theta_p_in (y)(x+2));
		
		
	end generate;
end generate;

	i0023: for y in 0 to 4 generate
		chi_out_for_theta_p(y)(3)<=k_slice_theta_p_in(y)(3) xor  ( not(k_slice_theta_p_in (y)(4))and k_slice_theta_p_in (y)(0));
	end generate;
	
	i0024: for y in 0 to 4 generate		
		chi_out_for_theta_p(y)(4)<=k_slice_theta_p_in(y)(4) xor  ( not(k_slice_theta_p_in (y)(0))and k_slice_theta_p_in (y)(1));		
	end generate;
	
	theta_parity_after_chi(0) <= chi_out_for_theta_p(0)(0) xor chi_out_for_theta_p(1)(0) xor chi_out_for_theta_p(2)(0) xor
		chi_out_for_theta_p(3)(0) xor chi_out_for_theta_p(4)(0) xor theta_parity_bit_iota_inp;
	i0025: for x in 1 to 4 generate
		theta_parity_after_chi(x) <= chi_out_for_theta_p(0)(x) xor chi_out_for_theta_p(1)(x) xor chi_out_for_theta_p(2)(x) xor
		chi_out_for_theta_p(3)(x) xor chi_out_for_theta_p(4)(x);
	end generate;
	
--theta

--compute sum of columns

i0101: for x in 0 to 4 generate
	i0102: for i in 0 to (bit_per_sub_lane-1) generate
		sum_sheet(x)(i)<=theta_in(0)(x)(i) xor theta_in(1)(x)(i) xor theta_in(2)(x)(i) xor theta_in(3)(x)(i) xor theta_in(4)(x)(i);
	
	end generate;	
end generate;

-- sum of colums fo rthe first round
	i0103: for x in 0 to 4 generate
		theta_parity_first_round(x) <= k_slice_theta_p_in(0)(x) xor k_slice_theta_p_in(1)(x) xor k_slice_theta_p_in(2)(x) xor
		k_slice_theta_p_in(3)(x) xor k_slice_theta_p_in(4)(x);
	end generate;
	
-- send in outptu the sum of columns for the next block	
	i0104: for x in 0 to 4 generate
		theta_parity_outp(x)<=sum_sheet(x)(bit_per_sub_lane-1);
	
	end generate;	

i0200: for y in 0 to 4 generate
	i0201: for x in 1 to 3 generate
		theta_out(y)(x)(0)<=theta_in(y)(x)(0) xor sum_sheet(x-1)(0) xor theta_parity(x+1);
		i0202: for i in 1 to (bit_per_sub_lane-1) generate
			theta_out(y)(x)(i)<=theta_in(y)(x)(i) xor sum_sheet(x-1)(i) xor sum_sheet(x+1)(i-1);
		end generate;	
	end generate;
end generate;

i2001: for y in 0 to 4 generate
	theta_out(y)(0)(0)<=theta_in(y)(0)(0) xor sum_sheet(4)(0) xor theta_parity(1);
	i2021: for i in 1 to (bit_per_sub_lane-1) generate
		theta_out(y)(0)(i)<=theta_in(y)(0)(i) xor sum_sheet(4)(i) xor sum_sheet(1)(i-1);
	end generate;	

end generate;

i2002: for y in 0 to 4 generate
	theta_out(y)(4)(0)<=theta_in(y)(4)(0) xor sum_sheet(3)(0) xor theta_parity(0);
	i2022: for i in 1 to (bit_per_sub_lane-1) generate
		theta_out(y)(4)(i)<=theta_in(y)(4)(i) xor sum_sheet(3)(i) xor sum_sheet(0)(i-1);
	end generate;	

end generate;

-- select which theta parity to choose
theta_parity <= theta_parity_first_round when(first_round ='1' and first_block ='1')
		else  theta_parity_after_chi when(first_block='1')
		else  theta_parity_inp;
--iota
i5001: for y in 1 to 4 generate
	i5002: for x in 0 to 4 generate
		i5003: for i in 0 to (bit_per_sub_lane-1) generate
			iota_out(y)(x)(i)<=iota_in(y)(x)(i);
		end generate;	
	end generate;
end generate;


	i5012: for x in 1 to 4 generate
		i5013: for i in 0 to (bit_per_sub_lane-1) generate
			iota_out(0)(x)(i)<=iota_in(0)(x)(i);
		end generate;	
	end generate;



		i5103: for i in 0 to (bit_per_sub_lane-1) generate
			iota_out(0)(0)(i)<=iota_in(0)(0)(i) xor round_constant_signal(i);
		end generate;	



end rtl;
