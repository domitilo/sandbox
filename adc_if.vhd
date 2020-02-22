----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2020 18:37:23
-- Design Name: 
-- Module Name: adc_if - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adc_if is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           data : out STD_LOGIC_VECTOR (13 downto 0);
           dv : out STD_LOGIC);
end adc_if;

architecture Behavioral of adc_if is
    signal u_data : unsigned (13 downto 0);
begin

    data <= std_logic_vector(u_data);

process(clk) is
begin
    if clk'event and clk='1' then
        if resetn='0' then
            u_data <= (others =>'0');
            dv <= '0';
        else
        u_data <= u_data + 1;
        dv <= '1';
        
        end if;
    end if;
end process;

end Behavioral;
