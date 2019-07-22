LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tx_rx_8B10B IS
	PORT 	(	RESET 	: 	IN	STD_LOGIC := '0';
				CLOCK_50	:	IN	STD_LOGIC;
				numberOfERRORS : OUT INTEGER := 0
			);
END ENTITY tx_rx_8B10B;

ARCHITECTURE BEHV OF tx_rx_8B10B IS
	
	COMPONENT Tx IS
	PORT(	CLOCK_50 	: IN 	STD_LOGIC; -- CONTROLA A SERIALIZACAO
			Tx_Rx			: OUT STD_LOGIC; -- SERIAL PRO RX
			Rx_Tx			: IN 	STD_LOGIC;  -- SERIAL DO RX
			RESET			: IN 	STD_LOGIC;
			inPHASE		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	
	COMPONENT Rx IS
	PORT(	RESET 				: IN 	STD_LOGIC;
			CLOCK_50 			: IN 	STD_LOGIC;
			S_IN					: IN 	STD_LOGIC; --DADO ORIGINARIO DO Tx
			Rx_Tx					: OUT STD_LOGIC;
			ABCDEFGH				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		 );
	END COMPONENT;
	
		
	COMPONENT clockDIVIDER IS
	GENERIC (numberBITSandCOMMA : INTEGER := 20);
	
	PORT(	CLOCK_50 	: IN 	STD_LOGIC;
			dividedCLOCK: OUT STD_LOGIC;
			RESET			: IN 	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT PHASE IS
	PORT (	CLK 			: 	IN		STD_LOGIC := '0';
				RESET			: 	IN		STD_LOGIC;
				TX_RESULT	:	IN		STD_LOGIC_vECTOR(7 DOWNTO 0) := (OTHERS => '0');
				inPHASE		:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
	END COMPONENT;
	
	
	COMPONENT COUNTER IS
	GENERIC	(  THRESHOLD 	: INTEGER := 1000;
					fifoSIZE		: INTEGER := 64);
					
	PORT		(	CLK 			: IN 	STD_LOGIC;
					COUNTER 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
					WRITE_FIFO 	: OUT STD_LOGIC := '0';
					AGAIN			: IN 	STD_LOGIC := '1'
				);
	END COMPONENT COUNTER;
	
	COMPONENT errorCOUNTER IS
		PORT (	txPCKT	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				rxPCKT	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				BYTECLK	: IN 	STD_LOGIC;
				error		: OUT INTEGER;
				RESET		: IN 	STD_LOGIC
			);
	END COMPONENT errorCOUNTER;

	SIGNAL dataValue 						: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Tx_Rx_SIGNAL					: STD_LOGIC;
	SIGNAL Rx_Tx_SIGNAL					: STD_LOGIC;
	SIGNAL READY_SIGNAL					: STD_LOGIC;
	SIGNAL Rx_VALUE_RECEIVED_SIGNAL	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL decodedPCKT_SIGNAL			: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL ABCDEFGH_Tx					: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL readyRX_SIGNAL				: STD_LOGIC;
	SIGNAL readyTX_SIGNAL				: STD_LOGIC;
	SIGNAL numberOfErrors_SIGNAL		: INTEGER;
	SIGNAL ERROR_32bit					: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL error_sent_export_SIGNAL	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL devidedCLOCK_SIGNAL			: STD_LOGIC;
	SIGNAL inPHASE							: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	
	SIGNAL COUNTER_SIGNAL				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL WRITE_FIFO_SIGNAL			: STD_LOGIC := '0';
	SIGNAL AGAIN							: STD_LOGIC := '1';
	
BEGIN
	ERROR_32bit <= STD_LOGIC_VECTOR(TO_UNSIGNED(numberOfErrors_SIGNAL, 8));
	L0 : Tx PORT MAP (CLOCK_50 => CLOCK_50, 
							Tx_Rx => Tx_Rx_SIGNAL, 
							Rx_Tx => Rx_Tx_SIGNAL, 
							RESET => (RESET), 
							inPHASE => ABCDEFGH_Tx 
							);

							
	L1 : Rx PORT MAP (RESET		=> RESET, 
							CLOCK_50 => CLOCK_50, 
							S_IN => Tx_Rx_SIGNAL, 
							Rx_Tx => Rx_Tx_SIGNAL, 
							ABCDEFGH => decodedPCKT_SIGNAL
							);

											
	L2	: clockDIVIDER PORT MAP (	CLOCK_50 => CLOCK_50, 
											dividedCLOCK => devidedCLOCK_SIGNAL, 
											RESET => '0'
										);
												
	L3	: PHASE			PORT MAP (	CLK => devidedCLOCK_SIGNAL, 
											RESET => RESET, 
											TX_RESULT => ABCDEFGH_Tx, 
											inPHASE => inPHASE
										);
											
	L4	: COUNTER		PORT MAP (	CLK => CLOCK_50, 
											COUNTER => COUNTER_SIGNAL, 
											WRITE_FIFO=> WRITE_FIFO_SIGNAL, 
											AGAIN => '1'
										);
											
	L5	: errorCOUNTER	PORT MAP (	txPCKT	=> inPHASE,
											rxPCKT	=> decodedPCKT_SIGNAL,
											BYTECLK	=> devidedCLOCK_SIGNAL,
											error		=> numberOfERRORS,
											RESET		=> (RESET)
										);
END ARCHITECTURE BEHV;

-- altpll_areset_conduit_export => '0', altpll_locked_conduit_export => altpll_locked_conduit_export,
-- altpll_sdram_clk => altpll_sdram_clk, 
	
