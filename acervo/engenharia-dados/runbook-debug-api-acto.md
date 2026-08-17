---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
---

# Runbook — Debug de ingestão via API Acto (módulo EAV)

## Quando usar este runbook

Abra este arquivo se você está vendo algum destes sintomas:

- Bronze retorna 2 linhas (ou um número muito baixo, como 1 item por catálogo) em vez de uma lista completa de solicitações
- Bronze está vazio mesmo com o pipeline rodando sem erro HTTP
- Colunas de negócio no Gold (ex.: `bairro_consolidado`, `titulo_profissional`, `zona`) são 100% nulas mesmo com o Bronze correto
- A API retorna um resumo com colunas `descricao` / `total` em vez de dados detalhados linha a linha
- Notebook Gold falha com `KeyError` em campo que aparecia na última execução

---

## Passo 1 — Reproduzir fora do Fabric antes de tudo

**Não suba nada no lakehouse ainda.** Cada tentativa de debug via pipeline gasta tempo de espera de trigger, dificulta isolamento e polui o histórico de carga.

O fluxo correto para iterar rápido:

1. Abra o sistema Acto no navegador e faça login normalmente.
2. Extraia o token de sessão das ferramentas de desenvolvedor (aba Network → qualquer requisição ao endpoint de dados → copiar o header `Authorization`).
3. Dispare o payload diretamente contra o endpoint de visualização de dados intermediários usando curl, Postman ou Python `requests`.
4. Inspecione a resposta JSON crua antes de qualquer transformação.

O que observar na resposta:
- Quantos itens vieram na lista? Se for 1 ou 2, a API está quebrada no nível do payload (ver Passo 2).
- A estrutura tem `descricao`/`total` em vez de colunas de solicitação? Mesmo sinal — é problema de payload.
- Os campos EAV estão chegando com nome `col` (identificador técnico) ou `tit` (rótulo legível)? Anote qual padrão está vindo (ver Passo 3).

> **Regra prática:** testar localmente com token do navegador reduz o ciclo de debug de ~20 min (trigger + carga + consulta) para ~2 min. Use este caminho **sempre** como primeiro movimento em bugs de payload/API deste módulo.

---

## Passo 2 — Checar campos órfãos no payload

**O problema:** o arquivo de payload de cada fonte define quais campos de formulário extrair, usando identificadores técnicos (`col`) que foram configurados numa versão específica do formulário no Acto. Se o formulário foi atualizado na origem e esses identificadores foram removidos ou renomeados, o payload passa a conter referências órfãs.

**O que acontece:** a API não retorna erro HTTP. Ela quebra silenciosamente no primeiro catálogo da lista que encontra um campo órfão e devolve apenas um item de resposta genérico, descartando todos os demais catálogos da requisição. O resultado no Bronze é uma tabela com 1–2 linhas em vez de milhares.

**Como identificar:**
1. No teste local do Passo 1, reduza o payload ao mínimo: apenas os 6 campos padrão (identificador, serviço, status, data de criação, data de finalização, solicitante) e **nenhum** campo de formulário.
2. Se a API passou a retornar a lista completa → a causa é um campo órfão nos campos de formulário.
3. Adicione os campos de negócio de volta **um a um** (ou em pequenos grupos) até a API voltar a quebrar. O campo que causa a quebra é o órfão.

**Como limpar o payload:**
- Remova todos os campos cujos `col` não aparecem mais como atributos válidos na resposta da API.
- Mantenha apenas os campos realmente usados nas tabelas Gold de destino.
- O payload de obras Santos foi reduzido de ~200 campos para ~8 campos relevantes e o problema foi resolvido imediatamente.

> **Atenção ao detalhe:** o endpoint de visualização retorna a lista de resultados com **um item por catálogo enviado**. Se você enviar 5 catálogos no payload e receber 5 itens, está tudo certo. Recebeu menos do que enviou → algum catálogo está falhando.

---

## Passo 3 — Confirmar nome real do campo EAV na Silver antes de escrever o Gold

**A regra mais importante deste módulo:**

- Para os **6 campos padrão** (identificador, serviço, status, datas, solicitante): a API retorna a linha chaveada pelo `tit` (rótulo legível).
- Para **todos os outros campos** com identificador de formulário preenchido no payload: a API retorna a linha chaveada pelo `col` (identificador técnico) em minúsculo.

O problema é que o `col` pode variar entre execuções. Em testes locais, campos EAV aparecem consolidados sob o `tit`; no pipeline real do Fabric com o mesmo payload, os mesmos campos aparecem sob o `col` de um catálogo específico. A contagem de linhas bate — só o nome do campo muda. **Um filtro por nome exato no Gold nunca é confiável.**

**Procedimento obrigatório antes de finalizar o notebook Gold:**

Execute este SQL no SQL Endpoint, substituindo `{fonte}` pelo identificador da sua fonte:

```sql
-- Listar todos os nomes de campo EAV que chegaram na Silver para esta fonte
SELECT DISTINCT
    lower(campo) AS nome_campo_real,
    COUNT(*) AS qtd_ocorrencias
FROM silver.fato_campos
WHERE fonte = '{fonte}'
GROUP BY lower(campo)
ORDER BY qtd_ocorrencias DESC;
```

Compare a lista retornada com o que você esperava pelo `tit` do payload. O nome que aparece na Silver é o nome que você deve usar no pivot do Gold — não o `tit` que você leu no payload.

