library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity round is
    Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           round_ready : in std_logic;
           data_in : in unsigned (127 downto 0);
           key : in unsigned (127 downto 0);
           rc : in unsigned(7 downto 0);
           round_done : out std_logic;
           data_out : out unsigned (127 downto 0);
           newkey : out unsigned(127 downto 0));
end round;

architecture Behavioral of round is
    component sbox
        Port ( clk : in STD_LOGIC;
               prev_done : in std_logic;
               data_in : in unsigned (127 downto 0);
               done : out std_logic;
               data_out : out unsigned (127 downto 0));
    end component;
    
    component shiftrows
        Port ( clk : in STD_LOGIC;
               rst : in std_logic;
               prev_done : in std_logic;
               data_in : in unsigned (127 downto 0);
               done : out std_logic;
               data_out : out unsigned (127 downto 0));
    end component;
    
    component mixcolumn
        Port ( clk : in STD_LOGIC;
               rst : in std_logic;
               prev_done : in std_logic;
               column : in unsigned (31 downto 0);
               done : out std_logic;
               data_out : out unsigned (31 downto 0));
    end component;
    
    component roundkey
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               prev_done : in std_logic_vector(3 downto 0);
               rc : in unsigned(7 downto 0);
               data_in : in unsigned(127 downto 0);
               key : in unsigned (127 downto 0);
               done : out std_logic;
               data_out : out unsigned(127 downto 0);
               newkey : out unsigned(127 downto 0));
    end component;
    
    signal data_reg0, data_reg1, data_reg2 : unsigned(127 downto 0);
    signal done_r1, done_r2 : std_logic;
    signal done_r3 : std_logic_vector(3 downto 0);
begin

box : sbox
port map (
    clk => clk,
    prev_done => round_ready,
    data_in => data_in,
    done => done_r1,
    data_out => data_reg0);
    
shift : shiftrows
port map (
    clk => clk,
    rst => rst,
    prev_done => done_r1,
    data_in => data_reg0,
    done => done_r2,
    data_out => data_reg1);

mix : for i in 0 to 3 generate
    uut : mixcolumn
    port map (
        clk => clk,
        rst => rst,
        prev_done => done_r2,
        column => data_reg1(31 + 32 * i downto 32 * i),
        done => done_r3(i),
        data_out => data_reg2(31 + 32 * i downto 32 * i));
end generate;
        
round : roundkey
port map (
    clk => clk,
    rst => rst,
    prev_done => done_r3,
    rc => rc,
    data_in => data_reg2,
    key => key,
    done => round_done,
    data_out => data_out,
    newkey => newkey);
    

-- data_out <= key_reg xor data_reg2
        
end Behavioral;
