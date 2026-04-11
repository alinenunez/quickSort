# quickSort
Método de ordenação em RISC-V

Modelo base em RISC-V QuickSort:

# Algoritmo Quicksort em RISC-V
# Organiza um array de inteiros em ordem crescente.

# main
addi sp, sp, 10000          # Ajusta o ponteiro de pilha (Stack Pointer)
                            
# Inicialização do Array na memória (Endereço base 0x0)
# Array original: {10, 80, 30, 90, 40, 50, 70}
addi a0, x0, 0              # a0 = endereço base do array (0)

addi t0, x0, 10
sw t0, 0(a0)                # arr[0] = 10
addi t0, x0, 80
sw t0, 4(a0)                # arr[1] = 80
addi t0, x0, 30
sw t0, 8(a0)                # arr[2] = 30
addi t0, x0, 90
sw t0, 12(a0)               # arr[3] = 90
addi t0, x0, 40
sw t0, 16(a0)               # arr[4] = 40
addi t0, x0, 50
sw t0, 20(a0)               # arr[5] = 50
addi t0, x0, 70
sw t0, 24(a0)               # arr[6] = 70

# Preparação para chamar QUICKSORT(arr, 0, 6)
addi a1, x0, 0              # a1 = start (índice 0)
addi a2, x0, 6              # a2 = end (índice 6)

jal ra, QUICKSORT           # Chama a função e salva o retorno em ra
jal ra, EXIT                # Após ordenar, vai para o encerramento

# --- FUNÇÃO QUICKSORT ---
QUICKSORT:
# Prólogo: Salva o contexto na pilha (recursão exige isso)
addi sp, sp, -20            # Aloca 20 bytes na pilha
sw ra, 16(sp)               # Salva endereço de retorno
sw s3, 12(sp)               # Salva s3 (usado para pi - índice do pivô)
sw s2, 8(sp)                # Salva s2 (fim da sublista)
sw s1, 4(sp)                # Salva s1 (início da sublista)
sw s0, 0(sp)                # Salva s0 (endereço base do array)

addi s0, a0, 0              # s0 = a0 (preserva base do array)
addi s1, a1, 0              # s1 = a1 (preserva início)
addi s2, a2, 0              # s2 = a2 (preserva fim)

# Caso Base: se start >= end, a lista está ordenada
BLT a2, a1, START_GT_END    

# Chama PARTITION(arr, start, end)
jal ra, PARTITION           
addi s3, a0, 0              # s3 recebe o índice do pivô (pi) retornado

# Recursão Esquerda: quicksort(arr, start, pi - 1)
addi a0, s0, 0              # restaura base
addi a1, s1, 0              # a1 = start
addi a2, s3, -1             # a2 = pi - 1
jal ra, QUICKSORT           

# Recursão Direita: quicksort(arr, pi + 1, end)
addi a0, s0, 0              # restaura base
addi a1, s3, 1              # a1 = pi + 1
addi a2, s2, 0              # a2 = end
jal ra, QUICKSORT           

START_GT_END:
# Epílogo: Restaura os valores da pilha e retorna
lw s0, 0(sp)
lw s1, 4(sp)
lw s2, 8(sp)
lw s3, 12(sp)
lw ra, 16(sp)
addi sp, sp, 20
jalr x0, ra, 0              # Retorna para quem chamou

# --- FUNÇÃO PARTITION ---
# Reorganiza o array em torno de um pivô (o último elemento)
PARTITION:
addi sp, sp, -4
sw ra, 0(sp)                # Salva ra na pilha

# t0 = pivô (arr[end])
slli t0, a2, 2              # t0 = end * 4 (ajuste de byte)
add t0, t0, a0              # t0 = endereço de arr[end]
lw t0, 0(t0)                # t0 = valor do pivô

addi t1, a1, -1             # t1 = i (índice dos menores elementos, inicia em start-1)
addi t2, a1, 0              # t2 = j (iterador, inicia em start)

LOOP:
BEQ t2, a2, LOOP_DONE       # Enquanto j < end

slli t3, t2, 2              # t3 = j * 4
add a6, t3, a0              # a6 = endereço de arr[j]
lw t3, 0(a6)                # t3 = valor de arr[j]

# Verifica se arr[j] <= pivô
# (Truque: pivô + 1 > arr[j] é o mesmo que pivô >= arr[j])
addi t4, t0, 1              # t4 = pivô + 1
BLT t4, t3, CURR_ELEMENT_GTE_PIVOT # Se pivô < arr[j], pula a troca

# Se menor ou igual, faz o SWAP de arr[i+1] com arr[j]
addi t1, t1, 1              # i++
slli t5, t1, 2              # t5 = i * 4
add a7, t5, a0              # a7 = endereço de arr[i]
lw t5, 0(a7)                # t5 = valor de arr[i]

sw t5, 0(a6)                # arr[j] = antigo arr[i]
sw t3, 0(a7)                # arr[i] = antigo arr[j]

CURR_ELEMENT_GTE_PIVOT:
addi t2, t2, 1              # j++
beq x0, x0, LOOP            # Volta para o início do loop

LOOP_DONE:
# Coloca o pivô na posição correta (i + 1)
addi t5, t1, 1              # t5 = i + 1
addi a5, t5, 0              # Salva o índice para retorno
slli t5, t5, 2              # t5 = (i + 1) * 4
add a7, t5, a0              # a7 = endereço de arr[i + 1]
lw t5, 0(a7)                # t5 = valor de arr[i + 1]

slli t3, a2, 2              # t3 = end * 4
add a6, t3, a0              # a6 = endereço do pivô (arr[end])
lw t3, 0(a6)                # t3 = valor de arr[end]

sw t5, 0(a6)                # arr[end] = arr[i + 1]
sw t3, 0(a7)                # arr[i + 1] = pivô

addi a0, a5, 0              # Retorna o índice do pivô em a0

lw ra, 0(sp)                # Restaura ra
addi sp, sp, 4
jalr x0, ra, 0              # Retorna ao QUICKSORT

EXIT:                       # Fim do programa














OUOUEIEI EIII SEM VOCE NAO VIVEREIII
