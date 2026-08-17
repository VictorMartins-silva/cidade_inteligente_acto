---
title: "Aprovação de Projetos e Alvarás — Santos"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - municipio/santos
  - dominio/obras
  - status/pendente
  - pendente-analista
status: pendente
data_reuniao: 2026-05-18
participantes:
  - Victor Martins Da Silva
  - Magda Valquíria Silva de Souza
  - kellysimoes@santos.sp.gov.br
---

# Aprovação de Projetos e Alvarás — Santos

> [!todo] Pendência criada em 18/05/2026
> Criação do painel solicitada em reunião com a cliente (DECONTE/Santos). Aguarda entrega da planilha Excel pela DECONTE antes de iniciar o desenvolvimento.

---

## Contexto da Reunião

**Data:** 18/05/2026 · 14h00–15h00
**Participantes:** Victor (InMov) · Magda Valquíria Silva de Souza · Kelly Simões (kellysimoes@santos.sp.gov.br)
**Pauta:** Painéis / Indicadores Obras — Santos

---

## Situação Atual (relatada pela cliente)

A DECONTE utiliza atualmente uma **planilha Excel** alimentada manualmente com dados extraídos dos relatórios da grid e da gestão do Acto. A planilha já contém os seguintes campos:

- Número de pavimentos
- Quantidade de processos aprovados
- Análises de tempo por etapa

> [!info] Próximo passo — DECONTE
> A DECONTE ficou de **enviar a planilha Excel** para o InMov, para que possamos mapear os campos existentes e entender o modelo de análise atual antes de iniciar o desenvolvimento do BI.

---

## Regras de Negócio (definidas na reunião)

| Condição | Interpretação |
|---|---|
| Processo passou pela etapa de **Alvará** | Considera-se **aprovado** |
| Processo passou pela etapa de **Licença** | Considera-se que a **licença foi emitida** |

> [!warning] Contagem distinta por processo
> Um mesmo processo pode passar **mais de uma vez** pela etapa de emissão de alvará. Nesses casos, **deve ser contabilizado apenas uma única vez** (DISTINCTCOUNT por OS).

---

## Requisitos do Painel

### Objetivo Principal

Permitir a análise da **quantidade de aprovações por ano e por bairro**, possibilitando consultas rápidas para:
- Atendimento de demandas internas da Prefeitura
- Solicitações externas (ex: pedidos da imprensa)

### Indicadores e Visualizações Solicitados

- [ ] Quantidade de edifícios implantados em determinado bairro **acima de uma quantidade específica de pavimentos**
- [ ] Quantidade de processos aprovados por bairro (baseado na passagem pela etapa de Alvará)
- [ ] Intervalo por número de pavimentos (ex: 1–5, 6–10, 11–20, >20)
- [ ] Visão anual das aprovações
- [ ] Visualização em **mapa por bairro**
- [ ] Tempo de aprovação (da abertura até a etapa de Alvará)
- [ ] Filtro por tipo de serviço (ex: Construções Novas)
- [ ] Todos os serviços disponíveis como filtro

---

## Gap Técnico Identificado

> [!danger] Campo "Pavimentos" não existe nas tabelas Gold atuais
> O campo `numero_pavimentos` **não está presente** em nenhuma tabela Gold ou Silver do pipeline de obras. Ele pode existir nos dados brutos da API Acto, mas não foi extraído. Opções:
> 1. Verificar se o campo existe na resposta bruta da API (Silver) após correção do R5
> 2. Obter via planilha Excel da DECONTE (fonte alternativa temporária)
> 3. Confirmar se vem de outro sistema (IPTU / cadastro imobiliário)

### Tabelas Gold disponíveis (dados parados desde 11/03/2025 — issue R5)

| Tabela | Conteúdo |
|---|---|
| `gold_pdr_acompanhamentos_os` | OS + bairro + etapa atual + zona + datas |
| `gold_obras_tempo_etapa` | Histórico de todas as etapas por OS + duração |

---

## Arquitetura Proposta

```
gold_obras_tempo_etapa        gold_pdr_acompanhamentos_os
   (nível etapa × OS)    ←→      (nível OS — tem bairro)
         │                              │
         └──────── JOIN por OS ─────────┘
                        │
              gold_obras_painel_aprovacoes  ← novo notebook Gold
                        │
              Aprovação de Projetos e Alvarás (Power BI)
```

---

## Pendências

- [ ] **DECONTE** enviar planilha Excel com campos atuais
- [ ] Investigar campo `pavimentos` na resposta bruta da API Acto (Silver)
- [ ] Confirmar com a cliente o que é "quando o documento foi disponibilizado" (data_atendimento_etapa?)
- [ ] Resolver R5 (HTTP 401) antes de ativar o pipeline — ver [[f5_obras_pdr]]
- [ ] Criar notebook `nb_gold_santos_aprovacao_projetos_alvaras`
- [ ] Construir relatório Power BI

---

## Relacionado

- [[f5_obras_pdr]] — família atual de painéis de obras (pipeline parado R5)
- [[Santos/nbs/obras/nb_gold_acto_gestao_obras.ipynb|nb_gold_acto_gestao_obras]] — notebook base de acompanhamento OS
- [[Santos/nbs/obras/nb_gold_acto_gestao_obras_etapas.ipynb|nb_gold_acto_gestao_obras_etapas]] — tempo por etapa
- [[Santos/nbs_analise/process_mining_obras_santos]] — análise de retrabalho no fluxo SEONT
