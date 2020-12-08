library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digitalwatch is
port(
		clk, pb0, pb1: in std_logic;
		mode : in std_logic_vector(3 downto 0);
		datain : in std_logic_vector(5 downto 0);
		d5, d4, d3, d2, d1, d0 : out std_logic_vector(6 downto 0);
		cd_done : out std_logic
		);
end entity digitalwatch;

architecture behavioural of digitalwatch is

type state_type_time is (s0, s1, s2,s3);
signal state_time : state_type_time;

type state_type_date is (s0, s1, s2, s3);
signal state_date : state_type_date;

type state_type_stopwatch is (s0, s1, s2, s3, s4);
signal state_stopwatch : state_type_stopwatch;

type state_type_countdown is (s0, s1, s2,s3,s4,s5,s6);
signal state_countdown : state_type_countdown;

signal data : std_logic_vector(5 downto 0) := "000000";

signal dividedclk : std_logic := '1';

signal hour_t, minute_t, second_t : std_logic_vector(7 downto 0) := "00000000";
signal year, month, day : std_logic_vector(7 downto 0) := "00000000";
signal hour_sw, temphour_sw, minute_sw, tempminute_sw, second_sw, tempsecond_sw : std_logic_vector(7 downto 0) := "00000000";
signal hour_cd, minute_cd, second_cd : std_logic_vector(7 downto 0) := "00000000";

signal sig_d5 : std_logic_vector(3 downto 0) := "0000";
signal sig_d4 : std_logic_vector(3 downto 0) := "0000";
signal sig_d3 : std_logic_vector(3 downto 0) := "0000";
signal sig_d2 : std_logic_vector(3 downto 0) := "0000";
signal sig_d1 : std_logic_vector(3 downto 0) := "0000";
signal sig_d0 : std_logic_vector(3 downto 0) := "0000";

-------------------------------
-- BINARY TO BCD TRANSLATION --
-------------------------------

function to_bcd (bin : std_logic_vector(5 downto 0) := "000000") return std_logic_vector is

variable i : integer := 0;
variable tens : unsigned(3 downto 0)  := "0000";
variable ones : unsigned(3 downto 0)  := "0000";
variable bcdout : std_logic_vector(7 downto 0) := "00000000";
variable funcdata : std_logic_vector(5 downto 0) := bin;

begin

for i in 5 downto 0 loop	
	if (tens > "0101" or tens = "0101") then
		tens := tens + 3;
	end if;
	if (ones > "0101" or ones = "0101") then
		ones := ones + 3;
	end if;
	tens(3 downto 1) := tens(2 downto 0);
	tens(0) := ones(3);
	ones(3 downto 1) := ones(2 downto 0);
	ones(0) := funcdata(i);
end loop;
bcdout := (std_logic_vector(tens) & std_logic_vector(ones));
return bcdout;
end function;

begin

----------------------
-- INPUT CONVERSION --
----------------------

input : process(datain)
	begin
		data <= datain;
	end process;

----------------
-- SEQUENTIAL --
----------------

