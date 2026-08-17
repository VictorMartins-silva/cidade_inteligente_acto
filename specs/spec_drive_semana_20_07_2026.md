---
title: "Spec Semanal — 20/07/2026 a 25/07/2026"
week: "W30/2026"
periodo: "2026-07-20 a 2026-07-25"
owner: "Victor Silva"
projeto: "Multi-frente — Paridade Gold Obras (Santos) · Geo Osasco (SSP Criminais) · Visita Domiciliar (NPCAD Osasco)"
status: "ativo"
origem: "continuidade W29 — reconciliação de 3 frentes que divergiram do plano original"
created: 2026-07-21
updated: 2026-07-24
revisao: "2026-07-21 — spec criado na terça (não na segunda); reconcilia contra o trabalho real de 14-18/07, que divergiu do plano de [[spec_drive_semana_13_07_2026]]. 2026-07-24 — atualizado com o desvio de 24/07 (bug suspeito SEGOV + achado de sub-formulários no Acto Gestão), que também não seguiu o plano diário original."
tags:
  - spec
  - semanal
  - obras
  - santos
  - osasco
  - geo
  - eav
  - power-bi
  - fabric
---

# Spec da Semana — 20/07/2026

## 1. Objetivo da semana

Fechar o ciclo de paridade Gold Obras Santos (comunicação formal a Kelly/Jorge), retomar o Geo Osasco que ficou parado desde 13/07, e destravar o painel de Visita Domiciliar Osasco (pipeline pronto, painel não iniciado).

> [!important] A semana passada não seguiu o plano original
> [[spec_drive_semana_13_07_2026]] planejava fechar o **Geo Osasco** (homologação, performance, runbook). Na prática, entre 14-17/07 o time foi puxado para uma investigação crítica não planejada em **Obras Santos**: o payload da fonte `santos_obras` estava quebrado desde a origem (Bronze), o que invalidava qualquer comparação de paridade de Gold feita até então. Essa investigação (ver [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API]] e Bloco 6 de [[spec_drive_paridade_gold_obras]]) consumiu a maior parte da semana e teve prioridade correta — sem ela, a paridade de Gold Obras seria uma comparação contra dado incompleto. O Geo Osasco não avançou nenhum item do checklist de 13/07. O painel de Visita Domiciliar Osasco teve o pipeline (Bronze→Silver→Gold) concluído em paralelo (14/07), mas o painel em si ainda não começou.

## 2. Fechamento da semana anterior (W29, 13-18/07) — confirmação

### 2.1 Confirmado como concluído (fora do plano original de W29)

**Frente Obras Santos — Paridade Gold + bug de origem (não estava no plano de 13/07, virou a prioridade real da semana):**
- Bug 1 (payload com 342 campos órfãos travando a API `VisualizarDadosIntermediarios` no 1º catálogo) — corrigido 15/07.
- Bug 2 (nomenclatura EAV inconsistente entre execuções — `tit` vs `col`) — corrigido 15-16/07, trocando filtro por nome exato por `rlike`.
- Blocos 1-3 de [[spec_drive_paridade_gold_obras]] (paridade `tempo_etapa`, `acompanhamento`, `seont`) revalidados sobre o Bronze corrigido, contagens confirmadas como superset limpo do legado (PDR e Acompanhamento).
- Bloco 6.1/6.2: fix do filtro `os_alem_seont` (categorias `Usuário`/`Sistema` deixaram de ser tratadas como ruído) — gap SEONT "só no legado" caiu de 126 → 71 OS (17/07).

**Frente Visita Domiciliar Osasco (NPCAD) — nova, não estava no plano de 13/07:**
- Payload validado contra API real (166 OS, todos os campos mapeados).
- Bronze → Silver → Gold rodados no Fabric (`gold.osasco_visita_domiciliar`, 166 linhas, 28/29 campos EAV pivotados) — concluído 14/07.
- Achado técnico documentado: para campos EAV com `codFormularioCampo`, o nome do campo em `fato_campos` vem do `col` (minúsculo), não do `tit` — regra geral registrada em `EAV_BRONZE_INVENTARIO.md` para qualquer fonte EAV nova.

