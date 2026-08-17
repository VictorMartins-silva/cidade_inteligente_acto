---
title: "Spec Drive — Paridade Gold Obras: EAV × Legado"
tags:
  - tipo/spec-drive
  - tema/obras
  - tema/santos
  - tema/paridade
  - tema/migracao
status: ativo
revisao: "2026-07-21"
---

# Spec Drive — Paridade Gold Obras (lh_solicitacoes_acto × lh_cidade_inteligente_santos)

> **Contexto:** Os 4 painéis de Obras Santos já foram migrados diretamente nos `.pbix` para o modelo EAV do `lh_solicitacoes_acto` — **essa migração está confirmada e não será revertida**. A cogitação inicial de religar os painéis ao lakehouse legado (`lh_cidade_inteligente_santos`) por causa de reclamações de "informações sumidas" foi **cancelada em 07/07/2026**. A investigação (`Acto Cidade Inteligente/exploracao_obras_sql/02_comparar_gold_obras.ipynb`) mostrou que a causa raiz não era a escolha do lakehouse, e sim que a Gold nova **não era réplica do legado**: houve redesign deliberado + 2 bugs de implementação (ver diagnóstico abaixo).
> **Objetivo deste spec:** corrigir os notebooks Gold do módulo Acto, célula a célula, para que produzam tabelas **idênticas** às legadas em lógica, colunas e valores — sem mexer nos painéis PBI, que permanecem apontando para `lh_solicitacoes_acto`. O resultado do refactor é servido às mesmas conexões já existentes; não há reconexão de modelo semântico envolvida neste spec.
> **Princípio:** o legado é a referência canônica de comportamento. Toda divergência intencional futura deve ser aprovada pela Kelly ANTES de implementada.

---

## Diagnóstico — por que as tabelas divergiam

### Bugs (causa provável das reclamações)

| Bug | Onde | Efeito |
|---|---|---|
| **B1 — status case-sensitive** | `nb_gold_santos_obras_acompanhamento` e `nb_gold_santos_obras_tempo_etapa`: `F.col("status").isin(["EM ATENDIMENTO", "PENDENTE"])` sem `upper()`. Valores reais do Silver: `"Em atendimento"`, `"Pendente atendimento"` | Match **nunca** ocorre → `dias_na_etapa` NULL para toda OS ativa |
| **B2 — flag sempre NULL** | `nb_gold_santos_obras_tempo_etapa`: `flag_tem_etapa_mais_avancada` depende do mesmo isin quebrado | Todas as 91,9k linhas com flag NULL → filtro PBI `flag = 0` retorna **zero linhas** (painel vazio) |

### Divergências de design (redesign do SPEC_DRIVE_MIGRACAO_OBRAS)

| # | Ponto | Legado (referência) | Novo (antes deste spec) |
|---|---|---|---|
| 1 | Grain acompanhamento | N linhas por OS c/ múltiplas etapas abertas | 1 linha por OS (Window prioridade por setor) |
| 2 | Seleção etapa_atual | Todas as etapas abertas, incl. sistema (`FINALIZAR FLUXO`) | Exclui `ETAPA RESUMO`/`FINALIZAR FLUXO`, rebaixa Usuário/Sistema |
| 3 | Colunas | 18 cols; SEONT em tabela própria | +7 cols extras; sem tabela SEONT dedicada; sem `tempo_execucao` |
| 4 | `flag_etapa_aprov` | Lista de ~28 variantes (PROCV) | `LIKE '%ANALISADA POR%'` |
| 5 | `duracao_dias_preciso` | `total_seconds()/86400` (fração de dia) | `datediff()` (dias inteiros) |
| 6 | Tipos | `n_da_solicitacao` bigint; datas do tempo_etapa string | varchar; timestamps |
| 7 | Bairro | mapa_bairros hardcoded + nome canônico do aux | coalesce cru, sem correções de grafia |

---

## Bloco 1 — `nb_gold_santos_obras_tempo_etapa` → paridade com `gold_obras_tempo_etapa`

Schema alvo (15 colunas, ordem legada): `os, etapa, servico, data_criacao_os, data_inicio_etapa, data_atendimento_etapa, data_fim_etapa, data_finalizacao_os, tempo_execucao, status, executor, duracao_dias_preciso, duracao_dias_int, aux_setor_responsavel, aux_pdr`

