-- generates the new round key and XORs it with the text

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity roundkey is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           prev_done : in std_logic_vector(3 downto 0);
           rc : in unsigned(7 downto 0);
           data_in : in unsigned(127 downto 0);
           key : in unsigned (127 downto 0);
           done : out std_logic;
           data_out : out unsigned(127 downto 0);
           newkey : out unsigned(127 downto 0));
end roundkey;

architecture Behavioral of roundkey is

    type state is (A, B, C, D, E, F, G, H, I, J, K, L);
    signal pr_state, nx_state : state;
    
    type vector is array (0 to 3) of unsigned(31 downto 0);
    signal word_in, word_in2, word_in3, word_in4, word_out : vector; -- fix this, the first three elements of the array for word_in2, 3, and 4 are unused

    subtype ByteInt is integer range 0 to 255;
    type ByteArray is array (0 to 255) of ByteInt;

    constant SBOX : ByteArray := (
    99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118,
    202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192,
    183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21,
    4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117,
    9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132,
    83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207,
    208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168,
    81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210,
    205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115,
    96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219,
    224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121,
    231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8,
    186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138,
    112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158,
    225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223,
    140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22);
    
    signal newkey_r : unsigned(127 downto 0);

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            done <= '0';
            pr_state <= A;
            data_out <= (others => '0');
            newkey_r <= (others => '0');
            newkey <= (others => '0');
            
            for i in 0 to 3 loop
                word_in(i) <= (others => '0');
                word_in2(i) <= (others => '0');
                word_in3(i) <= (others => '0');
                word_in4(i) <= (others => '0');
                word_out(i) <= (others => '0');
            end loop;
        else
            case pr_state is
                when A =>
                    done <= '0';
                
                    for i in 0 to 3 loop
                        word_in(i) <= key(127 - i * 32 downto 96 - i *32);
                    end loop;

                    for i in 0 to 3 loop
                        word_in2(i) <= (others => '0');
                        word_in3(i) <= (others => '0');
                        word_in4(i) <= (others => '0');
                        word_out(i) <= (others => '0');
                    end loop;
                    
                    if prev_done = "1111" then
                        pr_state <= B;
                    else
                        pr_state <= A;
                    end if;
                when B =>
                    for i in 0 to 3 loop
                        word_in2(3)(7 + i * 8 downto i * 8) <= word_in(3)((7 + i * 8 + 24) mod 32 downto (i * 8 + 24) mod 32);
                    end loop;
                    
                    pr_state <= C;
                when C =>
                    for i in 0 to 3 loop
                        word_in3(3)(7 + i * 8 downto i * 8) <= to_unsigned(SBOX(to_integer(word_in2(3)(7 + i * 8 downto i * 8))), 8);
                    end loop;
                    
                    pr_state <= D;
                when D =>
                    word_in4(3)(31 downto 24) <= word_in3(3)(31 downto 24) xor rc;
                    word_in4(3)(23 downto 0) <= word_in3(3)(23 downto 0);
                    
                    pr_state <= E;
                when E =>
                    word_out(0) <= word_in(0) xor word_in4(3);
                    
                    pr_state <= F;
                when F =>
                    word_out(1) <= word_out(0) xor word_in(1);
                    
                    pr_state <= G;
                when G =>
                    word_out(2) <= word_out(1) xor word_in(2);
                    
                    pr_state <= H;
                when H =>
                    word_out(3) <= word_out(2) xor word_in(3);
                    
                    pr_state <= I;
                when I =>
                    newkey_r <= word_out(0) & word_out(1) & word_out(2) & word_out(3);
                    
                    pr_state <= J;
                when J =>
                    data_out <= data_in xor newkey_r;
                    newkey <= newkey_r;
                    
                    pr_state <= K;
                when K =>
                    done <= '1';
                    pr_state <= L;
                when L =>
                    if prev_done < "1111" then
                        pr_state <= A;
                    else
                        pr_state <= L;
                    end if;
            end case;
        end if;
    end if;
end process;
            
end Behavioral;
