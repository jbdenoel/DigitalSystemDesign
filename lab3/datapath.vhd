library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
  port (
    clk, rst : in std_logic;
    image_num : in std_logic_vector(6 downto 0); -- 0 to 119
    w1_en : in std_logic;
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

  -- ADDRESSES
  signal image_curr : std_logic_vector(11 downto 0); -- 3840 depth
  signal image_addr : std_logic_vector(11 downto 0); -- initial address
  signal image_offs : std_logic_vector(4 downto 0) := (others => '0'); -- 32 rows
  
  signal w1_addr : std_logic_vector(12 downto 0) := (others => '0'); -- 8192 depth
  signal w2_addr : std_logic_vector(7 downto 0) := (others => '0'); -- 80 depth
  
  -- MEMORY DATA
  signal im_row, w2_4 : std_logic_vector(31 downto 0);
  signal w1_4 : std_logic_vector(15 downto 0);
  
  -- OTHERS
  signal pixel : std_logic_vector(3 downto 0);
  signal sel_pixel : std_logic_vector(2 downto 0);
  
  signal mul1, mul2, mul3, mul4 : std_logic_vector(3 downto 0);
  signal add1, add2 : signed(4 downto 0); -- TODO: check
  signal add3 : signed(5 downto 0); -- TODO: check

begin

  -- image memory address generator
  image_addr <= std_logic_vector(32 * unsigned(image_num)); -- initial address
  image_curr <= std_logic_vector(unsigned(image_addr) + unsigned(image_offs)); -- current address
  
  -- w1 rows counter
  process(clk)
  begin
    -- check reset
    if rst = '1' then
      w1_addr <= (others => '0');
    -- otherwise check clock
    elsif rising_edge(clk) then
      -- check enable
      if w1_en = '1' then
        -- check max value (8191)
        if w1_addr = "1111111111111" then
          -- inform control unit
          lay1_done <= '1';
          -- reset address
          w1_addr <= (others => '0');
        -- otherwise
        else
          lay1_done <= '0';
          -- increment address
          w1_addr <= std_logic_vector(unsigned(w1_addr) + 1);
        end if;
      end if;
    end if;
    sel_pixel <= w1_addr(2 downto 0);
    image_offs <= w1_addr(7 downto 3);
  end process;
  
  -- pixels mux
  pixel <= im_row(31 downto 28) when (sel_pixel = "000") else -- [p1, p2, p3, p4]
           im_row(27 downto 24) when (sel_pixel = "001") else
           im_row(23 downto 20) when (sel_pixel = "010") else
           im_row(19 downto 16) when (sel_pixel = "011") else
           im_row(15 downto 12) when (sel_pixel = "100") else
           im_row(11 downto 8) when (sel_pixel = "101") else
           im_row(7 downto 4) when (sel_pixel = "110") else
           im_row(3 downto 0);    
  
  -- layer1
  mul1 <= w1_4(15 downto 12) when pixel(3) = '0' else "0000"; -- w1 * p1
  mul2 <= w1_4(11 downto 8) when pixel(2) = '0' else "0000"; -- w2 * p2
  mul3 <= w1_4(7 downto 4) when pixel(1) = '0' else "0000"; -- w3 * p3
  mul4 <= w1_4(3 downto 0) when pixel(0) = '0' else "0000"; -- w4 * p4
  -- TODO: check
  add1 <= signed(mul1) + signed(mul2);
  add2 <= signed(mul3) + signed(mul4); 
  add3 <= add1 + add2;
  
  -- layer2

instance_images : images_mem
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => image_curr,
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