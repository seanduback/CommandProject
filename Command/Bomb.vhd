----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2018 08:41:59 PM
-- Design Name: 
-- Module Name: Bomb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bomb is
generic( start_column: integer range 0 to 639;
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
end Bomb;

architecture Behavioral of Bomb is

type bomb_mask_type is array (0 to 14) of std_logic_vector(6 downto 0);
constant bomb_mask : bomb_mask_type := 
    ("0011100", 
     "0111110", 
     "1111111", 
     "1100011", 
     "1011101", 
     "1111111", 
     "1101011", 
     "1111111", 
     "0111110", 
     "0011100", 
     "0001000", 
     "0011100", 
     "0111110", 
     "1101011", 
     "1001001");

signal x : unsigned(9 downto 0);
signal y : unsigned(8 downto 0);
signal ucol, x_sprite: unsigned(10 downto 0);
signal urow, y_sprite: unsigned(9 downto 0);
signal p, c, center_flag, right_flag, left_flag, start: std_logic;
signal dir_flag, hit : std_logic := '0';
signal count : integer range 0 to start_time;
--constant initial_col0
--constant initial_col1
--constant initial_col0
--constant initial_col3


begin
ucol <= '0' & unsigned(next_col); -- outputs bomb pixel and position 
urow <= unsigned(row);
pix <= p when rising_edge(clk);
crater <= c when rising_edge(clk);
y_sprite <= y - urow;
x_sprite <= ucol - x;

process (reset, clk)
begin 
	if reset = '1' then
		hit <= '0';
	elsif rising_edge(clk) then
	
		if p = '1' and pix_in = '1' then 
			hit <= '1';
		end if;
	end if;
end process;
	
process(y_sprite, x_sprite, hit) -- creates bomb pixel
	variable in_range : boolean;
	variable dx, dy : integer range -1023 to 1023;
begin 
	if hit = '1' then 
		dy := (to_integer(urow)) - (to_integer(y + 7));
		dx := (to_integer(ucol)) - (to_integer(x + 3));
		if dy < 0 then 
			dy := 0;	
		end if;
		c <= '0';
		p <= '0';
		if ((dx*dx) + (dy*dy) < 1200) then 
			c <= '1';
--			if dy < 0 then 
--			dy <= 0;	
--			end if;
		end if;
	else 
	in_range := (y_sprite <= 14) and (x_sprite <= 6);
		if in_range and start = '1' then
			p <= bomb_mask(to_integer(y_sprite))(to_integer(x_sprite));
		else 
			p <= '0';
		end if;
	end if;
end process;

process(clk) -- Randomizer 
begin
	if rising_edge(clk) then
			dir_flag <= not dir_flag;
	end if;
end process;

	process(clk, reset) --Timer
	begin	
		if reset = '1' then
			count <= 0;
			start <= '0';
		elsif rising_edge(clk) then
				if (ucol = 3) and (urow = 480) then
					if count = start_time then
						start <= '1';
					else
						count <= count + 1;
					end if;
				end if;
		end if;
	end process;
	
--process(urow, ucol, x, y) -- crater flag
--begin 
--	dy <= to_integer(urow) - to_integer(y);
--	dx <= to_integer(ucol) - to_integer(x);
--	if dy < 0 then 
--		dy <= 0;
--	end if;
--	if (dx*dx) + (dy*dy) < 30*30 then 
--		crater <= '1';
--	else 
--		crater <= '0';
--	end if;
--end process; 

process(clk, reset) -- dictates direction and movement of the bombs on reset, explosion, and off screen
begin
	if reset = '1' then 
      x <= to_unsigned(start_column, x'length); 
      y <= (others => '0');
		  center_flag <= '1';
		  left_flag <= '0';
		  right_flag <= '0';
	elsif rising_edge(clk) then

		  if (p = '1' and exp_flag = '1') or y > 491 or x > 636 or x = 0 then 
				x <= to_unsigned(start_column, x'length); 
				y <= (others => '0');
				if dir_flag = '1' then
					if left_flag = '1' then 
						center_flag <= '1';
						left_flag <= '0';
					elsif center_flag = '1' then 
						right_flag <= '1';
						center_flag <= '0';
					elsif right_flag = '1' then 
						left_flag <= '1';
						right_flag <= '0';
					else 
						left_flag <= '1';
					end if;
				else
					if left_flag = '1' then 
						right_flag <= '1';
						left_flag <= '0';
					elsif center_flag = '1' then 
						left_flag <= '1';
						center_flag <= '0';
					elsif right_flag = '1' then 
						center_flag <= '1';
						right_flag <= '0';
					else 
						right_flag <= '1';
					end if;
	
				end if;
        elsif (urow = 480) and (ucol = 0) and start = '1' then
			  		if hit = '1' then
						x <= x;
						y <= y;
				
				  elsif left_flag = '1' then
						x <= x + 1;
						y <= y + 2;
				  elsif center_flag = '1' then
						x <= x + 0;
						y <= y + 2;
				  else
						x <= x - 1;
						y <= y + 2;
				  end if;

			end if;
       
    end if;
end process;
        


end Behavioral;
