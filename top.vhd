
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity top is
generic(
c_clkfreq			:integer :=100_000_000;
c_baudrate			:integer :=115_200;
c_stopbit			:integer :=2
);
port(
clk			:in std_logic;
sw_i		:in std_logic_vector(3 downto 0);
btn_i		:in std_logic;
tx_o		:out std_logic
);
end top;

architecture Behavioral of top is

--component------------
component debounce is
generic (
c_clkfreq	: integer := 100_000_000;
c_debtime	: integer := 1000;
c_initval	: std_logic	:= '0'
);
port (
clk			: in std_logic;
signal_i	: in std_logic;
signal_o	: out std_logic
);
end component;

component uart_tx is
generic(
c_clkfreq			:integer :=100_000_000;
c_baudrate			:integer :=115_200;
c_stopbit			:integer :=2
);
port(
clk					:in std_logic;
din_i				:in std_logic_vector(7 downto 0);
tx_start_i			:in std_logic;
tx_o				:out std_logic;
tx_done_tick_o		:out std_logic
);
end component;
------------------------

--signal------------
signal btn_deb 		:std_logic:='0';
signal sw_y			:std_logic_vector(7 downto 0) := (others=>'0');
signal tx_start		:std_logic:='0';
signal tx_done_tick	:std_logic:='0';
signal btn_deb_next :std_logic:='0';
	
begin
sw_y(7 downto 4) <= sw_i;
sw_y(3 downto 0) <= sw_i;

i_deb: debounce
generic map(
c_clkfreq	=>c_clkfreq,
c_debtime	=> 1000,
c_initval	=> '0'
)
port map(
clk			=> clk,
signal_i	=> btn_i,
signal_o	=> btn_deb
);


i_uart:uart_tx
generic map(
c_clkfreq			=> c_clkfreq	,
c_baudrate			=> c_baudrate	,
c_stopbit			=> c_stopbit	
)
port map(
clk					=> clk,
din_i				=> sw_y,
tx_start_i			=> tx_start,
tx_o				=> tx_o,
tx_done_tick_o		=> tx_done_tick
);


P_MAIN: process(clk) begin
if(rising_edge(clk)) then
	btn_deb_next <= btn_deb;
	
	if(btn_deb ='1' and btn_deb_next='0')then
		tx_start <= '1';
	
	end if;

end if;
end process;

end Behavioral;
