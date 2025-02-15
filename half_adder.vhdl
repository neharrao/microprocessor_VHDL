library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HalfAdder is
    Port ( A, B : in STD_LOGIC;
           Sum : out STD_LOGIC;
           Carry : out STD_LOGIC) ;
end HalfAdder;

architecture Structural_HalfAdder of HalfAdder is

    signal Sum1 : STD_LOGIC;
    signal Carry1 : STD_LOGIC;
    
begin

    Sum1 <= A XOR B;
    Carry1 <= A AND B;

    Sum <= Sum1 after 1 ns;
    Carry <= Carry1 after 1 ns;
    
end Structural_HalfAdder;