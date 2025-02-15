library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FullAdder is
    Port ( A, B, Cin : in STD_LOGIC;
           Sum : out STD_LOGIC;
           Cout : out STD_LOGIC );
end FullAdder;

architecture Structural_FullAdder of FullAdder is

    signal Sum1, Sum2, Carry1, Carry2 : STD_LOGIC;
    
begin

    HalfAdder1: entity work.HalfAdder port map (A => A, B => B, Sum => Sum1, Carry => Carry1);
    HalfAdder2: entity work.HalfAdder port map (A => Sum1, B => Cin, Sum => Sum2, Carry => Carry2);
    
    Sum <= Sum2 after 1 ns;
    Cout <= Carry1 OR Carry2 after 1 ns;

end Structural_FullAdder;