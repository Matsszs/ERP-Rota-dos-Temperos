# ERP — Rota dos Temperos

Projeto acadêmico de modelagem e implementação de banco de dados relacional para organizar as informações de vendas, compras, estoque e controle financeiro da empresa Rota dos Temperos.

## 1. Identificação do projeto

**Projeto:** ERP — Rota dos Temperos  
**Disciplina:** Modelagem de Banco de Dados  
**Grupo:** 6 — período noturno  
**Banco de dados:** MySQL

### Integrantes

- Bruno Gomes Tibellio
- Erick Andrade de Peder
- Gabriel Marques Lopes
- Jônata Alves Borsari
- João Frazão Zanon
- Mateus de Lima Monteiro
- Murilo Domingues Saes
- Everton Santos Lima

## 2. Empresa e problema identificado

A Rota dos Temperos é um pequeno negócio familiar que comercializa temperos e especiarias. A operação não possui loja física: as vendas são realizadas pelos familiares, atendendo moradores do bairro e estabelecimentos comerciais, como restaurantes e bares da região.

Atualmente, vendas, compras, estoque e controle financeiro são acompanhados manualmente. Esse processo dificulta consultar as quantidades disponíveis, acompanhar valores em aberto e recuperar o histórico de vendas, compras e fornecedores.

## 3. Solução proposta

O projeto propõe um banco de dados relacional para centralizar os cadastros e relacionar as principais operações do negócio:

- cadastro de pessoas, estabelecimentos clientes, contatos, funcionários, fornecedores e produtos;
- registro de pedidos de venda e seus itens;
- registro de ordens de compra e seus itens;
- controle das entradas e saídas de estoque, inclusive quando ocorrem de forma parcial;
- controle de contas a pagar e a receber, com possibilidade de pagamentos e recebimentos parciais;
- consultas para acompanhar estoque, vendas, compras, valores em aberto e fluxo de caixa.

O escopo implementado nesta etapa é a estrutura do banco de dados e suas consultas SQL. A interface de um ERP acessado pelo navegador e o controle de acesso por usuário não fazem parte do script SQL entregue.

## 4. Organização do banco de dados

O modelo lógico é composto por 20 tabelas, organizadas em cinco grupos.

### Cadastros

`PESSOA`, `PESSOA_TELEFONE`, `PESSOA_EMAIL`, `PESSOA_ENDERECO`, `CLIENTE`, `CLIENTE_CONTATO`, `FUNCIONARIO`, `FORNECEDOR` e `PRODUTO`.

### Vendas e compras

`PEDIDO`, `ITEM_PEDIDO`, `ORDEM_COMPRA` e `ITEM_ORDEM_COMPRA`.

### Estoque

`MOVIMENTACAO_SAIDA` e `MOVIMENTACAO_ENTRADA`.

### Financeiro

`CONTAS_A_RECEBER`, `RECEBIMENTO`, `CONTAS_A_PAGAR`, `PAGAMENTO` e `SALDO_INICIAL_CAIXA`.

### Principais regras representadas

- O estabelecimento comercial cliente é identificado pelo CNPJ. A pessoa física que atua como contato é cadastrada separadamente em `PESSOA`.
- Um pedido pode ser registrado sem CNPJ de cliente, permitindo representar uma venda avulsa.
- O preço unitário registrado no item preserva o valor praticado no momento da venda ou compra.
- Um mesmo item de pedido pode ter várias movimentações de saída; um item de compra pode ter várias movimentações de entrada.
- Uma parcela pode ter mais de um recebimento ou pagamento, preservando cada liquidação realizada.
- O estoque é calculado a partir da quantidade inicial registrada no produto, somando as entradas e subtraindo as saídas posteriores à data da contagem.
- O fluxo de caixa considera o saldo inicial, os recebimentos efetivos e os pagamentos efetivos. Valores ainda em aberto não são tratados como dinheiro já movimentado.

## 5. Modelagem e normalização

O projeto apresenta o DER revisado, o modelo lógico relacional, as chaves primárias (PK), as chaves estrangeiras (FK), as chaves compostas e as restrições utilizadas na implementação.

A normalização é demonstrada até a terceira forma normal:

- **1FN:** telefones, e-mails e endereços de uma pessoa são armazenados em tabelas próprias, com uma ocorrência por registro.
- **2FN:** nas tabelas com chave composta, os atributos dependem da chave completa.
- **3FN:** informações de pessoas, estabelecimentos, produtos, parcelas e liquidações ficam nas tabelas correspondentes, evitando repetição e dependências transitivas inadequadas.

## 6. Implementação e execução do SQL

