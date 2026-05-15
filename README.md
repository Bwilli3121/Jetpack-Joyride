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
"We pledge our honor that we have abided by the Stevens Honor System" - Alison Dutton, Andrej Rinkovsky, Brennan Williams 
