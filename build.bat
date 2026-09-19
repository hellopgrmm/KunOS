@echo off
echo kunkun is coming...
echo 请确认你的电脑安装了QEMU虚拟机
del BINARY\*.bin
del BK\*.bin
del IMAGES\.img
nasm.exe -f bin BK\boot.asm -o BK\boot.bin 
nasm.exe -f bin BK\kernel.asm -o BK\kernel.bin 
cd BINARY
for /r %%f in (*.asm) do nasm.exe -f bin %%f -o %%f.bin
cd ..
type BK\boot.bin BK\kernel.bin BINARY\*.bin > IMAGES/ikun.img
qemu-system-i386 -fda IMAGES/ikun.img
pause