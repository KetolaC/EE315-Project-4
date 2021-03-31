library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ps2Handler is
  Port ( 
    clock       : in std_logic;
    in_ps2_clk  : in std_logic;
    data_in     : in std_logic;
    data_out    : out std_logic_vector(7 downto 0);
    irq         : out std_logic
    );
end ps2Handler;

architecture Behavioral of ps2Handler is
    signal clk_curt     : std_logic;
    signal clk_prev     : std_logic;
    signal ps2_data     : std_logic_vector(7 downto 0);
    signal deb_ps2      : std_logic;
    signal deb_data_in  : std_logic;
    signal data         : std_logic;    
    signal irq_0        : std_logic := '0';  
--    signal data_out     : std_logic_vector(7 downto 0);  
    signal chk          : std_logic := '0';    -- Check to see if the parity is the same.
    type statetype is (idle, start, databit0, databit1, databit2, databit3, databit4, databit5, databit6, databit7, parity, stop);
    signal state : statetype := idle;
    

begin
--    in_ps2_clk <= 'Z';
--    data_in <= 'Z';
    
--    ila_chk : ila_0 port map(clk => clock, probe0 => ps2_data, probe1 => deb_ps2, probe2 => deb_data_in);
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
            
                when idle =>
                   if(deb_ps2 = '0' and clk_prev = '1') then                
                        state <= start;
                        ps2_data <= x"00";
                        irq_0 <= '0';
                    end if;
                                
                when start =>
                   if(deb_ps2 = '0' and clk_prev = '1') then                
                        state <= databit0;
                        data <= deb_data_in;
                        irq_0 <= '0';
                    end if;
                    
                when databit0 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit1;
                    end if;
                
                when databit1 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit2;
                    end if;
                    
                when databit2 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit3;
                    end if;
                    
                when databit3 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit4;
                    end if;

                when databit4 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit5;
                    end if;
                    
                when databit5 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit6;
                    end if;
                    
                when databit6 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= databit7;
                    end if;
                    
                when databit7 =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data <= deb_data_in;                      
                        ps2_data <= data & ps2_data(7 downto 1);
                        state <= parity;
                    end if;
                    
                when parity =>
                    if(deb_ps2 = '0' and clk_prev = '1') then 
                        data_out <= ps2_data;
                        state <= stop;                    
                        chk <= ( deb_data_in xor ps2_data(0) xor ps2_data(1) xor ps2_data(2) xor ps2_data(3) xor ps2_data(4) xor ps2_data(5) xor ps2_data(6) xor ps2_data(7));                        
                        if(chk = '1') then
                            irq_0 <= '1';
                        end if;
                    end if;
                when stop =>
                         state <= stop;                
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
