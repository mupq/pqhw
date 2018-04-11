-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
-- Date        : Mon Apr 03 10:16:30 2017
-- Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_sim_netlist.vhdl
-- Design      : invpsi_mem
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_prim_wrapper_init is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_prim_wrapper_init : entity is "blk_mem_gen_prim_wrapper_init";
end invpsi_mem_blk_mem_gen_prim_wrapper_init;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_prim_wrapper_init is
  signal \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_0\ : STD_LOGIC;
  signal \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_32\ : STD_LOGIC;
  signal \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_33\ : STD_LOGIC;
  signal \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_8\ : STD_LOGIC;
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_DOBDO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_DOPBDOP_UNCONNECTED\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute CLOCK_DOMAINS : string;
  attribute CLOCK_DOMAINS of \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram\ : label is "COMMON";
  attribute box_type : string;
  attribute box_type of \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram\ : label is "PRIMITIVE";
begin
\DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram\: unisim.vcomponents.RAMB18E1
    generic map(
      DOA_REG => 1,
      DOB_REG => 0,
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_00 => X"442B1B301371435C0C6E56454706321D0A195A2F33192026281A40360B470001",
      INIT_01 => X"25554B32144107350433171F173E15383321236F3862323D1A002D112672553A",
      INIT_02 => X"476E00512160076817132620176B4D430919211F0C631550010C0E3D24030556",
      INIT_03 => X"4D720912073B06161901483B38230A2E3A13153B183F43013A3C1B6108261176",
      INIT_04 => X"07391D245946327A4C555F0B4E6C274B411419603D1D4D2522025E7F496C297E",
      INIT_05 => X"161A5C2158035F7813245D2E32625B610D093E4B2953267D20511C00551C135D",
      INIT_06 => X"1C6E283B0D5F1C7B454B026313742107434C447E5E702B26152B1E5C261A2E17",
      INIT_07 => X"56153D5D3B692C7B4D075D33546D5261502419595A2846584940462D27641029",
      INIT_08 => X"125F1A482847184017385A6248395E0E2B375C5D110253794070395844365C25",
      INIT_09 => X"192F147E1F0A171912424950362D444B5323104E3562470F0901164411491F50",
      INIT_0A => X"455D526840281947161F223E4F033D6D27321201402C4B2C3736155C261F5435",
      INIT_0B => X"4F0B4136007126370120473400033D2C434D393736564A710B12242E53020D71",
      INIT_0C => X"08294F220314242556713664093746515C1420002A444D3421710333551F5109",
      INIT_0D => X"5817386E3821213C26700C471D44066B13054343307B48561406110B2F171276",
      INIT_0E => X"580826155321275C5F66177A1D330B2054005E0F3B17202F1476430938660421",
      INIT_0F => X"4D205C47276D082B5C7B597C1D79423F5D1F3A041660333F386D133149560815",
      INIT_10 => X"3626353B430330345C2D1F145D45027E0F711F1E415A507F0A4F2A3B58340966",
      INIT_11 => X"5A734414525B503E2B19372B4702003830092D662A271C3B392D2F795C710D40",
      INIT_12 => X"382A193E4F08040A2164394D1F6B363E097E1228504C2B461B3A0811315C077A",
      INIT_13 => X"227325352B213A743D202A5001131D4D301B1D6A565B147B416D353C2338081A",
      INIT_14 => X"17552B5A3A53320320755C094E03045D03251F70436F304D1C10464230442410",
      INIT_15 => X"003A01714435076B505D271106752E78446C2C315E730851161C4513074F3F0D",
      INIT_16 => X"5A5C2D722F271A085556154E0034471B5356032F1349316F410C16175E6A104F",
      INIT_17 => X"28791668204918372A5C580F1B1A596E38403B273A551A750140555839511001",
      INIT_18 => X"4C665A56433900400C1E326B1704134718330D53176E2A6E22512E1F42072909",
      INIT_19 => X"1F6F082258675C48505B3E1F57294F6340335A3C184E555A3E711B722F310643",
      INIT_1A => X"46003E3701284A7D313827720F2A53472F6A137B284009305531410D2F673650",
      INIT_1B => X"5D5A302E327B5A751F3040141D3216675D3C0A7C087A0734311B567A1D101F51",
      INIT_1C => X"406A1F01154F5E654E18320D0F6F362C42455C5F316D0345354C252625015574",
      INIT_1D => X"482B3F6E4D480E3349255E2745171B4941065B413003130F505F100316420E0D",
      INIT_1E => X"15322D6C2C674B22174152645E535A2E0F371D2D5D2649141973032A513F3A6F",
      INIT_1F => X"5F5056123166543613440B510C2F2E3654195D230E17357A3608100919023C74",
      INIT_20 => X"5C07561A5511326946351A0A4E5D14720F161A504B7256744A29091A2A66444A",
      INIT_21 => X"3C1F5D080277532D0E2C032911090308303C2047080E071B11372F4C4A115E40",
      INIT_22 => X"0A22523149331C462C3A13171E6B5D2F45722017540F1067001438773C013756",
      INIT_23 => X"342345710E641C282C5C0A2D08050F19313A10641E77325C4C77562138063936",
      INIT_24 => X"455211731A413E12263144394210210B17031F0E5B053418046E0D4933593C6E",
      INIT_25 => X"03160D175E6F366D5506517530332845016F1654581F3C373B43040035293957",
      INIT_26 => X"3A7E211B2B0E563717543721026C123809541749287E3D0647503B2057601428",
      INIT_27 => X"5E4D3F57237D4B000B0128635E35347C0B3C1F0D1A4F5C320A40176213331006",
      INIT_28 => X"39453A54580B03405552436A411B28704A645F4547010B7F323523564E2D5F3D",
      INIT_29 => X"1F07396E2D4B47725478335523194E304261391E4C2117703813031C2B542D55",
      INIT_2A => X"097B347D09182C663A05571C0B25086B2E632B5C5B3E4150155147572E4E5E2D",
      INIT_2B => X"4F70323F445A3C2D1B4E41080D5C3F504E1E4C643E56336C383A20500B6E1D35",
      INIT_2C => X"456219053728573D43233E580F085C31515F49133C7818635711450843051926",
      INIT_2D => X"1A283E7E3E730464207E540B041C007D4726404130122568551410143D4D025A",
      INIT_2E => X"355D2071194E2E6944460336563F383C0C000D394D042007552417265A341C05",
      INIT_2F => X"5D2A1A783C470E74285B5137564924770D294C6F032059535A35103E4F0D2A28",
      INIT_30 => X"231859775B6F4B3F44073B281B0A525C0F7E4905170D0B49460C13645E76457D",
      INIT_31 => X"514832711944422E214D232B5C380008066F1421582B11643F073D5B1A7E1D2E",
      INIT_32 => X"08060352421452703B58313049103077535C1E0642302F2F037638034B570E6D",
      INIT_33 => X"4948497606174C7F0860136700152D305917117D5E572C124D7E3E4005080116",
      INIT_34 => X"3A1F4A69160C3E0120115F3942010E3245061F7E09593D672D1517651453573A",
      INIT_35 => X"291B0D7E09632A22500E57710E5A2F6D25225851365A1C552C29174C2A1E2439",
      INIT_36 => X"28324B11066156025E4447550D634E600B7A52631E1D22473239553B0D461D67",
      INIT_37 => X"3C5B476B56793A2D4A57355E114D51354C5316183F1F48360D77275623553913",
      INIT_38 => X"340F0C7A32644453384E5947476F550B4808541F2C473C7E2E0C5873246F056F",
      INIT_39 => X"3B354561280F5F42267B4D3C432B42215B3F3609034250692435037E143E2A0A",
      INIT_3A => X"0A005B1B00180A5B070813352B2B272F5910026D580A0F07352C17024B34231E",
      INIT_3B => X"1B0D3007225B1A5A3B2C4D5F117503215177536E38120E63223B0C36563A121E",
      INIT_3C => X"167D04372C1E365842044B5E466C3E50402F28575935372F0754052A3C13275A",
      INIT_3D => X"41193F7E341D2B1A4F061B18097148421701361C4B385503192002253A0A1D39",
      INIT_3E => X"47512F592F4633731E6542584431360746643B070D2A4128557F1B74501C1610",
      INIT_3F => X"5F7A507159344276472F3843462C22085E295F4F2B165A005A021D5D11253F48",
      INIT_A => X"00000",
      INIT_B => X"00000",
      INIT_FILE => "NONE",
      IS_CLKARDCLK_INVERTED => '0',
      IS_CLKBWRCLK_INVERTED => '0',
      IS_ENARDEN_INVERTED => '0',
      IS_ENBWREN_INVERTED => '0',
      IS_RSTRAMARSTRAM_INVERTED => '0',
      IS_RSTRAMB_INVERTED => '0',
      IS_RSTREGARSTREG_INVERTED => '0',
      IS_RSTREGB_INVERTED => '0',
      RAM_MODE => "TDP",
      RDADDR_COLLISION_HWCONFIG => "PERFORMANCE",
      READ_WIDTH_A => 18,
      READ_WIDTH_B => 18,
      RSTREG_PRIORITY_A => "REGCE",
      RSTREG_PRIORITY_B => "REGCE",
      SIM_COLLISION_CHECK => "ALL",
      SIM_DEVICE => "7SERIES",
      SRVAL_A => X"00000",
      SRVAL_B => X"00000",
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18
    )
        port map (
      ADDRARDADDR(13 downto 4) => addra(9 downto 0),
      ADDRARDADDR(3 downto 0) => B"0000",
      ADDRBWRADDR(13 downto 0) => B"00000000000000",
      CLKARDCLK => clka,
      CLKBWRCLK => clka,
      DIADI(15 downto 0) => B"0000000000000000",
      DIBDI(15 downto 0) => B"0000000000000000",
      DIPADIP(1 downto 0) => B"00",
      DIPBDIP(1 downto 0) => B"00",
      DOADO(15) => \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_0\,
      DOADO(14 downto 8) => douta(13 downto 7),
      DOADO(7) => \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_8\,
      DOADO(6 downto 0) => douta(6 downto 0),
      DOBDO(15 downto 0) => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_DOBDO_UNCONNECTED\(15 downto 0),
      DOPADOP(1) => \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_32\,
      DOPADOP(0) => \DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_n_33\,
      DOPBDOP(1 downto 0) => \NLW_DEVICE_7SERIES.NO_BMM_INFO.SP.SIMPLE_PRIM18.ram_DOPBDOP_UNCONNECTED\(1 downto 0),
      ENARDEN => ena,
      ENBWREN => '0',
      REGCEAREGCE => ena,
      REGCEB => '0',
      RSTRAMARSTRAM => '0',
      RSTRAMB => '0',
      RSTREGARSTREG => '0',
      RSTREGB => '0',
      WEA(1 downto 0) => B"00",
      WEBWE(3 downto 0) => B"0000"
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_prim_width is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_prim_width : entity is "blk_mem_gen_prim_width";
end invpsi_mem_blk_mem_gen_prim_width;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_prim_width is
begin
\prim_init.ram\: entity work.invpsi_mem_blk_mem_gen_prim_wrapper_init
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      clka => clka,
      douta(13 downto 0) => douta(13 downto 0),
      ena => ena
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_generic_cstr is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_generic_cstr : entity is "blk_mem_gen_generic_cstr";
end invpsi_mem_blk_mem_gen_generic_cstr;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_generic_cstr is
begin
\ramloop[0].ram.r\: entity work.invpsi_mem_blk_mem_gen_prim_width
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      clka => clka,
      douta(13 downto 0) => douta(13 downto 0),
      ena => ena
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_top is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_top : entity is "blk_mem_gen_top";
end invpsi_mem_blk_mem_gen_top;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_top is
begin
\valid.cstr\: entity work.invpsi_mem_blk_mem_gen_generic_cstr
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      clka => clka,
      douta(13 downto 0) => douta(13 downto 0),
      ena => ena
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_v8_3_0_synth is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_v8_3_0_synth : entity is "blk_mem_gen_v8_3_0_synth";
end invpsi_mem_blk_mem_gen_v8_3_0_synth;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_v8_3_0_synth is
begin
\gnativebmg.native_blk_mem_gen\: entity work.invpsi_mem_blk_mem_gen_top
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      clka => clka,
      douta(13 downto 0) => douta(13 downto 0),
      ena => ena
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem_blk_mem_gen_v8_3_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    regcea : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 13 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clkb : in STD_LOGIC;
    rstb : in STD_LOGIC;
    enb : in STD_LOGIC;
    regceb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 13 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 13 downto 0 );
    injectsbiterr : in STD_LOGIC;
    injectdbiterr : in STD_LOGIC;
    eccpipece : in STD_LOGIC;
    sbiterr : out STD_LOGIC;
    dbiterr : out STD_LOGIC;
    rdaddrecc : out STD_LOGIC_VECTOR ( 9 downto 0 );
    sleep : in STD_LOGIC;
    deepsleep : in STD_LOGIC;
    shutdown : in STD_LOGIC;
    rsta_busy : out STD_LOGIC;
    rstb_busy : out STD_LOGIC;
    s_aclk : in STD_LOGIC;
    s_aresetn : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 13 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 13 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    s_axi_injectsbiterr : in STD_LOGIC;
    s_axi_injectdbiterr : in STD_LOGIC;
    s_axi_sbiterr : out STD_LOGIC;
    s_axi_dbiterr : out STD_LOGIC;
    s_axi_rdaddrecc : out STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute C_ADDRA_WIDTH : integer;
  attribute C_ADDRA_WIDTH of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 10;
  attribute C_ADDRB_WIDTH : integer;
  attribute C_ADDRB_WIDTH of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 10;
  attribute C_ALGORITHM : integer;
  attribute C_ALGORITHM of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_AXI_ID_WIDTH : integer;
  attribute C_AXI_ID_WIDTH of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 4;
  attribute C_AXI_SLAVE_TYPE : integer;
  attribute C_AXI_SLAVE_TYPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_AXI_TYPE : integer;
  attribute C_AXI_TYPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_BYTE_SIZE : integer;
  attribute C_BYTE_SIZE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 9;
  attribute C_COMMON_CLK : integer;
  attribute C_COMMON_CLK of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_COUNT_18K_BRAM : string;
  attribute C_COUNT_18K_BRAM of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "1";
  attribute C_COUNT_36K_BRAM : string;
  attribute C_COUNT_36K_BRAM of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_CTRL_ECC_ALGO : string;
  attribute C_CTRL_ECC_ALGO of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "NONE";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_DISABLE_WARN_BHV_COLL : integer;
  attribute C_DISABLE_WARN_BHV_COLL of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_DISABLE_WARN_BHV_RANGE : integer;
  attribute C_DISABLE_WARN_BHV_RANGE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "./";
  attribute C_ENABLE_32BIT_ADDRESS : integer;
  attribute C_ENABLE_32BIT_ADDRESS of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_DEEPSLEEP_PIN : integer;
  attribute C_EN_DEEPSLEEP_PIN of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_ECC_PIPE : integer;
  attribute C_EN_ECC_PIPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_RDADDRA_CHG : integer;
  attribute C_EN_RDADDRA_CHG of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_RDADDRB_CHG : integer;
  attribute C_EN_RDADDRB_CHG of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SAFETY_CKT : integer;
  attribute C_EN_SAFETY_CKT of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SHUTDOWN_PIN : integer;
  attribute C_EN_SHUTDOWN_PIN of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SLEEP_PIN : integer;
  attribute C_EN_SLEEP_PIN of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EST_POWER_SUMMARY : string;
  attribute C_EST_POWER_SUMMARY of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "Estimated Power for IP     :     1.3132 mW";
  attribute C_FAMILY : string;
  attribute C_FAMILY of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "artix7";
  attribute C_HAS_AXI_ID : integer;
  attribute C_HAS_AXI_ID of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_ENA : integer;
  attribute C_HAS_ENA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_HAS_ENB : integer;
  attribute C_HAS_ENB of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_INJECTERR : integer;
  attribute C_HAS_INJECTERR of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_A : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_HAS_MEM_OUTPUT_REGS_B : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_A : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_B : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_REGCEA : integer;
  attribute C_HAS_REGCEA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_REGCEB : integer;
  attribute C_HAS_REGCEB of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_RSTA : integer;
  attribute C_HAS_RSTA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_RSTB : integer;
  attribute C_HAS_RSTB of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_SOFTECC_INPUT_REGS_A : integer;
  attribute C_HAS_SOFTECC_INPUT_REGS_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B : integer;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_INITA_VAL : string;
  attribute C_INITA_VAL of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_INITB_VAL : string;
  attribute C_INITB_VAL of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_INIT_FILE : string;
  attribute C_INIT_FILE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "invpsi_mem.mem";
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "invpsi_mem.mif";
  attribute C_INTERFACE_TYPE : integer;
  attribute C_INTERFACE_TYPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_LOAD_INIT_FILE : integer;
  attribute C_LOAD_INIT_FILE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 3;
  attribute C_MUX_PIPELINE_STAGES : integer;
  attribute C_MUX_PIPELINE_STAGES of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_PRIM_TYPE : integer;
  attribute C_PRIM_TYPE of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_READ_DEPTH_A : integer;
  attribute C_READ_DEPTH_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_READ_DEPTH_B : integer;
  attribute C_READ_DEPTH_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_READ_WIDTH_A : integer;
  attribute C_READ_WIDTH_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_READ_WIDTH_B : integer;
  attribute C_READ_WIDTH_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_RSTRAM_A : integer;
  attribute C_RSTRAM_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_RSTRAM_B : integer;
  attribute C_RSTRAM_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_RST_PRIORITY_A : string;
  attribute C_RST_PRIORITY_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "CE";
  attribute C_RST_PRIORITY_B : string;
  attribute C_RST_PRIORITY_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "CE";
  attribute C_SIM_COLLISION_CHECK : string;
  attribute C_SIM_COLLISION_CHECK of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "ALL";
  attribute C_USE_BRAM_BLOCK : integer;
  attribute C_USE_BRAM_BLOCK of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_BYTE_WEA : integer;
  attribute C_USE_BYTE_WEA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_BYTE_WEB : integer;
  attribute C_USE_BYTE_WEB of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_DEFAULT_DATA : integer;
  attribute C_USE_DEFAULT_DATA of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_ECC : integer;
  attribute C_USE_ECC of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_SOFTECC : integer;
  attribute C_USE_SOFTECC of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_URAM : integer;
  attribute C_USE_URAM of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_WEA_WIDTH : integer;
  attribute C_WEA_WIDTH of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_WEB_WIDTH : integer;
  attribute C_WEB_WIDTH of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_WRITE_DEPTH_A : integer;
  attribute C_WRITE_DEPTH_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_WRITE_DEPTH_B : integer;
  attribute C_WRITE_DEPTH_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_WRITE_MODE_A : string;
  attribute C_WRITE_MODE_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "WRITE_FIRST";
  attribute C_WRITE_MODE_B : string;
  attribute C_WRITE_MODE_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_A : integer;
  attribute C_WRITE_WIDTH_A of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_WRITE_WIDTH_B : integer;
  attribute C_WRITE_WIDTH_B of invpsi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "artix7";
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "blk_mem_gen_v8_3_0";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of invpsi_mem_blk_mem_gen_v8_3_0 : entity is "yes";
end invpsi_mem_blk_mem_gen_v8_3_0;

