
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.Numeric_Std.ALL;

library work;
use work.get_param_mem;
use work.fifo_non_simetric;
use work.sin_mem;
use work.proc_common_pkg.clog2;
use work.async_fifo_for_parameters;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antenn_array_x32_control is
    generic (
      c_sin_data_width              : integer := 2048;
      c_num_emitter                 : integer := 32;
      c_sin_points_per_period       : integer := 16;
      c_num_harmonics               : integer := 8;
      c_emitter_center_freq_hz      : integer := 40000;
      c_clk_freq_hz                 : integer := 200_000_000
    );
    Port (
      sys_clk                       : in std_logic;
      clk                           : in std_logic;
      en                            : in std_logic;
      sin_mem_wea                   : in std_logic;
      sin_mem_addra                 : in std_logic_vector(clog2(c_sin_data_width) - 1 downto 0);
      sin_mem_dina                  : in std_logic_vector(7 downto 0);
      
      param_mem_adda                : in std_logic_vector(clog2(4*c_num_harmonics * c_num_emitter) - 1 downto 0);
      param_mem_dina                : in std_logic_vector(7 downto 0);
      param_mem_wea                 : in std_logic;
      param_mem_load                : in std_logic;
      antenn_addr                   : out std_logic_vector(clog2(c_num_emitter) - 1 downto 0);
      antenn_data                   : out std_logic_vector(7 downto 0);
      antenn_data_valid             : out std_logic
    );
end antenn_array_x32_control;

architecture Behavioral of antenn_array_x32_control is
    constant c_num_div_clk          : integer := c_clk_freq_hz/(c_emitter_center_freq_hz*c_num_emitter*c_sin_points_per_period);
    constant c_sin_mem_addr_length  : integer := clog2(c_sin_data_width);
    constant c_max_emitter          : std_logic_vector(clog2(c_num_emitter) - 1 downto 0):= (others => '1');
    signal param_mem_addb           : std_logic_vector(clog2(2*c_num_emitter * c_num_harmonics) - 1 downto 0):= (others => '0');
    signal param_mem_dout           : std_logic_vector(31 downto 0);
    signal clk_counter              : std_logic_vector(clog2(c_num_div_clk) - 1 downto 0):= (others => '0');
    signal antenn_addr_edge         : std_logic;
    signal antenn_address           : std_logic_vector(clog2(c_num_emitter) - 1 downto 0):= (others => '0');
    signal en_d                     : std_logic:= '0';
    signal start                    : std_logic;
    signal new_adrr                 : std_logic_vector(clog2(c_num_harmonics)-1 downto 0):= (others => '0');
    signal sin_mem_b_addr           : std_logic_vector(c_sin_mem_addr_length - 1 downto 0):= (others => '0');
    signal freq_step                : std_logic_vector(c_sin_mem_addr_length - 1 downto 0):= (others => '0');
    signal ampl_byte                : std_logic_vector(7 downto 0):=(others => '0');
    signal ampl_byte_d              : std_logic_vector(7 downto 0):=(others => '0');
    signal amp_mult_sin_byte        : std_logic_vector(15 downto 0);
    signal new_param_wr_en          : std_logic;
    signal get_param_wea            : std_logic;
    signal get_param_addra          : std_logic_vector(clog2(4*c_num_emitter * c_num_harmonics)-1 downto 0);
    signal get_param_dina           : std_logic_vector(15 downto 0);
    signal sin_mem_byte             : std_logic_vector(7 downto 0);
    signal sin_mem_byte_d           : std_logic_vector(7 downto 0);
    signal data_out_valid           : std_logic;
    signal fifo_non_simetric_dout   : std_logic_vector(15 downto 0);
    signal fifo_non_simetric_rd_en  : std_logic;
    signal fifo_non_simetric_empty  : std_logic;
    signal fifo_non_simetric_rd_addr: std_logic_vector(clog2(2*c_num_emitter * c_num_harmonics)-1 downto 0);
    signal param_buff_addr          : std_logic:= '0';
    signal new_param_buff_addr      : std_logic:= '0';
    signal data_summ_en             : std_logic;
    signal data_out                 : std_logic_vector(10 downto 0);
    signal new_param_wr_en_d        : std_logic;
    signal new_param_wr_en_d1       : std_logic;
    signal addr_d                   : std_logic_vector(clog2(c_num_emitter) - 1 downto 0):= (others => '0');
    signal next_new_param_buf_en    : std_logic;
    signal async_fifo_for_parameters_wr_en : std_logic;
    signal async_fifo_for_parameters_rd_en : std_logic;
    signal async_fifo_for_parameters_dout   : std_logic_vector(18 downto 0);
    signal async_fifo_for_parameters_valid  : std_logic;
    signal fifo_non_simetric_full   : std_logic;
    signal sync_param_mem_adda      : std_logic_vector(clog2(4*c_num_harmonics * c_num_emitter) - 1 downto 0);
    signal sync_param_mem_dina      : std_logic_vector(7 downto 0);
    signal sync_param_mem_wea       : std_logic;
    signal sync_param_mem_load      : std_logic;
    
    
    
    

