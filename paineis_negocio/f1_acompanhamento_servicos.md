---
title: "F1 — Acompanhamento de Serviços por Secretaria"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# F1 — Acompanhamento de Serviços por Secretaria

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painéis desta família

| Secretaria | Arquivo Power BI | Título no painel |
|---|---|---|
| SEGOV | `acompanhamento_servicos_segov` | ACOMPANHAMENTO DE SERVIÇOS - SEGOV |
| SEINFRA | `acompanhamento_servicos_seinfra` | ACOMPANHAMENTO DE SERVIÇOS - SEINFRA |
| CET | `acompanhamento_servicos_cet` | ACOMPANHAMENTO DE SERVIÇOS - CET |
| SEPREF | `acompanhamento_servicos_sepref` | ACOMPANHAMENTO DE SERVIÇOS - SEPREF |
| OUVIDORIA | `acompanhamento_servicos_ouvidoria` | ACOMPANHAMENTO DE SERVIÇOS - OUVIDORIA |

> [!todo] Validar nomes
> Confirmar com a Prefeitura se os títulos acima são os nomes oficiais de cada secretaria.

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Descreva o propósito de negócio deste painel. Exemplos de perguntas a responder:
> - Para que a prefeitura usa este painel no dia a dia?
> - Que decisão de gestão ele apoia?
> - Qual problema ele resolve?

---

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> Quem são os usuários deste painel? Exemplos:
> - Gestor da secretaria X
> - Equipe operacional de atendimento
> - Diretoria / Secretário
> - Auditoria / Controle interno

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Liste as principais perguntas de negócio que o painel foi criado para responder. Exemplos:
> - Quantas OS estão abertas hoje e qual o status de prazo?
> - Quais serviços têm maior índice de vencimento?
> - Qual unidade executora está com mais atraso?

---

## Indicadores e Métricas (KPIs)

Dados extraídos do mapeamento técnico — **validar definições com a área de negócio**.

### KPIs de OS em Aberto

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| Total de Solicitações | Contagem de OS com status em aberto | _[preencher]_ |
| Em Atendimento | OS em execução ativa | _[preencher]_ |
| Pendentes | OS sem movimentação | _[preencher]_ |
| % Prazo Vencido | OS abertas com data de vencimento ultrapassada | _[preencher]_ |
| % Dentro do Prazo | OS abertas dentro do SLA contratado | _[preencher]_ |
| % Vence Hoje | OS abertas com vencimento no dia atual | _[preencher]_ |

### KPIs de OS Finalizadas

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| % Finalizadas dentro do prazo | Finalizadas antes do vencimento do SLA | _[preencher]_ |
| Tempo médio de finalização | Média de dias entre abertura e encerramento | _[preencher]_ |

> [!todo] Definição de SLA
> Qual é o prazo contratual (SLA) para cada serviço? Ele está documentado no sistema Acto?
> Essa informação vem da tabela `gold_dim_cartas_servico_vigencia` — confirmar com o time técnico.

### SLA Operacional (dados extraídos dos painéis — referência)

| Secretaria | OS Finalizadas Dentro do Prazo | OS Abertas Dentro do Prazo | Situação |
|---|---|---|---|
| CET | 99,37% | 99,58% | Excelente |
| SEGOV | 96,91% | 100% | Bom |
| OUVIDORIA | 73,6% | ~48% | Regular |
| SEINFRA | 61,82% | ~47% | Alto índice de atraso |
| SEPREF | — | 40,79% | Crítico |

> [!warning] Atenção — Dados de referência
> Os percentuais acima são da última extração disponível dos PDFs. Os dados do painel ao vivo podem diferir.

---

## Estrutura de Navegação (Abas)

Estrutura padrão aplicada a **todas as secretarias desta família**.

### Aba 1 — Ordens em Aberto · Visão Geral

- Donut chart de SLA: % Prazo Vencido / Dentro do Prazo / Vence Hoje
- Contagem de OS por serviço (barras horizontais)
- OS por canal de atendimento (Portal/Aplicativo, Telefônico, Presencial, E-mail)
- OS por etapa atual
- OS por Unidade Executora
- OS por Bairro (mapa geolocalizado — tema Grayscale Light)
- Ranking de solicitantes com mais OS abertas
- Totalizadores: Total · Em Atendimento · Pendentes

### Aba 2 — Gestão de Prazos · OS em Aberto

