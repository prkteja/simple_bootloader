#compile kernel
echo "Compiling Kernel ..."
gcc -m32 kernel.c -o kernel.bin -std=gnu99 -ffreestanding -O2 -masm=intel -mno-mmx -mno-80387 -fno-pic -mno-sse -mno-sse2

#find kernel entry point offset
echo "Finding Kernel offset ..."
KERNEL_OFFSET=`objdump -M intel --disassemble=main kernel.bin | grep -m 1 "\<main\>" | cut -d ' ' -f 1`
KERNEL_OFFSET=0x$KERNEL_OFFSET
KERNEL_BASE=0x8000
MEM_OFFSET=$(($KERNEL_OFFSET+$KERNEL_BASE))
MEM_OFFSET_STR=`printf "0x%X\n" $MEM_OFFSET`
echo "entry point offset = $MEM_OFFSET_STR"
cp boot.asm tmp.asm
sed -i "s/__MEM_OFFSET__/$MEM_OFFSET_STR/g" tmp.asm

echo "Assembling disk image ..."
nasm -f bin tmp.asm -o boot.img
rm tmp.asm
qemu-system-x86_64 -drive file=boot.img,format=raw,index=0,media=disk