begin
next_new_param_buf_en <= '1' when (antenn_address = c_max_emitter and antenn_addr_edge = '1') else '0';

param_buff_addr_proc :
  process(clk)
  begin
    if rising_edge(clk) then

        if (sync_param_mem_load = '1') then
          param_buff_addr <= not param_buff_addr;
        end if;

        if (next_new_param_buf_en = '1') or (start = '1') then
          new_param_buff_addr <= not param_buff_addr;
        end if;

        en_d <= en;

    end if;
  end process;

timer_tick_proc:
  process(clk)
  begin
    if rising_edge(clk) then
      if (en = '0') then
        clk_counter <= (others => '0');
      elsif clk_counter = c_num_harmonics then
        clk_counter <= (others => '0');
      else
        clk_counter <= clk_counter + 1;
      end if;
    end if;
  end process;
  

async_fifo_for_parameters_wr_en <= param_mem_wea or param_mem_load;

async_fifo : ENTITY async_fifo_for_parameters
  PORT map (
    wr_clk  => sys_clk,
    rd_clk  => clk,
    din     => param_mem_adda & param_mem_dina & param_mem_load,
    wr_en   => async_fifo_for_parameters_wr_en,
    rd_en   => async_fifo_for_parameters_rd_en,
    dout    => async_fifo_for_parameters_dout,
    full    => open,
    empty   => open,
    valid   => async_fifo_for_parameters_valid
  );

async_fifo_for_parameters_rd_en <= (not fifo_non_simetric_full) and async_fifo_for_parameters_valid;