### 2.2 Itens do plano original de W29 (Geo Osasco) — nenhum avançou

Todo o checklist da seção 7 de [[spec_drive_semana_13_07_2026]] segue **exatamente como estava em 13/07** — nenhuma evidência de trabalho nos arquivos do vault entre 14-20/07 nesta frente:
- [ ] Confirmar `dentro_mapa = 1` em visuais além do mapa principal (tabela/cartão)
- [ ] Confirmar filtro de bairro no painel
- [ ] Reexecutar `nb_analise_comparativa_gold_geo.ipynb` local com `dentro_mapa = 1`
- [ ] Registrar teste de performance
- [ ] Registrar aceite formal do stakeholder (ata, não só aviso via Teams)
- [ ] Atualizar runbook de operação diária/semanal
- [ ] Sanear NaN em `silver.ssp_criminais` (destrava SQL endpoint, erro 24762)
- [ ] Avaliar migração de `bairros_osasco.json` para Delta Table

### 2.3 Itens genuinamente não concluídos da frente Obras (ver [[spec_drive_paridade_gold_obras]] Blocos 5-6 para detalhe)

- **Bloco 4.2** — 1ª execução pós-refactor do `RefreshSqlEndpoint` com `recreateTables: true` (nova tabela `santos_obras_seont_os` + schemas alterados) ainda não feita.
- **Bloco 5.2** — comparação linha-a-linha ampla (`status`/`etapa_atual`/`aux_setor_responsavel`/`zona` ≥ 99% iguais) não refeita desde o fix do Bronze; só validações pontuais via `08_validacao_geral_obras`.
- **Bloco 5.5/6.3** — gap SEONT não fechado: dos 71 OS "só no legado", 47 são exclusão legítima (confirmado), mas **24 têm decisão de negócio pendente** — OS cuja etapa SEONT fechou de vez e sobrou só uma etapa `Usuário`/`Sistema` (ex.: aguardando resposta do munícipe). Pergunta em aberto: isso conta como "ainda em SEONT" (pausado) ou é saída legítima? Precisa decisão de negócio antes de codar mais um fix — pode exigir mudar o critério de **inclusão**, não só exclusão, do filtro.
- **Bloco 5.6** — comunicação formal a Kelly/Jorge **bloqueada** até 5.2 e 5.5 fecharem.
- **Bloco 6.4** — 33 variantes de `servico` não normalizadas (ex.: `05-DEMOLIÇÃO` vs `DEMOLIÇÃO`) — provável causa (ou uma das causas) das reclamações originais de "informações sumidas". Sem fix aplicado; decisão pendente entre normalizar no Gold ou investigar se são categorias de negócio distintas.
- **Postmortem, seção 6** — gap de `executor_responsavel` no SEONT (50.9% vs ~99% do legado) — investigado, causa é upstream (`silver.fato_etapas`/endpoint `ObterTempoEtapaRelatorio`), não bloqueante, mas sem dono definido para investigar a fundo.

### 2.4 Itens não concluídos da frente Visita Domiciliar (ver [[spec_painel_osasco_visita_domiciliar]])

- Painel Power BI / nativo Acto — não iniciado (🔴).
- 3 pendências de validação com o PMO: conteúdo da aba MONITORAMENTO (sem definição no docx original), confirmação formal de `secretaria: SAS` / `unidade_organizacional: NPCAD`, e o campo `CadÚnico – Cod.Familiar` sempre vazio (gap de processo do NPCAD, não bug).
- Refresh do SQL Endpoint + modelo PBI ainda não adicionado em `pl_ingest_acto`.

## 3. Backlog da semana de 20/07

