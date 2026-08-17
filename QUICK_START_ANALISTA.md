# 📊 Quick Start — Analista de Dados

**Tempo:** <5 minutos  
**Objetivo:** Encontrar dados, indicadores, painéis

---

## 1️⃣ Qual é o status?

Abra: **DASHBOARD_RISCOS.md**
- Qual pipeline está parada? (🔴)
- Qual risco é crítico? (R5 = obras parada)

---

## 2️⃣ Dados do meu município

Abra: `01-Municípios/[municipio]/STATUS_[MUNICIPIO].md`
- Última execução?
- Quantos registros?
- Erro em algum pipeline?

---

## 3️⃣ Meu painel Power BI

Vai para: **05-Painéis/**
- Encontra documentação do indicador
- Vê qual tabela Gold alimenta
- Encontra transformação em Silver

---

## 4️⃣ Dados públicos

Vai para: **03-Dados/**
- IBGE? Mapas? CSV?
- Lê README.md lá

---

## 🎯 Atalhos Comuns

### "Preciso da métrica X"
1. Procura em `05-Painéis/`
2. Vê qual notebook de Gold
3. Lê `02-Técnica/Arquitetura/` para entender SCD Type 2

### "Pipeline X está parada"
1. Abre **DASHBOARD_RISCOS.md**
2. Busca pelo nome da pipeline
3. Vê mitigação / contato responsável

### "Encontrei erro em dados"
1. Vai em `01-Municípios/STATUS_[MUNICIPIO].md`
2. Vê qual Silver/Bronze afeta
3. Abre notebook em GitHub

---

## 📞 Ajuda

- Slack: `#data-analytics`
- Power BI: Contate seu admin
- Dados ausentes? Veja DASHBOARD_RISCOS.md
