LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Top_Level_RS232 IS
	PORT (
		Rxd : IN std_logic;
		Reset : IN std_logic;
		SystemClock : IN std_logic;
		An : OUT std_logic_vector (3 DOWNTO 0);
		Ca, Cb, Cc, Cd, Ce, Cf, Cg : OUT std_logic
	);

END Top_Level_RS232;
ARCHITECTURE Behavioral OF Top_Level_RS232 IS

	COMPONENT RS232
		PORT (
			Reset, Clock16x, Rxd : IN std_logic;
			DataOut1, DataOut2 : OUT std_logic_vector (7 DOWNTO 0)
		);

	END COMPONENT;

	COMPONENT D4to7
		PORT (
			Q : IN std_logic_vector (3 DOWNTO 0);
			Seg : OUT std_logic_vector (6 DOWNTO 0));

	END COMPONENT;
	COMPONENT scan4digit
		PORT (
			Digit3, Digit2, Digit1, Digit0 : IN std_logic_vector(6 DOWNTO 0);
			Clock : IN std_logic;
			An : OUT std_logic_vector(3 DOWNTO 0);
			Ca, Cb, Cc, Cd, Ce, Cf, Cg : OUT std_logic);

	END COMPONENT;

	SIGNAL iClock16x : std_logic;
	SIGNAL iDigitOut3, iDigitOut2, iDigitOut1, iDigitOut0 : std_logic_vector (6 DOWNTO 0);
	SIGNAL iDataOut1 : std_logic_vector (7 DOWNTO 0);
	SIGNAL iDataOut2 : std_logic_vector (7 DOWNTO 0);
	SIGNAL iCount9 : std_logic_vector (8 DOWNTO 0) := (OTHERS => '0');

BEGIN

	PROCESS (SystemClock)

	BEGIN

		IF SystemClock'event AND SystemClock = '1' THEN
			IF Reset = '1' THEN
				iCount9 <= (OTHERS => '0');
			ELSIF
				iCount9 = "101000101" THEN -- the divider is 325, or "101000101"
				iCount9 <= (OTHERS => '0');
			ELSE
				iCount9 <= iCount9 + '1';
			END IF;
		END IF;

	END PROCESS;

	iClock16x <= iCount9(8);

	U1 : RS232 PORT MAP(
		Reset => Reset,
		Clock16x => iClock16x,
		Rxd => Rxd,
		DataOut1 => iDataOut1,
		DataOut2 => iDataOut2
	);
	U2 : D4to7 PORT MAP(
		Q => iDataOut1(3 DOWNTO 0),
		Seg => iDigitOut0);
	U3 : D4to7 PORT MAP(
		Q => iDataOut1(7 DOWNTO 4),
		Seg => iDigitOut1);
	U4 : D4to7 PORT MAP(
		Q => iDataOut2(3 DOWNTO 0),
		Seg => iDigitOut2);
	U5 : D4to7 PORT MAP(
		Q => iDataOut2(7 DOWNTO 4),
		Seg => iDigitOut3);
	U6 : scan4digit PORT MAP(
		Digit3 => iDigitOut3,
		Digit2 => iDigitOut2,
		Digit1 => iDigitOut1,
		Digit0 => iDigitOut0,
		Clock => SystemClock,
		An => An,
		Ca => Ca,
		Cb => Cb,
		Cc => Cc,
		Cd => Cd,
		Ce => Ce,
		Cf => Cf,
		Cg => Cg);
END Behavioral;