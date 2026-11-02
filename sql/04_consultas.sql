-- ============================================================
-- ERP ROTA DOS TEMPEROS
-- Arquivo: 04_consultas.sql
-- Banco de dados: MySQL 8.0.16 ou superior
-- Ordem de execução: 4º, depois da carga válida
-- ============================================================

-- Consultas gerenciais, consultas de auditoria e exemplos de UPDATE e DELETE.
-- As consultas de auditoria podem retornar zero linhas quando não há divergências.
-- UPDATE e DELETE ficam no final como exemplos e alteram/removem somente registros de teste.

USE erp_rota_temperos;

-- ============================================================
-- 8. CONSULTAS GERENCIAIS
-- Estas consultas respondem perguntas úteis para acompanhar a empresa:
-- estoque disponível, vendas, valores a receber, contas a pagar e caixa.
-- ============================================================

-- 8.1 Consultar o estoque de cada produto.
-- O cálculo parte da quantidade registrada na última contagem, soma as entradas
-- posteriores e subtrai as saídas posteriores.
SELECT
    p.codigo_produto,
    p.nome,
    p.quantidade_inicial
      + IFNULL((
          SELECT SUM(me.quantidade)
          FROM MOVIMENTACAO_ENTRADA me
          WHERE me.codigo_produto = p.codigo_produto
            AND me.data_movimentacao > p.data_contagem
      ), 0)
      - IFNULL((
          SELECT SUM(ms.quantidade)
          FROM MOVIMENTACAO_SAIDA ms
          WHERE ms.codigo_produto = p.codigo_produto
            AND ms.data_movimentacao > p.data_contagem
      ), 0) AS estoque_atual,
    p.estoque_minimo
FROM PRODUTO p
ORDER BY p.nome;

-- 8.2 Encontrar produtos que chegaram ao estoque mínimo ou estão abaixo dele.
-- O resultado ajuda a identificar quais itens precisam de reposição.
SELECT *
FROM (
    SELECT
        p.codigo_produto,
        p.nome,
        p.quantidade_inicial
          + IFNULL((
              SELECT SUM(me.quantidade)
              FROM MOVIMENTACAO_ENTRADA me
              WHERE me.codigo_produto = p.codigo_produto
                AND me.data_movimentacao > p.data_contagem
          ), 0)
          - IFNULL((
              SELECT SUM(ms.quantidade)
              FROM MOVIMENTACAO_SAIDA ms
              WHERE ms.codigo_produto = p.codigo_produto
                AND ms.data_movimentacao > p.data_contagem
          ), 0) AS estoque_atual,
        p.estoque_minimo
    FROM PRODUTO p
) AS estoque
WHERE estoque_atual <= estoque_minimo;

-- 8.3 Listar os produtos com maior quantidade vendida.
-- Somamos as quantidades registradas nas saídas e ordenamos da maior para a menor.
SELECT
    p.codigo_produto,
    p.nome,
    SUM(ms.quantidade) AS quantidade_vendida
FROM MOVIMENTACAO_SAIDA ms
JOIN PRODUTO p ON p.codigo_produto = ms.codigo_produto
GROUP BY p.codigo_produto, p.nome
ORDER BY quantidade_vendida DESC;

-- 8.4 Consultar quantos pedidos cada estabelecimento realizou e o valor total
-- desses pedidos. Vendas avulsas não aparecem nesta consulta porque não têm CNPJ.
SELECT
    c.cnpj,
    c.razao_social,
    COUNT(p.id_pedido) AS quantidade_pedidos,
    SUM(p.valor_total) AS total_em_pedidos
FROM CLIENTE c
JOIN PEDIDO p ON p.cnpj_cliente = c.cnpj
WHERE p.status <> 'CANCELADO'
GROUP BY c.cnpj, c.razao_social
ORDER BY total_em_pedidos DESC;