- [x] **1.1** `duracao_dias_preciso` = `(unix_timestamp(fim) − unix_timestamp(inicio)) / 86400` (fração de dia, não `datediff`)
- [x] **1.2** `duracao_dias_int` = `round()` cast bigint
- [x] **1.3** Incluir `tempo_execucao` do `silver.fato_etapas` (defensivo: se coluna não existir no Silver, criar como NULL e avisar)
- [x] **1.4** Datas convertidas para **string** `yyyy-MM-dd HH:mm:ss` (paridade de tipo com o legado — datas lá são varchar)
- [x] **1.5** Remover colunas extras: `dias_na_etapa`, `analista_responsavel`, `executor_responsavel`, `bairro_consolidado`, `zona`, `flag_seont`, `flag_chefia`, `flag_tem_etapa_mais_avancada` (elimina B2 por remoção)
- [x] **1.6** Executado no Fabric em 07/07/2026 — 97.822 registros (legado: 98.206 — gap de ~0,4%, normal por defasagem temporal); `aux_setor_responsavel` 92.693 (94,8%, dentro do esperado ~94%, dim com 188 etapas vs 183/185 legado).

> [!note] Micro-diferença aceita: pandas `.round()` usa half-even e Spark `F.round` half-up — divergência possível só em durações exatamente `.5` dia.

> [!warning] Gap real (não corrigível neste notebook): `silver.fato_etapas` não tem coluna `tempo_execucao` — sai NULL em 100% das linhas (o legado recebia esse valor direto da API). A célula já é defensiva (avisa e preenche NULL em vez de falhar). Corrigir a causa raiz exigiria alterar a extração Bronze/Silver do módulo Acto para capturar esse campo — fora do escopo deste spec (que é só paridade de Gold). Registrar como pendência separada se o painel realmente usar esse campo.

> [!bug]- **B3 — descoberto em produção via painel PDR, 07/07/2026**
> `duracao_dias_preciso`/`duracao_dias_int` saíam **NULL em 100% das linhas**. Causa: `data_inicio_etapa`/`data_fim_etapa` chegam do Silver como string ISO8601 (`"2026-03-31T13:38:26Z"`) — só `data_criacao`/`data_finalizacao`/`data_carga` recebem cast explícito em `nb_silver_acto_gestao`. `F.unix_timestamp()` sem cast prévio assume o padrão `yyyy-MM-dd HH:mm:ss` e não reconhece ISO8601, retornando NULL sempre. **Fix:** cast explícito `.cast("timestamp")` nas colunas de data ANTES do cálculo de duração (célula 1). Assert de regressão adicionado na célula de write: `n_duracao == n_fechadas` (toda etapa com `data_fim_etapa` preenchida precisa ter duração calculada).
>
> Como foi descoberto: ao reconectar o painel `pbi_obras_santos_pdr` no Power BI Desktop, uma etapa órfã de Power Query tentava recriar `tempo_execucao` (erro "campo já existe" — resolvido removendo a etapa), e os visuais de duração ficaram em branco. A investigação revelou que não era problema do Power BI, e sim os dados de duração saindo vazios do Gold.
>
> **Resolvido e validado em 07/07/2026:** reexecução no Fabric confirmou `duracao_dias_preciso` preenchida em 94.197/97.822 (96,3%) — exatamente igual ao número de etapas fechadas (`n_duracao == n_fechadas`, assert passou). `aux_setor_responsavel` 94,8%.
>
> **Confirmado visualmente em 08/07/2026:** painel `pbi_obras_santos_pdr` repontado para `duracao_dias_preciso` — Total de OS 27.279, Duração Dias 386,30 Mil, Média 14,16 dias, gráfico mensal e tabela AuxSetor todos preenchidos com valores fracionários corretos (ex.: 904,28 dias). Painel PDR fechado.

## Bloco 2 — `nb_gold_santos_obras_acompanhamento` → paridade com `gold_pdr_acompanhamentos_os`

Schema alvo (18 colunas, ordem legada): `n_da_solicitacao, servico, status, data_criacao, data_finalizacao, solicitante, titulo_profissional, etapa_atual, executor_atual, flag_multiplas_etapas, aux_setor_responsavel, data_etapa_inicio, data_etapa_fim, tempo_execucao, dias_na_etapa, zona, bairro_consolidado, zona_aplicavel`

