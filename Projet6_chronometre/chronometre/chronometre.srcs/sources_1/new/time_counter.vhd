----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2025 18:18:25
-- Design Name: 
-- Module Name: time_counter - Behavioral
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

entity time_counter is
    Port (
        clk : in STD_LOGIC;       
        reset : in STD_LOGIC;     
        sec_unit : out STD_LOGIC_VECTOR(3 downto 0);  
        sec_ten : out STD_LOGIC_VECTOR(3 downto 0);   
        min_unit : out STD_LOGIC_VECTOR(3 downto 0);  
        min_ten : out STD_LOGIC_VECTOR(3 downto 0)    
    );
end time_counter;

architecture Behavioral of time_counter is
    signal sec_unit_cnt : integer range 0 to 9 := 0;
    signal sec_ten_cnt : integer range 0 to 5 := 0;
    signal min_unit_cnt : integer range 0 to 9 := 0;
    signal min_ten_cnt : integer range 0 to 5 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- réinitialisation de tout les compteurs
            sec_unit_cnt <= 0;
            sec_ten_cnt <= 0;
            min_unit_cnt <= 0;
            min_ten_cnt <= 0;
        elsif rising_edge(clk) then
        
            -- logique d'incrémentation des compteurs
            
            
            sec_unit_cnt <= sec_unit_cnt + 1;
            
            if sec_unit_cnt = 9 then
                sec_unit_cnt <= 0;
                sec_ten_cnt <= sec_ten_cnt + 1;
                
                if sec_ten_cnt = 5 then
                    sec_ten_cnt <= 0;
                    min_unit_cnt <= min_unit_cnt + 1;
                    
                    if min_unit_cnt = 9 then
                        min_unit_cnt <= 0;
                        min_ten_cnt <= min_ten_cnt + 1;
                        
                        if min_ten_cnt = 5 then
                            min_ten_cnt <= 0;
                        end if;
                    end if;
                    
                end if;
                
            end if;
        end if;
        
    end process;
    
    -- conversion des compteurs en vecteurs binaires pour la sortie
    sec_unit <= std_logic_vector(to_unsigned(sec_unit_cnt, 4));
    sec_ten <= std_logic_vector(to_unsigned(sec_ten_cnt, 4));
    
    min_unit <= std_logic_vector(to_unsigned(min_unit_cnt, 4));
    min_ten <= std_logic_vector(to_unsigned(min_ten_cnt, 4));
end Behavioral;