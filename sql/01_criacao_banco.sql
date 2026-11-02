-- ============================================================
-- ERP ROTA DOS TEMPEROS
-- Arquivo: 01_criacao_banco.sql
-- Banco de dados: MySQL 8.0.16 ou superior
-- Ordem de execução: 1º
-- ============================================================

-- Este arquivo cria o banco e suas 20 tabelas, sem inserir registros.
-- Ao terminar, o banco estará vazio e pronto para receber a carga válida.

-- 1. Vamos criar o banco de dados que armazenará as informações do ERP.
-- O utf8mb4 permite salvar corretamente textos em português, como
-- nomes com acentos

CREATE DATABASE erp_rota_temperos
    CHARACTER SET utf8mb4;
    
USE erp_rota_temperos;

-- ============================================================
-- 2. CADASTROS: pessoas, clientes, funcionários, fornecedores e produtos
-- ============================================================

-- 2.1 Vamos criar a tabela PESSOA.
-- Ela guarda o nome e o CPF de cada pessoa cadastrada. O mesmo cadastro
-- pode ser usado para identificar um funcionário ou um contato de cliente.
CREATE TABLE PESSOA (
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    PRIMARY KEY (cpf)
);

-- 2.2 Vamos criar a tabela PESSOA_TELEFONE.
-- Cada telefone fica em uma linha separada, ligado à pessoa pelo CPF.
-- Assim, uma pessoa pode ter mais de um telefone sem juntar vários números
-- em uma única coluna.
CREATE TABLE PESSOA_TELEFONE (
    cpf CHAR(11) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (cpf, telefone),
    FOREIGN KEY (cpf) REFERENCES PESSOA (cpf)
);

-- 2.3 Vamos criar a tabela PESSOA_EMAIL.
-- Cada e-mail fica em uma linha própria e é relacionado à pessoa pelo CPF.
-- Isso permite cadastrar mais de um e-mail para a mesma pessoa.
CREATE TABLE PESSOA_EMAIL (
    cpf CHAR(11) NOT NULL,
    email VARCHAR(150) NOT NULL,
    PRIMARY KEY (cpf, email),
    FOREIGN KEY (cpf) REFERENCES PESSOA (cpf)
);

-- 2.4 Vamos criar a tabela PESSOA_ENDERECO.
-- Cada endereço fica em uma linha própria, relacionado à pessoa pelo CPF.
-- Dessa forma, a tabela PESSOA não precisa guardar uma lista de endereços.
CREATE TABLE PESSOA_ENDERECO (
    cpf CHAR(11) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    PRIMARY KEY (cpf, endereco),
    FOREIGN KEY (cpf) REFERENCES PESSOA (cpf)
);

-- 2.5 Vamos criar a tabela CLIENTE.
-- Aqui cadastramos o estabelecimento comercial, identificado pelo CNPJ.
-- Os dados da pessoa que representa o estabelecimento ficam em PESSOA e
-- o vínculo entre eles será registrado na tabela CLIENTE_CONTATO.
CREATE TABLE CLIENTE (
    cnpj CHAR(14) NOT NULL,
    razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150) NULL,
    observacao TEXT NULL,
    PRIMARY KEY (cnpj)
);

-- 2.6 Vamos criar a tabela CLIENTE_CONTATO.
-- Ela relaciona um estabelecimento cliente a uma ou mais pessoas de contato.
-- A chave composta (CNPJ + CPF) identifica cada vínculo sem repetir a mesma
-- pessoa como contato do mesmo estabelecimento.
CREATE TABLE CLIENTE_CONTATO (
    cnpj CHAR(14) NOT NULL,
    cpf CHAR(11) NOT NULL,
    PRIMARY KEY (cnpj, cpf),
    FOREIGN KEY (cnpj) REFERENCES CLIENTE (cnpj),
    FOREIGN KEY (cpf) REFERENCES PESSOA (cpf)
);

