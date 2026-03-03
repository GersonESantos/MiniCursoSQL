-- 1. CRIAÇÃO DA TABELA MARCAS
CREATE TABLE marcas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    site VARCHAR(100),
    telefone VARCHAR(15)
);

-- 2. CRIAÇÃO DA TABELA PRODUTOS
CREATE TABLE produtos (
    id INT IDENTITY(1,1) PRIMARY KEY, 
    nome VARCHAR(100) NOT NULL, 
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0
);

-- 3. ALTERAÇÃO PARA ADICIONAR CHAVE ESTRANGEIRA
ALTER TABLE produtos ADD id_marca INT NOT NULL;
ALTER TABLE produtos ALTER COLUMN nome VARCHAR(150);
ALTER TABLE produtos ADD CONSTRAINT FK_produtos_marcas FOREIGN KEY (id_marca) REFERENCES marcas(id);

-- 4. ÍNDICE
CREATE INDEX idx_produtos_nome ON produtos (nome);

-- 5. INSERÇÃO DE MARCAS
INSERT INTO marcas (nome, site, telefone) VALUES
('Apple', 'apple.com', '0800-761-0867'), 
('Dell', 'dell.com.br', '0800-970-3355'), 
('Herman Miller', 'hermanmiller.com.br', '(11) 3474-8043'),
('Shure', 'shure.com.br', '0800-970-3355');

SELECT * FROM marcas;

EXEC sp_help 'marcas';
-- 6. INSERÇÃO DE PRODUTOS
INSERT INTO produtos (nome, preco, estoque, id_marca) VALUES
('iPhone 16 Pro Apple (256GB) - Titânio Preto', 9299.99, 100, 1),
('iPhone 15 Apple (128GB) - Preto', 4599.00, 50, 1),
('MacBook Air 15" M2 (8GB RAM , 512GB SSD) - Prateado', 8899.99, 23, 1),
('Notebook Inspiron 16 Plus', 10398.00, 300, 2),
('Cadeira Aeron - Grafite', 15540.00, 8, 3),
('Microfone MV7 USB', 2999.99, 70, 4),
('Microfone SM7B', 5579.99, 30, 4);

-- 7. TABELA DE CLIENTES
CREATE TABLE clientes (
  id INT IDENTITY(1,1) PRIMARY KEY, 
  nome VARCHAR(100) NOT NULL, 
  email VARCHAR(100) UNIQUE NOT NULL, 
  cidade VARCHAR(200), 
  data_nascimento DATE 
);

-- 8. TABELA DE PEDIDOS (Usando GETDATE() em vez de NOW)
CREATE TABLE pedidos (
  id INT IDENTITY(1,1) PRIMARY KEY,
  data_pedido DATE DEFAULT (GETDATE()),
  id_cliente INT,
  valor_total DECIMAL(10,2),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

-- 9. ITENS DO PEDIDO
CREATE TABLE itens_pedido (
  id_pedido INT,
  id_produto INT,
  quantidade INT,
  preco_unitario DECIMAL(10,2),
  FOREIGN KEY (id_pedido) REFERENCES pedidos(id), 
  FOREIGN KEY (id_produto) REFERENCES produtos(id), 
  PRIMARY KEY (id_pedido, id_produto)
);

-- 10. INSERT CLIENTES
INSERT INTO clientes (nome, email, cidade) VALUES
('João Pereira', 'joao@exemplo.com.br', 'Rio de Janeiro'),
('Ana Costa', 'ana@costa.com', 'São Paulo'),
('Carlos Souza', 'carlos@gmail.com', 'Belo Horizonte'),
('Vanessa Weber', 'vanessa@codigofonte.tv', 'São José dos Campos'),
('Gabriel Fróes', 'gabriel@codigofonte.tv', 'São José dos Campos');

-- 11. EXEMPLO DE SELECT COM TOP (Substituindo o LIMIT)
SELECT TOP 5 *
FROM produtos
ORDER BY preco DESC;

-- 12. INNER JOIN
SELECT
    clientes.nome,
    pedidos.valor_total
FROM
    clientes
    INNER JOIN pedidos ON clientes.id = pedidos.id_cliente;