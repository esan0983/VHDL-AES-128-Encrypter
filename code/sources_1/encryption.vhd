----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2024 12:27:13 PM
-- Design Name: 
-- Module Name: encryption - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encryption is
    Port ( data_in : in unsigned(127 downto 0);
           key : in unsigned(127 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           round_start : in std_logic;
           data_out : out unsigned(127 downto 0));
end encryption;

architecture Behavioral of encryption is

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

signal start_r : std_logic_vector(10 downto 0);

type vector is array (0 to 9) of unsigned(7 downto 0);
constant rc : vector := ("00000001", "00000010", "00000100", "00001000", "00010000", "00100000", "01000000", "10000000", "00011011", "00110110");
    
type vector2 is array (0 to 10) of unsigned(127 downto 0);
signal ciphers : vector2;
signal keys : vector2;

begin

start_r(0) <= round_start;

ciphers(0) <= data_in xor key;
keys(0) <= key;

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
        data_out => data_out);
        

end Behavioral;
