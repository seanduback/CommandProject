library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vga is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           next_col : out  STD_LOGIC_VECTOR (9 downto 0);
           row : out  STD_LOGIC_VECTOR (9 downto 0);
           blank : out  STD_LOGIC);
end vga;

architecture Behavioral of vga is

signal Hcount : integer range 0 to 831;
signal Vcount : integer range 0 to 519;
signal Vert_Enable : boolean;
signal Hblank, Vblank : std_logic;

begin

process(clk, reset) --horizontal
begin
	if reset = '1' then
		Hcount <= 0;
		hsync <=  '1';
		Hblank <= '1';

	elsif rising_edge(clk) then

		if Hcount = 664 then
			hsync <= '0';
		elsif Hcount = 704 then
			hsync <= '1';
		end if;

		if Hcount = 831 then
			Hcount <= 0;
		else
			Hcount <= Hcount +1;
		end if;
		
		if Hcount = 640 then
			Hblank <= '1';
		elsif Hcount = 0 then
			Hblank <= '0';
		end if;
	end if;
end process;

next_col <= std_logic_vector(to_unsigned(Hcount, 10));
Vert_Enable <=  Hcount = 684; 

process(clk, reset) -- vertical
begin
	if reset = '1' then
		Vcount <= 0;
		vsync<=  '1';
		Vblank <= '1';

	elsif rising_edge(clk) then

		if Vcount = 489 then
			vsync <= '0';
		elsif Vcount = 491 then
			vsync<= '1';
		end if;
		
		if vert_enable then
		
			if Vcount = 519 then
				Vcount <= 0;
			else
				Vcount <= Vcount +1;
			end if;
		end if;
		
		if Vcount = 480 then
			Vblank <= '1';
		elsif Vcount = 0 then
			Vblank <= '0';
		end if;
	end if;
end process;

row <= std_logic_vector(to_unsigned(Vcount, 10));

blank <= '1' when Hblank = '1' or  Vblank = '1' else '0';

end Behavioral;
