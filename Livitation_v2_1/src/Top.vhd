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

library work;
use work.clock_generator;
use work.UART_RX;
use work.UART_TX;
use work.antenn_array_x16_control;
use work.my_std_mem.all;

entity Top is
    Port ( 
        sys_clk         : in std_logic;
        leds_out        : inout std_logic_vector(1 downto 0);
        button1_in      : in std_logic;
        button2_in      : in std_logic;
        u_tx            : out std_logic;
        u_rx            : in std_logic;
        ant_array1_addr : out std_logic_vector(3 downto 0);
        ant_array1_data : out std_logic_vector(7 downto 0)--;
--        wr              : out std_logic;
--        cs              : out std_logic
    );
end Top;

architecture Behavioral of Top is
    constant c_freq_hz          : integer := 125000000;
    constant c_boad_rate        : integer := 230400;
    constant g_CLKS_PER_BIT     : integer := c_freq_hz/c_boad_rate;
    type state_machine          is (idle, read_command, send_confirm, load_sinus, load_param1, load_param1_cont);
    signal state, next_state    : state_machine;
    signal clk_counter          : std_logic_vector(25 downto 0);
    signal counter25_d          : std_logic;
    signal next_led             : std_logic;
    signal gnd                  : std_logic:= '0';
    signal vcc                  : std_logic:= '1';
    signal pll_clkfbout         : std_logic;
    signal pll_clkfbin          : std_logic;
    signal pll_locked           : std_logic;
    signal clk_100MHz           : std_logic;
    signal led2                 : std_logic;
    signal pll_clk0             : std_logic;
    signal tst_data             : std_logic_vector(15 downto 0);
    signal clk_125MHz           : std_logic;
    signal rst_uart             : std_logic;
    signal start_en             : std_logic:= '0';
    signal confirm_byte         : std_logic_vector(7 downto 0);
    signal push_counter         : std_logic_vector(7 downto 0):= (others => '0');
    signal button1_in_d         : std_logic_vector(3 downto 0);
    signal rst                  : std_logic;
    signal confirm_push_en      : std_logic;
    signal sin_mem_adda         : std_logic_vector(11 downto 0);
    signal sin_mem_wea          : std_logic;
    signal sin_mem_addb         : std_logic_vector(10 downto 0);
    signal sin_mem_dout         : std_logic_vector(7 downto 0);
    signal uart_rx_byte         : std_logic_vector(7 downto 0);
    signal uart_rx_byte_valid   : std_logic;
    signal contrl_reg           : std_logic_vector(7 downto 0);
    signal param_mem_adda       : std_logic_vector(10-1 downto 0);
    signal param_mem_dina       : std_logic_vector(7 downto 0);
    signal param_mem_wea        : std_logic;
    signal antenn_data_valid    : std_logic;
    signal param_mem_load       : std_logic;
    signal sin_data_buff        : sim_mem_type;
    signal antenn_addr          : std_logic_vector(3 downto 0);
    signal uart_tx_byte         : std_logic_vector(7 downto 0);
    signal uart_tx_done         : std_logic;
    signal uart_tx_active       : std_logic;

begin

--wr  <= '0' when start_en = '1' and antenn_addr = 0 else '1';
--cs  <= '0' when start_en = '1' and antenn_addr = 0 else '1';

uart_rx_inst :  entity UART_RX
  generic map(
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
    )
  port map(
    i_Clk           => clk_125MHz,
    i_RX_Serial     => u_rx,
    o_RX_DV         => uart_rx_byte_valid,
    o_RX_Byte       => uart_rx_byte
    );

uart_tx_inst :  entity UART_TX 
  generic map(
    g_CLKS_PER_BIT  => g_CLKS_PER_BIT
    )
  port map(
    i_Clk           => clk_125MHz,
    i_TX_DV         => confirm_push_en,
    i_TX_Byte       => uart_tx_byte,
    o_TX_Active     => uart_tx_active,
    o_TX_Serial     => u_tx,
    o_TX_Done       => uart_tx_done
    );

