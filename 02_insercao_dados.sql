-- ====================================================================
-- PROJETO DE BANCO DE DADOS: E-COMMERCE (DIO / PORTFÓLIO)
-- Arquivo: 02_insercao_dados.sql
-- Descrição: Povoamento do banco de dados com dados de teste
-- SGBD: PostgreSQL
-- ====================================================================

-- 1. Inserção de Clientes (respeitando a regra de exclusividade PF e PJ)
-- Clientes PF (Pessoa Física):
INSERT INTO Cliente (nome, email, telefone, Endereco, tipo_cliente, data_cadastro, cpf, data_nascimento) VALUES
('Lucas Mendes', 'lucas.mendes@email.com', '11988881111', 'Rua das Flores, 120 - SP', 'PF', '2025-01-10 10:00:00', '123.456.789-01', '1995-04-12'),
('Mariana Lima', 'mariana.lima@email.com', '21977772222', 'Av. Copacabana, 450 - RJ', 'PF', '2025-01-15 14:30:00', '234.567.890-12', '1988-11-23'),
('Carlos Eduardo', 'carlos.edu@email.com', '31966663333', 'Rua Bahia, 88 - MG', 'PF', '2025-02-01 09:15:00', '345.678.901-23', '2001-08-05'),
('Beatriz Ramos', 'beatriz.ramos@email.com', '41955554444', 'Rua XV de Novembro, 300 - PR', 'PF', '2025-03-01 11:00:00', '456.789.012-34', '1992-02-17'); -- Cliente sem compras (para teste de Churn)

-- Clientes PJ (Pessoa Jurídica):
INSERT INTO Cliente (nome, email, telefone, Endereco, tipo_cliente, data_cadastro, cnpj, razao_social, nome_fantasia) VALUES
('Tech Corp Soluções', 'contato@techcorp.com', '1133330000', 'Av. Paulista, 1000 - SP', 'PJ', '2025-01-05 08:00:00', '11.222.333/0001-44', 'Tech Corp Soluções Tecnológicas Ltda', 'TechCorp'),
('Inova Varejo', 'compras@inovavarejo.com', '1932321111', 'Av. Barão de Itapura, 50 - SP', 'PJ', '2025-02-10 16:40:00', '22.333.444/0001-55', 'Inovação e Comércio Varejista SA', 'InovaVarejo');

-- 2. Formas de Pagamento cadastradas pelos clientes
INSERT INTO Forma_Pagamento (tipo_pagamento, Cliente_idCliente) VALUES
('Cartão de Crédito', 1),
('Pix', 1),
('Cartão de Crédito', 2),
('Boleto Bancário', 3),
('Pix', 5),
('Boleto Faturado', 6);

-- 3. Cadastro de Produtos
INSERT INTO Produto (Categoria, Descricao, Valor) VALUES
('Eletrônicos', 'Monitor Ultrawide 29 LG', 1250.00),
('Eletrônicos', 'Teclado Mecânico RGB Switch Red', 380.00),
('Eletrônicos', 'Mouse Gamer Sem Fio 16000 DPI', 220.00),
('Móveis', 'Mesa Gamer em L com Suporte', 850.00),
('Móveis', 'Cadeira Ergonômica NR17 Mesh', 1190.00),
('Acessórios', 'Headset Bluetooth com Cancelamento Ruído', 450.00),
('Acessórios', 'Hub USB-C 7 em 1 com HDMI 4K', 180.00);

-- 4. Registro de Pedidos
INSERT INTO Pedido (Status_do_Pedido, Descricao, Cliente_idCliente, Frete) VALUES
('Concluído', 'Pedido eletrônicos home-office', 1, 35.00),   -- Pedido 1 (Lucas)
('Concluído', 'Upgrade periféricos', 1, 20.00),            -- Pedido 2 (Lucas - Recompra)
('Concluído', 'Setup ergonômico', 2, 60.00),               -- Pedido 3 (Mariana)
('Concluído', 'Acessórios diversos', 3, 15.00),            -- Pedido 4 (Carlos)
('Concluído', 'Compra corporativa monitores', 5, 120.00),  -- Pedido 5 (TechCorp PJ)
('Concluído', 'Teclado e mouse reposição', 1, 25.00);      -- Pedido 6 (Lucas - 3ª compra)

