LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE tbBEHV OF testbench IS
	CONSTANT clockCYCLE	: TIME := 20 ns;
	SIGNAL RESET : STD_LOGIC := '0';
	SIGNAL CLOCK_50 : STD_LOGIC := '0';
	SIGNAL numberOfERRORS : INTEGER;
BEGIN
	DUT1 : ENTITY work.tx_rx_8B10B
	PORT MAP	(	RESET 	=> RESET,
					CLOCK_50	=> CLOCK_50,
					numberOfERRORS => numberOfERRORS
				);
				
					
	HORLOGE : PROCESS
	BEGIN
		CLOCK_50 <= '0';
		WAIT FOR clockCYCLE/2;
		CLOCK_50 <= '1';
		WAIT FOR clockCYCLE/2;
	END PROCESS;
	

	RESET <= '1';
				
				
END ARCHITECTURE tbBEHV;