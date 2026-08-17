---
title: "Guia do Acervo — Índice Completo de Conteúdo"
status: ativo
atualizado: "2026-07-22"
---

# Guia do Acervo

> Este arquivo e um mapa de leitura de tudo que existe hoje dentro de `acervo/`. Diferente do `README.md` (que explica a regra de encaixe — o que vai para onde), este guia lista **cada nota existente, com uma linha do que ela contem**, para achar rápido o que já está documentado antes de escrever algo novo ou propor um envio ao `lakehouse-inmov`.
>
> Organização: por pasta, na mesma ordem do `README.md` raiz. Dentro de cada pasta, notas em ordem de criação/relevância. Ver [README.md](README.md) para a regra de encaixe e [migracao/PLANO_PUBLICACAO_INCREMENTAL.md](migracao/PLANO_PUBLICACAO_INCREMENTAL.md) para o processo de curadoria.

---

## Comece por aqui — Trilha de onboarding por perfil

Se você acabou de entrar no projeto ou está retomando depois de um tempo, leia nesta ordem conforme seu perfil:

### Para todos os perfis (base comum)

1. [`visao-geral-plataforma.md`](visao-geral-plataforma.md) — escopo, topologia e responsabilidades macro
2. [`workspaces-fabric.md`](workspaces-fabric.md) — os 3 lakehouses ativos e regras de governança
3. [`glossario.md`](glossario.md) — termos usados nas notas sem definição explícita

### Engenheiro(a) de dados

4. [`engenharia-dados/padrao-medallion-acto.md`](engenharia-dados/padrao-medallion-acto.md) — padrão de camadas
5. [`engenharia-dados/catalogo-schema-lakehouse-acto.md`](engenharia-dados/catalogo-schema-lakehouse-acto.md) — schema EAV completo + regra crítica de nomenclatura
6. Catálogo de notebooks do seu município (`catalogo-notebooks-santos.md`, `catalogo-notebooks-osasco.md` ou `catalogo-notebooks-maua.md`)
7. [`engenharia-dados/orquestracao-e-observabilidade.md`](engenharia-dados/orquestracao-e-observabilidade.md) — padrão de orquestração
8. [`engenharia-dados/runbook-debug-api-acto.md`](engenharia-dados/runbook-debug-api-acto.md) — guardar para quando uma fonte EAV quebrar

### Analista de BI

4. [`bi/design-system-powerbi.md`](bi/design-system-powerbi.md) — padrão visual e diagnóstico de desvios
5. Catálogo de painéis do seu município (`bi/catalogo-paineis-santos.md` ou `bi/catalogo-paineis-osasco.md`)
6. [`consumo-sql-endpoint.md`](consumo-sql-endpoint.md) — contratos de consumo família × tabela Gold × SLA
7. [`decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita.md`](decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita.md) — padrão de vigência e escrita que afeta análise histórica

### Analista de front-end / integrações

4. [`front-end/README.md`](front-end/README.md) — padrão de acesso, consultas de exemplo, restrições de PII
5. [`consumo-sql-endpoint.md`](consumo-sql-endpoint.md) — contratos por família/eixo temático
6. [`workspaces-fabric.md`](workspaces-fabric.md) (§ SQL Endpoints disponíveis)

### Coordenador / produto

4. [`projetos/projeto-produto-datahub.md`](projetos/projeto-produto-datahub.md) — diagnóstico atual, riscos R1–R9, roadmap
5. Notas de projeto do seu município (`projetos/projeto-acto-santos.md` etc.)
6. [`decisoes/`](decisoes/) — todas as decisões datadas, em ordem cronológica
7. [`migracao/PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md`](migracao/PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md) — itens pendentes de envio ao acervo oficial da equipe

---

## Arquivos raiz (arquitetura transversal)

| Arquivo | Conteúdo |
|---|---|
| `README.md` | Regra de encaixe do acervo — o que entra em cada pasta, o que não migra direto |
| `visao-geral-plataforma.md` | Escopo da plataforma Acto Cidade Inteligente, topologia Fonte→Bronze→Silver→Gold→Consumo, princípios, responsabilidades macro e riscos estruturais conhecidos |
| `workspaces-fabric.md` | Inventário dos 3 workspaces Fabric ativos (`lh_cidade_inteligente_santos`, `lh_dados_publicos`, `lh_solicitacoes_acto`), escopo operacional, regras de governança e checklist mínimo por release |
| `consumo-sql-endpoint.md` | Contratos de consumo de dados via SQL Endpoint — contrato mínimo, padrão de acesso, e tabelas de contrato por família de painel (Santos) e por eixo temático (Osasco), com atraso máximo aceitável e dono por domínio |
| `glossario.md` | Glossário de 14 termos transversais usados no acervo: Medallion, EAV, SCD2, Direct Lake, SQL Endpoint, Gold+IA, Família de painel, Eixo temático, Cluster municipal, Contrato de produto de dados, SLA, Shortcut OneLake, Payload JSON, lakehouses ativos |

