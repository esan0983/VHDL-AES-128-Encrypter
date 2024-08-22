library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port ( rst : in std_logic;
           clk : in std_logic;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           sent : in STD_LOGIC;
           ready : out std_logic;
           data_out : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is

type state is (idle, add_bit, wait_state);
signal pr_state : state;
signal count : integer range 0 to 8;

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= idle;
            data_out <= '0';
            count <= 0;
            ready <= '0';
        else
            case pr_state is
                when idle =>
                    ready <= '0';
                    count <= 0;
                    if sent = '1' then
                        data_out <= '0';
                        pr_state <= add_bit;
                    else
                        pr_state <= idle;
                    end if;
                when add_bit =>
                    if count = 8 then
                        data_out <= '1';
                        pr_state <= wait_state;
                    else
                        data_out <= data_in(count);
                        count <= count + 1;
                        pr_state <= add_bit;
                    end if;
                when wait_state =>
                    if sent = '1' then
                        pr_state <= wait_state;
                        ready <= '1';
                    else
                        pr_state <= idle;
                        ready <= '0';
                    end if;
            end case;
        end if;
    end if;
end process;
end Behavioral;
