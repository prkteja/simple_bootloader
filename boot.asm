org 0x7c00
bits 16

start:
    cli
    cld
    jmp 0x0000:.initialise_cs
  .initialise_cs:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov si, StartBoot
    call print

    ;Load kernel

    mov si, KernelLoad
    call print

    mov eax, dword [kernel_sector]
    mov ebx, 0x7e00
    mov ecx, 1
    call read_sectors

    jc disk_error

    mov si, KernelInMem
    call print

    jmp 0x7e00

disk_error:
    mov si, DiskError
    call print
    jmp halt

a20_error:
    mov si, A20Error
    call print
    jmp halt

halt:
    hlt
    jmp halt

; data

StartBoot db 0x0D, 0x0A, 'Starting Bootloader...', 0x00
KernelLoad db 0x0D, 0x0A, 'Loading Kernel from disk...', 0x00
DiskError db 0x0D, 0x0A, 'Unable to read disk', 0x00
A20Error db 0x0D, 0x0A, 'Cannot enable a20', 0x00
KernelInMem db 0x0D, 0x0A, 'Loaded kernel into memory', 0x0D, 0x0A, 0x00

times 0xda-($-$$) db 0
times 6 db 0

; includes

%include 'print.asm'
%include 'disk.asm'

times 0x1b0-($-$$) db 0
kernel_sector: dd 1

times 0x1b8-($-$$) db 0
times 510-($-$$) db 0
dw 0xaa55

; switch to protected mode & jump to kernel entry point

kernel_jmp:
    mov eax, dword [kernel_sector]
    inc eax
    mov ebx, 0x8000
    mov ecx, 62
    call read_sectors
    jc disk_error

    call enable_a20
    jc a20_error

    lgdt [GDT]

    cli

    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 0x18:.pmode
    bits 32
  .pmode:
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    and edx, 0xff
    push edx
    call __MEM_OFFSET__
  ; mov si, 0x8000
  ; call print

bits 16
%include 'enable_a20.asm'
%include 'gdt.asm'

times 1024-($-$$) db 0

incbin 'kernel.bin'

times 32768-($-$$) db 0
