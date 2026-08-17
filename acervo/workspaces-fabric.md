---
status: validado
atualizado: "2026-07-22"
dono: coordenador
---

# Workspaces Fabric

## Inventario de workspaces

| Workspace | Foco | Status | Observacao |
| --- | --- | --- | --- |
| lh_cidade_inteligente_santos | Operacao principal legado + frentes ativas | ativo | concentra maior volume de notebooks |
| lh_dados_publicos | Dados publicos e geoespacial | ativo | usado na frente Geo Osasco |
| lh_solicitacoes_acto | Modulo Acto refatorado | ativo | arquitetura parametrizada |

## Escopo operacional por workspace

- lh_cidade_inteligente_santos: cadeia medallion principal e base de consumo legada para paineis de operacao
- lh_dados_publicos: cargas publicas, enriquecimento geo e consumo analitico especifico
- lh_solicitacoes_acto: consolidacao do modulo Acto com foco em padronizacao e reuso

## Padrao operacional

- definir ownership por frente
- versionar notebooks e docs de apoio
- monitorar refresh e consistencia de dados publicados

## Regras de governanca

- cada workspace deve ter dono tecnico explicito
- alteracao de pipeline precisa indicar impacto em tabelas Gold e paineis consumidores
- refresh de endpoint/modelo deve ocorrer apenas apos validacao de carga

## Pontos de atencao

- diferencas entre workspace tecnico e workspace de consumo
- sincronizacao de semantic model com atualizacao Gold

## Checklist minimo por release

1. carga concluida sem erro por camada
2. rowcount validado nas tabelas de saida
3. refresh de endpoint/modelo concluido
4. validacao funcional em painel critico da frente
