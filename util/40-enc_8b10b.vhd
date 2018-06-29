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
        err     :   out std_logic--;
    );
end entity;

architecture arch of enc_8b10b is

    signal K : std_logic;

    -- 6-bit group (A7 & RD bit & 5b/6b part)
    signal g6 : std_logic_vector(7 downto 0);
    signal g6sel : std_logic_vector(5 downto 0);
    -- 4-bit group (RD bit & 3b/4b part)
    signal g4 : std_logic_vector(4 downto 0);
    signal g4sel : std_logic_vector(3 downto 0);

begin

    -- https://en.wikipedia.org/wiki/8b/10b_encoding

    -- control (K) symbol
    K <= datain(8) and work.util.to_std_logic(
        datain(7 downto 0) = "111" & "10111" or -- K.23.7
        datain(7 downto 0) = "111" & "11011" or -- K.27.7
        datain(7 downto 0) = "111" & "11101" or -- K.29.7
        datain(7 downto 0) = "111" & "11110" or -- K.30.7
        datain(4 downto 0) = "11100" -- K.28
    );

    -- error if invalid K
    err <= datain(8) and not K;

    g6sel <= dispin & datain(4 downto 0);
    with g6sel select g6 <=
        '0' & '1' & "111001" when '0' & "00000",
        '0' & '0' & "000110" when '1' & "00000",
        '0' & '1' & "101110" when '0' & "00001",
        '0' & '0' & "010001" when '1' & "00001",
        '0' & '0' & "101101" when '0' & "00010",
        '0' & '1' & "010010" when '1' & "00010",
        '0' & '0' & "100011" when '0' & "00011",
        '0' & '1' & "100011" when '1' & "00011",
        '0' & '0' & "101011" when '0' & "00100",
        '0' & '1' & "010100" when '1' & "00100",
        '0' & '0' & "100101" when '0' & "00101",
        '0' & '1' & "100101" when '1' & "00101",
        '0' & '0' & "100110" when '0' & "00110",
        '0' & '1' & "100110" when '1' & "00110",
        '0' & '1' & "000111" when '0' & "00111",
        '0' & '0' & "111000" when '1' & "00111",
        '0' & '1' & "100111" when '0' & "01000",
        '0' & '0' & "011000" when '1' & "01000",
        '0' & '0' & "101001" when '0' & "01001",
        '0' & '1' & "101001" when '1' & "01001",
        '0' & '0' & "101010" when '0' & "01010",
        '0' & '1' & "101010" when '1' & "01010",
        '0' & '0' & "001011" when '0' & "01011",
        '1' & '1' & "001011" when '1' & "01011", -- D.11.A7
        '0' & '0' & "101100" when '0' & "01100",
        '0' & '1' & "101100" when '1' & "01100",
        '0' & '0' & "001101" when '0' & "01101",
        '1' & '1' & "001101" when '1' & "01101", -- D.13.A7
        '0' & '0' & "001110" when '0' & "01110",
        '1' & '1' & "001110" when '1' & "01110", -- D.14.A7
        '0' & '1' & "111010" when '0' & "01111",
        '0' & '0' & "000101" when '1' & "01111",
        '0' & '1' & "110110" when '0' & "10000",
        '0' & '0' & "001001" when '1' & "10000",
        '1' & '0' & "110001" when '0' & "10001", -- D.17.A7
        '0' & '1' & "110001" when '1' & "10001",
        '1' & '0' & "110010" when '0' & "10010", -- D.18.A7
        '0' & '1' & "110010" when '1' & "10010",
        '0' & '0' & "010011" when '0' & "10011",
        '0' & '1' & "010011" when '1' & "10011",
        '1' & '0' & "110100" when '0' & "10100", -- D.20.A7
        '0' & '1' & "110100" when '1' & "10100",
        '0' & '0' & "010101" when '0' & "10101",
        '0' & '1' & "010101" when '1' & "10101",
        '0' & '0' & "010110" when '0' & "10110",
        '0' & '1' & "010110" when '1' & "10110",
        '0' & '1' & "010111" when '0' & "10111",
        '0' & '0' & "101000" when '1' & "10111",
        '0' & '1' & "110011" when '0' & "11000",
        '0' & '0' & "001100" when '1' & "11000",
        '0' & '0' & "011001" when '0' & "11001",
        '0' & '1' & "011001" when '1' & "11001",
        '0' & '0' & "011010" when '0' & "11010",
        '0' & '1' & "011010" when '1' & "11010",
        '0' & '1' & "011011" when '0' & "11011",
        '0' & '0' & "100100" when '1' & "11011",
        '0' & '1' & "111100" when '0' & "11100", -- K.28
        '0' & '0' & "000011" when '1' & "11100", -- K.28
        '0' & '1' & "011101" when '0' & "11101",
        '0' & '0' & "100010" when '1' & "11101",
        '0' & '1' & "011110" when '0' & "11110",
        '0' & '0' & "100001" when '1' & "11110",
        '0' & '1' & "110101" when '0' & "11111",
        '0' & '0' & "001010" when '1' & "11111",
        '0' & '0' & "XXXXXX" when others;

    g4sel(2 downto 0) <= datain(7 downto 5);
    g4sel(3) <= dispin when ( K = '0' and datain(4 downto 0) = "11100" ) else -- D.28
                g6(6);
    with g4sel select g4 <=
        '1' & "1101" when '0' & "000",
        '0' & "0010" when '1' & "000",
        '0' & "1001" when '0' & "001",
        '1' & "1001" when '1' & "001",
        '0' & "1010" when '0' & "010",
        '1' & "1010" when '1' & "010",
        '1' & "0011" when '0' & "011",
        '0' & "1100" when '1' & "011",
        '1' & "1011" when '0' & "100",
        '0' & "0100" when '1' & "100",
        '0' & "0101" when '0' & "101",
        '1' & "0101" when '1' & "101",
        '0' & "0110" when '0' & "110",
        '1' & "0110" when '1' & "110",
        '1' & "1110" when '0' & "111", -- D.x.A7, K.x.7
        '0' & "0001" when '1' & "111", -- D.x.A7, K.x.7
        '0' & "XXXX" when others;

    dataout(5 downto 0) <= "011100" when ( K = '0' and datain(4 downto 0) = "11100" ) else -- D.28
                           g6(5 downto 0);
    -- D.x.A7 : RD-/0001, RD+/1110
    -- D.x.P7 : RD-/1000, RD+/0111
    dataout(9 downto 6) <= g4(0) & g4(2) & g4(1) & g4(3) when ( K = '0' and datain(7 downto 5) = "111" and g6(7) = '0' ) else -- D.x.P7
                           g4(3) & g4(2) & g4(1) & g4(0);
    dispout <= g4(4);

end architecture;
