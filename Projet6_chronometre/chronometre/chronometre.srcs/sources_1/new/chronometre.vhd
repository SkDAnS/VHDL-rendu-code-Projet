----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.04.2025 18:28:57
-- Design Name: 
-- Module Name: chronometre - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity chronometre is
    Port (
        clk : in STD_LOGIC;           -- Horloge 100 MHz
        reset : in STD_LOGIC;         -- Reset du chronomètre
        an : out STD_LOGIC_VECTOR(3 downto 0);  -- anodes des afficheurs
        seg : out STD_LOGIC_VECTOR(7 downto 0)  -- segments des afficheurs 
    );
end chronometre;

architecture Structural of chronometre is
    -- composant permettant de génere 1hz
    component div_1hz is
        Port (
            clk_in : in STD_LOGIC;    
            reset : in STD_LOGIC;     
            clk_out : out STD_LOGIC  
        );
    end component;
    
    --composant qui rafraichie l'afficheur (250hz)
    component div_250hz is
        Port (
            clk_in : in STD_LOGIC;   
            reset : in STD_LOGIC;     
            clk_out : out STD_LOGIC   
        );
    end component;
    
   -- composant qui compte les minutes et secondes
    component time_counter is
        Port (
            clk : in STD_LOGIC;      --1hz
            reset : in STD_LOGIC;     
            sec_unit : out STD_LOGIC_VECTOR(3 downto 0);  -- unités de secondes (0-9)
            sec_ten : out STD_LOGIC_VECTOR(3 downto 0);   -- dizaines de secondes (0-5)
            min_unit : out STD_LOGIC_VECTOR(3 downto 0);  -- unités de minutes (0-9)
            min_ten : out STD_LOGIC_VECTOR(3 downto 0)    -- dizaines de minutes (0-5)
        );
    end component;
    
   -- affichage 7 segment
    component display_controller is
        Port (
            clk : in STD_LOGIC;       -- 250 Hz
            reset : in STD_LOGIC;     
            digit0 : in STD_LOGIC_VECTOR(3 downto 0);  -- digit unités secondes
            digit1 : in STD_LOGIC_VECTOR(3 downto 0);  -- digit dizaines secondes
            digit2 : in STD_LOGIC_VECTOR(3 downto 0);  -- digit unités minutes
            digit3 : in STD_LOGIC_VECTOR(3 downto 0);  -- digit dizaines minutes
            an : out STD_LOGIC_VECTOR(3 downto 0);     -- anodes des afficheurs
            seg : out STD_LOGIC_VECTOR(7 downto 0)     -- segments des afficheurs
        );
    end component;
    
  
    signal clk_1hz : STD_LOGIC;
    signal clk_250hz : STD_LOGIC;
    signal sec_unit, sec_ten, min_unit, min_ten : STD_LOGIC_VECTOR(3 downto 0);
    
begin
    
    U1_DIV_1HZ: div_1hz
        port map (
            clk_in => clk,
            reset => reset,
            clk_out => clk_1hz
        );
    
    U2_DIV_250HZ: div_250hz
        port map (
            clk_in => clk,
            reset => reset,
            clk_out => clk_250hz
        );
    
    U3_TIME_COUNTER: time_counter
        port map (
            clk => clk_1hz,
            reset => reset,
            sec_unit => sec_unit,
            sec_ten => sec_ten,
            min_unit => min_unit,
            min_ten => min_ten
        );
    
    U4_DISPLAY_CONTROLLER: display_controller
        port map (
            clk => clk_250hz,
            reset => reset,
            digit0 => sec_unit,  
            digit1 => sec_ten,  
            digit2 => min_unit,  
            digit3 => min_ten,  
            an => an,
            seg => seg
        );

end Structural;



