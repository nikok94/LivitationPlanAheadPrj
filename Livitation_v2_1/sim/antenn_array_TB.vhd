----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.07.2019 18:16:16
-- Design Name: 
-- Module Name: antenn_array_TB - Behavioral
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
use IEEE.Std_Logic_Arith.ALL;

use STD.textio.all;

library work;
use work.antenn_array_x32_control;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antenn_array_TB is
--    Port ( );
end antenn_array_TB;

architecture Behavioral of antenn_array_TB is
    file file_sin           : text;
    file file_param1        : text;
    signal clk              : std_logic;
    signal rst              : std_logic;
    signal sin_mem_wea      : std_logic;
    signal sin_mem_adda     : std_logic_vector(10 downto 0):=(others => '0');
    signal sin_mem_adda_d   : std_logic_vector(10 downto 0):=(others => '0');
    signal sin_mem_adda_d1  : std_logic_vector(10 downto 0):=(others => '0');
    signal sin_mem_dina     : std_logic_vector(7 downto 0);
    signal sin_mem_dina_d   : std_logic_vector(7 downto 0);
    signal sin_mem_wea_d    : std_logic;
    signal param1_mem_wea   : std_logic;
    signal param1_mem_adda  : std_logic_vector(9 downto 0);
    signal param1_mem_dina  : std_logic_vector(7 downto 0);
    signal param1_mem_wea_d : std_logic;
    signal param1_mem_adda_d: std_logic_vector(9 downto 0);
    signal param1_mem_dina_d: std_logic_vector(7 downto 0);
    signal antenn_addr      : std_logic_vector(4 downto 0);
    signal antenn_data      : std_logic_vector(7 downto 0);
    signal antenn_data_val  : std_logic;
    signal param_mem_load   : std_logic;
    signal start_n          : std_logic;
    signal en               : std_logic:= '0';
    
    
    
begin

clk_gen_proc : 
  process
  begin
    clk <= '0';
    wait for 5 ns/2;
    clk <= '1';
    wait for 5 ns/2;
  end process;

rst_proc :
  process
  begin
    rst <= '1';
    wait for 100 ns;
    wait until rising_edge(clk);
    wait for 5 ns;
    rst <= '0';
    wait;
  end process;

start_proc :
  process
  begin
    start_n <= '0';
    wait for 20000 ns;
    start_n <= '1';
    wait;
  end process;


  process
    variable v_ILINE     : line;
    variable v_ADD_TERM1 : integer;
    variable v_SPACE     : character;
     
  begin
    sin_mem_wea <= '0';
    sin_mem_dina <= (others => '0');
    file_open(file_sin, "D:\FPGA_prj\FirstTest\FirstTest.srcs\sim_1\new\MyData.txt",  read_mode);
    wait until rst = '0';
    wait until rising_edge(clk);
    wait for 5 ns;
    while not endfile(file_sin) loop
    sin_mem_wea <= '1';
      readline(file_sin, v_ILINE);
      read(v_ILINE, v_ADD_TERM1);
      
      -- Pass the variable to a signal to allow the ripple-carry to use it
      sin_mem_dina <= conv_std_logic_vector(v_ADD_TERM1, 8);
      wait for 5 ns;
    end loop;
    wait for 10 ns;
    sin_mem_wea <= '0';
    file_close(file_sin);
    wait;
  end process;

process(clk)
begin
  if rising_edge(clk) then
    if sin_mem_wea_d = '1' then
      sin_mem_adda <= sin_mem_adda + 1;
    end if;
      sin_mem_adda_d <= sin_mem_adda;
      sin_mem_adda_d1 <= sin_mem_adda_d;
      sin_mem_wea_d <= sin_mem_wea;
      sin_mem_dina_d <= sin_mem_dina;
  end if;
end process;

  process
    variable v_ILINE     : line;
    variable v_ADD_TERM1 : integer;
    variable v_SPACE     : character;
     
  begin
    file_open(file_param1, "D:\GitFiles\LivitationPlanAheadPrj\Livitation_v2_1\prj\SFTI_Livitation.srcs\sim_1\new\MyParam.txt",  read_mode);
    param1_mem_wea <= '0';
    param_mem_load <= '0';
    param1_mem_adda <= (others => '0');
    param1_mem_dina <= (others => '0');
    wait until rst = '0';
    wait until rising_edge(clk);
    wait for 5 ns;
    while not endfile(file_param1) loop
    param1_mem_wea <= '1';
      readline(file_param1, v_ILINE);
      read(v_ILINE, v_ADD_TERM1);
      
      -- Pass the variable to a signal to allow the ripple-carry to use it
      param1_mem_dina(7 downto 0) <= conv_std_logic_vector(v_ADD_TERM1, 8);
--      readline(file_param1, v_ILINE);
--      read(v_ILINE, v_ADD_TERM1);
--      
--      -- Pass the variable to a signal to allow the ripple-carry to use it
--      param1_mem_dina(15 downto 8) <= conv_std_logic_vector(v_ADD_TERM1, 8);
      wait for 5 ns;
      param1_mem_adda <= param1_mem_adda + 1;
    end loop;
    wait until rising_edge(clk);
    param1_mem_wea <= '0';
    wait for 5 ns;
    param_mem_load <= '1';
    wait for 5 ns;
    param_mem_load <= '0';
    file_close(file_param1);
    wait;
  end process;

en_proc :
process(clk)
begin
  if rising_edge(clk) then
    en <= start_n;
    param1_mem_wea_d <= param1_mem_wea;
    param1_mem_adda_d<= param1_mem_adda;
    param1_mem_dina_d<= param1_mem_dina;
    
  end if;
end process;


antenn_array_x16_control_inst : entity antenn_array_x32_control
    Port map( 
      clk               => clk,
      en                => en,
      sin_mem_wea       => sin_mem_wea_d,
      sin_mem_addra     => sin_mem_adda,
      sin_mem_dina      => sin_mem_dina_d,
      param_mem_adda    => param1_mem_adda_d,
      param_mem_dina    => param1_mem_dina_d,
      param_mem_wea     => param1_mem_wea_d,
      param_mem_load    => param_mem_load,
      antenn_addr       => antenn_addr,
      antenn_data       => antenn_data,
      antenn_data_valid => antenn_data_val
    );

end Behavioral;
