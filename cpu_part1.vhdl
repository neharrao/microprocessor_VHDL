LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY cpu IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        wr_en : OUT STD_LOGIC;
        dr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data from the memory 
        dw : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data to the memory
        addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Memory address
        pc_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Program counter value
        accu_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Accumulator value
    );
END cpu;

ARCHITECTURE fsm OF cpu IS

    -- op-codes
    CONSTANT LDA : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT STA : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT ADD : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT JNC : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT JMP : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT MUL : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";

    CONSTANT one : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";

    -- CPU registers
    SIGNAL accu     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- Accumulator 
    SIGNAL op_code  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; -- Current op-code
    SIGNAL pc       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- Program counter
    SIGNAL temp_1   : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";

    -- FSM states
    TYPE state_t IS (load_opcode, LDA_1, ADD_1, ADD_2, STA_1, STA_2, JNC_1, JMP_1, JMP_2, MUL_1);
   
    -- Signals used for debugging
    SIGNAL state_watch : state_t;

BEGIN -- fsm

    -- Accumulator and program counter value outputs
    accu_out <= accu;
    pc_out <= pc;

    fsm_proc : PROCESS (clk, reset)
        VARIABLE state : state_t := load_opcode;

    BEGIN -- process fsm_proc

        IF (reset = '1') THEN -- Asynchronous reset
            -- Reset all registers and signals
            wr_en <= '0';
            dw <= (OTHERS => '0');
            addr <= (OTHERS => '0');
            op_code <= (OTHERS => '0');
            accu <= (OTHERS => '0');
            pc <= (OTHERS => '0');
            state := load_opcode;

        ELSIF rising_edge(clk) THEN -- Synchronous FSM
            state_watch <= state;

            CASE state IS

                WHEN load_opcode =>
                    op_code <= dr(3 DOWNTO 0); -- Load the op-code
                    pc <= pc + one; -- Increment the program counter
                    addr <= pc + one; -- Memory address pointed to by PC
                    
                    -- Op-code determines the next state:
                    CASE dr(3 DOWNTO 0) IS
                        WHEN LDA => state := LDA_1;
                        WHEN ADD => state := ADD_1;
                        WHEN STA => state := STA_1;
                        WHEN JNC => state := JNC_1;
                        WHEN JMP => state := JMP_1;
                        WHEN MUl => state := MUL_1;
                        WHEN OTHERS => state := load_opcode;
                    END CASE; -- opcode decoder

                -- State transitions for other instructions:
                WHEN LDA_1 =>
                    accu <= dr;
                    pc <= pc + one;
                    addr <= pc + one;
                    state := load_opcode;

                WHEN ADD_1 =>
                    temp_1 <= '0' & accu;
                    addr <= dr;
                    state := ADD_2;

                WHEN ADD_2 =>
                    temp_1 <= temp_1 + ('0' & dr);
                    accu <= accu + dr;
                    addr <= pc + one;
                    pc <= pc + one;
                    state := load_opcode;

                WHEN STA_1 =>
                    dw <= accu;
                    wr_en <= '1';
                    addr <= dr;
                    state := STA_2;

                WHEN STA_2 =>
                    wr_en <= '0';
                    addr <= pc + one;
                    pc <= pc + one;
                    state := load_opcode;

                WHEN JNC_1 =>
                    IF temp_1(8) > '1' OR temp_1(8) < '1' THEN
                        pc <= dr; -- Jump if no carry 
                        addr <= dr;
                        state := load_opcode;

                    ELSIF temp_1(8) = '1' THEN
                        pc <= pc + 1; -- Proceed with next instruction 
                        addr <= pc + 1;
                        state := load_opcode;
                    END IF;

                WHEN JMP_1 =>
                    accu <= dr; -- Jump to the specified address 
                    state := JMP_2;

                WHEN JMP_2 =>
                    pc <= dr;
                    addr <= dr;
                    state := load_opcode;

                WHEN MUL_1 =>
                    accu <= dr;
                    state := load_opcode;

            END CASE; -- state

        END IF; -- rising_edge(clk) 

    END PROCESS fsm_proc;
    
END fsm;