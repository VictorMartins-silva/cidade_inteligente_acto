---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
valido-ate: "2026-10-01"
---

# Padrao Tecnico - Schema e Volumetria do Lakehouse Modulo Acto (EAV)

## Padrao tecnico

Modulo Acto novo (`lh_solicitacoes_acto`) usa um modelo EAV (Entity-Attribute-Value) parametrizado por fonte, com 3 tabelas fato padronizadas por origem na Bronze, unificadas em 3 tabelas na Silver e pivotadas em tabelas de dominio na Gold. Total do lakehouse: 60 tabelas (48 Bronze, 3 Silver, 9 Gold), cobrindo 16 fontes ativas (9 Santos, 3 Osasco, 4 Maua).

### Estrutura Bronze (por fonte)

- `fato_solicitacoes_{fonte}` (12 colunas): cabecalho da solicitacao - id_os (PK), servico, status_fluxo, data_criacao, data_finalizacao, solicitante, origem, data_carga, fonte, municipio, secretaria, unidade_organizacional.
- `fato_campos_{fonte}` (10 colunas): campos dinamicos de formulario no modelo EAV - id_os (FK), servico, campo (atributo), valor, origem, data_carga, fonte, municipio, secretaria, unidade_organizacional.
- `fato_etapas_{fonte}` (16 colunas): rastreamento de SLA por etapa - etapa, servico, id_os, datas de criacao/finalizacao/inicio-fim-atendimento de etapa, status, executor, metadados de origem/carga/fonte/municipio/secretaria/unidade.

### Estrutura Silver (unificada, 3 tabelas)

`silver.fato_solicitacoes`, `silver.fato_campos`, `silver.fato_etapas` - geradas por UNION BY NAME (allowMissingColumns=True) sobre todas as fontes Bronze, com datas convertidas de string para timestamp. Validacao registrada: zero discrepancias entre Bronze e Silver em todas as fontes e tabelas (soma exata de linhas).

### Estrutura Gold (9 tabelas por dominio)

Cada tabela Gold pivota os atributos EAV da fato_campos para colunas horizontais conforme a regra de negocio da secretaria/dominio, mantendo as colunas raiz herdadas da Silver fato_solicitacoes. Dominios cobertos: avaliacao de servicos (28 colunas), CET (34 colunas), curso de motorista (53 colunas), obras (94 colunas, a mais larga do lakehouse), manifestacao/ouvidoria (19 colunas), SEGOV (26 colunas), SEINFRA (32 colunas), SEPREF (23 colunas), atendimento ao trabalhador de Osasco (35 colunas).

## Fluxo

```
Payload JSON (definicao de colunas por fonte, com "col" tecnico e "tit" retornado pela API)
    -> API Acto (endpoint de visualizacao de dados intermediarios)
    -> utilitario de request: consolida colunas duplicadas, limpa nomes de coluna, busca dados de etapa em endpoint separado
    -> bronze.fato_solicitacoes_{fonte} / fato_campos_{fonte} / fato_etapas_{fonte}
    -> notebook Silver: UNION BY NAME allowMissingColumns=True
    -> silver.fato_solicitacoes / fato_campos / fato_etapas
    -> notebook Gold por municipio/dominio: pivot EAV -> colunas de negocio
    -> gold.{tabela}
```

### Checklist para adicionar nova fonte ao modelo EAV

1. Criar payload JSON com as 6 colunas padrao (identificador, servico, status, datas de criacao/finalizacao, solicitante) mais os campos especificos do dominio.
2. Registrar a fonte na lista de fontes do orquestrador Bronze.
3. Registrar o identificador da fonte na lista de fontes do notebook Silver.
4. Criar o notebook Gold do dominio com a lista de campos EAV desejados.
5. Adicionar a chamada do notebook Gold ao orquestrador Gold.
6. Rodar o pipeline e validar volumetria com o notebook de verificacao do Bronze.

## Riscos e regra critica de nomenclatura EAV

- **Regra dos 6 campos padrao:** a API usa o `tit` (rotulo) como chave da resposta JSON apenas para os 6 campos padrao (identificador, servico, status, as duas datas, solicitante). Ausencia de qualquer um causa erro de chave ausente no Bronze.
- **Regra dos campos de formulario (EAV):** para campos com identificador de campo de formulario preenchido no payload, a API retorna a linha chaveada pelo `col` (identificador tecnico) em minusculo, nao pelo `tit` limpo. Isso foi descoberto ao adicionar uma fonte nova que quebrou a primeira tentativa de Gold (todos os campos apareceram como ausentes). Regra pratica: usar `lower(col)` para qualquer campo com identificador de formulario preenchido, e sempre confirmar o nome real do campo consultando a Silver antes de finalizar a lista de campos do Gold - nunca assumir pelo `tit`.
- **Qualidade conhecida por fonte:** todas as fontes de Osasco e Maua e a maioria das de Santos tem 0% de nulos nas colunas obrigatorias. A fonte de obras de Santos e uma excecao conhecida e aceita: ~45% de nulos em data de criacao e ~79% em solicitante, porque a API dessa fonte especifica retorna uma estrutura diferente das demais secretarias - nao e erro de pipeline, e caracteristica da fonte de origem.
- **Complexidade de fluxo variavel:** a fonte de obras de Santos tem a maior complexidade (212 etapas distintas por ~12 mil OS unicas), seguida por uma das fontes de meio ambiente de Maua (114 etapas distintas). Relevante para qualquer analise de SLA por etapa - dominios com muitas etapas distintas exigem atencao redobrada na normalizacao de nome de etapa antes de agregar.
- **Fonte residual sem pipeline ativo:** uma fonte de Osasco aparece na Silver com volume valido mas nao esta na lista de fontes processadas ativamente no notebook Silver atual - residuo de uma execucao anterior quando a fonte ainda estava ativa. Decisao registrada: manter os dados (nao deletar); reativar apenas se a fonte voltar a ser processada.

## Pontos de atencao

- Volumetria total do modelo (verificada por SQL endpoint, no momento do levantamento): ~75 mil solicitacoes, ~548 mil registros de campos EAV, ~340 mil registros de etapas, somando 16 fontes.
- O `allowMissingColumns=True` da uniao Bronze->Silver e desenho intencional: fontes com campos diferentes ficam com nulo nas colunas ausentes, tratado no Gold por funcao de deteccao de colunas existentes.
- Ao adicionar qualquer fonte nova ao modelo, tratar a etapa de confirmacao de nome real de campo via consulta na Silver como obrigatoria, nao opcional - e o erro mais recorrente do padrao EAV desse lakehouse.

## Referencias

- Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO.md (fonte pessoal, não versionada)
- Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO.md + EAV_SILVER_INVENTARIO.md (fonte pessoal, não versionada)
- acervo/decisoes/2026-07-15-bug-payload-api-santos-obras.md (postmortem do bug que originou a regra critica de nomenclatura EAV)
- acervo/engenharia-dados/problemas-qualidade-dados-obras-santos.md (divergencias de logica entre o Gold legado e o modulo Acto novo especificamente para obras)
