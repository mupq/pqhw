-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
-- Date        : Mon Apr 03 10:15:11 2017
-- Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/psi_mem/psi_mem_sim_netlist.vhdl
-- Design      : psi_mem
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity psi_mem_blk_mem_gen_prim_wrapper_init is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_prim_wrapper_init : entity is "blk_mem_gen_prim_wrapper_init";
end psi_mem_blk_mem_gen_prim_wrapper_init;

architecture STRUCTURE of psi_mem_blk_mem_gen_prim_wrapper_init is
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
      INIT_00 => X"2D64187B093C53131C254C1044511B563F5B2C68055255681F4B3767543A0001",
      INIT_01 => X"0A47390F327046012D44271F3C122C604A49484348625B4E584C4B40144F3A2C",
      INIT_02 => X"4E0B575B442025451D0047424A46256E5553275E17464700596B5846566F120F",
      INIT_03 => X"5A2B3B7E51445E754A31531E3E625668123E48163961486E58193E215F301813",
      INIT_04 => X"4F58381D195416411929055946280F5D0D200B14024E127A330624182224096C",
      INIT_05 => X"316A396741254A56345B01111B031C353E7A4C0D5D1E1A364306522237464313",
      INIT_06 => X"4C240A6544013F303904362E2136527804202D1F02534C5D0009077E03604967",
      INIT_07 => X"3603161501023D7F125C226446211E6D383611150076132C2D07063B425D5848",
      INIT_08 => X"576C162B4C5027142C424921257D02621D4242080605030657563814033A1261",
      INIT_09 => X"5B60271B1C784B0B3F52246A01720C015461424E4807001B38250C60396C0779",
      INIT_0A => X"4D0B306A4E764B7B172B2F061C3E4C7C5916423D533A39113E4527602713076A",
      INIT_0B => X"0E780A625C4E3E10124D353D4001036D1930564A291D09103B5C5C6D105F5758",
      INIT_0C => X"52100C7F3B53546F1510292B264A1C3422555F7E184D5E61394A5F101E4B1076",
      INIT_0D => X"0B4C39624A25284B14551F554E00384F2214107E3D434962463A1F590D191A24",
      INIT_0E => X"40314E38493D570018722A1F4F330C5E1B36295416314D3F486840774B034652",
      INIT_0F => X"035C1B4B26291F110C084E7F0324344A01731748051F48494741373A45394D22",
      INIT_10 => X"230D467F4F7829792A07516A025E0B68314B535254304C3D0B4B2E1B096F0031",
      INIT_11 => X"25120E425C57460E166D025B4254504A0553012E0D1D4840145F331A32154A4F",
      INIT_12 => X"5174493F4F7E0F224C722F7E04401E7B44381A6A015A165C514E123920131756",
      INIT_13 => X"0A0D3B003A5B2A355C3C2E1403221D3C295550122D741169011C4A3241001F17",
      INIT_14 => X"4030427109072E66584D570755050245491A424F1F6D4051050C2D062F530227",
      INIT_15 => X"2931301A1E740A50565137414C0630170C3A5057380F2E4915045E59214A1A01",
      INIT_16 => X"593E3050440F21100A27473305451F4E101E085821620F260339071A575F4012",
      INIT_17 => X"36781D7A31623D3035134813522E474E4C3A487D2D1653635F411C48052B131B",
      INIT_18 => X"500026300A295E41450C252C245A27410613446707723525474A3F3849193708",
      INIT_19 => X"4F320117496A1E752E124C385C520C2B18665F4D4A330A2B4579305A320F0525",
      INIT_1A => X"207458321A6E49655730010E33501B153109590C38700F2458161B4C5E105F47",
      INIT_1B => X"3B712F3D193F43712F341C1240115C5C5B24117E03783F0C2D7E252E3427482C",
      INIT_1C => X"57673C492A451E144B06092642172F6642345E6E35312261250D34603A4C3D0E",
      INIT_1D => X"58072E2557704447343B0F354D5956032943401626343E1D5B77107946432757",
      INIT_1E => X"52410310300826544346355A321B2F785F49187F285634680F430D261B6D050E",
      INIT_1F => X"561B074D354655320F021E27406350105D03023C406D03542F4D1C7E2A46295B",
      INIT_20 => X"20394E5C4224057F0601346B003201583D791955273E18521D0B064D0F100007",
      INIT_21 => X"49710F65440D0A021E595257247A191D297A1B501D29411C2C0E303B30281830",
      INIT_22 => X"424825775D5C46610A7E144929654900173F56104469107B34672B6420031E68",
      INIT_23 => X"3827236E5A57582D2852064C372A1F522131191514231D7D292933635B4A4904",
      INIT_24 => X"4D630947534B3D46511E276F0C130E0A5C604E0C1222245545273D262F7A4474",
      INIT_25 => X"3C63144D487F2A55507A07775D140671385234564C4C587955265F6904665601",
      INIT_26 => X"35774B435C033B4C0F185C3F297804421D601C5612453906003F37721A20244C",
      INIT_27 => X"5A123B12070E31752303333A0B6217790A761812063A27331B2E2D1D53072B72",
      INIT_28 => X"266E3C2C382B520A174B20624969132E0E4C4E342A23152A2554090818162326",
      INIT_29 => X"421A523B0A462D483D3A41640D1E54071121521E182C013D097F59201470374F",
      INIT_2A => X"3B48356348353358432C292707303A5F3014512708100F73355F561E52033666",
      INIT_2B => X"08474B2E481C326C221A562840031A7B514F1E0000483F702200497515182562",
      INIT_2C => X"5E6B5A7921411203336F012A4E04066A32515F6C4C1A57211302596A160B1639",
      INIT_2D => X"5114142A277E5C0B30521D51417B0C252F0A16712E5124290D111D6D5C2F577B",
      INIT_2E => X"425345032226207A4E1D07564B6059125F7903493C563E341D53463D2D100E39",
      INIT_2F => X"1A04010B4C1D197554384874167C50030D25447724591B7A14420412060A3C69",
      INIT_30 => X"355910744F43054C062E5C61131252583B0A09380E4A3726510D233A45090257",
      INIT_31 => X"437C054D485B0A5D3F7A127D52485401274509425C4B1B3B311846333F102A24",
      INIT_32 => X"5D2722344F6D0A6D3A192F6F1F40185B5F045B650B763F035B1D210E21034559",
      INIT_33 => X"465B1C7C1A790870471E2309166E0E220350507921291C5E08442859467C1A1F",
      INIT_34 => X"424C54133F3127472C15212B131D1163203152251E79443323541B272D421011",
      INIT_35 => X"01543133182A4A301E3104433425311E5716545C0865257C331B56692B045606",
      INIT_36 => X"322C342D5C65276E4811136026631D2011513C682C2C0B09180F32362613407A",
      INIT_37 => X"004411543C2B2D4C54021900003C151D37111E661C170A2F5C410776252D263C",
      INIT_38 => X"4F7B4C4E481F5541034F4532407454452B05014C371E550015013C04202A0134",
      INIT_39 => X"4B59082124611831227B37034838562D4D495D152860482D094A34733E662503",
      INIT_3A => X"262A2A585C01243E234A0762492D5E12373C2F4E0E0C0A7B29140112526A5C6B",
      INIT_3B => X"23132C2852385B132B69047C4073487E3E761D711B483950216F45404E0E1A2F",
      INIT_3C => X"264B277B0960130A2D25410A4F1D2E475068577C555433254359511D1A102B5E",
      INIT_3D => X"282B2400270A5F6D4F1A0B723F6A1A0F025241164C6A3347433B164E0D50555F",
      INIT_3E => X"0141157030354E4A586657733F3A2F455C794E785C5851550C545D0A02792362",
      INIT_3F => X"1B37351B56671558090D140F4531506B4B0F11244577194C2D180A700967037A",
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
entity psi_mem_blk_mem_gen_prim_width is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_prim_width : entity is "blk_mem_gen_prim_width";
end psi_mem_blk_mem_gen_prim_width;

