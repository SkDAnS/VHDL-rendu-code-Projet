----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.04.2025 18:51:35
-- Design Name: 
-- Module Name: afficheur_4digits - Behavioral
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

entity afficheur_4digits is
    Port (
        clk  : in  STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(3 downto 0);     -- AN0 à AN3
        seg  : out STD_LOGIC_VECTOR(7 downto 0)      -- CA à CG 
    );
end afficheur_4digits;

architecture Behavioral of afficheur_4digits is
    signal tempo : integer := 0;
    signal digit_sel        : integer range 0 to 3 := 0;
    
begin
    
    
-- processus qui change rapidement de chiffre actif (multiplexage visuel)
-- à chaque tempo atteint, on passe au chiffre suivant
    
    process(clk)
    begin
        if rising_edge(clk) then
            if tempo = 99_999 then 
                tempo <= 0;
                if digit_sel = 3 then
                    digit_sel <= 0;
                else
                    digit_sel <= digit_sel + 1;
                end if;
            else
                tempo <= tempo + 1;
            end if;
        end if;
    end process;

    -- processus qui active une seule anode à la fois (logique inversée)

    process(digit_sel)
    begin
        case digit_sel is
            when 0 => an <= "1110";  -- AN0 actif
            when 1 => an <= "1101";  -- AN1
            when 2 => an <= "1011";  -- AN2
            when 3 => an <= "0111";  -- AN3
            when others => an <= "1111";
        end case;
    end process;

    
    -- Format: "pgfedcba" et p signifie le point 
    -- on affiche toujours le chiffre 3 sur tous les digits
    -- (0 = allumé pour les segments)
    seg <= "10110000";

end Behavioral;