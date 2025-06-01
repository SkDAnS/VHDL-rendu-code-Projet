----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2025 18:17:40
-- Design Name: 
-- Module Name: div_250hz - Behavioral
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

entity div_250hz is
    Port (
        clk_in : in STD_LOGIC;   
        reset : in STD_LOGIC;     
        clk_out : out STD_LOGIC   
    );
end div_250hz;

architecture Behavioral of div_250hz is
    -- constantes
    constant COUNT_MAX : integer := 199999;  -- valeur pour 2ms à 100MHz (100_000_000/500 - 1)
    
    -- signaux
    signal count : integer range 0 to COUNT_MAX := 0;
    signal temp_clk : STD_LOGIC := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            count <= 0;
            temp_clk <= '0';
        elsif rising_edge(clk_in) then
            if count = COUNT_MAX then
                count <= 0;
                temp_clk <= not temp_clk;  -- inversion du signal d'horloge
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    
    clk_out <= temp_clk;  -- sortie de l'horloge divisée
end Behavioral;
