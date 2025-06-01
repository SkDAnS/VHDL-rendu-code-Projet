library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_game is
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
end snake_game;

architecture Behavioral of snake_game is
    -- constantes pour la taille de l'écran et du jeu
    constant GRID_SIZE : integer := 20;
    constant GRID_WIDTH : integer := 29;
    constant GRID_HEIGHT : integer := 24;
    constant MAX_LENGTH : integer := 50;
    
    -- types pour le jeu
    type direction_type is (UP, DOWN, LEFT, RIGHT);
    type position_type is record
        x : integer range 0 to GRID_WIDTH-1;
        y : integer range 0 to GRID_HEIGHT-1;
    end record;
    type snake_array is array (0 to MAX_LENGTH-1) of position_type;
    
    -- VGA
    signal pixel_clk : STD_LOGIC := '0';
    signal display_enable : STD_LOGIC;
    signal column : STD_LOGIC_VECTOR(9 downto 0);
    signal row : STD_LOGIC_VECTOR(9 downto 0);
    
    --  jeu
    signal snake : snake_array;
    signal snake_length : integer range 1 to MAX_LENGTH := 5;
    signal direction : direction_type := RIGHT;
    signal next_direction : direction_type := RIGHT;
    signal food_pos : position_type;
    signal game_over : STD_LOGIC := '0';
    
    -- générateur aléatoire simple
    signal rand_counter : unsigned(15 downto 0) := x"ABCD";
    
    --  gestion du temps
    signal game_clk : STD_LOGIC := '0';
    signal game_clk_counter : integer := 0;
    constant GAME_SPEED : integer := 25000000; -- Plus rapide pour les tests
    
    
    component vga_controller_640_60 is
        Port ( pixel_clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               h_sync : out STD_LOGIC;
               v_sync : out STD_LOGIC;
               display_enable : out STD_LOGIC;
               column : out STD_LOGIC_VECTOR (9 downto 0);
               row : out STD_LOGIC_VECTOR (9 downto 0);
               n_blank : out STD_LOGIC;
               n_sync : out STD_LOGIC);
    end component;
    
    -- diviseur d'horloge
    signal clk_divider : STD_LOGIC := '0';
    signal internal_reset : STD_LOGIC := '0';
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            clk_divider <= not clk_divider;
        end if;
    end process;
    
    pixel_clk <= clk_divider;
    
   
    VGA_Controller: vga_controller_640_60
    port map (
        pixel_clk => pixel_clk,
        reset => reset,
        h_sync => vga_hsync,
        v_sync => vga_vsync,
        display_enable => display_enable,
        column => column,
        row => row,
        n_blank => open,
        n_sync => open
    );
    
    -- génération de l'horloge du jeu
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or internal_reset = '1' then
                game_clk_counter <= 0;
                game_clk <= '0';
            else
                if game_clk_counter >= GAME_SPEED then
                    game_clk_counter <= 0;
                    game_clk <= '1';
                else
                    game_clk_counter <= game_clk_counter + 1;
                    game_clk <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- générateur de nombres aléatoires simple
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or internal_reset = '1' then
                rand_counter <= x"ABCD";
            else
                -- compteur qui s'incrémente constamment
                rand_counter <= rand_counter + 1;
            end if;
        end if;
    end process;
    
    -- gestion des entrée
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or internal_reset = '1' then
                next_direction <= RIGHT;
            else
                if btn_up = '1' and direction /= DOWN then
                    next_direction <= UP;
                elsif btn_down = '1' and direction /= UP then
                    next_direction <= DOWN;
                elsif btn_left = '1' and direction /= RIGHT then
                    next_direction <= LEFT;
                elsif btn_right = '1' and direction /= LEFT then
                    next_direction <= RIGHT;
                end if;
            end if;
        end if;
    end process;
    
    -- logique principale du jeu 
    process(clk)
        variable new_head_x : integer range 0 to GRID_WIDTH-1;
        variable new_head_y : integer range 0 to GRID_HEIGHT-1;
        variable collision : STD_LOGIC;
        variable new_food_x : integer range 0 to GRID_WIDTH-1;
        variable new_food_y : integer range 0 to GRID_HEIGHT-1;
    begin
        if rising_edge(clk) then
            if reset = '1' or internal_reset = '1' then
                --reset du jeu
                internal_reset <= '0';
                game_over <= '0';
                snake_length <= 5;
                direction <= RIGHT;
                
                -- Position initiale du serpent - horizontale
                snake(0).x <= 10; snake(0).y <= 12;
                snake(1).x <= 9;  snake(1).y <= 12;
                snake(2).x <= 8;  snake(2).y <= 12;
                snake(3).x <= 7;  snake(3).y <= 12;
                snake(4).x <= 6;  snake(4).y <= 12;
                
                -- initialiser le reste à 0
                for i in 5 to 25 loop -- limite fixe pour la synthèse
                    if i < MAX_LENGTH then
                        snake(i).x <= 0;
                        snake(i).y <= 0;
                    end if;
                end loop;
                
                -- Position initiale de la pomme - loin du serpent
                food_pos.x <= 20;
                food_pos.y <= 8;
                
            elsif game_clk = '1' and game_over = '0' then
                direction <= next_direction;
                
                -- calculer la nouvelle position de la tête
                new_head_x := snake(0).x;
                new_head_y := snake(0).y;
                
                case direction is
                    when UP =>    new_head_y := new_head_y - 1;
                    when DOWN =>  new_head_y := new_head_y + 1;
                    when LEFT =>  new_head_x := new_head_x - 1;
                    when RIGHT => new_head_x := new_head_x + 1;
                end case;
                
                -- vérifie les collisions avec les bordures
                collision := '0';
                if new_head_x <= 0 or new_head_x >= GRID_WIDTH-1 or 
                   new_head_y <= 0 or new_head_y >= GRID_HEIGHT-1 then
                    collision := '1';
                end if;
                
                -- Vérifie les collisions avec le corps (simple)
                if collision = '0' then
                    for i in 1 to 10 loop -- Limite fixe à 10 segments pour la synthèse
                        if i < snake_length and snake_length > 4 then
                            if new_head_x = snake(i).x and new_head_y = snake(i).y then
                                collision := '1';
                                exit;
                                
                            end if;
                        end if;
                        
                    end loop;
                end if;
                
                if collision = '1' then
                    -- collision détectée - redémarrer le jeu
                    internal_reset <= '1';
                else
                    -- Vérifier si la pomme est mangée AVANT de bouger
                    if new_head_x = food_pos.x and new_head_y = food_pos.y then
                        -- POMME MANGÉE - Agrandir le serpent ET créer nouvelle pomme
                        
                        -- deplacer tout le serpent vers l'avant (avec agrandissement)
                        for i in 15 downto 1 loop -- Limite fixe pour la synthèse
                            if i < MAX_LENGTH then
                                snake(i) <= snake(i-1);
                            end if;
                        end loop;
                        snake(0).x <= new_head_x;
                        snake(0).y <= new_head_y;
                        
                        -- Agrandir le serpent
                        if snake_length < MAX_LENGTH then
                            snake_length <= snake_length + 1;
                        end if;
                        
                        -- GÉNÉRER NOUVELLE POSITION DE POMME IMMÉDIATEMENT
                        new_food_x := (to_integer(rand_counter(7 downto 0)) mod 26) + 2;  -- Entre 2 et 27
                        new_food_y := (to_integer(rand_counter(15 downto 8)) mod 20) + 2; -- Entre 2 et 21
                        
                        -- S'assurer que la pomme n'est pas sur la tête (position simple)
                        if new_food_x = new_head_x and new_food_y = new_head_y then
                            new_food_x := (new_food_x + 5) mod 26 + 2;
                        end if;
                        
                        food_pos.x <= new_food_x;
                        food_pos.y <= new_food_y;
                        
                    else
                       
                        for i in 15 downto 1 loop
                            if i < snake_length then
                                snake(i) <= snake(i-1);
                            end if;
                        end loop;
                        snake(0).x <= new_head_x;
                        snake(0).y <= new_head_y;
                    end if;
                end if;
                
            end if;
        end if;
        
    end process;
    
    -- Affichage VGA 
    process(pixel_clk)
        variable pixel_x : integer;
        variable pixel_y : integer;
        variable grid_x : integer;
        variable grid_y : integer;
        variable draw_snake : STD_LOGIC;
        variable draw_head : STD_LOGIC;
        variable draw_food : STD_LOGIC;
        variable draw_border : STD_LOGIC;
    begin
        if rising_edge(pixel_clk) then
            if display_enable = '1' then
                pixel_x := to_integer(unsigned(column));
                pixel_y := to_integer(unsigned(row));
                
                if pixel_x < 640 and pixel_y < 480 then
                    grid_x := pixel_x / GRID_SIZE;
                    grid_y := pixel_y / GRID_SIZE;
                    
                    -- Détection des éléments
                    draw_head := '0';
                    draw_snake := '0';
                    draw_food := '0';
                    draw_border := '0';
                    
                    -- Tête du serpent
                    if grid_x = snake(0).x and grid_y = snake(0).y then
                        draw_head := '1';
                    end if;
                    
                    -- Corps du serpent
                    if draw_head = '0' then
                        for i in 1 to 15 loop 
                            if i < snake_length then
                                if grid_x = snake(i).x and grid_y = snake(i).y then
                                    draw_snake := '1';
                                    exit;
                                end if;
                            end if;
                        end loop;
                    end if;
                    
                    -- Pomme
                    if grid_x = food_pos.x and grid_y = food_pos.y then
                        draw_food := '1';
                    end if;
                    
                    -- Bordures
                    if grid_x = 0 or grid_x = GRID_WIDTH-1 or 
                       grid_y = 0 or grid_y = GRID_HEIGHT-1 then
                        draw_border := '1';
                    end if;
                    
                    -- Affichage des couleurs
                    if draw_head = '1' then
                        -- Tête en magenta
                        vga_red <= "1111"; vga_green <= "0000"; vga_blue <= "1111";
                    elsif draw_snake = '1' then
                        -- Corps en vert
                        vga_red <= "0000"; vga_green <= "1111"; vga_blue <= "0000";
                    elsif draw_food = '1' then
                        -- Pomme en rouge
                        vga_red <= "1111"; vga_green <= "0000"; vga_blue <= "0000";
                    elsif draw_border = '1' then
                        -- Bordure en bleu
                        vga_red <= "0000"; vga_green <= "0000"; vga_blue <= "1111";
                    else
                        -- Fond noir
                        vga_red <= "0000"; vga_green <= "0000"; vga_blue <= "0000";
                    end if;
                else
                    -- Hors écran
                    vga_red <= "0000"; vga_green <= "0000"; vga_blue <= "0000";
                end if;
            else
                -- Display disabled
                vga_red <= "0000"; vga_green <= "0000"; vga_blue <= "0000";
            end if;
        end if;
    end process;
    
end Behavioral;