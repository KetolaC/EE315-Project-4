library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ps2_controller is
  Port ( 
    clock      : in std_logic;
    in_ps2_clk     : inout std_logic;
    
    data_in     : inout std_logic;
    data_out    : out std_logic_vector(7 downto 0);
    irq         : out std_logic
    );
end ps2_controller;

architecture Behavioral of ps2_controller is
    signal clk_curt     : std_logic;
    signal clk_prev     : std_logic;
    signal ps2_data     : std_logic_vector(7 downto 0);
    signal deb_ps2      : std_logic;
    signal deb_data_in  : std_logic;
    signal irq_0        : std_logic := '0';  
--    signal data_out     : std_logic_vector(7 downto 0);  
    signal chk          : std_logic := '0';    -- Check to see if the parity is the same.
    type statetype is (start, databit0, databit1, databit2, databit3, databit4, databit5, databit6, databit7, parity, stop);
    signal state : statetype := start;
    
    component debounce IS
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    input  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
END component;
    
    component ila_0 is
    port(
        clk: in std_logic;
        probe0 : in std_logic_vector(7 downto 0);
        probe1 : in std_logic;
        probe2 : in std_logic
    );
    end component;
begin
--    in_ps2_clk <= 'Z';
--    data_in <= 'Z';
--    deb_ps2_clk : debounce port map(clk => clock, input => in_ps2_clk, result => deb_ps2);
--    deb_data : debounce port map(clk => clock, input => data_in, result => deb_data_in);
    
    ila_chk : ila_0 port map(clk => clock, probe0 => ps2_data, probe1 => deb_ps2, probe2 => deb_data_in);
    deb_ps2 <= in_ps2_clk;
    deb_data_in <= data_in;
    irq <= irq_0;
    
    process(clock)
    begin
    if(rising_edge(clock)) then
        clk_prev <= deb_ps2;
    end if;
    end process;
    
    process(clock)
    begin
    
    if(rising_edge(clock)) then
            case state is
                when start =>
                   if(deb_ps2 = '0' and clk_prev = '1') then                
                        state <= databit0;
                        ps2_data <= x"00";
                        irq_0 <= '0';
                    end if;
                    
                when databit0 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then   
                        ps2_data <= ps2_data(7 downto 1) & deb_data_in;
                        state <= databit1;
                    end if;
                
                when databit1 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "000000" & deb_data_in & ps2_data(0);
                        state <= databit2;
                    end if;
                    
                when databit2 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "00000" & deb_data_in & ps2_data(1 downto 0);
                        state <= databit3;
                    end if;
                    
                when databit3 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "0000" & deb_data_in & ps2_data(2 downto 0);
                        state <= databit4;
                    end if;

                when databit4 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "000" & deb_data_in & ps2_data(3 downto 0);
                        state <= databit5;
                    end if;
                    
                when databit5 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "00" & deb_data_in & ps2_data(4 downto 0);
                        state <= databit6;
                    end if;
                    
                when databit6 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= "0" & deb_data_in & ps2_data(5 downto 0);
                        state <= databit7;
                    end if;
                    
                when databit7 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        ps2_data <= deb_data_in & ps2_data(6 downto 0);
                        state <= parity;
                    end if;
                    
                when parity =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
--                        chk <= Not( deb_data_in xor ps2_data(0) xor ps2_data(1) xor ps2_data(2) xor ps2_data(3) xor ps2_data(4) xor ps2_data(5) xor ps2_data(6) xor ps2_data(7));
                        chk <= ( deb_data_in xor ps2_data(0) xor ps2_data(1) xor ps2_data(2) xor ps2_data(3) xor ps2_data(4) xor ps2_data(5) xor ps2_data(6) xor ps2_data(7));                        
                        if(chk = '1') then
                            irq_0 <= '1';
                            data_out <= ps2_data;
                            state <= stop;
                        end if;
                    end if;
                when stop =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        if(irq_0 = '0') then
                            state <= start;
                        else
                            state <= stop;
                        end if;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
