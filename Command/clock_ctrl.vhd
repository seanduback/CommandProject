----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:30:44 01/26/2011 
-- Design Name: 
-- Module Name:    clock_ctrl - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity clock_ctrl is
    Port ( Clk_in : in std_logic;
           Clk_out : out std_logic);
end clock_ctrl;

architecture Behavioral of clock_ctrl is

  signal Clk1, Clk2: STD_LOGIC;

begin
  IBUFG_inst : IBUFG
  generic map (IBUF_DELAY_VALUE => "0", IOSTANDARD => "DEFAULT")
  port map (O => Clk1,I => Clk_in);
  
  DCM_SP_inst : DCM_SP
  generic map (
    CLKDV_DIVIDE => 2.0,
    CLKFX_DIVIDE => 27, -- Can be any interger from 1 to 32
    CLKFX_MULTIPLY => 17, -- Can be any integer from 1 to 32
    CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
    CLKIN_PERIOD => 20.0, -- Specify period of input clock
    CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift of "NONE", "FIXED" or "VARIABLE"
    CLK_FEEDBACK => "1X", -- Specify clock feedback of "NONE", "1X" or "2X"
    DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                           -- an integer from 0 to 15
    DLL_FREQUENCY_MODE => "LOW", -- "HIGH" or "LOW" frequency mode for DLL
    DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
    PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 255
    STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
  port map (
    CLK0 => Open, -- 0 degree DCM CLK ouptput
    CLK180 => Open, -- 180 degree DCM CLK output
    CLK270 => Open, -- 270 degree DCM CLK output
    CLK2X => Open, -- 2X DCM CLK output
    CLK2X180 => Open, -- 2X, 180 degree DCM CLK out
    CLK90 => Open, -- 90 degree DCM CLK output
    CLKDV => Open, -- Divided DCM CLK out (CLKDV_DIVIDE)
    CLKFX => Clk2, -- DCM CLK synthesis out (M/D)
    CLKFX180 => Open, -- 180 degree CLK synthesis out
    LOCKED => Open, -- DCM LOCK status output
    PSDONE => Open, -- Dynamic phase adjust done output
    STATUS => Open, -- 8-bit DCM status bits output
    CLKFB => Open, -- DCM clock feedback
    CLKIN => Clk1, -- Clock input (from IBUFG, BUFG or DCM)
    PSCLK => Open, -- Dynamic phase adjust clock input
    PSEN => Open, -- Dynamic phase adjust enable input
    PSINCDEC => Open, -- Dynamic phase adjust increment/decrement
    RST => '0' -- DCM asynchronous reset input
  );

  BUFG_inst : BUFG
  port map (O => Clk_out, I => Clk2);

end Behavioral;