---

## engenharia-dados/ — padrões técnicos reutilizáveis

| Arquivo | Conteúdo |
|---|---|
| `padrao-medallion-acto.md` | Padrão de camadas Bronze→Silver→Gold com separação de responsabilidade por etapa |
| `orquestracao-e-observabilidade.md` | Padrão de orquestração de notebooks/pipelines com evidência de sucesso/falha por camada e validação antes de refresh de consumo |
| `monitoramento-fontes-dados.md` | Monitoramento mínimo para detectar degradação de qualidade, quebra de schema e falha de ingestão antes de impactar Gold/BI |
| `catalogo-notebooks-santos.md` | Inventário de 24 notebooks de Santos por camada, para manutenção/onboarding/investigação |
| `catalogo-notebooks-osasco.md` | Inventário de 31 notebooks de Osasco, com plano de migração para Gold em Delta |
| `catalogo-notebooks-maua.md` | Inventário de 4 notebooks de Mauá (Meio Ambiente, Planejamento Urbano) |
| `catalogo-pipelines-santos.md` | Orquestração/dependências dos pipelines de Santos, padrão `Notebook Gold → RefreshSqlEndpoint → Refresh PBI` |
| `problemas-qualidade-dados-obras-santos.md` | Postmortem de paridade Obras Santos: divergências de lógica legado×Acto novo, decisão de negócio sobre unidade de contagem (passagem por etapa, não OS deduplicada) registrada em 22/07/2026 |
| `pipeline-geoespacial-normalizacao-bairros.md` | Padrão técnico para cruzar dado com bairro em texto livre (ex.: SSP-SP) contra malha geográfica oficial e exportar para mapa Power BI |
| `catalogo-schema-lakehouse-acto.md` | Schema completo (60 tabelas: 48 Bronze/3 Silver/9 Gold) e volumetria do modelo EAV do módulo Acto (`lh_solicitacoes_acto`) — regra crítica de nomenclatura de campo EAV (`col` vs `tit`), checklist para adicionar fonte nova |
| `runbook-debug-api-acto.md` | Runbook de diagnóstico de falhas de ingestão na API Acto (EAV): 5 passos acionáveis, regra col×tit, pivot com regex, armadilhas do postmortem de obras Santos |

---

## fontes/ — uma ficha por fonte de dados

| Arquivo | Conteúdo |
|---|---|
| `acto-api.md` | API operacional Acto Gestão — solicitações, etapas, tempos de atendimento |
| `caged.md` | Novo CAGED — mercado de trabalho formal, recorte municipal, risco de código municipal incorreto |
| `ibge-sidra.md` | API pública IBGE SIDRA — indicadores socioeconômicos |
| `rais-bigquery.md` | RAIS via Base dos Dados/BigQuery — dados de emprego e renda |
| `ssp-sp.md` | Dados criminais da SSP-SP, recorte Osasco |
| `datasus-inep-saude-educacao.md` | 6 fontes novas de saúde/educação (CNES, SIM, SINASC, SIH, Censo Escolar, IDEB) — rota BigQuery recomendada, periodicidade e dependências de ordem de ingestão (CNES antes de SIM/SINASC/SIH; Censo Escolar antes de IDEB) |

---

## bi/ — padrões de painel e governança visual

| Arquivo | Conteúdo |
|---|---|
| `design-system-powerbi.md` | Diretriz de padronização de painéis (PBIP, temas, tokens), com diagnóstico de desvios recorrentes em Santos |
| `design-system-powerbi-metodologia.md` | Metodologia operacional completa (5 camadas, 4 fases) para corrigir e manter o design system — **contém pendência de validação de datas inconsistentes na fonte**, confirmar status real antes de usar como pronto |
| `catalogo-paineis-santos.md` | 19 dashboards de Santos em 6 famílias, com tabela família×tabela Gold×riscos |
| `catalogo-paineis-osasco.md` | 24 painéis ativos de Osasco em 9 eixos temáticos |

---

## front-end/ — consumo por aplicações/integrações

