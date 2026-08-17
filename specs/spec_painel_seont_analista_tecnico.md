---
title: "Spec — SEONT Análises Técnicas · Visão Analistas"
tags: ["santos", "obras", "seont", "painel", "spec"]
municipio: Santos
status: em-desenvolvimento
data: "2026-06-25"
revisao: "2026-07-21 — reunião Painéis Obras: retrabalho de layout + filtro por analista + tabela OS + tempo médio por etapa"
relacionados:
  - "[[spec_painel_semam_analista_tecnico]]"
  - "[[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO]]"
  - "[[spec_drive_semana_20_07_2026]]"
---

# SEONT — Análises Técnicas · Visão Analistas

Santos · Seção de Obras Novas e Trâmites

Painel para acompanhar a carteira de OS de edificações por analista técnico SEONT.
Identifica quem realizou a última análise técnica de cada OS e onde ela está agora no fluxo.

> Mesmo layout do painel SEMAM Analistas — diferem apenas etapas e serviços.

---

## Contexto de Negócio

**~850 OS** passaram por análise técnica SEONT (dez/2023 → jun/2026).  
53% Em andamento · 44% Finalizadas · 3% Não Atribuídas · 23 analistas ativos

**Fluxo típico de uma OS:**
```
Protocolo → [Pré-Análise] → [Conf. Documental] → [Análise Técnica] → [Conf. Dados] → [Conf. Final] → Chefia → D.O. → Publicação
                ↑_______________________________etapas capturadas_______________________________↑
                                                + [Retorno SEDURB]
```

**Regra:** o analista da **última etapa de análise** permanece vinculado à OS mesmo após ela sair do SEONT — útil para medir carteira e produtividade real.

---

## ⚠️ Incidente — OS pendentes na Chefia ausentes do painel (07/07/2026)

**Reclamação do cliente:** "o relatório de solicitações pendentes para a chefia SEONT segue com problemas" — anexou `confbi2.csv` comparando um relatório manual (filtro: `aux_setor_responsavel = SEONT-Chefia`, `status` ativo) contra o que o painel mostra. Várias OS do relatório manual não apareciam no BI (VLOOKUP `#N/D`).

**Causa raiz:** `nb_gold_santos_seont_analista_tecnico` filtra `bronze.fato_etapas_santos_obras` **apenas** pelas 7 etapas de análise técnica (`ETAPAS_ANALISE_SEONT`) antes de qualquer outra lógica — isso é por design, para identificar "quem analisou por último". Mas como consequência, **toda OS que nunca chegou a ter uma etapa de análise (ainda parada na fila da Chefia, nunca distribuída a um analista) fica 100% fora da tabela** — não é filtrada como "Não Atribuído" (esse rótulo é só para OS já analisadas por conta de sistema), simplesmente nunca entra no `df_ultima` que origina a tabela toda.

**Fix aplicado:** nova célula em `nb_gold_santos_seont_analista_tecnico` (inserida após o join com `gold.santos_obras_acompanhamento`) faz `left_anti` join para achar OS com `aux_setor_responsavel` em `{SEONT-Chefia, SEONT-Chefia (D.O), SEONT CHEFIA}`, status ativo, **e que não estão em `df_ultima`** — e as une (`unionByName`) à tabela final, com `analista_tecnico = 'Não Atribuído'` e `etapa_analise_label = 'Não Atribuído'` (decisão de negócio: mesclar no bucket já existente em vez de criar uma categoria nova).

**Impacto esperado:** `Total OS` (~846) e `Não Atribuído` (~27) devem crescer; `Em Andamento`/`Finalizadas` continuam iguais (essas OS não têm status "Finalizado").

- [ ] Reexecutar `nb_gold_santos_seont_analista_tecnico` no Fabric e conferir o print de "OS pendentes na Chefia SEONT sem etapa de análise (adicionadas)"
- [ ] Validar contra `confbi2.csv` — as OS que davam `#N/D` devem aparecer agora
- [ ] Atualizar cards/medidas DAX se o crescimento de "Não Atribuído" mudar a leitura do KPI para o cliente
- [ ] Comunicar Kelly/cliente que o gap foi identificado e corrigido

### Investigação por amostragem (08/07/2026) — causa raiz é dupla

Ao investigar 3 OS específicas do `confbi2.csv` marcadas `#N/D` (ausentes do BI vs. relatório manual do cliente):

