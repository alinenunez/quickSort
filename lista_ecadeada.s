.globl

main:
sw s0 zero zero #head da lista, usa s0 para não sobrescrever e poder voltar nele depois
li a1 10 #valor para o primeiro nó a ser inserido na lista
jal insere_lista
jal imprime_lista
endfor:

insere_lista:
addi sp sp -4 #abre espaço na pilha
sw t1 0(ra)
jal aloca_no

aloca_no:
li a0 8
li a7 9 #codigo da syscall de alocar heap
ecall
jalr