- [x] **2.1** Restaurar grain legado: **todas** as etapas abertas viram linhas (sem Window de prioridade, sem exclusão de etapas de sistema); fallback para OS sem etapa aberta = última fechada por `data_atender_etapa`
- [x] **2.2** `dias_na_etapa` com regra legada e comparação normalizada: `upper(trim(status)) ∈ {EM ATENDIMENTO, CANCELADO}` → hoje − início; `= FINALIZADO` → fim − início; senão NULL (corrige B1)
- [x] **2.3** Remover colunas extras (`numero_licenca`, `deliberacao`, `analista_responsavel`, `executor_responsavel`, `flag_seont`, `flag_chefia`, `flag_etapa_aprov`) — a lógica SEONT volta para notebook dedicado (Bloco 3)
- [x] **2.4** Bairro com paridade: correções de grafia do `mapa_bairros` legado (PONTA PRAIA→PONTA DA PRAIA, VILA MATIAS→VILA MATHIAS, MR/MOR.→MORRO…), valores inválidos → NULL, fora do município, e `bairro_consolidado` = nome canônico da dim (`bairro_raw`)
- [x] **2.5** Incluir `tempo_execucao` (da etapa atual) e `n_da_solicitacao` cast **bigint**
- [x] **2.6** Executado no Fabric em 07/07/2026 — resultado: 12.718 linhas / 12.363 OS (legado: 12.893/12.529 — gap normal de defasagem temporal), 311 OS com múltiplas etapas (legado ~252), `aux_setor_responsavel` 99,4%, `dias_na_etapa` NULL só em 304 casos (legado ~282), assert de regressão do bug B1 passou.
  > [!note] Investigação de `zona` (49,7% de cobertura) — inicialmente tratado como possível bug, mas uma query direta no legado (`gold_pdr_acompanhamentos_os`) confirmou fill rate real de **50,1%** (6.459/12.899) — praticamente idêntico. A expectativa de "~94%" era uma suposição incorreta (herdada do `aux_setor_responsavel`), sem base em dado real. Bairros como `ITARARÉ`, `VILA FÁTIMA`, `VILA NOVA CONCEIÇÃO` ficam com `zona = NULL` **também no legado** — nunca estiveram na planilha `Zona_Bairros`, mesmo aparecendo no dicionário de correção de grafia (que serve só para padronizar exibição, não implica zona mapeada). **Não é bug — paridade confirmada.**

> [!warning] O grain multi-linha **reintroduz** `etapa_atual = FINALIZAR FLUXO/ETAPA RESUMO` como linhas (comportamento legado). O fix "SEONT Chefias" validado em 29/06 era necessário só no modelo 1-linha-por-OS; no grain legado a etapa SEONT aparece como linha própria. Validar com o caso da Kelly (`validar_os_chefias_seont.ipynb`) após reprocessar.

## Bloco 3 — Criar `nb_gold_santos_obras_seont` → paridade com `gold_obras_seont_os`

Nova tabela: `gold.santos_obras_seont_os`. Fonte: `gold.santos_obras_acompanhamento` (pós-Bloco 2) + `silver.fato_campos` (analista).

- [x] **3.1** `analista_responsavel` via EAV (`campo rlike 'esta.solicitacao.devera.ser.analisada'`), zerado para etapas não-SEONT
- [x] **3.2** `flag_seont` / `flag_chefia` por `aux_setor_responsavel` (sets legados)
- [x] **3.3** `flag_etapa_aprov` = lista das **28 variantes** normalizadas (copiada do legado — NÃO usar `LIKE ANALISADA POR`)
- [x] **3.4** `executor_responsavel` cascade legado (SEONT c/ executor → executor; SEONT sem → analista; não-SEONT → executor)
- [x] **3.5** Filtro legado: `flag_seont = 1` **e** OS sem linha aberta fora do SEONT (`os_alem_seont`)
- [x] **3.6** 23 colunas na ordem legada (conferir schema real com `schema_tabela('gold_obras_seont_os', DB_LEGADO)` antes da 1ª execução)
- [x] **3.7** Executado no Fabric em 08/07/2026 — 221 linhas / 211 OS (vs. referência de 354/335). `executor_responsavel` 62,0% — bate com o legado ao vivo (63,3%), não é bug.

