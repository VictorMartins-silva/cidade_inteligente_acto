# Proposta de envio: acervo pessoal → lakehouse-inmov (atualizada 2026-07-24)

## Objetivo

Levantamento do que existe no acervo pessoal (`Documentação_Fabric/acervo`) sem equivalente — ou com valor incremental real — no acervo oficial da equipe (`lakehouse-inmov`). Não sou dono de nenhuma pasta do lakehouse-inmov: este documento é a base para revisão do Yuri. Após ele habilitar, o commit no repositório é feito seguindo o fluxo oficial (`operacao-do-acervo.md` / `CONTRIBUTING.md`) — Issue do formulário correspondente → triagem → curadoria pelo coordenador → publicação na `main`.

Cada item abaixo já vem estruturado no formato exigido pelos formulários de Issue do lakehouse-inmov (`contribuir-conhecimento.yml` ou `registrar-decisao.yml`), para copiar direto na abertura da Issue depois da validação do Yuri.

## ✅ Atualização 24/07/2026 — 4 itens que tinham sido publicados sem curadoria foram reconciliados

Entre 22/07 e 24/07, uma sessão de trabalho fez uma varredura independente do vault Obsidian (sem checar esta proposta antes) e escreveu 16 arquivos novos diretamente no `lakehouse-inmov`, pulando o fluxo Issue → triagem → curadoria. Quatro deles colidiam em tema com itens já preparados aqui. Nenhum foi perda de dado — os quatro criaram arquivo novo, não sobrescreveram nada — mas passaram a existir duas versões do mesmo conteúdo em lugares diferentes. No mesmo dia (24/07), as duas versões foram cotejadas e o lakehouse-inmov foi corrigido diretamente (não gera Issue nova — o conteúdo já estava na `main`). Resultado por item:

| Item aqui | Publicado como (lakehouse-inmov) | Situação após reconciliação (24/07) |
|---|---|---|
| #11 — Catálogo de schema EAV do módulo Acto | `engenharia-dados/ingestao/acto-api-schema.md` | **Reconciliado e fechado.** Mantido no destino já publicado (`ingestao/`, não a raiz de `engenharia-dados/` — decisão: ficar junto de `acto-api.md`, mesmo assunto de ingestão). Enriquecido com o que só existia na versão desta nota: diagrama de fluxo, checklist de 6 passos para nova fonte, regra crítica `col`/`tit`, riscos por fonte (obras com 212 etapas distintas, fonte residual sem pipeline) e pontos de atenção de volumetria. **Regra `col`/`tit` confirmada com o engenheiro de dados em 24/07** — só resta revalidar se a volumetria por fonte mudou desde o levantamento de 09/06 (item menor, não bloqueante). |
| #12 — Ficha de fontes DATASUS/INEP | 5 arquivos em `catalogo-dados/fontes/`: `datasus-cnes.md`, `datasus-sim-sinasc.md`, `datasus-sih.md`, `censo-escolar.md`, `ideb.md` | **Reconciliado.** Mantida a divisão em 5 fichas (coerente com o padrão "uma nota por fonte" da pasta — melhor que a divisão em 2 sugerida originalmente aqui). Adicionado a cada ficha o que só existia nesta nota: campo "Lakehouse alvo" (`lh_dados_publicos`, schema canônico) e seção "Restrições LGPD" (microdado individual em SIM/SINASC/SIH/matrícula do Censo Escolar exige agregação em Gold/painel). **Confirmado 24/07:** segue mesmo em `status: rascunho`/fase de planejamento, nenhuma das 6 bases ingerida ainda — tratar as 5 fichas como candidatas, não como definitivas. |
| #13 — Postmortem bug payload Obras Santos | `decisoes/2026-07-15-bug-payload-api-santos-obras.md` | **Correção de registro:** a alegação anterior nesta proposta de que a versão publicada usava "nomes reais dos envolvidos" estava **errada** — reconferido em 24/07, a versão publicada já era anonimizada, só com estrutura/redação diferente da preparada aqui (conteúdo tecnicamente equivalente, números batendo). Único ajuste real feito: corrigido um link quebrado no arquivo publicado (`2026-07-07-manter-paineis-obras-no-modelo-eav.md` → nome de arquivo real, sem o "no-" extra). **Confirmado 24/07:** o gap de "executor responsável abaixo da referência" ainda não foi investigado — fica com Victor para as próximas semanas, sem data fechada. |
| (não numerado — seção "Criados em 22/07") — `projetos/projeto-produto-datahub.md` | 3 arquivos em `arquitetura/datahub-municipal/`: `visao-produto-modelo-negocio.md`, `estrategia-terceirizacao-base-dos-dados.md`, `roadmap-fases.md` | **Reconciliado — risco de sensibilidade resolvido.** Os 3 arquivos publicados nomeavam pessoas reais como responsáveis por decisões de negócio, incluindo o contato da secretaria cliente por nome. Em 24/07, todas as ocorrências foram trocadas pela mesma convenção de anonimização já usada nesta nota (`responsável técnico externo`, `responsável pela reconexão de painéis Santos`, `stakeholder de negócio do município principal`) — conferido por busca de texto, nenhum nome próprio resta nos 3 arquivos. Nenhuma credencial ou segredo literal foi encontrado (o risco real era só de nome de pessoa, não de dado técnico sensível). |