-- 2.7 Vamos criar a tabela FUNCIONARIO.
-- Ela guarda os dados profissionais do funcionário. O CPF também existe
-- na tabela PESSOA, que mantém o nome e o cadastro básico dessa pessoa.
CREATE TABLE FUNCIONARIO (
    cpf CHAR(11) NOT NULL,
    cargo VARCHAR(80) NOT NULL,
    data_admissao DATE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (cpf),
    FOREIGN KEY (cpf) REFERENCES PESSOA (cpf),
    CHECK (salario >= 0)
);

-- 2.8 Vamos criar a tabela FORNECEDOR.
-- Ela armazena os dados comerciais dos fornecedores, identificados pelo CNPJ,
-- como razão social, telefone, e-mail e endereço.
CREATE TABLE FORNECEDOR (
    cnpj CHAR(14) NOT NULL,
    razao_social VARCHAR(150) NOT NULL,
    telefone VARCHAR(20) NULL,
    email VARCHAR(150) NULL,
    endereco VARCHAR(255) NULL,
    PRIMARY KEY (cnpj)
);

-- 2.9 Vamos criar a tabela PRODUTO.
-- Ela guarda o cadastro dos itens vendidos, incluindo categoria, unidade,
-- preço de venda e estoque mínimo. quantidade_inicial registra a quantidade
-- existente na data_contagem, usada como ponto de partida do cálculo do estoque.
CREATE TABLE PRODUTO (
    codigo_produto VARCHAR(20) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    estoque_minimo DECIMAL(10,3) NOT NULL DEFAULT 0,
    quantidade_inicial DECIMAL(10,3) NOT NULL DEFAULT 0,
    data_contagem DATE NOT NULL,
    PRIMARY KEY (codigo_produto),
    CHECK (preco_venda >= 0),
    CHECK (estoque_minimo >= 0),
    CHECK (quantidade_inicial >= 0)
);

-- ============================================================
-- 3. VENDAS E COMPRAS
-- As tabelas a seguir registram os pedidos de venda, as compras e seus itens.
-- ============================================================

-- 3.1 Vamos criar a tabela PEDIDO.
-- Cada registro representa uma venda. O CNPJ do cliente pode ficar vazio
-- quando a venda for avulsa. Também registramos o funcionário responsável,
-- o valor, o desconto e, quando houver, os dados de cancelamento/aprovação.
CREATE TABLE PEDIDO (
    id_pedido INT NOT NULL,
    data_pedido DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
    cnpj_cliente CHAR(14) NULL,
    cpf_funcionario CHAR(11) NOT NULL,
    cpf_aprovador CHAR(11) NULL,
    data_cancelamento DATE NULL,
    motivo_cancelamento VARCHAR(255) NULL,
    PRIMARY KEY (id_pedido),
    FOREIGN KEY (cnpj_cliente) REFERENCES CLIENTE (cnpj),
    FOREIGN KEY (cpf_funcionario) REFERENCES FUNCIONARIO (cpf),
    FOREIGN KEY (cpf_aprovador) REFERENCES FUNCIONARIO (cpf),
    CHECK (status IN ('ABERTO','PARCIAL','CONCLUIDO','CANCELADO')),
    CHECK (valor_total >= 0),
    CHECK (desconto >= 0)
);

-- 3.2 Vamos criar a tabela ORDEM_COMPRA.
-- Cada registro representa uma compra feita a um fornecedor. A tabela guarda
-- a data, o fornecedor, o funcionário responsável, o valor e a situação da compra.
CREATE TABLE ORDEM_COMPRA (
    numero_ordem_compra INT NOT NULL,
    data_ordem DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    cnpj_fornecedor CHAR(14) NOT NULL,
    cpf_funcionario CHAR(11) NOT NULL,
    data_cancelamento DATE NULL,
    motivo_cancelamento VARCHAR(255) NULL,
    PRIMARY KEY (numero_ordem_compra),
    FOREIGN KEY (cnpj_fornecedor) REFERENCES FORNECEDOR (cnpj),
    FOREIGN KEY (cpf_funcionario) REFERENCES FUNCIONARIO (cpf),
    CHECK (status IN ('ABERTA','PARCIAL','RECEBIDA','CANCELADA')),
    CHECK (valor_total >= 0)
);

