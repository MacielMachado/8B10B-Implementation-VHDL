LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Rx IS
	PORT(	RESET 				: IN 	STD_LOGIC;
			CLOCK_50 			: IN 	STD_LOGIC;
			S_IN					: IN 	STD_LOGIC;
			Rx_Tx					: OUT STD_LOGIC;
			ABCDEFGH				: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
		 );
END ENTITY Rx;

ARCHITECTURE BEHV OF RX IS

	COMPONENT clockWAIT IS
		PORT( CLOCK_50 : IN 	STD_LOGIC;
				newCLOCK	: OUT STD_LOGIC;
				RESET		: IN	STD_LOGIC
			);
		END COMPONENT clockWAIT;

	COMPONENT pll IS
		PORT(	inclk0: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC ;
				c1		: OUT STD_LOGIC ;
				c2		: OUT STD_LOGIC ;
				c3		: OUT STD_LOGIC ;
				locked: OUT STD_LOGIC 
			);
		END COMPONENT pll;

	COMPONENT clockDIVIDER IS
		GENERIC (numberBITSandCOMMA : INTEGER := 20);
	
			PORT (	CLOCK_50 	: IN STD_LOGIC;
				dividedCLOCK: OUT STD_LOGIC;
				RESET	: IN STD_LOGIC);
	END COMPONENT;
	
	-- Recebe os dados seriais do Tx e os armazena
	COMPONENT TxREGISTRE IS	
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
	END COMPONENT;
	
	-- Encontra os pacotes com dados
	COMPONENT commaDETECTOR IS
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
		END COMPONENT;
		
	
	-- Serializa os dados recebidos
	COMPONENT ENVOYEUR IS
			PORT(	CLK 	: IN STD_LOGIC;
					S_OUT : OUT STD_LOGIC;
					PARALLEL_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0)
				 );
	END COMPONENT;
	
	-- Tira a complementação dos pacotes
	COMPONENT complementationRECOVER IS
		PORT(	SBYTECLK						: 	IN  STD_LOGIC;
				abcdeifghj 					: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				comma 						: 	IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
				abcdeifghj_complemented	: 	OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
				RD_1							:  OUT INTEGER;
				RD_2							:  OUT INTEGER;
				RD_comeback_STEP_1		:  IN  INTEGER;
				RD_comeback_STEP_2  		:  IN  INTEGER;
				CurRD6						:  OUT INTEGER;
				CurRD4						:  OUT INTEGER
			);
	END COMPONENT complementationRECOVER;
	
	-- Decodifica 6B/5B
	COMPONENT ABCDErecover IS
		PORT(	abcdeifghj 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				ABCDE			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
				SBYTECLK		: IN STD_LOGIC
			);
	END COMPONENT;

	-- Decodifica 4B/3B
	COMPONENT FGHrecover IS
		PORT(	abcdeifghj 	: IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
				FGH			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				SBYTECLK		: IN 	STD_LOGIC
			);
	END COMPONENT;
	
	COMPONENT decodedPCKT_GENERATOR IS
		PORT(	ABCDE 	: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
				FGH 		: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
				BYTECLK	: IN 	STD_LOGIC;
				ABCDEGH	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				readyRX	: OUT STD_LOGIC := '0';
				RESET		: IN	STD_LOGIC
			);
	END COMPONENT;
	
	SIGNAL shift_reg_out0 				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL shift_reg_out90				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL shift_reg_out180				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL shift_reg_out270				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Rx_VALUE_RECEIVED_SIGNAL	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL READY_TO_READ					: STD_LOGIC;
	SIGNAL CHOCOLATE 		 				: STD_LOGIC;
	SIGNAL FOUND							: STD_LOGIC;
	SIGNAL COMMA_signal					: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL abcdeifghj_complemented	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL ABCDE_SIGNAL					: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL FGH_SIGNAL						: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL BYTECLK							: STD_LOGIC;
	SIGNAL RD_1_SIGNAL					: INTEGER;
	SIGNAL RD_2_SIGNAL					: INTEGER;
	SIGNAL CurRD4_SIGNAL					: INTEGER;
	SIGNAL CurRD6_SIGNAL					: INTEGER;
	SIGNAL COUNTER_SIGNAL				: INTEGER 	:= 0;
	SIGNAL Rx_VALUE_RECEIVED			: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL decodedPCKT					: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL readyRX							: STD_LOGIC := '0';
	SIGNAL CLK_0							: STD_LOGIC := '0';
	SIGNAL CLK_90							: STD_LOGIC := '0';
	SIGNAL CLK_180							: STD_LOGIC := '0';
	SIGNAL CLK_270							: STD_LOGIC := '0';
	SIGNAL CLOCK_50new					: STD_LOGIC;
	
	
