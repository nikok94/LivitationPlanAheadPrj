
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.Numeric_Std.ALL;


library work;
use work.get_param_mem;
use work.fifo_non_simetric;
use work.sin_mem;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antenn_array_x16_control is
    generic (
      c_sin_mem_addr_length         : integer := 11;
      c_param_mem_addr_length       : integer := 8
    );
    Port ( 
      clk                           : in std_logic;
      en                            : in std_logic;
      sin_mem_wea                   : in std_logic;
      sin_mem_addra                 : in std_logic_vector(c_sin_mem_addr_length - 1 downto 0);
      sin_mem_dina                  : in std_logic_vector(7 downto 0);
      
      param_mem_adda                : in std_logic_vector(c_param_mem_addr_length downto 0);
      param_mem_dina                : in std_logic_vector(7 downto 0);
      param_mem_wea                 : in std_logic;
      param_mem_load                : in std_logic;
      antenn_addr                   : out std_logic_vector(3 downto 0);
      antenn_data                   : out std_logic_vector(7 downto 0);
      antenn_data_valid             : out std_logic
    );
end antenn_array_x16_control;

architecture Behavioral of antenn_array_x16_control is

    signal param_mem_addb           : std_logic_vector(7 downto 0):= (others => '0');
    signal param_mem_dout           : std_logic_vector(31 downto 0);
    signal clk_counter              : std_logic_vector(3 downto 0):= (others => '0');
    signal antenn_addr_edge         : std_logic;
    signal antenn_address           : std_logic_vector(3 downto 0):= (others => '0');
    signal data_out                 : std_logic_vector(18 downto 0):= (others => '0');
    signal to_data_out              : std_logic_vector(18 downto 0):= (others => '0');
    signal en_d                     : std_logic:= '0';
    signal start                    : std_logic;
    signal clk_x8_counter           : std_logic_vector(3 downto 0):= "1000";
    signal clk_x8_counter_d         : std_logic_vector(3 downto 0):= "1000";
    signal clk_x8_counter_d1        : std_logic_vector(3 downto 0):= "1000";
    signal new_adrr_l               : std_logic_vector(clk_x8_counter'length - 2 downto 0):=(others => '0');
    signal sin_mem_b_addr           : std_logic_vector(15 downto 0):= (others => '0');
    signal freq_step                : std_logic_vector(15 downto 0):= (others => '0');
    signal ampl_byte                : std_logic_vector(7 downto 0);
    signal ampl_byte_d              : std_logic_vector(7 downto 0);
    signal new_addr_wr_en           : std_logic:= '0';
    signal new_addr_wr_en_d         : std_logic:= '0';
    signal new_addr_wr_en_d1        : std_logic:= '0';
    signal new_addr_wr_en_d2        : std_logic:= '0';
    signal get_param_wea            : std_logic;
    signal get_param_addra          : std_logic_vector(c_param_mem_addr_length downto 0);
    signal get_param_dina           : std_logic_vector(15 downto 0);
    signal sin_mem_byte             : std_logic_vector(7 downto 0);
    signal data_out_valid           : std_logic;
    signal fifo_non_simetric_dout   : std_logic_vector(15 downto 0);
    signal fifo_non_simetric_rd_en  : std_logic;
    signal fifo_non_simetric_empty  : std_logic;
    signal fifo_non_simetric_rd_addr: std_logic_vector(c_param_mem_addr_length downto 0);
    signal param_buff_addr          : std_logic:= '0';
    signal new_param_buff_addr      : std_logic:= '0';

begin

param_buff_addr_proc :
  process(clk)
  begin
    if rising_edge(clk) then
        if (param_mem_load = '1') then
          param_buff_addr <= not param_buff_addr;
        end if;

        if (antenn_address = "1111" and antenn_addr_edge = '1') or (start = '1') then
          new_param_buff_addr <= param_buff_addr;
        end if;
    end if;
  end process;


fifo_non_simetric_inst : entity fifo_non_simetric
    generic map(
      g_WIDTH           => 8,
      g_DEPTH           => 32,
      g_ADDR_LENGTH     => c_param_mem_addr_length + 1
    )
    Port map( 
      i_clk             => clk,
      i_rst_sync        => '0',
      i_wr_addr         => param_mem_adda,
      i_wr_data         => param_mem_dina,
      i_wr_en           => param_mem_wea,
      o_full            => open,
      o_rd_addr         => fifo_non_simetric_rd_addr,
      o_rd_data         => fifo_non_simetric_dout,
      i_rd_en           => fifo_non_simetric_rd_en,
      o_empty           => fifo_non_simetric_empty
    );

fifo_non_simetric_rd_en <= not (fifo_non_simetric_empty or new_addr_wr_en_d);

get_param_wea <= fifo_non_simetric_rd_en or new_addr_wr_en_d;
get_param_addra <= (not new_param_buff_addr) & antenn_address & (new_adrr_l - 1) & '0' when new_addr_wr_en_d = '1' else param_buff_addr & fifo_non_simetric_rd_addr(7 downto 0);
get_param_dina <= sin_mem_b_addr + freq_step when new_addr_wr_en_d = '1' else fifo_non_simetric_dout;
--sin_mem_byte <= sin_mem(to_integer(unsigned(sin_mem_b_addr(c_sin_mem_addr_length - 1 downto 0))));
to_data_out(15 downto 0) <= (sin_mem_byte*ampl_byte_d);

data_out_proc:
  process(clk)
  begin
    if rising_edge(clk) then
        if new_addr_wr_en_d1 = '1' then
          data_out <= data_out + to_data_out;
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

timer_tick_proc:
  process(clk)
  begin
    if rising_edge(clk) then
      if (en = '0') then
        clk_counter <= (others => '0');
        antenn_addr_edge <= '0';
      elsif clk_counter = 11 then
        clk_counter <= (others => '0');
        antenn_addr_edge <= '1';
      else
        clk_counter <= clk_counter + 1;
        antenn_addr_edge <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      en_d <= en;
      new_addr_wr_en <= not clk_x8_counter(clk_x8_counter'length - 1);
      new_addr_wr_en_d <= new_addr_wr_en;
      new_addr_wr_en_d1 <= new_addr_wr_en_d;
      new_addr_wr_en_d2 <= new_addr_wr_en_d1;
      new_adrr_l <= clk_x8_counter(clk_x8_counter'length - 2 downto 0);
    end if;
  end process;

data_out_valid <= new_addr_wr_en_d2 and not new_addr_wr_en_d1;

out_process :
  process(clk)
  begin
    if rising_edge(clk) then
      if data_out_valid = '1' then
        antenn_data <= data_out(18 downto 11);
        antenn_addr <= antenn_address;
        antenn_data_valid <= '1';
      else
        antenn_data_valid <= '0';
      end if;
    end if;
  end process;

antenn_address_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (en_d = '0') then
        antenn_address <= (others => '0');
      else
        if (antenn_addr_edge = '1') then
          antenn_address <= antenn_address + 1;
        end if;
      end if;
    end if;
  end process;

start <= en and (not en_d);
param_mem_addb <= (not new_param_buff_addr) & antenn_address & clk_x8_counter(clk_x8_counter'length - 2 downto 0);

clk_x8_counter_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (en = '0') then
        clk_x8_counter <= (clk_x8_counter'length - 1 => '1', others => '0');
      else
        if ((start = '1') or (antenn_addr_edge = '1')) then
          clk_x8_counter <= (others => '0');
        elsif clk_x8_counter(clk_x8_counter'length - 1) = '0' then
          clk_x8_counter <= clk_x8_counter + 1;
        end if;
      end if;
      clk_x8_counter_d <= clk_x8_counter;
      clk_x8_counter_d1 <= clk_x8_counter_d;
    end if;
  end process;

param_read_proc :
  process(clk)
  begin
    if rising_edge(clk) then
        sin_mem_b_addr(c_sin_mem_addr_length - 1 downto 0) <= param_mem_dout(c_sin_mem_addr_length - 1 downto 0);
        ampl_byte <= param_mem_dout(23 downto 16);
        ampl_byte_d <= ampl_byte;
        freq_step(7 downto 0) <= param_mem_dout(31 downto 24);
    end if;
  end process;


sin_mem_inst : ENTITY sin_mem 
  PORT map(
    clka    => clk,
    wea(0)  => sin_mem_wea   ,
    addra   => sin_mem_addra ,
    dina    => sin_mem_dina  ,
    clkb    => clk,
    addrb   => sin_mem_b_addr(c_sin_mem_addr_length - 1 downto 0),
    doutb   => sin_mem_byte
  );


end Behavioral;
