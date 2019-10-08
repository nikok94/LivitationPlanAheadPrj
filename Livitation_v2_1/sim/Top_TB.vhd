----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2019 12:03:48
-- Design Name: 
-- Module Name: Top_TB - Behavioral
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

library work;
use work.top;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_TB is
    --Port ( );
end Top_TB;

architecture Behavioral of Top_TB is
  signal clk_p              : std_logic;
  signal clk_n              : std_logic;
  signal clk                : std_logic;
  signal diff_clk_p_out     : std_logic;
  signal diff_clk_n_out     : std_logic;
  signal init_addr          : std_logic_vector(3 downto 0):= (others => '0');
  signal leds_out           : std_logic_vector(1 downto 0);
  signal button1_in         : std_logic;
  signal button2_in         : std_logic;
  signal u_tx               : std_logic;
  signal u_rx               : std_logic;
  signal ant_array_addr     : std_logic_vector(3 downto 0);
  signal ant_array0_data    : std_logic_vector(7 downto 0);
  signal ant_array1_data    : std_logic_vector(7 downto 0);
  signal ant_array2_data    : std_logic_vector(7 downto 0);
  signal ant_array3_data    : std_logic_vector(7 downto 0);
  signal ant_array4_data    : std_logic_vector(7 downto 0);
  signal ant_array5_data    : std_logic_vector(7 downto 0);
  signal ant_array6_data    : std_logic_vector(7 downto 0);
  signal ant_array7_data    : std_logic_vector(7 downto 0);
  signal antenn_en          : std_logic_vector(1 downto 0);



begin

clk_gen_proc :
  process
  begin
    clk <= '0';
    wait for 20 ns;
    clk <= '1';
    wait for 20 ns;
  end process;

clk_p <= clk;
clk_n <= not clk_p;


button1_in_gen_proc :
  process
  begin
    button1_in <= '1';
    wait until leds_out(0) = '0';
    wait for 100 ns;
    button1_in <= '0';
    wait for 50 ns;
    button1_in <= '1';
    wait;
  end process;
  
  
button2_in_gen_proc :
  process
  begin
    button2_in <= '1';
    wait until leds_out(0) = '0';
    wait for 500 ns;
    button2_in <= '0';
    wait for 50 ns;
    button2_in <= '1';
    wait;
  end process;


top_inst : entity Top
    Port map( 
        sys_clk         => clk,

        diff_clk_p_in   => clk_p,
        diff_clk_n_in   => clk_n,

        diff_clk_p_out  => diff_clk_p_out,
        diff_clk_n_out  => diff_clk_n_out,

        init_addr       => init_addr,

        leds_out        => leds_out,
        button1_in      => button1_in     ,
        button2_in      => button2_in     ,
        u_tx            => u_tx           ,
        u_rx            => u_rx           ,
        ant_array_addr  => ant_array_addr ,
        ant_array0_data => ant_array0_data,
        ant_array1_data => ant_array1_data,
        ant_array2_data => ant_array2_data,
        ant_array3_data => ant_array3_data,
        ant_array4_data => ant_array4_data,
        ant_array5_data => ant_array5_data,
        ant_array6_data => ant_array6_data,
        ant_array7_data => ant_array7_data,
        antenn_en       => antenn_en
    );
    
end Behavioral;
