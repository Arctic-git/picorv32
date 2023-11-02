
CROSS=~/Downloads/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-apple-darwin/bin/riscv64-unknown-elf-
CFLAGS=
USE_MYSTDLIB=0

SCP=scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
SSH=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
BB_LOGIN ?= debian@beaglebone.local


ifeq ($(USE_MYSTDLIB),1)
CFLAGS += -DUSE_MYSTDLIB -ffreestanding -nostdlib
# OBJS += start.o
else
# OBJS += syscalls.o
endif


bw_fw.elf: bw_sections.lds  firmware.c syscalls.c
#	$(CROSS)gcc $(CFLAGS)  -mabi=ilp32 -march=rv32imc -Wl,--build-id=none,-Bstatic,-T,bw_sections.lds,--strip-debug -ffreestanding -nostdlib -o bw_fw.elf start.s firmware.c
#	$(CROSS)gcc $(CFLAGS) -Iinclude  -mabi=ilp32 -march=rv32imc -Wl,--build-id=none,-Bstatic,-T,bw_sections.lds,--strip-debug -ffreestanding  -o bw_fw.elf start.s firmware.c
	$(CROSS)gcc $(CFLAGS)  -mabi=ilp32 -march=rv32imc -Wl,--build-id=none,-Bstatic,-T,bw_sections.lds,--strip-debug -lc -lgcc -o bw_fw.elf firmware.c syscalls.c 
	$(CROSS)size $@

bw_fw.hex: bw_fw.elf
	$(CROSS)objcopy -O verilog bw_fw.elf bw_fw.hex

bw_fw.bin: bw_fw.elf
	$(CROSS)objcopy -O binary bw_fw.elf bw_fw.bin

bw_fused.bin: ../bw.bin bw_fw.bin
	../fuse_bin.py ../bw.bin bw_fw.bin bw_fused.bin 1048576

push: bw_fused.bin
	@$(SCP) bw_fused.bin $(BB_LOGIN):/home/debian/pushburn.bin
	
pushburn: push
	@$(SSH) $(BB_LOGIN) 'source /etc/profile; source .profile; bw-spi.sh pushburn.bin'

	