| OS | Achado |
|---|---|
| 907010 | **Não é bug.** Etapa aberta atual = `SEONT - ANÁLISE TECNICA - CONFERÊNCIA DOS DADOS` (`aux_setor_responsavel = SEONT`, confirmado em `gold.santos_obras_acompanhamento`). A OS já saiu da Chefia; o relatório manual do cliente capturou um momento anterior (ainda em `DELIBERAÇÃO SEONT`) — defasagem entre duas fotografias, não erro do painel. |
| 910321, 983577 | **Ausentes de todo o pipeline novo** — nem em `bronze.fato_etapas_santos_obras` nem em `silver.fato_solicitacoes` (fonte `santos_obras`). |

**Causa confirmada com dado real:**

```sql
SELECT MAX(data_criacao) AS max_criacao, COUNT(*) AS total
FROM silver.fato_solicitacoes WHERE fonte = 'santos_obras'
-- max_criacao = 2026-06-24T02:3... | total = 12.363
```

A ingestão da fonte `santos_obras` (Bronze/Silver, dentro de `pl_ingest_acto`) está **~2 semanas atrasada** — nenhuma OS criada após 24/06/2026 existe no pipeline novo. Isso explica a maior parte das OS `#N/D` do relatório do cliente (qualquer OS aberta depois de 24/06 fica ausente de **todos** os painéis, não só o de Chefia SEONT).

- [ ] Verificar no Fabric Monitoring Hub a última execução bem-sucedida da atividade de ingestão da fonte `santos_obras` em `pl_ingest_acto` (token `TOKEN_SANTOS_OBRAS` expirado? erro 401/430 silencioso? agendamento ativo?)
- [ ] Disparar execução manual da ingestão se confirmado o atraso
- [ ] Reexecutar os Gold de obras (`acompanhamento`, `tempo_etapa`, `seont_analista_tecnico`) após a ingestão atualizar
- [ ] Recontar `confbi2.csv` completo após a atualização — separar quantas OS `#N/D` eram por defasagem de pipeline (resolvidas pela ingestão) vs. gap estrutural genuíno (resolvido pelo fix de "Não Atribuído" acima)

### ⚠️ Regressão descoberta (08/07/2026) — `_nb_gold_orquestracao` quebrado

A pipeline `pl_ingest_acto` **não estava parada** (rodou com sucesso 26/06→07/07, exceto falhas pontuais 03–05/07). A falha de hoje (08/07) em `_nb_gold_orquestracao` revelou a causa real:

```
[UNRESOLVED_COLUMN.WITH_SUGGESTION] A column ... `flag_chefia` cannot be resolved.
Did you mean one of the following? [data_criacao, dias_na_etapa, etapa_atual, servico, status].
```

Este notebook (`cell-join-gold`, código pré-existente) seleciona `flag_chefia` direto de `gold.santos_obras_acompanhamento` — coluna que **nós removemos** ao aplicar a correção de paridade com o legado ([[SPEC_DRIVE_PARIDADE_GOLD_OBRAS]], Bloco 2.3), sem checar consumidores downstream. Isso quebrou o Gold orchestrator inteiro desde que a correção da acompanhamento foi rodada em Fabric — e minha própria célula de fix (seção acima) copiou o mesmo erro.

**Corrigido:** removida a seleção de `flag_chefia` das duas células (`cell-join-gold` e a célula de fix "Não Atribuído") — a tabela `gold.santos_seont_analista_tecnico` perde essa coluna (era "oculta/interna" segundo o mapeamento de colunas abaixo, não usada em nenhum visual).

- [x] Reexecutar `nb_gold_santos_seont_analista_tecnico` e confirmar que roda sem erro — rodou, mas revelou um SEGUNDO bug silencioso (ver abaixo)
- [ ] Reexecutar `_nb_gold_orquestracao`/pipeline completo e confirmar sucesso end-to-end
- [ ] Checar se algum outro notebook depende de colunas removidas na paridade (`flag_seont`, `executor_responsavel`, `analista_responsavel`, `flag_etapa_aprov`, `numero_licenca`, `deliberacao`) antes de considerar a paridade "fechada"

### ⚠️ Segunda regressão (08/07/2026) — fan-out silencioso no join, sem erro

Após corrigir o `flag_chefia`, o notebook rodou sem erro mas com números errados: `df_ultima` (846 OS, correto) virou **1.011 linhas** após o join com `gold.santos_obras_acompanhamento` — sem nenhuma exceção.