architecture STRUCTURE of psi_mem_blk_mem_gen_prim_width is
begin
\prim_init.ram\: entity work.psi_mem_blk_mem_gen_prim_wrapper_init
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
entity psi_mem_blk_mem_gen_generic_cstr is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_generic_cstr : entity is "blk_mem_gen_generic_cstr";
end psi_mem_blk_mem_gen_generic_cstr;

architecture STRUCTURE of psi_mem_blk_mem_gen_generic_cstr is
begin
\ramloop[0].ram.r\: entity work.psi_mem_blk_mem_gen_prim_width
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
entity psi_mem_blk_mem_gen_top is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_top : entity is "blk_mem_gen_top";
end psi_mem_blk_mem_gen_top;

architecture STRUCTURE of psi_mem_blk_mem_gen_top is
begin
\valid.cstr\: entity work.psi_mem_blk_mem_gen_generic_cstr
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
entity psi_mem_blk_mem_gen_v8_3_0_synth is
  port (
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 );
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_v8_3_0_synth : entity is "blk_mem_gen_v8_3_0_synth";
end psi_mem_blk_mem_gen_v8_3_0_synth;

architecture STRUCTURE of psi_mem_blk_mem_gen_v8_3_0_synth is
begin
\gnativebmg.native_blk_mem_gen\: entity work.psi_mem_blk_mem_gen_top
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
entity psi_mem_blk_mem_gen_v8_3_0 is
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
  attribute C_ADDRA_WIDTH of psi_mem_blk_mem_gen_v8_3_0 : entity is 10;
  attribute C_ADDRB_WIDTH : integer;
  attribute C_ADDRB_WIDTH of psi_mem_blk_mem_gen_v8_3_0 : entity is 10;
  attribute C_ALGORITHM : integer;
  attribute C_ALGORITHM of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_AXI_ID_WIDTH : integer;
  attribute C_AXI_ID_WIDTH of psi_mem_blk_mem_gen_v8_3_0 : entity is 4;
  attribute C_AXI_SLAVE_TYPE : integer;
  attribute C_AXI_SLAVE_TYPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_AXI_TYPE : integer;
  attribute C_AXI_TYPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_BYTE_SIZE : integer;
  attribute C_BYTE_SIZE of psi_mem_blk_mem_gen_v8_3_0 : entity is 9;
  attribute C_COMMON_CLK : integer;
  attribute C_COMMON_CLK of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_COUNT_18K_BRAM : string;
  attribute C_COUNT_18K_BRAM of psi_mem_blk_mem_gen_v8_3_0 : entity is "1";
  attribute C_COUNT_36K_BRAM : string;
  attribute C_COUNT_36K_BRAM of psi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_CTRL_ECC_ALGO : string;
  attribute C_CTRL_ECC_ALGO of psi_mem_blk_mem_gen_v8_3_0 : entity is "NONE";
  attribute C_DEFAULT_DATA : string;
  attribute C_DEFAULT_DATA of psi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_DISABLE_WARN_BHV_COLL : integer;
  attribute C_DISABLE_WARN_BHV_COLL of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_DISABLE_WARN_BHV_RANGE : integer;
  attribute C_DISABLE_WARN_BHV_RANGE of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_ELABORATION_DIR : string;
  attribute C_ELABORATION_DIR of psi_mem_blk_mem_gen_v8_3_0 : entity is "./";
  attribute C_ENABLE_32BIT_ADDRESS : integer;
  attribute C_ENABLE_32BIT_ADDRESS of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_DEEPSLEEP_PIN : integer;
  attribute C_EN_DEEPSLEEP_PIN of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_ECC_PIPE : integer;
  attribute C_EN_ECC_PIPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_RDADDRA_CHG : integer;
  attribute C_EN_RDADDRA_CHG of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_RDADDRB_CHG : integer;
  attribute C_EN_RDADDRB_CHG of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SAFETY_CKT : integer;
  attribute C_EN_SAFETY_CKT of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SHUTDOWN_PIN : integer;
  attribute C_EN_SHUTDOWN_PIN of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EN_SLEEP_PIN : integer;
  attribute C_EN_SLEEP_PIN of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_EST_POWER_SUMMARY : string;
  attribute C_EST_POWER_SUMMARY of psi_mem_blk_mem_gen_v8_3_0 : entity is "Estimated Power for IP     :     1.3132 mW";
  attribute C_FAMILY : string;
  attribute C_FAMILY of psi_mem_blk_mem_gen_v8_3_0 : entity is "artix7";
  attribute C_HAS_AXI_ID : integer;
  attribute C_HAS_AXI_ID of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_ENA : integer;
  attribute C_HAS_ENA of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_HAS_ENB : integer;
  attribute C_HAS_ENB of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_INJECTERR : integer;
  attribute C_HAS_INJECTERR of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MEM_OUTPUT_REGS_A : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_HAS_MEM_OUTPUT_REGS_B : integer;
  attribute C_HAS_MEM_OUTPUT_REGS_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_A : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_MUX_OUTPUT_REGS_B : integer;
  attribute C_HAS_MUX_OUTPUT_REGS_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_REGCEA : integer;
  attribute C_HAS_REGCEA of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_REGCEB : integer;
  attribute C_HAS_REGCEB of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_RSTA : integer;
  attribute C_HAS_RSTA of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_RSTB : integer;
  attribute C_HAS_RSTB of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_SOFTECC_INPUT_REGS_A : integer;
  attribute C_HAS_SOFTECC_INPUT_REGS_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B : integer;
  attribute C_HAS_SOFTECC_OUTPUT_REGS_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_INITA_VAL : string;
  attribute C_INITA_VAL of psi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_INITB_VAL : string;
  attribute C_INITB_VAL of psi_mem_blk_mem_gen_v8_3_0 : entity is "0";
  attribute C_INIT_FILE : string;
  attribute C_INIT_FILE of psi_mem_blk_mem_gen_v8_3_0 : entity is "psi_mem.mem";
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of psi_mem_blk_mem_gen_v8_3_0 : entity is "psi_mem.mif";
  attribute C_INTERFACE_TYPE : integer;
  attribute C_INTERFACE_TYPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_LOAD_INIT_FILE : integer;
  attribute C_LOAD_INIT_FILE of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_MEM_TYPE : integer;
  attribute C_MEM_TYPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 3;
  attribute C_MUX_PIPELINE_STAGES : integer;
  attribute C_MUX_PIPELINE_STAGES of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_PRIM_TYPE : integer;
  attribute C_PRIM_TYPE of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_READ_DEPTH_A : integer;
  attribute C_READ_DEPTH_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_READ_DEPTH_B : integer;
  attribute C_READ_DEPTH_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_READ_WIDTH_A : integer;
  attribute C_READ_WIDTH_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_READ_WIDTH_B : integer;
  attribute C_READ_WIDTH_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_RSTRAM_A : integer;
  attribute C_RSTRAM_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_RSTRAM_B : integer;
  attribute C_RSTRAM_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_RST_PRIORITY_A : string;
  attribute C_RST_PRIORITY_A of psi_mem_blk_mem_gen_v8_3_0 : entity is "CE";
  attribute C_RST_PRIORITY_B : string;
  attribute C_RST_PRIORITY_B of psi_mem_blk_mem_gen_v8_3_0 : entity is "CE";
  attribute C_SIM_COLLISION_CHECK : string;
  attribute C_SIM_COLLISION_CHECK of psi_mem_blk_mem_gen_v8_3_0 : entity is "ALL";
  attribute C_USE_BRAM_BLOCK : integer;
  attribute C_USE_BRAM_BLOCK of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_BYTE_WEA : integer;
  attribute C_USE_BYTE_WEA of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_BYTE_WEB : integer;
  attribute C_USE_BYTE_WEB of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_DEFAULT_DATA : integer;
  attribute C_USE_DEFAULT_DATA of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_ECC : integer;
  attribute C_USE_ECC of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_SOFTECC : integer;
  attribute C_USE_SOFTECC of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_USE_URAM : integer;
  attribute C_USE_URAM of psi_mem_blk_mem_gen_v8_3_0 : entity is 0;
  attribute C_WEA_WIDTH : integer;
  attribute C_WEA_WIDTH of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_WEB_WIDTH : integer;
  attribute C_WEB_WIDTH of psi_mem_blk_mem_gen_v8_3_0 : entity is 1;
  attribute C_WRITE_DEPTH_A : integer;
  attribute C_WRITE_DEPTH_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_WRITE_DEPTH_B : integer;
  attribute C_WRITE_DEPTH_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 1024;
  attribute C_WRITE_MODE_A : string;
  attribute C_WRITE_MODE_A of psi_mem_blk_mem_gen_v8_3_0 : entity is "WRITE_FIRST";
  attribute C_WRITE_MODE_B : string;
  attribute C_WRITE_MODE_B of psi_mem_blk_mem_gen_v8_3_0 : entity is "WRITE_FIRST";
  attribute C_WRITE_WIDTH_A : integer;
  attribute C_WRITE_WIDTH_A of psi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_WRITE_WIDTH_B : integer;
  attribute C_WRITE_WIDTH_B of psi_mem_blk_mem_gen_v8_3_0 : entity is 14;
  attribute C_XDEVICEFAMILY : string;
  attribute C_XDEVICEFAMILY of psi_mem_blk_mem_gen_v8_3_0 : entity is "artix7";
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of psi_mem_blk_mem_gen_v8_3_0 : entity is "blk_mem_gen_v8_3_0";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of psi_mem_blk_mem_gen_v8_3_0 : entity is "yes";
end psi_mem_blk_mem_gen_v8_3_0;

