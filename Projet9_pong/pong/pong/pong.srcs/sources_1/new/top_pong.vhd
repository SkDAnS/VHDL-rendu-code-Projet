library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_pong is
    Port (
        clk100    : in  std_logic;  -- 100 MHz 
        reset     : in  std_logic;
        btnD      : in  std_logic;  -- joueur 1 bas
        btnU      : in  std_logic;  -- joueur 1 haut
        hsync     : out std_logic;
        vsync     : out std_logic;
        vga_red   : out std_logic_vector(3 downto 0);
        vga_green : out std_logic_vector(3 downto 0);
        vga_blue  : out std_logic_vector(3 downto 0)
    );
end top_pong;

architecture Behavioral of top_pong is
    -- 25 MHz 
    signal clk25       : std_logic;
    
    -- vga control du signal
    signal column      : std_logic_vector(9 downto 0);
    signal row         : std_logic_vector(9 downto 0);
    signal disp_ena    : std_logic;
    
    --position de la balle
    signal ball_x      : unsigned(9 downto 0);
    signal ball_y      : unsigned(9 downto 0);
    signal paddle1_y   : unsigned(9 downto 0); -- Player 1 (left)
    signal paddle2_y   : unsigned(9 downto 0); -- AI (right)
    
    -- score
    signal score_p1 : unsigned(3 downto 0);
    signal score_p2 : unsigned(3 downto 0);

    
    component clk_divider is
        Port (
            clk_in  : in  std_logic;
            reset   : in  std_logic;
            clk_out : out std_logic
        );
    end component;

    component paddle_control is
        Port(
            clk       : in std_logic;
            reset     : in std_logic;
            btnL      : in std_logic;
            btnU      : in std_logic;
            ball_x    : in unsigned(9 downto 0);
            ball_y    : in unsigned(9 downto 0);
            paddle1_y : out unsigned(9 downto 0);
            paddle2_y : out unsigned(9 downto 0)
        );
    end component;

    component ball is
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
    end component;

    component vga_controller_640_60 is
        Port (
            pixel_clk : in  std_logic;
            reset     : in  std_logic;
            h_sync    : out std_logic;
            v_sync    : out std_logic;
            disp_ena  : out std_logic;
            column    : out std_logic_vector(9 downto 0);
            row       : out std_logic_vector(9 downto 0)
        );
    end component;

    component vga_display is
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
    end component;

begin
    -- 100 MHz -> 25 MHz
    clk_div_inst : clk_divider
        port map (
            clk_in  => clk100,
            reset   => reset,
            clk_out => clk25
        );

    -- controle raquette  (Player 1 + AI)
    paddles_inst : paddle_control
        port map (
            clk       => clk25,
            reset     => reset,
            btnL      => btnD, 
            btnU      => btnU,  
            ball_x    => ball_x,
            ball_y    => ball_y,
            paddle1_y => paddle1_y,
            paddle2_y => paddle2_y
        );

    -- balle
    ball_inst : ball
        port map (
            clk           => clk25,
            reset         => reset,
            y_paddleLeft  => paddle1_y,
            y_paddleRight => paddle2_y,
            ball_x        => ball_x,
            ball_y        => ball_y,
            score_p1      => score_p1,
            score_p2      => score_p2
        );

    -- VGA 
    vga_ctrl_inst : vga_controller_640_60
        port map (
            pixel_clk => clk25,
            reset     => reset,
            h_sync    => hsync,
            v_sync    => vsync,
            disp_ena  => disp_ena,
            column    => column,
            row       => row
        );
    

    display_inst : vga_display
        port map (
            clk         => clk25,
            reset       => reset,
            pixel_x     => unsigned(column),
            pixel_y     => unsigned(row),
            ball_x      => ball_x,
            ball_y      => ball_y,
            paddle1_y   => paddle1_y,
            paddle2_y   => paddle2_y,
            score_p1    => score_p1,
            score_p2    => score_p2,
            red         => vga_red,
            green       => vga_green,
            blue        => vga_blue
        );

end Behavioral;