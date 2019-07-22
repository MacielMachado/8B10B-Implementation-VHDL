LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ABCDErecover IS
	PORT	(	abcdeifghj 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				ABCDE			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
				SBYTECLK		: IN STD_LOGIC
			);
END ENTITY ABCDErecover;

ARCHITECTURE BEHV OF ABCDErecover IS
SIGNAL A_OUT, B_OUT, C_OUT, D_OUT, E_OUT : STD_LOGIC := '0';
SIGNAL SUM 					: INTEGER := 0;
SIGNAL abcdeifghj_SIGNAL: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL CurRD6_signal		: INTEGER;
SIGNAL SUM_1, SUM_2		: INTEGER;
SIGNAL COUNTER 			: INTEGER := 0;
BEGIN
	SUM_1 <= conv_integer(abcdeifghj(4)) + conv_integer(abcdeifghj(5));
	SUM_2 <= conv_integer(abcdeifghj(6)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(9));
	SUM 	<= SUM_1 + SUM_2;
	CurRD6_signal <=	+2 WHEN SUM > 3 ELSE
							-2 WHEN SUM < 3 ELSE
							0;
--	abcdeifghj_SIGNAL(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4)) WHEN CurRD6_signal = -2 ELSE
--													 abcdeifghj(9 DOWNTO 4);	
	RECOVERY : PROCESS(SBYTECLK) 
	BEGIN
		IF RISING_EDGE(SBYTECLK) THEN
		COUNTER <= COUNTER + 1;
		-----------------
		IF (COUNTER > 2) THEN
			IF CurRD6_signal = -2 THEN
				IF abcdeifghj(9 DOWNTO 4) = "101000" THEN
					abcdeifghj_SIGNAL(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4); --ABCDE = "11111"
					
				ELSIF abcdeifghj(9 DOWNTO 4) = "011000" THEN
					abcdeifghj_SIGNAL(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4); --ABCDE = "00000"
					
				ELSIF (SUM = 2) AND abcdeifghj(5 DOWNTO 4) = "10" THEN
					abcdeifghj_SIGNAL(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4); --DADOS QUE JA ERAM ORIGINALMENTE -2
					
				ELSE
					abcdeifghj_SIGNAL(9 DOWNTO 4) <= NOT(abcdeifghj(9 DOWNTO 4)); --DADOS QUE ERAM ORIGINALMENTE +2
				END IF;
			ELSE
					abcdeifghj_SIGNAL(9 DOWNTO 4) <= abcdeifghj(9 DOWNTO 4);
			END IF;
			
			IF abcdeifghj_SIGNAL(9 DOWNTO 4) = "011000" THEN
				A_OUT <= '0';
				B_OUT	<= '0';
				C_OUT <= '0';
				D_OUT <= '0';
			ELSIF abcdeifghj_SIGNAL(9 DOWNTO 4) = "101000" THEN
				A_OUT <= '1';
				B_OUT <= '1';
				C_OUT <= '1';
				D_OUT <= '1';
			ELSE
				A_OUT <= abcdeifghj_SIGNAL(9);
				B_OUT <= abcdeifghj_SIGNAL(8);
				C_OUT <= abcdeifghj_SIGNAL(7);
				D_OUT <= abcdeifghj_SIGNAL(6);
			END IF; -- ABCD recovery
			
			IF (abcdeifghj_SIGNAL(5 DOWNTO 4) = "00") OR (abcdeifghj_SIGNAL(5 DOWNTO 4) = "01") THEN
				E_OUT <= '0';
			ELSIF abcdeifghj_SIGNAL(5 DOWNTO 4) = "11" THEN
				E_OUT <= '1';
			ELSE
				IF (conv_integer(abcdeifghj_SIGNAL(6)) + conv_integer(abcdeifghj_SIGNAL(7)) + conv_integer(abcdeifghj_SIGNAL(8)) + conv_integer(abcdeifghj_SIGNAL(9))) = 1 THEN
					E_OUT <= '0';
				ELSE 
					E_OUT <= '1';
				END IF; -- SUM
			END IF; -- E recovery
			
			ELSE
				A_OUT <= '0';
				B_OUT	<= '0';
				C_OUT <= '0';
				D_OUT <= '0';
				E_OUT <= '0';
			END IF; -- (COUNTER > 1)
			--------------------------------------
		END IF; -- RISING_EDGE
	END PROCESS;
	ABCDE(0) <= E_OUT;
	ABCDE(1) <= D_OUT;
	ABCDE(2) <= C_OUT;
	ABCDE(3) <= B_OUT;
	ABCDE(4) <= A_OUT;
END ARCHITECTURE BEHV;
---------------------------------------------------------------------------------------------------------
--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;
--
--ENTITY ABCDErecover IS
--	PORT	(	abcdeifghj 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--				ABCDE			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
--				SBYTECLK		: IN STD_LOGIC
--			);
--END ENTITY ABCDErecover;
--
--ARCHITECTURE BEHV OF ABCDErecover IS
--SIGNAL A_OUT, B_OUT, C_OUT, D_OUT, E_OUT : STD_LOGIC := '0';
--SIGNAL SUM : INTEGER := 0;
--
--BEGIN
--	SUM <= conv_integer(abcdeifghj(9)) + conv_integer(abcdeifghj(8)) + conv_integer(abcdeifghj(7)) + conv_integer(abcdeifghj(6));
--	RECOVERY : PROCESS(SBYTECLK) 
--	BEGIN
--		IF RISING_EDGE(SBYTECLK) THEN
--			IF (abcdeifghj(9 DOWNTO 6) = "0110") AND (abcdeifghj(4) = '0') THEN
--				A_OUT <= '0';
--				B_OUT	<= '0';
--				C_OUT <= '0';
--				D_OUT <= '0';
--			ELSIF abcdeifghj(9 DOWNTO 6) = "1010" AND (abcdeifghj(4) = '0') THEN
--				A_OUT <= '1';
--				B_OUT <= '1';
--				C_OUT <= '1';
--				D_OUT <= '1';
--			ELSE
--				A_OUT <= abcdeifghj(9);
--				B_OUT <= abcdeifghj(8);
--				C_OUT <= abcdeifghj(7);
--				D_OUT <= abcdeifghj(6);
--			END IF; -- ABCD recovery
--			
--			IF (abcdeifghj(5 DOWNTO 4) = "00") OR (abcdeifghj(5 DOWNTO 4) = "01") THEN
--				E_OUT <= '0';
--			ELSIF abcdeifghj(5 DOWNTO 4) = "11" THEN
--				E_OUT <= '1';
--			ELSE
--				IF SUM = 1 THEN
--					E_OUT <= '0';
--				ELSE 
--					E_OUT <= '1';
--				END IF; -- SUM
--			END IF; -- E recovery
--		END IF; -- RISING_EDGE
--	END PROCESS;
--	ABCDE(4) <= A_OUT;
--	ABCDE(3) <= B_OUT;
--	ABCDE(2) <= C_OUT;
--	ABCDE(1) <= D_OUT;
--	ABCDE(0) <= E_OUT;
--END ARCHITECTURE BEHV;