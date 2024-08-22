library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity encryption_tb is

end encryption_tb;

architecture Behavioral of encryption_tb is

    component encryption
    Port ( data_in : in unsigned(127 downto 0);
           key : in unsigned(127 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           round_start : in std_logic;
           data_out : out unsigned(127 downto 0));
    end component;
    
    signal clk, rst, round_start: std_logic;
    signal data_in, key : unsigned(127 downto 0);
    
    signal data_out : unsigned(127 downto 0);
begin

uut : encryption
port map (
    data_in => data_in,
    key => key,
    clk => clk,
    rst => rst,
    round_start => round_start,
    data_out => data_out);
    
clk_proc : process
begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
end process;

stim_proc : process
begin
    wait for 10 ns;
    
    rst <= '1';
    round_start <= '0';
    data_in <= x"00112233445566778899aabbccddeeff";
    key <= x"000102030405060708090a0b0c0d0e0f";
    
    wait for 100 ns;
    
    rst <= '0';
    round_start <= '1';
    -- ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a
    
    wait for 2000 ns;
    
    round_start <= '0';
    data_in <= x"89d810e8855ace682d1843d8cb128fe4";
    key <= x"2b7e151628aed2a6abf7158809cf4f3c";
    
    wait for 100 ns;
    
    round_start <= '1';
    -- ciphertext: 4045bf1ffafec86f10d998c50da439dd
    
    wait for 2000 ns;
    
    round_start <= '0';
    data_in <= x"6bc1bee22e409f96e93d7e117393172a";
    key <= x"2b7e151628aed2a6abf7158809cf4f3c";
    
    wait for 100 ns;
    
    round_start <= '1';
    -- ciphertext; 3ad77bb40d7a3660a89ecaf32466ef97
    
    wait for 2000 ns;
    
    round_start <= '0';
    data_in <= x"ae2d8a571e03ac9c9eb76fac45af8e51";
    key <= x"2b7e151628aed2a6abf7158809cf4f3c";
    
    wait for 2000 ns;
    
    round_start <= '1';
    -- ciphertext: f5d3d58503b9699de785895a96fdbaaf
    
    wait for 2000 ns;
    
    round_start <= '0';
    data_in <= x"30c81c46a35ce411e5fbc1191a0a52ef";
    key <= x"2b7e151628aed2a6abf7158809cf4f3c";
    
    wait for 100 ns;
    
    round_start <= '1';
    -- ciphertext: 43b1cd7f598ece23881b00e3ed030688
    
    wait for 2000 ns;
    
    round_start <= '0';
    
    wait for 2000 ns;
end process;

end Behavioral;
