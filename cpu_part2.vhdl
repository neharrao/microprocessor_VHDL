library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity cpu is
    port(
        clk      : in std_logic;
        reset    : in std_logic;
        wr_en    : out std_logic;
        dr       : in std_logic_vector(7 downto 0); -- Data from the memory
        dw       : out std_logic_vector(7 downto 0); -- Data to the memory
        addr     : out std_logic_vector(7 downto 0); -- Memory address
        pc_out   : out std_logic_vector(7 downto 0); -- Program counter value
        accu_out : out std_logic_vector(7 downto 0)  -- Accumulator value
    );
end cpu;

architecture fsm of cpu is
    -- op-codes
    constant LDA : std_logic_vector(3 downto 0) := "0001";
    constant STA : std_logic_vector(3 downto 0) := "0010";
    constant ADD : std_logic_vector(3 downto 0) := "0011";
    constant JNC : std_logic_vector(3 downto 0) := "0100";
    constant JMP : std_logic_vector(3 downto 0) := "0101";
    constant MUL : std_logic_vector(3 downto 0) := "0110";
    constant SUB : std_logic_vector(3 downto 0) := "0111";
    constant S_L : std_logic_vector(3 downto 0) := "1000";
    constant S_R : std_logic_vector(3 downto 0) := "1001";
    constant PRNG : std_logic_vector(3 downto 0) := "1010"; -- opcode for loading PRNG number
    constant SEED : std_logic_vector(3 downto 0) := "1011"; -- opcode for seeding the PRNG
    constant JSR : std_logic_vector(3 downto 0) := "1100";  -- Opcode for JSR
    constant RTS : std_logic_vector(3 downto 0) := "1101";  -- Opcode for RTS

    constant one : std_logic_vector(7 downto 0) := "00000001";

    -- CPU registers
    signal accu    : std_logic_vector(7 downto 0) := "00000000"; -- Accumulator
    signal op_code : std_logic_vector(3 downto 0) := "0000";     -- Current op-code
    signal pc      : std_logic_vector(7 downto 0) := "00000000"; -- Program counter
    signal temp_1  : std_logic_vector(8 downto 0) := "000000000"; -- Temporary register
    signal prng_register : std_logic_vector(7 downto 0) := "00000001"; -- PRNG register initial seed
    signal multiplicand, multiplier : std_logic_vector(7 downto 0) := (others => '0');
    signal product : std_logic_vector(8 downto 0) := (others => '0');
    signal return_addr : std_logic_vector(7 downto 0) := "00000000";  -- Register to store return address
    signal stack_ptr : std_logic_vector(7 downto 0) := "11111111"; -- Initialize stack pointer at RAM's last address

    -- FSM states
    type state_t is (load_opcode, LDA_1, ADD_1, ADD_2, STA_1, STA_2, JNC_1, JMP_1, JMP_2, MUL_1, MUL_2, SUB_1, SUB_2, SHL_1, SHR_1, PRNG_LOAD, SEED_LOAD, JSR_1, RTS_1);

    -- Signals used for debugging
    signal state_watch : state_t;
    
    -- Function to perform LFSR operation
    function lfsr_next(current : std_logic_vector) return std_logic_vector is
        variable next_value : std_logic_vector(7 downto 0);
    begin
        -- XOR tap positions: 8, 6, 5, 4 for an 8-bit LFSR
        next_value := current(6 downto 0) & (current(7) xor current(5) xor current(4) xor current(3));
        return next_value;
    end function;


