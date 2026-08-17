# Plano de Publicacao Incremental

## Passada 1 - Inventario bruto

Resultado esperado:

- lista completa de notas com dono e data de ultima revisao
- marcacao do que e fonte canonica e do que e rascunho

Arquivo base:

- migracao/INVENTARIO_BRUTO.md

## Passada 2 - Classificacao por destino

Resultado esperado:

- cada item com destino principal
- itens que viram varias notas ja quebrados em subtarefas

Arquivo base:

- migracao/MATRIZ_CLASSIFICACAO.md

## Passada 3 - Destilacao por formato do acervo

Formato minimo por destino:

- projeto: objetivo, status atual, proxima acao, ocorrencias, decisoes, pendencias
- decisao: problema, alternativas, decisao, status, impacto
- fonte: origem, formato, periodicidade, lakehouse, camadas, restricoes
- engenharia: padrao tecnico, fluxo, riscos, pontos de atencao
- bi: diretriz, padrao, excecao, referencia
- historico: resumo quinzenal curto

## Passada 4 - Publicacao incremental

Ordem:

1. projetos ativos
2. decisoes ainda nao registradas
3. fontes criticas em uso
4. padroes tecnicos recorrentes
5. material secundario

## Criterio de priorizacao

- alta: impacta entrega, operacao, risco tecnico ou onboarding
- media: conhecimento recorrente ainda tacito
- baixa: historico redundante ou especulativo

## Regra de reversibilidade

- migrar em lotes pequenos
- cada lote com diff curto e revisavel
- nao remover fonte original sem validacao funcional

## Cadencia de atualizacao da base unica

Ritmo semanal recomendado:

- Segunda-feira: atualizar INVENTARIO_BRUTO com novas notas e marcacao de prioridade.
- Quarta-feira: executar destilacao parcial dos projetos ativos e registrar decisoes novas.
- Sexta-feira: fechar semana dos projetos ativos e atualizar historico quando houver marco relevante.

Ritmo quinzenal recomendado:

- publicar 1 nota de historico por rodada com entregas, riscos e proximas acoes.

Criterio de entrada no acervo da equipe:

- entra se o conhecimento for reutilizavel por mais de uma pessoa/frente.
- nao entra se for apenas log diario ou rascunho sem conclusao.