| Arquivo | Conteúdo |
|---|---|
| `README.md` | Contrato de acesso, restrições de consumo, integração com SQL Endpoint; alerta de dado sensível (PII) — painéis com PII (ex. CadOZ H1N1 Osasco) não seguem contrato padrão de distribuição ampla |

---

## projetos/ — contexto vivo por cliente/frente

| Arquivo | Conteúdo |
|---|---|
| `projeto-acto-santos.md` | Sustentação/evolução da cadeia de dados Santos — status em produção com backlog de estabilização |
| `projeto-geo-osasco.md` | Visão geoespacial de ocorrências criminais Osasco — pipeline estabilizado, pendências de homologação final |
| `projeto-violencia-mulher-osasco.md` | Pipeline de Boletins de Ocorrência (PM+PC) sobre violência contra a mulher, Osasco — protótipo local completo, sem confirmação de rodar no Fabric |
| `projeto-produto-datahub.md` | Visão de produto "DataHub Municipal": modelo de negócio, diagnóstico do Fabric atual (matriz de risco), arquitetura alvo, estratégia de terceirização de dados públicos, roadmap por fases 0-90+ dias |

---

## decisoes/ — escolhas deliberadas datadas

| Arquivo | Conteúdo |
|---|---|
| `2026-07-21-arquitetura-agentes-orchestrator.md` | Decisão de usar um agente Orchestrator como porta de entrada única para 6 especialistas, em vez de seleção manual |
| `2026-07-21-scd2-carta-credenciais-consistencia-escrita.md` | Padrão transversal: SCD Type 2 para vigência de SLA/Carta de Serviços, renovação controlada de credencial em falha de autenticação, critério de deduplicação obrigatório em append |
| `2026-07-15-bug-payload-api-santos-obras.md` | Postmortem: bug de payload com campos órfãos (quebrava API no 1º catálogo) + bug de nomenclatura EAV inconsistente entre execuções — ambos na fonte obras Santos, resolvidos e validados |

---

## historico/ — fechamento quinzenal curto

| Arquivo | Conteúdo |
|---|---|
| `2026-Q3-rodada-01.md` | Período 01-21/07/2026 — consolidação inicial do vault em acervo por tipo de conhecimento, formalização da arquitetura de agentes |

---

## migracao/ — triagem e publicação incremental (meta-processo do próprio acervo)

| Arquivo | Conteúdo |
|---|---|
| `INVENTARIO_BRUTO.md` | Lista de notas do vault Obsidian candidatas ao acervo, por categoria (índice, essencial, ciclo, apoio, rascunho) — inclui a "segunda leva" de 22/07/2026 (varredura de ~110 arquivos ainda não triados) |
| `MATRIZ_CLASSIFICACAO.md` | Tabela origem→destino→ação→prioridade para cada nota candidata, incluindo a segunda leva de 22/07 |
| `PLANO_PUBLICACAO_INCREMENTAL.md` | As 4 passadas do processo (inventário bruto → classificação → destilação por formato → publicação incremental), cadência semanal/quinzenal, critério de entrada no acervo da equipe |
| `DOCUMENTOS_ESSENCIAIS_ACERVO.md` | Seleção curada do núcleo obrigatório de migração e complementares de alto valor |
| `SELECAO_NOTAS_PARA_MIGRACAO_2026-07-21.md` | Registro histórico de entregas concluídas por rodada (o que já foi migrado, quando) |
| `PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md` | Proposta formal de envio de 10 itens do acervo pessoal para o acervo oficial da equipe (`lakehouse-inmov`) — aguardando revisão do Yuri |

---

## Como usar este guia

- **Antes de escrever uma nota nova:** procure aqui primeiro — várias frentes (ex. paridade Obras, design system PBI, notebooks por município) já têm nota dedicada; complemente em vez de duplicar.
- **Antes de propor algo ao Yuri (`lakehouse-inmov`):** confirme que o conteúdo já está destilado aqui (não é nota bruta do vault Obsidian) — ver regra em `migracao/PLANO_PUBLICACAO_INCREMENTAL.md`, Passada 3 antes da Passada 4.
- **Itens marcados `(novo, 22/07)`** ainda não passaram por uma segunda leitura de revisão — tratar como primeira versão, não como definitivo, até confirmar com quem detém o contexto de cada fonte original.
- Ao adicionar uma nota nova: atualize **apenas este guia** (tabela da seção correspondente) e, se necessário, o `README.md` raiz — os READMEs de subpasta não listam mais arquivos individualmente.