-- 8.5 Consultar cada parcela que a empresa tem a receber.
-- Comparamos o valor original com a soma dos recebimentos já registrados para
-- descobrir quanto ainda falta receber.
SELECT
    cr.id_pedido,
    cr.numero_parcela,
    cr.valor AS valor_original,
    IFNULL(SUM(r.valor_recebido), 0) AS total_recebido,
    cr.valor - IFNULL(SUM(r.valor_recebido), 0) AS saldo_aberto,
    cr.data_vencimento,
    cr.status
FROM CONTAS_A_RECEBER cr
LEFT JOIN RECEBIMENTO r
    ON r.id_pedido = cr.id_pedido
   AND r.numero_parcela = cr.numero_parcela
WHERE cr.status <> 'CANCELADA'
GROUP BY cr.id_pedido, cr.numero_parcela, cr.valor,
         cr.data_vencimento, cr.status
ORDER BY cr.data_vencimento;

-- 8.6 Consultar cada parcela que a empresa precisa pagar.
-- Comparamos o valor original com a soma dos pagamentos já realizados para
-- descobrir quanto ainda falta pagar.
SELECT
    cp.numero_ordem_compra,
    cp.numero_parcela,
    cp.valor AS valor_original,
    IFNULL(SUM(pg.valor_pago), 0) AS total_pago,
    cp.valor - IFNULL(SUM(pg.valor_pago), 0) AS saldo_aberto,
    cp.data_vencimento,
    cp.status
FROM CONTAS_A_PAGAR cp
LEFT JOIN PAGAMENTO pg
    ON pg.numero_ordem_compra = cp.numero_ordem_compra
   AND pg.numero_parcela = cp.numero_parcela
WHERE cp.status <> 'CANCELADA'
GROUP BY cp.numero_ordem_compra, cp.numero_parcela, cp.valor,
         cp.data_vencimento, cp.status
ORDER BY cp.data_vencimento;

-- 8.7 Somar todo o dinheiro recebido entre as datas informadas.
SELECT SUM(valor_recebido) AS total_recebido
FROM RECEBIMENTO
WHERE data_recebimento BETWEEN '2026-11-01' AND '2026-11-30';

-- 8.8 Somar todo o dinheiro pago entre as datas informadas.
SELECT SUM(valor_pago) AS total_pago
FROM PAGAMENTO
WHERE data_pagamento BETWEEN '2026-11-01' AND '2026-11-30';

-- 8.9 Calcular o saldo final do caixa.
-- A conta considera o saldo inicial, soma os recebimentos e subtrai os pagamentos.
-- Com os dados de exemplo: R$ 500 + R$ 300 - R$ 200 = R$ 600.
SELECT
    (SELECT valor_inicial
     FROM SALDO_INICIAL_CAIXA
     WHERE data_referencia = '2026-11-01')
    + IFNULL((SELECT SUM(valor_recebido)
              FROM RECEBIMENTO
              WHERE data_recebimento BETWEEN '2026-11-01' AND '2026-11-30'), 0)
    - IFNULL((SELECT SUM(valor_pago)
              FROM PAGAMENTO
              WHERE data_pagamento BETWEEN '2026-11-01' AND '2026-11-30'), 0)
    AS saldo_final;

-- ============================================================
-- 9. CONSULTAS DE AUDITORIA
-- Estas consultas procuram possíveis diferenças ou situações que merecem
-- conferência. Um resultado não significa necessariamente erro: indica
-- um registro que deve ser analisado.
-- ============================================================
-- Em algumas consultas usamos HAVING porque precisamos comparar o resultado
-- de uma soma com a quantidade ou o valor que foi registrado.

-- 9.1 Verificar se algum produto foi entregue em quantidade maior do que
-- a quantidade registrada no pedido.
SELECT
    ip.id_pedido,
    ip.codigo_produto,
    ip.quantidade AS quantidade_pedida,
    SUM(ms.quantidade) AS quantidade_entregue
FROM ITEM_PEDIDO ip
JOIN MOVIMENTACAO_SAIDA ms
    ON ms.id_pedido = ip.id_pedido
   AND ms.codigo_produto = ip.codigo_produto
GROUP BY ip.id_pedido, ip.codigo_produto, ip.quantidade
HAVING SUM(ms.quantidade) > ip.quantidade;

