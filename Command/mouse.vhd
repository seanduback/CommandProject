----------------------------------------------------------------------------------
-- Mouse Driver
-- Create Date:    3/14/2018 
-- Module Name:    mouse - Behavioral 
-- Description: This module interfaces with the ps/2 module to first enable the
-- then monitor the position and the buttons 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mouse is
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
end mouse;

architecture Behavioral of mouse is
	type state_type is (do_reset, awaitACK1, awaitAA, await00, do_enable, awaitACK2, awaitB, awaitX, awaitY);
	signal state: state_type;
	signal b_reg: std_logic_vector(6 downto 0);
	signal x_reg: std_logic_vector(7 downto 0);
	signal x_int: unsigned(9 downto 0);
	signal y_int: unsigned(8 downto 0);
	signal new_x: signed(10 downto 0);
	signal new_y: signed(9 downto 0);
	signal ready: std_logic;
begin
	-- tx_ready is a signal we get from ps2 interface indicating that the interface is ready to send a byte
	-- we will delay it one cycle to manage the combinational delay. It won't hurd to delay 30ns.
	ready <= tx_ready when rising_edge(clk);
	
	-- we only transmit in the states that send the reset command (FF) and the enable commend (F4).
   tx_strobe <= '1' when ready='1' and (state = do_reset or state = do_enable) else '0';
	tx_byte <= X"FF" when state = do_reset else X"F4";
	
	-- calculate new x and y positions from the mouse data. Ignore the mouse data if the overflow
	-- flag is set
	new_x <= signed('0' & x_int) + signed(b_reg(3) & x_reg) when b_reg(5)='0' else signed('0' & x_int);
	new_y <= signed('0' & y_int) + signed(b_reg(4) & rx_byte) when b_reg(6)='0' else signed('0' & y_int);
	
	-- Controller. Note that the next state decoder is combined with the state register
	process(clk,reset)
	begin
		if reset = '1' then
			state <= do_reset;
			x_int <= to_unsigned(320,10); -- (320,240) is the center of the screen
			y_int <= to_unsigned(240,9);
		elsif rising_edge(clk) then
			if state = do_reset then -- the purpose of this state is to send the reset (FF) command
				if ready = '1' then
					state <= awaitACK1; -- if ready is true, tx_strobe will have been asserted, so move on
				end if;
			elsif state = do_enable then -- the purpose of this state is to send the enable (F4) command
				if ready = '1' then
					state <= awaitACK2; -- if ready is true, tx_strobe will have been asserted, so move on
				end if;
			elsif rx_strobe = '1' then -- if not in the transmitting states, wait for data from ps/2 interface
				case state is
					when awaitACK1 => state <= awaitAA;   -- acknowledge of reset has arrived, AA00 will follow
					when awaitAA   => state <= await00;   -- AA (we hope) has arrived, we don't bother to check it
					when await00   => state <= do_enable; -- 00 (we hope) has arrived, send the enable commamd
					when awaitACK2 => state <= awaitB;    -- cknowledge of enable has arrived, normal packets will follow
					when awaitB =>
						if rx_byte(3) = '1' then -- indicates a movement packet
							b_reg <= rx_byte(7 downto 4) & rx_byte(2 downto 0);
							-- breg = [6:Over Y, 5: Over X, 4:Sign Y, 3:Sign X, 2:Middle B, 1:Right B, 0:Left B]
							state <= awaitX; -- the delta x byte will follow
						end if;
					when awaitX =>
						x_reg <= rx_byte; -- sequester the delta x byte for later use
						state <= awaitY;
					when awaitY =>
						-- all the bytes are here, so new_x and new_y will be valid now. clamp the x value to the
						-- range 0 - 639
						if new_x < 0 then
							x_int <= (others=>'0');
						elsif new_x < 640 then
							x_int <= unsigned(new_x(x_int'range));
						else
							x_int <= to_unsigned(639,x_int'length);
						end if;
						-- clamp the x value to the range 0 - 479
						if new_y < 0 then
							y_int <= (others=>'0');
						elsif new_y < 480 then
							y_int <= unsigned(new_y(y_int'range));
						else
							y_int <= to_unsigned(479,y_int'length);
						end if;
						state <= awaitB; -- go back to waiting for button byte (first byte of movement packet)
					when others=>
						state <= do_reset; -- catch-all - should never happen
				end case;
			end if;
		end if;
	end process;
	
	-- output button and position state
	left <= b_reg(0);
	right <= b_reg(1);
	x <= std_logic_vector(x_int);
	y <= std_logic_vector(y_int);

end Behavioral;

