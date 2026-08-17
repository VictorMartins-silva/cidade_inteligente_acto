---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
---

# Decisao/Postmortem - Bug de Payload e Nomenclatura Inconsistente na API Acto (fonte obras Santos)

## Problema

A fonte de obras de Santos, no modulo Acto novo (EAV), apresentou dois bugs distintos e sequenciais:

1. A ingestao Bronze falhava com erro de chave ausente ao resolver o identificador da solicitacao. Isolando a extracao, a API retornava sempre um resumo agregado de 2 colunas (descricao, total) em vez dos dados detalhados linha a linha esperados.
2. Depois de corrigido o primeiro bug, colunas de negocio criticas do Gold (bairro consolidado, titulo profissional e, por efeito cascata via join, zona) ficavam 100% nulas mesmo com o Bronze correto.

## Investigacao e causas reais

**Causa 1 - payload com campos de formulario orfaos:** o arquivo de payload dessa fonte (base antiga, 29 catalogos) tinha centenas de campos de formulario referenciando identificadores tecnicos que existiam numa versao antiga do formulario de cada servico, mas ja tinham sido removidos/renomeados na origem havia tempo. Ao enviar esses campos orfaos na requisicao, a API quebrava o processamento logo no primeiro catalogo da lista e devolvia so um item de resposta generico, descartando os demais catalogos silenciosamente, sem erro HTTP. Tres hipoteses alternativas foram testadas e descartadas antes de chegar a causa real (problema de codificação de caracteres num catalogo especifico, relatorio reconfigurado no servidor, campo de sequencia fora de escala) - nenhuma delas alterou o comportamento do bug quando corrigida isoladamente.

**Causa 2 - nome de campo EAV inconsistente entre execucoes:** a API que consolida os dados nao e deterministica em como nomeia o campo EAV agregado entre execucoes - em teste local, variantes tecnicas diferentes de um mesmo campo de negocio vinham consolidadas sob o rotulo do `tit` (rubrica legivel); no pipeline real do Fabric, com o mesmo payload exato, as mesmas variantes vinham consolidadas sob o identificador tecnico (`col`) de um catalogo especifico. A contagem de linhas batia exatamente entre as duas execucoes - so o nome do campo mudava. Um filtro por nome exato no Gold nunca acertava de forma confiavel.

## Alternativas consideradas (para a causa 1)

1. Corrigir hipoteses de superficie (codificacao de caracteres, configuracao de relatorio, campo de sequencia) - testado, nao resolveu.
2. Investigar a API diretamente, fora do ambiente Fabric, com um token capturado do navegador, para iterar mais rapido do que subindo o payload no lakehouse a cada tentativa - abordagem que efetivamente revelou a causa raiz.

## Decisao / Fix aplicado

- **Causa 1:** o payload dessa fonte foi reduzido de dezenas de campos totais para apenas os campos realmente necessarios (6 campos padrao + 2 campos novos de etapa/executor atual + os campos de negocio de fato usados no Gold, recuperados do payload antigo). Validado com sucesso: todos os catalogos passaram a retornar dados detalhados.
- **Causa 2:** a logica do notebook Gold que fazia pivot desses campos foi trocada de filtro por nome exato para descoberta em tempo de execucao via padrao de texto (regex), consolidando por `coalesce` todos os campos que baterem com o padrao esperado, independente do nome exato retornado pela API naquela execucao.

## Status

Resolvido e validado em producao. Resultado apos os dois fixes: contagem de OS e etapas na faixa esperada (proxima da referencia do sistema legado), cobertura de zona subiu de 0% para a mesma faixa (~50%) do legado, cobertura de setor responsavel proxima de 99% (acima da referencia legada de ~94%).

## Item em aberto (nao bloqueante, descoberto na mesma investigacao)

Uma coluna de executor responsavel dentro do recorte de uma etapa especifica de analise tecnica veio bem abaixo da referencia do legado. Investigado e confirmado como gap upstream (dado alimentado por um endpoint separado de tempo de etapa, nao pelo payload investigado aqui) - nao e um bug desta investigacao. Confirmado em 24/07/2026: a investigacao a fundo ainda nao foi feita; fica como pendencia do engenheiro de dados responsavel por esta fonte para as proximas semanas, sem data fechada.

## Impacto e licoes para qualquer fonte EAV nova

1. Testar a API diretamente, fora do pipeline, com um token capturado do navegador e muito mais rapido para iterar do que subir payload no lakehouse a cada tentativa - usar esse caminho primeiro em bugs futuros de payload/API deste tipo de integracao.
2. Nunca confiar em nome fixo de campo EAV vindo dessa API - usar busca por padrao de texto no lugar de lista exata em qualquer pivot EAV, e sempre confirmar o nome real consultando a tabela Silver antes de assumir qual nome vai aparecer.
3. Um catalogo com campos de formulario orfaos (removidos/renomeados na origem) pode quebrar a resposta da API para todos os outros catalogos da mesma requisicao, sem erro HTTP - se um payload de qualquer fonte passar a devolver um resumo generico em vez de dados detalhados, suspeitar disso primeiro.
4. O endpoint de visualizacao de dados intermediarios retorna a lista de resultados com um item por catalogo enviado - atencao a esse detalhe ao simular ou testar localmente, pois olhar so o primeiro item da lista pode levar a um diagnostico errado.

## Referencias

- Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md (fonte pessoal, não versionada)
- acervo/engenharia-dados/catalogo-schema-lakehouse-acto.md (regra de nomenclatura EAV que este bug originou)
- acervo/engenharia-dados/problemas-qualidade-dados-obras-santos.md (divergencias de design entre o Gold legado e o modulo novo, mesma fonte)
