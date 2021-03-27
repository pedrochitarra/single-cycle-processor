-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	generic
	(
		DATA_WIDTH			: natural := 16;	   -- tamanho do dado em bits
		PC_WIDTH			   : natural := 8;		-- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		FR_ADDR_WIDTH		: natural := 4;		-- tamanho da linha de endereços do banco de registradores em bits
		ULA_CTRL_WIDTH		: natural := 4;		-- tamanho da linha de controle da ULA
		INSTR_WIDTH			: natural := 32		-- tamanho da instrução em bits
	);
	port(
		clock		 	: in std_logic;
		reset			: in std_logic;
		instrucaoin : in std_logic_vector(INSTR_WIDTH-1 downto 0);
		entrada   	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		w_eR			: in std_logic;
		sel_R			: in std_logic_vector(1 downto 0);
		sel_ula		: in std_logic;
		w_ePC			: in std_logic;
		branch		: in std_logic;
		outp			: in std_logic;
		opcode		: out std_logic_vector(3 downto 0);
		saida		 	: out std_logic_vector (DATA_WIDTH-1 downto 0);
		saidapc		: out std_logic_vector(PC_WIDTH-1 downto 0);
		enderecoreg : in std_logic
	);
end via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

component pc is
	generic
	(
		PC_WIDTH : natural := 8		-- tamanho de PC em bits
	);
	port(
		entrada	: in std_logic_vector (PC_WIDTH-1 downto 0);
		saida		: out std_logic_vector(PC_WIDTH-1 downto 0);
		clk		: in std_logic;
		we			: in std_logic;
		reset		: in std_logic
	);
end component;

component somador_de_8bits is	
	generic
	(
		PC_WIDTH : natural := 8		-- tamanho do somador em número de bits
	);
	port(
		entrada1	: in std_logic_vector (PC_WIDTH-1 downto 0);
		saida 	: out std_logic_vector (PC_WIDTH-1 downto 0)
	);
end component;

component banco_de_registradores is
	generic 
	(
		DATA_WIDTH 			: natural := 16;	-- tamanho de cada registrador do banco de registradores em bits
		QTY_REGISTERS		: natural := 16;	-- quantidade de registradores dentro do banco de registradores
		FR_ADDR_WIDTH		: natural := 4		-- tamanho da linha de endereços do banco de registradores em bits
	);
	port(
		clk 		: in std_logic;										-- Relógio
		read_regrs	: in std_logic_vector(FR_ADDR_WIDTH-1 downto 0); 	-- Índice do registrador rs
		read_regrt	: in std_logic_vector(FR_ADDR_WIDTH-1 downto 0); 	-- Índice do registrador rt
		write_regrd	: in std_logic_vector(FR_ADDR_WIDTH-1 downto 0); 	-- Índice no registrador rd
		data_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);		-- entrada de dados para escrita
		data_outrs	: out std_logic_vector(DATA_WIDTH-1 downto 0);		-- saída de dados do registrador rs
		data_outrt	: out std_logic_vector(DATA_WIDTH-1 downto 0);		-- saída de dados do registrador rt
		reg_write	: in std_logic										-- sinal de controle de escrita
	);
end component;

component ula is
	generic 
	(
		DATA_WIDTH : natural := 16;			-- tamanho das entradas e da saída de dados da ULA em bits
		ADDR_WIDTH : natural := 4			-- tamanho da entrada de controle da ULA em bits
	);
	port(
		A, B		 	: in std_logic_vector (DATA_WIDTH-1 downto 0);		-- Barramentos A e B
		opcode 		: in std_logic_vector (3 downto 0);		-- Controle da ULA 
		saidaula 	: out std_logic_vector (DATA_WIDTH-1 downto 0);		-- Saída da ULA
		flag			: in std_logic_vector(3 downto 0);									-- flag resultado zero
		flagsaida	: out std_logic										-- flag resultado negativo
	);
end component;

