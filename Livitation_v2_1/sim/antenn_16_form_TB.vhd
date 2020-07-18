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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.MATH_REAL.ALL;

library work;
use work.antenn_array_control;
use work.emmitter_address_gen;

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
  constant c_form_memory_length     : integer := 16;
  constant c_num_emmiter            : integer := 4;
  constant c_clk_div                : integer := 4;
  signal clk                        : std_logic;
  signal en                         : std_logic := '0';
  signal form_mem_wea               : std_logic:= '0';
  signal form_mem_addra_next        : std_logic_vector(natural(log2(real(c_form_memory_length)))-1 downto 0):= (others => '0');
  signal form_mem_addra             : std_logic_vector(natural(log2(real(c_form_memory_length)))-1 downto 0):= (others => '0');
  constant form_mem_addra_max       : std_logic_vector(natural(log2(real(c_form_memory_length)))-1 downto 0):= (others => '1');
  signal form_mem_dina              : std_logic_vector(7 downto 0):= (others => '0');
  signal form_counter               : std_logic_vector(14 downto 0):=(others => '0');
  signal param_mem_adda             : integer := 0;
  signal param_mem_adda_next        : integer := 0;
  signal param_mem_dina             : std_logic_vector(7 downto 0) := (others => '0');
  signal param_mem_wea              : std_logic:='0';
  signal param_mem_load             : std_logic;
  signal param_counter              : std_logic_vector(6 downto 0):=(others => '0');
  signal antenn_addr                : std_logic_vector(3 downto 0);
  signal antenn_data                : std_logic_vector(7 downto 0);
  signal antenn_data_valid          : std_logic;
  signal del                        : std_logic;
  signal ampl                       : std_logic_vector(7 downto 0):=x"0f";
  signal addr_out                   : integer range 0 to c_num_emmiter - 1;
  signal n_counter                  : std_logic_vector(15 downto 0);
  signal tick                       : std_logic;
  signal param_apply                : std_logic;
  
  

begin

clk_gen_proc :
process
begin
  clk <= '0';
  wait for 8 ns /2;
  clk <= '1';
  wait for 8 ns /2;
end process;

params_wr_proc :
  process(clk, param_apply)
  begin
    if param_apply = '1' then
      param_mem_adda <= 0;
      param_mem_adda_next <= 0;
    elsif rising_edge(clk) then
      if (param_mem_adda < c_num_emmiter*3 - 1) then
        param_mem_adda_next <= param_mem_adda_next + 1;
        param_mem_adda <= param_mem_adda_next;
        param_mem_wea <= '1';
        param_mem_dina <= param_mem_dina + 1;
      else
        param_mem_wea <= '0';
      end if;
    end if;
  end process;

form_wr_proc :
  process(clk, param_apply)
  begin

    if rising_edge(clk) then
      if (form_mem_addra < form_mem_addra_max) then
        form_mem_wea <= '1';
        form_mem_addra_next <= form_mem_addra_next + 1;
        form_mem_addra <= form_mem_addra_next;
        form_mem_dina <= form_mem_dina + 1;
      else
        form_mem_wea <= '0';
      end if;
    end if;
  end process;

param_apply_proc :
process 
begin
  param_apply <= '0';
  wait for 200 ns;
  param_apply <= '1';
  wait for 8 ns;
  param_apply <= '0';
  wait;
end process;


en <= '1' after 100 ns;

emmitter_address_gen_inst : entity emmitter_address_gen
  Generic map(
    c_num_emmiter                 => c_num_emmiter,
    c_form_memory_length          => c_form_memory_length,
    c_clk_div                     => c_clk_div
  )
  Port map(
    clk                           => clk,
    en                            => en,
    addr_out                      => addr_out,
    n_counter                     => n_counter
  );

antenn_array_control_inst : entity antenn_array_control
    generic map(
      c_form_memory_length         => c_form_memory_length,
      c_num_emmiter                => c_num_emmiter
    )
    Port map( 
      clk                           => clk,

      form_mem_wea                  => form_mem_wea,
      form_mem_addra                => form_mem_addra,
      form_mem_dina                 => form_mem_dina ,

      param_mem_adda                => param_mem_adda,
      param_mem_dina                => param_mem_dina,
      param_mem_wea                 => param_mem_wea ,

      param_apply                   => param_apply,

      N_counter                     => n_counter,
      emmiter_address               => addr_out,

      emmiter_addr_out              => open,
      emmiter_data_out              => open
    );


end Behavioral;
