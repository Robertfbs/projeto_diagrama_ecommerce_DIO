-- ====================================================================
-- PROJETO DE BANCO DE DADOS: E-COMMERCE (DIO / PORTFÓLIO)
-- Arquivo: 01_esquema_relacional.sql
-- Descrição: Criação das tabelas e restrições conforme o modelo MER
-- SGBD: PostgreSQL
-- ====================================================================

-- 1. Remoção de tabelas pré-existentes (ordem inversa de dependência)
DROP TABLE IF EXISTS Produtos_por_vendedor_terceiro CASCADE;
DROP TABLE IF EXISTS Terceiro_Vendedor CASCADE;
DROP TABLE IF EXISTS Disponibilizando_um_produto CASCADE;
DROP TABLE IF EXISTS Fornecedor CASCADE;
DROP TABLE IF EXISTS Produto_has_Estoque CASCADE;
DROP TABLE IF EXISTS Estoque CASCADE;
DROP TABLE IF EXISTS Relacao_de_Produto_pedido CASCADE;
DROP TABLE IF EXISTS Produto CASCADE;
DROP TABLE IF EXISTS Entrega CASCADE;
DROP TABLE IF EXISTS Pagamento_pedido CASCADE;
DROP TABLE IF EXISTS Pedido CASCADE;
DROP TABLE IF EXISTS Forma_Pagamento CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;

-- --------------------------------------------------------------------
-- 2. Tabela: Cliente (Refinamento PF/PJ com restrição de exclusividade mútua)
-- --------------------------------------------------------------------
CREATE TABLE Cliente (
    idCliente SERIAL PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    email VARCHAR(45) NOT NULL UNIQUE,
    telefone VARCHAR(45),
    Endereco VARCHAR(100),
    tipo_cliente VARCHAR(2) NOT NULL CHECK (tipo_cliente IN ('PF', 'PJ')),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    cnpj VARCHAR(18) UNIQUE,
    razao_social VARCHAR(100),
    nome_fantasia VARCHAR(100),
    CONSTRAINT chk_cliente_pf_pj CHECK (
        (tipo_cliente = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL AND razao_social IS NULL AND nome_fantasia IS NULL) OR
        (tipo_cliente = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL AND data_nascimento IS NULL)
    )
);

