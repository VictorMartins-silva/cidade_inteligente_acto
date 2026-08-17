---
title: Investigação — Bug santos_obras (payload + comportamento da API Acto Gestão)
tags: ["tipo/investigacao", "ferramenta/fabric", "camada/bronze", "camada/gold", "fonte/santos_obras"]
aliases: ["bug santos_obras", "investigacao payload obras", "api acto gestao inconsistente"]
description: "Postmortem: KeyError id_os em nb_bronze_acto_gestao para santos_obras, causa raiz real, e bug de nomenclatura EAV inconsistente na API achado em seguida"
status: "resolvido"
atualizado: "2026-07-15"
---
# Investigação — Bug santos_obras (payload + comportamento da API Acto Gestão)

> **Fonte afetada:** `santos_obras` (módulo novo EAV, `Acto Cidade Inteligente/Acto/`)
> **Notebooks envolvidos:** `nb_bronze_acto_gestao`, `nb_bronze_orquestracao`, `nb_gold_santos_obras_acompanhamento`, `nb_gold_santos_obras_seont`, `nb_gold_santos_obras_tempo_etapa`
> **Payload:** `Files/payloads/payload_obras.json`
> **Status final:** ✅ Resolvido e validado em produção (15/07/2026)

[[Documentação_Fabric/Acto/00_INDEX_ACTO|Índice Acto]] | [[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO|Doc Técnica]] | [[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO|Inventário Bronze EAV]]

---

## TL;DR

Dois bugs distintos, descobertos em sequência, ambos na fonte `santos_obras`:

1. **Bronze quebrava com `KeyError` no `id_os`** — causa real: `payload_obras.json` tinha centenas de campos de formulário órfãos (referenciando campos removidos/renomeados na Acto Gestão há tempo). Isso travava o processamento da API logo no primeiro catálogo da lista, e ela devolvia um resumo genérico (`descricao`/`total`) em vez de dados detalhados — silenciosamente, sem erro HTTP.
2. **Gold (`bairro_consolidado`, `titulo_profissional`, `zona`) ficava 100% NULL** mesmo com o Bronze correto — causa real: a API `VisualizarDadosIntermediarios` **não é consistente em como nomeia o campo EAV consolidado entre execuções** (às vezes usa o `tit`/rótulo, às vezes o `col`/identificador técnico de um catálogo específico). Um filtro por nome exato no Gold nunca acertava de forma confiável.

Ambos corrigidos e validados com números batendo (ou muito próximos) da referência legada.

---

## 1. Sintoma original

`nb_bronze_acto_gestao` falhava para `santos_obras` com:

```
KeyError: 'Nenhum candidato para id_os encontrado no DataFrame de solicitações.'
```

em `resolver_id_os()`. Isolando a extração, `df_solicitacoes` sempre vinha com apenas 2 colunas (`descricao`, `total`) e 123 linhas — um resumo agregado, nunca os dados detalhados linha-a-linha esperados (`Nº Solicitação`, `Serviço`, `Status Fluxo`, etc.).

---

## 2. Hipóteses erradas (nessa ordem, todas testadas e descartadas)

| # | Hipótese | Por que parecia plausível | Por que estava errada |
|---|---|---|---|
| 1 | Encoding mojibake no `tit` de um catálogo específico (`"N? Solicita??o"` em vez de `"Nº Solicitação"`) | Um catálogo (5604) realmente tinha esse problema | Corrigido, resultado da API não mudou nada |
| 2 | Relatório "Base_obras_santos" reconfigurado pra modo resumo/agrupado no servidor | Captura ao vivo do navegador mostrava campos desmarcados em alguns catálogos | Parcialmente relacionado, mas não era a causa principal |
| 3 | Campo `sequencia` fora de escala (ex.: `servico` com valores tipo 5873-5890 em vários catálogos, resíduo de alguma exportação antiga) | Valores claramente anômalos, muito maiores que os demais campos do mesmo catálogo | Corrigido (renumerado 1..N por catálogo), o bug persistiu idêntico |

**Lição:** essas três hipóteses vieram de inspecionar o payload localmente. A virada só aconteceu testando a API **diretamente**, fora do Fabric.

---

## 3. Causa raiz real #1 — campos de formulário órfãos

`payload_obras.json` (base antiga, 29 catálogos) tinha **342 campos de formulário órfãos** espalhados pelos catálogos: referências a `col` (identificador técnico) que existiam numa versão antiga do formulário de cada serviço na Acto Gestão, mas foram removidos/renomeados desde então.

Exemplo concreto — catálogo 8134 (PROVIDÊNCIA) tinha no payload antigo:
```
nunumero, RESPONSÁVEL TÉCNICO DA OBRA, Rzsocial_resp_pj, nmlogradouro
```
— nenhum desses existe mais na configuração ao vivo do catálogo.

