---
title: "F3 — Avaliação de Serviços"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# F3 — Avaliação de Serviços

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painel

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_avaliacao_servicos` | AVALIAÇÕES DE SERVIÇOS - SANTOS | 4 |

> [!warning] Template diferente do padrão
> Este painel usa um template completamente diferente das Famílias 1 e 2: título 28pt (padrão: 25pt), KPIs em 43pt (padrão: 27pt), sem watermark InMov, e fonte ArialMT em labels. Aguarda rebuild para adequação ao padrão visual.

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos de perguntas a responder:
> - Qual é o propósito da pesquisa de satisfação enviada ao cidadão após o atendimento?
> - Quem envia a avaliação: o sistema automaticamente após encerramento da OS?
> - Os resultados são usados para avaliação de desempenho das equipes?

---

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> Quem consome os dados de avaliação?
> - Gestores de secretaria para acompanhar satisfação do cidadão?
> - RH para avaliação de atendentes?
> - Diretoria para relatório de qualidade?

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Qual é a nota média de satisfação dos cidadãos por serviço?
> - Quais serviços têm maior taxa de expectativa frustrada?
> - Qual o percentual de avaliações respondidas?

---

## Indicadores e Métricas (KPIs)

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| Total de avaliações enviadas | Quantidade de formulários enviados pós-OS | _[preencher]_ |
| % respondidas | Avaliações preenchidas / enviadas | _[preencher]_ |
| Expectativa Atendida | Avaliações com resultado "Atendida" | _[preencher]_ |
| Expectativa Frustrada | Avaliações com resultado "Frustrada" | _[preencher]_ |
| Expectativa Superada | Avaliações com resultado "Superada" | _[preencher]_ |
| Nota média por serviço | Média de estrelas (escala 0–5 ★) | _[preencher]_ |
| Satisfação média por mês | Média de estrelas no período | _[preencher]_ |
| % Questão resolvida | Avaliações marcando "questão resolvida = sim" | _[preencher]_ |

> [!todo] Escala de avaliação
> Confirmar a escala usada: é 0–5 estrelas? Existe nota mínima para ser considerado "satisfeito"?
> Existe pontuação de NPS (Net Promoter Score) ou é escala Likert?

---

## Estrutura de Navegação (Abas)

### Aba 1 — Visão Geral

- KPIs gerais: total enviadas, % respondidas
- Gráfico de expectativas: Atendidas / Frustradas / Superadas
- Ranking de serviços por número de avaliações válidas
- % "questão resolvida" por serviço

### Aba 2 — Avaliação do Serviço

- Nota média por serviço (0–5 ★)
- Satisfação média por mês
- Tabela: OS · Nota · Comentário do cidadão

### Aba 3 — Avaliação do Atendimento

- Nota de atendimento por OS
- Satisfação média do atendimento

### Aba 4 — Base de Dados Detalhada

- Tabela completa por OS com todos os campos de avaliação

> [!todo] Diferença entre "avaliação do serviço" e "avaliação do atendimento"
> O formulário de avaliação tem perguntas distintas para o serviço em si e para o atendimento recebido?
> Qual é a diferença do ponto de vista do cidadão? Documentar aqui.

---

## Filtros Disponíveis

Filtros específicos deste painel (diferentes das Famílias 1 e 2):

- Mês
- Nome do serviço
- Ano
- Expectativa (Atendida / Frustrada / Superada)
- Classificação
- Questão resolvida (Sim / Não)

> [!note] Sem filtro de bairro ou unidade executora
> Este painel não possui os filtros de bairro, unidade executora ou status de prazo presentes nas Famílias 1 e 2.

---

## Origem dos Dados

| Tabela Gold (Fabric) | Conteúdo | Notebook de carga |
|---|---|---|
| `gold_avaliacoes_servico` | Dados principais das avaliações | `nb_gold_santos_avaliacao` |
| `gold_avaliacoes_servicos_sentimento` | Análise de sentimento dos comentários | `nb_gold_santos_avaliacao_sentimento` |

**Fonte primária:** API Acto Gestão → Lakehouse `lh_cidade_inteligente_santos`

> [!todo] Frequência de atualização
> Com qual periodicidade os dados são atualizados?

> [!warning] Risco técnico R3 — IDs potencialmente misalinhados
> A tabela `gold_avaliacoes_servico` usa modo `overwrite` e `gold_avaliacoes_servicos_sentimento` usa `append`. Se a base for reescrita e o sentimento falhar, os IDs das avaliações e sentimentos podem ficar desalinhados. Comunicar ao time técnico para validação.

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Quando a pesquisa de satisfação é enviada? (imediatamente após encerramento, após X horas?)
> - O cidadão tem prazo para responder?
> - Avaliações com comentário vazio são contabilizadas na análise de sentimento?
> - Como é tratada a ausência de resposta (não respondeu ≠ avaliação negativa)?

---

## Glossário

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Expectativa atendida/frustrada/superada | _[preencher]_ |
| Questão resolvida | _[preencher]_ |
| Análise de sentimento | _[preencher — contexto: processamento de texto dos comentários]_ |
| Avaliação válida | _[preencher — o que torna uma avaliação válida para o ranking?]_ |

---

## Alertas e Limitações Conhecidas

> [!bug] Template fora do padrão visual InMov
> Este painel usa template diferente: título 28pt, KPIs 43pt, fonte ArialMT, sem watermark "Desenvolvido por InMov". Aguarda rebuild para padronização. Não impacta os dados — apenas estética.

> [!warning] Sem mapa geolocalizado
> Ao contrário das Famílias 1 e 2, este painel não possui visualização de mapa. Não há dimensão geográfica (bairro/zona) nas avaliações.