> [!important] Investigação do gap 221 vs 354 (08/07/2026) — CONCLUÍDA, sem bug
> Comparação `set difference` entre `gold_obras_seont_os` (legado) e `gold.santos_obras_seont_os` (novo): 159 OS só no legado. Dessas, apenas **5** são lacuna real de ingestão (ausentes do Silver: 985986, 987197, 988460, 989399, 993840). As outras **154 (97%)** existem no Silver mas são excluídas pelo filtro `os_alem_seont` — investigação inicial apontou `Usuário`/`Sistema` (94+22 OS) como causa aparente.
>
> **Comparação linha-a-linha (OS 471298)** entre `gold_pdr_acompanhamentos_os` (legado) e `gold.santos_obras_acompanhamento` (novo) mostrou os **mesmos 3 registros, idênticos** (mesmas etapas, mesmos setores, datas quase iguais). A lógica do `os_alem_seont` é fiel em ambos — não há divergência de código nem de dado.
>
> **Causa real:** `gold_obras_seont_os` (legado) **não tem pipeline automatizado** — roda manualmente apenas (documentado em `Santos/nbs/obras/CLAUDE.md`). É um snapshot manual congelado de um momento em que essas 154 OS provavelmente ainda não tinham as etapas de ruído de fundo (`Usuário`/`Sistema`, geradas depois pelo próprio Acto). `gold_pdr_acompanhamentos_os` (a tabela principal) É atualizada pela pipeline automática — por isso reflete o estado atual (com o ruído), enquanto `gold_obras_seont_os` ficou parado no passado.
>
> **Conclusão:** `nb_gold_santos_obras_seont` está correto — replica fielmente a lógica legada sobre dados ao vivo. A referência "~354/~335" não é um alvo estável (nunca foi recalculada desde que o legado passou a rodar de novo). Nenhum fix de código necessário nesta frente.

## Bloco 4 — Orquestração e endpoint

- [x] **4.1** `_nb_gold_orquestracao`: garantir ordem `nb_ingest_obras_aux` → `nb_gold_santos_obras_acompanhamento` → `nb_gold_santos_obras_tempo_etapa` → `nb_gold_santos_obras_seont`
- [ ] **4.2** 1ª execução pós-refactor: `RefreshSqlEndpoint` com `recreateTables: true` (nova tabela `santos_obras_seont_os` + schemas alterados), depois reverter para `false`

## Bloco 5 — Validação de paridade (critério de aceite)

Usar `exploracao_obras_sql/02_comparar_gold_obras.ipynb` (ajustar seção 7 para `gold.santos_obras_seont_os`) — **retomado e ampliado em 15-17/07/2026** com os notebooks `05_comparar_novo_vs_legado_16_07.ipynb`, `06_investigar_gap_seont_126.ipynb` e `08_validacao_geral_obras.ipynb` (novo script de checklist único, ver Bloco 6).

- [x] **5.1** Contagens: PDR e Acompanhamento confirmados como **superset limpo do legado** (`só no legado = 0` nos dois, validado 16/07 e reconfirmado 17/07 via `08_validacao_geral_obras`). SEONT ainda com gap parcial — ver 5.5.
- [ ] **5.2** Valores em OS comuns (seção 5 do `02_comparar`): `status`/`etapa_atual`/`aux_setor_responsavel`/`zona` ≥ 99% iguais — não reexecutado formalmente nesta rodada; `zona`/`bairro_consolidado`/`aux_setor_responsavel` conferidos via `08_validacao_geral_obras` e batendo com a referência (ver 5.3/5.4), mas a comparação linha-a-linha ampla (seção 5 do `02_comparar`) não foi refeita. Script de referência pronto para colar em `02_comparar_gold_obras.ipynb` — ver "5.2.a" abaixo. **Ainda falta rodar no Fabric.**

### 5.2.a — Script de referência para a comparação linha-a-linha

> Ajustar nome/catálogo da tabela legada (`gold_pdr_acompanhamentos_os`) para o padrão de acesso cross-lakehouse já usado no restante do `02_comparar_gold_obras.ipynb` — o snippet abaixo assume que ambas as tabelas já estão acessíveis via `spark.table(...)` no mesmo notebook, igual às demais seções desse arquivo.

