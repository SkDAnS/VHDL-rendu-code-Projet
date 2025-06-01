library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider is
    Port (
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end clk_divider;

architecture Behavioral of clk_divider is
    signal counter : unsigned(1 downto 0) := (others => '0');
    signal clk_tmp : std_logic := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            clk_tmp <= '0';
        elsif rising_edge(clk_in) then
            counter <= counter + 1;
            if counter = "11" then
                clk_tmp <= not clk_tmp;
                counter <= (others => '0');
            end if;
        end if;
    end process;
    
    clk_out <= clk_tmp;
end Behavioral;
