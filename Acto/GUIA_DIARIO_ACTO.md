# Guia Diário — Acto

> **Para uso rápido:** abrir isto antes de mexer em qualquer notebook, pipeline ou Gold do Acto.

---

## 1. Comece por aqui

1. [DOCUMENTACAO_UNICA_ACTO.md](DOCUMENTACAO_UNICA_ACTO.md)
2. [GUIA_POR_ONDE_COMECAR_ACTO.md](GUIA_POR_ONDE_COMECAR_ACTO.md)
3. [ACTO/CLAUDE.md](../CLAUDE.md)

Se o foco for migração de Santos:

1. [SPEC_DRIVE_ROADMAP_MIGRACAO.md](../specs/SPEC_DRIVE_ROADMAP_MIGRACAO.md)
2. [SPEC_DRIVE_MIGRACAO_OBRAS.md](../specs/SPEC_DRIVE_MIGRACAO_OBRAS.md)

---

## 2. O que importa lembrar

- O modelo novo usa `lh_solicitacoes_acto`.
- Bronze → Silver → Gold é o fluxo oficial.
- O Gold novo grava Delta e valida volume mínimo antes do write.
- CET e SEPREF ainda precisam de migração validada com o legado de Santos.
- Documento antigo não vale mais do que notebook e pipeline atuais.

---

## 3. Ordem prática do dia

1. Verificar qual domínio será mexido hoje.
2. Abrir o Gold correspondente e entender a fonte.
3. Confirmar se a regra de negócio vem do legado ou do novo módulo.
4. Validar rowcount, colunas críticas e KPI na mesma janela temporal.
5. Só depois alterar conexão, pipeline ou Lakehouse.

---

## 4. Checklist rápido de validação

- Fonte carregou sem erro.
- Silver consolidou sem perder linhas.
- Gold escreveu Delta.
- Colunas críticas existem.
- KPI bate com o legado.
- Refresh do SQL Endpoint ocorreu.

---

## 5. Regra de decisão

Se houver conflito entre documento e notebook:

1. Confie no notebook.
2. Confie na pipeline.
3. Use o documento só como apoio.
