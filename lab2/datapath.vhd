library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    port(
     p1, p2, p3, p4 : in std_logic_vector(7 downto 0); -- data
     w1, w2, w3, w4 : in std_logic_vector(7 downto 0); -- data
     clk, rst : in std_logic;
     e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12 : in std_logic; -- enables
     s1, s2, s3, s4, s5 : in std_logic; -- selectors
     res : out std_logic_vector(16 downto 0) -- result
    );
end datapath;

architecture Behavioral of datapath is
    signal r1, r2 : std_logic_vector(15 downto 0); -- size: 8+8
    signal r1_sg, r2_sg : signed(15 downto 0);
    signal r3, r4  : std_logic_vector(16 downto 0); -- size: 16+1
    signal r3_sg : signed(16 downto 0);
    
    signal rp1, rp2, rp3, rp4 : std_logic_vector(7 downto 0);
    signal rw1, rw2, rw3, rw4 : std_logic_vector(7 downto 0);
    signal w1_2c, w2_2c, w3_2c, w4_2c : std_logic_vector(7 downto 0); -- 2's complement
    
    signal mul1, mul2 : std_logic_vector(15 downto 0); -- size: 8+8
    signal mul1_sg, mul2_sg : signed(15 downto 0);
    signal add1, add2 : std_logic_vector(16 downto 0); -- size: 16+1
    signal add1_sg, add2_sg : signed(16 downto 0);
    
    signal mux1, mux2, mux3, mux4 : std_logic_vector(7 downto 0);
    signal mux1_sg, mux2_sg, mux3_sg, mux4_sg : signed(7 downto 0);
    signal mux5 : std_logic_vector(16 downto 0);
    signal mux5_sg : signed(16 downto 0);
    
begin
    -- signed data
    r1_sg <= signed(r1);
    r2_sg <= signed(r2);
    r3_sg <= signed(r3);
    
    -- sign-magnitude to 2's complement: A'=not(A)+1
    w1_2c <= '1' & std_logic_vector(not(unsigned(w1(w1'high-1 downto 0))) + 1) when (w1(w1'high) = '1') else
             w1;
    w2_2c <= '1' & std_logic_vector(not(unsigned(w2(w2'high-1 downto 0))) + 1) when (w2(w2'high) = '1') else
             w2;
    w3_2c <= '1' & std_logic_vector(not(unsigned(w3(w3'high-1 downto 0))) + 1) when (w3(w3'high) = '1') else
             w3;
    w4_2c <= '1' & std_logic_vector(not(unsigned(w4(w4'high-1 downto 0))) + 1) when (w4(w4'high) = '1') else
             w4;    
                
    -- multiplier 1
    mul1_sg <= mux1_sg * mux2_sg;
    mul1 <= std_logic_vector(mul1_sg);
    
    -- multiplier 2
    mul2_sg <= mux3_sg * mux4_sg;
    mul2 <= std_logic_vector(mul2_sg);
    
    -- adder 1
    add1_sg <= r1_sg + mux5_sg;
    add1 <= std_logic_vector(add1_sg);
    
    -- adder 2
    add2_sg <= r2_sg + add1_sg;
    add2 <= std_logic_vector(add2_sg);
    
    -- mux 1
    mux1_sg <= signed(mux1);
    mux1 <= rp3 when (s1 = '0') else
            rp2;
     
    -- mux 2
    mux2_sg <= signed(mux2);
    mux2 <= rw3 when (s2 = '0') else
            rw2;
    
    -- mux 3
    mux3_sg <= signed(mux3);
    mux3 <= rp4 when (s3 = '0') else
            rp1;
    
    -- mux 4
    mux4_sg <= signed(mux4);
    mux4 <= rw4 when (s4 = '0') else
            rw1;
     
    -- mux 5
    mux5_sg <= signed(mux5);
    mux5 <= '0' & r2 when (s5 = '0') else -- padding
            r3;
            
    -- register 1
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                r1 <= (others => '0');
            elsif e1 = '1' then
                r1 <= mul1;
            end if;
        end if;
    end process;
     
    -- register 2
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                r2 <= (others => '0');
            elsif e2 = '1' then
                r2 <= mul2;
            end if;
        end if;
    end process;
     
    -- register 3
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                r3 <= (others => '0');
            elsif e3 = '1' then
                r3 <= add1;
            end if;
         end if;
    end process;
    
    -- register 4
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                r4 <= (others => '0');
            elsif e4 = '1' then
                r4 <= add2;
            end if;
         end if;
    end process;
     
    -- register p1
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rp1 <= (others => '0');
            elsif e5 = '1' then
                rp1 <= p1;
            end if;
        end if;
    end process;
     
    -- register p2
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rp2 <= (others => '0');
            elsif e6 = '1' then
                rp2 <= p2;
            end if;
        end if;
    end process;
     
    -- register p3
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rp3 <= (others => '0');
            elsif e7 = '1' then
                rp3 <= p3;
            end if;
        end if;
    end process;
     
    -- register p4
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rp4 <= (others => '0');
            elsif e8 = '1' then
                rp4 <= p4;
            end if;
        end if;
    end process;
     
    -- register w1
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rw1 <= (others => '0');
            elsif e9 = '1' then
                rw1 <= w1_2c;
            end if;
        end if;
    end process;
     
    -- register w2
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rw2 <= (others => '0');
            elsif e10 = '1' then
                rw2 <= w2_2c;
            end if;
        end if;
    end process;
     
    -- register w3
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rw3 <= (others => '0');
            elsif e11 = '1' then
                rw3 <= w3_2c;
            end if;
        end if;
    end process;
     
    -- register w4
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rw4 <= (others => '0');
            elsif e12 = '1' then
                rw4 <= w4_2c;
            end if;
        end if;
    end process;
     
    -- output
    res <= r4;

end Behavioral;