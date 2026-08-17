---
title: "F4 — Carta de Serviços"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# F4 — Carta de Serviços

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painel

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_carta_servicos` | ACOMPANHAMENTO DA CARTA DE SERVIÇOS | 4 |

> [!note] Foco diferente das demais famílias
> Este painel **não** acompanha OS operacionais ou atendimentos. Seu foco é a **gestão do catálogo de serviços públicos** — publicação, validade e atualização das fichas de serviço da Carta de Serviços Municipal.

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos de perguntas a responder:
> - O que é a Carta de Serviços do Município de Santos?
> - Quem é responsável por manter as fichas de serviço atualizadas?
> - Este painel é obrigação legal (ex.: Lei de Acesso à Informação / Decreto Municipal)?
> - Quem acessa este painel: gestores de secretaria, equipe da Ouvidoria, área de transparência?

---

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> - Responsáveis pela gestão da Carta de Serviços em cada secretaria?
> - Equipe de transparência / comunicação da prefeitura?
> - Coordenação de modernização administrativa?

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Quantos serviços estão publicados na Carta e quais secretarias têm mais serviços?
> - Quais fichas de serviço estão desatualizadas (última atualização há mais de X dias)?
> - Quantas atualizações estão em tramitação agora?

---

## Indicadores e Métricas (KPIs)

Dados extraídos diretamente do painel (valores de referência da última extração):

| Indicador | Valor de referência | Definição de negócio |
|---|---|---|
| Serviços publicados | 692 | _[preencher — o que é um serviço "publicado"?]_ |
| Serviços em tramitação | 37 | _[preencher — em que fase estão?]_ |
| Secretarias ativas | 28 | _[preencher]_ |
| Categorias | 25 | _[preencher — exemplos de categorias?]_ |
| Atualizados há > 120 dias | _[extrair do painel]_ | _[preencher — é considerado desatualizado?]_ |

> [!todo] Critério de desatualização
> O painel destaca serviços "atualizados há mais de 120 dias". Esse é um critério regulatório ou operacional?
> Existe prazo máximo legal para revisão da Carta de Serviços?

---

## Estrutura de Navegação (Abas)

### Aba 1 — Resumo da Carta

- Serviços publicados por secretaria
- Serviços publicados por categoria
- Serviços publicados por público-alvo
- Publicações por mês
- Totalizadores: 692 publicados · 37 em tramitação · 28 secretarias · 25 categorias

### Aba 2 — Validade da Carta

- Serviços por tempo desde a última atualização
- Ranking de serviços mais desatualizados
- Serviços atualizados há mais de 120 dias por secretaria

### Aba 3 — Atualizações em Tramitação

- Serviços em atualização por secretaria
- Serviços em atualização por categoria
- Distribuição por etapa de execução
- Executor pendente (quem está segurando a atualização)

### Aba 4 — Base Detalhada

- Tabela de serviços com metadados: nome · secretaria · categoria · público-alvo · data de publicação · data de última atualização · status · etapa atual

> [!todo] Metadados da ficha de serviço
> Quais são os campos obrigatórios de uma ficha de serviço na Carta? (Ex.: descrição, documentos necessários, prazo de atendimento, canais, legislação, etc.)
> Documentar aqui os campos que aparecem na Base Detalhada.

---

## Filtros Disponíveis

> [!todo] Levantar filtros
> Os filtros deste painel não foram mapeados em detalhe — são diferentes das Famílias 1 e 2.
> Verificar no painel ao vivo quais filtros estão disponíveis (provavelmente: Secretaria, Categoria, Público-alvo, Status, Período).

---

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook de carga |
|---|---|
| `gold_carta_servicos` | `nb_ingest_carta_servicos_santos` |

**Fonte primária:** CSV `exportar_4.csv` (693 registros, delimitador `;`, UTF-8 BOM)

> [!warning] Fonte CSV — ponto único de falha
> Os dados da Carta de Serviços vêm de um arquivo CSV (`exportar_4.csv`). Se o arquivo for movido ou renomeado, o pipeline quebra silenciosamente. Migração para Delta Table está planejada.

> [!note] CSV canônico
> O arquivo `exportar_4.csv` é o CSV canônico (693 registros). O arquivo `cadastro_carta_de_servico.csv` tem conteúdo idêntico e deve ser descartado para evitar duplicidade.

> [!todo] Frequência de atualização
> Com qual periodicidade os dados da Carta de Serviços são atualizados no Fabric?
> A Carta é atualizada pelo próprio sistema Acto ou por exportação manual de CSV?

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos de regras a documentar:
> - O que é necessário para um serviço ser "publicado" na Carta?
> - Quem aprova a publicação ou atualização de uma ficha de serviço?
> - O prazo de 120 dias sem atualização gera alguma ação (notificação, bloqueio)?
> - Os 37 serviços "em tramitação" precisam de aprovação de quem para serem publicados?
> - Existe SLA para o processo de atualização de ficha?

---

## Glossário

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Carta de Serviços | _[preencher — base legal e propósito]_ |
| Ficha de serviço | _[preencher]_ |
| Tramitação | _[preencher — o que significa estar "em tramitação"?]_ |
| Público-alvo | _[preencher — categorias usadas: pessoa física, empresa, servidor?]_ |
| Executor pendente | _[preencher]_ |

---

## Alertas e Limitações Conhecidas

> [!note] Estrutura de conteúdo diferente do padrão
> Este painel tem nomenclatura de abas diferente (RESUMO / VALIDADE / TRAMITAÇÃO / BASE), sem SLA operacional e sem mapa geolocalizado. É intencional — o domínio é gestão de catálogo, não atendimento operacional. As fontes e watermark InMov estão corretos.
