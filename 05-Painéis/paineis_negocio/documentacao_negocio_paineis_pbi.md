---
title: "Documentação de Negócio — Painéis Power BI Santos"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# Documentação de Negócio — Painéis Power BI Santos

**Workspace:** `lh_cidade_inteligente_santos`
**Responsável técnico:** Victor Silva
**Analista de Negócio:** _[preencher]_
**Início da documentação:** 2026-04-15

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio após entrevista com os responsáveis de cada secretaria.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos antes de publicar.

---

## Índice

- [[#F1 — Acompanhamento de Serviços por Secretaria]]
- [[#F2 — Manifestações de Ouvidoria por Secretaria]]
- [[#F3 — Avaliação de Serviços]]
- [[#F4 — Carta de Serviços]]
- [[#F5 — Obras / PDR I]]
- [[#F6 — Curso de Motorista]]
- [[#Secretarias e Contatos]]
- [[#Alertas Críticos Conhecidos]]

---

## Inventário Geral

| Família                         | Painéis | Padronizado | Observação                          |
| ------------------------------- | ------- | ----------- | ----------------------------------- |
| F1 — Acompanhamento de Serviços | 5       | Sim         | Estrutura padrão InMov              |
| F2 — Manifestações de Ouvidoria | 5       | Sim         | Idem + canais extras                |
| F3 — Avaliação de Serviços      | 1       | Parcial     | Template diferente, sem watermark   |
| F4 — Carta de Serviços          | 1       | Diferente   | Foco em gestão de catálogo          |
| F5 — Obras / PDR I              | 5       | Não         | ⚠️ Pipeline parado desde 11/03/2025 |
| F6 — Curso de Motorista         | 2       | Diferente   | Estrutura de treinamento            |
| **Total**                       | **19**  |             |                                     |

---

## O que a analista de negócio precisa preencher

Em cada seção, os campos `[!todo]` cobrem:

| Campo                               | O que documentar                                   |
| ----------------------------------- | -------------------------------------------------- |
| **Objetivo de Negócio**             | Por que este painel existe? Que decisão ele apoia? |
| **Público-alvo**                    | Quem usa e para quê?                               |
| **Perguntas que o painel responde** | As perguntas de negócio que motivaram o painel     |
| **Definição de KPIs**               | O que cada indicador significa para o negócio      |
| **Regras de Negócio**               | SLA, critérios, fluxos, cálculos                   |
| **Glossário**                       | Termos do domínio para novos usuários              |
| **Validações**                      | Confirmar dados técnicos com os responsáveis       |

---

---

# F1 — Acompanhamento de Serviços por Secretaria

## Painéis desta família

| Secretaria | Arquivo Power BI                    | Título no painel                       |
| ---------- | ----------------------------------- | -------------------------------------- |
| SEGOV      | `acompanhamento_servicos_segov`     | ACOMPANHAMENTO DE SERVIÇOS - SEGOV     |
| SEINFRA    | `acompanhamento_servicos_seinfra`   | ACOMPANHAMENTO DE SERVIÇOS - SEINFRA   |
| CET        | `acompanhamento_servicos_cet`       | ACOMPANHAMENTO DE SERVIÇOS - CET       |
| SEPREF     | `acompanhamento_servicos_sepref`    | ACOMPANHAMENTO DE SERVIÇOS - SEPREF    |
| OUVIDORIA  | `acompanhamento_servicos_ouvidoria` | ACOMPANHAMENTO DE SERVIÇOS - OUVIDORIA |

> [!todo] Validar nomes
> Confirmar com a Prefeitura se os títulos acima são os nomes oficiais de cada secretaria.

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> - Para que a prefeitura usa este painel no dia a dia?
> - Que decisão de gestão ele apoia?
> - Qual problema ele resolve?

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> - Gestor da secretaria X?
> - Equipe operacional de atendimento?
> - Diretoria / Secretário?
> - Auditoria / Controle interno?

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> - Quantas OS estão abertas hoje e qual o status de prazo?
> - Quais serviços têm maior índice de vencimento?
> - Qual unidade executora está com mais atraso?

## Indicadores e Métricas (KPIs)

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
> Qual é o prazo contratual (SLA) para cada serviço? Está documentado no sistema Acto?

### SLA Operacional — Referência (última extração disponível)

| Secretaria | Finalizadas Dentro do Prazo | Abertas Dentro do Prazo | Situação |
|---|---|---|---|
| CET | 99,37% | 99,58% | Excelente |
| SEGOV | 96,91% | 100% | Bom |
| OUVIDORIA | 73,6% | ~48% | Regular |
| SEINFRA | 61,82% | ~47% | Alto índice de atraso |
| SEPREF | — | 40,79% | Crítico |

> [!warning] Dados de referência — verificar atualidade no painel ao vivo.

## Estrutura de Navegação (Abas)

Estrutura padrão aplicada a **todas as secretarias desta família**.

### Aba 1 — Ordens em Aberto · Visão Geral
- Donut chart de SLA: % Prazo Vencido / Dentro do Prazo / Vence Hoje
- Contagem de OS por serviço (barras horizontais)
- OS por canal de atendimento (Portal/Aplicativo, Telefônico, Presencial, E-mail)
- OS por etapa atual · por Unidade Executora · por Bairro (mapa geolocalizado)
- Ranking de solicitantes com mais OS abertas
- Totalizadores: Total · Em Atendimento · Pendentes

### Aba 2 — Gestão de Prazos · OS em Aberto
- Gráfico de OS abertas por dia + média móvel 7 dias
- OS com prazo vencido por serviço / dentro do prazo por serviço
- Tabela: OS + serviço + dias desde o vencimento
- Tabela: OS + serviço + dias até o vencimento

### Aba 3 — Análise de Ordens Finalizadas
- Donut chart % dentro/fora do prazo nas finalizadas
- Tempo médio de finalização por serviço e por Unidade Executora
- OS finalizadas por canal, por solicitante (ranking) e por bairro + mapa

### Aba 4 — Base de Dados Detalhada
Tabela completa: OS · Serviço · Status · Etapa · Prazo (dias) · Status do prazo · Data de vencimento · Dias até/desde vencimento · Tempo de execução realizado (dias)

> [!note] Aba exclusiva do CET
> A secretaria CET possui **5ª aba**: **Autorização Carga e Descarga** — análise de horários, períodos e taxa de deferimento de autorizações temporárias.

## Filtros Disponíveis

Presentes em todas as abas: Status da OS · Etapa atual · Nome do serviço · Ano · Mês · Status prazo · Unidade Executora · Bairro · Botão **Limpar Filtros**

> [!todo] RLS — Row-Level Security
> Há restrição de acesso por secretaria? O gestor da SEGOV vê apenas dados da SEGOV? Documentar se houver RLS configurado no modelo Power BI.

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
> Com qual periodicidade os dados são atualizados? Verificar configuração dos pipelines no Data Factory.

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> - Como é calculado o prazo de uma OS? (dias corridos ou úteis?)
> - O que define "em atendimento" vs "pendente"?
> - Existe diferença de SLA por tipo de serviço ou secretaria?
> - Como é tratada a reabertura de OS?

## Glossário — F1

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| OS | _[preencher]_ |
| SLA | _[preencher]_ |
| Etapa atual | _[preencher]_ |
| Unidade Executora | _[preencher]_ |
| Canal de atendimento | _[preencher]_ |
| Solicitante | _[preencher]_ |

## Alertas — F1

> [!warning] Inconsistências de nomenclatura nos títulos
> - `acomp_servicos_segov`: título como **"SERVIÇOS -SEGOV"** (sem espaço antes do hífen) — aguarda correção
> - `acomp_servicos_ouvidoria`: sem sufixo "- OUVIDORIA" no título — aguarda correção

---

---

# F2 — Manifestações de Ouvidoria por Secretaria

## Painéis desta família

| Escopo | Arquivo Power BI | Título no painel |
|---|---|---|
| Geral | `acomp_servicos_manif_ouvidoria` | ACOMPANHAMENTO DE SOLICITAÇÕES - MANIFESTAÇÕES DE OUVIDORIA |
| CET | `acomp_servicos_manif_ouvidoria_cet` | MANIFESTAÇÕES DE OUVIDORIA - CET _(título com "CE T" — erro tipográfico)_ |
| SEGOV | `acomp_servicos_manif_ouvidoria_segov` | MANIFESTAÇÕES DE OUVIDORIA - SEGOV |
| SEINFRA | `acomp_servicos_manif_ouvidoria_seinfra` | MANIFESTAÇÕES DE OUVIDORIA - SEINFRA |
| SEPREF | `acomp_servicos_manif_ouvidoria_sepref` | MANIFESTAÇÕES DE OUVIDORIA - SEPREF |

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> - O que diferencia uma "manifestação de ouvidoria" de uma OS operacional comum?
> - Este painel é usado pela equipe da ouvidoria ou por cada secretaria destino?
> - Qual é o fluxo: o cidadão abre pela ouvidoria e é roteado para a secretaria?

## Público-alvo

> [!todo] Preencher — Analista de Negócio

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> - Quantas manifestações foram recebidas e encaminhadas para cada secretaria?
> - Qual é o canal preferido do cidadão (WhatsApp, telefone, presencial)?
> - As secretarias estão respondendo dentro do prazo?

## Diferença em relação à F1

| Aspecto | F1 — Acompanhamento de Serviços | F2 — Manifestações de Ouvidoria |
|---|---|---|
| Origem | Cidadão abre diretamente na secretaria | Cidadão abre via Ouvidoria Municipal |
| Canais | Portal/App, Telefônico, Presencial, E-mail | + **WhatsApp**, **Redes Sociais**, Correspondência |
| Escopo | Serviços da secretaria titular | Serviços de múltiplos domínios roteados via Ouvidoria |
| Sub-painéis | Um por secretaria | Um geral + um filtrado por secretaria destino |

> [!todo] Confirmar fluxo de roteamento
> Como uma manifestação chega à ouvidoria e é direcionada para a secretaria responsável?

## Indicadores e Métricas (KPIs)

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| Total de Manifestações | Contagem de OS originadas via Ouvidoria | _[preencher]_ |
| % Prazo Vencido | Manifestações abertas com SLA vencido | _[preencher]_ |
| % Dentro do Prazo | Manifestações abertas dentro do SLA | _[preencher]_ |
| Manifestações por canal | Contagem por canal de atendimento | _[preencher]_ |
| Tempo médio de resposta | Média de dias para finalização | _[preencher]_ |

> [!todo] SLA de manifestações
> O prazo de uma manifestação de ouvidoria é o mesmo das OS operacionais ou existe prazo específico?
> Há prazo regulatório (ex.: legislação municipal de ouvidoria)?

## Estrutura de Navegação (Abas)

Mesma estrutura de 4 abas da F1. Canal de atendimento tem destaque especial na Aba 1.

> [!todo] Validar canais ativos
> Confirmar quais canais estão operacionais atualmente. "Correspondência" e "Redes Sociais" estão ativos?

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook de carga |
|---|---|
| `gold_manifestacoes_ouvidoria` | `nb_gold_acto_gestao_manifestacoes_ouvidoria` |

Todos os 5 painéis leem da mesma tabela; sub-painéis aplicam filtros sobre ela.

> [!todo] Frequência de atualização

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> - Como uma manifestação é classificada (reclamação, sugestão, elogio, denúncia)?
> - Existe priorização por tipo?
> - O prazo varia por tipo de manifestação?
> - Como funciona o roteamento para a secretaria destino?

## Glossário — F2

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Manifestação de Ouvidoria | _[preencher]_ |
| Canal de atendimento | _[preencher — incluir WhatsApp e Redes Sociais]_ |
| Secretaria destino | _[preencher]_ |
| Roteamento | _[preencher]_ |

## Alertas — F2

> [!bug] Erro tipográfico — CET
> Título renderiza como **"MANIFESTAÇÕES DE OUVIDORIA - CE T"**. Aguarda correção.

> [!warning] SEINFRA — dados ausentes
> Páginas 1–2 do PDF de Manifestações SEINFRA sem métricas visíveis — possível ausência de dados no período.

---

---

# F3 — Avaliação de Serviços

## Painel

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_avaliacao_servicos` | AVALIAÇÕES DE SERVIÇOS - SANTOS | 4 |

> [!warning] Template diferente do padrão
> Título 28pt (padrão: 25pt), KPIs 43pt (padrão: 27pt), sem watermark InMov, fonte ArialMT em labels. Aguarda rebuild para adequação visual. Dados estão corretos.

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> - Qual é o propósito da pesquisa de satisfação enviada ao cidadão?
> - Quem envia: o sistema automaticamente após encerramento da OS?
> - Os resultados são usados para avaliação de desempenho das equipes?

## Público-alvo

> [!todo] Preencher — Analista de Negócio

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> - Qual é a nota média de satisfação por serviço?
> - Quais serviços têm maior taxa de expectativa frustrada?
> - Qual o percentual de avaliações respondidas?

## Indicadores e Métricas (KPIs)

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| Total de avaliações enviadas | Formulários enviados pós-OS | _[preencher]_ |
| % respondidas | Avaliações preenchidas / enviadas | _[preencher]_ |
| Expectativa Atendida | Avaliações com resultado "Atendida" | _[preencher]_ |
| Expectativa Frustrada | Avaliações com resultado "Frustrada" | _[preencher]_ |
| Expectativa Superada | Avaliações com resultado "Superada" | _[preencher]_ |
| Nota média por serviço | Média de estrelas (escala 0–5 ★) | _[preencher]_ |
| Satisfação média por mês | Média de estrelas no período | _[preencher]_ |
| % Questão resolvida | Avaliações marcando "questão resolvida = sim" | _[preencher]_ |

> [!todo] Escala de avaliação
> Confirmar: é escala 0–5 estrelas? NPS? Likert?
> Qual nota mínima é considerada "satisfeito"?

## Estrutura de Navegação (Abas)

### Aba 1 — Visão Geral
KPIs gerais · gráfico de expectativas · ranking de serviços por avaliações válidas · % questão resolvida

### Aba 2 — Avaliação do Serviço
Nota média por serviço (★) · satisfação média por mês · tabela: OS · nota · comentário

### Aba 3 — Avaliação do Atendimento
Nota de atendimento por OS · satisfação média do atendimento

### Aba 4 — Base de Dados Detalhada
Tabela completa por OS com todos os campos de avaliação

> [!todo] Diferença entre "avaliação do serviço" e "avaliação do atendimento"
> O formulário tem perguntas distintas para o serviço e para o atendimento recebido? Documentar a diferença.

## Filtros Disponíveis

Mês · Nome do serviço · Ano · Expectativa · Classificação · Questão resolvida

> [!note] Sem filtro de bairro, unidade executora ou status de prazo — diferente das Famílias 1 e 2.

## Origem dos Dados

| Tabela Gold (Fabric) | Conteúdo | Notebook |
|---|---|---|
| `gold_avaliacoes_servico` | Dados principais das avaliações | `nb_gold_santos_avaliacao` |
| `gold_avaliacoes_servicos_sentimento` | Análise de sentimento dos comentários | `nb_gold_santos_avaliacao_sentimento` |

> [!warning] Risco técnico R3 — IDs potencialmente misalinhados
> `gold_avaliacoes_servico` usa `overwrite` e `gold_avaliacoes_servicos_sentimento` usa `append`. Se a base for reescrita e o sentimento falhar, os IDs ficam desalinhados silenciosamente.

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> - Quando a pesquisa é enviada? Imediatamente após encerramento?
> - O cidadão tem prazo para responder?
> - Como é tratada a ausência de resposta?
> - Avaliações com comentário vazio entram na análise de sentimento?

## Glossário — F3

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Expectativa atendida/frustrada/superada | _[preencher]_ |
| Questão resolvida | _[preencher]_ |
| Análise de sentimento | _[preencher — processamento de texto dos comentários]_ |
| Avaliação válida | _[preencher — o que torna uma avaliação válida para o ranking?]_ |

---

---

# F4 — Carta de Serviços

## Painel

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_carta_servicos` | ACOMPANHAMENTO DA CARTA DE SERVIÇOS | 4 |

> [!note] Foco diferente das demais famílias
> Este painel **não** acompanha OS operacionais. Foco: **gestão do catálogo de serviços públicos** — publicação, validade e atualização das fichas de serviço da Carta de Serviços Municipal.

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> - O que é a Carta de Serviços do Município de Santos?
> - Quem é responsável por manter as fichas atualizadas?
> - Existe obrigação legal por trás deste painel?

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> - Responsáveis pela gestão da Carta em cada secretaria?
> - Equipe de transparência / comunicação?
> - Coordenação de modernização administrativa?

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> - Quantos serviços estão publicados e quais secretarias têm mais?
> - Quais fichas estão desatualizadas (última atualização há mais de X dias)?
> - Quantas atualizações estão em tramitação agora?

## Indicadores e Métricas (KPIs)

| Indicador | Valor de referência | Definição de negócio |
|---|---|---|
| Serviços publicados | 692 | _[preencher]_ |
| Serviços em tramitação | 37 | _[preencher]_ |
| Secretarias ativas | 28 | _[preencher]_ |
| Categorias | 25 | _[preencher]_ |
| Atualizados há > 120 dias | _[extrair do painel]_ | _[preencher — critério de desatualização?]_ |

> [!todo] Critério de desatualização
> O prazo de 120 dias é regulatório ou operacional? Há prazo legal para revisão da Carta de Serviços?

## Estrutura de Navegação (Abas)

### Aba 1 — Resumo da Carta
Serviços publicados por secretaria / categoria / público-alvo · publicações por mês · totalizadores

### Aba 2 — Validade da Carta
Serviços por tempo desde a última atualização · ranking dos mais desatualizados · serviços atualizados há > 120 dias por secretaria

### Aba 3 — Atualizações em Tramitação
Serviços em atualização por secretaria / categoria / etapa de execução · executor pendente

### Aba 4 — Base Detalhada
Tabela: serviço · secretaria · categoria · público-alvo · data de publicação · data de última atualização · status · etapa atual

> [!todo] Metadados da ficha de serviço
> Quais são os campos obrigatórios de uma ficha (descrição, documentos, prazo, canais, legislação)?

## Filtros Disponíveis

> [!todo] Levantar filtros no painel ao vivo
> Provavelmente: Secretaria · Categoria · Público-alvo · Status · Período.

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook |
|---|---|
| `gold_carta_servicos` | `nb_ingest_carta_servicos_santos` |

**Fonte primária:** CSV `exportar_4.csv` (693 registros, delimitador `;`, UTF-8 BOM)

> [!warning] Fonte CSV — ponto único de falha
> Dados vêm de arquivo CSV. Se movido ou renomeado, o pipeline quebra silenciosamente. Migração para Delta Table está planejada.

> [!todo] Frequência de atualização
> A Carta é atualizada pelo sistema Acto ou por exportação manual de CSV?

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> - O que é necessário para um serviço ser "publicado"?
> - Quem aprova a publicação ou atualização de uma ficha?
> - O prazo de 120 dias sem atualização gera alguma ação?
> - Existe SLA para o processo de atualização?

## Glossário — F4

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Carta de Serviços | _[preencher — base legal e propósito]_ |
| Ficha de serviço | _[preencher]_ |
| Tramitação | _[preencher]_ |
| Público-alvo | _[preencher — pessoa física, empresa, servidor?]_ |
| Executor pendente | _[preencher]_ |

---

---

# F5 — Obras / PDR I

## Painéis desta família

| Arquivo Power BI | Título no painel | Abas | Foco |
|---|---|---|---|
| `pbi_obras_santos_acomp_solicitacoes` | ACOMPANHAMENTO DE SOLICITAÇÕES - OBRAS | 3 | OS de obras em geral |
| `pbi_obras_santos_seman_acomp` | ACOMP. DE SOLICITAÇÕES - SEMAN | 3 | Licenciamento ambiental |
| `pbi_obras_santos_pdr` | PDR I — Participação Direta nos Resultados | 2 | Produtividade por executor |
| `pbi_santos_obras_seont_os` | ACOMPANHAMENTO DE PROCESSOS POR ANALISTAS - SEONT | 2 | Analistas por zona |
| `acomp_alvara_obras_santos_prototipo` | PDR I _(protótipo)_ | 5 | **Inacabado — aba "Rascunho"** |

> [!danger] Pipeline parado desde 11/03/2025
> Todos os painéis desta família estão sem atualização desde 11/03/2025 (erro HTTP 401 na API de Obras — issue R5 Crítico). Dados exibidos podem estar desatualizados em mais de um ano. **Não usar para tomada de decisão até correção.**

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio — um objetivo por painel
> 1. **Acomp. Solicitações — Obras:** _[preencher]_
> 2. **Acomp. Solicitações — SEMAN:** _[preencher — o que é SEMAN?]_
> 3. **PDR I:** _[preencher — o que é "Participação Direta nos Resultados"?]_
> 4. **SEONT — Analistas:** _[preencher — o que é SEONT?]_

## Público-alvo

> [!todo] Preencher — Analista de Negócio

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio

## Detalhes por Painel

### Painel 1 — Acompanhamento de Solicitações (Obras e SEMAN)

**3 abas** (sem "Gestão de Prazos" do padrão):
1. Ordens em Aberto — KPI SLA · OS por serviço · por zona (Z1/Z2/Z3) · mapa por zona
2. Ordens Finalizadas — % dentro/fora do prazo · tempo médio
3. Base de Dados — tabela completa

**Header:** "PDR I · Prefeitura de Santos (Participação Direta nos Resultados)"
**Período:** 01/01/2024 – 09/04/2026 (Obras) / 01/01/2024 – 09/03/2026 (SEMAN)

**Filtros específicos do SEMAN:** Licença Prévia · Licença de Instalação · Licença de Operação · Manifestação Técnica Ambiental

> [!todo] Tipos de licença SEMAN
> O que é cada tipo de licença? Qual o fluxo de aprovação? Há SLA específico por tipo?

> [!todo] Sigla SEMAN / SEMAM
> Confirmar sigla correta — o painel usa "SEMAM" no header e "SEMAN" no título.

---

### Painel 2 — PDR I (Produtividade)

**2 abas:**
1. Tabela de OS: OS · Serviço · Etapa · Data Início · Data Fim · Tempo Execução · Executor · Duração Dias
2. Resumo por Aux Setor: Total OS · Duração total · Média Duração (dias)

> [!todo] O que é PDR I?
> "Participação Direta nos Resultados" — é programa de incentivo/produtividade?
> Como os dados são usados: avaliação de desempenho, bonificação, planejamento?
> Quem são os "Auxiliares de Setor"?

---

### Painel 3 — SEONT (Analistas por Zona)

**2 abas:**
1. Analistas: OS por analista e zona (Z1/Z2/Z3) · Indicadores: OS > 30 Dias · OS > 60 Dias · Max. Dias
2. Tabela: OS · Status · Serviço · Bairro · Zona · Etapa · Analista · Data início · Dias na etapa

> [!todo] O que é SEONT?
> Sigla completa e responsabilidade? Os analistas são técnicos de fiscalização?
> As zonas Z1/Z2/Z3 seguem qual delimitação geográfica?

---

### Painel 4 — Alvará de Obras (Protótipo)

> [!danger] NÃO usar em produção
> Aba "Rascunho" visível · escala de fontes fora do padrão (80pt/60pt/40pt) · 5 abas sem estrutura definida.

> [!todo] Status do protótipo
> Será desenvolvido? Qual objetivo de negócio? Quem é o responsável? Existe prazo?

---

## Indicadores e Métricas — F5

| Indicador | Painel | Definição de negócio |
|---|---|---|
| OS em aberto por zona | Obras/SEMAN | _[preencher]_ |
| % SLA dentro do prazo | Obras/SEMAN | _[preencher]_ |
| Tempo médio de execução (dias) | PDR I | _[preencher]_ |
| Total OS por executor | PDR I | _[preencher]_ |
| OS > 30 dias | SEONT | _[preencher — alerta operacional?]_ |
| OS > 60 dias | SEONT | _[preencher — aciona escalada?]_ |
| Máximo de dias em aberto | SEONT | _[preencher]_ |

## Origem dos Dados — F5

| Painel | Tabela Gold (Fabric) | Notebook |
|---|---|---|
| Obras / SEMAN | `gold_pdr_acompanhamentos_os` | `nb_gold_acto_gestao_obras` |
| PDR I | `gold_obras_tempo_etapa` | `nb_gold_acto_gestao_obras_etapas` |
| SEONT | `gold_acto_gestao_obras_seont_os` | `nb_gold_acto_gestao_obras_seont_os` |

## Regras de Negócio — F5

> [!todo] Preencher — Analista de Negócio
> - Como uma OS de obras difere de uma OS operacional?
> - As zonas Z1/Z2/Z3 têm equipes dedicadas?
> - O PDR gera indicador formal de desempenho com consequências para os servidores?

## Glossário — F5

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| PDR I | _[preencher]_ |
| SEONT | _[preencher]_ |
| SEMAN | _[preencher]_ |
| Zona (Z1/Z2/Z3) | _[preencher]_ |
| Aux Setor Responsável | _[preencher]_ |
| Analista Responsável | _[preencher]_ |

## Alertas — F5

> [!warning] Fonte tipográfica diferente
> Painéis de Obras usam `SegoeUI-Semibold` em vez de `SegoeUI-Bold` e estão sem watermark InMov. Aguarda correção visual.

> [!bug] Título inconsistente SEMAM/SEMAN
> Header diz "SEMAM", título diz "SEMAN". Confirmar e padronizar.

---

---

# F6 — Curso de Motorista

## Painéis desta família

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_servicos_curso_motorista` | Curso de aperfeiçoamento profissional para motorista - Gestão | 1 |
| `acomp_servicos_curso_motorista_cet` | Idem — versão CET (dataset maior) | 1 |

> [!note] Domínio isolado — 1 página única
> Sem OS, sem SLA, sem mapa. Foco: funil de inscrição e resultados de curso de formação profissional gerenciado pela CET.

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> - O que é o "Curso de Aperfeiçoamento Profissional para Motorista"?
> - Quem organiza: CET, Secretaria de Emprego, outra?
> - Qual é o público (motoristas de transporte público, motoboys, táxi/app)?
> - É serviço público obrigatório ou programa voluntário? Há exigência legal?

## Público-alvo do Painel

> [!todo] Preencher — Analista de Negócio

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> - Quantas pessoas se inscreveram, foram deferidas e concluíram o curso?
> - Qual é a taxa de evasão?
> - Os participantes estão satisfeitos com conteúdo e instrutores?

## Diferença entre as versões

| Aspecto | Versão Gestão | Versão CET |
|---|---|---|
| Dataset | Menor (subset) | Maior (dataset completo da CET) |

> [!todo] Confirmar diferença real de escopo entre as duas versões.

## Indicadores e Métricas (KPIs)

### Funil de Conversão

| Etapa | Indicador | Definição de negócio |
|---|---|---|
| Topo | Total de Inscrições | _[preencher — quem pode se inscrever?]_ |
| ↓ | Total Deferidos | _[preencher — critério de deferimento?]_ |
| ↓ | Total Aprovados | _[preencher]_ |
| ↓ | Total Reprovados | _[preencher]_ |
| ↓ | Total Indeferidos | _[preencher — diferença entre indeferido e reprovado?]_ |
| ↓ | Total Cancelados | _[preencher]_ |

### KPIs Calculados

| Indicador | Definição de negócio |
|---|---|
| Taxa de Deferimento | _[preencher]_ |
| Taxa de Evasão | _[preencher]_ |

> [!todo] Definições de funil
> Documentar o fluxo: Inscrição → Deferimento → Curso → Resultado.

### Frequência Diária (D1–D7)

> [!todo] Duração do curso
> O curso tem duração fixa de 7 dias? É contínuo ou modular?
> O que acontece se o aluno falta: pode repor? É automaticamente reprovado?

### Satisfação (pesquisa pós-curso)

| Dimensão | Definição de negócio |
|---|---|
| Carga horária ideal | _[preencher]_ |
| Qualidade dos instrutores | _[preencher]_ |
| Clareza do conteúdo | _[preencher]_ |
| Não cansativo | _[preencher]_ |
| Aplicabilidade | _[preencher]_ |

> [!todo] Escala de satisfação
> 1–5 estrelas? Satisfeito/Insatisfeito? NPS?

## Estrutura do Painel (1 página única)

- Funil de conversão
- KPIs: Taxa de Deferimento · Taxa de Evasão
- Frequência diária D1–D7
- Resultados de satisfação por dimensão
- Tabela: Aluno · Status · Presença D1–D7

## Filtros Disponíveis

Mês/Ano · Status da Inscrição · Turma

> [!todo] Turmas
> Como as turmas são identificadas? Existe sazonalidade na oferta (ex.: mensal)?

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook |
|---|---|
| `gold_curso_motoristas` | `nb_silver_santos_curso_motoristas` + notebook gold |

**Fonte primária:** API Acto Gestão → Lakehouse `lh_cidade_inteligente_santos`

> [!todo] Frequência de atualização

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> - Critério para deferir uma inscrição?
> - Critério de aprovação (nota mínima? frequência mínima?)?
> - Os resultados têm consequência para o participante (certificado, benefício)?
> - Existe lista de espera?

## Glossário — F6

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Curso de aperfeiçoamento para motorista | _[preencher — nome oficial, público, objetivo]_ |
| Deferido | _[preencher]_ |
| Indeferido | _[preencher]_ |
| Taxa de Evasão | _[preencher]_ |
| Turma | _[preencher]_ |
| D1–D7 | _[preencher — dias do curso]_ |

## Alertas — F6

> [!warning] Footer e fonte fora do padrão
> Rodapé InMov presente mas com 5.2pt (padrão: 7.5pt). Fonte extra `SegoeFluentIcons` não presente nos outros painéis. Aguarda correção visual.

---

---

# Secretarias e Contatos

> [!todo] Preencher — para facilitar as entrevistas da analista de negócio

| Domínio | Secretaria | Responsável | Contato |
|---|---|---|---|
| Serviços SEGOV | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços SEINFRA | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços CET | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços SEPREF | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Ouvidoria | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Avaliações | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Carta de Serviços | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Obras / PDR I | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Curso Motorista (CET) | _[preencher]_ | _[preencher]_ | _[preencher]_ |

---

# Alertas Críticos Conhecidos

> [!danger] F5 — Obras parada desde 11/03/2025
> Os 5 painéis da Família 5 não recebem dados novos por falha de autenticação na API. Qualquer análise sobre Obras deve mencionar essa limitação ao usuário do painel.

> [!danger] F5 — Protótipo de Alvará inacabado em produção
> `acomp_alvara_obras_santos_prototipo` está na pasta de produção com aba "Rascunho" visível. Não deve ser referenciado como painel ativo.

> [!warning] F3 — Avaliações fora do padrão visual
> Template diferente — não é falha de conteúdo, apenas visual. Dados estão corretos.

> [!warning] F3 — Risco de desalinhamento de IDs (R3)
> Tabelas de avaliação e sentimento usam modos de escrita diferentes (overwrite vs append). Comunicar ao time técnico para validação.
