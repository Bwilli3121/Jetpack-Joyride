LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY leddec16 IS
    PORT (
        dig   : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
        score : IN  STD_LOGIC_VECTOR (11 DOWNTO 0); -- distance score, left 4 digits
        coins : IN  STD_LOGIC_VECTOR (11 DOWNTO 0); -- coin score, right 4 digits
        anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        seg   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS

    -- Converts a 12-bit binary number into 4 BCD decimal digits.
    -- Example: binary 10 becomes BCD 0000 0000 0001 0000.
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

    SIGNAL coins_bcd : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL score_bcd : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL digit     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL blank     : STD_LOGIC;

BEGIN

    coins_bcd <= to_bcd(coins);
    score_bcd <= to_bcd(score);

    -- 8-digit display layout:
    -- LEFT  4 digits = distance score
    -- RIGHT 4 digits = coin count
    --
    -- anode[7] anode[6] anode[5] anode[4] | anode[3] anode[2] anode[1] anode[0]
    -- distance thousands/hundreds/tens/ones | coins thousands/hundreds/tens/ones
    PROCESS (dig, coins_bcd, score_bcd)
    BEGIN
        anode <= "11111111";
        digit <= "0000";
        blank <= '0';

        CASE dig IS

            ------------------------------------------------------------------
            -- RIGHT 4 DIGITS: COINS
            ------------------------------------------------------------------
            WHEN "000" =>
                anode <= "11111110"; -- coin ones, rightmost digit
                digit <= coins_bcd(3 DOWNTO 0);

            WHEN "001" =>
                anode <= "11111101"; -- coin tens
                digit <= coins_bcd(7 DOWNTO 4);

                IF coins_bcd(15 DOWNTO 4) = "000000000000" THEN
                    blank <= '1';
                END IF;

            WHEN "010" =>
                anode <= "11111011"; -- coin hundreds
                digit <= coins_bcd(11 DOWNTO 8);

                IF coins_bcd(15 DOWNTO 8) = "00000000" THEN
                    blank <= '1';
                END IF;

            WHEN "011" =>
                anode <= "11110111"; -- coin thousands
                digit <= coins_bcd(15 DOWNTO 12);

                IF coins_bcd(15 DOWNTO 12) = "0000" THEN
                    blank <= '1';
                END IF;


            ------------------------------------------------------------------
            -- LEFT 4 DIGITS: DISTANCE SCORE
            ------------------------------------------------------------------
            WHEN "100" =>
                anode <= "11101111"; -- distance ones
                digit <= score_bcd(3 DOWNTO 0);

            WHEN "101" =>
                anode <= "11011111"; -- distance tens
                digit <= score_bcd(7 DOWNTO 4);

                IF score_bcd(15 DOWNTO 4) = "000000000000" THEN
                    blank <= '1';
                END IF;

            WHEN "110" =>
                anode <= "10111111"; -- distance hundreds
                digit <= score_bcd(11 DOWNTO 8);

                IF score_bcd(15 DOWNTO 8) = "00000000" THEN
                    blank <= '1';
                END IF;

            WHEN OTHERS =>
                anode <= "01111111"; -- distance thousands
                digit <= score_bcd(15 DOWNTO 12);

                IF score_bcd(15 DOWNTO 12) = "0000" THEN
                    blank <= '1';
                END IF;

        END CASE;
    END PROCESS;

    -- Nexys A7 active-low 7-segment decoder.
    -- Use this with the corrected .xdc where SEG7_seg[0]=CA, [1]=CB, ..., [6]=CG.
    PROCESS (digit, blank)
    BEGIN
        IF blank = '1' THEN
            seg <= "1111111"; -- blank
        ELSE
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
                WHEN OTHERS => seg <= "1111111"; -- blank invalid BCD
            END CASE;
        END IF;
    END PROCESS;

END Behavioral;
