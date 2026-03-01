-- 0. GARANTIR QUE ESTAMOS NO BANCO CERTO
USE estudos_sql;
GO

-- Limpar tabelas antigas se existirem (Ordem inversa por causa das FKs)
IF OBJECT_ID('dbo.itens_pedido', 'U') IS NOT NULL DROP TABLE dbo.itens_pedido;
IF OBJECT_ID('dbo.pedidos', 'U') IS NOT NULL DROP TABLE dbo.pedidos;
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.produtos', 'U') IS NOT NULL DROP TABLE dbo.produtos;
IF OBJECT_ID('dbo.marcas', 'U') IS NOT NULL DROP TABLE dbo.marcas;
GO

-- 1. CRIAÇÃO DA TABELA MARCAS
CREATE TABLE marcas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    site VARCHAR(100),
    telefone VARCHAR(15)
);
GO

-- 2. CRIAÇÃO DA TABELA PRODUTOS (Já com id_marca incluso)
CREATE TABLE produtos (
    id INT IDENTITY(1,1) PRIMARY KEY, 
    nome VARCHAR(150) NOT NULL, -- Já com o tamanho corrigido
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    id_marca INT NOT NULL, -- Coluna incluída aqui para evitar erro de consulta
    CONSTRAINT FK_produtos_marcas FOREIGN KEY (id_marca) REFERENCES marcas(id)
);
GO

-- 3. ÍNDICE
CREATE INDEX idx_produtos_nome ON produtos (nome);
GO

-- 4. INSERÇÃO DE MARCAS
INSERT INTO marcas (nome, site, telefone) VALUES
('Apple', 'apple.com', '0800-761-0867'), 
('Dell', 'dell.com.br', '0800-970-3355'), 
('Herman Miller', 'hermanmiller.com.br', '(11) 3474-8043'),
('Shure', 'shure.com.br', '0800-970-3355');
GO

-- 5. INSERÇÃO DE PRODUTOS
INSERT INTO produtos (nome, preco, estoque, id_marca) VALUES
('iPhone 16 Pro Apple (256GB) - Titânio Preto', 9299.99, 100, 1),
('iPhone 15 Apple (128GB) - Preto', 4599.00, 50, 1),
('MacBook Air 15" M2 (8GB RAM , 512GB SSD)', 8899.99, 23, 1),
('Notebook Inspiron 16 Plus', 10398.00, 300, 2),
('Cadeira Aeron - Grafite', 15540.00, 8, 3),
('Microfone MV7 USB', 2999.99, 70, 4),
('Microfone SM7B', 5579.99, 30, 4);
GO

-- 6. TABELA DE CLIENTES
CREATE TABLE clientes (
  id INT IDENTITY(1,1) PRIMARY KEY, 
  nome VARCHAR(100) NOT NULL, 
  email VARCHAR(100) UNIQUE NOT NULL, 
  cidade VARCHAR(200), 
  data_nascimento DATE 
);
GO

-- 7. TABELA DE PEDIDOS
CREATE TABLE pedidos (
  id INT IDENTITY(1,1) PRIMARY KEY,
  data_pedido DATE DEFAULT (GETDATE()),
  id_cliente INT,
  valor_total DECIMAL(10,2),
  CONSTRAINT FK_pedidos_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);
GO

-- 8. ITENS DO PEDIDO
CREATE TABLE itens_pedido (
  id_pedido INT,
  id_produto INT,
  quantidade INT,
  preco_unitario DECIMAL(10,2),
  CONSTRAINT FK_itens_pedidos FOREIGN KEY (id_pedido) REFERENCES pedidos(id), 
  CONSTRAINT FK_itens_produtos FOREIGN KEY (id_produto) REFERENCES produtos(id), 
  PRIMARY KEY (id_pedido, id_produto)
);
GO

-- 9. INSERT CLIENTES
INSERT INTO clientes (nome, email, cidade) VALUES
('João Pereira', 'joao@exemplo.com.br', 'Rio de Janeiro'),
('Ana Costa', 'ana@costa.com', 'São Paulo'),
('Carlos Souza', 'carlos@gmail.com', 'Belo Horizonte'),
('Vanessa Weber', 'vanessa@codigofonte.tv', 'São José dos Campos'),
('Gabriel Fróes', 'gabriel@codigofonte.tv', 'São José dos Campos');
GO
-- Relatório: Qual cliente comprou qual produto e de qual marca?
SELECT 
    C.nome AS Cliente,
    P.nome AS Produto,
    M.nome AS Marca,
    I.quantidade AS Qtd,
    I.preco_unitario AS Preco
FROM clientes C
INNER JOIN pedidos Ped ON C.id = Ped.id_cliente
INNER JOIN itens_pedido I ON Ped.id = I.id_pedido
INNER JOIN produtos P ON I.id_produto = P.id
INNER JOIN marcas M ON P.id_marca = M.id;

USE estudos_sql;
GO

-- 1. CRIANDO OS PEDIDOS (Cabeçalho)
-- Pedido 1 para João (ID 1), Pedido 2 para Vanessa (ID 4), Pedido 3 para Gabriel (ID 5)
INSERT INTO pedidos (id_cliente, valor_total, data_pedido) VALUES
(1, 18199.98, GETDATE()), -- João
(4, 15540.00, GETDATE()), -- Vanessa
(5, 8579.98, GETDATE());  -- Gabriel
GO

-- 2. ADICIONANDO OS ITENS DOS PEDIDOS (Detalhes)
-- Pedido 1 (João): iPhone 16 Pro (Prod 1) e MacBook Air (Prod 3)
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 9299.99),
(1, 3, 1, 8899.99);

-- Pedido 2 (Vanessa): Cadeira Aeron (Prod 5)
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(2, 5, 1, 15540.00);

-- Pedido 3 (Gabriel): Microfone MV7 (Prod 6) e Microfone SM7B (Prod 7)
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(3, 6, 1, 2999.99),
(3, 7, 1, 5579.99);
GO

-- 3. O GRANDE RELATÓRIO (O "SELECT" QUE CRUZA TUDO)
SELECT 
    C.nome AS [Nome do Cliente],
    P.nome AS [Produto Comprado],
    M.nome AS [Marca],
    I.quantidade AS [Qtd],
    FORMAT(I.preco_unitario, 'C', 'pt-br') AS [Preço Unitário],
    FORMAT(Ped.valor_total, 'C', 'pt-br') AS [Total do Pedido]
FROM clientes C
INNER JOIN pedidos Ped ON C.id = Ped.id_cliente
INNER JOIN itens_pedido I ON Ped.id = I.id_pedido
INNER JOIN produtos P ON I.id_produto = P.id
INNER JOIN marcas M ON P.id_marca = M.id
ORDER BY C.nome;

USE estudos_sql;
GO

-- RANKING DE VENDAS POR MARCA
-- Agrupando o total vendido por cada fabricante
SELECT 
    M.nome AS [Marca],
    COUNT(I.id_produto) AS [Total de Itens Vendidos],
    FORMAT(SUM(I.quantidade * I.preco_unitario), 'C', 'pt-br') AS [Faturamento Total]
FROM marcas M
INNER JOIN produtos P ON M.id = P.id_marca
INNER JOIN itens_pedido I ON P.id = I.id_produto
GROUP BY M.nome
ORDER BY SUM(I.quantidade * I.preco_unitario) DESC;
GO