```python
from pyspark.sql import functions as F

COLS_COMPARAR = ["status", "etapa_atual", "aux_setor_responsavel", "zona"]

df_novo = spark.table("gold.santos_obras_acompanhamento")
df_legado = spark.table("gold_pdr_acompanhamentos_os")  # ajustar catálogo/nome real

# Grain de ambos: OS x etapa aberta (Bloco 2.1) — comparar por OS + etapa_atual evita
# comparar linhas de etapas concorrentes diferentes na mesma OS
df_join = (
    df_novo.alias("n")
    .join(
        df_legado.alias("l"),
        on=[
            df_novo["n_da_solicitacao"] == df_legado["n_da_solicitacao"],
            F.upper(F.trim(df_novo["etapa_atual"])) == F.upper(F.trim(df_legado["etapa_atual"])),
        ],
        how="inner",
    )
)

total_join = df_join.count()
print(f"OS x etapa em comum (chave de junção): {total_join}")

resultados = {}
for c in COLS_COMPARAR:
    iguais = df_join.filter(
        F.upper(F.trim(F.coalesce(F.col(f"n.{c}"), F.lit("")))) ==
        F.upper(F.trim(F.coalesce(F.col(f"l.{c}"), F.lit(""))))
    ).count()
    pct = round(100 * iguais / total_join, 2) if total_join else None
    resultados[c] = pct
    veredito = "✅" if pct and pct >= 99 else "⚠️"
    print(f"{c}: {iguais}/{total_join} = {pct}% iguais {veredito}")

# Amostra de divergências por coluna, para inspeção manual antes de fechar 5.2
for c in COLS_COMPARAR:
    print(f"--- Amostra divergente em {c} ---")
    df_join.filter(
        F.upper(F.trim(F.coalesce(F.col(f"n.{c}"), F.lit("")))) !=
        F.upper(F.trim(F.coalesce(F.col(f"l.{c}"), F.lit(""))))
    ).select("n_da_solicitacao", f"n.{c}", f"l.{c}").show(10, truncate=False)
```

Critério de aceite (igual ao já usado em 5.1/5.3/5.4): cada coluna ≥ 99% igual fecha o item; abaixo disso, investigar amostra antes de assumir bug.
- [x] **5.3** `dias_na_etapa`: NULL em 309-310 casos (referência: ~282-310 nas execuções desta semana), padrão "só pendentes/sem data" confirmado, sem regressão do bug B1.
- [x] **5.4** tempo_etapa: `aux_setor_responsavel` 94,9% (referência ~94%), `duracao_dias_preciso` batendo exatamente com etapas fechadas (assert `n_duracao == n_fechadas` confirmado nas execuções de 15 e 16/07).
- [x] **5.5** SEONT: gap de 126 OS "só no legado" identificado em 16/07 caiu pra 71 depois do fix do `os_alem_seont` (16-17/07); dessas, 47 são exclusão legítima (confirmado) e as 24 restantes têm decisão de negócio registrada em 23/07 (Opção B, ver Bloco 6.3) — gap de 71 fica fechado como explicado/aceito, não como bug.
- [ ] **5.6** Ainda bloqueado por **5.2** — comparação linha-a-linha ampla (`status`/`etapa_atual`/`aux_setor_responsavel`/`zona`) foi mencionada como executada em 23/07, mas o resultado não está registrado neste spec nem foi possível confirmar os percentuais. **Confirmar o resultado real (rodar/re-rodar `08_validacao_geral_obras` ou o script 5.2.a e colar os números aqui) antes de enviar a comunicação formal a Kelly/Jorge.**

---

## Bloco 6 — Continuação da investigação (15-17/07/2026)

> [!important] Pré-requisito descoberto: a fonte `santos_obras` estava quebrada na origem (Bronze), não só na paridade de Gold
> Antes de qualquer paridade de Gold fazer sentido, era preciso que o Bronze/Silver da fonte `santos_obras` estivesse correto — e não estava. Ver [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API]] para o postmortem completo. Resumo:
>
> - **Bug 1 (payload com campos órfãos):** `payload_obras.json` tinha 342 campos de formulário órfãos (referenciando campos removidos há muito na Acto Gestão), o que travava a API `VisualizarDadosIntermediarios` logo no primeiro catálogo e devolvia um resumo genérico (`descricao`/`total`) em vez de dados detalhados — `nb_bronze_acto_gestao` falhava com `KeyError` no `id_os`. Corrigido reduzindo o payload aos campos essenciais (15/07/2026).
> - **Bug 2 (nomenclatura EAV inconsistente):** a mesma API, com o mesmo payload, às vezes nomeia o campo EAV consolidado pelo `tit` (`"bairro"`) e às vezes pelo `col` técnico (`"cob_imob_logrbairro"`) — inconsistente entre execuções. `nb_gold_santos_obras_acompanhamento` tinha `CAMPOS_DESEJADOS` com nomes fixos e não encontrava nada. Corrigido trocando pra `rlike`/descoberta em tempo de execução (15-16/07/2026).
>
> Sem esses dois fixes, nenhuma validação de paridade deste spec seria significativa — a fonte de dados em si estava incompleta.

