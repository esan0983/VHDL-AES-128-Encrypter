library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_v1 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx : in STD_LOGIC;
           tx : out STD_LOGIC;
           locked : out STD_LOGIC;
           locked_tx : out std_logic);
end top_v1;

architecture Behavioral of top_v1 is

component uart_rx
    Port ( rx : in STD_LOGIC;
           rst : in std_logic;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0);
           done : out STD_LOGIC);
end component;

component rx_buffer
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_enter : in std_logic;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           ready : out STD_LOGIC;
           data_out : out unsigned (127 downto 0);
           key : out unsigned (127 downto 0));
end component;

component round
    Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           round_ready : in std_logic;
           data_in : in unsigned (127 downto 0);
           key : in unsigned (127 downto 0);
           rc : in unsigned(7 downto 0);
           round_done : out std_logic;
           data_out : out unsigned (127 downto 0);
           newkey : out unsigned(127 downto 0));
end component;

component roundfinal
        Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           round_start : in std_logic;
           data_in : in unsigned (127 downto 0);
           key : in unsigned (127 downto 0);
           rc : in unsigned(7 downto 0);
           round_done : out std_logic;
           data_out : out unsigned (127 downto 0));
end component;

component msg_buffer
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           msg : in STD_LOGIC;
           buf_started : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (127 downto 0);
           data_out : out STD_LOGIC_VECTOR (127 downto 0);
           buf_activate : out STD_LOGIC);
end component;

component tx_buffer
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (127 downto 0);
           byte_ready : in std_logic;
           message_ready : in std_logic;
           sent : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0);
           buffer_started : out std_logic);
end component;

component uart_tx
    Port ( rst : in std_logic;
           clk : in std_logic;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           sent : in STD_LOGIC;
           ready : out std_logic;
           data_out : out STD_LOGIC);
end component;

component uart_clk
    Port ( clk_out : out std_logic;
        reset : in std_logic;
        locked : out std_logic;
        clk : in std_logic);
end component;

component tx_clk
    Port ( clk_out : out std_logic;
        reset : in std_logic;
        locked : out std_logic;
        clk : in std_logic);
end component;

component enable_generator
    Port ( clk : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end component;

signal clk_r1, clk_r2, clk_r1_tx, clk_r2_tx: std_logic;   
signal rx_r : std_logic_vector(7 downto 0);  
signal data_enter_r : std_logic;

signal start_r : std_logic_vector(10 downto 0);

type vector is array (0 to 9) of unsigned(7 downto 0);
constant rc : vector := ("00000001", "00000010", "00000100", "00001000", "00010000", "00100000", "01000000", "10000000", "00011011", "00110110");
    
type vector2 is array (0 to 10) of unsigned(127 downto 0);
signal ciphers : vector2;
signal keys : vector2;

signal buf_started_r : std_logic;
signal buf_cipher : std_logic_vector(127 downto 0);
signal buf_activate_r : std_logic;
signal byte_ready_r : std_logic;
signal sent_r : std_logic;
signal tx_msg : std_logic_vector(7 downto 0);

begin

new_clk : uart_clk
port map (
    clk_out => clk_r1,
    reset => rst,
    locked => locked,
    clk => clk);
    
new_tx_clk : tx_clk
port map (
    clk_out => clk_r1_tx,
    reset => rst,
    locked => locked_tx,
    clk => clk);
    
en_gen : enable_generator
port map (
    clk => clk_r1,
    clk_out => clk_r2);
    
en_gen_tx : enable_generator
port map (
    clk => clk_r1_tx,
    clk_out => clk_r2_tx);
    
trans_rx : uart_rx
port map (
    rx => rx,
    rst => rst,
    clk => clk_r2, -- r1 for behavioral simulation, r2 otherwise
    data_out => rx_r,
    done => data_enter_r);
    
rx_buf : rx_buffer
port map (
    clk => clk_r2, -- r1 for behavioral simulation, r2 otherwise
    rst => rst,
    data_enter => data_enter_r,
    data_in => rx_r,
    ready => start_r(0),
    data_out => ciphers(0),
    key => keys(0));
    
prelims : for i in 0 to 8 generate
    uut : round
        port map (
            clk => clk,
            rst => rst,
            round_ready => start_r(i),
            data_in => ciphers(i),
            key => keys(i),
            rc => rc(i),
            round_done => start_r(i + 1),
            data_out => ciphers(i + 1),
            newkey => keys(i + 1));
end generate;

final : roundfinal
    port map (
        clk => clk,
        rst => rst,
        round_start => start_r(9),
        data_in => ciphers(9),
        key => keys(9),
        rc => rc(9),
        round_done => start_r(10),
        data_out => ciphers(10));

int : msg_buffer
    port map (
        clk => clk,
        rst => rst,
        msg => start_r(10),
        buf_started => buf_started_r,
        data_in => std_logic_vector(ciphers(10)),
        data_out => buf_cipher,
        buf_activate => buf_activate_r);
        
buf : tx_buffer
    port map (
        clk => clk_r2_tx, -- r1 for behavioral simulation, r2 otherwise
        rst => rst,
        data_in => buf_cipher,
        byte_ready => byte_ready_r,
        message_ready => buf_activate_r,
        sent => sent_r,
        data_out => tx_msg,
        buffer_started => buf_started_r);
        
trans: uart_tx
    port map (
        rst => rst,
        clk => clk_r2_tx, -- r1 for behavioral simulation, r2 otherwise
        data_in => tx_msg,
        sent => sent_r,
        ready => byte_ready_r,
        data_out => tx);
            
end Behavioral;
