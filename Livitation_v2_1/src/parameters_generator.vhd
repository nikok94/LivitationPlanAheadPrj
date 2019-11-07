----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2019 10:19:47
-- Design Name: 
-- Module Name: parameters_generator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


library work;
use work.proc_common_pkg.clog2;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity parameters_generator is
    generic (
      c_num_emitter                 : integer := 32;
      c_num_harmonics               : integer := 8
    );
    Port (
      clk               : in std_logic;
      rst               : in std_logic;
      start             : in std_logic;
      addr              : out std_logic_vector(clog2(4*c_num_harmonics * c_num_emitter) - 1 downto 0);
      data              : out std_logic_vector(7 downto 0);
      wr_en             : out std_logic
    );
end parameters_generator;

architecture Behavioral of parameters_generator is

    type ROM    is array (0 to 4*c_num_harmonics * c_num_emitter - 1) of std_logic_vector(7 downto 0);
    constant param_rom  : ROM :=
    (
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76",
    x"00",
    x"00",
    x"ff",
    x"76"
    );
    signal data_counter : std_logic_vector(clog2(4*c_num_harmonics * c_num_emitter) downto 0) := (others => '0');
    signal data_d       : std_logic_vector(7 downto 0);
begin

addr_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        data_counter <= (others => '0');
      else
        if ((start = '1') and (data_counter = 0)) then 
          data_counter <= data_counter + 1;
        end if;
        if ((data_counter > 0) and (data_counter(data_counter'length - 1) = '0')) then
          data_counter <= data_counter + 1;
        end if;
      end if;
      data <= param_rom(to_integer(unsigned(data_counter(data_counter'length - 2 downto 0))));
      addr <= data_counter(addr'length - 1 downto 0);
      wr_en <= not(data_counter(data_counter'length - 1));
    end if;
  end process;


end Behavioral;