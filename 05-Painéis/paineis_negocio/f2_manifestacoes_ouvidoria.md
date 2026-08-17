---
title: "F2 — Manifestações de Ouvidoria por Secretaria"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# F2 — Manifestações de Ouvidoria por Secretaria

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painéis desta família

| Escopo | Arquivo Power BI | Título no painel |
|---|---|---|
| Geral (todos os domínios) | `acomp_servicos_manif_ouvidoria` | ACOMPANHAMENTO DE SOLICITAÇÕES - MANIFESTAÇÕES DE OUVIDORIA |
| CET | `acomp_servicos_manif_ouvidoria_cet` | MANIFESTAÇÕES DE OUVIDORIA - CET _(título com "CE T" — erro tipográfico)_ |
| SEGOV | `acomp_servicos_manif_ouvidoria_segov` | MANIFESTAÇÕES DE OUVIDORIA - SEGOV |
| SEINFRA | `acomp_servicos_manif_ouvidoria_seinfra` | MANIFESTAÇÕES DE OUVIDORIA - SEINFRA |
| SEPREF | `acomp_servicos_manif_ouvidoria_sepref` | MANIFESTAÇÕES DE OUVIDORIA - SEPREF |

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Descreva o propósito de negócio deste painel. Exemplos de perguntas a responder:
> - O que diferencia uma "manifestação de ouvidoria" de uma OS operacional comum?
> - Este painel é usado para acompanhamento interno da ouvidoria ou por cada secretaria destino?
> - Qual é o fluxo de uma manifestação: o cidadão abre pela ouvidoria e é roteada para a secretaria?

---

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> Quem são os usuários deste painel? Exemplos:
> - Equipe da Ouvidoria Municipal
> - Gestores de cada secretaria (filtram pelo sub-painel da sua área)
> - Diretoria para acompanhamento de reclamações

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Liste as principais perguntas de negócio. Exemplos:
> - Quantas manifestações foram recebidas pela ouvidoria e encaminhadas para cada secretaria?
> - Qual é o canal preferido do cidadão (WhatsApp, telefone, presencial)?
> - As secretarias estão respondendo as manifestações dentro do prazo?

---

## Diferença em relação à Família 1 (Serviços Operacionais)

| Aspecto | F1 — Acompanhamento de Serviços | F2 — Manifestações de Ouvidoria |
|---|---|---|
| Origem da solicitação | Cidadão abre diretamente na secretaria | Cidadão abre via Ouvidoria Municipal |
| Canais incluídos | Portal/App, Telefônico, Presencial, E-mail | Portal/App, Telefônico, Presencial, Correspondência, **WhatsApp**, **Redes Sociais** |
| Escopo de serviços | Apenas serviços da secretaria titular | Serviços de **múltiplos domínios** roteados via Ouvidoria |
| Sub-painéis | Um por secretaria | Um geral + um filtrado por secretaria destino |

> [!todo] Confirmar fluxo
> A analista deve confirmar e detalhar o fluxo de roteamento: como uma manifestação chega à ouvidoria e é direcionada para a secretaria responsável?

---

## Indicadores e Métricas (KPIs)

Os mesmos KPIs da Família 1 aplicam-se aqui. Validar se há indicadores exclusivos de manifestações:

| Indicador | Descrição técnica | Definição de negócio |
|---|---|---|
| Total de Manifestações | Contagem de OS originadas via Ouvidoria | _[preencher]_ |
| % Prazo Vencido | Manifestações abertas com SLA vencido | _[preencher]_ |
| % Dentro do Prazo | Manifestações abertas dentro do SLA | _[preencher]_ |
| Manifestações por canal | Contagem por canal de atendimento | _[preencher]_ |
| Tempo médio de resposta | Média de dias para finalização | _[preencher]_ |

> [!todo] SLA de manifestações
> O prazo (SLA) de uma manifestação de ouvidoria é o mesmo das OS operacionais ou existe prazo específico?
> Há prazo regulatório (ex.: legislação municipal de ouvidoria) que define o tempo máximo de resposta?

---

## Estrutura de Navegação (Abas)

Mesma estrutura de 4 abas da [[f1_acompanhamento_servicos#Estrutura de Navegação (Abas)|Família 1]].

### Diferenças específicas desta família

- **Canal de atendimento** tem destaque especial na Aba 1 (inclui WhatsApp e Redes Sociais, ausentes na F1)
- Os sub-painéis por secretaria (CET, SEGOV, SEINFRA, SEPREF) filtram manifestações **roteadas** para aquela secretaria, não apenas abertas por ela

> [!todo] Validar canais
> Confirmar quais canais de atendimento estão ativos na Ouvidoria de Santos atualmente.
> Os canais "Correspondência" e "Redes Sociais" estão operacionais?

---

## Filtros Disponíveis

Mesmos filtros da Família 1 (Status OS · Etapa · Serviço · Ano · Mês · Status prazo · Unidade Executora · Bairro · Limpar Filtros).

> [!todo] Filtro por secretaria destino
> No painel geral, existe filtro para ver manifestações direcionadas a uma secretaria específica?
> Confirmar se é filtro de painel ou se o usuário precisa acessar o sub-painel da secretaria.

---

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook de carga |
|---|---|
| `gold_manifestacoes_ouvidoria` | `nb_gold_acto_gestao_manifestacoes_ouvidoria` |

**Todos os 5 painéis desta família leem da mesma tabela.** Os sub-painéis por secretaria aplicam filtros sobre ela.

**Fonte primária:** API Acto Gestão → Lakehouse `lh_cidade_inteligente_santos`

> [!todo] Frequência de atualização
> Com qual periodicidade os dados são atualizados?

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos de regras a documentar:
> - Como uma manifestação é classificada (reclamação, sugestão, elogio, denúncia)?
> - Existe priorização de manifestações por tipo?
> - O prazo varia por tipo de manifestação?
> - Como funciona o roteamento para a secretaria destino?

---

## Glossário

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Manifestação de Ouvidoria | _[preencher]_ |
| Canal de atendimento | _[preencher — incluir WhatsApp e Redes Sociais]_ |
| Secretaria destino | _[preencher]_ |
| Roteamento | _[preencher]_ |

---

## Alertas e Limitações Conhecidas

> [!bug] Erro tipográfico — CET
> O painel `acomp_servicos_manif_ouvidoria_cet` renderiza o título como **"MANIFESTAÇÕES DE OUVIDORIA - CE T"** (com espaço indevido). Aguardando correção no arquivo Power BI.

> [!warning] SEINFRA — dados ausentes
> Nas páginas 1–2 do PDF de Manifestações SEINFRA, não há métricas visíveis — possível ausência de dados no período analisado. Verificar com o time técnico se é ausência de dado ou problema de visualização.
