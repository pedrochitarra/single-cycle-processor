library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparador is
generic(
	n: integer :=16
	);
	port (A: in std_logic_vector (n-1 downto 0);
		  B: in std_logic_vector (n-1 downto 0);
		  IGUAL: out std_logic;
		  MAIOR: out std_logic;
		  MENOR: out std_logic
		  );
end Comparador;

architecture comportamento of Comparador is
signal aux_a, aux_b, resultado : std_logic_vector(15 downto 0);
signal aux_menor, aux_maior, aux_igual : std_logic;

begin
process(A,B,aux_a,aux_b,resultado,aux_igual,aux_maior,aux_menor)
begin

if A(15) = '1' and B(15) = '1' then
aux_a <= NOT(A);
aux_a <= std_logic_vector(unsigned(aux_a) + to_unsigned(1,7));

aux_b <= NOT(B);
aux_b <= std_logic_vector(unsigned(aux_b) + to_unsigned(1,7));

resultado <= std_logic_vector(signed(aux_a) - signed(aux_b));

	if resultado(15) = '1' then
		aux_maior<='0'; aux_menor<='1'; aux_igual<='0';
	elsif resultado = "0000000000000000" then
		aux_maior<='0'; aux_menor<='0'; aux_igual<='1';
	else
		aux_maior<='1'; aux_menor<='0'; aux_igual<='0';
	end if;
	
elsif A(15) = '1' and B(15) = '0' then
aux_maior<='0';aux_menor<='1';aux_igual<='0';
resultado<="0000000000000000";
aux_a<="0000000000000000";
aux_b<="0000000000000000";

elsif A(15) = '0' and B(15) = '1' then
aux_maior<='1';aux_menor<='0';aux_igual<='0';
resultado<="0000000000000000";
aux_a<="0000000000000000";
aux_b<="0000000000000000";

else
aux_a<="0000000000000000";
aux_b<="0000000000000000";
resultado <= std_logic_vector(unsigned(A) - unsigned(B));

	if resultado(15) = '1' then
		aux_maior<='0'; aux_menor<='1'; aux_igual<='0';
	elsif resultado = "0000000000000000" then
		aux_maior<='0'; aux_menor<='0'; aux_igual<='1';
	else
		aux_maior<='1'; aux_menor<='0'; aux_igual<='0';
	end if;

end if;

MAIOR<=aux_maior; MENOR<=aux_menor; IGUAL<= aux_igual;

end process;
end comportamento;