Das 3 pendências de validação factual identificadas na reconciliação, 2 já fecharam (24/07): a regra crítica `col`/`tit` do schema Acto foi confirmada com o engenheiro de dados, e o gap de executor responsável ficou registrado como tarefa do Victor para as próximas semanas. Só o `status: rascunho` do DATASUS/INEP segue genuinamente em aberto — confirmado que a fonte ainda está em planejamento, sem previsão de ingestão.

## Critério de seleção aplicado

- Entra na proposta: conteúdo sem equivalente no lakehouse-inmov, ou que preenche gap real já citado em doc oficial (ex.: RAIS citado em `pipelines-e-orquestracao.md` sem ficha de fonte própria).
- Fica de fora: qualquer tema que já tem versão no lakehouse-inmov tecnicamente mais completa/aterrada (nomes reais de notebook, tabela, config) — comparação feita nota a nota, ver seção "Itens descartados" ao final.

> **Indicador de prontidão:** itens com `status: validado` no frontmatter do arquivo de origem estão prontos para curadoria. Itens com `status: rascunho` precisam de revisão antes.

## Mapa de destino no lakehouse-inmov

Onde cada item desta proposta cai (ou já caiu) na estrutura de pastas do acervo oficial. `✅` = já publicado e reconciliado (24/07) — não abrir Issue. `⏳` = aguardando Yuri, segue o fluxo normal (Issue → triagem → curadoria). Pastas/arquivos sem marcação já existiam antes desta proposta, listados só para orientação.

```text
lakehouse-inmov/                                        (github.com/datahub-eicon/acervo)
│
├── arquitetura/
│   └── datahub-municipal/
│       ├── spec-datahub-municipal.md                    já existia — PRD abstrato
│       ├── visao-produto-modelo-negocio.md               ✅ publicado 24/07 · reconciliado (nomes anonimizados)
│       ├── estrategia-terceirizacao-base-dos-dados.md    ✅ publicado 24/07 · reconciliado
│       └── roadmap-fases.md                              ✅ publicado 24/07 · reconciliado
│
├── bi/
│   ├── constituicao-pbi.md, diretrizes-servico.md, ...   já existiam
│   ├── catalogo-paineis-santos.md                        ⏳ item 5
│   └── catalogo-paineis-osasco.md                        ⏳ item 6
│
├── catalogo-dados/fontes/
│   ├── acto.md, caged.md, ibge.md, ssp.md, ...           já existiam
│   ├── rais.md                                            ⏳ item 8
│   ├── datasus-cnes.md                                    ✅ publicado 24/07 · status: rascunho (planejamento)
│   ├── datasus-sim-sinasc.md                              ✅ publicado 24/07 · status: rascunho
│   ├── datasus-sih.md                                     ✅ publicado 24/07 · status: rascunho
│   ├── censo-escolar.md                                   ✅ publicado 24/07 · status: rascunho
│   └── ideb.md                                            ✅ publicado 24/07 · status: rascunho
│
├── decisoes/
│   ├── 2026-07-20-*.md, 2026-07-21-fechamento-semanal.md  já existiam (governança do acervo)
│   ├── 2026-07-01-nao-trocar-fonte-ssp-criminais-geo.md   publicado fora desta proposta (frente Geo Osasco)
│   ├── 2026-07-07-manter-paineis-obras-modelo-eav.md      publicado fora desta proposta (frente Obras Santos)
│   ├── 2026-07-15-bug-payload-api-santos-obras.md         ✅ publicado 22/07 · reconciliado 24/07 (item 13)
│   ├── 2026-07-21-scd2-carta-credenciais-consistencia-escrita.md  ⏳ item 9
│   └── 2026-07-23-seont-saida-legitima-usuario-sistema.md publicado fora desta proposta (frente Obras Santos)
│
├── engenharia-dados/
│   ├── monitoramento-fontes-dados.md, pipelines-e-orquestracao.md, snippets.md  já existiam
│   ├── catalogo-notebooks-osasco.md                       ⏳ item 1
│   ├── catalogo-notebooks-santos.md                       ⏳ item 2
│   ├── catalogo-notebooks-maua.md                         ⏳ item 3
│   ├── catalogo-pipelines-santos.md                       ⏳ item 4
│   ├── runbook-debug-api-acto.md                          ⏳ item 14
│   └── ingestao/
│       ├── acto-api.md, fontes-publicas-basedosdados.md, postgresql-notebook.md  já existiam
│       └── acto-api-schema.md                              ✅ publicado 24/07 · reconciliado e fechado (item 11)
│
├── front-end/
│   └── consumo-sql-endpoint.md                             ⏳ itens 7 e 10 (nova seção de contratos + governança PII)
│
└── projetos/, historico/, convencoes.md, operacao-do-acervo.md, ...   não afetados por esta proposta
```

