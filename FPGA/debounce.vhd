library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    generic (
        CNT_MAX : integer := 50000  -- adjust based on clock frequency
    );
    port (
        clk     : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;
        btn_out : out STD_LOGIC
    );
end entity;

architecture rtl of debounce is
    signal btn_sync  : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal cnt       : integer := 0;
    signal btn_state : STD_LOGIC := '0';
begin
    -- Synchronize button to clk domain
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync(0) <= btn_in;
            btn_sync(1) <= btn_sync(0);
        end if;
    end process;

    -- Debounce logic
    process(clk)
    begin
        if rising_edge(clk) then
            if btn_sync(1) /= btn_state then
                cnt <= cnt + 1;
                if cnt > CNT_MAX then
                    btn_state <= btn_sync(1);
                    cnt <= 0;
                end if;
            else
                cnt <= 0;
            end if;
        end if;
    end process;

    btn_out <= btn_state;
end architecture;
