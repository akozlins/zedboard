library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity adder is
    generic (
        W   : positive := 8--;
    );
    port (
        a   :   in  std_logic_vector(W-1 downto 0);
        b   :   in  std_logic_vector(W-1 downto 0);
        ci  :   in  std_logic;
        s   :   out std_logic_vector(W-1 downto 0);
        co  :   out std_logic--;
    );
end entity;

architecture arch1 of adder is

    signal s_i : std_logic_vector(W downto 0);

begin

    s_i <= ('0' & a) + b + ci;
    s <= s_i(s'range);
    co <= s_i(s_i'left);

end architecture;

architecture arch2 of adder is

    signal s_i : std_logic_vector(W+1 downto 0);

begin

    s_i <= ('0' & a & '1') + ('0' & b & ci);
    s <= s_i(W downto 1);
    co <= s_i(s_i'left);

end architecture;

library UNISIM;
use UNISIM.vcomponents.all;

architecture rtl of adder is

    constant N : positive := (W + 3) / 4;

    signal a_i, b_i, ab_i, s_i : std_logic_vector(4*N-1 downto 0);
    signal co_i : std_logic_vector(4*N-1 downto 0);

    signal ci_i : std_logic_vector(4*N-1 downto 0);
    signal cyinit_i : std_logic_vector(N-1 downto 0);

begin

    a_i(a'range) <= a;
    b_i(b'range) <= b;
    ab_i <= a_i xor b_i;
    s <= s_i(s'range);
    co <= co_i(W-1);

    ci_i <= work.util.shift_left(co_i, 4);
    cyinit_i <= (0 => ci, others => '0');

    gen:
    for i in 0 to N-1 generate
    i_carry4_i : CARRY4
    port map (
        CO => co_i(4*i+3 downto 4*i),
        O => s_i(4*i+3 downto 4*i),
        CI => ci_i(4*i+3),
        CYINIT => cyinit_i(i),
        DI => a_i(4*i+3 downto 4*i),
        S => ab_i(4*i+3 downto 4*i)
    );
    end generate;

end architecture;