### Prioridade P0 — fechar a paridade Obras (estava quase pronta, falta o fechamento formal)
- [x] Reexecutar `08_validacao_geral_obras.ipynb` com dados ao vivo — feito 21/07, pré-reunião Kelly (ver [[spec_drive_paridade_gold_obras]] Bloco 7). PDR/Acompanhamento confirmados 0 gap; SEONT com gap parcial (80 OS, majoritariamente explicado, 9 OS pontuais não auditadas linha a linha)
- [~] Comparação linha-a-linha completa (Bloco 5.2) — mencionada como executada em 23/07, mas **resultado não está registrado**; confirmar/re-rodar e colar os percentuais em [[spec_drive_paridade_gold_obras]] (5.2.a) antes de considerar fechado
- [x] Decisão de negócio do item 6.3 (OS com SEONT fechado + só `Usuário`/`Sistema` remanescente) — **decidido 23/07/2026: Opção B** (saída legítima do SEONT, gap de 24 documentado como divergência aceita, não bug), registrado em [[spec_drive_paridade_gold_obras]] (Bloco 6.3)
- [ ] Executar `RefreshSqlEndpoint` com `recreateTables: true` (Bloco 4.2) — 1ª execução pós-refactor, reverter para `false` depois
- [x] Reunião com Kelly hoje (21/07) sobre os painéis PBI de Obras — realizada (22m54s, com João). Painel de Chefia confirmado OK por João (66 no BI vs 67 na planilha manual — diferença de 1 OS explicada pelo horário de execução do refresh às 4h). Números do Bloco 7 usados como base. Resultado: nova frente de trabalho nos **painéis internos de Obras** (ver seção 3.1 abaixo) — comunicação formal a Kelly/Jorge (Bloco 5.6) segue condicionada aos itens de paridade acima, não aos painéis internos

### Prioridade P0.1 — Painéis internos de Obras (reunião 21/07 com Kelly e João)

> Reunião "Painéis Obras" (21/07, 22m54s) revisou o estado dos 5 painéis internos: Chefia (OK), Analistas (prioridade máxima — "o mais bagunçado"), PDR (nova visão gerencial pedida), Pareceres (bug de classificação "reforma") e Pavimentos (bloqueado por dado de API). Detalhamento completo por painel arquivado em [[spec_painel_seont_analista_tecnico]] (seção "Reunião 21/07").

**Painel de Analistas (SEONT) — prioridade máxima, Victor começa por aqui:**
- [ ] Trocar filtro principal de "Ano/Período" para **Analista** logo de cara (mesmo padrão do painel de Chefia)
- [ ] Adicionar tabela de OS do analista filtrado na Pág. 1 ou 2 (Nº OS, executor responsável, setor, etapa) — é o item mais sentido pela falta ("falta a lista das OS")
- [ ] Adicionar card/indicador de **tempo médio de atuação por etapa**, por analista
- [ ] Adicionar visão de **quais serviços o analista está executando/atuando**
- [ ] Corrigir gráfico "Total de OS por Executor" que caiu desorganizado na Pág. 2 (base detalhada) — reorganizar layout geral do painel, que está "um caos" desde que quebrou e foi remontado por outra pessoa
- [ ] Avisar Kelly/João por mensagem conforme for avançando (não esperar terminar tudo para dar retorno)
- Meta combinada: Victor tenta adiantar até segunda-feira 27/07

**Painel PDR — nova visão gerencial (sem pressa, pode vir depois do painel de Analistas):**
- [ ] Criar nova página/aba com um card por setor responsável (ex.: ACKT, C1, SEFIS, SEONT/CEOB) mostrando **apenas a média de duração em dias** (o indicador central do PDR) — sem detalhamento adicional por enquanto, só o resultado; filtro por mês/ano deve continuar valendo
- [ ] (Futuro, não é P0 desta semana) gráfico de variação mensal ao clicar no card do setor

**Painel de Pareceres — bug de classificação "reforma":**
- [ ] Workaround imediato: excluir/filtrar o serviço "reforma" do painel de Pareceres — etapa genérica `PARECER TÉCNICO DIVERSOS` está sendo classificada como parecer e inflando a contagem (12 OS aparecendo vs. ~4 reais na semana testada)
- [ ] Aguardar Kelly enviar nova lista/parâmetro de classificação — a lógica dela na Grid ainda não consegue expor o campo adicional necessário para diferenciar "reforma" de "parecer" de verdade (dependência externa, sem previsão)
- [x] Confirmado ao vivo na própria reunião (21/07): removendo "reforma" da tabela, a contagem bate com o relatório do João (~4 pareceres na semana)

