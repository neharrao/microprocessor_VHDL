library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg is
    Port (
        clk         : in std_logic;               
        reset       : in std_logic;               
        load        : in std_logic;               
        data_in     : in std_logic_vector(3 downto 0); 
        data_out    : out std_logic_vector(3 downto 0) );
end shift_reg;

architecture behavioral of shift_reg is

    signal temp_reg : std_logic_vector(3 downto 0) := (others => '0');
    
begin

    shift_process : process(clk, reset)
    begin
        if reset = '1' then
            temp_reg <= (others => '0');  
        elsif rising_edge(clk) then
            if load = '0' then
                temp_reg <= '0' & temp_reg(3 downto 1);  
            else
                temp_reg <= data_in;  
            end if;
        end if;
    end process shift_process;

    data_out <= temp_reg;

end architecture behavioral;