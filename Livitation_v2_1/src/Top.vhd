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
use work.uart_tx_fifo;

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
    constant chip_id_byte       : std_logic_vector(7 downto 0):=x"42";  
    constant c_freq_hz          : integer := 125000000;
    constant c_boad_rate        : integer := 921600;
    constant g_CLKS_PER_BIT     : integer := c_freq_hz/c_boad_rate;
    type state_machine          is (idle, read_command, send_confirm, load_sinus, load_param, load_param_cont, chip_id_req, send_chip_id, get_num_emitter);
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
    signal sin_mem_adda         : std_logic_vector(14 downto 0);
    signal sin_mem_wea          : std_logic;
    signal sin_mem_addb         : std_logic_vector(10 downto 0);
    signal sin_mem_dout         : std_logic_vector(7 downto 0);
    signal uart_rx_byte         : std_logic_vector(7 downto 0);
    signal uart_rx_byte_valid   : std_logic;
    signal contrl_reg           : std_logic_vector(7 downto 0);
    signal param_mem_adda       : std_logic_vector(6 downto 0);
    signal param_mem_dina       : std_logic_vector(7 downto 0);
    signal param_mem_wea        : std_logic_vector(3 downto 0);
    signal antenn_data_valid    : std_logic;
    signal param_mem_load       : std_logic;
    signal antenn_addr          : std_logic_vector(3 downto 0);
    signal uart_tx_byte         : std_logic_vector(7 downto 0);
    signal uart_tx_done         : std_logic;
    signal uart_tx_dv           : std_logic;
    signal uart_tx_active       : std_logic;
    signal chip_id_req_counter  : std_logic_vector(5 downto 0);
    signal chip_id_req_error    : std_logic;
    signal chip_id_send_counter : std_logic_vector(1 downto 0);
    signal uart_tx_fifo_din     : std_logic_vector(7 downto 0);
    signal uart_tx_fifo_dout    : std_logic_vector(7 downto 0);
    signal uart_tx_fifo_wr_en   : std_logic;
    signal uart_tx_fifo_rd_en   : std_logic;
    signal uart_tx_fifo_full    : std_logic;
    signal uart_tx_fifo_empty   : std_logic;
    signal uart_tx_fifo_valid   : std_logic;
    signal uart_tx_en           : std_logic;
    signal num_emit_byte        : std_logic_vector(7 downto 0);
    type ant_addr_type  is array (1 downto 0) of std_logic_vector(3 downto 0);

begin
-- UART RX Module
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
-- UART TX Module
uart_tx_inst :  entity UART_TX 
  generic map(
    g_CLKS_PER_BIT  => g_CLKS_PER_BIT
    )
  port map(
    i_Clk           => clk_125MHz,
    i_TX_DV         => uart_tx_dv,
    i_TX_Byte       => uart_tx_byte,
    o_TX_Active     => uart_tx_active,
    o_TX_Serial     => u_tx,
    o_TX_Done       => uart_tx_done
    );

uart_tx_byte <= uart_tx_fifo_dout;
uart_tx_dv <= uart_tx_fifo_valid;
uart_tx_fifo_rd_en <= uart_tx_done and uart_tx_active;

-- UART TX FIFO
UART_TX_FIFO_inst : ENTITY uart_tx_fifo
  PORT MAP(
    clk     => clk_125MHz,
    rst     => rst,
    din     => uart_tx_fifo_din,
    wr_en   => uart_tx_fifo_wr_en,
    rd_en   => uart_tx_fifo_rd_en,
    dout    => uart_tx_fifo_dout,
    full    => uart_tx_fifo_full,
    empty   => uart_tx_fifo_empty,
    valid   => uart_tx_fifo_valid
  );

uart_tx_fifo_wr_en <= uart_tx_en and (not uart_tx_fifo_full);

-- UART STATE MACHINE
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
  process(state, uart_rx_byte_valid, num_emit_byte)
  begin
    confirm_push_en <= '0';
    rst_uart <= '0';
    sin_mem_wea <= '0';
    param_mem_load <= '0';
    uart_tx_en <= '0';
      case state is 
        when idle => 
          rst_uart <= '1';
        when send_confirm => 
          uart_tx_en <= '1';
          uart_tx_fifo_din <= chip_id_byte;
        when load_sinus => 
          sin_mem_wea <= uart_rx_byte_valid;
        when load_param =>
          case num_emit_byte is
            when x"00" =>
              param_mem_wea <= "0001";
            when x"01" =>
              param_mem_wea <= "0010";
            when x"02" =>
              param_mem_wea <= "0100";
            when x"03" =>
              param_mem_wea <= "1000";
            when others =>
              param_mem_wea <= "0000";
          end case;
        when load_param_cont =>
          param_mem_load <= '1';
        when send_chip_id =>
          uart_tx_en <= '1';
          uart_tx_fifo_din <= chip_id_byte;
        when others =>
      end case;
  end process;

