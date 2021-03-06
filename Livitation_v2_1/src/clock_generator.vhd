----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2019 17:38:20
-- Design Name: 
-- Module Name: clock_generator - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clock_generator is
  Port ( 
    sys_clk_in            : in std_logic;

    ext_clk_p_in          : in std_logic;
    ext_clk_n_in          : in std_logic;

    clk_sel               : in std_logic;

    rst_in                : in std_logic;
    pll_lock              : out std_logic;

    clk_100MHz_out        : out std_logic;
    clk_200MHz_out        : out std_logic;

    clk_50MHz_p_out       : out std_logic;
    clk_50MHz_n_out       : out std_logic
  );
end clock_generator;

architecture Behavioral of clock_generator is
  signal ext_clk_IBUFGDS    : std_logic;
  signal sys_clk_IBUFG      : std_logic;
  signal clk_res            : std_logic;
  signal CLKFBIN            : std_logic;
  signal CLKFBOUT           : std_logic;
  signal pll_clkout_0       : std_logic;
  signal pll_clkout_1       : std_logic;
  signal pll_clkout_2       : std_logic;
  signal pll_clkout_3       : std_logic;
  signal bufh_o             : std_logic;
  signal bufh_ext_clk       : std_logic;

begin

IBUFGDS_inst : IBUFGDS
   generic map (
      DIFF_TERM => TRUE, -- Differential Termination 
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => ext_clk_IBUFGDS,  -- Clock buffer output
      I => ext_clk_p_in,  -- Diff_p clock buffer input (connect directly to top-level port)
      IB => ext_clk_n_in -- Diff_n clock buffer input (connect directly to top-level port)
   );


   IBUFG_inst : IBUFG
   generic map (
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => sys_clk_IBUFG, -- Clock buffer output
      I => sys_clk_in  -- Clock buffer input (connect directly to top-level port)
   );

in_BUFH_inst : BUFG
   port map (
      O => bufh_ext_clk, -- 1-bit output: Clock output
      I => ext_clk_IBUFGDS  -- 1-bit input: Clock input
   );

BUFGMUX_inst : BUFGMUX
   generic map (
      CLK_SEL_TYPE => "ASYNC"  -- Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
   )
   port map (
      O => clk_res,             -- 1-bit output: Clock buffer output
      I0 => sys_clk_IBUFG,            -- 1-bit input: Clock buffer input (S=0)
      I1 => bufh_ext_clk,        -- 1-bit input: Clock buffer input (S=1)
      S => clk_sel                  -- 1-bit input: Clock buffer select
   );

PLL_BASE_inst : PLL_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",             -- "HIGH", "LOW" or "OPTIMIZED" 
      CLKFBOUT_MULT => 20,                   -- Multiply value for all CLKOUT clock outputs (1-64)
      CLKFBOUT_PHASE => 0.0,                -- Phase offset in degrees of the clock feedback output
                                            -- (0.0-360.0).
      CLKIN_PERIOD => 20.0,                  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30
                                            -- MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      CLKOUT0_DIVIDE => 5,
      CLKOUT1_DIVIDE => 10,
      CLKOUT2_DIVIDE => 20,
      CLKOUT3_DIVIDE => 20,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLK_FEEDBACK => "CLKFBOUT",           -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      COMPENSATION => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL" 
      DIVCLK_DIVIDE => 1,                   -- Division value for all output clocks (1-52)
      REF_JITTER => 0.1,                    -- Reference Clock Jitter in UI (0.000-0.999).
      RESET_ON_LOSS_OF_LOCK => FALSE        -- Must be set to FALSE
   )
   port map (
      CLKFBOUT => CLKFBOUT, -- 1-bit output: PLL_BASE feedback output
      -- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      CLKOUT0 => pll_clkout_0,
      CLKOUT1 => pll_clkout_1,
      CLKOUT2 => pll_clkout_2,
      CLKOUT3 => pll_clkout_3,
      CLKOUT4 => open,
      CLKOUT5 => open,
      LOCKED => pll_lock,     -- 1-bit output: PLL_BASE lock status output
      CLKFBIN => CLKFBIN,   -- 1-bit input: Feedback clock input
      CLKIN => clk_res,       -- 1-bit input: Clock input
      RST => rst_in            -- 1-bit input: Reset input
   );

CLKFBIN <= CLKFBOUT;


bufg1_inst : BUFG port map ( I => pll_clkout_0, O => clk_200MHz_out);
bufg2_inst : BUFG port map ( I => pll_clkout_1, O => clk_100MHz_out);

BUFH_inst : BUFH
   port map (
      O => bufh_o, -- 1-bit output: Clock output
      I => pll_clkout_2  -- 1-bit input: Clock input
   );


OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => clk_50MHz_p_out,     -- Diff_p output (connect directly to top-level port)
      OB => clk_50MHz_n_out,   -- Diff_n output (connect directly to top-level port)
      I => bufh_o      -- Buffer input 
   );



end Behavioral;
