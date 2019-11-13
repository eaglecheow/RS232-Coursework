LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all; 

ENTITY scan4Digit IS
	PORT (
		digit0 : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		digit1 : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		digit2 : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		digit3 : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock : IN STD_LOGIC;
		an : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		ca : OUT STD_LOGIC;
		cb : OUT STD_LOGIC;
		cc : OUT STD_LOGIC;
		cd : OUT STD_LOGIC;
		ce : OUT STD_LOGIC;
		cf : OUT STD_LOGIC;
		cg : OUT STD_LOGIC);

END scan4Digit;

ARCHITECTURE Behavioral OF scan4Digit IS
	SIGNAL iCount16 : std_logic_vector (15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL iDigitOut : std_logic_vector (6 DOWNTO 0);
BEGIN

	-- Generate the scan clock 50MHz/2**16 (763Hz)
	PROCESS (Clock)

	BEGIN
		IF Clock'event AND Clock = '1' THEN
			iCount16 <= iCount16 + '1';
		END IF;

	END PROCESS;

	--Send four digits to four 7-segment display using scan mode

	WITH iCount16 (15 DOWNTO 14) SELECT

	iDigitOut <= Digit0 WHEN "00", -- Connect Digit0 to the 7-segment display
		Digit1 WHEN "01", -- Connect Digit1 to the 7-segment display
		Digit2 WHEN "10", -- Connect Digit2 to the 7-segment display
		Digit3 WHEN "11", -- Connect Digit3 to the 7-segment display
		Digit0 WHEN OTHERS;

	WITH iCount16 (15 DOWNTO 14) SELECT
	An <= "1110" WHEN "00", -- with AN0 low only
		"1101" WHEN "01", -- with AN1 low only
		"1011" WHEN "10", -- with AN2 low only
		"0111" WHEN "11", -- with AN3 low only
		"1110" WHEN OTHERS;
	Ca <= iDigitOut(6);
	Cb <= iDigitOut(5);
	Cc <= iDigitOut(4);
	Cd <= iDigitOut(3);
	Ce <= iDigitOut(2);
	Cf <= iDigitOut(1);
	Cg <= iDigitOut(0);

END Behavioral;