sync_param_mem_adda <= async_fifo_for_parameters_dout(async_fifo_for_parameters_dout'length - 1 downto async_fifo_for_parameters_dout'length - sync_param_mem_adda'length);
sync_param_mem_dina <= async_fifo_for_parameters_dout(sync_param_mem_dina'length downto 1);

sync_param_mem_wea <= async_fifo_for_parameters_valid and (not async_fifo_for_parameters_dout(0));
sync_param_mem_load <= async_fifo_for_parameters_dout(0) and async_fifo_for_parameters_valid;
  
fifo_non_simetric_inst : entity fifo_non_simetric
    generic map(
      g_WIDTH           => 8,
      g_DEPTH           => 32,
      g_ADDR_LENGTH     => clog2(4*c_num_emitter * c_num_harmonics)
    )
    Port map( 
      i_clk             => clk,
      i_rst_sync        => '0',
      i_wr_addr         => sync_param_mem_adda,
      i_wr_data         => sync_param_mem_dina,
      i_wr_en           => sync_param_mem_wea,
      o_full            => fifo_non_simetric_full,
      o_rd_addr         => fifo_non_simetric_rd_addr,
      o_rd_data         => fifo_non_simetric_dout,
      i_rd_en           => fifo_non_simetric_rd_en,
      o_empty           => fifo_non_simetric_empty
    );

new_param_wr_en <= '1' when clk_counter > 0 else '0';
fifo_non_simetric_rd_en <= not (fifo_non_simetric_empty or new_param_wr_en);

sin_mem_b_addr <= param_mem_dout(c_sin_mem_addr_length - 1 downto 0);
freq_step(7 downto 0) <= param_mem_dout(31 downto 24);

get_param_proc : 
  process(clk)
  begin
    if rising_edge(clk) then
        if (new_param_wr_en = '1') then
          get_param_wea <= '1';
          get_param_addra <= new_param_buff_addr & antenn_address & new_adrr & '0';
          get_param_dina(15 downto c_sin_mem_addr_length) <= (others => '0');
          get_param_dina(c_sin_mem_addr_length - 1 downto 0) <= sin_mem_b_addr + freq_step;
          ampl_byte(7 downto 0) <= param_mem_dout(23 downto 16);
        elsif (fifo_non_simetric_empty = '0') then 
          get_param_wea <= '1';
          get_param_addra <= param_buff_addr & fifo_non_simetric_rd_addr;
          get_param_dina <= fifo_non_simetric_dout;
        else
          get_param_wea <= '0';
        end if;
        new_adrr <= clk_counter(clog2(c_num_harmonics)-1 downto 0);
    end if;
  end process;

out_process :
  process(clk)
  begin
    if rising_edge(clk) then
      if (en = '0') then
        antenn_data_valid <= '0';
        antenn_data <= (others => '0');
        antenn_addr <= (others => '0');
      else
        if data_summ_en = '0' then
            antenn_data <= data_out(data_out'length - 1 downto data_out'length - 8);
            antenn_addr <= addr_d;
            antenn_data_valid <= '1';
        else
            antenn_data_valid <= '0';
        end if;
      end if;
    end if;
  end process;

antenn_address_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (en = '0') then
        antenn_address <= (others => '0');
        antenn_addr_edge <= '0';
      else
        if (clk_counter(clog2(c_num_div_clk) - 1 downto 0)= c_num_harmonics) then
          antenn_address <= antenn_address + 1;
          addr_d <= antenn_address;
          antenn_addr_edge <= '1';
        else
          antenn_addr_edge <= '0';
        end if;
      end if;
    end if;
  end process;

start <= en and (not en_d);
param_mem_addb <= (new_param_buff_addr) & antenn_address & clk_counter(2 downto 0);

amp_mult_sin_byte_proc:
  process(clk)
  begin
    if rising_edge(clk) then
      new_param_wr_en_d <= new_param_wr_en;
      new_param_wr_en_d1 <= new_param_wr_en_d;
      data_summ_en <= new_param_wr_en_d1;
      amp_mult_sin_byte <= ampl_byte_d * sin_mem_byte_d;
      sin_mem_byte_d <= sin_mem_byte;
      ampl_byte_d <= ampl_byte;
      if data_summ_en = '1' then
        data_out <= data_out + ("000" & (amp_mult_sin_byte(15 downto 8) + 1));
      else
        data_out <= (others => '0');
      end if;
    end if;
  end process;


get_param_mem_inst : ENTITY get_param_mem
  PORT map(
    clka    => clk,
    wea(0)  => get_param_wea,
    addra   => get_param_addra,
    dina    => get_param_dina,
    clkb    => clk,
    addrb   => param_mem_addb,
    doutb   => param_mem_dout
  );

sin_mem_inst : ENTITY sin_mem 
  PORT map(
    clka    => sys_clk,
    wea(0)  => sin_mem_wea   ,
    addra   => sin_mem_addra ,
    dina    => sin_mem_dina  ,
    clkb    => clk,
    addrb   => sin_mem_b_addr,
    doutb   => sin_mem_byte
  );


end Behavioral;
