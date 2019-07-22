LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY complementationRECOVER IS
	PORT	(	SBYTECLK						: 	IN  STD_LOGIC;
				abcdeifghj 					: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				comma 						: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				abcdeifghj_complemented	: 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');---------------------------------------------------------------
				RD_1							:  OUT INTEGER;
				RD_2							:  OUT INTEGER;
				RD_comeback_STEP_1		:  IN  INTEGER;
				RD_comeback_STEP_2  		:  IN  INTEGER;
				CurRD6						:  OUT INTEGER;
				CurRD4						:  OUT INTEGER
				--Dcomma_out_recover			:  OUT STD_LOGIC_VECTOR(9 DOWNTO 0) <= (OTHERS => ;
				--abcdeifghj_RECEIVED		:  OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
			);
END ENTITY complementationRECOVER;

ARCHITECTURE BEHV OF complementationRECOVER IS
CONSTANT COMMA_CSTNT : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1100000101";
SIGNAL   runningDISPARITY : INTEGER; 

--	
--	IF (COMMA = COMMA_CSTNT)  THEN -- RD = -1
--		RD <= -1;	
--	ELSIF (COMMA = NOT(COMMA_CSTNT))  THEN -- RD = 1
--		RD <= 1;	
--	END IF;
BEGIN
	recovery : PROCESS(SBYTECLK)
		BEGIN
		IF RISING_EDGE(SBYTECLK) THEN
			IF (COMMA = (COMMA_CSTNT)) THEN -- RD = -1
				RD_1 <= -1;
			ELSE 
				RD_1 <=1;
			END IF; -- RD_1
			RD_2 <= RD_comeback_STEP_1;
			
			--comma_out_recover <= comma;
			--abcdeifghj_RECEIVED <= abcdeifghj;
			IF RD_comeback_STEP_2 = -1 THEN -- RD = -1
			runningDISPARITY <= -1;
				IF (conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4))) /= 3 THEN 
					--CurRD6 /= 0
					CurRD6 <= 1;
					abcdeifghj_complemented(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4));
				ELSE
					CurRD6 <= 0;
					abcdeifghj_complemented(9 DOWNTO 4) <=  	(abcdeifghj(9 DOWNTO 4));
				END IF;--CurRD6 /= 0
				abcdeifghj_complemented(3 DOWNTO 0) <= (abcdeifghj(3 DOWNTO 0));
			
			ELSIF RD_comeback_STEP_2 = 1 THEN -- RD = 1
			runningDISPARITY <= 1;
				abcdeifghj_complemented(9 DOWNTO 4) <= (abcdeifghj(9 DOWNTO 4));
				IF conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0)) /= 2 THEN
					-- CurRD4 /= 0
					CurRD4 <= 1;
					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
				ELSE
					CurRD6 <= 0;
					abcdeifghj_complemented(3 DOWNTO 0) <= (abcdeifghj(3 DOWNTO 0));
				END IF; -- CurRD4 =/ 0
				abcdeifghj_complemented(9 DOWNTO 4) <=  	(abcdeifghj(9 DOWNTO 4));
			END IF; -- COMMA				
		END IF; -- RISING_EDGE(SBYTECLK)
	END PROCESS;
END ARCHITECTURE BEHV;


