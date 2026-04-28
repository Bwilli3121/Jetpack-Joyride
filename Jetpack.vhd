LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC;
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        LED : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0';
    SIGNAL S_red, S_green, S_blue : STD_LOGIC;
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0) := (OTHERS => '0');
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL hits_value : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL coin_value : STD_LOGIC_VECTOR (15 DOWNTO 0);

    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            serve : IN STD_LOGIC;
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            hits : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            coins : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT clk_wiz_0 IS
        PORT (
            clk_in1  : IN STD_LOGIC;
            clk_out1 : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT leddec16 IS
        PORT (
            dig   : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            score : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            coins : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    
BEGIN

    pos : PROCESS (clk_in)
    BEGIN
        IF rising_edge(clk_in) THEN
            count <= count + 1;

            IF (btnl = '1' AND count = 0 AND batpos > 10) THEN
                batpos <= batpos - 10;
            ELSIF (btnr = '1' AND count = 0 AND batpos < 790) THEN
                batpos <= batpos + 10;
            END IF;
        END IF;
    END PROCESS;

    led_mpx <= count(19 DOWNTO 17);
    LED <= hits_value;

    add_bb : bat_n_ball
    PORT MAP(
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        bat_x => batpos, 
        serve => btn0, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        hits => hits_value,
        coins => coin_value
    );
    
    vga_driver : vga_sync
    PORT MAP(
        pixel_clk => pxl_clk, 
        red_in => S_red & S_red & S_red & S_red, 
        green_in => S_green & S_green & S_green & S_green, 
        blue_in => S_blue & S_blue & S_blue & S_blue, 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );

    VGA_vsync <= S_vsync;
        
    clk_wiz_0_inst : clk_wiz_0
    PORT MAP (
        clk_in1 => clk_in,
        clk_out1 => pxl_clk
    );

    led1 : leddec16
    PORT MAP(
        dig => led_mpx,
        score => hits_value(11 DOWNTO 0),
        coins => coin_value(11 DOWNTO 0),
        anode => SEG7_anode,
        seg => SEG7_seg
    );

END Behavioral;
