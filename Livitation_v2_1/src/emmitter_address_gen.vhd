----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2020 15:19:17
-- Design Name: 
-- Module Name: emmitter_address_gen - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity emmitter_address_gen is
    Generic(
      c_emmit_addr_length           : integer := 4;
      c_div_count_max_length        : integer := 4
    );
    Port ( 
      clk           : in std_logic;
      en            : in std_logic;
      div_range     : in std_logic_vector(c_div_count_max_length - 1 downto 0);
      addr_out      : out std_logic_vector(c_emmit_addr_length - 1 downto 0);
      addr_wr_en    : out std_logic;
      N_counter_edge: out std_logic
    );
end emmitter_address_gen;

architecture Behavioral of emmitter_address_gen is
    signal clk_counter      : std_logic_vector(c_div_count_max_length - 1 downto 0):= (others => '0');
    signal addr_counter     : std_logic_vector(c_emmit_addr_length - 1 downto 0);
    constant addr_max_count : std_logic_vector(c_emmit_addr_length - 1 downto 0) := (others => '1');
    signal addr_edge_sig    : std_logic;
    signal addr_edge        : std_logic;
    
begin

process(clk, en)
begin
  if (en = '0') then
    clk_counter <= (others => '0');
    addr_edge_sig <= '0';
  elsif rising_edge(clk) then
    if (clk_counter = div_range) then
      addr_edge_sig <= '1';
      clk_counter <= (others => '0');
    else
      clk_counter <= clk_counter + 1;
      addr_edge_sig <= '0';
    end if;
  end if;
end process;

N_counter_edge_proc :
  process(clk, en)
  begin
    if (en = '0') then
      N_counter_edge <= '0';
    elsif rising_edge(clk) then
      if (addr_edge_sig = '1') then
        if (addr_max_count = addr_counter) then
          N_counter_edge <= '1';
        end if;
      else
        N_counter_edge <= '0';
      end if;
    end if;
  end process;


antenn_address_proc :
  process(clk, en)
  begin
    if (en = '0') then
      addr_counter <= (others => '0');
      addr_edge <= '0';
    elsif rising_edge(clk) then
      if (addr_edge_sig = '1') then
        addr_counter <= addr_counter + 1;
        addr_edge <= '1';
      else
        addr_edge <= '0';
      end if;
    end if;
  end process;

process(clk)
  begin
    if rising_edge(clk) then
      addr_out <= addr_counter;
      addr_wr_en <= addr_edge;
    end if;
  end process;
  

end Behavioral;