**Causa:** a correção de paridade restaurou o grain do legado em `gold.santos_obras_acompanhamento` — **N linhas por OS** quando há múltiplas etapas abertas simultaneamente (`flag_multiplas_etapas`). Este notebook assumia (implicitamente, do design anterior) **1 linha por OS** nessa tabela — verdade na versão pré-paridade, que usava Window de prioridade para expor só 1 linha "atual". O `LEFT JOIN` contra a tabela multi-linha causa fan-out: cada OS analisada pode virar 2+ linhas se tiver etapas concorrentes abertas no momento.

**Fix:** nova célula de dedup logo após a leitura do Gold — `df_gold_dedup` usa `Window.partitionBy('n_da_solicitacao').orderBy(data_etapa_inicio desc)` para reduzir a 1 linha/OS (critério: etapa aberta mais recente) antes de qualquer join. `cell-join-gold` e a célula de fix "Não Atribuído" passaram a usar `df_gold_dedup` em vez de `df_gold` cru. Assert de regressão adicionado: `df_final.count() == df_ultima.count()` logo após o join principal.

> [!important] Lição para o restante da paridade
> Qualquer notebook que consome `gold.santos_obras_acompanhamento` esperando 1 linha por OS **vai quebrar silenciosamente** (sem erro, só números inflados) após a correção de paridade, a menos que dedupliquem antes de usar. Vale grep por `gold.santos_obras_acompanhamento` em todos os notebooks do módulo Acto para achar outros consumidores antes de dar a paridade como fechada.

- [ ] Reexecutar `nb_gold_santos_seont_analista_tecnico` (com o fix de dedup) e confirmar `Total OS` correto (846 + 98 novas "Não Atribuído" = 944, sem inflação por fan-out)
- [ ] Grep em `Acto/nbs/` por outros notebooks que leem `gold.santos_obras_acompanhamento` sem deduplicar

> [!warning] Falha não relacionada, mesma execução
> `nb_atualizar_carta_servicos` também falhou na mesma execução (08/07), com erro Python/numpy (`ValueError: ... array at index 0 has size 715 and the array at index 1 has size 15`). É de um domínio totalmente diferente (Carta de Serviços/SLA) e não tem relação com obras/SEONT — tratar como issue separada.

### ✅ Verificação final contra o chamado original da Kelly (10/07/2026)

Chamado de origem: `os.acto.net.br/#/operacao/servicos/fluxo/994650/7183/0` — o `confbi2.csv` anexado por ela é o mesmo arquivo investigado por amostragem em 08/07. Reconciliação completa (não mais por amostragem) contra o estado **atual** dos dados, via `exploracao_obras_sql/conexao_fabric.py`:

**Método:** extraídas as 88 OS distintas da coluna "OS no RELATÓRIO GERADO manualmente" do `confbi2.csv` que davam `#N/D` no VLOOKUP original (i.e., as que a Kelly reportou como sumidas do painel). Cruzadas contra `gold.santos_obras_acompanhamento` (deduplicado) e `gold.santos_seont_analista_tecnico` **hoje**.

| Grupo | Qtd | Achado |
|---|---|---|
| Não existem mais em `silver.fato_solicitacoes` | 6 | `910321, 983577, 985986, 987197, 988460, 989399` — não são OS válidas do módulo obras hoje (consistente com a amostragem de 08/07, que já achava 910321/983577 ausentes de todo o pipeline) |
| Existem, mas já saíram da Chefia SEONT | 79 | Avançaram naturalmente desde a foto do CSV: maioria foi para `SEONT - ANÁLISE TECNICA*` (já com analista atribuído) ou `COMUNIQUE-SE` (aguardando o cidadão); outras saíram do SEONT para SEFISO, Pareceres-SEMAM, SEAP, ou etapas de formulário (`DADOS DO IMÓVEL...`, `DECLARAÇÃO DE VERACIDADE...`). Ausência do painel de Chefia é **esperada**, não é bug. |
| Ainda pendentes na Chefia SEONT hoje | **3** | `774366`, `839908`, `960879` — as únicas que ainda representam o cenário original da reclamação |

**As 3 OS ainda pendentes na Chefia aparecem TODAS em `gold.santos_seont_analista_tecnico` hoje:**

| OS | `aux_setor_responsavel` | `analista_tecnico` |
|---|---|---|
| 774366 | SEONT-Chefia | `Não Atribuído` ← capturada pelo fix desta semana |
| 839908 | SEONT-Chefia | LUCAS DE OLIVEIRA DOS SANTOS |
| 960879 | SEONT-Chefia | ELTON MASSAHIRO CHINEN TAMASHIRO |

