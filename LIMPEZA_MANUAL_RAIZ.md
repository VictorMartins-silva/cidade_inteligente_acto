# 🧹 Limpeza Manual da Raiz — Instruções Passo a Passo

**Data:** 17/08/2026  
**Problema:** OneDrive está bloqueando operações de arquivo via scripts  
**Solução:** Execute manualmente seguindo os passos abaixo

---

## 📋 Arquivos a Remover (10 arquivos temporários)

- [ ] `CLEANUP_REPORT.md` — Relatório temporário
- [ ] `cleanup_specs.bat` — Script batch temporário
- [ ] `cleanup.ps1` — Script PowerShell temporário
- [ ] `commit_message.txt` — Arquivo de mensagem temporário
- [ ] `git_commands.json` — Arquivo de configuração temporário
- [ ] `REORGANIZACAO_CONCLUIDA.md` — Relatório temporário
- [ ] `reorganize.bat` — Script batch temporário
- [ ] `reorganize.py` — Script Python temporário
- [ ] `temp_test.txt` — Arquivo de teste
- [ ] `test_file.txt` — Arquivo de teste
- [ ] `test_permission.txt` — Arquivo de teste

**Total: 11 arquivos a remover**

---

## ✅ Arquivos a Manter (5 arquivos essenciais)

- ✅ `00_MAPA.md` — Hub central
- ✅ `CLAUDE.md` — Contexto e riscos
- ✅ `REFERÊNCIA_TÉCNICA_COMPLETA.md` — Referência técnica
- ✅ `README_ESTRUTURA.md` — Guia de estrutura
- ✅ `PROGRESSO_REORGANIZACAO.md` — Status da reorganização

---

## 🚀 Opção 1: Executar via Git Bash (RECOMENDADO)

### Passo 1: Abra Git Bash
- Clique com direito na pasta `Documentação_Fabric`
- Selecione "Git Bash Here"

### Passo 2: Execute os comandos (copie e cole)

```bash
# Deletar os 11 arquivos temporários com git rm
git rm -f CLEANUP_REPORT.md \
         cleanup_specs.bat \
         cleanup.ps1 \
         commit_message.txt \
         git_commands.json \
         REORGANIZACAO_CONCLUIDA.md \
         reorganize.bat \
         reorganize.py \
         temp_test.txt \
         test_file.txt \
         test_permission.txt

# Verificar o status
git status

# Fazer commit
git commit -m "chore: limpar arquivos temporários da raiz

Removidos 11 arquivos temporários:
- Scripts de organização (.bat, .ps1, .py)
- Arquivos de teste (temp_test.txt, test_file.txt, etc)
- Relatórios temporários (CLEANUP_REPORT.md, REORGANIZACAO_CONCLUIDA.md)
- Configurações temporárias (git_commands.json, commit_message.txt)

Raiz agora contém APENAS documentação essencial (5 arquivos .md).

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Fazer push
git push origin main
```

### Passo 3: Pronto! ✅

---

## 🚀 Opção 2: Deletar Manualmente no Explorador

Se a Opção 1 não funcionar:

1. Abra o Explorador de Arquivos
2. Vá até `Documentação_Fabric`
3. Selecione com CTRL+Click cada arquivo abaixo:
   - CLEANUP_REPORT.md
   - cleanup_specs.bat
   - cleanup.ps1
   - commit_message.txt
   - git_commands.json
   - REORGANIZACAO_CONCLUIDA.md
   - reorganize.bat
   - reorganize.py
   - temp_test.txt
   - test_file.txt
   - test_permission.txt
4. Pressione DELETE
5. Confirme "Sim, quero deletar"

Depois execute no Git Bash ou PowerShell:
```bash
git status
git add -A
git commit -m "chore: limpar arquivos temporários da raiz"
git push origin main
```

---

## 🚀 Opção 3: Pausar OneDrive e Usar Scripts

Se nenhuma opção acima funcionar:

### Passo 1: Pause OneDrive
1. Clique no ícone OneDrive na bandeja do sistema (canto inferior direito)
2. Selecione "Pausar sincronização" → "2 horas"
3. Aguarde 30 segundos

### Passo 2: Abra PowerShell como Administrador
1. Clique com direito no PowerShell
2. "Executar como Administrador"

### Passo 3: Execute os comandos
```powershell
cd "C:\Users\victor.silva\OneDrive - Eicon Controles Inteligentes de Negocios Ltda\Área de Trabalho\Documentação_Fabric"

# Deletar arquivos
Remove-Item CLEANUP_REPORT.md -Force
Remove-Item cleanup_specs.bat -Force
Remove-Item cleanup.ps1 -Force
Remove-Item commit_message.txt -Force
Remove-Item git_commands.json -Force
Remove-Item REORGANIZACAO_CONCLUIDA.md -Force
Remove-Item reorganize.bat -Force
Remove-Item reorganize.py -Force
Remove-Item temp_test.txt -Force
Remove-Item test_file.txt -Force
Remove-Item test_permission.txt -Force

# Fazer commit via git
git status
git add -A
git commit -m "chore: limpar arquivos temporários da raiz"
git push origin main
```

### Passo 4: Retome OneDrive
1. Clique no ícone OneDrive
2. Selecione "Retomar sincronização"

---

## ✨ Resultado Final Esperado

Após completar qualquer opção acima, a raiz deve conter APENAS:

```
Documentação_Fabric/
├─ 00_MAPA.md
├─ CLAUDE.md
├─ REFERÊNCIA_TÉCNICA_COMPLETA.md
├─ README_ESTRUTURA.md
├─ PROGRESSO_REORGANIZACAO.md
├─ LIMPEZA_MANUAL_RAIZ.md (este arquivo — pode deletar depois)
│
├─ 01-Municípios/
├─ 02-Técnica/
├─ 03-Dados/
├─ 04-Specs/
├─ 05-Painéis/
├─ 06-Estratégia/
│
└─ acervo/ (para deletar manualmente depois)
```

---

## 📝 Checklist de Conclusão

- [ ] Abri uma das 3 opções acima
- [ ] Deletei os 11 arquivos temporários
- [ ] Verifiquei com `git status` que todos foram removidos
- [ ] Fiz commit e push ao GitHub
- [ ] Confirmei no GitHub que os arquivos foram removidos

---

## 🔗 Resultado GitHub

Após push, você deve ver:
- Commit novo aparecer em: https://github.com/VictorMartins-silva/cidade_inteligente_acto/commits/main
- 11 deletions (+) no commit

---

**Precisa de ajuda?** Este arquivo (`LIMPEZA_MANUAL_RAIZ.md`) pode ser deletado depois de concluir a limpeza.

Boa sorte! 🚀
