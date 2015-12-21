-----------------------------------------------------------------------
-- Package name: SevSegDis
-- Author: Joshua MacVey
-- Description:  Process used to translate hexadecimal values to seven
-- segment display on the NEXYS3 protoboard. 
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package SevSegDis is
	procedure sseg_decode(signal hex : in std_logic_vector (3 downto 0);
	signal sseg_out : out std_logic_vector (7 downto 0) );
end SevSegDis;

package body SevSegDis is
	-- code the 7-segment decoding procedure declared above
	procedure sseg_decode(signal hex : in std_logic_vector (3 downto 0);
		signal sseg_out : out std_logic_vector (7 downto 0)) is
		variable temp : std_logic_vector (6 downto 0);
	begin
		case hex is
			when "0000" => temp := "0111111";
			when "0001" => temp := "0000110";
			when "0010" => temp := "1011011";
			when "0011" => temp := "1001111";
			when "0100" => temp := "1100110";
			when "0101" => temp := "1101101";
			when "0110" => temp := "1111101";
			when "0111" => temp := "0000111";
			when "1000" => temp := "1111111";
			when "1001" => temp := "1101111";
			when "1010" => temp := "1110111";
			when "1011" => temp := "1111100";
			when "1100" => temp := "0111001";
			when "1101" => temp := "1011110";
			when "1110" => temp := "1111001";
			when "1111" => temp := "1110001";
			when others => temp := "1111111"; 
		end case;
		
		sseg_out <= "1" & (not temp); -- dp=off
	end sseg_decode;
end SevSegDis;