**Conclusão: o fix aplicado (merge de OS pendentes-Chefia sem etapa de análise em "Não Atribuído") resolveu o chamado original.** Zero OS genuinamente presas na Chefia SEONT hoje estão ausentes do painel. As demais 79 OS do relatório manual da Kelly não aparecem mais como "pendentes na Chefia" simplesmente porque não estão mais lá — o relatório dela era uma fotografia de ~1-2 meses atrás, e o fluxo natural do processo já as moveu adiante.

- [x] Confrontar todas as OS do `confbi2.csv` contra o estado atual (não só amostra)
- [x] Confirmar que as OS ainda pendentes na Chefia aparecem no painel (com analista ou "Não Atribuído")
- [ ] Comunicar Kelly/cliente: chamado resolvido — anexar esta tabela como evidência

---

## ⚠️ Reunião 21/07 — "Painéis Obras" (Kelly, João, Victor)

Revisão geral dos 5 painéis internos de Obras. Resumo por painel:

### Painel de Chefia — confirmado OK
João conferiu ao vivo: painel mostra 66 OS, planilha manual mostra 67 — diferença de 1 explicada pelo refresh rodar às 4h da manhã (uma OS avançou/entrou depois da última planilha). Sem ação necessária.

### Painel de Analistas (este painel) — prioridade máxima, "o mais bagunçado"
Kelly reforçou que o objetivo central é: **o analista entra no painel e sabe o que tem que atender**. Pedidos concretos, em ordem de importância:

1. **Filtro principal = Analista**, não período — igual ao painel de Chefia (analista clica no nome dele e a tela já filtra tudo abaixo). Manter o filtro de período mas ele deixa de ser o primeiro/principal.
2. **Falta a lista de OS** — é a queixa mais repetida na call ("falta a listinha de quais são as OS", "acaba sendo secundário [o resto]"). Tabela com `Nº OS`, `executor responsável`, `setor`, `etapa` — Victor já havia planejado isso para a "Base Detalhada" (Pág. 2), confirmado como suficiente.
3. **Tempo médio de atuação por etapa, por analista** — card novo. Kelly: "se tu quisesse colocar um tempo médio de atuação na etapa" → Victor confirmou: por analista, tempo médio que ele está levando nas etapas.
4. **Quais serviços o analista está executando/atuando** — outro card/quebra pedido por Kelly.
5. Exemplo usado na call como validação do desenho (filtro "Ana Carolina"): 68 OS no nome dela, 49 em andamento, 19 finalizadas — esse tipo de leitura já funciona e deve ser preservado.

**Estado atual do painel:** Victor descreveu como "um caos" — quebrou inteiro em algum momento, foi remontado por outra pessoa sem o dono original ter entrado, e o gráfico "Total de OS por Executor" acabou perdido na Pág. 2 (base detalhada) sem organização. Retrabalho de layout é necessário, não só adicionar os itens acima.

**Compromisso:** Victor começa por este painel antes do PDR, avisando Kelly/João por mensagem conforme for ajustando (não esperar terminar tudo). Meta informal: adiantar até segunda-feira 27/07.

Ver seção "Prioridade P0.1" de [[spec_drive_semana_20_07_2026]] para o checklist consolidado.

### Painel PDR — nova visão gerencial pedida (sem pressa)
Kelly usa o `PMS_AuxiliarPDR.xlsx` para ver, por setor responsável (ex.: ACKT, C1, SEFIS, SEONT/CEOB), quanto tempo cada setor está demorando para atender — indicador que ela hoje monta manualmente no Excel (tabela dinâmica, "gerar todos os resultados daquele filtro"). Pedido: uma nova página com **um card por setor**, mostrando **apenas a média de duração em dias** (não é preciso nenhum detalhamento além do número — "se ele quiser depois algum detalhamento, ele volta nessa página e olha"). Filtro por mês/ano deve continuar funcionando. Ideia para depois (não agora): gráfico de variação mensal ao clicar no setor.

Kelly só revisita o painel PDR uma vez por mês (fechamento), então este item não é urgente — Victor cria a aba depois de resolver o painel de Analistas.

### Painel de Pareceres — bug de classificação por "reforma"
João extraiu o relatório de pareceres da semana e bateu 4 OS; o painel mostrava 12. Ao vivo, tirando o serviço "reforma" da tabela, o número caiu para as mesmas ~4 OS do João — confirmando a causa.

