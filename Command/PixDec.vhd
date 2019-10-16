----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:13:16 10/16/2018 
-- Design Name: 
-- Module Name:    PixDec - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PixDec is
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
			  pix_out : out STD_LOGIC
			  );
end PixDec;

architecture Behavioral of PixDec is

	signal icol, irow, ax, ay : integer range 0 to 1023;
	signal x: integer range 0 to 639;
	signal y: integer range 0 to 479;
	signal dot, explode, over: std_logic;
	signal draw_exp: std_logic := '0' ;
	signal flag_exp, ustrobe, iedge: std_logic;

	signal r : integer range 0 to 31 := 20;
	signal ucount : integer range 0 to etime6 + 1;
	type state_type is (idle, S1);


begin

irow <= to_integer(unsigned(row));
icol <= to_integer(unsigned(col));
x <= to_integer(unsigned(mx));
y <= 479 - to_integer(unsigned(my));

process (reset, clk)
begin 
	if reset = '1' then
		over <= '0';
	elsif rising_edge(clk) then
	
		if ((crater(0) = '1') or (crater(1) = '1') or (crater(2) = '1') or (crater(3) = '1')) then 
			over <= '1';
		end if;
	end if;
end process;
	 
process(blank, pixel, dot, pixbomb, draw_exp, crater)
begin
	red <= '0';
	green  <= '0';
	blue <= '0';
	if blank = '1' then	--blank
		red <= '0';
		green  <= '0';
		blue <= '0';
	elsif dot = '1' then --cursor
		red <= '1'; 
		green <= '1';
		blue <= '0';
	elsif draw_exp = '1' then --explosion
		red <= '1'; 
		green <= '0';
		blue <= '1';	
	elsif (pixbomb(0) = '1') or (pixbomb(1) = '1') or (pixbomb(2) = '1') or (pixbomb(3) = '1') then--bomb
		red <= '1';
		green  <= '0';
		blue <= '0';
	elsif ((crater(0) = '1') or (crater(1) = '1') or (crater(2) = '1') or (crater(3) = '1')) then --crater
		red <= '1';
		green  <= '1';
		blue <= '1';


	elsif pixel = '0' then --sky
		if over = '1' then
		red <= '1';
		green  <= '1';
		blue <= '1';
		else 
		red <= '0';
		green  <= '1';
		blue <= '1';
		end if;
	elsif pixel = '1' then --city
		red <= '0';
		green <= '0';
		blue <= '0';

	end if;
end process;

pix_out <= pixel;
exp_flag <= draw_exp;
	
process(clk, reset) --Draw the cursor
	variable dx, dy: integer range -15 to 15;
begin
	if rising_edge(clk) then
		dot <= '0';
	
		if icol < x+15 and icol > x-15 and irow < y+15 and irow > y-15 then
			dx := x - icol;
			dy := y - irow;
		if (x = icol or y = irow)	and (dx + dy < 155) then 
				dot <= '1';
			end if;
		end if;
	end if;
end process;

	process(clk) --Timer for explosions
	begin		
		if rising_edge(clk) then
			if explode = '1' then 
				r <= 0;
				ucount <= 0;
			end if;
			if (icol = 3) and (irow = 480) then
				if ucount < 6 then
					r <= r + 5;
					ucount <= ucount + 1;
				elsif r /= 0 then
					r <= r - 1;
				end if;
			end if;
		end if;
	end process;
				
	process(clk, reset) -- creates explosions based on r
		variable ex: integer range -31 to 31;
		variable ey: integer range -31 to 31; 
	begin
		if rising_edge(clk) then
			if explode = '1' then
				ax <= x;
				ay <= y;
			end if;
			draw_exp <= '0';
			if (icol < ax+32) and (icol > ax-32) and (irow < ay+32) and (irow > ay-32) then
				ex := ax - icol;
				ey := ay - irow;
				if ex*ex + ey*ey < r*r  then 
					draw_exp <= '1';
				end if;
			end if;
		end if;
	end process;

iedge <= left when rising_edge(clk);  --Rising Edge Flip Flop
explode <= not iedge and left;           

end Behavioral;

