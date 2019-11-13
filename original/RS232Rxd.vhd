LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY Rs232Rxd IS

	PORT (
		Reset, Clock16x, Rxd : IN std_logic;
		DataOut1, DataOut2 : OUT std_logic_vector (7 DOWNTO 0));

END Rs232Rxd;
ARCHITECTURE Rs232Rxd_Arch OF Rs232Rxd IS

	ATTRIBUTE enum_encoding : STRING;
	-- state definitions

	TYPE stateType IS (stIdle, stData, stStop, stRxdCompleted);
	ATTRIBUTE enum_encoding OF statetype : TYPE IS "00 01 11 10";

	SIGNAL presState : stateType;
	SIGNAL nextState : stateType;
	SIGNAL iReset, iRxd1, iRxd2, iClock1xEnable : std_logic;
	SIGNAL iClock1x : std_logic := '1';
	SIGNAL iEnableDataOut : std_logic;
	SIGNAL iClockDiv : std_logic_vector (3 DOWNTO 0) := "1010";
	SIGNAL iDataOut1, iDataOut2 : std_logic_vector (7 DOWNTO 0) := "00000000";
	SIGNAL iShiftRegister : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL iNoBitsReceived : std_logic_vector (3 DOWNTO 0) := (OTHERS => '0');

BEGIN

	PROCESS (Clock16x)

	BEGIN

		IF Clock16x'event AND Clock16x = '1' THEN

			IF Reset = '1' OR iReset = '1' THEN
				iRxd1 <= '1';
				iRxd2 <= '1';
				iClock1xEnable <= '0';
				iClockDiv <= "1010";

			ELSE
				iRxd1 <= Rxd;
				iRxd2 <= iRxd1;

			END IF;

			IF iRxd1 = '0' AND iRxd2 = '1' THEN
				iClock1xEnable <= '1';

			ELSIF iClock1xEnable = '1' THEN
				iClockDiv <= iClockDiv + '1';

				iClock1x <= iClockDiv(3);

			END IF;

		END IF;

	END PROCESS;
	PROCESS (iClock1xEnable, iClock1x)
	BEGIN
		IF iClock1xEnable = '0' THEN
			iNoBitsReceived <= (OTHERS => '0');
			presState <= stIdle;

		ELSIF iClock1x'event AND iClock1x = '1' THEN
			iNoBitsReceived <= iNoBitsReceived + '1';
			presState <= nextState;

		END IF;

		IF iClock1x'event AND iClock1x = '1' THEN

			IF iEnableDataOut = '1' THEN
				iDataOut2 <= iDataOut1;
				iDataOut1 <= iShiftRegister;

			ELSE
				iShiftRegister <= Rxd & iShiftRegister(7 DOWNTO 1);

			END IF;

		END IF;

	END PROCESS;
	DataOut1 <= iDataOut1;
	DataOut2 <= iDataOut2;

	PROCESS (presState, iClock1xEnable, iNoBitsReceived)
	BEGIN

		-- signal defaults
		iReset <= '0';
		iEnableDataOut <= '0';

		CASE presState IS

			WHEN stIdle =>
				IF iClock1xEnable = '1' THEN
					nextState <= stData;
				ELSE
					nextState <= stIdle;
				END IF;

			WHEN stData =>
				IF iNoBitsReceived = "1000" THEN
					iEnableDataOut <= '1';
					nextState <= stStop;

				ELSE
					iEnableDataOut <= '0';
					nextState <= stData;
				END IF;

			WHEN stStop =>
				nextState <= stRxdCompleted;
				iReset <= '1';

			WHEN stRxdCompleted =>
				nextState <= stIdle;
		END CASE;

	END PROCESS;
END Rs232Rxd_Arch;