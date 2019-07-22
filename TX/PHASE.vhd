LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Coloca os dados de informacao em fase com o clock;

ENTITY PHASE IS
	PORT (	CLK 			: 	IN		STD_LOGIC := '0';
				RESET			: 	IN		STD_LOGIC;
				TX_RESULT	:	IN		STD_LOGIC_vECTOR(7 DOWNTO 0) := (OTHERS => '0');
				inPHASE		:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
			);
END ENTITY;

ARCHITECTURE BEHV OF PHASE IS
	SIGNAL POS1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS3 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS4 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS5 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS6 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL POS7 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN
	PROCESS(CLK, RESET)
	BEGIN
		IF RESET = '1'  THEN
			POS1 		<= (OTHERS => '0');
			POS2 		<= (OTHERS => '0');
			POS3 		<= (OTHERS => '0');
			POS4 		<= (OTHERS => '0');
			POS5 		<= (OTHERS => '0');
			POS6 		<= (OTHERS => '0');
			POS7 		<= (OTHERS => '0');
			inPHASE 	<= (OTHERS => '0');
			
		ELSIF RISING_EDGE(CLK) THEN
			POS1 		<= TX_RESULT;
			POS2 		<= POS1;
			POS3 		<= POS2;
			POS4 		<= POS3;
			POS5 		<= POS4;
			POS6 		<= POS5;
			inPHASE 	<= POS6;
		END IF;
	END PROCESS;
END ARCHITECTURE BEHV;