library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;

entity top is
    Port (
        pl_clk_100  :   in  std_logic;
        pl_leds     :   out std_logic_vector(7 downto 0);
        pl_btns     :   in  std_logic_vector(4 downto 0)--;
    );
end top;

architecture arch of top is

    signal areset_i : std_logic;
    signal cnt_i : unsigned(31 downto 0);

    signal debug : std_logic_vector(31 downto 0);

begin

    debounce_i : debounce
    generic map (
        N => 1,
        C => X"FFFF"--,
    )
    port map (
        input(0 downto 0) => pl_btns(0 downto 0),
        output(0) => areset_i,
        clk => pl_clk_100--,
    );

--    pl_leds <= std_logic_vector(cnt_o(31 downto 24));

    process(pl_clk_100, areset_i)
    begin
    if areset_i = '1' then
        cnt_i <= (others => '0');
    elsif rising_edge(pl_clk_100) then
        cnt_i <= cnt_i + 1;
    end if; -- rising_edge
    end process;

    cpu_i : cpu_v2
    port map (
        dbg_out => debug,
        dbg_in => (others => '0'),
        clk => pl_clk_100,
        areset => areset_i--,
    );

    pl_leds <= debug(31 downto 24);

end arch;
