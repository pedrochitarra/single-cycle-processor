-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
	generic 
	(
		INSTR_WIDTH 		: natural := 32;
		OPCODE_WIDTH		: natural := 4;
		ULA_CTRL_WIDTH 	: natural := 4
	);
	port(
		opcode		: in std_logic_vector(3 downto 0);			-- instrução 												
		w_ePC_fsm	: in std_logic; 
		w_eR_fsm		: in std_logic; 
		sel_R			: out std_logic_vector(1 downto 0);  -- Bits de selecao para o MUX ligado ao registrador de destino (01: saida da ula,
		-- 10: entrada externa, 11: saida deslocador)
		sel_ula		: out std_logic;
		branch		: out std_logic;
		w_ePC			: out std_logic;
		w_eR 			: out std_logic;
		enderecoreg : out std_logic
	);
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is

signal inst_aux 	: std_logic_vector (31 downto 0);			-- instrucao

begin

	process (opcode, w_ePC_fsm, w_eR_fsm)
    begin				
		case opcode is
			--ADDI
			when "0010" => -- 1 para imediato, 0 para B
				sel_ula <='1';
				sel_R <="01";
				branch<='1';
				w_ePC <= '1';
				w_eR  <= '1';
				enderecoreg <='0';
			-- SHI
			when "1000" =>
				sel_R	<= "10";
				sel_ula <='0';
				w_ePC <= '1';
				w_eR  <= '1';
				branch<='0';
				enderecoreg <='0';
			-- INP
			when "1100" =>
				sel_R	<= "11";
				w_ePC <= w_ePC_fsm;
				w_eR  <= w_eR_fsm;
				sel_ula <='0';
				branch<='0';
				enderecoreg <='1';
			--OUT
			when "1101" =>
				sel_R	<= "00";
				w_ePC <= w_ePC_fsm;
				w_eR  <= w_eR_fsm;
				sel_ula <='0';
				branch<='0';
				enderecoreg <='1';
			--NOP
			when "1111" =>
				sel_R <= "00";
				w_ePC <= '1';
				sel_ula <='0';
				branch<='0';
				w_eR  <= '0';
				enderecoreg <='0';
			when others =>	-- todas as outras instrucoes	
				sel_R <= "01";
				w_ePC <= '1';
				sel_ula <='0';
				branch<='1';
				w_eR  <= '1';
				enderecoreg <='0';
		end case;
		
	end process;
		
end beh;
