@echo off
setlocal enabledelayedexpansion

REM Mudar para o diretório correto
cd /d "C:\Users\victor.silva\OneDrive - Eicon Controles Inteligentes de Negocios Ltda\Área de Trabalho\Documentação_Fabric"

REM Criar pastas temáticas
mkdir "01-Municípios" 2>nul
mkdir "02-Técnica" 2>nul
mkdir "02-Técnica\Arquitetura" 2>nul
mkdir "02-Técnica\Diagramas" 2>nul
mkdir "02-Técnica\Utils" 2>nul
mkdir "03-Dados" 2>nul
mkdir "03-Dados\Dados Públicos" 2>nul
mkdir "03-Dados\Mapas Geoespaciais" 2>nul
mkdir "03-Dados\Power BI" 2>nul
mkdir "04-Specs" 2>nul
mkdir "05-Painéis" 2>nul
mkdir "06-Estratégia" 2>nul

echo Pastas criadas com sucesso!

REM Mover pastas de municípios
git mv Santos "01-Municípios\Santos" 2>nul
git mv Osasco "01-Municípios\Osasco" 2>nul
git mv Acto "01-Municípios\Acto" 2>nul
git mv Mauá "01-Municípios\Mauá" 2>nul
git mv SJRP "01-Municípios\SJRP" 2>nul
git mv "Aparecida de Goiânia" "01-Municípios\Aparecida de Goiânia" 2>nul

REM Mover pastas técnicas
git mv doc "02-Técnica\Arquitetura" 2>nul
git mv diagramas "02-Técnica\Diagramas" 2>nul
git mv utils "02-Técnica\Utils" 2>nul

REM Mover dados
git mv "Dados Públicos" "03-Dados\Dados Públicos" 2>nul
git mv mapas "03-Dados\Mapas Geoespaciais" 2>nul
git mv "Powerbi-Santos" "03-Dados\Power BI" 2>nul

REM Mover specs
git mv specs "04-Specs" 2>nul

REM Mover painéis
git mv paineis_negocio "05-Painéis" 2>nul

REM Mover estratégia
git mv "Produto_DataHub" "06-Estratégia\Produto_DataHub" 2>nul
git mv Tarefas "06-Estratégia\Tarefas" 2>nul

REM Deletar acervo
rmdir /s /q "acervo" 2>nul

echo Reorganização concluída!
pause
