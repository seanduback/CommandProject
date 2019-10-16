library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity CommandTop is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
			  red   : out  std_logic;
           green : out  std_logic;
           blue  : out  std_logic;
			  ps2_clk : inout std_logic;
			  ps2_data : inout std_logic);
end CommandTop;

architecture Behavioral of CommandTop is

component vga is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           next_col : out  STD_LOGIC_VECTOR (9 downto 0);
           row : out  STD_LOGIC_VECTOR (9 downto 0);
           blank : out  STD_LOGIC);
end component;

component clock_ctrl is
    Port ( Clk_in : in std_logic;
           Clk_out : out std_logic);
end component;

component FrBuf is
    Port ( next_col : in  STD_LOGIC_VECTOR (9 downto 0);
           row : in  STD_LOGIC_VECTOR (9 downto 0);
           pixel : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end component;

component PixDec is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  pixel : in  STD_LOGIC;
			  pixbomb : in STD_LOGIC_VECTOR(3 downto 0);
			  blank : in  STD_LOGIC;
			  row : in std_logic_vector (9 downto 0);
			  col : in std_logic_vector (9 downto 0);
			  mx :  in  STD_LOGIC_VECTOR (9 downto 0);
			  my : in  STD_LOGIC_VECTOR (8 downto 0);
			  left : in  STD_LOGIC;
			  right : in  STD_LOGIC;
			  crater : in STD_LOGIC_VECTOR (3 downto 0);
           red : out  STD_LOGIC;
           green : out  STD_LOGIC;
           blue : out  STD_LOGIC;
			  exp_flag : out STD_LOGIC;
			  pix_out : out STD_LOGIC);
end component;

component Bomb is
	 generic (	start_column: integer range 0 to 639;
					start_time: integer range 0 to 160);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           row : in STD_LOGIC_VECTOR (9 downto 0);
           next_col : in STD_LOGIC_VECTOR (9 downto 0);
			  exp_flag : in STD_LOGIC;
			  pix_in : in STD_LOGIC;
           pix : out STD_LOGIC;
			  crater : out STD_LOGIC
			  );
end component;

component mouse is --written by Prof Brown
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  -- these signals interface to the ps/2 module
           rx_byte : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_strobe : in  STD_LOGIC;
			  tx_byte : out  STD_LOGIC_VECTOR (7 downto 0);
           tx_strobe : out  STD_LOGIC;
           tx_ready : in  STD_LOGIC;
			  -- these outputs reflect the mouse position and button state
           left : out  STD_LOGIC;
           right : out  STD_LOGIC;
           x : out  STD_LOGIC_VECTOR (9 downto 0);
           y : out  STD_LOGIC_VECTOR (8 downto 0));
end component;

component ps2 is
	Port ( clk : in std_logic; 
		reset : in std_logic; 
		ps2_clk : inout std_logic; 
		ps2_data : inout std_logic; 
		recv_byte : out std_logic_vector (7 downto 0); 
		recv_strobe : out std_logic; 
		txmt_byte: in std_logic_vector (7 downto 0); 
		txmt_strobe: in std_logic; 
		txmt_ready: out std_logic); 
end component;
 
 
signal Clk_out : std_logic;
signal row,col, mx: std_logic_vector(9 downto 0);
signal my : std_logic_vector(8 downto 0);
signal blank, dot, pixel, left, right, exp_flag, pix, impact: std_logic; 
signal border, leftward, upward: boolean;
--signal x: integer range 0 to 639;
--signal y: integer range 0 to 479;
signal icol, irow: integer range 0 to 1023;
signal pixbomb, crater : std_logic_vector(3 downto 0);
signal tx_byte, rx_byte: std_logic_vector(7 downto 0);
signal tx_strobe, rx_strobe, tx_ready: std_logic := '0';


begin

V1: vga port map (clk_out, reset, hsync, vsync, col, row, blank);
C1: clock_ctrl port map (clk, clk_out);
FB1: FrBuf port map (col, row, pixel, clk_out);
D1: PixDec port map (clk_out, reset, pixel, pixbomb, blank, row, col, mx, my, left, right, crater, red, green, blue, exp_flag, pix);
B0: Bomb generic map (180, 160) port map (clk_out, reset, row, col, exp_flag, pix, pixbomb(0), crater(0));
B1: Bomb generic map (260, 90) port map (clk_out, reset, row, col, exp_flag, pix,  pixbomb(1), crater(1));
B2: Bomb generic map (340, 150) port map (clk_out, reset, row, col, exp_flag, pix,  pixbomb(2), crater(2));
B3: Bomb generic map (420, 120) port map (clk_out, reset, row, col, exp_flag, pix,  pixbomb(3), crater(3));
P1: ps2 port map (clk_out, reset, ps2_clk, ps2_data, rx_byte, rx_strobe,tx_byte,tx_strobe,tx_ready);
M1: mouse port map(clk_out,reset,rx_byte,rx_strobe,tx_byte,tx_strobe,tx_ready,left,right,mx,my);
end Behavioral;

