#===================================================================
#
# Makefile
# --------
# Makefile for building the ascon simulation targets, perform
# linting etc.
#
#
# Author: Joachim Strombergson
# Copyright (c) 2023, Assured AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#===================================================================

# Sources.
ASCON_PERMUTATION_SRC = ../src/rtl/ascon_permutation.v
TB_ASCON_PERMUTATION_SRC = ../src/tb/tb_ascon_permutation.v

ASCON_CORE_SRC = ../src/rtl/ascon_core.v  $(ASCON_PERMUTATION_SRC)
TB_ASCON_CORE_SRC = ../src/rtl/ascon_core.v

ASCON_TOP_SRC = ../src/rtl/ascon.v $(ASCON_CORE_SRC)
TB_ASCON_TOP_SRC = ../src/tb/tb_ascon.v


# Tools and flags.
CC= iverilog
CC_FLAGS= -Wall

LINT= verilator
LINT_FLAGS = +1364-2005ext+ --lint-only  -Wall -Wno-fatal -Wno-DECLFILENAME


# Targets.
all: top.sim core.sim permutation.sim


top.sim:  $(TB_ASCON_TOP_SRC) $(ASCON_TOP_SRC)
	$(CC) $(CC_FLAGS) -o $@ $^


core.sim:  $(TB_ASCON_CORE_SRC) $(ASCON_CORE_SRC)
	$(CC) $(CC_FLAGS) -o $@ $^


permutation.sim:  $(TB_ASCON_PERMUTATION_SRC) $(ASCON_PERMUTATION_SRC)
	$(CC) $(CC_FLAGS) -o $@ $^


lint: $(ASCON_TOP_SRC)
	$(LINT) $(LINT_FLAGS)  $^


clean:
	rm -f *.sim
	rm -f *.log
	rm -f *.txt


help:
	@echo "Build system for simulation of BLAKE2s core."
	@echo ""
	@echo "Supported targets:"
	@echo "------------------"
	@echo "all:          Build all simulation targets."
	@echo "clean:        Delete all built files."
	@echo "help:         This is it."

#===================================================================
# EOF Makefile
#===================================================================
