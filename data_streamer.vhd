library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity data_streamer is

  generic (
    g_datawidth    : integer := 14;
    g_nearer_pow2  : integer := 16;
    g_packet_bytes : integer := 32;
    g_id_number    : integer range 0 to 15 := 0;
    g_num_channels : integer := 10);
  port (
    m_axis_clk    : in  std_logic;
    aresetn       : in  std_logic;
--    m_axis_tdata  : out std_logic_vector(((g_datawidth rem 8)+g_datawidth)*g_num_channels-1 downto 0);
    m_axis_tdata  : out std_logic_vector(g_nearer_pow2*g_num_channels-1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tlast  : out std_logic);

end entity data_streamer;


architecture behav of data_streamer is
 --constant near : integer :=  integer(ceil(real(14/8)));

  constant zero_padd : std_logic_vector(g_nearer_pow2-g_datawidth-1 downto 0) := (others => '0');
  --constant max_word  : unsigned(g_packet_bytes/(m_axis_tdata'length/8)) := g_packet_bytes/(m_axis_tdata'length/8);
--  constant max_word  : integer := g_packet_bytes/(m_axis_tdata'length/8);
  constant max_word  : integer := 5;
  constant nbits : natural := natural(CEIL(LOG2(real(max_word))));  
  constant id_word   : std_logic_vector(15 downto 0)                    := x"ADC" & std_logic_vector(to_unsigned(g_id_number,4));  -- Dummy word identificating the stream generating the actual data.
  signal gen_data    : unsigned(15 downto 0);
  signal word_count  : unsigned(nbits downto 0);
  signal tdata       : std_logic_vector(m_axis_tdata'length-1 downto 0);
  signal tvalid      : std_logic;
  signal tlast       : std_logic;
begin  -- architecture behav
    m_axis_tdata <= tdata;
    m_axis_tvalid <= tvalid;
    m_axis_tlast <= tlast;

  process (m_axis_clk, aresetn) is
  begin  -- process
    if aresetn = '0' then               -- asynchronous reset (active low)
        tdata <= (others => '0');
        tvalid <= '0';
        tlast      <= '0';
        word_count <= (others => '0');
    elsif m_axis_clk'event and m_axis_clk = '1' then  -- rising clock edge
      tdata  <=                   id_word  & x"0a00" &
                std_logic_vector(gen_data) & x"0b01" &   
                std_logic_vector(gen_data) & x"0c02" &
                std_logic_vector(gen_data) & x"0d03" &
                std_logic_vector(gen_data) & x"0e04" ;
      tvalid <= '1';
      tlast      <= '0';

      if word_count = max_word-2 then
        tlast      <= '1';
      end if;
      
      if word_count = max_word-1 then
        word_count <= (others => '0');
      else
        word_count <= word_count + 1;
      end if;
    end if;
  end process;

  data_generator : process (m_axis_clk, aresetn) is
  begin  -- process data_generator
    if aresetn = '0' then               -- asynchronous reset (active low)
      gen_data <= (others => '0');
    elsif m_axis_clk'event and m_axis_clk = '1' then  -- rising clock edge
      gen_data <= gen_data + 1;
    end if;
  end process data_generator;

end architecture behav;
