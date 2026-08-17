@echo off
cd /d "C:\Users\victor.silva\OneDrive - Eicon Controles Inteligentes de Negocios Ltda\Área de Trabalho\Documentação_Fabric"
git rm specs/spec_drive_semana_04_05_2026.md specs/spec_drive_semana_11_05_2026.md specs/spec_drive_semana_25_05_2026.md specs/spec_drive_semana_08_06_2026.md specs/spec_drive_semana_15_06_2026.md specs/spec_drive_semana_22_06_2026.md specs/spec_drive_semana_29_06_2026.md
git commit -m "chore: remover specs semanais antigos (^>30 dias)

Mantém histórico recente (últimas 4 semanas):
- spec_drive_semana_06_07_2026.md
- spec_drive_semana_13_07_2026.md
- spec_drive_semana_20_07_2026.md

Removidos 7 specs de maio/junho (conteúdo consolidado em specs/ principais)."
pause
