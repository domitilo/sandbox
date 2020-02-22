----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2020 18:45:50
-- Design Name: 
-- Module Name: stream_adc_if - Behavioral
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

entity stream_adc_if is
  port (
    m_axis_clk    : in  std_logic;
    aresetn       : in  std_logic;
    in_data            : in std_logic_vector(13 downto 0);
    dv              : in std_logic;
    eof             : in std_logic;
    ramp_valid :in std_logic;
--    m_axis_tdata  : out std_logic_vector(((g_datawidth rem 8)+g_datawidth)*g_num_channels-1 downto 0);
    m_axis_tdata  : out std_logic_vector(31 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tlast  : out std_logic);end stream_adc_if;

architecture Behavioral of stream_adc_if is
    signal     tdata : std_logic_vector(31 downto 0);
    signal tvalid: std_logic;
begin

m_axis_tvalid <= tvalid;
m_axis_tdata <= tdata;
m_axis_tlast <= eof;

    process(m_axis_clk) is
    begin
        if rising_edge(m_axis_clk) then
            if aresetn = '0' then
                tdata <= (others => '0');
                tvalid <= '0';
            else
                tdata <= "00" & in_data & "00" & in_data;     
                tvalid <= dv and ramp_valid ;       
            end if;
        end if;
    end process;

end Behavioral;