-- 3.3 Vamos criar a tabela ITEM_PEDIDO.
-- Ela informa quais produtos fazem parte de cada venda, com quantidade e
-- preço praticado. A chave composta (pedido + produto) identifica cada item
-- dentro de uma venda e as chaves estrangeiras ligam pedido e produto.
CREATE TABLE ITEM_PEDIDO (
    id_pedido INT NOT NULL,
    codigo_produto VARCHAR(20) NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, codigo_produto),
    FOREIGN KEY (id_pedido) REFERENCES PEDIDO (id_pedido),
    FOREIGN KEY (codigo_produto) REFERENCES PRODUTO (codigo_produto),
    CHECK (quantidade > 0),
    CHECK (preco_unitario >= 0)
);

-- 3.4 Vamos criar a tabela ITEM_ORDEM_COMPRA.
-- Ela lista os produtos solicitados em cada compra, com quantidade e preço
-- unitário. A chave composta identifica o produto dentro daquela ordem de compra.
CREATE TABLE ITEM_ORDEM_COMPRA (
    numero_ordem_compra INT NOT NULL,
    codigo_produto VARCHAR(20) NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (numero_ordem_compra, codigo_produto),
    FOREIGN KEY (numero_ordem_compra) REFERENCES ORDEM_COMPRA (numero_ordem_compra),
    FOREIGN KEY (codigo_produto) REFERENCES PRODUTO (codigo_produto),
    CHECK (quantidade > 0),
    CHECK (preco_unitario >= 0)
);

-- ============================================================
-- 4. ESTOQUE: ENTRADAS E SAÍDAS
-- Aqui registramos cada movimentação, inclusive quando a entrega ou o
-- recebimento de um item acontece em mais de uma etapa.
-- ============================================================

-- 4.1 Vamos criar a tabela MOVIMENTACAO_SAIDA.
-- Ela registra cada entrega de um produto vendido. O número da entrega faz
-- parte da chave para permitir que o mesmo item seja entregue em várias etapas,
-- sem perder o histórico de cada saída do estoque.
CREATE TABLE MOVIMENTACAO_SAIDA (
    id_pedido INT NOT NULL,
    codigo_produto VARCHAR(20) NOT NULL,
    numero_entrega INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    data_movimentacao DATE NOT NULL,
    PRIMARY KEY (id_pedido, codigo_produto, numero_entrega),
    FOREIGN KEY (id_pedido, codigo_produto)
        REFERENCES ITEM_PEDIDO (id_pedido, codigo_produto),
    CHECK (numero_entrega > 0),
    CHECK (quantidade > 0)
);

-- 4.2 Vamos criar a tabela MOVIMENTACAO_ENTRADA.
-- Ela registra cada recebimento de um produto comprado. O número do recebimento
-- permite registrar entregas parciais do fornecedor para uma mesma ordem de compra.
CREATE TABLE MOVIMENTACAO_ENTRADA (
    numero_ordem_compra INT NOT NULL,
    codigo_produto VARCHAR(20) NOT NULL,
    numero_recebimento INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    data_movimentacao DATE NOT NULL,
    PRIMARY KEY (numero_ordem_compra, codigo_produto, numero_recebimento),
    FOREIGN KEY (numero_ordem_compra, codigo_produto)
        REFERENCES ITEM_ORDEM_COMPRA (numero_ordem_compra, codigo_produto),
    CHECK (numero_recebimento > 0),
    CHECK (quantidade > 0)
);

-- ============================================================
-- 5. FINANCEIRO: CONTAS, RECEBIMENTOS E PAGAMENTOS
-- Primeiro registramos as parcelas a receber e a pagar. Depois registramos
-- cada entrada ou saída de dinheiro que realmente aconteceu.
-- ============================================================