------------------------------------------------------------------------------------------------
--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;
--
--ENTITY complementationRECOVER IS
--	PORT	(	SBYTECLK						: 	IN  STD_LOGIC;
--				abcdeifghj 					: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
--				comma 						: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
--				abcdeifghj_complemented	: 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
--				RD_1							:  OUT INTEGER;
--				RD_2							:  OUT INTEGER;
--				RD_comeback_STEP_1		:  IN  INTEGER;
--				RD_comeback_STEP_2  		:  IN  INTEGER;
--				CurRD6						:  OUT INTEGER;
--				CurRD4						:  OUT INTEGER;
--				comma_out_recover			:  OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
--				abcdeifghj_RECEIVED		:  OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
--			);
--END ENTITY complementationRECOVER;
--
--ARCHITECTURE BEHV OF complementationRECOVER IS
--CONSTANT COMMA_CSTNT : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1100000101";
--SIGNAL   runningDISPARITY : INTEGER; 
--
----	
----	IF (COMMA = COMMA_CSTNT)  THEN -- RD = -1
----		RD <= -1;	
----	ELSIF (COMMA = NOT(COMMA_CSTNT))  THEN -- RD = 1
----		RD <= 1;	
----	END IF;
--BEGIN
--	recovery : PROCESS(SBYTECLK)
--		BEGIN
--		IF RISING_EDGE(SBYTECLK) THEN
--			comma_out_recover <= comma;
--			abcdeifghj_RECEIVED <= abcdeifghj;
--			IF (COMMA = (COMMA_CSTNT)) THEN -- RD = -1
--			runningDISPARITY <= -1;
--				IF (conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4))) /= 3 THEN 
--					--CurRD6 /= 0
--					CurRD6 <= 1;
--					abcdeifghj_complemented(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4));
--				ELSE
--					CurRD6 <= 0;
--					abcdeifghj_complemented(9 DOWNTO 4) <=  	(abcdeifghj(9 DOWNTO 4));
--				END IF;--CurRD6 /= 0
--				abcdeifghj_complemented(3 DOWNTO 0) <= (abcdeifghj(3 DOWNTO 0));
--			
--			ELSIF (COMMA = NOT(COMMA_CSTNT)) THEN -- RD = 1
--			runningDISPARITY <= 1;
--				abcdeifghj_complemented(9 DOWNTO 4) <= (abcdeifghj(9 DOWNTO 4));
--				IF conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0)) /= 2 THEN
--					-- CurRD4 /= 0
--					CurRD4 <= 1;
--					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
--				ELSE
--					CurRD6 <= 0;
--					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
--				END IF; -- CurRD4 =/ 0
--				abcdeifghj_complemented(9 DOWNTO 4) <=  	(abcdeifghj(9 DOWNTO 4));
--			END IF; -- COMMA				
----			SUM_6 := conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4));
----			SUM_4 := conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0)); 
----			SUM	:= conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4)) + conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0));
----			IF COMMA = COMMA_CSTNT THEN
----				RD_SIGNAL := -1;
----			ELSE
----				RD_SIGNAL := 1;
----			END IF;
----			IF (RD_SIGNAL = 1) THEN
----				abcdeifghj_complemented(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4);
----				IF SUM_4 /= 2 THEN -- CurRD4 /= 0
----					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
----				ELSE -- CurRD4 = 0
----					abcdeifghj_complemented(3 DOWNTO 0) <= (abcdeifghj(3 DOWNTO 0));
----				END IF;
----			ELSE  -- RD = -1
----				abcdeifghj_complemented(3 DOWNTO 0) <= abcdeifghj(3 DOWNTO 0);
----				IF SUM_6 /= 3 THEN -- CurRD6 /= 0
----					abcdeifghj_complemented(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4));
----				ELSE -- CurRD6 = 0
----					abcdeifghj_complemented(9 DOWNTO 4) <= (abcdeifghj(9 DOWNTO 4));
----				END IF;
----			END IF;
--		END IF; -- RISING_EDGE(SBYTECLK)
--	END PROCESS;
--END ARCHITECTURE BEHV;
----------------------------------------------------------------------------------------------------
--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;
--
--ENTITY complementationRECOVER IS
--	PORT	(	SBYTECLK						: 	IN STD_LOGIC;
--				abcdeifghj 					: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--				comma 						: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--				abcdeifghj_complemented	: 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
--				RD								:  OUT INTEGER
--			);
--END ENTITY complementationRECOVER;
--
--ARCHITECTURE BEHV OF complementationRECOVER IS
--CONSTANT COMMA_CSTNT : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1100000101";
--SIGNAL   SUM_6			: INTEGER;
--SIGNAL 	SUM_4			: INTEGER;
--SIGNAL   SUM         : INTEGER;
--SIGNAL   RD_SIGNAL   : INTEGER;
--SIGNAL   runningDISPARITY : INTEGER; 
--	BEGIN
--	SUM_6 <= conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4));
--	SUM_4 <= conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0)); 
--	SUM	<= conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4)) + conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0));
--	RD_SIGNAL <= -1 WHEN COMMA = COMMA_CSTNT ELSE
--			 1 WHEN COMMA = NOT(COMMA_CSTNT);
--	RD <= RD_SIGNAL;
----	
----	IF (COMMA = COMMA_CSTNT)  THEN -- RD = -1
----		RD <= -1;	
----	ELSIF (COMMA = NOT(COMMA_CSTNT))  THEN -- RD = 1
----		RD <= 1;	
----	END IF;
--	recovery : PROCESS(SBYTECLK)
--		BEGIN
--		IF RISING_EDGE(SBYTECLK) THEN
--			IF (RD_SIGNAL = 1) THEN
--				abcdeifghj_complemented(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4);
--				IF SUM_4 /= 2 THEN -- CurRD4 /= 0
--					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
--				ELSE -- CurRD4 = 0
--					abcdeifghj_complemented(3 DOWNTO 0) <= (abcdeifghj(3 DOWNTO 0));
--				END IF;
--			ELSE  -- RD = -1
--				abcdeifghj_complemented(3 DOWNTO 0) <= abcdeifghj(3 DOWNTO 0);
--				IF SUM_6 /= 3 THEN -- CurRD6 /= 0
--					abcdeifghj_complemented(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4));
--				ELSE -- CurRD6 = 0
--					abcdeifghj_complemented(9 DOWNTO 4) <= (abcdeifghj(9 DOWNTO 4));
--				END IF;
--			END IF;
--			
--		END IF; -- RISING_EDGE(SBYTECLK)
--	END PROCESS;
--END ARCHITECTURE BEHV;
--
-------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------
----LIBRARY IEEE;
----USE IEEE.STD_LOGIC_1164.ALL;
----USE IEEE.STD_LOGIC_ARITH.ALL;
----USE IEEE.NUMERIC_STD.ALL;
----
----ENTITY complementationRECOVER IS
----	PORT	(	SBYTECLK						: 	IN STD_LOGIC;
----				abcdeifghj 					: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0);
----				comma 						: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0);
----				abcdeifghj_complemented	: 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
----				RD								:  OUT INTEGER
----			);
----END ENTITY complementationRECOVER;
----
----ARCHITECTURE BEHV OF complementationRECOVER IS
----CONSTANT COMMA_CSTNT : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1100000101";
----SIGNAL   SUM			: INTEGER;
----SIGNAL   runningDISPARITY : INTEGER; 
----	BEGIN
----	SUM <= conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(5)) + conv_integer(abcdeifghj(4)) + conv_integer(abcdeifghj(3)) + conv_integer(abcdeifghj(2)) + conv_integer(abcdeifghj(1)) + conv_integer(abcdeifghj(0)); 
----	recovery : PROCESS(SBYTECLK)
----		BEGIN
----		IF RISING_EDGE(SBYTECLK) THEN
----			IF (COMMA = COMMA_CSTNT)  THEN -- RD = 1
----				abcdeifghj_complemented(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4);-- RD = -1 
----				RD <= -1;
----				
----				IF (conv_integer(abcdeifghj(3))+conv_integer(abcdeifghj(2))+conv_integer(abcdeifghj(1))+conv_integer(abcdeifghj(0))) /= 2 THEN
----					abcdeifghj_complemented(3 DOWNTO 0) <= NOT(abcdeifghj(3 DOWNTO 0));
----				ELSE
----					abcdeifghj_complemented(3 DOWNTO 0) <= abcdeifghj(3 DOWNTO 0);
----				END IF; -- RD = '1' * CurRD4 /= 0
----				
----			ELSIF (COMMA = NOT(COMMA_CSTNT))  THEN -- RD = -1
----				RD <= 1;
----				IF (conv_integer(abcdeifghj(9))+conv_integer(abcdeifghj(8))+conv_integer(abcdeifghj(7))+conv_integer(abcdeifghj(6))+conv_integer(abcdeifghj(5))+conv_integer(abcdeifghj(4))) /= 3 THEN
----					abcdeifghj_complemented(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4));
----				ELSE
----					abcdeifghj_complemented(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4);
----				END IF; -- RD = -1 * CurRD6 /= 0
----				
----			abcdeifghj_complemented(3 DOWNTO 0) <= abcdeifghj(3 DOWNTO 0); -- RD = 1
----
----			END IF;
----		END IF; -- RISING_EDGE(SBYTECLK)
----	END PROCESS;
----END ARCHITECTURE BEHV;