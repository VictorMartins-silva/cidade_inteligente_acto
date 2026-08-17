@echo off
REM Script de limpeza automática - Execute com direito administrativo
REM Clique direito neste arquivo -> Executar como administrador

cd /d "%~dp0"

echo.
echo ===== LIMPEZA DE ARQUIVOS TEMPORARIOS =====
echo.

REM Parar OneDrive temporariamente
echo Parando OneDrive...
taskkill /F /IM onedrive.exe
timeout /t 2 /nobreak

echo.
echo Removendo arquivos temporarios...
echo.

REM Remover os 11 arquivos
git rm -f CLEANUP_REPORT.md
git rm -f cleanup_specs.bat
git rm -f cleanup.ps1
git rm -f commit_message.txt
git rm -f git_commands.json
git rm -f REORGANIZACAO_CONCLUIDA.md
git rm -f reorganize.bat
git rm -f reorganize.py
git rm -f temp_test.txt
git rm -f test_file.txt
git rm -f test_permission.txt

echo.
echo Verificando status...
git status

echo.
echo Fazendo commit...
git commit -m "chore: limpar arquivos temporarios da raiz

Removidos 11 arquivos temporarios:
- Scripts de organizacao (.bat, .ps1, .py)
- Arquivos de teste (temp_test.txt, test_file.txt, etc)
- Relatorios temporarios (CLEANUP_REPORT.md, REORGANIZACAO_CONCLUIDA.md)
- Configuracoes temporarias (git_commands.json, commit_message.txt)

Raiz agora contem APENAS documentacao essencial.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo.
echo Fazendo push...
git push origin main

echo.
echo Retomando OneDrive...
start "" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

echo.
echo ===== LIMPEZA CONCLUIDA! =====
echo Acesse: https://github.com/VictorMartins-silva/cidade_inteligente_acto/commits/main
echo.
pause