- Gráfico de OS abertas por dia + média móvel 7 dias
- OS com prazo vencido por serviço
- OS dentro do prazo por serviço
- Tabela: OS + serviço + dias desde o vencimento
- Tabela: OS + serviço + dias até o vencimento

### Aba 3 — Análise de Ordens Finalizadas

- Donut chart % dentro/fora do prazo nas finalizadas
- Tempo médio de finalização por serviço (dias)
- Tempo médio de finalização por Unidade Executora
- OS finalizadas por canal de atendimento
- OS finalizadas por solicitante (ranking)
- OS finalizadas por bairro + mapa geolocalizado

### Aba 4 — Base de Dados Detalhada

Tabela completa por OS:

| Coluna | Descrição |
|---|---|
| OS | Número da ordem de serviço |
| Serviço | Nome do serviço solicitado |
| Status | Status atual da OS |
| Etapa | Etapa atual no fluxo |
| Prazo de conclusão (dias) | SLA em dias do serviço |
| Status do prazo | Dentro do prazo / Vencido / Vence hoje |
| Data de vencimento | Data limite do SLA |
| Dias até/desde vencimento | Calculado dinamicamente |
| Tempo de execução realizado (dias) | Dias corridos desde a abertura |

> [!note] Aba exclusiva do CET
> A secretaria CET possui uma **5ª aba**: **Autorização Carga e Descarga**, com análise de horários, períodos e taxa de deferimento de autorizações temporárias.

---

## Filtros Disponíveis

Todos os filtros estão presentes em **todas as abas** desta família:

- Status da OS
- Etapa atual da OS
- Nome do serviço
- Ano da solicitação
- Mês da solicitação
- Status prazo da OS
- Unidade Executora
- Bairro
- Botão **Limpar Filtros**

> [!todo] Regras de filtro
> Há alguma restrição de acesso por secretaria? (ex.: gestor da SEGOV vê apenas dados da SEGOV?)
> Documentar aqui se houver Row-Level Security (RLS) configurado no modelo.

---

## Origem dos Dados

| Secretaria | Tabela Gold (Fabric) | Notebook de carga |
|---|---|---|
| SEGOV | `gold_segov_servicos` | `nb_gold_acto_gestao_segov` |
| SEINFRA | `gold_seinfra_servicos` | `nb_gold_acto_gestao_seinfra` |
| CET | `gold_cet_servicos` | `nb_gold_acto_gestao_cet` |
| CET (Carga/Descarga) | `gold_cet_carga_descarga` | `nb_gold_acto_gestao_cet_carga_descarga` |
| SEPREF | `gold_sepref_servicos` | `nb_gold_acto_gestao_sepref` |
| OUVIDORIA | `gold_ouvidoria_servicos` | `nb_gold_acto_gestao_ouvidoria_servicos` |

**Fonte primária:** API Acto Gestão → Lakehouse `lh_cidade_inteligente_santos`

> [!todo] Frequência de atualização
> Com qual periodicidade os dados são atualizados? (Ex.: diária às 06h, sob demanda, tempo real?)
> Verificar configuração dos pipelines no Data Factory.

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Documente as regras de negócio que regem os indicadores. Exemplos:
> - Como é calculado o prazo de uma OS? (dias corridos ou úteis?)
> - O que define que uma OS está "em atendimento" vs "pendente"?
> - Existe diferença de SLA por tipo de serviço ou secretaria?
> - Como é tratada a reabertura de OS?

---

## Glossário

> [!todo] Preencher — Analista de Negócio
> Defina os termos de negócio usados no painel. Exemplos:

| Termo | Definição |
|---|---|
| OS | _[preencher]_ |
| SLA | _[preencher]_ |
| Etapa atual | _[preencher]_ |
| Unidade Executora | _[preencher]_ |
| Canal de atendimento | _[preencher]_ |
| Solicitante | _[preencher]_ |

---

## Alertas e Limitações Conhecidas

> [!warning] Inconsistências de nomenclatura nos títulos
> - `acomp_servicos_segov`: título renderiza como **"SERVIÇOS -SEGOV"** (sem espaço antes do hífen) — aguardando correção
> - `acomp_servicos_ouvidoria`: título aparece sem sufixo "- OUVIDORIA" — aguardando correção

> [!tip] Nota técnica — fonte ArialMT em mapas
> A fonte ArialMT que aparece nos labels do mapa (TomTom/OSM) é injetada automaticamente pelo visual de mapa — não é uma inconsistência do designer, não deve ser corrigida.