architecture STRUCTURE of psi_mem_blk_mem_gen_v8_3_0 is
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
inst_blk_mem_gen: entity work.psi_mem_blk_mem_gen_v8_3_0_synth
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
entity psi_mem is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 13 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of psi_mem : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of psi_mem : entity is "psi_mem,blk_mem_gen_v8_3_0,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of psi_mem : entity is "psi_mem,blk_mem_gen_v8_3_0,{x_ipProduct=Vivado 2015.3,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=blk_mem_gen,x_ipVersion=8.3,x_ipCoreRevision=0,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_FAMILY=artix7,C_XDEVICEFAMILY=artix7,C_ELABORATION_DIR=./,C_INTERFACE_TYPE=0,C_AXI_TYPE=1,C_AXI_SLAVE_TYPE=0,C_USE_BRAM_BLOCK=0,C_ENABLE_32BIT_ADDRESS=0,C_CTRL_ECC_ALGO=NONE,C_HAS_AXI_ID=0,C_AXI_ID_WIDTH=4,C_MEM_TYPE=3,C_BYTE_SIZE=9,C_ALGORITHM=1,C_PRIM_TYPE=1,C_LOAD_INIT_FILE=1,C_INIT_FILE_NAME=psi_mem.mif,C_INIT_FILE=psi_mem.mem,C_USE_DEFAULT_DATA=0,C_DEFAULT_DATA=0,C_HAS_RSTA=0,C_RST_PRIORITY_A=CE,C_RSTRAM_A=0,C_INITA_VAL=0,C_HAS_ENA=1,C_HAS_REGCEA=0,C_USE_BYTE_WEA=0,C_WEA_WIDTH=1,C_WRITE_MODE_A=WRITE_FIRST,C_WRITE_WIDTH_A=14,C_READ_WIDTH_A=14,C_WRITE_DEPTH_A=1024,C_READ_DEPTH_A=1024,C_ADDRA_WIDTH=10,C_HAS_RSTB=0,C_RST_PRIORITY_B=CE,C_RSTRAM_B=0,C_INITB_VAL=0,C_HAS_ENB=0,C_HAS_REGCEB=0,C_USE_BYTE_WEB=0,C_WEB_WIDTH=1,C_WRITE_MODE_B=WRITE_FIRST,C_WRITE_WIDTH_B=14,C_READ_WIDTH_B=14,C_WRITE_DEPTH_B=1024,C_READ_DEPTH_B=1024,C_ADDRB_WIDTH=10,C_HAS_MEM_OUTPUT_REGS_A=1,C_HAS_MEM_OUTPUT_REGS_B=0,C_HAS_MUX_OUTPUT_REGS_A=0,C_HAS_MUX_OUTPUT_REGS_B=0,C_MUX_PIPELINE_STAGES=0,C_HAS_SOFTECC_INPUT_REGS_A=0,C_HAS_SOFTECC_OUTPUT_REGS_B=0,C_USE_SOFTECC=0,C_USE_ECC=0,C_EN_ECC_PIPE=0,C_HAS_INJECTERR=0,C_SIM_COLLISION_CHECK=ALL,C_COMMON_CLK=0,C_DISABLE_WARN_BHV_COLL=0,C_EN_SLEEP_PIN=0,C_USE_URAM=0,C_EN_RDADDRA_CHG=0,C_EN_RDADDRB_CHG=0,C_EN_DEEPSLEEP_PIN=0,C_EN_SHUTDOWN_PIN=0,C_EN_SAFETY_CKT=0,C_DISABLE_WARN_BHV_RANGE=0,C_COUNT_36K_BRAM=0,C_COUNT_18K_BRAM=1,C_EST_POWER_SUMMARY=Estimated Power for IP     _     1.3132 mW}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of psi_mem : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of psi_mem : entity is "blk_mem_gen_v8_3_0,Vivado 2015.3";
end psi_mem;

architecture STRUCTURE of psi_mem is
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
  attribute C_INIT_FILE of U0 : label is "psi_mem.mem";
  attribute C_INIT_FILE_NAME : string;
  attribute C_INIT_FILE_NAME of U0 : label is "psi_mem.mif";
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
U0: entity work.psi_mem_blk_mem_gen_v8_3_0
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