-- 9.2 Verificar se algum produto foi recebido em quantidade maior do que
-- a quantidade solicitada ao fornecedor.
SELECT
    ic.numero_ordem_compra,
    ic.codigo_produto,
    ic.quantidade AS quantidade_solicitada,
    SUM(me.quantidade) AS quantidade_recebida
FROM ITEM_ORDEM_COMPRA ic
JOIN MOVIMENTACAO_ENTRADA me
    ON me.numero_ordem_compra = ic.numero_ordem_compra
   AND me.codigo_produto = ic.codigo_produto
GROUP BY ic.numero_ordem_compra, ic.codigo_produto, ic.quantidade
HAVING SUM(me.quantidade) > ic.quantidade;

-- 9.3 Verificar se a soma dos recebimentos de alguma parcela ultrapassou
-- o valor que o cliente deveria pagar.
SELECT
    cr.id_pedido,
    cr.numero_parcela,
    cr.valor AS valor_devido,
    SUM(r.valor_recebido) AS valor_recebido
FROM CONTAS_A_RECEBER cr
JOIN RECEBIMENTO r
    ON r.id_pedido = cr.id_pedido
   AND r.numero_parcela = cr.numero_parcela
GROUP BY cr.id_pedido, cr.numero_parcela, cr.valor
HAVING SUM(r.valor_recebido) > cr.valor;

-- 9.4 Listar parcelas a receber marcadas como atrasadas e com vencimento
-- anterior à data atual.
SELECT id_pedido, numero_parcela, valor, data_vencimento, status
FROM CONTAS_A_RECEBER
WHERE status = 'ATRASADA'
  AND data_vencimento < CURDATE();

-- 9.5 Listar parcelas a pagar marcadas como atrasadas e com vencimento
-- anterior à data atual.
SELECT numero_ordem_compra, numero_parcela, valor, data_vencimento, status
FROM CONTAS_A_PAGAR
WHERE status = 'ATRASADA'
  AND data_vencimento < CURDATE();

-- 9.6 Comparar o valor total registrado no pedido com a soma dos itens,
-- descontando o desconto informado. Diferenças precisam ser conferidas.
SELECT
    p.id_pedido,
    p.valor_total AS valor_registrado,
    SUM(ip.quantidade * ip.preco_unitario) - p.desconto AS valor_calculado
FROM PEDIDO p
JOIN ITEM_PEDIDO ip ON ip.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.valor_total, p.desconto
HAVING p.valor_total <> (SUM(ip.quantidade * ip.preco_unitario) - p.desconto);

-- 9.7 Comparar o valor total da ordem de compra com a soma dos seus itens.
-- Diferenças precisam ser conferidas.
SELECT
    oc.numero_ordem_compra,
    oc.valor_total AS valor_registrado,
    SUM(ic.quantidade * ic.preco_unitario) AS valor_calculado
FROM ORDEM_COMPRA oc
JOIN ITEM_ORDEM_COMPRA ic ON ic.numero_ordem_compra = oc.numero_ordem_compra
GROUP BY oc.numero_ordem_compra, oc.valor_total
HAVING oc.valor_total <> SUM(ic.quantidade * ic.preco_unitario);

-- ============================================================
-- 10. EXEMPLOS DE ALTERAÇÃO E EXCLUSÃO DE DADOS
-- Os comandos abaixo demonstram UPDATE e DELETE em registros de teste.
-- Execute-os depois de conferir os dados que serão alterados ou removidos.
-- ============================================================

-- 10.1 Atualizar o preço atual de um produto.
-- O preço que já foi registrado em uma venda ou compra não muda, pois o valor
-- praticado naquela operação fica guardado nas tabelas de itens.
UPDATE PRODUTO
SET preco_venda = 32.00
WHERE codigo_produto = 'ARROZ01';

-- 10.2 Excluir um e-mail de teste.
-- Somente o e-mail indicado será removido. O cadastro da pessoa e os outros
-- dados dela continuarão armazenados.
DELETE FROM PESSOA_EMAIL
WHERE cpf = '00000000002'
  AND email = 'email-temporario@exemplo.com';
