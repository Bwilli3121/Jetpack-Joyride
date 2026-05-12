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
<video src="path/to/Jpjrvideo.mp4" width="320" height="240" controls></video>

or

<iframe width="560" height="315" src=["https://www.youtube.com/embed/video-id](https://youtu.be/u_vh7JEoxjg?si=vh3BrAQEWiXEdQTH)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

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



---
## Modules & FSMs


---
"We pledge our honor that we have abided by the Stevens Honor System" - Alison Dutton, Andrej Rinkovsky, Brennan Williams 
