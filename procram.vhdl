LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY procram IS
    PORT (
        A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        DI : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        RESET : IN STD_LOGIC;
        WR_EN : IN STD_LOGIC;
        CLK : IN STD_LOGIC;
        DO : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END procram;
ARCHITECTURE sim OF procram IS
    -- 16-word blocks of RAM and ROM memory
    TYPE mem_array IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ram_data : mem_array := (OTHERS => x"00");
    SIGNAL rom_data : mem_array :=
    (x"01", x"07", x"03", x"0a", x"02", x"10", x"04", x"02",
    x"05", x"00", x"09", x"00", x"00", x"00", x"00", x"00");
BEGIN
    PROCESS (clk, WR_EN, RESET, A) VARIABLE address : INTEGER := 0;
    BEGIN
        address := to_integer(unsigned(a));
        IF reset = '1' THEN
            ram_data <= (OTHERS => x"00");
        ELSIF rising_edge(clk) THEN
            IF ((WR_EN = '1') AND (address > 15) AND (address < 32)) THEN
                ram_data (address - 16) <= DI; -- Write to RAM address
            END IF;
        END IF;
        IF (address > 31) THEN
            DO <= (OTHERS => '0');
        ELSIF (address > 15) THEN
            DO <= ram_data(address - 16); -- Read from RAM address
        ELSE
            DO <= rom_data(address); -- Read from ROM address END IF;
        END PROCESS;
    END sim;