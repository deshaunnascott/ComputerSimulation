# Makefile for Cadence "inca" "ncvhdl"  VHDL
#
# use  tcsh
#      source vhdl_cshrc
#      make
#
# must have set up  cds.lib  and  hdl.var  in default directory
# must have subdirectory "vhdl_lib",  mkdir  vhdl_lib, or just  make clean 

all: add32_test.out

add32_test.out:  add32_test.vhdl add32_test.run
	ncvhdl -v93 add32_test.vhdl
	ncelab -v93 add32_test:circuits
	ncsim -batch  -logfile add32_test.out -input add32_test.run add32_test


clean:
	rm -f *.log
	rm -rf vhdl_lib
	mkdir  vhdl_lib


