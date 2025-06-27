library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity one_pulse is
    port (
        clk      : in  STD_LOGIC;
        btn_in   : in  STD_LOGIC;
        pulse_out: out STD_LOGIC
    );
end entity;

architecture rtl of one_pulse is
    signal btn_reg : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            pulse_out <= btn_in and not btn_reg;
            btn_reg   <= btn_in;
        end if;
    end process;
end architecture;