next_state_proc :
  process(state, uart_rx_byte_valid, uart_rx_byte, sin_mem_adda, param_mem_adda, chip_id_req_error, chip_id_req_counter, chip_id_send_counter)
  begin
    next_state <= state;
      case state is
        when idle =>
          next_state <= read_command;
        when read_command =>
          if (uart_rx_byte_valid = '1') then 
            case uart_rx_byte is
              when x"42" =>
                next_state <= send_confirm;
              when x"41" =>
                next_state <= send_confirm;
              when x"4C" =>
                next_state <= load_sinus;
              when x"43" =>
                next_state <= get_num_emitter;
              when x"40" => 
                next_state <= chip_id_req;
              when x"4E" => 
                next_state <= load_param_cont;
              when others => 
                next_state <= idle;
            end case;
          end if;
        when load_sinus =>
          if (sin_mem_adda(sin_mem_adda'length - 1) = '1') then
            next_state <= send_confirm;
          end if;
        when get_num_emitter => 
          if (uart_rx_byte_valid = '1') then
            num_emit_byte <= uart_rx_byte;
          end if;
        when load_param => 
          if (param_mem_adda(param_mem_adda'length - 1) = '1') then
            next_state <= send_confirm;
          end if;
        when load_param_cont => 
           next_state <= send_confirm;
        when send_confirm => 
          next_state <= idle;
        when chip_id_req =>
          if (chip_id_req_error = '1') then
            next_state <= idle;
          end if;
          if (chip_id_req_counter(5 downto 0) = "111111") then
            next_state <= send_chip_id;
          end if;
        when send_chip_id =>
          if (chip_id_send_counter = "11") then
            next_state <= idle;
          end if;
        when others =>
          next_state <= idle;
      end case;
  end process;

send_chip_id_proc :
  process(clk_125MHz)
  begin
    if rising_edge(clk_125MHz) then
      if (state = send_chip_id) then
        if uart_tx_fifo_wr_en = '1' then
          chip_id_send_counter <= chip_id_send_counter + 1;
        end if;
      else
        chip_id_send_counter <= (others => '0');
      end if;
    end if;
  end process;

chip_id_req_poc :
  process(clk_125MHz)
  begin
    if rising_edge(clk_125MHz) then
      if (state = chip_id_req) then
        if (uart_rx_byte_valid = '1') then
          if (uart_rx_byte = x"40") then
            chip_id_req_counter <= chip_id_req_counter + 1;
          else
            chip_id_req_error <= '1';
          end if;
        end if;
      else
        chip_id_req_error <= '0';
        chip_id_req_counter <= (others => '0');
      end if;
    end if;
  end process;

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
          when x"42" =>
            start_en <= '0';
          when x"41" =>
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
      elsif (state = load_param) then
        if (uart_rx_byte_valid = '1') then
          param_mem_adda <= param_mem_adda + 1;
        end if;
      end if;
    end if;
  end process;

emmiter_gen_proc : for i in 0 to 3 generate
begin
antenn_array_x16_control_0 : entity antenn_array_x16_control 
    Port map( 
      clk                           => clk_125MHz,
      --rst                           => rst,
      form_mem_wea                  => sin_mem_wea,
      form_mem_addra                => sin_mem_adda(sin_mem_adda'length - 2 downto 0),
      form_mem_dina                 => uart_rx_byte,
      en                            => start_en,
      param_mem_adda                => param_mem_adda(param_mem_adda'length - 2 downto 0),
      param_mem_dina                => uart_rx_byte,
      param_mem_wea                 => param_mem_wea(i),
      param_mem_load                => param_mem_load,
      antenn_addr                   => antenn_addr,
      antenn_data                   => ant_array1_data,
      antenn_data_valid             => antenn_data_valid
    );
end generate;




ant_array1_addr <= antenn_addr;

end Behavioral;
