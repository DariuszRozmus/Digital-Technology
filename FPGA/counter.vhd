library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity counter is
    port (
        clk  : in  STD_LOGIC;          -- zegar systemowy
        en   : in  STD_LOGIC;          -- impuls z one_pulse
        dir  : in  STD_LOGIC;          -- '0' = w góre, '1' = w dól
        num  : out INTEGER range 0 to 9
    );
end counter;

architecture rtl of counter is
    signal value : INTEGER range 0 to 9 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if dir = '1' then          -- w dol
                    if value = 0 then
                        value <= 9;
                    else
                        value <= value - 1;
                    end if;
                else                       -- do góry
                    if value = 9 then
                        value <= 0;
                    else
                        value <= value + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    num <= value;
end rtl;