architecture STRUCTURE of invpsi_mem_blk_mem_gen_v8_3_0 is
  signal \<const0>\ : STD_LOGIC;
begin
  dbiterr <= \<const0>\;
  doutb(13) <= \<const0>\;
  doutb(12) <= \<const0>\;
  doutb(11) <= \<const0>\;
  doutb(10) <= \<const0>\;
  doutb(9) <= \<const0>\;
  doutb(8) <= \<const0>\;
  doutb(7) <= \<const0>\;
  doutb(6) <= \<const0>\;
  doutb(5) <= \<const0>\;
  doutb(4) <= \<const0>\;
  doutb(3) <= \<const0>\;
  doutb(2) <= \<const0>\;
  doutb(1) <= \<const0>\;
  doutb(0) <= \<const0>\;
  rdaddrecc(9) <= \<const0>\;
  rdaddrecc(8) <= \<const0>\;
  rdaddrecc(7) <= \<const0>\;
  rdaddrecc(6) <= \<const0>\;
  rdaddrecc(5) <= \<const0>\;
  rdaddrecc(4) <= \<const0>\;
  rdaddrecc(3) <= \<const0>\;
  rdaddrecc(2) <= \<const0>\;
  rdaddrecc(1) <= \<const0>\;
  rdaddrecc(0) <= \<const0>\;
  rsta_busy <= \<const0>\;
  rstb_busy <= \<const0>\;
  s_axi_arready <= \<const0>\;
  s_axi_awready <= \<const0>\;
  s_axi_bid(3) <= \<const0>\;
  s_axi_bid(2) <= \<const0>\;
  s_axi_bid(1) <= \<const0>\;
  s_axi_bid(0) <= \<const0>\;
  s_axi_bresp(1) <= \<const0>\;
  s_axi_bresp(0) <= \<const0>\;
  s_axi_bvalid <= \<const0>\;
  s_axi_dbiterr <= \<const0>\;
  s_axi_rdaddrecc(9) <= \<const0>\;
  s_axi_rdaddrecc(8) <= \<const0>\;
  s_axi_rdaddrecc(7) <= \<const0>\;
  s_axi_rdaddrecc(6) <= \<const0>\;
  s_axi_rdaddrecc(5) <= \<const0>\;
  s_axi_rdaddrecc(4) <= \<const0>\;
  s_axi_rdaddrecc(3) <= \<const0>\;
  s_axi_rdaddrecc(2) <= \<const0>\;
  s_axi_rdaddrecc(1) <= \<const0>\;
  s_axi_rdaddrecc(0) <= \<const0>\;
  s_axi_rdata(13) <= \<const0>\;
  s_axi_rdata(12) <= \<const0>\;
  s_axi_rdata(11) <= \<const0>\;
  s_axi_rdata(10) <= \<const0>\;
  s_axi_rdata(9) <= \<const0>\;
  s_axi_rdata(8) <= \<const0>\;
  s_axi_rdata(7) <= \<const0>\;
  s_axi_rdata(6) <= \<const0>\;
  s_axi_rdata(5) <= \<const0>\;
  s_axi_rdata(4) <= \<const0>\;
  s_axi_rdata(3) <= \<const0>\;
  s_axi_rdata(2) <= \<const0>\;
  s_axi_rdata(1) <= \<const0>\;
  s_axi_rdata(0) <= \<const0>\;
  s_axi_rid(3) <= \<const0>\;
  s_axi_rid(2) <= \<const0>\;
  s_axi_rid(1) <= \<const0>\;
  s_axi_rid(0) <= \<const0>\;
  s_axi_rlast <= \<const0>\;
  s_axi_rresp(1) <= \<const0>\;
  s_axi_rresp(0) <= \<const0>\;
  s_axi_rvalid <= \<const0>\;
  s_axi_sbiterr <= \<const0>\;
  s_axi_wready <= \<const0>\;
  sbiterr <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst_blk_mem_gen: entity work.invpsi_mem_blk_mem_gen_v8_3_0_synth
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      clka => clka,
      douta(13 downto 0) => douta(13 downto 0),
      ena => ena
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity invpsi_mem is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of invpsi_mem : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of invpsi_mem : entity is "invpsi_mem,blk_mem_gen_v8_3_0,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of invpsi_mem : entity is "invpsi_mem,blk_mem_gen_v8_3_0,{x_ipProduct=Vivado 2015.3,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=blk_mem_gen,x_ipVersion=8.3,x_ipCoreRevision=0,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_FAMILY=artix7,C_XDEVICEFAMILY=artix7,C_ELABORATION_DIR=./,C_INTERFACE_TYPE=0,C_AXI_TYPE=1,C_AXI_SLAVE_TYPE=0,C_USE_BRAM_BLOCK=0,C_ENABLE_32BIT_ADDRESS=0,C_CTRL_ECC_ALGO=NONE,C_HAS_AXI_ID=0,C_AXI_ID_WIDTH=4,C_MEM_TYPE=3,C_BYTE_SIZE=9,C_ALGORITHM=1,C_PRIM_TYPE=1,C_LOAD_INIT_FILE=1,C_INIT_FILE_NAME=invpsi_mem.mif,C_INIT_FILE=invpsi_mem.mem,C_USE_DEFAULT_DATA=0,C_DEFAULT_DATA=0,C_HAS_RSTA=0,C_RST_PRIORITY_A=CE,C_RSTRAM_A=0,C_INITA_VAL=0,C_HAS_ENA=1,C_HAS_REGCEA=0,C_USE_BYTE_WEA=0,C_WEA_WIDTH=1,C_WRITE_MODE_A=WRITE_FIRST,C_WRITE_WIDTH_A=14,C_READ_WIDTH_A=14,C_WRITE_DEPTH_A=1024,C_READ_DEPTH_A=1024,C_ADDRA_WIDTH=10,C_HAS_RSTB=0,C_RST_PRIORITY_B=CE,C_RSTRAM_B=0,C_INITB_VAL=0,C_HAS_ENB=0,C_HAS_REGCEB=0,C_USE_BYTE_WEB=0,C_WEB_WIDTH=1,C_WRITE_MODE_B=WRITE_FIRST,C_WRITE_WIDTH_B=14,C_READ_WIDTH_B=14,C_WRITE_DEPTH_B=1024,C_READ_DEPTH_B=1024,C_ADDRB_WIDTH=10,C_HAS_MEM_OUTPUT_REGS_A=1,C_HAS_MEM_OUTPUT_REGS_B=0,C_HAS_MUX_OUTPUT_REGS_A=0,C_HAS_MUX_OUTPUT_REGS_B=0,C_MUX_PIPELINE_STAGES=0,C_HAS_SOFTECC_INPUT_REGS_A=0,C_HAS_SOFTECC_OUTPUT_REGS_B=0,C_USE_SOFTECC=0,C_USE_ECC=0,C_EN_ECC_PIPE=0,C_HAS_INJECTERR=0,C_SIM_COLLISION_CHECK=ALL,C_COMMON_CLK=0,C_DISABLE_WARN_BHV_COLL=0,C_EN_SLEEP_PIN=0,C_USE_URAM=0,C_EN_RDADDRA_CHG=0,C_EN_RDADDRB_CHG=0,C_EN_DEEPSLEEP_PIN=0,C_EN_SHUTDOWN_PIN=0,C_EN_SAFETY_CKT=0,C_DISABLE_WARN_BHV_RANGE=0,C_COUNT_36K_BRAM=0,C_COUNT_18K_BRAM=1,C_EST_POWER_SUMMARY=Estimated Power for IP     _     1.3132 mW}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of invpsi_mem : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of invpsi_mem : entity is "blk_mem_gen_v8_3_0,Vivado 2015.3";
end invpsi_mem;

