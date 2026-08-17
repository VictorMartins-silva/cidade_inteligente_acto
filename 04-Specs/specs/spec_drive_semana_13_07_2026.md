---
title: "Spec Semanal — 13/07/2026 a 18/07/2026"
week: "W29/2026"
periodo: "2026-07-13 a 2026-07-18"
owner: "Victor Silva"
projeto: "Geo Osasco — SSP Criminais"
status: "ativo"
origem: "continuidade W27"
created: 2026-07-13
updated: 2026-07-13
revisao: "2026-07-13 — reconciliado contra o fechamento real de 10/07 (ver [[spec_drive_semana_06_07_2026]] Frente 8 e [[spec_arquitetura_geo_osasco]])"
tags:
  - spec
  - semanal
  - osasco
  - geo
  - power-bi
  - fabric
---

# Spec da Semana — 13/07/2026

## 1. Objetivo da semana
Fechar o ciclo de entrega Geo Osasco com foco em produção de painel, governança de filtro geo e estabilização operacional (dados, validação e rotina de atualização).

> [!important] Reconciliação 13/07 — a maior parte do P0 já foi entregue em 10/07
> Na revisão desta spec contra o trabalho efetivamente registrado (ver [[spec_drive_semana_06_07_2026]], Frente 8), o painel **já foi publicado com `dentro_mapa = 1` aplicado, filtro de natureza do delito e tooltip de cobertura ativo** — não são mais itens em aberto, são trabalho concluído a validar/homologar formalmente. O objetivo real desta semana é mais estreito do que o rascunho original: **homologação formal com o cliente, baseline de performance, runbook de operação e a dívida técnica de fundo (SQL endpoint bloqueado por NaN + evolução do arquivo geo)** — não a construção do painel, que já existe em produção.

## 2. Fechamento da semana anterior (W27) — confirmação

### 2.1 Confirmado como concluído
- Pipeline base de dados entregue em 01/07:
  - nb_utils_geo_osasco.ipynb
  - nb_gold_osasco_ssp_dados_criminais_geo.ipynb
  - nb_gold_osasco_ssp_criminais_geo.ipynb
- Validações iniciais de qualidade implementadas (bbox, cobertura bairro, série temporal).
- Conexão inicial com Power BI e SQL Endpoint registrada.

### 2.2 Evidência de continuidade técnica após W27 — trabalho concluído em 10/07

Reconciliado contra [[spec_drive_semana_06_07_2026]] (Frente 8) e o levantamento local em `geo_osasco/levantamento_fora_mapa/`:

- **Levantamento de qualidade lat/long entregue à cliente**: funil fechado 85.986 marcados OSASCO → 63.620 no mapa (74,0%) → 22.366 excluídos (~97% sem coordenada na origem, irrecuperável por filtro; 744 fora do perímetro). Relatório HTML + Excel + CSV enviado no Teams.
- **`nb_gold_osasco_ssp_criminais_geo.ipynb` reprocessado e validado no Fabric**: grava todos os registros OSASCO com `dentro_mapa` (1/0) + `motivo_fora_mapa`, e `natureza_apurada` + `rubrica` adicionadas ao SELECT (28 naturezas, 100% preenchida). Números da Gold batem exatamente com o levantamento local.
- **Painel Power BI publicado**: filtro `dentro_mapa = 1` aplicado no visual de mapa, filtro por natureza do delito funcionando, medidas DAX de cobertura (`REMOVEFILTERS` em `dentro_mapa`) e **tooltip HTML ativo** (visual HTML Content em página-tooltip) mostrando % cobertura, ocorrências no recorte, plotadas e fora do mapa por motivo — confirmado em produção (screenshot 13/07).
- **Cliente comunicada** via Teams com o resumo e o aviso da nova funcionalidade de tooltip.

### 2.3 Itens genuinamente não concluídos (revisado 13/07)

- **Homologação formal**: a comunicação à cliente foi um aviso informativo via Teams, **não uma ata de validação/aceite** — falta o registro formal de homologação (aceite, ressalvas, próximos passos).
- **Baseline de performance do painel** com volume real — não medido.
- **Runbook/checklist de operação diária/semanal** — não escrito.
- **Rotina de atualização automatizada** (frequência, dono, pipeline agendada) — a Gold hoje é reprocessada manualmente no notebook, sem agendamento no Fabric.
- **Dívida técnica de fundo, ainda aberta**: (a) `silver.ssp_criminais` continua com NaN em lat/long, o que mantém o SQL endpoint inutilizável para essa tabela (erro 24762) — o levantamento local usa leitura direta via `deltalake`/OneLake como contorno, não como correção definitiva; (b) `bairros_osasco.json` continua como arquivo plano no lakehouse (`Files/geo/`), sem migração para Delta Table — risco de ponto único de falha (padrão R1 do projeto).
- **Comparativo local desatualizado**: `nb_analise_comparativa_gold_geo.ipynb` ainda não foi reexecutado com o filtro `dentro_mapa = 1` — a referência antiga de 62.322 registros não reflete a Gold nova.
- Fechamento operacional formal do dia 02/07 (checklist/kanban sem baixa final) — referência original (`Osasco/planejamento_semanal_W27`) não localizada no vault; se o documento existir em outro lugar, linkar aqui.

## 3. Backlog para a semana de 13/07 (revisado — construção do painel já entregue)

