----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2025 18:30:31
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
        seg  : out STD_LOGIC_VECTOR(7 downto 0)      -- CA à CG + DP
    );
end afficheur_4digits;

architecture Behavioral of afficheur_4digits is
    signal refresh_counter : integer := 0;
    signal digit_sel        : integer range 0 to 3 := 0;
    signal digit_val        : integer range 0 to 9;
    signal seg_val          : STD_LOGIC_VECTOR(7 downto 0);
begin

    -- Gestion du multiplexage
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_counter = 99_999 then
                refresh_counter <= 0;
                if digit_sel = 3 then
                    digit_sel <= 0;
                else
                    digit_sel <= digit_sel + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    -- Sélection des anodes
    process(digit_sel)
    begin
        case digit_sel is
            when 0 => an <= "1110";  -- AN0 
            when 1 => an <= "1101";  -- AN1
            when 2 => an <= "1011";  -- AN2
            when 3 => an <= "0111";  -- AN3
            when others => an <= "1111";
        end case;
    end process;

    -- Valeur du chiffre selon digit actif
    process(digit_sel)
    begin
        case digit_sel is
            when 0 => digit_val <= 4;
            when 1 => digit_val <= 3;
            when 2 => digit_val <= 2;
            when 3 => digit_val <= 1;
            when others => digit_val <= 0;
        end case;
    end process;

    -- Décodage chiffre vers segments (segments actifs à 0)
    -- on traduit le chiffre en code pour les segments (0 = segment allumé)
    process(digit_val)
    begin
        case digit_val is
            when 0 => seg_val <= "11000000"; -- 0
            when 1 => seg_val <= "11111001"; -- 1
            when 2 => seg_val <= "10100100"; -- 2
            when 3 => seg_val <= "10110000"; -- 3
            when 4 => seg_val <= "10011001"; -- 4
            when 5 => seg_val <= "10010010"; -- 5
            when 6 => seg_val <= "10000010"; -- 6
            when 7 => seg_val <= "11111000"; -- 7
            when 8 => seg_val <= "10000000"; -- 8
            when 9 => seg_val <= "10010000"; -- 9
            when others => seg_val <= "11111111"; -- Éteint
        end case;
    end process;

    seg <= seg_val;

end Behavioral;

