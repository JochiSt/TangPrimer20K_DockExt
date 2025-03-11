LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY simpleblinking IS
    PORT (
        clk27 : IN STD_LOGIC;                    -- Input clock (27MHz)
        led   : OUT STD_LOGIC_VECTOR(5 DOWNTO 0) -- Output for LED
    );
END simpleblinking;

ARCHITECTURE Behavioral OF simpleblinking IS
    SIGNAL clk_div : INTEGER := 0; -- Counter for dividing the clock
    SIGNAL led_state : STD_LOGIC := '0';-- State of the LED
BEGIN

    PROCESS (clk27)
    BEGIN
        IF rising_edge(clk27) THEN
            IF clk_div = 13500000 THEN -- Count to half of the target frequency (27MHz / 2Hz)
                clk_div <= 0;
                led_state <= NOT led_state; -- Toggle LED state
            ELSE
                clk_div <= clk_div + 1;
            END IF;
        END IF;
    END PROCESS;

    led(0) <= led_state; -- Assign the state to output

END Behavioral;