begin  -- fsm
    
    -- Accumulator and program counter value outputs
    accu_out <= accu;
    pc_out <= pc;


    fsm_proc : process (clk, reset)
        variable state : state_t := load_opcode;
        
    begin  -- process fsm_proc
    
        if reset = '1' then  -- Asynchronous reset
            -- Reset all registers and signals
            wr_en    <= '0';
            dw       <= (others => '0');
            addr     <= (others => '0');
            op_code  <= (others => '0');
            accu     <= (others => '0');
            pc       <= (others => '0');
            prng_register <= (others => '1'); 
            stack_ptr <= "11111111";
            state := load_opcode;
            
        elsif rising_edge(clk) then  -- Synchronous FSM
            state_watch <= state;
            
            case state is
            
                when load_opcode =>
                    op_code <= dr(3 downto 0); -- Load the op-code
                    pc      <= pc + one;       -- Increment the program counter
                    addr    <= pc + one;       -- Memory address pointed to by PC
                    
                    -- Op-code determines the next state:
                    case op_code is
                        when LDA => state := LDA_1;
                        when ADD => state := ADD_1;
                        when STA => state := STA_1;
                        when JNC => state := JNC_1;
                        when JMP => state := JMP_1;
                        when SUB => state := SUB_1;
                        when S_L => state := SHL_1;
                        when S_R => state := SHR_1;
                        when MUL => state := MUL_1;
                        when PRNG => state := PRNG_LOAD;
                        when SEED => state := SEED_LOAD;
                        when JSR => state := JSR_1;
                        when RTS => state := RTS_1;
                        when others => state := load_opcode;
                    end case;
                    
                when LDA_1 =>
                    accu <= dr;
                    pc   <= pc + one;
                    addr <= pc + one;
                    state := load_opcode;
                
                when ADD_1 =>
                    temp_1 <= '0' & accu;
                    addr <= dr; 
                    state := ADD_2; 
                    
                when ADD_2 =>
                    temp_1 <= temp_1 + ('0' & dr);
                    accu <= accu + dr;
                    addr <= pc + one;  
                    pc <= pc + one;
                    state := load_opcode;
                    
                when STA_1 =>
                    dw   <= accu;
                    wr_en <= '1'; 
                    addr <= dr;
                    state := STA_2;
                    
                when STA_2 =>
                    wr_en <= '0';
                    addr <= pc + one;
                    pc <= pc + one;
                    state := load_opcode;
                
                when JNC_1 =>
                    if temp_1(8) > '1' OR temp_1(8) < '1' then  
                        pc   <= dr;  -- Jump if no carry
                        addr <= dr;
                        state := load_opcode;
                        
                    elsif temp_1(8) = '1' then
                        pc   <= pc + 1;  -- Proceed with next instruction
                        addr <= pc + 1;
                        state := load_opcode;   
                    end if;
                    
                when JMP_1 =>
                    accu <= dr;  -- Jump to the specified address
                    state := JMP_2;
                    
                when JMP_2 => 
                    pc <= dr;
                    addr <= dr;
                    state := load_opcode; 

                when SUB_1 =>
                    addr <= dr;
                    state := SUB_2;

                when SUB_2 =>
                    accu <= accu - dr; -- Subtract and update accumulator
                    pc <= pc + one;
                    state := load_opcode;

                when SHL_1 => -- Shift left by one position
                    accu(7 downto 1) <= accu(6 downto 0); -- Shift all bits left, from bit 6 to 0 into 7 to 1
                    accu(0) <= '0'; -- Insert '0' at the LSB
                    pc <= pc + one;
                    state := load_opcode;
                
                when SHR_1 => -- Shift right by one position
                    accu(6 downto 0) <= accu(7 downto 1); -- Shift all bits right, from bit 7 to 1 into 6 to 0
                    accu(7) <= '0'; -- Insert '0' at the MSB
                    pc <= pc + one;
                    state := load_opcode;
                    
                when MUL_1 =>
                    multiplicand <= accu;
                    multiplier <= dr;
                    state := MUL_2;

                when MUL_2 =>
                    accu <= product(7 downto 0);
                    pc <= pc + one;
                    state := load_opcode;

                when PRNG_LOAD =>
                    accu <= prng_register;  -- Load the current PRNG value into the accumulator
                    prng_register <= lfsr_next(prng_register);  -- Update PRNG register
                    state := load_opcode;

                when SEED_LOAD =>
                    prng_register <= dr;  -- Load seed from data register
                    state := load_opcode;
                
                when JSR_1 =>
                    return_addr <= pc;        -- Save current program counter as return address
                    stack_ptr <= stack_ptr - 1; -- Decrement stack pointer
                    addr <= stack_ptr;        -- Set address to stack pointer
                    dw <= pc + one;           -- Store return address on stack
                    wr_en <= '1';             -- Enable write
                    pc <= pc + one;           -- Increment PC
                    state := load_opcode;     -- Go back to opcode fetch state
           
                when RTS_1 =>
                    pc <= return_addr;        -- Return to the address saved in return_addr
                    addr <= pc + 1;           -- Set address to the next instruction
                    state := load_opcode;     -- Go back to opcode fetch state
                    stack_ptr <= stack_ptr + 1; -- Increment stack pointer
                                
            end case;
        end if;
        
    end process fsm_proc;

-- Multiplier component instantiation
    multiplier_inst : entity work.multiplier
        port map (
            clk => clk,
            reset => reset,
            multiplicand => multiplicand,
            multiplier => multiplier,
            product => product
        );

end fsm;