---
title: Spec Drive — Governança de Documentação Unificada
date: 2026-05-21
tags:
  - tipo/spec
  - ferramenta/fabric
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: ativo
---
# Spec Drive — Governança de Documentação Unificada

Este documento define os padrões e regras para a manutenção da documentação do projeto **Acto Cidade Inteligente** no Microsoft Fabric. Ele serve como o guia de estilo e integridade para garantir que o conhecimento técnico nunca se fragmente ou se perca.

---

## 🛡️ 1. Princípio da Soberania (Fonte Única)
- **O Guia Mestre:** O arquivo `GUIA_COMPLETO_FABRIC.md` é a **única fonte de verdade**.
- **Proibição de Fragmentação:** É terminantemente proibido criar guias modulares permanentes (ex: `DETALHAMENTO_SANTOS.md`). Se um detalhamento for necessário, ele deve ser uma seção ou apêndice do Guia Mestre.
- **Sincronização:** Qualquer alteração em notebooks, pipelines ou modelos semânticos deve ser refletida no Guia Mestre em até 24 horas.

## 📈 2. Versionamento e Histórico
- **Versões Menores (v3.x):** Atualizações de inventário, correção de typos ou adição de novos notebooks.
- **Versões Maiores (v4.0):** Mudanças estruturais na arquitetura Medallion, novos municípios ou alteração de padrões de design.
- **Registro:** O cabeçalho do Guia Mestre deve sempre refletir a versão atual e a data da última validação.

## 🧬 3. Componentes Obrigatórios
Todo "Update de Governança" deve validar os seguintes blocos:
1.  **Diagrama de Linhagem (Mermaid):** Deve refletir o fluxo físico atual (Bronze → Silver → Gold).
2.  **Matriz de Riscos (R1-R9):** Novos bloqueios ou fragilidades devem ser catalogados imediatamente com impacto e remediação.
3.  **Inventário Técnico:** Listagem de notebooks com status de produção e tabelas de saída.
4.  **Executive Review:** Comentário técnico sobre a qualidade das novas implementações.

## 🎨 4. Padrões Visuais (Mermaid & Canvas)
- **Diagramas de Fluxo:** Usar o padrão `graph TB` ou `graph LR` com estilização de cores por camada (Bronze: Laranja, Silver: Roxo, Gold: Amarelo).
- **Relacionamentos de Risco:** Riscos críticos (R5, R9) devem ser destacados em vermelho nos diagramas.
- **Canvas:** Arquivos `.canvas` de pesquisa devem ser consolidados em texto no Guia Mestre antes de serem arquivados.

## 🛠️ 5. Checklist de Compliance (Spec Sync)
Ao atualizar a documentação, o agente/humano deve garantir que:
- [ ] As violações de nomenclatura (R2) estão listadas.
- [ ] O código IBGE para novos municípios está validado (R9 prevention).
- [ ] A lógica de SCD2 para SLA está explicitamente documentada.
- [ ] Os agendamentos de pipelines estão atualizados com horários BRT.

---
*Documento de Governança · Acto Cidade Inteligente 2026*
