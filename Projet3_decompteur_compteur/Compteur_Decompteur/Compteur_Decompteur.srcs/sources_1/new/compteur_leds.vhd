----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.04.2025 20:32:38
-- Design Name: 
-- Module Name: compteur_leds - Behavioral
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

entity compteur_leds is
    Port (
        clk  : in STD_LOGIC;                         -- Horloge 100 MHz
        btnL : in STD_LOGIC;                         -- Bouton gauche (BTNL)
        btnR : in STD_LOGIC;                         -- Bouton droite (BTNR)
        leds : out STD_LOGIC_VECTOR(15 downto 0)     -- 16 LEDs
    );
end compteur_leds;

architecture Behavioral of compteur_leds is
    signal compteur  : integer range 0 to 16 := 0;
    signal tempo     : integer := 0;
    signal leds_reg  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin

-- processus qui regarde les boutons toutes les x cycles pour éviter que ça aille trop vite
-- si on appuie sur gauche, on incrémente le compteur (jusqu'à 16)
-- si on appuie sur droite, on décrémente le compteur (jusqu'à 0)

    process(clk)
    begin
        if rising_edge(clk) then
            if tempo = 10_000_000 then
                tempo <= 0;

                if btnL = '1' then
                    if compteur < 16 then
                        compteur <= compteur + 1;
                    end if;
                end if;

                if btnR = '1' then
                    if compteur > 0 then
                        compteur <= compteur - 1;
                    end if;
                end if;

            else
                tempo <= tempo + 1;
            end if;
        end if;
    end process;

-- processus qui allume les leds en fonction du compteur (par exemple une barre qui se remplit ou se vide)

    process(compteur)
    begin
        for i in 0 to 15 loop
            if i < compteur then
                leds_reg(i) <= '1';
            else
                leds_reg(i) <= '0';
            end if;
        end loop;
    end process;

    leds <= leds_reg;

end Behavioral;


