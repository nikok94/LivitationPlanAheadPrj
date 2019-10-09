----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2019 19:37:16
-- Design Name: 
-- Module Name: Top - Behavioral
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
use IEEE.Numeric_Std.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
--use work.clock_gen_extr_clk;
--use work.clock_gen_sys_clk;
use work.UART_RX;
use work.UART_TX;
use work.antenn_array_x32_control;
use work.sinus_form_generator;
use work.parameters_generator;
use work.clock_generator;

--use work.my_std_mem.all;

entity Top is
    Port ( 
        sys_clk         : in std_logic;

        diff_clk_p_in   : in std_logic;
        diff_clk_n_in   : in std_logic;

        diff_clk_p_out  : out std_logic;
        diff_clk_n_out  : out std_logic;

        init_addr       : in std_logic_vector(3 downto 0);

        leds_out        : inout std_logic_vector(1 downto 0);
        button1_in      : in std_logic;
        button2_in      : in std_logic;
        
       -- sinus_form_generator_addr  : out std_logic_vector(10 downto 0);
       -- sinus_form_generator_data  : out std_logic_vector(7 downto 0);
       -- sinus_form_generator_wr_en : out std_logic
        u_tx            : out std_logic;
        u_rx            : in std_logic;
        ant_array_addr  : out std_logic_vector(3 downto 0);
        ant_array0_data : out std_logic_vector(7 downto 0);
        ant_array1_data : out std_logic_vector(7 downto 0);
        ant_array2_data : out std_logic_vector(7 downto 0);
        ant_array3_data : out std_logic_vector(7 downto 0);
        ant_array4_data : out std_logic_vector(7 downto 0);
        ant_array5_data : out std_logic_vector(7 downto 0);
        ant_array6_data : out std_logic_vector(7 downto 0);
        ant_array7_data : out std_logic_vector(7 downto 0);
        antenn_en       : out std_logic_vector(1 downto 0)
    );
end Top;

architecture Behavioral of Top is
    type antenn_data_type is array (7 downto 0) of std_logic_vector(7 downto 0);
    signal antenn_data_out      : antenn_data_type;
    type antenn_addr_type is array (7 downto 0) of std_logic_vector(4 downto 0);
    signal antenn_addr_out      : antenn_addr_type;
    
    constant c_freq_hz          : integer := 100_000_000;
    constant c_boad_rate        : integer := 230400;
    constant g_CLKS_PER_BIT     : integer := c_freq_hz/c_boad_rate;
    type state_machine          is (idle, read_command, send_confirm, load_sinus, load_param1, load_param1_cont, ext_state_start, ext_state, ext_start_contin);
    signal state, next_state    : state_machine;
    signal clk_counter          : std_logic_vector(25 downto 0);
    signal counter25_d          : std_logic;
    signal next_led             : std_logic;
    signal gnd                  : std_logic:= '0';
    signal vcc                  : std_logic:= '1';
    signal pll_clkfbout         : std_logic;
    signal pll_clkfbin          : std_logic;
    signal pll_locked           : std_logic;
    signal led2                 : std_logic;
    signal pll_clk0             : std_logic;
    signal tst_data             : std_logic_vector(15 downto 0);
    signal clk_200MHz           : std_logic;
    signal rst_uart             : std_logic;
    signal start_en             : std_logic:= '0';
    signal confirm_byte         : std_logic_vector(7 downto 0);
    signal butt1_push_counter   : std_logic_vector(7 downto 0):= (others => '0');
    signal button1_in_d         : std_logic_vector(3 downto 0);
    signal butt2_push_counter   : std_logic_vector(7 downto 0):= (others => '0');
    signal button2_in_d         : std_logic_vector(3 downto 0);
    signal rst                  : std_logic;
    signal confirm_push_en      : std_logic;
    signal sin_mem_adda         : std_logic_vector(11 downto 0);
    signal sin_mem_wea          : std_logic;
    signal sin_mem_addb         : std_logic_vector(10 downto 0);
    signal sin_mem_dout         : std_logic_vector(7 downto 0);
    signal uart_rx_byte         : std_logic_vector(7 downto 0);
    signal uart_rx_byte_valid   : std_logic;
    signal contrl_reg           : std_logic_vector(7 downto 0);
    signal param_mem_adda       : std_logic_vector(10 downto 0);
    signal param_mem_address    : std_logic_vector(9 downto 0);
    signal param_mem_dina       : std_logic_vector(7 downto 0);
    signal param_mem_wea        : std_logic;
    signal param_generator_addr  : std_logic_vector(9 downto 0);
    signal param_generator_data  : std_logic_vector(7 downto 0);
    signal param_generator_wr_en : std_logic;
    signal antenn_data_valid    : std_logic;
    signal param_mem_load       : std_logic;
    signal clk_next_chip        : std_logic;
    signal first_clk_ibufds     : std_logic;
    signal clk_res              : std_logic;
    signal clk_select           : std_logic;
    signal ext_start            : std_logic;
    signal sinus_form_generator_addr  : std_logic_vector(10 downto 0);
    signal sinus_form_generator_data  : std_logic_vector(7 downto 0);
    signal sinus_form_generator_wr_en : std_logic;
    signal external_start       : std_logic;
    signal sin_mem_dina         : std_logic_vector(7 downto 0);
    signal sin_mem_address      : std_logic_vector(10 downto 0);
    signal clk_100MHz           : std_logic;
    signal clk_20MHz            : std_logic;
    signal sys_clk_pll_lock     : std_logic;
    signal ext_clk_pll_lock     : std_logic;
    signal ext_clk_pll_rst      : std_logic;
    signal ext_start_up         : std_logic;
    
