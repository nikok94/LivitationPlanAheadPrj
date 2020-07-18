
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.MATH_REAL.ALL;


library work;
use work.ram_sclk;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antenn_array_control is
    generic (
      c_form_memory_length          : integer := 13;
      c_num_emmiter                 : integer := 4
    );
    Port ( 
      clk                           : in std_logic;

      form_mem_wea                  : in std_logic;
      form_mem_addra                : in std_logic_vector(natural(log2(real(c_form_memory_length)))-1 downto 0);
      form_mem_dina                 : in std_logic_vector(7 downto 0);

      param_mem_adda                : in integer range 0 to c_num_emmiter*3 - 1;
      param_mem_dina                : in std_logic_vector(7 downto 0);
      param_mem_wea                 : in std_logic;

      param_apply                   : in std_logic;

      n_counter                     : in std_logic_vector(15 downto 0);
      emmiter_address               : in integer range 0 to c_num_emmiter - 1;

      emmiter_addr_out              : out std_logic_vector(natural(log2(real(c_num_emmiter)))-1 downto 0);
      emmiter_data_out              : out std_logic_vector(7 downto 0)
    );
end antenn_array_control;

architecture Behavioral of antenn_array_control is
  signal c_addr_max_width           : integer := natural(log2(real(c_form_memory_length)));
  type params_array          is array (0 to c_num_emmiter*3 - 1) of std_logic_vector(7 downto 0);
  signal params0                    : params_array;
  signal params1                    : params_array;
  signal params_low_active          : std_logic:= '0';
  signal n_counter_d0               : std_logic_vector(15 downto 0):=(others => '0');
  signal ampl                       : std_logic_vector(7 downto 0):=(others => '0');
  signal ampl_d0                    : std_logic_vector(7 downto 0):=(others => '0');
  signal ampl_d1                    : std_logic_vector(7 downto 0):=(others => '0');
  signal addr                       : std_logic_vector(15 downto 0):=(others => '0');
  signal next_addr_offset           : std_logic_vector(15 downto 0):=(others => '0');
  signal ram_addr                   : std_logic_vector(c_addr_max_width - 1 downto 0):= (others => '0');
  signal ram_data                   : std_logic_vector(8 - 1 downto 0):=(others => '0');
  signal ram_we                     : std_logic:= '0';
  signal ram_q                      : std_logic_vector(8 - 1 downto 0):=(others => '0');
  signal res                        : std_logic_vector(15 downto 0);
  signal add_out                    : std_logic_vector(natural(log2(real(c_num_emmiter)))-1 downto 0);
  signal add_out_d0                 : std_logic_vector(natural(log2(real(c_num_emmiter)))-1 downto 0);

begin
params_process :
  process(clk)
  begin
    if rising_edge(clk) then
      if (param_mem_wea = '1') then
        if (params_low_active = '1') then
          params1(param_mem_adda) <= param_mem_dina;
        else
          params0(param_mem_adda) <= param_mem_dina;
        end if;
      end if;
    end if;
  end process;

params_low_active_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (param_apply = '1') then
        params_low_active <= not params_low_active;
      end if;
    end if;
  end process;

process(clk)
begin
  if rising_edge(clk) then
    if (params_low_active = '1') then
      next_addr_offset <= params0(emmiter_address + 1) & params0(emmiter_address);
      ampl <= params0(emmiter_address + 2);
    else
      next_addr_offset <= params1(emmiter_address + 1) & params1(emmiter_address);
      ampl <= params1(emmiter_address + 2);
    end if;
    n_counter_d0 <= n_counter;
    ampl_d0 <= ampl;
    ampl_d1 <= ampl_d0;
    res <= ampl_d1*ram_q;
    emmiter_data_out <= res(15 downto 8);
    add_out <= conv_std_logic_vector(emmiter_address, add_out'length); 
    add_out_d0 <= add_out;
    emmiter_addr_out <= add_out_d0;
  end if;
end process;

ram_addr_proc :
  process(clk)
  begin
    if rising_edge(clk) then
      if (form_mem_wea = '1') then
        ram_addr <= form_mem_addra;
        ram_data <= form_mem_dina;
        ram_we <= '1';
      else
        ram_we <= '0';
        ram_addr <= n_counter_d0(ram_addr'length - 1 downto 0) + next_addr_offset(ram_addr'length - 1 downto 0);
      end if;
    end if;
  end process;

ram_inst : entity ram_sclk
  Generic map(
    c_data_width    => 8,
    c_num_data      => c_form_memory_length
  )
  Port map(
    clk             => clk,
    addr            => ram_addr,
    data            => ram_data,
    we              => ram_we,
    q               => ram_q
  );


end Behavioral;
