library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_display is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        pixel_x     : in  unsigned(9 downto 0);
        pixel_y     : in  unsigned(9 downto 0);
        ball_x      : in  unsigned(9 downto 0);
        ball_y      : in  unsigned(9 downto 0);
        paddle1_y   : in  unsigned(9 downto 0);
        paddle2_y   : in  unsigned(9 downto 0);
        score_p1    : in  unsigned(3 downto 0);
        score_p2    : in  unsigned(3 downto 0);
        red         : out std_logic_vector(3 downto 0);
        green       : out std_logic_vector(3 downto 0);
        blue        : out std_logic_vector(3 downto 0)
    );
end vga_display;

architecture Behavioral of vga_display is
    constant PADDLE_WIDTH  : integer := 10;
    constant PADDLE_HEIGHT : integer := 60;
    constant BALL_SIZE     : integer := 12;
    constant SCREEN_WIDTH  : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;
    
    --score
    constant SCORE_WIDTH   : integer := 40;
    constant SCORE_HEIGHT  : integer := 60;
    constant SCORE_Y_POS   : integer := 40;
    
    -- position score
    constant P1_SCORE_X    : integer := SCREEN_WIDTH/4;
    constant P2_SCORE_X    : integer := 3*SCREEN_WIDTH/4;

    signal display_score_p1 : std_logic;
    signal display_score_p2 : std_logic;
    
    
    signal digit_pixel_p1 : std_logic;
    signal digit_pixel_p2 : std_logic;
    
