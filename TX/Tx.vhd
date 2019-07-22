LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Tx_LUT comeca gerando um pacote de dados. Este pacote e recebido em paralelo
-- por abcdeiGENERATOR e fghjGENERATOR que fazem a conversao. Entao estes pacotes
-- convertidos sao recebidos pelo bloco COMPLEMENTATION que ira complementa-los, 
-- garantindo o balanco DC. Entao estes blocos sao serializados e enviados para o
-- Rx. Este enviara os dados recebidos de volta pro Tx que fara a desserializacao
-- e armazenara os dados recebidos.

ENTITY Tx IS
	PORT(	CLOCK_50 	: IN 	STD_LOGIC; -- CONTROLA A SERIALIZACAO
			Tx_Rx			: OUT STD_LOGIC; -- SERIAL PRO RX
			Rx_Tx			: IN 	STD_LOGIC;  -- SERIAL DO RX
			RESET			: IN 	STD_LOGIC := '0';
			inPHASE		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
END ENTITY Tx;

ARCHITECTURE BEHV OF Tx IS

--------------------------- Component Declarition --------------------------------
	COMPONENT clockDIVIDER IS
		GENERIC (numberBITSandCOMMA : INTEGER := 20);
	
			PORT (	CLOCK_50 	: IN STD_LOGIC;
				dividedCLOCK: OUT STD_LOGIC;
				RESET	: IN STD_LOGIC);
	END COMPONENT;
	-- It generates the values to be converted and then sent.
	COMPONENT Tx_LUT IS
			PORT (ABCDE : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
					FGH	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
					CLK	: IN STD_LOGIC;
					ABCDEFGH : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
					readyTX	: OUT STD_LOGIC := '0';
					RESET		: IN	STD_LOGIC
					);
					
	END COMPONENT;
	-- It converts part of the input.
	COMPONENT abcdeiGENERATOR IS
			PORT(	ABCDE_in	:  IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
					BYTECLK	: 	IN 	STD_LOGIC;
					CurRD6	: 	OUT 	INTEGER;
					abcdei_out:	OUT 	STD_LOGIC_VECTOR(5 DOWNTO 0);
					RESET		: 	IN 	STD_LOGIC
					);
	END COMPONENT;
	-- It converts part of the input.
	COMPONENT fghjGENERATOR IS
			PORT(	FGH_in 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
					BYTECLK	: IN 	STD_LOGIC;
					CurRD4	: OUT INTEGER;
					fghj_out	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
					RESET		: IN 	STD_LOGIC
					);
	END COMPONENT;
	-- It complements the future output to keep the DC balance.
	COMPONENT COMPLEMENTATION IS
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
					comma_abcdeifghj		: OUT STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0')
				);
	END COMPONENT;
	-- It serializes the output.
	COMPONENT SERIALIZER IS
	
		GENERIC(	cyclesPerBit : INTEGER := 1;						
					numberBitsOfData: INTEGER := 20
				  );	
			PORT (dataBusIN: IN STD_LOGIC_VECTOR(numberBitsOfData-1 DOWNTO 0);
					reset: IN 	STD_LOGIC;
					clock: IN 	STD_LOGIC;
					dataBusOUT: OUT STD_LOGIC := '0';
					send : IN 	STD_LOGIC;
					enable:OUT	STD_LOGIC := '0';
					busy : OUT 	STD_LOGIC := '0');
	END COMPONENT;
	-- It receives the the message sent by Rx.
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
					ready				: OUT STD_LOGIC := '0'
					);
	END COMPONENT;
		
	COMPONENT PHASE IS
		PORT (	CLK 			: 	IN		STD_LOGIC := '0';
					RESET			: 	IN		STD_LOGIC;
					TX_RESULT	:	IN		STD_LOGIC_vECTOR(7 DOWNTO 0) := (OTHERS => '0');
					inPHASE		:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
				);
	END COMPONENT;
	
	COMPONENT pll IS
		PORT(	inclk0: IN STD_LOGIC  := '0';
				c0		: OUT STD_LOGIC ;
				c1		: OUT STD_LOGIC ;
				c2		: OUT STD_LOGIC ;
				c3		: OUT STD_LOGIC ;
				locked: OUT STD_LOGIC 
			);
	END COMPONENT pll;
