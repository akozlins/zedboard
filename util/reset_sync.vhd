--
-- Author: Alexandr Kozlinskiy
--

library ieee;
use ieee.std_logic_1164.all;

-- reset synchronizer
entity reset_sync is
    generic (
        -- number of stages
        N : positive := 1--;
    );
    port (
        rstout_n    :   out std_logic;
        arst_n      :   in  std_logic;
        clk         :   in  std_logic--;
    );
end entity;

architecture arch of reset_sync is
begin

    i_ff_sync : entity work.ff_sync
    generic map ( W => 1, N => N )
    port map ( d(0) => '1', q(0) => rstout_n, rst_n => arst_n, clk => clk );

end architecture;