begin
    --placement du score
    display_score_p1 <= '1' when (pixel_x >= P1_SCORE_X - SCORE_WIDTH/2) and 
                                  (pixel_x <= P1_SCORE_X + SCORE_WIDTH/2) and
                                  (pixel_y >= SCORE_Y_POS) and 
                                  (pixel_y <= SCORE_Y_POS + SCORE_HEIGHT) 
                                  else '0';
                                  
    display_score_p2 <= '1' when (pixel_x >= P2_SCORE_X - SCORE_WIDTH/2) and 
                                  (pixel_x <= P2_SCORE_X + SCORE_WIDTH/2) and
                                  (pixel_y >= SCORE_Y_POS) and 
                                  (pixel_y <= SCORE_Y_POS + SCORE_HEIGHT)
                                   else '0';

    
    process(pixel_x, pixel_y, score_p1)
        variable rel_x : integer;
        variable rel_y : integer;
    begin
        digit_pixel_p1 <= '0';
        if display_score_p1 = '1' then
            rel_x := to_integer(pixel_x) - (P1_SCORE_X - SCORE_WIDTH/2);
            rel_y := to_integer(pixel_y) - SCORE_Y_POS;
            
            case score_p1 is
                when "0000" => -- 0
                    if (rel_x <= 5 or rel_x >= 35 or rel_y <= 5 or rel_y >= 55) and
                       not ((rel_x >= 6 and rel_x <= 34) and (rel_y >= 25 and rel_y <= 35)) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0001" => -- 1
                    if (rel_x >= 15 and rel_x <= 25) or
                       (rel_y >= 55 and rel_x >= 5 and rel_x <= 35) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0010" => -- 2
                 if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y >= 30) or
                       (rel_x >= 35 and rel_y <= 30) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                    
                when "0011" => -- 3
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x >= 35) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0100" => -- 4
                    if (rel_y >= 25 and rel_y <= 35) or
                       (rel_x >= 35) or
                       (rel_x <= 5 and rel_y <= 35) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0101" => -- 5
                   if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y <= 30) or
                       (rel_x >= 35 and rel_y >= 30) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0110" => -- 6
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5) or
                       (rel_x >= 35 and rel_y >= 30) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "0111" => -- 7
                    if (rel_y <= 5) or
                       (rel_x >= 35) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "1000" => -- 8
                    if (rel_x <= 5 or rel_x >= 35 or rel_y <= 5 or rel_y >= 55 or
                       (rel_y >= 25 and rel_y <= 35)) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when "1001" => -- 9
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y <= 35) or
                       (rel_x >= 35) then
                        digit_pixel_p1 <= '1';
                    end if;
                    
                when others =>
                    digit_pixel_p1 <= '0';
            end case;
        end if;
    end process;

    --meme logique que precedemmment
    process(pixel_x, pixel_y, score_p2)
        variable rel_x : integer;
        variable rel_y : integer;
    begin
        digit_pixel_p2 <= '0';
        if display_score_p2 = '1' then
            rel_x := to_integer(pixel_x) - (P2_SCORE_X - SCORE_WIDTH/2);
            rel_y := to_integer(pixel_y) - SCORE_Y_POS;
            
            case score_p2 is
                when "0000" => -- 0
                    if (rel_x <= 5 or rel_x >= 35 or rel_y <= 5 or rel_y >= 55) and
                       not ((rel_x >= 6 and rel_x <= 34) and (rel_y >= 25 and rel_y <= 35)) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0001" => -- 1
                    if (rel_x >= 15 and rel_x <= 25) or
                       (rel_y >= 55 and rel_x >= 5 and rel_x <= 35) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0010" => -- 2
                     if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y >= 30) or
                       (rel_x >= 35 and rel_y <= 30) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0011" => -- 3
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x >= 35) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0100" => -- 4
                    if (rel_y >= 25 and rel_y <= 35) or
                       (rel_x >= 35) or
                       (rel_x <= 5 and rel_y <= 35) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0101" => -- 5
                  
                    
                     if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y <= 30) or
                       (rel_x >= 35 and rel_y >= 30) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0110" => -- 6
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5) or
                       (rel_x >= 35 and rel_y >= 30) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "0111" => -- 7
                    if (rel_y <= 5) or
                       (rel_x >= 35) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "1000" => -- 8
                    if (rel_x <= 5 or rel_x >= 35 or rel_y <= 5 or rel_y >= 55 or
                       (rel_y >= 25 and rel_y <= 35)) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when "1001" => -- 9
                    if (rel_y <= 5) or
                       (rel_y >= 25 and rel_y <= 35) or
                       (rel_y >= 55) or
                       (rel_x <= 5 and rel_y <= 35) or
                       (rel_x >= 35) then
                        digit_pixel_p2 <= '1';
                    end if;
                    
                when others =>
                    digit_pixel_p2 <= '0';
            end case;
        end if;
    end process;

    --processuce principale
    process(clk)
    begin
        if rising_edge(clk) then
            -- foond noir
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";
            
            
            if pixel_x < SCREEN_WIDTH and pixel_y < SCREEN_HEIGHT then
                
                -- deco raquette joueur 
                if (pixel_x >= 20) and (pixel_x < 20 + PADDLE_WIDTH) and
                   (pixel_y >= paddle1_y) and (pixel_y < paddle1_y + PADDLE_HEIGHT) then
                    red   <= "1111";
                    green <= "1111";
                    blue  <= "1111";
                    
                -- raquette deco , IA 
                elsif (pixel_x >= SCREEN_WIDTH - 30) and (pixel_x < SCREEN_WIDTH - 30 + PADDLE_WIDTH) and
                      (pixel_y >= paddle2_y) and (pixel_y < paddle2_y + PADDLE_HEIGHT) then
                    red   <= "1111";
                    green <= "1111";
                    blue  <= "1111";
                    
                -- ball
                elsif (pixel_x >= ball_x) and (pixel_x < ball_x + BALL_SIZE) and
                      (pixel_y >= ball_y) and (pixel_y < ball_y + BALL_SIZE) then
                    red   <= "1111";
                    green <= "1111";
                    blue  <= "1111";
                    
                -- milieu
                elsif (pixel_x >= SCREEN_WIDTH/2 - 2) and (pixel_x <= SCREEN_WIDTH/2 + 2) and
                      ((pixel_y mod 32) <= 16) then
                    red   <= "0111";
                    green <= "0111";
                    blue  <= "0111";
                    
                -- score joueur 1
                elsif digit_pixel_p1 = '1' then
                    red   <= "1111";
                    green <= "0000";
                    blue  <= "0000";
                    
                -- score IA
                elsif digit_pixel_p2 = '1' then
                    red   <= "1111";
                    green <= "0000";
                    
                    blue  <= "0000";
                end if;
            end if;
            
        end if;
    end process;

end Behavioral;