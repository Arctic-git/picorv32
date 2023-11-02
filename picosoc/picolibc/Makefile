
CROSS=~/Downloads/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-apple-darwin/bin/riscv64-unknown-elf-
SPECS=/Users/sebastian/repos/picolibc/build-rv32imc/picolibc.specs
CFLAGS=

SCP=scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
SSH=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
BB_LOGIN ?= debian@beaglebone.local

firmware.elf:
	$(CROSS)gcc --specs=$(SPECS) -Tfirmware.ld -march=rv32imc -mabi=ilp32 -o firmware.elf firmware.c

firmware.bin: firmware.elf
	$(CROSS)objcopy -O binary firmware.elf firmware.bin

bw_fused.bin: ../bw.bin firmware.bin
	../fuse_bin.py ../bw.bin firmware.bin bw_fused.bin 1048576

push: bw_fused.bin
	@$(SCP) bw_fused.bin $(BB_LOGIN):/home/debian/pushburn.bin
	
pushburn: push
	@$(SSH) $(BB_LOGIN) 'source /etc/profile; source .profile; bw-spi.sh pushburn.bin'

clean:
	rm *.bin
	rm *.elf