BEGIN

	L0 : clockWAIT						PORT MAP( CLOCK_50 	=> CLOCK_50,
														 newCLOCK	=> CLOCK_50new,
														 RESET		=> "NOT"(RESET));

  	
	L1	: clockDIVIDER					PORT MAP(CLOCK_50			=> CLOCK_50new,			
														dividedCLOCK => BYTECLK, 
														RESET => '0');
														
	L2 : TxREGISTRE 					PORT MAP(CLK_0 				=> CLK_0,
														CLK_90				=> CLK_90,
														CLK_180				=> CLK_180,
														CLK_270				=> CLK_270,
														PARALLEL_IN_0 		=> shift_reg_out0,
														PARALLEL_OUT_0 	=> shift_reg_out0,
														PARALLEL_IN_90 	=> shift_reg_out90,
														PARALLEL_OUT_90	=> shift_reg_out90,
														PARALLEL_IN_180	=> shift_reg_out180,
														PARALLEL_OUT_180	=> shift_reg_out180,
														PARALLEL_IN_270 	=> shift_reg_out270,
														PARALLEL_OUT_270 	=> shift_reg_out270,
														ENABLE				=> '1',
														S_IN 					=> S_IN,
														RESET					=> "NOT"(RESET));
														
	L3 : commaDETECTOR 				PORT MAP(shiftRegister => shift_reg_out0, ---------------------------------------
														CLK => CLOCK_50NEW, 
														RESET => "NOT"(RESET), 
														found => FOUND, 
														dataVALUE => Rx_VALUE_RECEIVED_SIGNAL, 
														READY => READY_TO_READ, 
														COMMA => COMMA_signal);
														
	L4 : ENVOYEUR   					PORT MAP(CLK => CLOCK_50new,
														S_OUT => CHOCOLATE, 
														PARALLEL_IN => shift_reg_out0);
														
	L5	: complementationRECOVER 	PORT MAP(SBYTECLK=> BYTECLK, 
														abcdeifghj => Rx_VALUE_RECEIVED_SIGNAL, 
														comma => COMMA_signal, 
														abcdeifghj_complemented => abcdeifghj_complemented, 
														RD_1 => RD_1_SIGNAL, 
														RD_2 => RD_2_SIGNAL, 
														RD_comeback_STEP_1 => RD_1_SIGNAL, 
														RD_comeback_STEP_2 => RD_2_SIGNAL, 
														CurRD6 => CurRD6_SIGNAL, 
														CurRD4 => CurRD4_SIGNAL);
														
	L6 : ABCDErecover					PORT MAP(abcdeifghj=>abcdeifghj_complemented, 
														ABCDE => ABCDE_SIGNAL, 
														SBYTECLK => BYTECLK);
														
	L7 : FGHrecover					PORT MAP(abcdeifghj=>abcdeifghj_complemented, 
														FGH   => FGH_SIGNAL, 
														SBYTECLK => BYTECLK);
														
	L8	: decodedPCKT_GENERATOR		PORT MAP(ABCDE 	=> ABCDE_SIGNAL, 
														FGH 		=> FGH_SIGNAL, 
														BYTECLK 	=> BYTECLK, 
														ABCDEGH 	=> ABCDEFGH, 
														readyRX 	=> readyRX,
														RESET		=> "NOT"(RESET));
														
	
	L9 : pll								PORT MAP(inclk0      => CLOCK_50,
														C0				=> CLK_0,
														C1				=> CLK_90,
														C2				=> CLK_180,
														C3				=> CLK_270);
	
	Rx_Tx <= CHOCOLATE;	
	Rx_VALUE_RECEIVED <= Rx_VALUE_RECEIVED_SIGNAL;
END ARCHITECTURE BEHV;