---
tags: [produto, datahub, basedosdados, terceirizacao, estrategia]
criado: 2026-07-03
status: proposta
---

# 04 · Estratégia de Terceirização — Base dos Dados

⬅️ [[03_arquitetura_alvo]] · Próximo: [[05_roadmap_fases]]

> [!tip] Recomendação
> **Sim, mas como estratégia híbrida.** A Base dos Dados (BD) entra como acelerador e fornecedor especializado para bases públicas nacionais — **parceira de supply chain, não substituta da engenharia da Eicon**. Mantemos ingestão própria para dados sensíveis, fontes municipais, diferenciais competitivos e produtos críticos sem SLA robusto. O caminho é **terceirizar → aprender → internalizar**.

## 1. Por que terceirizar agora

- **Time-to-market:** a PoC RAIS trouxe 19 anos de série (2006–2024, ~421 mil registros agregados, 15 municípios) com **uma query SQL** — contra semanas de engenharia FTP + parser (o caminho alternativo existe em `nb_append_rais_ftp.ipynb` e evidencia o custo).
- **Menos engenharia repetitiva:** elimina parsers `.DBC` do DATASUS, schemas instáveis do INEP, monitoramento de portais públicos, harmonização de chaves.
- **Padronização nacional pronta:** `id_municipio`, `sigla_uf`, `ano` normalizados; diretórios CNAE/CBO/escolas.
- **Libera o time para o produto:** Fabric, semantic models, painéis, onboarding — onde está o diferencial.

### Limites (o que a terceirização NÃO resolve)
Dependência operacional (atraso da BD vira atraso percebido do hub), SLA incerto (BD é ONG), custo BigQuery variável, menor controle de schema, risco de licenciamento comercial, debug mais longo (origem → BD → BigQuery → Fabric → produto). **Terceirizar engenharia não elimina responsabilidade perante a prefeitura.**

### Planos BD
| Plano | Preço | O que dá |
|---|---|---|
| Grátis | R$0 | Tabelas tratadas, SQL/Python/R, download 100 MB |
| **Pro** | R$37/mês (R$444/ano) | Dezenas de tabelas auto-atualizadas, download 1 GB, notificações — *ponto de entrada* |
| **Orgs** | Sob consulta | 10+ acessos Pro, suporte prioritário, infra segmentada — *alvo para contrato Eicon* |

## 2. Matriz de decisão por tipo de base

| Tipo | Estratégia | Exemplos |
|---|---|---|
| 🟢 Público nacional commodity | **Consumir da BD por padrão** | IBGE, CAGED, TSE, diretórios, frota, RAIS |
| 🔵 Público nacional crítico p/ produto pago | **Começar via BD + exigir SLA ou construir fallback gradual** | CNES/DATASUS, Censo Escolar, SICONFI/FINBRA, benefícios sociais |
| 🟡 Fonte estadual/local variável | **Avaliar caso a caso** (cobertura pode não ser nacional) | SSP-SP, Infosiga, portais estaduais |
| 🟣 Municipal / sistemas internos | **Engenharia própria Eicon** (é o diferencial; LGPD) | Acto, CadÚnico da prefeitura, planilhas operacionais |
| 🔴 Sensível/sigiloso | **Não terceirizar** — lakehouse municipal controlado | Dados pessoais identificados, prontuários, atendimento social |

> [!danger] Regra de controle
> Nenhuma base externa vira dependência crítica sem: dono interno, teste de frescor, teste de schema, política de fallback e clareza de licença. Registrar tudo em `config.fontes_externas` ([[03_arquitetura_alvo]] §4).

## 3. Padrão técnico já validado (PoC RAIS)

Fluxo em duas etapas, replicável para qualquer base BD:

