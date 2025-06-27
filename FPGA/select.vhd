library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity selector is
    port(
        clk : in STD_LOGIC;
        num_in: in integer range 0 to 9;
        num_out : out integer range 0 to 9
    );
end selector;

architecture a of selector is
    signal curr : integer range 0 to 9 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
			curr <= num_in;
        end if;
    end process;

    num_out <= curr;
end a;
