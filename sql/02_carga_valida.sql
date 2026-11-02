-- ============================================================
-- ERP ROTA DOS TEMPEROS
-- Arquivo: 02_carga_valida.sql
-- Banco de dados: MySQL 8.0.16 ou superior
-- Ordem de execução: 2º, depois de 01_criacao_banco.sql
-- ============================================================

-- Os registros abaixo são fictícios e servem para testar o funcionamento
-- dos cadastros, vendas, compras, estoque e financeiro.
-- Execute este arquivo uma única vez após criar o banco vazio.

USE erp_rota_temperos;

-- 6. INSERIR DADOS DE EXEMPLO
-- Os dados abaixo são fictícios. Eles permitem testar os cadastros,
-- as vendas, as compras, as movimentações e o controle financeiro.
-- ============================================================

-- 6.1 Cadastrar duas pessoas fictícias: um funcionário e um representante de cliente.
INSERT INTO PESSOA (cpf, nome) VALUES
('00000000001', 'Funcionario Exemplo'),
('00000000002', 'Representante Exemplo');

-- 6.2 Cadastrar os telefones das pessoas.
INSERT INTO PESSOA_TELEFONE (cpf, telefone) VALUES
('00000000001', '11900000001'),
('00000000002', '11900000002');

-- 6.3 Cadastrar os e-mails, incluindo um e-mail temporário que será excluído no final.
INSERT INTO PESSOA_EMAIL (cpf, email) VALUES
('00000000001', 'funcionario@exemplo.com'),
('00000000002', 'representante@exemplo.com'),
('00000000002', 'email-temporario@exemplo.com');

-- 6.4 Cadastrar os endereços das pessoas.
INSERT INTO PESSOA_ENDERECO (cpf, endereco) VALUES
('00000000001', 'Rua Exemplo, 100'),
('00000000002', 'Avenida Exemplo, 200');

-- 6.5 Cadastrar um estabelecimento comercial como cliente.
INSERT INTO CLIENTE (cnpj, razao_social, nome_fantasia, observacao) VALUES
('00000000000191', 'Restaurante Exemplo LTDA', 'Restaurante Exemplo', 'Cadastro ficticio para teste');

-- 6.6 Relacionar o estabelecimento à pessoa que será seu contato.
INSERT INTO CLIENTE_CONTATO (cnpj, cpf) VALUES
('00000000000191', '00000000002');

-- 6.7 Registrar a pessoa cadastrada como funcionária.
INSERT INTO FUNCIONARIO (cpf, cargo, data_admissao, salario) VALUES
('00000000001', 'Atendente', '2026-01-10', 1800.00);

-- 6.8 Cadastrar um fornecedor fictício.
INSERT INTO FORNECEDOR (cnpj, razao_social, telefone, email, endereco) VALUES
('00000000000272', 'Fornecedor Exemplo LTDA', '1130000000', 'fornecedor@exemplo.com', 'Rua do Fornecedor, 50');

-- 6.9 Cadastrar dois produtos com seus preços e quantidades de referência.
INSERT INTO PRODUTO
(codigo_produto, nome, categoria, unidade_medida, preco_venda, estoque_minimo, quantidade_inicial, data_contagem)
VALUES
('ARROZ01', 'Arroz', 'Graos', 'kg', 30.00, 2.000, 0.000, '2026-10-28'),
('PAPR01', 'Paprica', 'Temperos', 'kg', 45.00, 1.000, 0.000, '2026-10-27');

-- 6.10 Cadastrar duas vendas: uma para um estabelecimento e uma venda avulsa.
INSERT INTO PEDIDO
(id_pedido, data_pedido, status, valor_total, desconto, cnpj_cliente, cpf_funcionario)
VALUES
(1001, '2026-11-01', 'CONCLUIDO', 300.00, 0.00, '00000000000191', '00000000001'),
(1002, '2026-10-27', 'PARCIAL', 45.00, 0.00, NULL, '00000000001');

-- 6.11 Cadastrar duas compras feitas ao fornecedor.
INSERT INTO ORDEM_COMPRA
(numero_ordem_compra, data_ordem, status, valor_total, cnpj_fornecedor, cpf_funcionario)
VALUES
(2001, '2026-10-28', 'RECEBIDA', 200.00, '00000000000272', '00000000001'),
(2002, '2026-10-27', 'PARCIAL', 80.00, '00000000000272', '00000000001');

-- 6.12 Informar os produtos e as quantidades de cada venda.
INSERT INTO ITEM_PEDIDO (id_pedido, codigo_produto, quantidade, preco_unitario) VALUES
(1001, 'ARROZ01', 10.000, 30.00),
(1002, 'PAPR01', 1.000, 45.00);