1. **Validação local** (`nb_teste_rais_bigquery_local.ipynb`): pandas puro; testar conexão com query pequena (LIMIT 10) antes da completa; atenção — `id_municipio` é STRING no BigQuery; spot-checks de volumetria.
2. **Ingestão Fabric** (`nb_ingest_rais_bd.ipynb`):
   - Autenticação: service account JSON em `Files/` → `bigquery.Client.from_service_account_json(...)` (projeto GCP próprio `bd2024-*`; **mover segredo para Key Vault**);
   - Query com **pushdown de filtros** (colunas explícitas + `WHERE sigla_uf='SP' AND ano>=...`) — o custo de scan fica no BigQuery, só o agregado trafega;
   - Agregação pré-gravação → `write.format("delta")` Bronze.
3. **Gold** (`nb_gold_rais.ipynb`): recorte por município + enriquecimento com diretórios canônicos da própria BD (CNAE) + export por painel.

Escala: **Bronze = snapshot multi-município (ingere 1×) → Silver municipalizada → Gold produto**. Mesmo desenho já aprovado no [[spec_drive_datasus_censo_ideb]] para CNES → SIM/SINASC/SIH e Censo Escolar → IDEB.

## 4. O que negociar com a BD (plano Orgs)

1. **SLA e atualização** — frequência por base (CNES mensal, SIH ~2 meses de defasagem, IDEB bienal), janela máxima de atraso, canal de incidente, status page.
2. **Contrato de schema** — versionamento, aviso prévio de breaking changes, changelog, compatibilidade retroativa.
3. **Uso comercial** — direito de uso em produto pago, redistribuição em PBI/Excel/API/CSV, atribuição, limites por fonte, cópias no OneLake.
4. **Acesso técnico** — projeto BigQuery dedicado, service account, quotas/billing previsíveis, export Parquet/replicação incremental.
5. **Roadmap conjunto** — priorização de bases municipais (Saúde, Educação, Finanças, Assistência); grupos CNES ainda não replicados no BigQuery.
6. **Suporte especializado** — ponto focal técnico, tempo de resposta, apoio em dicionários/auditorias.

> [!note] Ponto comercial-chave
> Não estamos comprando acesso a tabelas — estamos comprando **redução de risco operacional e aceleração de roadmap**. O contrato precisa refletir manutenção, previsibilidade e canal de resolução.

### Piloto proposto
3 domínios de alto valor e baixa sensibilidade, cada um testando um perfil:
- **SICONFI/FINBRA** — fiscal, anual, baixo volume → teste de commodity puro;
- **CNES** — mensal, pré-requisito das bases de saúde → teste de cadência/SLA;
- **Censo Escolar/IDEB** — já mapeado, aguardando validação do Yuri → teste do fluxo completo até painel.

Critérios de sucesso: tempo de implantação no Fabric, frescor, estabilidade de schema, custo BigQuery, qualidade da documentação, esforço até Gold/semantic model.

## 5. Fase de aprendizado → internalização

**Estudar do stack da BD enquanto consumimos:**
- **dbt** — modelos públicos (`basedosdados/queries-*`): staging → produção, materialização;
- **Testes** — unicidade, not-null, relação com diretórios, recência → importar o conceito para o Fabric (hoje só `assert len(df) > 0`);
- **Diretórios canônicos** (`br_bd_diretorios_brasil`) — internalizar como Delta Tables;
- **Fluxo de onboarding de bases** — a metodologia de padronização é o "manual" para reproduzir qualquer fonte internamente.

**Gatilhos para internalizar uma base:**
(a) atraso recorrente acima da tolerância do indicador contratado; (b) coluna/granularidade que a BD não replica; (c) custo de scan superando pipeline próprio; (d) exigência contratual/compliance sobre cadeia de custódia.

Quando disparar: o fallback documentado (FTP DATASUS/PySUS, downloads INEP) vira pipeline titular, **mantendo o schema da BD como contrato interno** — a troca fica transparente para Silver/Gold/Power BI.

---
Fontes: `estrategia_terceirizacao_dados_basedosdados.html`, `analise_basedosdados_lakehouse_eicon.html`, notebooks `Prototipo_santos_dados_publicos/rais/`, [[spec_drive_datasus_censo_ideb]], `MAPEAMENTO_FONTES_COMPLETO.md`, print de preços basedosdados.org.
