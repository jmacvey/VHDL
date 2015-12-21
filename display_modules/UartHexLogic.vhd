----------------------------------------------------------------------------------
-- Engineer: Joshua MacVey
--
-- Design Name:	 Display Hex numbers to PC terminal
-- Module Name:	 UartHexLogic - Behavioral
-- Target Devices: Spartan 6
-- Dependencies:  UART_tx_chr
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity UartHexLogic is
	port (lbl : in std_logic_vector(31 downto 0);
	      HexData : in std_logic_vector(31 downto 0);
			btn : in std_logic;
			tx : out std_logic;
			clk : in std_logic);		
end UartHexLogic;

architecture Behavioral of UartHexLogic is
	signal TxData : std_logic_vector(7 downto 0);
	signal UartReady, TxEn, uart_tx : std_logic;
	type state_type is (idle, state1, state2, state3, state4, state5, state6, state7, state8, state9, state10, state11, state12, state13, state14);
	signal state_reg, state_next : state_type;
	
	function hexToAscii(hex : std_logic_vector(3 downto 0))
		return std_logic_vector is
		variable ascii : std_logic_vector(7 downto 0);
		begin
		ascii := X"30" when hex = "0000" else
         X"31" when hex = "0001" else
			X"32" when hex = "0010" else
			X"33" when hex = "0011" else
			X"34" when hex = "0100" else
			X"35" when hex = "0101" else
			X"36" when hex = "0110" else
			X"37" when hex = "0111" else
			X"38" when hex = "1000" else
			X"39" when hex = "1001" else
			X"41" when hex = "1010" else
			X"42" when hex = "1011" else
			X"43" when hex = "1100" else
			X"44" when hex = "1101" else
			X"45" when hex = "1110" else
			X"46";
		return ascii;
		end hexToAscii;
		

begin
	--UART TX utility, uses UART comms
	ute1 : entity work.uart_tx_chr(beh) 
		port map (send => TxEn, data => TxData, clk => clk, ready => UartReady, uart_tx => tx);				 
	
	--clock sync
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if btn = '1' then
				state_reg <= state1;
			else
				state_reg <= state_next;
			end if;
		end if;
	end process;
	
	--sends ascii data to UART_tx
	process(state_reg, UartReady, lbl, HexData)
	begin
		case state_reg is
			when idle => state_next <= idle;
							 TxEn <= '0';
			when state1 => if UartReady = '1' then
									TxData <= lbl(31 downto 24);
									state_next <= state2;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state1;
								end if;
			when state2 => if UartReady = '1' then
									TxData <= lbl(23 downto 16);
									state_next <= state3;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state2;
								end if;
			when state3 => if UartReady = '1' then
									TxData <= lbl(15 downto 8);
									state_next <= state4;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state3;
								end if;
			when state4 => if UartReady = '1' then
									TxData <= lbl(7 downto 0);
									state_next <= state5;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state4;
								end if;
			when state5 => if UartReady = '1' then
									TxData <= hexToAscii(HexData(31 downto 28));
									state_next <= state6;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state5;
								end if;
			when state6 => if UartReady = '1' then 
									TxData <=  hexToAscii(HexData(27 downto 24));
									state_next <= state7;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state6;
								end if;
			when state7 => if UartReady = '1' then
									TxData <=  hexToAscii(HexData(23 downto 20));
									state_next <= state8;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state7;
								end if;
			when state8 => if UartReady = '1' then
									TxData <=  hexToAscii(HexData(19 downto 16));
									state_next <= state9;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state8;
								end if;
			when state9 => if UartReady = '1' then
									TxData <=  hexToAscii(HexData(15 downto 12));
									state_next <= state10;
									TxEn <= '1';
								else
									TxEn <= '0';
									state_next <= state9;
								end if;
			when state10 => if UartReady = '1' then
									 TxData <=  hexToAscii(HexData(11 downto 8));
									 state_next <= state11;
									 TxEn <= '1';
								 else
									 TxEn <= '0';
									 state_next <= state10;
								 end if;
			when state11 => if UartReady = '1' then
									 TxData <= hexToAscii(HexData(7 downto 4));
									 state_next <= state12;
									 TxEn <= '1';
								 else
									 TxEn <= '0';
									 state_next <= state11;
								 end if;
			when state12 => if UartReady = '1' then
									 TxData <=  hexToAscii(HexData(3 downto 0));
									 state_next <= state13;
									 TxEn <= '1';
								 else
									 TxEn <= '0';
									 state_next <= state12;
								 end if;
			when state13 => if UartReady = '1' then
									 TxData <= X"0D";
									 state_next <= state14;
									 TxEn <= '1';
								 else
									 TxEn <= '0';
									 state_next <= state13;
								 end if;
			when state14 => if UartReady = '1' then
									TxData <= X"0A";
									state_next <= idle;
									TxEn <= '1';
								 else
									TxEn <= '0';
									state_next <= state14;
								 end if;
			when others => TxEn <= '0';
		end case;
	end process;
end Behavioral;
