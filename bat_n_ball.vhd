LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync    : IN  STD_LOGIC;
        pixel_row : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x     : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
        serve     : IN  STD_LOGIC;
        red       : OUT STD_LOGIC;
        green     : OUT STD_LOGIC;
        blue      : OUT STD_LOGIC;
        hits      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize        : INTEGER := 8;
    CONSTANT bat_h        : INTEGER := 3;
    CONSTANT bat_w_start  : INTEGER := 40;
    CONSTANT bat_w_min    : INTEGER := 4;
    CONSTANT base_speed   : INTEGER := 3;

    SIGNAL ball_on   : STD_LOGIC;
    SIGNAL bat_on    : STD_LOGIC;
    SIGNAL game_on   : STD_LOGIC := '0';

    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);

    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);

    SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(base_speed, 11);
    SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(base_speed, 11);

    SIGNAL hit_count   : INTEGER := 0;
    SIGNAL bat_w_cur   : INTEGER := bat_w_start;
    SIGNAL hit_latched : STD_LOGIC := '0';

BEGIN
    red   <= NOT bat_on;
    green <= NOT ball_on;
    blue  <= NOT ball_on;

    hits <= CONV_STD_LOGIC_VECTOR(hit_count, 16);

    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col, game_on)
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0);
    BEGIN
        IF pixel_col <= ball_x THEN
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;

        IF pixel_row <= ball_y THEN
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;

        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;

    batdraw : PROCESS (bat_x, pixel_row, pixel_col, bat_w_cur)
    BEGIN
        IF ((pixel_col >= bat_x - bat_w_cur) OR (bat_x <= bat_w_cur)) AND
           (pixel_col <= bat_x + bat_w_cur) AND
           (pixel_row >= bat_y - bat_h) AND
           (pixel_row <= bat_y + bat_h) THEN
            bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;

    mball : PROCESS
        VARIABLE temp      : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE speed_now : INTEGER;
        VARIABLE speed_slv : STD_LOGIC_VECTOR (10 DOWNTO 0);
        VARIABLE x_hit     : BOOLEAN;
        VARIABLE y_hit     : BOOLEAN;
        VARIABLE hit_now   : BOOLEAN;
    BEGIN
        WAIT UNTIL rising_edge(v_sync);

        speed_now := base_speed + hit_count;
        IF speed_now > 15 THEN
            speed_now := 15;
        END IF;
        speed_slv := CONV_STD_LOGIC_VECTOR(speed_now, 11);

        IF (serve = '1') AND (game_on = '0') THEN
            game_on       <= '1';
            hit_count     <= 0;
            bat_w_cur     <= bat_w_start;
            hit_latched   <= '0';
            ball_x        <= CONV_STD_LOGIC_VECTOR(400, 11);
            ball_y        <= CONV_STD_LOGIC_VECTOR(440, 11);
            ball_x_motion <= CONV_STD_LOGIC_VECTOR(base_speed, 11);
            ball_y_motion <= (NOT CONV_STD_LOGIC_VECTOR(base_speed, 11)) + 1;

        ELSE
            IF ball_y <= bsize THEN
                ball_y_motion <= speed_slv;
            END IF;

            IF ball_y + bsize >= 600 THEN
                game_on       <= '0';
                bat_w_cur     <= bat_w_start;
                hit_latched   <= '0';
                ball_y_motion <= (NOT speed_slv) + 1;
            END IF;

            IF ball_x + bsize >= 800 THEN
                ball_x_motion <= (NOT speed_slv) + 1;
            ELSIF ball_x <= bsize THEN
                ball_x_motion <= speed_slv;
            END IF;

            x_hit := ((ball_x + bsize/2) >= (bat_x - bat_w_cur)) AND
                     ((ball_x - bsize/2) <= (bat_x + bat_w_cur));

            y_hit := ((ball_y + bsize/2) >= (bat_y - bat_h)) AND
                     ((ball_y - bsize/2) <= (bat_y + bat_h));

            hit_now := x_hit AND y_hit;

            IF hit_now AND (hit_latched = '0') THEN
                hit_count <= hit_count + 1;
                hit_latched <= '1';

                IF bat_w_cur > bat_w_min THEN
                    bat_w_cur <= bat_w_cur - 1;
                END IF;

                ball_y_motion <= (NOT CONV_STD_LOGIC_VECTOR(base_speed + hit_count + 1, 11)) + 1;

                IF ball_x_motion(10) = '1' THEN
                    ball_x_motion <= (NOT CONV_STD_LOGIC_VECTOR(base_speed + hit_count + 1, 11)) + 1;
                ELSE
                    ball_x_motion <= CONV_STD_LOGIC_VECTOR(base_speed + hit_count + 1, 11);
                END IF;
            ELSIF NOT hit_now THEN
                hit_latched <= '0';
            END IF;

            temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
            IF game_on = '0' THEN
                ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
            ELSIF temp(11) = '1' THEN
                ball_y <= (OTHERS => '0');
            ELSE
                ball_y <= temp(10 DOWNTO 0);
            END IF;

            temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
            IF game_on = '0' THEN
                ball_x <= CONV_STD_LOGIC_VECTOR(400, 11);
            ELSIF temp(11) = '1' THEN
                ball_x <= (OTHERS => '0');
            ELSE
                ball_x <= temp(10 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
END Behavioral;