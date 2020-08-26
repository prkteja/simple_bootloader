print:
    push ax
    push si
    mov ah, 0x0e
  .loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
  .done:
    pop si
    pop ax
    ret
