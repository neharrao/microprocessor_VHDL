LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY cpu_top IS
    PORT (
        clk : IN STD_LOGIC; -- cpu clock
        clk50 : IN STD_LOGIC; -- display clock (50 MHz)
        reset : IN STD_LOGIC;
        an : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Anode for 7-segment display 
        CA, CB, CC, CD, CE, CF, CG : OUT STD_LOGIC -- 7-segment display cathodes
    );
END cpu_top;
ARCHITECTURE rtl OF cpu_top IS
    SIGNAL wr_en : STD_LOGIC := '1';
    SIGNAL dr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Data from the memory 
    SIGNAL dw : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Data TO the memory 
    SIGNAL addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Memory address 
    SIGNAL pc_out : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Program counter value
    SIGNAL accu_out : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Accumulator value
    SIGNAL output : STD_LOGIC_VECTOR (15 DOWNTO 0);
    COMPONENT procram
        PORT (
            A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            DI : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            RESET : IN STD_LOGIC;
            WR_EN : IN STD_LOGIC;
            CLK : IN STD_LOGIC;
            DO : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;
    COMPONENT cpu PORT (
        clk :
        reset
        wr_en
        dr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data from the memory
        dw : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data to the memory
        addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Memory address
        pc_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Program counter value 
        accu_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Accumulator value
        );
    END COMPONENT;
    COMPONENT disp4 PORT (
        clk : IN STD_LOGIC;
        disp_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        an : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        CA, CB, CC, CD, CE, CF, CG : OUT STD_LOGIC);
    END COMPONENT;
BEGIN -- rtl
    output <= pc_out & accu_out;
    cpu_inst : cpu
    PORT MAP(
        clk => clk,
        reset => reset, wr_en => wr_en,
        dr => dr,
        dw => dw,
        addr => addr, pc_out => pc_out, accu_out => accu_out
    );
    mem_inst : procram PORT MAP(
        A => addr,
        DI => dw, 
        RESET => reset, 
        WR_EN => wr_en, 
        CLK => clk,
        DO => dr
    );
    display : disp4
    PORT MAP(clk50, output, an, CA, CB, CC, CD, CE, CF, CG);
END rtl;