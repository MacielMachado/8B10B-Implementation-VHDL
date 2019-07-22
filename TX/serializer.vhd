LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.NUMERIC_STD.ALL;

---------- TRANSMIT THE PARALLEL DATA AND SERIALIZE IT ----------------
ENTITY serializer IS	
	GENERIC(	cyclesPerBit : INTEGER;						
				numberBitsOfData: INTEGER
				);
				
	PORT(	dataBusIN: IN STD_LOGIC_VECTOR(numberBitsOfData-1 DOWNTO 0);
			reset: IN 	STD_LOGIC;
			clock: IN 	STD_LOGIC;
			dataBusOUT: OUT STD_LOGIC := '0';
			send : IN 	STD_LOGIC;
			enable:OUT	STD_LOGIC := '0';
			busy : OUT 	STD_LOGIC := '0');	
END serializer;

ARCHITECTURE TXarch OF serializer IS
	TYPE	 STATES_TYPE	IS (firstPACK, DATA);
	SIGNAL STATE			: STATES_TYPE := firstPACK;
	SIGNAL transmission 	: STD_LOGIC_VECTOR((numberBitsOfData-1) DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL cycleCounter 	: INTEGER RANGE 0 TO cyclesPerBit;
	SIGNAL cyclesCounter	: INTEGER := 0;
	SIGNAL countBit 		: INTEGER := 0;
	
	BEGIN
	processUartTX : process (clock)
	BEGIN
	
	IF reset = '1' THEN
		countBit <= 0;
		busy <= '0';
		STATE <= firstPACK;
		cyclesCounter <= 0;
		enable <= '0';
		transmission <= (OTHERS => '0');
			
	ELSIF STATE = firstPACK THEN
		BUSY <= '0';
		IF send = '1' THEN
			STATE <= DATA;
			transmission <= dataBusIN;
		END IF;

	ELSIF RISING_EDGE(clock) THEN
		IF STATE = DATA THEN
		cyclesCounter <= cyclesCounter + 1; 
		IF cyclesCounter = cyclesPerBit THEN
			IF countBit = 0 THEN
				dataBusOUT <= transmission(countBit); -- ENVIA UM BIT DO PACOTE
				countBit <= countBit + 1;
				cyclesCounter <= 1;
				enable	<= '1';
			ELSIF countBit = numberBitsOfData THEN 
				cyclesCounter <= 1; -- RESETA O CONTADOR DE CICLOS
				countBit <= 0;
				transmission <= dataBusIN;
				enable	<= '1';
			ELSE
				cyclesCounter <= 1; -- RESETA O CONTADOR DE CICLOS
				dataBusOUT <= transmission(countBit); -- ENVIA UM BIT DO PACOTE
				countBit <= countBit + 1;
				enable	<= '1';
			END IF;
		END IF;	
		END IF;
		END IF;
		END PROCESS;
END ARCHITECTURE;