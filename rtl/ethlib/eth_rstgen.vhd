library ieee;
use ieee.std_logic_1164.all;

entity eth_rstgen is
  generic (acthigh : integer := 0);
  port (
    rstin     : in  std_ulogic;
    clk       : in  std_ulogic;
    clklock   : in  std_ulogic;
    rstout    : out std_ulogic;
    rstoutraw : out std_ulogic
  );
end;

architecture rtl of eth_rstgen is
signal r : std_logic_vector(4 downto 0);
signal rst : std_ulogic;

attribute equivalent_register_removal : string;
attribute keep                        : string;

attribute equivalent_register_removal of r : signal is "no";
attribute equivalent_register_removal of rst : signal is "no";

attribute keep of r : signal is "true";
attribute keep of rst : signal is "true";

begin

  rst <= not rstin when acthigh = 1 else rstin;
  rstoutraw <= rst;

  reg1 : process (clk, rst) begin
    if rising_edge(clk) then 
      r <= r(3 downto 0) & clklock; 
      rstout <= r(4) and r(3) and r(2);
    end if;
    if rst = '0' then r <= "00000"; rstout <= '0'; end if;
  end process;

end;

