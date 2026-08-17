-- endpoint: ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com
-- database: Osasco carta de serviço

-- 1) foto geral
SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT id_do_servico) AS total_distinct_id_servico,
    COUNT(DISTINCT nome_do_servico) AS total_distinct_nome_servico
FROM gold_carta_servicos;

-- 2) distribuicao por status
SELECT
    status_tramitacao,
    COUNT(*) AS qtd_linhas
FROM gold_carta_servicos
GROUP BY status_tramitacao
ORDER BY qtd_linhas DESC;

-- 3) servicos mais duplicados por id_do_servico
SELECT TOP 50
    id_do_servico,
    COUNT(*) AS qtd_linhas
FROM gold_carta_servicos
WHERE id_do_servico IS NOT NULL
GROUP BY id_do_servico
HAVING COUNT(*) > 1
ORDER BY qtd_linhas DESC, id_do_servico;

-- 4) servicos mais duplicados por nome_do_servico
SELECT TOP 50
    nome_do_servico,
    COUNT(*) AS qtd_linhas
FROM gold_carta_servicos
WHERE nome_do_servico IS NOT NULL
GROUP BY nome_do_servico
HAVING COUNT(*) > 1
ORDER BY qtd_linhas DESC, nome_do_servico;

-- 5) serie temporal da consolidacao (identificar virada)
SELECT
    CAST(data_consolidada AS date) AS dt,
    COUNT(*) AS qtd_linhas
FROM gold_carta_servicos
GROUP BY CAST(data_consolidada AS date)
ORDER BY dt DESC;

-- 6) comparativo de granularidade por dia (linhas x distinct)
SELECT
    CAST(data_consolidada AS date) AS dt,
    COUNT(*) AS qtd_linhas,
    COUNT(DISTINCT id_do_servico) AS qtd_distinct_id_servico,
    COUNT(DISTINCT nome_do_servico) AS qtd_distinct_nome_servico
FROM gold_carta_servicos
GROUP BY CAST(data_consolidada AS date)
ORDER BY dt DESC;

-- 7) checagem de tabela de atualizacoes
SELECT
    COUNT(*) AS total_linhas_atualizacoes
FROM gold_carta_servicos_atualizacoes;

-- 8) cardinalidade em aberto (se existirem os campos)
SELECT
    status_tramitacao,
    COUNT(*) AS qtd_linhas,
    COUNT(DISTINCT nome_do_servico) AS qtd_distinct_nome_servico
FROM gold_carta_servicos_atualizacoes
GROUP BY status_tramitacao
ORDER BY qtd_linhas DESC;
