---
tags: [produto, datahub, roadmap]
criado: 2026-07-03
status: proposta
---

# 05 · Roadmap por Fases

⬅️ [[04_estrategia_terceirizacao_bd]] · Índice: [[00_INDEX_PRODUTO]]

> [!info] Lógica do roadmap
> Primeiro **estancar riscos e organizar a casa** (sem isso não há produto vendável), em paralelo **destravar a terceirização** (ganha tempo), depois **pilotar produtos com contrato completo**, e só então **industrializar** o onboarding de municípios. A internalização da engenharia não tem data — tem **gatilhos** ([[04_estrategia_terceirizacao_bd]] §5).

## Fase 0 — Estancar e organizar (0–30 dias)

**Segurança e dívida crítica**
- [ ] Remover segredos de notebooks/repos e rotacionar credenciais expostas (tokens Acto, service account GCP) → Key Vault
- [ ] CI mínimo: gitleaks + validação de notebooks
- [ ] Resolver R5 (retry 401 em obras) e R9 (código IBGE hardcoded) — dívidas que consomem o time
- [ ] Migrar semantic models para **Service Principal** (piloto: 1 modelo, depois demais)

**Organização do Fabric**
- [ ] Definir e aplicar plano de descomissionamento do legado (tabela a tabela: migrar/dropar/congelar)
- [ ] Padronizar nomenclatura (`gold.{municipio}_{dominio}_*`) — regra já em memória/CLAUDE.md
- [ ] Template de **contrato de produto de dados** definido

**Terceirização**
- [ ] Assinar BD Pro (R$37/mês) para operação imediata
- [ ] Agendar conversa estruturada com a BD (pauta do [[04_estrategia_terceirizacao_bd]] §4) visando plano Orgs

## Fase 1 — Fundações de plataforma (30–60 dias)

- [ ] Criar `config.tenants` e `config.fontes_externas` (Delta) e migrar hardcodes/Excel auxiliares (mata R1/R9)
- [ ] Implantar checks de qualidade mínimos por produto (grão, chaves, freshness, volume) + tabela `monitor.execucoes`
- [ ] Internalizar **diretórios canônicos** (município, UF, tempo, CNAE, CBO) como Delta Tables
- [ ] Ambientes dev/prod: cobrar os 7 workspaces solicitados; fallback com sufixo `_dev`
- [ ] Fechar decisão **Direct Lake × Import** do semantic model unificado de dados públicos
- [ ] Destravar fase 2 DATASUS/INEP com Yuri (acesso GCP + validação)

## Fase 2 — Piloto de produto (60–90 dias)

- [ ] Pilotar **SICONFI/FINBRA, CNES e Censo Escolar/IDEB** via BD como produtos com contrato completo (metadados, testes, catálogo, painel)
- [ ] Publicar catálogo inicial + status de qualidade por produto
- [ ] Semantic model unificado de dados públicos com `dim_municipio`/`dim_calendario` compartilhadas
- [ ] Avaliar resultado do piloto contra os critérios de sucesso ([[04_estrategia_terceirizacao_bd]] §4) → decisão de contrato Orgs
- [ ] Empacotamento comercial: definir o que é insumo comum × fonte premium ([[01_visao_produto_modelo_negocio]] §4)

## Fase 3 — Industrialização (90+ dias)

- [ ] **Kit de onboarding de município**: provisionamento por configuração (workspace, shortcuts, payloads, pipelines, semantic model, painéis-template) — validar com Aparecida de Goiânia ou SJRP
- [ ] Shortcuts OneLake para dados públicos compartilhados entre workspaces
- [ ] Deployment pipelines Fabric (dev → prod com validação)
- [ ] Monitorar gatilhos de internalização por base; quando disparar, promover o fallback a titular mantendo o schema BD como contrato
- [ ] Camada de IA/serviços analíticos **somente sobre produtos documentados** (catálogo primeiro)

## Dependências externas e riscos do roadmap

| Dependência | Impacto se atrasar |
|---|---|
| Yuri (GCP, DATASUS, CAGED) | Fase 1–2 de dados públicos trava |
| Cliente/InMov (7 workspaces dev/prod) | ALM fica improvisado |
| Jorge (reconexão PBI Santos) | Migração legado não conclui |
| Negociação BD (Orgs) | Piloto roda no plano Pro, sem SLA |
| Kelly/SEMAM (escopo obras) | Frente Acto segue consumindo time |

> [!warning] Anti-padrão a evitar
> Não começar a Fase 2 (pilotos) sem a Fase 0 concluída — pilotar produto novo sobre credenciais expostas e sem monitoramento repete o padrão que gerou o R5 (60 dias de pipeline quebrado sem detecção).
