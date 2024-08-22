-- shifts the rows of the byte array

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shiftrows is
    Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           prev_done : in std_logic;
           data_in : in unsigned (127 downto 0);
           done : out std_logic;
           data_out : out unsigned (127 downto 0));
end shiftrows;

architecture Behavioral of shiftrows is

type state is (A, B, C, D);
signal pr_state : state;

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= A;
            data_out <= (others => '0');
            done <= '0';
        else
            case pr_state is
                when A =>
                    done <= '0';
                    if prev_done = '1' then
                        pr_state <= B;
                    else
                        pr_state <= A;
                    end if;
                when B =>
                    for i in 0 to 3 loop
                        data_out((127 - 32 * i) downto 120 - 32 * i) <= data_in((127 - 32 * i) downto (120 - 32 * i));
                        data_out(((23 + 32 * i) mod 128) downto ((16 + 32 * i) mod 128)) <= data_in(((23 + 32 * i + 96) mod 128) downto ((16 + 32 * i + 96) mod 128));
                        data_out(((15 + 32 * i) mod 128) downto ((8 + 32 * i) mod 128)) <= data_in(((15 + 32 * i + 64) mod 128) downto ((8 + 32 * i + 64) mod 128));
                        data_out(((7 + 32 * i) mod 128) downto ((32 * i) mod 128)) <= data_in(((7 + 32 * i + 32) mod 128) downto ((32 * i + 32) mod 128));
                    end loop;
                    
                    pr_state <= C;
                when C  =>
                    done <= '1';
                    pr_state <= D;
                when D =>
                    if prev_done <= '0' then
                        pr_state <= A;
                    else
                        pr_state <= D;
                    end if;
            end case;
        end if;
    end if;
end process;

end Behavioral;