--------------------------------------------------------------------------------------
SIGNAL ABCDE 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL FGH 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL CurRD6		: INTEGER;
SIGNAL CurRD4		: INTEGER;
SIGNAL abcdei_out	: STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL fghj_out	: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL abcdeifghj	: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL COMPLS6		: STD_LOGIC;
SIGNAL COMPLS4		: STD_LOGIC;
SIGNAL SEND			: STD_LOGIC;
SIGNAL ENABLE		: STD_LOGIC;
SIGNAL BUSY_TX		: STD_LOGIC;
SIGNAL FOUND		: STD_LOGIC;
SIGNAL comma_abcdeifghj : STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL runningDisparity	: INTEGER; 
SIGNAL BYTECLK				: STD_LOGIC := '0';
SIGNAL READY				: STD_LOGIC;
SIGNAL dataValue	 		: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL readyTX		 		: STD_LOGIC;
SIGNAL ABCDEFGH_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
--SIGNAL inPHASE				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLK_0				: STD_LOGIC := '0';
SIGNAL CLK_90				: STD_LOGIC := '0';
SIGNAL CLK_180				: STD_LOGIC := '0';
SIGNAL CLK_270				: STD_LOGIC := '0';
SIGNAL shift_reg_out0 	: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL shift_reg_out90	: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL shift_reg_out180	: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL shift_reg_out270	: STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
	

		

---------------------------------- Connections ---------------------------------------
		L0	: clockDIVIDER		PORT MAP	( 	CLOCK_50			=> CLOCK_50,			
													dividedCLOCK => BYTECLK, 
													RESET => '0');
													
		L1 : Tx_LUT				PORT MAP ( 	ABCDE		=> ABCDE, 				
													FGH 		=>	FGH,       
													CLK 		=> BYTECLK, 
													ABCDEFGH => ABCDEFGH_OUT, 
													readyTX 	=> readyTX,
													RESET		=>"NOT"(RESET));
													
		L2 : abcdeiGENERATOR PORT MAP ( 	ABCDE_in 	=> ABCDE, 				
													BYTECLK 		=> BYTECLK, 
													CurRD6 		=> CurRD6, 
													abcdei_out 	=> abcdei_out,
													RESET			=> "NOT"(RESET));
													
		L3 : fghjGENERATOR	PORT MAP ( 	FGH_in   => FGH,   				
													BYTECLK 	=> BYTECLK, 
													CurRD4 	=> CurRD4, 
													fghj_out	=> fghj_out,
													RESET		=> "NOT"(RESET));
													
		L4 : COMPLEMENTATION PORT MAP ( 	abcdei   			=> abcdei_out, 		
													fghj    => fghj_out,
													CurRD4 => CurRD4, 
													CurRD6 => CurRD6,
													runningDisparity => runningDisparity,
													BYTECLK => BYTECLK,
													COMPLS4 => COMPLS4,
													COMPLS6 => COMPLS6,
													runningDisparity_OUT => runningDisparity, 
													RESET => "NOT"(RESET),
													abcdeifghj => abcdeifghj,
													send => SEND,
													comma_abcdeifghj => comma_abcdeifghj);
													
		L5 : SERIALIZER		PORT MAP ( 	dataBusIN			=> comma_abcdeifghj,	
													reset   => "NOT"(RESET),	
													clock  => Clock_50, 
													dataBusOUT => Tx_Rx,
													send => SEND, 
													enable => ENABLE,
													busy => BUSY_TX);
													
		L6 : TxREGISTRE		PORT MAP(	CLK_0 				=> CLK_0,
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
													S_IN 					=> Rx_Tx,
													RESET					=> "NOT"(RESET));
													
		L7 : commaDETECTOR	PORT MAP ( 	shiftRegister	=> shift_reg_out0,	
													CLK	=> CLOCK_50,
													RESET => "NOT"(RESET),       
													found => FOUND,
													dataValue => dataValue,
													ready => READY);

		L8	: PHASE				PORT MAP (	CLK => BYTECLK, 
													RESET => "NOT"(RESET), 
													TX_RESULT => ABCDEFGH_OUT, 
													inPHASE => inPHASE
												);
												
		L9 : pll					PORT MAP(	inclk0      => CLOCK_50,
													C0				=> CLK_0,
													C1				=> CLK_90,
													C2				=> CLK_180,
													C3				=> CLK_270
												);
END ARCHITECTURE BEHV;

