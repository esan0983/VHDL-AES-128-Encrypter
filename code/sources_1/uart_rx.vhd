library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port ( rx : in STD_LOGIC;
           rst : in std_logic;
           clk : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0);
           done : out STD_LOGIC);
end uart_rx;

architecture Behavioral of uart_rx is

type state is (idle, start, trans, stop);
signal pr_state : state;
signal count : unsigned(3 downto 0);
signal msg_r : std_logic_vector(7 downto 0);

signal bit_count : unsigned(2 downto 0);

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= idle;
            done <= '0';
            msg_r <= (others => '0');
            data_out <= (others => '0');
            count <= "0000";
            bit_count <= (others => '0');
        else
            case pr_state is
                when idle =>
                    done <= '0';
                    if rx = '1' then
                        pr_state <= idle;
                    else
                        pr_state <= start;
                    end if;
                when start =>
                    if bit_count = "100" then
                        count <= "0000";
                        pr_state <= trans;
                    else
                        bit_count <= bit_count + 1;
                    end if;
                when trans =>
                    if bit_count = "111" then
                        msg_r(to_integer(count)) <= rx;
                        if count = 7 then
                            pr_state <= stop;
                        else
                            count <= count + 1;
                            pr_state <= trans;
                        end if;
                        bit_count <= (others => '0');
                    else
                        bit_count <= bit_count + 1;
                    end if;
                when stop =>
                    if bit_count = "111" then
                        data_out <= msg_r;
                        done <= '1';
                        pr_state <= idle;
                    else
                        bit_count <= bit_count + 1;
                    end if;
            end case;
        end if;
    end if;
end process;

end Behavioral;
