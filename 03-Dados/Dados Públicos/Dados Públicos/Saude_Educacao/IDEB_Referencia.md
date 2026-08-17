---
title: "IDEB — Índice de Desenvolvimento da Educação Básica"
tags:
  - tipo/referencia-tecnica
  - tema/dados-publicos
  - tema/educacao
status: ativo
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/Censo_Escolar_Referencia]]"
---

# IDEB — Índice de Desenvolvimento da Educação Básica

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

## 1. Fontes candidatas

| Rota | Origem | Prós | Contras |
|---|---|---|---|
| **BigQuery (basedosdados.org)** ⭐ recomendada | Dataset `basedosdados.br_inep_ideb` — tabelas por nível de agregação (escola, município, UF, Brasil) | Mesma infraestrutura GCP já usada (RAIS). Evita baixar/parsear planilhas XLSX manualmente publicadas pelo INEP a cada edição. | Volume de dados pequeno (poucas linhas por edição/município) — o ganho de usar BigQuery aqui é mais sobre padronização do que performance. |
| Planilhas oficiais INEP (`ideb.inep.gov.br` / `download.inep.gov.br`) | Arquivos XLSX/CSV publicados por edição, sem API REST formal | Fonte primária, disponível assim que o INEP divulga o resultado. | Sem API — só download direto de planilha; formato/layout muda entre edições; exige parsing manual de XLSX (fora do padrão de ingestão via API já usado no projeto). |

## 2. Acesso

- **BigQuery:** `basedosdados.br_inep_ideb.*` — combina dados de fluxo escolar (aprovação, vindos do Censo Escolar) com desempenho em avaliações (Saeb/Prova Brasil), agregados por escola, rede/município e UF.
- **INEP direto:** portal `https://ideb.inep.gov.br/` (Power BI público) e planilhas em `download.inep.gov.br` — sem API.

## 3. Periodicidade na fonte

- **Bienal** — divulgado em anos ímpares (ex.: 2019, 2021, 2023, 2025...), não anual. Isso é uma diferença crítica em relação às outras 5 fontes deste levantamento (mensais/anuais).

## 4. Schema e granularidade

- Granularidade: **escola**, **rede/município**, **UF** e **Brasil** — múltiplos níveis de agregação na mesma tabela/edição.
- Chave de junção com `gold.dim_municipio`: código do município (IBGE).
- Campos-chave: nota IDEB observada, meta projetada, taxa de aprovação, nota Saeb/Prova Brasil, etapa de ensino (anos iniciais/finais do fundamental, ensino médio).

## 5. Volumetria estimada

- Muito baixa — dezenas de linhas por município/edição (uma linha por escola/etapa a cada 2 anos). Não é um problema de volume, e sim de **cadência de atualização** (esperar a próxima edição bienal).

## 6. Estratégia de monitoramento/detecção de atualização recomendada

- Como a cadência é bienal e não há endpoint de metadados, o monitoramento deve ser **calendarizado** (checagem manual/agendada a cada divulgação de nova edição, tipicamente no ano seguinte ao ano de referência) em vez de polling automático por hash/rowcount.
- Registrar no Gold a "edição" (ano de referência) do IDEB usado, para deixar explícito quando o indicador está desatualizado em relação à edição mais recente disponível.

## 7. Riscos/dependências

- **Depende do Censo Escolar já carregado** (ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/Censo_Escolar_Referencia|Censo_Escolar_Referencia]]) — o IDEB usa taxas de aprovação vindas do Censo como um dos dois componentes do índice.
- Por ser bienal, painéis que combinam IDEB com indicadores anuais (ex.: Censo Escolar) devem tratar explicitamente os "gaps" de ano sem dado — não interpolar silenciosamente.

---

**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/IDEB_Referencia.md`
