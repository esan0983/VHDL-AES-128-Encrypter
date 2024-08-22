-- this serves as a buffer for the rx side
-- ones the rx module transfers a byte, one byte in the buf signal gets filled and moves on to the next byte
-- when the entire byte is filled and the user hasn't pressed enter yet, the byte filling wraps around
-- when the user presses enter, the first half of the buf signal becomes the text to be encrypted, the second half being the key

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rx_buffer is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_enter : in std_logic;
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           ready : out STD_LOGIC;
           data_out : out unsigned (127 downto 0);
           key : out unsigned (127 downto 0));
end rx_buffer;

architecture Behavioral of rx_buffer is

signal count : unsigned(4 downto 0);
signal buf : unsigned(255 downto 0);

type state is (reset, idle, fill, wait_fill, send, pause);
signal pr_state : state;

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= reset;
            data_out <= (others => '0');
            key <= (others => '0');
            count <= (others => '1');
            buf <= (others => '0');
            ready <= '0';
        else
            case pr_state is
                when reset =>
                    ready <= '0';
                    count <= (others => '1');
                    buf <= (others => '0');
                    pr_state <= idle;
                when idle =>
                    if data_enter = '1' then
                        if data_in /= "00001101" then
                            buf(8 * to_integer(count) + 7 downto 8 * to_integer(count)) <= unsigned(data_in);
                            count <= to_unsigned((to_integer(count) - 1 + 32) mod 32, count'length);
                            pr_state <= wait_fill;
                        else
                            pr_state <= send;
                        end if;
                    else
                        pr_state <= idle;
                    end if;
                when fill =>
                    if data_enter = '1' then
                        if data_in /= "00001101" then
                            buf(8 * to_integer(count) + 7 downto 8 * to_integer(count)) <= unsigned(data_in);
                            count <= to_unsigned((to_integer(count) - 1 + 32) mod 32, count'length);
                            pr_state <= wait_fill;
                        else
                            pr_state <= send;
                        end if;
                    else
                        pr_state <= fill;
                    end if;
                when wait_fill =>
                    if data_enter = '0' then
                        pr_state <= fill;
                    else
                        pr_state <= wait_fill;
                    end if;
                when send =>
                    data_out <= buf(255 downto 128) xor buf(127 downto 0);
                    key <= buf(127 downto 0);
                    ready <= '1';
                    pr_state <= pause;
                when pause =>
                    if data_enter = '0' then
                        pr_state <= reset;
                    else
                        pr_state <= pause;
                    end if;
            end case;
        end if;
    end if;
end process;

end Behavioral;
