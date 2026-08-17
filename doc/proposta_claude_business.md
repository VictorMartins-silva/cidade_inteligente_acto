---
titulo: Proposta de Migração — Claude Code para Plano Enterprise
data: 2026-06-03
destinatario: Gestão / Cibersegurança
tipo: proposta-interna
---

# Proposta: Migração do Claude Code para Plano Enterprise

## Contexto

A equipe de engenharia de dados da Acto utiliza o Claude Code (Anthropic) como ferramenta de produtividade no desenvolvimento de notebooks Microsoft Fabric. Atualmente, cada analista mantém e paga individualmente um plano pessoal (Pro ou Max), sem contrato corporativo.

O gerente de cibersegurança levantou preocupação legítima: **planos pessoais permitem que a Anthropic use conversas para treinamento de modelos por padrão**, o que representa um risco de exposição de dados técnicos da empresa.

---

## Situação Atual — Riscos Identificados

| Risco | Impacto | Situação |
|---|---|---|
| Dados de conversas usados para treino de IA | Médio | **Presente** — planos pessoais permitem por padrão |
| Sem controle centralizado de acesso | Médio | Sem visibilidade de quem usa, como e o quê |
| Sem auditoria de uso | Médio | Não há logs corporativos |
| Sem contrato de processamento de dados (DPA) | Alto | Sem respaldo jurídico para LGPD/compliance |
| Credenciais ou dados sensíveis colados no chat | Alto | **Mitigado** — política de uso já em vigor |
| Dados de munícipes expostos | Alto | **Mitigado** — política de uso já em vigor |

> A política interna de não colar tokens, senhas e dados pessoais já está em vigor e reduz os riscos mais críticos. O risco remanescente é **estrutural**: o modelo de contrato, não o comportamento dos usuários.

---

## Comparativo de Planos

| Critério | Plano Pessoal (atual) | Claude Business | Claude Enterprise |
|---|---|---|---|
| Dados usados para treino | **Sim** (padrão) | Não | **Não** — garantia contratual |
| Zero data training opt-out | Manual, por usuário | Automático | **Automático + auditável** |
| Retenção de conversas | 30 dias (padrão) | Configurável | **Configurável + exportável** |
| Controle centralizado de membros | Não | Sim | **Sim + grupos e permissões por papel** |
| SSO (login corporativo) | Não | Sim | **Sim — SAML/OIDC compatível com AD** |
| SCIM (provisionamento automático) | Não | Não | **Sim — sync com Azure AD / Entra ID** |
| Auditoria e logs de uso | Não | Básico | **Completo — exportável via API** |
| DPA (Data Processing Agreement) | Não | Básico | **Completo — LGPD / GDPR / SOC 2** |
| Isolamento de dados por organização | Não | Parcial | **Total — tenant dedicado** |
| Suporte | Comunidade | Prioritário | **Dedicado — SLA contratual** |
| Políticas de uso customizadas | Não | Não | **Sim — restrições por equipe/projeto** |
| Custo estimado | ~$20/usuário/mês | ~$30/usuário/mês | Contrato — cotação sob demanda |

---

## Vantagens Específicas para Cibersegurança — Enterprise

### 1. Isolamento de Dados com Garantia Contratual

No plano Enterprise, a Anthropic assina um **Data Processing Agreement (DPA)** formal, estabelecendo:

- As conversas da organização **nunca são usadas para treinar modelos**, sem exceções
- Os dados são processados em **infraestrutura isolada por tenant** — sem compartilhamento com outras organizações
- A Anthropic se compromete contratualmente com **retenção mínima** — dados podem ser deletados sob demanda
- Cobertura explícita para **LGPD, GDPR e SOC 2 Type II**

> Isso transforma uma preocupação de confiança em uma obrigação jurídica da Anthropic.

---

### 2. Identity & Access Management (IAM) Corporativo

O Enterprise integra nativamente com a infraestrutura de identidade já existente na empresa:

- **SSO via SAML 2.0 / OIDC** — analistas acessam com as mesmas credenciais corporativas do Azure AD / Microsoft Entra ID
- **SCIM provisioning** — quando um analista é desligado ou muda de função, o acesso ao Claude é **revogado automaticamente** pelo mesmo fluxo de offboarding já existente
- **Grupos e papéis** — é possível segmentar permissões por projeto ou secretaria municipal (ex: analistas Santos vs. Osasco)
- **MFA** — herda a política de MFA corporativa via SSO, sem configuração adicional

> Elimina a dependência de contas pessoais e o risco de ex-funcionários com acesso ativo.

