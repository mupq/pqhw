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



entity keccak16 is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    init : in std_logic;
    go : in std_logic;
    absorb : in std_logic;
    squeeze : in std_logic;
    din     : in  std_logic_vector(N-1 downto 0);    
    ready : out std_logic;
    dout    : out std_logic_vector(N-1 downto 0));

end keccak16;

architecture rtl of keccak16 is

--components

component rho_pi16
port (

    rho_pi_in     : in  k_state;
    rho_pi_out    : out k_state);

end component;

component chi_iota_theta16
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

 end component;


component keccak_round_constants_gen16
port (
    round_number: in unsigned(4 downto 0);
    round_constant_signal_out: out std_logic_vector(N-1 downto 0));
 end component;


 
 

  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

 
  signal reg_data,rho_pi_in,rho_pi_out: k_state;
 
  
  signal counter_nr_rounds : unsigned(4 downto 0);
  signal counter_block : unsigned(bits_num_slices downto 0); -- here you need one more bit since it counts also rho-pi phase

  signal round_constant_signal: std_logic_vector(N-1 downto 0);
  signal permutation_computed : std_logic;

signal     chi_inp,theta_inp     :  sub_state;


signal    k_slice_theta_p_in: k_slice;
signal    theta_parity_inp     :  k_row;
signal    first_round : std_logic;
signal    first_block : std_logic;
signal    round_constant_signal_sub    : sub_lane;
signal    theta_parity_outp,theta_parity_reg     : k_row;
signal    iota_outp     : sub_state;
signal    theta_outp     : sub_state;
signal tmp : std_logic_vector(N-1 downto 0);
 
  
begin  -- Rtl

-- port map

rho_pi_map: rho_pi16 port map(reg_data, rho_pi_out);


chi_iota_theta_map: chi_iota_theta16 port map 
(
    chi_inp,
    theta_inp,
    k_slice_theta_p_in,
    theta_parity_inp,
    first_round,
    first_block,
    round_constant_signal_sub,
    round_constant_signal(63),
    theta_parity_outp,
    iota_outp,
    theta_outp);


round_constants_gen: keccak_round_constants_gen16 port map(counter_nr_rounds,round_constant_signal);

-- constants signals
--zero_lane<= (others =>'0');

--i000: for x in 0 to 4 generate
--	zero_plane(x)<= zero_lane;
--end generate;

