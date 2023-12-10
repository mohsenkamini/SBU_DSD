LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY uart IS
	PORT(
		start:    IN std_logic;
		data_in:  IN std_logic_vector(7 DOWNTO 0);
		rx:       IN std_logic;
		clk:      IN std_logic;
		nreset:   IN std_logic;
		
		strobe:   OUT std_logic;
		data_out: OUT std_logic_vector(7 DOWNTO 0);
		tx:       OUT std_logic
		
	);
END uart;

ARCHITECTURE behavioural OF uart IS
	TYPE state_t is (SS, S0, S1, S2, S3, S4, S5, S6, S7, S8, SD);
	
	SIGNAL cur_recv_state, nxt_recv_state: state_t := S0;
	SIGNAL cur_trsm_state, nxt_trsm_state: state_t := S0;
	
	SIGNAL data_out_reg: std_logic_vector(7 DOWNTO 0);
	
BEGIN
	recv_sequential: PROCESS(clk, nreset)
	BEGIN
		IF nreset = '0' THEN
			cur_recv_state <= S0;
		ELSIF rising_edge(clk) THEN
			cur_recv_state <= nxt_recv_state;
		END IF;
	END PROCESS recv_sequential;
	
	trsm_sequential: PROCESS(clk, nreset)
	BEGIN
		IF nreset = '0' THEN
			cur_trsm_state <= S0;
		ELSIF rising_edge(clk) THEN
			cur_trsm_state <= nxt_trsm_state;
		END IF;
	END PROCESS trsm_sequential;
	
	recv_cobmbinational: PROCESS(cur_recv_state, data_out_reg, clk, rx)
	BEGIN
		nxt_recv_state <= cur_recv_state;
		strobe <= '0';

		CASE cur_recv_state IS
		WHEN S0 =>
		  	IF rx = '0' THEN
				nxt_recv_state <= S1;
		  	END IF;
		  
		WHEN S1 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S3;
		  	END IF;
		  
		WHEN S2 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S3;
		  	END IF;
		  
		WHEN S3 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S4;
		  	END IF;
		  
		WHEN S4 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S5;
		  	END IF;
		  
		WHEN S5 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S6;
		  	END IF;
		  
		WHEN S6 =>
		  	IF rising_edge(clk) THEN
				data_out_reg <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S7;
		  	END IF;
		  
		WHEN S7 =>
		  	IF rising_edge(clk) THEN
				data_out <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= S8;
		  	END IF;
		  
		WHEN S8 =>
		  	IF rising_edge(clk) THEN
				data_out <= rx & data_out_reg(6 DOWNTO 0);
				nxt_recv_state <= SD;
				strobe <= '1';
		  	END IF;

		WHEN OTHERS => -- SD
			strobe <= '1';
			IF rising_edge(clk) THEN
				nxt_recv_state <= S0;
				data_out <= "00000000";
				strobe <= '0';
			END IF;

		END CASE;

	END PROCESS recv_cobmbinational;
	
	trsm_cobmbinational: PROCESS(cur_trsm_state, data_in, clk, start)
	BEGIN
		nxt_trsm_state <= cur_trsm_state;
		tx <= '1';

		CASE cur_trsm_state IS
		WHEN S0 =>
			IF start = '1' AND rising_edge(clk) THEN
				nxt_trsm_state <= SS;
			END IF;

		WHEN SS =>
			IF rising_edge(clk) THEN
				tx <= '0';
				nxt_trsm_state <= S1;
			END IF;
		  
		WHEN S1 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(0);
				nxt_trsm_state <= S3;
		  	END IF;
		  
		WHEN S2 =>
			IF rising_edge(clk) THEN
				tx <= data_in(1);
				nxt_trsm_state <= S3;
			END IF;
		  
		WHEN S3 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(2);
				nxt_trsm_state <= S4;
		  	END IF;
		  
		WHEN S4 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(3);
				nxt_trsm_state <= S5;
		  	END IF;
		  
		WHEN S5 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(4);
				nxt_trsm_state <= S6;
		  	END IF;
		  
		WHEN S6 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(5);
				nxt_trsm_state <= S7;
		  	END IF;
		  
		WHEN S7 =>
		  	IF rising_edge(clk) THEN
				tx <= data_in(6);
				nxt_trsm_state <= S8;
		  	END IF;
			  
		WHEN S8 =>
			IF rising_edge(clk) THEN
				tx <= data_in(7);
				nxt_trsm_state <= SD;
			END IF;

		WHEN OTHERS => -- SD
			IF rising_edge(clk) THEN
				nxt_trsm_state <= S0;
			END IF;

		END CASE;

	END PROCESS trsm_cobmbinational;

END behavioural;