-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Versão: v1-2016 
-- Disciplina: ELT005 - Sistemas, Processadores e Periféricos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memi is
	generic 
	(
		INSTR_WIDTH : natural := 32;	-- tamanho da instrução em número de bits
		MI_ADDR_WIDTH : natural := 8	-- tamanho do endereço da memória de instruções em número de bits
	);
	port(
		Endereco	: in std_logic_vector(MI_ADDR_WIDTH-1 downto 0);
		Instrucao	: out std_logic_vector(INSTR_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of memi is
type rom_type is array (0 to 2**MI_ADDR_WIDTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
constant rom: rom_type := (
	0 => X"c1000000", -- INP $1
	1 => X"d1000000", -- OUT $1
	2 => X"c2000000", -- INP $2
	3 => X"d2000000", -- OUT $1
	4 => X"23100500", -- ADDI $3, $1, $0, 0, 5, 0
	5 => X"d3000000", -- OUT $3
	6 => X"43120000", -- NOR $3, $1, $2, 0, 0, 0
	7 => X"d3000000", -- OUT $3
	8 => X"73120000", -- AND $3, $1, $2, 0, 0, 0
	9 => X"d3000000", -- OUT $3
	10 => X"63120000", -- XOR $3, $1, $2, 0, 0, 0
	11 => X"d3000000", -- OUT $3
	12 => X"1321800f", -- SUB $3, $2, $1, 8, 0, else
	13 => X"d2000000", -- OUT $2
	14 => X"2300F010", -- ADDI $3, $0, $0, 15, 0, endif 
	15 => X"d1000000", -- else: OUT $1
	16 => X"03120000", -- endif: ADD $3, $1, $2, 0, 0, 0
	17 => X"d3000000", -- OUT $3
	18 => X"83112000", -- SHI  $3, $1, 1, 2
	19 => X"d3000000", -- OUT $3
	others => X"f0000000" -- Para todo o resto nao executa nada (NOP)
);
begin
    Instrucao <= rom(to_integer(unsigned(Endereco)));
end rtl;