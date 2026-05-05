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
        hits      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        distance  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
SIGNAL obstacle_x : INTEGER := 800;
--SIGNAL gap_y : INTEGER := 300;
SIGNAL top_height    : INTEGER := 200;
SIGNAL bottom_start  : INTEGER := 400;
CONSTANT gap_size : INTEGER := 150;
SIGNAL obstacle_on : STD_LOGIC;
SIGNAL obstacle_type : INTEGER := 0;  -- 0=circle, 1=rectangle, 2=triangle


SIGNAL coin_x : INTEGER := 600;
SIGNAL coin_y : INTEGER := 300;
SIGNAL coin_on : STD_LOGIC;
SIGNAL coin_active : STD_LOGIC := '1';
SIGNAL score : INTEGER := 0;
SIGNAL distance_score : INTEGER := 0;
SIGNAL distance_timer : INTEGER := 0; -- counts frames; 180 frames is about 3 seconds at 60 Hz
SIGNAL coin2_x : INTEGER := 700;
SIGNAL coin2_y : INTEGER := 350;
SIGNAL coin2_active : STD_LOGIC := '1';

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

    --CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    SIGNAL player_y : INTEGER := 300;
    SIGNAL velocity_y : INTEGER := 0;

    SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(base_speed, 11);
    SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(base_speed, 11);

    SIGNAL hit_count   : INTEGER := 0;
    SIGNAL bat_w_cur   : INTEGER := bat_w_start;
    SIGNAL hit_latched : STD_LOGIC := '0';
    
    SIGNAL particle_on : STD_LOGIC;
    SIGNAL particle_y : INTEGER :=0;
    SIGNAL particle_offset : INTEGER := 0;
    
    SIGNAL obstacle2_x : INTEGER := 1200;
SIGNAL obstacle2_type : INTEGER := 1;
SIGNAL obstacle2_top : INTEGER := 150;
SIGNAL obstacle2_bot : INTEGER := 350;

-- Third obstacle group, offset farther to the right so it enters later
SIGNAL obstacle3_x    : INTEGER := 1600;
SIGNAL obstacle3_type : INTEGER := 2;
SIGNAL obstacle3_top  : INTEGER := 240;
SIGNAL obstacle3_bot  : INTEGER := 430;

BEGIN

hits <= CONV_STD_LOGIC_VECTOR(score, 16);
distance <= CONV_STD_LOGIC_VECTOR(distance_score, 16);

--obstacle_type <= (obstacle_type + 1) mod 3;

colordraw : PROCESS(bat_on, obstacle_on, coin_on, particle_on)
BEGIN
    -- background = white
    red   <= '1';
    green <= '1';
    blue  <= '1';

    -- player = red
    IF bat_on = '1' THEN
        red   <= '1';
        green <= '0';
        blue  <= '0';

    -- particles = red
    ELSIF particle_on = '1' THEN
        red   <= '1';
        green <= '0';
        blue  <= '0';

    -- coins = yellow
    ELSIF coin_on = '1' THEN
        red   <= '1';
        green <= '1';
        blue  <= '0';

    -- obstacles = blue
    ELSIF obstacle_on = '1' THEN
        red   <= '0';
        green <= '0';
        blue  <= '1';
    END IF;
END PROCESS;


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

