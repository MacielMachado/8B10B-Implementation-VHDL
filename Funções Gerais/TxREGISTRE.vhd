LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

--- Registrador de Deslocamento

ENTITY TxREGISTRE IS 
	GENERIC (n : INTEGER := 10);
				
	PORT(	CLK_0					: IN	STD_LOGIC;
			CLK_90				: IN	STD_LOGIC;
			CLK_180				: IN	STD_LOGIC;
			CLK_270				: IN	STD_LOGIC;
			PARALLEL_IN_0		: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (OTHERS => '0');----------------------------------------------------
			PARALLEL_OUT_0		: OUT	STD_LOGIC_VECTOR(n-1 downto 0) := (OTHERS => '0');-----------------------------
			PARALLEL_IN_90		: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (OTHERS => '0');----------------------------------------------------
			PARALLEL_OUT_90	: OUT	STD_LOGIC_VECTOR(n-1 downto 0) := (OTHERS => '0');-----------------------------
			PARALLEL_IN_180	: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (OTHERS => '0');----------------------------------------------------
			PARALLEL_OUT_180	: OUT	STD_LOGIC_VECTOR(n-1 downto 0) := (OTHERS => '0');-----------------------------
			PARALLEL_IN_270	: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (OTHERS => '0');----------------------------------------------------
			PARALLEL_OUT_270	: OUT	STD_LOGIC_VECTOR(n-1 downto 0) := (OTHERS => '0');-----------------------------
			ENABLE				: IN 	STD_LOGIC;
			S_IN 					: IN	STD_LOGIC;
			RESET					: IN 	STD_LOGIC
			);
END ENTITY TxREGISTRE;

ARCHITECTURE behv OF TxREGISTRE IS

	CONSTANT LOAD_0 : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (others => '0');
	TYPE STATES_0 IS (first, nonFIRST);
	SIGNAL currentSTATE_0 	: STATES_0 := first;
	SIGNAL currentSTATE_90 	: STATES_0 := first;
	SIGNAL currentSTATE_180 : STATES_0 := first;
	SIGNAL currentSTATE_270 : STATES_0 := first;

BEGIN

	-------------------------------------- 0°----------------------------------------------

	DESLOCAMENTO_0 : PROCESS(CLK_0)
	BEGIN
		IF RESET = '1' THEN
			currentSTATE_0 	<= first;
			PARALLEL_OUT_0 	<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK_0) THEN
			IF currentSTATE_0 = first THEN
				IF ENABLE /= '1' THEN 
					PARALLEL_OUT_0 <= LOAD_0;
				ELSE
					PARALLEL_OUT_0(PARALLEL_OUT_0'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_0(PARALLEL_IN_0'LENGTH-1 DOWNTO 1);
					currentSTATE_0 <= nonFIRST;
				END IF;
			END IF;
			IF currentSTATE_0 = first THEN
				IF ENABLE = '1' THEN
					currentSTATE_0 <= nonFIRST;
					PARALLEL_OUT_0(PARALLEL_OUT_0'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_0(PARALLEL_IN_0'LENGTH-1 DOWNTO 1);	
				END IF;
			ELSE
					PARALLEL_OUT_0(PARALLEL_OUT_0'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_0(PARALLEL_IN_0'LENGTH-1 DOWNTO 1);
			END IF;
		END IF;
		
	END PROCESS;
	
	-------------------------------------- 90 ----------------------------------------------
	
	
	DESLOCAMENTO_90 : PROCESS(CLK_90)
	BEGIN
		IF RESET = '1' THEN
			currentSTATE_90 	<= first;
			PARALLEL_OUT_90 	<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK_90) THEN
			IF currentSTATE_90 = first THEN
				IF ENABLE /= '1' THEN 
					PARALLEL_OUT_90 <= LOAD_0;
				ELSE
					PARALLEL_OUT_90(PARALLEL_OUT_90'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_90(PARALLEL_IN_90'LENGTH-1 DOWNTO 1);
					currentSTATE_90 <= nonFIRST;
				END IF;
			END IF;
			IF currentSTATE_90 = first THEN
				IF ENABLE = '1' THEN
					currentSTATE_90 <= nonFIRST;
					PARALLEL_OUT_90(PARALLEL_OUT_90'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_90(PARALLEL_IN_90'LENGTH-1 DOWNTO 1);	
				END IF;
			ELSE
					PARALLEL_OUT_90(PARALLEL_OUT_90'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_90(PARALLEL_IN_90'LENGTH-1 DOWNTO 1);
			END IF;
		END IF;
		
	END PROCESS;
	
	-------------------------------------- 180 ----------------------------------------------

	
	DESLOCAMENTO_180 : PROCESS(CLK_180)
	BEGIN
		IF RESET = '1' THEN
			currentSTATE_180 	<= first;
			PARALLEL_OUT_180 	<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK_180) THEN
			IF currentSTATE_180 = first THEN
				IF ENABLE /= '1' THEN 
					PARALLEL_OUT_180 <= LOAD_0;
				ELSE
					PARALLEL_OUT_180(PARALLEL_OUT_180'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_180(PARALLEL_IN_180'LENGTH-1 DOWNTO 1);
					currentSTATE_180 <= nonFIRST;
				END IF;
			END IF;
			IF currentSTATE_180 = first THEN
				IF ENABLE = '1' THEN
					currentSTATE_180 <= nonFIRST;
					PARALLEL_OUT_180(PARALLEL_OUT_180'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_180(PARALLEL_IN_180'LENGTH-1 DOWNTO 1);	
				END IF;
			ELSE
					PARALLEL_OUT_180(PARALLEL_OUT_180'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_180(PARALLEL_IN_180'LENGTH-1 DOWNTO 1);
			END IF;
		END IF;
		
	END PROCESS;
	
	-------------------------------------- 270 ----------------------------------------------
	
	DESLOCAMENTO_270 : PROCESS(CLK_270)
	BEGIN
		IF RESET = '1' THEN
			currentSTATE_270 	<= first;
			PARALLEL_OUT_270 	<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK_270) THEN
			IF currentSTATE_270 = first THEN
				IF ENABLE /= '1' THEN 
					PARALLEL_OUT_270 <= LOAD_0;
				ELSE
					PARALLEL_OUT_270(PARALLEL_OUT_270'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_270(PARALLEL_IN_270'LENGTH-1 DOWNTO 1);
					currentSTATE_270 <= nonFIRST;
				END IF;
			END IF;
			IF currentSTATE_270 = first THEN
				IF ENABLE = '1' THEN
					currentSTATE_270 <= nonFIRST;
					PARALLEL_OUT_270(PARALLEL_OUT_270'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_270(PARALLEL_IN_270'LENGTH-1 DOWNTO 1);	
				END IF;
			ELSE
					PARALLEL_OUT_270(PARALLEL_OUT_270'length-1 DOWNTO 0) <=  S_IN & PARALLEL_IN_270(PARALLEL_IN_270'LENGTH-1 DOWNTO 1);
			END IF;
		END IF;
		
	END PROCESS;
	
END ARCHITECTURE behv;