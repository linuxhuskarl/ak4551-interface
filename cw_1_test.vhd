library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY cw_1_test IS
END cw_1_test;

ARCHITECTURE Behavioral OF cw_1_test IS 
	component cw_1 is
		Port ( clk : in  STD_LOGIC;
			push_s3: in  STD_LOGIC;
			lrck : out  STD_LOGIC;
			sclk : out  STD_LOGIC;
			mclk : out  STD_LOGIC;
			sdout : in  STD_LOGIC;
			sdin : out  STD_LOGIC;
			led : out STD_LOGIC_VECTOR(7 downto 0));
	end component;
	signal clk_i :  STD_LOGIC := '0'; -- main clk, 50 MHz
	signal rst_i :  STD_LOGIC := '0'; -- async reset
	signal lrck :   STD_LOGIC; -- 97.66 kHz 
	signal sclk :   STD_LOGIC; -- 3.125 MHz
	signal mclk :   STD_LOGIC; -- 12.5 MHz
	signal sdout :  STD_LOGIC := '0'; -- serial data from codec
	signal sdin :   STD_LOGIC; -- serial data to codec
	signal din :  	 STD_LOGIC_VECTOR(19 downto 0) := x"aaaaa"; -- parallel data to codec
	signal led :  	 STD_LOGIC_VECTOR(7 downto 0); -- parallel data to codec
BEGIN
	uut: cw_1 PORT MAP(clk_i, rst_i, lrck, sclk, mclk, sdout, sdin, led);
	
	tb : PROCESS BEGIN
		rst_i <= '0', '1' after 100 ns;
		wait;
	END PROCESS tb;
	
	clk: PROCESS BEGIN
		clk_i <= not clk_i;
		wait for 10 ns;
	END PROCESS;
	
	sdata: PROCESS BEGIN
		wait on lrck;
		din <= din + 1; 
		for I in din'range loop
			sdout <= din(I);
			wait until falling_edge(sclk);
		end loop;
		sdout <= '0';
	END PROCESS;
END;
