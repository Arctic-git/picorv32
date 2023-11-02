toolchain binary (riscv64-unknown-elf-): https://github.com/sifive/freedom-tools/releases

picolibc von source bauen und installieren:
https://github.com/picolibc/picolibc/tree/main
https://www.youtube.com/watch?v=SC6aBezNFFQ&t=2092s



### Bei Building Picolibc:
cross-rv32imc.txt (abgeändert von cross-rv32imac.txt)
```sh
[binaries]
c = ['ccache', 'riscv64-unknown-elf-gcc', '-nostdlib']
ar = 'riscv64-unknown-elf-ar'
as = 'riscv64-unknown-elf-as'
nm = 'riscv64-unknown-elf-nm'
strip = 'riscv64-unknown-elf-strip'
# only needed to run tests
exe_wrapper = ['sh', '-c', 'test -z "$PICOLIBC_TEST" || run-riscv "$@"', 'run-riscv']

[host_machine]
system = 'unknown'
cpu_family = 'riscv32'
cpu = 'riscv32'
endian = 'little'

[properties]
c_args = ['-msave-restore', '-fshort-enums', '-march=rv32imc', '-mabi=ilp32']
c_link_args = ['-msave-restore', '-fshort-enums', '-march=rv32imc', '-mabi=ilp32']
skip_sanity_check = true
default_flash_addr = '0x80000000'
default_flash_size = '0x00200000'
default_ram_addr   = '0x80200000'
default_ram_size   = '0x00200000'
```

do-rv32imc-configure
```sh
exec "$(dirname "$0")"/do-configure rv32imc -Dtests=false -Dmultilib=false "$@"
```

bauen (wie bei anleitung):
```sh
mkdir build-rv32imc
cd build-rv32imc
../scripts/do-rv32imc-configure -Dprefix=/Users/sebastian/repos/picolibc/build-rv32imc/output
ninja
ninja install
```