### 6.1 — Revisão do gap SEONT (retoma o achado de 08/07 com novo entendimento de negócio)

O Bloco 3 (item 3.7, nota de 08/07) já tinha identificado que 94+22 OS eram excluídas do SEONT por causa de linhas `Usuário`/`Sistema`, mas concluiu **"não há bug de código"**, atribuindo isso a `gold_obras_seont_os` (legado) ser uma tabela sem pipeline automatizado — um snapshot manual congelado de antes dessas etapas de ruído existirem.

A investigação desta semana chegou a um entendimento adicional que muda essa conclusão: `Usuário` e `Sistema` **não são ruído** — são categorias legítimas de "quem está com a bola" numa etapa (departamento interno real / aguardando resposta do munícipe / processamento automático do sistema). Ver [[project_obras_etapas_multiplas_dominio]] (memória) para o detalhamento. Isso significa que uma OS com a etapa SEONT real ainda aberta, coexistindo com uma etapa `Usuário`/`Sistema` também aberta, **deveria continuar contando como "em SEONT"** — o filtro `os_alem_seont` estava excluindo essas OS indevidamente, e isso é um bug de lógica genuíno, não apenas um artefato de comparação com um snapshot desatualizado.

**Fix aplicado** em `nb_gold_santos_obras_seont.ipynb` (16/07/2026): adicionado `SETORES_BACKGROUND = {"Usuário", "Sistema"}`; o filtro `os_alem_seont` agora só considera "avançou além do SEONT" quando a linha fora do SEONT **não** for background:
```python
os_alem_seont = (
    df.filter((F.col("flag_seont") == 0) & (~_setor.isin(list(SETORES_BACKGROUND))))
    .select("n_da_solicitacao").distinct()
)
```
Diagnóstico completo em `exploracao_obras_sql/06_investigar_gap_seont_126.ipynb`.

### 6.2 — Resultado do fix (aplicado no Fabric em 17/07/2026)

| Métrica | Antes do fix (16/07) | Depois do fix (17/07) |
|---|---|---|
| SEONT novo (total) | 254 OS | 325 OS |
| Gap "só no legado" | 126 OS | 71 OS |
| Recuperação esperada (diagnóstico 16/07) | — | ~79 OS (→ gap ~47) |
| Recuperação real | — | 55 OS (gap caiu pra 71, não 47) |

O fix melhorou o resultado na direção certa, mas não bateu exatamente com o previsto — recuperou 55 de 79 OS esperadas.

### 6.3 — Aberto: 24 OS ainda excluídas por Usuário/Sistema após o fix (mecanismo diferente, não investigado a fundo)

Reclassificando o gap atual (71 OS) com o mesmo critério: **47 são exclusão legítima** (confirmadas, avançaram pra outro setor real — SEFISO, Pareceres-*, SEAP-*, etc.) e **24 continuam no padrão "só Usuário/Sistema"**, que deveria ter sido resolvido pelo fix.

Investigando um exemplo (OS 746856), o mecanismo é **diferente** do original: a etapa SEONT dessa OS **já fechou de vez** (não está mais aberta) — sobrou só uma etapa `Usuário` (`COMUNIQUE-SE`, aguardando resposta do munícipe) como única linha da OS (`flag_multiplas_etapas = 0`). Como não sobra nenhuma linha com `flag_seont = 1`, a OS nem chega a ser candidata no filtro (`df.filter(flag_seont == 1)`) — o fix do `os_alem_seont` não se aplica a esse caso, porque ele só mexe na exclusão, não na inclusão.

**Pergunta em aberto, não decidida:** uma OS cuja etapa SEONT fechou e ficou só aguardando o munícipe deveria continuar contando como "em SEONT" (pausada, mas ainda no processo) ou isso é de fato uma saída legítima do SEONT? Precisa decisão de negócio antes de codar mais um fix — pode exigir mudar o critério de **inclusão** (não só exclusão) do filtro, o que é uma mudança mais profunda que a deste spec.