> **Erro comum:** o desenvolvedor lê o payload e escreve `WHERE campo = 'Bairro Consolidado'` no Gold. A Silver tem `bairro_consolidado_001` (o `col` do catálogo mais frequente). Resultado: 100% de nulos na coluna inteira.

---

## Passo 4 — Validar volumetria Bronze → Silver → Gold

Após qualquer correção de payload ou de lógica de Gold, execute esta sequência de checks **antes** de considerar o fix validado:

```sql
-- Bronze: total de linhas por tabela e fonte
SELECT fonte, COUNT(*) AS total_solicitacoes
FROM bronze.fato_solicitacoes_{fonte}
GROUP BY fonte;

SELECT fonte, COUNT(*) AS total_campos_eav
FROM bronze.fato_campos_{fonte}
GROUP BY fonte;

SELECT fonte, COUNT(*) AS total_etapas
FROM bronze.fato_etapas_{fonte}
GROUP BY fonte;

-- Silver: comparar com Bronze (deve ser igual)
SELECT fonte, COUNT(*) AS silver_solicitacoes
FROM silver.fato_solicitacoes
WHERE fonte = '{fonte}'
GROUP BY fonte;

-- Gold: verificar cobertura de colunas críticas
SELECT
    COUNT(*) AS total_os,
    SUM(CASE WHEN bairro_consolidado IS NULL THEN 1 ELSE 0 END) AS nulos_bairro,
    SUM(CASE WHEN zona IS NULL THEN 1 ELSE 0 END) AS nulos_zona,
    SUM(CASE WHEN setor_responsavel IS NULL THEN 1 ELSE 0 END) AS nulos_setor
FROM gold.{tabela_gold};
```

Critérios de aceite:
- Bronze ↔ Silver: diferença de zero linhas (o `UNION BY NAME allowMissingColumns=True` deve preservar tudo).
- Gold: colunas obrigatórias com nulo acima de 50% indicam problema de nomenclatura EAV (Passo 3). Nulos abaixo de 50% podem ser característica da fonte (ex.: obras Santos tem ~45% de nulos em `data_criacao` — isso é normal e aceito).
- Se Bronze está zerado mas Silver tem dados → há resíduo de execução anterior na Silver; reprocessar Bronze e forçar refresh da Silver.

---

## Passo 5 — Padrão de pivot resiliente no Gold

**Nunca use nome exato de campo EAV em filtro fixo no Gold.** Use detecção por padrão de texto.

Exemplo: em vez de `WHERE campo = 'bairro_consolidado_001'`, use:

```python
# Python/PySpark no notebook Gold
import re

# Detectar todas as variantes do campo de bairro que chegarem na Silver
bairro_cols = [c for c in df_campos.columns if re.search(r'bairro', c, re.IGNORECASE)]

# Consolidar com coalesce: usa o primeiro valor não-nulo entre as variantes
from pyspark.sql.functions import coalesce, col

df_gold = df_gold.withColumn(
    "bairro_consolidado",
    coalesce(*[col(c) for c in bairro_cols])
)
```

Este padrão garante que:
1. Se o nome do campo mudar entre execuções, o pivot ainda funciona.
2. Se houver múltiplas variantes do mesmo campo (de catálogos diferentes), o `coalesce` usa o primeiro não-nulo.
3. Se nenhuma variante chegar (campo removido da fonte), a coluna fica nula sem quebrar o notebook.

Para campos de formulário com identificador numérico no `col` (ex.: `campo_formulario_00342`): use o padrão de regex contra o sufixo semântico que você espera, não contra o código numérico.

---

## Armadilhas conhecidas

Estas são as 4 lições do postmortem de obras Santos (julho/2026). Qualquer nova fonte EAV deve considerar todas:

1. **Campo órfão quebra silenciosamente a lista inteira.** Um único `col` inválido no payload pode fazer a API descartar todos os outros catálogos da requisição sem retornar erro HTTP. Se a resposta parece um resumo agregado em vez de dados detalhados, suspeite disso primeiro — antes de investigar encoding, configuração de relatório ou campo de sequência.

2. **O nome do campo EAV não é determinístico.** A mesma execução local e o pipeline do Fabric podem retornar o mesmo dado com nomes diferentes (`tit` vs. `col`). Nunca assuma o nome pelo payload; sempre confirme consultando a Silver.

3. **Testar fora do Fabric é obrigatório em bugs de payload.** Iterar direto no pipeline gasta ciclos desnecessários. Token do navegador + request local é o caminho mais rápido para isolar a causa.

4. **Olhar só o primeiro item da resposta da API pode enganar.** O endpoint retorna um item por catálogo enviado. Se você testar com 1 catálogo e funcionar, não significa que o payload completo (com dezenas de catálogos) vai funcionar — um dos outros catálogos pode ter um campo órfão.

---

## Referências

- [decisoes/2026-07-15-bug-payload-api-santos-obras.md](../decisoes/2026-07-15-bug-payload-api-santos-obras.md) — postmortem completo com investigação, alternativas descartadas e métricas de resultado
- [engenharia-dados/catalogo-schema-lakehouse-acto.md](catalogo-schema-lakehouse-acto.md) — schema completo do módulo EAV e regra crítica de nomenclatura `col` vs `tit`
- [engenharia-dados/problemas-qualidade-dados-obras-santos.md](problemas-qualidade-dados-obras-santos.md) — divergências de design entre Gold legado e módulo novo para a fonte obras Santos
