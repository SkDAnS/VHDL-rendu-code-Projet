library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paddle_control is
    Port(
        clk       : in std_logic;
        reset     : in std_logic;
        btnL      : in std_logic;  
        btnU      : in std_logic;  
        ball_x    : in unsigned(9 downto 0);  --position de la ball pour l'IA afin qu'il la suive 
        ball_y    : in unsigned(9 downto 0);
        paddle1_y : out unsigned(9 downto 0);
        paddle2_y : out unsigned(9 downto 0)  
    );
end paddle_control;

architecture Behavioral of paddle_control is
    constant PADDLE_HEIGHT : integer := 60;
    constant SCREEN_HEIGHT : integer := 480;
    constant PADDLE_SPEED  : integer := 3;
    
    signal temp_counter    : integer := 0;
    signal paddle_left     : unsigned(9 downto 0) := to_unsigned(210, 10); 
    signal paddle_right    : unsigned(9 downto 0) := to_unsigned(210, 10);
    
    --variable d'IA
    signal ai_target       : unsigned(9 downto 0) := to_unsigned(210, 10);
    signal ai_delay_counter: integer := 0;
    constant AI_DELAY      : integer := 200000; --delai de l'IA 
    constant AI_SPEED      : integer := 2;      --vitesse
    
begin
    process(clk, reset)
        variable ball_center_y : unsigned(9 downto 0);
        variable paddle_center : unsigned(9 downto 0);
    begin
        if reset = '1' then
            paddle_left <= to_unsigned(210, 10);
            paddle_right <= to_unsigned(210, 10);
            temp_counter <= 0;
            ai_delay_counter <= 0;
            ai_target <= to_unsigned(210, 10);
            
        elsif rising_edge(clk) then
            
            if temp_counter = 200000 then --meilleur mouvement 
                temp_counter <= 0;
                
                if btnU = '1' and paddle_left > to_unsigned(0, 10) then
                    paddle_left <= paddle_left - to_unsigned(PADDLE_SPEED, 10);
                elsif btnL = '1' and paddle_left < to_unsigned(SCREEN_HEIGHT - PADDLE_HEIGHT, 10) then
                    paddle_left <= paddle_left + to_unsigned(PADDLE_SPEED, 10);
                end if;
            else
                temp_counter <= temp_counter + 1;
            end if;
            
            -- raquette IA suit la position Y de la balle
            if ai_delay_counter = AI_DELAY then
                ai_delay_counter <= 0;
                
                -- L'IA suit le centre de la balle
                if ball_y >= to_unsigned(PADDLE_HEIGHT/2, 10) then
                    ball_center_y := ball_y - to_unsigned(PADDLE_HEIGHT/2, 10);
                else
                    ball_center_y := to_unsigned(0, 10);
                end if;
                
                -- assure que l'IA ne dépasse pas les limites
                if ball_center_y > to_unsigned(SCREEN_HEIGHT - PADDLE_HEIGHT, 10) then
                    ai_target <= to_unsigned(SCREEN_HEIGHT - PADDLE_HEIGHT, 10);
                else
                    ai_target <= ball_center_y;
                end if;
                
                -- déplacer la palette de l'IA vers la cible
                paddle_center := paddle_right + to_unsigned(PADDLE_HEIGHT/2, 10);
                
                if paddle_center < ball_y and paddle_right < to_unsigned(SCREEN_HEIGHT - PADDLE_HEIGHT, 10) then
                    paddle_right <= paddle_right + to_unsigned(AI_SPEED, 10);
                elsif paddle_center > ball_y and paddle_right > to_unsigned(0, 10) then
                    paddle_right <= paddle_right - to_unsigned(AI_SPEED, 10);
                end if;
                
            else
                ai_delay_counter <= ai_delay_counter + 1;
            end if;
        end if;
    end process;
    
    paddle1_y <= paddle_left;
    paddle2_y <= paddle_right;
    
end Behavioral;