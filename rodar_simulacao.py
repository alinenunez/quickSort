import random
import subprocess
import os
import re

def executar_experimento(quantidade):
    print(f"\n{'='*50}")
    print(f" INICIANDO EXPERIMENTO COM {quantidade} NÓS ")
    print(f"{'='*50}")
    
    # --- NOVAS VARIÁVEIS DE CAMINHO ---
    pasta_programas = "programs"
    pasta_modelos = "models"

    arquivo_fonte = f"{pasta_programas}/listaencadeada.s"
    arquivo_dados = f"{pasta_programas}/dados_{quantidade}.s"
    binario_saida = f"{pasta_programas}/programa_{quantidade}.bin"
    modelo_gem5 = f"{pasta_modelos}/custom_core.py"
    pasta_saida = f"m5out_{quantidade}"
    
    # 1. Gera o arquivo de dados em Assembly (agora salva dentro da pasta programas)
    print("[1/4] Gerando vetor de números aleatórios...")
    with open(arquivo_dados, "w") as f:
        f.write(".data\n")
        f.write(".globl vetor_dados\n")
        f.write(".globl tamanho_vetor\n\n")
        
        f.write("tamanho_vetor:\n")
        f.write(f"    .word {quantidade}\n\n")
        
        f.write("vetor_dados:\n")
        for _ in range(quantidade):
            numero_aleatorio = random.randint(1, 100000)
            f.write(f"    .word {numero_aleatorio}\n")

        # Montando os caminhos corretos (Pasta + Nome do arquivo) 

    # 2. Compila apontando para os caminhos corretos
    print("[2/4] Compilando com riscv-gcc...")
    comando_gcc = [
        "riscv64-linux-gnu-gcc",
        "-static",
        arquivo_fonte,  # Agora ele sabe que está em programas/listaencadeada.s
        arquivo_dados,  # Agora ele sabe que está em programas/dados_X.s
        "-o", binario_saida # Salva o binário na pasta programas também
    ]
    try:
        subprocess.run(comando_gcc, check=True)
    except subprocess.CalledProcessError:
        print("Erro: Falha na compilação do Assembly. Verifique o código fonte.")
        return

    # 3. Executa a simulação apontando para a pasta models
    print("[3/4] Executando simulação no gem5 (Isso pode demorar um pouco)...")
    comando_gem5 = [
        "build/RISCV/gem5.opt",
        f"--outdir={pasta_saida}", 
        modelo_gem5,                 # Agora ele sabe que está em models/custom_core.py
        f"--binary={binario_saida}"  # Busca o binário recém-criado na pasta programas
    ]
    
    # ... (O resto do script de extração de métricas continua exatamente igual)
    try:
        # Usamos capture_output=True para esconder os logs gigantes do gem5 no terminal,
        # focando apenas nas métricas que importam.
        subprocess.run(comando_gem5, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        print("Erro na execução do gem5:")
        print(e.stderr)
        return
    
    # 4. Extração Automática de Métricas
    print("[4/4] Extraindo métricas do stats.txt...")
    caminho_stats = os.path.join(pasta_saida, "stats.txt")
    
    if os.path.exists(caminho_stats):
        with open(caminho_stats, "r") as f:
            conteudo_stats = f.read()
            
            # Usando expressões regulares para achar as linhas exatas no arquivo de log
            sim_ticks = re.search(r'simTicks\s+(\d+)', conteudo_stats)
            ipc = re.search(r'board\.processor\.cores\.core\.ipc\s+([0-9.]+)', conteudo_stats)
            
            print("\n>>> RESULTADOS <<<")
            if sim_ticks:
                print(f"Tempo total (simTicks): {sim_ticks.group(1)}")
            else:
                print("Tempo total (simTicks): Não encontrado")
                
            if ipc:
                print(f"IPC (Instruções/Ciclo): {ipc.group(1)}")
            else:
                print("IPC: Não encontrado. (Verifique se o nome da métrica no seu gem5 é exatamente system.processor.cores.core.ipc)")
    else:
        print(f"Erro: Arquivo {caminho_stats} não foi gerado.")

# Para rodar os cenários exigidos pelo trabalho:
executar_experimento(900000)
executar_experimento(1000000)
executar_experimento(2000000)
executar_experimento(3000000)
executar_experimento(4000000)
executar_experimento(5000000)