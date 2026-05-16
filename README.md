# Jetpack-Joyride
Final Project for CPE 487 Digital System Design

By Alison Dutton, Andrej Rinkovsky, & Brennan Williams

---
## Project Overview
Our Project recreates the mobile phone game Jetpack Joyride, using a sprite of a Club Penguin character with a jetpack on. Using Lab 6, Pong Game, we modified the code to make our desired gameplay. We used VHDL through Vivado and running on a Nexys A7-100T FPGA board. The code works to move your character along the positive x axis automatically while you control moving up the y axis using the BTNC button, avoiding obsticles and collecting coins. Our LED display on the Nexys A7 board gives a binary count of how far on the x axis you go along with the amount of coins you collect. 

---
## Hardware Required
- Digilent Nexys A7-100T FPGA Board
- Micro USB cable (connects to computer)
- VGA to HDMI Adapter
- HDMI cable
- TV or monitor with HDMI input
## Software Required
- AMD Vivado (2025.2)

---
## How to Run on Vivado 
- Open Vivado and create a new project
- Use the provided files when asked for imported files
- Add the .xdc file in constraints
- Import file and slect Nexys A7-100T in boards section
- When the project opens, Run Sythesis, Run Implementation, Generate Bitstream, then open Hardware Manager to open target, and finally program device