---

## 1. Contribuição — Catálogo de notebooks Osasco ✅ pronto

**Resumo:** Inventário dos 31 notebooks de Osasco por camada, com os pontos críticos de migração para Gold em Delta.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/catalogo-notebooks-osasco.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/catalogo-notebooks-osasco.md` (arquivo novo)
**Pendências:** Confirmar com o engenheiro de dados se a contagem de notebooks (31) e os pontos críticos de migração ainda procedem; verificar se algum dos 5 pontos críticos já foi resolvido desde o levantamento.

---

## 2. Contribuição — Catálogo de notebooks Santos ✅ pronto

**Resumo:** Inventário dos 24 notebooks de Santos por camada, útil para manutenção, onboarding e investigação de bugs.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/catalogo-notebooks-santos.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/catalogo-notebooks-santos.md` (arquivo novo)
**Pendências:** Cruzar com a lista de notebooks legados vs. nova arquitetura Acto já documentada em `arquitetura/visao-geral-plataforma.md` (§4.2 do lakehouse-inmov) para evitar contradição sobre quais notebooks ainda estão ativos.

---

## 3. Contribuição — Catálogo de notebooks Mauá ✅ pronto

**Resumo:** Inventário dos 4 notebooks de Mauá (Meio Ambiente e Planejamento Urbano).
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/catalogo-notebooks-maua.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/catalogo-notebooks-maua.md` (arquivo novo)
**Pendências:** Confirmar que Mauá continua sem pipeline/painel publicado antes de publicar (pode ter mudado).

---

## 4. Contribuição — Catálogo de pipelines Santos ✅ pronto

**Resumo:** Mapa de orquestração e dependências dos pipelines de Santos, no padrão Notebook Gold → RefreshSqlEndpoint → Refresh PBI.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/catalogo-pipelines-santos.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/catalogo-pipelines-santos.md` (arquivo novo)
**Pendências:** Validar se a lista de pipelines por secretaria ainda reflete o pipeline ativo, considerando a migração legado → Acto já em andamento (§4.2 de `arquitetura/visao-geral-plataforma.md`).

---

## 5. Contribuição — Catálogo de painéis Power BI Santos ✅ pronto

**Resumo:** 19 dashboards de Santos organizados em 6 famílias, com tabela família × tabela Gold × riscos conhecidos.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `bi/catalogo-paineis-santos.md` (`status: validado`)
**Destino sugerido:** `bi/catalogo-paineis-santos.md` (arquivo novo)
**Pendências:** Confirmar com a analista de BI se as 19 famílias/painéis e os riscos listados continuam válidos.

---

## 6. Contribuição — Catálogo de painéis Power BI Osasco ✅ pronto

