#!/usr/bin/env python3
"""
Script de reorganização de estrutura de pastas
"""
import os
import shutil
import subprocess
import sys
from pathlib import Path

def run_cmd(cmd):
    """Executar comando e retornar output"""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip(), result.returncode

def main():
    # Mudar para o diretório de trabalho
    base_path = Path.cwd()
    print(f"📁 Diretório base: {base_path}")
    
    # Estrutura de pastas a criar
    folders_to_create = [
        "01-Municípios",
        "02-Técnica/Arquitetura",
        "02-Técnica/Diagramas",
        "02-Técnica/Utils",
        "03-Dados/Dados Públicos",
        "03-Dados/Mapas Geoespaciais",
        "03-Dados/Power BI",
        "04-Specs",
        "05-Painéis",
        "06-Estratégia",
    ]
    
    # Criar pastas
    print("\n📁 Criando estrutura de pastas...")
    for folder in folders_to_create:
        folder_path = base_path / folder
        try:
            folder_path.mkdir(parents=True, exist_ok=True)
            print(f"  ✅ {folder}")
        except Exception as e:
            print(f"  ❌ {folder}: {e}")
            return False
    
    # Mapeamento de movimentos (origem -> destino)
    moves = {
        # Municípios
        "Santos": "01-Municípios/Santos",
        "Osasco": "01-Municípios/Osasco",
        "Acto": "01-Municípios/Acto",
        "Mauá": "01-Municípios/Mauá",
        "SJRP": "01-Municípios/SJRP",
        "Aparecida de Goiânia": "01-Municípios/Aparecida de Goiânia",
        # Técnica
        "doc": "02-Técnica/Arquitetura",
        "diagramas": "02-Técnica/Diagramas",
        "utils": "02-Técnica/Utils",
        # Dados
        "Dados Públicos": "03-Dados/Dados Públicos",
        "mapas": "03-Dados/Mapas Geoespaciais",
        "Powerbi-Santos": "03-Dados/Power BI",
        # Specs
        "specs": "04-Specs",
        # Painéis
        "paineis_negocio": "05-Painéis",
        # Estratégia
        "Produto_DataHub": "06-Estratégia/Produto_DataHub",
        "Tarefas": "06-Estratégia/Tarefas",
    }
    
    # Executar movimentos com git mv
    print("\n📦 Movendo pastas com git mv...")
    for src, dst in moves.items():
        stdout, rc = run_cmd(f'git mv "{src}" "{dst}"')
        if rc == 0:
            print(f"  ✅ {src} → {dst}")
        else:
            print(f"  ❌ {src}: {stdout}")
    
    # Remover acervo
    print("\n🗑️ Removendo acervo...")
    try:
        shutil.rmtree(base_path / "acervo", ignore_errors=True)
        stdout, rc = run_cmd('git rm -r "acervo"')
        if rc == 0:
            print(f"  ✅ acervo removido")
        else:
            print(f"  ℹ️ acervo pode estar em processo (saída: {stdout[:50]})")
    except Exception as e:
        print(f"  ⚠️ Erro ao remover acervo: {e}")
    
    print("\n✅ Reorganização concluída!")
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
