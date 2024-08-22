-- this divides the clock frequency by 1000

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity enable_generator is
    Port ( clk : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end enable_generator;

architecture Behavioral of enable_generator is

signal count : unsigned(8 downto 0) := (others => '0');
signal clk_reg : std_logic := '0';

begin

process(clk)
begin
    if rising_edge(clk) then
        if count = "111110100" then
            count <= (others => '0');
            clk_reg <= not clk_reg;
        else
            count <= count + 1;
        end if;
    end if;
end process;

clk_out <= clk_reg;

end Behavioral;
