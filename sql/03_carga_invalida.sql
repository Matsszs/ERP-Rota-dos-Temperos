-- ============================================================
-- ERP ROTA DOS TEMPEROS
-- Arquivo: 03_carga_invalida.sql
-- Banco de dados: MySQL 8.0.16 ou superior
-- Ordem de execução: 3º, depois da carga válida
-- ============================================================

-- Este arquivo contém tentativas de inserção que devem ser REJEITADAS.
-- Execute uma tentativa por vez, selecionando somente o INSERT correspondente.
-- O erro exibido pelo MySQL é o resultado esperado: nenhum registro deve ser inserido.

USE erp_rota_temperos;

-- TESTE 1: CHECK
-- O preço negativo viola a regra de PRODUTO (preco_venda >= 0).
-- Resultado esperado: erro de CHECK (MySQL 3819).
INSERT INTO PRODUTO
    (codigo_produto, nome, categoria, unidade_medida, preco_venda,
     estoque_minimo, quantidade_inicial, data_contagem)
VALUES
    ('TESTE_CHECK', 'Produto de teste', 'Teste', 'un', -1.00,
     0.000, 0.000, '2026-11-02');

-- TESTE 2: FOREIGN KEY
-- O pedido 9999 não existe em PEDIDO.
-- Resultado esperado: erro de chave estrangeira (MySQL 1452).
INSERT INTO ITEM_PEDIDO
    (id_pedido, codigo_produto, quantidade, preco_unitario)
VALUES
    (9999, 'ARROZ01', 1.000, 30.00);

-- TESTE 3: NOT NULL
-- O campo nome é obrigatório e não pode receber NULL.
-- Resultado esperado: erro de NOT NULL (MySQL 1048).
INSERT INTO PESSOA (cpf, nome)
VALUES ('00000000003', NULL);