**Painel de Pavimentos (relatório do subformulário) — segue bloqueado, possível caminho de destravamento encontrado 24/07:**
- [ ] Sem ação possível ainda — API retorna valor incorreto/aleatório do campo do subformulário mesmo com o dado presente na Grid; mesmo problema do lado da Kelly. Aguardar correção externa antes de retomar (relatório já está montado, só falta o dado da API vir certo)
- [x] Achado 24/07 (reunião técnica): Acto Gestão agora permite incluir sub-formulários aos relatórios — abre caminho para configurar um relatório com sub-formulário que capture o payload corretamente. Mesma limitação citada também para o painel de Pavimentos de **Mauá**, não só Santos
- [ ] Configurar um relatório de teste com sub-formulário e validar se o payload capturado resolve o valor incorreto/aleatório do campo (pendente, não testado ainda)

### Prioridade P1 — retomar Geo Osasco parado + destravar Visita Domiciliar
- [ ] Confirmar `dentro_mapa = 1` em todos os visuais + filtro de bairro (itens já feitos podem estar obsoletos, reconferir)
- [ ] Reexecutar `nb_analise_comparativa_gold_geo.ipynb` local com `dentro_mapa = 1`
- [ ] Registrar aceite formal do stakeholder do Geo Osasco (ata, não só aviso via Teams) + baseline de performance
- [ ] Validar com o PMO as 3 pendências de Visita Domiciliar (MONITORAMENTO, secretaria/unidade, CadÚnico Cod.Familiar)
- [ ] Adicionar refresh de Visita Domiciliar ao `pl_ingest_acto`
- [x] ~~Iniciar construção do painel de Visita Domiciliar~~ — **construção concluída 21/07** (Visão Geral + Base Detalhada); publicação e homologação com o PMO seguem pendentes (ver [[spec_painel_osasco_visita_domiciliar]])
- [ ] Decidir normalização de `servico` em Obras (Bloco 6.4) — 33 variantes vs ~29 catálogos esperados

### Prioridade P1.1 — Carta de Serviços: investigar duplicação de OS na ingestão (nova, 21/07)
- [ ] Mapear o fluxo de ingestão da Carta de Serviços hoje ativo no Fabric (Bronze → Silver → `gold_carta_servicos`) e identificar em qual etapa a duplicação de OS ocorre
- [ ] Confirmar se a causa é overwrite/append sem critério de deduplicação — ver regra recém-aprovada em [[Documentação_Fabric/acervo/decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita|decisão 2026-07-21 SCD2 Carta/Credenciais]]: *"append apenas com critério de deduplicação e idempotência definido"*
- [ ] Checar se o join de vigência SCD2 (`dt_abertura` entre `dt_inicio_vigencia`/`dt_fim_vigencia`) está gerando fan-out quando há sobreposição de vigências — padrão de bug já visto em [[spec_painel_seont_analista_tecnico]] (fan-out silencioso no join Acompanhamento)
- [ ] Aplicar fix de deduplicação (grain 1 linha por OS por vigência) e reexecutar o notebook de Carta de Serviços
- [ ] Validar rowcount antes/depois — confirmar que o total de OS bate com a fonte (`exportar_4.csv`, 693 registros, conforme convenção do CLAUDE.md do módulo)

