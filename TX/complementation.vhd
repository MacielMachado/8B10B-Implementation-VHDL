LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY complementation IS
	PORT(	abcdei					: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
			fghj						: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
			CurRD4					: IN 	INTEGER;
			CurRD6					: IN 	INTEGER;
			runningDisparity		: IN 	INTEGER;
			BYTECLK					: IN 	STD_LOGIC;
			COMPLS4					: OUT STD_LOGIC := '0';
			COMPLS6					: OUT STD_LOGIC := '0';
			runningDisparity_OUT	: OUT INTEGER := -1;
			RESET						: IN 	STD_LOGIC;
			abcdeifghj				: OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
			send						: OUT	STD_LOGIC := '0';
			comma_abcdeifghj		: OUT STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0');
			comma_out				: OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
END ENTITY complementation;

-- Calculamos a CurRD6 e CurRD4 a partir das 
-- entradas abcdei e fghj, respectivamente

ARCHITECTURE arch OF complementation IS
	TYPE 	 STATE_TYPE IS 	(firstCONVERSION, nonFirstCONVERSION);
	SIGNAL nxtRD6_sgn 		: INTEGER;
	SIGNAL nxtRD4_sgn 		: INTEGER;
	SIGNAL RD_SIGNAL	: INTEGER;
	SIGNAL STATE		: STATE_TYPE;
	CONSTANT COMMA		: STD_LOGIC_VECTOR(9 DOWNTO 0) := "1100000101";
	BEGIN
	
	PROCESS(BYTECLK)
		VARIABLE nxtRD4 : INTEGER;
		VARIABLE nxtRD6 : INTEGER;
		-- As variaveis a cima (nxtRD4 e nxtRD6) foram criadas para 
		-- implementar o novo valor do running_disparity sem precisar
		-- esperar pelo pr�?�?�?�??�?�??�?³ximo ciclo de clock.
		VARIABLE abcdeifghj_var : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
		-- A variavel a cima foi criada uma vez que queremos atribuir
		-- o valor de um sinal a outro em tempo real, i.e., sem esperar
		-- um ciclo de clock.
	BEGIN
	
	IF RESET = '1' THEN
		STATE 	<= firstCONVERSION;
		COMPLS4	<= '0';
		COMPLS6	<= '0';
		runningDisparity_OUT <= -1;
		abcdeifghj 				<= (OTHERS => '0');
		send						<= '0';
		comma_abcdeifghj   	<= (OTHERS => '0');
		comma_out				<= (OTHERS => '0');
		STATE <= firstCONVERSION;
		
	--END IF;
	ELSIF RISING_EDGE(BYTECLK) THEN
	------ CurRDx = 0 -> NAO MEXEMOS NOS BITS
		IF CurRD4 = 0 THEN
			COMPLS4 <= '0';
			abcdeifghj(3 DOWNTO 0) 			<= fghj;
			abcdeifghj_var(3 DOWNTO 0) 	:= fghj;
			nxtRD4  :=  0;
		END IF;
		
		IF CurRD6 = 0 THEN
			COMPLS6 <= '0';
			abcdeifghj(9 DOWNTO 4) 			<= abcdei;
			abcdeifghj_var(9 DOWNTO 4)		:= abcdei;
			nxtRD6  :=  0;
		END IF;
	--END IF;
	-----------------------------------------
	
	------ CurRDx /= 0 -> MEXEMOS NOS BITS
		IF 	(runningDisparity = -1) and (CurRD6 /= 0) THEN
			STATE <= nonFirstCONVERSION;
			send <= '1';
			COMPLS6 <= '1';
			abcdeifghj(9 DOWNTO 4) 			<= NOT(abcdei);
			abcdeifghj_var(9 DOWNTO 4) 	:= NOT(abcdei);
			IF CurRD6 > 0 THEN
				nxtRD6 := -2;
			ELSE
				nxtRD6 := +2;
			END IF;
			
		ELSIF (runningDisparity = 1) 	and (CurRD6 /= 0) THEN
			STATE <= nonFirstCONVERSION;
			send <= '1';
			COMPLS6 <= '0';
			abcdeifghj(9 DOWNTO 4)		 	<= abcdei;
			abcdeifghj_var(9 DOWNTO 4) 	:= abcdei;
			nxtRD6 := CurRD6;
		END IF;
		
		IF 	(runningDisparity = -1) and (CurRD4 /= 0) THEN
			STATE <= nonFirstCONVERSION;
			send <= '1';
			COMPLS4 <= '0';
			abcdeifghj(3 DOWNTO 0) 			<= fghj;
			abcdeifghj_var(3 DOWNTO 0) 	:= fghj;
			nxtRD4  := CurRD4;
		ELSIF (runningDisparity = 1) 	and (CurRD4 /= 0) THEN
			STATE <= nonFirstCONVERSION;
			send <= '1';
			COMPLS4 <= '1';
			abcdeifghj(3 DOWNTO 0) 			<= NOT(fghj);
			abcdeifghj_var(3 DOWNTO 0) 	:= NOT(fghj);
			IF CurRD4 > 0 THEN
				nxtRD4 := -2;
			ELSE
				nxtRD4 := +2;
			END IF;
		END IF;
		IF STATE = firstCONVERSION THEN
			--runningDisparity_OUT <= -1 + nxtRD4 + nxtRD6;
			comma_abcdeifghj(19 downto 10) <= abcdeifghj_var;
			STATE <= nonFirstCONVERSION;
			nxtRD4_sgn <= nxtRD4;
			nxtRD6_sgn <= nxtRD6;
			
			IF -1 + nxtRD4 + nxtRD6 >= 0 THEN 
				IF (-1 + nxtRD4 + nxtRD6 -2) = -1 THEN
					comma_abcdeifghj(9 downto 0) <= comma;
					comma_out(9 downto 0) <= comma;
				END IF;
				runningDisparity_OUT <= -1 + nxtRD4 + nxtRD6 -2;
				-- Se o running disparity sem o pacote virgula for +1, iremos colocar um virgula com disparidade -2;
			ELSE
				IF (-1 + nxtRD4 + nxtRD6 +2) = 1 THEN 
					comma_abcdeifghj(9 downto 0) <= NOT(comma);
					comma_out(9 downto 0) <= NOT(comma);
				END IF;
				runningDisparity_OUT <= -1 + nxtRD4 + nxtRD6 +2;
				-- Se o running disparity sem o pacote virgula for -1, iremos colocar uma virgula com disparidade +2;
			END IF;
			
		ELSE
			--runningDisparity_OUT <= runningDisparity + nxtRD4 + nxtRD6;
			send <= '1';
			nxtRD4_sgn <= nxtRD4;
			nxtRD6_sgn <= nxtRD6;
			comma_abcdeifghj(19 downto 10) <= abcdeifghj_var;
			
			IF runningDisparity + nxtRD4 + nxtRD6 >= 0 THEN
				IF runningDisparity + nxtRD4 + nxtRD6 -2 = -1 THEN
					comma_abcdeifghj(9 downto 0) <= comma;
					comma_out(9 downto 0) <= comma;
				END IF;
				runningDisparity_OUT <= runningDisparity + nxtRD4 + nxtRD6 -2;
				-- Se o running disparity sem o pacote virgula for +1, iremos colocar um virgula com disparidade -2;

			ELSE
				IF runningDisparity + nxtRD4 + nxtRD6 +2 = 1 THEN 
					comma_abcdeifghj(9 downto 0) <= NOT(comma);
					comma_out(9 downto 0) <= NOT(comma);
				END IF;
				runningDisparity_OUT <= runningDisparity + nxtRD4 + nxtRD6 +2;
				-- Se o running disparity sem o pacote virgula for -1, iremos colocar uma virgula com disparidade +2;

			END IF;
		END IF;
		
		---------------------------------------
		--RD_SIGNAL <= runningDisparity_OUT;
		END IF;
	END PROCESS;
END ARCHITECTURE;