**Causa:** a etapa que identifica "reforma" tem o nome genérico `PARECER TÉCNICO DIVERSOS` — a mesma etapa que o pipeline usa para identificar parecer de verdade. A lógica de classificação de Kelly (na Grid, fonte usada como parâmetro) ficou genérica demais e não expõe mais um campo adicional que permitiria diferenciar "reforma" de "parecer" — ela ainda não achou uma forma de fazer a Grid refletir essa distinção.

**Ação:**
- Workaround imediato: excluir/filtrar o serviço "reforma" do painel de Pareceres (Kelly concordou que fica assim por enquanto, mesmo sabendo que "o certo" seria ele aparecer corretamente classificado).
- Aguardar Kelly mandar uma nova lista/parâmetro quando destravar a lógica do lado dela — sem previsão, é dependência externa.
- Painel de Pareceres da Chefia (mesma fonte, outro recorte) tem o mesmo problema de fundo — não foi testado à parte na call, mas a causa é a mesma etapa genérica.

### Painel de Pavimentos (relatório de subformulário) — segue bloqueado
Ambos (Victor e Kelly) têm o mesmo problema: o campo do subformulário aparece certo na Grid, mas a extração via API traz um valor incorreto/aleatório. Victor já montou o relatório e só está esperando a OS de correção da API ser atendida. Nenhuma ação possível deste lado até a API ser corrigida — não adianta debater o desenho do painel enquanto isso não resolve, já que é "um relatório mais gerencial" (fora do escopo padrão do Acto).

---

## Etapas de Análise SEONT — Fonte: PMS_AuxiliarPDR + exploração Bronze

| Rótulo PBI (etapa_analise_label) | Etapa raw (Bronze)                              | OS Bronze |
|----------------------------------|-------------------------------------------------|-----------|
| Análise Técnica — Conf. Dados    | SEONT - ANÁLISE TECNICA - CONFERÊNCIA DOS DADOS | 837       |
| Análise Técnica                  | SEONT - ANÁLISE TECNICA                         | 818       |
| Pré-Análise                      | SEONT - PRÉ  ANÁLISE TECNICA *(duplo espaço)*   | 555       |
| Pré-Análise                      | SEONT - PRÉ ANÁLISE TECNICA                     | 266       |
| Conferência Final                | SEONT CONFERENCIA FINAL - ANÁLISE TECNICA       | 198       |
| Conferência Documental           | SEONT - CONFÊRENCIA DOCUMENTAL                  | 9         |
| Retorno SEDURB                   | SEONT - RETORNO SEDURB                          | 1         |

> Volumes Bronze ≠ OS Gold — o ROW_NUMBER captura apenas a última etapa por OS.

**Excluídos (chefia/admin, confirmado via exploração Bronze):**
- SEONT Z1/Z2/Z3 CHEFIA - DISTRIBUIÇÃO · SEONT CHEFIA - DISTRIBUIÇÃO (911 registros — chefes de zona)
- SOLICITAR PARECERES · DELIBERAÇÃO · D.O. · BUSCAR PROCESSO · AGUARDANDO OUTROS

> Usar `etapa_analise_label` nos visuais PBI. `etapa_analise` guarda o nome raw para auditoria.

---

