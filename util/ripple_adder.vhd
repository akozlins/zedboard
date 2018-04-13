library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;

entity ripple_adder is
    generic (
        W   : integer := 8--;
    );
    port (
        a   :   in  std_logic_vector(W-1 downto 0);
        b   :   in  std_logic_vector(W-1 downto 0);
        ci  :   in  std_logic;
        s   :   out std_logic_vector(W-1 downto 0);
        co  :   out std_logic--;
    );
end entity;

architecture arch of ripple_adder is

    signal c_i : std_logic_vector(W downto 0);

begin

    c_i(0) <= ci;
    co <= c_i(W);

    gen : for i in 0 to W-1 generate
        full_adder_i : component full_adder
        port map (
            a => a(i),
            b => b(i),
            ci => c_i(i),
            s => s(i),
            co => c_i(i+1)
        );
    end generate;

end architecture;
