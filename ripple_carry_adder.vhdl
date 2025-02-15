library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RippleCarryAdder is
    Port ( A, B : in STD_LOGIC_VECTOR(7 downto 0);
           Sum : out STD_LOGIC_VECTOR(7 downto 0);
           Cout : out STD_LOGIC );
end RippleCarryAdder;

architecture Structural_RippleCarryAdder of RippleCarryAdder is

   signal Cin, Cout1, Cout2, Cout3, Cout4, Cout5, Cout6, Cout7 : STD_LOGIC := '0';
   
begin

    FullAdder1: entity work.FullAdder port map (A => A(0), B => B(0), Cin => '0', Sum => Sum(0), Cout => Cout1);
    FullAdder2: entity work.FullAdder port map (A => A(1), B => B(1), Cin => Cout1, Sum => Sum(1), Cout => Cout2);
    FullAdder3: entity work.FullAdder port map (A => A(2), B => B(2), Cin => Cout2, Sum => Sum(2), Cout => Cout3);
    FullAdder4: entity work.FullAdder port map (A => A(3), B => B(3), Cin => Cout3, Sum => Sum(3), Cout => Cout4);   
    FullAdder5: entity work.FullAdder port map (A => A(4), B => B(4), Cin => Cout4, Sum => Sum(4), Cout => Cout5);
    FullAdder6: entity work.FullAdder port map (A => A(5), B => B(5), Cin => Cout5, Sum => Sum(5), Cout => Cout6);
    FullAdder7: entity work.FullAdder port map (A => A(6), B => B(6), Cin => Cout6, Sum => Sum(6), Cout => Cout7);
    FullAdder8: entity work.FullAdder port map (A => A(7), B => B(7), Cin => Cout7, Sum => Sum(7), Cout => Cout);
    
end Structural_RippleCarryAdder;