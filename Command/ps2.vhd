----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:33:21 11/01/2018 
-- Design Name: 
-- Module Name:    ps2 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity ps2 is
	Port ( clk : in std_logic; 
		reset : in std_logic; 
		ps2_clk : inout std_logic; 
		ps2_data : inout std_logic; 
		recv_byte : out std_logic_vector (7 downto 0); 
		recv_strobe : out std_logic; 
		txmt_byte: in std_logic_vector (7 downto 0); 
		txmt_strobe: in std_logic; 
		txmt_ready: out std_logic); 
end ps2;


architecture Behavioral of ps2 is

constant time100us : integer := 3150;
constant time5us : integer := 158;
signal ucount : integer range 0 to time100us;
type state_type is (idle, wait1, wait2, start, B0, B1, B2, B3, B4, B5, B6, B7, parity, end1, A_start, A0, A1, A2, A3, A4, A5, A6, A7, A_end1);
signal Q, N : state_type := idle; 
signal count : integer range 0 to 32;
signal clean_clk, iedge, edge, ustrobe, idata, Astrobe, shift: std_logic;
signal B, A: std_logic_vector (7 downto 0); 
signal iclk : boolean;
begin
	
ps2_clk <= '0' when not iclk else 'Z';
ps2_data <= '0' when idata = '0' else 'Z';
	
	process(clk, reset) -- clean clk
	begin
		if reset = '1' then 
			count <= 0;
			clean_clk <= '0';
			
		elsif rising_edge(clk) then  
--			mouse_count <= mouse_count + 1;
			if count /= 32 then 
				count <= count + 1;
				
			else 
				clean_clk <= ps2_clk;
				count <= 0;
			end if;
		end if;
	end process;
	
iedge <= clean_clk when rising_edge(clk);  --Falling Edge Flip Flop
edge <= iedge and not clean_clk;           --Falling Edge Flip Flop
	
	process(clk) --Timer
	begin		
		if rising_edge(clk) then
			if ustrobe = '1' then
				ucount <= ucount + 1;
			else
				ucount <= 0;
			end if;
		end if;
	end process;
	
	process(clk, reset) -- txmt_byte goes to b
	begin
		if reset = '1' then
		b <= "00000000";
		elsif rising_edge(clk) and txmt_strobe = '1' then
		b <= txmt_byte;
		end if;
	end process;
	
	process(clk, reset) -- state register 
	begin
		if reset = '1' then
		Q <= idle;
		elsif rising_edge(clk) then
		Q <= N;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) and shift = '1' then --shift register 
			A (6 downto 0) <= A (7 downto 1);
			if ps2_data = '0' then 
				A(7) <= '0';
			else 
				A(7) <= '1';
			end if;
		end if;
	end process;
	
recv_strobe <= Astrobe;
recv_byte <= A;
		
	process(Q, txmt_strobe, ucount, edge, B)--State machine for txmt
	begin
		shift <= '0';
		ustrobe <= '0';
		iclk <= true;
		idata <= '1';
		Astrobe <= '0';
		txmt_ready <= '0';
		Case Q is 
			when idle =>
				txmt_ready <= '1';
				if txmt_strobe = '1' then
					N <= wait1;
				elsif edge = '1' then
					N <= A_start;
				else
					N <= idle;
				end if;
			when A_start =>
				if edge = '0' then 
					N <= A_start;
				else
					N <= A0;
					shift <= '1';
				end if;
			when A0 =>
				if edge = '0' then
					N <= A0;
				elsif edge = '1' then
					shift <= '1';
					N <= A1;
				end if;	
			when A1 =>
				if edge = '0' then
					N <= A1;
				elsif edge = '1' then
					shift <= '1';
					N <= A2;
				end if;
			when A2 =>
				if edge = '0' then
					N <= A2;
				elsif edge = '1' then
					shift <= '1';
					N <= A3;
				end if;
			when A3 =>
				if edge = '0' then
					N <= A3;
				elsif edge = '1' then
					shift <= '1';
					N <= A4;
				end if;
			when A4 =>
				if edge = '0' then
					N <= A4;
				elsif edge = '1' then
					shift <= '1';
					N <= A5;
				end if;
			when A5 =>
				if edge = '0' then
					N <= A5;
				elsif edge = '1' then
					shift <= '1';
					N <= A6;
				end if;
			when A6 =>
				if edge = '0' then
					N <= A6;
				elsif edge = '1' then
					shift <= '1';
					N <= A7;
				end if;
			when A7 =>
				if edge = '0' then
					N <= A7;
				elsif edge = '1' then
					N <= A_end1;
				end if;
			when A_end1 =>
				if edge = '0' then 
					N <= A_end1;
				else 
					Astrobe <= '1';
					N <= idle;
				end if;
			when wait1 =>
				iclk <= false;
				if ucount /= time100us then
					N <= wait1;
					ustrobe <= '1';
				elsif ucount = time100us then
					N <= wait2;
				end if;
			when wait2 => 
				iclk <= false;
				idata <= '0';
				if ucount /= time5us then
					N <= wait2;
					ustrobe <= '1';
				elsif ucount = time5us then
					N <= start;
				end if;
			when start =>
				idata <= '0';
				if edge = '0' then
					N <= start;
				elsif edge = '1' then
					N <= B0;
				end if;
			when B0 =>
				idata <= B(0);
				if edge = '0' then
					N <= B0;
				elsif edge = '1' then
					N <= B1;
				end if;
			when B1 =>
				idata <= B(1);
				if edge = '0' then
					N <= B1;
				elsif edge = '1' then
					N <= B2;
				end if;
			when B2 =>
				idata <= B(2);
				if edge = '0' then
					N <= B2;
				elsif edge = '1' then
					N <= B3;
				end if;
			when B3 =>
				idata <= B(3);
				if edge = '0' then
					N <= B3;
				elsif edge = '1' then
					N <= B4;
				end if;
			when B4 =>
				idata <= B(4);
				if edge = '0' then
					N <= B4;
				elsif edge = '1' then
					N <= B5;
				end if;
			when B5 =>
				idata <= B(5);
				
				if edge = '0' then
					N <= B5;
				elsif edge = '1' then
					N <= B6;
				end if;
			when B6 =>
				idata <= B(6);
				if edge = '0' then
					N <= B6;
				elsif edge = '1' then
					N <= B7;
				end if;
			when B7 => 
				idata <= B(7);
				if edge = '0' then
					N <= B7;
				elsif edge = '1' then
					N <= parity;
				end if;
			when parity =>
				idata <= not(B(0) xor B(1) xor B(2) xor B(3) xor B(4) xor B(5) xor B(6) xor B(7));
				if edge = '0' then
					N <= parity;
				elsif edge = '1' then
					N <= end1;
				end if;
			when end1 =>
				idata <= '1';
				if edge = '0' then
					N <= end1;
				elsif edge = '1' then
					N <= idle;
				end if;
			end case;
		end process;
			
end Behavioral;



