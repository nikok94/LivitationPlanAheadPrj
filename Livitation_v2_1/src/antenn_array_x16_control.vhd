
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
      c_form_mem_addr_length        : integer := 13;
      c_param_mem_addr_length       : integer := 5;
      emmiter_address_length        : integer := 4
    );
    Port ( 
      clk                           : in std_logic;

      form_mem_wea                  : in std_logic;
      form_mem_addra                : in std_logic_vector(c_form_mem_addr_length - 1 downto 0);
      form_mem_dina                 : in std_logic_vector(7 downto 0);

      param_mem_adda                : in std_logic_vector(5 downto 0);
      param_mem_dina                : in std_logic_vector(7 downto 0);
      param_mem_wea                 : in std_logic;

      param_apply                   : in std_logic;

      N_counter                     : in std_logic_vector(c_form_mem_addr_length - 1 downto 0);

      emmiter_address               : in std_logic_vector(emmiter_address_length - 1 downto 0);
      emmiter_address_wr_en         : in std_logic;
      emmiter_data                  : out std_logic_vector(7 downto 0);
      emmiter_data_valid            : out std_logic
    );
end antenn_array_x16_control;

architecture Behavioral of antenn_array_x16_control is

    signal param_mem_addb           : std_logic_vector(4 downto 0):= (others => '0');
    signal param_mem_dout           : std_logic_vector(31 downto 0);
    signal emmiter_address_d1       : std_logic_vector(3 downto 0):= (others => '0');
    signal emmiter_address_d2       : std_logic_vector(3 downto 0):= (others => '0');
    signal emmiter_address_d3       : std_logic_vector(3 downto 0):= (others => '0');
    signal data_out                 : std_logic_vector(15 downto 0):= (others => '0');
    signal to_data_out              : std_logic_vector(17 downto 0):= (others => '0');
    signal form_mem_b_addr          : std_logic_vector(15 downto 0):= (others => '0');
    signal freq_step                : std_logic_vector(15 downto 0):= (others => '0');
    signal ampl_byte                : std_logic_vector(8 downto 0):=(others => '0');
    signal new_addr_wr_en           : std_logic:= '0';
    signal new_addr_wr_en_d         : std_logic:= '0';
    signal new_addr_wr_en_d1        : std_logic:= '0';
    signal new_addr_wr_en_d2        : std_logic:= '0';
    signal get_param_wea            : std_logic;
    signal get_param_addra          : std_logic_vector(c_param_mem_addr_length downto 0);
    signal get_param_dina           : std_logic_vector(15 downto 0);
    signal form_mem_byte            : std_logic_vector(7 downto 0):=(others => '0');
    signal form_mem_byte1           : std_logic_vector(8 downto 0):=(others => '0');
    signal fifo_non_simetric_dout   : std_logic_vector(15 downto 0);
    signal fifo_non_simetric_rd_en  : std_logic;
    signal fifo_non_simetric_empty  : std_logic;
    signal fifo_non_simetric_rd_addr: std_logic_vector(c_param_mem_addr_length - 1 downto 0);
    signal param_buff_addr          : std_logic:= '0';
    signal new_param_buff_addr      : std_logic:= '0';
    signal wr_buff_flag             : std_logic:= '0';
    signal new_addr                 : std_logic:= '0';
    signal new_addr_d               : std_logic;
    signal new_form_byte            : std_logic:= '0';
    signal new_form_byte_d          : std_logic:= '0';
    signal data_valid               : std_logic:= '0';

begin

param_buff_addr_proc :
  process(clk)
  begin
    if rising_edge(clk) then

      if (param_apply = '1') then
        new_param_buff_addr <= not new_param_buff_addr;
        wr_buff_flag <= '1';
      end if;

      if (emmiter_address_wr_en = '1') then

        if ((emmiter_address = 0) and (wr_buff_flag = '1')) then
          param_buff_addr <= new_param_buff_addr;
          param_mem_addb <= new_param_buff_addr & emmiter_address;
          wr_buff_flag <= '0';
        else
          param_mem_addb <= param_buff_addr & emmiter_address;
        end if;
        new_addr <= '1';
      else
        new_addr <= '0';
      end if;
      new_addr_d <= new_addr;
    end if;
  end process;

fifo_non_simetric_inst : entity fifo_non_simetric
    generic map(
      g_WIDTH           => 8,
      g_DEPTH           => 32,
      g_ADDR_LENGTH     => param_mem_adda'length
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

fifo_non_simetric_rd_en <= not (fifo_non_simetric_empty or data_valid);

--process(clk)
--begin
--  if rising_edge(clk) then
--    if (data_valid = '1') then
--      get_param_wea <= '1';
--      get_param_addra <= param_mem_addb & '0';
--      get_param_dina <= form_mem_b_addr + 1;
--    else
--      get_param_wea   <= fifo_non_simetric_rd_en;
--      get_param_addra <= (not param_buff_addr) & fifo_non_simetric_rd_addr(4 downto 0);
--      get_param_dina  <= fifo_non_simetric_dout;
--      end if;
--  end if;
--end process;

get_param_wea   <= fifo_non_simetric_rd_en;
get_param_addra <= (not param_buff_addr) & fifo_non_simetric_rd_addr(4 downto 0);
get_param_dina  <= fifo_non_simetric_dout;

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

form_mem_byte1 <= '0' & form_mem_byte;
emmiter_data <= to_data_out(15 downto 8);

out_process :
  process(clk)
  begin
    if rising_edge(clk) then
      if (new_form_byte_d = '1') then
        to_data_out <= (form_mem_byte1)*(ampl_byte + 1);
        data_valid <= '1';
      else 
        data_valid <= '0';
      end if;
    end if;
  end process;

emmiter_data_valid <= data_valid;

param_read_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (new_addr_d = '1') then
        form_mem_b_addr(c_form_mem_addr_length - 1 downto 0) <= param_mem_dout(c_form_mem_addr_length - 1 downto 0) +  N_counter;
        form_mem_b_addr(form_mem_b_addr'length - 1 downto c_form_mem_addr_length) <= (others => '1');
        ampl_byte(7 downto 0) <= param_mem_dout(23 downto 16);
        new_form_byte <= '1';
      else
        new_form_byte <= '0';
      end if;
      new_form_byte_d <= new_form_byte;
    end if;
  end process;

form_mem_inst : ENTITY sin_mem 
  PORT map(
    clka    => clk,
    wea(0)  => form_mem_wea   ,
    addra   => form_mem_addra ,
    dina    => form_mem_dina  ,
    clkb    => clk,
    addrb   => form_mem_b_addr(c_form_mem_addr_length - 1 downto 0),
    doutb   => form_mem_byte
  );


end Behavioral;
