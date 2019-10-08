----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2019 10:44:58
-- Design Name: 
-- Module Name: clock_gen_sys_clk - Behavioral
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

entity clock_gen_sys_clk is
    Port (
    in_clk  : in std_logic;
    clk_0   : out std_logic;
    clk_1   : out std_logic;
    clk_2_p : out std_logic;
    clk_2_n : out std_logic;
    locked  : out std_logic
    );
end clock_gen_sys_clk;

architecture Behavioral of clock_gen_sys_clk is
    signal clk_in_bufg          : std_logic;
    signal pll_lock             : std_logic;
    signal pll_clkout_2_bufg    : std_logic;
    signal IOCLK_BUFPLL         : std_logic;
    signal CLKFBIN              : std_logic;
    signal CLKFBOUT             : std_logic;
    signal pll_clkout_0         : std_logic;
    signal pll_clkout_1         : std_logic;
    signal pll_clkout_2         : std_logic;
    signal pll_clkout_3         : std_logic;
    signal bufh_o               : std_logic;

begin

IBUFG_inst : IBUFG
   generic map (
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => clk_in_bufg, -- Clock buffer output
      I => in_clk  -- Clock buffer input (connect directly to top-level port)
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
      CLKOUT0_DIVIDE => 10,
      CLKOUT1_DIVIDE => 50,
      CLKOUT2_DIVIDE => 50,
      CLKOUT3_DIVIDE => 1,
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
      CLKOUT3 => open,
      CLKOUT4 => open,
      CLKOUT5 => open,
      LOCKED => pll_lock,     -- 1-bit output: PLL_BASE lock status output
      CLKFBIN => CLKFBIN,   -- 1-bit input: Feedback clock input
      CLKIN => clk_in_bufg,       -- 1-bit input: Clock input
      RST => '0'            -- 1-bit input: Reset input
   );

locked <= pll_lock;


CLKFBIN <= CLKFBOUT;

bufg0_inst : BUFG port map ( I => pll_clkout_0, O => clk_0);
bufg1_inst : BUFG port map ( I => pll_clkout_1, O => clk_1);
--bufg2_inst : BUFG port map ( I => pll_clkout_2, O => pll_clkout_2_bufg );


--BUFPLL_inst : BUFPLL
--   generic map (
--      DIVIDE => 1,         -- DIVCLK divider (1-8)
--      ENABLE_SYNC => TRUE  -- Enable synchrnonization between PLL and GCLK (TRUE/FALSE)
--   )
--   port map (
--      IOCLK => IOCLK_BUFPLL,               -- 1-bit output: Output I/O clock
--      LOCK => open,                 -- 1-bit output: Synchronized LOCK output
--      SERDESSTROBE => open, -- 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
--      GCLK => pll_clkout_2_bufg,                 -- 1-bit input: BUFG clock input
--      LOCKED => pll_lock,             -- 1-bit input: LOCKED input from PLL
--      PLLIN => pll_clkout_0                -- 1-bit input: Clock input from PLL
--   );
   
BUFH_inst : BUFH
   port map (
      O => bufh_o, -- 1-bit output: Clock output
      I => pll_clkout_2  -- 1-bit input: Clock input
   );


OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT")
   port map (
      O => clk_2_p,     -- Diff_p output (connect directly to top-level port)
      OB => clk_2_n,   -- Diff_n output (connect directly to top-level port)
      I => bufh_o      -- Buffer input 
   );

end Behavioral;
