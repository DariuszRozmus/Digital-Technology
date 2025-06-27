library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity snake_anim is
    generic (
        DIV_MAX : natural := 5_000_000  -- ˜10 Hz przy 50 MHz
    );
    port (
        clk         : in  STD_LOGIC;
        enable      : in  STD_LOGIC;             -- switch_animate
        left_digit  : out STD_LOGIC_VECTOR(6 downto 0);  -- g f e d c b a, active-low
        right_digit : out STD_LOGIC_VECTOR(6 downto 0)
    );
end snake_anim;

architecture rtl of snake_anim is
    ----------------------------------------------------------------
    -- Kod segmentów: 1 = zgaszony, 0 = zapalony  (gfedcba)
    ----------------------------------------------------------------
    constant OFF : STD_LOGIC_VECTOR(6 downto 0) := (others => '1');

    -- pojedyncze segmenty
    constant SEG_A : STD_LOGIC_VECTOR(6 downto 0) := "1111110";
    constant SEG_B : STD_LOGIC_VECTOR(6 downto 0) := "1111101";
    constant SEG_C : STD_LOGIC_VECTOR(6 downto 0) := "1111011";
    constant SEG_D : STD_LOGIC_VECTOR(6 downto 0) := "1110111";
    constant SEG_E : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
    constant SEG_F : STD_LOGIC_VECTOR(6 downto 0) := "1011111";
    -- (g niepotrzebny)

    ----------------------------------------------------------------
    -- 8 klatek animacji
    ----------------------------------------------------------------
    type pat_arr is array (0 to 7) of STD_LOGIC_VECTOR(6 downto 0);

    -- lewy wyswietlacz (d e f a)------------
    constant L_PAT : pat_arr := (
        SEG_D,  -- 0
        SEG_E,  -- 1
        SEG_F,  -- 2
        SEG_A,  -- 3
        OFF,    -- 4  (od teraz waz na prawym)
        OFF,    -- 5
        OFF,    -- 6
        OFF     -- 7
    );

    -- prawy wyswietlacz (---- a b c d)
    constant R_PAT : pat_arr := (
        OFF,    -- 0
        OFF,    -- 1
        OFF,    -- 2
        OFF,    -- 3
        SEG_A,  -- 4
        SEG_B,  -- 5
        SEG_C,  -- 6
        SEG_D   -- 7
    );

    ----------------------------------------------------------------
    -- Licznik klatek + dzielnik czestotliwosci
    ----------------------------------------------------------------
    signal frame   : integer range 0 to 7 := 0;
    signal div_cnt : natural range 0 to DIV_MAX-1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if div_cnt = DIV_MAX-1 then
                    div_cnt <= 0;
                    frame   <= (frame + 1) mod 8;
                else
                    div_cnt <= div_cnt + 1;
                end if;
            else                    -- przy wylaczeniu animacji
                div_cnt <= 0;
                frame   <= 0;
            end if;
        end if;
    end process;

    left_digit  <= L_PAT(frame);
    right_digit <= R_PAT(frame);
end rtl;