-- 5. Itens do Pedido (Relacao_de_Produto_pedido)
INSERT INTO Relacao_de_Produto_pedido (Produto_idProduto, Pedido_idPedido, Quantidade) VALUES
(1, 1, 1), -- Pedido 1: 1 Monitor
(3, 1, 1), -- Pedido 1: 1 Mouse
(2, 2, 1), -- Pedido 2: 1 Teclado
(6, 2, 1), -- Pedido 2: 1 Headset
(4, 3, 1), -- Pedido 3: 1 Mesa Gamer
(5, 3, 1), -- Pedido 3: 1 Cadeira
(7, 4, 2), -- Pedido 4: 2 Hubs USB-C
(1, 5, 4), -- Pedido 5: 4 Monitores (Corporativo)
(2, 6, 1), -- Pedido 6: 1 Teclado
(3, 6, 1); -- Pedido 6: 1 Mouse

-- 6. Pagamentos dos Pedidos
INSERT INTO Pagamento_pedido (valor, status, Pedido_idPedido, Forma_Pagamento_idForma_Pagamento) VALUES
(1505.00, 'Aprovado', 1, 1), -- Pedido 1 pago com Cartão de Crédito
(850.00,  'Aprovado', 2, 2), -- Pedido 2 pago com Pix
(2100.00, 'Aprovado', 3, 3), -- Pedido 3 pago com Cartão
(375.00,  'Aprovado', 4, 4), -- Pedido 4 pago com Boleto
(5120.00, 'Aprovado', 5, 5), -- Pedido 5 pago com Pix
(625.00,  'Aprovado', 6, 2); -- Pedido 6 pago com Pix

-- 7. Entregas (Logística)
INSERT INTO Entrega (status_entrega, codigo_rastreio, data_envio, data_prevista, Pedido_idPedido) VALUES
('Entregue', 'BR123456789SP', '2025-01-12 14:00:00', '2025-01-18', 1),
('Entregue', 'BR987654321SP', '2025-02-02 10:30:00', '2025-02-08', 2),
('Entregue', 'BR456123789RJ', '2025-01-22 16:00:00', '2025-01-29', 3),
('Entregue', 'BR789123456MG', '2025-02-12 11:20:00', '2025-02-19', 4),
('Entregue', 'BR321654987SP', '2025-01-25 09:00:00', '2025-02-01', 5),
('Em trânsito', 'BR654987321SP', '2025-03-05 15:45:00', '2025-03-12', 6);

-- 8. Estoque
INSERT INTO Estoque (Local) VALUES
('Centro de Distribuição São Paulo (CD-SP)'),
('Centro de Distribuição Curitiba (CD-PR)');

-- 9. Saldo em Estoque
INSERT INTO Produto_has_Estoque (Produto_idProduto, Estoque_idEstoque, Quantidade) VALUES
(1, 1, 25),
(2, 1, 100),
(3, 1, 80),
(4, 1, 15),
(5, 1, 20),
(6, 2, 50),
(7, 2, 120);

-- 10. Fornecedores
INSERT INTO Fornecedor (Razao_Social, CNPJ) VALUES
('Distribuidora Tech Global Brasil', '33.444.555/0001-66'),
('Móveis Design & Conforto Indústria', '44.555.666/0001-77');

-- 11. Disponibilizando produto (Fornecedor x Produto)
INSERT INTO Disponibilizando_um_produto (Produto_idProduto, Fornecedor_idFornecedor) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2);

-- 12. Vendedores Parceiros (Marketplace)
INSERT INTO Terceiro_Vendedor (Razao_Social, Local) VALUES
('MegaStore Informática Eireli', 'São Paulo - SP'),
('GamerZone Comércio Digital', 'Florianópolis - SC');

-- 13. Produtos por Vendedor Terceiro
INSERT INTO Produtos_por_vendedor_terceiro (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto, Quantidade) VALUES
(1, 6, 30),
(2, 7, 50);