**Resumo:** 24 painéis ativos de Osasco organizados em 9 eixos temáticos.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `bi/catalogo-paineis-osasco.md` (`status: validado`)
**Destino sugerido:** `bi/catalogo-paineis-osasco.md` (arquivo novo)
**Pendências:** Validar se o painel CadOZ segue sem contrato de distribuição ampla (checar com quem administra acesso).

---

## 7. Contribuição — Contratos de consumo por família/eixo de painel (Santos e Osasco) ✅ pronto

**Resumo:** Contrato mínimo de consumo via SQL Endpoint — padrão de acesso e tabelas de contrato por família de painel (Santos) e eixo temático (Osasco), com atraso máximo aceitável e dono por domínio.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `consumo-sql-endpoint.md` (`status: validado`)
**Destino sugerido:** `front-end/consumo-sql-endpoint.md` (nova seção "Contratos por família/eixo de consumo")
**Pendências:** Validar os prazos de "atraso máximo aceitável" com o dono de cada domínio antes de tornar contrato oficial; confirmar se o dono da pasta correto para este conteúdo é front-end ou engenharia-dados (a tabela cruza Gold com consumo).

---

## 8. Contribuição — Ficha de fonte: RAIS (BigQuery / Base dos Dados) ✅ pronto

**Resumo:** Como a fonte RAIS (emprego e renda) é ingerida via Base dos Dados/BigQuery — a prova de conceito que validou o padrão de terceirização replicado depois para DATASUS/INEP.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `fontes/rais-bigquery.md` (`status: validado`)
**Destino sugerido:** `catalogo-dados/fontes/rais.md` (arquivo novo)
**Pendências:** Enriquecer com os detalhes técnicos já existentes em `pipelines-e-orquestracao.md` antes de publicar, para não regredir o nível de detalhe do restante da pasta `catalogo-dados/fontes/`.

---

## 9. Registro de decisão — SCD2 para Carta de Serviços, credenciais e consistência de escrita ✅ pronto

**Resumo:** Padrão transversal: SCD Type 2 para vigência de SLA da Carta de Serviços, renovação controlada de credencial em falha de autenticação, e critério de deduplicação obrigatório em toda escrita `append`.
**Formulário:** `registrar-decisao`
**Arquivo de origem:** `decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita.md` (`status: validado`)
**Destino sugerido:** `decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita.md` (arquivo novo)
**Pendências:** A curadoria deve decidir se isso vira uma decisão nova independente ou um adendo/registro formal do que já está descrito como "Ação requerida (P0)" em `arquitetura/visao-geral-plataforma.md` §4.1 e §4.2, para não duplicar o mesmo assunto em dois lugares. Confirmar status real: se já há aplicação em andamento, marcar como `aceita`; se é só proposta, marcar como `proposta`.

---

## 10. Contribuição — Alerta de dado sensível (PII) em consumo front-end ✅ pronto

**Resumo:** Contrato de acesso e restrições de consumo via SQL Endpoint, com alerta de que painéis com PII (ex. CadOZ) não seguem o contrato padrão de distribuição ampla.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `front-end/README.md` (`status: validado`)
**Destino sugerido:** seção de governança em `front-end/consumo-sql-endpoint.md` (mesmo destino do item 7) ou nota própria, a critério da curadoria
**Pendências:** Confirmar se já existe controle de acesso dedicado para CadOZ ou se isso ainda é uma lacuna a ser tratada como risco aberto.

---

## Novos candidatos (22/07/2026)

### 11. Contribuição — Catálogo de schema EAV do módulo Acto ✅ publicado e reconciliado 24/07 (não abrir Issue nova)

