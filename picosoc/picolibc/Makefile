
CROSS=riscv64-unknown-elf-
CFLAGS=

SCP=scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
SSH=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
BB_LOGIN ?= debian@beaglebone.local

firmware.elf: firmware.c
	$(CROSS)gcc --specs=picolibc.specs -Tfirmware.ld -march=rv32imc -mabi=ilp32 -o firmware.elf firmware.c -Wl,--print-memory-usage -Wstack-usage=512

firmware.bin: firmware.elf
	$(CROSS)objcopy -O binary firmware.elf firmware.bin

bw_fused.bin: ../bw.bin firmware.bin
	../fuse_bin.py ../bw.bin firmware.bin bw_fused.bin 1048576

push: bw_fused.bin
	@$(SCP) bw_fused.bin $(BB_LOGIN):/home/debian/pushburn.bin
	
pushburn: push
	@$(SSH) $(BB_LOGIN) 'source /etc/profile; source .profile; bw-spi.sh pushburn.bin'

size: firmware.elf
	$(CROSS)size -G firmware.elf
# $(CROSS)nm -t d -S --size-sort firmware.elf
# $(CROSS)objdump -t firmware.elf

clean:
	rm -f *.bin
	rm -f *.elf