button1_push_proc :
  process(clk_125MHz)
  begin 
    if rising_edge(clk_125MHz) then
      button1_in_d(3 downto 1) <= button1_in_d(2 downto 0);
      button1_in_d(0) <= button1_in;
      
      if ((button1_in_d(3) = '1') and (button1_in_d(2) = '0')) or ((button1_in_d(3) = '0') and (button1_in_d(2) = '1'))then 
        push_counter <= (0 => '1', others => '0');
      else
        if push_counter > 0 then
          push_counter <= push_counter + 1;
        end if;
      end if;
    end if;
  end process;

rst_proc :
  process(clk_125MHz)
  begin
    if rising_edge(clk_125MHz) then
      if push_counter = x"ff" then
        rst <= not button1_in;
      else
        rst <= rst;
      end if;
    end if;
  end process;

clk_gen_ist : entity clock_generator
    Port map( 
      clk_in        => sys_clk,
      rst_in        => gnd,
      pll_lock      => open,
      clk_out_125MHz=> clk_125MHz,
      rst_out       => leds_out(0)
    );

leds_out(1) <= not start_en;

command_byte_proc :
  process(clk_125MHz)
  begin 
    if rising_edge(clk_125MHz) then
      if (uart_rx_byte_valid = '1') and (state = read_command) then
        case uart_rx_byte is
          when "00000000" =>
            start_en <= '0';
          when "00000001" =>
            start_en <= '1';
          when others => 
        end case;
        confirm_byte <= uart_rx_byte;
      end if;
    end if;
  end process;

sin_mem_adda_proc :
  process(clk_125MHz)
  begin 
    if rising_edge(clk_125MHz) then
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
  process(clk_125MHz)
  begin 
    if rising_edge(clk_125MHz) then
      if (state = idle) then
        param_mem_adda <= (others => '0');
      elsif (state = load_param1) then
        if (uart_rx_byte_valid = '1') then
          param_mem_adda <= param_mem_adda + 1;
        end if;
      end if;
    end if;
  end process;

sync_proc :
  process(clk_125MHz)
  begin
    if rising_edge(clk_125MHz) then
      if rst = '1' then 
        state <= idle;
      else
        state <= next_state;
      end if;
    end if;
  end process;

out_proc :
  process(state, uart_rx_byte_valid)
  begin
    confirm_push_en <= '0';
    rst_uart <= '0';
    sin_mem_wea <= '0';
    param_mem_load <= '0';
      case state is 
        when idle => 
          rst_uart <= '1';
        when send_confirm => 
          confirm_push_en <= '1';
        when load_sinus => 
          sin_mem_wea <= uart_rx_byte_valid;
        when load_param1 =>
          param_mem_wea <= uart_rx_byte_valid;
        when load_param1_cont =>
          param_mem_load <= '1';
        when others =>
      end case;
  end process;

next_state_proc :
  process(state, uart_rx_byte_valid, uart_rx_byte, sin_mem_adda, param_mem_adda)
  begin
    next_state <= state;
      case state is
        when idle =>
          next_state <= read_command;
        when read_command =>
          if (uart_rx_byte_valid = '1') then 
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
        when load_sinus =>
          if (sin_mem_adda(11) = '1') then
            next_state <= send_confirm;
          end if;
        when load_param1 => 
          if (param_mem_adda(9) = '1') then
            next_state <= load_param1_cont;
          end if;
        when load_param1_cont => 
           next_state <= send_confirm;
        when send_confirm => 
          next_state <= idle;
      end case;
  end process;


antenn_array_x16_control_inst : entity antenn_array_x16_control 
    Port map( 
      clk                           => clk_125MHz,
      --rst                           => rst,
      sin_mem_wea                   => sin_mem_wea,
      sin_mem_addra                 => sin_mem_adda(10 downto 0),
      sin_mem_dina                  => uart_rx_byte,
      en                            => start_en,
      param_mem_adda                => param_mem_adda(8 downto 0),
      param_mem_dina                => uart_rx_byte,
      param_mem_wea                 => param_mem_wea,
      param_mem_load                => param_mem_load,
      antenn_addr                   => antenn_addr,
      antenn_data                   => ant_array1_data,
      antenn_data_valid             => antenn_data_valid
    );
ant_array1_addr <= antenn_addr;

end Behavioral;
