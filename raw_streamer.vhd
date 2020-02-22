library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity raw_streamer is

  generic (
    g_adc_datawidth : integer := 14;
    g_packet_bytes  : integer := 32;
    g_num_channels  : integer := 4);
  port (
    m_axis_clk    : in  std_logic;
    aresetn       : in  std_logic;
    adc_datavalid : in  std_logic;
    adc_chan0     : in  std_logic_vector(g_adc_datawidth-1 downto 0);
    adc_chan1     : in  std_logic_vector(g_adc_datawidth-1 downto 0);
    adc_chan2     : in  std_logic_vector(g_adc_datawidth-1 downto 0);
    adc_chan3     : in  std_logic_vector(g_adc_datawidth-1 downto 0);
    m_axis_tdata  : out std_logic_vector(((g_adc_datawidth rem 8)+g_adc_datawidth)*g_num_channels-1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tlast  : out std_logic);

end entity raw_streamer;

architecture behav of raw_streamer is
  constant zero_padding : std_logic_vector((g_adc_datawidth rem 8)-1 downto 0) := (others => '0');
  constant max_word     : integer                                              := g_packet_bytes/(m_axis_tdata'length/8);
  signal tdata          : std_logic_vector(m_axis_tdata'length-1 downto 0);
  signal tvalid         : std_logic;
  signal tlast          : std_logic;
begin  -- architecture behav

  process (m_axis_clk, aresetn) is
  begin  -- process
    if aresetn = '0' then               -- asynchronous reset (active low)
      tdata <= (others => '0');
    elsif m_axis_clk'event and m_axis_clk = '1' then  -- rising clock edge
      if (adc_datavalid = '1') then
        tdata <= zero_padding & adc_chan3
                 & zero_padding & adc_chan2
                 & zero_padding & adc_chan1
                 & zero_padding & adc_chan0;
        tvalid <= '1';
        if word_count = max_word-1 then
          word_count <= (others => '0');
          tlast      <= '1';
        else
          word_count <= word_count + 1;
          tlast      <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture behav;
