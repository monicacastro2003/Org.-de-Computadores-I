section .data
    uinput_dev db '/dev/uinput', 0
    
    ; Estrutura uinput_user_dev
    align 8
    uidev:
        .name:      db 'Virtual Mouse', 0
                    times 80-13 db 0  ; Preenche os 80 bytes
        .id:
            .bustype: dd 0x3    ; BUS_USB
            .vendor:  dd 0x1234  ; Vendor fake
            .product: dd 0x5678  ; Product fake
            .version: dd 0x111   ; Version
        .ff_effects_max: dd 0
        .absmax:    times 64 dd 0
        .absmin:    times 64 dd 0
        .absfuzz:   times 64 dd 0
        .absflat:   times 64 dd 0

section .text
    global _start

_start:
    ; 1. Abrir dispositivo uinput
    mov eax, 2              ; open()
    mov rdi, uinput_dev     ; path
    mov rsi, 2              ; O_RDWR
    xor rdx, rdx            ; mode
    syscall
    cmp eax, 0
    jl .error
    mov r15, rax            ; guardar fd

    ; 2. Configurar eventos suportados
    ; EV_KEY
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x40045560     ; UI_SET_EVBIT
    mov rdx, 1              ; EV_KEY
    syscall

    ; EV_REL
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x40045560     ; UI_SET_EVBIT
    mov rdx, 2              ; EV_REL
    syscall

    ; REL_X
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x40045561     ; UI_SET_RELBIT
    mov rdx, 0              ; REL_X
    syscall

    ; REL_Y
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x40045561     ; UI_SET_RELBIT
    mov rdx, 1              ; REL_Y
    syscall

    ; 3. Criar dispositivo
    ; Escrever estrutura de configuração
    mov eax, 1              ; write()
    mov rdi, r15
    mov rsi, uidev
    mov rdx, 384            ; sizeof(uinput_user_dev)
    syscall

    ; Criar dispositivo
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x4004555E     ; UI_DEV_CREATE
    xor rdx, rdx
    syscall

    ; Pequena pausa
    mov eax, 35             ; nanosleep()
    mov rdi, timespec
    xor rsi, rsi
    syscall

    ; 4. Enviar movimento
    ; Evento X
    mov eax, 1              ; write()
    mov rdi, r15
    mov rsi, rel_event_x
    mov rdx, 24             ; sizeof(input_event)
    syscall

    ; Evento Y
    mov eax, 1              ; write()
    mov rdi, r15
    mov rsi, rel_event_y
    mov rdx, 24
    syscall

    ; 5. Finalizar
    ; Destruir dispositivo
    mov eax, 16             ; ioctl()
    mov rdi, r15
    mov rsi, 0x4004555F     ; UI_DEV_DESTROY
    xor rdx, rdx
    syscall

    ; Fechar
    mov eax, 3              ; close()
    mov rdi, r15
    syscall

    ; Sair
    mov eax, 60
    xor edi, edi
    syscall

.error:
    mov eax, 60
    mov edi, 1
    syscall

section .bss
    timespec:
        .tv_sec: resq 1
        .tv_nsec: resq 1

section .data
    rel_event_x:
        dq 0          ; time
        dq 0
        dw 2          ; EV_REL
        dw 0          ; REL_X
        dd 50         ; value
        dd 0          ; padding

    rel_event_y:
        dq 0          ; time
        dq 0
        dw 2          ; EV_REL
        dw 1          ; REL_Y
        dd 30         ; value
        dd 0
