LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY leddec16 IS
    PORT (
        dig   : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);   -- 3-bit mux select (0-7)
        score : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);  -- 12-bit binary score (0-4095)
        coins : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);  -- 12-bit binary coin count (0-4095)
        anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- 8 anodes (active low)
        seg   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)    -- 7-segment cathodes (active low)
    );
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS

    -- Double Dabble: convert 12-bit binary to 16-bit BCD (4 digits)
    FUNCTION to_bcd(bin : STD_LOGIC_VECTOR(11 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE temp    : UNSIGNED(11 DOWNTO 0);
        VARIABLE bcd_var : UNSIGNED(15 DOWNTO 0);
    BEGIN
        temp := UNSIGNED(bin);
        bcd_var := (OTHERS => '0');

        FOR i IN 11 DOWNTO 0 LOOP
            IF bcd_var(3 DOWNTO 0) >= 5 THEN
                bcd_var(3 DOWNTO 0) := bcd_var(3 DOWNTO 0) + 3;
            END IF;
            IF bcd_var(7 DOWNTO 4) >= 5 THEN
                bcd_var(7 DOWNTO 4) := bcd_var(7 DOWNTO 4) + 3;
            END IF;
            IF bcd_var(11 DOWNTO 8) >= 5 THEN
                bcd_var(11 DOWNTO 8) := bcd_var(11 DOWNTO 8) + 3;
            END IF;
            IF bcd_var(15 DOWNTO 12) >= 5 THEN
                bcd_var(15 DOWNTO 12) := bcd_var(15 DOWNTO 12) + 3;
            END IF;

            bcd_var := bcd_var(14 DOWNTO 0) & temp(11);
            temp := temp(10 DOWNTO 0) & '0';
        END LOOP;

        RETURN STD_LOGIC_VECTOR(bcd_var);
    END FUNCTION;

    SIGNAL bcd_all : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL digit   : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    -- BCD conversion: coins in upper 16 bits, score in lower 16 bits
    bcd_all <= to_bcd(coins) & to_bcd(score);

    -- Digit mux: select one 4-bit BCD nibble based on dig
    -- dig 0-3 = right 4 digits (score), dig 4-7 = left 4 digits (coins)
    PROCESS (dig, bcd_all)
    BEGIN
        CASE dig IS
            WHEN "000" => anode <= "11111110"; digit <= bcd_all(3  DOWNTO 0);   -- score ones
            WHEN "001" => anode <= "11111101"; digit <= bcd_all(7  DOWNTO 4);   -- score tens
            WHEN "010" => anode <= "11111011"; digit <= bcd_all(11 DOWNTO 8);   -- score hundreds
            WHEN "011" => anode <= "11110111"; digit <= bcd_all(15 DOWNTO 12);  -- score thousands
            WHEN "100" => anode <= "11101111"; digit <= bcd_all(19 DOWNTO 16);  -- coins ones
            WHEN "101" => anode <= "11011111"; digit <= bcd_all(23 DOWNTO 20);  -- coins tens
            WHEN "110" => anode <= "10111111"; digit <= bcd_all(27 DOWNTO 24);  -- coins hundreds
            WHEN "111" => anode <= "01111111"; digit <= bcd_all(31 DOWNTO 28);  -- coins thousands
            WHEN OTHERS => anode <= "11111111"; digit <= "0000";
        END CASE;
    END PROCESS;

    -- 7-segment decoder (active low: '0' = segment ON)
    --   segment order: seg(6)=g, seg(5)=f, ..., seg(0)=a
    PROCESS (digit)
    BEGIN
        CASE digit IS
            WHEN "0000" => seg <= "1000000"; -- 0
            WHEN "0001" => seg <= "1111001"; -- 1
            WHEN "0010" => seg <= "0100100"; -- 2
            WHEN "0011" => seg <= "0110000"; -- 3
            WHEN "0100" => seg <= "0011001"; -- 4
            WHEN "0101" => seg <= "0010010"; -- 5
            WHEN "0110" => seg <= "0000010"; -- 6
            WHEN "0111" => seg <= "1111000"; -- 7
            WHEN "1000" => seg <= "0000000"; -- 8
            WHEN "1001" => seg <= "0010000"; -- 9
            WHEN OTHERS => seg <= "1111111"; -- blank
        END CASE;
    END PROCESS;

END Behavioral;
