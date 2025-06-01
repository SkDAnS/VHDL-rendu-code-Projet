library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ball is
    port (
        clk           : in std_logic;
        reset         : in std_logic;
        y_paddleLeft  : in unsigned(9 downto 0);
        y_paddleRight : in unsigned(9 downto 0);
        ball_x        : out unsigned(9 downto 0);
        ball_y        : out unsigned(9 downto 0);
        score_p1      : out unsigned(3 downto 0);
        score_p2      : out unsigned(3 downto 0)
    );
end ball;

architecture Behavioral of ball is
    constant PADDLE_HEIGHT : integer := 60;
    constant PADDLE_WIDTH  : integer := 10;
    constant BALL_SIZE     : integer := 12;
    constant SCREEN_WIDTH  : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    signal ballX           : unsigned(9 downto 0) := to_unsigned(320, 10);
    signal ballY           : unsigned(9 downto 0) := to_unsigned(240, 10);
    signal velocity_x      : signed(3 downto 0) := to_signed(4, 4); 
    signal velocity_y      : signed(3 downto 0) := to_signed(3, 4);  
    signal score_left      : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal score_right     : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal temp_counter    : integer := 0;
    
    -- colision de balle
    signal next_x          : unsigned(9 downto 0);
    signal next_y          : unsigned(9 downto 0);
    signal hit_left_paddle : std_logic;
    signal hit_right_paddle: std_logic;
    signal hit_top_wall    : std_logic;
    signal hit_bottom_wall : std_logic;

begin
    -- calcule prochaine position 
    process(ballX, ballY, velocity_x, velocity_y)
        variable temp_x : signed(10 downto 0);
        variable temp_y : signed(10 downto 0);
    begin
        -- calcul prochaine position de x
        temp_x := signed('0' & ballX) + resize(velocity_x, 11);
        if temp_x < 0 then
            next_x <= to_unsigned(0, 10);
        elsif temp_x > SCREEN_WIDTH then
            next_x <= to_unsigned(SCREEN_WIDTH, 10);
        else
            next_x <= unsigned(temp_x(9 downto 0));
        end if;
        
        -- meme chose que pour x mais pour y
        temp_y := signed('0' & ballY) + resize(velocity_y, 11);
        if temp_y < 0 then
            next_y <= to_unsigned(0, 10);
        elsif temp_y > SCREEN_HEIGHT then
            next_y <= to_unsigned(SCREEN_HEIGHT, 10);
        else
            next_y <= unsigned(temp_y(9 downto 0));
        end if;
    end process;

    -- detecte la la collision et agit selon ou il a toucher
    hit_left_paddle <= '1' when (next_x <= to_unsigned(30, 10)) and 
                                (next_x + to_unsigned(BALL_SIZE, 10) >= to_unsigned(20, 10)) and
                                (next_y + to_unsigned(BALL_SIZE, 10) >= y_paddleLeft) and 
                                (next_y <= y_paddleLeft + to_unsigned(PADDLE_HEIGHT, 10)) else '0';
                                
    hit_right_paddle <= '1' when (next_x + to_unsigned(BALL_SIZE, 10) >= to_unsigned(610, 10)) and 
                                 (next_x <= to_unsigned(620, 10)) and
                                 (next_y + to_unsigned(BALL_SIZE, 10) >= y_paddleRight) and 
                                 (next_y <= y_paddleRight + to_unsigned(PADDLE_HEIGHT, 10)) else '0';
                                 
    hit_top_wall <= '1' when next_y <= to_unsigned(0, 10) else '0';
    hit_bottom_wall <= '1' when next_y + to_unsigned(BALL_SIZE, 10) >= to_unsigned(SCREEN_HEIGHT, 10) else '0';

    process(clk, reset)
        variable paddle_hit_pos : signed(10 downto 0);
        variable paddle_center : signed(10 downto 0);
    begin
        if reset = '1' then
            ballX <= to_unsigned(320, 10);
            ballY <= to_unsigned(240, 10);
            velocity_x <= to_signed(4, 4);
            velocity_y <= to_signed(3, 4);
            score_left <= to_unsigned(0, 4);
            score_right <= to_unsigned(0, 4);
            temp_counter <= 0;
            
        elsif rising_edge(clk) then
            if temp_counter = 300000 then --vitesse de la balle ~83 FPS at 25MHz
                temp_counter <= 0;

                --SCORE
                if ballX <= to_unsigned(0, 10) then
                    -- IA gagne
                    ballX <= to_unsigned(320, 10);
                    ballY <= to_unsigned(240, 10);
                    velocity_x <= to_signed(-4, 4);
                    velocity_y <= to_signed(3, 4);
                    score_right <= score_right + to_unsigned(1, 4);
                    
                elsif ballX + to_unsigned(BALL_SIZE, 10) >= to_unsigned(SCREEN_WIDTH, 10) then
                    --joueur gagne
                    ballX <= to_unsigned(320, 10);
                    ballY <= to_unsigned(240, 10);
                    velocity_x <= to_signed(4, 4);  
                    velocity_y <= to_signed(-3, 4);
                    score_left <= score_left + to_unsigned(1, 4);
                    
                else
                    --colision raquette
                    if hit_left_paddle = '1' then
                        velocity_x <= abs(velocity_x); -- rebondit a droite
                       --selon ou est la balle il ira....
                        paddle_center := signed('0' & y_paddleLeft) + to_signed(PADDLE_HEIGHT/2, 11);
                        paddle_hit_pos := signed('0' & ballY) - paddle_center;
                        if paddle_hit_pos > 10 then
                            velocity_y <= to_signed(4, 4); -- bas
                        elsif paddle_hit_pos < -10 then
                            velocity_y <= to_signed(-4, 4); -- haut
                        else
                            velocity_y <= to_signed(0, 4);  -- droit
                        end if;
                        
                    elsif hit_right_paddle = '1' then
                        velocity_x <= -abs(velocity_x); -- rebondit gauche 

                        paddle_center := signed('0' & y_paddleRight) + to_signed(PADDLE_HEIGHT/2, 11);
                        paddle_hit_pos := signed('0' & ballY) - paddle_center;
                        if paddle_hit_pos > 10 then
                            velocity_y <= to_signed(4, 4);  
                        elsif paddle_hit_pos < -10 then
                            velocity_y <= to_signed(-4, 4); 
                        else
                            velocity_y <= to_signed(0, 4); 
                        end if;
                    end if;
                    
                    -- prend en compte les collision mur 
                    if hit_top_wall = '1' or hit_bottom_wall = '1' then
                        velocity_y <= -velocity_y; -- Bounce Y
                    end if;
                    
                    --position de la balle
                    ballX <= next_x;
                    ballY <= next_y;
                end if;
            else
                temp_counter <= temp_counter + 1;
            end if;
        end if;
    end process;

    ball_x <= ballX;
    ball_y <= ballY;
    score_p1 <= score_left;
    score_p2 <= score_right;

end Behavioral;