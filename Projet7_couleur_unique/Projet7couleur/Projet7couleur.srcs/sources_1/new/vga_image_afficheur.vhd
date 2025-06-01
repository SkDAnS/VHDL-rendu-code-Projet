
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_image_afficheur is
    Port ( 
        clk    : in  STD_LOGIC;                    
        reset  : in  STD_LOGIC;                    
        hsync  : out STD_LOGIC;                    
        vsync  : out STD_LOGIC;                    
        red    : out STD_LOGIC_VECTOR(3 downto 0); 
        green  : out STD_LOGIC_VECTOR(3 downto 0); 
        blue   : out STD_LOGIC_VECTOR(3 downto 0)  
    );
end vga_image_afficheur;

architecture Behavioral of vga_image_afficheur is

    component vga_controller_640_60
        Port (
            rst       : in  STD_LOGIC;
            pixel_clk : in  STD_LOGIC;
            HS        : out STD_LOGIC;
            VS        : out STD_LOGIC;
            hcount    : out STD_LOGIC_VECTOR(10 downto 0);
            vcount    : out STD_LOGIC_VECTOR(10 downto 0);
            blank     : out STD_LOGIC
        );
    end component;

    signal video_on : STD_LOGIC;
    signal clk_div : std_logic := '0';
    signal clk_cnt : unsigned(1 downto 0) := "00";


begin

-- processus pour diviser l'horloge principale (genre passer de 100 MHz à 25 MHz)

    process(clk)
    begin
        if rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
            if clk_cnt = "11" then
                clk_div <= not clk_div;
            end if;
        end if;
    end process;

-- instanciation du contrôleur VGA pour générer les signaux de synchronisation
    vga_sync_gen: vga_controller_640_60
        port map (
            rst       => reset,
            pixel_clk => clk_div,
            HS        => hsync,
            VS        => vsync,
            blank     => video_on
        );

    process(clk)
    
    -- processus qui affiche du bleu quand on est dans la zone visible, sinon écran noir
    
    begin
        if rising_edge(clk) then
            if video_on = '0' then 
                red   <= "0000"; green <= "0000"; blue  <= "1111"; -- bleu
            else
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;