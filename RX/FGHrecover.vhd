LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FGHrecover IS
	PORT (	abcdeifghj 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
				FGH			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
				SBYTECLK		: IN STD_LOGIC
			);
END ENTITY FGHrecover;

ARCHITECTURE BEHV OF FGHrecover IS
SIGNAL F_OUT, G_OUT, H_OUT : STD_LOGIC := '0';
	BEGIN
	RECOVERY : PROCESS(SBYTECLK)
	BEGIN
	IF RISING_EDGE(SBYTECLK) THEN
		IF (abcdeifghj(3 DOWNTO 1) = "010") AND (abcdeifghj(0) = '0') THEN
			F_OUT <= '0';
			G_OUT <= '0';
			H_OUT <= '0';
		ELSIF (abcdeifghj(3 DOWNTO 1) = "011") AND (abcdeifghj(0) = '1') THEN
			F_OUT <= '1';
			G_OUT <= '1';
			H_OUT <= '1';
		ELSE
			F_OUT <= abcdeifghj(3);
			G_OUT <= abcdeifghj(2);
			H_OUT <= abcdeifghj(1);
		END IF;
	END IF;
	END PROCESS;
	FGH(2) <= H_OUT;
	FGH(1) <= G_OUT;
	FGH(0) <= F_OUT;
END ARCHITECTURE BEHV;