begin


clk_gen_inst : entity clock_generator 
  Port map( 
    sys_clk_in            => sys_clk,

    ext_clk_p_in          => diff_clk_p_in,
    ext_clk_n_in          => diff_clk_n_in,

    clk_sel               => clk_select,

    rst_in                => '0',
    pll_lock              => sys_clk_pll_lock,

    clk_100MHz_out        => clk_100MHz,
    clk_200MHz_out        => clk_200MHz,

    clk_50MHz_p_out       => diff_clk_p_out,
    clk_50MHz_n_out       => diff_clk_n_out
  );

leds_out(0) <= not sys_clk_pll_lock;

--pll_from_sys_clk_inst : entity clock_gen_sys_clk
--    Port map(
--    in_clk  => sys_clk,
--    clk_0   => clk_100MHz,
--    clk_1   => clk_20MHz,
--    clk_2_p => diff_clk_p_out,
--    clk_2_n => diff_clk_n_out,
--    locked  => sys_clk_pll_lock
--    );
--
leds_out(0) <= not sys_clk_pll_lock;
--
--ext_clk_pll_rst <= (not button1_in) and sys_clk_pll_lock;
--
--pll_from_ext_clk_inst : entity clock_gen_extr_clk 
--    Port map(
--    rst         => ext_clk_pll_rst,
--    clk0_in     => clk_20MHz,
--    clk1_in_p   => diff_clk_p_in,
--    clk1_in_n   => diff_clk_n_in,
--    clk_out     => clk_200MHz,
--    sel         => init_addr(0),
--    lock        => ext_clk_pll_lock
--    );

--leds_out(1) <= not clk_select;

clk_select <= '0' when (init_addr = 0) else '1';

antenn_en(0) <= antenn_addr_out(0)(4);
antenn_en(1) <= not antenn_addr_out(0)(4);

uart_rx_inst :  entity UART_RX
  generic map(
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
    )
  port map(
    i_Clk           => clk_100MHz,
    i_RX_Serial     => u_rx,
    o_RX_DV         => uart_rx_byte_valid,
    o_RX_Byte       => uart_rx_byte
    );

uart_tx_inst :  entity UART_TX 
  generic map(
    g_CLKS_PER_BIT  => g_CLKS_PER_BIT
    )
  port map(
    i_Clk           => clk_100MHz,
    i_TX_DV         => confirm_push_en,
    i_TX_Byte       => contrl_reg,
    o_TX_Active     => open,
    o_TX_Serial     => u_tx,
    o_TX_Done       => open
    );