**Mecanismo do bug:** ao enviar esses campos órfãos no corpo da requisição pro endpoint `POST /api/Tabela/VisualizarDadosIntermediarios`, a API quebrava o processamento logo no **primeiro catálogo da lista** e devolvia só **1 item de resposta** (resumo genérico `Descrição`/`Total`) em vez de 1 item por catálogo enviado — descartando os outros 28 catálogos silenciosamente, sem erro HTTP.

### Como foi diagnosticado

Testando a API diretamente (fora do Fabric), com Python + `urllib` local e um Bearer token capturado do navegador (via "copy as cURL" do DevTools), foi possível iterar muito mais rápido do que subindo o payload no Lakehouse e rodando o orquestrador a cada tentativa. Comparação campo a campo entre a base antiga e uma captura ao vivo do preview funcionando no navegador revelou a diferença exata.

**Detalhe estrutural útil da API:** `POST VisualizarDadosIntermediarios` retorna `data` como uma **lista com um item por catálogo enviado** — não um blob único. Cada item tem `dados: {codCatalogo: [linhas...]}`. Um teste inicial que só olhava `data[0]` quase levou a um diagnóstico errado ("só 1 catálogo retorna algo").

### Fix aplicado

`payload_obras.json` reduzido de 29 catálogos com ~370 campos totais para 29 catálogos com só os campos realmente necessários:

- **6 campos padrão:** `seqFluxo`/Nº Solicitação, `servico`/Serviço, `statusFluxo`/Status Fluxo, `dataCriacao`/Data Finalização, `dataSolicitacao`/Data Criação, `solicitante`/Solicitante
- **2 campos novos solicitados:** `etapaAtual`/Etapa Atual, `executorAtual`/Executor Atual
- **Campos de negócio recuperados do payload antigo** (necessários pro Gold, ver seção 4): variantes de bairro (`COB_IMOB_LOGRBAIRRO`, `TXT_IMOB_LOGRBAIRRO`, `bairroadm`, `Logradouro_Bairro`, `bairro_oficial`, etc.) e de título profissional (`Titulo_Profissional_PF`/`PJ`), mais o campo de deliberação SEONT (`Esta solicitação deverá ser analisada por:`)

Testado com sucesso: 29/29 catálogos retornam dados detalhados, ~12.625 linhas totais, coluna de ID presente.

---

## 4. Causa raiz real #2 — nome de campo EAV inconsistente entre execuções

Depois do fix #1, o Bronze/Silver rodaram OK, mas `nb_gold_santos_obras_acompanhamento` (que fazia pivot EAV com `CAMPOS_DESEJADOS = ["bairro", "titulo_profissional"]`) encontrava **zero** campos — `bairro_consolidado`, `titulo_profissional` e (por efeito cascata, via join com a dimensão de zonas) `zona` ficavam **NULL em 100% das linhas**, mesmo com o Bronze tendo os dados certos.

### Causa

A API `VisualizarDadosIntermediarios` **não é consistente em como nomeia o campo EAV consolidado entre execuções**:

- Em testes diretos (script local), variantes técnicas diferentes de bairro (`TXT_IMOB_LOGRBAIRRO`, `COB_IMOB_LOGRBAIRRO`, `bairroadm`, etc. — todas com `tit` = "Bairro"/"Bairro:") vinham consolidadas sob o rótulo `bairro` (baseado no `tit`).
- No **pipeline real do Fabric**, com o **mesmo payload exato**, essas mesmas variantes vieram consolidadas sob `cob_imob_logrbairro` (baseado no `col` técnico do catálogo 12804).

A contagem de linhas bateu exatamente entre as duas execuções (6.438 registros de bairro, 1.895 de título profissional) — só o **nome do campo mudou**. Ou seja, o dado está sempre certo; o rótulo que a API escolhe pra representar o grupo consolidado não é determinístico.

### Fix aplicado

Trocada a lógica de `nb_gold_santos_obras_acompanhamento.ipynb` (célula "fato_campos: bairro e título profissional") de filtro por nome exato para descoberta em tempo de execução via `rlike` (regex):

```python
bairro_campos = [r.campo for r in _campos_fonte.filter(F.col("campo").rlike("bairro")).select("campo").distinct().collect()]
titulo_campos = [r.campo for r in _campos_fonte.filter(F.col("campo").rlike("titulo.*profissional")).select("campo").distinct().collect()]
```

Depois consolida (`F.coalesce`) todos os campos que baterem com o padrão, independente do nome exato. Testado e confirmado funcionando — `zona preenchida` foi de 0% pra **50.2%** (referência legado: ~50.1%).

