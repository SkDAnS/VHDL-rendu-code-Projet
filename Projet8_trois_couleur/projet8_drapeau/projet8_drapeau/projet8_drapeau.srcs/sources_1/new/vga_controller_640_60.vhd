
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_vga is
    Port ( 
        clk    : in  STD_LOGIC;                  
        reset  : in  STD_LOGIC;                   
        hsync  : out STD_LOGIC;                  
        vsync  : out STD_LOGIC;                  
        red    : out STD_LOGIC_VECTOR(3 downto 0); 
        green  : out STD_LOGIC_VECTOR(3 downto 0); 
        blue   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end image_vga;

architecture Behavioral of image_vga is
    -- déclaration du contrôleur VGA
    component vga_controller_640_60 is
        Port (
            pixel_clk : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            h_sync    : out STD_LOGIC;
            v_sync    : out STD_LOGIC;
            disp_ena  : out STD_LOGIC;
            column    : out STD_LOGIC_VECTOR(9 downto 0);
            row       : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    -- signaux pour le contrôleur VGA
    signal disp_ena  : STD_LOGIC;
    signal column    : STD_LOGIC_VECTOR(9 downto 0);
    signal row       : STD_LOGIC_VECTOR(9 downto 0);
    signal pxl_clk   : STD_LOGIC := '0';  -- horloge pixel 25 MHz

    -- paramètres de l'image
    constant IMAGE_WIDTH  : integer := 100;
    constant IMAGE_HEIGHT : integer := 100;
    constant IMAGE_X      : integer := 270;
    constant IMAGE_Y      : integer := 190;

    -- couleur bleue (RGB 4 bits par canal)
    constant COLOR_R : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant COLOR_G : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant COLOR_B : STD_LOGIC_VECTOR(3 downto 0) := "1111";

begin

    -- diviseur d'horloge 100 MHz -> 25 MHz
    process(clk)
        variable counter : integer range 0 to 3 := 0;
    begin
        if rising_edge(clk) then
            if counter = 3 then
                pxl_clk <= not pxl_clk;
                counter := 0;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;

    -- instanciation du contrôleur VGA
    vga_controller_inst: vga_controller_640_60
    port map(
        pixel_clk => pxl_clk,
        reset     => reset,
        h_sync    => hsync,
        v_sync    => vsync,
        disp_ena  => disp_ena,
        column    => column,
        row       => row
    );

    -- logique d'affichage synchrone
    display_process: process(pxl_clk)
        variable x_pos : integer;
        variable y_pos : integer;
    begin
        if rising_edge(pxl_clk) then
            x_pos := to_integer(unsigned(column));
            y_pos := to_integer(unsigned(row));
            
            if disp_ena = '1' then
                if (x_pos >= IMAGE_X) and (x_pos < IMAGE_X + IMAGE_WIDTH) and
                   (y_pos >= IMAGE_Y) and (y_pos < IMAGE_Y + IMAGE_HEIGHT) then
                    red   <= COLOR_R;
                    green <= COLOR_G;
                    blue  <= COLOR_B;
                else
                    red   <= (others => '0');
                    green <= (others => '0');
                    blue  <= (others => '0');
                end if;
            else
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;

--------------------------------------------------------------------------------
-- IMPLÉMENTATION DU CONTRÔLEUR VGA
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller_640_60 is
    Port (
        pixel_clk : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        h_sync    : out STD_LOGIC;
        v_sync    : out STD_LOGIC;
        disp_ena  : out STD_LOGIC;
        column    : out STD_LOGIC_VECTOR(9 downto 0);
        row       : out STD_LOGIC_VECTOR(9 downto 0)
    );
end entity;

architecture Behavioral of vga_controller_640_60 is
    -- Paramètres VGA 640x480 @ 60Hz
    constant HD  : integer := 640;  -- Affichage horizontal
    constant HF  : integer := 16;   -- Front porch
    constant HB  : integer := 48;   -- Back porch
    constant HR  : integer := 96;   -- Retrace horizontal
    constant VD  : integer := 480;  -- Affichage vertical
    constant VF  : integer := 10;   -- Front porch
    constant VB  : integer := 33;   -- Back porch
    constant VR  : integer := 2;    -- Retrace vertical

    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');

begin
    -- Compteur horizontal
    process(pixel_clk, reset)
    begin
        if reset = '1' then
            h_cnt <= (others => '0');
        elsif rising_edge(pixel_clk) then
            if h_cnt = HD + HF + HB + HR - 1 then
                h_cnt <= (others => '0');
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;

    -- Compteur vertical
    process(pixel_clk, reset)
    begin                                        if reset = '1' then
            v_cnt <= (others => '0');
        elsif rising_edge(pixel_clk) then
            if h_cnt = HD + HF + HB + HR - 1 then
                if v_cnt = VD + VF + VB + VR - 1 then
                    v_cnt <= (others => '0');
                else
                    v_cnt <= v_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Génération des signaux de synchronisation
    h_sync <= '0' when (h_cnt >= HD + HF) and (h_cnt < HD + HF + HR) else '1';
    v_sync <= '0' when (v_cnt >= VD + VF) and (v_cnt < VD + VF + VR) else '1';
    
    -- Signal d'activation de l'affichage
    disp_ena <= '1' when (h_cnt < HD) and (v_cnt < VD) else '0';
    
    -- Sorties de position
    column <= std_logic_vector(h_cnt);
    row <= std_logic_vector(v_cnt);

end architecture;
