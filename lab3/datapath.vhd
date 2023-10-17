library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
  port (
    clk, rst : in std_logic;
    image_num : in std_logic_vector(6 downto 0);
    en_ima : in std_logic;
    lay1_done, lay2_done : out std_logic
    );
end datapath;

architecture Behavioral of datapath is
COMPONENT images_mem
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT weights1
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT weights2
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

  type image_mem is array(3839 downto 0) of std_logic_vector(31 downto 0);
  type w1_mem is array(8191 downto 0) of std_logic_vector(15 downto 0);
  type w2_mem is array(79 downto 0) of std_logic_vector(31 downto 0);
  signal image_RAM : image_mem;
  --shared variable image_RAM : image_mem;
  signal w1_RAM : w1_mem;
  signal w2_RAM : w2_mem;
  signal image_addr : std_logic_vector(11 downto 0); -- 3840 depth
  signal w1_addr : std_logic_vector(12 downto 0); -- 8192 depth
  signal w2_addr : std_logic_vector(7 downto 0); -- 80 depth
  signal im_row, w2_4 : std_logic_vector(31 downto 0);
  signal w1_4 : std_logic_vector(15 downto 0);

begin

  -- image memory address generator
  image_addr <= std_logic_vector(32 * unsigned(image_num));
  
  -- image memory reading
  process(clk)
  begin
   if rising_edge(clk) then
   -- rst is needed?
    if rst = '1' then
      im_row <= (others => '0');
    elsif en_ima = '1' then
      im_row <= std_logic_vector(image_RAM(to_integer(unsigned(image_addr))));
    end if;
   end if;
  end process;
  
  -- weights1 memory reading
  process(clk)
  begin
   if rising_edge(clk) then
   -- rst is needed?
    if rst = '1' then
      im_row <= (others => '0');
    elsif en_ima = '1' then
      w1_4 <= std_logic_vector(w1_RAM(to_integer(unsigned(w1_addr))));
    end if;
   end if;
  end process;
  
  -- weigths2 memory reading
  process(clk)
  begin
   if rising_edge(clk) then
   -- rst is needed?
    if rst = '1' then
      im_row <= (others => '0');
    elsif en_ima = '1' then
      w2_4 <= std_logic_vector(w2_RAM(to_integer(unsigned(w2_addr))));
    end if;
   end if;
  end process;

instance_images : images_mem
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => image_addr,
    dina => (others => '0'),  
    douta => im_row,
    clkb => clk,
    web => "0",
    addrb => (others => '0'),  
    dinb => (others => '0'),
    doutb => open              -- port B not used
  );

instance_weights1 : weights1
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => w1_addr,
    dina => (others => '0'),
    douta => w1_4,
    clkb => clk,
    web => "0",
    addrb => (others => '0'),
    dinb => (others => '0'),
    doutb => open               -- port B not used
  );
  
  instance_weights2 : weights2
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => w2_addr,
    dina => (others => '0'),
    douta => w2_4,
    clkb => clk,
    web => "0",
    addrb => (others => '0'),
    dinb => (others => '0'),
    doutb => open               -- port B not used
  );    
   
end Behavioral;