--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--
---- Tx_LUT comeca gerando um pacote de dados. Este pacote e recebido em paralelo
---- por abcdeiGENERATOR e fghjGENERATOR que fazem a conversao. Entao estes pacotes
---- convertidos sao recebidos pelo bloco COMPLEMENTATION que ira complementa-los, 
---- garantindo o balanco DC. Entao estes blocos sao serializados e enviados para o
---- Rx. Este enviara os dados recebidos de volta pro Tx que fara a desserializacao
---- e armazenara os dados recebidos.
--
--ENTITY Tx IS
--	PORT(	CLOCK_50 	: IN 	STD_LOGIC; -- CONTROLA A SERIALIZACAO
--			dataValue	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- DADOS RECEBIDOS DO RX QUE SERAO ENVIADOS PARA UM PC
--			Tx_Rx			: OUT STD_LOGIC; -- SERIAL PRO RX
--			Rx_Tx			: IN 	STD_LOGIC;  -- SERIAL DO RX
--			READY			: OUT STD_LOGIC;
--			RESET			: IN 	STD_LOGIC := '0';
--			ABCDEFGH_OUT: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--			readyTX		: OUT STD_LOGIC
--		 );
--END ENTITY Tx;
--
--ARCHITECTURE BEHV OF Tx IS
--
----------------------------- Component Declarition --------------------------------
--	COMPONENT clockDIVIDER IS
--		GENERIC (numberBITSandCOMMA : INTEGER := 20);
--	
--			PORT (	CLOCK_50 	: IN STD_LOGIC;
--				dividedCLOCK: OUT STD_LOGIC;
--				RESET	: IN STD_LOGIC);
--	END COMPONENT;
--	-- It generates the values to be converted and then sent.
--	COMPONENT Tx_LUT IS
--			PORT (ABCDE : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
--					FGH	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
--					CLK	: IN STD_LOGIC;
--					ABCDEFGH : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--					readyTX	: OUT STD_LOGIC := '0';
--					RESET		: IN	STD_LOGIC
--					);
--					
--	END COMPONENT;
--	-- It converts part of the input.
--	COMPONENT abcdeiGENERATOR IS
--			PORT(	ABCDE_in	:  IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
--					BYTECLK	: 	IN 	STD_LOGIC;
--					CurRD6	: 	OUT 	INTEGER;
--					abcdei_out:	OUT 	STD_LOGIC_VECTOR(5 DOWNTO 0);
--					RESET		: 	IN 	STD_LOGIC
--					);
--	END COMPONENT;
--	-- It converts part of the input.
--	COMPONENT fghjGENERATOR IS
--			PORT(	FGH_in 	: IN 	STD_LOGIC_VECTOR(2 DOWNTO 0);
--					BYTECLK	: IN 	STD_LOGIC;
--					CurRD4	: OUT INTEGER;
--					fghj_out	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
--					RESET		: IN 	STD_LOGIC
--					);
--	END COMPONENT;
--	-- It complements the future output to keep the DC balance.
--	COMPONENT COMPLEMENTATION IS
--			PORT(	abcdei					: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
--					fghj						: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
--					CurRD4					: IN 	INTEGER;
--					CurRD6					: IN 	INTEGER;
--					runningDisparity		: IN 	INTEGER;
--					BYTECLK					: IN 	STD_LOGIC;
--					COMPLS4					: OUT STD_LOGIC := '0';
--					COMPLS6					: OUT STD_LOGIC := '0';
--					runningDisparity_OUT	: OUT INTEGER := -1;
--					RESET						: IN 	STD_LOGIC;
--					abcdeifghj				: OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
--					send						: OUT	STD_LOGIC := '0';
--					comma_abcdeifghj		: OUT STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0')
--				);
--	END COMPONENT;
--	-- It serializes the output.
--	COMPONENT SERIALIZER IS
--	
--		GENERIC(	cyclesPerBit : INTEGER := 1;						
--					numberBitsOfData: INTEGER := 20
--				  );	
--			PORT (dataBusIN: IN STD_LOGIC_VECTOR(numberBitsOfData-1 DOWNTO 0);
--					reset: IN 	STD_LOGIC;
--					clock: IN 	STD_LOGIC;
--					dataBusOUT: OUT STD_LOGIC := '0';
--					send : IN 	STD_LOGIC;
--					enable:OUT	STD_LOGIC := '0';
--					busy : OUT 	STD_LOGIC := '0');
--	END COMPONENT;
--	-- It receives the the message sent by Rx.
--	COMPONENT TxREGISTRE IS
--	
--		GENERIC (n : INTEGER := 10);
--					
--			PORT(	CLK				: IN	STD_LOGIC;
--					PARALLEL_IN		: IN	STD_LOGIC_VECTOR(n-1 DOWNTO 0);
--					PARALLEL_OUT0	: OUT	STD_LOGIC_VECTOR(n-1 downto 0);
--					ENABLE			: IN 	STD_LOGIC;
--					S_IN 				: IN	STD_LOGIC;
--					RESET				: IN 	STD_LOGIC
--					);
--	END COMPONENT;
--	
--	COMPONENT commaDETECTOR IS
--	
--		GENERIC (comma1 : STD_LOGIC_VECTOR	:= "0011111010";-- VIRGULA POSITIVA
--					comma2 : STD_LOGIC_VECTOR	:= "1100000101";	-- VIRGULA NEGATIVA	
--					N		 : INTEGER				:=  10
--					);
--				
--			PORT(	shiftRegister	: IN 	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
--					CLK				: IN 	STD_LOGIC;
--					RESET				: IN 	STD_LOGIC;
--					found				: OUT STD_LOGIC := '0';
--					dataValue		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
--					ready				: OUT STD_LOGIC := '0'
--					);
--		END COMPONENT;
----------------------------------------------------------------------------------------
--SIGNAL ABCDE 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
--SIGNAL FGH 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
--SIGNAL CurRD6		: INTEGER;
--SIGNAL CurRD4		: INTEGER;
--SIGNAL abcdei_out	: STD_LOGIC_VECTOR(5 DOWNTO 0);
--SIGNAL fghj_out	: STD_LOGIC_VECTOR(3 DOWNTO 0);
--SIGNAL abcdeifghj	: STD_LOGIC_VECTOR(9 DOWNTO 0);
--SIGNAL COMPLS6		: STD_LOGIC;
--SIGNAL COMPLS4		: STD_LOGIC;
--SIGNAL SEND			: STD_LOGIC;
--SIGNAL ENABLE		: STD_LOGIC;
--SIGNAL BUSY_TX		: STD_LOGIC;
--SIGNAL FOUND		: STD_LOGIC;
--SIGNAL comma_abcdeifghj : STD_LOGIC_VECTOR(19 DOWNTO 0);
--SIGNAL shift_reg_out0	: STD_LOGIC_VECTOR( 9 DOWNTO 0);----------------------------------
--SIGNAL runningDisparity	: INTEGER; 
--SIGNAL BYTECLK	: STD_LOGIC := '0';
--BEGIN
--	
--
--		
--
------------------------------------ Connections ---------------------------------------
--		L0	: clockDIVIDER		PORT MAP	( 	CLOCK_50			=> CLOCK_50,			
--													dividedCLOCK => BYTECLK, 
--													RESET => '0');
--													
--		L1 : Tx_LUT				PORT MAP ( 	ABCDE		=> ABCDE, 				
--													FGH 		=>	FGH,       
--													CLK 		=> BYTECLK, 
--													ABCDEFGH => ABCDEFGH_OUT, 
--													readyTX 	=> readyTX,
--													RESET		=> RESET);
--													
--		L2 : abcdeiGENERATOR PORT MAP ( 	ABCDE_in 	=> ABCDE, 				
--													BYTECLK 		=> BYTECLK, 
--													CurRD6 		=> CurRD6, 
--													abcdei_out 	=> abcdei_out,
--													RESET			=> RESET);
--													
--		L3 : fghjGENERATOR	PORT MAP ( 	FGH_in   => FGH,   				
--													BYTECLK 	=> BYTECLK, 
--													CurRD4 	=> CurRD4, 
--													fghj_out	=> fghj_out,
--													RESET		=> RESET);
--													
--		L4 : COMPLEMENTATION PORT MAP ( 	abcdei   			=> abcdei_out, 		
--													fghj    => fghj_out,
--													CurRD4 => CurRD4, 
--													CurRD6 => CurRD6,
--													runningDisparity => runningDisparity,
--													BYTECLK => BYTECLK,
--													COMPLS4 => COMPLS4,
--													COMPLS6 => COMPLS6,
--													runningDisparity_OUT => runningDisparity, 
--													RESET => RESET,
--													abcdeifghj => abcdeifghj,
--													send => SEND,
--													comma_abcdeifghj => comma_abcdeifghj);
--													
--		L5 : SERIALIZER		PORT MAP ( 	dataBusIN			=> comma_abcdeifghj,	
--													reset   => RESET,	
--													clock  => Clock_50, 
--													dataBusOUT => Tx_Rx,
--													send => SEND, 
--													enable => ENABLE,
--													busy => BUSY_TX);
--													
--		L6 : TxREGISTRE		PORT MAP ( 	CLK				=> Clock_50,			
--													PARALLEL_IN 	=> shift_reg_out0,       
--													PARALLEL_OUT0 	=> shift_reg_out0,
--													ENABLE 			=> ENABLE,
--													S_IN 				=> Rx_Tx,
--													RESET				=> RESET);
--													
--		L7 : commaDETECTOR	PORT MAP ( 	shiftRegister	=> shift_reg_out0,	
--													CLK	=> CLOCK_50,
--													RESET => RESET,       
--													found => FOUND,
--													dataValue => dataValue,
--													ready => READY);
--
--END ARCHITECTURE BEHV;


------------------------------- TESTE -------------------------