button1_push_proc :
  process(clk_100MHz)
  begin 
    if rising_edge(clk_100MHz) then
      button1_in_d(3 downto 1) <= button1_in_d(2 downto 0);
      button1_in_d(0) <= button1_in;
      
      if ((button1_in_d(3) = '1') and (button1_in_d(2) = '0'))then 
        butt1_push_counter <= (0 => '1', others => '0');
      else
        if butt1_push_counter > 0 then
          butt1_push_counter <= butt1_push_counter + 1;
        end if;
      end if;
    end if;
  end process;
  
rst_proc :
  process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then
      if butt1_push_counter = x"ff" then
        rst <= '1';
      else
        rst <= '0';
      end if;
    end if;
  end process;
  
button2_push_proc :
  process(clk_100MHz)
  begin 
    if rising_edge(clk_100MHz) then
      button2_in_d(3 downto 1) <= button2_in_d(2 downto 0);
      button2_in_d(0) <= button2_in;
      
      if ((button2_in_d(3) = '1') and (button2_in_d(2) = '0')) then 
        butt2_push_counter <= (0 => '1', others => '0');
      else
        if butt2_push_counter > 0 then
          butt2_push_counter <= butt2_push_counter + 1;
        end if;
      end if;
    end if;
  end process;

ext_start_proc :
  process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then
      if butt2_push_counter = x"ff" then
        ext_start <= '1';
      else
        ext_start <= '0';
      end if;
    end if;
  end process;


sin_gen : entity sinus_form_generator
    Port map ( 
      clk       => clk_100MHz,
      rst       => rst,
      start     => external_start,
      addr      => sinus_form_generator_addr,
      data      => sinus_form_generator_data,
      wr_en     => sinus_form_generator_wr_en
    );

param_gen : entity parameters_generator
    generic map(
      c_num_emitter     => 32,
      c_num_harmonics   => 8
    )
    Port map(
      clk               => clk_100MHz,
      rst               => rst,
      start             => external_start,
      addr              => param_generator_addr,
      data              => param_generator_data,
      wr_en             => param_generator_wr_en
    );

--external_start <= ext_start;

leds_out(1) <= not start_en;

command_byte_proc :
  process(clk_100MHz)
  begin 
    if rising_edge(clk_100MHz) then
      if rst = '1' then 
        start_en <= '0';
      else
        if (uart_rx_byte_valid = '1') and (state = read_command) then
          case uart_rx_byte is
          when "00000000" =>
              start_en <= '0';
          when "00000001" =>
              start_en <= '1';
          when others => 
          end case;
          confirm_byte <= uart_rx_byte;
        elsif ext_start_up = '1' then
          start_en <= '1';
        end if;
      end if;
    end if;
  end process;

sin_mem_adda_proc :
  process(clk_100MHz)
  begin 
    if rising_edge(clk_100MHz) then
      if (state = idle) then
        sin_mem_adda <= (others => '0');
      elsif (state = load_sinus) then
        if (uart_rx_byte_valid = '1') then
          sin_mem_adda <= sin_mem_adda + 1;
        end if;
      end if;
    end if;
  end process;

param_mem_adda_proc :
  process(clk_100MHz)
  begin 
    if rising_edge(clk_100MHz) then
      if (state = load_param1) then
        if (uart_rx_byte_valid = '1') then
          param_mem_adda <= param_mem_adda + 1;
        end if;
      else
        param_mem_adda <= (others => '0');
      end if;
    end if;
  end process;

sync_proc :
  process(clk_100MHz)
  begin
    if rising_edge(clk_100MHz) then
      if rst = '1' then 
        state <= idle;
      else
        state <= next_state;
      end if;
    end if;
  end process;

