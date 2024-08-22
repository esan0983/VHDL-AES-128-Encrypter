----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2024 09:31:08 PM
-- Design Name: 
-- Module Name: mixcolumn - Behavioral
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

entity mixcolumn is
    Port ( clk : in STD_LOGIC;
           rst : in std_logic;
           prev_done : in std_logic;
           column : in unsigned (31 downto 0);
           done : out std_logic;
           data_out : out unsigned (31 downto 0));
end mixcolumn;

architecture Behavioral of mixcolumn is

type vector is array (0 to 15) of unsigned(8 downto 0);
signal int_reg : vector;
type vector2 is array(0 to 15) of unsigned(7 downto 0);
signal int_reg2 : vector2;

type state is (A, B, C, D, E, F, G);
signal pr_state : state;

constant irr : unsigned(8 downto 0) := "100011011";

begin

process(clk, pr_state)
begin
    if rising_edge(clk) then
        if rst = '1' then
            pr_state <= A;
            
            done <= '0';
            data_out <= (others => '0');
            int_reg <= (others => (others => '0'));
            int_reg2 <= (others => (others => '0'));
        else
            case pr_state is
                when A =>
                    done <= '0';
                    int_reg <= (others => (others => '0'));
                    int_reg2 <= (others => (others => '0'));
                    
                    if prev_done = '1' then
                        pr_state <= B;
                    else
                        pr_state <= A;
                    end if;
                when B =>
                    int_reg(0) <= (column(31 downto 24) & '0');
                    int_reg(1) <= (column(23 downto 16) & '0') xor ('0' & column(23 downto 16));
                    int_reg(2) <= '0' & column(15 downto 8);
                    int_reg(3) <= '0' & column(7 downto 0);
                    int_reg(4) <= '0' & column(31 downto 24);
                    int_reg(5) <= (column(23 downto 16) & '0');
                    int_reg(6) <= (column(15 downto 8) & '0') xor ('0' & column(15 downto 8));
                    int_reg(7) <= '0' & column(7 downto 0);
                    int_reg(8) <= '0' & column(31 downto 24);
                    int_reg(9) <= '0' & column(23 downto 16);
                    int_reg(10) <= (column(15 downto 8) & '0');
                    int_reg(11) <= (column(7 downto 0) & '0') xor ('0' & column(7 downto 0));
                    int_reg(12) <= (column(31 downto 24) & '0') xor ('0' & column(31 downto 24));
                    int_reg(13) <= '0' & column(23 downto 16);
                    int_reg(14) <= '0' & column(15 downto 8);
                    int_reg(15) <= (column(7 downto 0) & '0');
                    
                    pr_state <= C;
                when C =>
                    for i in 0 to 15 loop
                        if int_reg(i) >= "100000000" then
                            int_reg(i) <= int_reg(i) xor irr;
                        end if;
                    end loop;
                    
                    pr_state <= D;
                when D =>
                    for i in 0 to 3 loop
                        int_reg2(i) <= (int_reg(4 * i)(7 downto 0) xor int_reg(4 * i + 1)(7 downto 0) xor int_reg(4 * i + 2)(7 downto 0) xor int_reg(4 * i + 3)(7 downto 0));
                    end loop;
                    
                    pr_state <= E;
                when E =>
                    for i in 0 to 3 loop
                        data_out(31 - i * 8 downto 24 - i * 8) <= int_reg2(i);
                    end loop;
                    
                    pr_state <= F;
                when F =>
                    done <= '1';
                    pr_state <= G;
                when G =>
                    if prev_done <= '0' then
                        pr_state <= A;
                    else
                        pr_state <= G;
                    end if;
            end case;
        end if;
    end if;
end process;

end Behavioral;
