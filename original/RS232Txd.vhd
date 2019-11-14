LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Rs232Txd IS
    PORT (
        Reset, Send, Clock16x : IN std_logic;
        DataIn : IN std_logic_vector (7 DOWNTO 0)
        Txd : OUT std_logic);
END Rs232Txd;

ARCHITECTURE Rs232Txd_Arch OF Rs232Txd IS

    ATTRIBUTE enum_encoding : STRING;
    --state definitions
    TYPE stateType IS (stIdle. stData, stStop, stTxdComplete);
    ATTRIBUTE enum_encoding OF stateType : TYPE IS "00 01 11 10";

    SIGNAL presState : stateType;
    SIGNAL nextState : stateType;
    SIGNAL iSend, iReset, iClock1xEnable, iEnableTxdBuffer, iEnableShift : std_logic;
    SIGNAL iTxdBuffer : std_logic_vector (8 DOWNTO 0);
    SIGNAL iClockDiv : std_logic_vector (3 DOWNTO 0);
    SIGNAL iClock1x : std_logic;
    SIGNAL iNoBitsSent : std_logic_vector (3 DOWNTO 0);
BEGIN

    -- This process handles the clock division and reset task
    -- If "Send" input is detected high, clock division shall start
    -- If "Reset" input is detected high, clock division shall stop
    process (Clock16x)
    
    begin

        if Clock16x'event and Clock16x = '1' then

            if Reset = '1' or iReset = '1' then

                iSend <= '0';
                iClock1xEnable <= '0';
                iClockDiv <= "1010";

            else
                
                iSend <= Send;
                
            end if;

            if iSend = '1' then

                if iClock1xEnable = '0' then

                    iClock1xEnable <= '1';

                else
                    
                    iClockDiv <= iClockDiv + '1';
                    iClock1x <= iClockDiv(3);

                end if;

            end if;

        end if;

    end process;

    
    process (iClock1xEnable, iClock1x)

    begin

        if iClock1xEnable = '0' then

            iNoBitsSent <= (others => '0');
            presState <= stIdle;

        elsif iClock1x'event and iClock1x = '1' then

            if iEnableTxdBuffer = '0' then

                iTxdBuffer <= '0' & DataIn;
                iEnableTxdBuffer <= '1';

            elsif iEnableShift = '1' then
                
                Txd <= iTxdBuffer(8);
                iTxdBuffer <= iTxdBuffer(7 downto 0) & '0';
                iNoBitsSent <= iNoBitsSent + '1';

            end if;

        end if;

    end process;


    process (presState, iClock1xEnable, iNoBitsReceived)

    begin

        iReset <= '0';

        case presState is

            when stIdle =>

                if iClock1xEnable = '1' then

                    nextState <= stData;

                else

                    nextState <= stIdle;

                end if;

            when stData =>

                if iNoBitsSent = "1000" then

                    iEnableShift <= '0';
                    nextState <= stStop;

                else
                    
                    iEnableShift <= '1';
                    nextState <= stData;

                end if;

            when stStop =>
                    
                nextState <= stTxdComplete;
                iReset <= '1';

            when stTxdComplete =>

                nextState <= stIdle;

        end case;

    end process;

END Rs232Txd_Arch;