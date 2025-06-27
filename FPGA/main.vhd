library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity main is
    port (
        clk              : in  STD_LOGIC;  -- 50 MHz
        btn_counter      : in  STD_LOGIC;  -- FLEX_PB1  (pin 28)
        btn_select       : in  STD_LOGIC;  -- FLEX_PB2  (pin 29)

        switch_down      : in  STD_LOGIC;  -- FLEX_SWITCH-1 (pin 41) – UP = '1'
        switch_animate   : in  STD_LOGIC;  -- FLEX_SWITCH-2 (pin 40) – UP = '1'

        menu_digit       : out STD_LOGIC_VECTOR(6 downto 0); -- lewy wyswietlacz
        selected_digit   : out STD_LOGIC_VECTOR(6 downto 0); -- prawy wyswietlacz
        menu_dp          : out STD_LOGIC;                    -- kropka (DP)
        selected_dp      : out STD_LOGIC                     -- kropka (DP)
    );
end entity;

architecture rtl of main is
    ----------------------------------------------------------------
    -- sygnaly z przycisków
    ----------------------------------------------------------------
    signal deb_counter   : STD_LOGIC;
    signal deb_select    : STD_LOGIC;
    signal pulse_counter : STD_LOGIC;
    signal pulse_select  : STD_LOGIC;

    ----------------------------------------------------------------
    -- logika licznika i pamieci
    ----------------------------------------------------------------
    signal count    : INTEGER range 0 to 9;
    signal selected : INTEGER range 0 to 9;

    ----------------------------------------------------------------
    -- zakodowane cyfry
    ----------------------------------------------------------------
    signal menu_norm : STD_LOGIC_VECTOR(6 downto 0);
    signal sel_norm  : STD_LOGIC_VECTOR(6 downto 0);

    ----------------------------------------------------------------
    -- animacja
    ----------------------------------------------------------------
    signal anim_left  : STD_LOGIC_VECTOR(6 downto 0);
    signal anim_right : STD_LOGIC_VECTOR(6 downto 0);

    ----------------------------------------------------------------
    -- sygnaly pomocnicze (odwrócona logika przelaczników)
    ----------------------------------------------------------------
    signal dir_count : STD_LOGIC;  -- 0 = UP, 1 = DOWN
    signal anim_en   : STD_LOGIC;  -- 1 = animacja WLACZONA
begin
    ----------------------------------------------------------------
    -- Eliminacja drgan styków + generacja pojedynczego impulsu
    ----------------------------------------------------------------
    deb1: entity work.debounce
        generic map (CNT_MAX => 250_000)          -- ~5 ms przy 50 MHz
        port map (
            clk     => clk,
            btn_in  => btn_counter,
            btn_out => deb_counter
        );

    deb2: entity work.debounce
        generic map (CNT_MAX => 250_000)
        port map (
            clk     => clk,
            btn_in  => btn_select,
            btn_out => deb_select
        );

    op1: entity work.one_pulse
        port map (
            clk       => clk,
            btn_in    => deb_counter,
            pulse_out => pulse_counter
        );

    op2: entity work.one_pulse
        port map (
            clk       => clk,
            btn_in    => deb_select,
            pulse_out => pulse_select
        );

    ----------------------------------------------------------------
    -- Konwersja przelaczników
    --   switch_down    : 1 (UP)  -> liczenie w góre
    --                     0 (DOWN)-> liczenie w dól
    --   switch_animate : 1 (UP)  -> animacja WYLACZONA
    --                     0 (DOWN)-> animacja WLACZONA
    ----------------------------------------------------------------
    dir_count <= not switch_down;       -- 0 = up, 1 = down
    anim_en   <= not switch_animate;    -- 1 = animacja on

    ----------------------------------------------------------------
    -- Licznik i funkcja „zapamietaj”
    ----------------------------------------------------------------
    cnt0: entity work.counter           -- implementacja: dir = '1' => down
        port map (
            clk => clk,
            en  => pulse_counter,
            dir => dir_count,
            num => count
        );

    sel0: entity work.selector
        port map (
            clk     => pulse_select,    -- zapis na zboczu impulsu
            num_in  => count,
            num_out => selected
        );

    to7seg1: entity work.int_to_digit
        port map (
            num   => count,
            digit => menu_norm
        );

    to7seg2: entity work.int_to_digit
        port map (
            num   => selected,
            digit => sel_norm
        );

    ----------------------------------------------------------------
    -- Animacja „weza”
    ----------------------------------------------------------------
    anim0: entity work.snake_anim
        generic map (DIV_MAX => 5_000_000)  -- ˜10 Hz przy 50 MHz
        port map (
            clk         => clk,
            enable      => anim_en,
            left_digit  => anim_left,
            right_digit => anim_right
        );

    ----------------------------------------------------------------
    -- Multiplekser wyjsc
    ----------------------------------------------------------------
    menu_digit     <= anim_left  when anim_en = '1' else menu_norm;
    selected_digit <= anim_right when anim_en = '1' else sel_norm;

    ----------------------------------------------------------------
    -- Stale wygaszenie kropek (DP)
    ----------------------------------------------------------------
    menu_dp     <= '1';   -- aktywne-LOW: '1' = zgaszona
    selected_dp <= '1';   -- aktywne-LOW: '1' = zgaszona
end rtl;
