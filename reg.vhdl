library IEEE;
use IEEE.std_logic_1164.all;

entity reg is
    port(
        d : in std_logic_vector(7 downto 0); 
        en, clk, reset : in std_logic;
        q : out std_logic_vector(7 downto 0));
end entity reg;

architecture behavioral of reg is

begin

    process(clk, reset)
    begin
        if reset = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d; 
            end if;
        end if;
    end process;

end architecture behavioral;