out_proc :
  process(state, uart_rx_byte_valid, sinus_form_generator_wr_en, param_generator_wr_en)
  begin
    confirm_push_en <= '0';
    rst_uart <= '0';
    sin_mem_wea <= '0';
    param_mem_wea <= '0';
    param_mem_load <= '0';
    external_start <= '0';
    ext_start_up <= '0';
      case state is 
        when idle => 
          rst_uart <= '1';
        when send_confirm => 
          confirm_push_en <= '1';
        when ext_state_start =>
          external_start <= '1';
        when ext_state =>
          sin_mem_wea <= sinus_form_generator_wr_en;
          param_mem_wea <= param_generator_wr_en;
        when load_sinus => 
          sin_mem_wea <= uart_rx_byte_valid;
        when load_param1 =>
          param_mem_wea <= uart_rx_byte_valid;
        when load_param1_cont =>
          param_mem_load <= '1';
        when ext_start_contin =>
          ext_start_up <= '1';
          param_mem_load <= '1';
        when others =>
      end case;
  end process;
  sin_mem_dina <= sinus_form_generator_data when (state = ext_state_start) or (state = ext_state) else uart_rx_byte;
  sin_mem_address <= sinus_form_generator_addr when (state = ext_state_start) or (state = ext_state) else sin_mem_adda(10 downto 0);
  param_mem_dina <= param_generator_data when (state = ext_state_start) or (state = ext_state) else uart_rx_byte;
  param_mem_address <= param_generator_addr when (state = ext_state_start) or (state = ext_state) else param_mem_adda(param_mem_adda'length - 2 downto 0);
next_state_proc :
  process(state, uart_rx_byte_valid, uart_rx_byte, sin_mem_adda, param_mem_adda, ext_start, sinus_form_generator_wr_en, param_generator_wr_en)
  begin
    next_state <= state;
      case state is
        when idle =>
          next_state <= read_command;
        when read_command =>
          if (ext_start = '1') then
            next_state <= ext_state_start;
          elsif (uart_rx_byte_valid = '1') then 
            case uart_rx_byte is
              when "00000000" =>
                next_state <= send_confirm;
              when "00000001" =>
                next_state <= send_confirm;
              when "00000010" =>
                next_state <= load_sinus;
              when "00000011" =>
                next_state <= load_param1;
              when others => 
                next_state <= idle;
            end case;
          end if;
        when ext_state_start =>
          next_state <= ext_state;
        when ext_state =>
          if ((sinus_form_generator_wr_en = '0') and (param_generator_wr_en = '0')) then
            next_state <= ext_start_contin;
          end if;
        when ext_start_contin =>
          next_state <= read_command;
        when load_sinus =>
          if (sin_mem_adda(11) = '1') then
            next_state <= send_confirm;
          end if;
        when load_param1 => 
          if (param_mem_adda(param_mem_adda'length - 1) = '1') then
            next_state <= load_param1_cont;
          end if;
        when load_param1_cont => 
           next_state <= send_confirm;
        when send_confirm => 
          next_state <= idle;
      end case;
  end process;

generate_proc : for i in 7 downto 0 generate

antenn_array_x32_control_inst : entity antenn_array_x32_control 
    generic map(
      c_sin_data_width              => 2048,
      c_num_emitter                 => 32,
      c_sin_points_per_period       => 16,
      c_num_harmonics               => 8,
      c_emitter_center_freq_hz      => 40_000,
      c_clk_freq_hz                 => 200_000_000
    )
    Port map(
      sys_clk                       => clk_100MHz,
      clk                           => clk_200MHz,
      sin_mem_wea                   => sin_mem_wea,
      sin_mem_addra                 => sin_mem_address,
      sin_mem_dina                  => sin_mem_dina,
      en                            => start_en,
      param_mem_adda                => param_mem_address,
      param_mem_dina                => param_mem_dina,
      param_mem_wea                 => param_mem_wea,
      param_mem_load                => param_mem_load,
      antenn_addr                   => antenn_addr_out(i),
      antenn_data                   => antenn_data_out(i),
      antenn_data_valid             => open
    );
end generate;

ant_array_addr <= antenn_addr_out(0)(3 downto 0);
ant_array0_data <= antenn_data_out(0);
ant_array1_data <= antenn_data_out(1);
ant_array2_data <= antenn_data_out(2);
ant_array3_data <= antenn_data_out(3);
ant_array4_data <= antenn_data_out(4);
ant_array5_data <= antenn_data_out(5);
ant_array6_data <= antenn_data_out(6);
ant_array7_data <= antenn_data_out(7);


end Behavioral;
