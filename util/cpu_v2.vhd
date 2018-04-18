library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity cpu_v2 is
    port (
        dbg_out :   out std_logic_vector(31 downto 0);
        dbg_in  :   in  std_logic_vector(31 downto 0);
        rst_n   :   in  std_logic;
        clk     :   in  std_logic--;
    );
end entity;

architecture arch of cpu_v2 is

    subtype word_t is std_logic_vector(15 downto 0);

    signal ram_addr : word_t;
    signal ram_addr_q : word_t;
    signal ram_rd : word_t;
    signal ram_wd : word_t;
    signal ram_we : std_logic;

    signal pc : word_t;

    -- instruction register
    signal ir : std_logic_vector(3 downto 0);
    -- flags register (carry, overflow, sign, zero)
    signal fr : std_logic_vector(3 downto 0);

    signal regA, regB, regC, regC_q : word_t;
    signal regC_addr, regC_addr_q : std_logic_vector(3 downto 0);
    signal regC_wd : word_t;
    signal regC_we : std_logic;

    type state_t is (
        S_EXEC,
        S_STORE,
        S_LOAD,
        S_LOADI,
        S_RESET--,
    );
    signal state : state_t;

    signal alu_a, alu_b, alu_y : word_t;
    signal alu_v, alu_co, alu_s, alu_z : std_logic;

begin

    i_ram : entity work.ram_v1
    generic map (
        W => 16,
        N => 8,
        INIT_FILE_HEX => "cpu_v2.hex"--,
    )
    port map (
        clk     => clk,
        addr    => ram_addr(7 downto 0),
        rd      => ram_rd,
        wd      => ram_wd,
        we      => ram_we--,
    );

    ram_addr <= ram_addr_q when ( state = S_STORE or state = S_LOAD ) else pc;
    ram_wd <= regC_q;
    ram_we <= '1' when ( state = S_STORE ) else '0';

    i_reg_file : entity work.reg_file_v1
    generic map (
        W => 16,
        N => 4--,
    )
    port map (
        clk     => clk,
        a_addr  => ram_rd(3 downto 0),
        a_rd    => regA,
        b_addr  => ram_rd(7 downto 4),
        b_rd    => regB,
        c_addr  => regC_addr,
        c_rd    => regC,
        c_wd    => regC_wd,
        c_we    => regC_we,
        rst_n   => rst_n--,
    );

    regC_addr <= regC_addr_q when ( state = S_LOAD or state = S_LOADI ) else
                 ram_rd(11 downto 8);
    regC_wd <= ram_rd when ( state = S_LOAD or state = S_LOADI ) else
               alu_y  when ( state = S_EXEC and ir(ir'left) = '0' ) else
               X"CCCC";
    regC_we <= '1' when ( state = S_LOAD or state = S_LOADI ) else
               '1' when ( state = S_EXEC and ir(ir'left) = '0' ) else
               '0';

    i_alu : entity work.alu_v2
    generic map (
        W => 16--,
    )
    port map (
        a   => alu_a,
        b   => alu_b,
        ci  => fr(3),
        op  => ir(2 downto 0),
        y   => alu_y,
        z   => alu_z,
        s   => alu_s,
        v   => alu_v,
        co  => alu_co--,
    );

    alu_a <= regA;
    alu_b <= regB;

    ir <= ram_rd(15 downto 12);

    process(clk, rst_n)
    begin
    if ( rst_n = '0' ) then
        state <= S_RESET;
    elsif rising_edge(clk) then
        state <= S_EXEC;
        ram_addr_q <= regB + regA;
        regC_addr_q <= regC_addr;
        regC_q <= regC;

        case state is
        when S_EXEC =>
            pc <= pc + 1;

            case ir is
            when X"F" => -- ST : *(regB + regA) = regC
                state <= S_STORE;
            when X"E" => -- LD : regC = *(regB + regA)
                state <= S_LOAD;
            when X"D" => -- LDI : regC = *(pc + 1)
                state <= S_LOADI;
            when X"C" => -- DBG
                dbg_out <= regB & regA;
            when X"A" => -- JMP : pc += rdata(7 downto 0)
                if ( (regC_addr and fr) = regC_addr ) then
                    pc <= pc + ((7 downto 0 => ram_rd(7)) & ram_rd(7 downto 0));
                end if;
            when others =>
                null;
            end case;

            if ( ir(ir'left) = '0' ) then
                fr(0) <= alu_z;
                fr(1) <= alu_s;
                fr(2) <= alu_v;
                fr(3) <= alu_co;
            end if;

        when S_LOADI =>
            pc <= pc + 1;

        when S_RESET =>
            pc <= (others => '0');

        when others =>
            null;
        end case;

    end if; -- rising_edge
    end process;

end architecture;
