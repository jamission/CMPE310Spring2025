section .data
    prompt1 db "Enter first string: ", 0
    prompt1_len equ $ - prompt1
    prompt2 db "Enter second string: ", 0
    prompt2_len equ $ - prompt2
    result_msg db "Hamming Distance: ", 0
    result_msg_len equ $ - result_msg
    newline db 10  ; Newline character

section .bss
    str1 resb 256
    str2 resb 256
    hamming_dist resb 4

section .text
    global _start

_start:
    ; Prompt for first string
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; stdout
    mov rsi, prompt1    ; message
    mov rdx, prompt1_len
    syscall

    ; Read first string
    mov rax, 0          ; syscall: read
    mov rdi, 0          ; stdin
    mov rsi, str1       ; buffer
    mov rdx, 256        ; max length
    syscall

    ; Remove newline from first string
    call strip_newline

    ; Prompt for second string
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    ; Read second string
    mov rax, 0
    mov rdi, 0
    mov rsi, str2
    mov rdx, 256
    syscall

    ; Remove newline from second string
    call strip_newline

    ; Compute Hamming distance
    call compute_hamming_distance

    ; Print result message
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall

    ; Print the computed Hamming distance
    mov rdi, [hamming_dist]
    call print_number

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit program
    mov rax, 60
    xor rdi, rdi
    syscall

; Function to compute Hamming distance
compute_hamming_distance:
    xor rcx, rcx        ; Reset counter (Hamming distance)
    mov rsi, str1
    mov rdi, str2

loop_compare:
    mov al, [rsi]       ; Load character from str1
    mov bl, [rdi]       ; Load character from str2
    test al, al         ; Check for null terminator
    jz end_compare
    test bl, bl
    jz end_compare

    xor al, bl          ; Bitwise XOR (find differing bits)
    test al, al         ; If different, count
    jz skip_increment
    inc rcx             ; Increment Hamming distance

skip_increment:
    inc rsi             ; Move to next character
    inc rdi
    jmp loop_compare

end_compare:
    mov [hamming_dist], rcx
    ret

; Function to remove newline character from string
strip_newline:
    mov rsi, str1       ; Start from first string
strip_loop:
    cmp byte [rsi], 10  ; Check for newline
    jz remove_newline
    test byte [rsi], 0  ; Check for null terminator
    jz end_strip
    inc rsi
    jmp strip_loop

remove_newline:
    mov byte [rsi], 0   ; Replace newline with null terminator
end_strip:
    ret

; Function to print a number
print_number:
    mov rax, 0          ; Clear RAX
    mov rsi, 10         ; Divisor for decimal conversion
    mov rbx, 0          ; Output buffer

convert_loop:
    mov rdx, 0          ; Clear RDX
    div rsi             ; Divide RAX by 10
    add dl, '0'         ; Convert remainder to ASCII
    push rdx            ; Store character
    inc rbx             ; Increase length
    test rax, rax       ; Check if quotient is 0
    jnz convert_loop

print_loop:
    pop rax             ; Get character
    mov rdi, 1          ; stdout
    mov rsi, rsp        ; Buffer
    mov rdx, 1          ; Length
    syscall
    dec rbx
    jnz print_loop
    ret
