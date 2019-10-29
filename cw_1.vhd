library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity cw_1 is
    Port ( clk : in  STD_LOGIC;
			  push_s3: in  STD_LOGIC;
           lrck : out  STD_LOGIC;
           sclk : out  STD_LOGIC;
           mclk : out  STD_LOGIC;
           sdout : in  STD_LOGIC;
           sdin : out  STD_LOGIC;
			  led : out STD_LOGIC_VECTOR(7 downto 0));
end cw_1;

architecture Behavioral of cw_1 is
	component ak4551_interface
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
	end component;
	signal din : STD_LOGIC_VECTOR(19 downto 0);
	signal dout : STD_LOGIC_VECTOR(19 downto 0);
	signal din_abs : STD_LOGIC_VECTOR(19 downto 0);
	signal r_strobe : STD_LOGIC;
	signal w_strobe : STD_LOGIC;
begin
	ak4551 : ak4551_interface port map (clk, push_s3, lrck, sclk, mclk, sdout, sdin, din, dout, r_strobe, w_strobe);
	
	process(clk, push_s3) begin
		if(push_s3 = '0') then
			din <= x"00000";
		elsif(rising_edge(clk)) then
			if(w_strobe = '1') then
				din <= dout;
			end if;
		end if;
	end process;
	led <= din_abs(19 downto 12);
	din_abs <= abs(signed(din));
	--led(7) <= din(19);
	--led(6) <= din(17);
	--led(5) <= din(15);
	--led(4) <= din(13);
	--led(3) <= din(11);
	--led(2) <= din(9);
	--led(1) <= din(7);
	--led(0) <= din(5);
end Behavioral;

