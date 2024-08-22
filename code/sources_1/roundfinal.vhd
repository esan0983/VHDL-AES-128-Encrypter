library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity roundfinal is
        Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           round_start : in std_logic;
           data_in : in unsigned (127 downto 0);
           key : in unsigned (127 downto 0);
           rc : in unsigned(7 downto 0);
           round_done : out std_logic;
           data_out : out unsigned (127 downto 0));
end roundfinal;

architecture Behavioral of roundfinal is
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
    
    signal data_reg0, data_reg1, key_reg : unsigned(127 downto 0);
    
    type state is (A, B, C, D);
    signal pr_state : state;
    
    signal done_r1 : std_logic;
    signal done_r2 : std_logic_vector(3 downto 0);
begin

done_r2(2 downto 0) <= "111";

box : sbox
port map (
    clk => clk,
    prev_done => round_start,
    data_in => data_in,
    done => done_r1,
    data_out => data_reg0);
    
shift : shiftrows
port map (
    clk => clk,
    rst => rst,
    prev_done => done_r1,
    data_in => data_reg0,
    done => done_r2(3),
    data_out => data_reg1);
        
round : roundkey
port map (
    clk => clk,
    rst => rst,
    prev_done => done_r2,
    rc => rc,
    data_in => data_reg1,
    key => key,
    done => round_done,
    data_out => data_out,
    newkey => key_reg);

end Behavioral;
