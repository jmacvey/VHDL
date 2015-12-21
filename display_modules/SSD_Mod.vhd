----------------------------------------------------------------------------------
-- SSD_MOD.vhd
----------------------------------------------------------------------------------
-- Authors: Joshua MacVey
----------------------------------------------------------------------------------
-- Description:
-- This display module takes a 16-bit vector and displays the corresponding 4 bit
-- HEX values on the SSD.
-- Anode Rotation frequency : 256 Hz
-- 
-- Port Descriptions:
-- clk 		: 100MHz system clock
-- ssd_num 	: the 16 bit vector to display on the SSD
-- anodes	: output to anodes port
-- cathodes : output to cathodes port
--
-- Dependencies: SevSegDis package (used to decode the bits to their corresponding
-- SSD values)
----------------------------------------------------------------------------------

library IEEE;
library Display_modules;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use Display_Modules.SevSegDis.all; -- seven seg display package

entity SSD_Mod is
    Port ( clk : in std_logic;
			  ssd_num : in std_logic_vector(15 downto 0);
           anodes : out std_logic_vector(3 downto 0);
			  cathodes : out std_logic_vector(7 downto 0));
end SSD_Mod;

architecture Behavioral of SSD_Mod is

signal count, count_next : integer := 0;
signal sclk : std_logic := '0';

type state_type is (s1, s2, s3, s4); -- states for controlling output to seven_seg_display
signal state_reg : state_type := s1; -- initial state at 1
signal state_next : state_type := s2; -- next state logic

begin

-- 256Hz clock generator
-- slow clock division process // concurrent statement
process(clk)
begin
	if (clk'event and clk = '1') then
		if (count = 50*10**6/256) then
			sclk <= not sclk;
		end if;
		count <= count_next;
	end if;
end process;
count_next <= 0 when count = 50*10**6/256 else
					count + 1;

-- ssd output on sclk
process (sclk)
begin
	if (sclk'event and sclk = '1') then
		state_reg <= state_next;
	end if;
end process;


-- next_state logic for ssd display
process(state_reg)
begin
	case state_reg is
		when s1 => anodes <= "0111";
					  state_next <= s2;
					  sseg_decode(hex => ssd_num(15 downto 12), sseg_out => cathodes);
		when s2 => anodes <= "1011";
					  state_next <= s3;
					  sseg_decode(hex => ssd_num(11 downto 8), sseg_out => cathodes);			  
		when s3 => anodes <= "1101";
					  state_next <= s4;
					  sseg_decode(hex => ssd_num(7 downto 4), sseg_out => cathodes);				  
		when others => anodes <= "1110";
					  state_next <= s1;
					  sseg_decode(hex => ssd_num(3 downto 0), sseg_out => cathodes);	
	end case;
end process;

end Behavioral;