architecture STRUCTURE of invpsi_mem is
  signal NLW_U0_dbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_rsta_busy_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_rstb_busy_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_dbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_sbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_s_axi_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_sbiterr_UNCONNECTED : STD_LOGIC;
  signal NLW_U0_doutb_UNCONNECTED : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal NLW_U0_rdaddrecc_UNCONNECTED : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal NLW_U0_s_axi_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_U0_s_axi_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_U0_s_axi_rdaddrecc_UNCONNECTED : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal NLW_U0_s_axi_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal NLW_U0_s_axi_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_U0_s_axi_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_ADDRA_WIDTH : integer;
  attribute C_ADDRA_WIDTH of U0 : label is 10;
  attribute C_ADDRB_WIDTH : integer;
  attribute C_ADDRB_WIDTH of U0 : label is 10;
  attribute C_ALGORITHM : integer;
  attribute C_ALGORITHM of U0 : label is 1;
  attribute C_AXI_ID_WIDTH : integer;
  attribute C_AXI_ID_WIDTH of U0 : label is 4;
  attribute C_AXI_SLAVE_TYPE : integer;
  attribute C_AXI_SLAVE_TYPE of U0 : label is 0;
  attribute C_AXI_TYPE : integer;
  attribute C_AXI_TYPE of U0 : label is 1;
  attribute C_BYTE_SIZE : integer;
  attribute C_BYTE_SIZE of U0 : label is 9;
  attribute C_COMMON_CLK : integer;
  attribute C_COMMON_CLK of U0 : label is 0;
  attribute C_COUNT_18K_BRAM : string;
  attribute C_COUNT_18K_BRAM of U0 : label is "1";
  attribute C_COUNT_36K_BRAM : string;
  attribute C_COUNT_36K_BRAM of U0 : label is "0";
  attribute C_CTRL_ECC_ALGO : string;
  attribute C_CTRL_ECC_ALGO of U0 : label is "NONE";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of U0 : label is "0";
  attribute C_DISABLE_WARN_BHV_COLL : integer;
  attribute C_DISABLE_WARN_BHV_COLL of U0 : label is 0;
  attribute C_DISABLE_WARN_BHV_RANGE : integer;
  attribute C_DISABLE_WARN_BHV_RANGE of U0 : label is 0;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of U0 : label is "./";
  attribute C_ENABLE_32BIT_ADDRESS : integer;
  attribute C_ENABLE_32BIT_ADDRESS of U0 : label is 0;
  attribute C_EN_DEEPSLEEP_PIN : integer;
  attribute C_EN_DEEPSLEEP_PIN of U0 : label is 0;
  attribute C_EN_ECC_PIPE : integer;
  attribute C_EN_ECC_PIPE of U0 : label is 0;
  attribute C_EN_RDADDRA_CHG : integer;
  attribute C_EN_RDADDRA_CHG of U0 : label is 0;
  attribute C_EN_RDADDRB_CHG : integer;
  attribute C_EN_RDADDRB_CHG of U0 : label is 0;
  attribute C_EN_SAFETY_CKT : integer;
  attribute C_EN_SAFETY_CKT of U0 : label is 0;
  attribute C_EN_SHUTDOWN_PIN : integer;
  attribute C_EN_SHUTDOWN_PIN of U0 : label is 0;
  attribute C_EN_SLEEP_PIN : integer;
  attribute C_EN_SLEEP_PIN of U0 : label is 0;
  attribute C_EST_POWER_SUMMARY : string;
  attribute C_EST_POWER_SUMMARY of U0 : label is "Estimated Power for IP     :     1.3132 mW";
  attribute C_FAMILY : string;
  attribute C_FAMILY of U0 : label is "artix7";
  attribute C_HAS_AXI_ID : integer;
  attribute C_HAS_AXI_ID of U0 : label is 0;
  attribute C_HAS_ENA : integer;
  attribute C_HAS_ENA of U0 : label is 1;
  attribute C_HAS_ENB : integer;
  attribute C_HAS_ENB of U0 : label is 0;
  attribute C_HAS_INJECTERR : integer;
  attribute C_HAS_INJECTERR of U0 : label is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_A : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_A of U0 : label is 1;
  attribute C_HAS_MEM_OUTPUT_REGS_B : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_A : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_A of U0 : label is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_B : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_HAS_REGCEA : integer;
  attribute C_HAS_REGCEA of U0 : label is 0;
  attribute C_HAS_REGCEB : integer;
  attribute C_HAS_REGCEB of U0 : label is 0;
  attribute C_HAS_RSTA : integer;
  attribute C_HAS_RSTA of U0 : label is 0;
  attribute C_HAS_RSTB : integer;
  attribute C_HAS_RSTB of U0 : label is 0;
  attribute C_HAS_SOFTECC_INPUT_REGS_A : integer;
  attribute C_HAS_SOFTECC_INPUT_REGS_A of U0 : label is 0;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B : integer;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B of U0 : label is 0;
  attribute C_INITA_VAL : string;
  attribute C_INITA_VAL of U0 : label is "0";
  attribute C_INITB_VAL : string;
  attribute C_INITB_VAL of U0 : label is "0";
  attribute C_INIT_FILE : string;
  attribute C_INIT_FILE of U0 : label is "invpsi_mem.mem";
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of U0 : label is "invpsi_mem.mif";
  attribute C_INTERFACE_TYPE : integer;
  attribute C_INTERFACE_TYPE of U0 : label is 0;
  attribute C_LOAD_INIT_FILE : integer;
  attribute C_LOAD_INIT_FILE of U0 : label is 1;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of U0 : label is 3;
  attribute C_MUX_PIPELINE_STAGES : integer;
  attribute C_MUX_PIPELINE_STAGES of U0 : label is 0;
  attribute C_PRIM_TYPE : integer;
  attribute C_PRIM_TYPE of U0 : label is 1;
  attribute C_READ_DEPTH_A : integer;
  attribute C_READ_DEPTH_A of U0 : label is 1024;
  attribute C_READ_DEPTH_B : integer;
  attribute C_READ_DEPTH_B of U0 : label is 1024;
  attribute C_READ_WIDTH_A : integer;
  attribute C_READ_WIDTH_A of U0 : label is 14;
  attribute C_READ_WIDTH_B : integer;
  attribute C_READ_WIDTH_B of U0 : label is 14;
  attribute C_RSTRAM_A : integer;
  attribute C_RSTRAM_A of U0 : label is 0;
  attribute C_RSTRAM_B : integer;
  attribute C_RSTRAM_B of U0 : label is 0;
  attribute C_RST_PRIORITY_A : string;
  attribute C_RST_PRIORITY_A of U0 : label is "CE";
  attribute C_RST_PRIORITY_B : string;
  attribute C_RST_PRIORITY_B of U0 : label is "CE";
  attribute C_SIM_COLLISION_CHECK : string;
  attribute C_SIM_COLLISION_CHECK of U0 : label is "ALL";
  attribute C_USE_BRAM_BLOCK : integer;
  attribute C_USE_BRAM_BLOCK of U0 : label is 0;
  attribute C_USE_BYTE_WEA : integer;
  attribute C_USE_BYTE_WEA of U0 : label is 0;
  attribute C_USE_BYTE_WEB : integer;
  attribute C_USE_BYTE_WEB of U0 : label is 0;
  attribute C_USE_DEFAULT_DATA : integer;
  attribute C_USE_DEFAULT_DATA of U0 : label is 0;
  attribute C_USE_ECC : integer;
  attribute C_USE_ECC of U0 : label is 0;
  attribute C_USE_SOFTECC : integer;
  attribute C_USE_SOFTECC of U0 : label is 0;
  attribute C_USE_URAM : integer;
  attribute C_USE_URAM of U0 : label is 0;
  attribute C_WEA_WIDTH : integer;
  attribute C_WEA_WIDTH of U0 : label is 1;
  attribute C_WEB_WIDTH : integer;
  attribute C_WEB_WIDTH of U0 : label is 1;
  attribute C_WRITE_DEPTH_A : integer;
  attribute C_WRITE_DEPTH_A of U0 : label is 1024;
  attribute C_WRITE_DEPTH_B : integer;
  attribute C_WRITE_DEPTH_B of U0 : label is 1024;
  attribute C_WRITE_MODE_A : string;
  attribute C_WRITE_MODE_A of U0 : label is "WRITE_FIRST";
  attribute C_WRITE_MODE_B : string;
  attribute C_WRITE_MODE_B of U0 : label is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_A : integer;
  attribute C_WRITE_WIDTH_A of U0 : label is 14;
  attribute C_WRITE_WIDTH_B : integer;
  attribute C_WRITE_WIDTH_B of U0 : label is 14;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of U0 : label is "artix7";
  attribute DONT_TOUCH : boolean;
  attribute DONT_TOUCH of U0 : label is std.standard.true;
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
  attribute x_interface_info : string;
  attribute x_interface_info of U0 : label is "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT";
