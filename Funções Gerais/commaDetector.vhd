LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- ESTA  FUNCAO  TEM  O OBJETIVO DE ENCONTRAR UM  PACOTE VIRGULA
-- NO REGISTRADOR DE DESLOCAMENTO, SE ESTE PACOTE FOR ENCONTRADO
-- SABEMOS QUE  OS  PROXIMOS  N  BITS  SERAO  DO PACOTE DE DADOS.
-- ASSIM, IREMOS ARMAZENAR ESTES N BITS.

ENTITY commaDetector IS
	GENERIC (comma1 : STD_LOGIC_VECTOR	:= "0011111010";-- VIRGULA POSITIVA
				comma2 : STD_LOGIC_VECTOR	:= "1100000101";	-- VIRGULA NEGATIVA	
				N		 : INTEGER				:=  10
				);
				
	PORT(	shiftRegister	: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			CLK				: IN 	STD_LOGIC;
			RESET				: IN 	STD_LOGIC;
			found				: OUT STD_LOGIC := '0';
			dataValue		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
			ready				: OUT STD_LOGIC := '0';
			comma 			: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0')
			);
END ENTITY commaDetector;

ARCHITECTURE comma_arch OF commaDetector IS
	TYPE STATES IS (lookingForComma, data);
	SIGNAL currentSTATE : STATES := lookingForComma;
BEGIN
	PROCESS(CLK)
		VARIABLE COUNTER : INTEGER := 0;
		VARIABLE dataVARIABLE : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	BEGIN
	
	IF RESET = '1' THEN
		currentSTATE	<= lookingForComma;
		FOUND 			<= '0';
		COUNTER 			:=  0;
		dataValue		<= (OTHERS => '0');
		ready				<= '0';
		comma				<= (OTHERS => '0');
		
	ELSIF RISING_EDGE(CLK) THEN
	CASE currentSTATE IS
		WHEN lookingForComma =>
			IF shiftRegister = comma1 or shiftRegister = comma2 THEN
				found <= '1';
				currentSTATE <= data;
				COUNTER := 0;
				comma <= shiftRegister;
			END IF;
			
		WHEN data => 
		
			IF counter /= N THEN
				dataVARIABLE(counter) := shiftRegister(N-1);
				counter := counter + 1;
				ready	  <= '0';
			
			ELSE
				currentSTATE 	<= lookingForComma;
				dataVALUE 		<= dataVARIABLE;
				ready 			<= '1';
				counter 			:= 0;
				found				<= '0';
			END IF;
			END CASE;
	END IF;
	END PROCESS;
END ARCHITECTURE comma_arch;