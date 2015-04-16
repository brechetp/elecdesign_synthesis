-- file g1_sim.vhd

-- the entity of a simulation environment usually has no input output ports.
-- file g1_sim_arc.vhd
entity g1_sim is
  port(s, s_syn: out bit);
end entity g1_sim;

architecture sim of g1_sim is

-- we declare signals to be connected to the instance of g1. the names of the
-- signals are the same as the name of the ports of the entity g1 because it is
-- much simpler but we could use different names and bind signal names to port
-- names in the instanciation of g1.
  signal clk, a, stop_simulation, s_syn_cp, s_cp: bit;

begin

-- this process generates a symmetrical clock with a period of 20 ns.
-- this clock will never stop.
  clock_generator: process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    if stop_simulation = '1' then
      wait;
    end if;
  end process clock_generator;

-- this process generates the input sequence for the signal a.
  a_generator: process
    type num_cycles_array is array(natural range 1 to 4) of positive;
    constant num_cycles: num_cycles_array := (2, 17, 21, 30);
  begin
    for i in num_cycles'range loop
      for j in 1 to num_cycles(i) loop
        wait until clk = '0' and clk'event;
      end loop;
      a <= '1';
      wait until clk = '0' and clk'event;
      a <= '0';
    end loop;
    for i in 1 to 64 loop
      wait until clk = '0' and clk'event;
    end loop;
    report "End of simulation";
    stop_simulation <= '1';
  end process a_generator;

-- we instanciate the entity g1, architecture arc. we name the instance i_g1 and
-- specify the association between port names and actual signals.
  i_g1: entity work.g1(arc) port map(clk => clk, a => a, s => s_cp);
  syn_g1: entity work.g1(syn) port map(clk => clk, a => a, s => s_syn_cp);

  s <= s_cp;
  s_syn <= s_syn_cp;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      assert (s_cp=s_syn_cp) report "bug" severity failure;
    end if;
  end process;
  
end architecture sim;