### Prioridade P1.2 — Novos pedidos de painel Osasco (nova, 23/07)
- [ ] Painel de Ocorrências PMS: adicionar tooltip nos pontos que caem fora do contorno de Osasco, informando os valores (mesmo domínio de "dentro do mapa" já tratado em [[project_ssp_geo_excluidos]] para SSP Criminais — reaproveitar critério de contorno/geojson se aplicável)
- [x] Painel de Atendimento CRAS: plano de 3 fases + protótipo + Fase 1 implementada no PBI (geometria corrigida, gradiente sequencial, filtros confirmados reativos, `dim_bairro_cras` + relações corrigidas) — tudo em 23/07. Achado extra: `indicadores_bairros` do painel vem de CSV local quebrado no OneDrive do Yuri (R1 novo, ver [[spec_painel_mapa_cras_osasco]] e [[project_risco_csv_local_indicadores_bairros_osasco]]). **Falta**: página de tooltip customizada

### Prioridade P1.3 — Bug suspeito de exclusão de OS não refletida na API (SEGOV Santos, nova, 24/07)
- [x] Bug reportado por André Ygor Bulata dos Santos (SEGOV, Santos) via Teams, 24/07 14:29 — painel de BI da SEGOV mostrando a OS 987194 (de teste), enviada ao time DEV para ser apagada mas que continua aparecendo no relatório
- [x] Hipótese levantada e considerada plausível por André (14:31): exclusão de OS no Acto não remove do banco, apenas inativa o status; a API do Acto Gestão retorna as OS independente do status, então a exclusão não se reflete na ingestão/BI
- [x] Ação imediata: OS 987194 retirada especificamente do relatório
- [ ] Confirmar causa raiz com André/Fernando (pendente resposta)
- [ ] Checar uma a uma as outras 6 OS suspeitas do mesmo padrão: 987256, 987643, 987602, 987701, 987784 (serviços "Instalação/manutenção/higienização", "Manifestação de ouvidoria", "Tapa-buraco", solicitadas 25-26/06/2026)
- [ ] Se confirmado: avaliar se afeta outros painéis que consomem a API do Acto Gestão sem filtrar por status de exclusão (não só SEGOV Santos) e se justifica postmortem próprio (padrão parecido com o bug de payload órfão de Obras Santos, ver [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API]], mas com causa raiz diferente)

### Prioridade P2 — dívida técnica de fundo (não bloqueia entregas desta semana)
- [ ] Sanear NaN em `silver.ssp_criminais` (destrava SQL endpoint, erro 24762)
- [ ] Migrar `bairros_osasco.json` de arquivo plano para Delta Table
- [ ] Investigar gap de `executor_responsavel` SEONT (50.9% vs ~99%) — não bloqueante, sem dono definido
- [ ] Escrever runbook de operação diária/semanal do Geo Osasco
- [ ] Continuar domínios P2-P7 do Geo Osasco (Flagrantes, Prisões, Entorpecentes, Veículos, Armas) — arquitetura aprovada, nenhum além de VCM foi ao Fabric