---

## 5. Validação final em produção (15/07/2026)

| Notebook / Tabela | Métrica | Resultado | Referência legado |
|---|---|---|---|
| `nb_bronze_orquestracao` | `santos_obras` | ✅ Bem-sucedido | — |
| `gold.santos_obras_acompanhamento` | Total / OS distintas | 12.997 / 12.626 | 12.893 / 12.529 |
| | zona preenchida | 50.2% | ~50.1% |
| | etapa_atual preenchida | 100.0% | — |
| | aux_setor_responsavel | 99.3% | ~94% |
| `gold.santos_obras_tempo_etapa` | Total registros | 101.545 | — |
| | aux_setor_responsavel | 94.9% | ~94% |
| | duracao_dias_preciso | 96.3% (bate com etapas fechadas) | — |
| `gold.santos_obras_seont_os` | Total / OS distintas | 267 / 253 | ~354 / ~335 |
| | flag_etapa_aprov=1 | 210 | — |
| | **executor_responsavel** | **50.9%** | **~99%** ⚠️ ver seção 6 |

---

## 6. Item em aberto (não bloqueante) — gap de `executor_responsavel` no SEONT

`executor_responsavel` no `gold.santos_obras_seont_os` veio em **50.9%**, bem abaixo do `~99%` de referência do legado. Investigado e confirmado: **o gap é upstream, não é um bug desta investigação.**

Dentro do universo SEONT (385 linhas em `gold.santos_obras_acompanhamento`), só 211 (54.8%) já vêm com `executor_atual` preenchido — e esse campo vem de `silver.fato_etapas` (coluna `executor`), alimentado pelo endpoint **separado** `ObterTempoEtapaRelatorio` (não pelo payload/`VisualizarDadosIntermediarios` que investigamos aqui).

Duas hipóteses em aberto para quem for investigar depois:
1. **Realidade operacional atual** — pode haver hoje uma fila real de solicitações em SEONT sem executor atribuído ainda (diferente do momento em que o legado foi medido, 8 dias antes).
2. **Problema de preenchimento pré-existente** no campo "Executor Etapa" na origem Acto Gestão, anterior a esta investigação.

---

## 7. Outros achados incidentais (não bloqueantes)

- Os catálogos `PROJETO URBANÍSTICO` e `ACOMPANHAMENTO DE OBRAS` estavam sem o campo "Serviço" marcado como visível na tela ao vivo da Acto Gestão (config diferente dos outros 27 catálogos) — pendente de correção manual na plataforma.
- `nb_bronze_orquestracao.ipynb` (arquivo local do repositório) tinha uma linha órfã (`"municipio": "Mauá",` solta fora de qualquer dict, na lista `fontes`) que causaria `SyntaxError` se esse arquivo fosse reimplantado no Fabric sem correção. Corrigida.
- `etapa_atual`/`executor_atual` do payload (campos novos pedidos nesta atividade) acabaram não sendo consumidos pelo Gold atual — `nb_gold_santos_obras_acompanhamento` já calcula sua própria versão desses campos a partir de `silver.fato_etapas` (etapa aberta = `data_fim_etapa IS NULL`), não a partir do payload. Ficam como dado extra disponível em `bronze.fato_campos_santos_obras`/`silver.fato_campos`, sem uso direto hoje.

---

## 8. Lições para debugging futuro desta API

1. **Testar a API diretamente, fora do Fabric**, com um Bearer token capturado do navegador (cURL do DevTools) é muito mais rápido que subir payload no Lakehouse e rodar o orquestrador a cada iteração. Usar esse caminho primeiro em bugs futuros de payload/API.
2. **Nunca confiar em nome de campo EAV fixo** vindo dessa API — usar `rlike`/pattern matching no lugar de lista exata em qualquer pivot EAV. Sempre conferir com `SELECT campo, COUNT(*) FROM silver.fato_campos WHERE fonte='...' GROUP BY campo` antes de assumir qual nome vai aparecer.
3. Um catálogo com campos de formulário órfãos (removidos/renomeados na Acto Gestão) pode quebrar a resposta da API **para todos os outros catálogos da mesma requisição**, sem erro HTTP — se um payload de qualquer fonte passar a devolver um resumo genérico em vez de dados detalhados, suspeitar disso primeiro.
4. `POST VisualizarDadosIntermediarios` retorna `data` como lista com 1 item por catálogo enviado (`dados: {codCatalogo: [linhas...]}`) — atenção a esse detalhe ao simular/testar localmente (um bug bobo de só olhar `data[0]` quase gerou um diagnóstico errado nesta investigação).
