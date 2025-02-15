LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY cpu_top_tb IS
END cpu_top_tb;

ARCHITECTURE behavior OF cpu_top_tb IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT cpu_top
        PORT (
            clk : IN STD_LOGIC;
            clk50 : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            an : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            CA : OUT STD_LOGIC;
            CB : OUT STD_LOGIC;
            CC : OUT STD_LOGIC;
            CD : OUT STD_LOGIC;
            CE : OUT STD_LOGIC;
            CF : OUT STD_LOGIC;
            CG : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL clk50 : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';

    -- Outputs
    SIGNAL an : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL CA : STD_LOGIC;
    SIGNAL CB : STD_LOGIC;
    SIGNAL CC : STD_LOGIC;
    SIGNAL CD : STD_LOGIC;
    SIGNAL CE : STD_LOGIC;
    SIGNAL CF : STD_LOGIC;
    SIGNAL CG : STD_LOGIC;

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;  -- 100 MHz
    CONSTANT clk50_period : TIME := 20 ns;  -- 50 MHz

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: cpu_top PORT MAP (
        clk => clk,
        clk50 => clk50,
        reset => reset,
        an => an,
        CA => CA,
        CB => CB,
        CC => CC,
        CD => CD,
        CE => CE,
        CF => CF,
        CG => CG
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    clk50_process : PROCESS
    BEGIN
        clk50 <= '0';
        WAIT FOR clk50_period/2;
        clk50 <= '1';
        WAIT FOR clk50_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Initialize Inputs
        reset <= '1';
        WAIT FOR 100 ns;  -- Reset duration
        reset <= '0';
        
        WAIT;
    END PROCESS;
END behavior;
