----------------------------------------------------------------------------------
-- decode.vhd
----------------------------------------------------------------------------------
-- Engineer: Joshua MacVey
--
-- Description:  This module serves as the decode component to the MIPS 32 bit, single
-- cycle processor.
--
-- Port Descriptions:
-- instruction : instruction fetched from memory by fetch module
-- memory_data : 32-bit data at specified memory location
-- alu_result  : resulting 32-bit value from last ALU operation 
-- RegDst, RegWrite, MemToReg, reset, writeClock : control signals as follows:
--							RegDst: Specifies destination register as rs or rt
--								 	  RegDst = 0 -> rt, else rs
--							RegWrite: Specifies whether to write to address
--							MemReg: Specifies whether data to write is from memory or ALU
--									  MemReg = 0 -> alu_result, else mem_data
--							WriteClock: Can't write when data is not ready.  We write on
--											negative edge of the write clock.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode is

port (instruction : in std_logic_vector(31 downto 0);
		memory_data, alu_result : in std_logic_vector(31 downto 0);
		RegDst, RegWrite, MemToReg, reset, wClock : in std_logic;
		register_rs, register_rt, register_rd : out std_logic_vector(31 downto 0);
		jump_addr, immediate : out std_logic_vector(31 downto 0));
		
end decode;

architecture Behavioral of decode is
-- store registers as signals within decode module
signal reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7 : std_logic_vector(31 downto 0);

begin

------------------------------------------------------
-- Write Process
------------------------------------------------------

REG_WRITE: process(reset, memory_data, alu_result, 
						RegWrite, RegDst, MemToReg, wClock)
	variable write_value, rd 		: std_logic_vector(31 downto 0);
	variable addr1, addr2, addr3 	: std_logic_vector(4 downto 0); -- 5 bits -> 32 data registers
begin

	-- write on negative edge of write clock to avoid writing when data isn't ready
	if (wClock'event and wClock = '0') then
	
	-- reset gets priority
		if (reset = '1') then
			reg0 <= X"00000000";
			reg1 <= X"00000000";
			reg2 <= X"00000000";
			reg3 <= X"00000000";
			reg4 <= X"00000000";
			reg5 <= X"00000000";
			reg6 <= X"00000000";
			reg7 <= X"00000000";
		end if;
		
		-- determine name of register to be written
		
		addr2 := instruction(20 downto 16); --rt
		addr3 := instruction(15 downto 11); --rd
		
			if (RegDst = '0') then
				addr3 := addr2; -- RegDst = 0 implies reg_destination = rt
			end if;
			
				-- determine data source to be written (memory or ALU result)
		
			if (RegWrite = '1') then
				if (MemToReg = '1') then
					write_value := memory_data;
				else
					write_value := alu_result;
				end if;
		
			-- store the value to the destination register
			-- rd used as intermediate variable for testing
				case addr3 is
					when "0" & X"0" => reg0 <= X"00000000";
					when "0" & X"1" => reg1 <= write_value;
					when "0" & X"2" => reg2 <= write_value;
					when "0" & X"3" => reg3 <= write_value;
					when "0" & X"4" => reg4 <= write_value;
					when "0" & X"5" => reg5 <= write_value;
					when "0" & X"6" => reg6 <= write_value;
					when "0" & X"7" => reg7 <= write_value;
					when others => reg0 <= X"00000000";
				end case;
				--rd := write_value;
				rd := write_value;
--			else
--				case addr3 is
--					when "0" & X"0" =>  rd := reg0;
--					when "0" & X"1" =>  rd := reg1;
--					when "0" & X"2" =>  rd := reg2;
--					when "0" & X"3" =>  rd := reg3;
--					when "0" & X"4" =>  rd := reg4;
--					when "0" & X"5" =>  rd := reg5;
--					when "0" & X"6" =>  rd := reg6;
--					when "0" & X"7" =>  rd := reg7;
--					when others => 	  rd := X"ffffffff";
--				end case;
			register_rd <= rd;
			end if; -- end RegWrite if
		--register_rd <= rd; -- for testing purposes
		end if; -- end Reset if;
end process REG_WRITE;

------------------------------------------------------
-- Read Process
------------------------------------------------------

REG_READ : process(instruction)
	variable rt, rs, imm 	: std_logic_vector(31 downto 0);
	variable addr1, addr2 	: std_logic_vector(4 downto 0);
begin
	-- register address for reading registers
	addr1 := instruction(25 downto 21); -- rs
	addr2 := instruction(20 downto 16); -- rt
	
	-- read the registers
	case addr1 is
		when "0" & X"0" => rs := reg0;	 
		when "0" & X"1" => rs := reg1;	 
		when "0" & X"2" => rs := reg2; 
		when "0" & X"3" => rs := reg3;	 
		when "0" & X"4" => rs := reg4;		 
		when "0" & X"5" => rs := reg5;	 
		when "0" & X"6" => rs := reg6;				 
		when "0" & X"7" => rs := reg7;
		when others => rs := X"00000000";
	end case;
	
	case addr2 is
		when "0" & X"0" => rt := reg0;	 
		when "0" & X"1" => rt := reg1;	 
		when "0" & X"2" => rt := reg2; 
		when "0" & X"3" => rt := reg3;	 
		when "0" & X"4" => rt := reg4;		 
		when "0" & X"5" => rt := reg5;	 
		when "0" & X"6" => rt := reg6;				 
		when "0" & X"7" => rt := reg7;
		when others => rt := X"00000000";
	end case;

	-- get immediate instruction and perform sign extension
	if (instruction(15) = '1') then
		imm := X"ffff" & instruction(15 downto 0);
	else
		imm := X"0000" & instruction(15 downto 0);
	end if;
	
	-- compute the jump address
	jump_addr <= "00" & X"0" & instruction(25 downto 0);
	-- bring out the register and immediate signals to the ports of the module
	register_rs <= rs;
	register_rt <= rt;
	immediate <= imm;
end process REG_READ;
							 
end Behavioral;

