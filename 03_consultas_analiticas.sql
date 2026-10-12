-- ====================================================================
-- PROJETO DE BANCO DE DADOS: E-COMMERCE (DIO / PORTFÓLIO)
-- Arquivo: 03_consultas_analiticas.sql
-- Descrição: Consultas SQL analíticas cobrindo os conceitos-chave:
--            - JOINs (INNER, LEFT, FULL)
--            - GROUP BY e HAVING
--            - CTEs (WITH)
--            - Window Functions (ROW_NUMBER, DENSE_RANK, LAG, LEAD, PARTITION BY)
-- SGBD: PostgreSQL
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. JOINS: Prevenção de Churn (Clientes cadastrados que nunca compraram)
-- Conceitos: LEFT JOIN, IS NULL
-- --------------------------------------------------------------------
SELECT 
    c.idCliente,
    c.nome,
    c.tipo_cliente,
    c.email,
    c.telefone,
    p.idPedido
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
WHERE p.idPedido IS NULL;


-- --------------------------------------------------------------------
-- 2. JOINS: Conciliação Completa de Fornecedores e Produtos
-- Conceitos: FULL OUTER JOIN
-- --------------------------------------------------------------------
SELECT 
    f.Razao_Social AS fornecedor,
    f.CNPJ,
    p.Descricao AS produto,
    p.Categoria,
    p.Valor
FROM Fornecedor f
FULL OUTER JOIN Disponibilizando_um_produto dp ON f.idFornecedor = dp.Fornecedor_idFornecedor
FULL OUTER JOIN Produto p ON dp.Produto_idProduto = p.idProduto;


-- --------------------------------------------------------------------
-- 3. GROUP BY & HAVING: Faturamento e Volume por Categoria de Produto
-- Conceitos: INNER JOIN, SUM, COUNT, GROUP BY, HAVING
-- --------------------------------------------------------------------
SELECT 
    p.Categoria,
    COUNT(DISTINCT ped.idPedido) AS total_pedidos,
    SUM(rp.Quantidade) AS unidades_vendidas,
    SUM(rp.Quantidade * p.Valor) AS receita_total
FROM Produto p
INNER JOIN Relacao_de_Produto_pedido rp ON p.idProduto = rp.Produto_idProduto
INNER JOIN Pedido ped ON rp.Pedido_idPedido = ped.idPedido
GROUP BY p.Categoria
HAVING SUM(rp.Quantidade * p.Valor) >= 1000.00
ORDER BY receita_total DESC;


-- --------------------------------------------------------------------
-- 4. CTEs (WITH): Segmentação de Clientes por Faixa de Gastos (RFM)
-- Conceitos: Common Table Expressions (WITH), CASE WHEN, COALESCE
-- --------------------------------------------------------------------
WITH metricas_cliente AS (
    SELECT 
        c.idCliente,
        c.nome,
        c.tipo_cliente,
        COUNT(DISTINCT p.idPedido) AS qtd_pedidos,
        COALESCE(SUM(rp.Quantidade * pr.Valor), 0) AS total_gasto
    FROM Cliente c
    LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
    LEFT JOIN Relacao_de_Produto_pedido rp ON p.idPedido = rp.Pedido_idPedido
    LEFT JOIN Produto pr ON rp.Produto_idProduto = pr.idProduto
    GROUP BY c.idCliente, c.nome, c.tipo_cliente
),
classificacao_cliente AS (
    SELECT 
        idCliente,
        nome,
        tipo_cliente,
        qtd_pedidos,
        total_gasto,
        CASE 
            WHEN total_gasto >= 3000 THEN 'VIP / Corporativo'
            WHEN total_gasto BETWEEN 500 AND 2999 THEN 'Consumidor Recorrente'
            WHEN total_gasto > 0 THEN 'Consumidor Eventual'
            ELSE 'Inativo / Lead'
        END AS segmento
    FROM metricas_cliente
)
SELECT * 
FROM classificacao_cliente
ORDER BY total_gasto DESC;


-- --------------------------------------------------------------------
-- 5. WINDOW FUNCTIONS: Ranking dos Produtos Mais Vendidos por Categoria
-- Conceitos: DENSE_RANK(), PARTITION BY, ORDER BY
-- --------------------------------------------------------------------
SELECT 
    p.Categoria,
    p.Descricao AS produto,
    SUM(rp.Quantidade) AS total_unidades_vendidas,
    DENSE_RANK() OVER (
        PARTITION BY p.Categoria 
        ORDER BY SUM(rp.Quantidade) DESC
    ) AS ranking_na_categoria
FROM Produto p
INNER JOIN Relacao_de_Produto_pedido rp ON p.idProduto = rp.Produto_idProduto
GROUP BY p.Categoria, p.Descricao;


-- --------------------------------------------------------------------
-- 6. WINDOW FUNCTIONS: Intervalo entre Compras do Mesmo Cliente
-- Conceitos: LEAD(), PARTITION BY, Subtração de Datas
-- --------------------------------------------------------------------
SELECT 
    c.idCliente,
    c.nome,
    ped.idPedido,
    ent.data_envio::DATE AS data_compra,
    LEAD(ent.data_envio::DATE) OVER (
        PARTITION BY c.idCliente 
        ORDER BY ent.data_envio
    ) AS proxima_compra,
    LEAD(ent.data_envio::DATE) OVER (
        PARTITION BY c.idCliente 
        ORDER BY ent.data_envio
    ) - ent.data_envio::DATE AS dias_ate_recompra
FROM Pedido ped
INNER JOIN Cliente c ON ped.Cliente_idCliente = c.idCliente
INNER JOIN Entrega ent ON ped.idPedido = ent.Pedido_idPedido
ORDER BY c.idCliente, ent.data_envio;
