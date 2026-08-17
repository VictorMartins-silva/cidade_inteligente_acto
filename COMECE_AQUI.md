# ⚡ EXECUTE AGORA — Limpeza da Raiz (Solução Definitiva)

## 🚀 PASSO 1: Pausar OneDrive (IMPORTANTE!)

1. Clique no ícone do OneDrive no canto inferior direito da tela (bandeja do sistema)
2. Selecione "Pausar sincronização" → "2 horas"
3. Aguarde 30 segundos para o OneDrive liberar os arquivos

## 🚀 PASSO 2: Executar o Script

**OPÇÃO A: Script Automático (Recomendado)**

1. Abra o Explorador de Arquivos
2. Navegue até: `Documentação_Fabric`
3. Clique com DIREITO em `EXECUTAR_AGORA.bat`
4. Selecione "Executar como administrador"
5. O script fará tudo automaticamente:
   - Remover os 11 arquivos
   - Fazer commit
   - Fazer push
   - Retomar OneDrive

---

**OPÇÃO B: Manual via Git Bash (Se o .bat não funcionar)**

1. Clique direito na pasta `Documentação_Fabric` → "Git Bash Here"
2. Cole este comando:

```bash
# Remover os 11 arquivos
git rm -f CLEANUP_REPORT.md cleanup_specs.bat cleanup.ps1 commit_message.txt git_commands.json REORGANIZACAO_CONCLUIDA.md reorganize.bat reorganize.py temp_test.txt test_file.txt test_permission.txt

# Verificar
git status

# Fazer commit
git commit -m "chore: limpar arquivos temporarios da raiz

Removidos 11 arquivos temporarios:
- Scripts de organizacao (.bat, .ps1, .py)
- Arquivos de teste (temp_test.txt, test_file.txt, etc)
- Relatorios temporarios (CLEANUP_REPORT.md, REORGANIZACAO_CONCLUIDA.md)
- Configuracoes temporarias (git_commands.json, commit_message.txt)

Raiz agora contem APENAS documentacao essencial.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Fazer push
git push origin main

# Retomar OneDrive (abra manualmente depois)
```

---

## ✅ PASSO 3: Verificar (Após executar)

Acesse: https://github.com/VictorMartins-silva/cidade_inteligente_acto/commits/main

Você deve ver:
- Um novo commit com mensagem "chore: limpar arquivos temporarios"
- "11 deletions" no commit (indicando que 11 arquivos foram removidos)

---

## ⚠️ Retomar OneDrive

Após a limpeza:
1. Clique no ícone OneDrive novamente
2. Selecione "Retomar sincronização"
3. Aguarde a sincronização completar

---

## 🎯 Resultado Final Esperado

Após isso, sua raiz terá APENAS:
- 00_MAPA.md
- CLAUDE.md
- REFERÊNCIA_TÉCNICA_COMPLETA.md
- README_ESTRUTURA.md
- PROGRESSO_REORGANIZACAO.md

✅ Sem scripts, testes ou arquivos temporários!

---

**Comece agora! Escolha a OPÇÃO A (mais fácil) ou OPÇÃO B (manual).**
