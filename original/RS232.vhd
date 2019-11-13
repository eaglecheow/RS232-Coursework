LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY RS232 IS
	PORT (
		Reset, Clock16x, Rxd : IN std_logic;
		DataOut1, DataOut2 : OUT std_logic_vector (7 DOWNTO 0)
	);
END RS232;

ARCHITECTURE RS232_Arch OF RS232 IS

	COMPONENT Rs232Rxd
		PORT (
			Reset, Clock16x, Rxd : IN std_logic;
			DataOut1, DataOut2 : OUT std_logic_vector (7 DOWNTO 0));
	END COMPONENT;

BEGIN

	u1 : Rs232Rxd PORT MAP(
		Reset => Reset,
		Clock16x => Clock16x,
		Rxd => Rxd,
		DataOut1 => DataOut1,
		DataOut2 => DataOut2);

END RS232_Arch;