sequential : process (dividedclk, mode, state_time, state_date, state_stopwatch, state_countdown, pb0, pb1, hour_cd, minute_cd, second_cd)
	begin
		if (dividedclk' event and dividedclk = '1') then
			case (mode) is
			when "0000" =>
				state_time <= s0;
				state_date <= s0;
				state_stopwatch <= s0;
				state_countdown <= s0;
			when "0001" =>
				state_date <= s0;
				state_stopwatch <= s0;
				state_countdown <= s0;
				if (pb1 = '0') then
					state_time <= s0;
				else
					case (state_time) is
					when s0 =>
						if (pb0 = '0') then
							state_time <= s1;
						end if;
					when s1 =>
						if (pb0 = '0') then
							state_time <= s2;
						end if;
					when s2 =>
						if (pb0 = '0') then
							state_time <= s3;
						end if;
					when s3 =>
						if (pb0 = '0') then
							state_time <= s0;
						end if;
					when others =>
					end case;
				end if;
			when "0010" =>
				state_time <= s0;
				state_stopwatch <= s0;
				state_countdown <= s0;
				if (pb1 = '0') then
					state_date <= s0;
				else
					case (state_date) is
					when s0 =>
						if (pb0 = '0') then
							state_date <= s1;
						end if;
					when s1 =>
						if (pb0 = '0') then
							state_date <= s2;
						end if;
					when s2 =>
						if (pb0 = '0') then
							state_date <= s3;
						end if;
					when s3 =>
						if (pb0 = '0') then
							state_date <= s0;
						end if;
					when others =>
					end case;
				end if;
			when "0100" =>
				state_time <= s0;
				state_date <= s0;
				state_countdown <= s0;
				case (state_stopwatch) is
				when s0 =>
					if (pb0 = '0') then
						state_stopwatch <= s1;
					end if;
				when s1 =>
					if (pb0 = '0') then
						state_stopwatch <= s3;
					end if;
					if (pb1 = '0') then
						state_stopwatch <= s2;
					end if;
				when s2 =>
					if (pb1 = '0') then
						state_stopwatch <= s0;
					end if;
				when s3 =>
					if (pb1 = '0') then
						state_stopwatch <= s4;
					end if;
				when s4 =>
					if (pb1 = '0') then
						state_stopwatch <= s0;
					end if;
				when others =>
				end case;
			when "1000" =>
				state_time <= s0;
				state_date <= s0;
				state_stopwatch <= s0;
				case (state_countdown) is
				when s0 =>
					if (pb0 = '0') then
						state_countdown <= s1;
					end if;
				when s1 =>
					if (pb0 = '0') then
						state_countdown <= s2;
					end if;
				when s2 =>
					if (pb0 = '0') then
						state_countdown <= s3;
					end if;
				when s3 =>
					if (pb0 = '0') then
						state_countdown <= s4;
					end if;
				when s4 =>
					if (pb0 = '0') then
						state_countdown <= s5;
					end if;
				when s5 =>
					if (pb1 = '0') then
						state_countdown <= s4;
					end if;
					if (hour_cd = "00000000" and minute_cd = "00000000" and second_cd = "00000000") then
						state_countdown <= s6;
					end if;
				when s6 =>
					if (pb0 = '0') then
						state_countdown <= s0;
					end if;
				when others =>
				end case;
			when others =>
			end case;
		end if;
	end process;

-------------------
-- DATE AND TIME --
-------------------

combinational : process (dividedclk, mode, state_time, state_date, state_stopwatch, state_countdown, pb0, pb1, hour_t, minute_t, second_t, year, month, day, datain, hour_sw, minute_sw, second_sw, temphour_sw, tempminute_sw, tempsecond_sw, hour_cd, minute_cd, second_cd)
	begin
		if (dividedclk' event and dividedclk = '1' and mode = "0001") then
			if (pb1 = '0') then
				hour_t <= "00000000";
				minute_t <= "00000000";
				second_t <= "00000000";
			else
				case (state_time) is
				when s0 =>	
				when s1 =>
					hour_t <= to_bcd(bin => data);
				when s2 =>
					minute_t <= to_bcd(bin => data);
				when s3 =>
					second_t <= to_bcd(bin => data);
				when others =>
				end case;
			end if;
		elsif (dividedclk' event and dividedclk = '1' and mode = "0010") then
			if (pb1 = '0') then
				year <= "00000000";
				month <= "00000000";
				day <= "00000000";
			else
				case (state_date) is
				when s0 =>
				when s1 =>
					year <= to_bcd(bin => data);
				when s2 =>
					month <= to_bcd(bin => data);
				when s3 =>
					day <= to_bcd(bin => data);
				when others =>
				end case;
			end if;
		elsif (dividedclk' event and dividedclk = '1') then
			if (year(7 downto 4) = "1001" and year(3 downto 0) = "1001" and month(7 downto 4) = "0001" and month(3 downto 0) = "0010" and day(7 downto 4) = "0011" and day(3 downto 0) = "0000" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				year(7 downto 4) <= "0000";
				year(3 downto 0) <= "0000";
				month (7 downto 4) <= "0000";
				month(3 downto 0) <= "0000";
				day(7 downto 4) <= "0000";
				day(3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (year(3 downto 0) = "1001" and month(7 downto 4) = "0001" and month(3 downto 0) = "0010" and day(7 downto 4) = "0011" and day(3 downto 0) = "0000" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				year(7 downto 4) <= std_logic_vector(unsigned(year(7 downto 4)) + "0001");
				year(3 downto 0) <= "0000";
				month (7 downto 4) <= "0000";
				month(3 downto 0) <= "0000";
				day(7 downto 4) <= "0000";
				day(3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (month(7 downto 4) = "0001" and month(3 downto 0) = "0010" and day(7 downto 4) = "0011" and day(3 downto 0) = "0000" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				year(3 downto 0) <= std_logic_vector(unsigned(year(3 downto 0)) + "0001");
				month (7 downto 4) <= "0000";
				month(3 downto 0) <= "0000";
				day(7 downto 4) <= "0000";
				day(3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (month(3 downto 0) = "1001" and day(7 downto 4) = "0011" and day(3 downto 0) = "0000" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				month (7 downto 4) <= std_logic_vector(unsigned(month(7 downto 4)) + "0001");
				month(3 downto 0) <= "0000";
				day(7 downto 4) <= "0000";
				day(3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (day(7 downto 4) = "0011" and day(3 downto 0) = "0000" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				month(3 downto 0) <= std_logic_vector(unsigned(month(3 downto 0)) + "0001");
				day(7 downto 4) <= "0000";
				day(3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (day(3 downto 0) = "1001" and hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				day(7 downto 4) <= std_logic_vector(unsigned(day(7 downto 4)) + "0001");
				day (3 downto 0) <= "0000";
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (hour_t(7 downto 4) = "0010" and hour_t(3 downto 0) = "0011" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				day(3 downto 0) <= std_logic_vector(unsigned(day(3 downto 0)) + "0001");
				hour_t(7 downto 4) <= "0000";
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (hour_t(3 downto 0) = "1001" and minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				hour_t(7 downto 4) <= std_logic_vector(unsigned(hour_t(7 downto 4)) + "0001");
				hour_t(3 downto 0) <= "0000";
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (minute_t(7 downto 4) = "0101" and minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				hour_t(3 downto 0) <= std_logic_vector(unsigned(hour_t(3 downto 0)) + "0001");
				minute_t(7 downto 4) <= "0000";
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (minute_t(3 downto 0) = "1001" and second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				minute_t(7 downto 4) <= std_logic_vector(unsigned(minute_t(7 downto 4)) + "0001");
				minute_t(3 downto 0) <= "0000";
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (second_t(7 downto 4) = "0101" and second_t(3 downto 0) = "1001") then
				minute_t(3 downto 0) <= std_logic_vector(unsigned(minute_t(3 downto 0)) + "0001");
				second_t(7 downto 4) <= "0000";
				second_t(3 downto 0) <= "0000";
			elsif (second_t(3 downto 0) = "1001") then
				second_t(7 downto 4) <= std_logic_vector(unsigned(second_t(7 downto 4)) + "0001");
				second_t(3 downto 0) <= "0000";
			else
				second_t(3 downto 0) <= std_logic_vector(unsigned(second_t(3 downto 0)) + "0001");
			end if;
		end if;
	end process;

----------------
-- STOPWATCH  --
----------------

stopwatch : process (dividedclk, mode, hour_t, minute_t, second_t, year, month, day, hour_sw, minute_sw, second_sw, temphour_sw, tempminute_sw, tempsecond_sw, hour_cd, minute_cd, second_cd)
	begin
		if (dividedclk' event and dividedclk = '1' and mode = "0100") then
			case (state_stopwatch) is
			when s0 =>
				hour_sw <= "00000000";
				minute_sw <= "00000000";
				second_sw <= "00000000";
				temphour_sw <= "00000000";
				tempminute_sw <= "00000000";
				tempsecond_sw <= "00000000";
			when s1 =>
				if (pb0 = '0') then
					temphour_sw <= hour_sw;
					tempminute_sw <= minute_sw;
					tempsecond_sw <= second_sw;
					hour_sw <= "00000000";
					minute_sw <= "00000000";
					second_sw <= "00000000";
				else
					if (hour_sw(7 downto 4) = "0010" and hour_sw(3 downto 0) = "0011" and minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
						hour_sw(7 downto 4) <= "0000";
						hour_sw(3 downto 0) <= "0000";
						minute_sw(7 downto 4) <= "0000";
						minute_sw(3 downto 0) <= "0000";
						second_sw(7 downto 4) <= "0000";
						second_sw(3 downto 0) <= "0000";
					elsif (hour_sw(3 downto 0) = "1001" and minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
						hour_sw(7 downto 4) <= std_logic_vector(unsigned(hour_sw(7 downto 4)) + "0001");
						hour_sw(3 downto 0) <= "0000";
						minute_sw(7 downto 4) <= "0000";
						minute_sw(3 downto 0) <= "0000";
						second_sw(7 downto 4) <= "0000";
						second_sw(3 downto 0) <= "0000";
					elsif (minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
						hour_sw(3 downto 0) <= std_logic_vector(unsigned(hour_sw(3 downto 0)) + "0001");
						minute_sw(7 downto 4) <= "0000";
						minute_sw(3 downto 0) <= "0000";
						second_sw(7 downto 4) <= "0000";
						second_sw(3 downto 0) <= "0000";
					elsif (minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
						minute_sw(7 downto 4) <= std_logic_vector(unsigned(minute_sw(7 downto 4)) + "0001");
						minute_sw(3 downto 0) <= "0000";
						second_sw(7 downto 4) <= "0000";
						second_sw(3 downto 0) <= "0000";
					elsif (second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
						minute_sw(3 downto 0) <= std_logic_vector(unsigned(minute_sw(3 downto 0)) + "0001");
						second_sw(7 downto 4) <= "0000";
						second_sw(3 downto 0) <= "0000";
					elsif (second_sw(3 downto 0) = "1001") then
						second_sw(7 downto 4) <= std_logic_vector(unsigned(second_sw(7 downto 4)) + "0001");
						second_sw(3 downto 0) <= "0000";
					else
						second_sw(3 downto 0) <= std_logic_vector(unsigned(second_sw(3 downto 0)) + "0001");
					end if;
				end if;
			when s2 =>
			when s3 =>
				if (hour_sw(7 downto 4) = "0010" and hour_sw(3 downto 0) = "0011" and minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
					hour_sw(7 downto 4) <= "0000";
					hour_sw(3 downto 0) <= "0000";
					minute_sw(7 downto 4) <= "0000";
					minute_sw(3 downto 0) <= "0000";
					second_sw(7 downto 4) <= "0000";
					second_sw(3 downto 0) <= "0000";
				elsif (hour_sw(3 downto 0) = "1001" and minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
					hour_sw(7 downto 4) <= std_logic_vector(unsigned(hour_sw(7 downto 4)) + "0001");
					hour_sw(3 downto 0) <= "0000";
					minute_sw(7 downto 4) <= "0000";
					minute_sw(3 downto 0) <= "0000";
					second_sw(7 downto 4) <= "0000";
					second_sw(3 downto 0) <= "0000";
				elsif (minute_sw(7 downto 4) = "0101" and minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
					hour_sw(3 downto 0) <= std_logic_vector(unsigned(hour_sw(3 downto 0)) + "0001");
					minute_sw(7 downto 4) <= "0000";
					minute_sw(3 downto 0) <= "0000";
					second_sw(7 downto 4) <= "0000";
					second_sw(3 downto 0) <= "0000";
				elsif (minute_sw(3 downto 0) = "1001" and second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
					minute_sw(7 downto 4) <= std_logic_vector(unsigned(minute_sw(7 downto 4)) + "0001");
					minute_sw(3 downto 0) <= "0000";
					second_sw(7 downto 4) <= "0000";
					second_sw(3 downto 0) <= "0000";
				elsif (second_sw(7 downto 4) = "0101" and second_sw(3 downto 0) = "1001") then
					minute_sw(3 downto 0) <= std_logic_vector(unsigned(minute_sw(3 downto 0)) + "0001");
					second_sw(7 downto 4) <= "0000";
					second_sw(3 downto 0) <= "0000";
				elsif (second_sw(3 downto 0) = "1001") then
					second_sw(7 downto 4) <= std_logic_vector(unsigned(second_sw(7 downto 4)) + "0001");
					second_sw(3 downto 0) <= "0000";
				else
					second_sw(3 downto 0) <= std_logic_vector(unsigned(second_sw(3 downto 0)) + "0001");
				end if;
			when s4 =>
			when others =>
			end case;
		end if;
	end process;
				
----------------
-- COUNTDOWN  --
----------------
	
countdown : process (dividedclk, datain, mode)	
	begin
		if (dividedclk' event and dividedclk = '1' and mode = "1000") then
			case (state_countdown) is
			when s0 =>
				cd_done <= '0';
			when s1 =>
				hour_cd <= to_bcd(bin => data);
			when s2 =>
				minute_cd <= to_bcd(bin => data);				
			when s3 =>
				second_cd <= to_bcd(bin => data);				
			when s4 =>				
			when s5 =>
				if (hour_cd(7 downto 4) = "0000" and hour_cd(3 downto 0) = "0000" and minute_cd(7 downto 4) = "0000" and minute_cd(3 downto 0) = "0000" and second_cd(7 downto 4) = "0000" and second_cd(3 downto 0) = "0000") then
					hour_cd(7 downto 4) <= "0000";
					hour_cd(3 downto 0) <= "0000";
					minute_cd(7 downto 4) <= "0000";
					minute_cd(3 downto 0) <= "0000";
					second_cd(7 downto 4) <= "0000";
					second_cd(3 downto 0) <= "0000";
				elsif (hour_cd(3 downto 0) = "0000" and minute_cd(7 downto 4) = "0000" and minute_cd(3 downto 0) = "0000" and second_cd(7 downto 4) = "0000" and second_cd(3 downto 0) = "0000") then
					hour_cd(7 downto 4) <= std_logic_vector(unsigned(hour_cd(7 downto 4)) - "0001");
					hour_cd(3 downto 0) <= "1001";
					minute_cd(7 downto 4) <= "0101";
					minute_cd(3 downto 0) <= "1001";
					second_cd(7 downto 4) <= "0101";
					second_cd(3 downto 0) <= "1001";
				elsif (minute_cd(7 downto 4) = "0000" and minute_cd(3 downto 0) = "0000" and second_cd(7 downto 4) = "0000" and second_cd(3 downto 0) = "0000") then
					hour_cd(3 downto 0) <= std_logic_vector(unsigned(hour_cd(3 downto 0)) - "0001");
					minute_cd(7 downto 4) <= "0101";
					minute_cd(3 downto 0) <= "1001";
					second_cd(7 downto 4) <= "0101";
					second_cd(3 downto 0) <= "1001";
				elsif (minute_cd(3 downto 0) = "0000" and second_cd(7 downto 4) = "0000" and second_cd(3 downto 0) = "0000") then
					minute_cd(7 downto 4) <= std_logic_vector(unsigned(minute_cd(7 downto 4)) - "0001");
					minute_cd(3 downto 0) <= "1001";
					second_cd(7 downto 4) <= "0101";
					second_cd(3 downto 0) <= "1001";
				elsif (second_cd(7 downto 4) = "0000" and second_cd(3 downto 0) = "0000") then
					minute_cd(3 downto 0) <= std_logic_vector(unsigned(minute_cd(3 downto 0)) - "0001");
					second_cd(7 downto 4) <= "0101";
					second_cd(3 downto 0) <= "1001";
				elsif (second_cd(3 downto 0) = "0000") then
					second_cd(7 downto 4) <= std_logic_vector(unsigned(second_cd(7 downto 4)) - "0001");
					second_cd(3 downto 0) <= "1001";
				else
					second_cd(3 downto 0) <= std_logic_vector(unsigned(second_cd(3 downto 0)) - "0001");
				end if;	
			when s6 =>
				cd_done <= '1';
			when others =>
			end case;
		end if;
	end process;
	
--------------
-- DISPLAY  --
--------------

display : process (mode, dividedclk, state_stopwatch, pb0, pb1, hour_t, minute_t, second_t, year, month, day, hour_sw, minute_sw, second_sw, temphour_sw, tempminute_sw, tempsecond_sw, hour_cd, minute_cd, second_cd)
	begin
		if (dividedclk' event and dividedclk = '1') then
			case (mode) is
			when "0000" =>
				if (pb1 = '1') then
					sig_d5 <= hour_t(7 downto 4);
					sig_d4 <= hour_t(3 downto 0);
					sig_d3 <= minute_t(7 downto 4);
					sig_d2 <= minute_t(3 downto 0);
					sig_d1 <= second_t(7 downto 4);
					sig_d0 <= second_t(3 downto 0);					
				else
					sig_d5 <= year(7 downto 4);
					sig_d4 <= year(3 downto 0);
					sig_d3 <= month(7 downto 4);
					sig_d2 <= month(3 downto 0);
					sig_d1 <= day(7 downto 4);
					sig_d0 <= day(3 downto 0);						
				end if;
			when "0001" =>
				sig_d5 <= hour_t(7 downto 4);
				sig_d4 <= hour_t(3 downto 0);
				sig_d3 <= minute_t(7 downto 4);
				sig_d2 <= minute_t(3 downto 0);
				sig_d1 <= second_t(7 downto 4);
				sig_d0 <= second_t(3 downto 0);	
			when "0010" =>
				sig_d5 <= year(7 downto 4);
				sig_d4 <= year(3 downto 0);
				sig_d3 <= month(7 downto 4);
				sig_d2 <= month(3 downto 0);
				sig_d1 <= day(7 downto 4);
				sig_d0 <= day(3 downto 0);
			when "0100" =>
				case (state_stopwatch) is
				when s0 =>
					sig_d5 <= hour_sw(7 downto 4);
					sig_d4 <= hour_sw(3 downto 0);
					sig_d3 <= minute_sw(7 downto 4);
					sig_d2 <= minute_sw(3 downto 0);
					sig_d1 <= second_sw(7 downto 4);
					sig_d0 <= second_sw(3 downto 0);
				when s1 =>
					sig_d5 <= hour_sw(7 downto 4);
					sig_d4 <= hour_sw(3 downto 0);
					sig_d3 <= minute_sw(7 downto 4);
					sig_d2 <= minute_sw(3 downto 0);
					sig_d1 <= second_sw(7 downto 4);
					sig_d0 <= second_sw(3 downto 0);
				when s2 =>
					sig_d5 <= hour_sw(7 downto 4);
					sig_d4 <= hour_sw(3 downto 0);
					sig_d3 <= minute_sw(7 downto 4);
					sig_d2 <= minute_sw(3 downto 0);
					sig_d1 <= second_sw(7 downto 4);
					sig_d0 <= second_sw(3 downto 0);
				when s3 =>
					sig_d5 <= hour_sw(7 downto 4);
					sig_d4 <= hour_sw(3 downto 0);
					sig_d3 <= minute_sw(7 downto 4);
					sig_d2 <= minute_sw(3 downto 0);
					sig_d1 <= second_sw(7 downto 4);
					sig_d0 <= second_sw(3 downto 0);
				when s4 =>
					if (pb0 = '1') then
						sig_d5 <= hour_sw(7 downto 4);
						sig_d4 <= hour_sw(3 downto 0);
						sig_d3 <= minute_sw(7 downto 4);
						sig_d2 <= minute_sw(3 downto 0);
						sig_d1 <= second_sw(7 downto 4);
						sig_d0 <= second_sw(3 downto 0);
					else
						sig_d5 <= temphour_sw(7 downto 4);
						sig_d4 <= temphour_sw(3 downto 0);
						sig_d3 <= tempminute_sw(7 downto 4);
						sig_d2 <= tempminute_sw(3 downto 0);
						sig_d1 <= tempsecond_sw(7 downto 4);
						sig_d0 <= tempsecond_sw(3 downto 0);
					end if;
				when others =>
				end case;
			when "1000" =>
				sig_d5 <= hour_cd(7 downto 4);
				sig_d4 <= hour_cd(3 downto 0);
				sig_d3 <= minute_cd(7 downto 4);
				sig_d2 <= minute_cd(3 downto 0);
				sig_d1 <= second_cd(7 downto 4);
				sig_d0 <= second_cd(3 downto 0);
			when others =>
				sig_d5 <= "1010";
				sig_d4 <= "1011";
				sig_d3 <= "1011";
				sig_d2 <= "1100";
				sig_d1 <= "1011";
				sig_d0 <= "1111";
			end case;
		end if;
	end process;
	
------------
-- CLOCK  --
------------

clkdivider: process (clk)
variable count: integer:= 0;
	begin
		if (clk'event and clk = '1') then
			if (count = 25000000) then
				dividedclk <= not dividedclk;
				count := 0;
			else
				count := count + 1;
			end if;
		end if;
	end process;
	
---------------------
-- 7SD TRANSLATION --
---------------------
		
with sig_d5 select
d5 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010",
				"0101111" when "1011",
				"0100011" when "1100",
				"0111111" when others;
		
with sig_d4 select
d4 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010",
				"0101111" when "1011",
				"0100011" when "1100",
				"0111111" when others;
		
with sig_d3 select
d3 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010", 
				"0101111" when "1011",  
				"0100011" when "1100",    
				"0111111" when others;

with sig_d2 select
d2 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010", 
				"0101111" when "1011", 
				"0100011" when "1100",   
				"0111111" when others;
				
with sig_d1 select
d1 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010", 
				"0101111" when "1011", 
				"0100011" when "1100",   
				"0111111" when others;

with sig_d0 select
d0 <= 		"1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0000110" when "1010",  
				"0101111" when "1011", 
				"0100011" when "1100",    
				"0111111" when others;

end architecture behavioural;