----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2020 15:19:17
-- Design Name: 
-- Module Name: ram_sclk - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_sclk is
  Generic(
    c_data_width    : integer := 8;
    c_num_data      : integer := 16
  );
  Port (
    clk             : in std_logic;
    addr            : in std_logic_vector(natural(log2(real(c_num_data))) - 1 downto 0);
    data            : in std_logic_vector(c_data_width - 1 downto 0);
    we              : in std_logic;
    q               : out std_logic_vector(c_data_width - 1 downto 0)
  );
end ram_sclk;

architecture Behavioral of ram_sclk is
  type ram   is array (0 to c_num_data - 1) of std_logic_vector(c_data_width - 1 downto 0);
  signal memory : ram;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if (we = '1') then
        memory(conv_integer(unsigned(addr))) <= data;
      end if;
      q <= memory(conv_integer(unsigned(addr)));
    end if;
  end process;
end Behavioral;
