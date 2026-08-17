---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Padrao Tecnico - Orquestracao e Observabilidade

## Padrao tecnico

Orquestracao de notebooks e pipelines com evidencias de sucesso/falha por camada e trilha de validacao antes de refresh de consumo.

## Fluxo

1. Trigger pipeline
2. Execucao Bronze/Silver/Gold
3. Validacao de qualidade
4. Refresh endpoint/modelo
5. Publicacao e monitoramento

## Dependencias de pipeline

- mapear notebook upstream/downstream por dominio
- identificar tabela Gold consumida por semantic model
- bloquear refresh quando etapa de carga critica falhar

## Riscos

- falha parcial sem alerta
- retry generico sem isolamento de camada
- falsa percepcao de sucesso

## Pontos de atencao

- classificar camada da falha antes de corrigir
- registrar evidencia de contagem por etapa
- notificar incidentes criticos

## Regras de operacao

- retry deve ser especifico para causa conhecida (ex.: autenticacao)
- mudanca de overwrite/append precisa de justificativa tecnica e impacto esperado
- alteracao em utilitario compartilhado exige revisao de todos os consumidores

## Evidencias minimas por execucao

1. status por atividade da pipeline
2. rowcount de entrada e saida por tabela alvo
3. resultado do refresh de endpoint/modelo
4. observacao de anomalias detectadas

## Referencias

- _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md (fonte pessoal, não versionada)
- Documentação_Fabric/Santos/operacao_acto_santos_e_riscos.md (fonte pessoal, não versionada)