--i001: for y in 0 to 4 generate
--	zero_state(y)<= zero_plane;
--end generate;



 
 
 -- state register and counter of the number of rounds
 
  p_main : process (clk, rst_n)
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
      --reg_data <= zero_state;
      		for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to N-1 loop
					reg_data(row)(col)(i)<='0';
				end loop;
			end loop;
		end loop;
      counter_nr_rounds <= (others => '0');
      counter_block <= (others => '0');
      permutation_computed <='1';
      first_block<='0';
      first_round<='0';
      
    elsif clk'event and clk = '1' then  -- rising clk edge
	tmp<=(others=>'0');

	if (init='1') then
		--reg_data <= zero_state;
		for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to N-1 loop
					reg_data(row)(col)(i)<='0';
				end loop;
			end loop;
		end loop;
		counter_nr_rounds <= (others => '0');
		counter_block <= (others => '0');	
		permutation_computed<='1';		
		first_block<='0';
		first_round<='0';
	else
		if(go='1') then
			counter_nr_rounds <= (others => '0');
			counter_block <= (others => '0');	
			permutation_computed<='0';
			first_block<='1';
			first_round<='1';
			
			-- do the first semi round
		
		else
			if(absorb='1' or squeeze='1') then
				-- absorb the input
				
				-- here rate is fixed to 1024
				for i in 0 to (N-1) loop
					tmp(i)<=reg_data(3)(0)(i);
					reg_data(3)(0)(i)<=reg_data(0)(0)(i) xor (absorb and din(i));																																						
				end loop;		
				for col in 0 to 3 loop
					for i in 0 to (N-1) loop				
						reg_data(0)(col)(i)<=reg_data(0)(col+1)(i);	
					end loop;
				end loop;
				for i in 0 to (N-1) loop				
					reg_data(0)(4)(i)<=reg_data(1)(0)(i);	
				end loop;				
				for col in 0 to 3 loop
					for i in 0 to (N-1) loop				
						reg_data(1)(col)(i)<=reg_data(1)(col+1)(i);	
					end loop;
				end loop;
				
				for i in 0 to (N-1) loop				
					reg_data(1)(4)(i)<=reg_data(2)(0)(i);	
				end loop;	
				
							
				for col in 0 to 3 loop
					for i in 0 to (N-1) loop				
						reg_data(2)(col)(i)<=reg_data(2)(col+1)(i);	
					end loop;
				end loop;
								
				for i in 0 to (N-1) loop				
					reg_data(2)(4)(i)<=tmp(i);	
				end loop;				
				
			else
			
				if(permutation_computed='0') then
				--continue computation of the rounds
					if(counter_block=0) then
						first_block <='0';
						counter_block<=counter_block+1;
						for row in 0 to 4 loop
							for col in 0 to 4 loop
								for i in 0 to (bit_per_sub_lane-1) loop

									reg_data(row)(col)(i)<=reg_data(row)(col)(bit_per_sub_lane+i);
									for j in 1 to (num_slices-2) loop
										reg_data(row)(col)(j*bit_per_sub_lane+i)<=reg_data(row)(col)((j+1)*bit_per_sub_lane+i);											
									end loop;									
									reg_data(row)(col)((num_slices-1)*bit_per_sub_lane+i)<=theta_outp(row)(col)(i);																														
								end loop;
							end loop;	
						end loop;						
					else
						first_block <='0';
						counter_block<=counter_block+1;					
						if(counter_block=num_slices) then
							--do_rho_pi;
							for row in 0 to 4 loop
								for col in 0 to 4 loop
									for i in 0 to N-1 loop
										reg_data(row)(col)(i)<= rho_pi_out(row)(col)(i);
									end loop;
								end loop;	
							end loop;							
							
							counter_block <= (others => '0');
							counter_nr_rounds<=counter_nr_rounds+1;
							first_round <='0';
							first_block <='1';
						else
							for row in 0 to 4 loop
								for col in 0 to 4 loop
									for i in 0 to (bit_per_sub_lane-1) loop																		
										reg_data(row)(col)(i)<=reg_data(row)(col)(bit_per_sub_lane+i);
										for j in 1 to (num_slices-2) loop
											reg_data(row)(col)(j*bit_per_sub_lane+i)<=reg_data(row)(col)((j+1)*bit_per_sub_lane+i);											
										end loop;																											
										reg_data(row)(col)((num_slices-1)*bit_per_sub_lane+i)<=theta_outp(row)(col)(i);			
									end loop;
								end loop;	
							end loop;						
						end if;
					end if;
				
					if( counter_nr_rounds = 24) then

						counter_block<=counter_block+1;

						for row in 0 to 4 loop
							for col in 0 to 4 loop
								for i in 0 to (bit_per_sub_lane-1) loop									
									reg_data(row)(col)(i)<=reg_data(row)(col)(bit_per_sub_lane+i);
									for j in 1 to (num_slices-2) loop
										reg_data(row)(col)(j*bit_per_sub_lane+i)<=reg_data(row)(col)((j+1)*bit_per_sub_lane+i);											
									end loop;
									reg_data(row)(col)((num_slices-1)*bit_per_sub_lane+i)<=iota_outp(row)(col)(i);																														
								end loop;
							end loop;	
						end loop;						
						if(counter_block = (num_slices-1)) then
							-- do the last part of the last round
							permutation_computed<='1';
							counter_nr_rounds<= (others => '0');
						
						end if;

					

					end if;
				end if;
			end if;

		end if;
		
		
	end if;
    end if;
  end process p_main;

-- process for the register stoing the parity of the previous block
 p_reg_parity : process (clk, rst_n)   
  begin  -- process p_reg_parity
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
    	theta_parity_reg <=(others=>'0');
    elsif clk'event and clk = '1' then  -- rising clk edge
	    theta_parity_reg<= theta_parity_outp;
    
    end if;
 
end process p_reg_parity;

-- assign input of the comp block
theta_parity_inp<=theta_parity_reg;

i100: for y in 0 to 4 generate
	i101: for x in 0 to 4 generate
		i102: for i in 0 to (bit_per_sub_lane-1) generate
			theta_inp(y)(x)(i)<=reg_data(y)(x)(i);
			chi_inp(y)(x)(i)<=reg_data(y)(x)(i);
		
		end generate;	
	end generate;
end generate;

i200: for y in 0 to 4 generate
	i201: for x in 0 to 4 generate
		k_slice_theta_p_in(x)(y)<=reg_data(x)(y)(63);
	end generate;
end generate;

-- check bit order

-- here the number of blocks is hardwired
-- canbe easily fixed with somethign like round_constant_signal_sub(i)<= round_constant_signal(i+bit_per_sub_lane*counterblock)
-- but not feasible
i302: for i in 0 to (bit_per_sub_lane-1) generate	

	round_constant_signal_sub(i)<= round_constant_signal(i) when (counter_block=0)
	
	-- uncomment next line for 2 blocks of slices	
--		else round_constant_signal(i+bit_per_sub_lane);


-- uncomment these lines for 4 blocks of slices	
--	else round_constant_signal(i+bit_per_sub_lane) when (counter_block=1)
--	else round_constant_signal(i+ 2*bit_per_sub_lane) when (counter_block=2)
--	else round_constant_signal(i+ 3*bit_per_sub_lane) ;

-- uncomment these lines for 8 blocks of slices	

--	else round_constant_signal(i+bit_per_sub_lane) when (counter_block=1)
--	else round_constant_signal(i+ 2*bit_per_sub_lane) when (counter_block=2)
--	else round_constant_signal(i+ 3*bit_per_sub_lane) when (counter_block=3)
--	else round_constant_signal(i+ 4*bit_per_sub_lane) when (counter_block=4)
--	else round_constant_signal(i+ 5*bit_per_sub_lane) when (counter_block=5)
--	else round_constant_signal(i+ 6*bit_per_sub_lane) when (counter_block=6)
--	else round_constant_signal(i+ 7*bit_per_sub_lane) ;