---
## Video Demonstration
[![Watch the video](https://img.youtube.com/vi/[<VIDEO_ID>](https://youtu.be/u_vh7JEoxjg)/hqdefault.jpg)](https://youtu.be/u_vh7JEoxjg)


---
## Inputs and Outputs
For Jetpack.vhd:

```vhd1
ENTITY pong IS
PORT(
    clk_in      : IN  STD_LOGIC;
    btn0        : IN  STD_LOGIC;
    btnl        : IN  STD_LOGIC;
    btnr        : IN  STD_LOGIC;

    VGA_red     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    VGA_green   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    VGA_blue    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    VGA_hsync   : OUT STD_LOGIC;
    VGA_vsync   : OUT STD_LOGIC;

    SEG7_anode  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    SEG7_seg    : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);

    LED         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
);
END pong;
``` 

For Jetpack_and_objects.vhd:

```vhd1
ENTITY bat_n_ball IS
PORT(
    v_sync      : IN  std_logic;
    pixel_row   : IN  std_logic_vector(9 DOWNTO 0);
    pixel_col   : IN  std_logic_vector(9 DOWNTO 0);
    serve       : IN  std_logic;
    bat_x       : IN  std_logic_vector(9 DOWNTO 0);

    red         : OUT std_logic;
    green       : OUT std_logic;
    blue        : OUT std_logic;

    hits        : OUT std_logic_vector(15 DOWNTO 0)
);
END bat_n_ball;
``` 


---
## Code Modifications
Our code modifications mainly consisted of changed in the Jetpack, Jetpack_and_Objects, and leddec files. The basis of these files came from modifications of the lab 6 pong, bat_n_ball, and leddec files. 

For the Jetpack_and_Objects file (formerly bat_n_ball) we changed and added Signals and Constants to make the bat into the Jetpack (with a sprite) that moves up and down the y axis while automatically moving along the x axis. We also added in signals for the coins and obstacles that show up on different spots along the y axis. To make the objects different size along with the postions we added Else/If loops. The objects, coins, and jetpack all needed to be drawn and colored which we achieved by modifing the draw process. 

For the Jetpack file (formerally pong) we had to change the architecture for every file that was being called upon, mostly adding in extra changes for the hit values, display, and leds. We also had to change the port and port map codes to modify the way we called files. 

Finally, for the leddec file we needed to change the leds to display basic numbers oppossed to binary or hex numbers. We also needed to change the display so coins collected would be on the left display and distance traveled would be on the right display.

---
## Modules & FSMs
<img width="392" height="206" alt="image" src="https://github.com/user-attachments/assets/5ab6bbc6-79b8-4f55-96bf-b6f1586028f0" />


---
## Summary
Individual Contributions:
Alison Dutton — Primary developer of the game engine (jetpack_and_objects.vhd). Alison designed and implemented the core gameplay systems including player physics (gravity and flap mechanics), obstacle generation and scrolling logic, coin spawning and collection, collision detection using dx²+dy² integer math, and the colordraw color priority process. She also handled the sprite integration into the jetpackdraw process.
Andrej Rinkovsky — Responsible for the clock wizard configuration (clk_wiz_0, clk_wiz_0_clk_wiz) and the leddec16 7-segment display module, including the Double Dabble BCD conversion and the dual-score display layout (distance on the left four digits, coins on the right four). Also contributed to project documentation, the presentation poster, and the block diagrams and FSM diagrams in the repository.
Brennan Williams — Contributed to game engine development and was the primary tester throughout the project, identifying and helping resolve bugs related to obstacle collision detection, game speed tuning, and edge-case behavior. Also led report writing and poster design for the final presentation.
Timeline (Rough Estimates)

==>Identified Jetpack Joyride as the project concept. Forked the Lab 6 Pong starter code and began exploring which modules needed modification. Set up the GitHub repository.
==>Alison began reworking bat_n_ball into the side-scrolling game engine — replacing the ball and bat with a fixed-x player controlled by gravity/flap physics, and adding the first scrolling obstacle. Andrej started working on the clock wizard setup and understanding the leddec16 module.
==> Added the sprite rendering system (converting a character image to a 32×32 binary sprite array), implemented multiple obstacle types (circles and rectangles) with shape cycling, and introduced coin spawning and collection. Andrej reworked leddec16 to support dual-score BCD output across all eight 7-segment digits. Brennan began systematic game testing and identified early collision and scoring bugs.
==>(Final Week): Bug fixing and polish — resolved obstacle collision detection issues, tuned scrolling speed and physics constants, added the particle exhaust effect, and finalized the constraint file. Assembled the repo documentation, recorded the demo video, and prepared the presentation poster.

Difficulties Encountered:
Sprite creation and rendering. One of the earliest challenges was getting the player character sprite into the design. We started with a JPEG of a Club Penguin character with a jetpack and had to manually convert it into a binary representation suitable for a VHDL constant array. The sprite is stored as a 32-row array of 128-bit vectors with 4 bits per pixel. Getting the indexing math right (idx := 127 - (px * 4)) to correctly extract each pixel's nibble from the array took several iterations of trial and error, as off-by-one errors would shift or mirror the entire sprite on screen.
7-segment display (leddec16) issues. The original leddec16 from Lab 6 displayed a single 16-bit hex value. Converting it to show two separate decimal scores required implementing BCD conversion, which we did using the Double Dabble algorithm. Before landing on that approach, we ran into multiple issues: the display would show hex letters (A–F) instead of decimal digits, the digit counts wouldn't line up correctly across the eight displays, and signals from other parts of the design were inadvertently interfering with the display data. We also had to restructure the module's port interface from a single data input to separate score and coins inputs, which required corresponding changes in the component declaration and port map in jetpack.vhd.
Game engine logic and bug fixing. Developing the game loop in the mball process was an iterative process with frequent testing on the board. Early versions had collision detection problems where the player would pass through obstacles or die without visibly touching them, was caused by using the sprite's corner coordinates instead of its center point for the collision check, which we fixed by computing px := 200 + 16 and py := player_y + 16. Obstacle speed tuning was another challenge; too fast and the game was unplayable, too slow and it was trivial. We settled on 5 pixels per frame after testing several values. We also encountered issues with obstacles stacking on top of each other since all three initially spawned at similar x-positions — staggering them to 800, 1200, and 1600 solved the overlap problem.


"We pledge our honor that we have abided by the Stevens Honor System" - Alison Dutton, Andrej Rinkovsky, Brennan Williams 