**Resumo:** Dicionário de dados completo do módulo EAV do Acto (60 tabelas: 48 Bronze, 3 Silver, 9 Gold), com a regra crítica de nomenclatura `col` vs. `tit` e um checklist para adicionar fonte nova.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/catalogo-schema-lakehouse-acto.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/catalogo-schema-lakehouse-acto.md` (arquivo novo)
**Valor:** Schema completo das 60 tabelas (48 Bronze, 3 Silver, 9 Gold), regra crítica `col vs tit`, checklist para adicionar fonte nova — não existe equivalente no lakehouse-inmov; é o item de maior valor técnico desta leva.
**Pendências:** Confirmar volumetria atual (pode ter mudado desde o levantamento); engenheiro de dados validar regra crítica de nomenclatura com base na versão mais recente dos notebooks.
**Status 24/07:** existe no lakehouse-inmov como `engenharia-dados/ingestao/acto-api-schema.md` — localização final decidida (fica em `ingestao/`, junto de `acto-api.md`). Conteúdo reconciliado: incorporado o checklist de 6 passos, o diagrama de fluxo e a seção de riscos por fonte que só existiam nesta nota. **Regra crítica de nomenclatura (`col` vs. `tit`) confirmada com o engenheiro de dados em 24/07** — pendência fechada. Só resta item menor: revalidar se a volumetria por fonte (levantada em 09/06) mudou desde então.

---

### 12. Contribuição — Ficha de fontes: DATASUS e INEP (6 bases saúde/educação) ⚠️ publicado e reconciliado 24/07, mas ainda `rascunho` de conteúdo (não abrir Issue nova)

**Resumo:** Mapeamento técnico das 6 fontes públicas de saúde e educação (CNES, SIM, SINASC, SIH, Censo Escolar, IDEB) — rota de ingestão via BigQuery, periodicidade, dependências entre as bases e restrições de LGPD.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `fontes/datasus-inep-saude-educacao.md` (`status: rascunho`)
**Destino sugerido:** `catalogo-dados/fontes/datasus-saude.md` + `catalogo-dados/fontes/inep-educacao.md` (dividir em 2 fichas, ou ficha única `datasus-inep.md` — a critério da curadoria)
**Valor:** Rota via BigQuery já validada, dependências de ingestão (CNES → SIM/SINASC/SIH), regra de dado preliminar vs. fechado para SIM/SINASC/SIH, restrições LGPD — nenhum desses domínios tem ficha em `catalogo-dados/fontes/` hoje.
**Pendências:** Confirmar com o responsável técnico externo se a "validação de fase 2" ainda está pendente antes de tratar o arquivo como definitivo (ver seção "Pendências externas" do arquivo de origem). Resolver o `status: rascunho` antes de abrir a Issue.
**Status 24/07:** existe no lakehouse-inmov como 5 arquivos separados em `catalogo-dados/fontes/`: `datasus-cnes.md`, `datasus-sim-sinasc.md`, `datasus-sih.md`, `censo-escolar.md`, `ideb.md` — granularidade maior que a sugerida aqui (uma fonte por arquivo), coerente com o padrão do resto da pasta; mantida como a divisão definitiva. Reconciliado: adicionado a cada ficha o campo "Lakehouse alvo" e a seção "Restrições LGPD" que só existiam nesta nota. **Pendência confirmada (24/07):** segue em `status: rascunho`/fase de planejamento — nenhuma das 6 bases foi ingerida ainda, "validação de fase 2" continua pendente. Não tratar nenhuma das 6 fichas como definitiva até a fase de ingestão de fato começar.

---

### 13. Registro de decisão — Postmortem: bug de payload e nomenclatura EAV (fonte obras Santos) ✅ publicado 22/07, conferido 24/07 — sem problema real, não abrir Issue nova

**Resumo:** Postmortem de dois bugs de produção na fonte `santos_obras` — payload com campos órfãos travando a API e nomenclatura de campo EAV inconsistente entre execuções — com as lições para qualquer fonte EAV nova.
**Formulário:** `registrar-decisao`
**Arquivo de origem:** `decisoes/2026-07-15-bug-payload-api-santos-obras.md` (`status: validado`)
**Destino sugerido:** `decisoes/2026-07-15-bug-payload-api-santos-obras.md` (arquivo novo)
**Valor:** As 4 lições deste postmortem evitam repetição do mesmo padrão de bug em qualquer fonte EAV nova — especialmente a regra de usar regex em vez de nome exato no pivot Gold e a de testar payload fora do Fabric primeiro.
**Pendências:** Confirmar se o item em aberto ("executor responsável em etapa de análise técnica abaixo da referência do legado") já foi investigado — se sim, atualizar o status antes de publicar.
**Status 24/07:** existe no lakehouse-inmov com **exatamente este mesmo nome de arquivo**. Reconferido em 24/07: **ao contrário do que uma versão anterior desta nota registrou**, a versão publicada já estava anonimizada — não havia nome real, só estrutura/redação diferente (conteúdo tecnicamente equivalente, números batendo com este arquivo). Único ajuste feito: corrigido um link quebrado no arquivo publicado. **Pendência confirmada (24/07):** o gap de "executor responsável abaixo da referência" ainda **não foi investigado** — fica com Victor para as próximas semanas, sem data fechada. Registrado nos dois arquivos (aqui e no lakehouse-inmov).

---

### 14. Contribuição — Runbook de debug da API Acto ✅ pronto

**Resumo:** Passo a passo para diagnosticar falhas de ingestão na API Acto (EAV): 5 passos acionáveis, regra `col`×`tit`, pivot com regex e armadilhas já conhecidas do postmortem de Obras Santos.
**Formulário:** `contribuir-conhecimento`
**Arquivo de origem:** `engenharia-dados/runbook-debug-api-acto.md` (`status: validado`)
**Destino sugerido:** `engenharia-dados/runbook-debug-api-acto.md` (arquivo novo)
**Valor:** Único documento operacional que consolida o "o que fazer quando a ingestão Acto quebra" em passos acionáveis; o lakehouse-inmov não tem nenhum runbook de diagnóstico hoje.
**Pendências:** Engenheiro de dados validar os comandos SQL de diagnóstico da seção "Passo 3" com os nomes de schema reais do ambiente de produção antes de publicar.

---

## Enriquecimento recente do acervo pessoal (informativo — não é proposta de envio)

Varredura adicional feita no repositório-fonte maior (`Mapeamento_fabric/`, do qual `Documentação_Fabric` é só o vault já podado) resultou em 3 notas novas criadas em 21/07. Em 22/07, mais 2 notas foram adicionadas e ficam fora da proposta principal. Todos os itens registrados aqui para o Yuri ter visibilidade e decidir se algum vira Issue futuramente.

**Criados em 21/07 (sem proposta de envio):**

| Nota | Pasta | Comparação com o que já existe no lakehouse-inmov |
|---|---|---|
| `engenharia-dados/problemas-qualidade-dados-obras-santos.md` | engenharia-dados/ | Não há equivalente — documenta as 7 divergências de lógica entre o Gold de Obras legado (`lh_cidade_inteligente_santos`, congelado desde 11/03/2025 por HTTP 401) e o novo módulo Acto, com achados de auditoria até 21/07. Conteúdo específico de investigação, não de padrão de plataforma. |
| `engenharia-dados/pipeline-geoespacial-normalizacao-bairros.md` | engenharia-dados/ | Não há equivalente — padrão técnico reutilizável (shapefile → GeoJSON, conversão EPSG:3857→4326) para cruzar dado com bairro em texto livre contra malha oficial. Tema não coberto em nenhuma nota do lakehouse-inmov hoje. |
| `bi/design-system-powerbi-metodologia.md` | bi/ | Complementa (não substitui) `bi/constituicao-pbi.md`/`diretrizes-servico.md` do lakehouse-inmov — traz metodologia operacional em 5 camadas/4 fases e artefatos prontos (temas JSON, templates HTML, tokens DAX). **Contém pendência de validação**: fonte tem inconsistência de data sobre o status real do projeto (uma diz concluído em 2026-08-17, data futura; outra diz "em desenvolvimento" em 2026-07-17) — não tratar como pronto para uso sem confirmar com quem mantém. |

**Criados em 22/07 (sem proposta de envio):**

| Nota | Pasta | Observação |
|---|---|---|
| `glossario.md` | raiz do acervo | Transversal, sem equivalente no lakehouse-inmov — mas é meta-documento do acervo pessoal, não conteúdo técnico de plataforma. Avaliar com a curadoria se faz sentido ter equivalente no lakehouse-inmov. |
| `projetos/projeto-produto-datahub.md` | projetos/ | Visão de produto do Datahub Municipal — cobre riscos com credenciais expostas e decisões de arquitetura em aberto. **Não enviar sem triagem cuidadosa**: parte do conteúdo pode ser informação sensível de operação interna. **Status 24/07:** foi publicado no lakehouse-inmov exatamente sem essa triagem, como 3 arquivos em `arquitetura/datahub-municipal/` (`visao-produto-modelo-negocio.md`, `estrategia-terceirizacao-base-dos-dados.md`, `roadmap-fases.md`), nomeando pessoas reais (incluindo o contato da secretaria cliente por nome) onde esta nota usava "responsável técnico externo"/"stakeholder de negócio do município principal". **Reconciliado no mesmo dia:** todos os nomes reais nos 3 arquivos foram trocados pela mesma convenção de anonimização usada aqui, conferido por busca de texto (nenhum nome próprio resta). Nenhuma credencial ou segredo literal foi encontrado nos arquivos — o risco era só de nome de pessoa. |

Também foi criada `projetos/projeto-violencia-mulher-osasco.md` (projeto com protótipo local completo — bronze/silver/gold + painel de referência — mas sem confirmação de que já roda no Fabric). Fica de fora da tabela acima por já ter formato de nota "projeto vivo", não de padrão técnico.

---

## Itens descartados (não entram na proposta)

| Origem | Motivo |
|---|---|
| `migracao/*` (todo o conteúdo) | Processo interno de destilação do vault pessoal, não é conhecimento de produto/plataforma. |
| `decisoes/2026-07-21-arquitetura-agentes-orchestrator.md` | Trata da arquitetura de agentes/skills do vault pessoal (Claude/Copilot), não da plataforma de dados compartilhada. |
| `historico/2026-Q3-rodada-01.md` | Fala da organização do próprio vault pessoal, não de entregas reais do time. |
| `arquitetura/visao-geral-plataforma.md`, `workspaces-fabric.md` (pessoal) | Já existe versão no lakehouse-inmov muito mais completa e tecnicamente aterrada (nomes reais de notebook/tabela, 3 gerações de arquitetura, análise crítica §4, benchmark §6). Nada de novo a agregar. |
| `engenharia-dados/monitoramento-fontes-dados.md`, `pipelines-e-orquestracao.md`/`padrao-medallion-acto.md` (pessoal) | Versão do lakehouse-inmov (`engenharia-dados/monitoramento-fontes-dados.md`, `pipelines-e-orquestracao.md`) já cobre o mesmo tema com grão de notebook real (`nb_setup_monitoramento`, `nb_checar_fontes`, etc.) — versão pessoal é um resumo genérico sem esse grounding. |
| `fontes/caged.md`, `ssp-sp.md`, `ibge-sidra.md`, `acto-api.md` (pessoal) | Equivalentes em `catalogo-dados/fontes/` do lakehouse-inmov já são mais específicos e citam notebooks reais (ex.: `nb_ingest_calendario_caged`). |
| `projetos/projeto-acto-santos.md`, `projeto-geo-osasco.md` (pessoal) | O lakehouse-inmov já tem notas de projeto por frente, mais granulares e com ocorrências reais datadas (`projetos/santos/`, `projetos/osasco/`). |
| `bi/design-system-powerbi.md` (pessoal) | Parcialmente redundante com `bi/constituicao-pbi.md`/`diretrizes-servico.md`. Só vale extrair o "diagnóstico Santos 2026-04" (desvios recorrentes) se a analista de BI confirmar que ainda não foi incorporado — não entra nesta leva. |

---

## Próximos passos

0. ~~Reconciliar os 4 itens já publicados (11, 12, 13 e Produto DataHub).~~ **Feito em 24/07** — ver detalhe em cada item e na seção "Atualização 24/07" no topo deste documento. Restam pendências de validação factual que só quem tem o contexto original resolve (regra técnica do schema Acto, status do rascunho DATASUS/INEP, gap de executor responsável do postmortem obras) — não bloqueiam leitura, mas os itens não devem ser tratados como definitivos até isso fechar.
1. Yuri revisa o restante desta proposta — itens 1-10 e 14, que seguem exatamente como em 22/07, sem nenhum avanço (conteúdo, destino sugerido, pendências de cada item). Os itens 11-13 e o Produto DataHub já estão publicados; revisar é opcional, mas as pendências de validação de cada um seguem valendo.
2. Itens aprovados: Yuri abre as Issues correspondentes no lakehouse-inmov (`contribuir-conhecimento` ou `registrar-decisao`), copiando o corpo já pronto de cada seção acima.
3. Curadoria (coordenador do lakehouse-inmov) faz a validação editorial/factual final e realiza o commit/PR na `main`.
4. Após publicação, marcar os itens correspondentes como concluídos neste documento (checklist a adicionar na próxima revisão).
