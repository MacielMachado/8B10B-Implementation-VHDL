LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY abcdeiGENERATOR IS
	PORT(ABCDE_in	:  IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		  BYTECLK	: 	IN  STD_LOGIC;
		  CurRD6		: 	OUT INTEGER;
		  abcdei_out:	OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		  RESET		:	IN	 STD_LOGIC
		  );
END;

ARCHITECTURE behv OF abcdeiGENERATOR IS
	TYPE STATES IS (first, nonFIRST);
	SIGNAL currentSTATE : STATES := first;
	SIGNAL a_out 			: 	STD_LOGIC := '0';
	SIGNAL b_out 			: 	STD_LOGIC := '0';
	SIGNAL c_out 			: 	STD_LOGIC := '0';
	SIGNAL d_out 			: 	STD_LOGIC := '0';
	SIGNAL e_out 			: 	STD_LOGIC := '0';
	SIGNAL i_out 			: 	STD_LOGIC := '0';
	SIGNAL SUM	 			:	INTEGER;
	SIGNAL SUM_BINARY		:	STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL outSUM			: 	INTEGER;
	SIGNAL CurRD6_signal	: 	INTEGER;
	SIGNAL SUM_OUT			: 	INTEGER;
	SIGNAL abcdei_SIGNAL	:  STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL abcdei_RAW		:  STD_LOGIC_VECTOR(5 DOWNTO 0);
	BEGIN
	
	SUM <= conv_integer(ABCDE_in(4))+conv_integer(ABCDE_in(3))+conv_integer(ABCDE_in(2))+conv_integer(ABCDE_in(1));
	SUM_BINARY <= STD_LOGIC_VECTOR(TO_SIGNED(conv_integer(ABCDE_in(4))+conv_integer(ABCDE_in(3))+conv_integer(ABCDE_in(2))+conv_integer(ABCDE_in(1)),2));
	
	PROCESS(BYTECLK,SUM_BINARY)
		BEGIN
		IF RESET = '1' THEN
			a_out <= '0';
			b_out <= '0';
			c_out <= '0';
			d_out <= '0';
			e_out <= '0';
			i_out <= '0';
		
		ELSIF RISING_EDGE(BYTECLK) THEN
			IF (ABCDE_in(4 DOWNTO 1) = "0000") THEN
				a_out <= ABCDE_in(4);
				b_out <= '1';
				c_out <= '1';
				d_out <= ABCDE_in(1);
			
			ELSIF (ABCDE_in(4 DOWNTO 1) = "1111") THEN
				a_out <= ABCDE_in(1);
				b_out <= '0';
				c_out <= ABCDE_in(3);
				d_out <= '0';
				
			ELSE
				a_out <= ABCDE_in(4);
				b_out <= ABCDE_in(3);
				c_out <= ABCDE_in(2);
				d_out <= ABCDE_in(1);
			END IF; -- (ABCDE_in(3 DOWNTO 0) ~= "0000") and (ABCDE_in(3 DOWNTO 0) ~= "0000")
				
			IF (ABCDE_in(0) = '0') THEN
				IF (SUM = 3) OR (SUM = 4) THEN
					e_out <= '0';
					i_out <= '0';
				ELSE
					e_out <= SUM_BINARY(0);
					i_out <= SUM_BINARY(1);
				END IF; -- SUM = 3 OR SUM = 4
			
			ELSE
				IF (SUM = 0) OR (SUM = 1) OR (SUM = 4) THEN
					e_out <= '1';
					i_out <= '1';	

				ELSIF (SUM = 2) OR (SUM = 3) THEN
					e_out <= '1';
					i_out <= '0';
				END IF; 
			END IF; -- E = '0'
		END IF;
		END PROCESS;
		
		outSUM <= conv_integer(a_out)+conv_integer(b_out)+conv_integer(c_out)+conv_integer(d_out)+conv_integer(e_out)+conv_integer(i_out);
		CurRD6_signal <=	+2 WHEN outSUM > 3 ELSE
								-2 WHEN outSUM < 3 ELSE
								0;
			--abcdei_out <= (OTHERS => '0') WHEN currentSTATE = first;
			--currentSTATE <= nonFIRST 		WHEN currentSTATE = first;
		
		abcdei_RAW(5) <= 	(a_out);
									
		abcdei_RAW(4) <= 	(b_out);
									
		abcdei_RAW(3) <=  (c_out);
									
		abcdei_RAW(2) <= 	(d_out);
									
		abcdei_RAW(1) <= 	(e_out);
									
		abcdei_RAW(0) <= 	(i_out);

		-----------------------------------------------------------
			
		abcdei_SIGNAL(5) <= 	NOT(a_out) WHEN CurRD6_signal = 2 ELSE
									(a_out);
									
		abcdei_SIGNAL(4) <= 	NOT(b_out) WHEN CurRD6_signal = 2 ELSE
									(b_out);
									
		abcdei_SIGNAL(3) <=  NOT(c_out) WHEN CurRD6_signal = 2 ELSE
									(c_out);
									
		abcdei_SIGNAL(2) <= 	NOT(d_out) WHEN CurRD6_signal = 2 ELSE
									(d_out);
									
		abcdei_SIGNAL(1) <= 	NOT(e_out) WHEN CurRD6_signal = 2 ELSE
									(e_out);
									
		abcdei_SIGNAL(0) <= 	NOT(i_out) WHEN CurRD6_signal = 2 ELSE
									(i_out);
									
		-----------------------------------------------------------							
		 
		abcdei_out(5) <= 	NOT(a_out) WHEN CurRD6_signal = 2 ELSE
									(a_out);
									
		abcdei_out(4) <= 	NOT(b_out) WHEN CurRD6_signal = 2 ELSE
									(b_out);
									
		abcdei_out(3) <=  NOT(c_out) WHEN CurRD6_signal = 2 ELSE
									(c_out);
									
		abcdei_out(2) <= 	NOT(d_out) WHEN CurRD6_signal = 2 ELSE
									(d_out);
									
		abcdei_out(1) <= 	NOT(e_out) WHEN CurRD6_signal = 2 ELSE
									(e_out);
									
		abcdei_out(0) <= 	NOT(i_out) WHEN CurRD6_signal = 2 ELSE
									(i_out);
					
		SUM_OUT <= conv_integer(abcdei_SIGNAL(5))+conv_integer(abcdei_SIGNAL(4))+conv_integer(abcdei_SIGNAL(3))+conv_integer(abcdei_SIGNAL(2))+conv_integer(abcdei_SIGNAL(1))+conv_integer(abcdei_SIGNAL(0));
		CurRD6 <= 	+2 WHEN SUM_OUT > 3 ELSE
						-2 WHEN SUM_OUT < 3 ELSE
						0;
END ARCHITECTURE behv;