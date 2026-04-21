LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec16 IS
    PORT (
        dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END leddec16;

ARCHITECTURE Behavioral OF leddec16 IS
    SIGNAL data4 : STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
data4 <= "000" & data(0) WHEN dig = "000" ELSE
         "000" & data(1) WHEN dig = "001" ELSE
         "000" & data(2) WHEN dig = "010" ELSE
         "000" & data(3);

    seg <= "0000001" WHEN data4 = "0000" ELSE
           "1001111" WHEN data4 = "0001" ELSE
           "0010010" WHEN data4 = "0010" ELSE
           "0000110" WHEN data4 = "0011" ELSE
           "1001100" WHEN data4 = "0100" ELSE
           "0100100" WHEN data4 = "0101" ELSE
           "0100000" WHEN data4 = "0110" ELSE
           "0001111" WHEN data4 = "0111" ELSE
           "0000000" WHEN data4 = "1000" ELSE
           "0000100" WHEN data4 = "1001" ELSE
           "0001000" WHEN data4 = "1010" ELSE
           "1100000" WHEN data4 = "1011" ELSE
           "0110001" WHEN data4 = "1100" ELSE
           "1000010" WHEN data4 = "1101" ELSE
           "0110000" WHEN data4 = "1110" ELSE
           "0111000";

    anode <= "11111110" WHEN dig = "000" ELSE
             "11111101" WHEN dig = "001" ELSE
             "11111011" WHEN dig = "010" ELSE
             "11110111" WHEN dig = "011" ELSE
             "11111111";
END Behavioral;