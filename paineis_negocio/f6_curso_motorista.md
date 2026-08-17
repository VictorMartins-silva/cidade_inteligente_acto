---
title: "F6 — Curso de Motorista"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
status: em-construção
---

# F6 — Curso de Motorista

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painéis desta família

| Arquivo Power BI | Título no painel | Páginas |
|---|---|---|
| `acomp_servicos_curso_motorista` | Curso de aperfeiçoamento profissional para motorista - Gestão | 1 |
| `acomp_servicos_curso_motorista_cet` | Idem — versão CET (dataset maior) | 1 |

> [!note] Domínio isolado
> Este painel tem estrutura completamente diferente das demais famílias: **1 página única**, sem OS, sem SLA, sem mapa. O foco é o **funil de inscrição e resultados de um curso de formação profissional** gerenciado pela CET.

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos de perguntas a responder:
> - O que é o "Curso de Aperfeiçoamento Profissional para Motorista"?
> - Quem organiza o curso: CET, Secretaria de Emprego, outra secretaria?
> - Qual é o público do curso (motoristas de transporte público, motoboys, motoristas de táxi/app)?
> - Este curso é um serviço público obrigatório ou programa voluntário?
> - Há alguma exigência legal por trás do curso?

---

## Público-alvo do Painel

> [!todo] Preencher — Analista de Negócio
> Quem usa este painel?
> - Coordenadores do curso na CET?
> - Gestores que acompanham a efetividade do programa?
> - RH / Secretaria responsável pelo programa?

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Quantas pessoas se inscreveram, foram deferidas e concluíram o curso?
> - Qual é a taxa de evasão do curso?
> - Os participantes estão satisfeitos com o conteúdo e instrutores?
> - Qual turma tem maior taxa de aprovação?

---

## Diferença entre as duas versões do painel

| Aspecto | Versão Gestão | Versão CET |
|---|---|---|
| Arquivo | `acomp_servicos_curso_motorista` | `acomp_servicos_curso_motorista_cet` |
| Dataset | Menor (subset) | Maior (dataset completo da CET) |

> [!todo] Qual é a diferença real de escopo?
> A versão "Gestão" mostra apenas um subconjunto de turmas/inscrições? Ou é uma visão gerencial agregada?
> Confirmar com a equipe técnica ou CET.

---

## Indicadores e Métricas (KPIs)

### Funil de Conversão

| Etapa | Indicador           | Definição de negócio                                    |
| ----- | ------------------- | ------------------------------------------------------- |
| Topo  | Total de Inscrições | _[preencher — quem pode se inscrever?]_                 |
| ↓     | Total Deferidos     | _[preencher — critério de deferimento?]_                |
| ↓     | Total Aprovados     | _[preencher — aprovado no curso?]_                      |
| ↓     | Total Reprovados    | _[preencher — critério de reprovação?]_                 |
| ↓     | Total Indeferidos   | _[preencher — diferença entre indeferido e reprovado?]_ |
| ↓     | Total Cancelados    | _[preencher — quem pode cancelar?]_                     |

### KPIs Calculados

| Indicador | Definição de negócio |
|---|---|
| Taxa de Deferimento | _[preencher — % dos inscritos que foram deferidos]_ |
| Taxa de Evasão | _[preencher — % que abandonou após deferimento?]_ |

> [!todo] Definições de funil
> Documentar o fluxo completo: Inscrição → Deferimento → Curso → Resultado. O que acontece em cada transição?

### Frequência Diária (D1–D7)

O painel mostra presença e ausência por dia do curso (D1 a D7).

> [!todo] Duração do curso
> O curso tem duração fixa de 7 dias? É contínuo (dias consecutivos) ou modular?
> O que acontece se o aluno falta em um dia: pode repor? É automaticamente reprovado?

### Satisfação (Pesquisa pós-curso)

| Dimensão avaliada | Definição de negócio |
|---|---|
| Carga horária ideal | _[preencher]_ |
| Qualidade dos instrutores | _[preencher]_ |
| Clareza do conteúdo | _[preencher]_ |
| Não cansativo | _[preencher]_ |
| Aplicabilidade | _[preencher — o conteúdo é aplicável ao dia a dia?]_ |

> [!todo] Escala de satisfação
> Qual escala é usada? (1–5 estrelas, Satisfeito/Insatisfeito, NPS?)
> A pesquisa é respondida ao final do curso por todos os participantes?

---

## Estrutura de Navegação

**Painel de página única** (sem abas de navegação).

Elementos presentes na única página:

- Funil de conversão (Inscrições → Deferidos → Aprovados/Reprovados/Indeferidos/Cancelados)
- KPIs: Taxa de Deferimento · Taxa de Evasão
- Frequência diária: presença/ausência D1–D7
- Resultados de satisfação por dimensão
- Tabela: Aluno · Status · Presença D1–D7

---

## Filtros Disponíveis

- Mês/Ano
- Status da Inscrição
- Turma

> [!todo] Turmas
> Como as turmas são identificadas? Há identificador numérico, por mês, por tipo de motorista?
> Existe sazonalidade na oferta de turmas (ex.: mensal)?

---

## Origem dos Dados

| Tabela Gold (Fabric) | Notebook de carga |
|---|---|
| `gold_curso_motoristas` | `nb_silver_santos_curso_motoristas` + `gold_curso_motorista` _(verificar nome exato)_ |

**Fonte primária:** API Acto Gestão → Lakehouse `lh_cidade_inteligente_santos`

> [!warning] Risco técnico R9 — código de município incorreto
> O notebook `nb_ingest_caged_santos` tem o código do município de Osasco hardcoded em vez de Santos. **Este notebook NÃO deve ser ativado até a correção.** Confirmar se isso afeta os dados do curso de motorista ou apenas dados do CAGED.

> [!todo] Frequência de atualização
> Com qual periodicidade os dados do curso são atualizados?

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Qual é o critério para deferir uma inscrição?
> - Existe lista de espera?
> - Qual é o critério de aprovação (nota mínima? frequência mínima?)?
> - Os resultados do curso têm alguma consequência para o participante (habilitação, certificado, benefício)?

---

## Glossário

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| Curso de aperfeiçoamento para motorista | _[preencher — nome oficial, público, objetivo]_ |
| Deferido | _[preencher]_ |
| Indeferido | _[preencher — diferente de reprovado como?]_ |
| Taxa de Evasão | _[preencher]_ |
| Turma | _[preencher]_ |
| D1–D7 | _[preencher — dias do curso]_ |

---

## Alertas e Limitações Conhecidas

> [!warning] Footer menor que o padrão
> O rodapé "Desenvolvido por InMov" está presente mas com tamanho 5.2pt (padrão: 7.5pt). Aguarda correção visual.

> [!warning] Fonte extra não padronizada
> O painel usa `SegoeFluentIcons` que não está presente nos outros 17 painéis. Impacto visual mínimo mas é desvio do padrão tipográfico.

> [!note] Sem SLA, sem mapa, sem OS
> Este painel não acompanha OS nem SLA — é voltado exclusivamente para gestão do programa de curso. Comparações com os demais painéis não se aplicam.
