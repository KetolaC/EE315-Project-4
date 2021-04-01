----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2021 10:48:47 PM
-- Design Name: 
-- Module Name: addr_int - Behavioral
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity addr_int is
    Port (  addr_in  : in std_logic_vector(31 downto 0);
            addr_out : out std_logic_vector(15 downto 0));
end addr_int;

architecture Behavioral of addr_int is

begin

addr_out <= addr_in(15 downto 0);
end Behavioral;
