library ieee;
use ieee.std_logic_1164.all;

library techmap;
use techmap.gencomp.all;
use techmap.types_mem.all;

library commonlib;
use commonlib.types_common.all;

--! AMBA system bus specific library
library ambalib;
--! AXI4 configuration constants.
use ambalib.types_amba4.all;

entity axi4_rom is
  generic (
    memtech  : integer := inferred;
    async_reset : boolean := false;
    xaddr    : integer := 0;
    xmask    : integer := 16#fffff#;
    sim_hexfile : string
  );
  port (
    clk  : in std_logic;
    nrst : in std_logic;
    cfg  : out axi4_slave_config_type;
    i    : in  axi4_slave_in_type;
    o    : out axi4_slave_out_type
  );
end; 
 
architecture arch_axi4_rom of axi4_rom is

  -- To avoid warning 'literal negative value' use -1048576 instead of 16#fff00000#
  constant size_4kbytes : integer := -(xmask - 1048576); 
  constant abits : integer := 12 + log2(size_4kbytes);

  constant xconfig : axi4_slave_config_type := (
     descrtype => PNP_CFG_TYPE_SLAVE,
     descrsize => PNP_CFG_SLAVE_DESCR_BYTES,
     irq_idx => conv_std_logic_vector(0, 8),
     xaddr => conv_std_logic_vector(xaddr, CFG_SYSBUS_CFG_ADDR_BITS),
     xmask => conv_std_logic_vector(xmask, CFG_SYSBUS_CFG_ADDR_BITS),
     vid => VENDOR_GNSSSENSOR,
     did => GNSSSENSOR_ROM
  );

  signal raddr : global_addr_array_type;
  signal rdata : std_logic_vector(CFG_SYSBUS_DATA_BITS-1 downto 0);

begin
  cfg  <= xconfig;

  axi0 :  axi4_slave generic map (
    async_reset => async_reset
  ) port map (
    i_clk => clk,
    i_nrst => nrst,
    i_xcfg => xconfig, 
    i_xslvi => i,
    o_xslvo => o,
    i_ready => '1',
    i_rdata => rdata,
    o_re => open,
    o_r32 => open,
    o_radr => raddr,
    o_wadr => open,
    o_we => open,
    o_wstrb => open,
    o_wdata => open
  );

  tech0 : Rom_tech generic map (
    memtech => memtech,
    abits => abits,
    sim_hexfile => sim_hexfile
  ) port map (
    clk => clk,
    address => raddr,
    data => rdata
  );

end;