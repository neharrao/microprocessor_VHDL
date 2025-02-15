LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY disp4 IS
    PORT (
        clk : IN STD_LOGIC;
        disp_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        an : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        CA, CB, CC, CD, CE, CF, CG : OUT STD_LOGIC);
END disp4;
ARCHITECTURE Behavioral OF disp4 IS
    PROCEDURE display_digit
    (SIGNAL digit : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL A, B, C, D, E, F, G : OUT STD_LOGIC) IS
BEGIN
    CASE digit IS
        WHEN "0000" => -- 0 
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '1'; -- 0 
        WHEN "0001" => -- 1
            A <= '1';
            B <= '0';
            C <= '0';
            D <= '1';
            E <= '1';
            F <= '1';
            G <= '1'; -- 1 
        WHEN "0010" => -- 02
            A <= '0';
            B <= '0';
            C <= '1';
            D <= '0';
            E <= '0';
            F <= '1';
            G <= '0'; -- 2 
        WHEN "0011" => -- 03
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '1';
            F <= '1';
            G <= '0'; -- 3 
        WHEN "0100" => -- 04
            A <= '1';
            B <= '0';
            C <= '0';
            D <= '1';
            E <= '1';
            F <= '0';
            G <= '0'; -- 4 
        WHEN "0101" => -- 05
            A <= '0';
            B <= '1';
            C <= '0';
            D <= '0';
            E <= '1';
            F <= '0';
            G <= '0'; -- 5 
        WHEN "0110" => -- 06
            A <= '0';
            B <= '1';
            C <= '0';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '0'; -- 6
        WHEN "0111" => -- 07
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '1';
            E <= '1';
            F <= '1';
            G <= '1'; -- 7 
        WHEN "1000" => -- 08
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '0'; -- 8 
        WHEN "1001" => -- 09
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '1';
            F <= '0';
            G <= '0'; -- 9 
        WHEN "1010" => -- A
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '1';
            E <= '0';
            F <= '0';
            G <= '0';
        WHEN "1011" => -- B 
            A <= '1';
            B <= '1';
            C <= '0';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '0';
        WHEN "1100" => -- C 
            A <= '0';
            B <= '1';
            C <= '1';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '1';
        WHEN "1101" => -- D 
            A <= '1';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '0';
            F <= '1';
            G <= '0';
        WHEN "1110" => -- E 
            A <= '0';
            B <= '1';
            C <= '1';
            D <= '0';
            E <= '0';
            F <= '0';
            G <= '0';
        WHEN "1111" => -- F 
            A <= '0';
            B <= '1';
            C <= '1';
            D <= '1';
            E <= '0';
            F <= '0';
            G <= '0';
        WHEN OTHERS => NULL;
    END CASE;
END display_digit;
TYPE digit_array IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL digit : digit_array;
BEGIN
gen0 : FOR i IN 0 TO 3 GENERATE
    digit(i) <= disp_in (((4 * i) + 3) DOWNTO (4 * i));
END GENERATE;
selector : PROCESS (clk, digit) 
    VARIABLE counter : INTEGER := 0;
    VARIABLE place : INTEGER
BEGIN
    IF rising_edge(clk) THEN
        counter := counter + 1;
        IF (counter > 50000) THEN
            counter := 0;
            place := place + 1;
            IF place > 3 THEN
                place := 0;
            END IF;
        END IF;
    END IF;
    -- select digit to display
    IF (place = 0) THEN
        an <= "1110";
        display_digit(digit(0), CA, CB, CC, CD, CE, CF, CG);
    ELSIF (place = 1) THEN
        an <= "1101";
        display_digit(digit(1), CA, CB, CC, CD, CE, CF, CG);
    ELSIF (place = 2) THEN
        an <= "1011";
        display_digit(digit(2), CA, CB, CC, CD, CE, CF, CG);
    ELSE
        an <= "0111";
        display_digit(digit(3), CA, CB, CC, CD, CE, CF, CG);
    END IF;
END PROCESS selector;
END Behavioral;