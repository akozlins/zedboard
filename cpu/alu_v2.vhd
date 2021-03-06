--
-- Author: Alexandr Kozlinskiy
--

library ieee;
use ieee.std_logic_1164.all;

entity alu_v2 is
generic (
    W   : positive := 8--;
);
port (
    -- operands
    a   :   in  std_logic_vector(W-1 downto 0);
    b   :   in  std_logic_vector(W-1 downto 0);
    -- carry in
    ci  :   in  std_logic;
    -- operation
    op  :   in  std_logic_vector(2 downto 0);
    -- output
    y   :   out std_logic_vector(W-1 downto 0);
    -- zero
    z   :   out std_logic;
    -- sign
    s   :   out std_logic;
    -- overflow
    v   :   out std_logic;
    -- carry out
    co  :   out std_logic--;
);
end entity;

architecture arch of alu_v2 is

    signal ci_i : std_logic;
    signal a_i, b_i, s_i : std_logic_vector(W-1 downto 0);
    signal y_i : std_logic_vector(W-1 downto 0);

begin

    e_adder : entity work.adder
    generic map (
        W => W--,
    )
    port map (
        i_a => a_i,
        i_b => b_i,
        i_c => ci_i,
        o_s => s_i,
        o_c => co--,
    );

    process(op, a, b, ci, s_i)
    begin
        a_i <= a;
        b_i <= b;
        ci_i <= ci;
        y_i <= s_i;

        case op is
        when "000" =>
            -- add
            ci_i <= '0';
        when "001" =>
            -- adc
        when "010" =>
            -- sub
            a_i <= not a;
            ci_i <= '1';
        when "011" =>
            -- sbb
            a_i <= not a;
            ci_i <= not ci;
        when "100" =>
            y_i <= a and b;
        when "101" =>
            y_i <= a or b;
        when "110" =>
            y_i <= a xor b;
        when "111" =>
            y_i <= not (a xor b);
        when others =>
            null;
        end case;
    end process;

    y <= y_i;
    z <= not work.util.or_reduce(y_i);
    s <= y_i(y_i'left);
--    v <= (a(a'left) and b(b'left) and not y_i(y_i'left)) or
--         (not a(a'left) and not b(b'left) and y_i(y_i'left));
    v <= (a(a'left) xnor b(b'left)) and (b(b'left) xor y_i(y_i'left));

end architecture;
