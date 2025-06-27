library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity int_to_digit is
    port(
        num : in integer range 0 to 9;
        digit : out STD_LOGIC_VECTOR(6 downto 0)
    );
end int_to_digit;

architecture a of int_to_digit is
begin
    -- Assuming common cathode 7-segment display
    with num select
        digit <=
            "1000000" when 0,  -- 0
            "1111001" when 1,  -- 1
            "0100100" when 2,  -- 2
            "0110000" when 3,  -- 3
            "0011001" when 4,  -- 4
            "0010010" when 5,  -- 5
            "0000010" when 6,  -- 6
            "1111000" when 7,  -- 7
            "0000000" when 8,  -- 8
            "0010000" when 9,  -- 9
            "1111111" when others;  -- all segments off (or error)
end a;
