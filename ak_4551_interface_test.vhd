-- TestBench Template 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ak4551_interface_test IS
END ak4551_interface_test;

ARCHITECTURE Behavioral OF ak4551_interface_test IS 
	COMPONENT ak4551_interface
		Port ( clk_i : in  STD_LOGIC; -- main clk, 50 MHz
			rst_i : in  STD_LOGIC; -- async reset
			lrck : out  STD_LOGIC; -- 97.66 kHz 
			sclk : out  STD_LOGIC; -- 3.125 MHz
			mclk : out  STD_LOGIC; -- 12.5 MHz
			sdout : in  STD_LOGIC; -- serial data from codec
			sdin : out  STD_LOGIC; -- serial data to codec
			din : 	in  STD_LOGIC_VECTOR(19 downto 0); -- parallel data to codec
			dout : out  STD_LOGIC_VECTOR(19 downto 0); -- parallel data from codec
			r_strobe : out STD_LOGIC; -- read protection signal
			w_strobe : out STD_LOGIC -- new data written signal
		);
	END COMPONENT;
	signal clk_i :  STD_LOGIC := '0'; -- main clk, 50 MHz
	signal rst_i :  STD_LOGIC := '0'; -- async reset
	signal lrck :   STD_LOGIC; -- 97.66 kHz 
	signal sclk :   STD_LOGIC; -- 3.125 MHz
	signal mclk :   STD_LOGIC; -- 12.5 MHz
	signal sdout :  STD_LOGIC := '0'; -- serial data from codec
	signal sdin :   STD_LOGIC; -- serial data to codec
	signal din :  	 STD_LOGIC_VECTOR(19 downto 0) := x"aaaaa"; -- parallel data to codec
	signal dout :   STD_LOGIC_VECTOR(19 downto 0); -- parallel data fr
	signal r_strobe : STD_LOGIC; -- read/write protection signal
	signal w_strobe : STD_LOGIC; -- read/write protection signal
BEGIN
	uut: ak4551_interface PORT MAP(clk_i, rst_i, lrck, sclk, mclk, sdout, sdin, din, dout, r_strobe, w_strobe);
	tb : PROCESS BEGIN
		rst_i <= '0';
		wait for 100 ns;
		rst_i <= '1';
		wait;
	END PROCESS tb;
	clk: PROCESS BEGIN
		clk_i <= not clk_i;
		wait for 10 ns;
	END PROCESS;
	data: PROCESS(r_strobe) BEGIN
		if(falling_edge(r_strobe)) then din <= din + 1; end if;
	END PROCESS;
	sdata: PROCESS BEGIN
		wait on lrck; 
		for I in din'range loop
			sdout <= din(I);
			wait until falling_edge(sclk);
		end loop;
		sdout <= '0';
	END PROCESS;
END;
