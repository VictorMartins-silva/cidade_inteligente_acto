---
status: pessoal
atualizado: "2026-07-22"
dono: coordenador
escopo: vault-pessoal
---

> **⚠️ NOTA DE ESCOPO:** Esta decisão é sobre a arquitetura de agentes de IA do **vault pessoal do coordenador** — não é uma decisão de arquitetura da plataforma de dados (Fabric, Lakehouse, Power BI). Não é relevante para operação do time de engenharia/BI. Mantida aqui apenas para registro histórico pessoal.

# Decisao - Arquitetura de agentes com Orchestrator

## Problema

Uso direto de especialistas sem porta de entrada unica gera roteamento inconsistente em tarefas cross-camada.

## Alternativas

1. Manter apenas especialistas e depender de selecao manual.
2. Criar agente principal para triagem e orquestracao.

## Decisao

Adotar agente principal Acto Orchestrator como entrada padrao e manter 6 especialistas por responsabilidade.

## Status

Aprovada e implementada em .github/agents.

## Impacto

- melhora triagem de tarefas ponta a ponta
- reduz risco de correcao prematura sem causa raiz
- preserva autonomia de uso direto de especialistas