## Protótipo Visual — Página 1: Visão Consolidada

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ■ SEONT · Análises Técnicas — Visão Analistas              Santos  ⬛ Obras │
├─────────────────────────────────────────────────────────────────────────────┤
│  📅 Abertura  [Jan 2024 ────────────────────────── Jun 2026]               │
│  👤 Analista  [▾ Todos              ]  🏗 Serviço [▾ Todos          ]      │
│  🔵 Status    [▾ Todos              ]  📍 Zona    [▾ Todas          ]      │
├──────────────┬──────────────┬─────────────────┬──────────────────────────── ┤
│              │              │                 │                             │
│   ~850       │    453       │      378        │          27                 │
│  TOTAL OS    │ EM ANDAMENTO │   FINALIZADAS   │    NÃO ATRIBUÍDAS           │
│  análises    │  53%  🔵     │   44%  ✅       │    3%  ⚠️                   │
│              │              │                 │                             │
├──────────────┴──────────────┴─────────────────┴─────────────────────────────┤
│                                                                              │
│  OS POR ANALISTA  (ordenado por volume ↓)      OS POR SERVIÇO               │
│  ──────────────────────────────────────────    ─────────────────────────── │
│                                                                              │
│  JOÃO PEDRO CHAMON      133 ████████████████   DEMOLIÇÃO          339 ████ │
│  FLAVIA LINS             84 ██████████         PROJ. URBANÍSTICO  147 ███  │
│  LUCAS R. BARCO          67 ████████           NOV. EDIF. COM.     85 ██   │
│  ANA CAROLINA            62 ███████            PLURI-HAB. VERT.    73 ██   │
│  RENATO CAETANO          57 ███████            SOBREPOSTA/GEMINADA 71 ██   │
│  ZANIA MEIRELES          52 ██████             REFORMA/LEGAL.      41 █    │
│  JEFFERSON F. SILVA      51 ██████             UNIFAMILIAR         30 █    │
│  LUCAS O. SANTOS         46 █████              COND. HORIZONTAL    23 █    │
│  ELTON TAMASHIRO         42 █████              OUTROS              35 █    │
│  LARISSA ALMEIDA         40 █████                                          │
│  LAUREANA SANTOS         36 ████               TIPO DE ANÁLISE (última/OS) │
│  SABRINA TEIXEIRA        30 ███                ────────────────────────── │
│  ▓ Não Atribuído         27 ███  ← vermelho    Análise Técnica   601  71% │
│  REGINA ARAUJO           26 ███                Conf. Final       140  17% │
│  MARILU SANTOS           24 ██                 An. Conf. Dados    69   8% │
│  GLAYCE LEITE            20 ██                 Pré-Análise        32   4% │
│  (...+7 analistas...)                          Retorno SEDURB      N*  ?% │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  ONDE ESTÃO AS OS AGORA              │  TEMPO DE ANÁLISE (dias_analise)     │
│  ────────────────────────────────    │  ──────────────────────────────────  │
│                                      │                                      │
│  Em trâmite (Sistema/Usuário)  576   │  Média    __ dias                   │
│  ██████████████████████████  68%     │  Mediana  __ dias                   │
│                                      │  Máximo   __ dias                   │
│  SEONT-Chefia (D.O.)          167   │                                      │
│  ██████████████████████       20%    │  [ ver histograma → Pág. 2 ]        │
│                                      │                                      │
│  SEFISO                        17   │  ← valores calculados após           │
│  Pareceres-SEMAM-DEPCAM        15   │    re-rodar notebook com             │
│  SEAP (CC/CB/TG/SO)            22   │    RETORNO SEDURB incluído           │
│  Outros pareceres externos     28   │                                      │
└──────────────────────────────────────┴──────────────────────────────────────┘
  [ Pág. 1 · Consolidada ]  [ Pág. 2 · Detalhe por Analista ]
```

---

## Protótipo Visual — Página 2: Detalhe por Analista

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ■ SEONT · Análises Técnicas — Detalhe                      Santos  ⬛ Obras │
├─────────────────────────────────────────────────────────────────────────────┤
│  👤 Analista  [▾ JOÃO PEDRO CHAMON DE OLIVEIRA JULIÃO              ]        │
│  🏗 Serviço   [▾ Todos    ]   🔵 Status [▾ Todos   ]   📍 Zona [▾ Todas]  │
├────────────────┬───────────────┬──────────────┬──────────────────────────── ┤
│                │               │              │                             │
│  133 OS        │  __ dias      │  __ dias     │  Análise Técnica  → 82 OS  │
│  carteira total│  média        │  mediana     │  Conf. Final      → 35 OS  │
│  João Pedro    │  análise      │  análise     │  Outros           → 16 OS  │
│                │               │              │                             │
├────────┬──────────────────────────────┬────────┬─────────────────┬─────────┤
│  Nº OS │ Serviço                      │ Status │ Etapa Atual     │ Dias An.│
├────────┼──────────────────────────────┼────────┼─────────────────┼─────────┤
│924.156 │ DEMOLIÇÃO                    │ 🔵 Atd │ SEONT-Chefia DO │   12   │
│854.621 │ PROJETO URBANÍSTICO          │ ✅ Fin │ PUBLICADO       │    8   │
│803.910 │ NOVAS EDIF. COM. SERV. MISTO │ 🔵 Atd │ SEFISO          │   45   │
│978.604 │ REFORMA E/OU LEGALIZAÇÃO     │ 🔵 Atd │ ANÁLISE TÉCNICA │    3   │
│867.233 │ PLURI-HABITACIONAL VERTICAL  │ ✅ Fin │ D.O. PUBLICADO  │   18   │
│        │ ...  (128 mais)              │        │                 │        │
├────────┴──────────────────────────────┴────────┴─────────────────┴─────────┤
│ 133 OS · João Pedro · ordenar por: [ Dias Análise ▾ ]   [ ↓ Exportar ]    │
├─────────────────────────────────────────────────────────────────────────────┤
│  DISTRIBUIÇÃO — DIAS DE ANÁLISE (João Pedro)                                │
│                                                                              │
│  qtd                                                                        │
│   45 ┤         ████                                                         │
│   35 ┤    ████ ████                                                         │
│   25 ┤    ████ ████ ████                                                    │
│   15 ┤    ████ ████ ████ ████                                               │
│    5 ┤ ██ ████ ████ ████ ████ ████ ████                                     │
│    0 └────────────────────────────────────────                              │
│       0-1   2-3   4-7  8-14  15-30 31-60  60+   (dias de análise)          │
│                 ↑ maioria em 2-7 dias = bom indicador                       │
└─────────────────────────────────────────────────────────────────────────────┘
  [ Pág. 1 · Consolidada ]  [ Pág. 2 · Detalhe por Analista ]
```

