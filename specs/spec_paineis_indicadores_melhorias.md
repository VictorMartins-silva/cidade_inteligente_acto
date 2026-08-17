---
title: "Spec — Melhorias no Módulo Gestão / Painéis de Indicadores"
tags:
  - tipo/spec
  - tema/modulo-gestao
  - tema/paineis-indicadores
  - tema/ux
  - tema/acto-web
revisao: "2026-05-13"
status: validacao-parcial
---

# Spec — Melhorias no Módulo Gestão / Painéis de Indicadores

> **Módulo:** Gestão > Painéis de Indicadores  
> **Objetivo:** Padronizar publicação, pesquisa e layout com os elementos do Acto Web  
> **Contexto:** O módulo atual não segue a estrutura hierárquica do Catálogo de Serviço nem o padrão visual do Acto Web. As melhorias abaixo alinham os dois sistemas.

---

## Contexto Visual

> [!info] Referência de Layout
> - **Layout padrão (Acto Web):** logo Acto | Administrativo → brasão + nome da prefeitura → breadcrumb hierárquico ativo → menu lateral com eixo identificado
> - **Layout atual (Módulo Gestão):** cabeçalho desaparece ao abrir painel; sem logo; sem brasão; menu chama-se "Painéis" sem identificação de eixo; botão voltar retorna ao início em vez do menu

---

## Grupo 1 — Publicação e Pesquisa

### 01 · Publicação por Categorias em Níveis

**Situação atual:** Os painéis são publicados em lista plana, sem hierarquia.

**Comportamento esperado:** O administrador deve poder configurar a publicação dos painéis em estrutura de categorias multinível, espelhando a hierarquia do Catálogo de Serviço (ex.: Eixo → Secretaria → Domínio → Painel).

**Critérios de aceite:**

- [ ] Interface de configuração permite criar/editar/excluir categorias em árvore (mínimo 3 níveis)
- [ ] Cada painel pode ser associado a uma ou mais categorias
- [ ] A hierarquia é refletida no menu de navegação do usuário final
- [ ] Reordenação de categorias por drag-and-drop ou campo de ordem numérica
- [ ] Categoria sem painéis não é exibida para o usuário final

---

### 02 · Tags (Palavras-chave) por Painel

**Critérios de aceite:**

- [ ] Campo de tags disponível na tela de cadastro/edição de painel
- [ ] Suporte a múltiplas tags por painel
- [ ] Tags sugerem termos já usados em outros painéis (autocomplete)
- [ ] Tags são salvas em minúsculo e sem acentos para consistência de busca

---

### 03 · Pesquisa Indexada por Categoria, Título e Tags

**Critérios de aceite:**

- [ ] Campo de busca visível no topo da tela de listagem de painéis
- [ ] Busca em tempo real (a partir de 2 caracteres) ou por Enter
- [ ] Resultados agrupados por categoria, com destaque do trecho correspondente
- [ ] Filtro combinável: pesquisa livre + seleção de categoria

---

## Grupo 2 — Layout e Navegação

### 04 · Renomear Menu para "Painéis de Indicadores"

- [ ] Texto alterado em todos os pontos de entrada: menu lateral, título da página, breadcrumb, título da aba do navegador

### 05 · Logo Acto | Administrativo no Canto Superior Esquerdo

- [ ] Logo renderizado como SVG ou PNG com fundo transparente
- [ ] Logo clicável e retorna à tela inicial do módulo
- [ ] Exibido em todas as telas do módulo

### 06 · Brasão e Nome da Prefeitura após o Logo

- [ ] Brasão e nome da prefeitura carregados de configuração por cliente
- [ ] Ambos exibidos em todas as telas

### 07 · Identificar o Eixo no Título do Menu

- [ ] Quando o usuário está dentro de uma categoria, o nome do eixo aparece como header acima dos itens do menu

### 08 · Manter Cabeçalho ao Abrir um Painel

> [!warning] Impacto em Painéis Externos
> Painéis embutidos via iframe devem ser renderizados em área delimitada, sem que o iframe ocupe 100% da viewport.

- [ ] Cabeçalho (logo + brasão + nome + navegação) permanece fixo no topo
- [ ] Menu lateral permanece acessível

### 09 · Breadcrumb Ativo com Navegação

**Exemplo:** `principal > painéis de indicadores > assistência social > RMA/CRAS`

- [ ] Breadcrumb reflete o caminho real de navegação
- [ ] Cada nível é um link clicável

### 10 · Botão Voltar do Navegador Retorna ao Último Nível do Menu

- [ ] Cada nível de navegação gera uma entrada distinta no histórico do browser (`history.pushState`)
- [ ] Botão Voltar retorna à listagem da categoria, não ao início

---

## Resumo das Melhorias

| # | Grupo | Item | Prioridade |
|---|---|---|---|
| 01 | Publicação | Categorias em níveis | Alta |
| 02 | Publicação | Tags por painel | Média |
| 03 | Pesquisa | Busca indexada | Alta |
| 04 | Layout | Renomear menu | Baixa |
| 05 | Layout | Logo Acto no cabeçalho | Alta |
| 06 | Layout | Brasão + nome da prefeitura | Alta |
| 07 | Navegação | Eixo no título do menu | Média |
| 08 | Navegação | Cabeçalho persistente ao abrir painel | **Crítica** |
| 09 | Navegação | Breadcrumb ativo | Alta |
| 10 | Navegação | Botão Voltar respeita hierarquia | Alta |

---

## Validação — 2026-05-13

### Resultado por Item

| # | Item | Status | Evidência |
|---|---|---|---|
| 01 | Categorias em Níveis | ⚠️ Parcial | Categorias visíveis na busca. Admin não verificável |
| 02 | Tags | ⚠️ Parcial | Tag "estratégicos" visível nos cards |
| 03 | Busca Indexada | ⚠️ Parcial | Campo visível, resultados agrupados ✅. **Highlight não implementado** ❌ |
| 04 | Renomear para "Painéis de Indicadores" | ❌ Pendente | H1 ainda exibe **"Painéis"** |
| 05 | Logo Acto | ✅ OK | Logo visível com painel aberto |
| 06 | Brasão + Nome da Prefeitura | ✅ OK | Brasão + "Prefeitura Municipal de Osasco" visíveis |
| 07 | Eixo no Título do Menu | ❌ Não implementado | Menu exibe **"Gestão <"** em vez do eixo |
| 08 | Cabeçalho Persistente ao Abrir Painel | ✅ **APROVADO** | Logo + brasão + menu presentes com painel aberto |
| 09 | Breadcrumb Ativo | ✅ OK (parcial) | 4 níveis visíveis. Clickabilidade não verificável por screenshot |
| 10 | Botão Voltar do Navegador | 🔲 Não verificável | Requer teste manual |

---

## Referências

- [[DOCUMENTACAO_NEGOCIO_ACTO]] — contexto de negócio do módulo Acto
- [[DOCUMENTACAO_TECNICA_ACTO]] — arquitetura técnica do módulo
