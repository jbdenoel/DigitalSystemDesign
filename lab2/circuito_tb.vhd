library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity circuito_tb is
end circuito_tb;

architecture Behavioral of circuito_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component circuito
    port(
    clk, rst: in std_logic;
    p1, p2, p3, p4 : in std_logic_vector(7 downto 0);
    w1, w2, w3, w4 : in std_logic_vector(7 downto 0);
    done : out std_logic;
    res : out std_logic_vector(16 downto 0)
    );
    end component;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal p1 : std_logic_vector(7 downto 0) := "00000001"; -- 1
   signal p2 : std_logic_vector(7 downto 0) := "00000010"; -- 2
   signal p3 : std_logic_vector(7 downto 0) := "00000011"; -- 3
   signal p4 : std_logic_vector(7 downto 0) := "00000111"; -- 7
   signal w1 : std_logic_vector(7 downto 0) := "00010001"; -- 17
   signal w2 : std_logic_vector(7 downto 0) := "01000111"; -- 71
   signal w3 : std_logic_vector(7 downto 0) := "00011111"; -- 31
   signal w4 : std_logic_vector(7 downto 0) := "00011111"; -- 31

 	--Outputs
   signal done : std_logic;
   signal res : std_logic_vector(16 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: circuito port map (
          clk => clk,
          rst => rst,
          p1 => p1,
          p2 => p2,
          p3 => p3,
          p4 => p4,
          w1 => w1,
          w2 => w2,
          w3 => w3,
          w4 => w4,
          done => done,
          res => res
        );

   -- Clock definition
   clk <= not clk after clk_period/2;

    -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      --wait for 100 ns;	
      --wait for clk_period*10;
      -- insert stimulus here 
      -- note that input signals should never change at the positive edge of the clock
	  rst <= '1',
			 '0' after 20 ns;
      wait;
   end process;
end Behavioral;