---

## Consistência com Painel SEMAM

| Elemento               | SEMAM Analistas                    | SEONT Analistas                       |
|------------------------|------------------------------------|---------------------------------------|
| Cor primária           | Verde `#2ca02c` (ambiental)        | Azul `#1f77b4` (obras/construção)     |
| Filtros Pág. 1         | Período · Analista · Serviço · Status · Zona | idem                       |
| Cards KPI              | Total · Em Andamento · Finalizadas · Não Atribuídas | idem              |
| Barra analistas        | horizontal, vermelho p/ Não Atrib. | idem                                  |
| Barra serviços         | horizontal verde                   | horizontal azul                       |
| Tabela tipo de análise | Etapa · Qtd · %                    | idem + rótulo limpo (etapa_analise_label) |
| Pág. 2 — tabela        | Nº OS · Serviço · Status · Etapa Atual · Abertura | + Dias Análise     |
| Pág. 2 — gráfico       | Linha do tempo por mês             | Histograma dias de análise            |
| Não Atribuído          | 4 OS (SUPORTE INMOV)               | 27 OS (SUPORTE INMOV + SUPORTE EICON) |

---

## Mapeamento — Colunas Gold → Visuais PBI

| Coluna                  | Tipo      | Visual                                           | Observação                            |
|-------------------------|-----------|--------------------------------------------------|---------------------------------------|
| `id_os`                 | bigint    | Tabela detalhe, drill-through                    | Chave                                 |
| `servico`               | varchar   | Filtro · barras por serviço · tabela             | Sem prefixo `05-` (normalizado)       |
| `analista_tecnico`      | varchar   | Filtro principal · barras horizontais            | "Não Atribuído" = contas sistema      |
| `etapa_analise_label`   | varchar   | Tabela tipo de análise · filtro                  | Rótulo limpo — usar este no PBI       |
| `etapa_analise`         | varchar   | Auditoria apenas                                 | Nome raw do Bronze                    |
| `data_inicio_analise`   | timestamp | Filtro período                                   | —                                     |
| `data_fim_analise`      | timestamp | Cálculo `dias_analise`                           | 89.8% preenchido                      |
| `dias_analise`          | integer   | KPIs média/mediana · histograma Pág. 2           | Calculado no Gold                     |
| `status`                | varchar   | Cards KPI · filtro · cor condicional             | "Em atendimento" / "Finalizado"       |
| `data_criacao`          | datetime2 | Filtro período · linha do tempo                  | —                                     |
| `data_finalizacao`      | datetime2 | Cálculo SLA                                      | —                                     |
| `etapa_atual`           | varchar   | Tabela detalhe — onde está a OS agora            | —                                     |
| `aux_setor_responsavel` | varchar   | Gargalo pós-análise (Pág. 1 inferior)            | "Sistema"/"Usuário" = em trâmite geral|
| `zona`                  | varchar   | Filtro geográfico                                | 98.7% preenchido                      |
| `dias_na_etapa`         | integer   | Contexto complementar (≠ dias de análise)        | Não expor como KPI principal          |
| `flag_chefia`           | integer   | **Ocultar** — interno                            | Reflete posição atual, não análise    |
| `analista_raw`          | varchar   | **Ocultar** — interno                            | Antes da normalização de contas       |
| `status_etapa_analise`  | varchar   | Complementar (não expor no canvas)               | Status da etapa específica            |

---

## Medidas DAX

