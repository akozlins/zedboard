--
-- 8b10b encoder
-- https://en.wikipedia.org/wiki/8b/10b_encoding
--
-- Author: Alexandr Kozlinskiy
-- Date: 2018-06-29
--

library ieee;
use ieee.std_logic_1164.all;

entity enc_8b10b is
    port (
        -- input data (K bit & 8 data bits)
        datain  :   in  std_logic_vector(8 downto 0);
        -- input disparity
        dispin  :   in  std_logic;
        -- output 10-bit data (8b10b encoded)
        dataout :   out std_logic_vector(9 downto 0);
        -- output disparity
        dispout :   out std_logic;
        -- error if invalid control symbol
        err     :   out std_logic--;
    );
end entity;

library ieee;
use ieee.numeric_std.all;

architecture arch of enc_8b10b is

    signal K28, Kx7 : std_logic;

    -- 6-bit group --
    -- out : isD+ & 6 bits
    signal G6 : std_logic_vector(6 downto 0);
    signal A7 : std_logic;

    -- 4-bit group --
    -- out : disp & 4 bits
    signal G4 : std_logic_vector(4 downto 0);

    signal a, b, c : std_logic;

begin

    K28 <= datain(8) and work.util.to_std_logic(
        datain(4 downto 0) = "11100"
    );
    Kx7 <= datain(8) and work.util.to_std_logic( datain(7 downto 5) = "111" ) and work.util.to_std_logic(
        datain(4 downto 0) = "10111" or -- K.23.7
        datain(4 downto 0) = "11011" or -- K.27.7
        datain(4 downto 0) = "11101" or -- K.29.7
        datain(4 downto 0) = "11110" or -- K.30.7
        datain(4 downto 0) = "11100" -- K.28.7
    );

    -- out : isD+ & 6 bits
    process(datain, dispin)
    begin
        A7 <= '0';

        case datain(4 downto 0) is
        when "00000" => G6 <= '1' & "111001";
        when "00001" => G6 <= '1' & "101110";
        when "00010" => G6 <= '1' & "101101";
        when "00011" => G6 <= '0' & "100011";
        when "00100" => G6 <= '1' & "101011";
        when "00101" => G6 <= '0' & "100101";
        when "00110" => G6 <= '0' & "100110";
        when "00111" => G6 <= '0' & "000111"; -- D.07
            if ( dispin = '1' ) then G6 <= '0' & "111000"; end if;
        when "01000" => G6 <= '1' & "100111";
        when "01001" => G6 <= '0' & "101001";
        when "01010" => G6 <= '0' & "101010";
        when "01011" => G6 <= '0' & "001011"; -- D.11
            if ( dispin = '1' ) then A7 <= '1'; end if;
        when "01100" => G6 <= '0' & "101100";
        when "01101" => G6 <= '0' & "001101"; -- D.13
            if ( dispin = '1' ) then A7 <= '1'; end if;
        when "01110" => G6 <= '0' & "001110"; -- D.14
            if ( dispin = '1' ) then A7 <= '1'; end if;
        when "01111" => G6 <= '1' & "111010";
        when "10000" => G6 <= '1' & "110110";
        when "10001" => G6 <= '0' & "110001"; -- D.17
            if ( dispin = '0' ) then A7 <= '1'; end if;
        when "10010" => G6 <= '0' & "110010"; -- D.18
            if ( dispin = '0' ) then A7 <= '1'; end if;
        when "10011" => G6 <= '0' & "010011";
        when "10100" => G6 <= '0' & "110100"; -- D.20
            if ( dispin = '0' ) then A7 <= '1'; end if;
        when "10101" => G6 <= '0' & "010101";
        when "10110" => G6 <= '0' & "010110";
        when "10111" => G6 <= '1' & "010111";
        when "11000" => G6 <= '1' & "110011";
        when "11001" => G6 <= '0' & "011001";
        when "11010" => G6 <= '0' & "011010";
        when "11011" => G6 <= '1' & "011011";
        when "11100" => G6 <= '0' & "011100"; -- D.28
            if ( datain(8) = '1' ) then G6 <= '1' & "111100"; end if; -- K.28
        when "11101" => G6 <= '1' & "011101";
        when "11110" => G6 <= '1' & "011110";
        when "11111" => G6 <= '1' & "110101";
        when others => G6 <= (others => 'X');
        end case;
    end process;

    -- out : disp & 4 bits out
    process(dispin, datain, K28, Kx7, G6, A7)
        -- in : disp & 3 bits
        variable G4sel : std_logic_vector(3 downto 0);
    begin
        G4sel := (dispin xor G6(6)) & datain(7 downto 5);

        case G4sel is
        when '0' & "000" => G4 <= '1' & "1101"; -- D.x.0
        when '1' & "000" => G4 <= '0' & "0010"; -- D.x.0
        when '0' & "001" => G4 <= '0' & "1001"; -- D.x.1
            if ( K28 = '1' ) then G4 <= '1' & "0110"; end if; -- K.x.1
        when '1' & "001" => G4 <= '1' & "1001"; -- D.x.1
        when '0' & "010" => G4 <= '0' & "1010"; -- D.x.2
            if ( K28 = '1' ) then G4 <= '1' & "0101"; end if; -- K.x.2
        when '1' & "010" => G4 <= '1' & "1010"; -- D.x.2
        when '0' & "011" => G4 <= '0' & "0011"; -- D.x.3
        when '1' & "011" => G4 <= '1' & "1100"; -- D.x.3
        when '0' & "100" => G4 <= '1' & "1011"; -- D.x.4
        when '1' & "100" => G4 <= '0' & "0100"; -- D.x.4
        when '0' & "101" => G4 <= '0' & "0101"; -- D.x.5
            if ( K28 = '1' ) then G4 <= '1' & "1010"; end if; -- K.x.5
        when '1' & "101" => G4 <= '1' & "0101"; -- D.x.5
        when '0' & "110" => G4 <= '0' & "0110"; -- D.x.6
            if ( K28 = '1' ) then G4 <= '1' & "1001"; end if; -- K.x.6
        when '1' & "110" => G4 <= '1' & "0110"; -- D.x.6
        when '0' & "111" => G4 <= '1' & "0111"; -- D.x.P7
            if ( A7 = '1' or Kx7 = '1' ) then G4 <= '1' & "1110"; end if; -- D.x.A7, K.x.7
        when '1' & "111" => G4 <= '0' & "1000"; -- D.x.P7
            if ( A7 = '1' or Kx7 = '1' ) then G4 <= '0' & "0001"; end if; -- D.x.A7, K.x.7
        when others => G4 <= (others => 'X');
        end case;
    end process;

    dataout(9 downto 6) <= G4(3 downto 0);
    dataout(5 downto 0) <= G6(5 downto 0) when ( dispin = '0' or G6(6) = '0' ) else not G6(5 downto 0);
    dispout <= G4(4);

    err <= datain(8) and not (K28 or Kx7);

end architecture;