### Prioridade P2.1 — Acervo institucional: comparação e envio incremental ao lakehouse-inmov (21/07, ampliado 22/07)
- [x] Comparação item a item concluída (21/07): `Documentação_Fabric/acervo/migracao/PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md` — cruza o acervo pessoal contra o acervo oficial da equipe (`lakehouse-inmov`) e mapeia 10 itens sem equivalente ou com gap real (8 contribuições de conhecimento + 1 decisão + 1 alerta de PII), com destino sugerido e pendências de curadoria por item; itens redundantes já descartados na própria proposta (seção "Itens descartados")
- [ ] Yuri revisar a proposta (conteúdo, destino sugerido, pendências de cada item)
- [ ] Itens aprovados por Yuri: abrir as Issues correspondentes no `lakehouse-inmov` (`contribuir-conhecimento` ou `registrar-decisao`), copiando o corpo já pronto de cada seção da proposta
- [ ] Curadoria (coordenador do `lakehouse-inmov`) validar editorial/factualmente e fazer o commit/PR na `main`
- [ ] Marcar os itens publicados como concluídos na proposta (checklist a adicionar na próxima revisão do arquivo)
- [x] Segunda leva concluída (22/07): varredura dos ~110 arquivos do vault Obsidian ainda não triados (`INVENTARIO_BRUTO.md`/`MATRIZ_CLASSIFICACAO.md` só cobriam 11 notas) — encontrados ~20 candidatos estruturais novos, destaque para a série `Produto_DataHub/01-05` (visão de produto, matriz de risco R1-R9, arquitetura alvo), `Acto/SCHEMA_LAKEHOUSE_ACTO.md` + inventários EAV, 2 postmortems de alta qualidade (`INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API`, `spec_drive_paridade_gold_obras`) e o conjunto de 7 fichas de fonte `Dados Públicos/Saude_Educacao/*` (DATASUS/INEP)
- [x] Destilação (Passada 3) concluída para os 4 achados de maior valor (22/07): criados `acervo/projetos/projeto-produto-datahub.md`, `acervo/engenharia-dados/catalogo-schema-lakehouse-acto.md`, `acervo/decisoes/2026-07-15-bug-payload-api-santos-obras.md`, `acervo/fontes/datasus-inep-saude-educacao.md` — READMEs das pastas atualizados e novo `acervo/GUIA_ACERVO.md` criado como índice completo de todo o acervo (o postmortem de paridade Gold Obras já estava coberto por `problemas-qualidade-dados-obras-santos.md` existente, não duplicado)
- [ ] **Pendente:** revisar os 4 arquivos destilados com quem detém o contexto de cada fonte original (Produto DataHub, schema Acto, bug payload, DATASUS/INEP) antes de virarem uma nova proposta de envio ao Yuri (adendo à `PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md` ainda não criado)
- [x] Reunião 23/07 sobre acervo institucional e tecnologias Git realizada — conteúdo/decisões da reunião ainda não detalhados nesta spec; registrar depois se render encaminhamento concreto (ex.: adoção de Git para versionar o acervo/`lakehouse-inmov`)

## 4. Plano diário da semana (20/07 a 25/07)

| Dia | Foco | Entregável objetivo |
|---|---|---|
| Seg 20/07 | *(retomada informal, sem spec formal)* | — |
| Ter 21/07 | Reconciliação da spec + priorização das 3 frentes + reunião Painéis Obras (Kelly/João) | Spec atualizada (este documento) · backlog de painéis internos (Analistas/PDR/Pareceres/Pavimentos) registrado |
| Qua 22/07 | Fechamento Obras P0: comparação 5.2 + decisão de negócio 6.3 | Comparação linha-a-linha refeita · decisão registrada sobre OS "SEONT fechado + Usuário/Sistema" |
| Qui 23/07 | `RefreshSqlEndpoint recreateTables=true` + comunicação Kelly/Jorge | Bloco 4.2 executado · comunicação formal enviada (Bloco 5.6) |
| Sex 24/07 | Geo Osasco: reconferir filtros + comparativo local | `nb_analise_comparativa_gold_geo` rodado com `dentro_mapa=1` · filtros de bairro/visuais reconfirmados |
| Sab 25/07 | Visita Domiciliar: validação PMO + início do painel | Pendências PMO respondidas · esboço do painel (Visão Geral) iniciado |

> [!important] Qui 23/07 divergiu do plano — dia inteiro foi pro mapa CRAS + reunião de acervo, não pra Obras
> O foco planejado (Bloco 4.2 `RefreshSqlEndpoint` + comunicação Kelly/Jorge) **não foi executado** — Obras segue exatamente onde estava desde a manhã (5.2 sem resultado confirmado, 4.2 e 5.6 pendentes). Em vez disso, o dia foi consumido por: (1) implementação completa da Fase 1 e Fase 3 do mapa CRAS no `bi_osasco_rma_cras` (ver [[spec_painel_mapa_cras_osasco]] — geometria corrigida, gradiente sequencial, `dim_bairro_cras`, página de tooltip customizada, achado e resolução do risco R1 do CSV local do Yuri); (2) reunião sobre **acervo institucional e tecnologias Git** (sem spec própria registrada ainda). Dia encerrado às 23/07 com essas duas frentes avançadas e Obras/Geo Osasco/PMS tooltip parados. **Amanhã (24/07) retoma as pendências da semana** — não necessariamente na ordem original do plano diário.