```dax
Total OS =
COUNTROWS('gold santos_seont_analista_tecnico')

OS Em Andamento =
CALCULATE([Total OS],
    'gold santos_seont_analista_tecnico'[status] = "Em atendimento")

OS Finalizado =
CALCULATE([Total OS],
    'gold santos_seont_analista_tecnico'[status] = "Finalizado")

OS Não Atribuído =
CALCULATE([Total OS],
    'gold santos_seont_analista_tecnico'[analista_tecnico] = "Não Atribuído")

Média Dias Análise =
AVERAGEX(
    FILTER('gold santos_seont_analista_tecnico',
        NOT ISBLANK('gold santos_seont_analista_tecnico'[dias_analise])),
    'gold santos_seont_analista_tecnico'[dias_analise])

Mediana Dias Análise =
MEDIANX(
    FILTER('gold santos_seont_analista_tecnico',
        NOT ISBLANK('gold santos_seont_analista_tecnico'[dias_analise])),
    'gold santos_seont_analista_tecnico'[dias_analise])

-- Coluna calculada para histograma
Faixa Dias Análise =
SWITCH(TRUE(),
    ISBLANK('gold santos_seont_analista_tecnico'[dias_analise]), "Sem data",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 1,  "0–1 d",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 3,  "2–3 d",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 7,  "4–7 d",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 14, "8–14 d",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 30, "15–30 d",
    'gold santos_seont_analista_tecnico'[dias_analise] <= 60, "31–60 d",
    "60+ d")
```

---

## Passo a Passo — Construção no Power BI

### 1. Conectar
- Microsoft Fabric → `lh_solicitacoes_acto` → `gold.santos_seont_analista_tecnico`
- Modo: Importar

### 2. Calendário
```dax
Calendário = CALENDAR(DATE(2023,1,1), TODAY())
```
Relacionar com `data_criacao` (1:N).

### 3. Página 1 — Consolidada

| Visual | Configuração |
|---|---|
| 5 Slicers | `data_criacao` (slider) · `analista_tecnico` (lista) · `servico` (dropdown) · `status` · `zona` |
| 4 Cards KPI | Total OS · Em Andamento · Finalizadas · Não Atribuídas |
| Barras horizontais | Eixo Y: `analista_tecnico` · Valor: `[Total OS]` · cor condicional vermelha p/ "Não Atribuído" |
| Barras horizontais | Eixo Y: `servico` · Valor: `[Total OS]` |
| Tabela simples | `etapa_analise_label` · Contagem · % |
| Tabela/barras | `aux_setor_responsavel` · Contagem · % (gargalo pós-análise) |
| 2 Cards KPI | `[Média Dias Análise]` · `[Mediana Dias Análise]` |

### 4. Página 2 — Detalhe por Analista

| Visual | Configuração |
|---|---|
| 4 Slicers | `analista_tecnico` (destaque) · `servico` · `status` · `zona` |
| 4 Cards | OS total filtrado · Média dias · Mediana dias · breakdown por `etapa_analise_label` |
| Tabela | `id_os` · `servico` · `status` (ícone) · `etapa_atual` · `aux_setor_responsavel` · `dias_analise` · `data_criacao` |
| Barras verticais | Eixo X: `Faixa Dias Análise` · Valor: contagem — histograma de duração |

### 5. Formatação
- Cor primária: `#1f77b4` (azul obras)
- Ocultar no semantic model: `flag_chefia` · `analista_raw` · `status_etapa_analise` · `etapa_analise` (manter apenas `etapa_analise_label`)
- Sincronizar filtros `analista_tecnico` · `servico` · `status` entre as duas páginas

---

## Checklist antes de publicar

- [ ] Notebook re-rodado no Fabric (inclui RETORNO SEDURB + `dias_analise` + `etapa_analise_label`)
- [ ] RefreshSqlEndpoint rodado (schema timestamp nas datas)
- [ ] `05-DEMOLIÇÃO` ausente — confirmar no notebook de validação
- [ ] `etapa_analise_label` presente e mapeado corretamente (6 rótulos)
- [ ] `dias_analise` com cobertura ≥ 85% no semantic model
- [ ] "Sistema"/"Usuário" em `aux_setor_responsavel` com rótulo "Em trâmite" no canvas
- [ ] `flag_chefia` e `analista_raw` ocultados
- [ ] Filtros sincronizados entre Pág. 1 e Pág. 2
- [ ] Validar consistência visual com painel SEMAM Analistas (mesma estrutura)