#### Memo de decisão — pronto para levar a Kelly/Jorge (22/07/2026)

**Contexto:** 24 das 71 OS do gap "só no legado" seguem um padrão específico: a etapa SEONT real **já fechou de vez** (não está mais aberta), restando apenas uma etapa de fundo (`Usuário` — ex. `COMUNIQUE-SE`, aguardando resposta do munícipe — ou `Sistema`) como única linha da OS. Como nenhuma linha resta com `flag_seont = 1`, a OS não é sequer candidata no filtro atual — o fix do Bloco 6.1 não alcança esse caso porque ele atua na **exclusão**, não na **inclusão**.

**Opção A — Reclassificar como "ainda em SEONT" (pausada)**
- Muda o critério de inclusão: passaria a contar OS cuja última etapa SEONT fechada foi seguida só por `Usuário`/`Sistema`.
- Fecha o gap das 24 OS restantes (71 → 47, já explicados).
- Risco: é uma mudança de modelagem mais profunda que a paridade original — o legado é um snapshot congelado, não dá para validar esse cenário específico contra ele.

**Opção B — Manter como saída legítima do SEONT (recomendado)**
- A análise técnica terminou; o que resta é responsabilidade do munícipe/sistema, não do analista SEONT.
- Mantém o filtro simples e consistente com o princípio já usado em outras partes do módulo ("quem está com a bola agora").
- Gap de 24 fica documentado como divergência aceita, não como bug.
- Ressalva: se for importante rastrear esse "limbo" para gestão, considerar um indicador separado (ex. "Aguardando resposta do cidadão") em vez de reclassificar como SEONT — preserva a carteira dos analistas sem perder visibilidade do caso.

**Recomendação:** Opção B + indicador complementar se o cliente sentir falta desse rastreio.

- [x] Levar este memo à Kelly/Jorge e registrar a decisão final aqui — **decidido 23/07/2026: Opção B aceita** (mantém como saída legítima do SEONT; gap de 24 fica documentado como divergência aceita, não bug). Indicador complementar de "aguardando resposta do cidadão" fica em aberto para avaliação futura se o cliente sentir falta do rastreio.

### 6.4 — Novo achado, não relacionado a este spec: variantes de `servico` não normalizadas

`gold.santos_obras_acompanhamento` tem 33 valores distintos de `servico`, não os ~29 catálogos esperados — variantes como `05-DEMOLIÇÃO` (29 registros, deveria ser `DEMOLIÇÃO`), `ALTERAÇÕES DIVERSAS EM PROJETOS APROVADOS` / `ALTERAÇÃO EM PROJETO APROVADO` (deveriam ser uma só categoria), `ALVARÁ DE CONSTRUÇÃO PLURI-HABITACIONAL` (sem "VERTICAL", variante de outro serviço). Isso fragmenta contagens/filtros por serviço no painel — provável causa (ou uma das causas) das "inconsistências" que motivaram o cliente a reportar problemas. **Sem fix aplicado ainda** — decisão pendente: normalizar no Gold (mapa tipo `MAPA_BAIRROS_NORM`) ou investigar se são categorias de negócio realmente distintas antes de mexer.

### 6.5 — Scripts de validação criados nesta investigação

Pasta `Acto Cidade Inteligente/exploracao_obras_sql/` (reaproveita `conexao_fabric.py` já existente):
- `04_verificacao_qualidade_obras.ipynb` — completude de campos, duplicatas, sanidade de datas
- `05_comparar_novo_vs_legado_16_07.ipynb` — retomada do `02_comparar_gold_obras` com dados atuais
- `06_investigar_gap_seont_126.ipynb` — diagnóstico do gap SEONT (reutilizável, já rodado 2x)
- `07_investigar_multiplas_etapas.ipynb` — classificação das OS com etapas simultâneas (grupos negócio/mistura/background)
- `08_validacao_geral_obras.ipynb` — checklist único consolidando todos os itens acima com veredito ✅/⚠️/ℹ️ por item

---

## Bloco 7 — Validação pré-reunião Kelly (21/07/2026)

`08_validacao_geral_obras.ipynb` reexecutado com dados ao vivo na manhã de 21/07, para levar números atualizados à reunião com a Kelly sobre os painéis PBI de Obras.