> [!important] Sex 24/07 também divergiu do plano — bug de produção SEGOV, não Geo Osasco
> O foco planejado (P1: reconferir filtros do Geo Osasco + `nb_analise_comparativa_gold_geo` local) **não foi executado** — nenhum avanço registrado nesta frente. O dia foi consumido por um bug de produção reportado pelo cliente: OS de teste (987194) que deveria ter sido excluída no Acto continuava aparecendo no painel da SEGOV (Santos), levantando a hipótese de que exclusão no Acto só inativa o status em vez de remover o registro (ver P1.3 acima). Achado colateral, na mesma reunião técnica do dia: Acto Gestão passou a suportar sub-formulários em relatórios, uma possível via de destravamento para o painel de Pavimentos (Santos e Mauá), ainda não testada. Obras (5.2/4.2/5.6), Geo Osasco e o tooltip do painel PMS seguem parados desde 23/07.

## 5. Critérios de pronto da semana
- Paridade Gold Obras comunicada formalmente a Kelly/Jorge, com gap SEONT resolvido ou decisão de negócio documentada.
- Geo Osasco com aceite formal do stakeholder registrado (ata).
- Visita Domiciliar com pendências de PMO respondidas e painel em construção (não necessariamente publicado).

## 6. Riscos da semana e mitigação

| Risco | Severidade | Mitigação |
|---|---|---|
| Decisão de negócio do item 6.3 não chega a tempo | Alto | Comunicar Kelly/Jorge com o gap parcial documentado (47 confirmados / 24 pendentes) em vez de bloquear indefinidamente |
| Geo Osasco acumula 2ª semana sem avanço | Alto | Bloco P1 desta semana prioriza reconferência rápida antes de qualquer item novo |
| Painel de Visita Domiciliar sem aba MONITORAMENTO definida atrasa entrega completa | Médio | Iniciar Visão Geral + Base Detalhada (já especificadas) sem esperar definição do PMO sobre Monitoramento |
| `RefreshSqlEndpoint recreateTables=true` gerar downtime inesperado no SQL endpoint | Médio | Executar fora do horário de consumo do painel, reverter para `false` logo em seguida |
| Normalização de `servico` (6.4) sem decisão pode mascarar mais reclamações do cliente | Médio | Levar como pauta explícita na comunicação com Kelly/Jorge (P0), não deixar como item solto |
| Bug SEGOV (OS "excluída" ainda aparece) pode não ser caso isolado — se a causa (status inativado, não remoção) for confirmada, pode afetar qualquer painel consumindo a API do Acto sem filtro de status | Alto (se confirmado) | Checar as 6 OS suspeitas adicionais e aguardar confirmação de André/Fernando antes de generalizar; se confirmado, tratar como bug de plataforma, não só de Santos |

## 7. Quadro de execução (checklist)

**Obras (P0):**
- [~] Refazer comparação linha-a-linha Bloco 5.2 — execução mencionada 23/07, resultado ainda não confirmado/registrado
- [x] Decisão de negócio registrada — item 6.3 (23/07, Opção B)
- [ ] `RefreshSqlEndpoint recreateTables=true` executado e revertido
- [ ] Comunicação formal a Kelly/Jorge enviada — depende de confirmar 5.2 primeiro

**Painéis internos de Obras (P0.1, nova — reunião 21/07):**
- [ ] Painel Analistas: filtro por analista + tabela de OS + tempo médio por etapa + serviços em atuação + conserto de layout
- [ ] Painel PDR: nova página com cards de média de duração por setor
- [ ] Painel Pareceres: excluir "reforma" como workaround (aguardando parâmetro novo da Kelly)
- [ ] Painel Pavimentos: bloqueado, sem ação até API corrigir valor do subformulário
- [x] Painel Chefia: confirmado OK por João (66 vs 67, diferença esperada)

