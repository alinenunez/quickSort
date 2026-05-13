#dados globais. esses dados ficam na memória estática, armazena as varíaveis globais, strings e arrays.
.data
    cabeca_da_lista: .word 0     # ponteiro global para o primeiro nó, começa em 0 (lista vazia = NULL)
    espaco:          .string " " # separador entre os números impressos

.text #memória para leitura
.globl main #fica visivel para todos os arquivos. é obrigatório

main:
    addi sp, sp, -4          # abre 4 bytes na stack
    sw   ra, 0(sp)           # salva ra, para conseguirmos restaurar o endereço quando chamarmos o jal ao longo do código

    li   a0, 10              # usa o registrador a0, porque ele é um argumento da função. aqui carrega o valor a inserir. 
    jal  ra, insere_lista    # chama a label/função insere_lista(10)

    li   a0, 20              # a0 = argumento: valor a inserir
    jal  ra, insere_lista    # chama label/função insere_lista(20)

    li   a0, 30              # a0 = argumento: valor a inserir
    jal  ra, insere_lista    # chama label/função insere_lista(30)

    jal  ra, imprime_lista   # chama imprime_lista()

    lw   ra, 0(sp)           # restaura o endereço de ra salvo na stack
    addi sp, sp, 4           # esvazia a pilha, retornando a memoria

    li   a7, 10              # código 10 = exit
    ecall                    # faz a chamada de sistema usando o código informando em a7

aloca_no:
    li   a0, 8               # a0 = 8 bytes. tamanho do nó, são 4 bytes para o valor e 4 bytes para o endereço do próximo nó
    li   a7, 9               # a7 = 9. código para a syscall sbrk
    ecall                    # executa: a0 = endereço alocado no heap. agora o a0 tem o endereço base do novo nó

    ret                      # retorna para insere_lista

insere_lista:
    addi sp, sp, -8          # abre 8 bytes (o tamanho do nó que definimos na função aloca_no)
    sw   ra, 4(sp)           # salva ra na posição sp+4 da stack, para quando chamarmos o próximo jal este endereço de retorno não se perca
    sw   a0, 0(sp)           # salva o valor (que vai ser informado na instrução da main) na posição sp+0 da stack


    jal  ra, aloca_no        # este jal pula para a função aloca_no e salva o endereço da proxima instrução (aqui a da linha 45)

    mv   t0, a0              # movemos o valor de a0 para t0, nesse momento ele é o endereço do novo nó

    lw   t1, 0(sp)           # busca em 0(sp) o valor a ser salvo no nó (definimos no inicio da nossa funcao que a0 seria salvo em 0(sp))
    sw   t1, 0(t0)           # escreve no espaço "valor" do nó o valor que carregamos da stack

    la   t2, cabeca_da_lista # carrega o endereço da variavel cabeça_da_lista em t2
    lw   t3, 0(t2)           # carrega o valor atual de t2 em t3 (que é o endereço do nó atual ou null se for lista vazia)
    sw   t3, 4(t0)           # pega o valor que carregamos em t3 e salva em t0 com um offset de 4

    sw   t0, 0(t2)           # pega o valor de t0 (endereço do novo nó) e salva em t2, então cabeca_da_lista = endereço do novo nó e torna o novo nó como o primeiro da lista

    lw   ra, 4(sp)           # restaura ra para saber o caminho de volta para a main
    addi sp, sp, 8           # esvazia a pilha, retornando a memoria

    ret                      # retorna para main

imprime_lista:
    addi sp, sp, -4          # abre 4 bytes na stack
    sw   s2, 0(sp)           # salva s2 original, s2 é callee-saved então não vamos perder esse valor durante nossas chamadas
  
    la   t2, cabeca_da_lista # t2 = endereço da variável global
    lw   s2, 0(t2)           # carrega em s2 o endereço do primeiro nó da lista

loop_imprime:
    # condição de parada: se s2 == 0 (NULL) chegou no fim da lista
    beq  s2, zero, fim_imprime   # aux == NULL? sai do loop, se chegou no fim da lista pula para fim_imprime

    lw   a0, 0(s2)           # a0 = nó->valor com offset 0
    li   a7, 1               # a7 = 1 código de syscall print_integer
    ecall                    # imprime na tela, s2 preservado pelo ecall

    # imprime um espaço separador
    la   a0, espaco          # a0 = endereço da string " "
    li   a7, 4               # a7 = 4 código de syscall print_string
    ecall                    # imprime, s2 continua preservado

    # avança para o próximo nó: aux = aux->next
    lw   s2, 4(s2)           # s2 = nó->next com offset 4
    j    loop_imprime        # volta para o início do loop

fim_imprime:
    lw   s2, 0(sp)           # restaura s2 original
    addi sp, sp, 4           # restaura a memoria

    ret                      # retorna para main