O banco foi implementado em **MySQL 8.0.16 ou superior**. O script `erp_rota_dos_temperos_mysql.sql` contém:

- criação do banco e das 20 tabelas;
- definição de PK, FK e restrições, como `NOT NULL`, `DEFAULT` e `CHECK`;
- inserção de dados fictícios para teste;
- consultas gerenciais com `SELECT`, `JOIN`, `WHERE` e `GROUP BY`;
- consultas de auditoria para verificar possíveis excessos de movimentação ou liquidação, parcelas atrasadas e diferenças entre os valores dos pedidos/compras e seus itens;
- exemplos de `UPDATE` e `DELETE`.

### Como executar

1. Abra o MySQL Workbench e conecte-se a um servidor MySQL 8.0.16 ou superior.
2. Abra o arquivo `erp_rota_dos_temperos_mysql.sql`.
3. Execute o script completo em um ambiente de teste no qual o banco `erp_rota_temperos` ainda não exista.
4. Atualize a lista de schemas e confira o banco `erp_rota_temperos` e suas tabelas.

**Atenção:** o script utiliza `CREATE DATABASE` sem `IF NOT EXISTS`. Por isso, deve ser executado uma vez em um ambiente de teste sem outro banco com esse nome. Os CPFs, CNPJs, nomes e demais registros inseridos no script são fictícios e servem somente para demonstração.

## 7. Testes realizados

O script foi executado no MySQL Workbench. Na validação da massa de dados, foram conferidos:

- criação das 20 tabelas;
- correspondência entre os valores dos pedidos/compras e a soma de seus itens;
- quantidades entregadas e recebidas em relação às quantidades solicitadas;
- valores recebidos e pagos em relação aos valores das parcelas;
- existência de estoque negativo;
- cálculo do saldo de caixa.

Na massa de teste utilizada, as verificações não apontaram divergências. O exemplo de fluxo de caixa apresentou saldo final de **R$ 600,00**, calculado a partir de saldo inicial de R$ 500,00, recebimentos de R$ 300,00 e pagamentos de R$ 200,00.

## 8. Consultas gerenciais e auditoria

As consultas gerenciais respondem perguntas relacionadas a:

- saldo atual e produtos no estoque mínimo ou abaixo dele;
- produtos com maior quantidade vendida;
- quantidade e valor de pedidos por estabelecimento cliente;
- saldo em aberto de parcelas a receber e a pagar;
- valores recebidos, pagos e saldo do caixa em determinado período.

As consultas de auditoria procuram situações que precisam ser conferidas, como entregas ou recebimentos acima da quantidade solicitada, liquidações acima do valor devido, parcelas vencidas e diferenças entre os valores dos pedidos/compras e a soma de seus itens.

## 9. Indicadores e possibilidades de evolução

Os dados organizados podem apoiar indicadores de estoque, produtos mais vendidos, vendas por estabelecimento, vencimentos e fluxo de caixa.

Como evolução futura, o histórico de vendas poderá ser utilizado para estudar a previsão de demanda por produto. Essa previsão com Inteligência Artificial é uma possibilidade de evolução e **não está implementada no script atual**. O mesmo vale para a construção de dashboards de BI: são possibilidades de análise a partir dos dados estruturados.

## 10. Arquivos do repositório

| Arquivo | Descrição |
|---|---|
| `ERP_Rota_dos_Temperos_Entrega_Final.pdf` | Documentação técnica da entrega final. |
| `DER_atualizado.png` | Diagrama Entidade-Relacionamento atualizado. |
| `DER_revisado.mmd` | Código-fonte do diagrama em Mermaid. |
| `dicionario_dados_revisado.csv` | Dicionário de dados atualizado. |
| `erp_rota_dos_temperos_mysql.sql` | Script de criação, dados de teste e consultas SQL. |
| `Fluxograma_Venda.png` | Fluxograma do processo de venda. |
| `Fluxograma_Compra.png` | Fluxograma do processo de compra. |
| `Fluxograma_Estoque.png` | Fluxograma do processo de estoque. |
| `Fluxograma_Financeiro.png` | Fluxograma do processo financeiro. |

Os arquivos devem ser mantidos na raiz do repositório com esses nomes para que os links e referências do README sejam localizados corretamente.

## 11. Conclusão

O projeto transforma os principais processos da Rota dos Temperos em uma estrutura relacional organizada, com cadastros, vendas, compras, movimentações de estoque e controle financeiro. A revisão do modelo e os testes realizados permitem demonstrar como os dados se relacionam e como as consultas SQL podem apoiar o acompanhamento das operações do negócio.