-- --------------------------------------------------------------------
-- 3. Tabela: Forma_Pagamento (Múltiplas formas de pagamento do cliente)
-- --------------------------------------------------------------------
CREATE TABLE Forma_Pagamento (
    idForma_Pagamento SERIAL PRIMARY KEY,
    tipo_pagamento VARCHAR(45) NOT NULL, -- Ex: 'Cartão de Crédito', 'Pix', 'Boleto'
    Cliente_idCliente INT NOT NULL REFERENCES Cliente(idCliente) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 4. Tabela: Pedido
-- --------------------------------------------------------------------
CREATE TABLE Pedido (
    idPedido SERIAL PRIMARY KEY,
    Status_do_Pedido VARCHAR(45) NOT NULL DEFAULT 'Em processamento',
    Descricao VARCHAR(100),
    Cliente_idCliente INT NOT NULL REFERENCES Cliente(idCliente),
    Frete FLOAT NOT NULL DEFAULT 0.0
);

-- --------------------------------------------------------------------
-- 5. Tabela: Pagamento_pedido (Associação entre Pedido e Forma de Pagamento)
-- --------------------------------------------------------------------
CREATE TABLE Pagamento_pedido (
    idPagamento_pedido SERIAL PRIMARY KEY,
    valor DECIMAL(10, 2) NOT NULL,
    status VARCHAR(45) NOT NULL DEFAULT 'Aprovado',
    Pedido_idPedido INT NOT NULL REFERENCES Pedido(idPedido) ON DELETE CASCADE,
    Forma_Pagamento_idForma_Pagamento INT NOT NULL REFERENCES Forma_Pagamento(idForma_Pagamento)
);

-- --------------------------------------------------------------------
-- 6. Tabela: Entrega (Status e código de rastreamento)
-- --------------------------------------------------------------------
CREATE TABLE Entrega (
    idEntrega SERIAL PRIMARY KEY,
    status_entrega VARCHAR(45) NOT NULL DEFAULT 'Preparando envio',
    codigo_rastreio VARCHAR(45),
    data_envio TIMESTAMP,
    data_prevista DATE,
    Pedido_idPedido INT NOT NULL UNIQUE REFERENCES Pedido(idPedido) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 7. Tabela: Produto
-- --------------------------------------------------------------------
CREATE TABLE Produto (
    idProduto SERIAL PRIMARY KEY,
    Categoria VARCHAR(45) NOT NULL,
    Descricao VARCHAR(100) NOT NULL,
    Valor DECIMAL(10, 2) NOT NULL
);

-- --------------------------------------------------------------------
-- 8. Tabela associativa: Relação de Produto/pedido
-- --------------------------------------------------------------------
CREATE TABLE Relacao_de_Produto_pedido (
    Produto_idProduto INT NOT NULL REFERENCES Produto(idProduto),
    Pedido_idPedido INT NOT NULL REFERENCES Pedido(idPedido) ON DELETE CASCADE,
    Quantidade INT NOT NULL DEFAULT 1,
    PRIMARY KEY (Produto_idProduto, Pedido_idPedido)
);

-- --------------------------------------------------------------------
-- 9. Tabela: Estoque
-- --------------------------------------------------------------------
CREATE TABLE Estoque (
    idEstoque SERIAL PRIMARY KEY,
    Local VARCHAR(45) NOT NULL
);

-- --------------------------------------------------------------------
-- 10. Tabela associativa: Produto_has_Estoque
-- --------------------------------------------------------------------
CREATE TABLE Produto_has_Estoque (
    Produto_idProduto INT NOT NULL REFERENCES Produto(idProduto),
    Estoque_idEstoque INT NOT NULL REFERENCES Estoque(idEstoque),
    Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Produto_idProduto, Estoque_idEstoque)
);

-- --------------------------------------------------------------------
-- 11. Tabela: Fornecedor
-- --------------------------------------------------------------------
CREATE TABLE Fornecedor (
    idFornecedor SERIAL PRIMARY KEY,
    Razao_Social VARCHAR(100) NOT NULL,
    CNPJ VARCHAR(18) NOT NULL UNIQUE
);

-- --------------------------------------------------------------------
-- 12. Tabela associativa: Disponibilizando_um_produto (Fornecedor x Produto)
-- --------------------------------------------------------------------
CREATE TABLE Disponibilizando_um_produto (
    Produto_idProduto INT NOT NULL REFERENCES Produto(idProduto),
    Fornecedor_idFornecedor INT NOT NULL REFERENCES Fornecedor(idFornecedor),
    PRIMARY KEY (Produto_idProduto, Fornecedor_idFornecedor)
);

-- --------------------------------------------------------------------
-- 13. Tabela: Terceiro - Vendedor (Marketplace)
-- --------------------------------------------------------------------
CREATE TABLE Terceiro_Vendedor (
    idTerceiro_Vendedor SERIAL PRIMARY KEY,
    Razao_Social VARCHAR(100) NOT NULL,
    Local VARCHAR(45) NOT NULL
);

-- --------------------------------------------------------------------
-- 14. Tabela associativa: Produtos por vendedor (terceiro)
-- --------------------------------------------------------------------
CREATE TABLE Produtos_por_vendedor_terceiro (
    Terceiro_Vendedor_idTerceiro_Vendedor INT NOT NULL REFERENCES Terceiro_Vendedor(idTerceiro_Vendedor),
    Produto_idProduto INT NOT NULL REFERENCES Produto(idProduto),
    Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto)
);
