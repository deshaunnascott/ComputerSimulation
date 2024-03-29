-- Author:       De'Shaunna Scott
-- Date:         10/21/18
-- Email:        dscott6@umbc.edu
-- File:         pmul16.vhdl
-- Description:  pmul16.vhdl parallel multiply 16 bit x 16 bit to get 32 bit unsigned product
--               uses VHDL 'generate' to have less statements
--               see diagram madd.jpg for madd schematic
--               see diagram pmul4.ps for pmul4 schematic

library IEEE;
use IEEE.std_logic_1164.all;

entity madd is      -- multiplying full adder stage
  port(c    : in  std_logic;   -- one input, think carry in
       b    : in  std_logic;   -- one input, think previous sum
       m    : in  std_logic;   -- multiplier bit
       a    : in  std_logic;   -- multiplicand bit
       sum  : out std_logic;   -- carry save sum out
       cout : out std_logic);  -- carry save carry out
end entity madd;

architecture circuits of madd is  -- multiplying full adder stage
  signal aa: std_logic;
begin
  aa <= a and m; -- logic could be reduced, yet probably circuit designed
  sum <= (aa and b and c) or (aa and not b and not c) or
         (not aa and b and not c) or (not aa and not b and c) after 1 ps;
  cout <= (aa and b) or (aa and c) or (b and c) after 1 ps;
end architecture circuits; -- of madd

library IEEE;
use IEEE.std_logic_1164.all;

-- special case when c and b are zero
entity madd1 is      -- multiplying full adder stage
  port(m    : in  std_logic;   -- multiplier bit
       a    : in  std_logic;   -- multiplicand bit
       sum  : out std_logic;   -- carry save sum out
       cout : out std_logic);  -- carry save carry out
end entity madd1;

architecture circuits of madd1 is  -- multiplying full adder stage
  signal zero : std_logic := '0';
begin
  sum  <= a and m; -- logic reduced
  cout <= zero; -- cout can never happen because c and b are always zero
end architecture circuits; -- of madd1

library IEEE;
use IEEE.std_logic_1164.all;

-- special case when c is zero
entity madd2 is      -- multiplying full adder stage
  port(b    : in  std_logic;   -- one input, think previous sum
       m    : in  std_logic;   -- multiplier bit
       a    : in  std_logic;   -- multiplicand bit
       sum  : out std_logic;   -- carry save sum out
       cout : out std_logic);  -- carry save carry out
end entity madd2;

architecture circuits of madd2 is  -- multiplying full adder stage
  signal aa: std_logic;
begin
  aa   <=  a and m; -- logic could be reduced, yet probably circuit designed
  sum  <= (aa xor b) after 1 ps;
  cout <= (aa and b) after 1 ps;
end architecture circuits; -- of madd2

library IEEE;
use IEEE.std_logic_1164.all;

entity pmul16 is  -- 16 x 16 = 32 bit unsigned product multiplier
  port(a : in  std_logic_vector(15 downto 0);  -- multiplicand
       b : in  std_logic_vector(15 downto 0);  -- multiplier
       p : out std_logic_vector(31 downto 0)); -- product
end pmul16;

architecture circuits of pmul16 is
  constant N  : integer := 15;     -- last row number
  constant NP : integer := N+1;   -- last row plus 1
  constant NM : integer := N-1;   -- last row minus 1
  type arr is array(0 to NP) of std_logic_vector(N downto 0);
  signal s    : arr; -- partial sums
  signal c    : arr; -- partial carries
  signal zero : std_logic := '0';
begin  -- circuits of pmul16
  -- the internal part of the multiplier is nested generate
  -- special case generate is needed for the top row,
  -- the bottom row, the left column and
  -- connecting to the product outputs.
  
  -- center 
  gmaddi: for i in 1 to N generate
    gmaddj: for j in 0 to NM generate
      maddij: entity WORK.madd
              port map(s(i-1)(j+1), c(i-1)(j), b(i), a(j), s(i)(j), c(i)(j));
    end generate gmaddj;  
  end generate gmaddi;  

  -- top row
  gmadd0j: for j in 0 to N generate
    madd0j: entity WORK.madd1
            port map(b(0), a(j), s(0)(j), c(0)(j));                                         
  end generate gmadd0j;

  -- left column
  gmaddiN: for i in 1 to N generate
    maddiN: entity WORK.madd2
            port map(c(i-1)(N), b(i), a(N), s(i)(N), c(i)(N));
  end generate gmaddiN;

  -- bottom row
  maddNP0: entity WORK.madd
           port map(s(N)(1), c(N)(0), '1', '0', s(NP)(0), c(NP)(0));
  maddNPN: entity WORK.madd
           port map(zero, c(N)(N), '1', c(NP)(NM), s(NP)(N), c(NP)(N));
  gmaddNP: for j in 1 to NM generate
    maddNPj: entity WORK.madd
             port map(s(N)(j+1), c(N)(j), '1', c(NP)(j-1), s(NP)(j), c(NP)(j));
  end generate gmaddNP;
  
  
  -- connect outputs
  gp0i: for i in 0 to N generate
    p0i: p(i) <= s(i)(0);
    pNi: p(i+NP) <= s(NP)(i);
  end generate gp0i;
  
end architecture circuits; -- of pmul16
