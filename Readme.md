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

O banco foi implementado em **MySQL 8.0.16 ou superior**. Para facilitar a execução e a demonstração, os comandos SQL foram separados em quatro arquivos, na ordem abaixo:

| Ordem | Arquivo | Conteúdo |
|---|---|---|
| 1 | `sql/01_criacao_banco.sql` | Cria o banco e as 20 tabelas, sem inserir registros. |
| 2 | `sql/02_carga_valida.sql` | Insere dados fictícios válidos para testar cadastros, vendas, compras, estoque e financeiro. |
| 3 | `sql/03_carga_invalida.sql` | Apresenta tentativas de inserção que devem ser bloqueadas pelas restrições do banco. Execute cada tentativa separadamente. |
| 4 | `sql/04_consultas.sql` | Reúne consultas gerenciais, consultas de auditoria e exemplos de `UPDATE` e `DELETE`. |

### Como executar

1. Conecte-se a um servidor MySQL 8.0.16 ou superior.
2. Execute `01_criacao_banco.sql` em um ambiente de teste no qual o banco `erp_rota_temperos` ainda não exista. Esse arquivo cria a estrutura vazia.
3. Execute `02_carga_valida.sql` uma única vez para inserir os dados fictícios.
4. Execute cada `INSERT` de `03_carga_invalida.sql` separadamente. O resultado esperado é que o MySQL rejeite as três tentativas por violação de `CHECK`, chave estrangeira (`FOREIGN KEY`) e `NOT NULL`.
5. Execute `04_consultas.sql` para visualizar as consultas gerenciais e de auditoria. Os comandos `UPDATE` e `DELETE` estão no final desse arquivo como exemplos sobre registros de teste.

**Atenção:** `01_criacao_banco.sql` utiliza `CREATE DATABASE` sem `IF NOT EXISTS`. Portanto, deve ser executado uma vez em um ambiente em que ainda não exista um banco com esse nome. A carga válida também deve ser executada uma única vez para evitar duplicidade de registros. Os CPFs, CNPJs, nomes e demais registros inseridos são fictícios e servem somente para demonstração.

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

## 10. Organização do repositório

Os arquivos estão organizados em pastas para facilitar a consulta:

```text
ERP-Rota-dos-Temperos/
├── README.md
├── docs/
│   ├── ERP_Rota_dos_Temperos_Entrega_Final.pdf
│   ├── DER_atualizado.png
│   └── dicionario_dados_revisado.csv
├── sql/
│   ├── 01_criacao_banco.sql
│   ├── 02_carga_valida.sql
│   ├── 03_carga_invalida.sql
│   └── 04_consultas.sql
└── evidencias/
    ├── 01-criacao-banco-vazio.png
    ├── 02-carga-valida.png
    ├── 03-carga-invalida.png
    └── 04-consultas-gerenciais-auditoria.png
```

O histórico de commits do repositório registra a evolução dos arquivos. As evidências de execução mostram a criação das tabelas, os relacionamentos consultados e os testes de integridade realizados no MySQL Workbench.

## 11. Conclusão

O projeto transforma os principais processos da Rota dos Temperos em uma estrutura relacional organizada, com cadastros, vendas, compras, movimentações de estoque e controle financeiro. A revisão do modelo e os testes realizados permitem demonstrar como os dados se relacionam e como as consultas SQL podem apoiar o acompanhamento das operações do negócio.
