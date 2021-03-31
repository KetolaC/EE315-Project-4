----------------------------------------------------------------------------------
-- Company: Clarkson University
-- Engineer: Camilla Ketola
-- 
--
-- Create Date:    14:50:51 03/18/2021
-- Project Name:   pmodvga
-- Target Devices: Cora-Z7-10
-- Tool versions:  2019.1
-- Additional Comments: 
--
-- Copyright Digilent 2017
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity vga_gen is
    Port ( CLK_I    : in   STD_LOGIC; --input clock
           rst      : in   std_logic;
           datain   : in   std_logic_vector(31 downto 0); --this is the data for one 8 pixel row
           wen      : in   std_logic; --signals when to write a new character
           VGA_HS_O : out  STD_LOGIC; -- h sync
           VGA_VS_O : out  STD_LOGIC; -- v sync
           VGA_R    : out  STD_LOGIC_VECTOR (3 downto 0); --red output
           VGA_B    : out  STD_LOGIC_VECTOR (3 downto 0); --blue output
           VGA_G    : out  STD_LOGIC_VECTOR (3 downto 0); --green output
           ready    : out  std_logic); -- tells when ready to change addrin
end vga_gen;

architecture Behavioral of vga_gen is

---------------------
--- Clock Divider ---
---------------------

component clk_wiz_0
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic
 );
end component;

--Sync Generation constants

--***640x480@60Hz***--  Requires 25 MHz clock
constant FRAME_WIDTH : natural := 640;
constant FRAME_HEIGHT : natural := 480;

constant H_FP : natural := 16; --H front porch width (pixels)
constant H_PW : natural := 96; --H sync pulse width (pixels)
constant H_MAX : natural := 800; --H total period (pixels)

constant V_FP : natural := 10; --V front porch width (lines)
constant V_PW : natural := 2; --V sync pulse width (lines)
constant V_MAX : natural := 525; --V total period (lines)

constant H_POL : std_logic := '0';
constant V_POL : std_logic := '0';
----------------------------------------------

signal pxl_clk : std_logic;
signal active : std_logic;

signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);

signal h_sync_dly_reg : std_logic := not(H_POL);
signal v_sync_dly_reg : std_logic :=  not(V_POL);

signal vga_red_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg : std_logic_vector(3 downto 0) := (others =>'0');

signal vga_red : std_logic_vector(3 downto 0);
signal vga_green : std_logic_vector(3 downto 0);
signal vga_blue : std_logic_vector(3 downto 0);

signal set_red : std_logic_vector(1 downto 0) := "00";
signal set_green : std_logic := '0';
signal set_blue : std_logic := '0';

signal cur_pixel_col : integer := 0;
signal cur_pixel_row : integer := 0;

begin
  
   
clk_div_inst : clk_wiz_0
  port map
   (-- Clock in ports
    CLK_IN1 => CLK_I,
    -- Clock out ports
    CLK_OUT1 => pxl_clk);

------------------------------------------------------  
-------            Colour Set-Up               -------  
------------------------------------------------------ 
--     This sets a pixel to the correct colour      --
------------------------------------------------------

vga_red     <= "0000" when (active = '1' and (set_red = "00")) else 
               "0101" when (active = '1' and (set_red = "01")) else 
               "1010" when (active = '1' and (set_red = "10")) else 
               "1111" when (active = '1' and (set_red = "11")) else 
               (others => '0');

vga_green   <= "0000" when (active = '1' and (set_green = '0')) else 
               "1111" when (active = '1' and (set_green = '1')) else 
               (others => '0');

vga_blue    <= "0000" when (active = '1' and (set_blue = '0')) else 
               "1111" when (active = '1' and (set_blue = '1')) else 
               (others => '0');

-----------------------------------------------------
-------         Character Generation          -------
-----------------------------------------------------
-- Creates a 8x12 character from the datain input  --
-----------------------------------------------------

cur_pixel_col <= to_integer(unsigned(h_cntr_reg));
                              
------------------------------------------------------  
-------           Colour Generation            -------  
------------------------------------------------------ 
--   This takes the datain and converts it to a     --
--   colour selection chart to be used in colour    -- 
--   set-up                                         --
------------------------------------------------------

process(pxl_clk) 
begin
    if(rising_edge(pxl_clk)) then
        if(cur_pixel_col mod 8 = 7) then
            set_red <= datain(0 downto 1);
            set_green <= datain(2);
            set_blue <= datain(3);
            ready <= '1';
        elsif(cur_pixel_col mod 8 = 6) then
            set_red <= datain(4 downto 5);
            set_green <= datain(6);
            set_blue <= datain(7);
        elsif(cur_pixel_col mod 8 = 5) then
            set_red <= datain(8 downto 9);
            set_green <= datain(10);
            set_blue <= datain(11);
        elsif(cur_pixel_col mod 8 = 4) then
            set_red <= datain(12 downto 13);
            set_green <= datain(14);
            set_blue <= datain(15);
        elsif(cur_pixel_col mod 8 = 3) then
            set_red <= datain(16 downto 17);
            set_green <= datain(18);
            set_blue <= datain(19);
        elsif(cur_pixel_col mod 8 = 2) then
            set_red <= datain(20 downto 21);
            set_green <= datain(22);
            set_blue <= datain(23);
        elsif(cur_pixel_col mod 8 = 1) then
            set_red <= datain(24 downto 25);
            set_green <= datain(26);
            set_blue <= datain(27);
        elsif(cur_pixel_col mod 8 = 0) then
            set_red <= datain(28 downto 29);
            set_green <= datain(30);
            set_blue <= datain(31);
            ready <= '0';
        end if;
    end if;

end process;
  
 ------------------------------------------------------
 -------      SYNC GENERATION AND PROCESSES      ------
 ------------------------------------------------------
  
  process(rst)
  begin
    if (rst = '0') then 
        vga_red_reg <= (others => '0');
        vga_green_reg <= (others => '0');
        vga_blue_reg <= (others => '0');
    end if;
  end process;
  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  
  
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
  
  active <= '1' when ((h_cntr_reg < FRAME_WIDTH) and (v_cntr_reg < FRAME_HEIGHT)) else
            '0';

  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      v_sync_dly_reg <= v_sync_reg;
      h_sync_dly_reg <= h_sync_reg;
      vga_red_reg <= vga_red;
      vga_green_reg <= vga_green;
      vga_blue_reg <= vga_blue;
    end if;
  end process;

  VGA_HS_O <= h_sync_dly_reg;
  VGA_VS_O <= v_sync_dly_reg;
  VGA_R <= vga_red_reg;
  VGA_G <= vga_green_reg;
  VGA_B <= vga_blue_reg;

end Behavioral;
