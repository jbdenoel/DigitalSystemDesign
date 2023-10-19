
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity control is
 port(
    clk, rst : in std_logic;
    layer1_done, layer2_done : in std_logic;
    w_enables : out std_logic_vector(1 downto 0)
    --w1_en, w2_en : out std_logic);
    );
end control;

architecture Behavioral of control is 
    type fsm_states is (init, layer1, layer2, finish);
    signal currstate, nextstate: fsm_states;

begin

process(clk)
  begin
    if rising_edge(clk) then
        if rst = '1' then
            currstate <= init;
        else
            currstate <= nextstate;
        end if;
    end if;
  end process;
  
  process(currstate, rst)
  begin
  
    nextstate <= currstate;
    case currstate is 
        when init => 
            if (rst = '0') then 
                nextstate <= layer1;
                w_enables <= "00";
            end if;
            
        when layer1 =>
            w_enables <= "01";
            if layer1_done = '1' then
                nextstate <= layer2;
            end if;
            
        when layer2 =>
            w_enables <= "10";
            if layer2_done = '1' then
                nextstate <= finish;
            end if;
        when finish =>
            w_enables <= "11";
            
      end case;
    end process;
            
 

end Behavioral;