component deslocador is
	port(
		Entrada_Dados		:in std_logic_vector(15 downto 0);
      Entrada_Shty 	 	:in std_logic_vector(3 downto 0);
		Entrada_Shmt 	 	:in std_logic_vector(3 downto 0);
      Saida	 				:out std_logic_vector(15 downto 0)
	);
end component;

component mux21_8bits is
	port(
		controle	: in std_logic;
		entrada0	: in std_logic_vector(7 downto 0);
		entrada1	: in std_logic_vector(7 downto 0);
		saida		: out std_logic_vector(7 downto 0)
	);
end component;

component mux21_16bits is
	port(
		controle : in std_logic;
		entrada0	: in std_logic_vector(15 downto 0);
		entrada1	: in std_logic_vector(15 downto 0);
		saida		: out std_logic_vector(15 downto 0)
	);
end component;

component mux41 is
	port(
		controle	: in std_logic_vector(1 downto 0);
		entrada0	: in std_logic_vector(15 downto 0);
		entrada1	: in std_logic_vector(15 downto 0);
		entrada2	: in std_logic_vector(15 downto 0);
		entrada3	: in std_logic_vector(15 downto 0);
		saida		: out std_logic_vector(15 downto 0)
	);
end component;

component extensor_de_sinal is
	port(
		entrada	: in std_logic_vector(3 downto 0);
		saida		: out std_logic_vector(15 downto 0)
	);
end component;

component registrador_de_16bits is
	port(
		entrada	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		saida	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		clk		: in std_logic;
		we		: in std_logic;
		reset	: in std_logic
	);
end component;

component mux21_4bits is
	port(
		controle : in std_logic;
		entrada0	: in std_logic_vector(3 downto 0);
		entrada1	: in std_logic_vector(3 downto 0);
		saida		: out std_logic_vector(3 downto 0)
	);
end component;

--GERAL
signal instrucao				: std_logic_vector(31 downto 0);
signal aux_addrop1	   	: std_logic_vector(FR_ADDR_WIDTH-1 downto 0);
signal aux_addrop2 	   	: std_logic_vector(FR_ADDR_WIDTH-1 downto 0);
signal aux_addrdes 	   	: std_logic_vector(FR_ADDR_WIDTH-1 downto 0);

--BANCO R
signal aux_data_in 			: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_outrop1		: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_data_outrop2 	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal aux_w_eR				: std_logic;
signal aux_sel_R				: std_logic_vector(1 downto 0);
signal aux_endereco			: std_logic_vector(3 downto 0);

--ULA
signal aux_flag				: std_logic_vector(3 downto 0);
signal aux_fsaida				: std_logic;
signal aux_saidaula			: std_logic_vector(15 downto 0);
signal aux_opcode 	   	: std_logic_vector(3 downto 0);
signal aux_ende 				: std_logic_vector(7 downto 0);
signal aux_imed				: std_logic_vector(3 downto 0);
signal aux_imed_ext			: std_logic_vector(15 downto 0);
signal aux_saidamuxula		: std_logic_vector(15 downto 0);
signal aux_sel_ula			: std_logic;
signal aux_branch				: std_logic;

--PC
signal aux_pc_out		   	: std_logic_vector(PC_WIDTH-1 downto 0);
signal aux_muxPC				: std_logic_vector(PC_WIDTH-1 downto 0);
signal aux_PC_1				: std_logic_vector(7 downto 0);
signal aux_w_ePC				: std_logic;

--DESLOCADOR
signal aux_outdes				: std_logic_vector(15 downto 0);
signal aux_shmt				: std_logic_vector(3 downto 0);
signal aux_shty				: std_logic_vector(3 downto 0);

--SAIDA EXTERNA
signal auxzero_16bits		: std_logic_vector(15 downto 0);
signal aux_saida				: std_logic_vector(15 downto 0);
signal aux_zero				: std_logic_vector(15 downto 0);

begin