---

### 3. Auditoria e Visibilidade Completa

O gerente de cibersegurança passa a ter visibilidade total sobre o uso da ferramenta:

- **Logs de acesso:** quem acessou, quando e de onde
- **Logs de uso por usuário:** volume de conversas, ferramentas utilizadas (edição de arquivos, execução de comandos)
- **Exportação de logs via API** — integração com SIEM corporativo (Sentinel, Splunk, etc.) se necessário
- **Alertas configuráveis** — é possível criar regras para usos fora do padrão

> Transforma a ferramenta de uma "caixa-preta" para um ativo monitorado como qualquer outro sistema.

---

### 4. Políticas de Uso Centralizadas

No Enterprise, o admin pode configurar restrições que se aplicam a **todos os usuários automaticamente**, sem depender de adesão individual:

- Bloquear integração com domínios externos não autorizados
- Restringir ferramentas do Claude Code por equipe (ex: proibir execução de comandos de rede em certos contextos)
- Definir avisos ou bloqueios para padrões de input suspeitos (regex de CPF, CNPJ, tokens no formato conhecido)

---

### 5. Resposta a Incidentes

Com o plano Enterprise, em caso de incidente:

- A Anthropic tem **SLA contratual para resposta a notificações de segurança**
- É possível solicitar **deletar dados de conversas específicas** com comprovação de exclusão
- O DPA define claramente **responsabilidades e notificações em caso de breach** (requisito LGPD Art. 48)

---

## Análise de Custo

O Enterprise é cotado sob demanda (volume de usuários e funcionalidades). Referência de mercado para contextualizar:

| Cenário | Custo Mensal | Proteção |
|---|---|---|
| Atual (5x Pro pessoal) | ~$100/mês | Nenhuma contratual |
| Claude for Business (5 usuários) | ~$150/mês | Parcial |
| Claude Enterprise | A cotar | **Total — DPA + IAM + Auditoria + SLA** |

> O custo do Enterprise deve ser avaliado frente ao custo de um único incidente de vazamento de dados: multa LGPD (até 2% do faturamento), dano reputacional com prefeituras clientes, e custo de resposta a incidente.

---

## O Que Muda na Prática

1. **Para os analistas:** acesso via login corporativo (mesmo usuário do Teams/Outlook) — sem impacto no fluxo de trabalho
2. **Para a cibersegurança:** visibilidade total, controle centralizado, logs exportáveis, conformidade contratual
3. **Para a gestão:** cobertura jurídica LGPD, DPA assinado, evidência de due diligence para clientes (prefeituras)
4. **Offboarding:** revogação automática via Azure AD — sem risco de acessos orfãos

---

## O Que NÃO Muda

- O Claude Code continua funcionando da mesma forma para os analistas
- A política de não colar dados sensíveis continua sendo necessária e deve ser mantida (defesa em profundidade)
- Não há integração nativa com sistemas internos — a ferramenta opera como assistente de código

---

## Esclarecimento — Print do Gerente de Cibersegurança

O comportamento observado ("Claude deu permissão a algo não aceito") refere-se ao sistema de **permissões por ferramenta do Claude Code CLI**, não a uma ação autônoma da IA:

- O Claude Code pede aprovação antes de executar comandos, editar arquivos ou fazer chamadas de rede
- Permissões podem ser pré-configuradas pelo próprio usuário em `settings.json` ou ativadas via modo de aprovação automática (`Shift+Tab`)
- O Claude Code **não toma decisões de segurança sozinho** — toda permissão concedida foi configurada ou aprovada por um humano

Para investigar o caso específico: verificar o arquivo `.claude/settings.json` no diretório do projeto do analista em questão e identificar quais ferramentas estão na lista `allowedTools`.

---

## Recomendação

**Migrar para Claude Enterprise** — resolve todas as preocupações estruturais de cibersegurança com cobertura contratual, IAM corporativo e auditoria completa.

**Próximos passos:**

1. Confirmar número exato de usuários ativos e perfis de uso
2. Solicitar cotação e DPA junto à Anthropic (contato enterprise: anthropic.com/contact-sales)
3. Encaminhar o DPA para revisão jurídica e validação pelo time de cibersegurança
4. Configurar integração SSO com Azure AD / Microsoft Entra ID
5. Migrar usuários em lote — admin cria organização e provisiona via SCIM
6. Configurar exportação de logs para SIEM corporativo (se aplicável)

---

*Elaborado em 2026-06-03 | Equipe de Engenharia de Dados — Acto Cidade Inteligente*
