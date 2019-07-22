LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


-- This function creates inputs for the circuitry.
-- Whenever it receives a high value on CLK, it will
-- dispatch the vectors ABCDE and FGH.
ENTITY Tx_LUT IS 
	PORT (ABCDE 	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
			FGH		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
			CLK		: IN  STD_LOGIC;
			ABCDEFGH : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
			readyTX	: OUT STD_LOGIC := '0';
			RESET		: IN	STD_LOGIC
			);
END ENTITY Tx_LUT;

ARCHITECTURE LUT OF Tx_LUT IS
SIGNAL COUNTER : INTEGER := 0;
BEGIN
	PROCESS(CLK) IS
	BEGIN
	
	IF RESET = '1' THEN
		ABCDE 	<= (OTHERS => '0');
		FGH 		<= (OTHERS => '0');
		COUNTER 	<= 0;
		ABCDEFGH <= (OTHERS => '0');
		readyTX	<= '0';
	
	ELSIF RISING_EDGE(CLK) THEN
		readyTX <= '1';
		CASE COUNTER IS
		
		WHEN 0 => 
					ABCDE 	<= "00000";
					FGH 		<= "000";
					COUNTER 	<= COUNTER + 1;
					ABCDEFGH <= "00000000";
		WHEN 1 =>
					ABCDE		<= "10011";
					FGH		<= "101";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "10011101";
					
		WHEN 2 => 
					ABCDE 	<= "01111";
					FGH		<= "111";
					COUNTER 	<= COUNTER + 1;
					ABCDEFGH <= "01111111";
					
		WHEN 3 =>
					ABCDE 	<= "01100";
					FGH		<= "110";
					COUNTER 	<= COUNTER + 1;
					ABCDEFGH <= "01100110";
					
		WHEN 4 =>
					ABCDE    <= "10100";
					FGH 		<= "111";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "10100111";
		
		WHEN 5 =>
					ABCDE    <= "01011";
					FGH 		<= "001";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "01011001";
					
		WHEN 6 =>
					ABCDE    <= "00110";
					FGH		<= "111";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "00110111";
					
		WHEN 7 => 
					ABCDE    <= "11110";
					FGH 		<= "000";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "11110000";
					
		WHEN 8 =>
					ABCDE		<= "01110";
					FGH 		<= "001";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "01110001";
					
		WHEN 9 => 
					ABCDE 	<= "01100";
					FGH		<= "001";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "01100001";
					
		WHEN 10=> 
					ABCDE 	<= "01011";
					FGH		<= "111";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "01011111";

		WHEN 11=> 
					ABCDE 	<= "11011";
					FGH		<= "110";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "11011110";
					
		WHEN 12=> 
					ABCDE 	<= "00100";
					FGH		<= "000";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "00100000";
					
		WHEN 13=> 
					ABCDE 	<= "10111";
					FGH		<= "000";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "10111000";
		
		WHEN 14=> 
					ABCDE 	<= "10000";
					FGH		<= "000";
					COUNTER  <=  COUNTER + 1;	
					ABCDEFGH <= "10000000";
		
		WHEN 15=> 
					ABCDE 	<= "10111";
					FGH		<= "000";
					COUNTER  <=  COUNTER + 1;
					ABCDEFGH <= "10111000";

		WHEN 16=> 
					ABCDE 	<= "10101";
					FGH		<= "010";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "10101010";
					
		WHEN 17=> 
					ABCDE 	<= "00100";
					FGH		<= "111";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "00100111";
		
		WHEN 18=> 
					ABCDE 	<= "11000";
					FGH		<= "011";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "11000011";
		
		WHEN 19=> 
					ABCDE 	<= "00111";
					FGH		<= "001";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "00111001";
				
		WHEN 20=> 
					ABCDE 	<= "01000";
					FGH		<= "001";
					COUNTER  <= COUNTER + 1;
					ABCDEFGH <= "01000001";
		
		WHEN OTHERS =>
					ABCDE 	<= "00000";
					FGH 		<= "110";
					COUNTER 	<= 1;
					ABCDEFGH <= "00000110";

		END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE LUT;