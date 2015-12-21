----------------------------------------------------------------------------------
-- Engineer: Joshua MacVey
-- Description: This modules serves as the execute module for single-cycle MIPS32.
-- Branching and ALU operations are done with combinatorial logic.  Needs to be
-- broken out into various modules to incorporate multi-cycle state machine.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity execute is

port(PC4, register_rs, register_rt, immediate : in std_logic_vector(31 downto 0);
	  ALU_Op : in std_logic_vector(1 downto 0);
	  ALU_Src, beq_control, clock : in std_logic;
	  ALU_Result, branch_addr : out std_logic_vector(31 downto 0);
	  branch_decision : out std_logic);

end execute;

architecture Behavioral of execute is
begin

process (ALU_Op, immediate)
variable alu_output : signed(31 downto 0);
variable zero : std_logic := '0'; --bit that indicates ALU_result is zero.
variable branch_offset : std_logic_vector(31 downto 0);
begin
	case ALU_Op is
		when "00" => -- memory instruction (lw, sw) 
			alu_output := signed(register_rs) + signed(immediate);
		when "01" => -- branch instruction 
			alu_output := signed(register_rs) - signed(register_rt);
				if (alu_output = X"00000000") then 		--determines if the ALU result is zero
				zero := '1';
			else
				zero := '0';
			end if;
		when "10" => -- R-type (can never have immediate value)
			case immediate(5 downto 0)is	--determines the alu_output
				when "10" & X"0" => --add
					alu_output := signed(register_rs) + signed(register_rt);
				when "10" & X"2" => --subtract
					alu_output := signed(register_rs) - signed(register_rt);
				when "10" & X"4" => --and
					alu_output := signed(register_rs and register_rt);
				when "10" & X"5" => -- or
					alu_output := signed(register_rs or register_rt);
				when others => 	  --error
					alu_output := X"ffffffff";
			end case;
		when others =>
			alu_output := X"ffffffff"; -- error
			zero := '0'; -- avoid false branching
	end case;
	
	branch_offset := immediate;		--sets up the branch_offset value
	branch_addr <= std_logic_vector(signed(PC4) + signed(branch_offset));	--determines where it should branch, if it branches
	branch_decision <= beq_control and zero;			--determines if it should branch or not
	alu_result <= std_logic_vector(alu_output);		--converts the ALU result to logic vector and assigns it to proper signal
	
end process;

end Behavioral;

