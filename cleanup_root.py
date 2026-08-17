#!/usr/bin/env python3
"""
Script de limpeza de arquivos temporários da raiz
Executar com: python cleanup_root.py
"""

import os
import subprocess
import sys

def main():
    # Arquivos a remover
    files_to_remove = [
        'CLEANUP_REPORT.md',
        'cleanup_specs.bat',
        'cleanup.ps1',
        'commit_message.txt',
        'git_commands.json',
        'REORGANIZACAO_CONCLUIDA.md',
        'reorganize.bat',
        'reorganize.py',
        'temp_test.txt',
        'test_file.txt',
        'test_permission.txt',
    ]
    
    print("🧹 Limpeza de arquivos temporários da raiz")
    print("=" * 50)
    
    # Verificar se os arquivos existem
    existing_files = []
    for f in files_to_remove:
        if os.path.exists(f):
            existing_files.append(f)
            print(f"✓ Encontrado: {f}")
        else:
            print(f"✗ Não encontrado: {f}")
    
    if not existing_files:
        print("\n✅ Nenhum arquivo temporário encontrado!")
        return
    
    print(f"\n📊 Total de arquivos a remover: {len(existing_files)}")
    
    # Confirmar
    response = input("\n⚠️  Deseja remover estes arquivos? (s/n): ")
    if response.lower() != 's':
        print("Operação cancelada.")
        return
    
    # Remover com git rm
    print("\n⏳ Removendo arquivos via git...")
    try:
        cmd = ['git', 'rm', '-f'] + existing_files
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Arquivos removidos com sucesso!")
            print(result.stdout)
            
            # Status
            print("\n📋 Status do repositório:")
            status = subprocess.run(['git', 'status'], capture_output=True, text=True)
            print(status.stdout)
            
            # Commit
            print("\n💾 Fazendo commit...")
            commit_msg = """chore: limpar arquivos temporários da raiz

Removidos 11 arquivos temporários:
- Scripts de organização (.bat, .ps1, .py)
- Arquivos de teste (temp_test.txt, test_file.txt, etc)
- Relatórios temporários (CLEANUP_REPORT.md, REORGANIZACAO_CONCLUIDA.md)
- Configurações temporárias (git_commands.json, commit_message.txt)

Raiz agora contém APENAS documentação essencial (5 arquivos .md).

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"""
            
            commit = subprocess.run(['git', 'commit', '-m', commit_msg], capture_output=True, text=True)
            if commit.returncode == 0:
                print("✅ Commit realizado com sucesso!")
                print(commit.stdout)
                
                # Push
                print("\n🚀 Fazendo push ao GitHub...")
                push = subprocess.run(['git', 'push', 'origin', 'main'], capture_output=True, text=True)
                if push.returncode == 0:
                    print("✅ Push concluído com sucesso!")
                    print(push.stdout)
                    print("\n🎉 Limpeza concluída! Acesse https://github.com/VictorMartins-silva/cidade_inteligente_acto/commits/main")
                else:
                    print("❌ Erro no push:")
                    print(push.stderr)
            else:
                print("❌ Erro no commit:")
                print(commit.stderr)
        else:
            print("❌ Erro ao remover arquivos:")
            print(result.stderr)
    
    except Exception as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
