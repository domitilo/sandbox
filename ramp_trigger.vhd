----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2020 17:21:48
-- Design Name: 
-- Module Name: ramp_trigger - Behavioral
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

entity ramp_trigger is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           enable : in std_logic;
           trigger : in STD_LOGIC;
           valid : out STD_LOGIC;
           eof : out STD_LOGIC);
end ramp_trigger;

architecture Behavioral of ramp_trigger is
    type t_state is (idle, framing,sof);
    signal state : t_state;
    signal trigger_low : std_logic;
    signal valid_s  : std_logic;
    signal sof_s    : std_logic;

begin

valid   <= valid_s;
eof     <= sof_s    ;

process(clk) is
begin
    if(clk'event and clk = '1') then
        if resetn = '0' then
            trigger_low <= '0';
            state <= idle;
            valid_s <= '0';
            sof_s   <= '0';
        else
        valid_s <= '1';
           if enable = '0' then
                valid_s <= '0';
                state <= idle;
                trigger_low <= '0';
                sof_s   <= '0';
            else
                trigger_low <= '0';
                sof_s   <= '0';
                case state is
                    when idle =>
                        valid_s <= '0';
                        if trigger = '1' and trigger_low = '1' then -- Avoids asserting if is not a rising edge
                            state <= framing;
                        else
                            state <= idle;  
                            if trigger = '0' then
                                trigger_low <= '1';
                            end if;
                        end if;
                    
                    when framing =>
                        if trigger = '1' and trigger_low = '1' then
--                            state <= sof;
                            state <= framing;
                            sof_s   <= '1';
                            trigger_low <= '0';
                        else
                            state <= framing;
                            if trigger = '0' then
                                trigger_low <= '1';
                            end if;
                        end if;
                    
--                    when sof =>
                        --if trigger = '0' then
--                            state <= framing;
--                            sof_s   <= '1';
                        --else
                        --    state <= sof;
                        --end if;
                    
                    when others =>
                        state <= idle;       
                end case;
            end if;           
        end if;           
    end if;
end process;






end Behavioral;
