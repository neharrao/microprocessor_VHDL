library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier is
    port (
        clk, reset : in std_logic;
        multiplicand, multiplier : in std_logic_vector(7 downto 0);
        product : out std_logic_vector(8 downto 0)
    );
end entity multiplier;

architecture mixed of multiplier is

    signal partial_product, full_product : std_logic_vector(7 downto 0) := (others => '0');
    signal arith_control, result_en, f_cout : std_logic;
    signal mult_bit : std_logic_vector(3 downto 0);
    signal count : integer := 0;
    
begin

    arith_unit : entity work.shift_adder
        port map (
            clk        => clk,
            reset      => reset,
            load       => arith_control,  
            d          => multiplicand,   
            augend_tb  => full_product,   
            sum_tb     => partial_product, 
            cout_tb    => f_cout
        );
  
    result : entity work.reg
        port map (
            d   => partial_product,
            en  => mult_bit(0),
            clk => clk,
            reset => reset,
            q   => full_product
        );

    multiplier_sr : entity work.shift_reg
        port map (
            clk      => clk,
            reset    => reset,
            load     => arith_control,
            data_in  => multiplier(3 downto 0),
            data_out => mult_bit
        );

    product <= f_cout & full_product;
    
    process(reset, clk)
    begin
    if reset = '1' then 
        count <= 0;
    elsif rising_edge(clk) then 
        count <= count+1;
            if count < 1 then 
                arith_control <= '1';
            elsif count = 1 then  
                arith_control <= '0'; 
            end if;   
        end if;     
    end process;

end architecture mixed;
