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
    c_num_emmiter                 : integer := 4;
    c_form_memory_length          : integer := 8192;
    c_clk_div                     : integer := 4
  );
  Port ( 
    clk                           : in std_logic;
    en                            : in std_logic;
    addr_out                      : out integer range 0 to c_num_emmiter - 1;
    n_counter                     : out std_logic_vector(15 downto 0)
  );
end emmitter_address_gen;

architecture Behavioral of emmitter_address_gen is
    signal clk_counter      : integer range 0 to c_clk_div - 1;
    signal tick_irq         : std_logic := '0';
    signal addr_counter     : integer range 0 to c_num_emmiter - 1;
    signal n_count          : std_logic_vector(15 downto 0):= (others => '0');
    signal addr_edge        : std_logic;
    
begin

process(clk, en)
begin
  if (en = '0') then
    clk_counter <= 0;
    tick_irq <= '0';
  elsif rising_edge(clk) then
    if (clk_counter < c_clk_div - 1) then
      tick_irq <= '0';
      clk_counter <= clk_counter + 1;
    else
      clk_counter <= 0;
      tick_irq <= '1';
    end if;
  end if;
end process;

antenn_address_proc :
  process(clk, en)
  begin
    if (en = '0') then
      addr_counter <= 0;
      addr_edge <= '0';
      n_count <= (others => '0');
      n_counter <= (others => '0');
    elsif rising_edge(clk) then
      if (tick_irq = '1') then
        addr_edge <= '1';
        if (addr_counter < c_num_emmiter - 1) then
          addr_counter <= addr_counter + 1;
        else
          addr_counter <= 0;
          if (n_count < c_form_memory_length - 1) then
            n_count <= n_count + 1;
          else
            n_count <= (others => '0');
          end if;
        end if;
      else
        addr_edge <= '0';
      end if;
      n_counter <= n_count;
      addr_out <= addr_counter;
    end if;
  end process;

end Behavioral;