**Carta de Serviços (P1.1, nova — investigação de duplicação de OS):**
- [ ] Mapear etapa da ingestão onde a duplicação ocorre
- [ ] Confirmar causa (overwrite/append sem dedup vs. fan-out no join SCD2)
- [ ] Aplicar fix de deduplicação e revalidar rowcount

**Geo Osasco (P1, herdado de W29):**
- [ ] Confirmar `dentro_mapa = 1` em todos os visuais
- [ ] Confirmar filtro de bairro
- [ ] Reexecutar `nb_analise_comparativa_gold_geo.ipynb`
- [ ] Ata de aceite formal do stakeholder
- [ ] Baseline de performance registrado

**Visita Domiciliar (P1, nova):**
- [ ] Pendências PMO respondidas (Monitoramento / secretaria-unidade / CadÚnico)
- [ ] Refresh adicionado a `pl_ingest_acto`
- [x] Painel construído (Visão Geral + Base Detalhada) — publicação/homologação ainda pendente

**Novos pedidos de painel Osasco (P1.2, nova — 23/07):**
- [ ] Tooltip de pontos fora do contorno de Osasco no painel de Ocorrências PMS — não iniciado
- [x] Mapa CRAS Fase 1 (choropleth por bairro) implementada no PBI — geometria corrigida, gradiente sequencial, filtros dinâmicos confirmados
- [x] Mapa CRAS Fase 3 (cruzamento CadÚnico) implementada — achada tabela Fabric real (`gold.osasco_cad_unico_indicadores_bairros`), CSV local do Yuri removido, página de tooltip customizada criada e validada
- [ ] Mapa CRAS Fase 2 (contorno aproximado de Jardim D'Abril) — validada no protótipo, ainda não trazida pro Azure Maps do PBI
- Ver [[spec_painel_mapa_cras_osasco]] para o detalhe completo

**Bug suspeito SEGOV — OS excluída não removida (P1.3, nova — 24/07):**
- [x] Bug reportado e ação imediata tomada (OS 987194 retirada do relatório)
- [ ] Causa raiz confirmada com André/Fernando
- [ ] 6 OS suspeitas adicionais checadas uma a uma
- [ ] Avaliação de impacto em outros painéis/secretarias, se confirmado

**Dívida técnica (P2):**
- [ ] NaN saneado em `silver.ssp_criminais`
- [ ] `bairros_osasco.json` migrado para Delta Table
- [ ] Decisão sobre normalização de `servico` (Obras, 6.4)

**Acervo institucional (P2.1, nova — envio ao lakehouse-inmov):**
- [x] Comparação acervo pessoal × lakehouse-inmov concluída (10 itens propostos)
- [ ] Yuri revisar a proposta
- [ ] Issues abertas no `lakehouse-inmov` para os itens aprovados
- [ ] Curadoria e merge na `main`

## 8. Referências
- [[spec_drive_semana_13_07_2026]] — spec da semana anterior (W29), plano original do Geo Osasco não executado
- [[spec_drive_paridade_gold_obras]] — spec ativo de paridade Gold Obras, Blocos 5-6 são a fonte primária de pendências desta semana
- [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API]] — postmortem do bug de origem que consumiu a semana passada
- [[esp_drive_os_multiplas_etapas]] — diagnóstico original do bug de múltiplas etapas, implementado no módulo EAV novo
- [[spec_painel_osasco_visita_domiciliar]] — spec do painel NPCAD, pipeline concluído, painel pendente
- [[spec_arquitetura_geo_osasco]] — arquitetura geo Osasco, P2-P7 ainda não iniciados além de VCM
- [[spec_painel_seont_analista_tecnico]] — detalhamento completo dos pedidos da reunião "Painéis Obras" 21/07 (Analistas, PDR, Pareceres, Pavimentos)
- [[Documentação_Fabric/acervo/decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita]] — decisão que padroniza SCD2/dedup para Carta de Serviços, relevante para a investigação de duplicação de OS
- [[Documentação_Fabric/acervo/migracao/PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21]] — proposta de incremento do acervo oficial da equipe (`lakehouse-inmov`) a partir do acervo pessoal, aguardando revisão do Yuri
