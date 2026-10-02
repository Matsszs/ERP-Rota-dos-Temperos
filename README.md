## 1. Identificação da equipe

**Projeto:** ERP — Rota dos Temperos  
**Disciplina:** Projeto Integrador — Modelagem de Dados

### Integrantes

- Bruno Gomes Tibellio
- Erick Andrade de Peder
- Gabriel Marques Lopes
- Jônata Alves Borsari
- João Frazão Zanon
- Mateus de Lima Monteiro
- Murilo Domingues Saes
- Everton Santos Lima

---

## 2. Caracterização da empresa

A **Rota dos Temperos** é um pequeno negócio familiar do segmento de comércio de temperos e especiarias.

A empresa comercializa diferentes tipos de temperos e produtos relacionados, atendendo principalmente clientes da região.

Atualmente, o negócio possui processos relacionados a vendas, compras, estoque e controle financeiro. Grande parte dessas informações é controlada manualmente, o que dificulta a organização e o acompanhamento das operações.

Os principais setores e áreas envolvidas são:

- Vendas e atendimento;
- Estoque;
- Compras e fornecedores;
- Controle financeiro.

As principais informações utilizadas pelo negócio são dados de clientes, funcionários, fornecedores, produtos, pedidos, compras, movimentações de estoque e contas a receber e a pagar.

---

## 3. Justificativa da escolha do negócio

A Rota dos Temperos foi escolhida por apresentar processos reais e estruturados que podem ser analisados e transformados em um modelo de dados.

O negócio apresenta problemas relacionados ao controle manual das informações, ausência de integração entre processos e dificuldade de acompanhamento de vendas, estoque e informações financeiras.

A empresa também apresenta potencial para utilização de um sistema ERP, permitindo centralizar informações e integrar processos como venda, compra, estoque e financeiro.

Dessa forma, o negócio oferece um contexto adequado para a aplicação dos conceitos de modelagem de dados propostos no projeto.

---

## 4. Problemas e necessidades identificados

Os principais problemas identificados foram:

| Problema | Consequência |
|---|---|
| Controle realizado manualmente | Dificulta o acompanhamento geral do negócio |
| Controle de estoque manual | Estoque desatualizado e risco de vender produtos sem disponibilidade |
| Vendas não integradas ao estoque | Diferença entre o controle e a quantidade realmente disponível |
| Contas a pagar e a receber controladas separadamente | Dificuldade para acompanhar valores financeiros |
| Ausência de histórico organizado de fornecedores e preços de compra | Dificuldade para consultar compras anteriores e comparar valores |

Esses problemas demonstram a necessidade de centralização, organização e integração das informações.

---

## 5. Principais processos de negócio

### 5.1 Processo de venda

Cliente escolhe os produtos → Funcionário verifica estoque → Produto disponível → Pedido é registrado → Estoque é atualizado → Conta a receber é gerada.

Quando o produto não está disponível, o cliente é informado sobre a indisponibilidade.

### 5.2 Processo de compra

Funcionário identifica a necessidade de reposição → Ordem de compra é registrada → Fornecedor realiza a entrega → Produtos são conferidos → Entrada no estoque é registrada → Conta a pagar é gerada.

Quando os produtos entregues não conferem com o pedido, a divergência é registrada e o fornecedor é contatado.

### 5.3 Processo de estoque

O estoque é atualizado a partir das entradas provenientes das compras e das saídas geradas pelas vendas.

As movimentações permitem acompanhar os produtos que entram e saem do estoque.

### 5.4 Processo financeiro

O sistema deve controlar as contas geradas pelas vendas e pelas compras, permitindo acompanhar valores, parcelas, vencimentos, pagamentos e situações em aberto ou atrasadas.

---

## 6. Requisitos funcionais

