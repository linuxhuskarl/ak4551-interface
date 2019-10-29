library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ak4551_interface is
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
end ak4551_interface;

architecture Behavioral of ak4551_interface is
	signal count : STD_LOGIC_VECTOR(9 downto 0); -- clock division signal
	signal sdin_sout : STD_LOGIC_VECTOR(31 downto 0); -- sdin output shift register
	signal sdout_sin : STD_LOGIC_VECTOR(31 downto 0); -- stout input shift register
	signal dout_tmp : STD_LOGIC_VECTOR(19 downto 0);
begin
	process (clk_i, rst_i) begin
		if(rst_i = '0') then
			count <= "0000000000";
			sdin_sout <= x"00000000";
			sdout_sin <= x"00000000";
			dout_tmp <= x"00000";
		elsif(rising_edge(clk_i)) then
			count <= count + 1;
			if(count(3 downto 0) = "1111") then -- each sclk falling edge
				if(count(8 downto 0) = "111111111") then -- each lrck edge
					sdin_sout(19 downto 0) <= din;
					sdin_sout(31 downto 20) <= "000000000000";
					dout_tmp <= sdout_sin(31 downto 12);
				end if;
			elsif(count(3 downto 0) = "0111") then -- each sclk rising edge		
				sdin_sout(31 downto 1) <= sdin_sout(30 downto 0);
				sdout_sin(31 downto 1) <= sdout_sin(30 downto 0);
				sdin_sout(0) <= '0';
				sdout_sin(0) <= sdout;
			end if;
		end if;
	end process;
	dout <= dout_tmp;
	mclk <= count(1); -- 50M/4 = 12.5M
	sclk <= count(3); -- 50M/16 = 3.125M
	lrck <= count(9); -- 50M/1024 = 48.83k
	sdin <= sdin_sout(31);
	r_strobe <= '1' when count(8 downto 0) = x"1ff" else '0';
	w_strobe <= '1' when count(8 downto 0) = x"000" else '0';
end Behavioral;

