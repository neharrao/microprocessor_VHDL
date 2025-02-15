library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity shift_adder is
    Port (
        clk       : in std_logic;
        reset     : in std_logic;
        load      : in std_logic;
        d         : in std_logic_vector(7 downto 0); 
        augend_tb : in std_logic_vector(7 downto 0); 
        sum_tb    : out std_logic_vector(7 downto 0); 
        cout_tb   : out std_logic );
end shift_adder;

architecture behavioral of shift_adder is

    signal temp_reg : std_logic_vector(7 downto 0) := (others => '0'); 
    signal internal_sum : std_logic_vector(7 downto 0);                
    signal carry_out : std_logic;                                      
begin
    
    process(clk, reset)
    begin
        if reset = '1' then
            temp_reg <= (others => '0'); 
        elsif rising_edge(clk) then
            if load = '1' then
                temp_reg <= d; 
            else
                temp_reg <= temp_reg(6 downto 0) & '0';
            end if;
        end if;
    end process;

    Ripple_Adder: entity work.RippleCarryAdder
        port map (
            A => augend_tb,
            B => temp_reg,
            Sum => internal_sum,
            Cout => carry_out );

            sum_tb <= internal_sum;
            cout_tb <= carry_out;
    
end architecture behavioral;