- **RF01** — O sistema deverá cadastrar, editar e consultar clientes, funcionários, fornecedores e produtos.
- **RF02** — O sistema deverá registrar pedidos de venda com múltiplos produtos.
- **RF03** — O sistema deverá registrar ordens de compra de fornecedores com múltiplos produtos.
- **RF04** — O sistema deverá atualizar o estoque automaticamente a partir das vendas e compras realizadas.
- **RF05** — O sistema deverá gerar contas a receber a partir dos pedidos.
- **RF06** — O sistema deverá gerar contas a pagar a partir das ordens de compra.
- **RF07** — O sistema deverá gerar opções de pagamento conforme as regras do negócio.
- **RF08** — O sistema deverá permitir consultar o histórico de compras de cada cliente.

---

## 7. Requisitos não funcionais

- **RNF01** — O sistema deverá ser acessado por navegador, sem necessidade de instalação local.
- **RNF02** — O sistema deverá controlar o acesso por perfil de usuário.
- **RNF03** — O sistema deverá manter registro das operações realizadas pelos usuários.
- **RNF04** — O sistema deverá apresentar as consultas em tempo adequado para utilização operacional.
- **RNF05** — O sistema deverá realizar backup periódico do banco de dados.

---

## 8. Regras de negócio / operacionais

1. Um pedido/ordem de compra precisa possuir pelo menos um item.
2. O preço unitário em um pedido deve representar o preço praticado naquele momento.
3. Toda venda deverá gerar uma movimentação de saída de estoque por item vendido.
4. Toda ordem de compra recebida deverá gerar uma movimentação de entrada de estoque por item comprado.
5. Uma pessoa pode exercer o papel de cliente, funcionário ou ambos, conforme o modelo adotado.
6. CPF e CNPJ devem ser identificadores únicos.
7. Cada pedido/ordem de compra deve possuir exatamente um funcionário responsável pelo registro.
8. Uma pessoa pode receber apenas um papel de cliente, funcionário ou ambos.
9. Uma conta a receber não deve possuir data de vencimento futura após o vencimento definido pelo pedido.
10. Um pedido pode não possuir cliente identificado quando se tratar de uma venda avulsa.
11. O pagamento de uma ordem de compra pode ocorrer de forma parcelada.

---

## 9. Restrições e políticas organizacionais

- O cancelamento de um pedido já registrado só poderá ser realizado pelo funcionário responsável ou pelo dono.
- O desconto acima do limite definido deverá depender de aprovação.
- A compra com fornecedor deverá ser registrada mediante ordem de compra formal.
- O pagamento só deverá ser considerado realizado mediante confirmação do pagamento.
- Produtos sem estoque não deverão ser considerados disponíveis para venda.

---

## 10. Fluxogramas

Os principais processos do negócio são representados pelos seguintes fluxogramas:

### Venda
Representa o processo desde a escolha dos produtos pelo cliente até o registro do pedido, atualização do estoque e geração da conta a receber.

### Compra
Representa a identificação da necessidade de reposição, registro da ordem de compra, conferência dos produtos recebidos, atualização do estoque e geração da conta a pagar.

### Estoque
Representa as movimentações de entrada e saída dos produtos relacionadas aos processos de compra e venda.

### Financeiro
Representa a geração e o controle das contas a receber e contas a pagar.

---

## 11. Entidades

As principais entidades identificadas no modelo são:

- **PESSOA** — representa os dados comuns de clientes e funcionários.
- **CLIENTE** — representa a pessoa que realiza compras.
- **FUNCIONARIO** — representa o funcionário que atende clientes e registra operações.
- **FORNECEDOR** — representa quem fornece os temperos para a empresa.
- **PRODUTO** — representa cada tempero ou produto comercializado.
- **PEDIDO** — representa uma venda realizada.
- **ORDEM_COMPRA** — representa uma compra realizada junto a um fornecedor.
- **ITEM_PEDIDO** — representa os produtos presentes em um pedido.
- **ITEM_ORDEM_COMPRA** — representa os produtos presentes em uma ordem de compra.
- **MOVIMENTACAO_SAIDA** — representa a saída de estoque provocada por uma venda.
- **MOVIMENTACAO_ENTRADA** — representa a entrada de estoque provocada por uma compra.
- **CONTAS_A_RECEBER** — representa os valores que os clientes devem à empresa.
- **CONTAS_A_PAGAR** — representa os valores que a empresa deve aos fornecedores.

---

## 12. Atributos