--GERAL
instrucao 		<= instrucaoin;
aux_addrop1 	<= instrucao(23 downto 20); 	  
aux_addrop2 	<= instrucao(19 downto 16); 	 
aux_addrdes		<= instrucao(27 downto 24);
aux_opcode 		<= instrucao(31 downto 28);
aux_w_eR			<= w_eR;
aux_sel_R 		<= sel_R;
aux_sel_ula		<= sel_ula;
aux_w_ePC		<= w_ePC;

--ULA
aux_flag			<= instrucao(15 downto 12);
aux_ende			<= instrucao(7 downto 0);
aux_imed 		<= instrucao(11 downto 8);
aux_branch		<= (branch and aux_fsaida);

--DESLOCADOR
aux_shmt 		<= instrucao(19 downto 16);
aux_shty			<= instrucao(15 downto 12);
     
--AUXILIAR
aux_zero 		<=X"0000";
saidapc 			<= aux_pc_out;
opcode			<= aux_opcode;

	instancia_ula1 : ula
	port map(
		A 			 => aux_data_outrop1,
		B 			 => aux_saidamuxula,
		opcode 	 => aux_opcode,
		saidaula  => aux_saidaula,
		flag		 => aux_flag,
		flagsaida => aux_fsaida
	);

	instancia_banco_de_registradores : banco_de_registradores
	port map(
		clk			=> clock,
		read_regrs	=> aux_endereco, 			-- Índice do registrador rs
		read_regrt	=> aux_addrop2, 			-- Índice do registrador rt
		write_regrd	=> aux_addrdes, 			-- Índice no registrador rd
		data_in		=> aux_data_in,			-- entrada de dados para escrita
		data_outrs	=> aux_data_outrop1,		-- saída de dados do registrador rs
		data_outrt	=> aux_data_outrop2,		-- saída de dados do registrador rt
		reg_write	=> aux_w_eR					-- sinal de controle de escrita
	);
	
	instancia_pc : pc
	port map(
		entrada	=> aux_muxPC,
		saida		=> aux_pc_out,
		clk		=> clock,
		we			=> aux_w_ePC,
		reset		=> reset
	);
	
	instancia_somador_de_8bits : somador_de_8bits	
	port map(
		entrada1		=> aux_pc_out,
		saida 		=> aux_PC_1
	);
	
	instancia_deslocador : deslocador
	port map(
		Entrada_Dados => aux_data_outrop1,
		Entrada_Shty  => aux_shty,
		Entrada_Shmt  => aux_shmt,
		Saida 		  => aux_outdes 
	);
	
	instancia_endereco : mux21_8bits
	port map(
		controle => aux_branch,
		entrada0 => aux_PC_1,
		entrada1 => aux_ende,
		saida 	=> aux_muxPC
	);
	
	instancia_valorRDES : mux41
	port map(
		controle => aux_sel_R,
		entrada0 => aux_zero,
		entrada1 => aux_saidaula,
		entrada2 => aux_outdes,
		entrada3 => entrada,
		saida 	=> aux_data_in
	);
	
	instancia_extensor: extensor_de_sinal
	port map(
		entrada   => aux_imed,
		saida 	 => aux_imed_ext
		);
	
	instancia_muxula: mux21_16bits
	port map(
		controle => aux_sel_ula,
		entrada0 => aux_data_outrop2,
		entrada1 =>	aux_imed_ext,
		saida 	=> aux_saidamuxula
		);
		
	instancia_muxsaida : mux21_16bits
	port map(
		controle => outp,
		entrada0	=> aux_zero,
		entrada1	=> aux_data_outrop1,
		saida		=> aux_saida
		);
	
	instancia_enderecoreg : mux21_4bits
	port map(
		controle => enderecoreg,
		entrada0 => aux_addrop1,
		entrada1 => aux_addrdes,
		saida 	=> aux_endereco
		);
		
		saida <=aux_saida;
		
end comportamento;
