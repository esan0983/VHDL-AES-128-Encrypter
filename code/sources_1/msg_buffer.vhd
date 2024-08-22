-- used as an intermediate between the tx side and the encryption side since both work at different clocks

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity msg_buffer is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           msg : in STD_LOGIC;
           buf_started : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (127 downto 0);
           data_out : out STD_LOGIC_VECTOR (127 downto 0);
           buf_activate : out STD_LOGIC);
end msg_buffer;

architecture Behavioral of msg_buffer is

type state is (A, B, C, D);
signal pr_state : state;

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= A;
            data_out <= (others => '0');
            buf_activate <= '0';
        else
            case pr_state is
                when A =>
                    if msg = '1' then
                        data_out <= data_in;
                        pr_state <= B;
                    else
                        pr_state <= A;
                    end if;
                when B =>
                    buf_activate <= '1';
                    pr_state <= C;
                when C =>
                    if buf_started <= '1' then
                        buf_activate <= '1';
                        pr_state <= D;
                    else
                        pr_state <= C;
                    end if;
                when D =>
                    if msg = '0' then
                        pr_state <= A;
                    else
                        pr_state <= D;
                    end if;
            end case;
        end if;
    end if;
end process;
end Behavioral;
