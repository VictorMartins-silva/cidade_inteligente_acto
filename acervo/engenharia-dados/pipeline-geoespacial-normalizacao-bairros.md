---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Padrao Tecnico - Pipeline Geoespacial (Normalizacao de Bairros para Power BI)

## Fonte canonica

- Acto Cidade Inteligente/Mapas_SSP_Osasco/README_Mapas_SSP_Osasco.md (fonte pessoal, não versionada)

## Objetivo

Documentar o padrao tecnico para cruzar dados com localizacao em texto livre (ex.: ocorrencias da SSP-SP) contra uma malha geografica oficial (shapefile de bairros) e exportar para visuais de mapa no Power BI. Reutilizavel para qualquer municipio com o mesmo problema (nome de bairro inconsistente na fonte).

## Problema resolvido

A fonte (SSP-SP) registra bairros em texto livre, com abreviacoes e grafias inconsistentes. O shapefile oficial usa nomenclatura padronizada. Sem normalizacao, o cruzamento fonte × malha geografica perde cobertura silenciosamente.

## Fluxo

```
shapefile oficial (.shp/.dbf/.shx/.prj, EPSG:3857 — metros)
  → normalizacao de nome de bairro (fonte × malha oficial)
  → conversao de projecao para EPSG:4326 (graus, exigido por Power BI/GeoJSON)
  → GeoJSON (poligonos dos bairros) + CSV de centroides
  → CSV consolidado (dado da fonte + lat/lon + categoria) pronto para Shape Map / visual de mapa no PBI
```

## Conceitos de referencia (usar sempre que houver duvida)

- **Vetorial x raster**: mapa aqui e vetorial — pontos, linhas, poligonos (nao pixel).
- **CRS/projecao**: WGS84 (EPSG:4326, graus) e o padrao de GPS/Power BI/GeoJSON; Web Mercator (EPSG:3857, metros) e comum em shapefile de prefeitura. **Sem converter 3857 → 4326, os poligonos aparecem em posicao errada ou o mapa nao renderiza.**
- **Shapefile**: nunca e um arquivo unico — sempre um conjunto (`.shp` geometria, `.dbf` atributos, `.shx` indice espacial, `.prj` projecao). Limite de 10 caracteres em nome de coluna (heranca dBASE); risco de corromper o dado se faltar um dos arquivos do conjunto.
- **GeoJSON**: formato moderno, um unico arquivo com geometria + atributos, UTF-8 nativo — mais simples de manter que shapefile.

## Pontos de atencao

- Validar cobertura geografica (nomes de bairro da fonte sem correspondencia na malha oficial) antes de publicar — perda de linhas nessa etapa e silenciosa se nao houver relatorio de validacao.
- Sempre confirmar o EPSG do shapefile de origem antes de assumir a conversao — nem toda prefeitura usa 3857.

## Aplicabilidade

Padrao usado hoje no projeto Geo Osasco (ver `projetos/projeto-geo-osasco.md`); reutilizavel para qualquer novo municipio/fonte que precise de mapa com localizacao em texto livre.

## Referencias

- Acto Cidade Inteligente/Mapas_SSP_Osasco/README_Mapas_SSP_Osasco.md (conceitos completos + scripts de validacao/exportacao) (fonte pessoal, não versionada)
- projetos/projeto-geo-osasco.md