batdraw : PROCESS (bat_x, pixel_row, pixel_col)

    type sprite_type is array (0 to 31) of std_logic_vector(127 downto 0);

    variable sprite : sprite_type := (
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000010101010000000000000100001100110011001101000100000001110111000000000000000000000000",
"00000000000000000000000000000000000000000000100101010101000000000100010001000100010001000111010000000000001100000000000000000000",
"00000000000000000000000000000000000000000000100101010101010100000100010001000100010000000000010101010101010100000000000000000000",
"00000000000000000000000000000000000000000000000001010101010101010000010001110000010101010110010101010101010101010000000000000000",
"00000000000000000000000000000000000000001000100010010101010101010101000001110101010101010000000001010101010101010000000000000000",
"00000000000000000000000000000000000010001000100010010101010101010101010101110101010101010000000001100101010101010000000000000000",
"00000000000000000000000000000000100010001000100000001001010101010101010101110101010101010000100110010110010101010000000000000000",
"00000000000000000000000000001001100010001000100000001001010101010101000001110101010101010000000000010110011010010000000000000000",
"00000000000000000000000000011001100010000000100110011001010101010101011100000101100100000100010001000000100100000001010101011001",
"00000000000000000000000000011001100000000111000001010101010101010111011101010101000100000100010001000100011000000101010110010000",
"00000000000000000000000100010000000000100000011101010101010101110111010100010010000101100100010001000100000001011001100100000000",
"00000000000000000011000000000001000000000000011100000101011101110001001000100010100010000000010001000100000010010000000000000000",
 "00000000000000110100010000010010000000000110000001110111011110000010001000100010100010000000100101000100000000000000000000000000",
 "00000000001101000100010001110010011001100110011001110111100000100010001000100010001000100101010101110000000000000000000000000000",
"00000000001101000100010000000110011001100110011001100111000000100010001000100010001000000101011100000000000000000000000000000000",
"00000011000000000100010001110110011001100110011001100000011110010010001000100010001001010000011100000000000000000000000000000000",
"00000000011101000100010000010110011001100110011001100110100110011001001000100010000000000111000000000000000000000000000000000000",
"00000000000001000100010001000111011001100110011001100110011010011001100100101000011101110000000000000000000000000000000000000000",
"00000000000001000111010001000001011101100110011001100110011001111001011100010111000000000000000000000000000000000000000000000000",
"00000000000000000000010001000000000000000110011001100110011001100110001001110111000000000000000000000000000000000000000000000000",
"00000000000000000100010000000000000000000110011001100110011001100010011000100000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000010001000111011001100110011000000110001000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000100010001000100000001100110001000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000100010001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000010001000001010001000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    );

    variable px, py : INTEGER;
    variable bx, by : INTEGER;
    variable pixel_bits : std_logic_vector(3 downto 0);
    variable idx : INTEGER;

BEGIN
    --bx := CONV_INTEGER(bat_x);
    bx := 200;  -- fixed x position
    by := player_y;

    px := CONV_INTEGER(pixel_col) - bx;
    py := CONV_INTEGER(pixel_row) - by;

    bat_on <= '0';

    IF (px >= 0 AND px < 32 AND py >= 0 AND py < 32) THEN

        idx := 127 - (px * 4);
        pixel_bits := sprite(py)(idx downto idx-3);

        IF pixel_bits /= "0000" THEN
            bat_on <= '1';
        END IF;
    END IF;
END PROCESS;

obstacledraw : PROCESS(pixel_row, pixel_col, 
                       obstacle_x, top_height, bottom_start, obstacle_type,
                       obstacle2_x, obstacle2_top, obstacle2_bot, obstacle2_type,
                       obstacle3_x, obstacle3_top, obstacle3_bot, obstacle3_type)
    VARIABLE pr : INTEGER;
    VARIABLE pc : INTEGER;
    VARIABLE dx : INTEGER;
    VARIABLE dy : INTEGER;
BEGIN
    pr := CONV_INTEGER(pixel_row);
    pc := CONV_INTEGER(pixel_col);

    obstacle_on <= '0';

    ------------------------------------------------------------------
    -- OBSTACLE 1
    ------------------------------------------------------------------
    IF obstacle_type = 0 THEN
        -- BIG circle
        dx := pc - (obstacle_x + 45);
        dy := pr - top_height;

        IF (dx*dx + dy*dy <= 60*60) THEN
            obstacle_on <= '1';
        END IF;

    ELSIF obstacle_type = 1 THEN
        -- BIG rectangle
        IF (pc >= obstacle_x AND pc <= obstacle_x + 80 AND
            pr >= bottom_start AND pr <= bottom_start + 200) THEN
            obstacle_on <= '1';
        END IF;

    ELSE
        -- medium circle
        dx := pc - (obstacle_x + 40);
        dy := pr - bottom_start;

        IF (dx*dx + dy*dy <= 45*45) THEN
            obstacle_on <= '1';
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- OBSTACLE 2 (SEPARATE, NOT INSIDE ELSE)
    ------------------------------------------------------------------
    IF obstacle2_type = 0 THEN
        dx := pc - (obstacle2_x + 45);
        dy := pr - obstacle2_top;

        IF (dx*dx + dy*dy <= 60*60) THEN
            obstacle_on <= '1';
        END IF;

    ELSIF obstacle2_type = 1 THEN
        IF (pc >= obstacle2_x AND pc <= obstacle2_x + 80 AND
            pr >= obstacle2_bot AND pr <= obstacle2_bot + 200) THEN
            obstacle_on <= '1';
        END IF;

    ELSE
        dx := pc - (obstacle2_x + 40);
        dy := pr - obstacle2_bot;

        IF (dx*dx + dy*dy <= 45*45) THEN
            obstacle_on <= '1';
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- OBSTACLE 3 (SEPARATE, NOT INSIDE ELSE)
    ------------------------------------------------------------------
    IF obstacle3_type = 0 THEN
        dx := pc - (obstacle3_x + 45);
        dy := pr - obstacle3_top;

        IF (dx*dx + dy*dy <= 60*60) THEN
            obstacle_on <= '1';
        END IF;

    ELSIF obstacle3_type = 1 THEN
        IF (pc >= obstacle3_x AND pc <= obstacle3_x + 80 AND
            pr >= obstacle3_bot AND pr <= obstacle3_bot + 200) THEN
            obstacle_on <= '1';
        END IF;

    ELSE
        dx := pc - (obstacle3_x + 40);
        dy := pr - obstacle3_bot;

        IF (dx*dx + dy*dy <= 45*45) THEN
            obstacle_on <= '1';
        END IF;
    END IF;

END PROCESS;

mball : PROCESS
    VARIABLE px : INTEGER;
    VARIABLE py : INTEGER;
    VARIABLE dx : INTEGER;
    VARIABLE dy : INTEGER;
BEGIN
    WAIT UNTIL rising_edge(v_sync);

    ------------------------------------------------------------------
    -- START GAME / RESET
    ------------------------------------------------------------------
    IF (serve = '1') AND (game_on = '0') THEN
        game_on <= '1';

        player_y   <= 300;
        velocity_y <= 0;

        obstacle_x   <= 800;
        top_height   <= 200;
        bottom_start <= 400;

        obstacle2_x    <= 1200;
        obstacle2_top  <= 150;
        obstacle2_bot  <= 350;
        obstacle2_type <= 1;

        obstacle3_x    <= 1600;
        obstacle3_top  <= 240;
        obstacle3_bot  <= 430;
        obstacle3_type <= 2;

        coin_x <= 600;
        coin_y <= 300;
        coin_active <= '1';

        coin2_x <= 700;
        coin2_y <= 350;
        coin2_active <= '1';

        score <= 0;
        distance_score <= 0;
        distance_timer <= 0;

    ------------------------------------------------------------------
    -- MAIN GAME LOOP
    ------------------------------------------------------------------
    ELSIF game_on = '1' THEN

        ------------------------------------------------------------------
        -- DISTANCE SCORE
        -- v_sync is about 60 Hz, so 180 frames is about 3 seconds.
        ------------------------------------------------------------------
        IF distance_timer >= 179 THEN
            distance_timer <= 0;

            IF distance_score < 4095 THEN
                distance_score <= distance_score + 1;
            END IF;
        ELSE
            distance_timer <= distance_timer + 1;
        END IF;

        ------------------------------------------------------------------
        -- OBSTACLE MOVEMENT
        ------------------------------------------------------------------
        obstacle_x <= obstacle_x - 5;

        IF obstacle_x < 0 THEN
            obstacle_x <= 800;

            top_height   <= (top_height + 97) mod 300 + 80;
            bottom_start <= (bottom_start + 173) mod 300 + 250;

            obstacle_type <= (obstacle_type + 1) mod 3;
        END IF;

        ------------------------------------------------------------------
        -- COIN MOVEMENT
        ------------------------------------------------------------------
        coin_x <= coin_x - 5;

        IF coin_x < 0 THEN
            coin_x <= 800;
            coin_y <= (coin_y + 211) mod 500 + 50;
            coin_active <= '1';
        END IF;

        coin2_x <= coin2_x - 5;

        IF coin2_x < 0 THEN
            coin2_x <= 800;
            coin2_y <= (coin2_y + 157) mod 500 + 50;
            coin2_active <= '1';
        END IF;

        ------------------------------------------------------------------
        -- PLAYER PHYSICS
        ------------------------------------------------------------------
        velocity_y <= velocity_y + 1;

        IF serve = '1' THEN
            velocity_y <= -10;
        END IF;

        player_y <= player_y + velocity_y;

        IF player_y < 0 THEN
            player_y <= 0;
            velocity_y <= 0;
        ELSIF player_y > 580 THEN
            player_y <= 580;
            velocity_y <= 0;
        END IF;


        ------------------------------------------------------------------
        -- COMPUTE PLAYER CENTER (CRITICAL FIX)
        ------------------------------------------------------------------
        px := 200 + 16;
        py := player_y + 16;
        
        particle_offset <= particle_offset + 2;

IF particle_offset > 20 THEN
    particle_offset <= 0;
END IF;

obstacle2_x <= obstacle2_x - 5;

IF obstacle2_x < 0 THEN
    obstacle2_x <= 800;

    obstacle2_top <= (obstacle2_top + 83) mod 300 + 80;
    obstacle2_bot <= (obstacle2_bot + 151) mod 300 + 250;

    obstacle2_type <= (obstacle2_type + 1) mod 3;
END IF;

obstacle3_x <= obstacle3_x - 5;

IF obstacle3_x < 0 THEN
    obstacle3_x <= 800;

    obstacle3_top <= (obstacle3_top + 127) mod 300 + 80;
    obstacle3_bot <= (obstacle3_bot + 199) mod 300 + 250;

    obstacle3_type <= (obstacle3_type + 1) mod 3;
END IF;
        ------------------------------------------------------------------
        -- OBSTACLE COLLISION
        ------------------------------------------------------------------
        IF (px >= obstacle_x AND px <= obstacle_x + 90) THEN

            IF obstacle_type = 0 THEN
                dx := px - (obstacle_x + 45);
                dy := py - top_height;

                IF (dx*dx + dy*dy <= 60*60) THEN
                    game_on <= '0';
                END IF;

            ELSIF obstacle_type = 1 THEN
                IF (px >= obstacle_x AND px <= obstacle_x + 80 AND
                    py >= bottom_start AND py <= bottom_start + 200) THEN
                    game_on <= '0';
                END IF;

            ELSE
                dx := px - (obstacle_x + 40);
                dy := py - bottom_start;

                IF (dx*dx + dy*dy <= 45*45) THEN
                    game_on <= '0';
                END IF;
            END IF;

        END IF;

        -- Obstacle 2 collision
        IF (px >= obstacle2_x AND px <= obstacle2_x + 90) THEN

            IF obstacle2_type = 0 THEN
                dx := px - (obstacle2_x + 45);
                dy := py - obstacle2_top;

                IF (dx*dx + dy*dy <= 60*60) THEN
                    game_on <= '0';
                END IF;

            ELSIF obstacle2_type = 1 THEN
                IF (px >= obstacle2_x AND px <= obstacle2_x + 80 AND
                    py >= obstacle2_bot AND py <= obstacle2_bot + 200) THEN
                    game_on <= '0';
                END IF;

            ELSE
                dx := px - (obstacle2_x + 40);
                dy := py - obstacle2_bot;

                IF (dx*dx + dy*dy <= 45*45) THEN
                    game_on <= '0';
                END IF;
            END IF;

        END IF;

        -- Obstacle 3 collision
        IF (px >= obstacle3_x AND px <= obstacle3_x + 90) THEN

            IF obstacle3_type = 0 THEN
                dx := px - (obstacle3_x + 45);
                dy := py - obstacle3_top;

                IF (dx*dx + dy*dy <= 60*60) THEN
                    game_on <= '0';
                END IF;

            ELSIF obstacle3_type = 1 THEN
                IF (px >= obstacle3_x AND px <= obstacle3_x + 80 AND
                    py >= obstacle3_bot AND py <= obstacle3_bot + 200) THEN
                    game_on <= '0';
                END IF;

            ELSE
                dx := px - (obstacle3_x + 40);
                dy := py - obstacle3_bot;

                IF (dx*dx + dy*dy <= 45*45) THEN
                    game_on <= '0';
                END IF;
            END IF;

        END IF;

        ------------------------------------------------------------------
        -- COIN COLLISION
        ------------------------------------------------------------------

        -- coin 1
        IF coin_active = '1' THEN
            dx := px - coin_x;
            dy := py - coin_y;

            IF (dx*dx + dy*dy <= 18*18) THEN
                coin_active <= '0';
                score <= score + 1;
            END IF;
        END IF;

        -- coin 2
        IF coin2_active = '1' THEN
            dx := px - coin2_x;
            dy := py - coin2_y;

            IF (dx*dx + dy*dy <= 18*18) THEN
                coin2_active <= '0';
                score <= score + 1;
            END IF;
        END IF;

    END IF;

END PROCESS;

particledraw : PROCESS(pixel_row, pixel_col, player_y, particle_offset)
    VARIABLE pr : INTEGER;
    VARIABLE pc : INTEGER;
BEGIN
    pr := CONV_INTEGER(pixel_row);
    pc := CONV_INTEGER(pixel_col);

    particle_on <= '0';

    -- exhaust stream below player
    IF (pc >= 200 AND pc <= 210 AND
        pr >= player_y + 32 + particle_offset AND
        pr <= player_y + 50 + particle_offset) THEN

        -- flicker effect
        IF (pr mod 2 = 0) THEN
            particle_on <= '1';
        END IF;
    END IF;

END PROCESS;

coindraw : PROCESS(pixel_row, pixel_col, coin_x, coin_y, coin_active, coin2_x, coin2_y, coin2_active)
    VARIABLE pr : INTEGER;
    VARIABLE pc : INTEGER;
    VARIABLE dx : INTEGER;
    VARIABLE dy : INTEGER;
BEGIN
    pr := CONV_INTEGER(pixel_row);
    pc := CONV_INTEGER(pixel_col);

    coin_on <= '0';

    -- coin 1
    IF coin_active = '1' THEN
        dx := pc - coin_x;
        dy := pr - coin_y;

        IF (dx*dx + dy*dy <= 14*14) THEN
            coin_on <= '1';
        END IF;
    END IF;

    -- coin 2
    IF coin2_active = '1' THEN
        dx := pc - coin2_x;
        dy := pr - coin2_y;

        IF (dx*dx + dy*dy <= 14*14) THEN
            coin_on <= '1';
        END IF;
    END IF;
END PROCESS;

END Behavioral;