begin
U0: entity work.invpsi_mem_blk_mem_gen_v8_3_0
     port map (
      addra(9 downto 0) => addra(9 downto 0),
      addrb(9 downto 0) => B"0000000000",
      clka => clka,
      clkb => '0',
      dbiterr => NLW_U0_dbiterr_UNCONNECTED,
      deepsleep => '0',
      dina(13 downto 0) => B"00000000000000",
      dinb(13 downto 0) => B"00000000000000",
      douta(13 downto 0) => douta(13 downto 0),
      doutb(13 downto 0) => NLW_U0_doutb_UNCONNECTED(13 downto 0),
      eccpipece => '0',
      ena => ena,
      enb => '0',
      injectdbiterr => '0',
      injectsbiterr => '0',
      rdaddrecc(9 downto 0) => NLW_U0_rdaddrecc_UNCONNECTED(9 downto 0),
      regcea => '0',
      regceb => '0',
      rsta => '0',
      rsta_busy => NLW_U0_rsta_busy_UNCONNECTED,
      rstb => '0',
      rstb_busy => NLW_U0_rstb_busy_UNCONNECTED,
      s_aclk => '0',
      s_aresetn => '0',
      s_axi_araddr(31 downto 0) => B"00000000000000000000000000000000",
      s_axi_arburst(1 downto 0) => B"00",
      s_axi_arid(3 downto 0) => B"0000",
      s_axi_arlen(7 downto 0) => B"00000000",
      s_axi_arready => NLW_U0_s_axi_arready_UNCONNECTED,
      s_axi_arsize(2 downto 0) => B"000",
      s_axi_arvalid => '0',
      s_axi_awaddr(31 downto 0) => B"00000000000000000000000000000000",
      s_axi_awburst(1 downto 0) => B"00",
      s_axi_awid(3 downto 0) => B"0000",
      s_axi_awlen(7 downto 0) => B"00000000",
      s_axi_awready => NLW_U0_s_axi_awready_UNCONNECTED,
      s_axi_awsize(2 downto 0) => B"000",
      s_axi_awvalid => '0',
      s_axi_bid(3 downto 0) => NLW_U0_s_axi_bid_UNCONNECTED(3 downto 0),
      s_axi_bready => '0',
      s_axi_bresp(1 downto 0) => NLW_U0_s_axi_bresp_UNCONNECTED(1 downto 0),
      s_axi_bvalid => NLW_U0_s_axi_bvalid_UNCONNECTED,
      s_axi_dbiterr => NLW_U0_s_axi_dbiterr_UNCONNECTED,
      s_axi_injectdbiterr => '0',
      s_axi_injectsbiterr => '0',
      s_axi_rdaddrecc(9 downto 0) => NLW_U0_s_axi_rdaddrecc_UNCONNECTED(9 downto 0),
      s_axi_rdata(13 downto 0) => NLW_U0_s_axi_rdata_UNCONNECTED(13 downto 0),
      s_axi_rid(3 downto 0) => NLW_U0_s_axi_rid_UNCONNECTED(3 downto 0),
      s_axi_rlast => NLW_U0_s_axi_rlast_UNCONNECTED,
      s_axi_rready => '0',
      s_axi_rresp(1 downto 0) => NLW_U0_s_axi_rresp_UNCONNECTED(1 downto 0),
      s_axi_rvalid => NLW_U0_s_axi_rvalid_UNCONNECTED,
      s_axi_sbiterr => NLW_U0_s_axi_sbiterr_UNCONNECTED,
      s_axi_wdata(13 downto 0) => B"00000000000000",
      s_axi_wlast => '0',
      s_axi_wready => NLW_U0_s_axi_wready_UNCONNECTED,
      s_axi_wstrb(0) => '0',
      s_axi_wvalid => '0',
      sbiterr => NLW_U0_sbiterr_UNCONNECTED,
      shutdown => '0',
      sleep => '0',
      wea(0) => '0',
      web(0) => '0'
    );
end STRUCTURE;
