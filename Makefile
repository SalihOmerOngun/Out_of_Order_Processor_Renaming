SV_FILES = ${wildcard ./src/pkg/*.sv} ${wildcard ./src/*.sv}
TB_FILES = ${wildcard ./tb/*.sv}
ALL_FILES = ${SV_FILES} ${TB_FILES}


lint:
	@echo "Running lint checks..."
	verilator --lint-only --timing -Wall -Wno-UNUSED -Wno-CASEINCOMPLETE ${SV_FILES}

build:
	verilator  --binary ${SV_FILES} ./tb/tb_rename.sv --top tb_rename -j 0 --trace -Wno-CASEINCOMPLETE 

run: build
	obj_dir/Vtb_rename

wave: run
	gtkwave --dark dump.vcd

clean:
	@echo "Cleaning temp files..."
	rm -f dump.vcd
	rm -rf obj_dir


.PHONY: compile run wave lint clean help
