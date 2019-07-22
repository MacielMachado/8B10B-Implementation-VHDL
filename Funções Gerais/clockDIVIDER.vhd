LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY clockDIVIDER IS
	GENERIC (numberBITSandCOMMA : INTEGER := 20);
	
	PORT(	CLOCK_50 	: IN 	STD_LOGIC;
			dividedCLOCK: OUT STD_LOGIC := '0';
			RESET			: IN 	STD_LOGIC);
END ENTITY;

ARCHITECTURE BEHV OF clockDIVIDER IS 
TYPE STATES IS (FIRST, nonFIRST);
SIGNAL currentSTATE : STATES := FIRST;
SIGNAL COUNTER : INTEGER := 0;

BEGIN
	PROCESS(CLOCK_50) IS
	BEGIN
		IF RESET = '1' THEN
			currentSTATE 	<= FIRST;
			COUNTER 			<= 0;
			dividedCLOCK	<= '0';
			
		ELSIF RISING_EDGE(CLOCK_50) THEN
		
			IF currentSTATE = FIRST THEN
				dividedCLOCK 	<= CLOCK_50;
				currentSTATE 	<= nonFIRST;
			ELSIF currentSTATE = nonFIRST THEN
				IF COUNTER = numberBITSandCOMMA THEN
					COUNTER 		<= 0;
					dividedCLOCK <= '1';
				ELSIF COUNTER = numberBITSandCOMMA/2 THEN
					dividedCLOCK <= '0';
					COUNTER 		<= COUNTER + 1;
				ELSE
					COUNTER 		<= COUNTER + 1;
				END IF;
			ELSE 
				currentSTATE 	<= FIRST;
				COUNTER			<= 0;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE BEHV;