library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_controller_640_60 is
    Port ( pixel_clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           h_sync : out STD_LOGIC;
           v_sync : out STD_LOGIC;
           display_enable : out STD_LOGIC;
           column : out STD_LOGIC_VECTOR (9 downto 0);
           row : out STD_LOGIC_VECTOR (9 downto 0);
           n_blank : out STD_LOGIC;
           n_sync : out STD_LOGIC);
end vga_controller_640_60;

architecture Behavioral of vga_controller_640_60 is
    -- Constantes pour le timing VGA 640x480 @ 60Hz
    constant h_pixels : STD_LOGIC_VECTOR(9 downto 0) := "1010000000"; -- 640
    constant h_fp : STD_LOGIC_VECTOR(9 downto 0) := "0000010000"; -- 16
    constant h_pulse : STD_LOGIC_VECTOR(9 downto 0) := "0001100000"; -- 96
    constant h_bp : STD_LOGIC_VECTOR(9 downto 0) := "0000110000"; -- 48
    constant h_total : STD_LOGIC_VECTOR(9 downto 0) := "1100010000"; -- 800
    
    constant v_pixels : STD_LOGIC_VECTOR(9 downto 0) := "0111100000"; -- 480
    constant v_fp : STD_LOGIC_VECTOR(9 downto 0) := "0000001010"; -- 10
    constant v_pulse : STD_LOGIC_VECTOR(9 downto 0) := "0000000010"; -- 2
    constant v_bp : STD_LOGIC_VECTOR(9 downto 0) := "0000100001"; -- 33
    constant v_total : STD_LOGIC_VECTOR(9 downto 0) := "1000001101"; -- 525
    
    -- Signaux pour les compteurs
    signal h_count : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal v_count : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    
    -- Signaux pour les synchronisations
    signal h_sync_reg : STD_LOGIC := '0';
    signal v_sync_reg : STD_LOGIC := '0';
    signal h_active : STD_LOGIC := '0';
    signal v_active : STD_LOGIC := '0';
    signal display_enable_reg : STD_LOGIC := '0';
    
begin
    -- Compteur horizontal
    process(pixel_clk, reset)
    begin
        if reset = '1' then
            h_count <= (others => '0');
        elsif rising_edge(pixel_clk) then
            if h_count = h_total - 1 then
                h_count <= (others => '0');
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;
    
    -- Compteur vertical
    process(pixel_clk, reset)
    begin
        if reset = '1' then
            v_count <= (others => '0');
        elsif rising_edge(pixel_clk) then
            if h_count = h_total - 1 then
                if v_count = v_total - 1 then
                    v_count <= (others => '0');
                else
                    v_count <= v_count + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Génération des signaux de synchronisation
    process(pixel_clk, reset)
    begin
        if reset = '1' then
            h_sync_reg <= '0';
            v_sync_reg <= '0';
        elsif rising_edge(pixel_clk) then
            -- Horizontal sync
            if (h_count >= h_pixels + h_fp) and (h_count < h_pixels + h_fp + h_pulse) then
                h_sync_reg <= '0';
            else
                h_sync_reg <= '1';
            end if;
            
            -- Vertical sync
            if (v_count >= v_pixels + v_fp) and (v_count < v_pixels + v_fp + v_pulse) then
                v_sync_reg <= '0';
            else
                v_sync_reg <= '1';
            end if;
        end if;
    end process;
    
    -- Zone active
    h_active <= '1' when h_count < h_pixels else '0';
    v_active <= '1' when v_count < v_pixels else '0';
    display_enable_reg <= h_active and v_active;
    
    -- Sorties
    h_sync <= h_sync_reg;
    v_sync <= v_sync_reg;
    display_enable <= display_enable_reg;
    column <= h_count when h_active = '1' else (others => '0');
    row <= v_count when v_active = '1' else (others => '0');
    n_blank <= '1';  -- Toujours actif pour les DACs VGA
    n_sync <= '0';   -- Pas de synchronisation composite
    
end Behavioral;