### Prioridade P0
- [x] ~~Garantir que todos os visuais de mapa/contagem no PBI apliquem dentro_mapa = 1~~ — **feito 10/07**, confirmar apenas se existe algum visual adicional (tabela/cartão) fora do mapa principal que ainda não tenha o filtro
- [x] ~~Publicar versão do painel com filtros bairro, natureza e período~~ — **publicado 10/07** (natureza e ano confirmados em produção); **validar explicitamente o filtro de bairro**, não confirmado no print mais recente
- [x] ~~Executar reprocessamento da Gold atualizada e RefreshSqlEndpoint~~ — **feito 10/07**, números validados (85.986 / 63.620 / 22.366)
- Registrar homologação formal com o cliente (ata de aceite) — o Teams foi só aviso informativo, falta o registro estruturado

### Prioridade P1
- Validar performance do painel com volume real e registrar baseline
- Padronizar checklist de operação diária/semanal (o painel já roda em produção sem esse runbook)
- Reexecutar `nb_analise_comparativa_gold_geo.ipynb` local com filtro `dentro_mapa = 1` (referência de 62.322 desatualizada)

### Prioridade P2
- Planejar automação de atualização da Gold (janela, frequência e dono) — hoje é reprocessamento manual
- Sanear os NaN de `latitude`/`longitude` em `silver.ssp_criminais` (Fabric) para destravar o SQL endpoint (erro 24762) — beneficia qualquer consumidor futuro da tabela, não só este painel
- Migrar `bairros_osasco.json` de arquivo plano (`Files/geo/`) para Delta Table — reduz risco de ponto único de falha

## 4. Plano diário da semana (13/07 a 18/07) — revisado

| Dia | Foco | Entregável objetivo |
|---|---|---|
| Seg 13/07 | Reconciliação da spec + auditoria de visuais restantes | Spec atualizada (este documento) · confirmar filtro bairro e visuais fora do mapa principal com dentro_mapa=1 |
| Ter 14/07 | Reexecutar comparativo local + fechar dívida do arquivo geo | `nb_analise_comparativa_gold_geo` rodado com dentro_mapa=1 · plano de migração do geojson para Delta Table |
| Qua 15/07 | Saneamento de NaN em silver.ssp_criminais | Notebook Silver ajustado + SQL endpoint validado sem erro 24762 |
| Qui 16/07 | Homologação funcional | Ata de validação com stakeholder (aceite, ressalvas, próximos passos) |
| Sex 17/07 | Performance e documentação | Baseline de performance + runbook curto de operação |
| Sab 18/07 | Revisão semanal e próximo ciclo | Fechamento da semana + backlog priorizado da próxima |

## 5. Critérios de pronto da semana
- Painel com regra de filtragem geo aplicada e validada.
- Dados publicados sem inconsistência entre contagens de mapa e tabela.
- Performance registrada com critérios explícitos.
- Evidência de validação funcional com stakeholder.
- Documentação mínima de operação disponível.

## 6. Riscos da semana e mitigação

| Risco | Severidade | Mitigação |
|---|---|---|
| Visual sem filtro dentro_mapa | Alto | Checklist de revisão visual obrigatório antes da publicação |
| Diferença de contagem após atualização da Gold | Alto | Conferência comparativa dentro_mapa=1 x total antes de refresh final |
| Performance degradada no PBI | Médio | Ajustar escopo temporal padrão e reduzir visuais de alto custo |
| Dependência manual para atualização | Médio | Definir rotina formal com responsável e horário fixo |

## 7. Quadro de execução (checklist)
- [x] Aplicar e validar dentro_mapa = 1 no visual de mapa — **feito 10/07**
- [ ] Confirmar dentro_mapa = 1 em qualquer outro visual (tabela/cartão) que consuma a Gold, além do mapa
- [ ] Confirmar filtro de bairro no painel (natureza e período já confirmados em produção)
- [x] Publicar versão do painel — **feito 10/07** (em produção, tooltip ativo)
- [x] Reprocessar Gold e executar RefreshSqlEndpoint — **feito 10/07** (números validados)
- [ ] Reexecutar `nb_analise_comparativa_gold_geo.ipynb` local com dentro_mapa=1
- [ ] Registrar teste de performance (cenário e tempo)
- [ ] Registrar aceite formal do stakeholder (ata, não apenas aviso via Teams)
- [ ] Atualizar documentação de operação (runbook diário/semanal)
- [ ] Sanear NaN em silver.ssp_criminais (destrava SQL endpoint)
- [ ] Avaliar migração de bairros_osasco.json para Delta Table

## 8. Referências
- [[spec_drive_semana_06_07_2026]] — Frente 8: fechamento técnico completo da entrega de 10/07 (levantamento, Gold, painel, comunicação à cliente)
- [[spec_arquitetura_geo_osasco]] — arquitetura geo Osasco e decisões de design (Gold por domínio, utilitário compartilhado)
- [[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais|Documentação Técnica Geo Osasco SSP]] — desatualizada (última revisão 01/07); não reflete dentro_mapa/natureza_apurada
- `geo_osasco/levantamento_fora_mapa/` (repositório local) — relatório HTML/Excel/CSV enviado à cliente

> [!warning] Referências quebradas removidas desta revisão
> `Osasco/planejamento_semanal_W27` e `Osasco/status_diario_geo_osasco` não foram localizados no vault — se existirem em outro caminho, atualizar os links acima.