-- 6.13 Informar os produtos e as quantidades de cada compra.
INSERT INTO ITEM_ORDEM_COMPRA (numero_ordem_compra, codigo_produto, quantidade, preco_unitario) VALUES
(2001, 'ARROZ01', 10.000, 20.00),
(2002, 'PAPR01', 2.000, 40.00);

-- 6.14 Inserir dois recebimentos parciais de 5 kg para a mesma compra.
INSERT INTO MOVIMENTACAO_ENTRADA
(numero_ordem_compra, codigo_produto, numero_recebimento, quantidade, data_movimentacao)
VALUES
(2001, 'ARROZ01', 1, 5.000, '2026-10-29'),
(2001, 'ARROZ01', 2, 5.000, '2026-10-30');

-- 6.15 Inserir três entregas parciais que, juntas, totalizam os 10 kg vendidos.
INSERT INTO MOVIMENTACAO_SAIDA
(id_pedido, codigo_produto, numero_entrega, quantidade, data_movimentacao)
VALUES
(1001, 'ARROZ01', 1, 3.000, '2026-11-01'),
(1001, 'ARROZ01', 2, 4.000, '2026-11-02'),
(1001, 'ARROZ01', 3, 3.000, '2026-11-03');

-- 6.16 Registrar as parcelas que a empresa tem a receber das vendas.
INSERT INTO CONTAS_A_RECEBER
(id_pedido, numero_parcela, valor, data_vencimento, status)
VALUES
(1001, 1, 300.00, '2026-11-10', 'PAGA'),
(1002, 1, 45.00, '2026-10-31', 'ATRASADA');

-- 6.17 Registrar os valores que já foram recebidos, inclusive em partes.
INSERT INTO RECEBIMENTO
(id_pedido, numero_parcela, numero_recebimento, valor_recebido, data_recebimento, forma_pagamento)
VALUES
(1001, 1, 1, 100.00, '2026-11-01', 'PIX'),
(1001, 1, 2, 200.00, '2026-11-01', 'PIX'),
(1002, 1, 1, 15.00, '2026-10-30', 'PIX');

-- 6.18 Registrar as parcelas que a empresa precisa pagar pelas compras.
INSERT INTO CONTAS_A_PAGAR
(numero_ordem_compra, numero_parcela, valor, data_vencimento, status, numero_boleto)
VALUES
(2001, 1, 200.00, '2026-11-10', 'PAGA', 'BOLETO-TESTE-2001'),
(2002, 1, 80.00, '2026-10-31', 'ATRASADA', NULL);

-- 6.19 Registrar os pagamentos que já foram realizados, inclusive parcialmente.
INSERT INTO PAGAMENTO
(numero_ordem_compra, numero_parcela, numero_pagamento, valor_pago, data_pagamento, forma_pagamento, comprovante)
VALUES
(2001, 1, 1, 200.00, '2026-11-01', 'BOLETO', 'comprovante-ficticio-2001'),
(2002, 1, 1, 30.00, '2026-10-30', 'PIX', NULL);

-- 6.20 Registrar o saldo que já existia no caixa no início do controle.
INSERT INTO SALDO_INICIAL_CAIXA (data_referencia, valor_inicial)
VALUES ('2026-11-01', 500.00);

-- ============================================================
-- 7. EXEMPLO DE REGISTRO DE NOVAS MOVIMENTAÇÕES
-- ============================================================

-- Para registrar outra entrega, buscamos o maior número já usado para aquele
-- pedido e produto e acrescentamos 1. Assim, cada entrega recebe uma numeração
-- própria. A mesma lógica é usada para registrar um novo recebimento de compra.
INSERT INTO MOVIMENTACAO_SAIDA
(id_pedido, codigo_produto, numero_entrega, quantidade, data_movimentacao)
SELECT 1002, 'PAPR01', IFNULL(MAX(numero_entrega), 0) + 1,
       0.250, '2026-10-29'
FROM MOVIMENTACAO_SAIDA
WHERE id_pedido = 1002 AND codigo_produto = 'PAPR01';

INSERT INTO MOVIMENTACAO_ENTRADA
(numero_ordem_compra, codigo_produto, numero_recebimento, quantidade, data_movimentacao)
SELECT 2002, 'PAPR01', IFNULL(MAX(numero_recebimento), 0) + 1,
       0.500, '2026-10-28'
FROM MOVIMENTACAO_ENTRADA
WHERE numero_ordem_compra = 2002 AND codigo_produto = 'PAPR01';
