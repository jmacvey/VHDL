----------------------------------------------------------------------------------
-- Fetch.vhd
----------------------------------------------------------------------------------
-- Authors: Joshua MacVey
----------------------------------------------------------------------------------
-- Description:
-- This module serves as the fetch component for a simplified MIPS processor.  
-- Memory is stores in a simple of word logic vectors.  Addresses are also specified
-- as words (though they are represented here in 32 bits).
-- 
-- Port Descriptions:
-- branch_addr 		: address of branch corresponding to branch decision
-- jump_adddr		 	: address of jump corresponding to jump decision
-- branch_decision	: branch yes/no logic
-- jump_decision		: jump yes/no logic
-- clock					: Fetch clocking mechanism
--	reset					: resets PC counter to initial memory address. Keeps address
--							  static if toggled on.
-- PC_out				: the address of the current PC
-- instruction			: 32 bit instruction stored in current PC address
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity Fetch is
    Port ( branch_addr, jump_addr : in  STD_LOGIC_VECTOR (31 downto 0);
			  branch_decision, jump_decision, clock, reset : in  STD_LOGIC;
           PC_out, instruction : out  STD_LOGIC_VECTOR (31 downto 0));
end Fetch;

architecture Behavioral of Fetch is
	--instruction memory is created as an array of 32 bits, and it has 16 locations for this example
	type mem_array is array(0 to 8) of STD_LOGIC_VECTOR(31 downto 0);
	signal mem : mem_array := (
X"20000000",	-- addi $0, 0($0) -> reset command
X"20010190",	-- addi $1, 400($0)
X"20420002",	-- L1: addi $2, $2, 2
X"00621820",   -- add  $3, $3, $2
X"10220001",	-- beq  $1, $3, L2
X"08000001",   -- j L1
X"ac030003",	-- L2: sw $3, 3($0)
X"8c050003",   -- L3: lw $5, 3($0)
X"08000006"   	-- j L3
										);
begin
	process ---no sensitivity list here, you are going to use a wait statement
		variable PC : STD_LOGIC_VECTOR(31 downto 0); --internal PC
		variable index : integer :=0; --index is used to reference mem array
		
		begin
		--below describes the logic of Fetch using pseudo code.
		
		--wait until start of a clock cycle, i.e.,
		wait until (clock'event and clock = '1'); 	--clock should be a debounced button signal for now.															--a real clock is used in the later lab.
			if reset = '1' then
				PC := X"00000000";
				index := 0;
			else
				if(branch_decision = '1') then
						PC := branch_addr;
				elsif(jump_decision = '1') then
						PC := jump_addr;
				end if;
						--normal PC operation.
						--only four bits are used for the address of the instruction memory above, mem,						i.e.,
						index := to_integer(unsigned(PC(3 downto 0)));
			end if;
			--Get instruction out from the mem.
			instruction <= mem(index);
			PC := std_logic_vector(unsigned(PC) + 1);
			--Now, pass PC out to the port
			PC_out <= PC;

	end process;
end Behavioral;
