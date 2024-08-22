-- sends the 128-bit message to the uart tx module byte by byte

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tx_buffer is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (127 downto 0);
           byte_ready : in std_logic;
           message_ready : in std_logic;
           sent : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0);
           buffer_started : out std_logic);
end tx_buffer;

architecture Behavioral of tx_buffer is

type state is (idle, start_msg, send_byte, byte_sent, wait_byte, wait_state);
signal pr_state : state;

signal byte_counter : unsigned(4 downto 0);
signal msg_signal: std_logic_vector(127 downto 0);


begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= idle;
            data_out <= (others => '0');
            msg_signal <= (others => '0');
            sent <= '0';
            data_out <= (others => '0');
            byte_counter <= (others => '0');
            buffer_started <= '0';
        else
            case pr_state is 
                when idle =>
                    sent <= '0';
                    buffer_started <= '0';
                    
                    if message_ready = '1' then
                        pr_state <= start_msg;
                    else
                        pr_state <= idle;
                    end if;
                when start_msg =>
                    byte_counter <= "10000";
                    msg_signal <= data_in;
                    buffer_started <= '1';
                    
                    pr_state <= send_byte;
                when send_byte =>
                    sent <= '0';
                    data_out <= msg_signal((to_integer(byte_counter) * 8) - 1 downto (to_integer(byte_counter) - 1) * 8);
                    byte_counter <= byte_counter - 1;
                    
                    pr_state <= byte_sent;
                when byte_sent =>
                    sent <= '1';
                    
                    if byte_counter = "00000" then
                        pr_state <= wait_state;
                        buffer_started <= '0';
                    else
                        pr_state <= wait_byte;
                    end if;
                when wait_byte =>
                    if byte_ready = '1' then
                        pr_state <= send_byte;
                    else
                        pr_state <= wait_byte;
                    end if;
                when wait_state =>
                    if message_ready = '1' then
                        pr_state <= wait_state;
                    else
                        pr_state <= idle;
                    end if;
            end case;
        end if;
    end if;
end process;

end Behavioral;
