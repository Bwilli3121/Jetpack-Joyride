LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bin2bcd IS
    PORT (
        bin  : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);  -- 12-bit binary (0-4095)
        bcd  : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)   -- 4 BCD digits (16 bits)
    );
END bin2bcd;

ARCHITECTURE Behavioral OF bin2bcd IS
BEGIN
    PROCESS (bin)
        VARIABLE temp : UNSIGNED (11 DOWNTO 0);
        VARIABLE bcd_var : UNSIGNED (15 DOWNTO 0);
    BEGIN
        temp := UNSIGNED(bin);
        bcd_var := (OTHERS => '0');

        -- 12 iterations: one per input bit
        FOR i IN 11 DOWNTO 0 LOOP
            -- If any BCD digit >= 5, add 3 before shifting
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

            -- Shift left: push next binary bit into LSB
            bcd_var := bcd_var(14 DOWNTO 0) & temp(11);
            temp := temp(10 DOWNTO 0) & '0';
        END LOOP;

        bcd <= STD_LOGIC_VECTOR(bcd_var);
    END PROCESS;
END Behavioral;
