----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.04.2025 19:20:07
-- Design Name: 
-- Module Name: chenillard - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity chenillard is
    Port (
        clk : in STD_LOGIC;
        leds : out STD_LOGIC_VECTOR(15 downto 0)  -- 16 LED
    );
end chenillard;

-- signaux internes : tempo pour le délai, index pour la led active, et registre pour les leds


architecture Behavioral of chenillard is
    signal tempo     : integer := 0;
    signal index     : integer range 0 to 15 := 0;
    signal leds_reg  : std_logic_vector(15 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if tempo = 50_000_000 then  -- temporisation ? 1 seconde (si clk = 100 MHz)
                tempo <= 0;

                if index = 15 then
                    index <= 0;
                else
                    index <= index + 1;
                end if;

            else
                tempo <= tempo + 1;
            end if;
        end if;
    end process;

    -- processus qui allume une seule led en fonction de l'index
    process(index)
    begin
        leds_reg <= (others => '0');
        leds_reg(index) <= '1';
    end process;
    
-- on envoie l'état final des leds en sortie

    leds <= leds_reg;

end Behavioral;