-- uncomment these lines for 16 blocks of slices	

	else round_constant_signal(i+bit_per_sub_lane) when (counter_block=1)
	else round_constant_signal(i+ 2*bit_per_sub_lane) when (counter_block=2)
	else round_constant_signal(i+ 3*bit_per_sub_lane) when (counter_block=3)
	else round_constant_signal(i+ 4*bit_per_sub_lane) when (counter_block=4)
	else round_constant_signal(i+ 5*bit_per_sub_lane) when (counter_block=5)
	else round_constant_signal(i+ 6*bit_per_sub_lane) when (counter_block=6)
	else round_constant_signal(i+ 7*bit_per_sub_lane) when (counter_block=7)
	else round_constant_signal(i+ 8*bit_per_sub_lane) when (counter_block=8)
	else round_constant_signal(i+ 9*bit_per_sub_lane) when (counter_block=9)
	else round_constant_signal(i+ 10*bit_per_sub_lane) when (counter_block=10)
	else round_constant_signal(i+ 11*bit_per_sub_lane) when (counter_block=11)
	else round_constant_signal(i+ 12*bit_per_sub_lane) when (counter_block=12)
	else round_constant_signal(i+ 13*bit_per_sub_lane) when (counter_block=13)
	else round_constant_signal(i+ 14*bit_per_sub_lane) when (counter_block=14)	
	else round_constant_signal(i+ 15*bit_per_sub_lane) ;

-- uncomment these lines for 32 blocks of slices	
  --      else round_constant_signal(i+bit_per_sub_lane) when (counter_block=1)
  --      else round_constant_signal(i+ 2*bit_per_sub_lane) when (counter_block=2)
  --      else round_constant_signal(i+ 3*bit_per_sub_lane) when (counter_block=3)
  --      else round_constant_signal(i+ 4*bit_per_sub_lane) when (counter_block=4)
  --      else round_constant_signal(i+ 5*bit_per_sub_lane) when (counter_block=5)
  --      else round_constant_signal(i+ 6*bit_per_sub_lane) when (counter_block=6)
  --      else round_constant_signal(i+ 7*bit_per_sub_lane) when (counter_block=7)
  --      else round_constant_signal(i+ 8*bit_per_sub_lane) when (counter_block=8)
  --      else round_constant_signal(i+ 9*bit_per_sub_lane) when (counter_block=9)
  --      else round_constant_signal(i+ 10*bit_per_sub_lane) when (counter_block=10)
  --      else round_constant_signal(i+ 11*bit_per_sub_lane) when (counter_block=11)
  --      else round_constant_signal(i+ 12*bit_per_sub_lane) when (counter_block=12)
  --      else round_constant_signal(i+ 13*bit_per_sub_lane) when (counter_block=13)
  --      else round_constant_signal(i+ 14*bit_per_sub_lane) when (counter_block=14)	
  --      else round_constant_signal(i+ 15*bit_per_sub_lane) when (counter_block=15)
  --      else round_constant_signal(i+ 16*bit_per_sub_lane) when (counter_block=16)
  --      else round_constant_signal(i+ 17*bit_per_sub_lane) when (counter_block=17)
  --      else round_constant_signal(i+ 18*bit_per_sub_lane) when (counter_block=18)
  --      else round_constant_signal(i+ 19*bit_per_sub_lane) when (counter_block=19)
  --      else round_constant_signal(i+ 20*bit_per_sub_lane) when (counter_block=20)
  --      else round_constant_signal(i+ 21*bit_per_sub_lane) when (counter_block=21)
  --      else round_constant_signal(i+ 22*bit_per_sub_lane) when (counter_block=22)
  --      else round_constant_signal(i+ 23*bit_per_sub_lane) when (counter_block=23)
  --      else round_constant_signal(i+ 24*bit_per_sub_lane) when (counter_block=24)
  --      else round_constant_signal(i+ 25*bit_per_sub_lane) when (counter_block=25)
  --      else round_constant_signal(i+ 26*bit_per_sub_lane) when (counter_block=26)
  --      else round_constant_signal(i+ 27*bit_per_sub_lane) when (counter_block=27)	
  --else round_constant_signal(i+ 28*bit_per_sub_lane) when (counter_block=28)	
  --else round_constant_signal(i+ 29*bit_per_sub_lane) when (counter_block=29)	
  --else round_constant_signal(i+ 30*bit_per_sub_lane) when (counter_block=30)		
  --      else round_constant_signal(i+ 31*bit_per_sub_lane) ;


end generate;

ready<=permutation_computed;

-- check if output order is correct or if dout shoulde connected to another register
i400: for i in 0 to (N-1) generate	
	dout(i)<=reg_data(0)(0)(i);
	end generate;

end rtl;