-- 5.1 Vamos criar a tabela CONTAS_A_RECEBER.
-- Ela registra os valores que a empresa tem a receber por venda, separados
-- por parcela. A chave composta identifica cada parcela dentro do pedido.
CREATE TABLE CONTAS_A_RECEBER (
    id_pedido INT NOT NULL,
    numero_parcela INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    PRIMARY KEY (id_pedido, numero_parcela),
    FOREIGN KEY (id_pedido) REFERENCES PEDIDO (id_pedido),
    CHECK (numero_parcela > 0),
    CHECK (valor >= 0),
    CHECK (status IN ('ABERTA','PARCIAL','PAGA','ATRASADA','CANCELADA'))
);

-- 5.2 Vamos criar a tabela RECEBIMENTO.
-- Cada linha representa um valor que entrou efetivamente no caixa para quitar
-- uma parcela. Assim, a mesma parcela pode receber vários pagamentos parciais.
CREATE TABLE RECEBIMENTO (
    id_pedido INT NOT NULL,
    numero_parcela INT NOT NULL,
    numero_recebimento INT NOT NULL,
    valor_recebido DECIMAL(10,2) NOT NULL,
    data_recebimento DATE NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_pedido, numero_parcela, numero_recebimento),
    FOREIGN KEY (id_pedido, numero_parcela)
        REFERENCES CONTAS_A_RECEBER (id_pedido, numero_parcela),
    CHECK (numero_recebimento > 0),
    CHECK (valor_recebido > 0)
);

-- 5.3 Vamos criar a tabela CONTAS_A_PAGAR.
-- Ela registra os valores que a empresa deve pagar por compra, separados
-- por parcela, incluindo vencimento e situação da obrigação.
CREATE TABLE CONTAS_A_PAGAR (
    numero_ordem_compra INT NOT NULL,
    numero_parcela INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    numero_boleto VARCHAR(60) NULL,
    PRIMARY KEY (numero_ordem_compra, numero_parcela),
    FOREIGN KEY (numero_ordem_compra) REFERENCES ORDEM_COMPRA (numero_ordem_compra),
    CHECK (numero_parcela > 0),
    CHECK (valor >= 0),
    CHECK (status IN ('ABERTA','PARCIAL','PAGA','ATRASADA','CANCELADA'))
);

-- 5.4 Vamos criar a tabela PAGAMENTO.
-- Cada linha representa um pagamento efetivamente realizado para uma parcela.
-- Mais de um registro pode existir para a mesma parcela quando o pagamento
-- for feito em partes.
CREATE TABLE PAGAMENTO (
    numero_ordem_compra INT NOT NULL,
    numero_parcela INT NOT NULL,
    numero_pagamento INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento DATE NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    comprovante VARCHAR(255) NULL,
    PRIMARY KEY (numero_ordem_compra, numero_parcela, numero_pagamento),
    FOREIGN KEY (numero_ordem_compra, numero_parcela)
        REFERENCES CONTAS_A_PAGAR (numero_ordem_compra, numero_parcela),
    CHECK (numero_pagamento > 0),
    CHECK (valor_pago > 0)
);

-- No fluxo de caixa, usamos RECEBIMENTO e PAGAMENTO para considerar somente
-- o dinheiro que realmente entrou ou saiu. Esta tabela guarda o saldo que já
-- existia no caixa na data em que o controle começou.
-- 5.5 Vamos criar a tabela SALDO_INICIAL_CAIXA.
-- Ela registra quanto dinheiro já existia no caixa na data de referência.
-- Esse valor será somado aos recebimentos e diminuído dos pagamentos para
-- calcular o saldo final do período.
CREATE TABLE SALDO_INICIAL_CAIXA (
    data_referencia DATE NOT NULL,
    valor_inicial DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (data_referencia),
    CHECK (valor_inicial >= 0)
);
