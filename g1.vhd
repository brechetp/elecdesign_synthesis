-- file g1.vhd

entity g1 is
  port(clk, a: in bit;
       s: out bit);
end entity g1;
--translate_off
-- we don't try to synth non synthesizable code
architecture arc of g1 is

-- internal copy; the output s will be a copy of this signal
  signal s_local: bit; -- a_mem keeps track of a macro exit
  
  type T is array(0 to 4) of INTEGER;

begin

  s <= s_local; -- the output s is a copy of s_local

  p: process
    variable a_mem: integer := 0;
  begin
    -- first, synchronize on a rising edge of clock where a is active
    if a_mem = 0 then 
      wait until clk = '1' and clk'event and a = '1';
    end if;
    a_mem := 0;
    s_local <= '1'; -- a macro-cycle starts (set s_local)
    macro: for i in 4 downto 0 loop -- a macro-cycle is made of 5 sequences
      for j in 1 to 2**i loop -- wait for 2^i cycles
        wait until clk = '1' and clk'event;
        if a = '1' and i = 0 then
          a_mem := 1;
          exit macro;
        end if;
      end loop;
      s_local <= not s_local; -- invert s_local
    end loop macro;
  end process p;

end architecture arc;
--translate_on
architecture syn of g1 is

  signal state: INTEGER range 0 to 31;

begin

  process(clk)
  begin
    if clk = '1' and clk'event then
      if a = '1' and (state = 31 or state = 0) then
          state <= 1;
      else
        if state = 31 then
          state <= 0;
        elsif state /= 0 then
          state <= state + 1;
        end if;
      end if;
    end if;
  end process ;


  s <= '1' when state >= 1 and state <= 16 else
       '1' when state >= 25 and state <= 28 else
       '1' when state = 31 else
       '0';

end architecture syn;



      