Os atributos foram definidos de acordo com as informações necessárias para representar cada entidade do negócio.

Entre os principais atributos estão:

- Identificadores;
- Nome;
- CPF;
- Telefone;
- E-mail;
- Endereço;
- Cargo;
- Data de admissão;
- Salário;
- CNPJ;
- Razão social;
- Categoria;
- Unidade de medida;
- Preço de venda;
- Datas de pedido e compra;
- Status;
- Valores;
- Quantidades;
- Datas de vencimento e pagamento.

O detalhamento completo dos atributos e suas respectivas regras está apresentado no dicionário de dados conceitual.

---

## 13. Relacionamentos

Os principais relacionamentos identificados são:

- PESSOA — assume — CLIENTE
- PESSOA — assume — FUNCIONARIO
- CLIENTE — realiza — PEDIDO
- FUNCIONARIO — atende — PEDIDO
- FUNCIONARIO — registra — ORDEM_COMPRA
- FORNECEDOR — fornece — ORDEM_COMPRA
- PEDIDO — contém — ITEM_PEDIDO
- PRODUTO — é incluído em — ITEM_PEDIDO
- ORDEM_COMPRA — contém — ITEM_ORDEM_COMPRA
- PRODUTO — é adquirido em — ITEM_ORDEM_COMPRA
- ITEM_PEDIDO — gera — MOVIMENTACAO_SAIDA
- ITEM_ORDEM_COMPRA — gera — MOVIMENTACAO_ENTRADA
- PEDIDO — origina — CONTAS_A_RECEBER
- ORDEM_COMPRA — origina — CONTAS_A_PAGAR

---

## 14. Cardinalidades

As cardinalidades foram determinadas considerando os dois sentidos de cada relacionamento e as regras de negócio levantadas.

O modelo apresenta relações 1:1, 1:N e situações em que entidades associativas representam a relação entre pedido/ordem de compra e seus respectivos produtos.

As cardinalidades completas estão representadas no DER e detalhadas na documentação do projeto.

---

## 15. Dicionário de dados conceitual

O dicionário de dados contém:

- Entidade;
- Atributo;
- Descrição;
- Regra/Observação.

Seu objetivo é organizar e explicar os dados utilizados pelo modelo conceitual, permitindo compreender o significado e a finalidade de cada atributo.

---

## 16. Diagrama Entidade-Relacionamento — DER

O DER representa a estrutura conceitual do sistema ERP da Rota dos Temperos, reunindo:

- Entidades;
- Atributos;
- Relacionamentos;
- Cardinalidades;
- Regras de negócio relevantes.

O diagrama foi construído como consequência da análise dos processos, problemas, requisitos e regras de negócio.

---

## 17. Justificativas técnicas

As principais decisões de modelagem foram tomadas com base nos processos e regras identificados na empresa.

A entidade **PESSOA** foi utilizada para concentrar informações comuns a clientes e funcionários, evitando repetição desnecessária de dados.

As entidades **ITEM_PEDIDO** e **ITEM_ORDEM_COMPRA** representam os itens de cada operação, permitindo relacionar pedidos e ordens de compra com múltiplos produtos.

As entidades **MOVIMENTACAO_SAIDA** e **MOVIMENTACAO_ENTRADA** foram utilizadas para registrar as alterações do estoque decorrentes das vendas e compras.

As entidades **CONTAS_A_RECEBER** e **CONTAS_A_PAGAR** permitem representar separadamente os compromissos financeiros gerados pelos pedidos e pelas ordens de compra.

As cardinalidades foram definidas a partir das regras de negócio e analisadas nos dois sentidos dos relacionamentos.

---

## 18. Conclusão

A modelagem desenvolvida para a Rota dos Temperos transforma os principais processos do negócio em uma estrutura organizada de dados.

A análise permitiu identificar os problemas existentes, levantar requisitos, estabelecer regras de negócio e definir as entidades, atributos, relacionamentos e cardinalidades necessárias para representar o funcionamento da empresa.

O DER resultante constitui a base conceitual para as próximas etapas do projeto, que poderão evoluir para o modelo lógico, normalização, modelo físico e implementação do banco de dados.
