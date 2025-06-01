library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller_640_60 is
    Port (
        pixel_clk : in  std_logic;
        reset     : in  std_logic;
        h_sync    : out std_logic;
        v_sync    : out std_logic;
        disp_ena  : out std_logic;
        column    : out std_logic_vector(9 downto 0);
        row       : out std_logic_vector(9 downto 0)
    );
end entity;

architecture Behavioral of vga_controller_640_60 is
    -- VGA 640x480 @ 60Hz parameters
    constant HD  : integer := 640;  -- Horizontal display
    constant HF  : integer := 16;   -- Horizontal front porch
    constant HB  : integer := 48;   -- Horizontal back porch
    constant HR  : integer := 96;   -- Horizontal retrace
    constant VD  : integer := 480;  -- Vertical display
    constant VF  : integer := 10;   -- Vertical front porch
    constant VB  : integer := 33;   -- Vertical back porch
    constant VR  : integer := 2;    -- Vertical retrace

    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');

begin
    -- Horizontal counter
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

    -- Vertical counter
    process(pixel_clk, reset)
    begin
        if reset = '1' then
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

    -- Generate sync signals
    h_sync <= '0' when (h_cnt >= HD + HF) and (h_cnt < HD + HF + HR) else '1';
    v_sync <= '0' when (v_cnt >= VD + VF) and (v_cnt < VD + VF + VR) else '1';
    
    -- Display enable signal
    disp_ena <= '1' when (h_cnt < HD) and (v_cnt < VD) else '0';
    
    -- Output position
    column <= std_logic_vector(h_cnt);
    row <= std_logic_vector(v_cnt);

end architecture;