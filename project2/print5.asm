section .data
    pathname: db "file2.txt", 0  
    buffer: times 2048 db 0     
    newline db 10, 0            
    format_string: db "%s", 0   
    sum_format: db "Sum: %ld", 10, 0  

section .bss
    fd resb 4  
    sum resq 1  ; Store total sum

section .text
    global main
    extern printf

main:
    ;xor edi,edi ; initialise edi as 0
    ;xor rdi,rdi
    ;; read only
    mov eax, 5           
    mov ebx, pathname   
    mov ecx, 0          
    int 0x80            
    mov [fd], eax       

    xor rdi, rdi  ; Clear sum register
    mov [sum], rdi

read_loop:
    ; Read file and cout
    mov eax, 3          
    mov ebx, [fd]       
    mov ecx, buffer     
    mov edx, 2048       
    int 0x80            

    cmp eax, 0
    jle close_file     

    mov byte [buffer+eax], 0  

    ; print each individual number using format string and print
    mov rdi, format_string  
    mov rsi, buffer
    xor rax, rax
    call printf  

    ; we need to add the number to sum. this will parse ASCII to int
    mov rsi, buffer  
    call sum_numbers  

    jmp read_loop  

; initialise registers for where we're going to convert ascii to int
sum_numbers:
    xor rax, rax  ;initialise rax ,the temp register we're going to put the 
    xor rdx, rdx  ; where we're going to put the digits

;; ascii to int is done separately from printing, we will print this sum at the end.
parse_loop:
    movzx rcx, byte [rsi]  ; get byte from buffer
    test rcx, rcx          ; make sure its not null
    jz sum_done            ;;

    ;; make sure the number is a number
    cmp rcx, '0'           
    jl skip_char           ; if the ascii is less than 0, skip this line
    cmp rcx, '9'          ; if the ascii is greater than 9, skip this line 
    jg skip_char           

    sub rcx, '0'           ; Convert ASCII to integer
    imul rax, rax, 10      ; Multiply current number by 10 for the second digit
    add rax, rcx           ; Add new digit

    jmp next_char

skip_char:
    test rax, rax          ; Check if we have a number
    jz next_char           
    add [sum], rax         ; Add current number to sum
    xor rax, rax           ; reset

next_char:
    inc rsi ;increment counter
    jmp parse_loop  ;reloop

sum_done:
    test rax, rax          ; Check if last number needs to be added
    jz end_sum_numbers
    add [sum], rax         ; Add last number

end_sum_numbers:
    ret  

close_file:
    ; Print sum
    mov rsi, [sum]        
    mov rdi, sum_format  
    xor rax, rax        
    call printf        
    ; close out
    mov eax, 6      
    mov ebx, [fd]   
    int 0x80        

    mov eax, 1      
    xor ebx, ebx
    int 0x80  
