----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2025 18:19:24
-- Design Name: 
-- Module Name: display_controller - Behavioral
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

entity display_controller is
    Port (
        clk : in STD_LOGIC;       
        reset : in STD_LOGIC;     
        digit0 : in STD_LOGIC_VECTOR(3 downto 0);  
        digit1 : in STD_LOGIC_VECTOR(3 downto 0); 
        digit2 : in STD_LOGIC_VECTOR(3 downto 0); 
        digit3 : in STD_LOGIC_VECTOR(3 downto 0);  
        an : out STD_LOGIC_VECTOR(3 downto 0);     
        seg : out STD_LOGIC_VECTOR(7 downto 0)     
    );
end display_controller;

architecture Behavioral of display_controller is
    -- signaux
    signal display_count : integer range 0 to 3 := 0;
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);
    
    -- fonction pour convertir un chiffre en code 7 segments
    function hex_to_7seg(hex: STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case hex is
            when "0000" => return "11000000"; -- 0 
            when "0001" => return "11111001"; -- 1
            when "0010" => return "10100100"; -- 2
            when "0011" => return "10110000"; -- 3
            when "0100" => return "10011001"; -- 4
            when "0101" => return "10010010"; -- 5
            when "0110" => return "10000010"; -- 6
            when "0111" => return "11111000"; -- 7
            when "1000" => return "10000000"; -- 8
            when "1001" => return "10010000"; -- 9
            when others => return "11111111"; -- touot est eteint
        end case;
    end function;
    
begin
    -- multiplexage des afficheurs
    process(clk, reset)
    begin
        if reset = '1' then
            display_count <= 0;
        elsif rising_edge(clk) then
            if display_count = 3 then
                display_count <= 0;
            else
                display_count <= display_count + 1;
            end if;
        end if;
    end process;
    
    -- sélection de l'afficheur actif et du chiffre à afficher
    process(display_count, digit0, digit1, digit2, digit3)
    begin
        case display_count is
            when 0 =>
                an <= "1110";  -- activer l'afficheur 0 ( unités secondes)
                current_digit <= digit0;
            when 1 =>
                an <= "1101";  -- activer l'afficheur 1 (dizaines secondes)
                current_digit <= digit1;
            when 2 =>
                an <= "1011";  -- activer l'afficheur 2 ( unités minutes )
                current_digit <= digit2;
            when 3 =>
                an <= "0111";  -- activer l'afficheur 3(dizaines minutes)
                current_digit <= digit3;
            when others =>
                an <= "1111";  -- tous les afficheurs désactivés
                current_digit <= "0000";
        end case;
    end process;
    
    -- conversion pour affichage 
    process(display_count, current_digit)
begin
    if display_count = 2 then  -- condition 
        seg <= hex_to_7seg(current_digit) and "01111111"; 
    else
        seg <= hex_to_7seg(current_digit);  
    end if;
end process;
    
end Behavioral;