| Item | 17/07 | 21/07 | Veredito |
|---|---|---|---|
| Bronze/Silver `santos_obras` | 12.626 OS | 12.676 OS | ✅ OK — crescimento normal |
| `bairro_consolidado` / `zona` preenchidos | 52,2% / 50,1% | 52,4% / 50,3% | ✅ OK — estável, bate com a referência do legado |
| Gap SEONT "só no legado" | 71 OS | **80 OS** | ⚠️ Subiu em vez de cair — ver análise abaixo |
| Variantes de `servico` não normalizadas | 33 (esperado ~29) | 33 | ℹ️ MONITOR — sem mudança, fix ainda não decidido (item 6.4) |
| PDR/Acompanhamento — só no legado | 0 / 0 | 0 / 0 | ✅ OK — superset do legado confirmado |
| OS só com Usuário/Sistema (grupo c) | 45 | 44 | ℹ️ MONITOR — estável, não é bug |

> [!warning] Gap SEONT subiu de 71 para 80 — não é regressão do fix, mas precisa confirmação antes da reunião
> Como o legado está congelado (335 OS, parado desde 11/03/2025) e o novo é produção viva (325→341 OS SEONT entre 17/07 e 21/07), decompondo os números: a **interseção real** com o legado caiu de 264 para 255 (−9), enquanto o novo ganhou 25 OS que não existem no legado (esperado — são OS que entraram no SEONT depois do congelamento). As 9 OS que "saíram" da interseção são o ponto de atenção: hipótese mais provável é que avançaram legitimamente para outro setor desde 17/07 (mesmo padrão dos 47 já confirmados como exclusão legítima no Bloco 6.3) — mas isso **não foi confirmado linha a linha** para essas 9 específicas antes da reunião. Tratar como "gap parcialmente explicado, com amostra pontual pendente de conferência", não como regressão do fix nem como 100% resolvido.

**Pontos para levar à Kelly:**
1. PDR e Acompanhamento (os dois painéis de maior volume) estão com paridade total confirmada (0 gap) — pode ser comunicado como fechado.
2. SEONT segue com gap parcial e explicado majoritariamente (47/71 já eram exclusão legítima em 17/07); os novos números de 21/07 são consistentes com o mesmo padrão, mas não foram auditados linha a linha nesta rodada.
3. Normalização de `servico` (33 variantes vs ~29 catálogos) segue sem decisão — candidata a causa raiz (ou parte dela) das reclamações originais de "informação sumida"; decisão de negócio necessária.
4. Decisão de negócio ainda pendente (Bloco 6.3): OS com SEONT fechado + só etapa `Usuário`/`Sistema` remanescente — conta como "ainda em SEONT" ou não?

---

## Decisão registrada — 07/07/2026

> [!important] Reversão de painéis CANCELADA
> A ideia de religar os 4 painéis de Obras ao `lh_cidade_inteligente_santos` foi descartada. Os painéis **permanecem** no modelo EAV (`lh_solicitacoes_acto`). Toda a correção deste spec acontece exclusivamente no backend (notebooks Gold) — nenhum `.pbix` precisa ser tocado.

---

## Referências

- [[SPEC_DRIVE_MIGRACAO_OBRAS]] — spec da migração original (redesign que este spec corrige para paridade de comportamento)
- [[spec_drive_semana_06_07_2026]] — semana em que a hipótese de reversão surgiu e foi descartada
- [[esp_drive_os_multiplas_etapas]] — diagnóstico original (04/08/2026) do bug de múltiplas etapas simultâneas no pipeline legado; o design proposto ali (não dropar etapas abertas, cascade de executor, `zona_aplicavel`) foi a base do Bloco 2/3 deste spec
- [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API]] — postmortem dos bugs de Bronze/payload (15-16/07/2026), pré-requisito descoberto pro Bloco 6
- [[project_obras_etapas_multiplas_dominio]] (memória) — entendimento de negócio sobre Usuário/Sistema que embasou o fix do Bloco 6.1
- `Acto Cidade Inteligente/exploracao_obras_sql/` — pasta de exploração SQL com evidências e notebooks de comparação (01-08, ver Bloco 6.5)
- Notebooks legados de referência: `Santos/nbs/obras/nb_gold_acto_gestao_obras.ipynb`, `nb_gold_acto_gestao_obras_etapas.ipynb`, `SEONT/nb_gold_acto_gestao_obras_seont_os.ipynb`
