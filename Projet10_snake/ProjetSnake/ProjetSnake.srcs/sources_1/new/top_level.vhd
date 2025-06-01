
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( clk : in STD_LOGIC;
           btnC : in STD_LOGIC;  --reset
           btnU : in STD_LOGIC;  
           btnD : in STD_LOGIC;  
           btnL : in STD_LOGIC;  
           btnR : in STD_LOGIC;  
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end top_level;

architecture Behavioral of top_level is
    -- composant du jeu Snake
    component snake_game is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               btn_up : in STD_LOGIC;
               btn_down : in STD_LOGIC;
               btn_left : in STD_LOGIC;
               btn_right : in STD_LOGIC;
               vga_red : out STD_LOGIC_VECTOR (3 downto 0);
               vga_green : out STD_LOGIC_VECTOR (3 downto 0);
               vga_blue : out STD_LOGIC_VECTOR (3 downto 0);
               vga_hsync : out STD_LOGIC;
               vga_vsync : out STD_LOGIC);
    end component;
    
    -- signaux pour le debouncing des boutons
    signal btn_up_debounced : STD_LOGIC;
    signal btn_down_debounced : STD_LOGIC;
    signal btn_left_debounced : STD_LOGIC;
    signal btn_right_debounced : STD_LOGIC;
    signal reset_debounced : STD_LOGIC;
    
    -- compteurs pour le debouncing
    signal debounce_counter : integer range 0 to 1000000 := 0;
    signal btn_up_reg, btn_down_reg, btn_left_reg, btn_right_reg, reset_reg : STD_LOGIC := '0';
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            -- enregistrement des états des boutons
            btn_up_reg <= btnU;
            btn_down_reg <= btnD;
            btn_left_reg <= btnL;
            btn_right_reg <= btnR;
            reset_reg <= btnC;
            
            
            if debounce_counter = 1000000 then
                debounce_counter <= 0;
                btn_up_debounced <= btn_up_reg;
                btn_down_debounced <= btn_down_reg;
                btn_left_debounced <= btn_left_reg;
                btn_right_debounced <= btn_right_reg;
                reset_debounced <= reset_reg;
            else
                debounce_counter <= debounce_counter + 1;
            end if;
        end if;
    end process;
    
    -- instanciation du jeu Snake
    Snake_Game_Inst: snake_game
    port map (
        clk => clk,
        reset => reset_debounced,
        btn_up => btn_up_debounced,
        btn_down => btn_down_debounced,
        btn_left => btn_left_debounced,
        btn_right => btn_right_debounced,
        vga_red => vgaRed,
        vga_green => vgaGreen,
        vga_blue => vgaBlue,
        vga_hsync => Hsync,
        vga_vsync => Vsync
    );
    
end Behavioral;