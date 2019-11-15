----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.11.2019 11:20:32
-- Design Name: 
-- Module Name: antenn_16_form_TB - Behavioral
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

library work;
use work.antenn_array_x16_control;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antenn_16_form_TB is
--    Port ( );
end antenn_16_form_TB;

architecture Behavioral of antenn_16_form_TB is
    signal clk                      : std_logic;
    signal en                       : std_logic;
    signal form_mem_wea             : std_logic:= '0';
    signal form_mem_addra           : std_logic_vector(14 - 1 downto 0);
    signal form_mem_dina            : std_logic_vector(7 downto 0):= (others => '0');
    signal form_counter             : std_logic_vector(14 downto 0):=(others => '0');
    signal param_mem_adda           : std_logic_vector(5 downto 0):= (others => '0');
    signal param_mem_dina           : std_logic_vector(7 downto 0);
    signal param_mem_wea            : std_logic;
    signal param_mem_load           : std_logic;
    signal param_counter            : std_logic_vector(6 downto 0):=(others => '0');
    signal antenn_addr              : std_logic_vector(3 downto 0);
    signal antenn_data              : std_logic_vector(7 downto 0);
    signal antenn_data_valid        : std_logic;
    signal del                      : std_logic;

begin

clk_gen_proc :
process
begin
  clk <= '0';
  wait for 8 ns /2;
  clk <= '1';
  wait for 8 ns /2;
end process;

form_counter_proc :
process(clk)
begin
  if rising_edge(clk) then
    if form_counter(form_counter'length - 1) = '0' then
      form_counter <= form_counter + 1;
      form_mem_addra <= form_counter(form_counter'length - 2 downto 0);
      form_mem_wea <= '1';
    else
      form_mem_wea <= '0';
    end if;
  end if;
end process;

form_mem_dina_proc :
process(clk)
begin
  if rising_edge(clk) then
    if form_mem_wea = '1' then
      form_mem_dina <= form_mem_dina +1;
    end if;
  end if;
end process;

param_mem_adda_proc :
process(clk)
begin
  if rising_edge(clk) then
    if param_counter(param_counter'length - 1) = '0' then
      param_counter <= param_counter + 1;
      if param_counter(1 downto 0) = "10" then
        param_mem_dina <= (others => '1');
      else
        param_mem_dina <= (others => '0');
      end if;
      param_mem_wea <= '1';
    else
      param_mem_wea <= '0';
    end if;
    del <= param_counter(param_counter'length - 1);
    param_mem_load <= param_counter(param_counter'length - 1) and not del;
  end if;
end process;


en <= form_counter(form_counter'length - 1);



andtenn_control_inst : entity antenn_array_x16_control
    generic map(
      c_form_mem_addr_length        => 14,
      c_param_mem_addr_length       => 5
    )
    Port map( 
      clk                           => clk,
      en                            => en,
      form_mem_wea                  => form_mem_wea,
      form_mem_addra                => form_mem_addra,
      form_mem_dina                 => form_mem_dina,
      
      param_mem_adda                => param_mem_adda,
      param_mem_dina                => param_mem_dina,
      param_mem_wea                 => param_mem_wea,
      param_mem_load                => param_mem_load,
      antenn_addr                   => antenn_addr,
      antenn_data                   => antenn_data,
      antenn_data_valid             => antenn_data_valid 
    );



end Behavioral;
