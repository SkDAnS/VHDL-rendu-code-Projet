library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_drapeau is
    Port ( 
        clk    : in  STD_LOGIC;                    
        reset  : in  STD_LOGIC;                   
        hsync  : out STD_LOGIC;                   
        vsync  : out STD_LOGIC;                  
        red    : out STD_LOGIC_VECTOR(3 downto 0); 
        green  : out STD_LOGIC_VECTOR(3 downto 0);
        blue   : out STD_LOGIC_VECTOR(3 downto 0)  
    );
end vga_drapeau;

architecture Behavioral of vga_drapeau is

    component vga_controller_640_60
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

    signal col, row : STD_LOGIC_VECTOR(9 downto 0);
    signal video_on : STD_LOGIC;
    signal clk_div : std_logic := '0';
    signal clk_cnt : unsigned(1 downto 0) := "00";


begin

    process(clk)
    begin
        if rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
            if clk_cnt = "11" then
                clk_div <= not clk_div;
            end if;
        end if;
    end process;


    vga_sync_gen: vga_controller_640_60
        port map (
            pixel_clk => clk_div,
            reset     => reset,
            h_sync    => hsync,
            v_sync    => vsync,
            disp_ena  => video_on,
            column    => col,
            row       => row
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if video_on = '1' then
                if to_integer(unsigned(col)) < 213 then
                    red   <= "0000"; green <= "0000"; blue  <= "1111"; -- bleu
                elsif to_integer(unsigned(col)) < 426 then
                    red   <= "1111"; green <= "1111"; blue  <= "1111"; -- blanc
                else
                    red   <= "1111"; green <= "0000"; blue  <= "0000"; -- rouge
                end if;
            else
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
